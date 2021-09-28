%% Four Neuron CPG Circular Chain.

% This script simulates a CPG network with four neurons in a chain 1 o-o 2 o-o 3 o-o 4 o-o 1, where 1 o-o 2, 2 o-o 3, 3 o-o 4, and 4 o-o 1 are two neuron CPGs that have been linked.

% Clear Everything.
clear, close('all'), clc


%% Define Neuron Properties.

% Note that most of the neurons have the same universal properties, but each neuron's properties are still set individually to allow for future variation if it becomes necessary.

% Define the number of neurons.
num_neurons = 4;    

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

% Define the properties of Neuron 1.
Cm1 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm1 = Gm;                                                                                             % [S] Membrane Conductance.
Er1 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R1 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am1 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm1 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm1 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah1 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh1 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh1 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna1 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh1_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna1 = TwoNeuronCPGSubnetworkNaConductance(R1, Gm1, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define the properties of Neuron 2.
Cm2 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm2 = Gm;                                                                                             % [S] Membrane Conductance.
Er2 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R2 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am2 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm2 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm2 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah2 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh2 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh2 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna2 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh2_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna2 = TwoNeuronCPGSubnetworkNaConductance(R2, Gm2, Am2, Sm2, dEm2, Ah2, Sh2, dEh2, dEna2);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define the properties of Neuron 3.
Cm3 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm3 = Gm;                                                                                             % [S] Membrane Conductance.
Er3 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R3 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am3 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm3 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm3 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah3 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh3 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh3 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna3 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh3_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna3 = TwoNeuronCPGSubnetworkNaConductance(R3, Gm3, Am3, Sm3, dEm3, Ah3, Sh3, dEh3, dEna3);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Define the properties of Neuron 4.
Cm4 = Cm;                                                                                             % [F] Membrane Capacitance.
Gm4 = Gm;                                                                                             % [S] Membrane Conductance.
Er4 = Er;                                                                                           % [V] Membrane Resting (Equilibrium) Potential.
R4 = R;                                                                                             % [V] Biphasic Equilibrium Voltage Range.
Am4 = Am;                                                                                                % [-] Sodium Channel Activation Parameter A.
Sm4 = Sm;                                                                                              % [-] Sodium Channel Activation Parametter S.
dEm4 = dEm;                                                                                              % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah4 = Ah;                                                                                              % [-] Sodium Channel Deactivation Parameter A.
Sh4 = Sh;                                                                                               % [-] Sodium Channel Deactivation Parameter S.
dEh4 = dEh;                                                                                               % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna4 = dEna;                                                                                         % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh4_max = tauh_max;                                                                                      % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna4 = TwoNeuronCPGSubnetworkNaConductance(R4, Gm4, Am4, Sm4, dEm4, Ah4, Sh4, dEh4, dEna4);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)


% Store the neuron properties into arrays.
Cms = [Cm1; Cm2; Cm3; Cm4];
Gms = [Gm1; Gm2; Gm3; Gm4];
Ers = [Er1; Er2; Er3; Er4];
Rs = [R1; R2; R3; R4]; Rs = repmat(Rs', [num_neurons, 1]);
Ams = [Am1; Am2; Am3; Am4];
Sms = [Sm1; Sm2; Sm3; Sm4];
dEms = [dEm1; dEm2; dEm3; dEm4];
Ahs = [Ah1; Ah2; Ah3; Ah4];
Shs = [Sh1; Sh2; Sh3; Sh4];
dEhs = [dEh1; dEh2; dEh3; dEh4];
dEnas = [dEna1; dEna2; dEna3; dEna4];
tauh_maxs = [tauh1_max; tauh2_max; tauh3_max; tauh4_max];
Gnas = [Gna1; Gna2; Gna3; Gna4];


%% Define Anonymous Functions to Compute Relevant Parameters.

% Define an anonymous function to compute the steady state sodium channel activation parameter.
fminf = @(U, Am, Sm, dEm) GetSteadyStateNaActDeactValue(U, Am, Sm, dEm);

% Define an anonymous function to compute the steady state sodium channel deactivation parameter.
fhinf = @(U, Ah, Sh, dEh) GetSteadyStateNaActDeactValue(U, Ah, Sh, dEh);

% Define an anonymous function to compute leak currents.
fIleak = @(U, Gm) -Gm.*U;

% Define an anonymous function to compute sodium channel currents.
fInainf = @(U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna) Gna.*fminf(U, Am, Sm, dEm).*fhinf(U, Ah, Sh, dEh).*(dEna - U);


%% Define Applied Current Magnitudes.

% Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

% Compute the necessary applied current magnitudes.
Iapp1 = Gm1*R1;                % [A] Applied Current.
Iapp2 = Gm2*R2;                % [A] Applied Current.
Iapp3 = Gm3*R3;                % [A] Applied Current.
Iapp4 = Gm3*R3;                % [A] Applied Current.

% Define tonic current magnitudes.
Iapps_tonic = zeros(num_neurons, 1);


%% Define Synapse Properties.

% Define synapse reversal potentials.
dEsyn21 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn31 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn41 = -40e-3;           % [V] Synapse Reversal Potential.

dEsyn12 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn32 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn42 = -40e-3;           % [V] Synapse Reversal Potential.

dEsyn13 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn23 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn43 = -40e-3;           % [V] Synapse Reversal Potential.

dEsyn14 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn24 = -40e-3;           % [V] Synapse Reversal Potential.
dEsyn34 = -40e-3;           % [V] Synapse Reversal Potential.

% Store the synapse reversal potentials into a matrix.
dEsyns = zeros(num_neurons, num_neurons);
dEsyns(2, 1) = dEsyn21;
dEsyns(3, 1) = dEsyn31;
dEsyns(4, 1) = dEsyn41;

dEsyns(1, 2) = dEsyn12;
dEsyns(3, 2) = dEsyn32;
dEsyns(4, 2) = dEsyn42;

dEsyns(1, 3) = dEsyn13;
dEsyns(2, 3) = dEsyn23;
dEsyns(4, 3) = dEsyn43;

dEsyns(1, 4) = dEsyn14;
dEsyns(2, 4) = dEsyn24;
dEsyns(3, 4) = dEsyn34;

% Define the bistable and oscillatory delta values.
delta_bistable = -0.1e-3;
delta_oscillatory = 0.1e-3;

% Define the CPG subnetwork bifurcation parameters.
delta21 = delta_oscillatory;
delta31 = delta_bistable;
delta41 = delta_bistable;

delta12 = delta_bistable;
delta32 = delta_oscillatory;
delta42 = delta_bistable;

delta13 = delta_bistable;
delta23 = delta_bistable;
delta43 = delta_oscillatory;

delta14 = delta_oscillatory;
delta24 = delta_bistable;
delta34 = delta_bistable;

% Store the CPG subnetwork bifurcation parameters into a matrix.
deltas = zeros(num_neurons, num_neurons);
deltas(2, 1) = delta21;
deltas(3, 1) = delta31;
deltas(4, 1) = delta41;

deltas(1, 2) = delta12;
deltas(3, 2) = delta32;
deltas(4, 2) = delta42;

deltas(1, 3) = delta13;
deltas(2, 3) = delta23;
deltas(4, 3) = delta43;

deltas(1, 4) = delta14;
deltas(2, 4) = delta24;
deltas(3, 4) = delta34;

% Compute the synaptic conductances necessary to achieve these deltas.
gsyn_maxs = GetCPGChainSynapticConductances(deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic);


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
hs0 = GetSteadyStateNaActDeactValue(Us0, Ah, Sh, dEh);


%% Define the Applied Currents.

% Use these applied currents to start Neuron 1 high.
Iapp1s = zeros(1, num_timesteps); Iapp1s(1, 1) = Iapp1;
Iapp2s = zeros(1, num_timesteps); %Iapp2s(1, 1) = Iapp2;
Iapp3s = zeros(1, num_timesteps); %Iapp3s(1, 1) = Iapp3;
Iapp4s = zeros(1, num_timesteps); %Iapp4s(1, 1) = Iapp4;

% % Use these applied currents to start Neuron 2 high.
% Iapp1s = zeros(1, num_timesteps);
% Iapp2s = zeros(1, num_timesteps); Iapp2s(1, 1) = Iapp2;
% Iapp3s = zeros(1, num_timesteps);

% % Use these applied currents to start Neuron 3 high.
% Iapp1s = zeros(1, num_timesteps);
% Iapp2s = zeros(1, num_timesteps);
% Iapp3s = zeros(1, num_timesteps); Iapp3s(1, 1) = Iapp3;

% Store the applied currents into arrays.
Iapps = [Iapp1s; Iapp2s; Iapp3s; Iapp4s];


%% Simulate the Network

% Simulate the network.
[ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt);

% Compute the state space domain of interest.
Umin = min(min(Us)); Umax = max(max(Us));
hmin = min(min(hs)); hmax = max(max(hs));


%% Compute the Nullclines.

% Define anonymous functions to compute the U nullclines.
fU1_nullcline = @(U1, U2) ( -Gm1.*U1 + gsyn_maxs(1, 2).*min(max(U2./R2, 0), 1).*(dEsyn12 - U1) )./( Gna1.*fminf(U1, Am1, Sm1, dEm1).*(U1 - dEna1) );
fU2_nullcline = @(U1, U2) ( -Gm2.*U2 + gsyn_maxs(2, 1).*min(max(U1./R1, 0), 1).*(dEsyn21 - U2) )./( Gna2.*fminf(U2, Am1, Sm1, dEm1).*(U2 - dEna2) );

% Define some CPG voltages that will be relevant to plotting the nullclines.
Us1_null = linspace(Umin, Umax, 100);
Us2_null = linspace(Umin, Umax, 100);
Us1_critlow = 0; Us1_crithigh = R1;
Us2_critlow = 0; Us2_crithigh = R2;

% Compute the U1 & U2 nullcline points for critical values of U1 & U2.
hs1_U1critlow = fU1_nullcline(Us1_null, Us2_critlow);
hs1_U1crithigh = fU1_nullcline(Us1_null, Us2_crithigh);
hs2_U2critlow = fU2_nullcline(Us1_critlow, Us2_null);
hs2_U2crithigh = fU2_nullcline(Us1_crithigh, Us2_null);

% Compute the h1 & h2 nullcline points.
hs1_h1null = fhinf(Us1_null, Ah1, Sh1, dEh1);
hs2_h2null = fhinf(Us2_null, Ah2, Sh2, dEh2);

% Compute the U1 & U2 nullcline surfaces.
[US1_null, US2_null] = meshgrid(Us1_null, Us2_null);
HS1_U1null = fU1_nullcline(US1_null, US2_null);
HS2_U2null = fU2_nullcline(US1_null, US2_null);


%% Plot the U1 & U2 Nullcline Surfaces.

% Plot the U1 nullcline surface.
figure('Color', 'w', 'Name', 'U1 Nullcline Surface'), hold on, grid on, xlabel('U1'), ylabel('U2'), zlabel('h1'), title('h1 vs U1 & U2'), rotate3d on
surf(US1_null, US2_null, HS1_U1null, 'Edgecolor', 'none')
plot3(Us1_null, Us1_critlow*ones(1,length(Us1_null)), hs1_U1critlow, '--', 'Linewidth', 2)
plot3(Us1_null, Us1_crithigh*ones(1,length(Us1_null)), hs1_U1crithigh, '--', 'Linewidth', 2)

% Plot the U2 nullcline surface.
figure('Color', 'w', 'Name', 'U2 Nullcline Surface'), hold on, grid on, xlabel('U1'), ylabel('U2'), zlabel('h2'), title('h2 vs U1 & U2'), rotate3d on
surf(US1_null, US2_null, HS2_U2null, 'Edgecolor', 'none')

% Overlay the U1 & U2 nullcline surfaces.
figure('Color', 'w', 'Name', 'U1 & U2 Nullcline Surfaces'), hold on, grid on, xlabel('U1'), ylabel('U2'), zlabel('h2'), title('h1 & h2 vs U1 & U2'), rotate3d on
surf(US1_null, US2_null, HS1_U1null, 'Edgecolor', 'none', 'Facecolor', 'b')
surf(US1_null, US2_null, HS2_U2null, 'Edgecolor', 'none', 'Facecolor', 'r')


%% Plot the CPG States over Time.

% Create a figure to store the CPG States Over Time plot.
fig_CPGStatesVsTime = figure('Color', 'w', 'Name', 'CPG States vs Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('CPG Membrane Voltage vs Time')
plot(ts, Us(1, :), '-', 'Linewidth', 3)
plot(ts, Us(2, :), '-', 'Linewidth', 3)
plot(ts, Us(3, :), '-', 'Linewidth', 3)
plot(ts, Us(4, :), '-', 'Linewidth', 3)
legend({'Neuron 1', 'Neuron 2', 'Neuron 3', 'Neuron 4'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG Sodium Channel Deactivation Parameter vs Time')
plot(ts, hs(1, :), '-', 'Linewidth', 3)
plot(ts, hs(2, :), '-', 'Linewidth', 3)
plot(ts, hs(3, :), '-', 'Linewidth', 3)
plot(ts, hs(4, :), '-', 'Linewidth', 3)
legend({'Neuron 1', 'Neuron 2', 'Neuron 3', 'Neuron 4'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')


%% Animate the CPG's State Space Trajectory.

% Create a plot to store the CPG's State Space Trajectory animation.
fig_CPGStateTrajectory = figure('Color', 'w', 'Name', 'CPG State Trajectory Animation'); hold on, grid on, xlabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG State Space Trajectory'), axis([Umin Umax hmin hmax])

% Plot the relevant nullclines.
plot(Us1_null, hs1_U1critlow, '--', 'Linewidth', 2)
plot(Us1_null, hs1_U1crithigh, '--', 'Linewidth', 2)
% plot(Us2_null, hs2_U2critlow, '--', 'Linewidth', 2)
% plot(Us2_null, hs2_U2crithigh, '--', 'Linewidth', 2)
plot(Us1_null, hs1_h1null, '--', 'Linewidth', 2)
% plot(Us2_null, hs2_h2null, '--', 'Linewidth', 2)

% Initialize line elements to represent the neuron states.
line1_path = plot(0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Us(1, 1:k)', 'YDataSource', 'hs(1, 1:k)');
line1_endpoint = plot(0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line1_path.Color, 'XDataSource', 'Us(1, k)', 'YDataSource', 'hs(1, k)');
line2_path = plot(0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Us(2, 1:k)', 'YDataSource', 'hs(2, 1:k)');
line2_endpoint = plot(0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line2_path.Color, 'XDataSource', 'Us(2, k)', 'YDataSource', 'hs(2, k)');
line3_path = plot(0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Us(3, 1:k)', 'YDataSource', 'hs(3, 1:k)');
line3_endpoint = plot(0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line3_path.Color, 'XDataSource', 'Us(3, k)', 'YDataSource', 'hs(3, k)');
line4_path = plot(0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Us(4, 1:k)', 'YDataSource', 'hs(4, 1:k)');
line4_endpoint = plot(0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line4_path.Color, 'XDataSource', 'Us(4, k)', 'YDataSource', 'hs(4, k)');

% Add a legend to the plot.
legend([line1_endpoint, line2_endpoint, line3_endpoint, line4_endpoint], {'Neuron 1', 'Neuron 2', 'Neuron 3', 'Neuron 4'})

% Set the number of animation playbacks.
num_playbacks = 1;

% Set the playback speed.
playback_speed = 1;

% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back...    
    for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
        
        % Refresh the plot data.
        refreshdata([line1_path, line1_endpoint, line2_path, line2_endpoint, line3_path, line3_endpoint, line4_path, line4_endpoint], 'caller')
        
        % Update the plot.
        drawnow

    end
end

