function [ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt)

% This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, dEsyns with an initial condition of U0, h0 for tf seconds with a step size of dt and an applied current of Iapp.

% Inputs:
    % Us0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
    % hs0 = num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
    % Gms = num_neurons x 1 vector of neuron membrane conductances.
    % Cms = num_neurons x 1 vector of neuron membrane capacitances.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
    % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
    % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
    % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
    % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
    % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
    % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
    % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
    % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
    % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
    % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
    % Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.
    % tf = Scalar that represents the simulation duration.
    % dt = Scalar that represents the simulation time step.

% Outputs:
    % ts = 1 x num_timesteps vector of the time associated with each simulation step.
    % Us = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
    % hs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
    % dUs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
    % dhs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameter derivatives.
    % Gsyns = num_neurons x num_neurons x num_neurons tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
    % Ileaks = num_neurons x num_timsteps matrix of neuron leak currents over time.
    % Isyns = num_neurons x num_timesteps matrix of synaptic currents over time.
    % Inas = num_neurons x num_timesteps matrix of sodium channel currents for each neuron.
    % Itotals = num_neurons x num_timesteps matrix of total currents for each neuron.
    % minfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel activation values.
    % hinfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel deactivation values.
    % tauhs = num_neurons x num_timesteps matrix of sodium channel deactivation parameter time constants.

% Compute the simulation time vector.
ts = 0:dt:tf;

% Compute the number of time steps.
num_timesteps = length(ts);

% Ensure that there are the correct number of applied currents.
if size(Iapps, 2) ~= num_timesteps                  % If the number of Iapps columns is not equal to the number of timesteps...
    
    % Throw an error.
    error('size(Iapps, 2) must equal the number of simulation time steps.\n')
    
end

% Retrieve the number of neurons from the input dimensions.
num_neurons = size(Us0, 1);

% Preallocate arrays to store the simulation data.
[Us, hs, dUs, dhs, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = deal( zeros(num_neurons, num_timesteps) );

% Preallocate a multidimensional array to store the synaptic conductances.
Gsyns = zeros(num_neurons, num_neurons, num_timesteps);

% Set the initial network condition.
Us(:, 1) = Us0; hs(:, 1) = hs0;

% Simulate the network.
for k = 1:(num_timesteps - 1)               % Iterate through each timestep...
    
    % Compute the network state derivatives (as well as other intermediate network values).
    [dUs(:, k), dhs(:, k), Gsyns(:, :, k), Ileaks(:, k), Isyns(:, k), Inas(:, k), Itotals(:, k), minfs(:, k), hinfs(:, k), tauhs(:, k)] = NetworkStep(Us(:, k), hs(:, k), Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps(:, k));
    
    % Compute the membrane voltages at the next time step.
    Us(:, k + 1) = ForwardEulerStep(Us(:, k), dUs(:, k), dt);
    
    % Compute the sodium channel deactivation parameters at the next time step.
    hs(:, k + 1) = ForwardEulerStep(hs(:, k), dhs(:, k), dt);
    
end

% Advance the loop counter variable to perform one more network step.
k = k + 1;

% Compute the network state derivatives (as well as other intermediate network values).
[dUs(:, k), dhs(:, k), Gsyns(:, :, k), Ileaks(:, k), Isyns(:, k), Inas(:, k), Itotals(:, k), minfs(:, k), hinfs(:, k), tauhs(:, k)] = NetworkStep(Us(:, k), hs(:, k), Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps(:, k));


end

