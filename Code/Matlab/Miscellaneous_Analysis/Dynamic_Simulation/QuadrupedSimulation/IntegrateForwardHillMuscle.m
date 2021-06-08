function [T, dT] = IntegrateForwardHillMuscle( T0, L, dL, A, kse, kpe, b, dt, intRes )

% Initialize the muscle tension.
T = T0;

% Integrate the forward hill muscle model for the specified number of steps.
for k = 1:intRes                       % Iterate through each of the integration steps...
    
    % Compute the rate of change of the muscle tension at this time step.
    dT = ForwardHillMuscleStep( T, L, dL, A, kse, kpe, b );
    
    % Compute the muscle tension at the next time step.
    T = ForwardEulerStep( T, dT, dt/intRes );
    
end


end

