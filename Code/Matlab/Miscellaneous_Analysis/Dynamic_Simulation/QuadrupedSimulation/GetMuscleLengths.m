function Lmuscles = GetMuscleLengths( Pmuscles )

% This function computes the muscle lengths associated with a history of muscle attachment point locations.

% Inputs:
    % Pmuscles = num_spatial_dimensions (i.e., 3 for x, y, z) x num_attachment_pts_per_muscle x num_muscles x num_timesteps matrix of muscle attachment points over time.

% Outputs:
    % Lmuscles = num_muscles x num_timesteps matrix of muscle lengths over time.

% Retrieve size information from the inputs.
num_muscles = size(Pmuscles, 3);
num_timesteps = size(Pmuscles, 4);

% Create a matrix to store the muscle lengths
Lmuscles = zeros(num_muscles, num_timesteps);

% Compute the muscle lengths throughout the trajectory.
for k1 = 1:num_timesteps            % Iterate through each of the time steps...
    for k2 = 1:num_muscles          % Iterate through each of the muscles...
        
        % Compute the distance between the muscle attachment points for this muscle at this time step.
        dPmuscles_desired = diff(Pmuscles(:, :, k2, k1), 1, 2);
        
        % Compute the length of this muscle at this time step.
        Lmuscles(k2, k1) = sum(vecnorm(dPmuscles_desired, 2, 1));
        
    end
end

end

