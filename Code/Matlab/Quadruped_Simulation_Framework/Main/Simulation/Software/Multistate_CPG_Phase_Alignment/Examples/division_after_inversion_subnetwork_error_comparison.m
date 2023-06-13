%% Division After Inversion Subnetwork Encoding Comparison

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options

% Define the save and load directories.
save_directory = '.\Save';
load_directory = '.\Load';

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-5;
network_tf = 3;


%% Create Absolute Division Subnetwork

% Set the necessary parameters.
R1_absolute = 20e-3;                               	% [V] Activation Domain
R2_absolute = 20e-3;                                 % [V] Activation Domain
c1_absolute = 0.76e-9;                               % [W] Division Parameter 1
c3_absolute = 0.40e-9;                               % [W] Division Parameter 3
delta1_absolute = 1e-3;                              % [V] Inversion Offset
delta2_absolute = 2e-3;                              % [V] Division Offset
dEs31_absolute = 194e-3;                             % [V] Synaptic Reversal Potential

% Compute the network properties.
R3_absolute = ( c1_absolute*R1_absolute*R2_absolute*delta2_absolute )/( c1_absolute*R1_absolute*delta1_absolute + c3_absolute*R2_absolute*delta2_absolute - c3_absolute*delta1_absolute*delta2_absolute );                % [V] Activation Domain
c2_absolute = ( c1_absolute*R1_absolute - c3_absolute*delta2_absolute )/( delta2_absolute*R2_absolute );                                                   % [A] Division Parameter 2
gs31_absolute = ( c1_absolute*c3_absolute )/( ( c3_absolute*dEs31_absolute - R1_absolute*c1_absolute )*R2_absolute );                                               % [S] Maximum Synaptic Conductance
gs32_absolute = ( ( delta2_absolute*c3_absolute - R1_absolute*c1_absolute )*dEs31_absolute*c3_absolute )/( ( R1_absolute*c1_absolute - dEs31_absolute*c3_absolute )*R1_absolute*R2_absolute*delta2_absolute );            % [S] Maximum Synaptic Conductance
dEs32_absolute = 0;                                                                                  % [V] Synaptic Reversal Potential
Iapp3_absolute = 0;                                                                                  % [A] Applied Current
Gm3_absolute = c3_absolute/( R1_absolute*R2_absolute );                                                                         % [S] Membrane Conductance

% Print a summary of the relevant network parameters.
fprintf( 'ABSOLUTE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2_absolute*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', R3_absolute*( 10^3 ) )
fprintf( 'c1 = %0.2f [nW]\n', c1_absolute*( 10^9 ) )
fprintf( 'c2 = %0.2f [nA]\n', c2_absolute*( 10^9 ) )
fprintf( 'c3 = %0.2f [nW]\n', c3_absolute*( 10^9 ) )
fprintf( 'delta1 = %0.2f [mV]\n', delta1_absolute*( 10^3 ) )
fprintf( 'delta2 = %0.2f [mV]\n', delta2_absolute*( 10^3 ) )
fprintf( 'dEs31 = %0.2f [mV]\n', dEs31_absolute*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs32_absolute*( 10^3 ) )
fprintf( 'gs31 = %0.2f [muS]\n', gs31_absolute*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs32_absolute*( 10^6 ) )
fprintf( 'Gm3 = %0.2f [muS]\n', Gm3_absolute*( 10^6 ) )
fprintf( 'Iapp3 = %0.2f [nA]\n', Iapp3_absolute*( 10^9 ) )

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 3 );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 2 );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 3 );

% Set the network parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, zeros( size( neuron_IDs_absolute ) ), 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, [ R1_absolute, R2_absolute, R3_absolute ], 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 3 ), Gm3_absolute, 'Gm' );

network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 1, 2 ], 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ 3, 3 ], 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ gs31_absolute, gs32_absolute ], 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, [ dEs31_absolute, dEs32_absolute ], 'dE_syn' );

network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ 1, 2, 3 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 1 ), 0*network_absolute.neuron_manager.neurons( 1 ).R*network_absolute.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 2 ), 0*network_absolute.neuron_manager.neurons( 2 ).R*network_absolute.neuron_manager.neurons( 2 ).Gm, 'I_apps' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 3 ), Iapp3_absolute, 'I_apps' );


%% Create Relative Division Subnetwork

% Set the necesary parameters.
R1_relative = 20e-3;                                 % [V] Activation Domain
R2_relative = 20e-3;                                 % [V] Activation Domain
R3_relative = 20e-3;                                 % [V] Activation Domain
c3_relative = 1e-6;                                  % [S] Division Parameter 3
delta1_relative = 1e-3;                              % [V] Inversion Offset
delta2_relative = 2e-3;                              % [V] division Offset
dEs31_relative = 194e-3;                             % [V] Synaptic Reversal Potential

% Compute the necessary parameters.
c1_relative = ( ( delta1_relative - R2_relative )*delta2_relative*c3_relative )/( delta1_relative*R3_relative - delta2_relative*R2_relative );                                                                           % [S] Division Parameter 1
c2_relative = ( ( R3_relative - delta2_relative )*R2_relative*c3_relative )/( R2_relative*delta2_relative - R3_relative*delta1_relative );                                                                               % [S] Division Parameter 2
gs31_relative = ( ( c3_relative^2 )*delta1_relative*delta2_relative + ( c1_relative - c3_relative )*c3_relative*R2_relative*delta2_relative )/( -c3_relative*delta1_relative*delta2_relative + c3_relative*dEs31_relative*delta1_relative + ( c3_relative - c1_relative )*R2_relative*delta2_relative );           % [S] Maximum Synaptic Conductance
gs32_relative = ( ( c1_relative - c3_relative )*c3_relative*R2_relative*dEs31_relative )/( -c3_relative*delta1_relative*delta2_relative + c3_relative*dEs31_relative*delta1_relative + ( c3_relative - c1_relative )*R2_relative*delta2_relative );                                     % [S] Maximum Synaptic Conductance
dEs32_relative = 0;                                                                                                                              % [V] Synaptic Reversal Potential
Iapp3_relative = 0;                                                                                                                              % [A] Applied Current
Gm3_relative = c3_relative;                                                                                                                               % [S] Membrane Conductance

% Print a summary of the relevant network parameters.
fprintf( '\nRELATIVE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2_relative*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', R3_relative*( 10^3 ) )
fprintf( 'c1 = %0.2f [muS]\n', c1_relative*( 10^6 ) )
fprintf( 'c2 = %0.2f [muS]\n', c2_relative*( 10^6 ) )
fprintf( 'c3 = %0.2f [muS]\n', c3_relative*( 10^6 ) )
fprintf( 'delta1 = %0.2f [mV]\n', delta1_relative*( 10^3 ) )
fprintf( 'delta2 = %0.2f [mV]\n', delta2_relative*( 10^3 ) )
fprintf( 'dEs31 = %0.2f [mV]\n', dEs31_relative*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs32_relative*( 10^3 ) )
fprintf( 'gs31 = %0.2f [muS]\n', gs31_relative*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs32_relative*( 10^6 ) )
fprintf( 'Gm3 = %0.2f [muS]\n', Gm3_relative*( 10^6 ) )
fprintf( 'Iapp3 = %0.2f [nA]\n', Iapp3_relative*( 10^9 ) )

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 3 );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 2 );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 3 );

% Set the network parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, zeros( size( neuron_IDs_relative ) ), 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, [ R1_relative, R2_relative, R3_relative ], 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 3 ), Gm3_relative, 'Gm' );

network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 1, 2 ], 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ 3, 3 ], 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ gs31_relative, gs32_relative ], 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, [ dEs31_relative, dEs32_relative ], 'dE_syn' );

network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ 1, 2, 3 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 3 ), Iapp3_relative, 'I_apps' );


%% Load the Absolute & Relative Division Subnetworks

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


%% Compute the Error in the Steady State Division Subnetwork Responses

% Compute the desired steady state output membrane voltage.
Us_desired_absolute_output = ( c1_absolute*Us_achieved_absolute( :, :, 1 ) )./( c2_absolute*Us_achieved_absolute( :, :, 2 ) + c3_absolute );
Us_desired_relative_output = ( c1_relative*R2_relative*R3_relative*Us_achieved_relative( :, :, 1 ) )./( c2_relative*R1_relative*Us_achieved_relative( :, :, 2 ) + R1_relative*R2_relative*c3_relative );

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


%% Print Out the Summary Information

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


%% Plot the Steady State Division Error Surfaces

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute division subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Absolute Division Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Absolute_Division_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative division subnetwork.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Relative Division Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Relative_Division_Subnetwork_Steady_State_Response.png' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Division Subnetwork Steady State Error' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Division_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Division Subnetwork Steady State Error Percentage' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Division_Subnetwork_Approximation_Error_Percentage_Comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative division subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Division Subnetwork Steady State Error Difference' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Division_Subnetwork_Approximation_Error_Difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent division subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Division Subnetwork Steady State Error Percentage Difference' )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Division_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

