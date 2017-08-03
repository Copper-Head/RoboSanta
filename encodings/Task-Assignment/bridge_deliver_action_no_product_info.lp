% input is a set of assigned(R,S,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

% limit actions
:- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), not assigned(R,S,Pi,O), time(T).

% check if every assignment is fulfilled
fulfilled(R,S,Pi,O,T) :- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), assigned(R,S,Pi,O), time(T)

:- assigned(R,S,Pi,O), not fulfilled(R,S,Pi,O,T) : time(T).



