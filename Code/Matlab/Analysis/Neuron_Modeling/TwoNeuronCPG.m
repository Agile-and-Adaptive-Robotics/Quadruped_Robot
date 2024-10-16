%% Multistage CPGs.

% This script attempts to simulate CPG networks with more than two oscillatory states.

% Clear Everything.
clear, close('all'), clc


%% Define Neuron Properties.

% Note that most of the neurons have the same universal properties, but each neuron's properties are still set individually to allow for future variation if it becomes necessary.

% Define the number of neurons.
num_neurons = 2;    

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

% Store the neuron properties into arrays.
Cms = [Cm1; Cm2];
Gms = [Gm1; Gm2];
Ers = [Er1; Er2];
Rs = [R1; R2]; Rs = repmat(Rs', [num_neurons, 1]);
Ams = [Am1; Am2];
Sms = [Sm1; Sm2];
dEms = [dEm1; dEm2];
Ahs = [Ah1; Ah2];
Shs = [Sh1; Sh2];
dEhs = [dEh1; dEh2];
dEnas = [dEna1; dEna2];
tauh_maxs = [tauh1_max; tauh2_max];
Gnas = [Gna1; Gna2];


%% Define Anonymous Functions to Compute the Steady State Sodium Channel Activation & Deactivation Parameter.

% Define an anonymous function to compute the steady state sodium channel activation parameter.
fminf = @(U) GetSteadyStateNaActDeactValue(U, Am, Sm, dEm);

% Define an anonymous function to compute the steady state sodium channel deactivation parameter.
fhinf = @(U) GetSteadyStateNaActDeactValue(U, Ah, Sh, dEh);


%% Define Applied Current Magnitudes.

% Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

% Compute the necessary applied current magnitudes.
Iapp1 = Gm1*R1;                % [A] Applied Current.
Iapp2 = Gm2*R2;                % [A] Applied Current.
   

%% Define Synapse Properties (SYMMETRIC DELTA TECHNIQUE)

% This section chooses synaptic conductances by using a single delta value and applying it to both neurons.

% % Define synapse reversal potentials.
% dEsyn12 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn21 = -40e-3;            % [V] Synapse Reversal Potential.
% 
% % Store the synapse reversal potentials into a matrix.
% dEsyns = zeros(num_neurons, num_neurons);
% dEsyns(1, 2) = dEsyn12;
% dEsyns(2, 1) = dEsyn21;
% 
% % Define the Bistable CPG subnetwork bifurcation parameters.
% % delta = 15e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% delta = 1.0e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% % delta = 0.01e-3;            % [V] Bifurcation parameter. Use these to create slower oscillation.
% % delta = -0.01e-3;         % [V] Bifurcation parameter. Use these to create a slightly bistable result.
% % delta = -1.0e-3;          % [V] Bifurcation parameter. Use these to create a strongly bistable result.
% 
% % Compute the synapse conductances.
% gsyn12_max = TwoNeuronCPGSubnetworkSynConductance(delta, Gm1, dEsyn12, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1, Gna1);
% gsyn21_max = gsyn12_max;
% 
% % Store the maximum synaptic conductances into a matrix.
% gsyn_maxs = zeros(num_neurons, num_neurons);
% gsyn_maxs(1, 2) = gsyn12_max;
% gsyn_maxs(2, 1) = gsyn21_max;


%% Define Synapse Properties (ASYMMETRY DELTA TECHNIQUE).

% This section chooses synaptic conductances by using two seperate delta parameters (one for each neuron).

% % Define synapse reversal potentials.
% dEsyn12 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn21 = -40e-3;            % [V] Synapse Reversal Potential.
% 
% % Store the synapse reversal potentials into a matrix.
% dEsyns = zeros(num_neurons, num_neurons);
% dEsyns(1, 2) = dEsyn12;
% dEsyns(2, 1) = dEsyn21;
% 
% % Define the bifurcation parameters.
% delta12 = 1.0e-3; delta21 = 0.01e-3;
% % delta12 = 5e-3; delta21 = 0.1e-3;
% % delta12 = 2e-3; delta21 = 1e-3;
% 
% % Compute the required synaptic conductances.
% gsyn12_max = TwoNeuronCPGSubnetworkSynConductance(delta12, Gm1, dEsyn12, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1, Gna1);
% gsyn21_max = TwoNeuronCPGSubnetworkSynConductance(delta21, Gm2, dEsyn21, Am2, Sm2, dEm2, Ah2, Sh2, dEh2, dEna2, Gna2);
% 
% % Store the maximum synaptic conductances into a matrix.
% gsyn_maxs = zeros(num_neurons, num_neurons);
% gsyn_maxs(1, 2) = gsyn12_max;
% gsyn_maxs(2, 1) = gsyn21_max;


%% Define Synapse Properties (EQUILIBRIUM POINT SPECIFICATION TECHNIQUE).

% This section chooses synaptic conductances by directly specifying the desired equilibrium points.

% Define synapse reversal potentials.
dEsyn12 = -40e-3;            % [V] Synapse Reversal Potential.
dEsyn21 = -40e-3;            % [V] Synapse Reversal Potential.

% Store the synapse reversal potentials into a matrix.
dEsyns = zeros(num_neurons, num_neurons);
dEsyns(1, 2) = dEsyn12;
dEsyns(2, 1) = dEsyn21;

% Define the Bistable CPG subnetwork bifurcation parameters.
delta = 5e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% delta = 1.0e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% delta = 0.01e-3;            % [V] Bifurcation parameter. Use these to create slower oscillation.
% delta = -0.01e-3;         % [V] Bifurcation parameter. Use these to create a slightly bistable result.
% delta = -1.0e-3;          % [V] Bifurcation parameter. Use these to create a strongly bistable result.

% Define the desired equilibrium points.
U1_star = delta; U2_star = R2 - delta;

% Compute the synapse conductances.
gsyn12_max = (1./min(max((U2_star./R2), 0), 1)).*TwoNeuronCPGSubnetworkSynConductance(U1_star, Gm1, dEsyn12, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1, Gna1);
gsyn21_max = (1./min(max((U1_star./R1), 0), 1)).*TwoNeuronCPGSubnetworkSynConductance(U2_star, Gm2, dEsyn21, Am2, Sm2, dEm2, Ah2, Sh2, dEh2, dEna2, Gna2);

% Store the maximum synaptic conductances into a matrix.
gsyn_maxs = zeros(num_neurons, num_neurons);
gsyn_maxs(1, 2) = gsyn12_max;
gsyn_maxs(2, 1) = gsyn21_max;


%% Define Synapse Properties (NEW TECHNIQUE).

% This section chooses synaptic conductances by directly specifying the desired equilibrium points.

% % Define synapse reversal potentials.
% dEsyn12 = -40e-3;            % [V] Synapse Reversal Potential.
% dEsyn21 = -40e-3;            % [V] Synapse Reversal Potential.
% 
% % Store the synapse reversal potentials into a matrix.
% dEsyns = zeros(num_neurons, num_neurons);
% dEsyns(1, 2) = dEsyn12;
% dEsyns(2, 1) = dEsyn21;
% 
% % Define the Bistable CPG subnetwork bifurcation parameters.
% % delta = 10e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% % delta = 1.0e-3;           % [V] Bifurcation parameter. Use these to create faster oscillation.
% delta = 0.01e-3;            % [V] Bifurcation parameter. Use these to create slower oscillation.
% % delta = -0.01e-3;         % [V] Bifurcation parameter. Use these to create a slightly bistable result.
% % delta = -1.0e-3;          % [V] Bifurcation parameter. Use these to create a strongly bistable result.
% 
% % Compute preliminary synapse conductances.
% gsyn12_max = TwoNeuronCPGSubnetworkSynConductance(delta, Gm1, dEsyn12, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1, Gna1);
% % gsyn21_max = gsyn12_max;
% gsyn21_max = 0.9*gsyn12_max;
% 
% % Store the maximum synaptic conductances into a matrix.
% gsyn_maxs = zeros(num_neurons, num_neurons);
% gsyn_maxs(1, 2) = gsyn12_max;
% gsyn_maxs(2, 1) = gsyn21_max;
% 
% % Define the input current to use when finding the equilibrium voltages.
% Iapps_eq = zeros(num_neurons, 1);
% 
% % Define the initial condition for the numerical root finding algorithm.
% eq0 = [0; R2; fhinf(0); fhinf(R2)];
% % eq0 = [R1; 0; fhinf(R1); fhinf(0)];
% 
% % Compute the equilibrium points of the network.
% eq_points = GetNetworkEquilibriumPoints(eq0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps_eq);
% 
% vec = [min(eq_points(1:2)); R - max(eq_points(1:2))];
% vec = vec/norm(vec, 2);
% 
% disp(vec)
% 
% % % Define the desired equilibrium points.
% % U1_star = delta; U2_star = R2 - delta;
% % 
% % % Compute the synapse conductances.
% % gsyn12_max = (1./min(max((U2_star./R2), 0), 1)).*TwoNeuronCPGSubnetworkSynConductance(U1_star, Gm1, dEsyn12, Am1, Sm1, dEm1, Ah1, Sh1, dEh1, dEna1, Gna1);
% % gsyn21_max = (1./min(max((U1_star./R1), 0), 1)).*TwoNeuronCPGSubnetworkSynConductance(U2_star, Gm2, dEsyn21, Am2, Sm2, dEm2, Ah2, Sh2, dEh2, dEna2, Gna2);
% % 
% % % Store the maximum synaptic conductances into a matrix.
% % gsyn_maxs = zeros(num_neurons, num_neurons);
% % gsyn_maxs(1, 2) = gsyn12_max;
% % gsyn_maxs(2, 1) = gsyn21_max;


%% Compute the Equilibrium Points of the Network.

% Define the input current to use when finding the equilibrium voltages.
Iapps_eq = zeros(num_neurons, 1);

% Define the initial condition for the numerical root finding algorithm.
% eq0 = [0; R2; fhinf(0); fhinf(R2)];
eq0 = [R1; 0; fhinf(R1); fhinf(0)];

% Compute the equilibrium points of the network.
eq_points = GetNetworkEquilibriumPoints(eq0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps_eq);


%% Define Simulation Properties.

% Set the simulation time.
tf = 5;         % [s] Simulation Duration.
dt = 1e-3;      % [s] Simulation Time Step.

% Compute the simulation time vector.
ts = 0:dt:tf;

% Compute the number of time steps.
num_timesteps = length(ts);

% Set the network initial conditions.
% Us0 = zeros(num_neurons, 1);
% hs0 = GetSteadyStateNaActDeactValue(Us0, Ah, Sh, dEh);
Us0 = eq_points(1:2);
hs0 = eq_points(3:4);


%% Define the Simulation Applied Currents.

% Use these applied currents to start Neuron 1 high.
Iapp1s = zeros(1, num_timesteps); Iapp1s(1, 1) = Iapp1;
Iapp2s = zeros(1, num_timesteps);

% % Use these applied currents to start Neuron 2 high.
% Iapp1s = zeros(1, num_timesteps);
% Iapp2s = zeros(1, num_timesteps); Iapp2s(1, 1) = Iapp2;

% % Use these applied currents to start Neuron 1 high and switch halfway through the simulation.
% Iapp1s = zeros(1, num_timesteps); Iapp1s(1, 1) = Iapp1;
% Iapp2s = zeros(1, num_timesteps); Iapp2s(1, floor(num_timesteps/2)) = Iapp2;

% % Use these applied currents to start Neuron 1 high and switch halfway through the simulation.
% Iapp1s = zeros(1, num_timesteps); Iapp1s(1, floor(num_timesteps/2)) = Iapp1;
% Iapp2s = zeros(1, num_timesteps); Iapp2s(1, 1) = Iapp2;

% Store the applied currents into arrays.
Iapps = [Iapp1s; Iapp2s];


%% Simulate the Network

% Simulate the network.
[ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt);

% Compute the state space domain of interest.
Umin = min(min(Us)); Umax = max(max(Us));
hmin = min(min(hs)); hmax = max(max(hs));


%% Compute the Nullclines.

% Define anonymous functions to compute the U nullclines.
fU1_nullcline = @(U1, U2) ( -Gm1.*U1 + gsyn12_max.*min(max(U2./R2, 0), 1).*(dEsyn12 - U1) )./( Gna1.*fminf(U1).*(U1 - dEna1) );
fU2_nullcline = @(U1, U2) ( -Gm2.*U2 + gsyn21_max.*min(max(U1./R1, 0), 1).*(dEsyn21 - U2) )./( Gna2.*fminf(U2).*(U2 - dEna2) );

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
hs1_h1null = fhinf(Us1_null);
hs2_h2null = fhinf(Us2_null);

% Compute the U1, U2, h1, h2 nullcline surfaces.
[US1_null, US2_null] = meshgrid(Us1_null, Us2_null);
HS1_U1null = fU1_nullcline(US1_null, US2_null);
HS2_U2null = fU2_nullcline(US1_null, US2_null);
HS1_h1null = fhinf(US1_null);
HS2_h2null = fhinf(US2_null);


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
figure('Color', 'w', 'Name', 'U1 & U2 Nullcline Surfaces'), hold on, grid on, xlabel('U1'), ylabel('U2'), zlabel('h1, h2'), title('h1 & h2 vs U1 & U2'), rotate3d on
surf(US1_null, US2_null, HS1_U1null, 'Edgecolor', 'none', 'Facecolor', [0 0 1], 'Facealpha', 0.5)
surf(US1_null, US2_null, HS2_U2null, 'Edgecolor', 'none', 'Facecolor', [1 0 0], 'Facealpha', 0.5)
surf(US1_null, US2_null, HS1_h1null, 'Edgecolor', 'none', 'Facecolor', [0.25 0.25 1], 'Facealpha', 0.5)
surf(US1_null, US2_null, HS2_h2null, 'Edgecolor', 'none', 'Facecolor', [1 0.25 0.25], 'Facealpha', 0.5)


%% Plot the CPG States over Time.

% Create a figure to store the CPG States Over Time plot.
fig_CPGStatesVsTime = figure('Color', 'w', 'Name', 'CPG States vs Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('CPG Membrane Voltage vs Time')
plot(ts, Us(1, :), '-b', 'Linewidth', 3)
plot(ts, Us(2, :), '-r', 'Linewidth', 3)
legend({'Neuron 1', 'Neuron 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG Sodium Channel Deactivation Parameter vs Time')
plot(ts, hs(1, :), '-b', 'Linewidth', 3)
plot(ts, hs(2, :), '-r', 'Linewidth', 3)
legend({'Neuron 1', 'Neuron 2'}, 'Location', 'Southoutside', 'Orientation', 'Horizontal')


%% Animate the CPG's State Space Trajectory.

% Create a plot to store the CPG's State Space Trajectory animation.
fig_CPGStateTrajectory = figure('Color', 'w', 'Name', 'CPG State Trajectory Animation'); hold on, grid on, xlabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG State Space Trajectory'), axis([Umin Umax hmin hmax])

% Plot the relevant nullclines.
plot(Us1_null, hs1_U1critlow, '--b', 'Linewidth', 2)
plot(Us1_null, hs1_U1crithigh, '--b', 'Linewidth', 2)
plot(Us1_null, hs1_h1null, '--b', 'Linewidth', 2)
plot(Us2_null, hs2_U2critlow, '--r', 'Linewidth', 2)
plot(Us2_null, hs2_U2crithigh, '--r', 'Linewidth', 2)
plot(Us2_null, hs2_h2null, '--r', 'Linewidth', 2)

% Plot the equilibrium points.
plot(eq_points(1), eq_points(3), '.b', 'Markersize', 20)
plot(eq_points(2), eq_points(4), '.r', 'Markersize', 20)

% Initialize line elements to represent the neuron states.
line1_path = plot(0, 0, '-b', 'Linewidth', 2, 'XDataSource', 'Us(1, 1:k)', 'YDataSource', 'hs(1, 1:k)');
line1_endpoint = plot(0, 0, 'ob', 'Linewidth', 2, 'Markersize', 15, 'Color', line1_path.Color, 'XDataSource', 'Us(1, k)', 'YDataSource', 'hs(1, k)');
line2_path = plot(0, 0, '-r', 'Linewidth', 2, 'XDataSource', 'Us(2, 1:k)', 'YDataSource', 'hs(2, 1:k)');
line2_endpoint = plot(0, 0, 'or', 'Linewidth', 2, 'Markersize', 15, 'Color', line2_path.Color, 'XDataSource', 'Us(2, k)', 'YDataSource', 'hs(2, k)');

% Set the number of animation playbacks.
num_playbacks = 1;

% Set the playback speed.
playback_speed = 1;

% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back...    
    for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
        
        % Refresh the plot data.
        refreshdata([line1_path, line1_endpoint, line2_path, line2_endpoint], 'caller')
        
        % Update the plot.
        drawnow

    end
end


%% Animate the CPG's State Space Trajectory (High Dimensional State Space).

% % Create a plot to store the CPG's State Space Trajectory animation.
% fig_CPGStateTrajectory = figure('Color', 'w', 'Name', 'CPG State Trajectory Animation'); hold on, grid on
% xlabel('Membrane Voltage, $U1$ [V]', 'Interpreter', 'Latex'), ylabel('Membrane Voltage, $U2$ [V]', 'Interpreter', 'Latex'), zlabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG State Space Trajectory')
% axis([Umin Umax Umin Umax hmin hmax]), view(-30, 30), rotate3d on
% 
% % % Plot the relevant nullclines.
% % plot(Us1_null, hs1_U1critlow, '--b', 'Linewidth', 2)
% % plot(Us1_null, hs1_U1crithigh, '--b', 'Linewidth', 2)
% % plot(Us1_null, hs1_h1null, '--b', 'Linewidth', 2)
% % plot(Us2_null, hs2_U2critlow, '--r', 'Linewidth', 2)
% % plot(Us2_null, hs2_U2crithigh, '--r', 'Linewidth', 2)
% % plot(Us2_null, hs2_h2null, '--r', 'Linewidth', 2)
% 
% % Plot the equilibrium points.
% plot3(eq_points(1), eq_points(2), eq_points(3), '.b', 'Markersize', 20)
% plot3(eq_points(1), eq_points(2), eq_points(4), '.r', 'Markersize', 20)
% 
% % Initialize line elements to represent the neuron states.
% line1_path = plot3(0, 0, 0, '-b', 'Linewidth', 2, 'XDataSource', 'Us(1, 1:k)', 'YDataSource', 'Us(2, 1:k)', 'ZDataSource', 'hs(1, 1:k)');
% line1_endpoint = plot3(0, 0, 0, 'ob', 'Linewidth', 2, 'Markersize', 15, 'Color', line1_path.Color, 'XDataSource', 'Us(1, k)', 'YDataSource', 'Us(2, k)', 'ZDataSource', 'hs(1, k)');
% line2_path = plot3(0, 0, 0, '-r', 'Linewidth', 2, 'XDataSource', 'Us(1, 1:k)', 'YDataSource', 'Us(2, 1:k)', 'ZDataSource', 'hs(2, 1:k)');
% line2_endpoint = plot3(0, 0, 0, 'or', 'Linewidth', 2, 'Markersize', 15, 'Color', line2_path.Color, 'XDataSource', 'Us(1, k)', 'YDataSource', 'Us(2, k)', 'ZDataSource', 'hs(2, k)');
% 
% % Set the number of animation playbacks.
% num_playbacks = 1;
% 
% % Set the playback speed.
% playback_speed = 1;
% 
% % Animate the figure.
% for j = 1:num_playbacks                     % Iterate through each play back...    
%     for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
%         
%         % Refresh the plot data.
% %         refreshdata([line1_path, line1_endpoint], 'caller')
%         refreshdata([line1_path, line1_endpoint, line2_path, line2_endpoint], 'caller')
%         
%         % Update the plot.
%         drawnow
% 
%     end
% end
