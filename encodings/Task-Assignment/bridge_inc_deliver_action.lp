% input is a set of assigned(R,S,Pi,O) predicates
% R = robot, S = shelf, Pi = Picking station, O = order

#program base.
allowed(R,action(deliver(O,product(P)))) :- assigned(R,shelf(S),Pi,O), init(object(product,P),value(on,(S,A))).

% use allowed to limit actions
#program step(t).
:- do(R,action(deliver(O,P)),t), not allowed(R,action(deliver(O,P))).



