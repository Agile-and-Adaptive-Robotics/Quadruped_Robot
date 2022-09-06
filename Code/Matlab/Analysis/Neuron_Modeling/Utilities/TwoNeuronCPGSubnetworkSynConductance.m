function gsyn_max = TwoNeuronCPGSubnetworkSynConductance(delta, Gm, dEsyn, Am, Sm, dEm, Ah, Sh, dEh, dEna, Gna)

% Compute the steady state sodium channel activation & devactivation parameters at the lower equilibrium.
minf = GetSteadyStateNaActDeactValue(delta, Am, Sm, dEm);
hinf = GetSteadyStateNaActDeactValue(delta, Ah, Sh, dEh);

% Compute the maximum synaptic conductance for the two half-center neurons.
gsyn_max = (-delta*Gm - delta*Gna*minf*hinf + Gna*minf*hinf*dEna)/(delta - dEsyn);           % Equation straight from Szczecinski's CPG example.

end

