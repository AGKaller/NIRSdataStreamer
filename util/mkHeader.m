function header = mkHeader(chnInfo,type)
%

if nargin<2 || isempty(type)
    type = 'rawHb';
end
type = validatestring(type,{'rawHb','StO2'});

header = 'TStamp,Trg,Frame';

switch type
    case 'rawHb'
        for prfx = {'wl1' 'wl2' 'oxy' 'dxy'}
            frmt = sprintf(',%s_S%%02d-D%%02d',prfx{1});
            for srci = 1:numel(chnInfo)
        %         deti = strfind(chnMask{srci},'1');
                deti = find(double(chnInfo{srci})==49); % 10x faster
                srciHead = sprintf(frmt, [ones(1,numel(deti))*srci; ...
                                          deti]);
                header = sprintf('%s%s',header,srciHead);
            end
        end
    case 'StO2'
        for prfx = {'StO2','HbO','HbR','muaWL1','muaWL2'}
            frmt = sprintf(',%s_S%%02dD%%02dD%%02dS%%02d',prfx{1});
            ptchHead = sprintf(frmt,chnInfo.');
            cerebOxHead = sprintf('%s%s',cerebOxHead,ptchHead);
        end
    otherwise, error('Bug');
end

end
