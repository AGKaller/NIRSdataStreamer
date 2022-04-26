%% Calculation function for Oxygen Saturation level, StO2.
% Update 2021.05.31, Lin Yang
% Input: inputDat, cnsts (struct data), sys_cnfg (struct data)
%   inputDat:
%       intensity, inputDat.S1 inputDat.S2 short distance intensity at two
%
%   sys_cnfg: constants of the probe geometry and system configurations, refering system_init function
%   cnsts:    physical constants of the subjects, refering constants_init function
%   cnsts.perc_water: Amount of water in tissues
%   cnsts.mua_water:  mua values of water at 2 wavelengths; unit: mm^-1
%   cnsts.musp:       musp values of tissues at 2 wavelengths; unit: mm^-1
%   
% Output:
%   res.
%       St: calculated StO2 [T x P] - T time points, P patches
%       mua: calculated absorption coefficients [T x WL x P] - T time points, WL Wavelengths, P patches
%       c: calculated StO2 [T x C x P] - T time points, C Chromophores (HbO / Hb), P patches 

function [res] = calc_OxStO2_new(inputDat, cnsts, sys_cnfg)
%   Calculate Slope SL with Self-calbriating concept and get mua quantities.
res.mua = [];
res.c = [];
res.St = [];
    
%% loop for all defined patches
for pp=1:sys_cnfg.NPatch
    
    if size(sys_cnfg.patch(pp).rho,3)==1
        sys_cnfg.patch(pp).rho = repmat(sys_cnfg.patch(pp).rho,1,1,2);
    end
    rhoLong = prod(sys_cnfg.patch(pp).rho(1,:,:),3);
    rhoShrt = prod(sys_cnfg.patch(pp).rho(2,:,:),3);
    rhoDivi =  sum(sys_cnfg.patch(pp).rho(2,:,:),3) ...
             - sum(sys_cnfg.patch(pp).rho(1,:,:),3);
    chIdx_L1 = sys_cnfg.patch(pp).chIdx(:,2);
    chIdx_L2 = sys_cnfg.patch(pp).chIdx(:,4);
    chIdx_S1 = sys_cnfg.patch(pp).chIdx(:,1);
    chIdx_S2 = sys_cnfg.patch(pp).chIdx(:,3);
    
    % the following line uses the full input stream, and select the appropriate channels using the sys_cnfg fields (channel indices)
    SL = ( log(inputDat(chIdx_L1).*inputDat(chIdx_L2) ./ ...
               inputDat(chIdx_S1) ./ inputDat(chIdx_S2))...
           + 2*log(rhoLong./rhoShrt)) ...
         ./ rhoDivi; % [760; 850]    
    
    mua = SL.^2/3./cnsts(pp).musp; % [760 850]nm
    mua = mua - cnsts(pp).perc_water.*cnsts(pp).mua_water; % subtract water absorption, with 80% of head are water. unit: mm-1 @Kedenburg
    res.mua(:,pp) = mua;
    
    C = mua/cnsts(pp).A; % concentration = mua * cross^-1; [HbO2 HHb]
    res.c(:,pp) = C;
    
    StO2 = C(:,1)./(C(:,1)+C(:,2));
    res.St(:,pp) = StO2;
end

end