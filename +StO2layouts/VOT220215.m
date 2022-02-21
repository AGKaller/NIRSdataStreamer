function [Optodes, Types] = VOT220215
% Vascular occlusion test 22-02-15
defs = {
    [1 1 2 2], 'VOT220215.L_Rect36-18_prec_sym';
    [2 2 3 3], 'VOT220215.L_Rect36-18_asym';
    [1 1 3 3], 'VOT220215.L_Sqr36_asym';
    [4 5 6 6], 'VOT220215.R_Trap18-51-25_asym';
    [5 5 6 7], 'VOT220215.R_Trap18-51-25_prec_sym';
    [6 4 7 7], 'VOT220215.R_Sqr25_asym';
    [4 4 7 5], 'VOT220215.R_Sqr25_prec_sym';    
    };
Types = defs(:,2);
Optodes = vertcat(defs{:,1});

end