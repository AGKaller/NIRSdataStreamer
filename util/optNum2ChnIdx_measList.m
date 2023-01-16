function [varargout] = optNum2ChnIdx_measList(srcNum,detNum,measList)
% [chIdx_wl1, chIdx_wl2, ...] = optNum2ChnIdx_measList(srcNum,detNum,measList)
%
% Input measList from .nirs file, field .SD.MeasList

assert(numel(srcNum)==numel(detNum),'Number of sources and number detectors must be the same!');
nchn = numel(srcNum);


for wl = max(1,nargout):-1:1
    [lia,varargout{wl}] = ismember([srcNum(:) detNum(:) wl*ones(nchn,1)],measList(:,[1 2 4]),'rows');
    miss = find(~lia,1,'first');
    assert(isempty(miss),'Channel S%02d-D%02d (wl%d) not found in measList!', ...
        srcNum(miss), detNum(miss), wl);
    varargout{wl} = reshape(varargout{wl},size(srcNum));
end

end