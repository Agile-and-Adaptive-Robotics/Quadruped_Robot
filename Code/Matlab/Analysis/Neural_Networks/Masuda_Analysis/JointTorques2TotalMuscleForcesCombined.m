function Fmuscles_total = JointTorques2TotalMuscleForces( taus, Pmuscles, Pjoints, muscle_joint_orientations, Fmuscles_total_lowbnd )

% This function computes the total muscle muscles necessary to achieve the specified joint torques, given the the current position of the muscle attachment points and joints, the muscle / joint orientations, and the minimum acceptable muscle force.

% to do: make sure that muscle attachment points of biarticular muscles
%        update with the position of lower joints

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

% set the proportion of joint torque that should be assigned to the
% biarticular muscles
biarticular_weighting_factor = 0.5;

% initialize torque variables
hip_torque = 0;
knee_torque = 0;
ankle_torque = 0;

% MA hip extensor index   1
% MA hip flexor index     2
% MA knee extensor index  3
% MA knee flexor index    4
% MA ankle extensor index 5
% MA ankle flexor index   6
% BA hip extensor index   7
% BA hip flexor index     8
% BA ankle flexor index   9
% MA hip abductor index   10
% MA hip adductor index   11

% Ensure that there are the correct number of muscles.
if num_muscles ~= 11         % there should be six monoarticular muscles and three biarticular muscles
   
    % Throw an error stating that we have a wrong number of muscles
    error('The current muscle tension calculation algorithm is designed for exactly nine muscles.\n')
    
end

% Initialize a variable to store the desired total muscle forces.
Fmuscles_total = zeros(num_muscles, num_timesteps);

% Compute the force required in each muscle.
for time_index = 1:num_timesteps                % Iterate through each time step...
    
    hip_torque = taus(1, time_index);
    knee_torque = taus(2, time_index);
    ankle_torque = taus(3, time_index);
    
    % find forces for hip muscles including BA muscles
    
    % hip positive direction is extension
    if hip_torque >= 0
       % hip rotation is positive
       muscle_index_primary_MA = 1; % MA hip extensor
       muscle_index_primary_BA = 7; % BA hip extensor
       muscle_index_secondary_MA = 2; % MA hip flexor
       muscle_index_secondary_BA = 8; % BA hip flexor
    else
        % hip rotation is negative
        muscle_index_primary_MA = 2; % MA hip flexor
        muscle_index_primary_BA = 8; % BA hip flexor
        muscle_index_secondary_MA = 1; % MA hip extensor
        muscle_index_secondary_BA = 7; % BA hip extensor
    end   

    
    % Compute the moment arm for each muscle.
    r_primary_MA = Pmuscles(:, 3, muscle_index_primary_MA, time_index) - Pjoints(:, 1, 1, time_index);
    r_secondary_MA = Pmuscles(:, 3, muscle_index_secondary_MA, time_index) - Pjoints(:, 1, 1, time_index);   
    r_primary_BA = Pmuscles(:, 3, muscle_index_primary_BA, time_index) - Pjoints(:, 1, 1, time_index);
    r_secondary_BA = Pmuscles(:, 3, muscle_index_secondary_BA, time_index) - Pjoints(:, 1, 1, time_index);
    
    % Compute the direction of the total forces applied by the primary & secondary muscles.
    Fmuscle_total_dir_primary_MA = (Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index));
    Fmuscle_total_dir_secondary_MA = (Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index));
    Fmuscle_total_dir_primary_BA = (Pmuscles(:, 2, muscle_index_primary_BA, time_index) - Pmuscles(:, 3, muscle_index_primary_BA, time_index))./norm(Pmuscles(:, 2, muscle_index_primary_BA, time_index) - Pmuscles(:, 3, muscle_index_primary_BA, time_index));
    Fmuscle_total_dir_secondary_BA = (Pmuscles(:, 2, muscle_index_secondary_BA, time_index) - Pmuscles(:, 3, muscle_index_secondary_BA, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary_BA, time_index) - Pmuscles(:, 3, muscle_index_secondary_BA, time_index));
            
    % Set the secondary muscles to have the minimum allowable total force magnitude.
    Fmuscle_total_mag_secondary_MA = Fmuscles_total_lowbnd(muscle_index_secondary_MA);
    Fmuscle_total_mag_secondary_BA = Fmuscles_total_lowbnd(muscle_index_secondary_BA);
    
    % Compute the secondary muscle total force vectors.
    Fmuscle_total_secondary_MA = Fmuscle_total_mag_secondary_MA*Fmuscle_total_dir_secondary_MA;
    Fmuscle_total_secondary_BA = Fmuscle_total_mag_secondary_BA*Fmuscle_total_dir_secondary_BA;    
    
    
    % Compute the torque contributed to the joint by the secondary muscles.
    tau_secondary_MA = norm(cross(r_secondary_MA, Fmuscle_total_secondary_MA), 2);
    tau_secondary_BA = norm(cross(r_secondary_BA, Fmuscle_total_secondary_BA), 2);
    tau_secondary = tau_secondary_MA + tau_secondary_BA;
    
    
    % find needed forward torque
    tau_primary = abs(taus(1, time_index)) + tau_secondary;   
       
    % split torque between MA and BA muscles
    tau_primary_MA = tau_primary * (1 - biarticular_weighting_factor);
    tau_primary_BA = tau_primary * biarticular_weighting_factor;
    
    % Compute the angles between the primary force lines of action and the moment arms.
    phi_MA = vecangle(r_primary_MA, Fmuscle_total_dir_primary_MA);
    phi_BA = vecangle(r_primary_BA, Fmuscle_total_dir_primary_BA);
    
    % Compute the required total force magnitude in the primary muscles.
    Fmuscle_total_mag_primary_MA = tau_primary_MA/(norm(r_primary_MA, 2)*sin(phi_MA));    
    Fmuscle_total_mag_primary_BA = tau_primary_BA/(norm(r_primary_BA, 2)*sin(phi_BA));
    
    % Store the required total muscles forces into a matrix.
    Fmuscles_total(muscle_index_primary_MA, time_index) = Fmuscle_total_mag_primary_MA;
    Fmuscles_total(muscle_index_secondary_MA, time_index) = Fmuscle_total_mag_secondary_MA;
    Fmuscles_total(muscle_index_primary_BA, time_index) = Fmuscle_total_mag_primary_BA;
    Fmuscles_total(muscle_index_secondary_BA, time_index) = Fmuscle_total_mag_secondary_BA;
    
    % we naively assume that the torque on the knee joint from the
    % biarticular actuators will be the same as the torque on the hip joint
    % from the biarticular actuators
    cascade_torque = tau_secondary_BA + tau_primary_BA;
    
    % We have now found the forces for all four muscles involved in the
    % motion of the hip. Finding the forces for the knee muscles will be
    % similar except that the tension in the biarticular hip/knee muscles
    % has already been determined, and also that they apply some torque to
    % the knee joint which must be accounted for in determining the torque
    % that the knee muscles and biarticular ankle flexor must supply
    
    % knee positive direction is the opposite of hip positive
    % so inverting the sign of the cascade torque and subtracting works out
    % to adding
    % adjust knee torque to *net* torque after accounting for cascade
    % torque
    knee_torque = knee_torque + cascade_torque;
    
    
    % knee positive direction is flexion
    if knee_torque >= 0
       % knee rotation is positive
       muscle_index_primary_MA = 4; % MA knee flexor
       muscle_index_primary_BA = 9; % BA ankle flexor
       muscle_index_secondary_MA = 3; % MA knee extensor
       
       % Compute the moment arm for each muscle.
       r_primary_MA = Pmuscles(:, 3, muscle_index_primary_MA, time_index) - Pjoints(:, 1, 1, time_index);
       r_secondary_MA = Pmuscles(:, 3, muscle_index_secondary_MA, time_index) - Pjoints(:, 1, 1, time_index);   
       r_primary_BA = Pmuscles(:, 3, muscle_index_primary_BA, time_index) - Pjoints(:, 1, 1, time_index);
    
       % Compute the direction of the total forces applied by the primary & secondary muscles.
       Fmuscle_total_dir_primary_MA = (Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index));
       Fmuscle_total_dir_secondary_MA = (Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index));
       Fmuscle_total_dir_primary_BA = (Pmuscles(:, 2, muscle_index_primary_BA, time_index) - Pmuscles(:, 3, muscle_index_primary_BA, time_index))./norm(Pmuscles(:, 2, muscle_index_primary_BA, time_index) - Pmuscles(:, 3, muscle_index_primary_BA, time_index));
            
       % Set the secondary muscles to have the minimum allowable total force magnitude.
       Fmuscle_total_mag_secondary_MA = Fmuscles_total_lowbnd(muscle_index_secondary_MA);
    
       % Compute the secondary muscle total force vectors.
       Fmuscle_total_secondary_MA = Fmuscle_total_mag_secondary_MA*Fmuscle_total_dir_secondary_MA;    
    
    
       % Compute the torque contributed to the joint by the secondary muscles.
       tau_secondary = norm(cross(r_secondary_MA, Fmuscle_total_secondary_MA), 2);    
    
       % find needed forward torque
       tau_primary = abs(taus(1, time_index)) + tau_secondary;   
       
       % split torque between MA and BA muscles
       tau_primary_MA = tau_primary * (1 - biarticular_weighting_factor);
       tau_primary_BA = tau_primary * biarticular_weighting_factor;
    
       % Compute the angles between the primary force lines of action and the moment arms.
       phi_MA = vecangle(r_primary_MA, Fmuscle_total_dir_primary_MA);
       phi_BA = vecangle(r_primary_BA, Fmuscle_total_dir_primary_BA);
    
       % Compute the required total force magnitude in the primary muscles.
       Fmuscle_total_mag_primary_MA = tau_primary_MA/(norm(r_primary_MA, 2)*sin(phi_MA));    
       Fmuscle_total_mag_primary_BA = tau_primary_BA/(norm(r_primary_BA, 2)*sin(phi_MA));
    
       % Store the required total muscles forces into a matrix.
       Fmuscles_total(muscle_index_primary_MA, time_index) = Fmuscle_total_mag_primary_MA;
       Fmuscles_total(muscle_index_secondary_MA, time_index) = Fmuscle_total_mag_secondary_MA;
       Fmuscles_total(muscle_index_primary_BA, time_index) = Fmuscle_total_mag_primary_BA;
       
       % again assuming that biarticular torque is the same in both
       % affected joints
       cascade_torque = tau_primary_BA;

    else
        % knee rotation is negative, i.e. extension
        muscle_index_primary_MA = 3; % MA knee extensor
        muscle_index_secondary_MA = 4; % MA knee flexor
        muscle_index_secondary_BA = 9; % BA ankle flexor
        
        % Compute the moment arm for each muscle.
        r_primary_MA = Pmuscles(:, 3, muscle_index_primary_MA, time_index) - Pjoints(:, 1, 1, time_index);
        r_secondary_MA = Pmuscles(:, 3, muscle_index_secondary_MA, time_index) - Pjoints(:, 1, 1, time_index);   
        r_secondary_BA = Pmuscles(:, 3, muscle_index_secondary_BA, time_index) - Pjoints(:, 1, 1, time_index);
    
        % Compute the direction of the total forces applied by the primary & secondary muscles.
        Fmuscle_total_dir_primary_MA = (Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_primary_MA, time_index) - Pmuscles(:, 3, muscle_index_primary_MA, time_index));
        Fmuscle_total_dir_secondary_MA = (Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary_MA, time_index) - Pmuscles(:, 3, muscle_index_secondary_MA, time_index));
        Fmuscle_total_dir_secondary_BA = (Pmuscles(:, 2, muscle_index_secondary_BA, time_index) - Pmuscles(:, 3, muscle_index_secondary_BA, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary_BA, time_index) - Pmuscles(:, 3, muscle_index_secondary_BA, time_index));
            
        % Set the secondary muscles to have the minimum allowable total force magnitude.
        Fmuscle_total_mag_secondary_MA = Fmuscles_total_lowbnd(muscle_index_secondary_MA);
        Fmuscle_total_mag_secondary_BA = Fmuscles_total_lowbnd(muscle_index_secondary_BA);
    
        % Compute the secondary muscle total force vectors.
        Fmuscle_total_secondary_MA = Fmuscle_total_mag_secondary_MA*Fmuscle_total_dir_secondary_MA;
        Fmuscle_total_secondary_BA = Fmuscle_total_mag_secondary_BA*Fmuscle_total_dir_secondary_BA;    
    
    
        % Compute the torque contributed to the joint by the secondary muscles.
        tau_secondary_MA = norm(cross(r_secondary_MA, Fmuscle_total_secondary_MA), 2);
        tau_secondary_BA = norm(cross(r_secondary_BA, Fmuscle_total_secondary_BA), 2);
        tau_secondary = tau_secondary_MA + tau_secondary_BA;
    
    
        % find needed forward torque
        tau_primary = abs(taus(1, time_index)) + tau_secondary;   
       
        % split torque between MA and BA muscles
        % except in this direction there isn't any BA muscle
        tau_primary_MA = tau_primary;
    
        % Compute the angles between the primary force line of action and the moment arm.
        phi_MA = vecangle(r_primary_MA, Fmuscle_total_dir_primary_MA);
    
        % Compute the required total force magnitude in the primary muscle.
        Fmuscle_total_mag_primary_MA = tau_primary_MA/(norm(r_primary_MA, 2)*sin(phi_MA));
    
        % Store the required total muscles forces into a matrix.
        Fmuscles_total(muscle_index_primary_MA, time_index) = Fmuscle_total_mag_primary_MA;
        Fmuscles_total(muscle_index_secondary_MA, time_index) = Fmuscle_total_mag_secondary_MA;
        Fmuscles_total(muscle_index_secondary_BA, time_index) = Fmuscle_total_mag_secondary_BA;
        
        % again assuming that the torque from the biarticular ankle flexor
        % is the same in both affected joints
        cascade_torque = tau_secondary_BA;
    end   
    % we finally arrive at the ankle joint, which has no biarticular
    % actuators to be set. Yes, it's affected by the biarticular ankle
    % flexor, but we account for that with the cascade torque
    joint_number = 3;
    % ankle positive direction is extension
    
    ankle_torque = ankle_torque + cascade_torque;
    if ankle_torque >= 0 % extension
        muscle_index_primary = 5;
        muscle_index_secondary = 6;
    else
        muscle_index_primary = 6;
        muscle_index_secondary = 5;
    end
    % Compute the moment arm for each muscle.
    r_primary = Pmuscles(:, 3, muscle_index_primary, time_index) - Pjoints(:, 1, joint_number, time_index);
    r_secondary = Pmuscles(:, 3, muscle_index_secondary, time_index) - Pjoints(:, 1, joint_number, time_index);

    % Compute the direction of the total forces applied by the primary & secondary muscles.
    Fmuscle_total_dir_primary = (Pmuscles(:, 2, muscle_index_primary, time_index) - Pmuscles(:, 3, muscle_index_primary, time_index))./norm(Pmuscles(:, 2, muscle_index_primary, time_index) - Pmuscles(:, 3, muscle_index_primary, time_index));
    Fmuscle_total_dir_secondary = (Pmuscles(:, 2, muscle_index_secondary, time_index) - Pmuscles(:, 3, muscle_index_secondary, time_index))./norm(Pmuscles(:, 2, muscle_index_secondary, time_index) - Pmuscles(:, 3, muscle_index_secondary, time_index));
        
    % Set the secondary muscle to have the minimum allowable total force magnitude.
    Fmuscle_total_mag_secondary = Fmuscles_total_lowbnd(muscle_index_secondary);
        
    % Compute the secondary muscle total force vector.
    Fmuscle_total_secondary = Fmuscle_total_mag_secondary*Fmuscle_total_dir_secondary;
        
    % Compute the torque contributed to the joint by the secondary muscle.
    tau_secondary = norm(cross(r_secondary, Fmuscle_total_secondary), 2);
        
    % Compute the torque that we need to create with the primary muscle.
    tau_primary = abs(taus(joint_number, time_index)) + tau_secondary;

    % Compute the angle between the primary force line of action and the moment arm.
    phi = vecangle(r_primary, Fmuscle_total_dir_primary);
        
    % Compute the required total force magnitude in the primary muscle.
    Fmuscle_total_mag_primary = tau_primary/(norm(r_primary, 2)*sin(phi));
        
    % Store the required total muscles forces into a matrix.
    Fmuscles_total(muscle_index_primary, time_index) = Fmuscle_total_mag_primary;
    Fmuscles_total(muscle_index_secondary, time_index) = Fmuscle_total_mag_secondary;
    
    
    
    

end % end of loop-over-timesteps loop

end

