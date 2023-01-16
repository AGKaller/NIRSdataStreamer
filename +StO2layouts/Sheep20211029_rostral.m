function [Optodes, Types] = Sheep20211029_rostral
% 2nd Sheep, patches without optodes on eyes and w/o posterior optodes
Optodes = [
    % horizontal:
    3 1 2 5;
    4 2 3 6;
    3 4 5 5;
    4 5 6 6;
    % vertical
    6 3 9 10;
    6 6 9 14;
    3 1 7 7;
    3 4 7 11;
    ... RECTENGULARS? (different type!)
    ];
Types = repmat({'Trapeze25-50'}, ...
                size(Optodes,1),1);
end