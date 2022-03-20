%% CPG Frequency Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the path to the directory that contains the robot data.
robot_data_save_path = 'D:\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data\Save';
robot_data_load_path = 'D:\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data\Load';

% robot_data_save_path = 'C:\Users\Cody Scharzenberger\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data\Save';
% robot_data_load_path = 'C:\Users\Cody Scharzenberger\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data\Load';

% Define the network integration step size.
network_dt = 1e-3;
% network_dt = 1e-4;
% network_dt = 1e-5;
% network_dt = 1e-6;
% network_tf = 1;
% network_tf = 3;
network_tf = 5;


%% Initialize the Data Loader Class.

% Determine whether to print status messages.
if b_verbose, fprintf( 'INITIALIZING DATA LOADER. Please Wait...\n' ), end

% Start a timer.
tic

% Create an instance of the data loader class.
data_loader = data_loader_utilities_class( robot_data_load_path );

% Retrieve the elapsed time.
elapsed_time = toc;

% Determine whether to print status messages.
if b_verbose, fprintf( 'INITIALIZING DATA LOADER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end


%% Create Multistate CPG Subnetworks.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% % Define the oscillatory and bistable delta CPG synapse design parameters.
% delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
% delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Define the number of CPG neurons.
num_cpg_neurons = 4;

% Create the first multistate cpg subnetwork.
[ network, neuron_IDs_cpg1, synapse_IDs_cpg1, applied_current_ID_cpg1 ] = network.create_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable );

% Delete the initial applied current.
network.applied_current_manager = network.applied_current_manager.delete_applied_currents( applied_current_ID_cpg1 );

% Create applied current.
[ network.applied_current_manager, applied_current_ID_cpg1 ] = network.applied_current_manager.create_applied_currents( num_cpg_neurons );

% Apply a small constant current to each neuron.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );
I_mag = -0.02e-9;                            % T = 2.3 [s], f = 0.4348 [hz]
% I_mag = -0.01e-9;                            % T = 2.1285 [s], f = 0.4698 [hz]
% I_mag = 0;                            % T = 2.0890 [s], f = 0.4787 [hz]
% I_mag = 0.5e-9;                       % T = 1.1225 [s], f = 0.8909 [hz]
% I_mag = 1e-9;                       % T = 0.8750 [s], f = 1.1429 [hz]
% I_mag = 1.25e-9;                       % T = 0.6351 [s], f = 1.5746 [hz]
% I_mag = 1.5e-9;                       % T = 0.5174 [s], f = 1.9327 [hz]
% I_mag = 2e-9;                       % T = 0.3812 [s], f = 2.6235 [hz]

I_apps = I_mag*ones( num_timesteps, 1 );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, neuron_IDs_cpg1, 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, { I_apps }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_cpg1, network.tf, 'tf' );


% % Create the second multistate cpg subnetwork.
% [ network, neuron_IDs_cpg2, synapse_IDs_cpg2, applied_current_ID_cpg2 ] = network.create_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable );
%
% % Disable the cpg subnetworks.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg1 );
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg2 );




%% DEBUGGING CODE


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
% [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation( network.dt, network.tf, 'RK4' );


%% Post-Process Simulation Results.

% Compute the transition logical indexes.
transition_logicals = logical( abs( diff( Us > 20e-3, 1, 2 ) ) );

% Preallocate an array to store the activation and deactivation periods.
[ Ts_activation, Ts_deactivation ] = deal( zeros( 1, num_cpg_neurons ) );

% Compute the activation and deactivation times for each of the CPG neurons.
for k = 1:num_cpg_neurons                           % Iterate through each of the CPG neurons.
    
    % Compute the transition times for this 
    transition_times = ts( transition_logicals( k, : ) );
    
    % Compute the duration between transitions.
    dTs = diff( transition_times );
    
    % Compute the average activation time for this neuron
    Ts_activation( k ) = mean( dTs( 1:2:end ) );
    
    % Compute the average deactivation time for this neuron.
    Ts_deactivation( k ) = mean( dTs( 2:2:end ) );
        
end

% Compute the period of oscillation.
Ts_period = Ts_activation + Ts_deactivation;                        % [s] Oscillation Period.

% Compute the frequency of oscillation.
fs_frequency = 1./Ts_period;                                        % [Hz] Oscillation Frequency.

% Print the oscillation period.
fprintf('Oscillation Period: [s]\n'), disp( Ts_period )
fprintf('Oscillation Frequency: [hz]\n'), disp( fs_frequency )


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us(1:2, :), hs(1:2, :), neuron_IDs );

% dUs = Us( 1, : ) - Us( 2, : );
% figure( 'Color', 'w' ), plot( ts, dUs, '-m', 'Linewidth', 3 )

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );
% fig_network_animation = network.network_utilities.animate_network_states( Us(1:2, :), hs(1:2, :), neuron_IDs );


x = 1;

