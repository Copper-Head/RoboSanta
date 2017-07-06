#include "./format.lp".
#include "./task_assignement.lp".

%shelf cost calculation - basic L1 metric
shelf_target_cost(S, M, Z) :- shelf_delivery_sequence(O1, S, M), target(order(O1),station(P1)), shelf_delivery_sequence(O2, S, M+1), target(order(O2),station(P2)), P1 != P2, position(station(P1),(X1,Y1)), position(station(P2),(X2,Y2)), |X1-X2| + |Y1-Y2| = Z.

shelf_cost(S, C) :- C = #sum{Z : shelf_target_cost(S, M, Z)}, shelf(S).

%robot cost calculation - L1 metric again
robot_shelf_cost(R, S2, C) :- robot_shelf_sequence(S1, R, N-1), shelf_last_delivery(S1, M), shelf_delivery_sequence(O, S1, M), target(order(O1),station(P1)), position(station(P1),(X1,Y1)), robot_shelf_sequence(S2, R, N), position(shelf(S2),(X2,Y2),0), C = |X1-X2| + |Y1-Y2|.

%collecting all the costs
robot_single_cost(R, W + Z) :- Z = #sum{C : robot_shelf_cost(R, S, C)}, position(robot(R),(X1,Y1),0), robot_shelf_sequence(S1, R, 1), position(shelf(S1),(X2,Y2),0), W = |X1-X2| + |Y1-Y2|, robot(R).

robot_shelf_cost(R, Y) :- Y = #sum{C : pairing(S, R), shelf_cost(S, C)}, robot(R).

robot_total_cost(R, Y + Z) :- robot_shelf_cost(R, Y), robot_single_cost(R, Z).

robot_highest_cost(Z) :- Z = #max{C,R : robot_total_cost(R, C)}.

#minimize{Z: robot_highest_cost(Z)}.