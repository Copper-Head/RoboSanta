% input:
% shelf_delivery_sequence(Order, Shelf, Number)
% robot_shelf_sequence(Shelf, Robot, Number)

robot_to_shelf(robot(R),shelf(S)) :- robot_shelf_sequence(S, R, N).
shelf_to_order(order(O),shelf(S)) :- shelf_delivery_sequence(O,S,N).

last_order(shelf(S),N) :- shelf_delivery_sequence(O,S,N), not shelf_delivery_sequence(O2,S,N+1), order(order(O2)).

%% limit delivery actions

% only the right robot can deliver the shelf
:- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), not robot_to_shelf(R,S).

% can only deliver using the right shelf
:- do(R,action(deliver(O,P)),T), holds(carry(R,S),T), not shelf_to_order(O,S).

% task is completed if the right robot delivers the shelf
done(task(O,S,N),T) :- delivered(robot(R),order(O),product(P),Pi,T), holds(carry(robot(R),shelf(S)),T), shelf_delivery_sequence(O,S,N), robot_to_shelf(robot(R),shelf(S)).

% remove answer if the previous task was done later (wrong order)
:- done(task(O1,S1,N),T1), done(task(O2,S1,N-1),T2), T2 > T1, N > 1, time(T1), time(T2).

% remove answer if task was not fulfilled
:- shelf_delivery_sequence(O,S,N), not done(task(O,S,N),T) : time(T).
#show done/2.

% only fulfill task once
:- 2{done(task(order(O),shelf(S),N),T) : time(T)}, shelf_delivery_sequence(O,S,N).


last_delivery(R,shelf(S),T) :- robot_to_shelf(R,shelf(S)), last_order(shelf(S),N), done(task(O,S,N),T).  
:- robot_shelf_sequence(S,R,N-1), robot_shelf_sequence(S2,R,N), S2 != S, last_delivery(R,shelf(S),T1), done(task(O,shelf(S2),1),T2), T2 < T1.
