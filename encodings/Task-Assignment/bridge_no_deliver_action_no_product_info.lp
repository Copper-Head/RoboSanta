% input is a set of assigned(R,S,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

allowed(R,O,P,Pi) :- assigned(R,shelf(S),Pi,O), init(object(product,P),value(on,(S,A))), init(object(order,O),value(line,(P,A))).

% use allowed to limit actions
% delivered(R,O,P,Pi,T)
:- delivered(R,O,P,Pi,T), not allowed(R,O,P,Pi), time(T).

fulfilled(R,S,Pi,O,T) :- delivered(R,O,P,Pi,T), holds(carry(R,S),T), assigned(R,S,Pi,O), time(T).


:- assigned(R,S,Pi,O), not fulfilled(R,S,Pi,O,T) : time(T).
