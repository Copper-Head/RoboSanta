% format the action into the input for the visualizer
#program step(t).

occurs(R,action(move,(DX,DY)),t-1) :- do(R,action(move(DX,DY)),t-1).
occurs(R,action(pickup,()),t-1) :- do(R,action(pickup),t-1).
occurs(R,action(putdown,()),t-1) :- do(R,action(putdown),t-1).


occurs(R,action(deliver,(O,P,A)),t-1) :- do(R,action(deliver(O,P,A)),t-1).

occurs(R,action(deliver,(O,P)),t-1) :- do(R,action(deliver(O,P)),t-1).

occurs(R,action(deliver,(O,P)),t-1) :- delivered(R,O,P,_,t-1).

#show occurs/3.
