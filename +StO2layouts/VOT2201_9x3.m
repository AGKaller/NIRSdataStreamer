function [Optodes, Types] = VOT2201_9x3
% Vascular occlusion test 22-01-26
defs = {
    [1 1 5 4], 'VOT220126.Rect33-21_prec_sym';
    [2 1 5 6], 'VOT220126.Trap28-25-21_prec_sym';
    [2 3 6 6], 'VOT220126.Sqr25_prec_sym';
    [3 3 6 7], 'VOT220126.Sqr25_asym';
    [2 2 7 3], 'VOT220126.Trap18-51-25_asym';
    [6 2 7 7], 'VOT220126.Trap18-51-25_prec_sym';
    [3 4 8 7], 'VOT220126.Trap28-25-21_asym';
    [4 4 8 8], 'VOT220126.Rect33-21_asym';    
    };
Types = defs(:,2);
Optodes = vertcat(defs{:,1});

end