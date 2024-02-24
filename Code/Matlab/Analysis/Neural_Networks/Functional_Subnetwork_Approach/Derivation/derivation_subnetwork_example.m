%% Derivation Subnetwork Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;


%% Create Derivation Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a derivation subnetwork.
[ network, neuron_IDs_der, synapse_IDs_der ] = network.create_derivation_subnetwork(  );

% Define the properties of the applied currents for the derivation subnetwork.
I_mag = 20e-9;
ts = ( 0:network.dt:network.tf )';
I_apps = I_mag*ts;
num_timesteps = length( ts );

% Create applied currents for the derivation subnetwork.
[ network.applied_current_manager, applied_current_IDs_der ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, { 'Der1', 'Der2' }, 'name' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, neuron_IDs_der( 1:2 ), 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, { I_apps }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_der, network.tf, 'tf' );

% % Disable the derivation subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_der );


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

