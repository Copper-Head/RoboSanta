% input:
% assign(Robot, Shelf, PickingStation)

%% limit delivery actions
sdelivered(R, Pi, T) :- delivered(R, O, P, Pi, T).

% task is completed if the right robot delivers the shelf to the right picking station
done(task(R, S, station(Pi)), T) :- sdelivered(R, pickingStation(Pi), T), holds(carry(R, S), T), assign(R, S, station(Pi)).

% remove answer if task was not fulfilled
:- assign(R, S, Pi), {done(task(R, S, Pi), T) : time(T)}0.
#show done/2.
