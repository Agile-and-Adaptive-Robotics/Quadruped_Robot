%% Multistate CPG Phase Alignment

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
% network_dt = 1e-3;
network_dt = 1e-4;
% network_dt = 1e-6;
network_tf = 1;


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


%% Build the Network.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Create the first multistate cpg subnetwork.
[ network, neuron_IDs_cpg1, synapse_IDs_cpg1, applied_current_ID_cpg1 ] = network.create_multistate_cpg_subnetwork( 4, delta_oscillatory, delta_bistable );

% Create the second multistate cpg subnetwork.
[ network, neuron_IDs_cpg2, synapse_IDs_cpg2, applied_current_ID_cpg2 ] = network.create_multistate_cpg_subnetwork( 4, delta_oscillatory, delta_bistable );


%% TESTING CODE

% Disable the cpg subnetworks.
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg1 );
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg2 );

% Create an addition subnetwork.
[ network, neuron_IDs_add, synapse_IDs_add ] = network.create_addition_subnetwork(  );

% Create applied currents.
[ network.applied_current_manager, applied_current_IDs_add ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add(1), 5e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add(2), 10e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add, neuron_IDs_add(1:2), 'neuron_ID' );

% Disable the addition subnetwork.
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_add );

% Create a subtraction subnetwork.
[ network, neuron_IDs_sub, synapse_IDs_sub ] = network.create_subtraction_subnetwork(  );

% Create applied currents.
[ network.applied_current_manager, applied_current_IDs_sub ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_sub(1), 15e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_sub(2), 10e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_sub, neuron_IDs_sub(1:2), 'neuron_ID' );

% Disable the subtraction subnetwork.
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_sub );

% Create a division subnetwork.
[ network, neuron_IDs_div, synapse_IDs_div ] = network.create_division_subnetwork(  );

% Create applied currents.
[ network.applied_current_manager, applied_current_IDs_div ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_div(1), 15e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_div(2), 5e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_div, neuron_IDs_div(1:2), 'neuron_ID' );

% Disable the division subnetwork.
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_div );

% Create a multiplication subnetwork.
[ network, neuron_IDs_mult, synapse_IDs_mult ] = network.create_multiplication_subnetwork(  );

% Create applied currents.
[ network.applied_current_manager, applied_current_IDs_mult ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(1), 10e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(2), 30e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult, neuron_IDs_mult(1:2), 'neuron_ID' );

% network.synapse_manager = network.synapse_manager.disable_synapses( network.synapse_manager.synapses(end-2).ID );
% network.synapse_manager = network.synapse_manager.disable_synapses( network.synapse_manager.synapses(end-1).ID );
% network.synapse_manager = network.synapse_manager.disable_synapses( network.synapse_manager.synapses(end).ID );


% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_add(1:2) );


% network.neuron_manager = network.neuron_manager.create_neuron( 5 );
% network.neuron_manager = network.neuron_manager.create_neuron( 6 );
% network.neuron_manager = network.neuron_manager.create_neuron( 7 );
% network.neuron_manager = network.neuron_manager.create_neuron( 8 );
% 
% network.synapse_manager = network.synapse_manager.create_synapse( 17 );
% network.synapse_manager.synapses( 17 ).from_neuron_ID = 5;
% network.synapse_manager.synapses( 17 ).to_neuron_ID = 6;
% % network.synapse_manager.synapses( 17 ).from_neuron_ID = 1;
% % network.synapse_manager.synapses( 17 ).to_neuron_ID = 2;
% 
% network.synapse_manager = network.synapse_manager.create_synapse( 18 );
% network.synapse_manager.synapses( 18 ).from_neuron_ID = 4;
% network.synapse_manager.synapses( 18 ).to_neuron_ID = 5;
% 
% network.synapse_manager = network.synapse_manager.create_synapse( 19 );
% network.synapse_manager.synapses( 19 ).from_neuron_ID = 8;
% network.synapse_manager.synapses( 19 ).to_neuron_ID = 8;
% 
% 
% network.applied_current_manager = network.applied_current_manager.create_applied_current( 5 );
% network.applied_current_manager.applied_currents(5).neuron_ID = 7;
% network.applied_current_manager.applied_currents(5).I_apps = 1e-7;
% 
% network.applied_current_manager = network.applied_current_manager.create_applied_current( 6 );
% network.applied_current_manager.applied_currents(6).neuron_ID = 5;
% network.applied_current_manager.applied_currents(6).I_apps = 1e-7;
% network.applied_current_manager.applied_currents(6).b_enabled = false;
% 
% % network.neuron_manager = network.neuron_manager.disable_neuron( 5 );
% % network.neuron_manager = network.neuron_manager.disable_neuron( 6 );
% 
% % network.neuron_manager = network.neuron_manager.delete_neuron( 5 );
% % network.neuron_manager = network.neuron_manager.delete_neuron( 6 );
% 
% 
% % network.neuron_manager.neurons(5) = network.neuron_manager.neurons(5).disable(  );
% % network.neuron_manager.neurons(4) = network.neuron_manager.neurons(4).disable(  );
% 
% % network.synapse_manager.synapses(2) = network.synapse_manager.synapses(2).disable(  );
% 
% % network.synapse_manager.synapses(13) = network.synapse_manager.synapses(13).disable(  );
% % network.synapse_manager.synapses(14) = network.synapse_manager.synapses(14).disable(  );
% % network.synapse_manager.synapses(15) = network.synapse_manager.synapses(15).disable(  );
% % network.synapse_manager.synapses(16) = network.synapse_manager.synapses(16).disable(  );
% 
% % network.applied_current_manager.applied_currents(1) = network.applied_current_manager.applied_currents(1).disable(  );
% 
% % g_syn_maxs = network.get_max_synaptic_conductances( [1 2 3 5] );


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us(1:2, :), hs(1:2, :), neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );
% fig_network_animation = network.network_utilities.animate_network_states( Us(1:2, :), hs(1:2, :), neuron_IDs );


x = 1;

