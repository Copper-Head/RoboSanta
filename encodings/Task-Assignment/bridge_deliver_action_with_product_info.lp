% input is a set of assigned(R,S,P,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

% limit actions
:- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), not assigned(R,S,P,Pi,O), time(T).

fulfilled(R,S,P,Pi,O,T) :- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), assigned(R,S,P,Pi,O), time(T)

:- assigned(R,S,P,Pi,O), not fulfilled(R,S,P,Pi,O,T) : time(T).


