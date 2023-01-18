function U = ForwardEulerStep(U, dU, dt)

% This function performs a single forward Euler step.

% Estimate the simulation states at the next time step.
U = U + dt*dU;

end

