function [ adT ] = adjointT( T )

%This script computes the adjoint of a transformation matrix T.
    %T = 4x4 Transformation Matrix.
    %adT = 6x6 Adjoint Transformation Matrix.

%Retrieve the rotational component of the transformation matrix.
R = T(1:3, 1:3);

%Retrieve the translational component of the transformation matrix.
p = T(1:3, 4);

%Compute the skew-symmetric matrix associated with the translational component.
pskew = Vec2Skew(p);

%Compute the adjoint of the matrix.
adT = [R zeros(3); pskew*R R];

end

