#include "./format.lp".

%choose a robot for delivery
{delivery(O, R) : robot(R)} = 1 :- order(O).

%pick a robot for the shelves 
delivery_count(R, C) :- C = #count{O: delivery(O, R)}, robot(R).
delivery_numbers(R, 1..C) :- delivery_count(R, C).

delivery_count(R, C) :- C = #count{O: delivery(O, R)}, robot(R).
delivery_numbers(R, 1..C) :- delivery_count(R, C).

%delivery order for robot
{delivery_order(O, R, N) : delivery(O, R)} = 1 :- delivery_numbers(R, N). 
{delivery_order(O, R, N) : delivery_numbers(R, N)} = 1 :- delivery(O, R).

%#show delivery_count/2.
%#show delivery_numbers/2.
%#show delivery_order/3.