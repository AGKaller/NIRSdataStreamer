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

function [sys_cnfg] = system_initFR(ncfgFile)
% TODO: change input to aurora config name, e.g. sheep20210602long and use
% switch-case to set correct NChan and Optodes, Types ,etc

[~,ncfgName,~] = fileparts(ncfgFile);
rootDir = fileparts(fileparts(mfilename('fullpath')));
%% NSP2 configuration
% sys_cnfg.srate = floor(15.3);  % floor(10.2); % Sampling rate in Hz
% sys_cnfg.NChan = NChan; % former sys_cnfg.Bin_d = 64
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
% % StO2 update rate

%% NSP2 channel - Probe assignment
% sampling rate & number of channels

% switch ncfgName
%     case 'Sheep20210602all'
%         sys_cnfg.srate = floor(10.2);
%         sys_cnfg.NChan = 144;
%     case 'Sheep20210602'
%         sys_cnfg.srate = floor(10.2);
%         sys_cnfg.NChan = 86;
%     otherwise, error('Unknown configuration name!');
% end
[sys_cnfg.NChan, sys_cnfg.srate, sys_cnfg.chnMask, tag] = getCfgParam(ncfgFile, ...
    'nchn', 'fs', 'channel_mask', 'tag');
srcCfg = regexp(tag,sprintf('[^%s]*(?=\\.ncfg$)',fsepEscpd),'match','once');
if ~isempty(srcCfg), ncfgName = srcCfg; end

sys_cnfg.srate = floor(sys_cnfg.srate);
chnMskNum = double(vertcat(sys_cnfg.chnMask{:}))==49; % channel Mask as logicals
srcNChn = sum(chnMskNum,2); % number of channels each source contributes to.
% optode topo-layout & resulting patches:
% switch ncfgName
%     case {'Sheep20210602all', 'Sheep20210602'}
if startsWith(ncfgName,{'Sheep20210602'})
%     chnHeadr = regexp('0-0, 0-4, 0-5, 1-1, 1-4, 1-5, 2-2, 2-4, 2-6, 2-7, 3-3, 3-5, 3-6, 3-7, 4-0, 4-1, 4-2, 4-4, 4-8, 4-9, 5-0, 5-1, 5-3, 5-5, 5-8, 5-9, 6-2, 6-3, 6-6, 6-8, 6-10, 6-11, 7-2, 7-3, 7-7, 7-9, 7-10, 7-11, 8-4, 8-5, 8-6, 8-8, 9-4, 9-5, 9-7, 9-9, 10-6, 10-7, 10-10, 11-6, 11-7, 11-11', ...
%         ', ','split');
    Optodes = [
            5  1  2  6;
            1  5  6  2; % *
            3  7  8  4;
            7  3  4  8;
            5  9 10  6;
            9  5  6 10;
           11  7  8 12;
            7 11 12  8;
            3  3  5  5; % *
            4  4  6  6;
            7  7  9  9; % * 
            8  8 10 10; % *
            ];
        sys_cnfg.chnGrdFile = fullfile(rootDir, ...
            'cerebOx_topolayouts','Sheep20210602.csv'); % currently not used
        Types = repmat({
            'Rectangular36-18' 
            }, size(Optodes,1),1);
        
%     case 'template-copyMe!'
%         Optodes = [
%             1 1 2 2;
%             ];
%         Types = {
%             'Rectangular35-30' 
%             };
        
%     otherwise,
else
    error('Unknown configuration name!');
end
% Optodes = [
%     1 1 2 2;
%     3 3 4 4
%     5 5 6 6
%     7 7 8 8
%     ];
% %   S1 D1 D2 S2   Probe1, linear as what you see by eye, for square, the principle is the same: the closer Source and detector are next to each other in the Optodes matrix.
% %   S1 D1 D2 S2   Probe2
% %   S1 D1 D2 S2   Probe3
% %   S1 D1 D2 S2   Probe4
% Types = {
%     'Linear20-16' 
%     'Rectangular35-30' 
%     'Linear20-16' 
%     'Linear20-16'
%     };
% live = 0; % 1 for online streaming, 0 for offline
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
    wlbuf = [sum(srcNChn(1:src1-1))+sum(chnMskNum(src1,1:det1)), ...
             sum(srcNChn(1:src1-1))+sum(chnMskNum(src1,1:det2)), ...
             sum(srcNChn(1:src2-1))+sum(chnMskNum(src2,1:det2)), ...
             sum(srcNChn(1:src2-1))+sum(chnMskNum(src2,1:det1))];
    
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
    switch sys_cnfg.patch(i).type
        
        case 'Linear20-16'
            sys_cnfg.patch(i).rho = [36 20]; %mm long / short separation
            
        case 'Rectangular35-30'
            sys_cnfg.patch(i).rho = [35 30];
            
        case 'Linear20-20'
            sys_cnfg.patch(i).rho = [40 20];
            
        case 'Rectangular36-18'
            sys_cnfg.patch(i).rho = [40.25 36];
            
    end
end

%% LSL configuration
% load lsl library
sys_cnfg.lsl.lslib = lsl_loadlib();
% stream labels
sys_cnfg.lsl.InSLabel = {'fNIRS'};
sys_cnfg.lsl.OutSLabel = {'StO2'};
sys_cnfg.lsl.InTLabel = 'Trigger_in';
sys_cnfg.lsl.OutTLabel = 'Trigger_out';
% default stream name
sys_cnfg.lsl.InSName = 'Aurora'; % 'NSP2_Stream';
sys_cnfg.lsl.OutSName = 'CerebOx_Stream';
sys_cnfg.lsl.InTName = 'NIRStarTriggers';
sys_cnfg.lsl.OutTName = 'Trigger';

end

function fsep = fsepEscpd
%
if ispc
    fsep = '\\';
else
    fsep = filesep;
end
end