%% ==============
%% Robot movememt
%% ==============
timelimit(30).
time(0..T) :- timelimit(T).

%% Initial position
path(R, N, 0) :-    init(object(robot,R),value(at,(X,Y))),
                    init(object(node,N), value(at,(X,Y))).
%% subsequent positions
{ move(R, N2, T+1) : edge(N1, N2) } < 2 :- path(R, N1, T), time(T).

moved(R,T) :- move(R,N,T).
path(R,N,T) :- move(R,N,T).
path(R,N,T) :- path(R,N,T-1), time(T-1), not moved(R,T).

%% No robot collisions!
:- path(R1, N, T), path(R2, N, T), R1 != R2.

%% Helper predicate to make sure we visit the goals
visit(R, N) :- path(R, N, _).
%% goals are defined elsewhere, we don't care how
:- goal(R, N), not visit(R, N).

#show move/3.
#show visit/2.
#show makespan/1.

%% =============
%% Optimizations
%% =============

makespan(T) :- moved(R,T).
makespan(T) :- makespan(T+1), 0 < T.

% makespan(T) :- path(_, _, T).
#minimize{ 1,T : makespan(T)}.

%#minimize{ R, N, T : path(R, N, T)}.
