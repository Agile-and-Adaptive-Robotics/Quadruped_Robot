function [ M ] = RotyMat3( theta )

%Create a 3x3 rotation matrix by the given angle theta about the y-axis.
M = [cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];

end

