%% Reduced Multiplication Subnetwork Conversion Example.

% Clear Everything.
clear, close( 'all' ), clc


%% Set the Simulation Parameters.

% Define the network integration step size.
network_dt = 1.3e-4;                                                                                                    % [s] Simulation Step Size.

% Define the network simulation duration.
network_tf = 3;                                                                                                         % [s] Simulation Duration.

% Define the applied current state.
% current_state1 = 0;                                                                                                   % [0-1] Current Activation Ratio (Neuron 1). (0 = Input Current Completely Off, 1 = Input Current Completely On.)
% current_state1 = 0.25;                                                                                                % [0-1] Current Activation Ratio (Neuron 1). (0 = Input Current Completely Off, 1 = Input Current Completely On.)
current_state1 = 1;                                                                                                     % [0-1] Current Activation Ratio (Neuron 1). (0 = Input Current Completely Off, 1 = Input Current Completely On.)

% current_state2 = 0;                                                                                                   % [0-1] Current Activation Ratio (Neuron 2). (0 = Input Current Completely Off, 1 = Input Current Completely On.)
% current_state2 = 0.25;                                                                                                % [0-1] Current Activation Ratio (Neuron 2). (0 = Input Current Completely Off, 1 = Input Current Completely On.)
current_state2 = 1;                                                                                                     % [0-1] Current Activation Ratio (Neuron 2).(0 = Input Current Completely Off, 1 = Input Current Completely On.)


%% Define Basic Reduced Relative Multiplication Subnetwork Parameters.

% Define neuron maximum membrane voltages.
R1_relative = 20e-3;                                                                                                   	% [V] Maximum Membrane Voltage (Neuron 1).
R2_relative = 20e-3;                                                                                                   	% [V] Maximum Membrane Voltage (Neuron 2).
R3_relative = 20e-3;                                                                                                   	% [V] Maximum Membrane Voltage (Neuron 3).
R4_relative = 20e-3;                                                                                                  	% [V] Maximum Membrane Voltage (Neuron 4).

% Define the membrane conductances.
Gm1_relative = 1e-6;                                                                                                  	% [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                                                                                  	% [S] Membrane Conductance (Neuron 2).
Gm3_relative = 1e-6;                                                                                                   	% [S] Membrane Conductance (Neuron 3).
Gm4_relative = 1e-6;                                                                                                   	% [S] Membrane Conductance (Neuron 4).

% Define the membrane capacitances.
Cm1_relative = 5e-9;                                                                                                	% [F] Membrance Conductance (Neuron 1).
Cm2_relative = 5e-9;                                                                                                  	% [F] Membrance Conductance (Neuron 2).
Cm3_relative = 5e-9;                                                                                                   	% [F] Membrance Conductance (Neuron 3).
Cm4_relative = 5e-9;                                                                                                 	% [F] Membrance Conductance (Neuron 4).

% Define the sodium channel conductances.
Gna1_relative = 0;                                                                                                    	% [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                                                                                   	% [S] Sodium Channel Conductance (Neuron 2).
Gna3_relative = 0;                                                                                                    	% [S] Sodium Channel Conductance (Neuron 3).
Gna4_relative = 0;                                                                                                     	% [S] Sodium Channel Conductance (Neuron 4).

% Define the synaptic reversal potential.
dEs32_relative = 0;                                                                                                  	% [V] Synaptic Reversal Potential (Synapse 32).
dEs41_relative = 194e-3;                                                                                               	% [V] Synaptic Reversal Potential (Synapse 41).
dEs43_relative = 0;                                                                                                   	% [V] Synaptic Reversal Potential (Synapse 43).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                                                                             	% [A] Applied Current (Neuron 1).
Ia2_relative = R2_relative*Gm2_relative;                                                                              	% [A] Applied Current (Neuron 2).
Ia3_relative = R3_relative*Gm3_relative;                                                                               	% [A] Applied Current (Neuron 3).
Ia4_relative = 0;                                                                                                     	% [A] Applied Current (Neuron 4).

% Define the subnetwork voltage offsets.
delta1_relative = 1e-3;                                                                                              	% [V] Inversion Membrane Voltage Offset.
delta2_relative = 2e-3;                                                                                               	% [V] Division Membrane Voltage Offset.


%% Compute Derived Reduced Relative Multiplication Subnetwork Parameters.

% Compute the network design parameters.
c1_relative = delta1_relative/( R2_relative - delta1_relative );                                                                                                                                                                                        % [-] Reduced Relative Multiplication Design Constant 1 (Reduced Relative Inversion Design Constant 1).
c2_relative = c1_relative;                                                                                                                                                                                                                              % [-] Reduced Relative Multiplication Design Constant 2 (Reduced Relative Inversion Design Constant 2).
c3_relative = ( ( R3_relative - delta1_relative )*delta2_relative )/( ( R4_relative - delta2_relative )*R3_relative );                                                                                                                                  % [-] Reduced Relative Multiplication Design Constant 3 (Reduced Relative Division After Inversion Design Constant 1).
c4_relative = ( delta2_relative*R3_relative - delta1_relative*R4_relative )/( ( R4_relative - delta2_relative )*R3_relative );                                                                                                                          % [-] Reduced Relative Multiplication Design Constant 4 (Reduced Relative Division AFter Inversion Design Constant 2).

% Compute the synaptic conductances.
gs32_relative = ( Ia3_relative - delta1_relative*Gm3_relative )/( delta1_relative - dEs32_relative );                                                                                                                                                   % [S] Synaptic Conductance (Synapse 32).
gs41_relative = ( ( delta1_relative - R3_relative )*delta2_relative*R4_relative*Gm4_relative )/( ( R3_relative - delta1_relative )*delta2_relative*R4_relative + ( delta1_relative*R4_relative - delta2_relative*R3_relative )*dEs41_relative );        % [S] Synaptic Conductance (Synapse 41).
gs43_relative = ( ( delta2_relative - R4_relative )*R3_relative*Gm4_relative*dEs41_relative )/( ( R3_relative - delta1_relative )*delta2_relative*R4_relative + ( delta1_relative*R4_relative - delta2_relative*R3_relative )*dEs41_relative );      	% [S] Synaptic Conductance (Synapse 43).


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

fprintf( 'p1 \t\t= \t%0.0f \t\t[-]\n', current_state1 )
fprintf( 'p2 \t\t= \t%0.0f \t\t[-]\n', current_state2 )
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
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_state1*Ia1_relative, current_state2*Ia2_relative, Ia3_relative, Ia4_relative ], 'I_apps' );


%% Compute the Relative Multiplication Numerical Stability Analysis Parameters.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network_relative.RK4_stability_analysis( cell2mat( network_relative.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network_relative.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network_relative.neuron_manager.get_neuron_property( 'all', 'R' ) ), network_relative.get_gsynmaxs( 'all' ), network_relative.get_dEsyns( 'all' ), zeros( network_relative.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Convert the Relative Multiplication Parameters to Fundamental Absolute Multiplication Parameters.

% Convert the maximum membrane voltages.
R1_absolute = R1_relative;                                                                                                                                  % [V] Maximum Membrane Voltage (Neuron 1).
R2_absolute = R2_relative;                                                                                                                                 	% [V] Maximum Membrane Voltage (Neuron 2).
R3_absolute = R3_relative;                                                                                                                                  % [V] Maximum Membrane Voltage (Neuron 3).
R4_absolute = R4_relative;                                                                                                                                  % [V] Maximum Membrane Voltage (Neuron 4).

% Convert the membrane conductances.
Gm1_absolute = Gm1_relative;                                                                                                                                % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = Gm2_relative;                                                                                                                                % [S] Membrane Conductance (Neuron 2).
Gm3_absolute = Gm3_relative;                                                                                                                                % [S] Membrane Conductance (Neuron 3).
Gm4_absolute = Gm4_relative;                                                                                                                                % [S] Membrane Conductance (Neuron 4).

% Convert the membrane capacitances.
Cm1_absolute = Cm1_relative;                                                                                                                                % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = Cm2_relative;                                                                                                                                % [F] Membrane Capacitance (Neuron 2).
Cm3_absolute = Cm3_relative;                                                                                                                                % [F] Membrane Capacitance (Neuron 3).
Cm4_absolute = Cm4_relative;                                                                                                                                % [F] Membrane Capacitance (Neuron 4).

% Convert the sodium channel conductances.
Gna1_absolute = Gna1_relative;                                                                                                                              % [S] Sodium Channel Conductance (Neuron 1).
Gna2_absolute = Gna2_relative;                                                                                                                           	% [S] Sodium Channel Conductance (Neuron 2).
Gna3_absolute = Gna3_relative;                                                                                                                              % [S] Sodium Channel Conductance (Neuron 3).
Gna4_absolute = Gna4_relative;                                                                                                                              % [S] Sodium Channel Conductance (Neuron 4).

% Define the synaptic reversal potentials.
dEs32_absolute = dEs32_relative;                                                                                                                           	% [V] Synaptic Reversal Potential (Synapse 32).
dEs41_absolute = dEs41_relative;                                                                                                                          	% [V] Synaptic Reversal Potential (Synapse 41).
dEs43_absolute = dEs43_relative;                                                                                                                         	% [V] Synaptic Reversal Potential (Synapse 43).

% Define the applied currents.
Ia1_absolute = Ia1_relative;                                                                                                                                % [A] Applied Current (Neuron 1).
Ia2_absolute = Ia2_relative;                                                                                                                                % [A] Applied Current (Neuron 2).
Ia3_absolute = Ia3_relative;                                                                                                                              	% [A] Applied Current (Neuron 3).
Ia4_absolute = Ia4_relative;                                                                                                                              	% [A] Applied Current (Neuron 4).

% Convert the voltage offsets.
delta1_absolute = delta1_relative;                                                                                                                          % [V] Inversion Membrane Voltage Offset.
delta2_absolute = delta2_relative;                                                                                                                          % [V] Division Membrane Voltage Offset.

% Convert the design constants.
c1_absolute = ( R2_relative*R3_relative*delta1_relative )/( R3_relative - delta1_relative );                                                              	% [V^2] Design Constant 1.
c3_absolute = ( ( delta1_absolute - R3_absolute )*delta2_absolute*R4_absolute )/( ( delta2_absolute - R4_absolute )*R1_absolute );                          % [V] Design Constant 1.


%% Compute the Derived Parameters of the Absolute Multiplication Subnetwork.

% Compute the network design parameters.
c2_absolute = ( c1_absolute - delta1_absolute*R2_absolute )/delta1_absolute;                                                                                                                                                                              % [V] Reduced Relative Multiplication Design Constant 2 (Reduced Relative Inversion Design Constant 2).
c4_absolute = ( R1_absolute*c3_absolute - delta2_absolute*R3_absolute )/( delta2_absolute );                                                                                                                                                            % [A] Reduced Relative Multiplication Design Constant 4 (Reduced Relative Division After Inversion Design Constant 2).

% Compute the maximum membrane voltages.
R3_absolute = c1_absolute/c2_absolute;                                                                                                                                                                                                                  % [V] Maximum Membrane Voltage (Neuron 3).
R4_absolute = ( R1_absolute*c3_absolute )/( delta1_absolute + c4_absolute );                                                                                                                                                                            % [V] Maximum Membrane Voltage (Neuron 4).

% Compute the synaptic conductances.
gs32_absolute = ( R2_absolute*Ia3_absolute )/( c1_absolute - c2_absolute*dEs32_absolute );                                                                                                                                                            	% [S] Maximum Synaptic Conductance (Synapse 32).
gs41_absolute = ( ( delta1_absolute - R3_absolute )*delta2_absolute*R4_absolute*Gm4_absolute )/( ( R3_absolute - delta1_absolute )*delta2_absolute*R4_absolute + ( R4_absolute*delta1_absolute - R3_absolute*delta2_absolute )*dEs41_absolute );        % [S] Maximum Synaptic Conductance (Synapse 41).
gs43_absolute = ( ( delta2_absolute - R4_absolute )*dEs41_absolute*R3_absolute*Gm4_absolute )/( ( R3_absolute - delta1_absolute )*delta2_absolute*R4_absolute + ( R4_absolute*delta1_absolute - R3_absolute*delta2_absolute )*dEs41_absolute );         % [S] Maximum Synaptic Conductance (Synapse 43).


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

fprintf( 'p1 \t\t= \t%0.0f \t\t[-]\n', current_state1 )
fprintf( 'p2 \t\t= \t%0.0f \t\t[-]\n', current_state2 )
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
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_state1*Ia1_absolute, current_state2*Ia2_absolute, Ia3_absolute, Ia4_absolute ], 'I_apps' );


%% Compute the Reduced Absolute Multiplication Numerical Stability Analysis Parameters.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network_absolute.RK4_stability_analysis( cell2mat( network_absolute.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network_absolute.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network_absolute.neuron_manager.get_neuron_property( 'all', 'R' ) ), network_absolute.get_gsynmaxs( 'all' ), network_absolute.get_dEsyns( 'all' ), zeros( network_absolute.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Simulate the Reduced Relative Multiplication Subnetwork Results.

% Start the timer.
tic

% Simulate the network.
[ network_relative, ts_relative, Us_relative, hs_relative, dUs_relative, dhs_relative, G_syns_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, m_infs_relative, h_infs_relative, tauhs_relative, neuron_IDs_relative ] = network_relative.compute_set_simulation(  );

% End the timer.
toc


%% Simulate the Reduced Absolute Multiplication Subnetwork Results.

% Start the timer.
tic

% Simulate the network.
[ network_absolute, ts_absolute, Us_absolute, hs_absolute, dUs_absolute, dhs_absolute, G_syns_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, m_infs_absolute, h_infs_absolute, tauhs_absolute, neuron_IDs_absolute ] = network_absolute.compute_set_simulation(  );

% End the timer.
toc


%% Plot the Reduced Absolute Multiplication Subnetwork Results.

% Plot the network currents over time.
fig_relative_network_currents = network_relative.network_utilities.plot_network_currents( ts_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, neuron_IDs_relative );
fig_absolute_network_currents = network_absolute.network_utilities.plot_network_currents( ts_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, neuron_IDs_absolute );

% Plot the network states over time.
fig_relative_network_states = network_relative.network_utilities.plot_network_states( ts_relative, Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_states = network_absolute.network_utilities.plot_network_states( ts_absolute, Us_absolute, hs_absolute, neuron_IDs_absolute );

% Animate the network states over time.
fig_relative_network_animation = network_relative.network_utilities.animate_network_states( Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_animation = network_absolute.network_utilities.animate_network_states( Us_absolute, hs_absolute, neuron_IDs_absolute );


