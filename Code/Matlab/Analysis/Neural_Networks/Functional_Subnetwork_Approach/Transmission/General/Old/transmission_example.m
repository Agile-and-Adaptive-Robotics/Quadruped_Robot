%% Transmission Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;


%% Create Transmission Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a transmission subnetwork.
[ network, neuron_IDs_trans, synapse_ID_trans ] = network.create_transmission_subnetwork(  );

% Create an applied current for the input of the transmission subnetwork.
[ network.applied_current_manager, applied_current_ID_trans ] = network.applied_current_manager.create_applied_currents( 1 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_trans, 5e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_trans, neuron_IDs_trans( 1 ), 'neuron_ID' );

% % Disable the transmission subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_trans );


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

