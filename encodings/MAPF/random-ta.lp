robot(R) :- init(object(robot,R),_).
shelf(S) :- init(object(shelf,S),_).

{ goal(R, S) : shelf(S) } = 1 :- robot(R).
:- goal(R1, S), goal(R2, S), R1 != R2.

#show goal/2.
