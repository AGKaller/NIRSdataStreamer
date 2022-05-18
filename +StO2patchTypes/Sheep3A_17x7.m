function rho = Sheep3A_17x7(patchNam)
% patches for 3rd sheep, 8.4.2022

import StO2patchTypes.FNC.trapz_rho
import StO2patchTypes.FNC.arbitr_rho
import StO2patchTypes.FNC.sqr_rho

ptchIds = strsplit(patchNam,'_');

[ptype,config] = ptchIds{2:3};


d0 = sqrt(2)*18;

switch ptype
    case 'trap'
        % trapezoid -------------------------------------------------------
        if strcmpi(config,'a') % antisymmetric . . . . . . . . . . . . . . 
            rho = trapz_rho(d0,2*d0,18,'anti');
%             rho = arbitr_rho(sqrt(2)*[9 9], sqrt(2)*[3*9 9], [sqrt(2)*4*9 0], 90, 90);
            
        elseif startsWith(config,'o') % sym, othogonal . . . . . . . . . . 
            rho = trapz_rho(d0,2*d0,18,'sym','ortho',config(2));
        
        elseif startsWith(config,'p') % sym, paralllel . . . . . . . . . . 
            if endsWith(config,'ss') % src on short side
                rho = trapz_rho(d0, 2*d0, 18, 'sym', 'para', config(2));
            elseif endsWith(config,'sl') % src on long side
                rho = trapz_rho(2*d0, d0, 18, 'sym', 'para', config(2));
            else
                error('Unexpected trapezoid configuration code in patch ''%s''.', patchNam);
            end
            
        else
            error('Unexpected source orientation code in patch ''%s''.', patchNam);
        end
            
        
    case {'sqr'}
        % square ----------------------------------------------------------
        if strcmpi(config,'a')
            % square antisymmetric 
            rho = sqr_rho(18*sqrt(2),'antisym');
        elseif startsWith(config,'o')
            rho = sqr_rho(18*sqrt(2),'sym','ortho',config(2));
        else
            % square, diagonal src rotation! 
            angl = str2double(strsplit(config,','));
            assert(all(isfinite(angl)),'Failed to get source rotation from patch ''%s''.',patchNam);
            rho = arbitr_rho([0 18],[18 18],[18 0],angl(1),angl(2));
%         switch config
%             case 'oup' % outward up down
%                 rho = arbitr_rho([0 18],[18 18],[18 0],-135,45);
%                 
%             otherwise
%                 error('Square configuration code in patch ''%s'' not implemented.', patchNam);
%         end
        end
        
    case {'rect'}
        % rectangular, diagonal src rotation! -----------------------------
        angl = str2double(strsplit(config,','));
        assert(all(isfinite(angl)),'Failed to get source rotation from patch ''%s''.',patchNam);
        rho = arbitr_rho([0 36],[18 36],[18 0],angl(1),angl(2));
        
        
    case 'lin'
        % linear, diagonal src rotation! ----------------------------------
        cfgCell = strsplit(config,',');
        angl = str2double(cfgCell(2:3));
        assert(all(isfinite(angl)),'Failed to get source rotation from patch ''%s''.',patchNam);
        switch cfgCell{1}
            case 'o', rho = arbitr_rho([0 -18], [0 -36], [0 -54], angl(1), angl(2));
            case 'i', rho = arbitr_rho([0  18], [0 -54], [0 -36], angl(1), angl(2));
            otherwise, error('Unexpected source position code in patch ''%s''.', patchNam);
        end
        
        
    otherwise, error('Unrecognized patch name'); % rho=[NaN NaN]; % 
end


end