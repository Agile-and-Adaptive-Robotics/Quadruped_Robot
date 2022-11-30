%% Inversion Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-4;
network_tf = 3;

% Define the inversion offset and gain values.
epsilon = 5e-4;
k = 1e-5;

% % Define the inversion offset and gain values.
% epsilon = 1e-6;
% k = 1;


%% Create Inversion Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create an inversion subnetwork.
[ network, neuron_IDs_inv, synapse_IDs_inv ] = network.create_inversion_subnetwork( epsilon, k );

% Create applied currents.
ts = 0:network_dt:network_tf;
Is = ( 20e-9/network_tf )*ts;
[ network.applied_current_manager, applied_current_IDs_inv ] = network.applied_current_manager.create_applied_currents( 1 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_inv( 1 ), 10e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_inv( 1 ), { Is }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_inv, neuron_IDs_inv( 1 ), 'neuron_ID' );

% % Disable the inversion subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_inv );


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

