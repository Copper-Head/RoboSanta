#program base.
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
potential_task(shelf(S),Pi,O) :- init(object(product,P),value(on,(S,A))), needproduct(product(P),Pi,O).

% chose a subset of shelfs
1{chosen(shelf(S),Pi,O) : potential_task(shelf(S),Pi,O)}.

% all needed products need a shelf
:- needproduct(product(P),Pi,O), not chosen(shelf(S),Pi,O) : init(object(product,P),value(on,(S,_))).


%%%
% assign task to robot

{assigned(R,S,Pi,O) : robot(R)}=1 :- chosen(S,Pi,O).

%%%
% evaluate solution

% estimated distance for all shelfs to travel
shelfused(S,C) :- #sum{1,Pi,O : chosen(S,Pi,O)} = C, shelf(S).
shelftravel(S,T*U) :- shelfused(S,U), #sum{ D,Pi,O : chosen(S,Pi,O), dist(S,Pi,D) } = T.

%shelftravel(T) :- #sum{ D,S,Pi,O : chosen(S,Pi,O), dist(S,Pi,D) } = T.

% estimated travel distance to shelfs
taskcount(R,C) :- #sum{1,S,Pi,O : assigned(R,S,Pi,O)} = C, robot(R).
robottravel(R,T*C) :- taskcount(R,C), #sum{ D,S,Pi,O : assigned(R,S,Pi,O), rdist(R,S,D) } = T.

#minimize{ T : shelftravel(S,T) }.
#minimize{ T : robottravel(R,T) }.


#show chosen/3.
#show shelftravel/2.
#show assigned/4.
#show robottravel/2.

