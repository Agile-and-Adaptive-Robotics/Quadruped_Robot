function Fmuscles_total = JointTorques2TotalMuscleForces( taus, Pmuscles, Pjoints, muscle_joint_orientations, Fmuscles_total_lowbnd )

% This function computes the total muscle muscles necessary to achieve the specified joint torques, given the the current position of the muscle attachment points and joints, the muscle / joint orientations, and the minimum acceptable muscle force.

% Inputs:
    % taus = num_joints x num_timesteps matrix of joint torques.
    % Pmuscles = num_spatial_dimensions x num_attachment_pts x num_muscles x num_timesteps tensor of muscle locations.
    % Pjoint = num_spatial_dimensions x 1 x num_joints x num_timesteps tensor of joint locations.
    % muscle_joint_orientations = num_joints x 1 cell array of joint orientations (either 'Ext' or 'Flx').
    % Fmuscles_total_lowbnd = num_muscles x 1 column vector of minimum allowable muscle forces.

% Outputs:
    % Fmuscles_total = num_muscles x num_timesteps matrix of total muscle forces required to produce the desired joint torques.

% Retrieve size information from the inputs.
num_muscles = size(Pmuscles, 3);
num_timesteps = size(Pmuscles, 4);
num_joints = size(Pjoints, 3);

% Ensure that there are two muscles assigned to each joint.
if num_muscles ~= 2*num_joints          % If there are not two muscles per joint...
   
    % Throw an error stating that we must have two muscles per joint.
    error('The current muscle tension calculation alogrithm assumes that there are exactly two muscles per joint.\n')
    
end

% Initialize a variable to store the desired total muscle forces.
Fmuscles_total = zeros(num_muscles, num_timesteps);

% Compute the force required in each muscle.
for k1 = 1:num_timesteps                % Iterate through each time step...
    for k2 = 1:num_joints               % Iterate through each joint...

        % Reset the primary and secondary muscle indexes.
        muscle_index_primary = 2*k2 - 1;
        muscle_index_secondary = 2*k2;
        
        % Determine which muscle type to use to create the desired torque.
        if taus(k2, k1) >= 0                                                                    % If the torque is greater than or equal to zero...
            
            % Set the muscle type to that associated with positive torque.
            muscle_type = muscle_joint_orientations{k2};                
            
        else                                                                                    % Otherwise...
            
            % Set the muscle type to that associated with negative torque.
            muscle_type = GetOppositeString('Ext', 'Flx', muscle_joint_orientations{k2});       
            
        end
        
        % Determine whether we need to swap the primary and secondary muscle indexes.
        if strcmp(muscle_type, 'Flx')                   % If this is a flexor muscle...
            
            % Swap the primary and secondary muscle indexes.
            [muscle_index_primary, muscle_index_secondary] = deal( muscle_index_secondary, muscle_index_primary );
            
        end

        % Compute the moment arm for each muscle.
        r_primary = Pmuscles(:, 3, muscle_index_primary, k1) - Pjoints(:, 1, k2, k1);
        r_secondary = Pmuscles(:, 3, muscle_index_secondary, k1) - Pjoints(:, 1, k2, k1);

        % Compute the direction of the total forces applied by the primary & secondary muscles.
        Fmuscle_total_dir_primary = (Pmuscles(:, 2, muscle_index_primary, k1) - Pmuscles(:, 3, muscle_index_primary, k1))./norm(Pmuscles(:, 2, muscle_index_primary, k1) - Pmuscles(:, 3, muscle_index_primary, k1));
        Fmuscle_total_dir_secondary = (Pmuscles(:, 2, muscle_index_secondary, k1) - Pmuscles(:, 3, muscle_index_secondary, k1))./norm(Pmuscles(:, 2, muscle_index_secondary, k1) - Pmuscles(:, 3, muscle_index_secondary, k1));
        
        % Set the secondary muscle to have the minimum allowable total force magnitude.
        Fmuscle_total_mag_secondary = Fmuscles_total_lowbnd(muscle_index_secondary);
        
        % Compute the secondary muscle total force vector.
        Fmuscle_total_secondary = Fmuscle_total_mag_secondary*Fmuscle_total_dir_secondary;
        
        % Compute the torque contributed to the joint by the secondary muscle.
        tau_secondary = norm(cross(r_secondary, Fmuscle_total_secondary), 2);
        
        % Compute the torque that we need to create with the primary muscle.
        tau_primary = abs(taus(k2, k1)) + tau_secondary;

        % Compute the angle between the primary force line of action and the moment arm.
        phi = vecangle(r_primary, Fmuscle_total_dir_primary);
        
        % Compute the required total force magnitude in the primary muscle.
        Fmuscle_total_mag_primary = tau_primary/(norm(r_primary, 2)*sin(phi));
        
        % Store the required total muscles forces into a matrix.
        Fmuscles_total(muscle_index_primary, k1) = Fmuscle_total_mag_primary;
        Fmuscles_total(muscle_index_secondary, k1) = Fmuscle_total_mag_secondary;
        
    end
end

end

