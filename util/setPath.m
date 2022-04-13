function p = setPath()
%

afsNSP2path = '\\AFS\fbi.ukl.uni-freiburg.de\projects\CascadeNIRS\test\202101_NIRSport2_test\';

switch getenv('COMPUTERNAME')
    case 'DESKTOP-DFUE7OD' % ='NIRS'
        dsPth = fileparts(fileparts(mfilename('fullpath'))); % 'C:\Users\nradu\Documents\MATLAB';
        rootPth = fileparts(fileparts(fileparts(mfilename('fullpath')))); % 'C:\Users\nradu\Documents\MATLAB';
        addpath(genpath(fullfile(rootPth,'liblsl-Matlab')));
        addpath(fullfile(rootPth,'jsonlab-2.0'));
        addpath(fullfile(rootPth,'TriggerCtrlGUI','src'));
        p.nspConfigPth = fullfile('C:\Users\nradu\Documents','NIRx','Configurations');% fullfile(fileparts(userpath),'NIRx','Configurations');
        p.optodeLayouts = fullfile(dsPth, 'optodeLayouts');
        
    case 'CHIMERA'
        dsPth = fileparts(fileparts(mfilename('fullpath'))); % 'C:\Users\nradu\Documents\MATLAB';
        rootPth = fileparts(fileparts(fileparts(mfilename('fullpath')))); % 'C:\Users\nradu\Documents\MATLAB';
        addpath(genpath(fullfile(rootPth,'liblsl-Matlab')));
        addpath(fullfile(rootPth,'jsonlab-2.0'));
        addpath(fullfile(rootPth,'TriggerCtrlGUI','src'));
        p.nspConfigPth = fullfile(afsNSP2path,'Configurations');
        p.optodeLayouts = fullfile(dsPth, 'optodeLayouts');
        
        
    otherwise, error('Unknown COMPUTERNAME, can''t set paths.');
end


% p.outPath = fullfile(afsNSP2path,'StreamOutput','NIRS_PERFUSION','ENABLE');
p.outPath = 'W:\Data\NIRSport2Data\NIRS_PERFUSION\ENABLE';
p.outPath_fallback = fullfile(userpath,'ENABLE_data_fallbackPth',datestr(datetime,'yyyy-mm-dd'));
% nspDataPth = 'C:\Users\nradu\Documents\NIRx\Data';
p.nspDataPth = fullfile(fileparts(userpath),'NIRx','Data');

end