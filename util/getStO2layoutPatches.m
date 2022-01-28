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


%     case 'template-copyMe!'
%         Optodes = [
%             1 1 2 2;
%             ];
%         Types = {
%             'Rectangular35-30' 
%             };

else
    defFile = fullfile(pth,'+StO2layouts',sprintf('%s.m',cfgname));
    if ~exist(defFile,'file')
        error('''%s'' does not exist in package ''StO2layouts''!',cfgname);
    end
    fh = str2func(cfgname);
    [Optodes, Types] = fh();
end

end