function [ M ] = RotzMat3( theta )

%Create a 3x3 rotation matrix by the given angle theta about the y-axis.
M = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];

end

