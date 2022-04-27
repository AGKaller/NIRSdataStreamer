function [Optodes, Types] = neckUS_shorts
% 3rd Sheep

import StO2layouts.Sheep3A_17x7.neckUS

% TRAPEZOIDS (HEAD)
patches = {
    % RECTENGULARS
    21 23 18 20 'neck_lin_i,-45,135'; % cable inward, src inside
    22 22 20 19 'neck_lin_o,-45,135'; % cable inward, src outside
    
    23 23 21 22 'neck_sqr_a';
    19 19 18 17 'neck_sqr_oi';
    
    22 22 24 23 'neck_trap_a';
    20 19 22 22 'neck_trap_a';
    19 29 21 21 'neck_trap_pisl'; % parallel, inward, sources on long side
    19 20 17 17 'neck_trap_oi';
    
    };

Optodes = cell2mat(patches(:,1:4));
Types = strcat('Sheep3A_17x7.',patches(:,5));

% get other neckUS patches:
[oNeck, tNeck] = neckUS;
Optodes = [Optodes; oNeck];
Types = [Types; tNeck];

end

        