%% Centered Double Subtraction Subnetwork Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;


%% Create Centered Double Subtraction Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a centered double subtraction subnetwork.
[ network, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell  ] = network.create_centered_double_subtraction_subnetwork(  );


%% Setup the Applied Currents.

% % Create applied currents for the centered double subtraction subnetwork.
% [ network.applied_current_manager, applied_current_IDs_in ] = network.applied_current_manager.create_applied_currents( 2 );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 1 ), 0e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 2 ), 0e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs_cell{ 1 }( 1:2 ), 'neuron_ID' );

% % Create applied currents for the centered double subtraction subnetwork.
% [ network.applied_current_manager, applied_current_IDs_in ] = network.applied_current_manager.create_applied_currents( 2 );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 1 ), 20e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 2 ), 0e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs_cell{ 1 }( 1:2 ), 'neuron_ID' );

% Create applied currents for the centered double subtraction subnetwork.
[ network.applied_current_manager, applied_current_IDs_in ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 1 ), 0e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 2 ), 20e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs_cell{ 1 }( 1:2 ), 'neuron_ID' );



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

