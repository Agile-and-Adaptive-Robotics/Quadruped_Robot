function [ M ] = RotxMat3( theta )

%Create a 3x3 rotation matrix by the given angle theta about the x-axis.
M = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];

end

