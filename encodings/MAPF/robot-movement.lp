%% ==============
%% Robot movememt
%% ==============
timelimit(30).
time(0..T) :- timelimit(T).

%% Initial position
path(R, N, 0) :-    init(object(robot,R),value(at,(X,Y))),
                    init(object(node,N), value(at,(X,Y))).
%% subsequent positions
{ move(R, N2, T+1) : edge(N1, N2) } 1 :- path(R, N1, T), time(T).

moved(R,T) :- move(R,N,T).
path(R,N,T) :- move(R,N,T).
path(R,N,T) :- path(R,N,T-1), time(T-1), not moved(R,T).

%% No robot collisions!
:- path(R1, N, T), path(R2, N, T), R1 != R2.
:-  path(R1, N1, T), path(R1, N2, T+1),
    path(R2, N2, T), path(R2, N1, T+1), R1 != R2.

%% Helper predicate to make sure we visit the goals
visit(R, N) :- path(R, N, _).
%% goals are defined elsewhere, we don't care how
:- goal(R, N), not visit(R, N).


%% =============
%% Optimizations
%% =============

makespan(T) :- moved(R,T).
#minimize{ 1,T : makespan(T)}.

