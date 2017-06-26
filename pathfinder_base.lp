
#program base.

#const imin   = 0.
#const imax   = 50.

%%
% Actions
%%

action(action(move(0,-1))).
action(action(move(0,1))).
action(action(move(1,0))).
action(action(move(-1,0))).
action(action(pickup)).
action(action(putdown)).


%%
% Initial state
%%
holds(at(robot(R),node(X,Y)),0) :- init(object(robot,R),value(at,(X,Y))).
holds(at(shelf(S),node(X,Y)),0) :- init(object(shelf,S),value(at,(X,Y))).


% check product amounts and see that there is enough to fulfill order
productamt(P,C) :- C = #sum{A,S : init(object(product,P),value(on,(S,A)))}, product(product(P)).
orderedamt(P,C) :- C = #sum{A,O : init(object(order,O),value(line,(P,A)))}, product(product(P)).
notenough(P) :- productamt(P,A), orderedamt(P,A2), A2 > A.

% There is not enough product to fulfill orders
:- notenough(P).

#program step(t).

% generate actions
{ do(R,A,t-1) : action(A) } 1 :- robot(R).
:- do(R,A,t-1), not possible(R,A,t-1).

% helpers
moved(R,t-1) :- do(R,action(move(DX,DY)),t-1).

%%%%%%%% Inertia
holds(F,t) :- holds(F,t-1), not abnormal(F,t).


%%%%%%%% Possibles
possible(R,action(move(DX,DY)),t-1) :- holds(at(R,node(X,Y)),t-1), node(X+DX,Y+DY), action(action(move(DX,DY))), robot(R).

possible(R,action(pickup),t-1) :- holds(at(R,node(X,Y)),t-1), holds(at(S,node(X,Y)),t-1), not holds(carry(R,S),t-1), robot(R), shelf(S).

possible(R,action(putdown),t-1) :- holds(carry(R,S),t-1), robot(R), shelf(S).


%%%%%%% Dynamic Effects

holds(at(R,node(X+DX,Y+DY)),t) :- holds(at(R,node(X,Y)),t-1), do(R,action(move(DX,DY)),t-1), node(X+DX,Y+DY).

holds(at(S,node(X,Y)),t) :- holds(at(R,node(X,Y)),t), holds(carry(R,S),t).

holds(carry(R,S),t) :- holds(at(R,node(X,Y)),t-1), holds(at(S,node(X,Y)),t-1), do(R,action(pickup),t-1), robot(R), shelf(S).

%%%%%%% Inertia Effects

abnormal(at(R,node(X,Y)),t) :- node(X,Y), moved(R,t-1).

abnormal(at(S,node(X,Y)),t) :- node(X,Y), holds(carry(R,S),t-1), moved(R,t-1).

abnormal(carry(R,S),t) :- holds(carry(R,S),t-1), do(R,action(putdown),t-1).

%%%%%%% Static Laws

% highways, can only stand on a highway for max 3 steps
%this rule somehow leads to UNSAT :/
%:- holds(at(R,node(X,Y)),t), not moved(R,t), not moved(R,t-1), not moved(R,t-2), robot(R), highway(X,Y).

% can not place shelf on a highway
:- holds(at(R,node(X,Y)),t), do(R,action(putdown),t), highway(X,Y).


% no 2+ robots/shelfs in the same spot
:- node(X,Y), 2{holds(at(R,node(X,Y)),t) : robot(R)}.
:- node(X,Y), 2{holds(at(S,node(X,Y)),t) : shelf(S)}.

% robot/shelf can only be in 1 node
:- robot(R), 2{holds(at(R,node(X,Y)),t) : node(X,Y)}.
:- shelf(S), 2{holds(at(S,node(X,Y)),t) : node(X,Y)}.

% robots cant swap places
%:- holds(at(R1,node(X1,Y1)),t), holds(at(R2,node(X2,Y2)),t), holds(at(R1,node(X2,Y2)),t-1), holds(at(R2,node(X1,Y1)),t-1), R1 != R2, |X2-X1|+|Y2-Y1|==1.

:- holds(at(R1,node(X1,Y1)),t), holds(at(R2,node(X1,Y1-1)),t), do(R1,action(move(0,-1)),t), do(R2,action(move(0,1)),t), R1 != R2.
:- holds(at(R1,node(X1,Y1)),t), holds(at(R2,node(X1-1,Y1)),t), do(R1,action(move(-1,0)),t), do(R2,action(move(1,0)),t), R1 != R2.

% a robot can only carry 1 shelf
:- robot(R), 2{holds(carry(R,S),t) : shelf(S)}.




#show do/3.
#show occurs/3.



