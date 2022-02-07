function d = trapz_diag(long,shrt,leg)
% calulate diagonal of isosceles trapezoid
% d = trapz_diag(long,shrt,leg)


d = sqrt((long*leg^2 + long^2*shrt-long*shrt^2-shrt*leg^2) ...
    / (long-shrt));

end