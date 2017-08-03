%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid Size X:                      4
% Grid Size Y:                      4
% Number of Nodes:                  16
% Number of Robots:                 2
% Number of Shelves:                2
% Number of picking stations:       1
% Number of products:               2
% Number of product units in total: 4
% Number of orders:                 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% init

% Grid cells
init(object(node,1), value(at,(1,1))).
init(object(node,2), value(at,(2,1))).
init(object(node,3), value(at,(3,1))).
init(object(node,4), value(at,(4,1))).
init(object(node,5), value(at,(1,2))).
init(object(node,6), value(at,(2,2))).
init(object(node,7), value(at,(3,2))).
init(object(node,8), value(at,(4,2))).
init(object(node,9), value(at,(1,3))).
init(object(node,10),value(at,(2,3))).
init(object(node,11),value(at,(3,3))).
init(object(node,12),value(at,(4,3))).
init(object(node,13),value(at,(1,4))).
init(object(node,14),value(at,(2,4))).
init(object(node,15),value(at,(3,4))).
init(object(node,16),value(at,(4,4))).

% Robot locations
init(object(robot,1),value(at,(4,1))).
init(object(robot,2),value(at,(1,1))).

% Picking station location(s)
init(object(pickingStation,1),value(at,(4,2))).

% Shelf locations
init(object(shelf,1),value(at,(4,1))).
init(object(shelf,2),value(at,(4,4))).

% Product shelves
init(object(product,1),value(on,(1,3))). % three units of product 1 on shelf 1
%init(object(product,1),value(on,(2,1))). % one unit    of product 1 on shelf 2
init(object(product,2),value(on,(2,2))). % two units   of product 2 on shelf 2

% Pending orders
init(object(order,1),value(line,(2,1))).       % one unit of product 2 in order 1
init(object(order,1),value(pickingStation,1)). % deliver order 1 to picking station 1

init(object(order,2),value(line,(1,2))).       % two units of product 1 in order 2
init(object(order,2),value(pickingStation,1)). % deliver order 2 to picking station 1



