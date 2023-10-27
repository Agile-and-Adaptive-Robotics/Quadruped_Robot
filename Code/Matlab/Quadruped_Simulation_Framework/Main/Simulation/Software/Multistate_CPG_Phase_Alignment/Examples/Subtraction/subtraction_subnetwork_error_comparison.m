%% Subtraction Subnetwork Encoding Comparison

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options

% Define the save and load directories.
save_directory = '.\Save';
load_directory = '.\Load';

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;

% Set the subtraction subnetwork properties.
% num_subtraction_neurons = 4;
% c = 1;
% npmk_relative = [ 2, 1 ];
% s_ks = [ 1, -1, 1 ];
% % s_ks = [ 1, 1 ];

num_subtraction_neurons = 3;
c = 1;
npm_k = [ 1, 1 ];
s_ks = [ 1, -1 ];

% % Create absolute and relative subtraction subnetwork.
% [ network_absolute, neuron_IDs_absolute, synapse_IDs_absolute, applied_current_IDs_absolute ] = network_absolute.create_absolute_subtraction_subnetwork( num_subtraction_neurons, c, s_ks );
% [ network_relative, neuron_IDs_relative, synapse_IDs_relative, applied_current_IDs_relative ] = network_relative.create_relative_subtraction_subnetwork( num_subtraction_neurons, c, npm_k, s_ks );


%% Compute the Absolute Subtraction Subnetwork Parameters.

% Define the network parameters.
R1_absolute = 40e-3;
R2_absolute = 20e-3;
c_absolute = 1;
s1_absolute = 1;
s2_absolute = -1;
Ia3_absolute = 0;
Gm3_absolute = 1e-7;
dEs31_absolute = 194e-3;
dEs32_absolute = -194e-3;
s_ks_absolute = [ s1_absolute, s2_absolute ];

% Compute the derived parameters.
R3_absolute = c_absolute*R1_absolute;
gs31_absolute = ( Ia3_absolute - c_absolute*s1_absolute*Gm3_absolute*R1_absolute )/( c_absolute*s1_absolute*R1_absolute - dEs31_absolute );
gs32_absolute = ( Ia3_absolute - c_absolute*s2_absolute*Gm3_absolute*R2_absolute )/( c_absolute*s2_absolute*R2_absolute - dEs32_absolute );


%% Print the Absolute Subtraction Subnetwork Parameters.

% Print a summary of the relevant network parameters.
fprintf( '\n' )
fprintf( 'ABSOLUTE SUBTRACTION SUBNETWORK PARAMETERS:\n' )
fprintf( 'R1_absolute = %0.2f [mV]\n', R1_absolute*( 10^3 ) )
fprintf( 'R2_absolute = %0.2f [mV]\n', R2_absolute*( 10^3 ) )
fprintf( 'R3_absolute = %0.2f [mV]\n', R3_absolute*( 10^3 ) )
fprintf( 'c_absolute = %0.2f [-]\n', c_absolute )
fprintf( 'dEs31_absolute = %0.2f [mV]\n', dEs31_absolute*( 10^3 ) )
fprintf( 'dEs32_absolute = %0.2f [mV]\n', dEs32_absolute*( 10^3 ) )
fprintf( 'gs31_absolute = %0.2f [muS]\n', gs31_absolute*( 10^6 ) )
fprintf( 'gs32_absolute = %0.2f [muS]\n', gs32_absolute*( 10^6 ) )
fprintf( 'Gm3_absolute = %0.2f [muS]\n', Gm3_absolute*( 10^6 ) )
fprintf( 'Ia3_absolute = %0.2f [nA]\n', Ia3_absolute*( 10^9 ) )
fprintf( '\n' )


%% Create the Absolute Subtraction Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs ] = network_absolute.neuron_manager.create_neurons( 3 );
[ network_absolute.synapse_manager, synapse_IDs ] = network_absolute.synapse_manager.create_synapses( 3 );
[ network_absolute.applied_current_manager, applied_current_IDs ] = network_absolute.applied_current_manager.create_applied_currents( 3 );

% Set the network  parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 1 ), 0, 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 2 ), 0, 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'Gna' );

network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 1 ), R1_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 2 ), R2_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 3 ), R3_absolute, 'R' );

network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Gm3_absolute, 'Gm' );
% network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Ia3_absolute, 'I_tonic' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'I_tonic' );

network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 1, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 3, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 1 ), gs31_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 1 ), dEs31_absolute, 'dE_syn' );

network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 2, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 3, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 2 ), gs32_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs( 2 ), dEs32_absolute, 'dE_syn' );

network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), Ia3_absolute, 'I_apps' );


%% Compute the Relative Subtraction Subnetwork Parameters.

% Define the network parameters.
R1_relative = 40e-3;
R2_relative = 20e-3;
R3_relative = 20e-3;
c_relative = 1;
s1_relative = 1;
s2_relative = -1;
Ia3_relative = 0;
Gm3_relative = 1e-7;
dEs31_relative = 194e-3;
dEs32_relative = -194e-3;
s_ks_relative = [ s1_relative, s2_relative ];
npm1_relative = 1;
npm2_relative = 1;
npmk_relative = [ npm1_relative, npm2_relative ];

% Compute the derived parameters.
gs31_relative = ( npm1_relative*Ia3_relative - c_relative*s1_relative*Gm3_relative*R3_relative )/( c_relative*s1_relative*R3_relative - npm1_relative*dEs31_relative );
gs32_relative = ( npm2_relative*Ia3_relative - c_relative*s2_relative*Gm3_relative*R3_relative )/( c_relative*s2_relative*R3_relative - npm2_relative*dEs32_relative );


%% Print the Relative Subtraction Subnetwork Parameters.

% Print a summary of the relevant network parameters.
fprintf( '\n' )
fprintf( 'RELATIVE SUBTRACTION SUBNETWORK PARAMETERS:\n' )
fprintf( 'R1_relative = %0.2f [mV]\n', R1_relative*( 10^3 ) )
fprintf( 'R2_relative = %0.2f [mV]\n', R2_relative*( 10^3 ) )
fprintf( 'R3_relative = %0.2f [mV]\n', R3_relative*( 10^3 ) )
fprintf( 'c_relative = %0.2f [-]\n', c_relative )
fprintf( 'dEs31_relative = %0.2f [mV]\n', dEs31_relative*( 10^3 ) )
fprintf( 'dEs32_relative = %0.2f [mV]\n', dEs32_relative*( 10^3 ) )
fprintf( 'gs31_relative = %0.2f [muS]\n', gs31_relative*( 10^6 ) )
fprintf( 'gs32_relative = %0.2f [muS]\n', gs32_relative*( 10^6 ) )
fprintf( 'Gm3_relative = %0.2f [muS]\n', Gm3_relative*( 10^6 ) )
fprintf( 'npm1_relative = %0.2f [#]\n', npm1_relative )
fprintf( 'npm2_relative = %0.2f [#]\n', npm2_relative )
fprintf( '\n' )


%% Create the Relative Subtraction Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs ] = network_relative.neuron_manager.create_neurons( 3 );
[ network_relative.synapse_manager, synapse_IDs ] = network_relative.synapse_manager.create_synapses( 3 );
[ network_relative.applied_current_manager, applied_current_IDs ] = network_relative.applied_current_manager.create_applied_currents( 3 );

% Set the network parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 1 ), 0, 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 2 ), 0, 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'Gna' );

network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 1 ), R1_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 2 ), R2_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 3 ), R3_relative, 'R' );

network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Gm3_relative, 'Gm' );
% network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Ia3_relative, 'I_tonic' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'I_tonic' );

network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 1, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 3, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 1 ), gs31_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 1 ), dEs31_relative, 'dE_syn' );

network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 2, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 3, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 2 ), gs32_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs( 2 ), dEs32_relative, 'dE_syn' );

network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), Ia3_relative, 'I_apps' );


%% Load the Absolute & Relative Subtraction Subnetworks

% Load the simulation results.
absolute_subtraction_simulation_data = load( [ load_directory, '\', 'absolute_subtraction_subnetwork_error' ] );
relative_subtraction_simulation_data = load( [ load_directory, '\', 'relative_subtraction_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
Absolute_Applied_Currents1 = absolute_subtraction_simulation_data.Applied_Currents1;
Absolute_Applied_Currents2 = absolute_subtraction_simulation_data.Applied_Currents2;
Us_achieved_absolute = absolute_subtraction_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
Relative_Applied_Currents1 = relative_subtraction_simulation_data.Applied_Currents1;
Relative_Applied_Currents2 = relative_subtraction_simulation_data.Applied_Currents2;
Us_achieved_relative = relative_subtraction_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Subtraction Subnetwork Responses

% Get the absolute activation domains of the neurons.
% R4_absolute = network_absolute.neuron_manager.get_neuron_property( 4, 'R' ); R4_absolute = R4_absolute{ 1 };
R3_absolute = network_absolute.neuron_manager.get_neuron_property( 3, 'R' ); R3_absolute = R3_absolute{ 1 };

% Get the relative activation domains of the neurons.
% R1_relative = network_relative.neuron_manager.get_neuron_property( 1, 'R' ); R1_relative = R1_relative{ 1 };
% R2_relative = network_relative.neuron_manager.get_neuron_property( 2, 'R' ); R2_relative = R2_relative{ 1 };
% R3_relative = network_relative.neuron_manager.get_neuron_property( 3, 'R' ); R3_relative = R3_relative{ 1 };
% R4_relative = network_relative.neuron_manager.get_neuron_property( 4, 'R' ); R4_relative = R4_relative{ 1 };

R1_relative = network_relative.neuron_manager.get_neuron_property( 1, 'R' ); R1_relative = R1_relative{ 1 };
R2_relative = network_relative.neuron_manager.get_neuron_property( 2, 'R' ); R2_relative = R2_relative{ 1 };
R3_relative = network_relative.neuron_manager.get_neuron_property( 3, 'R' ); R3_relative = R3_relative{ 1 };

% Compute the desired steady state output membrane voltage.
% Us_desired_absolute_output = Us_achieved_absolute( :, :, 1 ) - Us_achieved_absolute( :, :, 2 ) + Us_achieved_absolute( :, :, 3 );
% Us_desired_relative_output = c*R4_relative*( ( 1/npmk_relative( 1 ) )*( Us_achieved_relative( :, :, 1 )/R1_relative + Us_achieved_relative( :, :, 3 )/R3_relative ) - ( 1/npm_k( 2 ) )*( Us_achieved_relative( :, :, 2 )/R2_relative ) );

Us_desired_absolute_output = c_absolute*( Us_achieved_absolute( :, :, 1 ) - Us_achieved_absolute( :, :, 2 ) );
Us_desired_relative_output = c_relative*R3_relative*( ( 1/npmk_relative( 1 ) )*( Us_achieved_relative( :, :, 1 )/R1_relative ) - ( 1/npmk_relative( 2 ) )*( Us_achieved_relative( :, :, 2 )/R2_relative ) );

% Generate desired steady state membrane voltage matrices.
Us_desired_absolute = Us_achieved_absolute; Us_desired_absolute( :, :, end ) = Us_desired_absolute_output;
Us_desired_relative = Us_achieved_relative; Us_desired_relative( :, :, end ) = Us_desired_relative_output;

% Compute the error between the achieved and desired results.
error_absolute = Us_achieved_absolute( :, :, end ) - Us_desired_absolute( :, :, end );
error_relative = Us_achieved_relative( :, :, end ) - Us_desired_relative( :, :, end );

% Compute the percent error between the achieve and desired results.
% error_absolute_percent = 100*( error_absolute/R4_absolute );
% error_relative_percent = 100*( error_relative/R4_relative );

error_absolute_percent = 100*( error_absolute/R3_absolute );
error_relative_percent = 100*( error_relative/R3_relative );

% Compute the mean error.
mse_absolute = ( 1/numel( error_absolute ) )*sqrt( sum( error_absolute.^2, 'all' ) );
mse_relative = ( 1/numel( error_relative ) )*sqrt( sum( error_relative.^2, 'all' ) );

% Compute the mean error percentage.
% mse_absolute_percent = 100*( mse_absolute/R4_absolute );
% mse_relative_percent = 100*( mse_relative/R4_relative );

mse_absolute_percent = 100*( mse_absolute/R3_absolute );
mse_relative_percent = 100*( mse_relative/R3_relative );

% mse_absolute_percent = ( 1/numel( error_absolute_percent ) )*sqrt( sum( error_absolute_percent.^2, 'all' ) );
% mse_relative_percent = ( 1/numel( error_relative_percent ) )*sqrt( sum( error_relative_percent.^2, 'all' ) );

% Compute the standard deviation of the error.
std_absolute = std( error_absolute, 0, 'all' );
std_relative = std( error_relative, 0, 'all' );

% Compute the standard deviation of the error percentage.
% std_absolute_percent = 100*( std_absolute/R4_absolute );
% std_relative_percent = 100*( std_relative/R4_relative );

std_absolute_percent = 100*( std_absolute/R3_absolute );
std_relative_percent = 100*( std_relative/R3_relative );

% std_absolute_percent = std( error_absolute_percent, 0, 'all' );
% std_relative_percent = std( error_relative_percent, 0, 'all' );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the maximum error percentages.
% error_absolute_max_percent = 100*( error_absolute_max/R4_absolute );
% error_relative_max_percent = 100*( error_relative_max/R4_relative );

error_absolute_max_percent = 100*( error_absolute_max/R3_absolute );
error_relative_max_percent = 100*( error_relative_max/R3_relative );

% error_absolute_max_percent = max( abs( error_absolute_percent ), [  ], 'all' );
% error_relative_max_percent = max( abs( error_relative_percent ), [  ], 'all' );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the minimum error percentages.
% error_absolute_min_percent = 100*( error_absolute_min/R4_absolute );
% error_relative_min_percent = 100*( error_relative_min/R4_relative );

error_absolute_min_percent = 100*( error_absolute_min/R3_absolute );
error_relative_min_percent = 100*( error_relative_min/R3_relative );

% error_absolute_min_percent = min( abs( error_absolute_percent ), [  ], 'all' );
% error_relative_min_percent = min( abs( error_relative_percent ), [  ], 'all' );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the range of the error percentages.
% error_absolute_range_percent = 100*( error_absolute_range/R4_absolute );
% error_relative_range_percent = 100*( error_relative_range/R4_relative );

error_absolute_range_percent = 100*( error_absolute_range/R3_absolute );
error_relative_range_percent = 100*( error_relative_range/R3_relative );

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


%% Print Out the Summary Information

% Retrieve the absolute input voltage matrices.
Us1_achieved_absolute = Us_achieved_absolute( :, :, 1 );
Us2_achieved_absolute = Us_achieved_absolute( :, :, 2 );

% Retrieve the relative input voltage matrices.
Us1_achieved_relative = Us_achieved_relative( :, :, 1 );
Us2_achieved_relative = Us_achieved_relative( :, :, 2 );

% Print out the absolute subtraction summary statistics.
fprintf( 'Absolute Subtraction Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us1_achieved_absolute( index_absolute_max ), Us2_achieved_absolute( index_absolute_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us1_achieved_absolute( index_absolute_min ), Us2_achieved_absolute( index_absolute_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Relative Subtraction Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us1_achieved_relative( index_relative_max ), Us2_achieved_relative( index_relative_max ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us1_achieved_relative( index_relative_min ), Us2_achieved_relative( index_relative_min ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Absolute vs Relative Subtraction Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Plot the Steady State Subtraction Error Surfaces

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute subtraction subnetwork.
% % figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Absolute Subtraction Subnetwork Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
% legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% saveas( fig, [ save_directory, '\', 'Absolute_Subtraction_Subnetwork_Steady_State_Response.png' ] )

fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Absolute Subtraction Subnetwork Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_desired_absolute( :, :, 1 )*(10^3), Us_desired_absolute( :, :, 2 )*(10^3), Us_desired_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), Us_achieved_absolute( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 15 )
% colormap( get_bichromatic_colormap(  ) )
saveas( fig, [ save_directory, '\', 'Absolute_Subtraction_Subnetwork_Steady_State_Response.png' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative subtraction subnetwork.
% % figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Relative Subtraction Subnetwork Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
% surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
% legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% % colorbar(  )
% saveas( fig, [ save_directory, '\', 'Relative_Subtraction_Subnetwork_Steady_State_Response.png' ] )

fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Relative Subtraction Subnetwork Steady State Response (Comparison)' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_desired_relative( :, :, 1 )*(10^3), Us_desired_relative( :, :, 2 )*(10^3), Us_desired_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), Us_achieved_relative( :, :, end )*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( -45, 30 )
% colormap( get_bichromatic_colormap(  ) )
% colorbar(  )
saveas( fig, [ save_directory, '\', 'Relative_Subtraction_Subnetwork_Steady_State_Response.png' ] )


% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [mV]' ), title( 'Subtraction Subnetwork Steady State Response (Comparison)' )
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
saveas( fig, [ save_directory, '\', 'Absolute_Subtraction_Subnetwork_Steady_State_Response.png' ] )


% Create a surface that shows the membrane voltage error.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Subtraction Subnetwork Steady State Error' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
% surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute*(10^3), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative*(10^3), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
saveas( fig, [ save_directory, '\', 'Subtraction_Subnetwork_Approximation_Error_Comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Subtraction Subnetwork Steady State Error Percentage' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
% surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_absolute_percent, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_relative( :, :, 1 )*(10^3), Us_achieved_relative( :, :, 2 )*(10^3), error_relative_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
view( 45, 15 )
saveas( fig, [ save_directory, '\', 'Subtraction_Subnetwork_Approximation_Error_Percentage_Comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative subtraction subnetworks.
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Subtraction Subnetwork Steady State Error Difference' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference*(10^3), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
view( 45, 15 )
colormap( get_bichromatic_colormap(  ) )
saveas( fig, [ save_directory, '\', 'Subtraction_Subnetwork_Approximation_Error_Difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent subtraction subnetworks.
% % figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Subtraction Subnetwork Steady State Error Percentage Difference' )
% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
% view( 45, 15 )
% colormap( get_bichromatic_colormap(  ) )
% saveas( fig, [ save_directory, '\', 'Subtraction_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

% fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Subtraction Subnetwork Steady State Error Percentage Difference' )
fig = figure( 'color', 'w' ); hold on, grid on, rotate3d on
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
% surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'Interp', 'FaceAlpha', 0.75 )
surf( Us_achieved_absolute( :, :, 1 )*(10^3), Us_achieved_absolute( :, :, 2 )*(10^3), error_difference_percent, 'Edgecolor', 'None', 'Facecolor', 'Interp', 'FaceAlpha', 1.0 )
view( 45, 15 )
colormap( get_bichromatic_colormap(  ) )
saveas( fig, [ save_directory, '\', 'Subtraction_Subnetwork_Approximation_Error_Percentage_Difference.png' ] )

