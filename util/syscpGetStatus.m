function [sts,msg] = syscpGetStatus(logFile)
% Reads log files produced by robocopy.exe and returns status of copy process.
%
% Input: logFile
% Output: sts      msg
%         -3      'Failed to open log file'; ...
%         -2      'There was an error while executing the script performing the copy operation'; ...
%         -1      'Log file does not exist'; ...
%          0      'File skipped'; ...
%          1      'Retrying...'; ...
%          2      'Copy operation in progress'; ...
%          3      'File copied successfully'; ...
%          4      'No file found'; ...
%         99      'Unknown status';
% 
% V1.0, 2022-03-23, Konrad Schumacher

sts = NaN;
validateattributes(logFile,'char',{'row'},mfilename,'logFile',1);

stsTab = {...
    -3      'Failed to open log file'; ...
    -2      'There was an error while executing the script performing the copy operation'; ...
    -1      'Log file does not exist'; ...
     0      'File skipped'; ...
     1      'Retrying...'; ...
     2      'Copy operation in progress'; ...
     3      'File copied successfully'; ...
     4      'No file found'; ...
    99      'Unknown status';
     };

if ~exist(logFile,'file')
    sts = -1;
end

[fid,msg] = fopen(logFile,'r');
if fid == -1
    sts = -3;
    warning('DataStreamer:syscpGetStatus:failedToOpenLogFile',...
        'Could not open log file %s for reading. Reason:\n %s', logFile, msg);
end
%     ,'DataStreamer:syscpGetStatus:failedToOpenLogFile',...
%     'Could not open log file %s for reading. Reason:\n %s', logFile, msg);

if ~isnan(sts)
    msg = stsTab{[stsTab{:,1}]==sts,2};
    return;
end

pattObj_Err = regexpPattern('^([\d/\s\:]+ )?FEHLER .*');
patt_Sumry = '^\s*Dateien:(\s+\d+)(\s+\d+)(\s+\d+)(\s+\d+)(\s+\d+)(\s+\d+)';
pattObj_Sumry = regexpPattern(patt_Sumry);
pattObj_fin = regexpPattern('^\s+Beendet: \w+,.*');
pattObj_retr = regexpPattern('^\d+ Sekunden wird gewartet...*');
patt_prgs = '^\s*\d+(\.\d+)?%';
pattObj_prgs = regexpPattern(patt_prgs);

msgAppend = '';
tline = '';
lastNonEmptyLine = '';
sumry_files = false(1,6);
while ischar(tline)
    tline = fgetl(fid);
    if ~ischar(tline) || isempty(strip(tline)), continue; end
    lastNonEmptyLine = tline;
    
    if matches(tline,pattObj_Err)
        sts = -2;
%         break;
    end
    
    if matches(tline,pattObj_Sumry)
        sumry_files_c = regexp(tline,patt_Sumry,'tokens','once');
        sumry_files = ~strcmp(strip(sumry_files_c),'0');
    end
end

if matches(lastNonEmptyLine,pattObj_retr)
    sts = 1;
elseif ~isnan(sts)
    % pass
elseif isempty(lastNonEmptyLine)
    sts = 99;
elseif matches(lastNonEmptyLine,pattObj_fin)
    if ~sumry_files(1) % no file found
        sts = 4;
    elseif sumry_files(2) % at least 1 file copied
        sts = 3;
    elseif sumry_files(3) % at least 1 file skipped
        sts = 0;
    else
        sts = 99;
    end
elseif matches(lastNonEmptyLine,pattObj_prgs)
    sts = 2;
    msgAppend = regexp(lastNonEmptyLine,patt_prgs,'match','once');
    
else
    sts = 99;
end


fclose(fid);
msg = stsTab{[stsTab{:,1}]==sts,2};
msg = sprintf('%s: %s',msg,msgAppend);

end