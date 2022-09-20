function [Optodes, Types] = OP220906_FETp2
% FET OP Pilot 2, 6.9.2022
defs = {
    [14 15 14 13], 'neck_sqr_-135,-45';
    [16 15 14 15], 'neck_rect_-135,-45';
    [30 31 30 29], 'neck_sqr_-135,-45';
    [32 31 30 31], 'neck_rect_-135,-45';
    };
Types = strcat('Sheep3A_17x7.', defs(:,2));
Optodes = vertcat(defs{:,1});

end