% eVTOL fleet scheduling for clingu -- PRE-SOLVE per-aircraft segments + DROPPABLE.
%
% Best-performing configuration: instead of an in-solve
% `1 {max_seg(D,1..max_seg)} 1` choice (symmetric, slow), the per-aircraft segment
% cap `max_seg(D,M)` is supplied as FACTS computed before solving (utils/solver.py
% emits a random partition summing to ~10*nb_agents, larger caps on lower-indexed
% agents -> symmetry break). Segments are DROPPABLE: each aircraft flies a
% contiguous PREFIX of its candidate segments (0..M), so an over-generous cap is
% harmless and any segment that cannot fit the horizon is simply not flown.
%
% Provide an instance (e.g. from exp/gen_instance.py, left at its default) plus
% max_seg(D,M) facts (utils/solver.py injects them). Instance predicates: agent/1,
% capacity/2, edge/1, distance/2, flight_time/2, charge_time/2, init_loc/2,
% vertiport/1, initial_request/3. (request/3 and vertiport_cap/2 derived below.)

#const horizon = 180.
#const cap = 5.
#const window_length = 15.
request(N,E,W) :- initial_request(N,E,W).
vertiport_cap(V,cap) :- vertiport(V).

% candidate segments come from the pre-solve max_seg(D,M) facts
seg(D,X) :- max_seg(D,M), X=1..M.

% DROPPABLE routing: 0 or 1 edge per candidate segment; flown segments = prefix
{ route((V,V'),D,X): edge((V,V')), V!=V' } 1 :- seg(D,X).
flown(D,X) :- route(_,D,X).
:- flown(D,X), X>1, not flown(D,X-1).             % contiguous prefix (no gaps)

1 { passengers(P,D,X): P=0..C } 1 :- flown(D,X), capacity(D,C).

% total delivered customers can not exceed demand
:- request(_,E,Dem), #sum{P,D,X : route(E,D,X), passengers(P,D,X)} > Dem.
% no passengers on a no-demand edge (self-loops already excluded above)
:- route(E,D,X), passengers(P,D,X), P>0, not request(_,E,_).
% first leg departs the initial vertiport
:- init_loc(D,V), route((V',_),D,1), V!=V'.
% consecutive legs connect
:- route((V,V1),D,X), route((V2,V3),D,X+1), V1!=V2.

% ----- TIME SCHEDULE (clingcon &sum) -----
&dom{0..horizon} = takeoff(V,D,X) :- route((V,V'),D,X).
&dom{0..horizon} = landing(V',D,X) :- route((V,V'),D,X).
&sum {takeoff(V,D,1)} >= 0 :- route((V,V'),D,1).
&sum {landing(V',D,M)} <= horizon :- route((V,V'),D,M).
% flight duration is a free variable >= the edge flight time (loiter allowed)
&sum {landing(V',D,X); -takeoff(V,D,X)} >= FT :- flight_time((V,V'),FT), route((V,V'),D,X).
% charge >= 1.6 * flight duration   (5*charge >= 8*duration  =>  13*T_x - 8*L_x - 5*L_{x-1} >= 0)
&sum { 13*takeoff(V,D,X); -8*landing(V',D,X); -5*landing(V,D,X-1) } >= 0 :-
    route((V,V'),D,X), route((_,V),D,X-1).

% ----- VERTIPORT CAPACITY (&cumu): <= cap ops per window_length window per vertiport -----
% Grounding condition is the DESTINATION-INDEPENDENT departs/arrives atom, not the
% full route/3: takeoff(V,D,X)/landing(V,D,X) are keyed only by (vertiport, agent,
% segment), so a capacity violation never depends on the chosen destination. Using
% route((V,V'),..) baked V' into the nogood, so a fixed overload was re-derived once
% per destination combination (destination-invariant &cumu).
departs(V,D,X) :- route((V,_),D,X).
arrives(V,D,X) :- route((_,V),D,X).
&cumu{ takeoff(V,D,X), window_length, 1 : departs(V,D,X);
       landing(V,D,X), window_length, 1 : arrives(V,D,X) } <= C :- vertiport_cap(V,C).

% objective: maximize passenger-miles (passengers carried x edge distance)
revenue(P*S,D,X) :- passengers(P,D,X), route(E,D,X), distance(E,S).
#maximize{R,D,X: revenue(R,D,X)}.
#heuristic passengers(P,D,X) : route(E,D,X), distance(E,S). [P*S, true]

#show route/3.
#show passengers/3.
