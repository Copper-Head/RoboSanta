% input:
% shelf_delivery_sequence(Order, Shelf, Number)
% robot_shelf_sequence(Shelf, Robot, Number)

robot_to_shelf(R,S) :- robot_shelf_sequence(S, R, N).
shelf_to_order(O,S) :- shelf_delivery_sequence(O,S,N).

%% limit delivery actions

% only the right robot can deliver the shelf
:- do(R,action(deliver(O,P),T), holds(carry(R,S),T), not robot_to_shelf(R,S).

% can only deliver using the right shelf
:- do(R,action(deliver(O,P),T), holds(carry(R,S),T), not shelf_to_order(O,S).

% task is completed if the right robot delivers the shelf
done(task(O,S,N),T) :- do(R,action(deliver(O,P),T), holds(carry(R,S),T), shelf_delivery_sequence(O,S,N), robot_to_shelf(R,S).

% remove answer if the previous task was done later (wrong order)
:- done(task(O1,S1,N),T1), done(task(O2,S2,N-1),T2), T2 > T1, N > 1, time(T1), time(T2).

% remove answer if task was not fulfilled
:- shelf_delivery_sequence(O,S,N), not done(task(O,S,N),T) : time(T).

% only fulfill task once
:- 2{done(task(O,S,N),T) : time(T)}, shelf_delivery_sequence(O,S,N).
