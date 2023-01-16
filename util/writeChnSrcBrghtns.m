function writeChnSrcBrghtns(cfgFile,outFile)
%

assert(exist(cfgFile,'file'),'File not found: ''%s''',cfgFile);
cfg = loadjson(cfgFile);

chnMask = cfg.channel_mask;
drv_plan = cfg.drv_plan;
switch cfg.modulation
    case 'rect'
        brgth_plan = cfg.amp_plan;
    case 'sine'
        brgth_plan = cfg.drv_amplitudes;
    otherwise, error('Unexpected modulation ''%s'' in ''%s''',cfg.modulation,cfgFile);
end

[chnList, chnBrghtns] = getChnSrcBrghtns(chnMask,brgth_plan,drv_plan);

D = [chnList num2cell(chnBrghtns)].';

[fid,errmsg] = fopen(outFile,'w');
assert(fid>2,'Failed to open file ''%s'' for writing because:\n%s',outFile,errmsg);
fprintf(fid,'channel,wl1,wl2');
fprintf(fid,'\n%s,%.9f,%.6f',D{:});
fclose(fid);

end