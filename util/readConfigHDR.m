function cfgHDR = readConfigHDR(infile)

[fid,errmsg] = fopen(infile);
assert(fid>2,'Failed to open file ''%s'' because:\n%s',infile,errmsg);

c = fread(fid,'uint8=>char',[1 inf]);
cs = regexp(c,'\r?\n','split');
tok = regexp(cs,'(^[\w\s]+)=(.*$)','tokens');

tok = vertcat(tok{~cellfun(@isempty,tok)});
tok = vertcat(tok{2==cellfun(@numel,tok)});

keep = cellfun(@isempty,regexp(tok(:,1),'^Channel (Mask|indices)','once'));
tok = tok(keep,:);


% conversion
convFncs = { 'Date',             @(x)datetime(x,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS'); ...
            {'Sources','Detectors','Sampling rate'} ...
                                @str2double; ...
           };
for k = 1:size(convFncs)
    tokIdx = ismember(tok(:,1),convFncs{k,1});
    tok(tokIdx,2) = cellfun(convFncs{k,2},tok(tokIdx,2),'UniformOutput',false);
end

% make struct
cfgHDR = cell2struct(tok(:,2),matlab.lang.makeValidName(tok(:,1)));


end