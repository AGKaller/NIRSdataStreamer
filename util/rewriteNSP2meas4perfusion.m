function rewriteNSP2meas4perfusion(infile,outPath, ...
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
%

% w = what('StO2layouts');
% assert(~isempty(w),'Layout package directory not found. Check if DataStreamer is on the path!');
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

bolusTrg = 50;
bolusPostTrg = 51;

bolusTrgNums = [bolusPreTrgNum bolusInitTrg bolusTrg bolusPostTrg];

%% lambert-beer stuff

a_HbO_760 = 1381.8;
a_HbO_850 = 2441.18;
a_Hb_760  = 3961.16;
a_Hb_850  = 1842.4;
% a_HbO_760 = 1486.5865;
% a_HbO_850 = 2526.391;
% a_Hb_760  = 3843.707;
% a_Hb_850  = 1798.643;

% dpf_760   = 6.4;
% dpf_850   = 5.75;
dpf_760   = 6.2966;
dpf_850   = 5.23433;

dc_HbO = @(dA_760,dA_850)(a_Hb_760  * dA_850/dpf_850 - a_Hb_850  * dA_760/dpf_760) / (a_Hb_760*a_HbO_850 - a_Hb_850  * a_HbO_760) / 1e-6;
dc_Hb  = @(dA_760,dA_850)(a_HbO_760 * dA_850/dpf_850 - a_HbO_850 * dA_760/dpf_760) / (a_HbO_760*a_Hb_850 - a_HbO_850 * a_Hb_760)  / 1e-6;


%% get input files

[inPth,inName,~] = fileparts(infile);

cfgFile = fullfile(inPth,sprintf('%s_config.json',inName));
assert(exist(cfgFile,'file'),...
    'Could not find config file for baseName ''%s''!',inName);

nirsFile = fullfile(inPth,sprintf('%s.nirs',inName));
assert(exist(nirsFile,'file'),...
    'Could not find .nirs file for inputName ''%s''!',inName);

% not used anymore:
% hdrFile = fullfile(inPth,sprintf('%s_config.hdr',inName));
% assert(exist(hdrFile,'file'),...
%     'Could not find config.hdr file for inputName ''%s''!',inName);


%% load & prep data


% NIRS DATA ...............................................................
[nch, chnMask] = getCfgParam(cfgFile,'nch','channel_mask');

nd = load(nirsFile,'-mat');
dA = -log(bsxfun(@rdivide, nd.d, mean(nd.d,1)));
ndp = size(dA,1);
oxy = dc_HbO(dA(:,1:nch), dA(:,nch+1:end));
dxy = dc_Hb( dA(:,1:nch), dA(:,nch+1:end));


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
tstmp = nd.t + secsOfDay;


% SRC BRRIGHTNESS .........................................................
% cfgHDR = readConfigHDR(hdrFile);
% measDatetime = cfgHDR.Date; % CAVE: this does not correspond to the measurement date, but to the time the file was converted/written
srcBrgtnsFileName = sprintf('%s_chnSrcLevels.csv', ...
                            datestr(t0d,'yyyymmdd-HHMMSS'));



% TRIGGER .................................................................
[trgT,trgN] = find(nd.s);
trg = zeros(ndp,1);
trg(trgT) = trgN;


% ASSEMBLE ................................................................
D = [tstmp, trg, (1:ndp).', nd.d, oxy, dxy].';
fmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,nch*4)];


% ACCELEROMETER & HEADER ..................................................
if inclAcc
    acc = permute(nd.aux,[1 3 2]);
    nAcc = size(acc,3)/2;
    assert(nAcc==round(nAcc) && numel(acc)==ndp*nAcc*6, ...
        'NSPstreamer:rewriteNSP2meas4perf:accArraySizeMismatch', ...
        'Size of accelerometer data array does not match in %s!', ...
        infile)
    D = [D; reshape(acc,ndp,nAcc*6).']; % x,y,z X acc,gyr
    header = mkHeader(chnMask,'rawHb',nAcc);
    fmt = [fmt repmat(',%.3f',1,nAcc*6)];
else
    header = mkHeader(chnMask,'rawHb',0);
end




%% write RAW output

if ~exist(outPath,'dir'), mkdir(outPath); end

% write src brightness
srcBrgtnsFile = fullfile(outPath,srcBrgtnsFileName);
writeChnSrcBrghtns(cfgFile,srcBrgtnsFile);


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
    
    outRawNam = sprintf('%s_%03d_raw.csv', ...
        datestr(fileTime,'yyyymmdd-HHMMSS'), nch);
    rawFile = fullfile(outPath,outRawNam);
    if ~overwrite && exist(rawFile,'file')
%         warning('Output file ''%s'' already exists, overwriting disabled.',...
%             rawFile);
    else
        fidRaw = fopen(rawFile,'w');
        fprintf(fidRaw,header);
        fprintf(fidRaw,fmt,D(:,dataIdx));
        fclose(fidRaw);
    end
end

%% write PERFUSION output

iBolInit = find(trg==bolusInitTrg);
if isequal([bolusPreLength bolusChunkSec],[0 0])
    iBolInit = [];
end

for ib = 1:numel(iBolInit)
    
    tBol = nd.t(iBolInit(ib));
    perfFileNam = sprintf('%s_%03d_perfusion.csv', ...
        datestr(t0+tBol/86400,'yyyymmdd-HHMMSS'), nch);
    perfFile = fullfile(outPath,perfFileNam);
    
    if ~overwrite && exist(perfFile,'file')
%         warning('Output file ''%s'' already exists, overwriting disabled.',...
%             perfFile);
        continue;
    end
    
    iPreBol = find(trg(1:iBolInit(ib))==bolusPreTrgNum,1,'last');
    if isempty(iPreBol)
%         warning('No preBolus-Trigger (%d) found in file\n ''%s''\n bolus#: %d.\nTrying to prepend %ds of data.', ...
%             bolusPreTrgNum, nirsFile, ib, bolusPreLength);
        [~,iPreBol] = min(abs(nd.t-(tBol-bolusPreLength)));
    end
    
    [~,iEndBol] = min(abs(nd.t-(tBol+bolusChunkSec)));
    Db = D(:,iPreBol:iEndBol);

    % remove any other Trigger from previous bolus
    iBInitDb = iBolInit(ib)-iPreBol;
    iTpre = 1:iBInitDb;
    k = ismember(Db(2,iTpre),bolusTrgNums);
    Db(2,iTpre(k)) = 0;

    % remove any other Trigger from following bolus
    idxTrgRem = find(ismember(Db(2,iBInitDb:end),bolusTrgNums)) + iBInitDb-1;
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