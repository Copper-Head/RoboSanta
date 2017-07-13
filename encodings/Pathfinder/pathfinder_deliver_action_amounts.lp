
maxProduct(Amount) :- #max{A,O,P : init(object(order,O),value(line,(P,A)))} = Amount.
action(action(deliver(O,P,1..A))) :- order(O), product(P), maxProduct(A).

holds(on(product(P),shelf(S),A),0) :- init(object(product,P),value(on,(S,A))).
holds(request(order(O),product(P),pickingStation(Pi),A),0) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).


possible(R,action(deliver(O,P,1..A)),T) :- holds(at(R,node(X,Y)),t-1), holds(carry(R,S),T), holds(on(P,S,A),T), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),T), robot(R), shelf(S), product(P), pickingStation(Pi), order(O), A < A2, time(T).

possible(R,action(deliver(O,P,1..A2)),T) :- holds(at(R,node(X,Y)),T), holds(carry(R,S),T), holds(on(P,S,A),T), at(Pi,node(X,Y)), holds(request(O,P,Pi,A2),T), robot(R), shelf(S), product(P), pickingStation(Pi), order(O), time(T), A2 < A.


%%% helpers
delivered(R,O,P,T) :- do(R,action(deliver(O,P,_)),T), time(T).

%%% dynamic effect and inertia
holds(request(O,P,Pi,A-A2),T) :- holds(request(O,P,Pi,A),T-1), do(R,action(deliver(O,P,A2)),T-1), A > A2, time(T).
holds(on(P,S,A-A2),T) :- holds(on(P,S,A),T-1), holds(carry(R,S),T-1), do(R,action(deliver(O,P,A2)),T-1), A > A2, time(T).

abnormal(request(O,P,Pi,A),T) :- holds(request(O,P,Pi,A),T-1), delivered(R,O,P,T-1), time(T).
abnormal(on(P,S,A),T) :- holds(on(P,S,A),T-1), holds(carry(R,S),T-1), delivered(R,O,P,T-1), time(T).


goal(T) :- not holds(request(_,_,_,_),T), time(T).
:- not goal(T), timelimit(T).

% dont do anything if goal was reached
:- goal(T), occurs(_,_,T).
