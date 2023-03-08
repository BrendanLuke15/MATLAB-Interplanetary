function map = myColorMap(n)
% Colour map for filled contour plots
%   - creates RGB map based on resolution, n, specified
%   - colour profile is personal taste of creator Brendan Luke
expo = 5;

for i = 1:n
    R(n-i+1) = -(i/n)^expo + 1;
    G(i) = -(i/n)^expo + 1;
    B(i) = 0.11 + (0.21-0.11)/n*i;
end

map = [R' G' B'];
end

