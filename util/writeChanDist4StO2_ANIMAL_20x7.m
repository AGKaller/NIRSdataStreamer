clear
addpath('C:\Users\nradu\Documents\MATLAB\DataStreamer');
%%

[o, t] = StO2layouts.ANIMAL_20x7_3stiff;
outname = 'patchDef_ANIMAL_20x7.csv';
% [o, t] = StO2layouts.Pig02_220524_18x7_Yo25;
% [o2, t2] = StO2layouts.Sheep3A_17x7.neckUS; % <- this is loaded by the
                                              % other two layout functions.
% [o3, t3] = StO2layouts.Sheep3A_17x7.neckUS_shorts;
% o = [o1;o3];
% t = [t1;t3];
% remove dublicates!
[o,io] = unique(o,'rows','stable');
t = t(io);

%%

shape = regexp(t,'(?<=neck_|head_)[^_]+','match','once');
assert(~any(cellfun(@isempty,shape)));
shape = regexprep(shape, ...
    {'rect',        'trap',         'sqr',      'lin',   'rectWide',     'parallgrmL',        'parallgrmS'}, ...
    {'rectangular', 'trapezoid',    'square',   'linear' 'rectangular45','parallelogram_long','parallelogram_short'});

%%

cable_config = cell(size(shape));
k = endsWith(t,'a');
cable_config(k) = {'antisymmetric'};
cable_config(~k) = {'symmetric'};

k = startsWith(shape,{'parallelogram_'});
kidx = find(k);
angls = regexp(t(k),'(?<=_)(-?\d+),(-?\d+)$','tokens','once');
angln = str2double(vertcat(angls{:}));
k(kidx(diff(angln,1,2)~=0)) = false;
cable_config(k) = {'antisymmetric'};

k = endsWith(t,'_sqr_45,135');
cable_config(k) = {'antisymmetric'};



%%

cable_orientation = repmat({missing},(size(shape)));
k = endsWith(t,regexpPattern('_o[a-z]+'));
cable_orientation(k) = {'orthogonal'};

k = endsWith(t,regexpPattern('_p[a-z]+'));
assert(~any(k & ismissing(cable_orientation)));
cable_orientation(k) = {'parallel'};

k = endsWith(t,regexpPattern('\d+'));
assert(~any(k & ismissing(cable_orientation)));
cable_orientation(k) = {'diagonal'};


%%

patchID = compose('S%02dD%02dD%02dS%02d',o);
writetable(table(patchID,shape,cable_config,cable_orientation),outname);

