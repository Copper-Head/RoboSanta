% format the action into the input for the visualizer

occurs(R,action(move,(DX,DY)),T) :- do(R,action(move(DX,DY)),T).
occurs(R,action(pickup,()),T) :- do(R,action(pickup),T).
occurs(R,action(putdown,()),T) :- do(R,action(putdown),T).


occurs(R,action(deliver,(O,P,A)),T) :- do(R,action(deliver(O,P,A)),T).

occurs(R,action(deliver,(O,P)),T) :- do(R,action(deliver(O,P)),T).

occurs(R,action(deliver,(O,P)),T) :- delivered(R,O,P,_,T).

#show occurs/3.
