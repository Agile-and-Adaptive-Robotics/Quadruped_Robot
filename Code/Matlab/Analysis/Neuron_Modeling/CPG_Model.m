%% CPG Model

% Clear Everything.
clear, close('all'), clc

%% Simulate the System.

% Define the number of neurons in the simulation.
num_neurons = 2;

% Define the simulation properties.
V0 = [-60e-3; -60e-3; -60e-3; -60e-3];
% h0 = [0; 0; 0; 0];
h0 = [0.67; 0.67; 0.67; 0.67];
x0 = [V0; h0];
tspan = [0 5];

% Simulate the system.
[ts, ys] = ode45(@HalfCenter, tspan, x0);

% Create arrays to store the hidden system states.

dxdt = zeros(size(ys));
[Ileaks, Isyns, Inas, Iapps, Itotals] = deal( zeros(size(ys, 1), num_neurons) );

% Reconstruct the hidden system states.
for k = 1:size(ys, 1)               % Iterate through each of the time steps...
    
    % Compute the hidden states for this time step.
    [dxdt(k, :), Ileaks(k, :), Isyns(k, :), Inas(k, :), Iapps(k, :), Itotals(k, :)] = HalfCenter(0, ys(k, :));

end

%% Plot the System Response.

% Create figures to store the simulation data.
fig_voltages_vs_time = figure('color', 'w', 'name', 'Membrane Voltage vs Time');
fig_Na_deactivation_vs_time = figure('color', 'w', 'name', 'Na Ch. Deactivation vs Time');
fig_state_trajectories = figure('color', 'w', 'name', 'State Trajectories');
fig_leak_current_vs_time = figure('color', 'w', 'name', 'Leak Currents vs Time');
fig_synapse_current_vs_time = figure('color', 'w', 'name', 'Synapse Currents vs Time');
fig_Na_current_vs_time = figure('color', 'w', 'name', 'Sodium Channel Currents vs Time');
fig_total_current_vs_time = figure('color', 'w', 'name', 'Total Currents vs Time');


% Plot the states of the CPG neurons.
for k = 1:num_neurons           % Iterate through each of the neurons...

    % Plot the CPG neuron membrane voltage over time.
    figure(fig_voltages_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Membrane Voltage, $V$ [V]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Membrane Voltage, $V$ [V] vs Time', k), 'Interpreter', 'latex'), plot(ts, ys(:, k), '-', 'Linewidth', 3)
    figure(fig_Na_deactivation_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Na Ch. Deactivation, $h$ [-]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Na Ch. Deactivation, $h$ [-] vs Time', k), 'Interpreter', 'latex'), plot(ts, ys(:, k + 4), '-', 'Linewidth', 3)
    figure(fig_leak_current_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Leak Current, $I_{leak}$ [A]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Leak Current, $I_{leak}$ [A] vs Time', k), 'Interpreter', 'latex'), plot(ts, Ileaks(:, k), '-', 'Linewidth', 3)
    figure(fig_synapse_current_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Synapse Current, $I_{syn}$ [A]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Synapse Current, $I_{syn}$ [A] vs Time', k), 'Interpreter', 'latex'), plot(ts, Isyns(:, k), '-', 'Linewidth', 3)
    figure(fig_Na_current_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Na Ch. Current, $I_{Na}$ [A]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Na Ch. Current, $I_{Na}$ [A] vs Time', k), 'Interpreter', 'latex'), plot(ts, Inas(:, k), '-', 'Linewidth', 3)
    figure(fig_total_current_vs_time), subplot(2, 2, k), hold on, grid on, xlabel('Time [s]', 'Interpreter', 'latex'), ylabel('Total Current, $I_{Na}$ [A]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: Total Current, $I_{total}$ [A] vs Time', k), 'Interpreter', 'latex'), plot(ts, Itotals(:, k), '-', 'Linewidth', 3)

    % Plot the CPG neuron state trajectory over time.
    figure(fig_state_trajectories), subplot(2, 2, k), hold on, grid on, xlabel('Membrane Voltage, $V$ [V]', 'Interpreter', 'latex'), ylabel('Na Ch. Deactivation, $h$, [-]', 'Interpreter', 'latex'), title(sprintf('Neuron %0.0f: State Trajectory', k), 'Interpreter', 'latex'), plot(ys(:, k), ys(:, k + 4), '-', 'Linewidth', 3)
    
end

% legend('Membrane Voltage, V', 'Na Ch. Deactivation, h', 'Location', 'South', 'Orientation', 'Horizontal')

%% Define the System Dynamics.

function [dxdt, Ileaks, Isyns, Inas, Iapps, Itotals] = HalfCenter(t, x)

% Retrieve the components of the input vector.
Vs = reshape(x(1:4), [1 4]); hs = reshape(x(5:end), [1 4]);

% Define the input current.
% Iapps = [0 0 0 0]; 
% Iapps = [(10*(10^(-9))) 0 0 0]; 
if t < 0.01
    Iapps = [(10*(10^(-9))) 0 0 0]; 
else
    Iapps = [0 0 0 0]; 
end
    
% Define membrane properties (these are the same for all four neurons).
Cms = (5e-9)*ones(size(Vs));                  % [C] Membrane Capacitance.
Gms = (1e-6)*ones(size(Vs));                  % [S] Membrane Conductance.
Ers = (-60e-3)*ones(size(Vs));                  % [V] Membrane Resting (Equilibrium) Potential.

% Define synapse properties.
Elos = (-60e-3)*ones(size(Vs));                 % [V] Presynaptic Threshold.
Ehis = (-25e-3)*ones(size(Vs));                 % [V] Presynaptic Saturation Level.
% gmaxs = (0.5e-6)*ones(size(Vs));
% gmaxs = [-1.5e-6 5e-6 -1.5e-6 5e-6];            % [S] Maximum Synaptic Conductance.
gmaxs = [1.5e-6 5e-6 1.5e-6 5e-6];            % [S] Maximum Synaptic Conductance.
% gmaxs = [0 0 0 0];                            % [S] Maximum Synaptic Conductance.
% gmaxs = [0 5e-6 1.5e-6 0];            % [S] Maximum Synaptic Conductance.
% Ess = (-10e-3)*ones(size(Vs));
Ess = [-70e-3 -40e-3 -70e-3 -40e-3];            % [V] Synaptic Equilibrium Potential.

% Define sodium channel properties.
Ams = 1*ones(size(Vs));
Sms = -50*ones(size(Vs));
Ems = (20e-3)*ones(size(Vs));
Ahs = 0.5*ones(size(Vs));
Shs = 50*ones(size(Vs));
Ehs = 0*ones(size(Vs));
% Gnas = [0 0 0 0];
% Gnas = (1e-6)*ones(size(Vs));
Enas = (50e-3)*ones(size(Vs));
tauhmaxs = 0.3*ones(size(Vs));

minf0 = 1./(1 + Ams); hinf0 = 1./(1 + Ahs.*exp(Shs.*(Ems - Ehs)));


% Compute the sodium channel synapse conductance.
% Gnas = [1.5e-6 0 1.5e-6 0];
Gnas = (Gms.*Ems)./(minf0.*hinf0.*(Enas - Ems));

% Compute the synapse conductance.
Gss = gmaxs.*min( max( (circshift(Vs, 1) - Elos)./(Ehis - Elos), 0), 1);

% Compute the steady state sodium channel activation and deactivation parameters.
minfs = 1./(1 + Ams.*exp(Sms.*(Vs - Ems))); hinfs = 1./(1 + Ahs.*exp(Shs.*(Vs - Ehs)));

% Compute the sodium channel deactivation time constant.
tauhs = tauhmaxs.*hinfs.*sqrt(Ahs.*exp(Shs.*(Vs - Ehs)));

% Compute the leak current.
Ileaks = Gms.*(Ers - Vs);

% Compute the synaptic current.
Isyns = Gss.*(Ess - Vs);

% Compute the sodium current.
Inas = Gnas.*minfs.*hs.*(Enas - Vs);

% Compute the total current.
Itotals = Ileaks + Isyns + Inas + Iapps;
% Itotals = Ileaks + Isyns + Iapps;

% Compute the membrane voltage derivative.
dVdts = Itotals./Cms;

% Compute the sodium channel deactivation derivative.
dhdts = (hinfs - hs)./tauhs;

% Compute the state derivative.
dxdt = [dVdts'; dhdts'];

end




