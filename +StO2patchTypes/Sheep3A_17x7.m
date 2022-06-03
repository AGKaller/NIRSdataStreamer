function rho = Sheep3A_17x7(patchNam)
% patches for 3rd sheep, 8.4.2022

import StO2patchTypes.FNC.trapz_rho
import StO2patchTypes.FNC.arbitr_rho
import StO2patchTypes.FNC.sqr_rho
import StO2patchTypes.FNC.rect_rho

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
        
            
    case {'trap1854'}
        % trap with 18 and 54 mm ------------------------------------------
        if strcmpi(config,'a')
            rho = trapz_rho(18,54,d0,'antisym');
        else
            error('config not implemented for this patch type');
        end
        
            
    case {'sqr'}
        % square ----------------------------------------------------------
        if strcmpi(config,'a') %                  !!!! sides 25 mm long !!!
            % square antisymmetric 
            rho = sqr_rho(d0,'antisym');
        elseif startsWith(config,'o') %                sides 25 mm long
            rho = sqr_rho(d0,'sym','ortho',config(2));
        else
            % square, diagonal src rotation!      !!!! sides 18 mm long !!!
            angl = str2double(strsplit(config,','));
            assertAngl(angl,patchNam);
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
        % rectangular (srcs & dets on short side), diagonal src rotation! 
        if strcmpi(config,'a')
            % rect antisymmetric, 18x36 
            rho = rect_rho(18,sqrt(5*18^2),'antisym');
        else
            angl = str2double(strsplit(config,','));
            assertAngl(angl,patchNam);
            rho = arbitr_rho([0 36],[18 36],[18 0],angl(1),angl(2));
        end
        
    case 'rectWide'
        % rectangular - sources (and dets) on long side -------------------
        angl = str2double(strsplit(config,','));
        assertAngl(angl,patchNam);
        rho = arbitr_rho([0 18],[36 18],[36 0],angl(1),angl(2));

        
    case 'lin'
        % linear, diagonal src rotation! ----------------------------------
        cfgCell = strsplit(config,',');
        angl = str2double(cfgCell(2:3));
        assertAngl(angl,patchNam);
        switch cfgCell{1}
            case 'o', rho = arbitr_rho([0 -18], [0 -36], [0 -54], angl(1), angl(2));
            case 'i', rho = arbitr_rho([0  18], [0 -54], [0 -36], angl(1), angl(2));
            otherwise, error('Unexpected source position code in patch ''%s''.', patchNam);
        end
        
        
    case 'parallgrmL'
        % parallelogram ---------------------------------------------------
        % long            S    |    S            |            D    |    D            
        %           D   D      |      D   D      |      S   S      |      S   S      
        %         S            |            S    |    D            |            D    
        %           UpSo       |     DownSo      |      UpSi       |      DownSi
        %
        % Note: Source angles have to be EQUAL to result in equal distances
        % for both wavelengths.
        
        angl = str2num(ptchIds{4});
        assertAngl(angl,patchNam);
        
        switch config
            case 'UpSo',    pos = {sqrt(2).*[9  9], sqrt(2).*[3*9  9], sqrt(2).*[4*9  2*9]};
            case 'DownSo',  pos = {sqrt(2).*[9 -9], sqrt(2).*[3*9 -9], sqrt(2).*[4*9 -2*9]};
            case 'UpSi',    pos = {sqrt(2).*-[9 9], sqrt(2).*[3*9  9], sqrt(2).*[2*9 0]};
            case 'DownSi',  pos = {sqrt(2).*[-9 9], sqrt(2).*[3*9 -9], sqrt(2).*[2*9 0]};
            otherwise, error('Unexpected configuration code in patch ''%s''.', patchNam);
        end
        
        rho = arbitr_rho(pos{:}, angl(1), angl(2));
        
        
    case 'parallgrmS'
        % parallelogram ---------------------------------------------------
        % short    S      |         D       |     D          |     S
        %    D       D    |   S       S     |   S       S    |   D       D
        %      S          |     D           |         D      |         S
        % Up SourceInside | Up SourceOuts.  | Down SrceOuts. | Down SrceIns.
        %
        % Note: Source angles have to be EQUAL to result in equal distances
        % for both wavelengths.

        angl = str2num(ptchIds{4});
        assertAngl(angl,patchNam);
        
        switch config
            case 'UpSi',    pos = {sqrt(2).*[-9 9], sqrt(2).*[3*9  9], sqrt(2).*[2*9 2*9]};
            case 'UpSo',    pos = {sqrt(2).*[9 -9], sqrt(2).*[3*9  9], sqrt(2).*[4*9 0]};
            case 'DownSo',  pos = {sqrt(2).*[9  9], sqrt(2).*[3*9 -9], sqrt(2).*[4*9 0]};
            case 'DownSi',  pos = {sqrt(2).*-[9 9], sqrt(2).*[3*9 -9], sqrt(2).*[2*9 -2*9]};
            otherwise, error('Unexpected configuration code in patch ''%s''.', patchNam);
        end
        
        rho = arbitr_rho(pos{:}, angl(1), angl(2));
    
    
    otherwise, error('Unrecognized patch name'); % rho=[NaN NaN]; % 
end


end


function assertAngl(angl,patchNam)
try
    assert(all(isfinite(angl)) && numel(angl)==2 && all(ismember(abs(angl),0:45:180)), ...
        'Failed to get source rotation from patch ''%s''.', patchNam);
catch ME
    throwAsCaller(ME);
end
end