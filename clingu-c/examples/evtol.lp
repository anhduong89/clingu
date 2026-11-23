% eVTOL fleet scheduling for clingu (= clingcon + the &cumu propagator).
%
% The &cumu line carries the start variable INSIDE the theory-term tuple
% (StartVar, Duration, Demand), with the routing atom as the element's condition.
% A form such as `&cumu{1, W : takeoff(_,(V,_),_)}` would put the variable after
% the ':' (a condition, not a term), so grounding would collapse every task into
% one element and drop the variable identity.
%
% Provide an instance supplying agent/1, capacity/2, edge/1, distance/2,
% flight_time/2, charge_time/2, init_loc/2, vertiport/1, initial_request/3.
% (request/3 and vertiport_cap/2 are derived below.) The repository has 120
% such instances in exp/instances/, plus a small one alongside this file:
%
%   clingu-c/examples/network-ny_0_pax6_uniform_init0_agent3_seg10_horizon60.lp
%
% The generator that produced them depended on a sibling project and is not
% part of this repository.

#const max_seg = 10.
#const horizon = 180.
% ------ INSTANCES
#const cap = 5.
#const window_length = 15.
request(N,E,W) :- initial_request(N,E,W).
vertiport_cap(V,cap) :- vertiport(V).

% seg(1..max_seg).
% ------ GENERATE ROUTING

% -- assign edge to each segment

1 {max_seg(D,1..max_seg)} 1 :- agent(D).


seg(D,X) :- agent(D), max_seg(D,M), X=1..M.

1 {route((V,V'),D,X): edge((V,V')), V!=V'} 1 :- seg(D,X).
1 {passengers(P,D,X): P=0..C} 1 :- seg(D,X), capacity(D,C).

% total delivered customers can not excess demand
:- request(_,E,Dem), #sum{P,D,X : route(E,D,X), passengers(P,D,X)} > Dem.

% no passengers on an edge with no demand (also forbids stationed self-loops,
% since initial_request is only generated for o != d)
:- route(E,D,X), passengers(P,D,X), P>0, not request(_,E,_).


% takeoff vertiport as specicfied
:- init_loc(D,V), route((V',_),D,1), V!=V'.

% consecutive trips need to be connected
:-route((V,V1),D,X),route((V2,V3),D,X+1),V1!=V2.

%  ----------------------------
% ----- TIME SCHEDULE WITH DIFFERENCE CONSTRAINTS (ordinary clingcon &sum)
% takeoff time at initial vertiport = charge duration

&dom{0..horizon} = takeoff(V,D,X) :- route((V,V'),D,X).
&dom{0..horizon} = landing(V',D,X) :- route((V,V'),D,X).

&sum {takeoff(V,D,1)} >= 0 :- route((V,V'),D,1).

&sum {landing(V',D,M)} <= horizon :- route((V,V'),D,M).

&sum {landing(V',D,X); -takeoff(V,D,X)} >= FT :- flight_time((V,V'),FT), route((V,V'),D,X).

% &sum {takeoff(V,D,X); -landing(V,D,X-1)} >= CT :-
% charge_time((V,V'),CT), route((V,V'),D,X), route((_,V),D,X-1).

&sum { 13*takeoff(V,D,X); -8*landing(V',D,X); -5*landing(V,D,X-1) } >= 0 :-
    route((V,V'),D,X), route((_,V),D,X-1).



% ----- VERTIPORT CAPACITY via the cumulative propagator -----
% Global cumulative  cumulative(S,D,R,C):  each element is (StartVar, Duration,
% Demand). Each takeoff departing V and each landing arriving at V occupies one
% of C slots for window_length time units.
%
% The grounding condition is the DESTINATION-INDEPENDENT departs/arrives atom,
% not the full route/3. The start vars takeoff(V,D,X)/landing(V,D,X) are already
% keyed only by (vertiport, agent, segment), so the capacity violation never
% depends on which destination an agent picks. Using route((V,V'),..) as the
% condition baked V' into the nogood, so a fixed overload (e.g. > C agents
% departing V at t=0) was re-derived once per destination combination. The
% departs/arrives condition makes that nogood destination-invariant -> learned
% once. (One element per (V,D,X) instead of one per edge also grounds smaller.)
departs(V,D,X) :- route((V,_),D,X).
arrives(V,D,X) :- route((_,V),D,X).
&cumu{ takeoff(V,D,X), window_length, 1 : departs(V,D,X);
       landing(V,D,X), window_length, 1 : arrives(V,D,X) } <= C :- vertiport_cap(V,C).
%  ----------------------------
revenue(P*S,D,X) :- passengers(P,D,X), route(E,D,X), distance(E,S).
#maximize{R,D,X: revenue(R,D,X)}.
#heuristic passengers(P,D,X) :route(E,D,X), distance(E,S). [P*S, true]

% display
#show route/3.
#show passengers/3.
