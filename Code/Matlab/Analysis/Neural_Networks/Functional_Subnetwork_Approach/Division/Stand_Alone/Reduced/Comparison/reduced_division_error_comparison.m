%% Reduced Division Subnetwork Error Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options.

% Define the save and load directories.
save_directory = '.\Save';                                                              % [str] Save Directory.
load_directory = '.\Load';                                                              % [str] Load Directory.

% Define the network simulation time step.
% network_dt = 1e-3;                                                                    % [s] Simulation Time Step.
network_dt = 1e-5;                                                                      % [s] Simulation Time Step.

% Define the network simulation duration.
network_tf = 3;                                                                         % [s] Simulation Duration.


%% Define Basic Reduced Absolute Subnetwork Parameters.

% Set the maximum voltages.
R1_absolute = 20e-3;                                                                                                                        % [V] Maximum Voltage (Neuron 1)
R2_absolute = 20e-3;                                                                                                                        % [V] Maximum Voltage (Neuron 2)

% Set the membrane conductances.
Gm1_absolute = 1e-6;                                                                                                                        % [S] Membrane Conductance (Neuron 1)
Gm2_absolute = 1e-6;                                                                                                                      	% [S] Membrane Conductance (Neuron 2) 
Gm3_absolute = 1e-6;                                                                                                                        % [S] Membrane Conductance (Neuron 3) 

% Set the membrane capacitance.
Cm1_absolute = 5e-9;                                                                                                                        % [F] Membrane Capacitance (Neuron 1)
Cm2_absolute = 5e-9;                                                                                                                        % [F] Membrane Capacitance (Neuron 2)
Cm3_absolute = 5e-9;                                                                                                                        % [F] Membrane Capacitance (Neuron 3)

% Define the sodium channel conductances.
Gna1_absolute = 0;                                                                                                                          % [S] Sodium Channel Conductance (Neuron 1).
Gna2_absolute = 0;                                                                                                                          % [S] Sodium Channel Conductance (Neuron 2).
Gna3_absolute = 0;                                                                                                                          % [S] Sodium Channel Conductance (Neuron 3).

% Set the synaptic reversal potentials.
dEs31_absolute = 194e-3;                                                                                                                  	% [V] Synaptic Reversal Potential (Synapse 31).
dEs32_absolute = 0;                                                                                                                         % [V] Synaptic Reversal Potential (Synapse 32).

% Set the applied currents.
Ia1_absolute = R1_absolute*Gm1_absolute;                                                                                                    % [A] Applied Current (Neuron 1).
Ia2_absolute = R2_absolute*Gm2_absolute;                                                                                                    % [A] Applied Current (Neuron 2).
Ia3_absolute = 0;                                                                                                                           % [A] Applied Current (Neuron 3).

% Define the input current states.
current_state1_absolute = 0;                                                                                                                % [%] Applied Current Activity Percentage (Neuron 1). 
% current_state1_absolute = 1;                                                                                                            	% [%] Applied Current Activity Percentage (Neuron 1). 
current_state2_absolute = 0;                                                                                                                % [%] Applied Current Activity Percentage (Neuron 2). 
% current_state2_absolute = 1;                                                                                                            	% [%] Applied Current Activity Percentage (Neuron 2). 

% Set the network design parameters.
R3_absolute_target = 20e-3;                                                                                                                 % [V] Maximum Voltage Target (Neuron 3) (Used to compute c1 such that R3 will be set to the target value.)
delta_absolute = 1e-3;                                                                                                                      % [V] Membrane Voltage Offset.
c1_absolute = ( delta_absolute*R2_absolute*R3_absolute_target )/( R1_absolute*R3_absolute_target - delta_absolute*R1_absolute );            % [V^2] Design Constant 1.


%% Compute Reduced Absolute Division Subnetwork Derived Parameters.

% Compute the network design parameters.
c2_absolute = ( c1_absolute*R1_absolute - delta_absolute*R2_absolute )/( delta_absolute );                                                                      % [V] Absolute Division Parameter 2.

% Compute the maximum membrane voltages.
R3_absolute = c1_absolute*R1_absolute/c2_absolute;                                                                                                              % [V] Activation Domain.

% Compute the synaptic conductances.
gs31_absolute = ( R3_absolute*Gm3_absolute - Ia3_absolute )/( dEs31_absolute - R3_absolute );                                                                   % [S] Maximum Synaptic Conductance.
gs32_absolute = ( ( dEs31_absolute - delta_absolute )*gs31_absolute + Ia3_absolute - delta_absolute*Gm3_absolute )/( delta_absolute - dEs32_absolute );         % [S] Maximum Synaptic Conductance.


%% Print Reduced Absolute Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED ABSOLUTE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_absolute*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3_absolute*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_absolute*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_absolute*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3_absolute*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_absolute*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_absolute*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3_absolute*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_absolute*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_absolute*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs31 \t= \t%0.2f \t[mV]\n', dEs31_absolute*( 10^3 ) )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32_absolute*( 10^3 ) )

fprintf( 'gs31 \t= \t%0.2f \t[muS]\n', gs31_absolute*( 10^6 ) )
fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Current Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1_absolute*Ia1_absolute*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', current_state2_absolute*Ia2_absolute*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3_absolute*( 10^9 ) )
fprintf( '\n' )

% Print out design parameters.
fprintf( 'Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[mV]\n', c1_absolute*( 10^3 ) )
fprintf( 'c2 \t\t= \t%0.2f \t[mV]\n', c2_absolute*( 10^3 ) )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta_absolute*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Reduced Absolute Inversion Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 3 );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 2 );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 3 );

% Set the neuron parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ R1_absolute, R2_absolute, R3_absolute ], 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gm1_absolute, Gm2_absolute, Gm3_absolute ], 'Gm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Cm1_absolute, Cm2_absolute, Cm3_absolute ], 'Cm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gna1_absolute, Gna2_absolute, Gna3_absolute ], 'Gna' );

% Set the synapse parameters.
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 1, 2 ], 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 3, 3 ], 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ gs31_absolute, gs32_absolute ], 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ dEs31_absolute, dEs32_absolute ], 'dE_syn' );

% Set the applied current parameters.
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ 1, 2, 3 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_state1_absolute*Ia1_absolute, current_state2_absolute*Ia2_absolute, Ia3_absolute ], 'I_apps' );


%% Define Basic Reduced Relative Division Subnetwork Parameters.

% Define the maximum voltages.
R1_relative = 20e-3;                                                                   	% [V] Maximum Voltage (Neuron 1)
R2_relative = 20e-3;                                                                 	% [V] Maximum Voltage (Neuron 2)
R3_relative = 20e-3;                                                                   	% [V] Maximum Voltage (Neuron 3)

% Define the membrane conductances.
Gm1_relative = 1e-6;                                                                 	% [S] Membrane Conductance (Neuron 1)
Gm2_relative = 1e-6;                                                                  	% [S] Membrane Conductance (Neuron 2) 
Gm3_relative = 1e-6;                                                                    % [S] Membrane Conductance (Neuron 3) 

% Define the membrane capacitance.
Cm1_relative = 5e-9;                                                                 	% [F] Membrane Capacitance (Neuron 1)
Cm2_relative = 5e-9;                                                                    % [F] Membrane Capacitance (Neuron 2)
Cm3_relative = 5e-9;                                                                  	% [F] Membrane Capacitance (Neuron 3)

% Define the sodium channel conductances.
Gna1_relative = 0;                                                                    	% [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                                                     	% [S] Sodium Channel Conductance (Neuron 2).
Gna3_relative = 0;                                                                    	% [S] Sodium Channel Conductance (Neuron 3).

% Define the synaptic reversal potentials.
dEs31_relative = 194e-3;                                                               	% [V] Synaptic Reversal Potential (Synapse 31).
dEs32_relative = 0;                                                                  	% [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                                              	% [A] Applied Current (Neuron 1)
Ia2_relative = R2_relative*Gm2_relative;                                               	% [A] Applied Current (Neuron 2)
Ia3_relative = 0;                                                                      	% [A] Applied Current (Neuron 3)

% Define the current state.
current_state1_relative = 0;                                                            % [-] Current State (Neuron 1). (Specified as a ratio of the maximum applied current.)
% current_state1_relative = 1;                                                         	% [-] Current State (Neuron 1). (Specified as a ratio of the maximum applied current.)
current_state2_relative = 0;                                                        	% [-] Current State (Neuron 2). (Specified as a ratio of the maximum applied current.)
% current_state2_relative = 1;                                                         	% [-] Current State (Neuron 2). (Specified as a ratio of the maximum applied current.)

% Define the network design parameters.
delta_relative = 1e-3;                                                                   % [V] Membrane Voltage Offset.


%% Compute Reduced Relative Division Subnetwork Derived Parameters.

% Compute the design parameters.
c1_relative = delta_relative/( R3_relative - delta_relative );                                                                                                  % [-] Relative Division Parameter 1.
c2_relative = c1_relative;                                                                                                                                      % [-] Relative Division Parameter 2.

% Compute the maximum synaptic conductances.
gs31_relative = ( R3_relative*Gm3_relative - Ia3_relative )/( dEs31_relative - R3_relative );                                                                   % [S] Maximum Synaptic Conductance (Synapse 31).
gs32_relative = ( ( dEs31_relative - delta_relative )*gs31_relative + Ia3_relative - delta_relative*Gm3_relative )/( delta_relative - dEs32_relative );         % [S] Maximum Synaptic Conductance (Synapse 32).


%% Print Reduced Relative Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED RELATIVE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_relative*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3_relative*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_relative*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_relative*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3_relative*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_relative*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_relative*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3_relative*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_relative*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_relative*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3_relative*( 10^6 ) )
fprintf( '\n' )

% Print out synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs31 \t= \t%0.2f \t[mV]\n', dEs31_relative*( 10^3 ) )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32_relative*( 10^3 ) )

fprintf( 'gs31 \t= \t%0.2f \t[muS]\n', gs31_relative*( 10^6 ) )
fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32_relative*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Current Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1_relative*Ia1_relative*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', current_state2_relative*Ia2_relative*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3_relative*( 10^9 ) )
fprintf( '\n' )

% Print out design parameters.
fprintf( 'Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[-]\n', c1_relative )
fprintf( 'c2 \t\t= \t%0.2f \t[-]\n', c2_relative )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta_relative*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Reduced Relative Division Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 3 );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 2 );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 3 );

% Set the neuron parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ R1_relative, R2_relative, R3_relative ], 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gm1_relative, Gm2_relative, Gm3_relative ], 'Gm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Cm1_relative, Cm2_relative, Cm3_relative ], 'Cm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gna1_relative, Gna2_relative, Gna3_relative ], 'Gna' );

% Set the synapse parameters.
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 1, 2 ], 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 3, 3 ], 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ gs31_relative, gs32_relative ], 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ dEs31_relative, dEs32_relative ], 'dE_syn' );

% Set the applied current parameters.
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ 1, 2, 3 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_state1_relative*Ia1_relative, current_state2_relative*Ia2_relative, Ia3_relative ], 'I_apps' );


%% Load the Absolute & Relative Reduced Division Subnetworks.

% Load the simulation results.
absolute_division_simulation_data = load( [ load_directory, '\', 'absolute_division_subnetwork_error' ] );
relative_division_simulation_data = load( [ load_directory, '\', 'relative_division_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
Absolute_Applied_Currents1 = absolute_division_simulation_data.Applied_Currents1;
Absolute_Applied_Currents2 = absolute_division_simulation_data.Applied_Currents2;
Us_achieved_absolute = absolute_division_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
Relative_Applied_Currents1 = relative_division_simulation_data.Applied_Currents1;
Relative_Applied_Currents2 = relative_division_simulation_data.Applied_Currents2;
Us_achieved_relative = relative_division_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Reduced Division Subnetwork Responses.

% Compute the desired steady state output membrane voltage.
Us_desired_absolute_output = ( c1_absolute*Us_achieved_absolute( :, :, 1 ) )./( Us_achieved_absolute( :, :, 2 ) + c2_absolute );
Us_desired_relative_output = ( c1_relative*R2_relative*R3_relative*Us_achieved_relative( :, :, 1 ) )./( R1_relative*Us_achieved_relative( :, :, 2 ) + R1_relative*R2_relative*c2_relative );

% Generate desired steady state membrane voltage matrices.
Us_desired_absolute = Us_achieved_absolute; Us_desired_absolute( :, :, end ) = Us_desired_absolute_output;
Us_desired_relative = Us_achieved_relative; Us_desired_relative( :, :, end ) = Us_desired_relative_output;

% Compute the error between the achieved and desired results.
error_absolute = Us_achieved_absolute( :, :, end ) - Us_desired_absolute( :, :, end );
error_relative = Us_achieved_relative( :, :, end ) - Us_desired_relative( :, :, end );

% Compute the percent error between the achieve and desired results.
error_absolute_percent = 100*( error_absolute/R3_absolute );
error_relative_percent = 100*( error_relative/R3_relative );

% Compute the mean error.
mse_absolute = ( 1/numel( error_absolute ) )*sqrt( sum( error_absolute.^2, 'all' ) );
mse_relative = ( 1/numel( error_relative ) )*sqrt( sum( error_relative.^2, 'all' ) );

% Compute the mean error percentage.
mse_absolute_percent = 100*( mse_absolute/R3_absolute );
mse_relative_percent = 100*( mse_relative/R3_relative );

% Compute the standard deviation of the error.
std_absolute = std( error_absolute, 0, 'all' );
std_relative = std( error_relative, 0, 'all' );

% Compute the standard deviation of the error percentage.
std_absolute_percent = 100*( std_absolute/R3_absolute );
std_relative_percent = 100*( std_relative/R3_relative );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the maximum error percentages.
error_absolute_max_percent = 100*( error_absolute_max/R3_absolute );
error_relative_max_percent = 100*( error_relative_max/R3_relative );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the minimum error percentages.
error_absolute_min_percent = 100*( error_absolute_min/R3_absolute );
error_relative_min_percent = 100*( error_relative_min/R3_relative );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the range of the error percentages.
error_absolute_range_percent = 100*( error_absolute_range/R3_absolute );
error_relative_range_percent = 100*( error_relative_range/R3_relative );

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


%% Print Out the Reduced Division Error Summary Information.

% Retrieve the absolute input voltage matrices.
Us1_achieved_absolute = Us_achieved_absolute( :, :, 1 );
Us2_achieved_absolute = Us_achieved_absolute( :, :, 2 );

% Retrieve the relative input voltage matrices.
Us1_achieved_relative = Us_achieved_relative( :, :, 1 );
Us2_achieved_relative = Us_achieved_relative( :, :, 2 );

% Print out the absolute division summary statistics.
fprintf( 'Absolute Division Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us1_achieved_absolute( index_absolute_max ), Us2_achieved_absolute( index_absolute_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us1_achieved_absolute( index_absolute_min ), Us2_achieved_absolute( index_absolute_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Relative Division Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us1_achieved_relative( index_relative_max ), Us2_achieved_relative( index_relative_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us1_achieved_relative( index_relative_min ), Us2_achieved_relative( index_relative_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Absolute vs Relative Division Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Plot the Steady State Reduced Division Error Surfaces.

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute division subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Absolute Division Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Absolute_Division_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative division subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Relative Division Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Relative_Division_Subnetwork_Steady_State_Response.png' ] )

% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Reduced Division Subnetwork Steady State Response (Comparison)' )
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
% surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
% surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )

% surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'FaceColor', [ 1, 0.5, 0 ], 'Edgecolor', 'None', 'FaceAlpha', 0.75 )
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'FaceColor', [ 1, 0.2, 0.2 ], 'Edgecolor', 'None', 'FaceAlpha', 0.75 )
% surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'FaceColor', [ 0, 1, 0 ], 'Edgecolor', 'None', 'FaceAlpha', 0.75 )
% surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'FaceColor', [ 0.2, 0.2, 1 ], 'Edgecolor', 'None', 'FaceAlpha', 0.75 )

surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'FaceColor', 'r', 'Edgecolor', 'None', 'FaceAlpha', 0.50 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'FaceColor', 'b', 'Edgecolor', 'None', 'FaceAlpha', 0.50 )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'FaceColor', 'r', 'Edgecolor', 'None', 'FaceAlpha', 0.50 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'FaceColor', 'b', 'Edgecolor', 'None', 'FaceAlpha', 0.50 )

% legend( { 'Absolute Desired', 'Absolute Achieved', 'Relative Desired', 'Relative Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
saveas( fig, [ save_directory, '\', 'reduced_division_ss_response_comparison.png' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Reduced Division Subnetwork Steady State Error' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Division_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Reduced Division Subnetwork Steady State Error Percentage' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Division_Subnetwork_Approximation_Error_Percentage_Comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative division subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Reduced Division Subnetwork Steady State Error Difference' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Division_Subnetwork_Approximation_Error_Difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent division subnetworks.
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Reduced Division Subnetwork Steady State Error Percentage Difference' )
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Reduced_Division_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

