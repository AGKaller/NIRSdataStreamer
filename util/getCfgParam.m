function varargout = getCfgParam(nfgFile,varargin)
% [v1,v2,...] = getCfgParam(nfgFile,p1,p2,...)

cfgstrct = loadjson(nfgFile);

varargout = cell(size(varargin));
for i = 1:numel(varargin)
    switch lower(varargin{i})
        case {'fs','srate'}
            varargout{i} = 46875 / cfgstrct.plan_length / cfgstrct.total_cycle_samples;
        case {'nchn','nch'}
            varargout{i} = sum(count(cfgstrct.channel_mask,'1'));
        case {'json'}
            varargout{i} = cfgstrct;
        case {'mastercfg'}
            pattrn = '(?<=(optimal, based on )?master, from ).*';
            uri = regexp(cfgstrct.tag,pattrn,'match','once');
            varargout{i} = regexprep(uri,'\\{2}','\');
        case {'optimized'}
            varargout{i} = ~isempty(regexp(cfgstrct.tag,'^optimal','once'));
        otherwise
            try
                param = validatestring(varargin{i},fieldnames(cfgstrct));
                varargout{i} = cfgstrct.(param);
            catch
                error('Parameter not implemented/not found in json!');
            end
    end
end

end



function fsep = fsepEscpd
%
if ispc
    fsep = '\\';
else
    fsep = filesep;
end
end