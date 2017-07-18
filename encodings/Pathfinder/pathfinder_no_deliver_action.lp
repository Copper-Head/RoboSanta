

on(product(P),shelf(S)) :- init(object(product,P),value(on,(S,A))).

holds(request(order(O),product(P),pickingStation(Pi)),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).


noaction(R,T) :- not do(R,A,T) : action(A); robot(R), time(T).

delivered(R,O,P,Pi,T) :- holds(request(O,P,Pi),T-1), at(Pi,node(X,Y)), holds(at(R,node(X,Y)),T-1), holds(carry(R,S),T-1), on(P,S), noaction(R,T-1), time(T).

abnormal(request(O,P,Pi),T) :- delivered(R,O,P,Pi,T-1), time(T).


goal(T) :- not holds(request(_,_,_),T), time(T).
:- not goal(T), timelimit(T).

% dont do anything if goal was reached
:- goal(T), do(_,_,T).


