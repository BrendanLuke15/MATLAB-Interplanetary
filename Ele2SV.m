function [r,v] = Ele2SV(Elements_S,TrueAnoms,mu,n)
% Function to turn Keplerian elements to state vectors:
% Inputs:
%   - Elements_S: vector of static elements (5)
%       - 1,a: semi major axis (km)
%       - 2,e: eccentricity
%       - 3,i: inclination (°)
%       - 4,RAAN: right ascension of ascending node (°)
%       - 5,w: argument of periapsis (°)
%   - TrueAnoms: true anomolies, [start end] (°) -> end > start
%   - mu: standard gravitational parameter of central body (km^3/s^2)
%   - n: resolution of output states
% Outputs:
%   - r: XYZ position (km)
%   - v: XYZ velocity (km/s)

r = NaN(n,3); v = NaN(n,3); % initalize outputs
r_Mag = NaN(n,1); % initalize intermediates
truAnomVect = linspace(TrueAnoms(1),TrueAnoms(2),n);

% 3D Transformation of Orbit
R11 = cosd(Elements_S(5))*cosd(Elements_S(4)) - sind(Elements_S(5))*sind(Elements_S(4))*cosd(Elements_S(3));
R12 = -cosd(Elements_S(5))*sind(Elements_S(4)) - sind(Elements_S(5))*cosd(Elements_S(4))*cosd(Elements_S(3));
R13 = sind(Elements_S(5))*sind(Elements_S(3));
R21 = sind(Elements_S(5))*cosd(Elements_S(4)) + cosd(Elements_S(5))*sind(Elements_S(4))*cosd(Elements_S(3));
R22 = -sind(Elements_S(5))*sind(Elements_S(4)) + cosd(Elements_S(5))*cosd(Elements_S(4))*cosd(Elements_S(3));
R23 = -cosd(Elements_S(5))*sind(Elements_S(3));
R31 = sind(Elements_S(4))*sind(Elements_S(3));
R32 = cosd(Elements_S(4))*sind(Elements_S(3));
R33 = cosd(Elements_S(3));

TransformSC = [R11 R12 R13;
               R21 R22 R23;
               R31 R32 R33];

% Coordinate Transform
for k = 1:n
    r_Mag(k) = (Elements_S(1)*(1-Elements_S(2)^2))./(1+Elements_S(2).*cosd(truAnomVect(k))); % radius of heliocentric orbit (km)
    r(k,:) = TransformSC*[r_Mag(k)*cosd(truAnomVect(k)); r_Mag(k)*sind(truAnomVect(k)); 0];  % cartesian position (km)
    v(k,:) = TransformSC*(sqrt(mu*Elements_S(1))/(r_Mag(k))*...
        [-(sqrt(1-Elements_S(2)^2)*sind(truAnomVect(k)))/(1+Elements_S(2)*cosd(truAnomVect(k))); ...
        sqrt(1-Elements_S(2)^2)*(Elements_S(2)+cosd(truAnomVect(k)))/(1+Elements_S(2)*cosd(truAnomVect(k))); ...
        0]);  % cartesian velocity (km/s)
end

end