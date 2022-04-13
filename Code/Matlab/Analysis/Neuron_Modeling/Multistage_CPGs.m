%% Multistage CPGs

% This script simulates a CPG network with arbitrarily many states.

% Clear Everything.
clear, close('all'), clc


%% Define Neuron Properties.

% Define the number of neurons.
num_neurons = 4;    

% Define the neuron order.
% neuron_order = [2 1 3];
neuron_order = 1:num_neurons;

% Define universal neuron properties.
Cm = 5e-9;                                                                                          % [F] Membrane Capacitance.
Gm = 1e-6;                                                                                          % [S] Membrane Conductance.
Er = -60e-3;                                                                                        % [V] Membrane Resting (Equilibrium) Potential.
R = 20e-3;                                                                                          % [V] Biphasic Equilibrium Voltage Range.
Am = 1;                                                                                             % [-] Sodium Channel Activation Parameter A.
Sm = -50;                                                                                           % [-] Sodium Channel Activation Parametter S.
dEm = 2*R;                                                                                          % [V] Sodium Channel Activation Reversal Potential w.r.t. Equilibrium Potential.
Ah = 0.5;                                                                                           % [-] Sodium Channel Deactivation Parameter A.
Sh = 50;                                                                                            % [-] Sodium Channel Deactivation Parameter S.
dEh = 0;                                                                                            % [V] Sodium Channel Deactivation Reversal Potential  w.r.t. Equilibrium Potential.
dEna = 110e-3;                                                                                      % [V] Sodium Channel Reversal Potential With Respect to the Resting Potential.
tauh_max = 0.250;                                                                                   % [s] Maximum Sodium Channel Deactivation Time Constant.
Gna = TwoNeuronCPGSubnetworkNaConductance(R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna);             % [S] Sodium Channel Conductance.  (A zero value means that sodium channel currents will not be applied to this neuron.)

% Store the neuron properties into arrays.
Cms = Cm*ones(num_neurons, 1);
Gms = Gm*ones(num_neurons, 1);
Ers = Er*ones(num_neurons, 1);
Rs = R*ones(num_neurons, 1); Rs = repmat(Rs', [num_neurons, 1]);
Ams = Am*ones(num_neurons, 1);
Sms = Sm*ones(num_neurons, 1);
dEms = dEm*ones(num_neurons, 1);
Ahs = Ah*ones(num_neurons, 1);
Shs = Sh*ones(num_neurons, 1);
dEhs = dEh*ones(num_neurons, 1);
dEnas = dEna*ones(num_neurons, 1);
tauh_maxs = tauh_max*ones(num_neurons, 1);
Gnas = Gna*ones(num_neurons, 1);


%% Define Applied Current Magnitudes.

% Note that these are not necessarily constant applied currents.  Here we are only computing the maximum applied current for each neuron, if an applied current will be applied at all.

% Compute the necessary applied current magnitudes.
Iapps_mag = Gms.*Rs;                % [A] Applied Current.

% Define tonic current magnitudes.
Iapps_tonic = zeros(num_neurons, 1);


%% Define Synapse Properties.

% Define the universal synaptic reversal potential.
dEsyn = -40e-3;             % [V] Synapse Reversal Potential.

% Create a matrix of synaptic reversal potentials.
dEsyns = dEsyn*ones(num_neurons, num_neurons); dEsyns(logical(eye(size(dEsyns)))) = 0;

% Define the bistable and oscillatory delta values.
delta_bistable = -10e-3;
% delta_bistable = -0.1e-3;
delta_oscillatory = 0.01e-3;
% delta_oscillatory = 0.1e-3;
% delta_oscillatory = 1e-3;
% delta_oscillatory = 10e-3;

% Compute the delta matrix that describes the type of synaptic connections we want to form.
deltas = GetDeltaMatrix(neuron_order, delta_bistable, delta_oscillatory);

% Compute the synaptic conductances necessary to achieve these deltas.
gsyn_maxs = GetCPGChainSynapticConductances(deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic);


%% Define Simulation Properties.

% Set the simulation time.
tf = 5;         % [s] Simulation Duration.
dt = 1e-3;      % [s] Simulation Time Step.
% dt = 0.5e-3;      % [s] Simulation Time Step.
% dt = 1e-4;      % [s] Simulation Time Step.

% Compute the simulation time vector.
ts = 0:dt:tf;

% Compute the number of time steps.
num_timesteps = length(ts);

% Set the network initial conditions.
Us0 = zeros(num_neurons, 1);
hs0 = GetSteadyStateNaActDeactValue(Us0, Ah, Sh, dEh);


%% Define the Applied Currents.

% Create the applied currents to use during simulation.
Iapps = zeros(num_neurons, num_timesteps); Iapps(neuron_order(1), 1) = Iapps_mag(neuron_order(1));


%% Simulate the Network

% Simulate the network.
[ts, Us, hs, dUs, dhs, Gsyns, Ileaks, Isyns, Inas, Itotals, minfs, hinfs, tauhs] = SimulateNetwork(Us0, hs0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapps, tf, dt);

% Compute the state space domain of interest.
Umin = min(min(Us)); Umax = max(max(Us));
hmin = min(min(hs)); hmax = max(max(hs));


%% Plot the CPG States over Time.

% Create a figure to store the CPG States Over Time plot.
fig_CPGStatesVsTime = figure('Color', 'w', 'Name', 'CPG States vs Time');
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), title('CPG Membrane Voltage vs Time')
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG Sodium Channel Deactivation Parameter vs Time')

% Prellocate an array to store the legend entries.
legstr = cell(1, num_neurons);

% Plot the states of each neuron over time.
for k = 1:num_neurons           % Iterate through each of the neurons.
    
    % Plot the states associated with this neuron.
    subplot(2, 1, 1), plot(ts, Us(k, :), '-', 'Linewidth', 3)
    subplot(2, 1, 2), plot(ts, hs(k, :), '-', 'Linewidth', 3)

    % Add an entry to our legend string.
    legstr{k} = sprintf('Neuron %0.0f', k);
    
end

% Add a legend to the plots.
subplot(2, 1, 1), legend(legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal')
subplot(2, 1, 2), legend(legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

% % Save this figure.
% SaveFigureAtSize(fig_CPGStatesVsTime, 'C:\Users\USER\Documents\Graduate_School\Coursework\Year3\Spring2020\ME610_NeuromechanicalModeling\Project\Paper\MultistateCPG_State_vs_Time.jpg', 0.5)

%% Animate the CPG's State Space Trajectory.

% Create a plot to store the CPG's State Space Trajectory animation.
fig_CPGStateTrajectory = figure('Color', 'w', 'Name', 'CPG State Trajectory Animation'); hold on, grid on, xlabel('Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex'), ylabel('Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex'), title('CPG State Space Trajectory'), axis([Umin Umax hmin hmax])

% Preallocate arrays to store the figure elements.
line_paths = gobjects(num_neurons, 1);
line_ends = gobjects(num_neurons, 1);

% Create the figure elements associated with each of the neurons.
for k = 1:num_neurons               % Iterate through each of the neurons...
   
    % Create data source strings for the path figure element.
    xdatastr_path = sprintf('Us(%0.0f, 1:k)', k);
    ydatastr_path = sprintf('hs(%0.0f, 1:k)', k);
    
    % Add this path figure element to the array of path figure elements.
    line_paths(k) = plot(0, 0, '-', 'Linewidth', 2, 'XDataSource', xdatastr_path, 'YDataSource', ydatastr_path);
    
    % Create data source strings for each end point figure element.
    xdatastr_end = sprintf('Us(%0.0f, k)', k);
    ydatastr_end = sprintf('hs(%0.0f, k)', k);
    
    % Add this path figure element to the array of end figure elements.
    line_ends(k) = plot(0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line_paths(k).Color, 'XDataSource', xdatastr_end, 'YDataSource', ydatastr_end);
    
end

% Add a legend to the plot.
legend(line_ends, legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal')

% Set the number of animation playbacks.
num_playbacks = 1;

% Set the playback speed.
playback_speed = 1;
% playback_speed = 10;
% playback_speed = 100;

% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back...    
    for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
        
        % Refresh the plot data.
        refreshdata([line_paths, line_ends], 'caller')
        
        % Update the plot.
        drawnow

    end
end

