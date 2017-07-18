#include "./format.lp".

%choose a robot for delivery
{delivery(O, R) : robot(R)} = 1 :- order(O).

%pick a robot for the shelves 
delivery_count(R, C) :- C = #count{O: delivery(O, R)}, robot(R).
delivery_numbers(R, 1..C) :- delivery_count(R, C).

delivery_count(R, C) :- C = #count{O: delivery(O, R)}, robot(R).
delivery_numbers(R, 1..C) :- delivery_count(R, C).

%delivery order for robot (can this be done better?)
{delivery_order(O, R, N) : delivery(O, R)} = 1 :- delivery_numbers(R, N). 
{delivery_order(O, R, N) : delivery_numbers(R, N)} = 1 :- delivery(O, R).

%costs 
order_path(O, X1, Y1, X2, Y2) :- target(order(O),station(P)), ordered(order(O),product(A)), onShelf(product(A),shelf(S)), position(shelf(S),(X1,Y1),0), position(station(P),(X2,Y2)).

return_path(O1, O2, X1, Y1, X2, Y2) :- target(order(O1),station(P)), ordered(order(O2),product(A)), onShelf(product(A),shelf(S)), position(shelf(S),(X2,Y2),0),  position(station(P),(X1,Y1)), delivery_order(O1, R, N), delivery_order(O2, R, N+1).

order_cost(O, |X1-X2| + |Y1-Y2|) :- order_path(O, X1, Y1, X2, Y2).

return_cost(O1, |X1-X2| + |Y1-Y2|) :- return_path(O1, O2, X1, Y1, X2, Y2).

%estimate path_cost for robot
robot_path_cost(Z, R) :- robot(R), Z=#sum{N : order_cost(O, N) , delivery(O, R); M : return_cost(O, M) , delivery(O, R)}.

#minimize{Z: robot_path_cost(Z,R)}.

%#show delivery_count/2.
%#show delivery_numbers/2.
#show delivery_order/3.
%#show robot_path_cost/2.