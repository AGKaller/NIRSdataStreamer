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
        case {'nacc','naccelerometer'}
            if cfgstrct.use_accelerometer
                varargout{i} = sum(cfgstrct.device_split(:,2))/8;
            else
                varargout{i} = 0;
            end
        otherwise
            try
                param = validatestring(varargin{i},fieldnames(cfgstrct));
                varargout{i} = cfgstrct.(param);
            catch ME
                throw(addCause(MException('DataStreamer:getCfgParam:cfgParamNotFound',...
                    'The input argument %d was not recognized and the parameter was not found in the json file!',i),ME));
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