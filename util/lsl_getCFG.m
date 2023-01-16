function lsl_cfg = lsl_getCFG()
%

%% LSL configuration
% load lsl library
lsl_cfg.lslib = lsl_loadlib();
% stream labels
lsl_cfg.InSLabel = {'fNIRS'};
lsl_cfg.OutSLabel = {'StO2'};
lsl_cfg.InTLabel = 'Trigger_in';
% obsolete, handled by TrigCtrlGUI:
% sys_cnfg.lsl.OutTLabel = 'Trigger_out';
% default stream name
lsl_cfg.InSName = 'Aurora'; % 'NSP2_Stream';
lsl_cfg.OutSName = 'CerebOx_Stream';
lsl_cfg.InTName = 'NIRStarTriggers';
% obsolete, handled by TrigCtrlGUI:
% sys_cnfg.lsl.OutTName = 'Trigger';


end