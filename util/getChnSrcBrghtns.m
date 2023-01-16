function [chnList, chnBrghtns] = getChnSrcBrghtns(chnMask,brgth_plan,drv_plan)
%


% TODO: implement for sine modulation -> brgth_plan is drv_amplitudes!

chnMask = vertcat(chnMask{:});
chnMaskNum = reshape(sscanf(chnMask,'%1d'),size(chnMask));

[iSrc,iDet] = find(chnMaskNum);
chnList = compose('S%02dD%02d',iSrc,iDet);


drv_plan = cell2mat(vertcat(drv_plan{:}));
drv_planNum = reshape(sscanf(drv_plan,'%1d'),size(drv_plan));
% drv_planLgcl = drv_planNum>0;

assert(max(iSrc)<=size(drv_planNum,2), ...
    'The number of columns in drv_plan does not match the number of sources in the channel mask!');

chnBrghtns = zeros(numel(chnList),2);

if size(brgth_plan,1)==size(drv_plan,1)
    % brightness = amp_plan (RECT MODULATION)
    % TODO: VECTORIZE ?!
    for ci = 1:numel(chnList)
        src = iSrc(ci); det = iDet(ci);

        stepsActive = find(drv_planNum(:,src));
        brgtStep = chnMaskNum(src,det);
        assert(numel(stepsActive)>=brgtStep, ...
            'Source %d has not enough active steps (#%d for chn %s)', ...
            src, brgtStep, chnList{ci});

        iStep = stepsActive(brgtStep);

        devIdx = ceil(src/16);
        srcIdx = ceil((src-(devIdx-1)*16)/4);
        amp_plnIdx = [-1 0]+2*srcIdx;

        chnBrghtns(ci,:) = brgth_plan(iStep,devIdx,amp_plnIdx);

    end


elseif size(brgth_plan,2) == 8
    % brightness = drv_amplitudes (sine modulation)
    % TODO: VECTORIZE ?!
    for ci = 1:numel(chnList)
        src = iSrc(ci);

        devIdx = ceil(src/16);
        srcIdx = ceil((src-(devIdx-1)*16)/4);
        amp_plnIdx = [-1 0]+2*srcIdx;

        chnBrghtns(ci,:) = brgth_plan(devIdx,amp_plnIdx);
    end
else, error('2nd input, brght_plan, must be either an amp_plan (size(brgth_plan,1)==numel(drv_plan)) or drv_amplitudes of size Nx8, where N = number of NSP2');
end


end
