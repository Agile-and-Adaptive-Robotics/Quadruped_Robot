%% Multiplication Subnetwork Encoding Comparison

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                                                                                      % [str] Save Directory.
load_directory = '.\Load';                                                                                      % [str] Load Directory.

% Define the network integration step size.
network_dt = 1e-5;                                                                                              % [s] Network Integration Timestep.

% Define network simulation duration.
network_tf = 3;                                                                                                 % [s] Network Simulation Duration.


%% Define Basic Reduced Absolute Multiplication Subnetwork Parameters.

% Define neuron maximum membrane voltages.
R1_absolute = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 1).
R2_absolute = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 2).
R3_target_absolute = 20e-3;                                                                                              % [V] Maximum Membrane Voltage Target (Neuron 3).
R4_target_absolute = 20e-3;                                                                                              % [V] Maximum Membrane Voltage Target (Neuron 4).

% Define the membrane conductances.
Gm1_absolute = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 2).
Gm3_absolute = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 3).
Gm4_absolute = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 4).

% Define the membrane capacitances.
Cm1_absolute = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 1).
Cm2_absolute = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 2).
Cm3_absolute = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 3).
Cm4_absolute = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 4).

% Define the sodium channel conductances.
Gna1_absolute = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 1).
Gna2_absolute = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 2).
Gna3_absolute = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 3).
Gna4_absolute = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 4).

% Define the synaptic reversal potential.
dEs32_absolute = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 32).
dEs41_absolute = 194e-3;                                                                                                 % [V] Synaptic Reversal Potential (Synapse 41).
dEs43_absolute = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 43).

% Define the applied currents.
Ia1_absolute = R1_absolute*Gm1_absolute;                                                                                                   % [A] Applied Current (Neuron 1).
Ia2_absolute = R2_absolute*Gm2_absolute;                                                                                                   % [A] Applied Current (Neuron 2).
Ia3_absolute = R3_target_absolute*Gm3_absolute;                                                                                         	% [A] Applied Current (Neuron 3).
Ia4_absolute = 0;                                                                                                        % [A] Applied Current (Neuron 4).

% Define the input current states.
% current_state1_absolute = 0;                                                                                             % [%] Applied Current Activity Percentage (Neuron 1). 
current_state1_absolute = 1;                                                                                           % [%] Applied Current Activity Percentage (Neuron 1). 
% current_state2_absolute = 0;                                                                                           % [%] Applied Current Activity Percentage (Neuron 2). 
current_state2_absolute = 1;                                                                                             % [%] Applied Current Activity Percentage (Neuron 2). 

% Define the subnetwork voltage offsets.
delta1_absolute = 1e-3;                                                                                                  % [V] Inversion Membrane Voltage Offset.
delta2_absolute = 2e-3;                                                                                                  % [V] Division Membrane Voltage Offset.

% Define subnetwork design constants.
c1_absolute = ( delta1_absolute*R2_absolute*R3_target_absolute )/( R3_target_absolute - delta1_absolute );                                                            % [V^2] Reduced Absolute Multiplication Design Parameter 1 (Reduced Absolute Inversion Design Parameter 1).
c3_absolute = ( ( delta1_absolute - R3_target_absolute )*delta2_absolute*R4_target_absolute )/( ( delta2_absolute - R4_target_absolute )*R1_absolute );                                 % [V] Reduced Absolute Multiplication Design Parameter 3 (Reduced Absolute Division Design Parameter 1)


%% Compute Derived Reduced Absolute Mutliplication Subnetwork Constraints.

% Compute the network design parameters.
c2_absolute = ( c1_absolute - delta1_absolute*R1_absolute )/delta1_absolute;                                                                                 % [V] Design Constant 2.
c4_absolute = ( R1_absolute*c3_absolute - delta2_absolute*R3_target_absolute )/( delta2_absolute );                                                                	% [A] Absolute Division Parameter 2.

% Compute the maximum membrane voltages.
R3_absolute = c1_absolute/c2_absolute;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 2).
R4_absolute = ( R1_absolute*c3_absolute )/( delta1_absolute + c4_absolute );                                                                                 % [V] Maximum Membrane Voltage (Neuron 3).

% Compute the synaptic conductances.
gs32_absolute = ( R2_absolute*Ia3_absolute )/( c1_absolute - c2_absolute*dEs32_absolute );                                                                            % [S] Synaptic Conductance (Synapse 21)
gs41_absolute = ( ( delta1_absolute - R3_absolute )*delta2_absolute*R4_absolute*Gm4_absolute )/( ( R3_absolute - delta1_absolute )*delta2_absolute*R4_absolute + ( R4_absolute*delta1_absolute - R3_absolute*delta2_absolute )*dEs41_absolute );       % [S] Maximum Synaptic Conductance (Synapse 41).
gs43_absolute = ( ( delta2_absolute - R4_absolute )*dEs41_absolute*R3_absolute*Gm4_absolute )/( ( R3_absolute - delta1_absolute )*delta2_absolute*R4_absolute + ( R4_absolute*delta1_absolute - R3_absolute*delta2_absolute )*dEs41_absolute );        % [S] Maximum Synaptic Conductance (Synapse 32).


%% Print Reduced Absolute Multiplication Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED ABSOLUTE MULTIPLICATION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_absolute*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3_absolute*( 10^3 ) )
fprintf( 'R4 \t\t= \t%0.2f \t[mV]\n', R4_absolute*( 10^3 ) )
fprintf( '\n' )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_absolute*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_absolute*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3_absolute*( 10^6 ) )
fprintf( 'Gm4 \t= \t%0.2f \t[muS]\n', Gm4_absolute*( 10^6 ) )
fprintf( '\n' )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_absolute*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_absolute*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3_absolute*( 10^9 ) )
fprintf( 'Cm4 \t= \t%0.2f \t[nF]\n', Cm4_absolute*( 10^9 ) )
fprintf( '\n' )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_absolute*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_absolute*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3_absolute*( 10^6 ) )
fprintf( 'Gna4 \t= \t%0.2f \t[muS]\n', Gna4_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32_absolute*( 10^3 ) )
fprintf( 'dEs41 \t= \t%0.2f \t[mV]\n', dEs41_absolute*( 10^3 ) )
fprintf( 'dEs43 \t= \t%0.2f \t[mV]\n', dEs43_absolute*( 10^3 ) )
fprintf( '\n' )

fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32_absolute*( 10^6 ) )
fprintf( 'gs41 \t= \t%0.2f \t[muS]\n', gs41_absolute*( 10^6 ) )
fprintf( 'gs43 \t= \t%0.2f \t[muS]\n', gs43_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', Ia1_absolute*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2_absolute*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3_absolute*( 10^9 ) )
fprintf( 'Ia4 \t= \t%0.2f \t[nA]\n', Ia4_absolute*( 10^9 ) )
fprintf( '\n' )

fprintf( 'p1 \t\t= \t%0.0f \t\t[-]\n', current_state1_absolute )
fprintf( 'p2 \t\t= \t%0.0f \t\t[-]\n', current_state2_absolute )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[mV^2]\n', c1_absolute*( 10^6 ) )
fprintf( 'c2 \t\t= \t%0.2f \t[mV]\n', c2_absolute*( 10^3 ) )
fprintf( 'c3 \t\t= \t%0.2f \t[mV]\n', c3_absolute*( 10^3 ) )
fprintf( 'c4 \t\t= \t%0.2f \t[mV]\n', c4_absolute*( 10^3 ) )
fprintf( '\n' )

fprintf( 'delta1 \t= \t%0.2f \t[mV]\n', delta1_absolute*( 10^3 ) )
fprintf( 'delta2 \t= \t%0.2f \t[mV]\n', delta2_absolute*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create a Reduced Absolute Multiplication Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 4 );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 3 );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 4 );

% Set the neuron parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ R1_absolute, R2_absolute, R3_absolute, R4_absolute ], 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gm1_absolute, Gm2_absolute, Gm3_absolute, Gm4_absolute ], 'Gm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Cm1_absolute, Cm2_absolute, Cm3_absolute, Cm4_absolute ], 'Cm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gna1_absolute, Gna2_absolute, Gna3_absolute, Gna4_absolute ], 'Gna' );

% Set the synapse parameters.
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 2, 1, 3 ], 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 3, 4, 4 ], 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ gs32_absolute, gs41_absolute, gs43_absolute ], 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ dEs32_absolute, dEs41_absolute, dEs43_absolute ], 'dE_syn' );

% Set the applied current parameters.
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ 1, 2, 3, 4 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_state1_absolute*Ia1_absolute, current_state2_absolute*Ia2_absolute, Ia3_absolute, Ia4_absolute ], 'I_apps' );


%% Define Basic Reduced Relative Multiplication Subnetwork Parameters.

% Define neuron maximum membrane voltages.
R1_relative = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 1).
R2_relative = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 2).
R3_relative = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 3).
R4_relative = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 4).

% Define the membrane conductances.
Gm1_relative = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 2).
Gm3_relative = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 3).
Gm4_relative = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 4).

% Define the membrane capacitances.
Cm1_relative = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 1).
Cm2_relative = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 2).
Cm3_relative = 5e-9;                                                                                                 	% [F] Membrance Conductance (Neuron 3).
Cm4_relative = 5e-9;                                                                                                 	% [F] Membrance Conductance (Neuron 4).

% Define the sodium channel conductances.
Gna1_relative = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                                                                                   	% [S] Sodium Channel Conductance (Neuron 2).
Gna3_relative = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 3).
Gna4_relative = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 4).

% Define the synaptic reversal potential.
dEs32_relative = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 32).
dEs41_relative = 194e-3;                                                                                                 % [V] Synaptic Reversal Potential (Synapse 41).
dEs43_relative = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 43).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                                                                                                   % [A] Applied Current (Neuron 1).
Ia2_relative = R2_relative*Gm2_relative;                                                                                                   % [A] Applied Current (Neuron 2).
Ia3_relative = R3_relative*Gm3_relative;                                                                                                   % [A] Applied Current (Neuron 3).
Ia4_relative = 0;                                                                                                        % [A] Applied Current (Neuron 4).

% Define the input current states.
% current_state1_relative = 0;                                                                                             % [%] Applied Current Activity Percentage (Neuron 1). 
current_state1_relative = 1;                                                                                        	% [%] Applied Current Activity Percentage (Neuron 1). 
% current_state2_relative = 0;                                                                                          	% [%] Applied Current Activity Percentage (Neuron 2). 
current_state2_relative = 1;                                                                                         	% [%] Applied Current Activity Percentage (Neuron 2). 

% Define the subnetwork voltage offsets.
delta1_relative = 1e-3;                                                                                                  % [V] Inversion Membrane Voltage Offset.
delta2_relative = 2e-3;                                                                                                  % [V] Division Membrane Voltage Offset.


%% Compute Derived Reduced Relative Multiplication Subnetwork Parameters.

% Compute the network design parameters.
c1_relative = delta1_relative/( R2_relative - delta1_relative );                                                                                     % [-] Reduced Relative Multiplication Design Constant 1 (Reduced Relative Inversion Design Constant 1).
c2_relative = c1_relative;                                                                                                        % [-] Reduced Relative Multiplication Design Constant 2 (Reduced Relative Inversion Design Constant 2).
c3_relative = ( ( R3_relative - delta1_relative )*delta2_relative )/( ( R4_relative - delta2_relative )*R3_relative );                                                     	% [-] Reduced Relative Multiplication Design Constant 3 (Reduced Relative Division After Inversion Design Constant 1).
c4_relative = ( delta2_relative*R3_relative - delta1_relative*R4_relative )/( ( R4_relative - delta2_relative )*R3_relative );                                                        	% [-] Reduced Relative Multiplication Design Constant 4 (Reduced Relative Division AFter Inversion Design Constant 2).

% Compute the synaptic conductances.
gs32_relative = ( Ia3_relative - delta1_relative*Gm3_relative )/( delta1_relative - dEs32_relative );                                                                 % [S] Synaptic Conductance (Synapse 32).
gs41_relative = ( ( delta1_relative - R3_relative )*delta2_relative*R4_relative*Gm4_relative )/( ( R3_relative - delta1_relative )*delta2_relative*R4_relative + ( delta1_relative*R4_relative - delta2_relative*R3_relative )*dEs41_relative );       % [S] Synaptic Conductance (Synapse 41).
gs43_relative = ( ( delta2_relative - R4_relative )*R3_relative*Gm4_relative*dEs41_relative )/( ( R3_relative - delta1_relative )*delta2_relative*R4_relative + ( delta1_relative*R4_relative - delta2_relative*R3_relative )*dEs41_relative );        % [S] Synaptic Conductance (Synapse 43).


%% Print Reduced Relative Multiplication Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED RELATIVE MULTIPLICATION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_relative*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3_relative*( 10^3 ) )
fprintf( 'R4 \t\t= \t%0.2f \t[mV]\n', R4_relative*( 10^3 ) )
fprintf( '\n' )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_relative*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_relative*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3_relative*( 10^6 ) )
fprintf( 'Gm4 \t= \t%0.2f \t[muS]\n', Gm4_relative*( 10^6 ) )
fprintf( '\n' )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_relative*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_relative*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3_relative*( 10^9 ) )
fprintf( 'Cm4 \t= \t%0.2f \t[nF]\n', Cm4_relative*( 10^9 ) )
fprintf( '\n' )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_relative*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_relative*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3_relative*( 10^6 ) )
fprintf( 'Gna4 \t= \t%0.2f \t[muS]\n', Gna4_relative*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32_relative*( 10^3 ) )
fprintf( 'dEs41 \t= \t%0.2f \t[mV]\n', dEs41_relative*( 10^3 ) )
fprintf( 'dEs43 \t= \t%0.2f \t[mV]\n', dEs43_relative*( 10^3 ) )
fprintf( '\n' )

fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32_relative*( 10^6 ) )
fprintf( 'gs41 \t= \t%0.2f \t[muS]\n', gs41_relative*( 10^6 ) )
fprintf( 'gs43 \t= \t%0.2f \t[muS]\n', gs43_relative*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', Ia1_relative*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2_relative*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3_relative*( 10^9 ) )
fprintf( 'Ia4 \t= \t%0.2f \t[nA]\n', Ia4_relative*( 10^9 ) )
fprintf( '\n' )

fprintf( 'p1 \t\t= \t%0.0f \t\t[-]\n', current_state1_relative )
fprintf( 'p2 \t\t= \t%0.0f \t\t[-]\n', current_state2_relative )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[-]\n', c1_relative )
fprintf( 'c2 \t\t= \t%0.2f \t[-]\n', c2_relative )
fprintf( 'c3 \t\t= \t%0.2f \t[-]\n', c3_relative )
fprintf( 'c4 \t\t= \t%0.2f \t[-]\n', c4_relative )
fprintf( '\n' )

fprintf( 'delta1 \t= \t%0.2f \t[mV]\n', delta1_relative*( 10^3 ) )
fprintf( 'delta2 \t= \t%0.2f \t[mV]\n', delta2_relative*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create a Relative Multiplication Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 4 );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 3 );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 4 );

% Set the neuron parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ R1_relative, R2_relative, R3_relative, R4_relative ], 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gm1_relative, Gm2_relative, Gm3_relative, Gm4_relative ], 'Gm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Cm1_relative, Cm2_relative, Cm3_relative, Cm4_relative ], 'Cm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gna1_relative, Gna2_relative, Gna3_relative, Gna4_relative ], 'Gna' );

% Set the synapse parameters.
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 2, 1, 3 ], 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 3, 4, 4 ], 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ gs32_relative, gs41_relative, gs43_relative ], 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ dEs32_relative, dEs41_relative, dEs43_relative ], 'dE_syn' );

% Set the applied current parameters.
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ 1, 2, 3, 4 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_state1_relative*Ia1_relative, current_state2_relative*Ia2_relative, Ia3_relative, Ia4_relative ], 'I_apps' );


%% Load the Absolute & Relative Multiplication Subnetworks.

% Load the simulation results.
absolute_multiplication_simulation_data = load( [ load_directory, '\', 'reduced_absolute_multiplication_error' ] );
relative_multiplication_simulation_data = load( [ load_directory, '\', 'reduced_relative_multiplication_error' ] );

% Store the absolute simulation results in separate variables.
Absolute_Applied_Currents1 = absolute_multiplication_simulation_data.Applied_Currents1;
Absolute_Applied_Currents2 = absolute_multiplication_simulation_data.Applied_Currents2;
Us_achieved_absolute = absolute_multiplication_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
Relative_Applied_Currents1 = relative_multiplication_simulation_data.Applied_Currents1;
Relative_Applied_Currents2 = relative_multiplication_simulation_data.Applied_Currents2;
Us_achieved_relative = relative_multiplication_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Multiplication Subnetwork Responses.

% Compute the desired steady state output membrane voltage.
% Us_desired_absolute_output = ( c1_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*Us_achieved_absolute( :, :, 2 ) + c3_absolute );
% Us_desired_relative_output = ( c1_relative*R2_relative*R3_relative*Us_achieved_relative( :, :, 1 ) )./( c2_relative*R1_relative*Us_achieved_relative( :, :, 2 ) + R1_relative*R2_relative*c3_relative );

% Us_desired_absolute_output = ( c2_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ).*Us_achieved_absolute( :, :, 2 ) + c3_absolute*c4_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*c6_absolute*Us_achieved_absolute( :, :, 2 ) + c1_absolute*c5_absolute + c3_absolute*c6_absolute );
% Us_desired_relative_output = ( c2_relative*c4_relative*R4_relative*Us_achieved_relative( :, :, 1 ).*Us_achieved_relative( :, :, 2 ) + c3_relative*c4_relative*R2_relative*R4_relative*Us_achieved_relative( :, :, 1 ) )./( c2_relative*c6_relative*R1_relative*Us_achieved_relative( :, :, 2 ) + ( c3_relative*c6_relative + c1_relative*c5_relative )*R1_relative*R2_relative );

Us_desired_absolute_output =  ( c3_absolute*Us_achieved_absolute( :, :, 1 ).*Us_achieved_absolute( :, :, 2 ) + c2_absolute*c3_absolute*Us_achieved_absolute( :, :, 1 ) )./( c4_absolute*Us_achieved_absolute( :, :, 2 ) + c2_absolute*c4_absolute + c1_absolute );
Us_desired_relative_output =  ( c3_relative*R3_relative*R4_relative*Us_achieved_relative( :, :, 1 ).*Us_achieved_relative( :, :, 2 ) + c2_relative*c3_relative*R2_relative*R3_relative*R4_relative*Us_achieved_relative( :, :, 1 ) )./( c4_relative*R1_relative*R3_relative*Us_achieved_relative( :, :, 2 ) + ( c2_relative*c4_relative + c1_relative )*R1_relative*R2_relative*R3_relative );


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


%% Print Out the Multiplication Summary Information.

% Retrieve the absolute input voltage matrices.
Us1_achieved_absolute = Us_achieved_absolute( :, :, 1 );
Us2_achieved_absolute = Us_achieved_absolute( :, :, 2 );

% Retrieve the relative input voltage matrices.
Us1_achieved_relative = Us_achieved_relative( :, :, 1 );
Us2_achieved_relative = Us_achieved_relative( :, :, 2 );

% Print out the absolute multiplication summary statistics.
fprintf( 'Reduced Absolute Multiplication Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us1_achieved_absolute( index_absolute_max ), Us2_achieved_absolute( index_absolute_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us1_achieved_absolute( index_absolute_min ), Us2_achieved_absolute( index_absolute_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Reduced Relative Multiplication Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us1_achieved_relative( index_relative_max ), Us2_achieved_relative( index_relative_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us1_achieved_relative( index_relative_min ), Us2_achieved_relative( index_relative_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Reduced Absolute vs Relative Multiplication Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Plot the Steady State Multiplication Error Surfaces.

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Absolute Multiplication Steady State Response (Comparison)' )
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_ss_response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Relative Multiplication Steady State Response (Comparison)' )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_relative_multiplication_ss_response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative multiplication subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Multiplication Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.50 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.50 )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.50 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.50 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -135, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_multiplication_ss_response.png' ] )


% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Reduced Multiplication Steady State Error' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_multiplication_error_comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Reduced Multiplication Steady State Error Percentage' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_multiplication_error_percentage_comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative multiplication subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Reduced Multiplication Steady State Error Difference' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_multiplication_error_difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent multiplication subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Reduced Multiplication Steady State Error Percentage Difference' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
view( -135, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'reduced_multiplication_error_percentage_difference.png' ] )

