function header = mkHeader(chnMask)
%

header = 'TStamp,Trg,Frame';

for prfx = {'wl1' 'wl2' 'oxy' 'dxy'}
    frmt = sprintf(',%s_S%%02d-D%%02d',prfx{1});
    for srci = 1:numel(chnMask)
%         deti = strfind(chnMask{srci},'1');
        deti = find(double(chnMask{srci})==49); % 10x faster
        srciHead = sprintf(frmt, [ones(1,numel(deti))*srci; ...
                                  deti]);
        header = sprintf('%s%s',header,srciHead);
    end
end


end