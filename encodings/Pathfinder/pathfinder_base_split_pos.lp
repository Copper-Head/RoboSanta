timelimit(22).

time(0..M) :- timelimit(M). 

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
holds(atx(robot(R),X),0) :- init(object(robot,R),value(at,(X,Y))).
holds(aty(robot(R),Y),0) :- init(object(robot,R),value(at,(X,Y))).

holds(atx(shelf(S),X),0) :- init(object(shelf,S),value(at,(X,Y))).
holds(aty(shelf(S),Y),0) :- init(object(shelf,S),value(at,(X,Y))).

% check product amounts and see that there is enough to fulfill order
productamt(P,C) :- C = #sum{A,S : init(object(product,P),value(on,(S,A)))}, product(product(P)).
orderedamt(P,C) :- C = #sum{A,O : init(object(order,O),value(line,(P,A)))}, product(product(P)).
notenough(P) :- productamt(P,A), orderedamt(P,A2), A2 > A.

% There is not enough product to fulfill orders
:- notenough(P).

% generate actions
{ do(R,A,T) : action(A) } 1 :- robot(R), time(T).
:- do(R,A,T), not possible(R,A,T), time(T).

% helpers
moved(R,T) :- do(R,action(move(DX,DY)),T), time(T).

%%%%%%%% Inertia
holds(F,T) :- holds(F,T-1), not abnormal(F,T), time(T).


%%%%%%%% Possibles
possible(R,action(move(DX,DY)),T) :- holds(atx(R,X),T), holds(aty(R,Y),T), node(X+DX,Y+DY), action(action(move(DX,DY))), robot(R), time(T).

possible(R,action(pickup),T) :- holds(atx(R,X),T), holds(aty(R,Y),T), holds(atx(S,X),T), holds(aty(S,Y),T), not holds(carry(R,S),T), robot(R), shelf(S), time(T).

possible(R,action(putdown),T) :- holds(carry(R,S),T), robot(R), shelf(S).

%%%%%%% Dynamic Effects
% robot position
holds(atx(R,X+DX),T) :- holds(atx(R,X),T-1), holds(aty(R,Y),T-1), do(R,action(move(DX,DY)),T-1), node(X+DX,Y+DY), time(T).
holds(aty(R,Y+DY),T) :- holds(atx(R,X),T-1), holds(aty(R,Y),T-1), do(R,action(move(DX,DY)),T-1), node(X+DX,Y+DY), time(T).

% shelf position
holds(atx(S,X),T) :- holds(atx(R,X),T), holds(carry(R,S),T), time(T).
holds(aty(S,Y),T) :- holds(aty(R,Y),T), holds(carry(R,S),T), time(T).

holds(carry(R,S),T) :- holds(atx(R,X),T-1), holds(aty(R,Y),T-1), holds(atx(S,X),T-1), holds(aty(S,Y),T-1), do(R,action(pickup),T-1), robot(R), shelf(S), time(T).

%%%%%%% Inertia Effects

abnormal(atx(R,X),T) :- node(X,Y), moved(R,T-1), time(T).
abnormal(aty(R,Y),T) :- node(X,Y), moved(R,T-1), time(T).

abnormal(atx(S,X),T) :- node(X,Y), holds(carry(R,S),T-1), moved(R,T-1), time(T).
abnormal(aty(S,Y),T) :- node(X,Y), holds(carry(R,S),T-1), moved(R,T-1), time(T).

abnormal(carry(R,S),T) :- holds(carry(R,S),T-1), do(R,action(putdown),T-1), time(T).

%%%%%%% Static Laws

% can only stand on a highway for max 3 steps
% this rule somehow leads to UNSAT :/
%:-  holds(atx(R,X),T), holds(aty(R,Y),T), not moved(R,T), not moved(R,T-1), not moved(R,T-2), robot(R), highway(X,Y), time(T),time(T-1).

% can not place shelf on a highway
:-  holds(atx(R,X),T), holds(aty(R,Y),T), do(R,action(putdown),T), highway(X,Y), time(T).


% no 2+ robots/shelfs in the same spot
robotAt(R,X,Y,T) :- holds(atx(R,X),T), holds(aty(R,Y),T), robot(R).
shelfAt(S,X,Y,T) :- holds(atx(S,X),T), holds(aty(S,Y),T), shelf(S).
:- node(X,Y), time(T), 2{robotAt(R,X,Y,T) : robot(R)}.
:- node(X,Y), time(T), 2{shelfAt(S,X,Y,T) : shelf(S)}.

% robot/shelf can only be in 1 node
:- robot(R), time(T), 2{robotAt(R,X,Y,T) : node(X,Y)}.
:- shelf(S), time(T), 2{shelfAt(S,X,Y,T) : node(X,Y)}.

% robots cant swap places
%:- holds(at(R1,node(X1,Y1)),T), holds(at(R2,node(X2,Y2)),T), holds(at(R1,node(X2,Y2)),T-1), holds(at(R2,node(X1,Y1)),T-1), R1 != R2, |X2-X1|+|Y2-Y1|==1, time(T).

:- holds(atx(R1,X1),T), holds(aty(R1,Y1),T), holds(atx(R2,X1),T), holds(aty(R2,Y1-1),T), do(R1,action(move(0,-1)),T), do(R2,action(move(0,1)),T), R1 != R2, time(T).
:- holds(atx(R1,X1),T), holds(aty(R1,Y1),T), holds(atx(R2,X1-1),T), holds(aty(R2,Y1),T), do(R1,action(move(-1,0)),T), do(R2,action(move(1,0)),T), R1 != R2, time(T).

% a robot can only carry 1 shelf
:- robot(R), time(T), 2{holds(carry(R,S),T) : shelf(S)}.

%#minimize{ T,R : done(R,T) }.
#maximize{ 1,T : goal(T) }.

