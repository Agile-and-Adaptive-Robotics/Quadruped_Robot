function [gsyn_maxs, dEsyns] = SubtractionSubnetwork(R, ksyn, dEs1, dEs2)

% This function computes the synaptic condutances for a subtraction subnetwork.

% Set the default synaptic reversal potentials.
if nargin < 4, dEs2 = -40e-3; end                  % [V] Synaptic Reversal Potential w.r.t Post-Synaptic Neuron Equilibrium Potential.
if nargin < 3, dEs1 = 194e-3; end                  % [V] Synaptic Reversal Potential w.r.t Post-Synaptic Neuron Equilibrium Potential.

% Compute the minimum reversal potential of the first synapse.
dEs1_min = ksyn*R;

% Determine whether the specified reversal potential for the first synapse exceeds the minimum required synapse.
if dEs1 < dEs1_min                  % If the specified synaptic reversal potential for the first synapse is less than the minimum required synaptic reversal potential...
    
    % Throw an error.
    error('Reversal potential of the first synapse must satify: dEs1 > ksyn*R\n')
    
end

% Compute the maximum synaptic condutances.
gsyn1 = ksyn*R/(dEs1 - ksyn*R)*(10^(-6));       % [S] Maximum Synaptic Conductance.
gsyn2 = -(dEs1/dEs2)*gsyn1;                     % [S] Maximum Synaptic Conductance.

% Store the maximum synaptic conductances and synaptic reversal potentials into arrays.
gsyn_maxs = [gsyn1 gsyn2];
dEsyns = [dEsyn1 dEsyn2];

end
