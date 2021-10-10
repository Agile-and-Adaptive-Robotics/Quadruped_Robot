function Ileaks = GetLeakCurrent(Us, Gms)

% This function computes the leak current associated with each neuron in a network.

% Inputs:
    % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
    % Gms = num_neurons x 1 vector of neuron membrane conductances.

% Outputs:
    % Ileaks = num_neurons x 1 vector of the leak current associated with each neuron in the network.
    
% Compute the leak current associated with each neuron.
Ileaks = -Gms.*Us;


end

