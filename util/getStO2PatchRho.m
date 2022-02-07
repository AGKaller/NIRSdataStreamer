function rho = getStO2PatchRho(patchNam)
% rho = getStO2PatchRho(patchNam)

import StO2patchTypes.*

% assumes that cable is vertical to the 2 parallel sides:
% trap_beta = @(long, shrt, leg, d) ...
%     pi/2 + d*asin( ((long-shrt)/2)/leg );
% 
% leg_shrt = @(long, shrt, leg, delta) ...
%     sqrt(delta^2+leg^2 - 2*delta*leg*cos( trap_beta(long,shrt,leg,-1) ));
% leg_long = @(long, shrt, leg, delta) ...
%     sqrt(delta^2+leg^2 - 2*delta*leg*cos( trap_beta(long,shrt,leg,+1) ));


patchID = strsplit(patchNam,'.');
if numel(patchID)==1
    patchID = [{'GENERAL'} patchID];
end

fncH = str2func(strjoin(patchID(1:end-1),'.'));
rho = fncH(patchID{end});



end % end function