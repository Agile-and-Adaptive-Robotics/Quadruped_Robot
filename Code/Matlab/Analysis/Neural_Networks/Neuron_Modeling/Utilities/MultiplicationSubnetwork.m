function [gsyn_maxs, dEsyns] = MultiplicationSubnetwork(R, dEsyn1, dEsyn2)

% This function computes the maximum synaptic conductances and synaptic reversal potentials for a multiplication subnetwork.

% Set the default input arguments.
if nargin < 3, dEsyn1 = 194e-3; end
if nargin < 2, dEsyn2 = 194e-3; end

% Validate the input arguments.
if dEsyn1 <= R, error('The reversal potential of synapse 1 must satisfy: dEs1 > R\n'), end
if dEsyn2 >= 0, error('The reversal potential of synapse 2 must satisfy: dEs1 < 0\n'), end

% Define the synapse gains.
ksyn = 1;

% Define the reversal potential of synapse 3.
dEs3 = dEsyn2;

% Compute the maximum synaptic conductances.
gsyn1 = (ksyn*R/(dEsyn1 - ksyn*R))*(10^(-6));
gsyn2 = -R/dEsyn2;
gsyn3 = gsyn2;

% Store the maximum synaptic conductances and synaptic reversal potentials into arrays.
gsyn_maxs = [gsyn1 gsyn2 gsyn3];
dEsyns = [dEsyn1 dEsyn2 dEs3];

end

