% ============================================================================
% tiny_3v3a_unsat.lp  --  hand-checkable UNSATISFIABLE instance for evtol.lp
% 3 vertiports (v1,v2,v3), 3 agents (d1,d2,d3), vertiport capacity = 2.
% Each agent flies exactly ONE leg (run with -c max_seg=1).
%
% RUN:
%   PYTHONPATH=~/clingu-build/clingcon/libpyclingcon \
%   ~/miniconda3/envs/clingu/bin/python3 -m clingcon \
%       evtol.lp tiny_3v3a_unsat.lp \
%       -c max_seg=1 -c window_length=15 -c horizon=10 -c cap=2
%
% EXPECTED: UNSATISFIABLE.
%
% WHY IT IS UNSATISFIABLE (one clean reason -- vertiport capacity):
%   All three aircraft start at v1 (init_loc), so all three MUST take off
%   from v1 on their first (only) leg -> three "departs(v1,·)" operations.
%   Each takeoff occupies a window of length 15 starting at its takeoff time.
%   The horizon is 10, so every takeoff time lies in [0,10]; any two of them
%   differ by at most 10 < 15, so all three 15-wide windows overlap at the
%   latest takeoff instant. That means 3 simultaneous slots are needed at v1,
%   but cap(v1) = 2.  3 > 2  ->  UNSAT.
%
%   The per-aircraft timing itself is fine (flight_time 3 <= horizon 10, so
%   one aircraft alone could depart at 0 and land at 3); capacity is the sole
%   obstruction.
%
%   BOUNDARY (verified): UNSAT for horizon <= 17, SAT from horizon >= 18.
%   To spread three cap-2 departures the 3rd must wait until t = 15
%   (= window_length, to clear the first two's [0,15) window), and it then
%   needs flight_time to land, so the smallest feasible horizon is
%   window_length + flight_time = 15 + 3 = 18. At horizon 10 there is no room
%   at all. (e.g. -c horizon=30 -> SAT; departures staggered 0, 0, 15.)
% ============================================================================

% ---- vertiports & fleet ----------------------------------------------------
vertiport(v1;v2;v3).
agent(d1;d2;d3).

capacity(D,4) :- agent(D).

% baked cap = 2 (holds even without -c cap=2)
vertiport_cap(V,2) :- vertiport(V).

% initial location: ALL THREE aircraft at v1 -> the overload source
init_loc(d1,v1).
init_loc(d2,v1).
init_loc(d3,v1).

% ---- network: directed edges, NO self-loops --------------------------------
edge((v1,v2)). edge((v1,v3)).
edge((v2,v1)). edge((v2,v3)).
edge((v3,v1)). edge((v3,v2)).

distance((v1,v2),10). distance((v1,v3),20).
distance((v2,v1),10). distance((v2,v3),15).
distance((v3,v1),20). distance((v3,v2),15).

% short flight time so per-aircraft timing is NOT the reason for UNSAT
flight_time(E,3) :- edge(E).
charge_time(E,2) :- edge(E).

% ---- demand (irrelevant to feasibility here; kept for completeness) --------
initial_request(1,(v1,v2),5).
initial_request(2,(v1,v3),3).
