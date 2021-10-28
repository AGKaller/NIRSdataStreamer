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


% ========== CAVE CAVE ==========
%:: CEREBOX STREAMING DISABLED ::
% ===============================


% TODO: 
% Bolus pre buffer writing: adapt size (and end time?) according to
% position of Trigger in current chunk.

%% SET PARAMETERS

PID = 'TEST'; % 'ENABLE_002'; % 
SID = sprintf('%s-093000',datestr(now,'yyyymmdd'));
shortLongCfg = 'Sheep2a_211029.ncfg'; % 'Sheep2a_211029_sine.ncfg'; % 'Sheep2a_211029_SCD.ncfg'; % 
% shortLongCfg = 'Sheep2b_211029_sine.ncfg'; % 'Sheep2b_211029_SCD.ncfg'; % 'Sheep2b_211029.ncfg'; % 
cerebOxCfg = shortLongCfg; %'Sheep2a_211029.ncfg';


bolusPreTrgNum = 48;
bolusPreLength = 30; % seconds
bolusTrgNum = [49 50 51];
bolusChunkSec = 100;
StO2rate = 1;


%% initialize paths
rootPth = fileparts(mfilename('fullpath')); % 'C:\Users\nradu\Documents\MATLAB';
addpath(fullfile(rootPth,'util'));
P = setPath();

nspConfigPth = P.nspConfigPth;
outPath = fullfile(P.outPath,PID,SID);
outPath_fallback = P.outPath_fallback;
optLayoutPath = P.optodeLayouts;


% ### !!! for TESTing !!! ####
% outPath = outPath_fallback;

% ------- initialize plots (only for testing, ONLY Sheep1): ---------
testing = 0;
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
% loFiles = {sprintf('chnPos_%s',regexprep(cerebOxCfg,'\.ncfg$','.csv'));
%            sprintf('optPos_%s',regexprep(cerebOxCfg,'\.ncfg$','.csv'))};


% provide layout files .................
setupID = regexprep(shortLongCfg,'(_sine|_rect)?.ncfg$','');

loFiles = dir(optLayoutPath);
loFileNames = {loFiles.name};
lofPattern = sprintf('^(chn|opt)Pos_%s.*',setupID);
ilof = find(~cellfun(@isempty,regexp(loFileNames,lofPattern,'once')));
assert(numel(ilof)==2, ...
    'Unexpected number of optodeLayout-files found for setupID ''%s'' (%d), need 2!', ...
    setupID, numel(ilof));
for i = 1:numel(ilof)
    copyfile(fullfile(optLayoutPath, loFileNames{ilof(i)}), ...
             outPath);
end

%% initialize LSL & TriggerCtrlGUI
% [sys_cnfg] = lsl_init(sys_cnfg,'input');
[sys_cnfg] = lsl_init(sys_cnfg,'output');
% Start Bolus & Trigger control GUI: (not required)
close(findall(0,'Type','figure','-and','Name','BolusTriggerCtrl'));

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
                fprintf('%s\t waiting for new stream.\n',datestr(now,'yyyy-mm-dd HH:MM:SS'));
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
        if 0 % size(currentChunk,1)-1==sys_cnfg.NChan*4 % cerebOx setup -> long channels only
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
        preBolusBuffLen = ceil(bolusPreLength*fs)*2;
        preBolusBuff = zeros(size(currentChunk,1)+2,preBolusBuffLen);
    end % if startNewFile
    
    currentDATA = [t0+currentTStamp; trgs; currentChunk];
    
    % fill pre-Bolus-buff .................................................
    chnkLen = size(currentDATA,2);
    if chnkLen < preBolusBuffLen
        preBolusBuff = [preBolusBuff(:,chnkLen+1:end) currentDATA];
    else
        preBolusBuff = currentDATA;%(:,end-preBolusBuffLen+1:end);
    end
    
    % create files for bolus chunk ........................................
    iBolus = ismember(currentDATA(2,:),bolusTrgNum(1));
%     iBolus = ismember(trgChunk(2,:),bolusTrgNum(1));
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
            iBuff1 = size(preBolusBuff,2) - find(iBolus(end:-1:1),1,'first') + 1;
%             iBuff1 = find(preBolusBuff(2,:)==bolusTrgNum(1),1,'last');
            iBuff0 = max(1, iBuff1 - preBolusBuffLen/2 + 1);
            preBolChnk = preBolusBuff(:,iBuff0:end);
            preBolChnk(2,1) = bolusPreTrgNum;
            fprintf(fidRaw_bol,rawFmt,preBolChnk);
            fclose(fidRaw_bol);
%         end            
    elseif bolus_running
        fidRaw_bol = fopen_fallback(bolFile,...
                                    outPath_fallback,'a');
        fprintf(fidRaw_bol,rawFmt,currentDATA);
        fclose(fidRaw_bol);
    end
    preBolusBuff = preBolusBuff(:,end-preBolusBuffLen+1:end);
    
    % write data
    fidRaw = fopen_fallback(rawFile,...
                        outPath_fallback, 'a');
    fprintf(fidRaw,rawFmt,currentDATA);
    fclose(fidRaw);
    
    % calculate StO2 if there is enough data for one window
    if cerebOxMeas 
        cbOxbuf = [cbOxbuf currentDATA];
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