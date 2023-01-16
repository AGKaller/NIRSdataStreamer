%% constants_init function to determine the physical constants of the subjects
% Update 2021.04.12, Lin Yang
% Input: TissueType (char data)
%   name: different tissues under investigation.
% output: cnsts (struct data)
%   cnsts.perc_water: Amount of water in tissues
%   cnsts.mua_water:  mua values of water at 2 wavelengths; unit: mm^-1 
%   cnsts.musp:       musp values of tissues at 2 wavelengths; unit: mm^-1
%   cnsts.A:          Absorption cross section of HbO2 and HHb at 2
%   wavelength[760 850], unit: mm^2

function [cnsts] = constants_init(TissueType)

if nargin==0, TissueType = 'AdultHead'; end

% assumed percentage content of human head are water
cnsts.perc_water = 0.75;
% water absorption
cnsts.mua_water = [0.00276 0.00414]; % at NIRSport2 operating wavelength lambda1 = 750, lambda2 = 850nm; Values@Kedenburg 
% matrix of absorption cross section of HbO2 and HHb at 2 wavelengths;
cnsts.A = [0.6096 1.1596; 1.6745 0.7861]; % [HbO2@760, HbO2@850; HHb@760, HHb@850]; Values@Cope UCL 1991

switch TissueType
    
    case 'Phantom_C2'
        % C2 phantom
        cnsts.musp = [1.022 0.835]; % [musp_Lambda1 musp_Lambda2] mm^-1  @Grosnick
    case 'Phantom_D2'
        % D2 phantom
        cnsts.musp = [0.995 0.815]; % [musp_Lambda1 musp_Lambda2] mm^-1 
    case 'Phantom_C3'
        % C3 phantom
        cnsts.musp = [1.548 1.261]; % [musp_Lambda1 musp_Lambda2] mm^-1  
    case 'Phantom_D3'
        % D3 phantom
        cnsts.musp = [1.570 1.295]; % [musp_Lambda1 musp_Lambda2] mm^-1 
    case 'AdultHead'
        % Adult whole head
        cnsts.musp = [1.233 1.029]; % [musp_Lambda1 musp_Lambda2] mm^-1  @Jacques2013, musp = a*(lamda/500)^(-b), a=2.42, b=1.611
        
end

end

