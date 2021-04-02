function In = RotateMomentOfInertia(I, R)

% This function computes the rotated moment of inertia In given a moment of inertia I and rotation matrix R.

% Compute the rotated moment of inertia.
In = R*I*(R');

end

