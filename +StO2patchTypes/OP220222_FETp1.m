function rho = OP220222_FETp1(patchNam)
% Trapezoid crown made for 1st FET Pilot, 22.02.22.
% For Pilot1 only 2x4 lateral trapezoids used...

import StO2patchTypes.*
delta = FNC.LED_DELTA();

switch patchNam

    % ---- SYMETRIC --------------------    
    case 'Trap1-5-6-2_in'
        leg = 27.129; % delta: 0.036
        short = 17.976;
        long = 28.223;

    case 'Trap2-6-7-3_in'
        leg = 27.096; % delta: 0.030
        short = 17.962;
        long = 30.897;

    case 'Trap8-12-13-9_in'
        leg = 27.049; % delta: 0.165
        short = 17.963;
        long = 30.796;

    case 'Trap9-13-14-10_in'
        leg = 27.143; % delta: 0.023
        short = 17.977;
        long = 28.317;
        
        
    case 'Trap2-2-3-3_out'
        leg = 27.796; % delta: 0.122
        short = 24.321;
        long = 30.897;

    case 'Trap1-1-2-2_out'
        leg = 27.724; % delta: 0.022
        short = 17.976;
        long = 25.223;

    case 'Trap8-9-10-9_out'
        leg = 27.812; % delta: 0.098
        short = 23.663;
        long = 30.796;

    case 'Trap9-10-11-10_out'
        leg = 27.760; % delta: 0.007
        short = 17.977;
        long = 25.776;
    
        
    case '0000R_Trap18-51-25_prec_sym'
        leg = 18;
        long = 2*25.46; % long edge length
        short = 25.46; % short edge length
        
        leg_longer = FNC.trapz_legDelta(long,short,leg,delta);
        leg_shrter = FNC.trapz_legDelta(long,short,leg,-delta);
        
        diag_longer = FNC.trapz_diag(long,short,leg_longer); % when cable is vertical to the 2 parallel sides
        diag_shrter = FNC.trapz_diag(long,short,leg_shrter);
        
        rho = [diag_longer diag_shrter; leg_longer leg_shrter]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.

    otherwise, error('Patch type ''%s'' no found in %s!',patchNam,mfilename);

end % end switch

        
leg_longer = FNC.trapz_legDelta(long,short,leg,delta);
leg_shrter = FNC.trapz_legDelta(long,short,leg,-delta);

diag_longer = FNC.trapz_diag(long,short,leg_longer);
diag_shrter = FNC.trapz_diag(long,short,leg_shrter);

rho = [diag_longer diag_shrter; leg_longer leg_shrter];

if endsWith(patchNam,'_in')
    rho = fliplr(rho);
elseif endsWith(patchNam,'_out')
else, error('Unexpected Patch-Name for this layout!');
end

end