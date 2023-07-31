function A = InverseHillMuscle(T, dT, L, dL, kse, kpe, b)

% This function computes the muscle activation, A, of a Hill Muscle given muscle parameters & the length / tension history of the muscle.

% Inputs:
    % T = Muscle Tension as a num_muscles x num_timesteps matrix.
    % dT = Rate of Change of Muscle Tension Over Time as a num_muscles x num_timesteps matrix.
    % L = Muscle Length as a num_muscles x num_timesteps matrix.
    % dL = Muscle Velocity as a num_muscles x num_timesteps matrix.
    % kse = Series Muscle Stiffness.
    % kpe = Parallel Muscle Stiffness.
    % b = Damping Coefficient.

% Outputs:
    % A = Muscle Activation.
    
% Compute the muscle activation.
A = (b./kse).*dT + (1 + (kpe./kse)).*T - b.*dL - kpe.*L;

end

