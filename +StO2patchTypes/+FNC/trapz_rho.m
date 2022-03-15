function rho = trapz_rho(srcDist,detDist,srcDetDist,cblSym,cblOri,cblPos)
% Rho for trapezoid patches
%
% rho = trapz_rho(srcDist,detDist,srcDetDist,'opposite') % or equivalent:
% rho = trapz_rho(srcDist,detDist,srcDetDist,'antisymmetric')
% 
% rho = trapz_rho(srcDist,detDist,srcDetDist,'symmetric',cblOri,cblPos) 
%   where cblOri is the cable orientation (one of 'orthogonal' 'parallel')
%   and cblPos is the cable position (on off 'inward' 'outward')
%
%
%     Orthogonal outward:      Orthogonal inward:
%     -S  D                    S-  D
%     -S  D                    S-  D
%
%     Parallel outward:        Parallel inward:
%     |                        S D
%     S   D                    |
%     S   D                    |
%     |                        S D

import StO2patchTypes.FNC.trapz_diag
import StO2patchTypes.FNC.trapz_legDelta
import StO2patchTypes.FNC.LED_DELTA

cblSym = validatestring(cblSym,{'symmetric','opposite','antisymmetric'}, ...
    mfilename,'cblSym',4);


switch cblSym
    case {'opposite','antisymmetric'}
        if nargin>4
            warning('DataStreamer:StO2patchTypes_FNC_trapz_diag:IgnoringAdditionalInput',...
                'Cable orientation and position are ignored when symmetry is ''%s''!',cblSym);
        end
        diag = trapz_diag(srcDist,detDist,srcDetDist);
        rho = [diag; srcDetDist];
        
        
    case {'symmetric'}
        cblOri = validatestring(cblOri,{'orthogonal','parallel'}, ...
                                mfilename,'cblOri',5);
        cblPos = validatestring(cblPos,{'inward','outward'}, ...
                                mfilename,'cblPos',6);

        leg = srcDetDist;
        delta = LED_DELTA;
        
        leg_wl1 = trapz_legDelta(srcDist, detDist, leg,  delta, cblOri);
        leg_wl2 = trapz_legDelta(srcDist, detDist, leg, -delta, cblOri);
        
        switch cblOri
            case 'orthogonal'
                diag_wl1 = trapz_diag(srcDist,detDist,leg_wl1);
                diag_wl2 = trapz_diag(srcDist,detDist,leg_wl2);
            case 'parallel'
                diag_wl1 = trapz_diag(srcDist+2*delta,detDist,leg_wl1);
                diag_wl2 = trapz_diag(srcDist-2*delta,detDist,leg_wl2);
            otherwise, error('BUG!');
        end
        rho = [diag_wl1 diag_wl2; leg_wl1 leg_wl2];
        
        switch cblPos
            case 'inward', rho = fliplr(rho);
            case 'outward'
            otherwise, error('BUG!');
        end
        
        
    otherwise, error('BUG!');
end



end