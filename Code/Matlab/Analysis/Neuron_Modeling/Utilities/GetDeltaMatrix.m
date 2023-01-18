function deltas = GetDeltaMatrix(neuron_order, delta_bistable, delta_oscillatory)

% This function computes the delta matrix required to make a multistate CPG oscillate in a specified order.

% Inputs:
    % neuron_order = 1 x num_neurons array that specifies the order in which the multistate CPG should oscillate.
    % delta_bistable = Scalar delta value that describes the steady state voltage to which low neurons should be sent in bistable configurations.
    % delta_oscillatory = Scalar delta value that describes the steady state voltage to which low neurons should be sent in oscillatory configurations.
    
% Outputs:
    % deltas = num_neurons x num_neurons matrix whose ij entry is the delta value that describes the synapse from neuron j to neuron i.

% Compute the number of neurons.
num_neurons = length(neuron_order);

% Initialize the delta matrix to be completely bistable.
deltas = delta_bistable*ones(num_neurons, num_neurons);

% Switch the desired synapses to be oscillatory.
for k = 1:num_neurons
    
    % Compute the index of the next neuron in the chain.
    j = mod(k, num_neurons) + 1;
    
    % Compute the from and to indexes.
    from_index = neuron_order(k);
    to_index = neuron_order(j);
    
    % Set the appropriate synapse to be oscillatory.
    deltas(to_index, from_index) = delta_oscillatory;
    
end

% Zero out the diagonal entries.
deltas(1:(1 + size(deltas, 1)):end) = 0;

end

