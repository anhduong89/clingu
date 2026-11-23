#!/usr/bin/env python3
"""Solve one instance with clingu and DUMP THE FULL SCHEDULE as ground atoms,
including the theory-assigned takeoff/landing times (which solver.py's JSON drops
because they are not #shown). Output feeds utils/check_schedule.py (P0-1).

This is the *producer* side: it reuses solver.py's clingu setup on purpose --
the checker is the thing that must be independent, not the generator.

Run with the clingu python (see utils/solver.py header), e.g.:
  "$CLINGU_PY" utils/gen_schedule.py \
      --instance <pax420>.lp --time-limit 45 --out schedule.lp
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import solver as S  # noqa: E402  -- provides Control, ast, ClingconTheory + helpers


def solve_capture(enc_src, program_inst, time_limit, consts, use_domain=True):
    """Run one clingu optimization and capture the best model's route/passengers
    atoms AND the theory takeoff/landing times. Returns (best, res). Encoding-agnostic
    -- pass the baseline, presolve, or seeded (evtol-open-evolve-drop.lp) encoding."""
    args = ["--warn=no-atom-undefined"]
    # Third entry point into clingu (after solver.run_solve and run_one.py's own
    # Control).  Each has to stamp the charging physics itself or the encoding
    # falls back to its #const default -- which is how a benchmark came to run
    # the legacy 1.6x rule in some arms and SoC in others.
    if not any(k == "charge_model" for k, _ in consts):
        consts = list(consts) + [
            ("charge_model", os.environ.get("PORC_CHARGE_MODEL") or "duration16")]
    for k, v in consts:
        args += ["-c", f"{k}={v}"]
    if use_domain:
        args.append("--heuristic=Domain")
    # Optional multi-threaded clasp: set CLINGCU_THREADS=N (parallel search, best
    # incumbent kept). The Domain heuristic needs a lookback-enabled config on EVERY
    # thread, so clasp's default/diverse ("many") portfolio errors with
    # "Heuristic requires lookback strategy"; force a single named config across all
    # threads (jumpy) instead. CLINGCU_CONFIG overrides the config name (also usable
    # at 1 thread as a control). Default (both unset) reproduces the historical
    # single-threaded default-config behaviour exactly, so the 82% baseline stands.
    _threads = int(os.environ.get("CLINGCU_THREADS", "1") or "1")
    _config = os.environ.get("CLINGCU_CONFIG", "").strip()
    if _threads > 1:
        args.append(f"-t{_threads}")
        if not _config:
            _config = "jumpy"
    if _config:
        args.append(f"--configuration={_config}")
    # Arbitrary extra clasp flags (space-separated), e.g. CLINGCU_EXTRA_ARGS="--sat-prepro=no".
    _extra = os.environ.get("CLINGCU_EXTRA_ARGS", "").split()
    args.extend(_extra)
    args = S.enforce_no_sat_prepro(args)  # SAT-prepro breaks &cumu; hard-disable (see solver.py)

    theory = S.ClingconTheory()
    ctl = S.Control(args)
    theory.register(ctl)
    with S.ast.ProgramBuilder(ctl) as bld:
        S.ast.parse_string(enc_src + "\n" + program_inst,
                           lambda st: theory.rewrite_ast(st, bld.add))
    ctl.ground([("base", [])])
    theory.prepare(ctl)

    best = {"cost": None, "routes": [], "pax": [], "takeoff": {}, "landing": {}}

    def on_model(m):
        theory.on_model(m)
        routes, pax = [], []
        for s in m.symbols(shown=True):
            if s.name == "route" and len(s.arguments) == 3:
                e = s.arguments[0]
                routes.append((str(e.arguments[0]), str(e.arguments[1]),
                               str(s.arguments[1]), int(str(s.arguments[2]))))
            elif s.name == "passengers" and len(s.arguments) == 3:
                pax.append((int(str(s.arguments[0])), str(s.arguments[1]),
                            int(str(s.arguments[2]))))
        tk, ld = {}, {}
        for s, v in theory.assignment(m.thread_id):
            if s.name in ("takeoff", "landing") and len(s.arguments) == 3:
                key = (str(s.arguments[0]), str(s.arguments[1]),
                       int(str(s.arguments[2])))
                (tk if s.name == "takeoff" else ld)[key] = int(v)
        best.update(cost=list(m.cost), routes=routes, pax=pax, takeoff=tk, landing=ld)

    with ctl.solve(on_model=on_model, async_=True) as hnd:
        finished = hnd.wait(time_limit)
        if not finished:
            hnd.cancel()
        res = hnd.get()
    return best, res


def status_of(res):
    return ("OPTIMUM" if res.satisfiable and res.exhausted else
            "SAT/TIMEOUT" if res.satisfiable else
            "UNSAT" if res.unsatisfiable else "UNKNOWN")


def generate(instance_path, time_limit, presolve=True, seed=0, avg=10, lo=5, hi=15):
    with open(instance_path) as f:
        inst = f.read()
    enc_path = S.ENCODING_PRESOLVE if presolve else S.ENCODING_BASE
    with open(enc_path) as f:
        enc = f.read()

    meta = S.parse_instance_metadata(instance_path)
    nb = S.parse_nb_agents(inst, meta)
    max_rev = S.max_revenue(inst)

    program_inst = inst
    parts = None
    if presolve:
        parts = S.estimate_maxseg(nb, avg, lo, hi, seed)
        program_inst = inst + "\n" + S.maxseg_facts(parts)

    consts = [("horizon", meta["horizon"])] if meta.get("horizon") else []
    best, res = solve_capture(enc, program_inst, time_limit, consts)
    rev = -best["cost"][0] if best["cost"] else None
    return best, status_of(res), rev, max_rev, parts


def write_schedule(path, best, status, rev, max_rev, instance_path):
    lines = [
        f"% schedule for {os.path.basename(instance_path)}",
        f"% status={status}  revenue={rev}  max_revenue={max_rev}"
        f"  yield={100*rev/max_rev:.1f}%" if rev is not None else f"% status={status}",
        "%",
        "% route((from,to),agent,seg).   passengers(P,agent,seg).",
        "% takeoff(vertiport,agent,seg,time).  landing(vertiport,agent,seg,time).",
        "",
    ]
    for o, d, D, X in sorted(best["routes"], key=lambda r: (str(r[2]), r[3])):
        lines.append(f"route(({o},{d}),{D},{X}).")
    for P, D, X in sorted(best["pax"], key=lambda r: (str(r[1]), r[2])):
        lines.append(f"passengers({P},{D},{X}).")
    for (V, D, X), T in sorted(best["takeoff"].items(), key=lambda kv: (str(kv[0][1]), kv[0][2], str(kv[0][0]))):
        lines.append(f"takeoff({V},{D},{X},{T}).")
    for (V, D, X), T in sorted(best["landing"].items(), key=lambda kv: (str(kv[0][1]), kv[0][2], str(kv[0][0]))):
        lines.append(f"landing({V},{D},{X},{T}).")
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--instance", required=True)
    p.add_argument("--time-limit", type=int, default=45)
    p.add_argument("--no-presolve", action="store_true")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--out", required=True)
    args = p.parse_args()

    best, status, rev, max_rev, parts = generate(
        args.instance, args.time_limit, presolve=not args.no_presolve, seed=args.seed)
    write_schedule(args.out, best, status, rev, max_rev, args.instance)
    print(f"[gen_schedule] status={status} revenue={rev} "
          f"routes={len(best['routes'])} -> {args.out}")


if __name__ == "__main__":
    main()
