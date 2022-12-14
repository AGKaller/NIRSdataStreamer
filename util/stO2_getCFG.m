%% system_init function to determine the constants of the probe geometry and system configurations
% Update 2021.05.31, Lin Yang
% You don't need to consider the channel assignments youself any more.
% Input: NChan (dbl data)
%   NChan: Number of channels in use, maximum 128 for NIRSport2.
%   Replace the former sys_cnfg.Bin_d:  Channel distance between lambda1 and lambda2 in raw data of file/stream
% output: sys_cnfg (struct data)
%   sys_cnfg.srate:  Sampling rate during the measurements, unit: Hz
%   sys_cnfg.NChan:  Number of channels in use (as defined in Aurora
%                    config!)
%   sys_cnfg.lambda: Operating wavelengths of NIRSport2, unit: nm
%   sys_cnfg.StO2rate: Monitoring frequency in Hz; e.g., 1 - 1 check every 1s, 0.1 - 1 check every 10s;
%   sys_cnfg.NPatch:   Number of probes/patches
%   sys_cnfg.patch: Probe/Patch confirgation (struct data)
%       sys_cnfg.patch(i).chIdx: Channel indices assignment of ith patch, always in the format [S1,L1,S2,L2; S1,L1,S2,L2]
%       sys_cnfg.patch(i).type:  ith patch's name
%       sys_cnfg.patch(i).rho:   [short long] source-detector distances of ith patch, unit: mm
% sys_cnfg.lsl: LSL configuration (struct data)
%       sys_cnfg.lsl.lslib:  load LSL function library
%       sys_cnfg.lsl.InSLabel: Input Stream label
%       sys_cnfg.lsl.InSName:  InputStream name
%       sys_cnfg.lsl.OutSLabel: Output Stream label
%       sys_cnfg.lsl.OutSName:  Output Stream name

function [sys_cnfg] = stO2_getCFG(ncfgFile)

[~,ncfgName,~] = fileparts(ncfgFile);
%% NSP2 configuration
sys_cnfg.lambda = [760 850];

%% StO2 processing
live = 1;  % online 1, offline 0;
% % lowpass filter characteristics
% forder = 3;
% %cutoff frequency
% fc = 0.1;
% % init filter coefficients
% [sys_cnfg.filt.b, sys_cnfg.filt.a] = butter(forder, fc/sys_cnfg.srate*2, 'low');
% sys_cnfg.filt.zi = zeros(max(length(sys_cnfg.filt.a),length(sys_cnfg.filt.b))-1,1);

%% NSP2 channel - Probe assignment
% sampling rate & number of channels

[sys_cnfg.NChan, sys_cnfg.srate, sys_cnfg.chnMask, tag] = getCfgParam(ncfgFile, ...
    'nchn', 'fs', 'channel_mask', 'tag');
srcCfg = regexp(tag,sprintf('[^%s]*(?=\\.ncfg$)',fsepEscpd),'match','once');
if ~isempty(srcCfg), ncfgName = srcCfg; end

sys_cnfg.srate = floor(sys_cnfg.srate);
% optode topo-layout & resulting patches:
[Optodes, Types] = getStO2layoutPatches(ncfgName);


% TODO: use function optNum2ChnIdx_chMsk for vectorized calculation of channel indices!


chnMskBool = double(vertcat(sys_cnfg.chnMask{:}))~=48; % channel Mask as logicals
srcNChn = sum(chnMskBool,2); % number of channels each source contributes to.

% check chnMask for active channels
src = repmat(Optodes(:,[1 4]),1,2);
det = repmat(Optodes(:,[2 3]),2,1);
chnIdx = sub2ind(size(chnMskBool),src(:),det(:));
assert(all(chnMskBool(chnIdx)), sprintf(['The channel mask is missing a source-detector-pair required by an StO2-Patch.\n' ...
    'The config.json MUST match the input data, otherwise the channel indices are not computed correctly!']));

% Optodes = [
%     1 1 2 2;
%     ];
% %   S1 D1 D2 S2   Probe1, linear as what you see by eye, for square, the
% principle is the same: the closer Source and detector are next to each
% other in the Optodes matrix.
% Types = {
%     'Linear20-16' 
%     };
%% Linear Patch
% [ Source A ----- Detector A ----- Detector B ----- Source B ]
%
% channel assignment indices (only necessary for WL1):
% idx 1: Source A - Detector A  (short channel)
% idx 2: Source A - Detector B  (long channel)
% idx 3: Source B - Detector B  (short channel)
% idx 4: Source B - Detector A  (long channel)
%
% wlbuf = [SA-DA, SA-DB, SB-DB, SB-DA]  <-- insert here corresp. NSP2 channel numbers
%
%% Rectangular Patch
% [ Source B ----- Detector B ]
%   |                       |
%   |                       |
% [ Source A ----- Detector A ]
%
% channel assignment indices (only necessary for WL1):
% idx 1: Source A - Detector A  (horizontal (shorter) channel)
% idx 2: Source A - Detector B  (diagonal (longer) channel)
% idx 3: Source B - Detector B  (horizontal (shorter) channel)
% idx 4: Source B - Detector A  (diagonal (longer) channel)
%
% wlbuf = [SA-DA, SA-DB, SB-DB, SB-DA]  <-- insert here corresp. NSP2 channel numbers

%% Definition of Patches HERE
% pairs = [1 2; 1 3; 4 3; 4 2];

for i = 1:size(Optodes,1)
%     wlbuf(i,:) = [8*(Optodes(i,1)-1)+Optodes(i,2), 8*(Optodes(i,1)-1)+Optodes(i,3), 8*(Optodes(i,4)-1)+Optodes(i,3), 8*(Optodes(i,4)-1)+Optodes(i,2)];
    src1 = Optodes(i,1); src2 = Optodes(i,4);
    det1 = Optodes(i,2); det2 = Optodes(i,3);
    wlbuf = [sum(srcNChn(1:src1-1))+sum(chnMskBool(src1,1:det1)), ...
             sum(srcNChn(1:src1-1))+sum(chnMskBool(src1,1:det2)), ...
             sum(srcNChn(1:src2-1))+sum(chnMskBool(src2,1:det2)), ...
             sum(srcNChn(1:src2-1))+sum(chnMskBool(src2,1:det1))];
    
%     for j = 1:size(pairs,1)
%         wlbuf(j) = find(strcmp(chnHeadr, ...
%                                sprintf('%d-%d', ...
%                                         Optodes(i,pairs(j,1))-1, ....
%                                         Optodes(i,pairs(j,2))-1)));
%     end
    %NSP2 Channels assignment at WL 1. NOTE: In real-time streaming data, the intensity voltage start from channel 2
    sys_cnfg.patch(i).chIdx = [wlbuf; wlbuf+sys_cnfg.NChan]+live;
    sys_cnfg.patch(i).type = Types{i};
    
end

sys_cnfg.NPatch = numel(sys_cnfg.patch);
sys_cnfg.patchOptodes = Optodes;

%% Patch selection and channel separations
for i=1:sys_cnfg.NPatch
    sys_cnfg.patch(i).rho = getStO2PatchRho(sys_cnfg.patch(i).type);
end


end

function fsep = fsepEscpd
%
if ispc
    fsep = '\\';
else
    fsep = filesep;
end
end