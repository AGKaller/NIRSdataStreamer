function rewriteNSP2meas4oxygenation(infile,outPath, ...
    overwrite,bolusPreLength,bolusChunkSec,inclAcc,splitAfter, varargin)
%
% INPUT
%
% infile            Input file name, file extension will be ignored.
%
%       --- optional: ---
%
% outPath           Path to save output to.
%                   Defaults to pwd().
%
% overwrite         Overwrite existing files?
%                   Defaults to false.
%
% bolusPreLength    Time in seconds to prepend to perfusion measurements.
%                   If NaN, perfusion files will not be written.
%                   Defaults to 30.
%
% bolusChunkSec     Length of measurement to include in perfusion files
%                   starting from init-trigger (49) in seconds. If Nan,
%                   perfusion file will not be written.
%                   Defaults to 100.
%
% inclAcc           Include accelerometer data?
%                   Defaults to false.
%
% splitAfter        Split raw data files after X seconds?
%                   Defaults to 0 (do not split).
%
% '-zipfile' zipfile  Specify zip-file of raw data (.rho) from which
%                   measurement time will be retrieved.
%                   Defaults to the infile-name with .zip-extension.


w = what('StO2layouts');
assert(~isempty(w),'Layout package directory not found. Check if DataStreamer is on the path!');
assert(exist('loadjson','file'),  'loadjson() not found. Check if jsonlab is on the path!');
assert(exist('zip_readlines','file'), ...
    sprintf('zip_readlines() not found. Check if zipToolsPy is on the path!\nRepo: <a href="%1$s">%1$s</a>',...
            'https://github.com/f-k-s/zipToolsPy'));

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

nvaraIn = numel(varargin);
flag = 0;
for v = 1:nvaraIn
    if flag
        flag = 0;
        continue;
    end
    if ischar(varargin{v}) || isstring(varargin{v})
        switch lower(varargin{v})
            case '-zipfile'
                assert(v<nvaraIn,'Please provide a value for parameter ''%s''',varargin{v})
                zipfile = varargin{v+1};
                flag = 1;
            otherwise, error('Unrecognized input argument ''%s''',varargin{v});
        end
    end
end
    

bolusInitTrg = 49;
bolusPreTrgNum = 48;

% bolusTrg = 50;
bolusPostTrg = 51;

stO2_winLen = 10;
stO2_winShft = stO2_winLen;

if any(isnan([bolusPreLength,bolusChunkSec]))
      writeBolusFiles = false;
else, writeBolusFiles = true;
end


%% get input files

[inPth,inName,~] = fileparts(infile);

cfgFile = fullfile(inPth,sprintf('%s_config.json',inName));
assert(exist(cfgFile,'file'),...
    'Could not find config file for baseName ''%s''!',inName);

nirsFile = fullfile(inPth,sprintf('%s.nirs',inName));
assert(exist(nirsFile,'file'),...
    'Could not find .nirs file for inputName ''%s''!',inName);


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
if ~exist('zipfile','var')
    zipfile = fullfile(inPth,sprintf('%s.zip',inName));
end
assert(exist(zipfile,'file'),...
    'Could not find zip file (for ''%s''): ''%s''!',inName,zipfile);
content = zip_getContent(zipfile);
rohIdx = ~cellfun(@isempty,regexp({content.file_name},'\.roh$','once'));
assert(sum(rohIdx)==1,'Failed to identify roh file in ''%s''.',zipfile);
rohLine = zip_readlines(zipfile,content(rohIdx).file_name,1,0);

t0Char = regexp(rohLine{1},'^[^;,]+','match','once');
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
%         warning('DataStreamer:rewriteNSP2meas4oxygenation:skippingExistingFile',...
%                 'Output file ''%s'' already exists, overwriting disabled.',...
%                 rawFile);
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
%         warning('DataStreamer:rewriteNSP2meas4oxygenation:skippingExistingFile',...
%             'Output file ''%s'' already exists, overwriting disabled.',...
%             perfFile);
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

    % remove any other Trigger from previous bolus
    iBInitDb = iBolInit(ib)-iPreBol;
    iTpre = 1:iBInitDb;
    Db(2,iTpre) = 0;

    % remove any other Trigger from following bolus
    idxTrgRem = find(Db(2,iBInitDb:end)) + iBInitDb-1;
    if Db(2,idxTrgRem(1))==bolusInitTrg
        keep = 1;
        if numel(idxTrgRem)>1 && Db(2,idxTrgRem(2)) == bolusTrg
            keep = 2;
            if numel(idxTrgRem)>2 && Db(2,idxTrgRem(3)) == bolusPostTrg
                keep = 3;
            end
        end
        idxTrgRem(1:keep) = [];
    end
    Db(2,idxTrgRem) = 0;
    
    % add the pre-bolus-Trigger
    Db(2,1) = bolusPreTrgNum;
    
    % write to file
    fidPerf = fopen(perfFile,'w');
    fprintf(fidPerf,header);
    fprintf(fidPerf,fmt,Db);
    fclose(fidPerf);
end


end