function dT = ForwardHillMuscleStep( T, L, dL, A, kse, kpe, b )

% This function computes a single step of the foward hill muscle simulation.

% Inputs:
    % T = num_muscles x 1 column vector of total muscle tensions.
    % L = num_muscles x 1 column vector of muscle lengths.
    % dL = num_muscles x 1 column vector of muscle velocities.
    % A = num_muscles x 1 column vector of active muscle forces.
    % kse = Series Muscle Stiffness as a num_muscles x 1 column vector.
    % kpe = Parallel Muscle Stiffness as a num_muscles x 1 column vector.
    % b = Damping Coefficient as a num_muscles x 1 column vector.

% Outputs:
    % dT = num_muscles x 1 column vector of rate of change of total muscle force with respect to time.
   
% Compute the rate of change of the total muscle force with respect to time.
dT = (kse./b).*(kpe.*L + b.*dL - (1 + (kpe./kse)).*T + A);


end

