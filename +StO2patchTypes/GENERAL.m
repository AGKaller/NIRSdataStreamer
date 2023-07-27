function rho = GENERAL(patchNam)
%

switch patchNam

    case 'Linear20-16'
        rho = [36; 20]; %mm long / short separation

    case 'Rectangular35-30'
        rho = [35; 30];

    case 'Linear20-20'
        rho = [40; 20];

    case 'Rectangular36-18'
        rho = [40.25; 36];

    case 'Rectangular_precise'
        delta = 0.2; % unit mm , half of the dies distance
        long = 32; % long edge length
        short = 16; % short edge length
        rho = [sqrt((long+delta)^2+short^2) sqrt((long-delta)^2+short^2); long+delta long-delta]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.
    
    otherwise, error('Patch type ''%s'' no found in %s!',patchNam,mfilename);

end % end switch
