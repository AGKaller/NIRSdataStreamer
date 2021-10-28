%% lsl_init function to initilize the input and output streaming data
% Update 2021.04.19, Lin Yang
% Input: sys_cnfg (struct data), type (char data)
%   sys_cnfg: system configragtion, more details can be found in the
%           comments of function system_init
%   type: Models of the LSL streaming
%           - 'input' : checking the existing streams and search the
%           identical one with the name as of sys_cnfg.lsl.InSName, and save
%           the streaming data into sys_cnfg.lsl.inlet
%           - 'output': Save the outgoing stream data under the name sys_cnfg.lsl.OutSName into
%           sys_cnfg.lsl.outlet
% output: sys_cnfg (struct data)
%           Add the following data into sys_cnfg:
%           sys_cnfg.lsl.inlet:   Incoming streaming data
%           sys_cnfg.lsl.InSInfo: Incoming streaming information
%           sys_cnfg.lsl.outlet:  Outgoing streaming data
%           sys_cnfg.lsl.outSInfo: Outgoing streaming information

function [sys_cnfg] = lsl_init(sys_cnfg,type,silent)

if ~exist('silent','var')
    silent = false;
end
switch type
    case 'input'
        % Check whether names of streams on the lab network are identical to those in the config file
        snames = '';
        while isempty(snames)
            snames = unique(cellfun(@(s)s.name(), lsl_resolve_all(sys_cnfg.lsl.lslib,0.3) ,'UniformOutput',false));
        end
%         if isempty(snames)
%             error('There is no stream visible on the network.');
%         else
            if isempty(find(strcmp(snames,sys_cnfg.lsl.InSName),1))
                warning(['No ' sys_cnfg.lsl.InSName ' data stream found.']);
            end
            % data stream .................................................
            if ~silent, disp(['Resolving stream ' sys_cnfg.lsl.InSName '...']); end
            result = {};
            while isempty(result)
                result = lsl_resolve_byprop(sys_cnfg.lsl.lslib,'name', sys_cnfg.lsl.InSName);
                pause(.1);
            end
            % create and save new inlet
            if ~silent, disp(['Opening inlet for stream ' sys_cnfg.lsl.InSName '...']); end
            sys_cnfg.lsl.inlet = lsl_inlet(result{1});
            % get the stream info objects
            sys_cnfg.lsl.InSInfo =  sys_cnfg.lsl.inlet(1).info();

            % trigger stream ..............................................
            if ~silent, disp(['Resolving stream ' sys_cnfg.lsl.InTName '...']); end
            result = {};
            while isempty(result)
                result = lsl_resolve_byprop(sys_cnfg.lsl.lslib,'name', sys_cnfg.lsl.InTName);
                pause(.1);
            end
            % create and save new inlet
            if ~silent, disp(['Opening inlet for stream ' sys_cnfg.lsl.InTName '...']); end
            sys_cnfg.lsl.inlet_trg = lsl_inlet(result{1});
            % get the stream info objects
            sys_cnfg.lsl.InTInfo =  sys_cnfg.lsl.inlet_trg.info();
%         end
        
    case 'output'
        % make new stream outlets
        % cerebox .........................................................
%         if ~silent, disp(['Creating new stream for CerebOx data: ' sys_cnfg.lsl.OutSName]); end
%         sys_cnfg.lsl.OutSInfo = lsl_streaminfo(sys_cnfg.lsl.lslib, sys_cnfg.lsl.OutSName, sys_cnfg.lsl.OutSLabel, sys_cnfg.NPatch, sys_cnfg.StO2rate,'cf_float32','sdfwerr32432');
%         if ~silent, disp(['Opening ' sys_cnfg.lsl.OutSName ' stream outlet...']); end
%         sys_cnfg.lsl.outlet = lsl_outlet(sys_cnfg.lsl.OutSInfo);
        
        % trigger .........................................................
        % obsolete, handled by TrigCtrlGUI
%         if ~silent, disp(['Creating new stream for trigger: ' sys_cnfg.lsl.OutTName]); end
%         sys_cnfg.lsl.OutTInfo = lsl_streaminfo(sys_cnfg.lsl.lslib, sys_cnfg.lsl.OutTName, sys_cnfg.lsl.OutTLabel, 1, 0, 'cf_int8', 'sdfwerr32432');
%         if ~silent, disp(['Opening ' sys_cnfg.lsl.OutTName ' stream outlet...']); end
%         sys_cnfg.lsl.outlet_trg = lsl_outlet(sys_cnfg.lsl.OutTInfo);
end

end