function [Optodes, Types] = OP220222_FETp1
% FET OP Pilot 1, 22.02.2022
defs = {
    [1  5  6  2], 'Trap1-5-6-2_in';
    [1  1  2  2], 'Trap1-1-2-2_out';
    [2  6  7  3], 'Trap2-6-7-3_in';
    [2  2  3  3], 'Trap2-2-3-3_out';
    [8 12 13  9], 'Trap8-12-13-9_in';
    [8  9 10  9], 'Trap8-9-10-9_out';
    [9 13 14 10], 'Trap9-13-14-10_in';
    [9 10 11 10], 'Trap9-10-11-10_out';    
    };
Types = strcat('OP220222_FETp1.', defs(:,2));
Optodes = vertcat(defs{:,1});

end