function [res, t] = raw2StO2(data, cnsts, patchCfg, winLen, winShft)
% High-level wrapper for calc_OxStO2, handles complete measurements.
%
% === INPUT: ===
%
% data: [T1 wl1_ch1 wl1_ch2 ... wl2_ch1 wl2_ch2 ...;
%        T2 wl1_ch1 wl1_ch2 ... wl2_ch1 wl2_ch2 ...;
%        ... ]
%
% cnsts: Constants from init function
%
% patchCfg: Structure of patch geometries (rho & chIdx)
%
% winLen: Window length in number of data points
%
% winShft: Number datapoints to shift window on each iteration; defaults to
%          winLen if empty.
%
%
% === OUTPUT: ===
%
% TODO...

StO2fh = @calc_OxStO2_new;

ndp = size(data,1);

assert(ndp>=winLen, ...
    'Window length is larger than number of data points (size(data,1))!');

if ~exist('winShft','var') || isempty(winShft)
    winShft = winLen;
end

StO2CFG = struct('patch',patchCfg,'NPatch',numel(patchCfg));

iStrt = 1:winShft:ndp;
iEnd = winLen:winShft:ndp;
nWin = numel(iEnd);

% prealloc
res = StO2fh(sum(data(iStrt(1):iEnd(1),:)), cnsts, StO2CFG);
res = repmat(res,nWin,1);
t = zeros(nWin,1);
t(1) = mean(data(iStrt(1):iEnd(1),1));

for k = 2:nWin
    res(k) = StO2fh(sum(data(iStrt(k):iEnd(k),:)), cnsts, StO2CFG);
    t(k) = mean(data(iStrt(k):iEnd(k),1));
end

end
