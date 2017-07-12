
action(action(deliver(O,P))) :- order(O), product(P).

on(product(P),shelf(S)) :- init(object(product,P),value(on,(S,A))).

holds(request(order(O),product(P),pickingStation(Pi)),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).


possible(R,action(deliver(O,P)),T) :- holds(at(R,node(X,Y)),T), holds(carry(R,S),T), on(P,S), at(Pi,node(X,Y)), holds(request(O,P,Pi),T), robot(R), shelf(S), product(P), pickingStation(Pi), order(O), time(T).


%%% dynamic effect and inertia

abnormal(request(O,P,Pi),T) :- holds(request(O,P,Pi),T-1), do(R,action(deliver(O,P)),T-1), time(T).


goal(T) :- not holds(request(_,_,_),T), time(T).
:- not goal(T), timelimit(T).

% dont do anything if goal was reached
:- goal(T), occurs(_,_,T).

