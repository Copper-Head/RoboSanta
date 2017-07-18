#include "./format.lp".

%choose a shelf for delivery
{delivery(O, S) : onShelf(product(P), shelf(S))} = 1 :- ordered(order(O), product(P)).
shelf_last_delivery(S, N) :- N=#count{O: delivery(O, S)}, shelf(S).
shelf_delivery_numbers(S, 1..N) :- shelf(S), shelf_last_delivery(S, N).

%delivery ordered
{shelf_delivery_sequence(O, S, N) : delivery(O, S)} = 1 :- shelf_delivery_numbers(S, N).
{shelf_delivery_sequence(O, S, N) : shelf_delivery_numbers(S, N)} = 1 :- delivery(O, S).

%pick a robot for shelf
{pairing(S, R) : robot(R)} = 1 :- shelf(S).
robot_shelves(R, Z) :- #count{S : pairing(S, R)} = Z, robot(R).
{robot_shelf_sequence(S, R, N) : N=1..Z} = 1 :- pairing(S, R), robot_shelves(R, Z).
:- robot_shelf_sequence(S1, R, N), robot_shelf_sequence(S2, R, N), S1 != S2.

%deliver everything to a given picking station consecutively
:- shelf_delivery_sequence(O1, S, M-1), shelf_delivery_sequence(O2, S, M), shelf_delivery_sequence(O3, S, N), target(order(O1),station(P1)), target(order(O2),station(P2)), target(order(O3),station(P1)), P1!=P2, N>M.

%shelf cost calculation - basic L1 metric
shelf_target_cost(S, M, Z) :- shelf_delivery_sequence(O1, S, M), target(order(O1),station(P1)), shelf_delivery_sequence(O2, S, M+1), target(order(O2),station(P2)), P1 != P2, position(station(P1),(X1,Y1)), position(station(P2),(X2,Y2)), |X1-X2| + |Y1-Y2| = Z.

shelf_cost(S, C) :- C = #sum{Z : shelf_target_cost(S, M, Z)}, shelf(S).

%robot cost calculation - L1 metric again
robot_shelf_cost(R, S2, C) :- robot_shelf_sequence(S1, R, N-1), shelf_last_delivery(S1, M), shelf_delivery_sequence(O, S1, M), target(order(O1),station(P1)), position(station(P1),(X1,Y1)), robot_shelf_sequence(S2, R, N), position(shelf(S2),(X2,Y2),0), C = |X1-X2| + |Y1-Y2|.

robot_cost(R, W + Z) :- Z = #sum{C : robot_shelf_cost(R, S, C)}, position(robot(R),(X1,Y1),0), robot_shelf_sequence(S1, R, 1), position(shelf(S1),(X2,Y2),0), W = |X1-X2| + |Y1-Y2|, robot(R).

% these minimize statements don't account for time, just sum of robot moves
#minimize{C: shelf_cost(S, C)}.
#minimize{C: robot_cost(R, C)}.

#show delivery/2.
#show pairing/2.
#show robot_shelves/2.
#show robot_shelf_sequence/3.
#show shelf_delivery_sequence/3.
#show shelf_last_delivery/2.
#show shelf_target_cost/3.
#show shelf_cost/2.
#show robot_shelf_cost/3.
#show robot_cost/2.