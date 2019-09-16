% input:
% assign(Robot, Shelf, PickingStation)

%% limit delivery actions

% task is completed if the right robot delivers the shelf to the right picking station
done(task(R, S, Pi), T) :- delivered(R, O, P, Pi, T), holds(carry(R, S), T), assign(R, S, Pi).

% remove answer if task was not fulfilled
:- assign(R, S, Pi), not done(task(R, S, Pi), T) : time(T).
#show done/2.

% only fulfill task once
:- 2{done(task(R, S, Pi), T) : time(T)}, assign(R, S, Pi).
