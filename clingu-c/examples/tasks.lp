% Three tasks share a resource of capacity 3.  task(Name, Duration, Demand).
task(a,4,2). task(b,3,1). task(c,3,2).

% One integer start time per task.
&dom{0..10} = s(T) :- task(T,_,_).

% At every instant, the demands of the running tasks sum to at most 3.
&cumu{ s(T),D,R : task(T,D,R) } <= 3.

% Minimise the makespan.
&dom{0..13} = makespan.
&sum{ s(T) } <= makespan - D :- task(T,D,_).
&minimize{ makespan }.
