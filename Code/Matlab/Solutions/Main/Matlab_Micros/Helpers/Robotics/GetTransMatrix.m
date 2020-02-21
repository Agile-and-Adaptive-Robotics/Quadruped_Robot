function [ R ] = GetTransMatrix( w, theta )

%This function computes the transformation matrix associated with a given angle and axis of rotation.

%Compute the exponential coordinates from the given axis of rotation and angle.
wtheta = w*theta;

%Compute the skew matrix from the exponential coordinates.
wtheta_skew = Vec2Skew(wtheta);

%Compute the transformation matrix.
R = expm(wtheta_skew);


end

