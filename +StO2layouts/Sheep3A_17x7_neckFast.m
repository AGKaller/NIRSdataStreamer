function [Optodes, Types] = Sheep3A_17x7_neckFast
% 3rd Sheep

% TRAPEZOIDS (HEAD)
patches = {
    % RECTENGULARS
    24 24 23 22 'neck_rect_-135,45'; % outward up down
    23 21 22 24 'neck_rect_135,-45'; % inward up down
    20 20 22 21 'neck_rect_45,-135';
    19 18 17 18 'neck_rect_-135,45';
    18 20 19 17 'neck_rect_-45,135';
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

end











% 
% clear 
% grd = [0,0,0,201,0,0,0;0,0,101,0,109,0,0;0,202,0,203,0,209,0;102,0,103,0,110,0,111;0,204,0,205,0,210,0;104,0,105,0,112,0,113;0,206,0,211,0,212,0;106,0,107,0,114,0,115;0,207,0,213,0,214,0;0,0,108,0,116,0,0;0,208,0,215,0,216,0];
% grdsz = size(grd);
% isSrc = (grd>100 & grd <200);
% isDet = (grd>200);
% idxSrc = find(isSrc);
% idxDet = find(isDet);
% 
% for s = 1:numel(idxSrc)
%     sn1 = grd(idxSrc(s))-100;
%     [r,c] = ind2sub(grdsz,idxSrc(s));
%     
%     if c+3 < grdsz(2) && isSrc(r,c+4)
%         sn2 = grd(r,c+4);
%         