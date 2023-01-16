function rho = rect_rho(srcDist,srcDetDist,cblSym,varargin)
% Rho for rectangular patches
% (for rectangular patches srcDist == detDist)
% 
% rho = rect_rho(srcDist,srcDetDist,'antisymmetric')
%
% rho = rect_rho(srcDist,srcDetDist,'symmetric',cblOri,cblPos) 
%   where cblOri is the cable orientation (one of 'orthogonal' 'parallel')
%   and cblPos is the cable position (on off 'inward' 'outward')
%
%
%     Orthogonal outward:      Orthogonal inward:
%     -S D                     S- D
%     -S D                     S- D
%
%     Parallel outward:        Parallel inward:
%     |                        S D
%     S D                      |
%     S D                      |
%     |                        S D

rho = StO2patchTypes.FNC.trapz_rho(srcDist,srcDist,srcDetDist,cblSym,varargin{:});

end