function [gsyn_maxs, dEsyns] = AdditionSubnetwork(R, ksyn1, ksyn2, dEsyn1, dEsyn2)

% This function computes the synaptic condutances for an addition subnetwork.

% Set the default synaptic reversal potentials.
if nargin < 4, dEsyn2 = 194e-3; end                  % [V] Synaptic Reversal Potential w.r.t Post-Synaptic Neuron Equilibrium Potential.
if nargin < 3, dEsyn1 = 194e-3; end                  % [V] Synaptic Reversal Potential w.r.t Post-Synaptic Neuron Equilibrium Potential.

% Compute the minimum reversal potential of the first synapse.
dEs1_min = ksyn1*R;
dEs2_min = ksyn2*R;

% Validate the input arguments.
if dEsyn1 <= dEs1_min, error('Reversal potential of the first synapse must satify: dEs1 > ksyn1*R\n'), end
if dEsyn2 <= dEs2_min, error('Reversal potential of the second synapse must satify: dEs2 > ksyn2*R\n'), end

% Compute the maximum synaptic conductances.
gsyn1 = ksyn1*R/(dEsyn1 - ksyn1*R)*(10^(-6));       % [S] Maximum Synaptic Conductance.
gsyn2 = ksyn2*R/(dEsyn2 - ksyn2*R)*(10^(-6));       % [S] Maximum Synaptic Conductance.

% Store the maximum synaptic conductances and synaptic reversal potentials into arrays.
gsyn_maxs = [gsyn1 gsyn2];
dEsyns = [dEsyn1 dEsyn2];

end

