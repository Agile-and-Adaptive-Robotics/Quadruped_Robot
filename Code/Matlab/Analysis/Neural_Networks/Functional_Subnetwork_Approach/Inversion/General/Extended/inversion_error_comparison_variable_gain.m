%% Inversion Subnetwork Encoding Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                         	% [str] Save Directory.
load_directory = '.\Load';                        	% [str] Load Directory.

% Set a flag to determine whether to simulate.
% simulate_flag = false;                            % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
verbose_flag = true;                            	% [T/F] Printing Flag. (Determines whether to print out information.)

% Define the undetected option.
undetected_option = 'Error';                        % [str] Undetected Option.

% Define the network simulation time step.
% network_dt = 1e-3;                                 	% [s] Simulation Time Step.
% network_dt = 1e-4;                             	% [s] Simulation Timestep.
network_dt = 5e-5;                             	% [s] Simulation Timestep.
% network_dt = 1e-5;                             	% [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Compute the number of simulation timesteps.
n_timesteps = length( ts );                         % [#] Number of Simulation Timesteps.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the number of input signals.
n_input_signals = 20;                               % [#] Number of Input Signals.

% Define whether to save simulation data.
simulate_flag = true;                             	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
save_flag = true;                                   % [T/F] Save Flag.  (Determine whether to save simulation data.
verbose_flag = true;                            	% [T/F] Printing Flag. (Determines whether to print out information.)

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );
numerical_method_utilities = numerical_method_utilities_class(  );
plotting_utilities = plotting_utilities_class(  );


%% Define the Desired Subnetwork Formulation Parameters.

% Define the number of gains.
num_c1s = 5;
num_c3s = 5;
num_deltas = 5;

% Define the minimum and maximum formulation parameters.
c1_min = 20e-6; c1_max = 80e-6;
c3_min = 0.25e-3; c3_max = 1e-3;
delta_min = 1e-4; delta_max = 1e-3;

% Define the subnetwork formulation parameter arrays.
c1s = linspace( c1_min, c1_max, num_c1s );                                            % [-] Subnetwork Gain 1.
c3s = linspace( c3_min, c3_max, num_c3s );                                            % [-] Subnetwork Gain 1.
deltas = linspace( delta_min, delta_max, num_deltas );                                % [-] Subnetwork Offset.


%% Debugging

[ C1s, C3s ] = ndgrid( c1s, c3s );

X2_maxs = C1s./C3s;

[ row_maxs, row_max_indexes ] = max( X2_maxs );
[ true_max, col_max_index ] = max( row_maxs );

c1_max = C1s( row_max_indexes( col_max_index ), col_max_index );
c3_max = C3s( row_max_indexes( col_max_index ), col_max_index );

[ row_mins, row_min_indexes ] = min( X2_maxs );
[ true_min, col_min_index ] = min( row_mins );

c1_min = C1s( row_min_indexes( col_min_index ), col_min_index );
c3_min = C3s( row_min_indexes( col_min_index ), col_min_index );

fprintf( 'Maximum: x2_max = %0.3e when c1 = %0.3e and c3 = %0.3e.\n', true_max, c1_max, c3_max )
fprintf( 'Minimum: x2_max = %0.3e when c1 = %0.3e and c3 = %0.3e.\n', true_min, c1_min, c3_min )



%% Define the Constant Subnetwork Parameters.

% Define the subnetwork formulation parameters (shared by both encoding schemes).
x1_max = 20e-3;

% Define the transmission subnetwork design parameters.
Gm1_absolute = 1e-6;                                        % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                      	% [S] Membrane Conductance (Neuron 2).
Cm1_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 2).

% Store the transmission subnetwork design parameters.
absolute_inversion_input_parameters.x1_max = x1_max;
absolute_inversion_input_parameters.Gm1 = Gm1_absolute;
absolute_inversion_input_parameters.Gm2 = Gm2_absolute;
absolute_inversion_input_parameters.Cm1 = Cm1_absolute;
absolute_inversion_input_parameters.Cm2 = Cm2_absolute;

% Define the transmission subnetwork design parameters.
R1_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 1).
R2_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 2).
Gm1_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 2).
Cm1_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 2).

% Store the transmission subnetwork design parameters.
relative_inversion_input_parameters.x1_max = x1_max;
relative_inversion_input_parameters.R1 = R1_relative;
relative_inversion_input_parameters.R2 = R2_relative;
relative_inversion_input_parameters.Gm1 = Gm1_relative;
relative_inversion_input_parameters.Gm2 = Gm2_relative;
relative_inversion_input_parameters.Cm1 = Cm1_relative;
relative_inversion_input_parameters.Cm2 = Cm2_relative;


%% Define the Encoding & Decoding Operations.

% Define the absolute encoding maps.
f_encode1_absolute = @( x1 ) network_utilities.encode_absolute_inversion_input( x1 );
f_encode2_absolute = @( x2 ) network_utilities.encode_absolute_inversion_output( x2 );
f_encode_absolute = @( Xs ) [ f_encode1_absolute( Xs( :, 1 ) ), f_encode2_absolute( Xs( :, 2 ) ) ];

% Define the absolute decoding maps.
f_decode1_absolute = @( U1 ) network_utilities.decode_absolute_inversion_input( U1 );
f_decode2_absolute = @( U2 ) network_utilities.decode_absolute_inversion_output( U2 );
f_decode_absolute = @( Us ) [ f_decode1_absolute( Us( :, 1 ) ), f_decode2_absolute( Us( :, 2 ) ) ];

% Define the relative encoding maps.
f_encode1_relative = @( x1 ) network_utilities.encode_relative_inversion_input( x1, x1_max, R1_relative );
f_encode2_relative = @( x2, c1, c3 ) network_utilities.encode_relative_inversion_output( x2, c1, c3, R2_relative );
f_encode_relative = @( Xs, c1, c3 ) [ f_encode1_relative( Xs( :, 1 ) ), f_encode2_relative( Xs( :, 2 ), c1, c3 ) ];

% Define the relative decoding maps.
f_decode1_relative = @( U1 ) network_utilities.decode_relative_inversion_input( U1, x1_max, R1_relative );
f_decode2_relative = @( U2, c1, c3 ) network_utilities.decode_relative_inversion_output( U2, c1, c3, R2_relative );
f_decode_relative = @( Us, c1, c3 ) [ f_decode1_relative( Us( :, 1 ) ), f_decode2_relative( Us( :, 2 ), c1, c3 ) ];


%% Define Simulation Parameters.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
set_flag = true;                            % [T/F] Set Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';               % [str] Undetected Option.


%% Preallocate Arrays to Store Simulation Data.

% Create arrays to store the encoded steady state output information.
Us_desired_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Us_theoretical_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Us_numerical_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );

Us_desired_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Us_theoretical_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Us_numerical_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );

% Create arrays to store the decoded steady state output information.
Xs_desired_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Xs_theoretical_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Xs_numerical_absolute_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );

Xs_desired_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Xs_theoretical_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
Xs_numerical_relative_output = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );

% Create arrays to store the error information.
errors_theoretical_encoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_theoretical_encoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas ); 
errors_rmse_percentage_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_theoretical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );

errors_theoretical_encoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_theoretical_encoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_theoretical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );

errors_numerical_encoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_numerical_encoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_numerical_encoded_absolute = zeros( num_c1s, num_c3s, num_deltas );

errors_numerical_encoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_numerical_encoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_numerical_encoded_relative = zeros( num_c1s, num_c3s, num_deltas );

errors_theoretical_decoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_theoretical_decoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas ); 
errors_rmse_percentage_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_theoretical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );

errors_theoretical_decoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_theoretical_decoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_theoretical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );

errors_numerical_decoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_numerical_decoded_absolute = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_numerical_decoded_absolute = zeros( num_c1s, num_c3s, num_deltas );

errors_numerical_decoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percentage_numerical_decoded_relative = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_rmse_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_rmse_percentage_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percentage_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percentage_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percentage_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );
errors_range_percentage_numerical_decoded_relative = zeros( num_c1s, num_c3s, num_deltas );

errors_diff_theoretical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_diff_theoretical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_diff_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );

errors_diff_numerical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_diff_numerical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_diff_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );

errors_diff_theoretical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_diff_theoretical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_diff_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );

errors_diff_numerical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_diff_numerical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_diff_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );

errors_improv_theoretical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_improv_theoretical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_improv_theoretical_encoded = zeros( num_c1s, num_c3s, num_deltas );

errors_improv_numerical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_improv_numerical_encoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_improv_numerical_encoded = zeros( num_c1s, num_c3s, num_deltas );

errors_improv_theoretical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_improv_theoretical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_improv_theoretical_decoded = zeros( num_c1s, num_c3s, num_deltas );

errors_improv_numerical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_percent_improv_numerical_decoded = zeros( n_input_signals, num_c1s, num_c3s, num_deltas );
errors_mse_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_mse_percent_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_std_percent_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_min_percent_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );
errors_max_percent_improv_numerical_decoded = zeros( num_c1s, num_c3s, num_deltas );

% Create arrays to store the maximum RK4 step size.
dts_max_absolute = zeros( num_c1s, num_c3s, num_deltas );
dts_max_relative = zeros( num_c1s, num_c3s, num_deltas );

% Create arrays to store the maximum condition numbers.
condition_numbers_max_absolute = zeros( num_c1s, num_c3s, num_deltas );
condition_numbers_max_relative = zeros( num_c1s, num_c3s, num_deltas );

% Create arrays to store the network parameters.
c2s_absolute = zeros( num_c1s, num_c3s, num_deltas );
x2maxs_absolute = zeros( num_c1s, num_c3s, num_deltas );
R1s_absolute = zeros( num_c1s, num_c3s, num_deltas );
R2s_absolute = zeros( num_c1s, num_c3s, num_deltas );
Gna1s_absolute = zeros( num_c1s, num_c3s, num_deltas );
Gna2s_absolute = zeros( num_c1s, num_c3s, num_deltas );
dEs21s_absolute = zeros( num_c1s, num_c3s, num_deltas );
gs21s_absolute = zeros( num_c1s, num_c3s, num_deltas );
Ia2s_absolute = zeros( num_c1s, num_c3s, num_deltas );

c2s_relative = zeros( num_c1s, num_c3s, num_deltas );
x2maxs_relative = zeros( num_c1s, num_c3s, num_deltas );
Gna1s_relative = zeros( num_c1s, num_c3s, num_deltas );
Gna2s_relative = zeros( num_c1s, num_c3s, num_deltas );
dEs21s_relative = zeros( num_c1s, num_c3s, num_deltas );
gs21s_relative = zeros( num_c1s, num_c3s, num_deltas );
Ia2s_relative = zeros( num_c1s, num_c3s, num_deltas );

% Perform the following analysis given each gain value.
for k1 = 1:num_c1s                          % Iterate through each of the c1s...
    for k2 = 1:num_c3s                      % Iterate through each of the c3s...
        for k3 = 1:num_deltas               % Iterate through each of the deltas...
            
            
            %% Define the Variable Subnetwork Formulation Parameters.
            
            % Retrieve the variable subnetwork formulation parameters (shared by both encoding schemes).
            c1 = c1s( k1 );
            c3 = c3s( k2 );
            delta = deltas( k3 );
            
            % Store the variable subnetwork formulation parameters.
            absolute_inversion_input_parameters.c1 = c1;
            absolute_inversion_input_parameters.c3 = c3;
            absolute_inversion_input_parameters.delta = delta;
            
            relative_inversion_input_parameters.c1 = c1;
            relative_inversion_input_parameters.c3 = c3;
            relative_inversion_input_parameters.delta = delta;
            
            
            %% Define the Absolute & Relative Subnetwork Input Currents.
            
            % Define the applied current ID.
            input_current_ID_absolute = 1;                                  % [#] Absolute Input Current ID.
            input_current_ID_relative = 1;                                  % [#] Relative Input Current ID.
            
            % Define the applied current name.
            input_current_name_absolute = 'Applied Current 1 (Absolute)';   % [str] Absolute Input Current Name.
            input_current_name_relative = 'Applied Current 1 (Relative)';  	% [str] Relative Input Current Name.
            
            % Define the IDs of the neurons to which the currents are applied.
            input_current_to_neuron_ID_absolute = 1;                        % [#] Absolute Neuron ID to Which Input Current is Applied.
            input_current_to_neuron_ID_relative = 1;                        % [#] Relative Neuron ID to Which Input Current is Applied.
            
            % Define the applied current magnitudes.
            Ias1_absolute = zeros( n_timesteps, 1 );                        % [A] Applied Current Magnitude.
            Ias1_relative = zeros( n_timesteps, 1 );                        % [A] Applied Current Magnitude.
            
            
            %% Create the Relative Transmission Subnetwork.
            
            % Create an instance of the network class.
            network_absolute = network_class( network_dt, network_tf );
            network_relative = network_class( network_dt, network_tf );

            % Create an inversion subnetwork.
            [ absolute_inversion_output_parameters, neurons_absolute, synapses_absolute, applied_currents_absolute, neuron_manager_absolute, synapse_manager_absolute, applied_current_manager_absolute, network_absolute ] = network_absolute.create_inversion_subnetwork( absolute_inversion_input_parameters, 'absolute', network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, true, true, false, undetected_option );
            [ relative_inversion_output_parameters, neurons_relative, synapses_relative, applied_currents_relative, neuron_manager_relative, synapse_manager_relative, applied_current_manager_relative, network_relative ] = network_relative.create_inversion_subnetwork( relative_inversion_input_parameters, 'relative', network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, true, true, false, undetected_option );

            % Unpack the subnetwork output parameters.
            [ c2s_absolute( k1, k2, k3 ), x2maxs_absolute( k1, k2, k3 ), R1s_absolute( k1, k2, k3 ), R2s_absolute( k1, k2, k3 ), Gna1s_absolute( k1, k2, k3 ), Gna2s_absolute( k1, k2, k3 ), dEs21s_absolute( k1, k2, k3 ), gs21s_absolute( k1, k2, k3 ), Ia2s_absolute( k1, k2, k3 ) ] = network_absolute.unpack_absolute_inversion_output_parameters( absolute_inversion_output_parameters, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option );
            [ c2s_relative( k1, k2, k3 ), x2maxs_relative( k1, k2, k3 ), Gna1s_relative( k1, k2, k3 ), Gna2s_relative( k1, k2, k3 ), dEs21s_relative( k1, k2, k3 ), gs21s_relative( k1, k2, k3 ), Ia2s_relative( k1, k2, k3 ) ] = network_relative.unpack_relative_inversion_output_parameters( relative_inversion_output_parameters, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option );

            % Update the input current ID and name.
            [ ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.set_applied_current_property( network_absolute.applied_current_manager.applied_currents( 1 ).ID, 2, 'ID', network_absolute.applied_current_manager.applied_currents, true );
            [ ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.set_applied_current_property( network_absolute.applied_current_manager.applied_currents( 1 ).ID, { 'Applied Current 2 (Absolute)' }, 'name', network_absolute.applied_current_manager.applied_currents, true );

            [ ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.set_applied_current_property( network_relative.applied_current_manager.applied_currents( 1 ).ID, 2, 'ID', network_relative.applied_current_manager.applied_currents, true );
            [ ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.set_applied_current_property( network_relative.applied_current_manager.applied_currents( 1 ).ID, { 'Applied Current 2 (Relative)' }, 'name', network_relative.applied_current_manager.applied_currents, true );

            % Create the input applied current.
            [ ~, ~, ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.create_applied_current( input_current_ID_absolute, input_current_name_absolute, input_current_to_neuron_ID_absolute, ts, Ias1_absolute, true, network_absolute.applied_current_manager.applied_currents, true, false, network_absolute.applied_current_manager.array_utilities );
            [ ~, ~, ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.create_applied_current( input_current_ID_relative, input_current_name_relative, input_current_to_neuron_ID_relative, ts, Ias1_relative, true, network_relative.applied_current_manager.applied_currents, true, false, network_relative.applied_current_manager.array_utilities );

            % Reverse the order of the applied currents in the applied current manager for cleanliness.
            temporary_applied_current = network_absolute.applied_current_manager.applied_currents( 1 );
            network_absolute.applied_current_manager.applied_currents( 1 ) = network_absolute.applied_current_manager.applied_currents( 2 );
            network_absolute.applied_current_manager.applied_currents( 2 ) = temporary_applied_current;

            temporary_applied_current = network_relative.applied_current_manager.applied_currents( 1 );
            network_relative.applied_current_manager.applied_currents( 1 ) = network_relative.applied_current_manager.applied_currents( 2 );
            network_relative.applied_current_manager.applied_currents( 2 ) = temporary_applied_current;
            
            
            %% Print Subnetwork Information.
            
            %     % Print absolute subnetwork information.
            %     fprintf( '----------------------------------- ABSOLUTE TRANSMISSION SUBNETWORK -----------------------------------\n\n' )
            %     network_absolute.print( network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, verbose_flag );
            %     fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )
            %
            %     % Print the relative subnetwork information.
            %     fprintf( '----------------------------------- RELATIVE TRANSMISSION SUBNETWORK -----------------------------------\n\n' )
            %     network_relative.print( network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, verbose_flag );
            %     fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )
            
            
            %% Simulate the Subnetwork.
            
            % Determine whether to simulate the network.
            if simulate_flag                            % If we want to simulate the network...
                
                % Define the decoded input signals.
                xs_numerical_input = linspace( 0, x1_max, n_input_signals )';
                
                % Compute the decoded steady state simulation results.
                [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.compute_steady_state_simulation_decoded( network_dt, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_absolute, f_decode2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, network_absolute.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_absolute.network_utilities );
                [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.compute_steady_state_simulation_decoded( network_dt, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_relative, @( xs ) f_decode2_relative( xs, c1, c3 ), network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, network_relative.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_relative.network_utilities );
                
                % Determine whether to save the simulation data.
                if save_flag                    % If we want to save the simulation data...
                    
                    data_absolute.Ias_magnitude = Ias_magnitude_absolute;
                    data_absolute.Us_numerical = Us_numerical_absolute;
                    data_absolute.xs_numerical = xs_numerical_absolute;
                    
                    data_relative.Ias_magnitude = Ias_magnitude_relative;
                    data_relative.Us_numerical = Us_numerical_relative;
                    data_relative.xs_numerical = xs_numerical_relative;
                    
                    % Define the save file names.
                    file_name_absolute = sprintf( 'absolute_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                    file_name_relative = sprintf( 'relative_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                    
                    % Save the simulation results.
                    save( [ save_directory, '\', file_name_absolute ], 'data_absolute' )
                    save( [ save_directory, '\', file_name_relative ], 'data_relative' )
                    
                end
                
            else                % Otherwise... ( We must want to load data from an existing simulation... )
                
                % Define the load file names.
                file_name_absolute = sprintf( 'absolute_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                file_name_relative = sprintf( 'relative_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                
                % Load the simulation results.
                data_absolute = load( [ load_directory, '\', file_name_absolute ] );
                data_relative = load( [ load_directory, '\', file_name_relative ] );
                
                % Unpack the steady state simulation data.
                [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.unpack_steady_state_simulation_data( data_absolute.data_absolute );
                [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.unpack_steady_state_simulation_data( data_relative.data_relative );
                
            end
            
            
            %% Compute the Absolute & Relative Desired & Achieved (Theory) Subnetwork Output.
            
            % Initialize the desired decoded steady state response.
            xs_desired_absolute = [ xs_numerical_absolute( :, 1 ), zeros( size( xs_numerical_absolute, 1 ), 1 ) ];
            xs_desired_relative = [ xs_numerical_relative( :, 1 ), zeros( size( xs_numerical_relative, 1 ), 1 ) ];
            
            % Initialize the theoretically achieved decoded steady state response.
            xs_theoretical_absolute = [ xs_numerical_absolute( :, 1 ), zeros( size( xs_numerical_absolute, 1 ), 1 ) ];
            xs_theoretical_relative = [ xs_numerical_relative( :, 1 ), zeros( size( xs_numerical_relative, 1 ), 1 ) ];
            
            % Initialize the desired encoded steady state response.
            Us_desired_absolute = [ Us_numerical_absolute( :, 1 ), zeros( size( Us_numerical_absolute, 1 ), 1 ) ];
            Us_desired_relative = [ Us_numerical_relative( :, 1 ), zeros( size( Us_numerical_relative, 1 ), 1 ) ];
            
            % Initialize the theoretically achieved encoded stady state response.
            Us_theoretical_absolute = [ Us_numerical_absolute( :, 1 ), zeros( size( Us_numerical_absolute, 1 ), 1 ) ];
            Us_theoretical_relative = [ Us_numerical_relative( :, 1 ), zeros( size( Us_numerical_relative, 1 ), 1 ) ];
            
            % Compute the absolute and relative desired subnetwork output.
            Us_desired_absolute( :, 2 ) = network_absolute.compute_encoded_desired_absolute_inversion_sso( Us_desired_absolute( :, 1 ), c1, c3, delta, x1_max, network_absolute.network_utilities );
            Us_desired_relative( :, 2 ) = network_relative.compute_encoded_desired_relative_inversion_sso( Us_desired_relative( :, 1 ), c1, c3, delta, R1_relative, R2_relative, network_relative.neuron_manager, undetected_option, network_relative.network_utilities );
            
            % Compute the absolute and relative achieved theoretical subnetwork output.
            Us_theoretical_absolute( :, 2 ) = network_absolute.compute_encoded_achieved_inversion_sso( Us_theoretical_absolute( :, 1 ), R1s_absolute( k1, k2, k3 ), Gm2_absolute, gs21s_absolute( k1, k2, k3 ), dEs21s_absolute( k1, k2, k3 ), Ia2s_absolute( k1, k2, k3 ), network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option, network_absolute.network_utilities );
            Us_theoretical_relative( :, 2 ) = network_relative.compute_encoded_achieved_inversion_sso( Us_theoretical_relative( :, 1 ), R1_relative, Gm2_relative, gs21s_relative( k1, k2, k3 ), dEs21s_relative( k1, k2, k3 ), Ia2s_relative( k1, k2, k3 ), network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option, network_relative.network_utilities );
            
            % Compute the decoded desired absolute and relative network outputs.
            xs_desired_absolute( :, 2 ) = f_decode2_absolute( Us_desired_absolute( :, 2 ) );
            xs_desired_relative( :, 2 ) = f_decode2_relative( Us_desired_relative( :, 2 ), c1, c3 );
            
            % Compute the decoded achieved theoretical absolute and relative network outputs.
            xs_theoretical_absolute( :, 2 ) = f_decode2_absolute( Us_theoretical_absolute( :, 2 ) );
            xs_theoretical_relative( :, 2 ) = f_decode2_relative( Us_theoretical_relative( :, 2 ), c1, c3 );
            
            
            %% Store the Encoded & Decoded Network Outputs.
            
            % Store the encoded network output for plotting.
            Us_desired_absolute_output( :, k1, k2, k3 ) = Us_desired_absolute( :, 2 );
            Us_theoretical_absolute_output( :, k1, k2, k3 ) = Us_theoretical_absolute( :, 2 );
            Us_numerical_absolute_output( :, k1, k2, k3 ) = Us_numerical_absolute( :, 2 );
            
            Us_desired_relative_output( :, k1, k2, k3 ) = Us_desired_relative( :, 2 );
            Us_theoretical_relative_output( :, k1, k2, k3 ) = Us_theoretical_relative( :, 2 );
            Us_numerical_relative_output( :, k1, k2, k3 ) = Us_numerical_relative( :, 2 );
            
            % Store the decoded network output for plotting.
            Xs_desired_absolute_output( :, k1, k2, k3 ) = xs_desired_absolute( :, 2 );
            Xs_theoretical_absolute_output( :, k1, k2, k3 ) = xs_theoretical_absolute( :, 2 );
            Xs_numerical_absolute_output( :, k1, k2, k3 ) = xs_numerical_absolute( :, 2 );
            
            Xs_desired_relative_output( :, k1, k2, k3 ) = xs_desired_relative( :, 2 );
            Xs_theoretical_relative_output( :, k1, k2, k3 ) = xs_theoretical_relative( :, 2 );
            Xs_numerical_relative_output( :, k1, k2, k3 ) = xs_numerical_relative( :, 2 );
            
            
            %% Compute the Absolute & Relative Subnetwork Error.
            
            % Compute the error between the encoded theoretical output and the desired output.
            [ errors_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_rmse_theoretical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_absolute( k1, k2, k3 ), index_min_theoretical_encoded_absolute, errors_max_theoretical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_absolute( k1, k2, k3 ), index_max_theoretical_encoded_absolute, errors_range_theoretical_encoded_absolute( k1, k2, k3 ), errors_range_percentage_theoretical_encoded_absolute( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( Us_theoretical_absolute, Us_desired_absolute, R2s_absolute( k1, k2, k3 ) );
            [ errors_theoretical_encoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_std_theoretical_encoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_min_theoretical_encoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_relative( k1, k2, k3 ), index_min_theoretical_encoded_relative, errors_max_theoretical_encoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_relative( k1, k2, k3 ), index_max_theoretical_encoded_relative, errors_range_theoretical_encoded_relative( k1, k2, k3 ), errors_range_percentage_theoretical_encoded_relative( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( Us_theoretical_relative, Us_desired_relative, R2_relative );
            
            % Compute the error between the encoded numerical output and the desired output.
            [ errors_numerical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_encoded_absolute( :, k1, k2, k3 ), errors_rmse_numerical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_std_numerical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_min_numerical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_encoded_absolute( k1, k2, k3 ), index_min_numerical_encoded_absolute, errors_max_numerical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_encoded_absolute( k1, k2, k3 ), index_max_numerical_encoded_absolute, errors_range_numerical_encoded_absolute( k1, k2, k3 ), errors_range_percentage_numerical_encoded_absolute( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( Us_numerical_absolute, Us_desired_absolute, R2s_absolute( k1, k2, k3 ) );
            [ errors_numerical_encoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_encoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_std_numerical_encoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_min_numerical_encoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_encoded_relative( k1, k2, k3 ), index_min_numerical_encoded_relative, errors_max_numerical_encoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_encoded_relative( k1, k2, k3 ), index_max_numerical_encoded_relative, errors_range_numerical_encoded_relative( k1, k2, k3 ), errors_range_percentage_numerical_encoded_relative( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( Us_numerical_relative, Us_desired_relative, R2_relative );
            
            % Compute the error between the decoded theoretical output and the desired output.
            [ errors_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_rmse_theoretical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_absolute( k1, k2, k3 ), index_min_theoretical_decoded_absolute, errors_max_theoretical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_absolute( k1, k2, k3 ), index_max_theoretical_decoded_absolute, errors_range_theoretical_decoded_absolute( k1, k2, k3 ), errors_range_percentage_theoretical_decoded_absolute( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( xs_theoretical_absolute, xs_desired_absolute, x2maxs_absolute( k1, k2, k3 ) );
            [ errors_theoretical_decoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_std_theoretical_decoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_min_theoretical_decoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_relative( k1, k2, k3 ), index_min_theoretical_decoded_relative, errors_max_theoretical_decoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_relative( k1, k2, k3 ), index_max_theoretical_decoded_relative, errors_range_theoretical_decoded_relative( k1, k2, k3 ), errors_range_percentage_theoretical_decoded_relative( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( xs_theoretical_relative, xs_desired_relative, x2maxs_relative( k1, k2, k3 ) );
            
            % Compute the error between the decoded numerical output and the desired output.
            [ errors_numerical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_decoded_absolute( :, k1, k2, k3 ), errors_rmse_numerical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_std_numerical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_min_numerical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_decoded_absolute( k1, k2, k3 ), index_min_numerical_decoded_absolute, errors_max_numerical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_decoded_absolute( k1, k2, k3 ), index_max_numerical_decoded_absolute, errors_range_numerical_decoded_absolute( k1, k2, k3 ), errors_range_percentage_numerical_decoded_absolute( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( xs_numerical_absolute, xs_desired_absolute, x2maxs_absolute( k1, k2, k3 ) );
            [ errors_numerical_decoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_decoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_std_numerical_decoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_min_numerical_decoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_decoded_relative( k1, k2, k3 ), index_min_numerical_decoded_relative, errors_max_numerical_decoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_decoded_relative( k1, k2, k3 ), index_max_numerical_decoded_relative, errors_range_numerical_decoded_relative( k1, k2, k3 ), errors_range_percentage_numerical_decoded_relative( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_statistics( xs_numerical_relative, xs_desired_relative, x2maxs_relative( k1, k2, k3 ) );
            
            
            %% Print the Absolute & Relative Subnetwork Summary Statistics.
            
            % Define the absolute header strings.
            header_str_encoded_absolute = 'Absolute Inversion Encoded Error Statistics';
            header_str_decoded_absolute = 'Absolute Inversion Decoded Error Statistics';
            
            % Define the relative header strings.
            header_str_encoded_relative = 'Relative Inversion Encoded Error Statistics';
            header_str_decoded_relative = 'Relative Inversion Decoded Error Statistics';
            
            % Define the unit strings.
            unit_str_encoded = 'mV';
            unit_str_decoded = '-';
            
            % Retrieve the minimum and maximum encoded theoretical and numerical absolute network results.
            Us_critmin_theoretical_absolute = Us_theoretical_absolute( index_min_theoretical_encoded_absolute, : );
            Us_critmin_numerical_absolute = Us_numerical_absolute( index_min_numerical_encoded_absolute, : );
            Us_critmax_theoretical_absolute = Us_theoretical_absolute( index_max_theoretical_encoded_absolute, : );
            Us_critmax_numerical_absolute = Us_numerical_absolute( index_max_numerical_encoded_absolute, : );
            
            % Retrieve the minimum and maximum encoded theoretical and numerical relative network results.
            Us_critmin_theoretical_relative = Us_theoretical_relative( index_min_theoretical_encoded_relative, : );
            Us_critmin_numerical_relative = Us_numerical_relative( index_min_numerical_encoded_relative, : );
            Us_critmax_theoretical_relative = Us_theoretical_relative( index_max_theoretical_encoded_relative, : );
            Us_critmax_numerical_relative = Us_numerical_relative( index_max_numerical_encoded_relative, : );
            
            % Retrieve the minimum and maximum decoded theoretical and numerical absolute network results.
            xs_critmin_theoretical_absolute = f_decode_absolute( Us_critmin_theoretical_absolute );
            xs_critmin_numerical_absolute = f_decode_absolute( Us_critmin_numerical_absolute );
            xs_critmax_theoretical_absolute = f_decode_absolute( Us_critmax_theoretical_absolute );
            xs_critmax_numerical_absolute = f_decode_absolute( Us_critmax_numerical_absolute );
            
            % Retrieve the minimum and maximum decoded theoretical and numerical relative network results.
            xs_critmin_theoretical_relative = f_decode_relative( Us_critmin_theoretical_relative, c1, c3 );
            xs_critmin_numerical_relative = f_decode_relative( Us_critmin_numerical_relative, c1, c3 );
            xs_critmax_theoretical_relative = f_decode_relative( Us_critmax_theoretical_relative, c1, c3 );
            xs_critmax_numerical_relative = f_decode_relative( Us_critmax_numerical_relative, c1, c3 );
            
            %     % Print the absolute transmission summary statistics.
            %     network_absolute.numerical_method_utilities.print_error_statistics( header_str_encoded_absolute, unit_str_encoded, 10^( -3 ), error_rmse_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_absolute, error_rmse_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_absolute, error_std_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_absolute, error_std_numerical_encoded_absolute, error_std_percentage_numerical_encoded_absolute, error_min_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_absolute, Us_critmin_theoretical_absolute, error_min_numerical_encoded_absolute, error_min_percentage_numerical_encoded_absolute, Us_critmin_numerical_absolute, error_max_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_absolute, Us_critmax_theoretical_absolute, error_max_numerical_encoded_absolute, error_max_percentage_numerical_encoded_absolute, Us_critmax_numerical_absolute, error_range_theoretical_encoded_absolute, error_range_percentage_theoretical_encoded_absolute, error_range_numerical_encoded_absolute, error_range_percentage_numerical_encoded_absolute )
            %     network_absolute.numerical_method_utilities.print_error_statistics( header_str_decoded_absolute, unit_str_decoded, 1, error_rmse_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_absolute, error_rmse_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_absolute, error_std_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_absolute, error_std_numerical_decoded_absolute, error_std_percentage_numerical_decoded_absolute, error_min_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_absolute, xs_critmin_theoretical_absolute, error_min_numerical_decoded_absolute, error_min_percentage_numerical_decoded_absolute, xs_critmin_numerical_absolute, error_max_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_absolute, xs_critmax_theoretical_absolute, error_max_numerical_decoded_absolute, error_max_percentage_numerical_decoded_absolute, xs_critmax_numerical_absolute, error_range_theoretical_decoded_absolute, error_range_percentage_theoretical_decoded_absolute, error_range_numerical_decoded_absolute, error_range_percentage_numerical_decoded_absolute )
            %
            %     % Print the relative transmission summary statistics.
            %     network_relative.numerical_method_utilities.print_error_statistics( header_str_encoded_relative, unit_str_encoded, 10^( -3 ), error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_relative, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_relative, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_relative, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_relative, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_relative, Us_critmin_theoretical_relative, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_relative, Us_critmin_numerical_relative, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_relative, Us_critmax_theoretical_relative, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_relative, Us_critmax_numerical_relative, error_range_theoretical_encoded_relative, error_range_percentage_theoretical_encoded_relative, error_range_numerical_encoded_relative, error_range_percentage_numerical_encoded_relative )
            %     network_relative.numerical_method_utilities.print_error_statistics( header_str_decoded_relative, unit_str_decoded, 1, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_relative, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_relative, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_relative, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_relative, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_relative, xs_critmin_theoretical_relative, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_relative, xs_critmin_numerical_relative, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_relative, xs_critmax_theoretical_relative, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_relative, xs_critmax_numerical_relative, error_range_theoretical_decoded_relative, error_range_percentage_theoretical_decoded_relative, error_range_numerical_decoded_relative, error_range_percentage_numerical_decoded_relative )
            
            
            %% Compute the Difference between the Absolute & Relative Subnetwork Errors.
            
            % Compute the difference between the theoretical absolute and relative network errors.
            [ errors_diff_theoretical_encoded( :, k1, k2, k3 ), errors_percent_diff_theoretical_encoded( :, k1, k2, k3 ), errors_mse_diff_theoretical_encoded( k1, k2, k3 ), errors_mse_percent_diff_theoretical_encoded( k1, k2, k3 ), errors_std_diff_theoretical_encoded( k1, k2, k3 ), errors_std_percent_diff_theoretical_encoded( k1, k2, k3 ), errors_min_diff_theoretical_encoded( k1, k2, k3 ), errors_min_percent_diff_theoretical_encoded( k1, k2, k3 ), errors_max_diff_theoretical_encoded( k1, k2, k3 ), errors_max_percent_diff_theoretical_encoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_difference_statistics( errors_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_theoretical_encoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_encoded_absolute( k1, k2, k3 ), errors_rmse_theoretical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_std_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_theoretical_encoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_min_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_theoretical_encoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_max_theoretical_encoded_absolute( k1, k2, k3 ), errors_max_theoretical_encoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_relative( k1, k2, k3 ) );
            [ errors_diff_theoretical_decoded( :, k1, k2, k3 ), errors_percent_diff_theoretical_decoded( :, k1, k2, k3 ), errors_mse_diff_theoretical_decoded( k1, k2, k3 ), errors_mse_percent_diff_theoretical_decoded( k1, k2, k3 ), errors_std_diff_theoretical_decoded( k1, k2, k3 ), errors_std_percent_diff_theoretical_decoded( k1, k2, k3 ), errors_min_diff_theoretical_decoded( k1, k2, k3 ), errors_min_percent_diff_theoretical_decoded( k1, k2, k3 ), errors_max_diff_theoretical_decoded( k1, k2, k3 ), errors_max_percent_diff_theoretical_decoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_difference_statistics( errors_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_theoretical_decoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_decoded_absolute( k1, k2, k3 ), errors_rmse_theoretical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_std_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_theoretical_decoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_min_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_theoretical_decoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_max_theoretical_decoded_absolute( k1, k2, k3 ), errors_max_theoretical_decoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_relative( k1, k2, k3 ) );
            
            % Compute the difference between the numerical absolute and relative network errors.
            [ errors_diff_numerical_encoded( :, k1, k2, k3 ), errors_percent_diff_numerical_encoded( :, k1, k2, k3 ), errors_mse_diff_numerical_encoded( k1, k2, k3 ), errors_mse_percent_diff_numerical_encoded( k1, k2, k3 ), errors_std_diff_numerical_encoded( k1, k2, k3 ), errors_std_percent_diff_numerical_encoded( k1, k2, k3 ), errors_min_diff_numerical_encoded( k1, k2, k3 ), errors_min_percent_diff_numerical_encoded( k1, k2, k3 ), errors_max_diff_numerical_encoded( k1, k2, k3 ), errors_max_percent_diff_numerical_encoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_difference_statistics( errors_numerical_encoded_absolute( :, k1, k2, k3 ), errors_numerical_encoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_encoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_encoded_absolute( k1, k2, k3 ), errors_rmse_numerical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_std_numerical_encoded_absolute( k1, k2, k3 ), errors_std_numerical_encoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_min_numerical_encoded_absolute( k1, k2, k3 ), errors_min_numerical_encoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_max_numerical_encoded_absolute( k1, k2, k3 ), errors_max_numerical_encoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_encoded_relative( k1, k2, k3 ) );
            [ errors_diff_numerical_decoded( :, k1, k2, k3 ), errors_percent_diff_numerical_decoded( :, k1, k2, k3 ), errors_mse_diff_numerical_decoded( k1, k2, k3 ), errors_mse_percent_diff_numerical_decoded( k1, k2, k3 ), errors_std_diff_numerical_decoded( k1, k2, k3 ), errors_std_percent_diff_numerical_decoded( k1, k2, k3 ), errors_min_diff_numerical_decoded( k1, k2, k3 ), errors_min_percent_diff_numerical_decoded( k1, k2, k3 ), errors_max_diff_numerical_decoded( k1, k2, k3 ), errors_max_percent_diff_numerical_decoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_difference_statistics( errors_numerical_decoded_absolute( :, k1, k2, k3 ), errors_numerical_decoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_decoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_decoded_absolute( k1, k2, k3 ), errors_rmse_numerical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_std_numerical_decoded_absolute( k1, k2, k3 ), errors_std_numerical_decoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_min_numerical_decoded_absolute( k1, k2, k3 ), errors_min_numerical_decoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_max_numerical_decoded_absolute( k1, k2, k3 ), errors_max_numerical_decoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_decoded_relative( k1, k2, k3 ) );
            
            % Compute the improvement between the theoretical absolute and relative network errors.
            [ errors_improv_theoretical_encoded( :, k1, k2, k3 ), errors_percent_improv_theoretical_encoded( :, k1, k2, k3 ), errors_mse_improv_theoretical_encoded( k1, k2, k3 ), errors_mse_percent_improv_theoretical_encoded( k1, k2, k3 ), errors_std_improv_theoretical_encoded( k1, k2, k3 ), errors_std_percent_improv_theoretical_encoded( k1, k2, k3 ), errors_min_improv_theoretical_encoded( k1, k2, k3 ), errors_min_percent_improv_theoretical_encoded( k1, k2, k3 ), errors_max_improv_theoretical_encoded( k1, k2, k3 ), errors_max_percent_improv_theoretical_encoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_improvement_statistics( errors_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_theoretical_encoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_encoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_encoded_absolute( k1, k2, k3 ), errors_rmse_theoretical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_std_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_theoretical_encoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_min_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_theoretical_encoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_encoded_relative( k1, k2, k3 ), errors_max_theoretical_encoded_absolute( k1, k2, k3 ), errors_max_theoretical_encoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_encoded_relative( k1, k2, k3 ) );
            [ errors_improv_theoretical_decoded( :, k1, k2, k3 ), errors_percent_improv_theoretical_decoded( :, k1, k2, k3 ), errors_mse_improv_theoretical_decoded( k1, k2, k3 ), errors_mse_percent_improv_theoretical_decoded( k1, k2, k3 ), errors_std_improv_theoretical_decoded( k1, k2, k3 ), errors_std_percent_improv_theoretical_decoded( k1, k2, k3 ), errors_min_improv_theoretical_decoded( k1, k2, k3 ), errors_min_percent_improv_theoretical_decoded( k1, k2, k3 ), errors_max_improv_theoretical_decoded( k1, k2, k3 ), errors_max_percent_improv_theoretical_decoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_improvement_statistics( errors_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_theoretical_decoded_relative( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_theoretical_decoded_relative( :, k1, k2, k3 ), errors_rmse_theoretical_decoded_absolute( k1, k2, k3 ), errors_rmse_theoretical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_std_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_theoretical_decoded_relative( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_min_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_theoretical_decoded_relative( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_theoretical_decoded_relative( k1, k2, k3 ), errors_max_theoretical_decoded_absolute( k1, k2, k3 ), errors_max_theoretical_decoded_relative( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_theoretical_decoded_relative( k1, k2, k3 ) );
            
            % Compute the improvement between the numerical absolute and relative network errors.
            [ errors_improv_numerical_encoded( :, k1, k2, k3 ), errors_percent_improv_numerical_encoded( :, k1, k2, k3 ), errors_mse_improv_numerical_encoded( k1, k2, k3 ), errors_mse_percent_improv_numerical_encoded( k1, k2, k3 ), errors_std_improv_numerical_encoded( k1, k2, k3 ), errors_std_percent_improv_numerical_encoded( k1, k2, k3 ), errors_min_improv_numerical_encoded( k1, k2, k3 ), errors_min_percent_improv_numerical_encoded( k1, k2, k3 ), errors_max_improv_numerical_encoded( k1, k2, k3 ), errors_max_percent_improv_numerical_encoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_improvement_statistics( errors_numerical_encoded_absolute( :, k1, k2, k3 ), errors_numerical_encoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_encoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_encoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_encoded_absolute( k1, k2, k3 ), errors_rmse_numerical_encoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_std_numerical_encoded_absolute( k1, k2, k3 ), errors_std_numerical_encoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_min_numerical_encoded_absolute( k1, k2, k3 ), errors_min_numerical_encoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_encoded_relative( k1, k2, k3 ), errors_max_numerical_encoded_absolute( k1, k2, k3 ), errors_max_numerical_encoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_encoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_encoded_relative( k1, k2, k3 ) );
            [ errors_improv_numerical_decoded( :, k1, k2, k3 ), errors_percent_improv_numerical_decoded( :, k1, k2, k3 ), errors_mse_improv_numerical_decoded( k1, k2, k3 ), errors_mse_percent_improv_numerical_decoded( k1, k2, k3 ), errors_std_improv_numerical_decoded( k1, k2, k3 ), errors_std_percent_improv_numerical_decoded( k1, k2, k3 ), errors_min_improv_numerical_decoded( k1, k2, k3 ), errors_min_percent_improv_numerical_decoded( k1, k2, k3 ), errors_max_improv_numerical_decoded( k1, k2, k3 ), errors_max_percent_improv_numerical_decoded( k1, k2, k3 ) ] = numerical_method_utilities.compute_error_improvement_statistics( errors_numerical_decoded_absolute( :, k1, k2, k3 ), errors_numerical_decoded_relative( :, k1, k2, k3 ), errors_percentage_numerical_decoded_absolute( :, k1, k2, k3 ), errors_percentage_numerical_decoded_relative( :, k1, k2, k3 ), errors_rmse_numerical_decoded_absolute( k1, k2, k3 ), errors_rmse_numerical_decoded_relative( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_rmse_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_std_numerical_decoded_absolute( k1, k2, k3 ), errors_std_numerical_decoded_relative( k1, k2, k3 ), errors_std_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_std_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_min_numerical_decoded_absolute( k1, k2, k3 ), errors_min_numerical_decoded_relative( k1, k2, k3 ), errors_min_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_min_percentage_numerical_decoded_relative( k1, k2, k3 ), errors_max_numerical_decoded_absolute( k1, k2, k3 ), errors_max_numerical_decoded_relative( k1, k2, k3 ), errors_max_percentage_numerical_decoded_absolute( k1, k2, k3 ), errors_max_percentage_numerical_decoded_relative( k1, k2, k3 ) );
            
            
            %% Compute the Subnetwork Numerical Stability Information.
            
            % Define the property retrieval settings.
            as_matrix_flag = true;
            
            % Define the stability analysis timestep seed.
            dt0 = 1e-6;                                                                                                                                                             % [s] Numerical Stability Time Step.
            
            % Retrieve the properties necessary to compute the numerical stability parameters for an absolute and relative transmission subnetwork.
            [ Cms_absolute, Gms_absolute, Rs_absolute, gs_absolute, dEs_absolute, Ias_absolute ] = network_absolute.get_numerical_stability_parameters( network_absolute.neuron_manager, network_absolute.synapse_manager, as_matrix_flag, undetected_option );
            [ Cms_relative, Gms_relative, Rs_relative, gs_relative, dEs_relative, Ias_relative ] = network_relative.get_numerical_stability_parameters( network_relative.neuron_manager, network_relative.synapse_manager, as_matrix_flag, undetected_option );
            
            % Compute the realtive transmission steady state output.
            [ ~, As_absolute, dts_absolute, condition_numbers_absolute ] = network_absolute.achieved_transmission_RK4_stability_analysis( Us_desired_absolute( :, 1 ), Cms_absolute, Gms_absolute, Rs_absolute, Ias_absolute, gs_absolute, dEs_absolute, dt0, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option, network_absolute.network_utilities );
            [ ~, As_relative, dts_relative, condition_numbers_relative ] = network_relative.achieved_transmission_RK4_stability_analysis( Us_desired_relative( :, 1 ), Cms_relative, Gms_relative, Rs_relative, Ias_relative, gs_relative, dEs_relative, dt0, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option, network_relative.network_utilities );
            
            % Retrieve the maximum RK4 step size.
            [ dts_max_absolute( k1, k2, k3 ), indexes_dt_absolute ] = max( dts_absolute );
            [ dts_max_relative( k1, k2, k3 ), indexes_dt_relative ] = max( dts_relative );
            
            % Retrieve the maximum condition number.
            [ condition_numbers_max_absolute( k1, k2, k3 ), indexes_condition_number_absolute ] = max( condition_numbers_absolute );
            [ condition_numbers_max_relative( k1, k2, k3 ), indexes_condition_number_relative ] = max( condition_numbers_relative );
            
            
            %% Print the Numerical Stability Information.
            
            % % Print out the stability information.
            % network_absolute.numerical_method_utilities.print_numerical_stability_info( As_absolute, dts_absolute, network_dt, condition_numbers_absolute );
            % network_relative.numerical_method_utilities.print_numerical_stability_info( As_relative, dts_relative, network_dt, condition_numbers_relative );
            
            
        end
    end
end


%% Define Plotting Parameters.

% Define a scaling factor.
scale = 1e3;

% Define the line colors.
color1 = [ 0.0000, 0.4470, 0.7410, 1.0000 ];
color2 = [ 0.8500, 0.3250, 0.0980, 1.0000 ];

% % Retrieve the numerical input.
% xs_numerical_input = xs_numerical_absolute( :, 1 );
% Us_numerical_input = Us_numerical_absolute( :, 1 );
% 
% % Define the input grid.
% [ Cs, Xs_input ] = meshgrid( cs, xs_numerical_input );
% [ ~, Us_input ] = meshgrid( cs, Us_numerical_input );

% c1, c3, delta, x1


% ---------- Output Plots ----------

% U2 vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% x2 vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% U2 vs U1, where U2 is averaged over c1, c3, & delta (also add curve where U2 is minimized over the fixed parameters, and where U2 is maximized over the fixed parameters).
% x2 vs x1, where U2 is averaged over c1, c3, & delta (also add curve where U2 is minimized over the fixed parameters, and where U2 is maximized over the fixed parameters).


% U2 vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% U2 vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% U2 vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% x2 vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% x2 vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% x2 vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% U2 vs U1 & c1, where U2 is averaged over c3 & delta (also add curve where U2 is minimized over the fixed parameters, and where U2 is maximized over the fixed parameters).
% U2 vs U1 & c3, where U2 is averaged over c1 & delta (also add curve where U2 is minimized over the fixed parameters, and where U2 is maximized over the fixed parameters).
% U2 vs U1 & delta, where U2 is averaged over c1 & c3 (also add curve where U2 is minimized over the fixed parameters, and where U2 is maximized over the fixed parameters).

% x2 vs x1 & c1, where x2 is averaged over c3 & delta (also add curve where x2 is minimized over the fixed parameters, and where x2 is maximized over the fixed parameters).
% x2 vs x1 & c3, where x2 is averaged over c1 & delta (also add curve where x2 is minimized over the fixed parameters, and where x2 is maximized over the fixed parameters).
% x2 vs x1 & delta, where x2 is averaged over c1 & c3 (also add curve where x2 is minimized over the fixed parameters, and where x2 is maximized over the fixed parameters).


% ---------- Error Plots ----------

% E vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% E vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% E vs U1, where E is averaged over c1, c3, & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).
% E vs x1, where E is averaged over c1, c3, & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).


% E vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% E vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% E vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% E vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% E vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% E vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% E vs U1 & c1, where E is averaged over c3 & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).
% E vs U1 & c3, where E is averaged over c1 & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).
% E vs U1 & delta, where E is averaged over c1 & c3 (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).

% E vs x1 & c1, where E is averaged over c3 & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).
% E vs x1 & c3, where E is averaged over c1 & delta (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).
% E vs x1 & delta, where E is averaged over c1 & c3 (also add curve where E is minimized over the fixed parameters, and where E is maximized over the fixed parameters).


% E vs c1 @ specific c3 & delta (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).
% E vs c3 @ specific c1 & delta (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).
% E vs delta @ specific c1 & c3 (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).

% E vs c1 @ specific c3 & delta (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).
% E vs c3 @ specific c1 & delta (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).
% E vs delta @ specific c1 & c3 (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).



% ---------- Error Difference Plots ----------

% dE vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% dE vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% dE vs U1, where E is averaged over c1, c3, & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).
% dE vs x1, where E is averaged over c1, c3, & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).


% dE vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% dE vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% dE vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% dE vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% dE vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% dE vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% dE vs U1 & c1, where dE is averaged over c3 & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).
% dE vs U1 & c3, where dE is averaged over c1 & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).
% dE vs U1 & delta, where dE is averaged over c1 & c3 (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).

% dE vs x1 & c1, where dE is averaged over c3 & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).
% dE vs x1 & c3, where dE is averaged over c1 & delta (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).
% dE vs x1 & delta, where dE is averaged over c1 & c3 (also add curve where dE is minimized over the fixed parameters, and where dE is maximized over the fixed parameters).


% dE vs c1 @ specific c3 & delta (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).
% dE vs c3 @ specific c1 & delta (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).
% dE vs delta @ specific c1 & c3 (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).

% dE vs c1 @ specific c3 & delta (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).
% dE vs c3 @ specific c1 & delta (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).
% dE vs delta @ specific c1 & c3 (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).



% ---------- Error Improvement Plots ----------

% |dE| vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% |dE| vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% |dE| vs U1, where E is averaged over c1, c3, & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).
% |dE| vs x1, where E is averaged over c1, c3, & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).


% |dE| vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% |dE| vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% |dE| vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% |dE| vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% |dE| vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% |dE| vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% |dE| vs U1 & c1, where |dE| is averaged over c3 & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).
% |dE| vs U1 & c3, where |dE| is averaged over c1 & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).
% |dE| vs U1 & delta, where |dE| is averaged over c1 & c3 (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).

% |dE| vs x1 & c1, where |dE| is averaged over c3 & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).
% |dE| vs x1 & c3, where |dE| is averaged over c1 & delta (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).
% |dE| vs x1 & delta, where |dE| is averaged over c1 & c3 (also add curve where |dE| is minimized over the fixed parameters, and where |dE| is maximized over the fixed parameters).


% |dE| vs c1 @ specific c3 & delta (median of each fixed parameter) where |dE| is averaged over U1 (& |dE| is minimized over U1 & |dE| is maximized over U1).
% |dE| vs c3 @ specific c1 & delta (median of each fixed parameter) where |dE| is averaged over U1 (& |dE| is minimized over U1 & |dE| is maximized over U1).
% |dE| vs delta @ specific c1 & c3 (median of each fixed parameter) where |dE| is averaged over U1 (& |dE| is minimized over U1 & |dE| is maximized over U1).

% |dE| vs c1 @ specific c3 & delta (median of each fixed parameter) where |dE| is averaged over x1 (& |dE| is minimized over x1 & |dE| is maximized over x1).
% |dE| vs c3 @ specific c1 & delta (median of each fixed parameter) where |dE| is averaged over x1 (& |dE| is minimized over x1 & |dE| is maximized over x1).
% |dE| vs delta @ specific c1 & c3 (median of each fixed parameter) where |dE| is averaged over x1 (& |dE| is minimized over x1 & |dE| is maximized over x1).



% ---------- Maximum RK4 Step Size ----------

% dts vs c1 & c3 @ specific delta (median of each fixed parameter).


% ---------- Condition Number ----------

% k vs c1 & c3 @ specific delta (median of each fixed parameter).



% ---------- Subnetwork Properties ----------

% c2 vs c1 & c3 @ specific delta (median of each fixed parameter).
% x2_max vs c1 & c3 @ specific delta (median of each fixed parameter).
% R1 vs c1 & c3 @ specific delta (median of each fixed parameter).
% R2 vs c1 & c3 @ specific delta (median of each fixed parameter).
% Gna1 vs c1 & c3 @ specific delta (median of each fixed parameter).
% Gna2 vs c1 & c3 @ specific delta (median of each fixed parameter).
% dEs21 vs c1 & c3 @ specific delta (median of each fixed parameter).
% gs21 vs c1 & c3 @ specific delta (median of each fixed parameter).
% Ia2 vs c1 & c3 @ specific delta (median of each fixed parameter).



%% Plot the Encoded Steady State Behavior.

% Plot the encoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Absolute Encoded Steady State Response' ); hold on, grid on, rotate3d on, view( 45, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Transmission: Absolute Encoded Steady State Response' ), zlim( [ 0, 0.160*scale ] )
surf( Cs, scale*Us_input, scale*Us_desired_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_theoretical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_numerical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_absolute_encoded_ss_response_gain' ] ) 

fig = figure( 'Color', 'w', 'Name', 'Transmission: Relative Encoded Steady State Response' ); hold on, grid on, rotate3d on, view( 45, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Transmission: Relative Encoded Steady State Response' ), zlim( [ 0, 0.020*scale ] )
surf( Cs, scale*Us_input, scale*Us_desired_relative_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_theoretical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_numerical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_relative_encoded_ss_response_gain' ] ) 


%% Plot the Decoded Steady State Behavior.

% Plot the absolute decoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Absolute Decoded Steady State Response' ); hold on, grid on, rotate3d on, view( 45, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Transmission: Absolute Decoded Steady State Response' )
surf( Cs, scale*Xs_input, scale*Xs_desired_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*Xs_theoretical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*Xs_numerical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_absolute_decoded_ss_response_gain' ] ) 

% Plot the relative decoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Relative Decoded Steady State Response' ); hold on, grid on, rotate3d on, view( 45, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Transmission: Relative Decoded Steady State Response' )
surf( Cs, scale*Xs_input, scale*Xs_desired_relative_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*Xs_theoretical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*Xs_numerical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_relative_decoded_ss_response_gain' ] ) 


%% Plot the Encoded Error vs Gain.

% Plot the encoded error vs gain comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error' ); 
subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mv]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Error' )
surf( Cs, scale*Us_input, scale*errors_theoretical_encoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_theoretical_encoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mv]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Error' )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_gain_comparison' ] ) 

% Plot the theoretical encoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Theoretical Encoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mv]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Us_input, scale*errors_theoretical_encoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_theoretical_encoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_theoretical_encoded_error_gain' ] ) 

% Plot the numerical encoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Numerical Encoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mv]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_numerical_encoded_error_gain' ] ) 

% Plot the encoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mv]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Encoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_numerical_encoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_gain' ] ) 

% Plot the encoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Summary' );
subplot( 2, 2, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_theoretical_encoded_absolute; flipud( scale*errors_max_theoretical_encoded_absolute ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_encoded_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_encoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_encoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 2, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_theoretical_encoded_relative; flipud( scale*errors_max_theoretical_encoded_relative ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_encoded_relative, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_encoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_encoded_relative, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 2, 3 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_absolute; flipud( scale*errors_max_numerical_encoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 2, 4 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_relative; flipud( scale*errors_max_numerical_encoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_gain_summary_comparison' ] )

% Plot the theoretical encoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Theoretical Encoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_theoretical_encoded_absolute; flipud( scale*errors_max_theoretical_encoded_absolute ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_encoded_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_encoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_encoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Theoretical Encoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_theoretical_encoded_relative; flipud( scale*errors_max_theoretical_encoded_relative ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_encoded_relative, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_encoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_encoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_theoretical_encoded_error_gain_summary' ] ) 

% Plot the numerical encoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Numerical Encoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_absolute; flipud( scale*errors_max_numerical_encoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Numerical Encoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_relative; flipud( scale*errors_max_numerical_encoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_numerical_encoded_error_gain_summary' ] )

% Plot the encoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Encoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_absolute; flipud( scale*errors_max_numerical_encoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'Transmission: Encoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_numerical_encoded_relative; flipud( scale*errors_max_numerical_encoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_encoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_encoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_gain_summary' ] )


%% Plot the Decoded Error vs Gain.

% Plot the decoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error' ); 
subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'Transmission: Theoretical Decoded Error' )
surf( Cs, scale*Xs_input, scale*errors_theoretical_decoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_theoretical_decoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )

subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'Transmission: Numerical Decoded Error' )
surf( Cs, Xs_input, scale*errors_numerical_decoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, Xs_input, scale*errors_numerical_decoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_gain_comparison' ] ) 

% Plot the theoretical decoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Theoretical Decoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'Transmission: Theoretical Decoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Xs_input, scale*errors_theoretical_decoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_theoretical_decoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_theoretical_decoded_error_gain' ] ) 

% Plot the numerical decoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Numerical Decoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'Transmission: Numerical Decoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Xs_input, scale*errors_numerical_decoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_numerical_decoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_numerical_decoded_error_gain' ] ) 

% Plot the decoded error vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error' ); hold on, grid on, rotate3d on, view( 25, 10 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Error' ), zlim( [ 0, 70 ] )
surf( Cs, scale*Xs_input, scale*errors_numerical_decoded_absolute, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_numerical_decoded_relative, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_gain' ] ) 

% Plot the decoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Summary' );
subplot( 2, 2, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Theoretical Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_theoretical_decoded_absolute; flipud( errors_max_theoretical_decoded_absolute ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_decoded_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_decoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_decoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 2, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Theoretical Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_theoretical_decoded_relative; flipud( errors_max_theoretical_decoded_relative ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_decoded_relative, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_decoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_decoded_relative, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 2, 3 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Numerical Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_absolute; flipud( errors_max_numerical_decoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 2, 4 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Numerical Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_relative; flipud( errors_max_numerical_decoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_gain_summary_comparison' ] ) 

% Plot the theoretical decoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Theoretical Decoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Theoretical Decoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_theoretical_decoded_absolute; flipud( errors_max_theoretical_decoded_absolute ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_decoded_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_decoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_decoded_absolute, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Theoretical Decoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_theoretical_decoded_relative; flipud( errors_max_theoretical_decoded_relative ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_theoretical_decoded_relative, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_theoretical_decoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_theoretical_decoded_relative, '--', 'Color', color1, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_theoretical_decoded_error_gain_summary' ] ) 

% Plot the numerical decoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Numerical Decoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Numerical Decoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_absolute; flipud( errors_max_numerical_decoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Numerical Decoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_relative; flipud( errors_max_numerical_decoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_numerical_decoded_error_gain_summary' ] )

% Plot the decoded error vs gain summary.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Absolute Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_absolute; flipud( errors_max_numerical_decoded_absolute ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_absolute, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_absolute, '--', 'Color', color2, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'Transmission: Decoded Relative Error Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_numerical_decoded_relative; flipud( errors_max_numerical_decoded_relative ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_rmse_numerical_decoded_relative, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_numerical_decoded_relative, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_gain_summary' ] )


%% Plot the Encoded Error Difference vs Gain.

% Plot the encoded error difference. 
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Difference' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Difference, dE [mV]' ), title( 'Transmission: Encoded Error Difference' )
surf( Cs, scale*Us_input, scale*errors_diff_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_diff_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_difference_gain' ] ) 

% Plot the encoded error difference percentage.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Difference Percentage' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Difference Percentage, dE [%]' ), title( 'Transmission: Encoded Error Difference Percentage' )
surf( Cs, scale*Us_input, errors_percent_diff_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, errors_percent_diff_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_difference_percentage_gain' ] ) 

% Plot the encoded error difference.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Difference Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Difference, dE [mV]' ), title( 'Transmission: Encoded Theoretical Error Difference  Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_diff_theoretical_encoded; flipud( scale*errors_max_diff_theoretical_encoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_diff_theoretical_encoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_diff_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_diff_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Difference Summary, dE [mV]' ), title( 'Transmission: Encoded Numerical Error Difference Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_diff_numerical_encoded; flipud( scale*errors_max_diff_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_diff_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_diff_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_diff_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_difference_gain_summary' ] ) 

% Plot the encoded error percentage difference.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Percentage Difference Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Percentage Difference, E [%]' ), title( 'Transmission: Encoded Theoretical Error Percentage Difference Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_diff_theoretical_encoded; flipud( errors_max_percent_diff_theoretical_encoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_diff_theoretical_encoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, errors_min_percent_diff_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, errors_max_percent_diff_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Percentage Difference, E [%]' ), title( 'Transmission: Encoded Numerical Error Percentage Difference Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_diff_numerical_encoded; flipud( errors_max_percent_diff_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_diff_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_diff_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_diff_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_difference_percentage_gain_summary' ] ) 


%% Plot Decoded Error Difference vs Gain.

% Plot the decoded error difference.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Difference' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Difference, E [-]' ), title( 'Transmission: Decoded Error Difference' )
surf( Cs, scale*Xs_input, scale*errors_diff_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_diff_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_difference_gain' ] ) 

% Plot the decoded error difference percentage.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Difference Percentage' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Difference Percentage, E [%]' ), title( 'Transmission: Decoded Error Difference Percentage' )
surf( Cs, scale*Xs_input, errors_percent_diff_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, errors_percent_diff_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_difference_percentage_gain' ] ) 

% % Plot the decoded mse difference.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded MSE Difference' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded MSE Difference, mse [-]' ), title( 'Transmission: Decoded MSE Difference' )
% plot( cs, errors_mse_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_mse_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_mse_difference_gain' ] ) 
% 
% % Plot the decoded mse difference percentage.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded MSE Difference Percentage' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded MSE Difference Percentage, mse [%]' ), title( 'Transmission: Decoded MSE Difference Percentage' )
% plot( cs, errors_mse_percent_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_mse_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_mse_percent_difference_gain' ] ) 
% 
% % Plot the decoded std difference.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded STD Difference' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded STD Difference, std [-]' ), title( 'Transmission: Decoded STD Difference' )
% plot( cs, errors_std_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_std_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_std_difference_gain' ] ) 
% 
% % Plot the decoded std percentage difference.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded STD Difference Percentage' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded STD Difference Percentage, std [%]' ), title( 'Transmission: Decoded STD Difference Percentage' )
% plot( cs, errors_std_percent_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_std_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_std_percent_difference_gain' ] ) 
% 
% % Plot the decoded minimum error difference.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Minimum Error Difference' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Minimum Error Difference, Emin [-]' ), title( 'Transmission: Decoded Minimum Error Difference' )
% plot( cs, errors_min_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_min_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_min_error_difference_gain' ] ) 
% 
% % Plot the decoded minimum error difference percentage.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Minimum Error Difference Percentage' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Minimum Error Difference Percentage, Emin [%]' ), title( 'Transmission: Decoded Minimum Error Difference Percentage' )
% plot( cs, errors_min_percent_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_min_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_min_percent_error_difference_gain' ] ) 
% 
% % Plot the decoded maximum error difference.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Maximum Error Difference' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Maximum Error Difference, Emin [-]' ), title( 'Transmission: Decoded Maximum Error Difference' )
% plot( cs, errors_max_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_max_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_max_error_difference_gain' ] ) 
% 
% % Plot the decoded maximum error difference percentage.
% fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Maximum Error Difference Percentage' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Maximum Error Difference Percentage, Emax [%]' ), title( 'Transmission: Decoded Maximum Error Difference Percentage' )
% plot( cs, errors_max_percent_diff_theoretical_decoded, '-.', 'Color', color1, 'Linewidth', 3 )
% plot( cs, errors_max_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 3 )
% legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% saveas( fig, [ save_directory, '\', 'transmission_decoded_max_percent_error_difference_gain' ] ) 

% Plot the decoded error difference.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Difference Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Difference, E [-]' ), title( 'Transmission: Decoded Theoretical Error Difference Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_diff_theoretical_decoded; flipud( errors_max_diff_theoretical_decoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_diff_theoretical_decoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_diff_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_diff_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Difference, E [-]' ), title( 'Transmission: Decoded Numerical Error Difference Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_diff_numerical_decoded; flipud( errors_max_diff_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_diff_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_error_difference_gain_summary' ] ) 

% Plot the decoded error percentage difference.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Percentage Difference Summary' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Percentage Difference, E [%]' ), title( 'Transmission: Decoded Theoretical Error Percentage Difference Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_diff_theoretical_decoded; flipud( errors_max_percent_diff_theoretical_decoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_diff_theoretical_decoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, errors_min_percent_diff_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, errors_max_percent_diff_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Percentage Difference, E [%]' ), title( 'Transmission: Decoded Numerical Error Percentage Difference Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_diff_numerical_decoded; flipud( errors_max_percent_diff_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_diff_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_diff_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )


%% Plot the Encoded Error Improvement vs Gain.

% Plot the encoded error improvement comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement Comparison' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Improvement, E [mV]' ), title( 'Transmission: Encoded Error Improvement Comparison' )
surf( Cs, scale*Us_input, scale*errors_improv_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*errors_improv_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_gain_comparison' ] ) 

% Plot the encoded error improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Improvement, E [mV]' ), title( 'Transmission: Encoded Error Improvement' )
surf( Cs, scale*Us_input, scale*errors_improv_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_gain' ] ) 

% Plot the encoded error improvement percentage comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement Percentage Comparison' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Improvement Percentage, E [%]' ), title( 'Transmission: Encoded Error Improvement Percentage Comparison' )
surf( Cs, scale*Us_input, errors_percent_improv_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, errors_percent_improv_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_percentage_gain_comparison' ] ) 

% Plot the encoded error improvement percentage.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement Percentage' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Error Improvement Percentage, E [%]' ), title( 'Transmission: Encoded Error Improvement Percentage' )
surf( Cs, scale*Us_input, errors_percent_improv_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_percentage_gain' ] ) 

% Plot the encoded error improvement comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement Summary Comparison' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Improvement, E [mV]' ), title( 'Transmission: Encoded Theoretical Error Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_improv_theoretical_encoded; flipud( scale*errors_max_improv_theoretical_encoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_theoretical_encoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Improvement, E [mV]' ), title( 'Transmission: Encoded Numerical Error Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_improv_numerical_encoded; flipud( scale*errors_max_improv_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_gain_summary' ] ) 

% Plot the encoded error improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Improvement Summary' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Improvement, E [mV]' ), title( 'Transmission: Encoded Error Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ scale*errors_min_improv_numerical_encoded; flipud( scale*errors_max_improv_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_gain_summary' ] ) 

% Plot the encoded error percentage improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Percentage Improvement Summary Comparison' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Encoded Theoretical Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_theoretical_encoded; flipud( errors_max_percent_improv_theoretical_encoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_theoretical_encoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_theoretical_encoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Encoded Numerical Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_numerical_encoded; flipud( errors_max_percent_improv_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_percentage_gain_summary_comparison' ] ) 

% Plot the encoded error percentage improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Encoded Error Percentage Improvement Summary' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Encoded Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_numerical_encoded; flipud( errors_max_percent_improv_numerical_encoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_numerical_encoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_numerical_encoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_encoded_error_improvement_percentage_gain_summary' ] ) 


%% Plot the Decoded Error Improvement vs Gain.

% Plot the decoded error improvement comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement Comparison' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Improvement, E [-]' ), title( 'Transmission: Decoded Error Improvement Comparison' )
surf( Cs, scale*Xs_input, scale*errors_improv_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, scale*errors_improv_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_gain_comparison' ] ) 

% Plot the decoded error improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Improvement, E [-]' ), title( 'Transmission: Decoded Error Improvement' )
surf( Cs, scale*Xs_input, scale*errors_improv_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_gain' ] ) 

% Plot the decoded error improvement percentage comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement Percentage Comparison' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Improvement Percentage, E [%]' ), title( 'Transmission: Decoded Error Improvement Percentage Comparison' )
surf( Cs, scale*Xs_input, errors_percent_improv_theoretical_decoded, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Xs_input, errors_percent_improv_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_percentage_gain_comparison' ] ) 

% Plot the decoded error improvement percentage.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement Percentage' ); hold on, grid on, rotate3d on, view( 45, 20 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Error Improvement Percentage, E [%]' ), title( 'Transmission: Decoded Error Improvement Percentage' )
surf( Cs, scale*Xs_input, errors_percent_improv_numerical_decoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_percentage_gain' ] ) 

% Plot the decoded error improvement comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement Summary Comparison' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Improvement, E [-]' ), title( 'Transmission: Decoded Theoretical Error Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_improv_theoretical_decoded; flipud( errors_max_improv_theoretical_decoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_theoretical_decoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Improvement, E [-]' ), title( 'Transmission: Decoded Numerical Error Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_improv_numerical_decoded; flipud( errors_max_improv_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_difference_gain_summary_comparison' ] ) 

% Plot the decoded error improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Improvement Summary' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Improvement, E [-]' ), title( 'Transmission: Decoded Numerical Error Improvement Summary' ), ylim( [ 0, 70 ] )
patch( [ cs'; flipud( cs' ) ], scale*[ errors_min_improv_numerical_decoded; flipud( errors_max_improv_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, scale*errors_mse_improv_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, scale*errors_min_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, scale*errors_max_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_difference_gain_summary' ] ) 

% Plot the encoded error percentage improvement comparison.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Percentage Improvement Summary Comparison' );
subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Decoded Theoretical Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_theoretical_decoded; flipud( errors_max_percent_improv_theoretical_decoded ) ], color1( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_theoretical_decoded, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_theoretical_decoded, '--', 'Color', color1, 'Linewidth', 1 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Decoded Numerical Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_numerical_decoded; flipud( errors_max_percent_improv_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_percentage_gain_summary_comparison' ] ) 

% Plot the encoded error percentage improvement.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Decoded Error Percentage Improvement Summary' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Error Percentage Improvement, E [%]' ), title( 'Transmission: Decoded Numerical Error Percentage Improvement Summary' )
patch( [ cs'; flipud( cs' ) ], [ errors_min_percent_improv_numerical_decoded; flipud( errors_max_percent_improv_numerical_decoded ) ], color2( 1:end - 1 ), 'FaceAlpha', 0.5, 'EdgeColor', 'None' )
plot( cs, errors_mse_percent_improv_numerical_decoded, '-', 'Color', color2, 'Linewidth', 3 )
plot( cs, errors_min_percent_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
plot( cs, errors_max_percent_improv_numerical_decoded, '--', 'Color', color2, 'Linewidth', 1 )
saveas( fig, [ save_directory, '\', 'transmission_decoded_error_improvement_percentage_gain_summary' ] ) 


%% Plot the Numerical Stability Information vs Gain.

% Plot the maximum RK4 step size.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Maximum RK4 Step Size' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Max RK4 Step Size, dt [s]' ), title( 'Transmission: Maximum RK4 Step Size' )
plot( cs, dts_max_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, dts_max_relative, '-', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_max_rk4_step_size_gain' ] ) 

% Plot the maximum condition number.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Maximum Condition Number' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Max Condition Number [-]' ), title( 'Transmission: Maximum Condition Number' )
plot( cs, condition_numbers_max_absolute, '-', 'Color', color1, 'Linewidth', 3 )
plot( cs, condition_numbers_max_relative, '-', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_max_condition_number_gain' ] ) 


%% Plot Network Parameters vs Gain.

% Plot the maximum decoded output vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Maximum Decoded Output' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Maximum Decoded Output, x2_max [-]' ), title( 'Transmission: Maximum Decoded Output' )
plot( cs, scale*x2maxs_absolute, '--', 'Color', color1, 'Linewidth', 3 )
plot( cs, scale*x2maxs_relative , '--', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_maximum_decoded_output_gain' ] )

% Plot the maximum membrane voltage vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Maximum Membrane Voltage' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Maximum Membrane Voltage, R [V]' ), title( 'Transmission: Maximum Membrane Voltage' )
plot( cs, R1s_absolute, '-.', 'Color', color1, 'Linewidth', 3 )
plot( cs, R2s_absolute, '--', 'Color', color1, 'Linewidth', 3 )
plot( cs, R1_relative*ones( size( cs ) ) , '-.', 'Color', color2, 'Linewidth', 3 )
plot( cs, R2_relative*ones( size( cs ) ) , '--', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute 1', 'Absolute 2', 'Relative 1', 'Relative 2' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_maximum_membrane_voltage_gain' ] )

% Plot the sodium channel conductance vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Sodium Channel Conductance' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Sodium Channel Conductance, Gna [S]' ), title( 'Transmission: Sodium Channel Conductance' )
plot( cs, Gna1s_absolute, '-.', 'Color', color1, 'Linewidth', 3 )
plot( cs, Gna2s_absolute, '--', 'Color', color1, 'Linewidth', 3 )
plot( cs, Gna1s_relative, '-.', 'Color', color2, 'Linewidth', 3 )
plot( cs, Gna2s_relative, '--', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute 1', 'Absolute 2', 'Relative 1', 'Relative 2' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_sodium_channel_conductance_gain' ] )

% Plot the synaptic reversal potential vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Synaptic Reversal Potential' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Synaptic Reversal Potential, dE [V]' ), title( 'Transmission: Synaptic Reversal Potential' )
plot( cs, dEs21s_absolute, '-.', 'Color', color1, 'Linewidth', 3 )
plot( cs, dEs21s_relative, '-.', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_synaptic_reversal_potential_gain' ] )

% Plot the maximum synaptic conductance vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Maximum Synaptic Conductance' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Maximum Synaptic Conductance, gs [S]' ), title( 'Transmission: Maximum Synaptic Conductance' )
plot( cs, gs21s_absolute, '-.', 'Color', color1, 'Linewidth', 3 )
plot( cs, gs21s_relative, '-.', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_max_synaptic_conductance_gain' ] )

% Plot the steady state applied current vs gain.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Applied Current' ); hold on, grid on, xlabel( 'Gain, c [-]' ), ylabel( 'Applied Current, Ia [A]' ), title( 'Transmission: Applied Current' )
plot( cs, Ia2s_absolute, '-.', 'Color', color1, 'Linewidth', 3 )
plot( cs, Ia2s_relative, '-.', 'Color', color2, 'Linewidth', 3 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'transmission_applied_currents_gain' ] )

