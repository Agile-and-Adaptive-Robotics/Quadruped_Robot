%% Reduced Inversion Subnetwork Encoding Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options.

% Define the save and load directories.
save_directory = '.\Save';                                                                                              % [str] Save Directory.
load_directory = '.\Load';                                                                                              % [str] Load Directory.

% Define the network simulation time step.
network_dt = 1e-3;                                                                                                      % [s] Simulation Time Step.

% Define the network simulation duration.
network_tf = 3;                                                                                                         % [s] Simulation Duration.


%% Define Reduced Absolute Inversion Subnetwork Parameters.

% Define the maximum membrane voltages.
R1_absolute = 20e-3;                                                                                                    % [V] Maximum Membrane Voltage (Neuron 1).

% Define the membrane conductances.
Gm1_absolute = 1e-6;                                                                                                    % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                                                                                    % [S] Membrane Conductance (Neuron 2).

% Define the membrane capacitance.
Cm1_absolute = 5e-9;                                                                                                    % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                                                                                    % [F] Membrane Capacitance (Neuron 2).

% Define the sodium channel conductance.
Gna1_absolute = 0;                                                                                                      % [S] Sodium Channel Conductance (Neuron 1).
Gna2_absolute = 0;                                                                                                      % [S] Sodium Channel Conductance (Neuron 2).

% Define the synaptic reversal potentials.
dEs21_absolute = 0;                                                                                                     % [V] Synaptic Reversal Potential (Synapse 21).

% Define the applied currents.
% Ia1 = 0;                                                                                                              % [A] Applied Current (Neuron 1).
Ia1_absolute = R1_absolute*Gm1_absolute;                                                                                % [A] Applied Current (Neuron 1).

% Define the current states.
current_state1_absolute = 0;                                                                                            % [-] Current State (Neuron 1). (Specified as a ratio of the maximum applied current.)
% current_state1_absolute = 1;                                                                                          % [-] Current State (Neuron 1). (Specified as a ratio of the maximum applied current.)

% Define the network design parameters.
R2_absolute_target = 20e-3;                                                                                             % [V] Maximum Voltage Target (Neuron 2) (Used to compute c1 such that R2 will be set to the target value.)
delta_absolute = 1e-3;                                                                                                  % [V] Membrane Voltage Offset
c1_absolute = ( delta_absolute*R1_absolute*R2_absolute_target )/( R2_absolute_target - delta_absolute );                % [V^2] Design Constant 1


%% Compute the Derived Reduced Absolute Inversion Subnetwork Parameters.

% Compute the network design parameters.
c2_absolute = ( c1_absolute - delta_absolute*R1_absolute )/delta_absolute;                                              % [V] Design Constant 2.

% Compute the maximum membrane voltages.
R2_absolute = c1_absolute/c2_absolute;                                                                                  % [V] Maximum Membrane Voltage (Neuron 2).

% Compute the applied currents.
Ia2_absolute = R2_absolute*Gm2_absolute;                                                                                % [A] Applied Current (Neuron 2).

% Compute the synaptic conductances
gs21_absolute = ( R1_absolute*Ia2_absolute )/( c1_absolute - c2_absolute*dEs21_absolute );                            	% [S] Synaptic Conductance (Synapse 21)


%% Print Reduced Absolute Inversion Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED ABSOLUTE INVERSION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_absolute*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_absolute*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_absolute*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_absolute*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_absolute*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_absolute*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs21 \t= \t%0.2f \t[mV]\n', dEs21_absolute*( 10^3 ) )
fprintf( 'gs21 \t= \t%0.2f \t[muS]\n', gs21_absolute*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1_absolute*Ia1_absolute*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2_absolute*( 10^9 ) )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[mV^2]\n', c1_absolute*( 10^6 ) )
fprintf( 'c2 \t\t= \t%0.2f \t[mV]\n', c2_absolute*( 10^3 ) )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta_absolute*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create a Reduced Absolute Inversion Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 2 );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 1 );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 2 );

% Set neuron parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ R1_absolute, R2_absolute ], 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gm1_absolute, Gm2_absolute ], 'Gm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Cm1_absolute, Cm2_absolute ], 'Cm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ Gna1_absolute, Gna2_absolute ], 'Gna' );

% Set synapse parameters.
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, 1, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, 2, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, gs21_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, dEs21_absolute, 'dE_syn' );

% Set the applied current parameters.
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ 1, 2 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_state1_absolute*Ia1_absolute, Ia2_absolute ], 'I_apps' );


%% Define Basic Reduced Relative Inversion Subnetwork Parameters.

% Define the maximum membrane voltages.
R1_relative = 20e-3;                                                                                            % [V] Maximum Voltage (Neuron 1).
R2_relative = 20e-3;                                                                                            % [V] Maximum Voltage (Neuron 2).

% Define the membrane conductances.
Gm1_relative = 1e-6;                                                                                            % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                                                                            % [S] Membrane Conductance (Neuron 2).

% Define the membrane capacitance.
Cm1_relative = 5e-9;                                                                                            % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                                                                            % [F] Membrane Capacitance (Neuron 2).

% Define the sodium channel conductance.
Gna1_relative = 0;                                                                                              % [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                                                                              % [S] Sodium Channel Conductance (Neuron 2).

% Define the synaptic reversal potential.
dEs21_relative = 0;                                                                                             % [V] Synaptic Reversal Potential (Synapse 21).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                                                                        % [A] Applied Current (Neuron 1).
Ia2_relative = R2_relative*Gm2_relative;                                                                        % [A] Applied Current (Neuron 2).

% Define the current state.
current_state1_relative = 0;                                                                                    % [-] Current State (Neuron 1).  (Specified as a ratio of the maximum current.)
% current_state1_relative = 1;                                                                                  % [-] Current State (Neuron 1).  (Specified as a ratio of the maximum current.)

% Define the network design parameters.
delta_relative = 1e-3;                                                                                          % [V] Membrane Voltage Offset.


%% Compute Derived Reduced Relative Inversion Subnetwork Parameters.

% Compute the design parameters.
c1_relative = delta_relative/( R2_relative - delta_relative );                                                  % [-] Design Constant 1.
c2_relative = c1_relative;                                                                                      % [-] Design Constant 2.

% Compute the synpatic conductance.
gs21_relative = ( Ia2_relative - delta_relative*Gm2_relative )/( delta_relative - dEs21_relative );             % [S] Synaptic Conductance (Synapse 21).


%% Print Relative Inversion Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED RELATIVE INVERSION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2_relative*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1_relative*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2_relative*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1_relative*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2_relative*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1_relative*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2_relative*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs21 \t= \t%0.2f \t[mV]\n', dEs21_relative*( 10^3 ) )
fprintf( 'gs21 \t= \t%0.2f \t[muS]\n', gs21_relative*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1_relative*Ia1_relative*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2_relative*( 10^9 ) )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2e \t[-]\n', c1_relative )
fprintf( 'c2 \t\t= \t%0.2e \t[-]\n', c2_relative )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta_relative*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create a Reduced Relative Inversion Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 2 );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 1 );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 2 );

% Set neuron parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ R1_relative, R2_relative ], 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gm1_relative, Gm2_relative ], 'Gm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Cm1_relative, Cm2_relative ], 'Cm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ Gna1_relative, Gna2_relative ], 'Gna' );

% Set synapse parameters.
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, 1, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, 2, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, gs21_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, dEs21_relative, 'dE_syn' );

% Set the applied current parameters.
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ 1, 2 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_state1_relative*Ia1_relative, Ia2_relative ], 'I_apps' );


%% Load the Absolute & Relative Reduced Inversion Subnetworks.

% Load the simulation results.
absolute_inversion_simulation_data = load( [ load_directory, '\', 'reduced_absolute_inversion_subnetwork_error' ] );
relative_inversion_simulation_data = load( [ load_directory, '\', 'reduced_relative_inversion_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
absolute_applied_currents = absolute_inversion_simulation_data.applied_currents;
Us_achieved_absolute = absolute_inversion_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
relative_applied_currents = relative_inversion_simulation_data.applied_currents;
Us_achieved_relative = relative_inversion_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Reduced Inversion Subnetwork Responses.

% Compute the desired steady state output membrane voltage.
Us_desired_absolute_output = c1_absolute./( Us_achieved_absolute( :, 1 ) + c2_absolute );
Us_desired_relative_output = ( c1_relative*R1_relative*R2_relative )./( Us_achieved_relative( :, 1 ) + c2_relative*R1_relative );

% Generate desired steady state membrane voltage matrices.
Us_desired_absolute = Us_achieved_absolute; Us_desired_absolute( :, end ) = Us_desired_absolute_output;
Us_desired_relative = Us_achieved_relative; Us_desired_relative( :, end ) = Us_desired_relative_output;

% Compute the error between the achieved and desired results.
error_absolute = Us_achieved_absolute( :, end ) - Us_desired_absolute( :, end );
error_relative = Us_achieved_relative( :, end ) - Us_desired_relative( :, end );

% Compute the percent error between the achieve and desired results.
error_absolute_percent = 100*( error_absolute/R2_absolute );
error_relative_percent = 100*( error_relative/R2_relative );

% Compute the mean error.
mse_absolute = ( 1/numel( error_absolute ) )*sqrt( sum( error_absolute.^2, 'all' ) );
mse_relative = ( 1/numel( error_relative ) )*sqrt( sum( error_relative.^2, 'all' ) );

% Compute the mean error percentage.
mse_absolute_percent = 100*( mse_absolute/R2_absolute );
mse_relative_percent = 100*( mse_relative/R2_relative );
% mse_absolute_percent = ( 1/numel( error_absolute_percent ) )*sqrt( sum( error_absolute_percent.^2, 'all' ) );
% mse_relative_percent = ( 1/numel( error_relative_percent ) )*sqrt( sum( error_relative_percent.^2, 'all' ) );

% Compute the standard deviation of the error.
std_absolute = std( error_absolute, 0, 'all' );
std_relative = std( error_relative, 0, 'all' );

% Compute the standard deviation of the error percentage.
std_absolute_percent = 100*( std_absolute/R2_absolute );
std_relative_percent = 100*( std_relative/R2_relative );
% std_absolute_percent = std( error_absolute_percent, 0, 'all' );
% std_relative_percent = std( error_relative_percent, 0, 'all' );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the maximum error percentages.
error_absolute_max_percent = 100*( error_absolute_max/R2_absolute );
error_relative_max_percent = 100*( error_relative_max/R2_relative );
% error_absolute_max_percent = max( abs( error_absolute_percent ), [  ], 'all' );
% error_relative_max_percent = max( abs( error_relative_percent ), [  ], 'all' );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the minimum error percentages.
error_absolute_min_percent = 100*( error_absolute_min/R2_absolute );
error_relative_min_percent = 100*( error_relative_min/R2_relative );
% error_absolute_min_percent = min( abs( error_absolute_percent ), [  ], 'all' );
% error_relative_min_percent = min( abs( error_relative_percent ), [  ], 'all' );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the range of the error percentages.
error_absolute_range_percent = 100*( error_absolute_range/R2_absolute );
error_relative_range_percent = 100*( error_relative_range/R2_relative );
% error_absolute_range_percent = error_absolute_max_percent - error_absolute_min_percent;
% error_relative_range_percent = error_relative_max_percent - error_relative_min_percent;

% Compute the difference in error between the absolute and relative encoding schemes.
error_difference = abs( error_relative ) - abs( error_absolute );
error_difference_percent = abs( error_relative_percent ) - abs( error_absolute_percent );

% Compute the mean squared error difference.
error_difference_mse = abs( mse_relative ) - abs( mse_absolute );
error_difference_mse_percent = abs( mse_relative_percent ) - abs( mse_absolute_percent );
% error_difference_mse = ( 1/numel( error_difference ) )*sqrt( sum( error_difference.^2, 'all' ) );
% error_difference_mse_percent = ( 1/numel( error_difference_percent ) )*sqrt( sum( error_difference_percent.^2, 'all' ) );

% Compute the standard deviation difference.
error_difference_std = abs( std_relative ) - abs( std_absolute );
error_difference_std_percent = abs( std_relative_percent ) - abs( std_absolute_percent );

% Compute the maximum error difference.
error_difference_max = abs( error_relative_max ) - abs( error_absolute_max );
error_difference_max_percent = abs( error_relative_max_percent ) - abs( error_absolute_max_percent );
% error_difference_max = max( abs( error_difference ), [  ], 'all' );
% error_difference_max_percent = max( abs( error_difference_percent ), [  ], 'all' );


%% Print Out the Summary Information.

% Retrieve the absolute input voltage matrices.
Us1_achieved_absolute = Us_achieved_absolute( :, 1 );
Us2_achieved_absolute = Us_achieved_absolute( :, 2 );

% Retrieve the relative input voltage matrices.
Us1_achieved_relative = Us_achieved_relative( :, 1 );
Us2_achieved_relative = Us_achieved_relative( :, 2 );

% Print out the absolute subtraction summary statistics.
fprintf( 'Absolute Inversion Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us1_achieved_absolute( index_absolute_max ), Us2_achieved_absolute( index_absolute_max ) )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us1_achieved_absolute( index_absolute_min ), Us2_achieved_absolute( index_absolute_min ) )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Relative Inversion Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us1_achieved_relative( index_relative_max ), Us2_achieved_relative( index_relative_max ) )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us1_achieved_relative( index_relative_min ), Us2_achieved_relative( index_relative_min ) )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Absolute vs Relative Inversion Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Plot the Steady State Inversion Error Surfaces

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute inversion subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [mV]' ), title( 'Reduced Absolute Inversion Subnetwork Steady State Response (Comparison)' )
plot( Us_desired_absolute( :, 1 )*(10^3), Us_desired_absolute( :, end )*(10^3), '-', 'Linewidth', 3 )
plot( Us_achieved_absolute( :, 1 )*(10^3), Us_achieved_absolute( :, end )*(10^3), '-', 'Linewidth', 3 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'Reduced_Absolute_Inversion_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative inversion subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [mV]' ), title( 'Reduced Relative Inversion Subnetwork Steady State Response (Comparison)' )
plot( Us_desired_relative( :, 1 )*(10^3), Us_desired_relative( :, end )*(10^3), '-', 'Linewidth', 3 )
plot( Us_achieved_relative( :, 1 )*(10^3), Us_achieved_relative( :, end )*(10^3), '-', 'Linewidth', 3 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'Reduced_Relative_Inversion_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative inversion subnetwork.
% fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [mV]' ), title( 'Reduced Inversion Subnetwork Steady State Response (Comparison)' )
fig = figure( 'color', 'w' ); hold on, grid on
plot( Us_desired_relative( :, 1 )*(10^3), Us_desired_absolute( :, end )*(10^3), 'r-', 'Linewidth', 3 )
plot( Us_achieved_relative( :, 1 )*(10^3), Us_achieved_absolute( :, end )*(10^3), 'b--', 'Linewidth', 3 )
plot( Us_desired_relative( :, 1 )*(10^3), Us_desired_relative( :, end )*(10^3), 'r-', 'Linewidth', 3 )
plot( Us_achieved_relative( :, 1 )*(10^3), Us_achieved_relative( :, end )*(10^3), 'b--', 'Linewidth', 3 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'Reduced_Relative_Inversion_Subnetwork_Steady_State_Response.png' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage Error, E [mV]' ), title( 'Reduced Inversion Subnetwork Steady State Error' )
plot( Us_achieved_absolute( :, 1 )*(10^3), error_absolute*(10^3), '-', 'Linewidth', 3 )
plot( Us_achieved_relative( :, 1 )*(10^3), error_relative*(10^3), '-', 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'Reduced_Inversion_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Reduced_Inversion Subnetwork Steady State Error Percentage' )
plot( Us_achieved_absolute( :, 1 )*(10^3), error_absolute_percent, '-', 'Linewidth', 3 )
plot( Us_achieved_relative( :, 1 )*(10^3), error_relative_percent, '-', 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'Reduced_Inversion_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative inversion subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Reduced Inversion Subnetwork Steady State Error Difference' )
plot( Us_achieved_absolute( :, 1 )*(10^3), error_difference*(10^3), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'Reduced_Inversion_Subnetwork_Approximation_Error_Difference.png' ] )

% % Create a surface that shows the difference in error between the absolute and relative percent inversion subnetworks.
% fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Reduced Inversion Subnetwork Steady State Error Difference Percentage' )
% plot( Us_achieved_absolute( :, 1 )*(10^3), error_difference_percent, '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'Reduced_Inversion_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent inversion subnetworks.
% fig = figure( 'color', 'w' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Reduced Inversion Subnetwork Steady State Error Difference Percentage' )
fig = figure( 'color', 'w' ); hold on, grid on
plot( Us_achieved_absolute( :, 1 )*(10^3), error_difference_percent, 'b-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'Reduced_Inversion_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

