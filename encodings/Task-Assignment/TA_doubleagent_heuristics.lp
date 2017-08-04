#include "../input_torsten.lp".
#include "./TA_doubleagent.lp".

%shelf cost calculation - basic L1 metric
shelf_target_cost(S, M, Z) :- shelf_delivery_sequence(O1, S, M), target(O1,PS1), shelf_delivery_sequence(O2, S, M+1), target(O2,PS2), PS1 != PS2, position(PS1,(X1,Y1)), position(PS2,(X2,Y2)), |X1-X2| + |Y1-Y2| = Z.

shelf_cost(shelf(S), C) :- C = #sum{Z : shelf_target_cost(shelf(S), M, Z)}, shelf(S).

%robot cost calculation - L1 metric again
robot_shelf_cost(R, S2, C) :- robot_shelf_sequence(S1, R, N-1), shelf_last_delivery(S1, M), shelf_delivery_sequence(O, S1, M), target(O1,PS1), position(PS1,(X1,Y1)), robot_shelf_sequence(S2, R, N), position(S2,(X2,Y2),0), C = |X1-X2| + |Y1-Y2|.

%collecting all the costs
robot_single_cost(robot(R), W + Z) :- Z = #sum{C : robot_shelf_cost(robot(R), S, C)}, position(robot(R),(X1,Y1),0), robot_shelf_sequence(S1, robot(R), 1), position(S1,(X2,Y2),0), W = |X1-X2| + |Y1-Y2|, robot(R).

robot_shelf_cost(robot(R), Y) :- Y = #sum{C : pairing(S, robot(R)), shelf_cost(S, C)}, robot(R).

robot_total_cost(R, Y + Z) :- robot_shelf_cost(R, Y), robot_single_cost(R, Z).

total_cost(1..Y+Z) :- robot_shelf_cost(R, Y), robot_single_cost(R, Z).

#minimize{1,Z: total_cost(Z)}.

%old optimizer version
%robot_highest_cost(Z) :- Z = #max{C,R : robot_total_cost(R, C)}.
%#minimize{Z: robot_highest_cost(Z)}.

#show shelf_last_delivery/2.
#show shelf_delivery_sequence/3.
#show robot_shelf_sequence/3.