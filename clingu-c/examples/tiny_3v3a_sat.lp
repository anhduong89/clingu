% ============================================================================
% tiny_3v3a_sat.lp  --  hand-checkable SATISFIABLE instance for evtol.lp
% 3 vertiports (v1,v2,v3), 3 agents (d1,d2,d3), vertiport capacity = 2.
% Each agent flies exactly ONE leg (run with -c max_seg=1), so the whole
% answer set is 3 legs + 3 passenger counts + 6 theory times -- checkable by hand.
%
% RUN:
%   PYTHONPATH=~/clingu-build/clingcon/libpyclingcon \
%   ~/miniconda3/envs/clingu/bin/python3 -m clingcon \
%       evtol.lp tiny_3v3a_sat.lp \
%       -c max_seg=1 -c window_length=15 -c horizon=60 -c cap=2
%
% EXPECTED: OPTIMUM, revenue = 160  (cost = -160).
%   d1: v1->v3, 3 pax  = 3*20 = 60   (uses all of v1->v3 demand 3)
%   d2: v1->v2, 4 pax  = 4*10 = 40   (uses 4 of v1->v2 demand 5)
%   d3: v2->v3, 4 pax  = 4*15 = 60   (uses all of v2->v3 demand 4)
%                                   total = 160
%
% WHY IT IS SATISFIABLE (capacity check, cap = 2 at every vertiport):
%   v1: 2 departures (d1,d2)                 = 2  <= 2  OK
%   v2: 1 departure (d3) + 1 landing (d2)    = 2  <= 2  OK
%   v3: 2 landings (d1,d3)                    = 2  <= 2  OK
%   With flight_time 5 and horizon 60 the times trivially fit; e.g. all
%   takeoffs at 0, all landings at 5, no window ever exceeds 2 ops.
% ============================================================================

% ---- vertiports & fleet ----------------------------------------------------
vertiport(v1;v2;v3).
agent(d1;d2;d3).

% per-aircraft passenger capacity
capacity(D,4) :- agent(D).

% per-vertiport simultaneous-slot capacity enforced by &cumu (baked = 2, so the
% instance is cap-2 even if you forget -c cap=2).
vertiport_cap(V,2) :- vertiport(V).

% initial location: two aircraft at v1, one at v2
init_loc(d1,v1).
init_loc(d2,v1).
init_loc(d3,v2).

% ---- network: directed edges, NO self-loops --------------------------------
edge((v1,v2)). edge((v1,v3)).
edge((v2,v1)). edge((v2,v3)).
edge((v3,v1)). edge((v3,v2)).

% distance (= passenger-miles per passenger carried on that edge)
distance((v1,v2),10). distance((v1,v3),20).
distance((v2,v1),10). distance((v2,v3),15).
distance((v3,v1),20). distance((v3,v2),15).

% flight time per leg (minutes)
flight_time(E,5) :- edge(E).

% charge/turnaround time per edge (unused at max_seg=1: the charge constraint
% only binds from the 2nd leg onward, but kept so the instance is complete).
charge_time(E,2) :- edge(E).

% ---- demand (upper bound on passengers carried per edge) -------------------
% initial_request(id, (from,to), demand)
initial_request(1,(v1,v2),5).
initial_request(2,(v1,v3),3).
initial_request(3,(v2,v3),4).
