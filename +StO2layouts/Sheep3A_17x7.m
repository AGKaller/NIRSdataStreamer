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
    % head (45°)                                      D     
     1  1  9 10  'head_rectWide_-135,45';       %   S     
    10  5  2  1  'head_rectWide_-135,45';       %             D
     2  2  5  5  'head_rectWide_45,-135';       %           S
    11 10  3  9  'head_rectWide_-135,45';
     3  3 10 12  'head_rectWide_45,-135';
    12 11  4  3  'head_rectWide_45,-135';
     4  4 11  7  'head_rectWide_-135,45';
    13 12  5 10  'head_rectWide_45,-135';
     5  5 12 14  'head_rectWide_-135,45';
    14 13  6  5  'head_rectWide_-135,45';
     6  6 13  8  'head_rectWide_45,45';
    15 14 11 12  'head_rectWide_-135,12';
     7 11 14 16  'head_rectWide_45,45';
    16 15  7  7  'head_rectWide_-135,-135';
     3  2  1  9  'head_rectWide_-45,135';
     9  9  5  3  'head_rectWide_-45,135';
    12  5  9 11  'head_rectWide_135,-45';
     1  3  4  2  'head_rectWide_-45,135';
     5  4  3 10  'head_rectWide_135,-45';
    10 10 11  5  'head_rectWide_135,-45';
    14 11 10 13  'head_rectWide_-45,135';
     3  5  6  4  'head_rectWide_135,-45';
     7  6  5 12  'head_rectWide_-45,135';
    12 12 13  7  'head_rectWide_-45,135';
    16 13 12 15  'head_rectWide_-45,-45';
     5 11  7  6  'head_rectWide_-45,135';
     8  7 11 14  'head_rectWide_-45,-45';
    14 14 15  8  'head_rectWide_135,135';

    % neck (rects are tall)                 D  D
    28 26 25 26 'neck_rect_-135,45';
    27 26 25 25 'neck_sqr_-135,45';     %   S  S
    32 28 27 30 'neck_rect_-135,45';
    31 28 27 29 'neck_sqr_-135,45';

    % PARALLELOGRAMS (head)
    % long            S    |    S            |            D    |    D            
    %           D   D      |      D   D      |      S   S      |      S   S      
    %         S            |            S    |    D            |            D    
    %       UpSourceOut    |     DownSo      |   UpSourceIn    |      DownSi
     2  4  6  7 'head_parallgrmL_UpSo_90,90';
     4  6  7  8 'head_parallgrmL_UpSo_-90,90';
     4  4  2  1 'head_parallgrmL_DownSo_90,90';
     6  6  4  3 'head_parallgrmL_DownSo_-90,-90';
     1  3  5 12 'head_parallgrmL_UpSo_-90,-90';
     3  5 11 14 'head_parallgrmL_UpSo_90,90';
     5 11 13 16 'head_parallgrmL_UpSo_-90,90';
     5  5  3  9 'head_parallgrmL_DownSo_90,90';
     7 11  5 10 'head_parallgrmL_DownSo_-90,-90';
     8 13 11 12 'head_parallgrmL_DownSo_-90,90';
     9  9 10 13 'head_parallgrmL_UpSo_-90,-90';
    10 10 12 15 'head_parallgrmL_UpSo_90,90';
    14 12 10 11 'head_parallgrmL_DownSo_-90,-90';
    16 14 12 13 'head_parallgrmL_DownSo_-90,90';
     3  4  1  1 'head_parallgrmL_DownSi_-90,90';
     5  6  3  3 'head_parallgrmL_DownSi_90,-90';
     7  7  5  5 'head_parallgrmL_DownSi_-90,90';
     8  8 11  7 'head_parallgrmL_DownSi_-90,-90';
     5 11  2  3 'head_parallgrmL_UpSi_90,-90';
     7 13  4  5 'head_parallgrmL_UpSi_-90,90';
     8 15  6  7 'head_parallgrmL_UpSi_-90,-90';
    12 11  9 10 'head_parallgrmL_DownSi_90,-90';
    14 13 10 12 'head_parallgrmL_DownSi_-90,90';
    16 15 12 14 'head_parallgrmL_DownSi_-90,-90';
    10 10  1  9 'head_parallgrmL_UpSi_-90,90';
    12 12  3 10 'head_parallgrmL_UpSi_90,-90';
    14 14  5 12 'head_parallgrmL_UpSi_-90,90';
    16 16 11 14 'head_parallgrmL_UpSi_-90,-90';

     2  2  3  9 'head_parallgrmL_UpSo_0,180';
     4  4  5 10 'head_parallgrmL_UpSo_180,0';
     6  6 11 12 'head_parallgrmL_UpSo_0,180';
     5  5 10 11 'head_parallgrmL_UpSo_180,0';
     7 11 12 13 'head_parallgrmL_UpSo_0,180';
     8 13 14 15 'head_parallgrmL_UpSo_0,0';
     2  4  5 12 'head_parallgrmL_DownSo_0,180';
     4  6 11 14 'head_parallgrmL_DownSo_180,0';
     6  7 13 16 'head_parallgrmL_DownSo_0,0';
     1  3  9 11 'head_parallgrmL_DownSo_180,0';
     3  5 10 13 'head_parallgrmL_DownSo_0,180';
     5 11 12 15 'head_parallgrmL_DownSo_180,0';
     3  4  9 10 'head_parallgrmL_UpSi_0,0';
     5  6 10 12 'head_parallgrmL_UpSi_180,180';
     7  7 12 14 'head_parallgrmL_UpSi_0,0';
     8  8 14 16 'head_parallgrmL_UpSi_0,0';
     3  2 10 10 'head_parallgrmL_DownSi_0,0';
     5  4 12 12 'head_parallgrmL_DownSi_180,180';
     7  6 14 14 'head_parallgrmL_DownSi_0,0';
     8  7 16 16 'head_parallgrmL_DownSi_0,0';
     

    % short    S      |         D       |     D          |     S
    %    D       D    |   S       S     |   S       S    |   D       D
    %      S          |     D           |         D      |         S
    % Up SourceInside | Up SourceOuts.  | Down SrceOuts. | Down SrceIns.

     % horizontal
     1  2  9 10 'head_parallgrmS_DownSi_180,0';
     3  4 10 12 'head_parallgrmS_DownSi_0,180';
     5  6 12 14 'head_parallgrmS_DownSi_180,0';
     7  7 14 16 'head_parallgrmS_DownSi_0,0';
     3  2  9  9 'head_parallgrmS_UpSi_0,180';
     5  4 10 10 'head_parallgrmS_UpSi_180,0';
     7  6 12 12 'head_parallgrmS_UpSi_0,180';
     8  7 14 14 'head_parallgrmS_UpSi_0,0';
     
     2  2  5 10 'head_parallgrmS_DownSo_0,0';
     4  4 11 12 'head_parallgrmS_DownSo_180,180';
     6  6 13 14 'head_parallgrmS_DownSo_0,0';
     2  4  3 10 'head_parallgrmS_UpSo_0,0';
     4  6  5 12 'head_parallgrmS_UpSo_180,180';
     6  7 11 14 'head_parallgrmS_UpSo_0,0';
    
     3  3 10 11 'head_parallgrmS_DownSo_0,0';
     5  5 12 13 'head_parallgrmS_DownSo_180,180';
     7 11 14 15 'head_parallgrmS_DownSo_0,0';
     3  5  9 11 'head_parallgrmS_UpSo_0,0';
     5 11 10 13 'head_parallgrmS_UpSo_180,180';
     7 13 12 15 'head_parallgrmS_UpSo_0,0';

     % vertical
     9  1  5  3 'head_parallgrmS_DownSi_-90,90';
    11  9 12 12 'head_parallgrmS_DownSi_90,-90';
    10  3 11  5 'head_parallgrmS_DownSi_90,-90';
     3  2  6  4 'head_parallgrmS_DownSi_90,-90';
    13 10 14 14 'head_parallgrmS_DownSi_-90,90';
    12  5 13  7 'head_parallgrmS_DownSi_-90,90';
     5  4  7  6 'head_parallgrmS_DownSi_-90,90';
    15 12 16 16 'head_parallgrmS_DownSi_90,90';
    14 11 15  8 'head_parallgrmS_DownSi_90,90';
     
     9  3 10 12 'head_parallgrmS_UpSo_-90,-90';
     1  2  5  5 'head_parallgrmS_UpSo_-90,-90';
    10  5 12 14 'head_parallgrmS_UpSo_90,90';
     3  4 11  7 'head_parallgrmS_UpSo_90,90';
    12 11 14 16 'head_parallgrmS_UpSo_-90,90';
     5  6 13  8 'head_parallgrmS_UpSo_-90,90';

     1  1  5 10 'head_parallgrmS_UpSi_-90,90';
    10  9 12 13 'head_parallgrmS_UpSi_90,-90';
     3  3 11 12 'head_parallgrmS_UpSi_90,-90';
     2  2  6  5 'head_parallgrmS_UpSi_90,-90';
    12 10 14 15 'head_parallgrmS_UpSi_-90,90';
     5  5 13 14 'head_parallgrmS_UpSi_-90,90';
     4  4  7  7 'head_parallgrmS_UpSi_-90,90';
     7 11 15 16 'head_parallgrmS_UpSi_90,90';
     6  6  8  8 'head_parallgrmS_UpSi_90,90';

     9  9  5 12 'head_parallgrmS_DownSo_-90,-90';
     1  3  4  5 'head_parallgrmS_DownSo_-90,-90';
    10 10 11 14 'head_parallgrmS_DownSo_90,90';
     3  5  6  7 'head_parallgrmS_DownSo_90,90';
    12 12 13 16 'head_parallgrmS_DownSo_-90,90';
     5 11  7  8 'head_parallgrmS_DownSo_-90,90';

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