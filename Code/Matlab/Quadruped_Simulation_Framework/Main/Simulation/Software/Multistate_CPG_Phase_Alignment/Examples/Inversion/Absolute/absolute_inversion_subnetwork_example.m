%% Absolute Inversion Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-4;
% network_dt = 1e-5;
network_tf = 3;

% Set the user specified parameters.
R1 = 20e-3;
c1 = 0.40e-9;
c3 = 20e-9;
delta = 1e-3;

% R1 = 20e-3;
% c1 = 0.80e-9;
% c3 = 20e-9;
% delta = 1e-3;

% R1 = 20e-3;
% c1 = 40e-9;
% c3 = 1e-6;
% delta = 1e-3;

% R1 = 20e-3;
% c1 = 2e-11;
% c3 = 1e-9;
% delta = 1e-3;


%% Create Absolute Inversion Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Compute the network properties.
R2 = c1/c3;
c2 = ( c1 - delta*c3 )/( delta*R1 );
dEs21 = 0;
Gm2 = c3/R1;
Iapp2 = c1/R1;
gs21 = ( c1 - delta*c3 )/( delta*R1 );

% Print a summary of the relevant network parameters.
fprintf( 'NETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2*( 10^3 ) )
fprintf( 'c1 = %0.2f [nW]\n', c1*( 10^9 ) )
fprintf( 'c2 = %0.2f [muS]\n', c2*( 10^6 ) )
fprintf( 'c3 = %0.2f [nA]\n', c3*( 10^9 ) )
fprintf( 'delta = %0.2f [mV]\n', delta*( 10^3 ) )
fprintf( 'dEs21 = %0.2f [mV]\n', dEs21*( 10^3 ) )
fprintf( 'gs21 = %0.2f [muS]\n', gs21*( 10^6 ) )
fprintf( 'Gm2 = %0.2f [muS]\n', Gm2*( 10^6 ) )
fprintf( 'Iapp2 = %0.2f [nA]\n', Iapp2*( 10^9 ) )

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 2 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 1 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 2 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), R1, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), R2, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), Gm2, 'Gm' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 2, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), gs21, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), dEs21, 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1, 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 2, 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.25*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.50*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), Iapp2, 'I_apps' );

% % Create applied currents.
% % network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0e-9, 'I_apps' );
% % network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.25*network.neuron_manager.neurons(1).R*network.neuron_manager.neurons(1).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), network.neuron_manager.neurons(1).R*network.neuron_manager.neurons(1).Gm/2, 'I_apps' );
% % network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), network.neuron_manager.neurons(1).R*network.neuron_manager.neurons(1).Gm, 'I_apps' );
% % network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 5e-9, 'I_apps' );
% % network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 20e-9, 'I_apps' );


%% Simulate the Network.

% Start the timer.
tic

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );

% End the timer.
toc


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

