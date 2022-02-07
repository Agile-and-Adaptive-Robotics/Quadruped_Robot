%% Multistate CPG Phase Alignment

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;



%% Initialize the Data Loader Class.

% Determine whether to print status messages.
if b_verbose                                                        % If we want to print status messages...
    
    % State that we are starting a new operation.
    fprintf( 'INITIALIZING DATA LOADER. Please Wait...\n' )

end

% Start a timer.
tic

% Define the path to the directory that contains the robot data.
% robot_data_load_path = 'C:\Users\USER\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Utilities\Robot_Data';
% robot_data_load_path = 'C:\Users\Cody Scharzenberger\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Utilities\Robot_Data';

robot_data_load_path = 'C:\Users\USER\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data';
% robot_data_load_path = 'C:\Users\Cody Scharzenberger\Documents\GitHub\Quadruped_Robot\Code\Matlab\Quadruped_Simulation\Quadruped_Simulation_Framework\Main\Simulation\Software\Multistate_CPG_Phase_Alignment\Robot_Data';

% Create an instance of the data loader class.
data_loader = data_loader_class( robot_data_load_path );

% Retrieve the elapsed time.
elapsed_time = toc;

% Determine whether to print status messages.
if b_verbose                                                        % If we want to print status messages...
    
    % State that we have finished this operation.
    fprintf( 'INITIALIZING DATA LOADER. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )

end


%% Initialize the Neural Network.

% Determine whether to print status messages.
if b_verbose                                                        % If we want to print status messages...
    
    % State that we are starting a new operation.
    fprintf( 'INITIALIZING NEURAL NETWORK. Please Wait...\n' )

end
    
% Start a timer.
tic

% Load the neuron data.
[ neuron_IDs, neuron_names, neuron_Cms, neuron_Gms, neuron_Ers, neuron_Rs, neuron_Ams, neuron_Sms, neuron_dEms, neuron_Ahs, neuron_Shs, neuron_dEhs, neuron_dEnas, neuron_tauh_maxs, neuron_Gnas ] = data_loader.load_neuron_data( 'Neuron_Data.xlsx' );

% Define the number of neurons.
num_neurons = length( neuron_IDs );

% Preallocate an array of neurons.
neurons = repmat( neuron_class(  ), 1, num_neurons );

% Create each neuron object.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Create this neuron.
    neurons(k) = neuron_class( neuron_IDs(k), neuron_names{k}, neuron_Cms(k), neuron_Gms(k), neuron_Ers(k), neuron_Rs(k), neuron_Ams(k), neuron_Sms(k), neuron_dEms(k), neuron_Ahs(k), neuron_Shs(k), neuron_dEhs(k), neuron_dEnas(k), neuron_tauh_maxs(k), neuron_Gnas(k) );
    
end

% Create an instance of the neuron manager class.
neuron_manager = neuron_manager_class( neurons );

% Load the synapse data.
[ synapse_IDs, synapse_names, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = data_loader.load_synapse_data( 'Synapse_Data.xlsx' );

% Define the number of synapses.
num_synapses = length( synapse_IDs );

% Preallocate an array of synapses.
synapses = repmat( synapse_class(  ), 1, num_synapses );

% Create each synapse object.
for k = 1:num_synapses                  % Iterate through each synapse...
    
    % Create this synapse.
    synapses(k) = synapse_class( synapse_IDs(k), synapse_names{k}, synapse_dEsyns(k), synapse_gsyn_maxs(k), synapse_from_neuron_IDs(k), synapse_to_neuron_IDs(k) );
    
end

% Create an instance of the synapse manager class.
synapse_manager = synapse_manager_class( synapses );

% Load the applied current data.
[ applied_current_IDs, applied_current_names, applied_current_neuron_IDs, applied_current_ts, applied_current_I_apps ] = data_loader.load_applied_current_data( 'Applied_Current_Data.xlsx' );

% Define the number of applied currents.
num_applied_currents = length( applied_current_IDs );

% Preallocate an array of applied currents.
applied_currents = repmat( applied_current_class(  ), 1, num_applied_currents );

% Create each applied current.
for k = 1:num_applied_currents              % Iterate through each applied current...
    
    % Create this applied current.
    applied_currents(k) = applied_current_class( applied_current_IDs(k), applied_current_names{k}, applied_current_neuron_IDs(k), applied_current_ts( :, k ), applied_current_I_apps( :, k ) );
    
end

% Create an instance of the applied current manager class.
applied_current_manager = applied_current_manager_class( applied_currents );

% Define the network integration step size.
network_dt = 1e-3;

% Create an instance of the network class.
network = network_class( neuron_manager, synapse_manager, applied_current_manager, network_dt );

% Retrieve the elapsed time.
elapsed_time = toc;

% Determine whether to print status messages.
if b_verbose                                                        % If we want to print status messages...
    
    % State that we have finished this operation.
    fprintf( 'INITIALIZING NEURAL NETWORK. Please Wait... Done. %0.3f [s] \n\n', elapsed_time )

end


%% Modify Neural Network Parameters.

% Set the sodium channel conductance of every neuron in the network using the two neuron CPG approach.
network.neuron_manager = network.neuron_manager.compute_set_CPG_Gna( 'all' );

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;
delta_bistable = -10e-3;

% Define the neuron ID order.
neuron_ID_order = [ 1 2 3 4 ];

% Set the oscillatory and bistable delta CPG synapse design parameters.
network.synapse_manager.delta_oscillatory = delta_oscillatory;
network.synapse_manager.delta_bistable = delta_bistable;

% Set the neuron ID order.
network.synapse_manager.neuron_ID_order = neuron_ID_order;

% Set the synapse delta values.
network.synapse_manager = network.synapse_manager.neuron_ID_order2synapse_delta(  );

% Set the network delta matrix.
network = network.construct_set_delta_matrix(  );

% Compute and set the maximum synaptic conductances required to achieve these delta values.
network = network.compute_set_max_synaptic_conductance_matrix(  );



x = 1;

