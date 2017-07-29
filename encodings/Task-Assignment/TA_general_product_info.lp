
% get robot ids
robot(robot(R)) :- init(object(robot,R),_).
shelf(shelf(S)) :- init(object(shelf,S),_).


% get distance to pickingstation for each shelf
dist(shelf(S),pickingStation(Pi),D) :- init(object(shelf,S),value(at,(SX,SY))), init(object(pickingStation,Pi),value(at,(PiX,PiY))), D = |SX-PiX| + |SY-PiY|.

% get the distance of each robot to each shelf
rdist(robot(R),shelf(S), D) :- init(object(shelf,S),value(at,(SX,SY))), init(object(robot,R),value(at,(RX,RY))), D = |SX-RX| + |SY-RY|.

% get which product we need
needproduct(product(P), pickingStation(Pi),order(O)) :- init(object(order,O),value(line,(P,A))), init(object(order,O),value(pickingStation,Pi)).

% list which shelf can potentially be needed
potential_task(shelf(S),product(P),Pi,O) :- init(object(product,P),value(on,(S,A))), needproduct(product(P),Pi,O).

% chose a subset of shelfs
1{chosen(S,P,Pi,O) : potential_task(S,P,Pi,O)}.

% all needed products need a shelf
:- needproduct(product(P),Pi,O), not chosen(shelf(S),product(P),Pi,O) : init(object(product,P),value(on,(S,_))).


%%%
% assign task to robot

{assigned(R,S,P,Pi,O) : robot(R)}=1 :- chosen(S,P,Pi,O).
:- assigned(R,S,P,Pi,O), assigned(R2,S,P,Pi,O), R != R2.

%%%
% evaluate solution

% estimated distance for all shelfs to travel
shelfused(S,C) :- #sum{1,P,Pi,O : chosen(S,P,Pi,O)} = C, shelf(S).
shelftravel(S,T*U) :- shelfused(S,U), #sum{ D,P,Pi,O : chosen(S,P,Pi,O), dist(S,Pi,D) } = T.

% estimated travel distance to shelfs
taskcount(R,C) :- #sum{1,S,P,Pi,O : assigned(R,S,P,Pi,O)} = C, robot(R).
robottravel(R,T*C) :- taskcount(R,C), #sum{ D,S,P,Pi,O : assigned(R,S,P,Pi,O), rdist(R,S,D) } = T.

#minimize{ T : shelftravel(S,T) }.
#minimize{ T : robottravel(R,T) }.


%#show chosen/3.
%#show shelftravel/2.
#show assigned/5.
%#show robottravel/2.

