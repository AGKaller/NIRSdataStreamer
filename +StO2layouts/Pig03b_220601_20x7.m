function [Optodes, Types] = Pig03b_220601_20x7
% 2nd Pig (1st with NIRS)

% import StO2layouts.Sheep3A_17x7.neckUS

% TRAPEZOIDS (HEAD)
patches = {
    % horizontal:
    1 2 9 9     'head_trap_a';
    2 2 3 10    'head_trap_oo'; % othogonal, outward
    3 2 9 10    'head_trap_a';
    3 3 9 11    'head_trap_oi';
    2 4 5 10    'head_trap_oi'; % orthogonal, inward
    3 4 10 10   'head_trap_a';
    3 5 10 11   'head_trap_oo';
    4 4 5 12    'head_trap_oo';
    5 4 10 12   'head_trap_a';
    5 5 10 13   'head_trap_oi';
    4 6 11 12   'head_trap_oi';
    5 6 12 12   'head_trap_a';
    5 11 12 13  'head_trap_oo';
    6 6 11 14   'head_trap_oo';
    7 6 12 14   'head_trap_a';
    7 11 12 15  'head_trap_oi';
    6 7 13 14   'head_trap_oi';
    7 7 14 14   'head_trap_a';
    7 13 14 15  'head_trap_oo';
    8 7 14 16   'head_trap_a';
    8 8 16 16   'head_trap_a';
   17 7 13 16   'head_trap_oo';
   17 8 15 16   'head_trap_oi';
    8 13 14 18  'head_trap_oi';
    8 15 16 18  'head_trap_oo';
   19 8 16 20   'head_trap_a';
    
    % vertical
    2 2 6 4      'head_trap_a';
    2 4 6 6      'head_trap_a';    % antisymmetric
    4 4 7 6      'head_trap_a';
    1 2 4 5      'head_trap_a';
    3 2 6 5      'head_trap_a';
    3 4 6 7      'head_trap_a';
    5 4 7 7      'head_trap_a';
    5 6 7 8      'head_trap_a';
    7 6 8 8      'head_trap_a';
    1 1 5 3      'head_trap_a';
    1 3 5 5      'head_trap_a';
    3 3 11 5     'head_trap_a';
    3 5 11 7     'head_trap_a';
    5 5 13 7     'head_trap_a';
    5 11 13 8    'head_trap_a';
    7 11 15 8    'head_trap_a';
    9 1 5 10     'head_trap_a';
    9 3 5 12     'head_trap_a';
    10 3 11 12   'head_trap_a';
    10 5 11 14   'head_trap_a';
    12 5 13 14   'head_trap_a';
    12 11 13 16  'head_trap_a';
    14 11 15 16  'head_trap_a';
    9 9 10 12    'head_trap_a';
    10 9 12 12   'head_trap_a';
    10 10 12 14  'head_trap_a';
    12 10 14 14  'head_trap_a';
    12 12 14 16  'head_trap_a';
    14 12 16 16  'head_trap_a';
    11 9 12 13   'head_trap_a';
    11 10 12 15  'head_trap_a';
    13 10 14 15  'head_trap_a';
    4 6 7 17     'head_trap_a';
    6 6 8 17     'head_trap_a';
    13 12 14 18  'head_trap_a';
    15 12 16 18  'head_trap_a';
    19 8 7 7     'head_trap_a';
    19 15 13 7   'head_trap_a';
    19 17 13 8   'head_trap_a';
    20 16 14 14  'head_trap_a';
    20 15 13 14  'head_trap_a';
    20 17 13 16  'head_trap_a';

    
    % RECTENGULARS
    % head (45°)                                      D     
     1  1  9 10  'head_rectWide_-135,45';       %   S     
    10  5  2  1  'head_rectWide_-135,45';       %             D
     2  2  5  5  'head_rectWide_45,-135';       %           S
    11 10  3  9  'head_rectWide_45,-135';
     3  3 10 12  'head_rectWide_-135,45';
    12 11  4  3  'head_rectWide_-135,45';
     4  4 11  7  'head_rectWide_45,-135';
    13 12  5 10  'head_rectWide_45,-135';
     5  5 12 14  'head_rectWide_-135,45';
    14 13  6  5  'head_rectWide_-135,45';
     6  6 13  8  'head_rectWide_45,-135';
    15 14 11 12  'head_rectWide_45,-135';
     7 11 14 16  'head_rectWide_-135,45';
    16 15  7  7  'head_rectWide_-135,45';
     3  2  1  9  'head_rectWide_135,-45';
     9  9  5  3  'head_rectWide_135,-45';
    12  5  9 11  'head_rectWide_-45,135';
     1  3  4  2  'head_rectWide_-45,135';
     5  4  3 10  'head_rectWide_135,-45';
    10 10 11  5  'head_rectWide_135,-45';
    14 11 10 13  'head_rectWide_-45,135';
     3  5  6  4  'head_rectWide_-45,135';
     7  6  5 12  'head_rectWide_135,-45';
    12 12 13  7  'head_rectWide_135,-45';
    16 13 12 15  'head_rectWide_-45,135';
     5 11  7  6  'head_rectWide_-45,135';
     8  7 11 14  'head_rectWide_135,-45';
    14 14 15  8  'head_rectWide_135,-45';
    17 7 15 19   'head_rectWide_45,-135';
    7 13 8 17    'head_rectWide_-45,135';
    18 16 13 14  'head_rectWide_45,-135';
    20 15 14 18  'head_rectWide_-45,135';
    19 8 13 16   'head_rectWide_135,-45';
    8 13 16 20   'head_rectWide_-135,45';
    16 16 17 19  'head_rectWide_135,-45';
    20 17 8 8    'head_rectWide_-135,45';


    % neck (rects are tall)                 D  D
%     22 21 20 21 'neck_rect_a';
%     23 18 19 24 'neck_rect_a';     %        S  S
    26 26 25 25 'neck_rect_a';
    30 28 27 29 'neck_rect_a';

    % neck square (18mm)^2
%     22 19 18 21 'neck_sqr_45,135';
%     23 20 21 24 'neck_sqr_45,135';
    28 26 25 27 'neck_sqr_45,135';
    32 28 27 31 'neck_sqr_45,135';

    % neck trapezoids
%     22 18 20 24 'neck_trap1854_a';
%     21 19 21 23 'neck_trap1854_a';

    % neck linear
%     22 19 21 24 'neck_lin_o,45,-45'; % src outside
%     21 18 20 23 'neck_lin_o,135,-135'; % src outside


    % PARALLELOGRAMS (head)
    % long            S    |    S            |            D    |    D            
    %           D   D      |      D   D      |      S   S      |      S   S      
    %         S            |            S    |    D            |            D    
    %       UpSourceOut    |     DownSo      |   UpSourceIn    |      DownSi
     2  4  6  7 'head_parallgrmL_UpSo_90,-90';
     4  6  7  8 'head_parallgrmL_UpSo_90,-90';
     4  4  2  1 'head_parallgrmL_DownSo_-90,90';
     6  6  4  3 'head_parallgrmL_DownSo_-90,90';
     1  3  5 12 'head_parallgrmL_UpSo_-90,90';
     3  5 11 14 'head_parallgrmL_UpSo_-90,90';
     5 11 13 16 'head_parallgrmL_UpSo_-90,90';
     5  5  3  9 'head_parallgrmL_DownSo_90,-90';
     7 11  5 10 'head_parallgrmL_DownSo_90,-90';
     8 13 11 12 'head_parallgrmL_DownSo_90,-90';
     9  9 10 13 'head_parallgrmL_UpSo_90,-90';
    10 10 12 15 'head_parallgrmL_UpSo_90,-90';
    14 12 10 11 'head_parallgrmL_DownSo_-90,90';
    16 14 12 13 'head_parallgrmL_DownSo_-90,90';
     3  4  1  1 'head_parallgrmL_DownSi_90,90';
     5  6  3  3 'head_parallgrmL_DownSi_90,90';
     7  7  5  5 'head_parallgrmL_DownSi_90,90';
     8  8 11  7 'head_parallgrmL_DownSi_90,90';
     5 11  2  3 'head_parallgrmL_UpSi_90,90';
     7 13  4  5 'head_parallgrmL_UpSi_90,90';
     8 15  6  7 'head_parallgrmL_UpSi_90,90';
    12 11  9 10 'head_parallgrmL_DownSi_-90,-90';
    14 13 10 12 'head_parallgrmL_DownSi_-90,-90';
    16 15 12 14 'head_parallgrmL_DownSi_-90,-90';
    10 10  1  9 'head_parallgrmL_UpSi_-90,-90';
    12 12  3 10 'head_parallgrmL_UpSi_-90,-90';
    14 14  5 12 'head_parallgrmL_UpSi_-90,-90';
    16 16 11 14 'head_parallgrmL_UpSi_-90,-90';
    17  7  6  5 'head_parallgrmL_DownSo_-90,90';
    18 14 12 12 'head_parallgrmL_UpSo_90,-90';
    19  8  7  6 'head_parallgrmL_UpSo_90,-90';
    19 15 13 14 'head_parallgrmL_DownSo_90,-90';
    20 15 13  7 'head_parallgrmL_UpSo_-90,90';
    20 16 14 15 'head_parallgrmL_DownSo_-90,90';
    19 17  7  8 'head_parallgrmL_UpSi_90,90';
    20 17 14 16 'head_parallgrmL_DownSi_-90,-90';

     2  2  3  9 'head_parallgrmL_UpSo_0,0';
     4  4  5 10 'head_parallgrmL_UpSo_0,0';
     6  6 11 12 'head_parallgrmL_UpSo_0,0';
     5  5 10 11 'head_parallgrmL_UpSo_180,180';
     7 11 12 13 'head_parallgrmL_UpSo_180,180';
     8 13 14 15 'head_parallgrmL_UpSo_180,180';
     2  4  5 12 'head_parallgrmL_DownSo_0,0';
     4  6 11 14 'head_parallgrmL_DownSo_0,0';
     6  7 13 16 'head_parallgrmL_DownSo_0,0';
     1  3  9 11 'head_parallgrmL_DownSo_180,180';
     3  5 10 13 'head_parallgrmL_DownSo_180,180';
     5 11 12 15 'head_parallgrmL_DownSo_180,180';
     3  4  9 10 'head_parallgrmL_UpSi_180,0';
     5  6 10 12 'head_parallgrmL_UpSi_180,0';
     7  7 12 14 'head_parallgrmL_UpSi_180,0';
     8  8 14 16 'head_parallgrmL_UpSi_180,0';
     3  2 10 10 'head_parallgrmL_DownSi_180,0';
     5  4 12 12 'head_parallgrmL_DownSi_180,0';
     7  6 14 14 'head_parallgrmL_DownSi_180,0';
     8  7 16 16 'head_parallgrmL_DownSi_180,0';
     17 7 13 14 'head_parallgrmL_UpSo_0,0';
     17 8 15 20 'head_parallgrmL_DownSo_0,0';
     7 13 14 18 'head_parallgrmL_DownSo_180,180';
    19 15 16 18 'head_parallgrmL_UpSo_180,180';
     

    % short    S      |         D       |     D          |     S
    %    D       D    |   S       S     |   S       S    |   D       D
    %      S          |     D           |         D      |         S
    % Up SourceInside | Up SourceOuts.  | Down SrceOuts. | Down SrceIns.

     % horizontal
     1  2  9 10 'head_parallgrmS_DownSi_180,0';
     3  4 10 12 'head_parallgrmS_DownSi_180,0';
     5  6 12 14 'head_parallgrmS_DownSi_180,0';
     7  7 14 16 'head_parallgrmS_DownSi_180,0';
     8  8 16 20 'head_parallgrmS_DownSi_180,0';
     3  2  9  9 'head_parallgrmS_UpSi_180,0';
     5  4 10 10 'head_parallgrmS_UpSi_180,0';
     7  6 12 12 'head_parallgrmS_UpSi_180,0';
     8  7 14 14 'head_parallgrmS_UpSi_180,0';
    19  8 16 16 'head_parallgrmS_UpSi_180,0';
     
     2  2  5 10 'head_parallgrmS_DownSo_0,0';
     4  4 11 12 'head_parallgrmS_DownSo_0,0';
     6  6 13 14 'head_parallgrmS_DownSo_0,0';
     17 7 15 16 'head_parallgrmS_DownSo_0,0';
     2  4  3 10 'head_parallgrmS_UpSo_0,0';
     4  6  5 12 'head_parallgrmS_UpSo_0,0';
     6  7 11 14 'head_parallgrmS_UpSo_0,0';
     17 8 13 16 'head_parallgrmS_UpSo_0,0';
    
     3  3 10 11 'head_parallgrmS_DownSo_180,180';
     5  5 12 13 'head_parallgrmS_DownSo_180,180';
     7 11 14 15 'head_parallgrmS_DownSo_180,180';
     8 13 16 18 'head_parallgrmS_DownSo_180,180';
     3  5  9 11 'head_parallgrmS_UpSo_180,180';
     5 11 10 13 'head_parallgrmS_UpSo_180,180';
     7 13 12 15 'head_parallgrmS_UpSo_180,180';
     8 15 14 18 'head_parallgrmS_UpSo_180,180';

     % vertical
     9  1  5  3 'head_parallgrmS_DownSi_90,-90';
    11  9 12 12 'head_parallgrmS_DownSi_-90,90';
    10  3 11  5 'head_parallgrmS_DownSi_90,-90';
     3  2  6  4 'head_parallgrmS_DownSi_-90,90';
    13 10 14 14 'head_parallgrmS_DownSi_-90,90';
    12  5 13  7 'head_parallgrmS_DownSi_90,-90';
     5  4  7  6 'head_parallgrmS_DownSi_-90,90';
    15 12 16 16 'head_parallgrmS_DownSi_-90,90';
    14 11 15  8 'head_parallgrmS_DownSi_90,-90';
     7  6  8 17 'head_parallgrmS_DownSi_-90,90';
    16 13 17 19 'head_parallgrmS_DownSi_90,-90';

     
     9  3 10 12 'head_parallgrmS_UpSo_90,90';
     1  2  5  5 'head_parallgrmS_UpSo_-90,-90';
    10  5 12 14 'head_parallgrmS_UpSo_90,90';
     3  4 11  7 'head_parallgrmS_UpSo_-90,-90';
    12 11 14 16 'head_parallgrmS_UpSo_90,90';
     5  6 13  8 'head_parallgrmS_UpSo_-90,-90';
    14 13 16 20 'head_parallgrmS_UpSo_90,90';
     7  7 15 19 'head_parallgrmS_UpSo_-90,-90';

     1  1  5 10 'head_parallgrmS_UpSi_-90,90';
    10  9 12 13 'head_parallgrmS_UpSi_90,-90';
     3  3 11 12 'head_parallgrmS_UpSi_-90,90';
     2  2  6  5 'head_parallgrmS_UpSi_90,-90';
    12 10 14 15 'head_parallgrmS_UpSi_90,-90';
     5  5 13 14 'head_parallgrmS_UpSi_-90,90';
     4  4  7  7 'head_parallgrmS_UpSi_90,-90';
    14 12 16 18 'head_parallgrmS_UpSi_90,-90';
     7 11 15 16 'head_parallgrmS_UpSi_-90,90';
     6  6  8  8 'head_parallgrmS_UpSi_90,-90';
     8 13 17 20 'head_parallgrmS_UpSi_-90,90';
     

     9  9  5 12 'head_parallgrmS_DownSo_90,90';
     1  3  4  5 'head_parallgrmS_DownSo_-90,-90';
    10 10 11 14 'head_parallgrmS_DownSo_90,90';
     3  5  6  7 'head_parallgrmS_DownSo_-90,-90';
    12 12 13 16 'head_parallgrmS_DownSo_90,90';
     5 11  7  8 'head_parallgrmS_DownSo_-90,-90';
    14 14 15 20 'head_parallgrmS_DownSo_90,90';
     7 13  8 19 'head_parallgrmS_DownSo_-90,-90';
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