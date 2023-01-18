%% Relative Division Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-5;
network_dt = 1e-3;
network_tf = 3;

 
% c = 2.43e-4;
% alpha = 1.25e-3;
% epsilon = 4.35e-4;
% Gm_3 = 8.70e-9;

c = 5.00e-2;
alpha = 5.15e-3;
epsilon = 4.48e-2;
Gm_3 = 8.70e-10;


%% Create Absolute Inversion Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a subtraction subnetwork.
[ network, neuron_IDs, synapse_IDs, applied_current_IDs ] = network.create_relative_division_subnetwork( c, alpha, epsilon );

% Create applied currents.
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.25*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm/2, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );

% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 0.5*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );


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

