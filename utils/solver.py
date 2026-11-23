#!/usr/bin/env python3
"""clingu solver for the eVTOL scheduling model.

Default (PRE-SOLVE strategy): compute a per-aircraft segment cap max_seg(D,M)
before solving -- a random partition summing to avg*nb_agents, with larger caps on
lower-indexed agents (symmetry break) -- inject it as facts, and solve
examples/evtol_presolve.lp (droppable segments) via the clingu `clingcon` module.
This is the best configuration found: removing the
in-solve max_seg choice collapses first-feasible time and raises yield.

--no-presolve solves the free-choice baseline examples/evtol.lp instead.

Writes a JSON run record (trace of improving models, revenue = -cost[0],
passengers, status).

Run with the python that hosts the clingu .so (cpython-3.13; the build prints
which interpreter it built for). Set CLINGCU_PY if libpyclingcon is elsewhere:

  "$CLINGU_PY" utils/solver.py \
      --instance exp/instances/network-ny_0_pax420_*horizon180.lp \
      --time-limit 300
"""

import argparse
import json
import os
import random
import re
import sys
import time
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
_PRJ_ROOT = os.path.dirname(HERE)            # repo root

# The clingu module lives outside the repo (built by clingu-c/build_clingu.sh).
CLINGCU_PY = os.environ.get(
    "CLINGCU_PY", os.path.expanduser("~/clingu-build/clingcon/libpyclingcon"))
if CLINGCU_PY not in sys.path:
    sys.path.insert(0, CLINGCU_PY)

from clingo import Control  # noqa: E402
from clingo import ast      # noqa: E402

try:
    from clingcon import ClingconTheory  # noqa: E402  (this is the clingu build)
except ImportError as exc:  # pragma: no cover
    sys.exit(
        f"cannot import the clingu `clingcon` module from {CLINGCU_PY}: {exc}\n"
        f"Build it with clingu-c/build_clingu.sh, run this with the "
        f"matching python (the .so is cpython-version-specific), or set CLINGCU_PY.")


def enforce_no_sat_prepro(args):
    """Force `--sat-prepro=no` on any clasp arg list before it reaches Control().

    Before the condition-watch fix of 2026-07-07, SAT preprocessing could eliminate
    unshown condition atoms and leave the &cumu constraint unenforced. The fix removes that problem; the
    setting is kept so that the solver configuration is fixed. Removes any
    `--sat-prepro[=...]` given by the caller (including the one implied by a
    `--configuration` preset) and appends `--sat-prepro=no` last, so that it takes
    precedence over such a preset."""
    out = [a for a in args if a != "--sat-prepro" and not a.startswith("--sat-prepro=")]
    out.append("--sat-prepro=no")
    return out


_EXAMPLES = os.path.join(_PRJ_ROOT, "clingu-c", "examples")
ENCODING_PRESOLVE = os.path.join(_EXAMPLES, "evtol_presolve.lp")
ENCODING_BASE = os.path.join(_EXAMPLES, "evtol.lp")
ENCODING = ENCODING_BASE  # back-compat alias (e.g. verify_throughput default)
DEFAULT_OUT = os.path.join(_PRJ_ROOT, "results", "runs")

# clingu evtol predicate shapes: route((o,d),D,X) ; passengers(P,D,X).
FLIGHT_PREDICATES = ("route", "passengers")
_DIST_RE = re.compile(r"distance\(\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*,\s*(\d+)\s*\)")
_REQ_RE = re.compile(
    r"initial_request\(\s*\d+\s*,\s*\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*,\s*(\d+)\s*\)")
_ROUTE_RE = re.compile(
    r"route\(\(\s*(\w+)\s*,\s*(\w+)\s*\)\s*,\s*(\w+)\s*,\s*(\w+)\s*\)")
_CAP_RE = re.compile(r"capacity\(\s*\w+\s*,\s*(\d+)\s*\)")
_META_BEGIN = "--- BEGIN INSTANCE METADATA ---"
_META_END = "--- END INSTANCE METADATA ---"

CONFIGS = {"noheur": False, "domain": True}


# --------------------------------------------------------------------------- #
# instance parsing
# --------------------------------------------------------------------------- #
def parse_instance_metadata(path):
    """Parse the `% k: v` metadata header (stdlib only; avoids importing
    gen_instance, which pulls numpy absent from the clingu python env)."""
    meta, in_block = {}, False
    with open(path) as f:
        for line in f:
            if _META_BEGIN in line:
                in_block = True
                continue
            if _META_END in line:
                break
            if in_block and line.startswith("%") and ":" in line:
                k, _, v = line.lstrip("%").strip().partition(":")
                meta[k.strip()] = v.strip()
    return meta


def parse_nb_agents(instance_text, metadata):
    if metadata.get("nb_agents"):
        try:
            return int(metadata["nb_agents"])
        except ValueError:
            pass
    m = re.search(r"agent\(\s*0\.\.\s*(\d+)\s*\)", instance_text)
    if m:
        return int(m.group(1)) + 1
    return len(set(re.findall(r"\bagent\(\s*(\w+)\s*\)", instance_text)))


def max_revenue(instance_text):
    """Upper bound on passenger-miles if every requested passenger is served."""
    dist = {(o, d): int(s) for o, d, s in _DIST_RE.findall(instance_text) if o != d}
    rev = 0
    for o, d, p in _REQ_RE.findall(instance_text):
        if o != d:
            rev += dist.get((o, d), 0) * int(p)
    return rev


# --------------------------------------------------------------------------- #
# pre-solve per-aircraft segment estimate
# --------------------------------------------------------------------------- #
def estimate_maxseg(nb_agents, avg, lo, hi, seed):
    """Random partition of avg*nb_agents into nb_agents parts in [lo,hi], sorted
    descending (larger caps -> lower-indexed agents = canonical, symmetry-broken)."""
    total = avg * nb_agents
    total = max(lo * nb_agents, min(hi * nb_agents, total))  # clamp into band
    rng = random.Random(seed)
    parts = [lo] * nb_agents
    for _ in range(total - lo * nb_agents):
        parts[rng.choice([i for i in range(nb_agents) if parts[i] < hi])] += 1
    return sorted(parts, reverse=True)


def maxseg_facts(parts):
    return "".join(f"max_seg({d},{m}).\n" for d, m in enumerate(parts))


# --------------------------------------------------------------------------- #
# solving
# --------------------------------------------------------------------------- #
def _model_symbols(model):
    syms = list(model.symbols(shown=True))
    return syms if syms else list(model.symbols(atoms=True))


def _count_pax(symbols):
    # passengers(P,D,X): carried count is the FIRST argument
    return sum(s.arguments[0].number for s in symbols if s.name == "passengers")


def _extract_atoms(symbols):
    return [str(s) for s in symbols if s.name in FLIGHT_PREDICATES]


def run_solve(encoding_src, instance_src, time_limit, use_domain, consts,
              cumu_explanation=None):
    """One clingu optimization solve; returns status/trace/atoms/cost."""
    args = ["--warn=no-atom-undefined"]
    # Charging physics.  Every encoding in this project now carries a
    # `#const charge_model` switch (duration16 = legacy ny_0 1.6x rule,
    # soc = the current state-of-charge table).  Stamping it here means the
    # solver and check_schedule.py -- which reads the same variable -- can
    # never disagree about the physics a plan was built under.
    if not any(k == "charge_model" for k, _ in consts):
        consts = list(consts) + [
            ("charge_model", os.environ.get("PORC_CHARGE_MODEL") or "duration16")]
    for k, v in consts:
        args += ["-c", f"{k}={v}"]
    if use_domain:
        args.append("--heuristic=Domain")
    args = enforce_no_sat_prepro(args)

    theory = ClingconTheory()
    ctl = Control(args)
    theory.register(ctl)
    if cumu_explanation:
        # form of the clauses the &cumu propagator emits: pointwise | bigstep | naive | mixed
        theory.configure("cumu-explanation", cumu_explanation)
    with ast.ProgramBuilder(ctl) as bld:
        ast.parse_string(encoding_src + "\n" + instance_src,
                         lambda stm: theory.rewrite_ast(stm, bld.add))
    ctl.ground([("base", [])])
    theory.prepare(ctl)

    trace = []
    state = {"atoms": [], "cost": None}
    t0 = time.time()

    def on_model(m):
        theory.on_model(m)
        symbols = _model_symbols(m)
        state["atoms"] = _extract_atoms(symbols)
        state["cost"] = list(m.cost)
        trace.append({
            "time_s": round(time.time() - t0, 3),
            "cost": list(m.cost),
            "revenue": -m.cost[0] if m.cost else 0,
            "passengers_served": _count_pax(symbols),
        })

    with ctl.solve(on_model=on_model, async_=True) as hnd:
        finished = hnd.wait(time_limit)
        if not finished:
            hnd.cancel()
        res = hnd.get()
    wall = time.time() - t0

    if res.satisfiable and res.exhausted:
        status = "OPTIMUM_FOUND"
    elif res.satisfiable:
        status = "SATISFIABLE" if finished else "TIMEOUT"
    elif res.unsatisfiable:
        status = "UNSATISFIABLE"
    else:
        status = "UNKNOWN"

    return {
        "status": status,
        "wall_time_s": round(wall, 3),
        "trace": trace,
        "atoms": "\n".join(a + "." for a in state["atoms"]),
        "final_cost": state["cost"],
    }


def run(instance_path, time_limit, config="domain", presolve=True, avg=10, lo=5,
        hi=15, seed=0, encoding_path=None, out_dir=DEFAULT_OUT, overwrite=False,
        cumu_explanation=None):
    """Solve one instance (pre-solve estimate by default). Returns (out_path,
    skipped, record)."""
    stem = os.path.splitext(os.path.basename(instance_path))[0]
    tag = (f"presolve_{config}" if presolve else config)
    if cumu_explanation and cumu_explanation != "pointwise":
        tag += f"_{cumu_explanation}"   # keep runs with another form in their own file
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{stem}__{tag}.json")
    if os.path.exists(out_path) and not overwrite:
        return out_path, True, None

    enc_path = encoding_path or (ENCODING_PRESOLVE if presolve else ENCODING_BASE)
    with open(enc_path) as f:
        enc = f.read()
    with open(instance_path) as f:
        inst = f.read()

    meta = parse_instance_metadata(instance_path)
    nb = parse_nb_agents(inst, meta)
    max_rev = max_revenue(inst)

    parts = None
    program_inst = inst
    if presolve:
        parts = estimate_maxseg(nb, avg, lo, hi, seed)
        program_inst = (inst + "\n% --- pre-solve per-aircraft segment caps ---\n"
                        + maxseg_facts(parts))

    consts = []
    if meta.get("horizon"):
        consts.append(("horizon", meta["horizon"]))

    result = run_solve(enc, program_inst, time_limit, CONFIGS[config], consts,
                       cumu_explanation=cumu_explanation)
    record = {
        "instance": stem,
        "instance_metadata": meta,
        "config": tag,
        "time_limit_s": time_limit,
        "cumu_explanation": cumu_explanation or "pointwise",
        "max_revenue": max_rev,
        "nb_agents": nb,
        **result,
    }
    if parts is not None:
        record["maxseg_partition"] = parts
        record["maxseg_seed"] = seed
    with open(out_path, "w") as f:
        json.dump(record, f, indent=2)
    return out_path, False, record


def print_run_summary(record):
    if record.get("maxseg_partition"):
        print(f"  caps: {record['maxseg_partition']}")
    fin = [e for e in record["trace"] if e.get("revenue") is not None]
    tot = int(record["instance_metadata"].get("total_passengers") or 0)
    mr = record["max_revenue"] or 0
    if fin:
        l = fin[-1]
        msg = (f"  status={record['status']} wall={record['wall_time_s']}s "
               f"profit={l['revenue']}")
        if mr:
            msg += f" rev-yield={100*l['revenue']/mr:.1f}%"
        print(msg)
        if tot:
            print(f"  served={l['passengers_served']}/{tot} "
                  f"({100*l['passengers_served']/tot:.1f}%)  "
                  f"first-model={fin[0]['time_s']}s  models={len(fin)}")
    else:
        print(f"  status={record['status']} -- no feasible model")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--instance", required=True)
    p.add_argument("--time-limit", type=int, default=300)
    p.add_argument("--config", default="domain", choices=list(CONFIGS))
    p.add_argument("--no-presolve", action="store_true",
                   help="solve the free-choice baseline evtol.lp (no segment estimate)")
    p.add_argument("--avg", type=int, default=10, help="avg segments/aircraft (total = avg*n)")
    p.add_argument("--lo", type=int, default=5)
    p.add_argument("--hi", type=int, default=15)
    p.add_argument("--seed", type=int, default=0, help="seed for the segment partition")
    p.add_argument("--out-dir", default=DEFAULT_OUT)
    p.add_argument("--encoding", default=None, help="override the encoding .lp")
    p.add_argument("--overwrite", action="store_true")
    p.add_argument("--cumu-explanation", default=None,
                   choices=["pointwise", "bigstep", "naive", "mixed"],
                   help="form of the clauses emitted for &cumu (default: pointwise)")
    args = p.parse_args()

    presolve = not args.no_presolve
    tag = f"presolve_{args.config}" if presolve else args.config
    print(f"[solver] {os.path.basename(args.instance)} :: {tag} "
          f":: {args.time_limit}s" + (f" :: seed {args.seed}" if presolve else ""),
          flush=True)
    out_path, skipped, record = run(
        args.instance, args.time_limit, config=args.config, presolve=presolve,
        avg=args.avg, lo=args.lo, hi=args.hi, seed=args.seed,
        encoding_path=args.encoding, out_dir=args.out_dir, overwrite=args.overwrite,
        cumu_explanation=args.cumu_explanation)
    if skipped:
        print(f"[skip] -> {out_path}")
        return
    print(f"[done] -> {out_path}")
    print_run_summary(record)


if __name__ == "__main__":
    main()
