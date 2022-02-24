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
network_dt = 1e-3;
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


%% Initialize the Neural Network.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Load the network data.
network = network.load_xlsx( robot_data_load_path );


%% Modify Neural Network Parameters.

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;
delta_bistable = -10e-3;

% Define the neuron ID order.
neuron_ID_order = [ 1 2 3 4 ];

% Set the sodium channel conductance of every neuron in the network using the CPG approach.
network.neuron_manager = network.neuron_manager.compute_set_CPG_Gna( neuron_ID_order );

% Set the synapse delta values.
network.synapse_manager = network.synapse_manager.compute_set_deltas( delta_oscillatory, delta_bistable, neuron_ID_order );

% Compute and set the maximum synaptic conductances required to achieve these delta values.
network = network.compute_set_max_synaptic_conductances( neuron_ID_order );


%% TESTING CODE


network = network.create_multistate_cpg_subnetwork( 4, delta_oscillatory, delta_bistable );

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
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Plot the Network Results.

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );


x = 1;

