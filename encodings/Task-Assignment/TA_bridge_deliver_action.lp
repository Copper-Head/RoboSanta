% input is a set of assigned(R,S,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

allowed(R,action(deliver(O,product(P)))) :- assigned(R,shelf(S),Pi,O), init(object(product,P),value(on,(S,A))).

% use allowed to limit actions
:- do(R,action(deliver(O,P)),T), not allowed(R,action(deliver(O,P))), time(T).



