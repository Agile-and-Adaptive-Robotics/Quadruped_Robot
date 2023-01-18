function Us = GetInvSteadyStateNaActDeactValue(mhinfs, Amhs, Smhs, dEmhs)

% This function computes the membrane voltage at which a specified steady state Na channel activation / deactivation parameter value is achieved.

% Validate the input.
if any(mhinfs <= 0) || any(mhinfs >= 1)      % If any of the provided minf or hinf values are out of bounds...
   
    % Throw an error.
    error('minf, hinf values must be in (0, 1).\n')
    
end

% Compute the membrane voltage at which the desired steady state Na Channel Activation / Deactivation parameter value is achieved.
Us = (1./Smhs).*log( (1 - mhinfs)./(Amhs.*mhinfs) ) + dEmhs;


end

