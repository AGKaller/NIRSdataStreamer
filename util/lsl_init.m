%% lsl_init function to initilize the input and output streaming data
% Update 2021.04.19, Lin Yang
% Input: sys_cnfg (struct data), type (char data)
%   sys_cnfg: system configragtion, more details can be found in the
%           comments of function system_init
%   type: Models of the LSL streaming
%           - 'input' : checking the existing streams and search the
%           identical one with the name as of lsl_cfg.InSName, and save
%           the streaming data into lsl_cfg.inlet
%           - 'output': Save the outgoing stream data under the name lsl_cfg.OutSName into
%           lsl_cfg.outlet
% output: sys_cnfg (struct data)
%           Add the following data into sys_cnfg:
%           lsl_cfg.inlet:   Incoming streaming data
%           lsl_cfg.InSInfo: Incoming streaming information
%           lsl_cfg.outlet:  Outgoing streaming data
%           lsl_cfg.outSInfo: Outgoing streaming information

function [lsl_cfg] = lsl_init(lsl_cfg,type,silent)

if ~exist('silent','var')
    silent = false;
end
switch type
    case 'input'
        % Check whether names of streams on the lab network are identical to those in the config file
        snames = '';
        while isempty(snames)
            snames = unique(cellfun(@(s)s.name(), lsl_resolve_all(lsl_cfg.lslib,0.3) ,'UniformOutput',false));
        end
%         if isempty(snames)
%             error('There is no stream visible on the network.');
%         else
            if isempty(find(strcmp(snames,lsl_cfg.InSName),1))
                warning(['No ' lsl_cfg.InSName ' data stream found.']);
            end
            % data stream .................................................
            if ~silent, disp(['Resolving stream ' lsl_cfg.InSName '...']); end
            result = {};
            while isempty(result)
                result = lsl_resolve_byprop(lsl_cfg.lslib,'name', lsl_cfg.InSName);
                pause(.1);
            end
            % create and save new inlet
            if ~silent, disp(['Opening inlet for stream ' lsl_cfg.InSName '...']); end
            lsl_cfg.inlet = lsl_inlet(result{1});
            % get the stream info objects
            lsl_cfg.InSInfo =  lsl_cfg.inlet(1).info();

            % trigger stream ..............................................
            if ~silent, disp(['Resolving stream ' lsl_cfg.InTName '...']); end
            result = {};
            while isempty(result)
                result = lsl_resolve_byprop(lsl_cfg.lslib,'name', lsl_cfg.InTName);
                pause(.1);
            end
            % create and save new inlet
            if ~silent, disp(['Opening inlet for stream ' lsl_cfg.InTName '...']); end
            lsl_cfg.inlet_trg = lsl_inlet(result{1});
            % get the stream info objects
            lsl_cfg.InTInfo =  lsl_cfg.inlet_trg.info();
%         end
        
    case 'output'
        % make new stream outlets
        % cerebox .........................................................
%         if ~silent, disp(['Creating new stream for CerebOx data: ' lsl_cfg.OutSName]); end
%         lsl_cfg.OutSInfo = lsl_streaminfo(lsl_cfg.lslib, lsl_cfg.OutSName, lsl_cfg.OutSLabel, sys_cnfg.NPatch, sys_cnfg.StO2rate,'cf_float32','sdfwerr32432');
%         if ~silent, disp(['Opening ' lsl_cfg.OutSName ' stream outlet...']); end
%         lsl_cfg.outlet = lsl_outlet(lsl_cfg.OutSInfo);
        
        % trigger .........................................................
        % obsolete, handled by TrigCtrlGUI
%         if ~silent, disp(['Creating new stream for trigger: ' lsl_cfg.OutTName]); end
%         lsl_cfg.OutTInfo = lsl_streaminfo(lsl_cfg.lslib, lsl_cfg.OutTName, lsl_cfg.OutTLabel, 1, 0, 'cf_int8', 'sdfwerr32432');
%         if ~silent, disp(['Opening ' lsl_cfg.OutTName ' stream outlet...']); end
%         lsl_cfg.outlet_trg = lsl_outlet(lsl_cfg.OutTInfo);
end

end