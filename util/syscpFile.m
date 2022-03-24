function [sts,msg] = syscpFile(srcPth,destPth,srcFile,logFile)
% sts = syscpFile(srcPth,destPth,srcFile,logFile)

pth = fileparts(mfilename('fullpath'));
sysScript = fullfile(pth,'cpFile.vbs');
assert(exist(sysScript,'file'),'DataStreamer:cpFile_sys:VBSscriptNotFound',...
    'The script that performs the copy operation was not found: %s',...
    sysScript);

cmd = sprintf('%s "%s" "%s" "%s" "%s"', ...
    sysScript, srcPth, destPth, srcFile, logFile);
[sts,msg] = system(cmd);

end