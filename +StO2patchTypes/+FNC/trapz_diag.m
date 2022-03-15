function d = trapz_diag(long,shrt,leg)
% calulate diagonal of isosceles trapezoid
% d = trapz_diag(long,shrt,leg)

if abs(long-shrt)>1e-12
    d = sqrt((long*leg^2 + long^2*shrt-long*shrt^2-shrt*leg^2) ...
        / (long-shrt));
else
    d = sqrt(long^2+leg^2);
end
end