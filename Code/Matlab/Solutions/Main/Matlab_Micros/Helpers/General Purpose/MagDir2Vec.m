function [ v ] = MagDir2Vec( mag, dir )

%This function computes the vector associated with a given magnitude and direction.

%Ensure that the direction is a unit vector.
dir = dir/norm(dir);

%Define the new vector.
v = mag*dir;

end

