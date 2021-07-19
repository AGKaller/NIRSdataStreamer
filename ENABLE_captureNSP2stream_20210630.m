%% Evaluate the Oxygen Saturation level, StO2 of online Streaming LSL data.
% --- adapted from lsl_example/Eval_online_lsl --- (KS)
% Update 2021.05.31, Lin Yang
% Structure:
%   Initializations - Initialize Paths, System Configuration, LSL data
%       structure, physical constants, and variables for final StO2 results
%   Streaming calculation and display  - Streaming Data collecting, buffer transfering,
%       data pre-processing, StO2 Calculation, output streaming generating,
%       and final results dynamic display.
clear


% TODO: 
% ordnerstruktur mit pid, studydate-studytime
% GUI bolus trigger - improve responsiveness, use poolfeval to run in
%       separate process. Use _exported-GUI!
% Laengerer, definierter Vorlauf fue perfusion-Messungen. Retro-Prospektiv?

%% initialize paths
rootPth = fileparts(fileparts(mfilename('fullpath'))); % 'C:\Users\nradu\Documents\MATLAB';
addpath(fullfile(rootPth,'DataStreamer','util'));
addpath(genpath(fullfile(rootPth,'liblsl-Matlab')));
addpath(fullfile(rootPth,'jsonlab-2.0'));
addpath(fullfile(rootPth,'TriggerCtrlGUI'));

% paths = Paths_init('Lin'); % only necessary for offline testing

nspConfigPth = 'C:\Users\nradu\Documents\NIRx\Configurations';
nspDataPth = 'C:\Users\nradu\Documents\NIRx\Data';

%% SET PARAMETERS

bolusTrgNum = [49 50 51];
bolusChunkSec = 100;
StO2rate = 1;

cerebOxCfg = 'Sheep20210602cerebOx2d.ncfg';
shortLongCfg = 'Sheep20210602min18max40v2d.ncfg';
outPath = '\\AFS\fbi.ukl.uni-freiburg.de\projects\CascadeNIRS\test\202101_NIRSport2_test\StreamOutput';
outPath_fallback = fullfile(userpath,'ENABLE_data_fallbackPth',datestr(datetime,'yyyy-mm-dd'));
% ### !!! for TESTing !!! ####
% outPath = outPath_fallback;

% ------- initialize plots (only for testing): ---------
testing = 1;
if testing
    fh = figure; ah = axes('Parent',fh);
    hold(ah,'on');
    for i = 1:12
        tph(i) = plot(NaN,'Parent',ah);
    end
end

%% initialize system configuration
fprintf('   ==== INITIALIZE - Please wait.... ==== \n');
sys_cnfg = system_initFR(fullfile(nspConfigPth,cerebOxCfg)); % define Sampling rate, Monitoring rate, NSP2 Channels assignment, Source/detector separations on probes, stream name, etc.
sys_cnfg.StO2rate = StO2rate; % Monitoring every second;

[shortLongMeas.NChan, shortLongMeas.srate, shortLongMeas.chnMask] = getCfgParam(fullfile(nspConfigPth,shortLongCfg), ...
    'nchn', 'fs', 'channel_mask');
% see more details in system_init function

if ~exist(outPath,'dir'), mkdir(outPath); end

%% initialize LSL & TriggerCtrlGUI
% [sys_cnfg] = lsl_init(sys_cnfg,'input');
[sys_cnfg] = lsl_init(sys_cnfg,'output');
% Start Bolus & Trigger control GUI: (not required)
close(findall(0,'Type','figure','-and','Name','BolusTriggerCtrl'));
TCH = TrigCtrlGUI(sys_cnfg.lsl.outlet_trg,'COM3');
TCH.bolusTrgNums = bolusTrgNum;

%% initialize physical constants
% For adult head
% cnsts(1) = constants_init('AdultHead');

% For phantoms test only, where different patchs monitor phantoms with different properties.
cnsts(1) = constants_init('AdultHead'); % Probe1
cnsts = repmat(cnsts,sys_cnfg.NPatch,1);

%% Initialize Variables
% init = true;
% StO2buf.mua = [];
% StO2buf.c = [];
% StO2buf.St = [];
% SP_start = 0; % Initialize the starting sampling point for monitoring
Width_Wd = ceil(sys_cnfg.srate/sys_cnfg.StO2rate); % width of the windows of monitoring in the unit of sampling points

% time to wait each loop (to save CPU load), unit: s
ptime = 0.01;

%% build header for output text files
metaHead = 'TStamp,Trg,Frame';
rawHeadShortLong = metaHead;
for prfx = {'wl1' 'wl2' 'oxy' 'dxy'}
    frmt = sprintf(',%s_S%%02d-D%%02d',prfx{1});
    for srci = 1:numel(shortLongMeas.chnMask)
        deti = strfind(shortLongMeas.chnMask{srci},'1');
        srciHead = sprintf(frmt, [ones(1,numel(deti))*srci; ...
                                  deti]);
        rawHeadShortLong = sprintf('%s%s',rawHeadShortLong,srciHead);
    end
end
rawHeadLong = metaHead;
for prfx = {'wl1' 'wl2' 'oxy' 'dxy'}
    frmt = sprintf(',%s_S%%02d-D%%02d',prfx{1});
    for srci = 1:numel(sys_cnfg.chnMask)
        deti = strfind(sys_cnfg.chnMask{srci},'1');
        srciHead = sprintf(frmt, [ones(1,numel(deti))*srci; ...
                                  deti]);
        rawHeadLong = sprintf('%s%s',rawHeadLong,srciHead);
    end
end
cerebOxHead = metaHead;
cerebOxTyps = {'StO2','HbO','HbR','muaWL1','muaWL2'};
for prfx = cerebOxTyps
    frmt = sprintf(',%s_S%%02dD%%02dD%%02dS%%02d',prfx{1});
    ptchHead = sprintf(frmt,sys_cnfg.patchOptodes.');
    cerebOxHead = sprintf('%s%s',cerebOxHead,ptchHead);
end

%% Receive and calculate data

disp('   ==== READY! - Starting to receive data ====  ')%for ' num2str(Ttarget) ' seconds'])
tic
Tstart = toc;
startNewFile = true;
bolus_running = false;
fidRaw = [];
fidCOx = [];
while true % toc < Tstart+Ttarget
    % fetch data from stream and put into buffer
    currentChunk = [];
    emptyChunkCnt = 0;
    while isempty(currentChunk)
        if startNewFile && rem(emptyChunkCnt,400)==0 % check for new stream from time to time.
            [sys_cnfg] = lsl_init(sys_cnfg,'input',true);
        end
        [currentChunk, currentTStamp] = sys_cnfg.lsl.inlet.pull_chunk();
        if isempty(currentChunk)
            if emptyChunkCnt==600 % .01*100 = 1s without new chunk
                try fclose(fidCOx); end
                try fclose(fidRaw); end
%                 try fclose(fidCOx_bol); end
%                 try fclose(fidRaw_bol); end
                fprintf('%s\t files closed.\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                startNewFile = true;
            end
            emptyChunkCnt = emptyChunkCnt + 1;
            pause(.01);
        end
    end
    
    % pull and process trigger:
    [trgChunk,trgTStamp] = sys_cnfg.lsl.inlet_trg.pull_chunk();
    trgs = zeros(1,size(currentChunk,2));
    for ti = 1:numel(trgTStamp)
        [~,mini] = min(abs(currentTStamp-trgTStamp(ti)));
        trgs(mini) = trgChunk(2,ti);
    end
    
    % create files for continuous data recording ..........................
    if startNewFile
        fprintf('%s\t opening new files...\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
        startNewFile = false;
        % time stamp at start of measurement ...
        % ... as number of seconds of current day:
        t0 = rem(now,1)*24*60*60 - currentTStamp(1);
        
        baseOutFName = datestr(datetime,'yyyymmdd-HHMMSS');
        
        rawFmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,size(currentChunk,1)-1)];
        if size(currentChunk,1)-1==sys_cnfg.NChan*4 % cerebOx setup -> long channels only
            nChn = sys_cnfg.NChan;
            rawFile = fullfile(outPath,sprintf('%s_%03d_raw.csv',baseOutFName,nChn));
            fidRaw = fopen_fallback(rawFile,...
                                    outPath_fallback, 'w');
            fprintf('\t\t\t\t\t(cerebOx)\n');
            cerebOxMeas = true;
            cbOxbuf = [];
            nDataHead = size(sys_cnfg.patchOptodes,1) * numel(cerebOxTyps);
            coxFmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,nDataHead)];
            coxFile = fullfile(outPath,sprintf('%s_%03d_oxygenation.csv',baseOutFName,nChn));
            fidCOx = fopen_fallback(coxFile,...
                                    outPath_fallback,'w');
            fprintf(fidRaw,rawHeadLong);
            fprintf(fidCOx,cerebOxHead);
            fs = sys_cnfg.srate;
            fclose(fidCOx);
            bolHead = rawHeadLong;
        else % tomographic setup
            nChn = shortLongMeas.NChan;
            rawFile = fullfile(outPath,sprintf('%s_%03d_raw.csv',baseOutFName,nChn));
            fidRaw = fopen_fallback(rawFile,...
                                    outPath_fallback, 'w');
            fprintf('\t\t\t\t\t(tomographic)\n');
            cerebOxMeas = false;
            fprintf(fidRaw,rawHeadShortLong);
            fs = shortLongMeas.srate;
            bolHead = rawHeadShortLong;
        end
        if size(currentChunk,1)-1 ~= nChn*4
            warning('Number of channels in LSL stream does not match nirs configuration.\nWriting to file %s.',rawFile);
        end
        fclose(fidRaw);
    end
    
    % create files for bolus chunk ........................................
    iBolus = ismember(trgChunk(2,:),bolusTrgNum(1));
    % TODO (minor): check for bolus abortion trigger?!
    if any(iBolus) && ~bolus_running
        fprintf('%s\t bolus initiated.\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
        bolus_running = true;
        bolusTic = tic;
        baseOutFName = datestr(datetime,'yyyymmdd-HHMMSS');
        bolFile = fullfile(outPath,sprintf('%s_%03d_perfusion.csv',baseOutFName,nChn));
        fidRaw_bol = fopen_fallback(bolFile,...
                                    outPath_fallback,'w');
%         if cerebOxMeas
%             fidCOx_bol = fopen_fallback(fullfile(outPath,sprintf('%s_bolus_cerebOx.csv',baseOutFName)),...
%                                         outPath_fallback,'w');
%             fprintf(fidRaw_bol,rawHeadLong);
%             fprintf(fidCOx_bol,cerebOxHead);
%         else
            fprintf(fidRaw_bol,bolHead);
            fclose(fidRaw_bol);
%         end            
    end
    
    % write data
    fidRaw = fopen_fallback(rawFile,...
                        outPath_fallback, 'a');
    fprintf(fidRaw,rawFmt,[t0+currentTStamp; trgs; currentChunk]);
    fclose(fidRaw);
    if bolus_running
        fidRaw_bol = fopen_fallback(bolFile,...
                                    outPath_fallback,'a');
        fprintf(fidRaw_bol,rawFmt,[t0+currentTStamp; trgs; currentChunk]);
        fclose(fidRaw_bol);
    end
    
    % calculate StO2 if there is enough data for one window
    if cerebOxMeas 
        cbOxbuf = [cbOxbuf [t0+currentTStamp; trgs; currentChunk]];
        for iBlk = 1:floor(size(cbOxbuf,2)/Width_Wd)
            bufIdx = (1:Width_Wd) + (iBlk-1)*Width_Wd;
            bufOut = calc_OxStO2(sum(cbOxbuf(3:end,bufIdx),2).', cnsts, sys_cnfg);
            c = squeeze(bufOut.c).';
            mua = bufOut.mua.';
            writeOut = [cbOxbuf(1:3,bufIdx(1)); ... frame; TStamp (first of StO2 chunk)
                        squeeze(bufOut.St).'; ... St
                        c(:); ... HbO; HbR
                        mua(:); ... mua WL1; WL2
                        ];
            fidCOx = fopen_fallback(coxFile,...
                        outPath_fallback,'a');
            fprintf(fidCOx,coxFmt,writeOut);
            fclose(fidCOx);
%             if bolus_running
%                 fprintf(fidCOx_bol,coxFmt,writeOut);
%             end
            % ---- for testing ----
            if testing
                try
                    for i = 1:numel(tph)
                        set(tph(i),'YData', [tph(i).YData bufOut.St(i)], ...
                                   'XData', [tph(i).XData cbOxbuf(1,bufIdx(1))]);
                        if numel(tph(i).XData) > 400
                            n = numel(tph(i).XData);
                            set(tph(i),'YData', tph(i).YData(n-399:end), ...
                                       'XData', tph(i).XData(n-399:end));
                        end
                    end
                    set(tph(1).Parent, 'XLim', tph(1).XData([2 end]), ...
                                       'YLim', [-.2 1.5]);
                end
            end
        end
        if ~isempty(iBlk) % remove processed data from buffer
            cbOxbuf = cbOxbuf(:,(iBlk*Width_Wd)+1:end);
        end
        
        % Cerebral Oximmetry / StO2 Calculation
        %       St: calculated StO2 [T x P] - T time points, P patches
        %       mua: calculated absorption coefficients [T x WL x P] - T time points, WL Wavelengths, P patches
        %       c: calculated StO2 [T x C x P] - T time points, C Chromophores (HbO / Hb), P patches
        
        
        % feed StO2 data into LSL output stream
%         sys_cnfg.lsl.outlet.push_sample(bufOut.St); & outlet disabled!
    end
    if bolus_running && toc(bolusTic)>bolusChunkSec
        fprintf('%s\t recording bolus chunk stopped; closing files.\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
        bolus_running = false;
        try fclose(fidCOx_bol); end
        try fclose(fidRaw_bol); end
    end
    pause(ptime)
    %t = toc-tstart;
%     vis_stream();
end

try fclose(fidCOx); end
try fclose(fidRaw); end
try fclose(fidCOx_bol); end
try fclose(fidRaw_bol); end

StO2_mean = mean(StO2buf.St);
disp('data received.')