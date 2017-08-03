%% ==============
%% Robot movememt
%% ==============
%% Initial position
path(R, N, 0) :-    init(object(robot,R),value(at,(X,Y))),
                    init(object(node,N), value(at,(X,Y))).
%% subsequent positions
{ path(R, N2, T+1) : edge(N1, N2) } = 1 :- path(R, N1, T).
%% No robot collisions!
:- path(R1, N, T), path(R2, N, T), R1 != R2.

%% Helper predicate to make sure we visit the goals
visit(R, N) :- path(R, N, _).
%% goals are defined elsewhere, we don't care how
:- goal(R, N), not visit(R, N).


%% =============
%% Optimizations
%% =============
makespan(T) :- path(_, _, T).
#minimize{ 1, T : makespan(T)}.

#minimize{ 1, R, N, T : path(R, N, T)}.
