function [Optodes, Types] = getStO2layoutPatches(cfgname)
%
% pth = fileparts(fileparts(mfilename('fullpath')));
% addpath(fullfile(pth,'StO2patchDefs'));
import StO2layouts.*

if startsWith(cfgname,{'Sheep20210602'})
    [Optodes, Types] = Sheep20210602();
    
elseif startsWith(cfgname,{'Sheep2a'})
    [o{1}, t{1}] = Sheep20211029_base();
    [o{2}, t{2}] = Sheep20211029_rostral();
    Optodes = vertcat(o{:});
    Types = vertcat(t{:});

elseif startsWith(cfgname,{'Sheep2b'})
    [o{1}, t{1}] = Sheep20211029_base();
    [o{2}, t{2}] = Sheep20211029_caudal();
    Optodes = vertcat(o{:});
    Types = vertcat(t{:});

else
    
    aliases = {...
        % LayoutName    {mapped config filenames};
        'VOT2201_9x3'   {'VOT2201_9x3_sine' 'VOT2201_9x3_sine_.5prc'};
        'VOT220215'     {'VOT220215_sine'};
        'dummy'         {'dummy_sine' 'dummy_scd'};
        'OP220222_FETp1' {'HUMlateral_P1a_220222'};
        };
    assert(numel([aliases{:,2}])==numel(unique([aliases{:,2}])), ...
        'A config file cannot appear for multiple aliases.');
    isAlias = cellfun(@(x) ismember(cfgname,x), aliases(:,2)) | ...
                ismember(aliases(:,1), cfgname);
    assert(sum(isAlias)<2, 'Error matching config name to layout');
    
    if any(isAlias)
        cfgname = aliases{isAlias,1};
    end
    
    % this exist-check is disabled to allow sub-packages in the
    % StO2layouts-package, i.e. LayoutNames like 'Sheep99.rostral' located
    % in +Sheep99/rostral.m
%     defFile = fullfile(pth,'+StO2layouts',sprintf('%s.m',cfgname));
%     if ~exist(defFile,'file')
%         error('''%s'' does not exist in package ''StO2layouts''!',cfgname);
%     end
        
    fh = str2func(cfgname);
    try
        [Optodes, Types] = fh();
    catch ME
        if strcmpi(ME.identifier,'MATLAB:UndefinedFunction')
            error('getStO2layoutPatches:unrecognizedLayout', ...
                'No implementation of layout ''%s'' found.', ...
                cfgname);
        else
            baseME = MException('getStO2layoutPatches:layoutFncFailed', ...
                        sprintf('Implementation of layout ''%s'' caused an error.', ...
                                cfgname));
            baseME = baseME.addCause(ME);
            throw(baseME);
        end
    end
end

end