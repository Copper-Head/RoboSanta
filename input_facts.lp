node(X,Y) :- init(object(node,N),value(at,(X,Y))).

robot(robot(R)) :- init(object(robot,R),_).
shelf(shelf(S)) :- init(object(shelf,S),_).
order(order(O)) :- init(object(order,O),_).
product(product(P)) :- init(object(product,P),_).
pickingStation(pickingStation(P)) :- init(object(pickingStation,P),_).

at(pickingStation(P),node(X,Y)) :- init(object(pickingStation,P),value(at,(X,Y))).

highway(X,Y) :- init(object(highway,_),value(at,(X,Y))).

