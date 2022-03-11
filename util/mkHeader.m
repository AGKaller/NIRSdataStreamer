function header = mkHeader(chnInfo,type,nAcc)
%

if nargin<2 || isempty(type)
    type = 'rawHb';
end
if nargin<3 || isempty(nAcc)
    nAcc = 0;
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
            header = sprintf('%s%s',header,ptchHead);
        end
    otherwise, error('Bug');
end

for k = 1:nAcc
    for var = {'acc%d_x','acc%d_y','acc%d_z','gyr%d_x','gyr%d_y','gyr%d_z'}
        header = sprintf(['%s,' var{1}], header, k);
    end
end

end
