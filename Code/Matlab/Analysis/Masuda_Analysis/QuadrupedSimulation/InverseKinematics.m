function [thetas, successes] = InverseKinematics(Ss, M, Ts, theta_guess, eomg, ev)

% This function computes the inverse kinematics s

% Retrieve size information from the inputs.
num_dof = size(Ss, 2);
num_timesteps = size(Ts, 5);

% Define a small amount of noise to apply to perturb the theta guess values.
theta_noise_mag = 2*pi/100;

% Define the number of inverse kinematic solution attempts to make before moving on.
max_attempts = 10;

% Initialize an array to store the required angles.
thetas = zeros(num_dof, num_timesteps);

% Initialize an array to store whether the
successes = zeros(1, num_timesteps);

% Compute the inverse kinematics solution for each time step.
for k = 1:num_timesteps                 % Iterate through each of the time steps.
    
    % Define the current attempt number.
    attempt_number = 1;
    
    % Attempt the inverse kinematics solution a maximum number of times using different initial conditions.
    while (~successes(k)) && (attempt_number <= max_attempts)                % While the inverse kinematics solution has not been successful and the number of attempts is still less than or equal to the maximum allowable number of attempts.
        
        % Compute the inverse kinematics solution at this time step.
        [thetas(:, k), successes(k)] = IKinSpace(Ss, M, Ts(:, :, 1, 1, k), theta_guess, eomg, ev);
        
        % Perturb the theta guess value.
        theta_guess = theta_guess + theta_noise_mag*rand(num_dof, 1);
        
        % Advance the attempt counter.
        attempt_number = attempt_number + 1;
        
    end
    
    % Determine how to update the necessary joint angles if an inverse kinematics solution was not achieved.
    if ~successes(k)            % If an inverse kinematics solution was not achieved...
        
        % Determine how to update the necessary joint angles.
        if k ~= 1           % If this is not the first iteration...
            
            % Set the current joint angle to be the same as the last.
            thetas(:, k) = thetas(:, k - 1);
            
        else                % Otherwise...
            
            % Set the current joint angle to zero.
            thetas(:, k) = zeros(num_dof, 1);
            
        end
        
    end
    
    % Update the theta guess value to be the most recent value.
    theta_guess = thetas(:, k);
    
end

% Determine whether there were any convergence failures.
if ~all(successes)              % If not all of the inverse kinematics solutions were successful...
    
    % Throw a warning if at least one of the desired points did not converge.
    warning('At least one solution to the inverse kinematics problem could not be found\n')
    
end

end

