function [chIdxWL1,varargout] = optNum2ChnIdx_chMsk(srcNum,detNum,chnMask)
% [chIdx_wl1, chIdx_wl2, ...] = optNum2ChnIdx_chMsk(srcNum,detNum,chnMask)

assert(numel(srcNum)==numel(detNum),'Number of sources and number detector must be the same!');

if ~isnumeric(chnMask) && ~islogical(chnMask)
    assert(iscellstr(chnMask),'channel mask must be provided as logical/numeric matrix or as cellstring!');
    chnMskBool = double(vertcat(chnMask{:}))~=48;
else
    chnMskBool = chnMask>0;
end
% srcNChn = sum(chnMskBool,2); % number of channels each source contributes to.

assert(max(srcNum(:))<=size(chnMskBool,1),'Source number exceeds channel mask!');
assert(max(detNum(:))<=size(chnMskBool,2),'Detector number exceeds channel mask!');

chnMskBool_T = chnMskBool.'; % DETECTORS IN ROWS NOW!

chnMskTIdx = sub2ind(size(chnMskBool_T),detNum,srcNum);
if ~all(chnMskBool_T(chnMskTIdx))
    [d,s] = ind2sub(size(chnMskBool_T), chnMskTIdx(find(~chnMskBool_T(chnMskTIdx),1,'first')));
    error('Channel S%02d-D%02d (and possibly others) is not set in channel mask!',s,d);
end

chIdxWL1 = arrayfun(@(x)sum(chnMskBool_T(1:x)),chnMskTIdx);

% chIdxWL1 = nan(size(srcNum));
% 
% for k = numel(srcNum):-1:1
%     chIdxWL1(k) = sum(srcNChn(1:srcNum(k)-1)) + sum(chnMskBool(srcNum(k),1:detNum(k)));
% end
% 
nchn = sum(chnMskBool(:));
for wl = nargout:-1:2
    varargout{wl-1} = chIdxWL1 + (wl-1)*nchn;
end


end