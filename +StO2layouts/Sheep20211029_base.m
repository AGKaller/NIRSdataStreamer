function [Optodes, Types] = Sheep20211029_base
% 2nd Sheep, patches without optodes on eyes and w/o posterior optodes
Optodes = [
    % horizontal:
    1 1 3 2;
    4 1 3 5;
    4 4 6 5;
    7 4 5 9;
    8 5 6 10;
    8 4 6 9;
    7 7 8 9;
    8 8 9 10;
    8 7 9 9;
    11 7 8 13;
    12 8 9 14;
    12 7 9 13;
    11 10 11 13;
    12 11 12 14;
    12 10 12 13;
    15 10 12 16;
    15 13 14 16;
    % vertical
    10 6 12 14;
    2 3 6 9;
    5 6 9 13;
    9 9 12 16;
    5 3 9 9;
    9 6 12 13;
    13 9 14 16;
    2 2 5 9;
    5 5 8 13;
    9 8 11 16;
    5 2 8 9;
    9 5 11 13;
    1 2 5 8;
    4 5 8 12;
    8 8 11 15;
    4 2 8 8;
    8 5 11 12;
    1 1 4 8;
    4 4 7 12;
    8 7 10 15;
    4 1 7 8;
    8 4 10 12;
    12 7 13 15;
    7 4 10 11;
    ... RECTENGULARS? (different type!)
    ];
Types = repmat({'Trapeze25-50'}, ...
                size(Optodes,1),1);

end