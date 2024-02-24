function [dUs, Gsyns, Ileaks, Isyns, Itotals] = NetworkStepNoNa(Us, Gms, Cms, Rs, gsyn_maxs, dEsyns, Iapp)

% This function computes a single step of a neural network without sodium channels.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
    % Gms = num_neurons x 1 vector of neuron membrane conductances.
    % Cms = num_neurons x 1 vector of neuron membrane capacitances.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
    % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
    % Iapp = num_neurons x 1 vector of applied currents for each neuron.

% Outputs:
    % dUs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
    % Gsyns = num_neurons x num_neurons matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
    % Ileaks = num_neurons x 1 vector of leak currents for each neuron.
    % Isyns = num_neurons x 1 vector of synaptic currents for each neuron.
    % Itotals = num_neurons x 1 vector of total currents for each neuron.
    
% Compute the leak currents.
Ileaks = GetLeakCurrent(Us, Gms);

% Compute synaptic currents.
[Isyns, Gsyns] = GetSynapticCurrents(Us, Rs, gsyn_maxs, dEsyns);

% Compute the total currents.
Itotals = Ileaks + Isyns + Iapp;

% Compute the membrane voltage derivatives.
dUs = Itotals./Cms;

end

