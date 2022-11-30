%% Multiplication Subnetwork Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-5;
network_tf = 3;


%% Create Multiplication Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a multiplication subnetwork.
[ network, neuron_IDs_mult, synapse_IDs_mult, applied_current_ID_mult ] = network.create_multiplication_subnetwork(  );

% % Create applied currents for the multiplication subnetwork.
% [ network.applied_current_manager, applied_current_IDs_mult ] = network.applied_current_manager.create_applied_currents( 2 );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(1), 10e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(2), 30e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult, neuron_IDs_mult(1:2), 'neuron_ID' );

% Create applied currents for the multiplication subnetwork.
[ network.applied_current_manager, applied_current_IDs_mult ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(1), 5e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult(2), 2e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_mult, neuron_IDs_mult(1:2), 'neuron_ID' );


% % Disable the multiplication subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_mult );


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

