% wrapper with UI for rewriteNSP2meas4perfusion.m
addpath(fullfile(fileparts(mfilename('fullpath')),'util'));


% load config .............................................................
cfgFile = fullfile(fileparts(mfilename('fullpath')),'@NSPstreamerGUI','cfg.mat');
try
    CFG = load(cfgFile);
catch ME
    warning('Failed to load cfg.mat');
    CFG = struct();
end


% add paths to jsonlab toolbox ............................................
if isfield(CFG,'jsonlabPath')
    addpath(CFG.jsonlabPath);
end
p = which('loadjson.m');
if isempty(p)
    p = uigetdir(userpath,'Select path to jsonlab-2.0');
    if ~p, error('jsonlab toolbox is required!'); end
    addpath(p);
    assert(~isempty(which('loadjson.m')),'Selected path does not seem to contain the jsonlab tool box!')
end
CFG.jsonlabPath = p;


% add paths to zipToolsPy toolbox .........................................
if isfield(CFG,'zipToolsPath')
    addpath(CFG.zipToolsPath);
end
p = which('zip_readlines.m');
if isempty(p)
    p = uigetdir(userpath,'Select path to zipToolsPy');
    if ~p, error('zipToolsPy toolbox is required!'); end
    addpath(p);
    assert(~isempty(which('zip_readlines.m')),'Selected path does not seem to contain the zipToolsPy tool box!')
end
CFG.zipToolsPath = p;

save(cfgFile,'-struct','CFG');


% default parameters for snippet writing ..................................
if isfield(CFG,'writePerfSnipParam')
    defaultParam = CFG.writePerfSnipParam;
else
    defaultParam = {'1','290','310','1','300'};
end


% get measurement date dir  & sub-dirs ....................................
if isfield(CFG,'writePerfSnipInputDir')
    inputDir = CFG.writePerfSnipInputDir;
else
    inputDir = fullfile(fileparts(userpath),'NIRx','Data');
end
measDateDir = uigetdir(inputDir,'Select date-directory of measurements');

if ~measDateDir, return; end
fprintf('Selected date-dir:\n\t%s\n',measDateDir);
CFG.writePerfSnipInputDir = fileparts(measDateDir);
save(cfgFile,'-struct','CFG');

measDirs = dir(measDateDir);
k = [measDirs.isdir] & ~startsWith({measDirs.name},'.');
measDirs = measDirs(k);

% assert that directory has subdirs
if isempty(measDirs)
    msg = sprintf('No folders found in ''%s''!\nSelect the date-directory (YYYY-MM-DD) containing the measurement folders (YYYY-MM-DD_xxx).',...
        measDateDir);
    errordlg(msg, ...
        'Empty directory selected','modal');
    error(msg);
end


% select measurements .....................................................
sel = listdlg("ListString",{measDirs.name},"SelectionMode","multiple","PromptString",'Select measurements');
if isempty(sel), return; end

fprintf('Selected Measurements:\n%s',sprintf('\t%s\n',measDirs(sel).name));


% select output dir .......................................................
if isfield(CFG,'writePerfSnipOutputDir')
    outpath = CFG.writePerfSnipOutputDir;
else
    outpath = userpath;
end
outpath = uigetdir(outpath,'Select output directory');
if ~outpath, return; end
fprintf('Selected out-dir:\n\t%s\n',outpath);
CFG.writePerfSnipOutputDir = outpath;
save(cfgFile,'-struct','CFG');


% set parameters ..........................................................
paramCS = inputdlg({'Overwrite existing files? [0|1]',...
                  'Snippet length (seconds) befor bolus prep-trigger (#49)', ...
                  'Snippet length (seconds) after bolus prep-trigger (#49)', ...
                  'Include accelerometer data? [0|1]', ...
                  'Raw data chunk length (seconds)'}, ...
                 'Enter parameters', ... title
                 repmat([1 60],5,1), ... input edit fields size
                 defaultParam); % defaults

param = str2double(paramCS);
if isempty(param), disp(' ====== Cancelled ======'); return; end
if any(isnan(param)), error('Failed to convert parameter to numeric!'); end
param = num2cell(param);

CFG.writePerfSnipParam = paramCS;
save(cfgFile,'-struct','CFG');


% RUN .....................................................................
for k = sel
    f = fullfile(measDirs(k).folder,measDirs(k).name,sprintf('%s.nirs',measDirs(k).name));
    rewriteNSP2meas4perfusion(f,outpath,param{:});
end