%% ==============
%% Robot movememt
%% ==============
timelimit(30).
time(0..T) :- timelimit(T).

%% Initial position
path(R, N, 0) :-    init(object(robot,R),value(at,(X,Y))),
                    init(object(node,N), value(at,(X,Y))).
%% subsequent positions.
%% { move(R, N2, T+1) : edge(N1, N2) } 1 :- path(R, N1, T), time(T).
%% This variant prevents robots from moving once they've reached their goal
{ move(R, N2, T+1) : edge(N1, N2) } 1 :- path(R, N1, T), time(T), not goal(R, N1).

moved(R,T) :- move(R,N,T).
path(R,N,T) :- move(R,N,T).
path(R,N,T) :- path(R,N,T-1), time(T-1), not moved(R,T).

%% No robot collisions!
:- path(R1, N, T), path(R2, N, T), R1 != R2.
:-  path(R1, N1, T), path(R1, N2, T+1),
    path(R2, N2, T), path(R2, N1, T+1), R1 != R2.


goal(R, N) :-   target(R, S),
                init(object(robot,R),_),
                init(object(shelf,S),value(at,(X,Y))),
                init(object(node,N),value(at,(X,Y))).

%% For this to work we must assume that it's only one shelf per node
%% :- goal(R1, S), goal(R2, S), R1 != R2.

%% Helper predicate to make sure we visit the goals
visit(R, N) :- path(R, N, _).
:- goal(R, N), not visit(R, N).


%% =============
%% Optimizations
%% =============

makespan(T) :- moved(R,T).
#minimize{ 1@2,T : makespan(T)}.
%% Minimizing over move predicates significantly slows the solver down
%% #minimize{ 1@1,R,N,T : move(R,N,T) }.
