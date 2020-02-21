function [ nps ] = RotateAboutPointz( ps, theta, p_rot )
%% This function rotates a matrix of points, ps, about the point, p_rot, by the angle, theta, in the z-direction.

%Create the z-rotation matrix.
Rz = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];

%Create the transformation matrix that maps to the desired rotation point.
T = [eye(3) p_rot; 0 0 0 1];

%Rotate the points by the given angle about the given point in the z-direction.
nps = T*[Rz [0; 0; 0]; 0 0 0 1]*(T\[ps; ones(1, size(ps, 2))]);

%Return the new point in R3.
nps = nps(1:3, :);


end

