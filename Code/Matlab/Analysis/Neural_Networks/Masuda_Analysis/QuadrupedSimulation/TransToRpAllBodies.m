function [Rs, Ps] = TransToRpAllBodies(Ts)

% This function retrieves the rotational and translational components associated with the given transformation matrices.

% Retrieve the number of transformation matrices.
num_pts_per_body = size(Ts, 3);
num_bodies = size(Ts, 4);
num_angles = size(Ts, 5);

% Initialize tensors to store the rotational and translational components that we will extract from the transfomratino matrices.
Rs = zeros(3, 3, num_pts_per_body, num_bodies, num_angles);
Ps = zeros(3, num_pts_per_body, num_bodies, num_angles);

% Retrieve the rotational and translational components associated with each transformation matrix.
for k1 = 1:num_angles               % Iterate through each of the angles...
    for k2 = 1:num_bodies               % Iterate through each of the bodies...
        for k3 = 1:num_pts_per_body         % Iterate through each of the points in this body...
            
            % Retrieve the rotational and translational components associated with this transformation matrix.
            [Rs(:, :, k3, k2, k1), Ps(:, k3, k2, k1)] = TransToRp(Ts(:, :, k3, k2, k1));
            
        end
    end
end

end

