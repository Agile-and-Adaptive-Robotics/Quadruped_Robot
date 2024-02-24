function [Gna, gsyn_max] = TwoNeuronCPGSubnetwork(R, delta, Gm, dEsyn, Am, Sm, dEm, Ah, Sh, dEh, dEna)

% This function computes the sodium channel conductance and maximum synaptic conductances for a two neuron CPG subnetwork.

% Compute the sodium channel conductance for each half-center neuron.
Gna = TwoNeuronCPGSubnetworkNaConductance(R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna);

% Compute the maximum synaptic conductance for the two half-center neurons.
gsyn_max = TwoNeuronCPGSubnetworkSynConductance(delta, dEsyn, Am, Sm, dEm, Ah, Sh, dEh, dEna, Gna);


end

