function legDelta = trapz_legDelta(long, shrt, leg, delta, orient)
% calculates corrected leg length for isosceles trapezoid when cable
% vertical to the 2 parallel sides. Set delta<0 for shorter leg and delta>0
% for longer leg.

if ~exist('orient','var')
    orient = 'orthogonal';
end

orient = validatestring(orient,{'orthogonal','parallel'});

switch orient
    case 'orthogonal'
        trap_beta = @(long, shrt, leg, d) ...
            pi/2 + d*asin( ((long-shrt)/2)/leg );
    case 'parallel'
        trap_beta = @(long, shrt, leg, d) ...
            (d>0)*pi - d*asin( ((long-shrt)/2)/leg );
    otherwise, error('BUG');
end

legDelta = sqrt(delta^2 + leg^2 - ...
    2 * abs(delta) * leg * cos( ...
                                trap_beta(long,shrt,leg,sign(delta)) ...
                               ) ...
                );


end