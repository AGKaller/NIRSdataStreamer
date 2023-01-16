clear
addpath(fileparts(fileparts(mfilename("fullpath"))));
%%

[o, t] = StO2layouts.OP220906_FETp2;
outname = 'patchDef_FET_NECK.csv';
% [o, t] = StO2layouts.Pig02_220524_18x7_Yo25;
% [o2, t2] = StO2layouts.Sheep3A_17x7.neckUS; % <- this is loaded by the
                                              % other two layout functions.
% [o3, t3] = StO2layouts.Sheep3A_17x7.neckUS_shorts;
% o = [o1;o3];
% t = [t1;t3];
% remove dublicates!
[o,io] = unique(o,'rows','stable');
t = t(io);

ismissCell = @(x)cellfun(@(x)any(ismissing(x))|isempty(x),x);

%% SHAPE AND POSITION
position = regexp(t,'(?<=\.)[^_]+','match','once');

shape = regexp(t,'(?<=neck_|head_)[^_]+','match','once');
assert(~any(cellfun(@isempty,shape)));
shape = regexprep(shape, ...
    {'rect$',       'trap',         'sqr',      'lin',   'rectWide',     'parallgrmL',        'parallgrmS'}, ...
    {'rectangular', 'trapezoid',    'square',   'linear' 'rectangular45','parallelogram_long','parallelogram_short'});


%% CABLE CONFIGURATION 

cable_config = cell(size(shape));
k = endsWith(t,'a');
cable_config(k) = {'antisymmetric'};
k = endsWith(t,regexpPattern('o[oi]$'));
cable_config(k) = {'symmetric'};

k = startsWith(shape,{'parallelogram_'});
kidx = find(k);
angls = regexp(t(k),'(?<=_)(-?\d+),(-?\d+)$','tokens','once');
angln = str2double(vertcat(angls{:}));
k(kidx(diff(angln,1,2)~=0)) = false;
cable_config(k) = {'antisymmetric'};
k = false(size(k));
k(kidx(diff(angln,1,2)~=0)) = true;
cable_config(k) = {'symmetric'};


k = endsWith(t,'_sqr_-135,-45');
cable_config(k) = {'antisymmetric'};

k = strcmpi(shape,'rectangular45');
cable_config(k) = {'other'};

k = strcmpi(shape,'rectangular');
cable_config(k) = {'antisymmetric'};

k = strcmpi(shape,'linear');
cable_config(k) = {'symmetric'};

assert(~any(ismissCell(cable_config)),'Unassigned cable configuration!');


%% CABLE ORIENTATION

% 
% cable_orientation = repmat({missing},(size(shape)));
% k = endsWith(t,regexpPattern('_o[a-z]+'));
% cable_orientation(k) = {'orthogonal'};
% 
% k = endsWith(t,regexpPattern('_p[a-z]+'));
% assert(~any(k & ismissCell(cable_orientation)));
% cable_orientation(k) = {'parallel'};
% 
% k = endsWith(t,regexpPattern('\d+'));
% assert(~any(k & ismissCell(cable_orientation)));
% cable_orientation(k) = {'diagonal'};


%% get rho, replicate for wl1/2 & for chn1/2 if needed

rho = cellfun(@getStO2PatchRho,t,'UniformOutput',false);
nd = cellfun(@(x)sum(size(x)>1),rho);
k = nd < 2;
rho(k) = cellfun(@(x)repmat(x,1,2),rho(k),'UniformOutput',false);
k = nd < 3;
rho(k) = cellfun(@(x)repmat(x,1,1,2),rho(k),'UniformOutput',false);

optID_shortChn1 = compose('S%02d-D%02d',o(:,[1 2]));
optID_shortChn2 = compose('S%02d-D%02d',o(:,[4 3]));
optID_longChn1 = compose('S%02d-D%02d',o(:,[1 3]));
optID_longChn2 = compose('S%02d-D%02d',o(:,[4 2]));

rho_shortChn1 = cell2mat(cellfun(@(x)x(2,:,1),rho,'UniformOutput',false));
rho_shortChn2 = cell2mat(cellfun(@(x)x(2,:,2),rho,'UniformOutput',false));
rho_longChn1 = cell2mat(cellfun(@(x)x(1,:,1),rho,'UniformOutput',false));
rho_longChn2 = cell2mat(cellfun(@(x)x(1,:,2),rho,'UniformOutput',false));

tOut = table(optID_shortChn1, optID_shortChn2, optID_longChn1, optID_longChn2, ...
             rho_shortChn1,   rho_shortChn2,   rho_longChn1,   rho_longChn2, ...
             position, shape, cable_config);


%%

% patchID = compose('S%02dD%02dD%02dS%02d',o);
% writetable(table(patchID,shape,cable_config,cable_orientation),outname);

writetable(tOut,outname);
