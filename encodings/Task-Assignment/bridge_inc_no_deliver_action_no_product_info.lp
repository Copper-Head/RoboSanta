% input is a set of assigned(R,S,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

allowed(R,O,P,Pi) :- assigned(R,shelf(S),Pi,O), init(object(product,P),value(on,(S,A))), init(object(order,O),value(line,(P,A))).

#program step(t).

% use allowed to limit actions
:- delivered(R,O,P,Pi,t), not allowed(R,O,P,Pi).

fulfilled(R,S,Pi,O,t) :- delivered(R,O,P,Pi,t), holds(carry(R,S),t), assigned(R,S,Pi,O).

% ??
%:- assigned(R,S,Pi,O), not fulfilled(R,S,Pi,O,T) : time(T).
