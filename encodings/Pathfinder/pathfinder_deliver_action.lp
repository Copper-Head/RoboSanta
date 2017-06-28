#program base.

action(action(deliver(O,P))) :- order(O), product(P).

on(product(P),shelf(S)) :- init(object(product,P),value(on,(S,A))).
holds(request(order(O),product(P),pickingStation(Pi)),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).

#program step(t).

possible(R,action(deliver(O,P)),t-1) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), on(P,S), at(Pi,node(X,Y)), holds(request(O,P,Pi),t-1), robot(R), shelf(S), product(P), pickingStation(Pi), order(O).


%%% dynamic effect and inertia

abnormal(request(O,P,Pi),t) :- holds(request(O,P,Pi),t-1), do(R,action(deliver(O,P)),t-1).


#program check(t).
#external query(t).

:- holds(request(_,_,_),t), query(t).
