function [T, dT] = ForwardHillMuscle(T0, L, dL, A, kse, kpe, b, dt, intRes)

% NOT CURRENTLY USING INTRES, BUT POTENTIALLY NEED TO.

% This function computes the muscle tension and rate of change of the muscle tension over time in a Hill Muscle given an activation and length history.

% Inputs:
% T0 = Initial Muscle Tension as a num_muscles x 1 vector.
% L = Muscle Length as a num_muscles x num_timesteps matrix.
% dL = Muscle Velocity as a num_muscles x num_timesteps matrix.
% A = Muscle Activation as a num_muscles x num_timesteps matrix.
% kse = Series Muscle Stiffness as a num_muscles x 1 column vector.
% kpe = Parallel Muscle Stiffness as a num_muscles x 1 column vector.
% b = Damping Coefficient as a num_muscles x 1 column vector.

% Outputs:
% T = Muscle Tension as a num_muscles x num_timesteps matrix.
% dT = Rate of Change of Muscle Tension Over Time as a num_muscles x num_timesteps matrix.

% % Retrieve size information from the inputs.
% num_muscles = size(L, 1);
% num_timesteps = size(L, 2);
% 
% % Initialize matrices to store the muscle tensions.
% [T, dT] = deal( zeros(num_muscles, num_timesteps) );
% 
% % Set the initial tension.
% T(:, 1) = T0;
% 
% % Compute the muscle tensions & rate of change of muscle tension over time.
% for k = 1:(num_timesteps - 1)
%     
%     % Compute the rate of change of the muscle tension at this time step.
%     %     dT(:, k) = (kse./b).*(kpe.*L(:, k) + b.*dL(:, k) - (1 + (kpe./kse)).*T(:, k) + A(:, k));
%     dT(:, k) = ForwardHillMuscleStep( L(:, k), dL(:, k), A(:, k), kse, kpe, b );
%     
%     % Compute the muscle tension at the next time step.
%     %     T(:, k + 1) = T(:, k) + dt*dT(:, k);
%     T(:, k + 1) = ForwardEulerStep(T(:, k), dT(:, k), dt);
%     
% end
% 
% % Compute the final rate of change of the muscle tension.
% dT(:, k + 1) = (kse/b)*(kpe*L(:, k + 1) + b*dL(:, k + 1) - (1 + (kpe/kse))*T0 + A(:, k + 1));

% Retrieve size information from the inputs.
num_muscles = size(L, 1);
num_timesteps = size(L, 2);

% Initialize matrices to store the muscle tensions.
[T, dT] = deal( zeros(num_muscles, num_timesteps) );

% Set the initial tension.
T(:, 1) = T0;

% Compute the muscle tensions & rate of change of muscle tension over time.
for k = 1:(num_timesteps - 1)              % Iterate through each of the time steps...

    % Integrate the Hill Muscle Model differential equation for the specified number of steps.
    [T(:, k + 1), dT(:, k)] = IntegrateForwardHillMuscle( T(:, k), L(:, k), dL(:, k), A(:, k), kse, kpe, b, dt, intRes );
    
end

% Compute the final rate of change of the muscle tension.
[~, dT(:, k + 1)] = IntegrateForwardHillMuscle( T(:, k + 1), L(:, k + 1), dL(:, k + 1), A(:, k + 1), kse, kpe, b, dt, intRes );


end

