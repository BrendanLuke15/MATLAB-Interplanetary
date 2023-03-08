function elements = SV2Ele(r,v,mu)
% Function to turn state vectors to Keplerian elements:
% Inputs:
%   - r: XYZ position
%   - v: XYZ velocity
%   - mu: standard gravitational parameter of central body (km^3/s^2)
% Outputs:
%   - elements: vector of elements (6)
%       - 1,a: semi major axis (km)
%       - 2,e: eccentricity
%       - 3,i: inclination (°)
%       - 4,RAAN: right ascension of ascending node (°)
%       - 5,w: argument of periapsis (°)
%       - 6,v: true anomoly (°)

elements(1) = 1/(2/norm(r)-norm(v)^2/mu);
h = cross(r,v);
e_Vect = cross(v,h)/mu-r/norm(r);
elements(2) = norm(e_Vect);
elements(3) = acosd(h(3)/norm(h));
n = cross([0,0,1],h);
if n(2) > 0
    elements(4) = acosd(n(1)/norm(n));
else
    elements(4) = 360 - acosd(n(1)/norm(n)); % RAAN
end
if e_Vect(1) > 0
    elements(5) = acosd(dot(n,e_Vect)/norm(n)/elements(2));
else
    elements(5) = 360 - acosd(dot(n,e_Vect)/norm(n)/elements(2)); % aop, w
end
if ~(dot(r,v) < 0)
    elements(6) = acosd(dot(e_Vect,r)/norm(r)/elements(2));
else
    elements(6) = 360 - acosd(dot(e_Vect,r)/norm(r)/elements(2)); % true anom, v
end

end