%% Absolute Division Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
% network_dt = 1e-4;
network_dt = 1e-5;
network_tf = 3;

% Set the necessary parameters.
R1 = 20e-3;
R2 = 20e-3;
c1 = 0.40e-9;
c3 = 0.40e-9;
delta = 1e-3;
dEs31 = 194e-3;


%% Create Absolute Division Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Compute the network properties.
R3 = c1*R1/c3;
c2 = ( R1*c1 - delta*c3 )/( delta*R2 );
dEs32 = 0;
Iapp3 = 0;
Gm3 = c3/( R1*R2 );
gs31 = ( R3*Gm3 - Iapp3 )/( dEs31 - R3 );
gs32 = ( ( dEs31 - delta )*gs31 + Iapp3 - delta*Gm3 )/( delta - dEs32 );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 3 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 2 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 3 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Gm3, 'Gm' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 3, 3 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs31, gs32 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs31, dEs32 ], 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );

% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.25*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );

% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 0*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 0.25*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 1*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), Iapp3, 'I_apps' );



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

