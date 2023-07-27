function rho = sqr_rho(srcDist,cblSym,varargin)
% Rho for square patches
% (for square patches srcDist == detDist == srcDetDist)
% 
% rho = sqr_rho(srcDist,'antisymmetric')
%
% rho = sqr_rho(srcDist,'symmetric',cblOri,cblPos) 
%   where cblOri is the cable orientation (one of 'orthogonal' 'parallel')
%   and cblPos is the cable position (on off 'inward' 'outward')
%
%
%     Orthogonal outward:      Orthogonal inward:
%     -S D                     S-D
%     -S D                     S-D
%
%     Parallel outward:        Parallel inward:
%     |                        S      D
%     S D                      |
%     S D                      |
%     |                        S      D

rho = StO2patchTypes.FNC.trapz_rho(srcDist,srcDist,srcDist,cblSym,varargin{:});

end