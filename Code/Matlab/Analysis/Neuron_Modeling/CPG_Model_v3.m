%% CPG Model

% Clear Everything.
clear, close('all'), clc


%% Define the Network Properties.

% Define the number of neurons in the simulation.
num_neurons = 2;

% Define the voltage range for the CPG to oscillator over.
R = 20e-3;                                          % [V] Biphasic Equilibrium Voltage Range.

% Define membrane properties.
Cm = 5e-9;                   % [C] Membrane Capacitance.
Gm = 1e-6;                   % [S] Membrane Conductance.
Er = -60e-3;                 % [V] Membrane Resting (Equilibrium) Potential.

% Define synapse properties.
Elo = Er;                    % [V] Presynaptic Threshold.
Ehi = Elo + R;               % [V] Presynaptic Saturation Level.
Esyn = -100e-3;                % [V] Synaptic Equilibrium Potential.
dEsyn = Esyn - Er;          % [V] Synaptic Equilibrium Potential With Respect to
delta = 0.01e-3;             % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.
% delta = -0.01e-3;            % [V] Voltage Difference Between Inhibited Neuron's Equilibrium Potential & the Presynaptic Threshold.

% Define sodium channel activation properties.
Am = 1;
Sm = -50;
Em = Ehi;
dEm = Em - Er;

% Define sodium channel deactivation properties.
Ah = 0.5;
Sh = 50;
Eh = Elo;
dEh = Eh - Er;

% Define the steady state sodium channel activation & deactivation parameters.
minf_func = @(U) 1./(1 + Am.*exp(-Sm.*(dEm - U)));
hinf_func = @(U) 1./(1 + Ah.*exp(-Sh.*(dEh - U)));

% Define the sodium channel reversal potential.
Ena = 50e-3;                % [V] Sodium Channel Reversal Potential.
dEna = Ena - Er;       % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.

% Define the maximum sodium channel time constant.
tauhmax = 0.3;             % [s] Maximum Sodium Channel Time Constant.

% Compute the sodium channel conductance and maximum synaptic conductances.
[Gna, gsyn_max] = TwoNeuronCPGSubnetwork(R, delta, Gm, dEsyn, Am, Sm, dEm, Ah, Sh, dEh, dEna);


%% Store the Network Properties for Simulation.

% Store the network properties for simulation.
Gms = Gm*ones(num_neurons, 1);
Cms = Cm*ones(num_neurons, 1);
Rs = R*ones(num_neurons, 1);
gsyn_maxs = zeros(num_neurons, num_neurons); gsyn_maxs(1, 2) = gsyn_max; gsyn_maxs(2, 1) = gsyn_max;
dEsyns = zeros(num_neurons, num_neurons); dEsyns(1, 2) = dEsyn; dEsyns(2, 1) = dEsyn;
Ams = Am*ones(num_neurons, 1);
Sms = Sm*ones(num_neurons, 1);
dEms = dEm*ones(num_neurons, 1);
Ahs = Ah*ones(num_neurons, 1);
Shs = Sh*ones(num_neurons, 1);
dEhs = dEh*ones(num_neurons, 1);
tauh_maxs = tauhmax*ones(num_neurons, 1);
Gnas = Gna*ones(num_neurons, 1);
dEnas = dEna*ones(num_neurons, 1);


%% Setup the Simulation Properties.

% Define simulation properties.
tf = 5;                 % [s] Simulation Duration.
dt = 1e-3;              % [s] Simulation Time Step.

% Define the network initial condition.
Us0 = zeros(num_neurons, 1);
hs0 = zeros(num_neurons, 1);

% Define the number of time steps.
num_timesteps = tf/dt + 1;

% Define the applied currents.
Iapps = zeros(num_neurons, num_timesteps);

Iapps(1, 1) = 20e-9;
% Iapps(2, floor(num_timesteps/2)) = 20e-9;

% Iapps(1, 1:(floor(num_timesteps/2) - 1)) = (20e-9)*ones(1, (floor(num_timesteps/2) - 1));
% Iapps(2, floor(num_timesteps/2):end) = (20e-9)*ones(1, length(floor(num_timesteps/2)));


%% Simulate the Network.

% Simulate the network.
[ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt);


%% Plot the Simulation Results.

% Create a figure to store the system state space trajectory.
fig_state_trajectory = figure('color', 'w', 'name', 'Network State Space Trajectory'); hold on, grid on, xlabel('Membrane Voltage w.r.t Resting Potential, U [V]'), ylabel('Na Ch. Deactivation, h [-]'), title('Network State Space Trajectory')
plot(Us(1, :), hs(1, :), '-', 'Linewidth', 3)
plot(Us(2, :), hs(2, :), '-', 'Linewidth', 3)

% Create a figure to store the system states over time.
fig_states_vs_time = figure('color', 'w', 'name', 'Network States Over Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage w.r.t. Resting Voltage, $U$ [V]', 'Interpreter', 'latex'), title('Membrane Voltage w.r.t. Resting Voltage, $U$ [V] vs Time [s]', 'Interpreter', 'latex')
plot(ts, Us, '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter $h$, [-]', 'Interpreter', 'latex'), title('Sodium Channel Deactivation Parameter $h$, [-] vs Time [s]', 'Interpreter', 'latex')
plot(ts, hs, '-', 'Linewidth', 3)

% Create a figure to store the system state derivatives over time.
fig_state_derivatives_vs_time = figure('color', 'w', 'name', 'Network State Derivatives Over Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage w.r.t Resting Voltage Derivative, $\dot{U}$ [V/s]', 'Interpreter', 'latex'), title('Membrane Voltage w.r.t Resting Voltage Derivative, $\dot{U}$ [V/s] vs Time [s]', 'Interpreter', 'latex')
plot(ts, dUs, '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Deactivation Parameter Derivatie, $\dot{h}$ [-/s]', 'Interpreter', 'latex'), title('Na Ch. Deactivation Parameter Derivatie, $\dot{h}$ [-/s] vs Time [s]', 'Interpreter', 'latex')
plot(ts, dhs, '-', 'Linewidth', 3)

% Create a figure to store the currents over time.
fig_currents_vs_time = figure('color', 'w', 'name', 'Network Currents Over Time');

subplot(5, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Leak Currents, $I_{leak}$ [A]', 'Interpreter', 'latex'), title('Leak Currents, $I_{leak}$ [A] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), Ileaks(:, 1:end-1), '-', 'Linewidth', 3) 

subplot(5, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Synaptic Currents, $I_{syn}$ [A]', 'Interpreter', 'latex'), title('Synaptic Currents, $I_{syn}$ [A] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), Isyns(:, 1:end-1), '-', 'Linewidth', 3) 

subplot(5, 1, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Currents, $I_{Na}$ [A]', 'Interpreter', 'latex'), title('Na Ch. Currents, $I_{Na}$ [A] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), Inas(:, 1:end-1), '-', 'Linewidth', 3) 

subplot(5, 1, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Applied Currents, $I_{app}$ [A]', 'Interpreter', 'latex'), title('Applied Currents, $I_{app}$ [A] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), Iapps(:, 1:end-1), '-', 'Linewidth', 3) 

subplot(5, 1, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Total Currents, $I_{total}$ [A]', 'Interpreter', 'latex'), title('Total Currents, $I_{total}$ [A] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), Itotals(:, 1:end-1), '-', 'Linewidth', 3) 


% Create a figure to store the sodium channel activation & deactivation parameters over time.
fig_mhinf_vs_time = figure('color', 'w', 'name', 'Steady State Sodium Channel Activation & Deactivation Over Time');

subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Steady State Sodium Channel Activation, $m_{\infty}$ [-]', 'Interpreter', 'latex'), title('Steady State Sodium Channel Activation, $m_{\infty}$ [-] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), minfs(:, 1:end-1), '-', 'Linewidth', 3)

subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Steady State Sodium Channel Deactivation, $h_{\infty}$ [-]', 'Interpreter', 'latex'), title('Steady State Sodium Channel Deactivation, $h_{\infty}$ [-] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), hinfs(:, 1:end-1), '-', 'Linewidth', 3)


% Create a figure to store the sodium channel deactivation time constant over time.
fig_tauh_vs_time = figure('color', 'w', 'name', 'Sodium Channel Deactivation Time Constants Over Time'); hold on, grid on, xlabel('Time [s]'), ylabel('Na Ch. Deactivation Time Constant, $\tau_{h}$ [s]', 'Interpreter', 'latex'), title('Na Ch. Deactivation Time Constant, $\tau_{h}$ [s] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), tauhs(:, 1:end-1), '-', 'Linewidth', 3)

% Create a figure to store the synaptic conductances.
fig_gsyns_vs_time = figure('color', 'w', 'name', 'Synaptic Conductances Over Time'); hold on, grid on, xlabel('Time [s]'), ylabel('Synaptic Conductance, $G_{s,i}$ [S]', 'Interpreter', 'latex'), title('Synaptic Conductance, $G_{s,i}$ [S] vs Time [s]', 'Interpreter', 'latex')
plot(ts(1:end-1), reshape(Gsyns(2, 1, 1:end-1), [1, num_timesteps-1]), '-', 'Linewidth', 3)
plot(ts(1:end-1), reshape(Gsyns(1, 2, 1:end-1), [1, num_timesteps-1]), '-', 'Linewidth', 3)

% Make the network states over time figure active.
figure(fig_states_vs_time)

