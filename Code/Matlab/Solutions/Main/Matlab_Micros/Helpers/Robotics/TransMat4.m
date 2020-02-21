function [ M ] = TransMat4( dx, dy, dz )

%Define the 3x3 translation matrix.
M = [1 0 0 dx; 0 1 0 dy; 0 0 1 dz; 0 0 0 1];


end

