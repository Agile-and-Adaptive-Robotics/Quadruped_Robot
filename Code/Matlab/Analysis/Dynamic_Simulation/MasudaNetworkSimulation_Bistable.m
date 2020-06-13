%% Masuda Network Simulation

% This script simulates a non-spiking neural network that attempts to implement the reflexes discussed in Masuda et al.

% Notes:
    % All units are in standard SI units.  i.e., voltages in Volts, capacitances in Farads, conductances in Siemens, etc.  NOT mV, nF, uS, etc.
    % Neurons 1, 2, 3, 4 are motor neurons (Neurons 1, 2, 3, 4 do NOT have sodium channels).  Neurons 5 & 7 form a 2 neuron CPG and neurons 6 & 8 form a 2 neuron CPG (Neurons 5, 6, 7, 8 have sodum channels).
    % For the purpose of Matlab calculations, neurons 5, 6, 7, 8 use sodium channels.  In Animatlab, these same neurons use calcium channels.  Hence, when printing parameters for Animatlab, values refer to calcium channels.
    
% Clear Everything.
clear, close('all'), clc


%% Define Neuron Properties.

% Note that most of the neurons have the same universal properties, but each neuron's properties are still set individually to allow for future variation if it becomes necessary.

% Define the number of neurons.
num_neurons = 8;                                                                                        % [#] Number of Neurons in the Network.

% Define universal neuron properties.
Cm = 5e-9;                                                                                          % [F] Membrane Capacitance.
Gm = 1e-6;                                                                                          % [S] Membrane Conductance.
Er = -60e-3;                                                                                        % [V] Membrane Resting (Equilibrium) Potential.
R = 20e-3;                                                                                          % [V] Biphasic Equilibrium Voltage Range.
Am = 1;                                                                                             % [-] Sodium Channel Activation Parameter A.
Sm = -50;                                                                                           % [-] Sodium Channel Activation Parametter S.
dEm = 2*R;                                                                                            % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah = 0.5;                                                                                             % [-] Sodium Channel Deactivation Parameter A.
Sh = 50;                                                                                            % [-] Sodium Channel Deactivation Parameter S.
dEh = 0;                                                                                            % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna = 110e-3;                                                                                      % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh_max = 0.250;                                                                                   % [s] Maximum Sodium Channel Deactivation Time Constant.

% Define Hip Extensor Motor Neuron Properties (Neuron 1).
Cm1 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm1 = Gm;                                                                                             % [S] Membrane Conductance.
Er1 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R1 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am1 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm1 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm1 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm1, Smidm1] = GetAnimatlabmhinfProperties(Am1, Sm1, dEm1);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah1 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh1 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh1 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh1, Smidh1] = GetAnimatlabmhinfProperties(Ah1, Sh1, dEh1);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna1 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh1_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna1 = 0;                                                                                               % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Hip Flexor Motor Neuron Properties (Neuron 2).
Cm2 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm2 = Gm;                                                                                             % [S] Membrane Conductance.
Er2 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R2 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am2 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm2 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm2 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm2, Smidm2] = GetAnimatlabmhinfProperties(Am2, Sm2, dEm2);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah2 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh2 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh2 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh2, Smidh2] = GetAnimatlabmhinfProperties(Ah2, Sh2, dEh2);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna2 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh2_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna2 = 0;                                                                                               % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Knee Extensor Motor Neuron Properties (Neuron 3).
Cm3 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm3 = Gm;                                                                                             % [S] Membrane Conductance.
Er3 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R3 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am3 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm3 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm3 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm3, Smidm3] = GetAnimatlabmhinfProperties(Am3, Sm3, dEm3);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah3 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh3 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh3 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh3, Smidh3] = GetAnimatlabmhinfProperties(Ah3, Sh3, dEh3);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna3 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh3_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna3 = 0;                                                                                               % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Knee Flexor Motor Neuron Properties (Neuron 4).
Cm4 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm4 = Gm;                                                                                             % [S] Membrane Conductance.
Er4 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R4 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am4 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm4 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm4 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm4, Smidm4] = GetAnimatlabmhinfProperties(Am4, Sm4, dEm4);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah4 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh4 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh4 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh4, Smidh4] = GetAnimatlabmhinfProperties(Ah4, Sh4, dEh4);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna4 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh4_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna4 = 0;                                                                                               % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Hip Feedback Neuron Properties (Neuron 5).
Cm5 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm5 = Gm;                                                                                             % [S] Membrane Conductance.
Er5 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R5 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am5 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm5 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm5 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm5, Smidm5] = GetAnimatlabmhinfProperties(Am5, Sm5, dEm5);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah5 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh5 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh5 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh5, Smidh5] = GetAnimatlabmhinfProperties(Ah5, Sh5, dEh5);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna5 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh5_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna5 = TwoNeuronCPGSubnetworkNaConductance(R5, Gm5, Am5, Sm5, dEm5, Ah5, Sh5, dEh5, dEna5);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Knee Feedback Neuron Properties (Neuron 6).
Cm6 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm6 = Gm;                                                                                             % [S] Membrane Conductance.
Er6 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R6 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am6 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm6 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm6 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm6, Smidm6] = GetAnimatlabmhinfProperties(Am6, Sm6, dEm6);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah6 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh6 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh6 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh6, Smidh6] = GetAnimatlabmhinfProperties(Ah6, Sh6, dEh6);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna6 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh6_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna6 = TwoNeuronCPGSubnetworkNaConductance(R6, Gm6, Am6, Sm6, dEm6, Ah6, Sh6, dEh6, dEna6);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Hip Bistable Interneuron Properties (Neuron 7).
Cm7 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm7 = Gm;                                                                                             % [S] Membrane Conductance.
Er7 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R7 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am7 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm7 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm7 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm7, Smidm7] = GetAnimatlabmhinfProperties(Am7, Sm7, dEm7);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah7 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh7 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh7 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh7, Smidh7] = GetAnimatlabmhinfProperties(Ah7, Sh7, dEh7);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna7 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh7_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna7 = TwoNeuronCPGSubnetworkNaConductance(R7, Gm7, Am7, Sm7, dEm7, Ah7, Sh7, dEh7, dEna7);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define Knee Bistable Intereuron Properties (Neuron 8).
Cm8 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm8 = Gm;                                                                                             % [S] Membrane Conductance.
Er8 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R8 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am8 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm8 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm8 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
[Umidm8, Smidm8] = GetAnimatlabmhinfProperties(Am8, Sm8, dEm8);                                         % [V, 1/V] Steady State Sodium Channel Activation Midpoint, Steady State Sodium Channel Activation Midpoint Slope.
Ah8 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh8 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh8 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
[Umidh8, Smidh8] = GetAnimatlabmhinfProperties(Ah8, Sh8, dEh8);                                         % [V, 1/V] Steady State Sodium Channel Deactivation Midpoint, Steady State Sodium Channel Deactivation Midpoint Slope.
dEna8 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh8_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna8 = TwoNeuronCPGSubnetworkNaConductance(R8, Gm8, Am8, Sm8, dEm8, Ah8, Sh8, dEh8, dEna8);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)


% Store the neuron properties into arrays.
Cms = [Cm1; Cm2; Cm3; Cm4; Cm5; Cm6; Cm7; Cm8];
Gms = [Gm1; Gm2; Gm3; Gm4; Gm5; Gm6; Gm7; Gm8];
Ers = [Er1; Er2; Er3; Er4; Er5; Er6; Er7; Er8];
Rs = [R1; R2; R3; R4; R5; R6; R7; R8]; Rs = repmat(Rs', [num_neurons, 1]);
Ams = [Am1; Am2; Am3; Am4; Am5; Am6; Am7; Am8];
Sms = [Sm1; Sm2; Sm3; Sm4; Sm5; Sm6; Sm7; Sm8];
dEms = [dEm1; dEm2; dEm3; dEm4; dEm5; dEm6; dEm7; dEm8];
Umidms = [Umidm1; Umidm2; Umidm3; Umidm4; Umidm5; Umidm6; Umidm7; Umidm8];
Smidms = [Smidm1; Smidm2; Smidm3; Smidm4; Smidm5; Smidm6; Smidm7; Smidm8];
Ahs = [Ah1; Ah2; Ah3; Ah4; Ah5; Ah6; Ah7; Ah8];
Shs = [Sh1; Sh2; Sh3; Sh4; Sh5; Sh6; Sh7; Sh8];
dEhs = [dEh1; dEh2; dEh3; dEh4; dEh5; dEh6; dEh7; dEh8];
Umidhs = [Umidh1; Umidh2; Umidh3; Umidh4; Umidh5; Umidh6; Umidh7; Umidh8];
Smidhs = [Smidh1; Smidh2; Smidh3; Smidh4; Smidh5; Smidh6; Smidh7; Smidh8];
dEnas = [dEna1; dEna2; dEna3; dEna4; dEna5; dEna6; dEna7; dEna8];
tauh_maxs = [tauh1_max; tauh2_max; tauh3_max; tauh4_max; tauh5_max; tauh6_max; tauh7_max; tauh8_max];
Gnas = [Gna1; Gna2; Gna3; Gna4; Gna5; Gna6; Gna7; Gna8];


%% Define Applied Current Magnitudes.

% Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

% Compute the necessary applied current magnitudes.
Iapp1 = 0;                     % [A] Applied Current.
Iapp2 = Gm2*R2;                % [A] Applied Current.
Iapp3 = 0;                     % [A] Applied Current.
Iapp4 = Gm4*R4;                % [A] Applied Current.
Iapp5 = Gm5*R5;                % [A] Applied Current.
Iapp6 = Gm6*R6;                % [A] Applied Current.
Iapp7 = Gm7*R7;                % [A] Applied Current.
Iapp8 = Gm8*R8;                % [A] Applied Current.     


%% Define Synapse Properties.

% Define the Bistable CPG subnetwork bifurcation parameters.

% Use these to create faster oscillation.
% delta57 = 1.0e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.
% delta68 = 1.0e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

% Use these to create slower oscillation.
% delta57 = 0.01e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.
% delta68 = 0.01e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

% Use these to produce a barely bistable result.
delta57 = -0.01e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.
delta68 = -0.01e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

% Use these to produce a more strongly bistable result.
% delta57 = -1.0e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.
% delta68 = -1.0e-3;          % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

% Define synapse reversal potentials.
dEsyn61 = 2*R1;              % [V] Synapse Reversal Potential.
dEsyn64 = -2*R4;             % [V] Synapse Reversal Potential.
dEsyn52 = -2*R2;             % [V] Synapse Reversal Potential.
dEsyn53 = 2*R3;              % [V] Synapse Reversal Potential.

% Use these to match Szczecinski's CPG example.
% dEsyn57 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn75 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn68 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn86 = -40e-3;            % [V] Synapse Reversal Potential.

% Use these to match Hunt's Rat example.
dEsyn57 = -40e-3;            % [V] Synapse Reversal Potential.
dEsyn75 = -40e-3;            % [V] Synapse Reversal Potential.
dEsyn68 = -40e-3;            % [V] Synapse Reversal Potential.
dEsyn86 = -40e-3;            % [V] Synapse Reversal Potential.


% Compute the synapse conductances.
gsyn61_max = Gm1*R1/(dEsyn61 - R1);
gsyn64_max = -Iapp4/dEsyn64;
gsyn52_max = -Iapp2/dEsyn52;
gsyn53_max = Gm3*R3/(dEsyn53 - R3);
gsyn57_max = TwoNeuronCPGSubnetworkSynConductance(delta57, Gm5, dEsyn57, Am5, Sm5, dEm5, Ah5, Sh5, dEh5, dEna5, Gna5);
gsyn75_max = gsyn57_max;
gsyn68_max = TwoNeuronCPGSubnetworkSynConductance(delta68, Gm6, dEsyn68, Am6, Sm6, dEm6, Ah6, Sh6, dEh6, dEna6, Gna6);
gsyn86_max = gsyn68_max;

% Store the synapse reversal potentials into a matrix.
dEsyns = zeros(num_neurons, num_neurons);
dEsyns(1, 6) = dEsyn61;
dEsyns(4, 6) = dEsyn64;
dEsyns(2, 5) = dEsyn52;
dEsyns(3, 5) = dEsyn53;
dEsyns(7, 5) = dEsyn57;
dEsyns(5, 7) = dEsyn75;
dEsyns(8, 6) = dEsyn68;
dEsyns(6, 8) = dEsyn86;

% Store the maximum synaptic conductances into a matrix.
gsyn_maxs = zeros(num_neurons, num_neurons);
gsyn_maxs(1, 6) = gsyn61_max;
gsyn_maxs(4, 6) = gsyn64_max;
gsyn_maxs(2, 5) = gsyn52_max;
gsyn_maxs(3, 5) = gsyn53_max;
gsyn_maxs(7, 5) = gsyn57_max;
gsyn_maxs(5, 7) = gsyn75_max;
gsyn_maxs(8, 6) = gsyn68_max;
gsyn_maxs(6, 8) = gsyn86_max;


%% Define Simulation Properties.

% Set the simulation time.
tf = 5;         % [s] Simulation Duration.
dt = 1e-3;      % [s] Simulation Time Step.

% Compute the simulation time vector.
ts = 0:dt:tf;

% Compute the number of time steps.
num_timesteps = length(ts);

% Set the network initial conditions.
Us0 = zeros(num_neurons, 1);
hs0 = zeros(num_neurons, 1);

% Define the number of cycles.
num_cycles = 5;

% Define the applied currents over time.
Iapp1s = Iapp1*ones(1, num_timesteps);
Iapp2s = Iapp2*ones(1, num_timesteps);
Iapp3s = Iapp3*ones(1, num_timesteps);
Iapp4s = Iapp4*ones(1, num_timesteps);

Iapp5s = zeros(1, num_timesteps); Iapp5s(1, 1) = Iapp5;
Iapp6s = zeros(1, num_timesteps); Iapp6s(1, 1) = Iapp6;
Iapp7s = zeros(1, num_timesteps); %Iapp7s(1, floor(num_timesteps/2)) = Iapp7;
Iapp8s = zeros(1, num_timesteps); %Iapp8s(1, floor(num_timesteps/2)) = Iapp8;

% Iapp5s = zeros(1, num_timesteps);
% Iapp6s = zeros(1, num_timesteps);
% Iapp7s = zeros(1, num_timesteps); Iapp7s(1, 1) = Iapp7;
% Iapp8s = zeros(1, num_timesteps); Iapp8s(1, 1) = Iapp8;

% Store the applied currents into arrays.
Iapps = [Iapp1s; Iapp2s; Iapp3s; Iapp4s; Iapp5s; Iapp6s; Iapp7s; Iapp8s];


%% Simulate the Network

% Simulate the network.
[ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt);


%% Plot the minf & hinf Curves for the Fifth Neuron.

% Define how far to extend the minf & hinf curve plots.
percent_converged = 0.98;

% Compute the lower & upper input bounds of the minf curve.
Um_lb = GetInvSteadyStateNaActDeactValue(1 - percent_converged, Am5, Sm5, dEm5);
Um_ub = GetInvSteadyStateNaActDeactValue(percent_converged, Am5, Sm5, dEm5);

% Compute the lower & upper input bounds of the hinf curve.
Uh_lb = GetInvSteadyStateNaActDeactValue(1 - percent_converged, Ah5, Sh5, dEh5);
Uh_ub = GetInvSteadyStateNaActDeactValue(percent_converged, Ah5, Sh5, dEh5);

% Create inputs for the minf & hinf curves over the specified domains.
Us_minf_curve = linspace(Um_lb, Um_ub, 100);
Us_hinf_curve = linspace(Uh_lb, Uh_ub, 100);

% Evaluate the minf & hinf curves over the specified domains.
minfs_curve = GetSteadyStateNaActDeactValue(Us_minf_curve, Am5, Sm5, dEm5);
hinfs_curve = GetSteadyStateNaActDeactValue(Us_hinf_curve, Ah5, Sh5, dEh5);

% Create tangent lines at the midpoints of the minf & hinf curves.
poly_minf = PointSlope2Poly([Umidm5, 0.5], Smidm5);
poly_hinf = PointSlope2Poly([Umidh5, 0.5], Smidh5);

% Create a figure to store the steady state sodium channel activation & deactivation parameter curves.
fig_mhinf = figure('Color', 'w', 'Name', 'Steady State Sodium Channel Activation / Deactivation Parameter Curves');

% Plot the minf curve.
subplot(2, 1, 1), hold on, grid on, xlabel('Membrane Voltage, U [V]'), ylabel('Sodium Channel Activation Parameter, m [-]'), title('Sodium Channel Activation Parameter vs Membrane Voltage'), xlim(sort([Um_lb, Um_ub]))
plot(Us_minf_curve, minfs_curve, '-', 'Linewidth', 3)
line_minf_curve = plot(Us_minf_curve, polyval(poly_minf, Us_minf_curve), '-', 'Linewidth', 3);
line_minf_curve.Color = [line_minf_curve.Color 0.5];
legend({'minf Curve', 'Midpoint Tanget Line'}, 'Location', 'South', 'Orientation', 'Horizontal')

% Plot the hinf curve.
subplot(2, 1, 2), hold on, grid on, xlabel('Membrane Voltage, U [V]'), ylabel('Sodium Channel Deactivation Parameter, m [-]'), title('Sodium Channel Deactivation Parameter vs Membrane Voltage'), xlim(sort([Uh_lb, Uh_ub]))
plot(Us_hinf_curve, hinfs_curve, '-', 'Linewidth', 3)
line_hinf_curve = plot(Us_hinf_curve, polyval(poly_hinf, Us_hinf_curve), '-', 'Linewidth', 3);
line_hinf_curve.Color = [line_hinf_curve.Color 0.5];
legend({'hinf Curve', 'Midpoint Tanget Line'}, 'Location', 'South', 'Orientation', 'Horizontal')


%% Plot the Motor Neuron Subnetwork States vs Time.

% Plot the network membranve voltage vs time.
fig_U = figure('Color', 'w', 'Name', 'Motor Neuron Subnetwork States vs Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('Motor Subnetwork: Membrane Voltage vs Time')
plot(ts, Us(1:4, :), '-', 'Linewidth', 3)
legend({'(1) Hip Ext MN', '(2) Hip Flx MN', '(3) Knee Ext MN', '(4) Knee Flx MN'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage Derivative, $\dot{U}$ [V/s]', 'Interpreter', 'Latex'), title('Motor Subnetwork: Membrane Voltage Derivative vs Time')
plot(ts(1:end-1), dUs(1:4, 1:end-1), '-', 'Linewidth', 3)
legend({'(1) Hip Ext MN', '(2) Hip Flx MN', '(3) Knee Ext MN', '(4) Knee Flx MN'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')


%% Plot the Bistable Subnetwork States Over Time.

% Plot the bistable hip subnetwork states over time.
fig_HipBistableOverTime = figure('Color', 'w', 'Name', 'Bistable Hip Subnetwork States vs Time');

subplot(2, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('Hip Bistable: Membrane Voltage vs Time')
plot(ts, Us(5, :), '-', 'Linewidth', 3)
plot(ts, Us(7, :), '-', 'Linewidth', 3)
legend({'(5) Hip Bistable 1', '(7) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('Hip Bistable: Sodium Channel Deactivation Parameter vs Time')
plot(ts, hs(5, :), '-', 'Linewidth', 3)
plot(ts, hs(7, :), '-', 'Linewidth', 3)
legend({'(5) Hip Bistable 1', '(7) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage Derivative, $\dot{U}$ [V/s]', 'Interpreter', 'Latex'), title('Hip Bistable: Membrane Voltage Derivative vs Time')
plot(ts(1:end-1), dUs(5, 1:end-1), '-', 'Linewidth', 3)
plot(ts(1:end-1), dUs(7, 1:end-1), '-', 'Linewidth', 3)
legend({'(5) Hip Bistable 1', '(7) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter Derivative, $\dot{h}$ [-]', 'Interpreter', 'Latex'), title('Hip Bistable: Sodium Channel Deactivation Parameter Derivative vs Time')
plot(ts(1:end-1), dhs(5, 1:end-1), '-', 'Linewidth', 3)
plot(ts(1:end-1), dhs(7, 1:end-1), '-', 'Linewidth', 3)
legend({'(5) Hip Bistable 1', '(7) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

% Plot the bistable knee subnetwork states over time.
fig_KneeBistableOverTime = figure('Color', 'w', 'Name', 'Bistable Knee Subnetwork States vs Time');

subplot(2, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('Knee Bistable: Membrane Voltage vs Time')
plot(ts, Us(6, :), '-', 'Linewidth', 3)
plot(ts, Us(8, :), '-', 'Linewidth', 3)
legend({'(6) Knee Bistable 1', '(8) Knee Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('Knee Bistable: Sodium Channel Deactivation Parameter vs Time')
plot(ts, hs(6, :), '-', 'Linewidth', 3)
plot(ts, hs(8, :), '-', 'Linewidth', 3)
legend({'(6) Knee Bistable 1', '(8) Knee Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage Derivative, $\dot{U}$ [V/s]', 'Interpreter', 'Latex'), title('Knee Bistable: Membrane Voltage Derivative vs Time')
plot(ts(1:end-1), dUs(6, 1:end-1), '-', 'Linewidth', 3)
plot(ts(1:end-1), dUs(8, 1:end-1), '-', 'Linewidth', 3)
legend({'(6) Knee Bistable 1', '(8) Knee Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter Derivative, $\dot{h}$ [-]', 'Interpreter', 'Latex'), title('Knee Bistable: Sodium Channel Deactivation Parameter Derivative vs Time')
plot(ts(1:end-1), dhs(6, 1:end-1), '-', 'Linewidth', 3)
plot(ts(1:end-1), dhs(8, 1:end-1), '-', 'Linewidth', 3)
legend({'(6) Knee Bistable 1', '(8) Knee Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')


%% Plot the Bistable Subnetwork State Space Trajectories.

% Plot the bistable hip subnetwork state space trajectories.
fig_HipBistableStateTrajectory = figure('Color', 'w', 'Name', 'Bistable Hip Subnetwork State Space Trajectories');
hold on, grid on, xlabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('Hip Bistable: Membrane Voltage vs Time')
plot(Us(5, :), hs(5, :), '-', 'Linewidth', 3)
plot(Us(7, :), hs(7, :), '-', 'Linewidth', 3)
legend({'(5) Hip Bistable 1', '(7) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

% Plot the bistable knee subnetwork state space trajectories.
fig_KneeBistableStateTrajectory = figure('Color', 'w', 'Name', 'Bistable Knee Subnetwork State Space Trajectories');
hold on, grid on, xlabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('Knee Bistable: Membrane Voltage vs Time')
plot(Us(6, :), hs(6, :), '-', 'Linewidth', 3)
plot(Us(8, :), hs(8, :), '-', 'Linewidth', 3)
legend({'(6) Hip Bistable 1', '(8) Hip Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')



%% Plot the Network Currents Over Time.

fig_I = figure('Color', 'w', 'Name', 'Network Currents vs Time');
subplot(5, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Leak Current, $I_{leak}$ [A]', 'Interpreter', 'Latex'), title('Leak Current vs Time'), plot(ts(1:end-1), Ileaks(:, 1:end-1), '-', 'Linewidth', 3)
subplot(5, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Synaptic Current, $I_{syn}$ [A]', 'Interpreter', 'Latex'), title('Synaptic Current vs Time'), plot(ts(1:end-1), Isyns(:, 1:end-1), '-', 'Linewidth', 3)
subplot(5, 1, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Current, $I_{na}$ [A]', 'Interpreter', 'Latex'), title('Sodium Channel Current vs Time'), plot(ts(1:end-1), Inas(:, 1:end-1), '-', 'Linewidth', 3)
subplot(5, 1, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Applied Current, $I_{app}$ [A]', 'Interpreter', 'Latex'), title('Applied Current vs Time'), plot(ts(1:end-1), Iapps(:, 1:end-1), '-', 'Linewidth', 3)
subplot(5, 1, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Total Current, $I_{total}$ [A]', 'Interpreter', 'Latex'), title('Total Current vs Time'), plot(ts(1:end-1), Itotals(:, 1:end-1), '-', 'Linewidth', 3)
legend({'Hip Ext MN', 'Hip Flx MN', 'Knee Ext MN', 'Knee Flx MN', 'Hip Bistable 1', 'Knee Bistable 1', 'Hip Bistable 2', 'Knee Bistable 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')


%% Print Out Network Properties for Animatlab.

fprintf('-------------------- GLOBAL NEURON PROPERTIES --------------------\n\n')
fprintf('Ca Equil Potential: \t%0.16f \t[mV]\n', (dEna5 + Er5)*10^3)


fprintf('\n\n-------------------- NEURON PROPERTIES --------------------\n\n')

fprintf('Ca Activation:\n')
fprintf('\tMidPoint: \t\t\t%0.16f \t[mV]\n', (dEm5 + Er5)*10^3)
fprintf('\tSlope: \t\t\t\t%0.16f \t\t[-]\n', -Sm5/1000)
fprintf('\tTimeConstant: \t\t%0.16f \t\t[ms]\n', 1)

fprintf('\nCa Deactivation:\n')
fprintf('\tMidPoint: \t\t\t%0.16f \t\t[mV]\n', (dEh5 + Er5)*10^3)
fprintf('\tSlope: \t\t\t\t%0.16f \t[-]\n', -Sh5/1000)
fprintf('\tTimeConstant: \t\t%0.16f \t[ms]\n', tauh5_max*10^3)

fprintf('\nMax Ca Conductance: \t%0.16f \t\t[uS]\n', Gna5*10^6)

fprintf('\nResting Potential: \t\t%0.16f \t[mV]\n', Er5*10^3)


fprintf('\n\n--------------------SYNAPSE PROPERTIES--------------------\n\n')
fprintf('Equilibrium Potential: \t\t\t%0.16f \t[mV]\n', (dEsyn57 + Er5)*10^3)
fprintf('\nMaximum Synaptic Conductance: \t%0.16f \t\t[uS]\n', gsyn57_max*10^6)
fprintf('\nPre-Synaptic Saturation Level: \t%0.16f \t[mV]\n', (R5 + Er5)*10^3)
fprintf('\nPre-Synaptic Threshold: \t\t%0.16f \t[mV]\n', Er5*10^3)

fprintf('\nNote: The above values are Matlab simulation values that have been converted to (presumably) be in the form required by Animatlab.  These conversions may be the source of the error...\n')
