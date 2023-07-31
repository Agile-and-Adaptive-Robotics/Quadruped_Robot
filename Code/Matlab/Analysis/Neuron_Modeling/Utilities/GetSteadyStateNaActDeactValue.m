function mhinfs = GetSteadyStateNaActDeactValue(Us, Amhs, Smhs, dEmhs)

% This function computes the steady state sodium channel activation / deactivation parameter for every neuron in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials for each neuron in the network.
    % Amhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation A parameters.
    % Smhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation S parameters.
    % dEmhs = num_neurons x 1 vector of neuron sodium channel activation / deactivation reversal potential w.r.t thier resting potentials.

% Outputs:
    % mhinfs = num_neurons x 1 vector of neuron steady state sodium channel activation /deactivation values.
    
% Compute the steady state sodium channel activation / deactivation parameter.
mhinfs = 1./(1 + Amhs.*exp(-Smhs.*(dEmhs - Us)));

end

