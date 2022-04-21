function rewriteNSP2meas4perfusion(infile,outPath, ...
    overwrite,bolusPreLength,bolusChunkSec,inclAcc,splitAfter)
%


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

[inPth,inNam,~] = fileparts(infile);

inBaseName = regexp(inNam,'^\d{4}(-\d\d){2}_\d{3}','match','once');
if isempty(inBaseName), inBaseName = inNam; end

cfgFile = fullfile(inPth,sprintf('%s_config.json',inBaseName));
assert(exist(cfgFile,'file'),...
    'Could not find config file for baseName ''%s''!',inBaseName);
% cfgIfo = dir(cfgFile);

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


%% load & prep data

% TODO: use a zip-reading toolbox from FEX instead of unpacking the whole
% archive!
% https://de.mathworks.com/matlabcentral/fileexchange/77257-zipfile
% '-> doesnt work. use filelist = system('unzip -l file.zip') to get
% content and 'unzip -o file.zip file.roh' to inflate and overwrite
% roh-file, -n to skip existing (on windows!).
if ~rohExist
    extrFiles = unzip(fullfile(inPth,sprintf('%s.zip',inBaseName)), ...
        inPth);
    if numel(extrFiles)>2
        warning('There were more than 2 files extracted from %s.zip',inBaseName);
    end
    iroh = ~cellfun(@isempty,regexp(extrFiles,'.*\.roh$','once'));
    rohfile = extrFiles{iroh};
    iacc = ~cellfun(@isempty,regexp(extrFiles,'.*\.acc$','once'));
    accfile = extrFiles{iacc};
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

[nch, chnMask] = getCfgParam(cfgFile,'nch','channel_mask');

nd = load(nirsFile,'-mat');
dA = -log(bsxfun(@rdivide, nd.d, mean(nd.d,1)));
ndp = size(dA,1);
oxy = dc_HbO(dA(:,1:nch), dA(:,nch+1:end));
dxy = dc_Hb( dA(:,1:nch), dA(:,nch+1:end));


% t0 = rem(cfgIfo.datenum,1)*24*60*60;
tstmp = nd.t + secsOfDay;

[trgT,trgN] = find(nd.s);
trg = zeros(ndp,1);
trg(trgT) = trgN;

D = [tstmp, trg, (1:ndp).', nd.d, oxy, dxy].';
fmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,nch*4)];

if inclAcc
    acc = permute(nd.aux,[1 3 2]);
    nAcc = size(acc,3)/2;
    D = [D; reshape(acc,ndp,nAcc*6).']; % x,y,z X acc,gyr
    header = mkHeader(chnMask,'rawHb',nAcc);
    fmt = [fmt repmat(',%.3f',1,nAcc*6)];
else
    header = mkHeader(chnMask,'rawHb',0);
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
    
    outRawNam = sprintf('%s_%03d_raw.csv', ...
        datestr(fileTime,'yyyymmdd-HHMMSS'), nch);
    rawFile = fullfile(outPath,outRawNam);
    if ~overwrite && exist(rawFile,'file')
        warning('Output file ''%s'' already exists, overwriting disabled.',...
            rawFile);
    else
        fidRaw = fopen(rawFile,'w');
        fprintf(fidRaw,header);
        fprintf(fidRaw,fmt,D(:,dataIdx));
        fclose(fidRaw);
    end
end

%% write PERFUSION output

iBolInit = find(trg==bolusInitTrg);

for ib = 1:numel(iBolInit)
    
    tBol = nd.t(iBolInit(ib));
    perfFileNam = sprintf('%s_%03d_perfusion.csv', ...
        datestr(t0+tBol/86400,'yyyymmdd-HHMMSS'), nch);
    perfFile = fullfile(outPath,perfFileNam);
    
    if ~overwrite && exist(perfFile,'file')
        warning('Output file ''%s'' already exists, overwriting disabled.',...
            perfFile);
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
    Db(2,1) = bolusPreTrgNum;
    fidPerf = fopen(perfFile,'w');
    fprintf(fidPerf,header);
    fprintf(fidPerf,fmt,Db);
    fclose(fidPerf);
end


end