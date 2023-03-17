%% Addition Subnetwork Encoding Comparison

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options

% Define the save and load directories.
save_directory = '.\Save';
load_directory = '.\Load';

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;


%% Create Absolute Addition Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );
network_relative = network_class( network_dt, network_tf );

% Create absolute and relative addition subnetwork.
[ network_absolute, neuron_IDs_absolute, synapse_IDs_absolute, applied_current_IDs_absolute ] = network_absolute.create_absolute_addition_subnetwork(  );
[ network_relative, neuron_IDs_relative, synapse_IDs_relative, applied_current_IDs_relative ] = network_relative.create_relative_addition_subnetwork(  );


%% Load the Absolute & Relative Addition Subnetworks

% Load the simulation results.
absolute_addition_simulation_data = load( [ load_directory, '\', 'absolute_addition_subnetwork_error' ] );
relative_addition_simulation_data = load( [ load_directory, '\', 'relative_addition_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
Absolute_Applied_Currents1 = absolute_addition_simulation_data.Applied_Currents1;
Absolute_Applied_Currents2 = absolute_addition_simulation_data.Applied_Currents2;
Us_achieved_absolute = absolute_addition_simulation_data.Us_achieved;

% Store the relative simulation results in separate variables.
Relative_Applied_Currents1 = relative_addition_simulation_data.Applied_Currents1;
Relative_Applied_Currents2 = relative_addition_simulation_data.Applied_Currents2;
Us_achieved_relative = relative_addition_simulation_data.Us_achieved;


%% Compute the Error in the Steady State Addition Subnetwork Responses

% Get the activation domains of the neurons.
R1 = network_relative.neuron_manager.get_neuron_property( 1, 'R' ); R1 = R1{1};
R2 = network_relative.neuron_manager.get_neuron_property( 2, 'R' ); R2 = R2{1};
R3 = network_relative.neuron_manager.get_neuron_property( 3, 'R' ); R3 = R3{1};

% Compute the desired steady state output membrane voltage.
Us3_desired_absolute = Us_achieved_absolute( :, :, 1 ) + Us_achieved_absolute( :, :, 2 );
Us3_desired_relative = ( R3/2 )*( Us_achieved_relative( :, :, 1 )/R1 + Us_achieved_relative( :, :, 2 )/R2 );

% Generate desired steady state membrane voltage matrices.
Us_desired_absolute = cat( 3, Us_achieved_absolute( :, :, 1 ), Us_achieved_absolute( :, :, 2 ), Us_achieved_absolute( :, :, 1 ) + Us_achieved_absolute( :, :, 2 ) );
Us_desired_relative = cat( 3, Us_achieved_relative( :, :, 1 ), Us_achieved_relative( :, :, 2 ), ( R3/2 )*( Us_achieved_relative( :, :, 1 )/R1 + Us_achieved_relative( :, :, 2 )/R2 ) );

% Compute the error between the achieved and desired results.
error_absolute = Us_achieved_absolute( :, :, end ) - Us_desired_absolute( :, :, end );
error_relative = Us_achieved_relative( :, :, end ) - Us_desired_relative( :, :, end );

% Compute the mean squared error.
mse_absolute = sqrt( sum( error_absolute.^2, 'all' ) );
mse_relative = sqrt( sum( error_relative.^2, 'all' ) );

% Compute the standard deviation of the error.
std_absolute = std( error_absolute );
std_relative = std( error_relative );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_relative ), [  ], 'all', 'linear' );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the difference in error between the absolute and relative encoding schemes.
error_difference = abs( error_relative ) - abs( error_absolute );


%% Plot the Steady State Addition Error Surfaces

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the absolute addition subnetwork.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Addition Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_absolute( :, :, 1 ), Us_desired_absolute( :, :, 2 ), Us_desired_absolute( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( Us_achieved_absolute( :, :, 1 ), Us_achieved_absolute( :, :, 2 ), Us_achieved_absolute( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Desired', 'Achieved' )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs for the relative addition subnetwork.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Relative Addition Subnetwork Steady State Response (Comparison)' )
surf( Us_desired_relative( :, :, 1 ), Us_desired_relative( :, :, 2 ), Us_desired_relative( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( Us_achieved_relative( :, :, 1 ), Us_achieved_relative( :, :, 2 ), Us_achieved_relative( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Desired', 'Achieved' )

% Create a surface that shows the membrane voltage error.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Addition Subnetwork Steady State Error' )
surf( Us_achieved_absolute( :, :, 1 ), Us_achieved_absolute( :, :, 2 ), error_absolute, 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( Us_achieved_relative( :, :, 1 ), Us_achieved_relative( :, :, 2 ), error_relative, 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Absolute', 'Relative' )

% Create a surface that shows the difference in error between the absolute and relative addition subnetworks.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error Difference, dE [V]' ), title( 'Addition Subnetwork Steady State Error Difference' )
surf( Us_achieved_absolute( :, :, 1 ), Us_achieved_absolute( :, :, 2 ), error_difference, 'Edgecolor', 'None' )


