#!/usr/bin/env python3
"""P0-1: independent feasibility checker for an eVTOL schedule (answer set).

Input:  an instance .lp  +  a schedule .lp of ground atoms
            route((from,to),Agent,Seg).      passengers(P,Agent,Seg).
            takeoff(Vertiport,Agent,Seg,T).  landing(Vertiport,Agent,Seg,T).
        (produce the schedule with utils/gen_schedule.py, which dumps the
         theory-assigned times that solver.py's JSON omits.)

This checker is deliberately SELF-CONTAINED: it re-implements every rule from
scratch and imports nothing from solver.py / throughput.py, so a shared
misunderstanding of window/charge semantics cannot pass both the solver and its
check. It asserts, independently:

  1. routing   -- first leg departs init_loc; segments 1..k contiguous; legs connect
  2. demand    -- per-edge passengers <= demand; none on demand-less edges; 0<=P<=cap
  3. flight    -- landing - takeoff >= flight_time  (>= for clingu output);
                  --charge-model paper: landing - takeoff == flight_time
  4. charge    -- 13*takeoff_x - 8*landing_x - 5*landing_{x-1} >= 0   (== gap>=ceil(1.6*dur));
                  --charge-model paper: takeoff_x - landing_{x-1} >= charge_time(edge_x)
  5. horizon   -- takeoff >= 0 and landing <= horizon
  6. vertiport -- <= cap ops in any width-w window (half-open [t,t+w)) per vertiport
  7. revenue   -- recompute sum(P * distance) and compare to the claimed value

Exit code 0 iff every check passes AND recomputed revenue matches. Constants
(cap, window_length, horizon) default to evtol.lp's (#const cap=5, window=15,
horizon=180); override for cap-2 / small instances.
"""
import argparse
import math
import os
import re
import sys
from collections import defaultdict

# ---------------------------------------------------------------- parsing ----
# strip ASP rules (anything with ':-') and comments; keep ground facts only.
def _facts(text):
    out = []
    for line in text.splitlines():
        line = line.split("%", 1)[0].strip()
        if not line or ":-" in line:
            continue
        out.append(line)
    return "\n".join(out)


_EDGE = r"\(\s*([\w']+)\s*,\s*([\w']+)\s*\)"          # ((from,to))
_ID = r"([\w']+)"                                       # agent / vertiport / int


_DEFAULT_CHARGE_MODEL = os.environ.get("PORC_CHARGE_MODEL") or "duration16"


def parse_instance(text):
    t = _facts(text)
    cap = {m[0]: int(m[1]) for m in
           re.findall(r"\bcapacity\(\s*" + _ID + r"\s*,\s*(\d+)\s*\)", t)}
    init = {m[0]: m[1] for m in
            re.findall(r"\binit_loc\(\s*" + _ID + r"\s*,\s*" + _ID + r"\s*\)", t)}
    dist = {(m[0], m[1]): int(m[2]) for m in
            re.findall(r"\bdistance\(\s*" + _EDGE + r"\s*,\s*(\d+)\s*\)", t)}
    ftime = {(m[0], m[1]): int(m[2]) for m in
             re.findall(r"\bflight_time\(\s*" + _EDGE + r"\s*,\s*(\d+)\s*\)", t)}
    ctime = {(m[0], m[1]): int(m[2]) for m in
             re.findall(r"\bcharge_time\(\s*" + _EDGE + r"\s*,\s*(\d+)\s*\)", t)}
    # demand: initial_request(N,(o,d),W) or request(N,(o,d),W). Keep the tightest.
    demand = {}
    for m in re.findall(r"\b(?:initial_)?request\(\s*[\w']+\s*,\s*" + _EDGE
                        + r"\s*,\s*(\d+)\s*\)", t):
        e, w = (m[0], m[1]), int(m[2])
        demand[e] = min(w, demand.get(e, w))
    return {"cap": cap, "init": init, "dist": dist, "ftime": ftime, "ctime": ctime,
            "demand": demand}


def parse_schedule(text):
    t = _facts(text)
    routes = {}   # (agent, seg) -> (o, d)
    for m in re.findall(r"\broute\(\s*" + _EDGE + r"\s*,\s*" + _ID + r"\s*,\s*(\d+)\s*\)", t):
        routes[(m[2], int(m[3]))] = (m[0], m[1])
    pax = {}      # (agent, seg) -> P
    for m in re.findall(r"\bpassengers\(\s*(\d+)\s*,\s*" + _ID + r"\s*,\s*(\d+)\s*\)", t):
        pax[(m[1], int(m[2]))] = int(m[0])
    tk, ld = {}, {}   # (vertiport, agent, seg) -> time
    for name, tgt in (("takeoff", tk), ("landing", ld)):
        for m in re.findall(r"\b" + name + r"\(\s*" + _ID + r"\s*,\s*" + _ID
                            + r"\s*,\s*(\d+)\s*,\s*(-?\d+)\s*\)", t):
            tgt[(m[0], m[1], int(m[2]))] = int(m[3])
    return {"routes": routes, "pax": pax, "takeoff": tk, "landing": ld}


# ---------------------------------------------------------------- checks -----
class Checker:
    def __init__(self, inst, sched, cap, window, horizon):
        self.i, self.s = inst, sched
        self.cap, self.w, self.H = int(cap), int(window), int(horizon)
        self.fails = []           # (check, message)

    def fail(self, chk, msg):
        self.fails.append((chk, msg))

    def _agents_segs(self):
        by = defaultdict(list)
        for (D, X) in self.s["routes"]:
            by[D].append(X)
        for D in by:
            by[D].sort()
        return by

    def c1_routing(self):
        for D, segs in self._agents_segs().items():
            if segs != list(range(1, len(segs) + 1)):
                self.fail(1, f"agent {D}: segments not contiguous 1..k: {segs}")
            o1, _ = self.s["routes"][(D, 1)]
            init = self.i["init"].get(D)
            if init is not None and o1 != init:
                self.fail(1, f"agent {D}: first leg departs {o1}, init_loc is {init}")
            for X in segs[:-1]:
                if (D, X + 1) not in self.s["routes"]:
                    continue
                _, d = self.s["routes"][(D, X)]
                o2, _ = self.s["routes"][(D, X + 1)]
                if d != o2:
                    self.fail(1, f"agent {D}: leg {X} ends {d} but leg {X+1} starts {o2}")

    def c2_demand(self):
        served = defaultdict(int)
        for (D, X), e in self.s["routes"].items():
            P = self.s["pax"].get((D, X), 0)
            cap = self.i["cap"].get(D)
            if cap is not None and not (0 <= P <= cap):
                self.fail(2, f"agent {D} leg {X}: P={P} out of [0,{cap}]")
            if P > 0 and e not in self.i["demand"]:
                self.fail(2, f"agent {D} leg {X}: {P} pax on no-demand edge {e}")
            served[e] += P
        for e, tot in served.items():
            dem = self.i["demand"].get(e)
            if dem is not None and tot > dem:
                self.fail(2, f"edge {e}: served {tot} > demand {dem}")

    def _off(self, o, D, X):
        return self.s["takeoff"].get((o, D, X))

    def _land(self, d, D, X):
        return self.s["landing"].get((d, D, X))

    def c3_flight(self):
        for (D, X), (o, d) in self.s["routes"].items():
            t_off, t_land = self._off(o, D, X), self._land(d, D, X)
            if t_off is None or t_land is None:
                self.fail(3, f"agent {D} leg {X} ({o}->{d}): missing takeoff/landing time")
                continue
            ft = self.i["ftime"].get((o, d))
            paper = getattr(self, "charge_model", _DEFAULT_CHARGE_MODEL) == "paper"
            if ft is not None and (t_land - t_off) < ft:
                self.fail(3, f"agent {D} leg {X} ({o}->{d}): "
                             f"duration {t_land-t_off} < flight_time {ft}")
            elif paper and ft is not None and (t_land - t_off) != ft:
                self.fail(3, f"agent {D} leg {X} ({o}->{d}): "
                             f"duration {t_land-t_off} != flight_time {ft} (paper: equality)")

    def c4_charge(self):
        for D, segs in self._agents_segs().items():
            for X in segs:
                if X < 2 or (D, X - 1) not in self.s["routes"]:
                    continue
                o, d = self.s["routes"][(D, X)]
                t_off_x, t_land_x = self._off(o, D, X), self._land(d, D, X)
                t_land_prev = self._land(o, D, X - 1)   # landed at o on prev leg
                if None in (t_off_x, t_land_x, t_land_prev):
                    self.fail(4, f"agent {D} leg {X}: missing time for charge check")
                    continue
                gap, dur = t_off_x - t_land_prev, t_land_x - t_off_x
                model = getattr(self, "charge_model", _DEFAULT_CHARGE_MODEL)
                if model in ("paper", "table"):
                    # `paper` and `table` models: gap >= charge_time(o,d)
                    # of the edge about to fly.
                    ct = self.i["ctime"].get((o, d))
                    if ct is None:
                        self.fail(4, f"agent {D} leg {X} ({o}->{d}): no charge_time fact")
                    elif gap < ct:
                        self.fail(4, f"agent {D} leg {X} ({o}->{d}): gap {gap} < charge_time {ct}")
                    continue
                if model == "soc":
                    # just-in-time SoC charging: the aircraft charges only what
                    # the UPCOMING leg needs, so the required ground time is a
                    # function of that edge alone.  100% pack = 150 mi =>
                    # consume% = ceil(2*S/3); restored at 6 %/min.
                    S_ = self.i["dist"].get((o, d))
                    if S_ is None:
                        self.fail(4, f"agent {D} leg {X} ({o}->{d}): no distance")
                        continue
                    need = -(-(-(-2 * S_ // 3)) // 6)
                    if gap < need:
                        self.fail(4, f"agent {D} leg {X} ({o}->{d}): gap {gap} < "
                                     f"{need} min to charge {-(-2*S_//3)}% for {S_} mi")
                    continue
                lhs = 13 * t_off_x - 8 * t_land_x - 5 * t_land_prev
                if lhs < 0:
                    self.fail(4, f"agent {D} leg {X} ({o}->{d}): 13*{t_off_x}-8*{t_land_x}"
                                 f"-5*{t_land_prev} = {lhs} < 0  (gap {gap} < ceil(1.6*{dur})"
                                 f"={math.ceil(1.6*dur)})")

    def c5_horizon(self):
        for (D, X), (o, d) in self.s["routes"].items():
            t_off, t_land = self._off(o, D, X), self._land(d, D, X)
            if t_off is not None and t_off < 0:
                self.fail(5, f"agent {D} leg {X}: takeoff {t_off} < 0")
            if t_land is not None and t_land > self.H:
                self.fail(5, f"agent {D} leg {X}: landing {t_land} > horizon {self.H}")

    def c6_vertiport(self):
        ops = defaultdict(list)   # vertiport -> [op times]
        for (D, X), (o, d) in self.s["routes"].items():
            t_off, t_land = self._off(o, D, X), self._land(d, D, X)
            if t_off is not None:
                ops[o].append(t_off)
            if t_land is not None:
                ops[d].append(t_land)
        self.peaks = {}
        for v, times in ops.items():
            peak = 0
            for t in times:                       # probe at each op start
                cnt = sum(1 for tp in times if t - self.w < tp <= t)
                peak = max(peak, cnt)
            self.peaks[v] = peak
            if peak > self.cap:
                self.fail(6, f"vertiport {v}: {peak} ops in a width-{self.w} window > cap {self.cap}")

    def c7_revenue(self, claimed):
        rev = 0
        for (D, X), (o, d) in self.s["routes"].items():
            P = self.s["pax"].get((D, X), 0)
            s = self.i["dist"].get((o, d), 0)
            rev += P * s
        self.revenue = rev
        if claimed is not None and rev != claimed:
            self.fail(7, f"recomputed revenue {rev} != claimed {claimed}")
        return rev

    def run(self, claimed):
        self.c1_routing(); self.c2_demand(); self.c3_flight(); self.c4_charge()
        self.c5_horizon(); self.c6_vertiport(); self.c7_revenue(claimed)


def _claimed_from_header(text):
    m = re.search(r"revenue\s*=\s*(\d+)", text)
    return int(m.group(1)) if m else None


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--instance", required=True)
    p.add_argument("--schedule", required=True)
    p.add_argument("--cap", type=int, default=5)
    p.add_argument("--window", type=int, default=15)
    p.add_argument("--horizon", type=int, default=180)
    p.add_argument("--revenue", type=int, default=None,
                   help="claimed revenue; default = read 'revenue=' from schedule header")
    p.add_argument("--charge-model", choices=["duration16", "soc", "paper", "table"],
                   default=_DEFAULT_CHARGE_MODEL,
                   help="duration16: legacy 13/8/5 rule; paper: flight time equality and "
                        "gap >= charge_time fact")
    args = p.parse_args()

    inst = parse_instance(open(args.instance).read())
    sched_text = open(args.schedule).read()
    sched = parse_schedule(sched_text)
    claimed = args.revenue if args.revenue is not None else _claimed_from_header(sched_text)

    c = Checker(inst, sched, args.cap, args.window, args.horizon)
    c.charge_model = args.charge_model
    c.run(claimed)

    n_legs = len(sched["routes"])
    n_agents = len({D for (D, _) in sched["routes"]})
    print(f"instance : {args.instance}")
    print(f"schedule : {args.schedule}")
    print(f"parsed   : {n_agents} agents, {n_legs} legs; "
          f"cap={args.cap} window={args.window} horizon={args.horizon}")
    names = {1: "routing", 2: "demand/capacity", 3: "flight time", 4: "charge",
             5: "horizon", 6: "vertiport window", 7: "revenue"}
    by_check = defaultdict(list)
    for chk, msg in c.fails:
        by_check[chk].append(msg)
    for k in range(1, 8):
        if by_check[k]:
            print(f"  [FAIL] {k}. {names[k]}  ({len(by_check[k])} violation(s))")
            for msg in by_check[k][:8]:
                print(f"         - {msg}")
            if len(by_check[k]) > 8:
                print(f"         ... +{len(by_check[k])-8} more")
        else:
            print(f"  [ OK ] {k}. {names[k]}")
    peak_str = ", ".join(f"{v}:{pk}" for v, pk in sorted(c.peaks.items()))
    print(f"vertiport peaks (<= {args.cap}): {peak_str}")
    print(f"recomputed revenue = {c.revenue}"
          + (f"  (claimed {claimed})" if claimed is not None else ""))
    if c.fails:
        print(f"RESULT: INFEASIBLE  ({len(c.fails)} violation(s))")
        sys.exit(1)
    print("RESULT: FEASIBLE  (all 7 checks pass" +
          (", revenue matches)" if claimed is not None else ")"))


if __name__ == "__main__":
    main()
