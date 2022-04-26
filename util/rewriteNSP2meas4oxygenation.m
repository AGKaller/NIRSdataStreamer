function rewriteNSP2meas4oxygenation(infile,outPath, ...
    overwrite,bolusPreLength,bolusChunkSec,inclAcc,splitAfter)
%

w = what('+StO2layouts');
assert(~isempty(w),'Layout package directory not found. Check if DataStreamer is on the path!');
assert(exist('loadjson','file'),  'loadjson() not found. Check if jsonlab is on the path!');

%% input handling 

if ~exist('outPath','var') || isempty(outPath)
    outPath = pwd;
end
if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = false;
end
if ~exist('bolusPreLength','var') || isempty(bolusPreLength)
    bolusPreLength = 30; % seconds
end
if ~exist('bolusChunkSec','var') || isempty(bolusChunkSec)
    bolusChunkSec = 100; % seconds
end
if ~exist('inclAcc','var') || isempty(inclAcc)
    inclAcc = false;
end
if ~exist('splitAfter','var') || isempty(splitAfter)
    splitAfter = 0;
end

bolusInitTrg = 49;
bolusPreTrgNum = 48;

stO2_winLen = 10;
stO2_winShft = stO2_winLen;

if any(isnan([bolusPreLength,bolusChunkSec]))
      writeBolusFiles = false;
else, writeBolusFiles = true;
end


%% get input files

[inPth,inNam,~] = fileparts(infile);

inBaseName = regexp(inNam,'^\d{4}(-\d\d){2}_\d{3}','match','once');
if isempty(inBaseName), inBaseName = inNam; end

cfgFile = fullfile(inPth,sprintf('%s_config.json',inBaseName));
assert(exist(cfgFile,'file'),...
    'Could not find config file for baseName ''%s''!',inBaseName);
cfgIfo = dir(cfgFile);

% wlFiles = strcat(fullfile(inPth,inBaseName),{'.wl1','.wl2'});
% assert(all(cellfun(@exist,wlFiles)),...
%     'Raw data files (.wl1 .wl2) not found for baseName ''%s''!',inBaseName);

nirsFile = fullfile(inPth,sprintf('%s.nirs',regexprep(inNam,'\.nirs$','','once')));
assert(exist(nirsFile,'file'),...
    'Could not find .nirs file for inputName ''%s''!',inNam);

rohfile = fullfile(inPth,sprintf('%s.roh',inBaseName));
accfile = fullfile(inPth,sprintf('%s.acc',inBaseName));
rohExist = exist(rohfile,'file');
accExist = exist(rohfile,'file');


%% load & convert data

% NIRS DATA ...............................................................
stO2_cnfg = stO2_getCFG(cfgFile);
nch = stO2_cnfg.NPatch;
cnsts = repmat(constants_init('AdultHead'), nch, 1);

nd = load(nirsFile,'-mat');
[cerebOx,tNSP] = raw2StO2([nd.t nd.d], cnsts, stO2_cnfg.patch, ...
                          stO2_winLen, stO2_winShft);
ndp = numel(cerebOx);
ndpRaw = numel(nd.t);

stO2 = vertcat(cerebOx.St);

hb = cat(3,cerebOx.c);
hbO = permute(hb(1,:,:),[3 2 1]);
hbR = permute(hb(2,:,:),[3 2 1]);

mua = cat(3,cerebOx.mua);
mua1 = permute(mua(1,:,:),[3 2 1]);
mua2 = permute(mua(2,:,:),[3 2 1]);


% DATE & TIME .............................................................
if ~rohExist
    extrFiles = unzip(fullfile(inPth,sprintf('%s.zip',inBaseName)), ...
        inPth);
    if numel(extrFiles)>2
        warning('There were more than 2 files extracted from %s.zip',inBaseName);
    end
end
fidRoh = fopen(rohfile,'r');
rohLine = fgetl(fidRoh);
fclose(fidRoh);
if ~rohExist
    try delete(rohfile); end
end
if ~accExist
    try delete(accfile); end
end
t0Char = regexp(rohLine,'^[^;,]+','match','once');
t0d = datenum(t0Char,'yyyy-mm-ddTHH:MM:SS');
t0s = str2double(regexp(t0Char,'(?<=:\d\d)\.\d+$','match','once'));
t0 = t0d + t0s/86400;
secsOfDay = rem(t0,1)*86400;


% t0 = rem(cfgIfo.datenum,1)*24*60*60;
tstmp = tNSP + secsOfDay;


% TRIGGER .................................................................
[trgT,trgN] = find(nd.s);
dtTrg = bsxfun(@minus,tNSP,nd.t(trgT).');
[~,itTrg] = min(abs(dtTrg));
trg = zeros(ndp,1);
trg(itTrg) = trgN;


% ASSEMBLE ................................................................
frames = 1 : stO2_winShft : ndpRaw-stO2_winLen+1;

D = [tstmp, trg, frames.', stO2, hbO, hbR, mua1, mua2].';
fmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,nch*5)];


% ACCELEROMETER & HEADER ..................................................
if inclAcc
    acc_orig = permute(nd.aux,[1 3 2]);
    nAcc = size(acc_orig,3)/2;
    acc_orig = reshape(acc_orig,ndpRaw,nAcc*6); % x,y,z X acc,gyr
%     acc = interp1(nd.t,acc_orig,tNSP,'pchip');
%     acc = decimate(acc_orig,
    accMX = movmax(acc_orig,stO2_winLen,1);
    acc = accMX(frames+floor(stO2_winLen/2),:);
    D = [D; acc.'];
    header = mkHeader(stO2_cnfg.patchOptodes,'StO2',nAcc);
    fmt = [fmt repmat(',%.3f',1,nAcc*6)];
else
    header = mkHeader(stO2_cnfg.patchOptodes,'StO2',0);
end


%% write RAW output

if ~exist(outPath,'dir'), mkdir(outPath); end

if splitAfter>0
    chnkTStmp = tstmp(1):splitAfter:tstmp(end);
    if chnkTStmp(end)~=tstmp(end)
        chnkTStmp = [chnkTStmp inf];
    end
else
    chnkTStmp = [tstmp(1) inf];
end

for k = 1:numel(chnkTStmp)-1
    fileTime = t0 + (chnkTStmp(k)-tstmp(1))/86400;
    dataIdx = tstmp >= chnkTStmp(k) & ...
              tstmp <  chnkTStmp(k+1);
    
    outRawNam = sprintf('%s_%03d_oxygenation.csv', ...
        datestr(fileTime,'yyyymmdd-HHMMSS'), nch);
    rawFile = fullfile(outPath,outRawNam);
    if ~overwrite && exist(rawFile,'file')
        warning('DataStreamer:rewriteNSP2meas4oxygenation:skippingExistingFile',...
                'Output file ''%s'' already exists, overwriting disabled.',...
                rawFile);
    else
        fidRaw = fopen(rawFile,'w');
        fprintf(fidRaw,header);
        fprintf(fidRaw,fmt,D(:,dataIdx));
        fclose(fidRaw);
    end
end



%% write PERFUSION output

if writeBolusFiles
    iBolInit = find(trg==bolusInitTrg);
    isBolTrg = trgN==bolusInitTrg;
    trgT_orig = nd.t(trgT(isBolTrg));
else
    iBolInit = [];
end

for ib = 1:numel(iBolInit)
    
    tBol = trgT_orig(ib);%tNSP(iBolInit(ib));
    perfFileNam = sprintf('%s_%03d_oxygenation_perfusion.csv', ...
        datestr(t0+tBol/86400,'yyyymmdd-HHMMSS'), nch);
    perfFile = fullfile(outPath,perfFileNam);
    
    if ~overwrite && exist(perfFile,'file')
        warning('DataStreamer:rewriteNSP2meas4oxygenation:skippingExistingFile',...
            'Output file ''%s'' already exists, overwriting disabled.',...
            perfFile);
        continue;
    end
    
    iPreBol = find(trg(1:iBolInit(ib))==bolusPreTrgNum,1,'last');
    if isempty(iPreBol)
%         warning('DataStreamer:rewriteNSP2meas4oxygenation:PrependingPreBolTrg',...
%             'No preBolus-Trigger (%d) found in file\n ''%s''\n bolus#: %d.\nTrying to prepend %ds of data.', ...
%             bolusPreTrgNum, nirsFile, ib, bolusPreLength);
        [~,iPreBol] = min(abs(tNSP-(tBol-bolusPreLength)));
    end
    
    [~,iEndBol] = min(abs(tNSP-(tBol+bolusChunkSec)));
    Db = D(:,iPreBol:iEndBol);
    Db(2,1) = bolusPreTrgNum;
    fidPerf = fopen(perfFile,'w');
    fprintf(fidPerf,header);
    fprintf(fidPerf,fmt,Db);
    fclose(fidPerf);
end


end