function [ts, Us, dUs, Gsyns, Ileaks, Isyns, Itotals] = SimulateNetworkNoNa(Us0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Iapps, tf, dt)

% This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, dEsyns with an initial condition of U0 for tf seconds with a step size of dt with an applied current of Iapp.

% Inputs:
    % Us0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
    % Gms = num_neurons x 1 vector of neuron membrane conductances.
    % Cms = num_neurons x 1 vector of neuron membrane capacitances.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
    % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
    % Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.

% Outputs:
    % ts = 1 x num_timesteps vector of the time associated with each simulation step.
    % Us = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
    % dUs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
    % Gsyns = num_neurons x num_neurons x num_neurons tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
    % Ileaks = num_neurons x num_timsteps matrix of neuron leak currents over time.
    % Isyns = num_neurons x num_timesteps matrix of synaptic currents over time.
    % Itotals = num_neurons x num_timesteps matrix of total currents over time.
    
% Retrieve the number of neurons from the input dimensions.
num_neurons = size(Us0, 1);

% Compute the simulation time vector.
ts = 0:dt:tf;

% Compute the number of time steps.
num_timesteps = length(ts);

% Ensure that there are the correct number of applied currents.
if size(Iapps, 2) ~= num_timesteps                  % If the number of Iapps columns is not equal to the number of timesteps...
    
    % Throw an error.
    error('size(Iapps, 2) must equal the number of simulation time steps.\n')
    
end

% Preallocate arrays to store the simulation data.
[Us, dUs, Ileaks, Isyns, Itotals] = deal( zeros(num_neurons, num_timesteps) );

% Preallocate a multidimensional array to store the synaptic conductances.
Gsyns = zeros(num_neurons, num_neurons, num_timesteps);

% Set the initial network condition.
Us(:, 1) = Us0;

% Simulate the network.
for k = 1:(num_timesteps - 1)               % Iterate through each timestep...
    
    % Compute the network state derivatives (as well as other intermediate network values).
    [dUs(:, k), Gsyns(:, :, k), Ileaks(:, k), Isyns(:, k), Itotals(:, k)] = NetworkStepNoNa(Us(:, k), Gms, Cms, Rs, gsyn_maxs, dEsyns, Iapps(:, k));
    
    % Compute the membrane voltage at the next time step.
    Us(:, k + 1) = ForwardEulerStep(Us(:, k), dUs(:, k), dt);
    
end

% Advance the loop counter variable to perform one more network step.
k = k + 1;

% Compute the network state derivatives (as well as other intermediate network values).
[dUs(:, k), Gsyns(:, :, k), Ileaks(:, k), Isyns(:, k), Itotals(:, k)] = NetworkStepNoNa(Us(:, k), Gms, Cms, Rs, gsyn_maxs, dEsyns, Iapps(:, k));


end

