function rho = VOT220215(patchNam)
%

import StO2patchTypes.*
delta = FNC.LED_DELTA();

switch patchNam

    % ---- ASYMETRIC --------------------
    case 'R_Sqr25_asym'
        long = 25.46; % long edge length
        short = 25.46; % short edge length
        rho = [sqrt(long^2+short^2); long];

    case 'L_Rect36-18_asym'
        long = 36; % long edge length
        short = 18; % short edge length
        rho = [sqrt(long^2+short^2); long];
        
    case 'L_Sqr36_asym'
        long = 36; % long edge length
        short = 36; % short edge length
        rho = [sqrt(long^2+short^2); long];

    case 'R_Trap18-51-25_asym'
        leg = 18;
        long = 2*25.46; % long edge length
        short = 25.46; % short edge length
        
        diag = FNC.trapz_diag(long,short,leg); % when cable is vertical to the 2 parallel sides        
        rho = [diag; leg];

    
    % ---- SYMETRIC --------------------
    case 'R_Sqr25_prec_sym'
        long = 25.46; % long edge length
        short = 25.46; % short edge length
        rho = [sqrt((long+delta)^2+short^2) sqrt((long-delta)^2+short^2); ...
            long+delta long-delta]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.
%         rho = fliplr(rho);
        
    case 'L_Rect36-18_prec_sym'
        long = 36; % long edge length
        short = 18; % short edge length
        rho = [sqrt((long+delta)^2+short^2) sqrt((long-delta)^2+short^2); ...
            long+delta long-delta]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.
    
    case 'R_Trap18-51-25_prec_sym'
        leg = 18;
        long = 2*25.46; % long edge length
        short = 25.46; % short edge length
        
        leg_longer = FNC.trapz_legDelta(long,short,leg,delta,'paral');
        leg_shrter = FNC.trapz_legDelta(long,short,leg,-delta,'paral');
        
        diag_longer = FNC.trapz_diag(long+2*delta,short,leg_longer); % when cable is aligned with the longer side
        diag_shrter = FNC.trapz_diag(long-2*delta,short,leg_shrter);
        
        rho = [diag_longer diag_shrter; leg_longer leg_shrter]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.
    
    case 'R_Trap18-51-25_prec_sym_FALSE'
        leg = 18;
        long = 2*25.46; % long edge length
        short = 25.46; % short edge length
        
        leg_longer = FNC.trapz_legDelta(long,short,leg,delta);
        leg_shrter = FNC.trapz_legDelta(long,short,leg,-delta);
        
        diag_longer = FNC.trapz_diag(long,short,leg_longer); % when cable is aligned with the longer side
        diag_shrter = FNC.trapz_diag(long,short,leg_shrter);
        
        rho = [diag_longer diag_shrter; leg_longer leg_shrter]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.

    otherwise, error('Patch type ''%s'' no found in %s!',patchNam,mfilename);

end % end switch
