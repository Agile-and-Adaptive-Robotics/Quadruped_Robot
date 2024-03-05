%% Multiplication Subnetwork Encoding Comparison

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options

% Define the save and load directories.
save_directory = '.\Save';
load_directory = '.\Load';

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-4;
% network_dt = 1e-5;
network_tf = 3;


%% Define the Absolute Multiplication Subnetwork Parameters.

% Set the necessary parameters.
R1_absolute = 20e-3;                                 % [V] Activation Domain
R2_absolute = 20e-3;                                 % [V] Activation Domain
c1_absolute = 8.00e-12;                              % [W] Absolute Inversion Parameter 1
c3_absolute = 0.40e-9;                               % [A] Absolute Inversion Parameter 3
% c6_absolute = 0.40e-9;                               % [W] Absolute Division Parameter 3 
c6_absolute = 0.070175438596491236e-09;                               % [W] Absolute Division Parameter 3 R4 = 30e-3
% c6_absolute = 0.21052631578947373e-9;                               % [W] Absolute Division Parameter 3  R4 = 20e-3
% c6_absolute = 40.040040040040048e-9;                               % [W] Absolute Division Parameter 3
% c6_absolute = -0.18947368421052636e-9;                               % [W] Absolute Division Parameter 3 
delta1_absolute = 1e-3;                              % [V] Inversion Offset Voltage
delta2_absolute = 2e-3;                              % [V] Division Offset Voltage
dEs41_absolute = 194e-3;                             % [V] Synaptic Reversal Potential

% % Set the number of multiplication neurons.
% num_multiplication_neurons = 4;

% Compute the network properties.
R3_absolute = c1_absolute/c3_absolute;
R4_absolute = ( c1_absolute*c3_absolute*R1_absolute*delta2_absolute )/( ( c3_absolute^2 )*R1_absolute*delta1_absolute + c1_absolute*c6_absolute*delta2_absolute - c3_absolute*c6_absolute*delta1_absolute*delta2_absolute );

c2_absolute = ( c1_absolute - delta1_absolute*c3_absolute )/( delta1_absolute*R2_absolute );
c4_absolute = c3_absolute;
c5_absolute = ( ( c3_absolute*R1_absolute - c6_absolute*delta2_absolute )*c3_absolute )/( delta2_absolute*c1_absolute );

Ia3_absolute = c1_absolute/R2_absolute;
Ia4_absolute = 0;

Gm3_absolute = c3_absolute/R2_absolute;
Gm4_absolute = ( c3_absolute*c6_absolute )/( R1_absolute*c1_absolute );

dEs32_absolute = 0;
dEs43_absolute = 0;

gs32_absolute = ( c1_absolute - delta1_absolute*c3_absolute )/( delta1_absolute*R2_absolute );
gs41_absolute = ( ( c3_absolute^2 )*c6_absolute )/( ( dEs41_absolute*c6_absolute - R1_absolute*c3_absolute )*c1_absolute );
gs43_absolute = ( ( delta2_absolute*c6_absolute - R1_absolute*c3_absolute )*dEs41_absolute*c3_absolute*c6_absolute )/( ( R1_absolute*c3_absolute - dEs41_absolute*c6_absolute )*R1_absolute*c1_absolute*delta2_absolute );


%% Print the Absolute Multiplication Subnetwork Parameters.

% Print a summary of the relevant network parameters.
fprintf( '\n' )
fprintf( 'ABSOLUTE MULTIPLICATION NETWORK PARAMETERS:\n' )
fprintf( 'R1_absolute = %0.2f [mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2_absolute = %0.2f [mV]\n', R2_absolute*( 10^3 ) )
fprintf( 'R3_absolute = %0.2f [mV]\n', R3_absolute*( 10^3 ) )
fprintf( 'R4_absolute = %0.2f [mV]\n', R4_absolute*( 10^3 ) )
fprintf( 'c1_absolute = %0.2e [-]\n', c1_absolute )
fprintf( 'c2_absolute = %0.2e [-]\n', c2_absolute )
fprintf( 'c3_absolute = %0.2e [-]\n', c3_absolute )
fprintf( 'c4_absolute = %0.2e [-]\n', c4_absolute )
fprintf( 'c5_absolute = %0.2e [-]\n', c5_absolute )
fprintf( 'c6_absolute = %0.2e [-]\n', c6_absolute )
fprintf( 'dEs41_absolute = %0.2f [mV]\n', dEs41_absolute*( 10^3 ) )
fprintf( 'dEs32_absolute = %0.2f [mV]\n', dEs32_absolute*( 10^3 ) )
fprintf( 'dEs43_absolute = %0.2f [mV]\n', dEs43_absolute*( 10^3 ) )
fprintf( 'gs41_absolute = %0.2f [muS]\n', gs41_absolute*( 10^6 ) )
fprintf( 'gs32_absolute = %0.2f [muS]\n', gs32_absolute*( 10^6 ) )
fprintf( 'gs43_absolute = %0.2f [muS]\n', gs43_absolute*( 10^6 ) )
fprintf( 'Gm3_absolute = %0.2f [muS]\n', Gm3_absolute*( 10^6 ) )
fprintf( 'Gm4_absolute = %0.2f [muS]\n', Gm4_absolute*( 10^6 ) )
fprintf( 'Ia3_absolute = %0.2f [nA]\n', Ia3_absolute*( 10^9 ) )
fprintf( 'Ia4_absolute = %0.2f [nA]\n', Ia4_absolute*( 10^9 ) )
fprintf( '\n' )


%% Create the Absolute Multiplication Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network absolute components.
[ network_absolute.neuron_manager, neuron_IDs ] = network_absolute.neuron_manager.create_neurons( 4 );
[ network_absolute.synapse_manager, synapse_IDs ] = network_absolute.synapse_manager.create_synapses( 3 );
[ network_absolute.applied_current_manager, applied_current_IDs ] = network_absolute.applied_current_manager.create_applied_currents( 4 );

% Set the network absolute parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs, [ R1_absolute, R2_absolute, R3_absolute, R4_absolute ], 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( [ neuron_IDs( 3 ), neuron_IDs( 4 ) ], [ Gm3_absolute, Gm4_absolute ], 'Gm' );

network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2, 3 ], 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs, [ 4, 3, 4 ], 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs, [ gs41_absolute, gs32_absolute, gs43_absolute ], 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs, [ dEs41_absolute, dEs32_absolute, dEs43_absolute ], 'dE_syn' );

network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3, 4 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs( 3:4 ), [ Ia3_absolute, Ia4_absolute ], 'I_apps' );



% %% Create Absolute Multiplication Subnetwork
% 
% % Set the necessary parameters.
% R1_absolute = 20e-3;                                 % [V] Activation Domain
% R2_absolute = 20e-3;                                 % [V] Activation Domain
% c1_absolute = 2.28e-9;                               % [W] Multiplication Parameter 1
% c3_absolute = 0.40e-9;                               % [W] Multiplication Parameter 3
% delta1_absolute = 1e-3;                              % [V] Inversion Offset
% delta2_absolute = 2e-3;                              % [V] Multiplication Offset
% dEs31_absolute = 194e-3;                             % [V] Synaptic Reversal Potential
% 
% % R1_absolute = 20e-3;                                 % [V] Activation Domain
% % R2_absolute = 20e-3;                                 % [V] Activation Domain
% % c1_absolute = 8.00e-12;                               % [W] Multiplication Parameter 1
% % c3_absolute = 0.40e-9;                               % [W] Multiplication Parameter 3
% % c6_absolute = 0.21052631578947373e-9;                % [W] Multiplication Parameter 6
% % delta1_absolute = 1e-3;                              % [V] Inversion Offset
% % delta2_absolute = 2e-3;                              % [V] Multiplication Offset
% % dEs31_absolute = 194e-3;                             % [V] Synaptic Reversal Potential
% 
% % Compute the network properties.
% R3_absolute = ( c1_absolute*R1_absolute*R2_absolute*delta2_absolute )/( c1_absolute*R1_absolute*delta1_absolute + c3_absolute*R2_absolute*delta2_absolute - c3_absolute*delta1_absolute*delta2_absolute );                % [V] Activation Domain
% c2_absolute = ( c1_absolute*R1_absolute - c3_absolute*delta2_absolute )/( delta2_absolute*R2_absolute );                                                   % [A] Multiplication Parameter 2
% gs31_absolute = ( c1_absolute*c3_absolute )/( ( c3_absolute*dEs31_absolute - R1_absolute*c1_absolute )*R2_absolute );                                               % [S] Maximum Synaptic Conductance
% gs32_absolute = ( ( delta2_absolute*c3_absolute - R1_absolute*c1_absolute )*dEs31_absolute*c3_absolute )/( ( R1_absolute*c1_absolute - dEs31_absolute*c3_absolute )*R1_absolute*R2_absolute*delta2_absolute );            % [S] Maximum Synaptic Conductance
% dEs32_absolute = 0;                                                                                  % [V] Synaptic Reversal Potential
% Iapp3_absolute = 0;                                                                                  % [A] Applied Current
% Gm3_absolute = c3_absolute/( R1_absolute*R2_absolute );                                                                         % [S] Membrane Conductance
% 
% % Print a summary of the relevant network parameters.
% fprintf( 'ABSOLUTE DIVISION AFTER INVERSION SUBNETWORK PARAMETERS:\n' )
% fprintf( 'R1 = %0.2f [mV]\n', R1_absolute*( 10^3 ) )
% fprintf( 'R2_absolute = %0.2f [mV]\n', R2_absolute*( 10^3 ) )
% fprintf( 'R3_absolute = %0.2f [mV]\n', R3_absolute*( 10^3 ) )
% fprintf( 'c1 = %0.2f [nW]\n', c1_absolute*( 10^9 ) )
% fprintf( 'c2_absolute = %0.2f [nA]\n', c2_absolute*( 10^9 ) )
% fprintf( 'c3 = %0.2f [nW]\n', c3_absolute*( 10^9 ) )
% fprintf( 'delta1_absolute = %0.2f [mV]\n', delta1_absolute*( 10^3 ) )
% fprintf( 'delta2_absolute = %0.2f [mV]\n', delta2_absolute*( 10^3 ) )
% fprintf( 'dEs31 = %0.2f [mV]\n', dEs31_absolute*( 10^3 ) )
% fprintf( 'dEs32 = %0.2f [mV]\n', dEs32_absolute*( 10^3 ) )
% fprintf( 'gs31 = %0.2f [muS]\n', gs31_absolute*( 10^6 ) )
% fprintf( 'gs32 = %0.2f [muS]\n', gs32_absolute*( 10^6 ) )
% fprintf( 'Gm3 = %0.2f [muS]\n', Gm3_absolute*( 10^6 ) )
% fprintf( 'Iapp3 = %0.2f [nA]\n', Iapp3_absolute*( 10^9 ) )
% 
% % Create an instance of the network class.
% network_absolute = network_class( network_dt, network_tf );
% 
% % Create the network components.
% [ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 3 );
% [ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 2 );
% [ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 3 );
% 
% % Set the network parameters.
% network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, zeros( size( neuron_IDs_absolute ) ), 'Gna' );
% network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ R1_absolute, R2_absolute, R3_absolute ], 'R' );
% network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 3 ), Gm3_absolute, 'Gm' );
% 
% network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 1, 2 ], 'from_neuron_ID' );
% network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 3, 3 ], 'to_neuron_ID' );
% network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ gs31_absolute, gs32_absolute ], 'g_syn_max' );
% network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ dEs31_absolute, dEs32_absolute ], 'dE_syn' );
% 
% network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ 1, 2, 3 ], 'neuron_ID' );
% network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 1 ), 0*network_absolute.neuron_manager.neurons( 1 ).R*network_absolute.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 2 ), 0*network_absolute.neuron_manager.neurons( 2 ).R*network_absolute.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
% network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 3 ), Iapp3_absolute, 'I_apps' );


%% Define the Relative Multiplication Subnetwork Parameters.

% Define the relative multiplication subnetwork parameters.
R1_relative = 20e-3;
R2_relative = 20e-3;
R3_relative = 20e-3;
R4_relative = 20e-3;
c3_relative = 1e-6;
c6_relative = 1e-6;
delta1_relative = 1e-3;
delta2_relative = 2e-3;
dEs41_relative = 194e-3;

% Compute the network properties.
c1_relative = c3_relative;
c2_relative = ( ( R3_relative - delta1_relative )*c3_relative )/delta1_relative;
c4_relative = ( ( R3_relative - delta1_relative )*delta2_relative*c6_relative )/( R3_relative*delta2_relative - R4_relative*delta1_relative );
c5_relative = ( ( R4_relative - delta2_relative )*R3_relative*c6_relative )/( R3_relative*delta2_relative - R4_relative*delta1_relative );
gs32_relative = ( ( R3_relative - delta1_relative )*c3_relative )/delta1_relative;
gs41_relative = ( ( c6_relative^2 )*delta1_relative*delta2_relative + ( c4_relative - c6_relative )*c6_relative*R3_relative*delta2_relative )/( -c6_relative*delta1_relative*delta2_relative + c6_relative*dEs41_relative*delta1_relative + ( c6_relative - c4_relative )*R3_relative*delta2_relative );
gs43_relative = ( ( c4_relative - c6_relative )*c6_relative*R3_relative*dEs41_relative )/( -c6_relative*delta1_relative*delta2_relative + c6_relative*dEs41_relative*delta1_relative + ( c6_relative - c4_relative )*R3_relative*delta2_relative );
dEs32_relative = 0;
dEs43_relative = 0;
Gm3_relative = c3_relative;
Gm4_relative = c6_relative;
Ia3_relative = R3_relative*c3_relative;
Ia4_relative = 0;


%% Print the Relative Mutliplication Subnetwork Parameters.

% Print a summary of the relevant network parameters.
fprintf( '\n' )
fprintf( 'RELATIVE MULTIPLICATION NETWORK PARAMETERS:\n' )
fprintf( 'R1_relative = %0.2f [mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2_relative = %0.2f [mV]\n', R2_relative*( 10^3 ) )
fprintf( 'R3_relative = %0.2f [mV]\n', R3_relative*( 10^3 ) )
fprintf( 'R4_relative = %0.2f [mV]\n', R4_relative*( 10^3 ) )
fprintf( 'c1_relative = %0.2e [-]\n', c1_relative )
fprintf( 'c2_relative = %0.2e [-]\n', c2_relative )
fprintf( 'c3_relative = %0.2e [-]\n', c3_relative )
fprintf( 'c4_relative = %0.2e [-]\n', c4_relative )
fprintf( 'c5_relative = %0.2e [-]\n', c5_relative )
fprintf( 'c6_relative = %0.2e [-]\n', c6_relative )
fprintf( 'dEs41_relative = %0.2f [mV]\n', dEs41_relative*( 10^3 ) )
fprintf( 'dEs32_relative = %0.2f [mV]\n', dEs32_relative*( 10^3 ) )
fprintf( 'dEs43_relative = %0.2f [mV]\n', dEs43_relative*( 10^3 ) )
fprintf( 'gs41_relative = %0.2f [muS]\n', gs41_relative*( 10^6 ) )
fprintf( 'gs32_relative = %0.2f [muS]\n', gs32_relative*( 10^6 ) )
fprintf( 'gs43_relative = %0.2f [muS]\n', gs43_relative*( 10^6 ) )
fprintf( 'Gm3_relative = %0.2f [muS]\n', Gm3_relative*( 10^6 ) )
fprintf( 'Gm4_relative = %0.2f [muS]\n', Gm4_relative*( 10^6 ) )
fprintf( 'Ia3 = %0.2f [nA]\n', Ia3_relative*( 10^9 ) )
fprintf( 'Ia4 = %0.2f [nA]\n', Ia4_relative*( 10^9 ) )
fprintf( '\n' )


%% Create the Relative Multiplication Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs ] = network_relative.neuron_manager.create_neurons( 4 );
[ network_relative.synapse_manager, synapse_IDs ] = network_relative.synapse_manager.create_synapses( 3 );
[ network_relative.applied_current_manager, applied_current_IDs ] = network_relative.applied_current_manager.create_applied_currents( 4 );

% Set the network parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs, [ R1_relative, R2_relative, R3_relative, R4_relative ], 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( [ neuron_IDs( 3 ), neuron_IDs( 4 ) ], [ Gm3_relative, Gm4_relative ], 'Gm' );

network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2, 3 ], 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs, [ 4, 3, 4 ], 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs, [ gs41_relative, gs32_relative, gs43_relative ], 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs, [ dEs41_relative, dEs32_relative, dEs43_relative ], 'dE_syn' );

network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3, 4 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs( 3:4 ), [ Ia3_relative, Ia4_relative ], 'I_apps' );



% %% Create Relative Multiplication Subnetwork
% 
% % Set the necesary parameters.
% R1_relative = 20e-3;                                 % [V] Activation Domain
% R2_relative = 20e-3;                                 % [V] Activation Domain
% R3_relative = 20e-3;                                 % [V] Activation Domain
% c3_relative = 1e-6;                                  % [S] Multiplication Parameter 3
% delta1_relative = 1e-3;                              % [V] Inversion Offset
% delta2_relative = 2e-3;                              % [V] multiplication Offset
% dEs31_relative = 194e-3;                             % [V] Synaptic Reversal Potential
% 
% % Compute the necessary parameters.
% c1_relative = ( ( delta1_relative - R2_relative )*delta2_relative*c3_relative )/( delta1_relative*R3_relative - delta2_relative*R2_relative );                                                                           % [S] Multiplication Parameter 1
% c2_relative = ( ( R3_relative - delta2_relative )*R2_relative*c3_relative )/( R2_relative*delta2_relative - R3_relative*delta1_relative );                                                                               % [S] Multiplication Parameter 2
% gs31_relative = ( ( c3_relative^2 )*delta1_relative*delta2_relative + ( c1_relative - c3_relative )*c3_relative*R2_relative*delta2_relative )/( -c3_relative*delta1_relative*delta2_relative + c3_relative*dEs31_relative*delta1_relative + ( c3_relative - c1_relative )*R2_relative*delta2_relative );           % [S] Maximum Synaptic Conductance
% gs32_relative = ( ( c1_relative - c3_relative )*c3_relative*R2_relative*dEs31_relative )/( -c3_relative*delta1_relative*delta2_relative + c3_relative*dEs31_relative*delta1_relative + ( c3_relative - c1_relative )*R2_relative*delta2_relative );                                     % [S] Maximum Synaptic Conductance
% dEs32_relative = 0;                                                                                                                              % [V] Synaptic Reversal Potential
% Iapp3_relative = 0;                                                                                                                              % [A] Applied Current
% Gm3_relative = c3_relative;                                                                                                                               % [S] Membrane Conductance
% 
% % Print a summary of the relevant network parameters.
% fprintf( '\nRELATIVE DIVISION AFTER INVERSION SUBNETWORK PARAMETERS:\n' )
% fprintf( 'R1 = %0.2f [mV]\n', R1_relative*( 10^3 ) )
% fprintf( 'R2 = %0.2f [mV]\n', R2_relative*( 10^3 ) )
% fprintf( 'R3 = %0.2f [mV]\n', R3_relative*( 10^3 ) )
% fprintf( 'c1 = %0.2f [muS]\n', c1_relative*( 10^6 ) )
% fprintf( 'c2 = %0.2f [muS]\n', c2_relative*( 10^6 ) )
% fprintf( 'c3 = %0.2f [muS]\n', c3_relative*( 10^6 ) )
% fprintf( 'delta1 = %0.2f [mV]\n', delta1_relative*( 10^3 ) )
% fprintf( 'delta2 = %0.2f [mV]\n', delta2_relative*( 10^3 ) )
% fprintf( 'dEs31 = %0.2f [mV]\n', dEs31_relative*( 10^3 ) )
% fprintf( 'dEs32 = %0.2f [mV]\n', dEs32_relative*( 10^3 ) )
% fprintf( 'gs31 = %0.2f [muS]\n', gs31_relative*( 10^6 ) )
% fprintf( 'gs32_relative = %0.2f [muS]\n', gs32_relative*( 10^6 ) )
% fprintf( 'Gm3 = %0.2f [muS]\n', Gm3_relative*( 10^6 ) )
% fprintf( 'Iapp3 = %0.2f [nA]\n', Iapp3_relative*( 10^9 ) )
% 
% % Create an instance of the network class.
% network_relative = network_class( network_dt, network_tf );
% 
% % Create the network components.
% [ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 3 );
% [ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 2 );
% [ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 3 );
% 
% % Set the network parameters.
% network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, zeros( size( neuron_IDs_relative ) ), 'Gna' );
% network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ R1_relative, R2_relative, R3_relative ], 'R' );
% network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 3 ), Gm3_relative, 'Gm' );
% 
% network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 1, 2 ], 'from_neuron_ID' );
% network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 3, 3 ], 'to_neuron_ID' );
% network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ gs31_relative, gs32_relative ], 'g_syn_max' );
% network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ dEs31_relative, dEs32_relative ], 'dE_syn' );
% 
% network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ 1, 2, 3 ], 'neuron_ID' );
% network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 3 ), Iapp3_relative, 'I_apps' );


%% Load the Absolute & Relative Multiplication Subnetworks

% Load the simulation results.
absolute_multiplication_simulation_data = load( [ load_directory, '\', 'absolute_multiplication_subnetwork_error' ] );
relative_multiplication_simulation_data = load( [ load_directory, '\', 'relative_multiplication_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
Absolute_Applied_Currents1 = absolute_multiplication_simulation_data.Applied_Currents1;
Absolute_Applied_Currents2 = absolute_multiplication_simulation_data.Applied_Currents2;
Us_achieved_absolute = absolute_multiplication_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
Relative_Applied_Currents1 = relative_multiplication_simulation_data.Applied_Currents1;
Relative_Applied_Currents2 = relative_multiplication_simulation_data.Applied_Currents2;
Us_achieved_relative = relative_multiplication_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Multiplication Subnetwork Responses

% Compute the desired steady state output membrane voltage.
% Us_desired_absolute_output = ( c1_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*Us_achieved_absolute( :, :, 2 ) + c3_absolute );
% Us_desired_relative_output = ( c1_relative*R2_relative*R3_relative*Us_achieved_relative( :, :, 1 ) )./( c2_relative*R1_relative*Us_achieved_relative( :, :, 2 ) + R1_relative*R2_relative*c3_relative );

Us_desired_absolute_output = ( c2_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ).*Us_achieved_absolute( :, :, 2 ) + c3_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*c6_absolute*Us_achieved_absolute( :, :, 2 ) + c1_absolute*c5_absolute + c3_absolute*c6_absolute );
Us_desired_relative_output = ( c2_relative*c4_relative*R4_relative*Us_achieved_relative( :, :, 1 ).*Us_achieved_relative( :, :, 2 ) + c3_relative*c4_relative*R2_relative*R4_relative*Us_achieved_relative( :, :, 1 ) )./( c2_relative*c6_relative*R1_relative*Us_achieved_relative( :, :, 2 ) + ( c3_relative*c6_relative + c1_relative*c5_relative )*R1_relative*R2_relative );

% asdf =  ( c2_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ).*Us_achieved_absolute( :, :, 2 ) + c3_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*c6_absolute*Us_achieved_absolute( :, :, 2 ) + c1_absolute*c5_absolute + c3_absolute*c6_absolute );

% Generate desired steady state membrane voltage matrices.
Us_desired_absolute = Us_achieved_absolute; Us_desired_absolute( :, :, end ) = Us_desired_absolute_output;
Us_desired_relative = Us_achieved_relative; Us_desired_relative( :, :, end ) = Us_desired_relative_output;

% Compute the error between the achieved and desired results.
error_absolute = Us_achieved_absolute( :, :, end ) - Us_desired_absolute( :, :, end );
error_relative = Us_achieved_relative( :, :, end ) - Us_desired_relative( :, :, end );

% Compute the percent error between the achieve and desired results.
error_absolute_percent = 100*( error_absolute/R4_absolute );
error_relative_percent = 100*( error_relative/R4_relative );

% Compute the mean error.
mse_absolute = ( 1/numel( error_absolute ) )*sqrt( sum( error_absolute.^2, 'all' ) );
mse_relative = ( 1/numel( error_relative ) )*sqrt( sum( error_relative.^2, 'all' ) );

% Compute the mean error percentage.
mse_absolute_percent = 100*( mse_absolute/R4_absolute );
mse_relative_percent = 100*( mse_relative/R4_relative );

% Compute the standard deviation of the error.
std_absolute = std( error_absolute, 0, 'all' );
std_relative = std( error_relative, 0, 'all' );

% Compute the standard deviation of the error percentage.
std_absolute_percent = 100*( std_absolute/R4_absolute );
std_relative_percent = 100*( std_relative/R4_relative );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the maximum error percentages.
error_absolute_max_percent = 100*( error_absolute_max/R4_absolute );
error_relative_max_percent = 100*( error_relative_max/R4_relative );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the minimum error percentages.
error_absolute_min_percent = 100*( error_absolute_min/R4_absolute );
error_relative_min_percent = 100*( error_relative_min/R4_relative );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the range of the error percentages.
error_absolute_range_percent = 100*( error_absolute_range/R4_absolute );
error_relative_range_percent = 100*( error_relative_range/R4_relative );

% Compute the difference in error between the absolute and relative encoding schemes.
error_difference = abs( error_relative ) - abs( error_absolute );
error_difference_percent = abs( error_relative_percent ) - abs( error_absolute_percent );

% Compute the mean squared error difference.
error_difference_mse = abs( mse_relative ) - abs( mse_absolute );
error_difference_mse_percent = abs( mse_relative_percent ) - abs( mse_absolute_percent );

% Compute the standard deviation difference.
error_difference_std = abs( std_relative ) - abs( std_absolute );
error_difference_std_percent = abs( std_relative_percent ) - abs( std_absolute_percent );

% Compute the maximum error difference.
error_difference_max = abs( error_relative_max ) - abs( error_absolute_max );
error_difference_max_percent = abs( error_relative_max_percent ) - abs( error_absolute_max_percent );


%% Print Out the Summary Information

% Retrieve the absolute input voltage matrices.
Us1_achieved_absolute = Us_achieved_absolute( :, :, 1 );
Us2_achieved_absolute = Us_achieved_absolute( :, :, 2 );

% Retrieve the relative input voltage matrices.
Us1_achieved_relative = Us_achieved_relative( :, :, 1 );
Us2_achieved_relative = Us_achieved_relative( :, :, 2 );

% Print out the absolute multiplication summary statistics.
fprintf( 'Absolute Multiplication Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us1_achieved_absolute( index_absolute_max ), Us2_achieved_absolute( index_absolute_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us1_achieved_absolute( index_absolute_min ), Us2_achieved_absolute( index_absolute_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Relative Multiplication Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us1_achieved_relative( index_relative_max ), Us2_achieved_relative( index_relative_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us1_achieved_relative( index_relative_min ), Us2_achieved_relative( index_relative_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Absolute vs Relative Multiplication Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Plot the Steady State Multiplication Error Surfaces

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Absolute Multiplication Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Absolute_Multiplication_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Relative Multiplication Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Relative_Multiplication_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Multiplication Subnetwork Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on

surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.50 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.50 )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.50 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.50 )

legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -135, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Multiplication_Subnetwork_Steady_State_Response.png' ] )


% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Multiplication Subnetwork Steady State Error' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Multiplication_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Multiplication Subnetwork Steady State Error Percentage' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Multiplication_Subnetwork_Approximation_Error_Percentage_Comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative multiplication subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Multiplication Subnetwork Steady State Error Difference' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Multiplication_Subnetwork_Approximation_Error_Difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent multiplication subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Multiplication Subnetwork Steady State Error Percentage Difference' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
view( -135, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Multiplication_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

