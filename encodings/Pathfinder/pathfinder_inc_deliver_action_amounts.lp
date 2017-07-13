#program base.

maxProduct(Amount) :- #max{A,O,P : init(object(order,O),value(line,(P,A)))} = Amount.
action(action(deliver(O,P,1..A))) :- order(O), product(P), maxProduct(A).

holds(on(product(P),shelf(S),A),0) :- init(object(product,P),value(on,(S,A))).
holds(request(order(O),product(P),pickingStation(Pi),A),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).

#program step(t).


possible(R,action(deliver(O,P,1..A)),t-1) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), holds(on(P,S,A),t-1), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),t-1), robot(R), shelf(S), product(P), pickingStation(Pi), order(O), A < A2.

possible(R,action(deliver(O,P,1..A2)),t-1) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), holds(on(P,S,A),t-1), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),t-1), robot(R), shelf(S), product(P), pickingStation(Pi), order(O), A2 < A.


%%% helpers
delivered(R,O,P,t-1) :- do(R,action(deliver(O,P,_)),t-1).

%%% dynamic effect and inertia
holds(request(O,P,Pi,A-A2),t) :- holds(request(O,P,Pi,A),t-1), do(R,action(deliver(O,P,A2)),t-1), A > A2.
holds(on(P,S,A-A2),t) :- holds(on(P,S,A),t-1), holds(carry(R,S),t-1), do(R,action(deliver(O,P,A2)),t-1), A > A2.

abnormal(request(O,P,Pi,A),t) :- holds(request(O,P,Pi,A),t-1), delivered(R,O,P,t-1).
abnormal(on(P,S,A),t) :- holds(on(P,S,A),t-1), holds(carry(R,S),t-1), delivered(R,O,P,t-1).


#program check(t).
#external query(t).

:- holds(request(_,_,_,_),t), query(t).
