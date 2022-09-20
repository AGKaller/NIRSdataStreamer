% rewrite PERFUSION measurement chunks & bolus snippets


measPath = fullfile(fileparts(userpath),'NIRx','Data');
measDateDir = uigetdir(measPath,'Select date-directory of measurements');

if ~measDateDir, return; end

measDirs = dir(measDateDir);
k = [measDirs.isdir] & ~startsWith({measDirs.name},'.');
measDirs = measDirs(k);


sel = listdlg("ListString",{measDirs.name},"SelectionMode","multiple","PromptString",'Select measurements');
if isempty(sel), return; end

outpath = uigetdir(userpath,'Select output directory');
if ~outpath, return; end

param = inputdlg({'Overwrite existing files?',...
                  'Snippet length (seconds) befor bolus prep-trigger (49)', ...
                  'Snippet length (seconds) after bolus prep-trigger (49)', ...
                  'Include accelerometer data?', ...
                  'Raw data chunk length (s)'}, ...
                 'Enter parameters', ... title
                 repmat([1 60],5,1), ... input edit fields size
                 {'1','290','310','1','300'}); % defaults
param = str2double(param);
if any(isnan(param)), error('Failed to convert parameter to numeric!'); end
param = num2cell(param);


for k = sel
    f = fullfile(measDirs(k).folder,measDirs(k).name,sprintf('%s.nirs',measDirs(k).name));
    rewriteNSP2meas4perfusion(f,outpath,param{:});
end