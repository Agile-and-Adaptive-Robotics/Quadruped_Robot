function Gsyns = GetSynapticCondutances(Us, Rs, gsyn_maxs)

% This function computes the synaptic condutance associated with each synapse in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
    % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
    % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.

% Outputs:
    % Gsyns = num_neurons x num_neurons matrix of synapse conductances over time.  The ijkentry represens the synaptic condutance from neuron j to neuron i.
    
% Compute the synaptic conductance associated with each synapse in the network.
Gsyns = gsyn_maxs.*(min( max( Us'./Rs, 0 ), 1 ));

end

