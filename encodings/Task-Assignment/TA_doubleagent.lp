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