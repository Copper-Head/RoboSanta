% input is a set of assigned(R,S,P,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

% limit actions
% robot delivered a product in a shelf for an order and it was not assigned to do so
#program step(t).
:- delivered(R,O,P,Pi,t), holds(carry(R,S),t), not assigned(R,S,P,Pi,O).


% check that every assignment is fulfilled
fulfilled(R,S,P,Pi,O,t) :- delivered(R,O,P,Pi,t), holds(carry(R,S),t), assigned(R,S,P,Pi,O).

% ??
%:- assigned(R,S,P,Pi,O), not fulfilled(R,S,P,Pi,O,t) : time(T).

#show fulfilled/6.
#show assigned/5.

