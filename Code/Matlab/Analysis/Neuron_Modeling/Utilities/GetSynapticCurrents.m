function [Isyns, Gsyns] = GetSynapticCurrents(Us, Rs, gsyn_maxs, dEsyns)

% This function computes the synaptic current associated with each neuron in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
    % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
    
% Outputs:
    % Isyns = num_neurons x 1 vector of synaptic currents for each neuron in the network.
    % Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.

% Compute the synaptic conductances of each synapse in the network.
Gsyns = GetSynapticCondutances(Us, Rs, gsyn_maxs);

% Compute the synaptic current for each neuron.
Isyns = sum(Gsyns.*( dEsyns - Us ), 2);


end

