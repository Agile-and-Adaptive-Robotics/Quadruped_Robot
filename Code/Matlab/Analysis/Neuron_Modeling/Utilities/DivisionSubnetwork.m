function [gsyn_maxs, dEsyns] = DivisionSubnetwork(R, csyn, dEsyn1)

% This function computes the maximum synaptic conductances for a division subnetwork.

% Set the default input arguments.
if nargin < 3, dEsyn1 = 194e-3; end

% Validate the input arguments.
if dEsyn1 <= R, error('Synaptic reversal potential for synapse 1 must satisfy: dEs1 > R.\n'), end
if (csyn <= 0) || (csyn >= 1), error('The division constant must satisfy: 0 < csyn < 1.\n'), end

% Set the synaptic gains.
ksyn1 = 1; ksyn2 = csyn;

% Set the synaptic reversal potential of the second synapse.
dEs2 = 0;

% Compute the maximum synpatic condutances.
gsyn1 = ksyn1*R/(dEsyn1 - ksyn1*R)*(10^(-6));       % [S] Maximum Synaptic Conductance.
gsyn2 = ksyn2*R/(dEs2 - ksyn2*R)*(10^(-6));       % [S] Maximum Synaptic Conductance.

% Store the maximum synaptic conductances and synaptic reversal potentials into arrays.
gsyn_maxs = [gsyn1 gsyn2];
dEsyns = [dEsyn1 dEsyn2];

end

