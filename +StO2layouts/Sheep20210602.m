function [Optodes, Types] = Sheep20210602
% 1st sheep
Optodes = [
        5  1  2  6;
        1  5  6  2; % *
        3  7  8  4;
        7  3  4  8;
        5  9 10  6;
        9  5  6 10;
       11  7  8 12;
        7 11 12  8;
        3  3  5  5; % *
        4  4  6  6;
        7  7  9  9; % * 
        8  8 10 10; % *
        ];
    

Types = repmat({
    'Rectangular36-18' 
    }, size(Optodes,1),1);
end