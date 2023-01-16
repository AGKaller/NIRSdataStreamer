function [Optodes, Types] = Sheep20211029_caudal
% 2nd Sheep, patches without optodes on eyes and w/o posterior optodes
Optodes = [
    % horizontal:
    3 13 14 6;
    % vertical
    13 12 14 6;
    12 10 13 3;
    ... RECTENGULARS? (different type!)
    ];
Types = repmat({'Trapeze25-50'}, ...
                size(Optodes,1),1);
end