function [Optodes, Types] = Sheep3A_17x7
% 3rd Sheep

import StO2layouts.Sheep3A_17x7.neckUS

% TRAPEZOIDS (HEAD)
patches = {
    % horizontal:
    1 2 9 9     'head_trap_oo'; % othogonal, outward
    2 2 3 10    'head_trap_oo';
    3 2 9 10    'head_trap_oo';
    3 3 9 11    'head_trap_oo';
    2 4 5 10    'head_trap_oi'; % orthogonal, inward
    3 4 10 10   'head_trap_oi';
    3 5 10 11   'head_trap_oi';
    4 4 5 12    'head_trap_oi';
    5 4 10 12   'head_trap_oi';
    5 5 10 13   'head_trap_oi';
    4 6 11 12   'head_trap_oo';
    5 6 12 12   'head_trap_oo';
    5 11 12 13  'head_trap_oo';
    6 6 11 14   'head_trap_oo';
    7 6 12 14   'head_trap_oo';
    7 11 12 15  'head_trap_oo';
    6 7 13 14   'head_trap_oi';
    7 7 14 14   'head_trap_oi';
    7 13 14 15  'head_trap_oi';
    8 7 14 16   'head_trap_oo';
    8 8 16 16   'head_trap_oi';
    
    % vertical
    2 2 6 4      'head_trap_piss'; % parallel inward, src on short side
    2 4 6 6      'head_trap_a';    % antisymmetric
    4 4 7 6      'head_trap_poss';
    1 2 4 5      'head_trap_a';
    3 2 6 5      'head_trap_piss';
    3 4 6 7      'head_trap_a';
    5 4 7 7      'head_trap_poss';
    5 6 7 8      'head_trap_posl'; % parallel outward, src on long side
    7 6 8 8      'head_trap_a';
    1 1 5 3      'head_trap_poss';
    1 3 5 5      'head_trap_a';
    3 3 11 5     'head_trap_piss';
    3 5 11 7     'head_trap_a';
    5 5 13 7     'head_trap_poss';
    5 11 13 8    'head_trap_posl';
    7 11 15 8    'head_trap_a';
    9 1 5 10     'head_trap_poss';
    9 3 5 12     'head_trap_a';
    10 3 11 12   'head_trap_piss';
    10 5 11 14   'head_trap_a';
    12 5 13 14   'head_trap_poss';
    12 11 13 16  'head_trap_posl';
    14 11 15 16  'head_trap_a';
    9 9 10 12    'head_trap_a';
    10 9 12 12   'head_trap_piss';
    10 10 12 14  'head_trap_a';
    12 10 14 14  'head_trap_piss';
    12 12 14 16  'head_trap_pisl';
    14 12 16 16  'head_trap_a';
    11 9 12 13   'head_trap_piss';
    11 10 12 15  'head_trap_a';
    13 10 14 15  'head_trap_poss';
    
    % RECTENGULARS
    28 26 25 26 'neck_rect_-135,45';
    27 26 25 25 'neck_sqr_-135,45';
    32 28 27 30 'neck_rect_-135,45';
    31 28 27 29 'neck_sqr_-135,45';
    
    };

Optodes = cell2mat(patches(:,1:4));
Types = strcat('Sheep3A_17x7.',patches(:,5));

% get double-sampled neck patches:
[oNeck, tNeck] = neckUS;
Optodes = [Optodes; oNeck];
Types = [Types; tNeck];

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