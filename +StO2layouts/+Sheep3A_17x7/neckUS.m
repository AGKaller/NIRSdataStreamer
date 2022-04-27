function [Optodes, Types] = neckUS
% 3rd Sheep

% TRAPEZOIDS (HEAD)
patches = {
    % RECTENGULARS
    24 24 23 22 'neck_rect_-135,45'; % outward up down
    23 21 22 24 'neck_rect_135,-45'; % inward up down
    20 20 22 21 'neck_rect_45,-135';
    19 18 17 18 'neck_rect_-135,45';
    18 20 19 17 'neck_rect_-45,135';
    
    };

Optodes = cell2mat(patches(:,1:4));
Types = strcat('Sheep3A_17x7.',patches(:,5));

end

  