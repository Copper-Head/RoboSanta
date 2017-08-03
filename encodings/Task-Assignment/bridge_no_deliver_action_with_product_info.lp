% input is a set of assigned(R,S,P,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

% limit actions
% robot delivered a product in a shelf for an order and it was not assigned to do so
:- delivered(R,O,P,Pi,T), holds(carry(R,S),T), not assigned(R,S,P,Pi,O), time(T).


% check that every assignment is fulfilled
fulfilled(R,S,P,Pi,O,T) :- delivered(R,O,P,Pi,T), holds(carry(R,S),T), assigned(R,S,P,Pi,O), time(T).


:- assigned(R,S,P,Pi,O), not fulfilled(R,S,P,Pi,O,T) : time(T).

#show fulfilled/6.
#show assigned/5.

