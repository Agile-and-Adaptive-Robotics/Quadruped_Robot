%% Multistate CPG Phase Alignment

% Clear Everything.
clear, close('all'), clc

% EACH DESIGN FUNCTION SHOULD CHECK TO ENSURE THAT THE PRODIVED NEURON IDS HAVE THE NECESSARY SYNAPSES AND APPLIED CURRENTS TO SUCCESSFULLY CREATE THE ASSOCIATED SUBNETWORK.
% ALL NEURON, SYNAPSE, AND APPLIED CURRENT DESIGN COMPUTATIONS SHOULD BE DONE IN THEIR RESPECTIVE FUNCTIONS.



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

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Define the number of CPG neurons.
num_cpg_neurons = 4;

% Create the first multistate cpg subnetwork.
[ network, neuron_IDs_cpg1, synapse_IDs_cpg1, applied_current_ID_cpg1 ] = network.create_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable );

% % Create the second multistate cpg subnetwork.
% [ network, neuron_IDs_cpg2, synapse_IDs_cpg2, applied_current_ID_cpg2 ] = network.create_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable );
% 
% % % Disable the cpg subnetworks.
% % network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg1 );
% % network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg2 );
% 
% % Create a subtraction network to compute the CPG state difference.
% [ network, neuron_IDs_sub, synapse_IDs_sub ] = network.create_subtraction_subnetwork(  );




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

