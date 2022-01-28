function rewriteNSP2meas4perfusion(infile,outPath, ...
    overwrite,bolusPreLength,bolusChunkSec)
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

bolusInitTrg = 49;
bolusPreTrgNum = 48;


%% lambert-beer stuff

a_HbO_760 = 1486.5865;
a_HbO_850 = 2526.391;
a_Hb_760  = 3843.707;
a_Hb_850  = 1798.643;

dpf_760   = 6.4;
dpf_850   = 5.75;

dc_HbO = @(dA_760,dA_850)(a_Hb_760  * dA_850/dpf_850 - a_Hb_850  * dA_760/dpf_760) / (a_Hb_760*a_HbO_850 - a_Hb_850  * a_HbO_760) / 1e-6;
dc_Hb  = @(dA_760,dA_850)(a_HbO_760 * dA_850/dpf_850 - a_HbO_850 * dA_760/dpf_760) / (a_HbO_760*a_Hb_850 - a_HbO_850 * a_Hb_760)  / 1e-6;


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

nirsFile = fullfile(inPth,sprintf('%s.nirs',inBaseName));
assert(exist(nirsFile,'file'),...
    'Could not find .nirs file for baseName ''%s''!',inBaseName);


%% load & prep data

[nch, chnMask] = getCfgParam(cfgFile,'nch','channel_mask');
header = mkHeader(chnMask);
fmt = ['\r\n%.3f,%d,%d' repmat(',%.8f',1,nch*4)];

nd = load(nirsFile,'-mat');
dA = -log(bsxfun(@rdivide, nd.d, mean(nd.d,1)));
ndp = size(dA,1);
oxy = dc_HbO(dA(:,1:nch), dA(:,nch+1:end));
dxy = dc_Hb( dA(:,1:nch), dA(:,nch+1:end));

t0 = rem(cfgIfo.datenum,1)*24*60*60;
tstmp = nd.t + t0;

[trgT,trgN] = find(nd.s);
trg = zeros(ndp,1);
trg(trgT) = trgN;

D = [tstmp, trg, (1:ndp).', nd.d, oxy, dxy].';


%% write RAW output

outRawNam = sprintf('%s_%03d_raw.csv', ...
    datestr(cfgIfo.datenum,'yyyymmdd-HHMMSS'), nch);
rawFile = fullfile(outPath,outRawNam);
if ~overwrite && exist(rawFile,'file')
    warning('Output file ''%s'' already exists, overwriting disabled.',...
        rawFile);
else
    fidRaw = fopen(rawFile,'w');
    fprintf(fidRaw,header);
    fprintf(fidRaw,fmt,D);
    fclose(fidRaw);
end


%% write PERFUSION output

iBolInit = find(trg==bolusInitTrg);

for ib = 1:numel(iBolInit)
    
    tBol = nd.t(iBolInit(ib));
    perfFileNam = sprintf('%s_%03d_perfusion.csv', ...
        datestr(cfgIfo.datenum+tBol/86400,'yyyymmdd-HHMMSS'), nch);
    perfFile = fullfile(outPath,perfFileNam);
    
    if ~overwrite && exist(perfFile,'file')
        warning('Output file ''%s'' already exists, overwriting disabled.',...
            perfFile);
        continue;
    end
    
    iPreBol = find(trg(1:iBolInit(ib))==bolusPreTrgNum,1,'last');
    if isempty(iPreBol)
        warning('No preBolus-Trigger (%d) found in file\n ''%s''\n bolus#: %d.\nTrying to prepend %ds of data.', ...
            bolusPreTrgNum, nirsFile, ib, bolusPreLength);
        [~,iPreBol] = min(abs(nd.t-(tBol-bolusPreLength)));
    end
    
    [~,iEndBol] = min(abs(nd.t-(tBol+bolusChunkSec)));
    Db = D(:,iPreBol:iEndBol);
    Db(2,1) = bolusPreTrgNum;
    fidPerf = fopen(perfFileNam,'w');
    fprintf(fidPerf,header);
    fprintf(fidPerf,fmt,Db);
    fclose(fidPerf);
end


end