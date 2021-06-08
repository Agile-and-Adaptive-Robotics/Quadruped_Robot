function Ps = GetCuboidPoints(sx, sy, sz, dx, dy, dz, thetax, thetay, thetaz)

% This function returns the points of a cuboid specified by the given properties

% Inputs:
    % sx, sy, sz = x, y, and z scale of the desired cuboid.
    % dx, dy, dz = x, y, and z position of the center of the desired cuboid.
    % thetax, thetay, thetaz = x, y, and z rotation of the desired cuboid.

% Outputs:
    % Ps = 3 x 16 matrix of cuboid points.
    
% Define default input arguments.
if nargin < 9, thetaz = 0; end
if nargin < 8, thetay = 0; end
if nargin < 7, thetax = 0; end
if nargin < 6, dz = 0; end
if nargin < 5, dy = 0; end
if nargin < 4, dx = 0; end
if nargin < 3, sz = 1; end
if nargin < 2, sy = 1; end
if nargin < 1, sx = 1; end

% Create a scaling matrix.
S = [sx 0 0 0; 0 sy 0 0; 0 0 sz 0; 0 0 0 1];

% Create a rotation matrix.
Rx = [1 0 0 0; 0 cos(thetax) -sin(thetax) 0; 0 sin(thetax) cos(thetax) 0; 0 0 0 1];
Ry = [cos(thetay) 0 sin(thetay) 0; 0 1 0 0; -sin(thetay) 0 cos(thetay) 0; 0 0 0 1];
Rz = [cos(thetaz) sin(thetaz) 0 0; -sin(thetaz) cos(thetaz) 0 0; 0 0 1 0; 0 0 0 1];
R = Rz*Ry*Rx;

% Create a translation matrix.
T = [1 0 0 dx; 0 1 0 dy; 0 0 1 dz; 0 0 0 1];

% Define the template cubiod points.
xs = 0.5*[-1 -1 -1 -1 -1 1 1 -1 1 1 -1 1 1 -1 1 1];
ys = 0.5*[-1 1 1 -1 -1 -1 1 1 1 1 1 1 -1 -1 -1 -1];
zs = 0.5*[-1 -1 1 1 -1 -1 -1 -1 -1 1 1 1 1 1 1 -1];
Ps = [xs; ys; zs; ones(1, length(xs))];

% Transform the cuboid based on the desired properties.
Ps = T*R*S*Ps;

% Remove the last row that is filled with ones.
Ps(end, :) = [];

end

