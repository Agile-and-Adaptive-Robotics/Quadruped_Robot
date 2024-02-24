function Gna = TwoNeuronCPGSubnetworkNaConductance(R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna)

% Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
minf = GetSteadyStateNaActDeactValue(R, Am, Sm, dEm);
hinf = GetSteadyStateNaActDeactValue(R, Ah, Sh, dEh);

% Compute the sodium channel conductance for each half-center neuron.
Gna = (Gm.*R)./(minf.*hinf.*(dEna - R));       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

end

