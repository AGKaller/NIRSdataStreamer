function rho = arbitr_rho(xy_dA,xy_dB,xy_s2,alphaDeg_s1,alphaDeg_s2)
% returns rho for arbitrary optode positions, corrected for source rotation
%
% INPUT: 
%   - xy_dA, xy_dB, xy_s2
%               x&y position of detectors and source relative to source 1.
%
%   - alphaDeg_s1, alphaDeg_s2
%               Rotation of sources in degrees.
%
%
% Optode positions:
%
%    dA      
%            dB
%
%          s2
%  s1
%
%
% Sign of source orientation:
%                                    \                                /
% 0°:  s       -45°:   s      -135°:  s       90°:  s-      135°:    s
%      |              /
%
%
% OUTPUT:
%
% rho = cat(3, ...
%           [B1_wl1  B1_wl2; ...
%            A1_wl1  A1_wl2], ...
%           [A2_wl1  A2_wl2; ...
%            B2_wl1  B2_wl2]);
%

import StO2patchTypes.FNC.LED_DELTA

cosLaw = @(sd,gamma) sqrt(sd.^2 + LED_DELTA.^2 - 2*sd*LED_DELTA*cosd(gamma));

if iscolumn(xy_dA), xy_dA = xy_dA.'; end
if iscolumn(xy_dB), xy_dB = xy_dB.'; end
if iscolumn(xy_s2), xy_s2 = xy_s2.'; end
xyClas = {'numeric'};
xyAttr = {'size',[1 2],'finite'};
angClas = {'numeric'};
angAttr = {'scalar'};
validateattributes(xy_dA,xyClas,xyAttr,1);
validateattributes(xy_dB,xyClas,xyAttr,2);
validateattributes(xy_s2,xyClas,xyAttr,3);
validateattributes(alphaDeg_s1,angClas,angAttr,4);
validateattributes(alphaDeg_s2,angClas,angAttr,5);

alphaDeg_s1 = wrapTo180(alphaDeg_s1);
alphaDeg_s2 = wrapTo180(alphaDeg_s2);

B1 = norm(xy_dB);
A1 = norm(xy_dA);
B2 = norm(xy_dB-xy_s2);
A2 = norm(xy_dA-xy_s2);


% A1
s = anglSign(-xy_dA(1));
gammaP = atand(xy_dA(2)/xy_dA(1));
gamma = 90 + s.*[-1 1].*(gammaP - alphaDeg_s1);
A1_wl12 = cosLaw(A1,gamma);


% B1
s = anglSign(-xy_dB(1));
gammaP = atand(xy_dB(2)/xy_dB(1));
gamma = 90 + s.*[-1 1].*(gammaP - alphaDeg_s1);
B1_wl12 = cosLaw(B1,gamma);


% A2
xy_dAP = xy_dA-xy_s2;
s = anglSign(-xy_dAP(1));
gammaP = atand(xy_dAP(2)/xy_dAP(1));
gamma = 90 + s.*[-1 1].*(gammaP - alphaDeg_s2);
A2_wl12 = cosLaw(A2,gamma);


% B2
xy_dBP = xy_dB-xy_s2;
s = anglSign(-xy_dBP(1));
gammaP = atand(xy_dBP(2)/xy_dBP(1));
gamma = 90 + s.*[-1 1].*(gammaP - alphaDeg_s2);
B2_wl12 = cosLaw(B2,gamma);


rho = cat(3, ...
    [B1_wl12; A1_wl12], ...
    [A2_wl12; B2_wl12]);

end


function s = anglSign(x_dSD)
%

if x_dSD > 0
    s = 1;
else
    s = -1;
end

end