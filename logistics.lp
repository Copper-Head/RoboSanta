
#program base.

#const imin   = 0.
#const imax   = 50.

%%
% Facts
%%

node(X,Y) :- init(object(node,N),value(at,(X,Y))).

robot(robot(R)) :- init(object(robot,R),_).
shelf(shelf(S)) :- init(object(shelf,S),_).
order(order(O)) :- init(object(order,O),_).
product(product(P)) :- init(object(product,P),_).
pickingStation(pickingStation(P)) :- init(object(pickingStation,P),_).

at(pickingStation(P),node(X,Y)) :- init(object(pickingStation,P),value(at,(X,Y))).

highway(X,Y) :- init(object(highway,_),value(at,(X,Y))).

%%
% Actions
%%

action(action(move(0,-1))).
action(action(move(0,1))).
action(action(move(1,0))).
action(action(move(-1,0))).
action(action(pickup)).
action(action(putdown)).

action(action(deliver(O,P))) :- order(O), product(P).

%%
% Initial state
%%
holds(at(robot(R),node(X,Y)),0) :- init(object(robot,R),value(at,(X,Y))).
holds(at(shelf(S),node(X,Y)),0) :- init(object(shelf,S),value(at,(X,Y))).
holds(on(product(P),shelf(S),A),0) :- init(object(product,P),value(on,(S,A))).
holds(request(order(O),product(P),pickingStation(Pi),A),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).


% check product amounts and see that there is enough to fulfill order
productamt(P,C) :- C = #sum{A,S : init(object(product,P),value(on,(S,A)))}, product(product(P)).
orderedamt(P,C) :- C = #sum{A,O : init(object(order,O),value(line,(P,A)))}, product(product(P)).
notenough(P) :- productamt(P,A), orderedamt(P,A2), A2 > A.

% There is not enough product to fulfill orders
:- notenough(P).

#program step(t).

% generate actions
{ do(R,A,t-1) : action(A) } 1 :- robot(R).
%:- do(R,A,t-1), impossible(R,A,t-1).
:- do(R,A,t-1), not possible(R,A,t-1).

% helpers
moved(R,t-1) :- do(R,action(move(DX,DY)),t-1).
delivered(R,O,t-1) :- do(R,action(deliver(O,P)),t-1).
delivered(R,P,t-1) :- do(R,action(deliver(O,P)),t-1).

% calculate how much product to deliver
deliveredamt(R,O,P,A2,t-1) :- do(R,action(deliver(O,P)),t-1), holds(on(P,S,A1),t-1), holds(carry(R,S),t-1), holds(request(O,P,Pi,A2),t-1), A2<=A1.
deliveredamt(R,O,P,A1,t-1) :- do(R,action(deliver(O,P)),t-1), holds(on(P,S,A1),t-1), holds(carry(R,S),t-1), holds(request(O,P,Pi,A2),t-1), A1<=A2.

%%%%%%%% Inertia
holds(F,t) :- holds(F,t-1), not abnormal(F,t).


%%%%%%%% Possibles
possible(R,action(move(DX,DY)),t-1) :- holds(at(R,node(X,Y)),t-1), node(X+DX,Y+DY), action(action(move(DX,DY))), robot(R).

possible(R,action(pickup),t-1) :- holds(at(R,node(X,Y)),t-1), holds(at(S,node(X,Y)),t-1), not holds(carry(R,S),t-1), robot(R), shelf(S).

possible(R,action(putdown),t-1) :- holds(carry(R,S),t-1), robot(R), shelf(S).

possible(R,action(deliver(O,P)),t-1) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), holds(on(P,S,A),t-1), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),t-1), robot(R), shelf(S), product(P), pickingStation(Pi), order(O).

possible(R,action(deliver(O,P)),t-1) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), holds(on(P,S,A),t-1), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),t-1), robot(R), shelf(S), product(P), pickingStation(Pi), order(O).

%%%%%%% Dynamic Effects

holds(at(R,node(X+DX,Y+DY)),t) :- holds(at(R,node(X,Y)),t-1), do(R,action(move(DX,DY)),t-1), node(X+DX,Y+DY).

holds(at(S,node(X,Y)),t) :- holds(at(R,node(X,Y)),t), holds(carry(R,S),t).

holds(carry(R,S),t) :- holds(at(R,node(X,Y)),t-1), holds(at(S,node(X,Y)),t-1), do(R,action(pickup),t-1), robot(R), shelf(S).

holds(on(P,S,A-A2),t) :- holds(on(P,S,A),t-1), holds(carry(R,S),t-1), deliveredamt(R,O,P,A2,t-1), A > A2.

holds(request(O,P,Pi,A-A2),t) :- holds(request(O,P,Pi,A),t-1), deliveredamt(R,O,P,A2,t-1), A > A2.

%%%%%%% Inertia Effects

abnormal(at(R,node(X,Y)),t) :- node(X,Y), moved(R,t-1).

abnormal(at(S,node(X,Y)),t) :- node(X,Y), holds(carry(R,S),t-1), moved(R,t-1).

abnormal(carry(R,S),t) :- holds(carry(R,S),t-1), do(R,action(putdown),t-1).

abnormal(on(P,S,A),t) :- holds(on(P,S,A),t-1), holds(carry(R,S),t-1), delivered(R,P,t-1).

abnormal(request(O,P,Pi,A),t) :- holds(request(O,P,Pi,A),t-1), delivered(R,O,t-1).


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

% shelf can only contain one amount of product, slow :/
%:- holds(on(P,S,A),t), holds(on(P,S,A2),t), A<A2.

% a robot can only carry 1 shelf
:- robot(R), 2{holds(carry(R,S),t) : shelf(S)}.


% format the action into the input for the visualizer
occurs(R,action(move,(DX,DY)),t-1) :- do(R,action(move(DX,DY)),t-1).
occurs(R,action(pickup,()),t-1) :- do(R,action(pickup),t-1).
occurs(R,action(putdown,()),t-1) :- do(R,action(putdown),t-1).
occurs(R,action(deliver,(O,P,A)),t-1) :- do(R,action(deliver(O,P)),t-1), deliveredamt(R,O,P,A,t-1).

#program check(t).
#external query(t).

:- holds(request(_,_,_,_),t), query(t).

#show do/3.
#show occurs/3.



