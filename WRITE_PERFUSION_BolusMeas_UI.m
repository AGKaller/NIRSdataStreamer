% wrapper with UI for rewriteNSP2meas4perfusion.m
addpath(fullfile(fileparts(mfilename('fullpath')),'util'));
addpath(fullfile(userpath,'zipToolsPy'));
addpath(fullfile(userpath,'jsonlab-2.0'));

if ~exist('loadjson','file')
    p = uigetdir(userpath,'Select path to jsonlab-2.0');
    if ~p, error('jsonlab toolbox is required!'); end
    addpath(p);
end
if ~exist('zip_readlines','file')
    p = uigetdir(userpath,'Select path to zipToolsPy');
    if ~p, error('zipToolsPy toolbox is required!'); end
    addpath(p);
end

measPath = fullfile(fileparts(userpath),'NIRx','Data');
measDateDir = uigetdir(measPath,'Select date-directory of measurements');

if ~measDateDir, return; end

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

sel = listdlg("ListString",{measDirs.name},"SelectionMode","multiple","PromptString",'Select measurements');
if isempty(sel), return; end

outpath = uigetdir(userpath,'Select output directory');
if ~outpath, return; end

param = inputdlg({'Overwrite existing files? [0|1]',...
                  'Snippet length (seconds) befor bolus prep-trigger (#49)', ...
                  'Snippet length (seconds) after bolus prep-trigger (#49)', ...
                  'Include accelerometer data? [0|1]', ...
                  'Raw data chunk length (seconds)'}, ...
                 'Enter parameters', ... title
                 repmat([1 60],5,1), ... input edit fields size
                 {'1','290','310','1','300'}); % defaults
param = str2double(param);
if isempty(param), disp(' ====== Cancelled ======'); return; end
if any(isnan(param)), error('Failed to convert parameter to numeric!'); end
param = num2cell(param);


for k = sel
    f = fullfile(measDirs(k).folder,measDirs(k).name,sprintf('%s.nirs',measDirs(k).name));
    rewriteNSP2meas4perfusion(f,outpath,param{:});
end