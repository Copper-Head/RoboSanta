#program base.

on(product(P),shelf(S)) :- init(object(product,P),value(on,(S,A))).

holds(request(order(O),product(P),pickingStation(Pi)),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).


#program step(t).

noaction(R,t-1) :- not do(R,A,t-1) : action(A); robot(R).

{delivered(R,O,P,Pi,t-1)} :- holds(request(O,P,Pi),t-1), at(Pi,node(X,Y)), holds(at(R,node(X,Y)),t-1), holds(carry(R,S),t-1), on(P,S), noaction(R,t-1).

abnormal(request(O,P,Pi),t) :- delivered(R,O,P,Pi,t-1).



#program check(t).
#external query(t).

:- holds(request(_,_,_),t), query(t).

