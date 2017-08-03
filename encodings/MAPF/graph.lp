%% ====================================================================
%% Define an abstract graph with nodes and edges instead of coordinates
%% ====================================================================
node(N) :- init(object(node,N),value(at,(X,Y))).

%% Infer edges from neighboring nodes.
%% Investigate: does it make sense to include highway information at this point?
edge(N1, N2) :- init(object(node,N1), value(at,(X,Y1))),
                init(object(node,N2), value(at,(X,Y2))),
                |Y1 - Y2| == 1.
edge(N1, N2) :- init(object(node,N1), value(at,(X1,Y))),
                init(object(node,N2), value(at,(X2,Y))),
                |X1 - X2| == 1.
