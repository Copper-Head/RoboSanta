%choose a shelf for delivery
{delivery(O, S) : onShelf(P, S)} = 1 :- ordered(O, P).
shelf_last_delivery(shelf(S), N) :- N=#count{O: delivery(O, shelf(S))}, shelf(S).
shelf_delivery_numbers(shelf(S), 1..N) :- shelf(S), shelf_last_delivery(shelf(S), N).

%delivery ordered
{shelf_delivery_sequence(O, S, N) : delivery(O, S)} = 1 :- shelf_delivery_numbers(S, N).
{shelf_delivery_sequence(O, S, N) : shelf_delivery_numbers(S, N)} = 1 :- delivery(O, S).

%pick a robot for shelf
{pairing(shelf(S), robot(R)) : robot(R)} = 1 :- shelf(S).
robot_shelves(robot(R), Z) :- #count{S : pairing(S, robot(R))} = Z, robot(R).
{robot_shelf_sequence(S, R, N) : N=1..Z} = 1 :- pairing(S, R), robot_shelves(R, Z).
:- robot_shelf_sequence(S1, R, N), robot_shelf_sequence(S2, R, N), S1 != S2.

%deliver everything to a given picking station consecutively
:- shelf_delivery_sequence(O1, S, M-1), shelf_delivery_sequence(O2, S, M), shelf_delivery_sequence(O3, S, N), target(O1,PS1), target(O2,PS2), target(O3,PS1), PS1!=PS2, N>M.