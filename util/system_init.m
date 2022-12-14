%% system_init function to determine the constants of the probe geometry and system configurations
% Update 2021.05.31, Lin Yang
% You don't need to consider the channel assignments youself any more.
% Input: NChan (dbl data)
%   NChan: Number of channels in use, maximum 128 for NIRSport2.
%   Replace the former sys_cnfg.Bin_d:  Channel distance between lambda1 and lambda2 in raw data of file/stream
% output: sys_cnfg (struct data)
%   sys_cnfg.srate:  Sampling rate during the measurements, unit: Hz
%   sys_cnfg.NChan:  Number of channels in use
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

function [sys_cnfg] = system_init(NChan)

%% NSP2 configuration
sys_cnfg.srate = floor(15.3);  % floor(10.2); % Sampling rate in Hz
sys_cnfg.NChan = NChan; % former sys_cnfg.Bin_d = 64
sys_cnfg.lambda = [760 850];

%% StO2 processing
sys_cnfg.StO2rate = 1; % Monitoring every second;
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
Optodes = [
    1 1 2 2];
%     2 2 3 3
%     ];
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
Types = {
    'Rectangular_precise'};
%     'Rectangular35-30'};
%     'Rectangular34.3-29.3'   %     'Rectangular35-30' 
%     };
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
for i = 1:size(Optodes,1)
    
    wlbuf(i,:) = [8*(Optodes(i,1)-1)+Optodes(i,2), 8*(Optodes(i,1)-1)+Optodes(i,3), 8*(Optodes(i,4)-1)+Optodes(i,3), 8*(Optodes(i,4)-1)+Optodes(i,2)];
    %NSP2 Channels assignment at WL 1. NOTE: In real-time streaming data, the intensity voltage start from channel 2
    sys_cnfg.patch(i).chIdx = [wlbuf(i,:); wlbuf(i,:)+sys_cnfg.NChan]+live;
    sys_cnfg.patch(i).type = Types{i};
    
end

sys_cnfg.NPatch = numel(sys_cnfg.patch);

%% Patch selection and channel separations
for i=1:sys_cnfg.NPatch
    switch sys_cnfg.patch(i).type
        
        case 'Linear20-16'
            sys_cnfg.patch(i).rho = [36 20]; %mm long / short separation
            
        case 'Rectangular35-30'
            sys_cnfg.patch(i).rho = [35 30];
            
        case 'Linear20-20'
            sys_cnfg.patch(i).rho = [40 20];
            
        case 'Rectangular_precise'
            delta = 0.2; % unit mm , half of the dies distance
            long = 32; % long edge length
            short = 16; % short edge length
            sys_cnfg.patch(i).rho = [sqrt((long+delta)^2+short^2) sqrt((long-delta)^2+short^2); long+delta long-delta]; % sqrt((29.9+-0.3)^2+18^2); 29.9+-0.3, in the layout of cables are paralle to long edges.
            
    end
end

%% LSL configuration
% load lsl library
sys_cnfg.lsl.lslib = lsl_loadlib();
% stream labels
sys_cnfg.lsl.InSLabel = {'fNIRS'};
sys_cnfg.lsl.OutSLabel = {'StO2'};
% default stream name
sys_cnfg.lsl.InSName = 'Aurora'; % 'NSP2_Stream';
sys_cnfg.lsl.OutSName = 'CerebOx_Stream';

end