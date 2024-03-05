%% Absolute Multiplication Subnetwork Example.

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
% network_dt = 1e-4;
network_dt = 1e-5;
% network_dt = 1e-6;
network_tf = 3;


% % Doesn't work, produces negative conductances.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 20.0e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% delta2 = 1e-3;
% dEs41 = 194e-3;

% % Doesn't work, everything correct sign, maybe numerical problems.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 20.0e-9;
% c6 = 2.1e-9;
% delta1 = 1e-3;
% delta2 = 1e-3;
% dEs41 = 194e-3;

% % Inversion doesn't work.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 0.40e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% delta2 = 1e-3;
% dEs41 = 194e-3;

% % This set of parameters appears to work.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 8.00e-12;
% c3 = 0.40e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% % This set of parameters is obtained by using a naive conversion from the relative version and doesn't appear to correctly replicate those results.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 20.00e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% % delta2 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% % This set of parameters was choosen to make R3 = 20e-3 and R4 = 20e-3.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 3.80000000e-08;
% c3 = 1.90000000e-06;
% c6 = 1e-6;
% delta1 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% % This set of parameters was choosen to make R3 = 20e-3 and R4 = 4e-4.
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 4.02020202e-10;
% c3 = 2.01010101e-08;
% c6 = 1e-6;
% delta1 = 1e-4;
% delta2 = 2e-4;
% dEs41 = 194e-3;

% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 5.20000000e-08;
% c3 = 1.30000000e-06;
% c6 = 1e-6;
% delta1 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% This set comes from combining the current absolute inversion and absolute division after inversion (prefering the inversion stats).
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 20e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% This set comes from combining the current absolute inversion and absolute division after inversion (prefering the division stats).
% R1 = 20e-3;
% R2 = 20e-3;
% c1 = 0.40e-9;
% c3 = 2.28e-9;
% c6 = 0.40e-9;
% delta1 = 1e-3;
% delta2 = 2e-3;
% dEs41 = 194e-3;

% Set the known network parameters.
R1 = 20e-3;
R2 = 20e-3;
R4 = 20e-3;
delta = 1e-3;



%% Create Absolute Division Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% % Compute the network properties.
% R3 = c1/c3;
% R4 = ( c1*c3*R1*delta2 )/( ( c3^2 )*R1*delta1 + c1*c6*delta2 - c3*c6*delta1*delta2 );
% 
% c2 = ( c1 - delta1*c3 )/( delta1*R2 );
% c4 = c3;
% c5 = ( ( c3*R1 - c6*delta2 )*c3 )/( delta2*c1 );
% 
% Iapp3 = c1/R2;
% Iapp4 = 0;
% 
% Gm3 = c3/R2;
% Gm4 = ( c3*c6 )/( R1*c1 );
% 
% dEs32 = 0;
% dEs43 = 0;
% 
% gs32 = ( c1 - delta1*c3 )/( delta1*R2 );
% gs41 = ( ( c3^2 )*c6 )/( ( dEs41*c6 - R1*c3 )*c1 );
% gs43 = ( ( delta2*c6 - R1*c3 )*dEs41*c3*c6 )/( ( R1*c3 - dEs41*c6 )*R1*c1*delta2 );

% Compute the network parameters.
k1 = ( R4 - delta )/( R1*R2 );
k2 = delta/R1;

dEs43 = 0;
Ia4 = 0;

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 4 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 3 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 4 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3, R4 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( [ neuron_IDs( 3 ), neuron_IDs( 4 ) ], [ Gm3, Gm4 ], 'Gm' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2, 3 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 4, 3, 4 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs41, gs32, gs43 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs41, dEs32, dEs43 ], 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3, 4 ], 'neuron_ID' );

% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0.25*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 0*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 0.25*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 1*network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, 'I_apps' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), Iapp3, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 4 ), Iapp4, 'I_apps' );



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

