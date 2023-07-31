function Pcom = GetCenterOfMass(Ps, ms)

% This function computes the center of mass of points Ps with masses ms;

% Inputs:
    % Ps = 3 x N matrix of points whose first row are x coordinates, second row are y coordinates, and third row are z coordinates.
    % ms = N x 1 array of masses, one mass per points in Ps.

% Outputs:
    % Pcom = 3 x 1 array of points that describe the location of the center of mass of the points.

% Compute the center of mass.
Pcom = Ps*ms/sum(ms);

end

