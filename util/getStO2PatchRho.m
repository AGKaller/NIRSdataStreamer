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

try
    rho = fncH(patchID{end});
catch ME
    if strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
        error('getStO2PatchRho:unrecognizedPatch', ...
            'No collection of patch types found with name ''%s''.', ...
            func2str(fncH));
    else
        baseME = MException('getStO2PatchRho:patchFncFailed', ...
            sprintf('Patch type collection ''%s'' with input ''%s'' caused an error.', ...
                    func2str(fncH), patchID{end}));
        baseME = baseME.addCause(ME);
        throw(baseME);
    end
end


end % end function