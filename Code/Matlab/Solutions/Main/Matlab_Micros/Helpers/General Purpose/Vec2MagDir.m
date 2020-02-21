function [ mag, dir ] = Vec2MagDir( v )

%This function computes the magnitude and direction associated with a given vector.

%Compute the magnitude of the given vector.
mag = norm(v);

%Compute the unit direction of the vector.
dir = v/mag;

end

