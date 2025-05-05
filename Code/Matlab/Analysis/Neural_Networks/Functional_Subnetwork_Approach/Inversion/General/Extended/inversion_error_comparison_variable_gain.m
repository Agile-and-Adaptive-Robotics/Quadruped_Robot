%% Inversion Subnetwork Encoding Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                         	% [str] Save Directory.
load_directory = '.\Load';                        	% [str] Load Directory.

% Define the network simulation time step.
% network_dt = 1e-3;                                 	% [s] Simulation Time Step.
% network_dt = 1e-4;                             	% [s] Simulation Timestep.
network_dt = 5e-5;                             	% [s] Simulation Timestep.
% network_dt = 1e-5;                             	% [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Define the step size adaptation threshold.
epsilon = 0.80;                                     % [0-1] Adapted Step Size Threshold (Detemines how close to the maximum acceptable simulation step size an adapted step size can be made.)

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Compute the number of simulation timesteps.
n_timesteps = length( ts );                         % [#] Number of Simulation Timesteps.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the number of input signals.
n_input_signals = 20;                               % [#] Number of Input Signals.

% Define whether to save simulation data.
simulate_flag = false;                             	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
% simulate_flag = true;                             	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
save_flag = true;                                   % [T/F] Save Flag.  (Determine whether to save simulation data.
verbose_flag = true;                            	% [T/F] Printing Flag. (Determines whether to print out information.)
adapt_step_size_flag = true;                        % [T/F] Adapt Step Size Flag.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';                        % [str] Undetected Option.

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );
numerical_method_utilities = numerical_method_utilities_class(  );
plotting_utilities = plotting_utilities_class(  );


%% Define the Desired Subnetwork Formulation Parameters.

% Define the number of gains.
num_c1s = 5;
num_c3s = 5;
num_deltas = 5;

% Define the minimum and maximum formulation params.
c1_min = 20e-6; c1_max = 80e-6;
c3_min = 0.25e-3; c3_max = 1e-3;
delta_min = 1e-4; delta_max = 1e-3;

% Define the subnetwork formulation parameter arrays.
c1s = linspace( c1_min, c1_max, num_c1s );                                            % [-] Subnetwork Gain 1.
c3s = linspace( c3_min, c3_max, num_c3s );                                            % [-] Subnetwork Gain 1.
deltas = linspace( delta_min, delta_max, num_deltas );                                % [-] Subnetwork Offset.


%% Debugging

% [ C1s, C3s ] = ndgrid( c1s, c3s );
% 
% X2_maxs = C1s./C3s;
% 
% [ row_maxs, row_max_indexes ] = max( X2_maxs );
% [ true_max, col_max_index ] = max( row_maxs );
% 
% c1_max = C1s( row_max_indexes( col_max_index ), col_max_index );
% c3_max = C3s( row_max_indexes( col_max_index ), col_max_index );
% 
% [ row_mins, row_min_indexes ] = min( X2_maxs );
% [ true_min, col_min_index ] = min( row_mins );
% 
% c1_min = C1s( row_min_indexes( col_min_index ), col_min_index );
% c3_min = C3s( row_min_indexes( col_min_index ), col_min_index );
% 
% fprintf( 'Maximum: x2_max = %0.3e when c1 = %0.3e and c3 = %0.3e.\n', true_max, c1_max, c3_max )
% fprintf( 'Minimum: x2_max = %0.3e when c1 = %0.3e and c3 = %0.3e.\n', true_min, c1_min, c3_min )


%% Define the Constant Subnetwork Parameters.

% Define the subnetwork formulation params (shared by both encoding schemes).
x1_max = 20e-3;

% Define the transmission subnetwork design params.
Gm1_absolute = 1e-6;                                        % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                      	% [S] Membrane Conductance (Neuron 2).
Cm1_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 2).

% Store the transmission subnetwork design params.
absolute_inversion_input_params.x1_max = x1_max;
absolute_inversion_input_params.Gm1 = Gm1_absolute;
absolute_inversion_input_params.Gm2 = Gm2_absolute;
absolute_inversion_input_params.Cm1 = Cm1_absolute;
absolute_inversion_input_params.Cm2 = Cm2_absolute;

% Define the transmission subnetwork design params.
R1_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 1).
R2_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 2).
Gm1_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 2).
Cm1_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 2).

% Store the transmission subnetwork design params.
relative_inversion_input_params.x1_max = x1_max;
relative_inversion_input_params.R1 = R1_relative;
relative_inversion_input_params.R2 = R2_relative;
relative_inversion_input_params.Gm1 = Gm1_relative;
relative_inversion_input_params.Gm2 = Gm2_relative;
relative_inversion_input_params.Cm1 = Cm1_relative;
relative_inversion_input_params.Cm2 = Cm2_relative;


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

% Create arrays to store the network params.
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

% Compute the total number of simulations.
num_simulations = num_c1s*num_c3s*num_deltas;

% Define an aggregate loop counter.
k = 1;

% Start a global timer for all of the simulations.
global_start_time = tic;

% Print out header information.
fprintf( '\n--------------------------------------------------------------------------------------------------------------------------------------------\n' )
fprintf( '---------------------------------------- INVERSION SUBNETWORK VARIABLE GAIN SIMULATIONS ----------------------------------------\n' )
fprintf( '--------------------------------------------------------------------------------------------------------------------------------------------\n\n' )

% Perform the following analysis given each gain value.
for k1 = 1:num_c1s                          % Iterate through each of the c1s...
    for k2 = 1:num_c3s                      % Iterate through each of the c3s...
        for k3 = 1:num_deltas               % Iterate through each of the deltas...
            
            % Start the timer for this iteration.
            simulation_start_time = tic;
            
            
            %% Print Out Simulation Progress.
            
            % Print out a status update.
            fprintf( 'Running simulation %0.0f of %0.0f (%0.2f%% Complete)...\n\n', k, num_simulations, 100*( k/num_simulations ) )
            
            
            %% Define the Variable Subnetwork Formulation Parameters.
            
            % Determine whether to print a status message.  
            if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tDefining formulation parameters...\n' ); end
            
            % Retrieve the variable subnetwork formulation params (shared by both encoding schemes).
            c1 = c1s( k1 );
            c3 = c3s( k2 );
            delta = deltas( k3 );
            
            % Store the variable subnetwork formulation params.
            absolute_inversion_input_params.c1 = c1;
            absolute_inversion_input_params.c3 = c3;
            absolute_inversion_input_params.delta = delta;
            
            relative_inversion_input_params.c1 = c1;
            relative_inversion_input_params.c3 = c3;
            relative_inversion_input_params.delta = delta;
            
            % Determine whether to print additional information.
            if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tDefining formulation parameters... Done!', local_start_time ); end
            
            
            %% Define the Absolute & Relative Subnetwork Input Currents.
            
            % Determine whether to print out a status message.
            if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tCreating subnetwork...\n' ); end
            
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
            
            
            %% Create the Subnetwork.
            
            % Create an instance of the network class.
            network_absolute = network_class( network_dt, network_tf );
            network_relative = network_class( network_dt, network_tf );

            % Create an inversion subnetwork.
            [ absolute_inversion_output_params, neurons_absolute, synapses_absolute, applied_currents_absolute, neuron_manager_absolute, synapse_manager_absolute, applied_current_manager_absolute, network_absolute ] = network_absolute.create_inversion_subnetwork( absolute_inversion_input_params, 'absolute', network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, true, true, false, undetected_option );
            [ relative_inversion_output_params, neurons_relative, synapses_relative, applied_currents_relative, neuron_manager_relative, synapse_manager_relative, applied_current_manager_relative, network_relative ] = network_relative.create_inversion_subnetwork( relative_inversion_input_params, 'relative', network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, true, true, false, undetected_option );

            % Unpack the subnetwork output params.
            [ c2s_absolute( k1, k2, k3 ), x2maxs_absolute( k1, k2, k3 ), R1s_absolute( k1, k2, k3 ), R2s_absolute( k1, k2, k3 ), Gna1s_absolute( k1, k2, k3 ), Gna2s_absolute( k1, k2, k3 ), dEs21s_absolute( k1, k2, k3 ), gs21s_absolute( k1, k2, k3 ), Ia2s_absolute( k1, k2, k3 ) ] = network_absolute.unpack_absolute_inversion_output_params( absolute_inversion_output_params, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option );
            [ c2s_relative( k1, k2, k3 ), x2maxs_relative( k1, k2, k3 ), Gna1s_relative( k1, k2, k3 ), Gna2s_relative( k1, k2, k3 ), dEs21s_relative( k1, k2, k3 ), gs21s_relative( k1, k2, k3 ), Ia2s_relative( k1, k2, k3 ) ] = network_relative.unpack_relative_inversion_output_params( relative_inversion_output_params, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option );

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
            
            % Determine whether to print out a status message.
            if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tCreating subnetwork... Done!', local_start_time ); end

            
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
            
            
            %% Compute the Subnetwork Numerical Stability Information.

            % Determine whether to print a status update.
            if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tAnalyzing subnetwork numerical stability...\n' ); end
            
            % Define the decoded input signals.
            xs_numerical_input = linspace( 0, x1_max, n_input_signals )';

            % Define the stability analysis timestep seed.
            dt0 = 1e-6;                                                                                                                                                             % [s] Numerical Stability Time Step.

            % Retrieve the properties necessary to compute the numerical stability params for an absolute and relative transmission subnetwork.
            [ Cms_absolute, Gms_absolute, Rs_absolute, gs_absolute, dEs_absolute, Ias_absolute ] = network_absolute.get_numerical_stability_params( network_absolute.neuron_manager, network_absolute.synapse_manager, true, undetected_option );
            [ Cms_relative, Gms_relative, Rs_relative, gs_relative, dEs_relative, Ias_relative ] = network_relative.get_numerical_stability_params( network_relative.neuron_manager, network_relative.synapse_manager, true, undetected_option );

            % Compute the relative inversion steady state output.
            [ ~, As_absolute, dts_absolute, condition_numbers_absolute ] = network_absolute.achieved_inversion_RK4_stability_analysis_decoded( xs_numerical_input, Cms_absolute, Gms_absolute, Rs_absolute, Ias_absolute, gs_absolute, dEs_absolute, dt0, f_encode1_absolute, f_decode2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, undetected_option, network_absolute.network_utilities );
            [ ~, As_relative, dts_relative, condition_numbers_relative ] = network_relative.achieved_inversion_RK4_stability_analysis_decoded( xs_numerical_input, Cms_relative, Gms_relative, Rs_relative, Ias_relative, gs_relative, dEs_relative, dt0, f_encode1_relative, @( xs ) f_decode2_relative( xs, c1, c3 ), network_relative.neuron_manager, network_relative.synapse_manager, undetected_option, network_relative.network_utilities );

            % Retrieve the maximum RK4 step size.
            [ dts_max_absolute( k1, k2, k3 ), indexes_dt_absolute ] = min( dts_absolute );
            [ dts_max_relative( k1, k2, k3 ), indexes_dt_relative ] = min( dts_relative );

            % Retrieve the maximum condition number.
            [ condition_numbers_max_absolute( k1, k2, k3 ), indexes_condition_number_absolute ] = max( condition_numbers_absolute );
            [ condition_numbers_max_relative( k1, k2, k3 ), indexes_condition_number_relative ] = max( condition_numbers_relative );


            %% Print the Numerical Stability Information.

%             % Print out the stability information.
%             network_absolute.numerical_method_utilities.print_numerical_stability_info( As_absolute, dts_absolute, network_dt, condition_numbers_absolute );
%             network_relative.numerical_method_utilities.print_numerical_stability_info( As_relative, dts_relative, network_dt, condition_numbers_relative );


            %% Process Simulation Step Sizes.

            % Create an array to store the step sizes.
            network_dts_absolute = network_dt*ones( n_input_signals, 1 );
            network_dts_relative = network_dt*ones( n_input_signals, 1 );

            % Determine whether to adapt the step sizes.
            if adapt_step_size_flag                     % If we want to adapt the step sizes...

                % Adapt the step sizes.
                network_dts_absolute = network_utilities.adapt_step_sizes( network_dts_absolute, dts_absolute, epsilon );
                network_dts_relative = network_utilities.adapt_step_sizes( network_dts_relative, dts_relative, epsilon );

            end
            
            % Determine whether to print out a status message.            
            if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tAnalyzing subnetwork numerical stability... Done!', local_start_time ); end
            
            
            %% Simulate the Subnetwork.
            
            % Determine whether to simulate the network.
            if simulate_flag                            % If we want to simulate the network...

                % Determine whether to print a status message.
                if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tSimulating absolute subnetwork...\n' ); end

                % Compute the decoded steady state simulation for the absolute subnetwork.
                [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.compute_steady_state_simulation_decoded( network_dts_absolute, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_absolute, f_decode2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, network_absolute.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_absolute.network_utilities );
                
                % Determine whether to print a status message.
                if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tSimulating absolute subnetwork... Done!', local_start_time ); end

                % Determine whether to print a status message.
                if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tSimulating relative subnetwork...\n' ); end
                
                % Compute the decoded steady state simulation for the relative subnetwork.
                [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.compute_steady_state_simulation_decoded( network_dts_relative, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_relative, @( xs ) f_decode2_relative( xs, c1, c3 ), network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, network_relative.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_relative.network_utilities );
                
                % Determine whether to print a status message.
                if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tSimulating relative subnetwork... Done!', local_start_time ); end

                % Determine whether to save the simulation data.
                if save_flag                    % If we want to save the simulation data...
                    
                    % Determine whether to print a status message.
                    if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tSaving simulation data...\n' ); end
                    
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
                    
                    % Determine whether to print a status message.
                    if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tSaving simulation data... Done!', local_start_time ); end
                    
                end
                
            else                % Otherwise... ( We must want to load data from an existing simulation... )
                
                % Determine whether to print a status message.
                if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tLoading simulation data...\n' ); end

                % Define the load file names.
                file_name_absolute = sprintf( 'absolute_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                file_name_relative = sprintf( 'relative_inversion_subnetwork_error_gain_%0.0f%0.0f%0.0f', k1, k2, k3 );
                
                % Load the simulation results.
                data_absolute = load( [ load_directory, '\', file_name_absolute ] );
                data_relative = load( [ load_directory, '\', file_name_relative ] );
                
                % Unpack the steady state simulation data.
                [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.unpack_steady_state_simulation_data( data_absolute.data_absolute );
                [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.unpack_steady_state_simulation_data( data_relative.data_relative );
                
                % Determine whether to print a status message.
                if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tLoading simulation data... Done!', local_start_time ); end
                
            end
            
            
            %% Compute the Absolute & Relative Desired & Achieved (Theory) Subnetwork Output.
            
            % Determine whether to print a status message.
            if verbose_flag, local_start_time = network_utilities.print_starting_status_message( '\tComputing error statistics...\n' ); end
            
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
                    
            % Print a status message.
            if verbose_flag, local_duration = network_utilities.print_ending_status_message( '\tComputing error statistics... Done!', local_start_time ); end

            
            %% Print Out a Status Message.
            
            % Retrieve the duration of this iteration.
            simulation_duration = toc( simulation_start_time );
            
            % Print out a message at the end of a simulation.
            fprintf( 'Running simulation %0.0f of %0.0f (%0.2f%% Complete)... Done. (Elapsed Time: %0.2e seconds = %0.2e minutes = %0.2e hours = %0.2e days)\n\n\n', k, num_simulations, 100*( k/num_simulations ), simulation_duration, simulation_duration/60, simulation_duration/( 60*60 ), simulation_duration/( 60*60*24 ) )
            
            % Advance the aggregate loop counter.
            k = k + 1;
            
            
        end
    end
end

% Compute the duration of all simulations.
global_duration = toc( global_start_time );

% Print out footer information.
fprintf( '--------------------------------------------------------------------------------------------------------------------------------------------\n' )
fprintf( 'Complete! Total Elapsed Time: %0.2e seconds = %0.2e minutes = %0.2e hours = %0.2e days\n', global_duration, global_duration/60, global_duration/( 60*60 ), global_duration/( 60*60*24 ) )
fprintf( '--------------------------------------------------------------------------------------------------------------------------------------------\n\n' )


%% Define Plotting Parameters.

% Define a scaling factor.
scale = 1e3;

% Define the line colors.
color1 = [ 0.0000, 0.4470, 0.7410 ];
color2 = [ 0.8500, 0.3250, 0.0980 ];

% Retrieve the numerical input.
xs_numerical_input = xs_numerical_absolute( :, 1 );
Us_numerical_input = Us_numerical_absolute( :, 1 );

% Retrieve the median formulation parameter values.
c1s_median = median( c1s ); 
c3s_median = median( c3s );
deltas_median = median( deltas );

% Retrieve the indexes associated with the median formulation parameter values.
c1s_median_index = find( c1s == c1s_median );
c3s_median_index = find( c3s == c3s_median );
deltas_median_index = find( deltas == deltas_median );

% Create grids from the relevant input data.
[ C1s_input, Us_input_c1 ] = meshgrid( c1s, Us_numerical_input );
[ ~, Xs_input_c1 ] = meshgrid( c1s, xs_numerical_input );

[ C3s_input, Us_input_c3 ] = meshgrid( c3s, Us_numerical_input );
[ ~, Xs_input_c3 ] = meshgrid( c3s, xs_numerical_input );

[ Deltas_input, Us_input_delta ] = meshgrid( deltas, Us_numerical_input );
[ ~, Xs_input_delta ] = meshgrid( deltas, xs_numerical_input );


% ---------- Median Steady State Outputs ----------

% Retrieve the encoded steady state outputs associated with the median formulation parameter simulations.
Us_desired_absolute_output_median = Us_desired_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
Us_theoretical_absolute_output_median = Us_theoretical_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
Us_numerical_absolute_output_median = Us_numerical_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );

Us_desired_relative_output_median = Us_desired_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
Us_theoretical_relative_output_median = Us_theoretical_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
Us_numerical_relative_output_median = Us_numerical_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );

% Retrieve the decoded steady state outputs associated with the median formulation parameter simulations.
xs_desired_absolute_output_median = Xs_desired_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
xs_theoretical_absolute_output_median = Xs_theoretical_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
xs_numerical_absolute_output_median = Xs_numerical_absolute_output( :, c1s_median_index, c3s_median_index, deltas_median_index );

xs_desired_relative_output_median = Xs_desired_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
xs_theoretical_relative_output_median = Xs_theoretical_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );
xs_numerical_relative_output_median = Xs_numerical_relative_output( :, c1s_median_index, c3s_median_index, deltas_median_index );


% ---------- Mean Steady State Outputs ----------

% Compute the average encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_mean = mean( Us_desired_absolute_output, [ 2, 3, 4 ] );
Us_theoretical_absolute_output_mean = mean( Us_theoretical_absolute_output, [ 2, 3, 4 ] );
Us_numerical_absolute_output_mean = mean( Us_numerical_absolute_output, [ 2, 3, 4 ] );

Us_desired_relative_output_mean = mean( Us_desired_relative_output, [ 2, 3, 4 ] );
Us_theoretical_relative_output_mean = mean( Us_theoretical_relative_output, [ 2, 3, 4 ] );
Us_numerical_relative_output_mean = mean( Us_numerical_relative_output, [ 2, 3, 4 ] );

% Compute the average encoded steady state outputs associated with the formulation parameters.
xs_desired_absolute_output_mean = mean( Xs_desired_absolute_output, [ 2, 3, 4 ] );
xs_theoretical_absolute_output_mean = mean( Xs_theoretical_absolute_output, [ 2, 3, 4 ] );
xs_numerical_absolute_output_mean = mean( Xs_numerical_absolute_output, [ 2, 3, 4 ] );

xs_desired_relative_output_mean = mean( Xs_desired_relative_output, [ 2, 3, 4 ] );
xs_theoretical_relative_output_mean = mean( Xs_theoretical_relative_output, [ 2, 3, 4 ] );
xs_numerical_relative_output_mean = mean( Xs_numerical_relative_output, [ 2, 3, 4 ] );


% ---------- Min Steady State Outputs ----------

% Compute the min encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_min = min( Us_desired_absolute_output, [  ], [ 2, 3, 4 ] );
Us_theoretical_absolute_output_min = min( Us_theoretical_absolute_output, [  ], [ 2, 3, 4 ] );
Us_numerical_absolute_output_min = min( Us_numerical_absolute_output, [  ], [ 2, 3, 4 ] );

Us_desired_relative_output_min = min( Us_desired_relative_output, [  ], [ 2, 3, 4 ] );
Us_theoretical_relative_output_min = min( Us_theoretical_relative_output, [  ], [ 2, 3, 4 ] );
Us_numerical_relative_output_min = min( Us_numerical_relative_output, [  ], [ 2, 3, 4 ] );

% Compute the average decoded steady state outputs associated with the formulation parameters.
xs_desired_absolute_output_min = min( Xs_desired_absolute_output, [  ], [ 2, 3, 4 ] );
xs_theoretical_absolute_output_min = min( Xs_theoretical_absolute_output, [  ], [ 2, 3, 4 ] );
xs_numerical_absolute_output_min = min( Xs_numerical_absolute_output, [  ], [ 2, 3, 4 ] );

xs_desired_relative_output_min = min( Xs_desired_relative_output, [  ], [ 2, 3, 4 ] );
xs_theoretical_relative_output_min = min( Xs_theoretical_relative_output, [  ], [ 2, 3, 4 ] );
xs_numerical_relative_output_min = min( Xs_numerical_relative_output, [  ], [ 2, 3, 4 ] );


% ---------- Max Steady State Outputs ----------

% Compute the max encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_max = max( Us_desired_absolute_output, [  ], [ 2, 3, 4 ] );
Us_theoretical_absolute_output_max = max( Us_theoretical_absolute_output, [  ], [ 2, 3, 4 ] );
Us_numerical_absolute_output_max = max( Us_numerical_absolute_output, [  ], [ 2, 3, 4 ] );

Us_desired_relative_output_max = max( Us_desired_relative_output, [  ], [ 2, 3, 4 ] );
Us_theoretical_relative_output_max = max( Us_theoretical_relative_output, [  ], [ 2, 3, 4 ] );
Us_numerical_relative_output_max = max( Us_numerical_relative_output, [  ], [ 2, 3, 4 ] );

% Compute the average encoded steady state outputs associated with the formulation parameters.
xs_desired_absolute_output_max = max( Xs_desired_absolute_output, [  ], [ 2, 3, 4 ] );
xs_theoretical_absolute_output_max = max( Xs_theoretical_absolute_output, [  ], [ 2, 3, 4 ] );
xs_numerical_absolute_output_max = max( Xs_numerical_absolute_output, [  ], [ 2, 3, 4 ] );

xs_desired_relative_output_max = max( Xs_desired_relative_output, [  ], [ 2, 3, 4 ] );
xs_theoretical_relative_output_max = max( Xs_theoretical_relative_output, [  ], [ 2, 3, 4 ] );
xs_numerical_relative_output_max = max( Xs_numerical_relative_output, [  ], [ 2, 3, 4 ] );


% ---------- Median Steady State Outputs (Variable c1) ----------

% U2 vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).

% Retrieve the encoded steady state outputs associated with the median formulation parameter simulations (variable c1).
Us_desired_absolute_output_median_c1 = Us_desired_absolute_output( :, :, c3s_median_index, deltas_median_index );
Us_theoretical_absolute_output_median_c1 = Us_theoretical_absolute_output( :, :, c3s_median_index, deltas_median_index );
Us_numerical_absolute_output_median_c1 = Us_numerical_absolute_output( :, :, c3s_median_index, deltas_median_index );

Us_desired_relative_output_median_c1 = Us_desired_relative_output( :, :, c3s_median_index, deltas_median_index );
Us_theoretical_relative_output_median_c1 = Us_theoretical_relative_output( :, :, c3s_median_index, deltas_median_index );
Us_numerical_relative_output_median_c1 = Us_numerical_relative_output( :, :, c3s_median_index, deltas_median_index );

% Retrieve the decoded steady state outputs associated with the median formulation parameter simulations (variable c1).
Xs_desired_absolute_output_median_c1 = Xs_desired_absolute_output( :, :, c3s_median_index, deltas_median_index );
Xs_theoretical_absolute_output_median_c1 = Xs_theoretical_absolute_output( :, :, c3s_median_index, deltas_median_index );
Xs_numerical_absolute_output_median_c1 = Xs_numerical_absolute_output( :, :, c3s_median_index, deltas_median_index );

Xs_desired_relative_output_median_c1 = Xs_desired_relative_output( :, :, c3s_median_index, deltas_median_index );
Xs_theoretical_relative_output_median_c1 = Xs_theoretical_relative_output( :, :, c3s_median_index, deltas_median_index );
Xs_numerical_relative_output_median_c1 = Xs_numerical_relative_output( :, :, c3s_median_index, deltas_median_index );


% ---------- Mean Steady State Outputs (Variable c1) ----------

% U2 vs U1 & c1, where U2 is averaged over c3 & delta (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params).

% Compute the average encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_mean_c1 = mean( Us_desired_absolute_output, [ 3, 4 ] );
Us_theoretical_absolute_output_mean_c1 = mean( Us_theoretical_absolute_output, [ 3, 4 ] );
Us_numerical_absolute_output_mean_c1 = mean( Us_numerical_absolute_output, [ 3, 4 ] );

Us_desired_relative_output_mean_c1 = mean( Us_desired_relative_output, [ 3, 4 ] );
Us_theoretical_relative_output_mean_c1 = mean( Us_theoretical_relative_output, [ 3, 4 ] );
Us_numerical_relative_output_mean_c1 = mean( Us_numerical_relative_output, [ 3, 4 ] );

% Compute the average decoded steady state outputs associated with the formulation parameters.
Xs_desired_absolute_output_mean_c1 = mean( Xs_desired_absolute_output, [ 3, 4 ] );
Xs_theoretical_absolute_output_mean_c1 = mean( Xs_theoretical_absolute_output, [ 3, 4 ] );
Xs_numerical_absolute_output_mean_c1 = mean( Xs_numerical_absolute_output, [ 3, 4 ] );

Xs_desired_relative_output_mean_c1 = mean( Xs_desired_relative_output, [ 3, 4 ] );
Xs_theoretical_relative_output_mean_c1 = mean( Xs_theoretical_relative_output, [ 3, 4 ] );
Xs_numerical_relative_output_mean_c1 = mean( Xs_numerical_relative_output, [ 3, 4 ] );


% ---------- Min Steady State Outputs (Variable c1) ----------

% Compute the average encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_min_c1 = min( Us_desired_absolute_output, [  ], [ 3, 4 ] );
Us_theoretical_absolute_output_min_c1 = min( Us_theoretical_absolute_output, [  ], [ 3, 4 ] );
Us_numerical_absolute_output_min_c1 = min( Us_numerical_absolute_output, [  ], [ 3, 4 ] );

Us_desired_relative_output_min_c1 = min( Us_desired_relative_output, [  ], [ 3, 4 ] );
Us_theoretical_relative_output_min_c1 = min( Us_theoretical_relative_output, [  ], [ 3, 4 ] );
Us_numerical_relative_output_min_c1 = min( Us_numerical_relative_output, [  ], [ 3, 4 ] );

% Compute the average decoded steady state outputs associated with the formulation parameters.
Xs_desired_absolute_output_min_c1 = min( Xs_desired_absolute_output, [  ], [ 3, 4 ] );
Xs_theoretical_absolute_output_min_c1 = min( Xs_theoretical_absolute_output, [  ], [ 3, 4 ] );
Xs_numerical_absolute_output_min_c1 = min( Xs_numerical_absolute_output, [  ], [ 3, 4 ] );

Xs_desired_relative_output_min_c1 = min( Xs_desired_relative_output, [  ], [ 3, 4 ] );
Xs_theoretical_relative_output_min_c1 = min( Xs_theoretical_relative_output, [  ], [ 3, 4 ] );
Xs_numerical_relative_output_min_c1 = min( Xs_numerical_relative_output, [  ], [ 3, 4 ] );


% ---------- Max Steady State Outputs (Variable c1) ----------

% Compute the average encoded steady state outputs associated with the formulation parameters.
Us_desired_absolute_output_max_c1 = max( Us_desired_absolute_output, [  ], [ 3, 4 ] );
Us_theoretical_absolute_output_max_c1 = max( Us_theoretical_absolute_output, [  ], [ 3, 4 ] );
Us_numerical_absolute_output_max_c1 = max( Us_numerical_absolute_output, [  ], [ 3, 4 ] );

Us_desired_relative_output_max_c1 = max( Us_desired_relative_output, [  ], [ 3, 4 ] );
Us_theoretical_relative_output_max_c1 = max( Us_theoretical_relative_output, [  ], [ 3, 4 ] );
Us_numerical_relative_output_max_c1 = max( Us_numerical_relative_output, [  ], [ 3, 4 ] );

% Compute the average decoded steady state outputs associated with the formulation parameters.
Xs_desired_absolute_output_max_c1 = max( Xs_desired_absolute_output, [  ], [ 3, 4 ] );
Xs_theoretical_absolute_output_max_c1 = max( Xs_theoretical_absolute_output, [  ], [ 3, 4 ] );
Xs_numerical_absolute_output_max_c1 = max( Xs_numerical_absolute_output, [  ], [ 3, 4 ] );

Xs_desired_relative_output_max_c1 = max( Xs_desired_relative_output, [  ], [ 3, 4 ] );
Xs_theoretical_relative_output_max_c1 = max( Xs_theoretical_relative_output, [  ], [ 3, 4 ] );
Xs_numerical_relative_output_max_c1 = max( Xs_numerical_relative_output, [  ], [ 3, 4 ] );


% ---------- Median Steady State Outputs (Variable c3) ----------

% U2 vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).

% Retrieve the encoded steady state outputs associated with the median formulation parameter simulations (variable c3).
Us_desired_absolute_output_median_c3 = squeeze( Us_desired_absolute_output( :, c1s_median_index, :, deltas_median_index ) );
Us_theoretical_absolute_output_median_c3 = squeeze( Us_theoretical_absolute_output( :, c1s_median_index, :, deltas_median_index ) );
Us_numerical_absolute_output_median_c3 = squeeze( Us_numerical_absolute_output( :, c1s_median_index, :, deltas_median_index ) );

Us_desired_relative_output_median_c3 = squeeze( Us_desired_relative_output( :, c1s_median_index, :, deltas_median_index ) );
Us_theoretical_relative_output_median_c3 = squeeze( Us_theoretical_relative_output( :, c1s_median_index, :, deltas_median_index ) );
Us_numerical_relative_output_median_c3 = squeeze( Us_numerical_relative_output( :, c1s_median_index, :, deltas_median_index ) );

% Retrieve the decoded steady state outputs associated with the median formulation parameter simulations (variable c3).
Xs_desired_absolute_output_median_c3 = squeeze( Xs_desired_absolute_output( :, c1s_median_index, :, deltas_median_index ) );
Xs_theoretical_absolute_output_median_c3 = squeeze( Xs_theoretical_absolute_output( :, c1s_median_index, :, deltas_median_index ) );
Xs_numerical_absolute_output_median_c3 = squeeze( Xs_numerical_absolute_output( :, c1s_median_index, :, deltas_median_index ) );

Xs_desired_relative_output_median_c3 = squeeze( Xs_desired_relative_output( :, c1s_median_index, :, deltas_median_index ) );
Xs_theoretical_relative_output_median_c3 = squeeze( Xs_theoretical_relative_output( :, c1s_median_index, :, deltas_median_index ) );
Xs_numerical_relative_output_median_c3 = squeeze( Xs_numerical_relative_output( :, c1s_median_index, :, deltas_median_index ) );




% Us_numerical_input
% xs_numerical_input
% 
% Us_desired_absolute_output
% Us_theoretical_absolute_output
% Us_numerical_absolute_output
% 
% Xs_desired_absolute_output
% Xs_theoretical_absolute_output
% Xs_numerical_absolute_output


% ---------- Output Plots ----------

% U2 vs U1 @ specific c1, c3, & delta (median of each fixed parameter). DONE.
% x2 vs x1 @ specific c1, c3, & delta (median of each fixed parameter). DONE.


% U2 vs U1, where U2 is averaged over c1, c3, & delta (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params). DONE.
% x2 vs x1, where U2 is averaged over c1, c3, & delta (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params). DONE.


% U2 vs U1 & c1 @ specific c3 & delta (median of each fixed parameter). DONE.
% U2 vs U1 & c3 @ specific c1 & delta (median of each fixed parameter). 
% U2 vs U1 & delta @ specific c1 & c3 (median of each fixed parameter). 

% x2 vs x1 & c1 @ specific c3 & delta (median of each fixed parameter). DONE.
% x2 vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% x2 vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% U2 vs U1 & c1, where U2 is averaged over c3 & delta (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params). DONE.
% U2 vs U1 & c3, where U2 is averaged over c1 & delta (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params).
% U2 vs U1 & delta, where U2 is averaged over c1 & c3 (also add curve where U2 is minimized over the fixed params, and where U2 is maximized over the fixed params).

% x2 vs x1 & c1, where x2 is averaged over c3 & delta (also add curve where x2 is minimized over the fixed params, and where x2 is maximized over the fixed params). DONE.
% x2 vs x1 & c3, where x2 is averaged over c1 & delta (also add curve where x2 is minimized over the fixed params, and where x2 is maximized over the fixed params).
% x2 vs x1 & delta, where x2 is averaged over c1 & c3 (also add curve where x2 is minimized over the fixed params, and where x2 is maximized over the fixed params).


% ---------- Error Plots ----------

% E vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% E vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% E vs U1, where E is averaged over c1, c3, & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).
% E vs x1, where E is averaged over c1, c3, & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).


% E vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% E vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% E vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% E vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% E vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% E vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% E vs U1 & c1, where E is averaged over c3 & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).
% E vs U1 & c3, where E is averaged over c1 & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).
% E vs U1 & delta, where E is averaged over c1 & c3 (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).

% E vs x1 & c1, where E is averaged over c3 & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).
% E vs x1 & c3, where E is averaged over c1 & delta (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).
% E vs x1 & delta, where E is averaged over c1 & c3 (also add curve where E is minimized over the fixed params, and where E is maximized over the fixed params).


% E vs c1 @ specific c3 & delta (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).
% E vs c3 @ specific c1 & delta (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).
% E vs delta @ specific c1 & c3 (median of each fixed parameter) where E is averaged over U1 (& E is minimized over U1 & E is maximized over U1).

% E vs c1 @ specific c3 & delta (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).
% E vs c3 @ specific c1 & delta (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).
% E vs delta @ specific c1 & c3 (median of each fixed parameter) where E is averaged over x1 (& E is minimized over x1 & E is maximized over x1).



% ---------- Error Difference Plots ----------

% dE vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% dE vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% dE vs U1, where E is averaged over c1, c3, & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).
% dE vs x1, where E is averaged over c1, c3, & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).


% dE vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% dE vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% dE vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% dE vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% dE vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% dE vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% dE vs U1 & c1, where dE is averaged over c3 & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).
% dE vs U1 & c3, where dE is averaged over c1 & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).
% dE vs U1 & delta, where dE is averaged over c1 & c3 (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).

% dE vs x1 & c1, where dE is averaged over c3 & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).
% dE vs x1 & c3, where dE is averaged over c1 & delta (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).
% dE vs x1 & delta, where dE is averaged over c1 & c3 (also add curve where dE is minimized over the fixed params, and where dE is maximized over the fixed params).


% dE vs c1 @ specific c3 & delta (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).
% dE vs c3 @ specific c1 & delta (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).
% dE vs delta @ specific c1 & c3 (median of each fixed parameter) where dE is averaged over U1 (& dE is minimized over U1 & dE is maximized over U1).

% dE vs c1 @ specific c3 & delta (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).
% dE vs c3 @ specific c1 & delta (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).
% dE vs delta @ specific c1 & c3 (median of each fixed parameter) where dE is averaged over x1 (& dE is minimized over x1 & dE is maximized over x1).



% ---------- Error Improvement Plots ----------

% |dE| vs U1 @ specific c1, c3, & delta (median of each fixed parameter).
% |dE| vs x1 @ specific c1, c3, & delta (median of each fixed parameter).


% |dE| vs U1, where E is averaged over c1, c3, & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).
% |dE| vs x1, where E is averaged over c1, c3, & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).


% |dE| vs U1 & c1 @ specific c3 & delta (median of each fixed parameter).
% |dE| vs U1 & c3 @ specific c1 & delta (median of each fixed parameter).
% |dE| vs U1 & delta @ specific c1 & c3 (median of each fixed parameter).

% |dE| vs x1 & c1 @ specific c3 & delta (median of each fixed parameter).
% |dE| vs x1 & c3 @ specific c1 & delta (median of each fixed parameter).
% |dE| vs x1 & delta @ specific c1 & c3 (median of each fixed parameter).


% |dE| vs U1 & c1, where |dE| is averaged over c3 & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).
% |dE| vs U1 & c3, where |dE| is averaged over c1 & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).
% |dE| vs U1 & delta, where |dE| is averaged over c1 & c3 (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).

% |dE| vs x1 & c1, where |dE| is averaged over c3 & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).
% |dE| vs x1 & c3, where |dE| is averaged over c1 & delta (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).
% |dE| vs x1 & delta, where |dE| is averaged over c1 & c3 (also add curve where |dE| is minimized over the fixed params, and where |dE| is maximized over the fixed params).


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


%% Plot the Encoded Steady State Behavior for Median Formulation Parameters.

% Plot the encoded absolute steady state behavior for the median formulation parameters.
fig_absolute_encoded_ssr_median = plotting_utilities.plot_steady_state_response( Us_numerical_input, Us_desired_absolute_output_median, Us_theoretical_absolute_output_median, Us_numerical_absolute_output_median, scale, 'Inversion', 'Absolute', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory, 'median' );

% Plot the encoded relative steady state behavior for the median formulation parameters.
fig_relative_encoded_ssr_median = plotting_utilities.plot_steady_state_response( Us_numerical_input, Us_desired_relative_output_median, Us_theoretical_relative_output_median, Us_numerical_relative_output_median, scale, 'Inversion', 'Relative', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory, 'median' );

% Plot the encoded steady state behavior of the median formulation parameters.
fig_encoded_ssr_median = plotting_utilities.plot_steady_state_response_comparison( Us_numerical_input, Us_desired_absolute_output_median, Us_theoretical_absolute_output_median, Us_numerical_absolute_output_median, color1, Us_numerical_input, Us_desired_relative_output_median, Us_theoretical_relative_output_median, Us_numerical_relative_output_median, color2, scale, 'Inversion', 'Encoded', 'U1', 'U2', 'mV', true, save_flag, save_directory, 'median' );
fig_encoded_ssr_median_subplots = plotting_utilities.plot_steady_state_response_comparison( Us_numerical_input, Us_desired_absolute_output_median, Us_theoretical_absolute_output_median, Us_numerical_absolute_output_median, color1, Us_numerical_input, Us_desired_relative_output_median, Us_theoretical_relative_output_median, Us_numerical_relative_output_median, color2, scale, 'Inversion', 'Encoded', 'U1', 'U2', 'mV', false, save_flag, save_directory, 'median' );


%% Plot the Decoded Steady State Behavior for Median Formulation Parameters.

% Plot the absolute decoded steady state behavior for the median formulation parameters.
fig_absolute_decoded_ssr_median = plotting_utilities.plot_steady_state_response( xs_numerical_input, xs_desired_absolute_output_median, xs_theoretical_absolute_output_median, xs_numerical_absolute_output_median, scale, 'Inversion', 'Absolute', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory, 'median' );

% Plot the decoded relative steady state behavior for the median formulation parameters.
fig_relative_decoded_ssr_median = plotting_utilities.plot_steady_state_response( xs_numerical_input, xs_desired_relative_output_median, xs_theoretical_relative_output_median, xs_numerical_relative_output_median, scale, 'Inversion', 'Relative', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory, 'median' );

% Plot the decoded steady state behavior of the median formulation parameters.
fig_decoded_ssr_median_compact = plotting_utilities.plot_steady_state_response_comparison( xs_numerical_input, xs_desired_absolute_output_median, xs_theoretical_absolute_output_median, xs_numerical_absolute_output_median, color1, xs_numerical_input, xs_desired_relative_output_median, xs_theoretical_relative_output_median, xs_numerical_relative_output_median, color2, scale, 'Inversion', 'Decoded', 'x1', 'x2', '-', true, save_flag, save_directory, 'median_compact' );
fig_decoded_ssr_median = plotting_utilities.plot_steady_state_response_comparison( xs_numerical_input, xs_desired_absolute_output_median, xs_theoretical_absolute_output_median, xs_numerical_absolute_output_median, color1, xs_numerical_input, xs_desired_relative_output_median, xs_theoretical_relative_output_median, xs_numerical_relative_output_median, color2, scale, 'Inversion', 'Decoded', 'x1', 'x2', '-', false, save_flag, save_directory, 'median' );


%% Plot the Steady State Behavior for Median Formulation Parameters.

% Plot the steady state behavior associated with the median formulation parameters.
fig_ssr_median_compact = plotting_utilities.plot_steady_state_response_full_comparison( Us_numerical_input, Us_desired_absolute_output_median, Us_theoretical_absolute_output_median, Us_numerical_absolute_output_median, xs_numerical_input, xs_desired_absolute_output_median, xs_theoretical_absolute_output_median, xs_numerical_absolute_output_median, color1, Us_numerical_input, Us_desired_relative_output_median, Us_theoretical_relative_output_median, Us_numerical_relative_output_median, xs_numerical_input, xs_desired_relative_output_median, xs_theoretical_relative_output_median, xs_numerical_relative_output_median, color2, scale, scale, 'Inversion', 'U1', 'x1', 'U2', 'x2', 'mV', '-', true, save_flag, save_directory, 'median_compact' );
fig_ssr_median = plotting_utilities.plot_steady_state_response_full_comparison( Us_numerical_input, Us_desired_absolute_output_median, Us_theoretical_absolute_output_median, Us_numerical_absolute_output_median, xs_numerical_input, xs_desired_absolute_output_median, xs_theoretical_absolute_output_median, xs_numerical_absolute_output_median, color1, Us_numerical_input, Us_desired_relative_output_median, Us_theoretical_relative_output_median, Us_numerical_relative_output_median, xs_numerical_input, xs_desired_relative_output_median, xs_theoretical_relative_output_median, xs_numerical_relative_output_median, color2, scale, scale, 'Inversion', 'U1', 'x1', 'U2', 'x2', 'mV', '-', false, save_flag, save_directory, 'median' );


%% Plot a Summary of the Encoded Steady State Behavior Over the Formulation Parameters.

% Plot a summary of the absolute encoded steady state behavior over the formulation parameters.
fig_absolute_encoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch( Us_numerical_input, Us_numerical_absolute_output_mean, Us_numerical_absolute_output_min, Us_numerical_absolute_output_max, color1, scale, 'Inversion', 'Absolute', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory, 'patch' );

% Plot a summary of the relative encoded steady state behavior over the formulation parameters.
fig_relative_encoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch( Us_numerical_input, Us_numerical_relative_output_mean, Us_numerical_relative_output_min, Us_numerical_relative_output_max, color2, scale, 'Inversion', 'Relative', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory, 'patch' );

% Plot a summary of the encoded steady state behavior over the formulation parameters.
fig_encoded_ssr_patch_compact = plotting_utilities.plot_steady_state_response_patch_comparison( Us_numerical_input, Us_numerical_absolute_output_mean, Us_numerical_absolute_output_min, Us_numerical_absolute_output_max, color1, Us_numerical_relative_output_mean, Us_numerical_relative_output_min, Us_numerical_relative_output_max, color2, scale, 'Inversion', 'Encoded', 'U1', 'U2', 'mV', true, save_flag, save_directory, 'patch_compact' );
fig_encoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch_comparison( Us_numerical_input, Us_numerical_absolute_output_mean, Us_numerical_absolute_output_min, Us_numerical_absolute_output_max, color1, Us_numerical_relative_output_mean, Us_numerical_relative_output_min, Us_numerical_relative_output_max, color2, scale, 'Inversion', 'Encoded', 'U1', 'U2', 'mV', false, save_flag, save_directory, 'patch' );


%% Plot a Summary of the Decoded Steady State Behavior Over the Formulation Parameters.

% Plot a summary of the absolute decoded steady state behavior over the formulation parameters.
fig_absolute_decoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch( xs_numerical_input, xs_numerical_absolute_output_mean, xs_numerical_absolute_output_min, xs_numerical_absolute_output_max, color1, scale, 'Inversion', 'Absolute', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory, 'patch' );

% Plot a summary of the relative decoded steady state behavior over the formulation parameters.
fig_relative_decoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch( xs_numerical_input, xs_numerical_relative_output_mean, xs_numerical_relative_output_min, xs_numerical_relative_output_max, color2, scale, 'Inversion', 'Relative', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory, 'patch' );

% Plot a summary of the decoded steady state behavior over the formulation parameters.
fig_decoded_ssr_patch_compact = plotting_utilities.plot_steady_state_response_patch_comparison( xs_numerical_input, xs_numerical_absolute_output_mean, xs_numerical_absolute_output_min, xs_numerical_absolute_output_max, color1, xs_numerical_relative_output_mean, xs_numerical_relative_output_min, xs_numerical_relative_output_max, color2, scale, 'Inversion', 'Decoded', 'x1', 'x2', '-', true, save_flag, save_directory, 'patch_compact' );
fig_decoded_ssr_patch = plotting_utilities.plot_steady_state_response_patch_comparison( xs_numerical_input, xs_numerical_absolute_output_mean, xs_numerical_absolute_output_min, xs_numerical_absolute_output_max, color1, xs_numerical_relative_output_mean, xs_numerical_relative_output_min, xs_numerical_relative_output_max, color2, scale, 'Inversion', 'Decoded', 'x1', 'x2', '-', false, save_flag, save_directory, 'patch' );


%% Plot a Summary of the Steady State Behavior Over the Formulation Parameters.

% Plot a summary of the steady state behavior over the formulation parameters.
fig_ssr_patch_compact = plotting_utilities.plot_steady_state_response_patch_full_comparison( Us_numerical_input, Us_numerical_absolute_output_mean, Us_numerical_absolute_output_min, Us_numerical_absolute_output_max, xs_numerical_input, xs_numerical_absolute_output_mean, xs_numerical_absolute_output_min, xs_numerical_absolute_output_max, color1, Us_numerical_relative_output_mean, Us_numerical_relative_output_min, Us_numerical_relative_output_max, xs_numerical_relative_output_mean, xs_numerical_relative_output_min, xs_numerical_relative_output_max, color2, scale, scale, 'Inversion', 'U1', 'x1', 'U2', 'x2', 'mV', '-', true, save_flag, save_directory, 'patch_compact' );
fig_ssr_patch = plotting_utilities.plot_steady_state_response_patch_full_comparison( Us_numerical_input, Us_numerical_absolute_output_mean, Us_numerical_absolute_output_min, Us_numerical_absolute_output_max, xs_numerical_input, xs_numerical_absolute_output_mean, xs_numerical_absolute_output_min, xs_numerical_absolute_output_max, color1, Us_numerical_relative_output_mean, Us_numerical_relative_output_min, Us_numerical_relative_output_max, xs_numerical_relative_output_mean, xs_numerical_relative_output_min, xs_numerical_relative_output_max, color2, scale, scale, 'Inversion', 'U1', 'x1', 'U2', 'x2', 'mV', '-', false, save_flag, save_directory, 'patch' );


%% Plot the Encoded Steady State Behavior for Median Formulation Parameters (Variable c1).

% Plot the encoded absolute steady state behavior for the median formulation parameters (variable c1).
fig_absolute_encoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response( C1s_input, Us_input_c1, Us_desired_absolute_output_median_c1, Us_theoretical_absolute_output_median_c1, Us_numerical_absolute_output_median_c1, scale, [ 145, 15 ], 'Inversion', 'Absolute', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Median, Variable c1)', save_flag, save_directory, 'median_variable_c1' );

% Plot the encoded relative steady state behavior for the median formulation parameters (variable c1).
fig_relative_encoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response( C1s_input, Us_input_c1, Us_desired_relative_output_median_c1, Us_theoretical_relative_output_median_c1, Us_numerical_relative_output_median_c1, scale, [ 145, 15 ], 'Inversion', 'Relative', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Median, Variable c1)', save_flag, save_directory, 'median_variable_c1' );

% Plot the encoded steady state behavior for the median formulation parameters (variable c1).
fig_encoded_ssr_median_c1_compact = plotting_utilities.surf_steady_state_response_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_median_c1, Us_theoretical_absolute_output_median_c1, Us_numerical_absolute_output_median_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_median_c1, Us_theoretical_relative_output_median_c1, Us_numerical_relative_output_median_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Median, Variable c1)', true, save_flag, save_directory, 'median_variable_c1_compact' );
fig_encoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_median_c1, Us_theoretical_absolute_output_median_c1, Us_numerical_absolute_output_median_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_median_c1, Us_theoretical_relative_output_median_c1, Us_numerical_relative_output_median_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Median, Variable c1)', false, save_flag, save_directory, 'median_variable_c1' );


%% Plot the Decoded Steady State Behavior for Median Formulation Parameters (Variable c1).

% Plot the decoded absolute steady state behavior for the median formulation parameters (variable c1).
fig_absolute_decoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response( C1s_input, Xs_input_c1, Xs_desired_absolute_output_median_c1, Xs_theoretical_absolute_output_median_c1, Xs_numerical_absolute_output_median_c1, scale, [ 145, 15 ], 'Inversion', 'Absolute', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Median, Variable c1)', save_flag, save_directory, 'median_variable_c1' );

% Plot the decoded relative steady state behavior for the median formulation parameters (variable c1).
fig_relative_decoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response( C1s_input, Xs_input_c1, Xs_desired_relative_output_median_c1, Xs_theoretical_relative_output_median_c1, Xs_numerical_relative_output_median_c1, scale, [ 145, 15 ], 'Inversion', 'Relative', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Median, Variable c1)', save_flag, save_directory, 'median_variable_c1' );

% Plot the decoded steady state behavior for the median formulation parameters (variable c1).
fig_decoded_ssr_median_c1_compact = plotting_utilities.surf_steady_state_response_comparison( C1s_input, Xs_input_c1, Xs_desired_absolute_output_median_c1, Xs_theoretical_absolute_output_median_c1, Xs_numerical_absolute_output_median_c1, color1, C1s_input, Xs_input_c1, Xs_desired_relative_output_median_c1, Xs_theoretical_relative_output_median_c1, Xs_numerical_relative_output_median_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Median, Variable c1)', true, save_flag, save_directory, 'median_variable_c1_compact' );
fig_decoded_ssr_median_c1 = plotting_utilities.surf_steady_state_response_comparison( C1s_input, Xs_input_c1, Xs_desired_absolute_output_median_c1, Xs_theoretical_absolute_output_median_c1, Xs_numerical_absolute_output_median_c1, color1, C1s_input, Xs_input_c1, Xs_desired_relative_output_median_c1, Xs_theoretical_relative_output_median_c1, Xs_numerical_relative_output_median_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Median, Variable c1)', false, save_flag, save_directory, 'median_variable_c1' );


%% Plot the Steady State Behavior for Median Formulation Parameters (Variable c1).

% Plot the steady state behavior for the median formulation parameters (variable c1).
fig_ssr_median_c1_compact = plotting_utilities.surf_steady_state_response_full_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_median_c1, Us_theoretical_absolute_output_median_c1, Us_numerical_absolute_output_median_c1, C1s_input, Xs_input_c1, Xs_desired_absolute_output_median_c1, Xs_theoretical_absolute_output_median_c1, Xs_numerical_absolute_output_median_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_median_c1, Us_theoretical_relative_output_median_c1, Us_numerical_relative_output_median_c1, C1s_input, Xs_input_c1, Xs_desired_relative_output_median_c1, Xs_theoretical_relative_output_median_c1, Xs_numerical_relative_output_median_c1, color2, scale, scale, [ 145, 15 ], 'Inversion', { 'c1', 'U1', 'U2' }, { 'c1', 'x1', 'x2' }, { '-', 'mV', 'mV' }, { '-', '-', '-' }, '(Median, Variable c1)', true, save_flag, save_directory, 'median_variable_c1_compact' );
fig_ssr_median_c1 = plotting_utilities.surf_steady_state_response_full_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_median_c1, Us_theoretical_absolute_output_median_c1, Us_numerical_absolute_output_median_c1, C1s_input, Xs_input_c1, Xs_desired_absolute_output_median_c1, Xs_theoretical_absolute_output_median_c1, Xs_numerical_absolute_output_median_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_median_c1, Us_theoretical_relative_output_median_c1, Us_numerical_relative_output_median_c1, C1s_input, Xs_input_c1, Xs_desired_relative_output_median_c1, Xs_theoretical_relative_output_median_c1, Xs_numerical_relative_output_median_c1, color2, scale, scale, [ 145, 15 ], 'Inversion', { 'c1', 'U1', 'U2' }, { 'c1', 'x1', 'x2' }, { '-', 'mV', 'mV' }, { '-', '-', '-' }, '(Median, Variable c1)', false, save_flag, save_directory, 'median_variable_c1' );


%% Plot a Summary of the Encoded Steady State Behavior Over the Formulation Parameters (Variable c1).

% Plot a summary of the absolute encoded steady state behavior over the formulation parameters (variable c1).
fig_absolute_encoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch( C1s_input, Us_input_c1, Us_desired_absolute_output_mean_c1, Us_desired_absolute_output_min_c1, Us_desired_absolute_output_max_c1, color1, scale, [ 145, 15 ], 'Inversion', 'Absolute', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(c1 Summary)', save_flag, save_directory, 'c1_summary' );

% Plot a summary of the relative encoded steady state behavior over the formulation parameters (variable c1).
fig_relative_encoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch( C1s_input, Us_input_c1, Us_desired_relative_output_mean_c1, Us_desired_relative_output_min_c1, Us_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Relative', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(c1 Summary)', save_flag, save_directory, 'c1_summary' );

% Plot a summary of the encoded steady state behavior over the fomrualtion aprameters (variable c1).
fig_encoded_srr_summary_c1_compact = plotting_utilities.surf_steady_state_response_patch_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_mean_c1, Us_desired_absolute_output_min_c1, Us_desired_absolute_output_max_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_mean_c1, Us_desired_relative_output_min_c1, Us_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Summary, Variable c1)', true, save_flag, save_directory, 'c1_summary_compact' );
fig_encoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch_comparison( C1s_input, Us_input_c1, Us_desired_absolute_output_mean_c1, Us_desired_absolute_output_min_c1, Us_desired_absolute_output_max_c1, color1, C1s_input, Us_input_c1, Us_desired_relative_output_mean_c1, Us_desired_relative_output_min_c1, Us_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Encoded', { 'c1', 'U1', 'U2' }, { '-', 'mV', 'mV' }, '(Summary, Variable c1)', false, save_flag, save_directory, 'c1_summary' );


%% Plot a Summary of the Decoded Steady State Behavior Over the Formulation Parameters (Variable c1).

% % Create the patch data.
% ys_patch_xlower_decoded = [ xs_numerical_input; flipud( xs_numerical_input ) ];
% ys_patch_xupper_decoded = [ xs_numerical_input; flipud( xs_numerical_input ) ];
% ys_patch_ylower_decoded = xs_numerical_input( 1 )*ones( 2*num_c1s, 1 );
% ys_patch_yupper_decoded = xs_numerical_input( end )*ones( 2*num_c1s, 1 );
% ys_patch_zlower_decoded = [ xs_numerical_input; xs_numerical_input( end )*ones( num_c1s, 1 ); flipud( xs_numerical_input ); xs_numerical_input( 1 )*ones( num_c1s, 1 ) ];
% ys_patch_zupper_decoded = [ xs_numerical_input; xs_numerical_input( end )*ones( num_c1s, 1 ); flipud( xs_numerical_input ); xs_numerical_input( 1 )*ones( num_c1s, 1 ) ];
% 
% zs_patch_xlower_decoded_absolute = [ Xs_desired_absolute_output_max_c1( :, 1 ); flipud( Xs_desired_absolute_output_min_c1( :, 1 ) ) ];
% zs_patch_xupper_decoded_absolute = [ Xs_desired_absolute_output_max_c1( :, end ); flipud( Xs_desired_absolute_output_min_c1( :, end ) ) ];
% zs_patch_ylower_decoded_absolute = [ Xs_desired_absolute_output_max_c1( 1, : ), fliplr( Xs_desired_absolute_output_min_c1( 1, : ) ) ]';
% zs_patch_yupper_decoded_absolute = [ Xs_desired_absolute_output_max_c1( end, : ), fliplr( Xs_desired_absolute_output_min_c1( end, : ) ) ]';
% zs_patch_zlower_decoded_absolute = [ Xs_desired_absolute_output_max_c1( :, 1 ); Xs_desired_absolute_output_max_c1( end, : )'; flipud( Xs_desired_absolute_output_max_c1( :, end ) ); flipud( Xs_desired_absolute_output_max_c1( 1, : )' ) ];
% zs_patch_zupper_decoded_absolute = [ Xs_desired_absolute_output_min_c1( :, 1 ); Xs_desired_absolute_output_min_c1( end, : )'; flipud( Xs_desired_absolute_output_min_c1( :, end ) ); flipud( Xs_desired_absolute_output_min_c1( 1, : )' ) ];
% 
% zs_patch_xlower_decoded_relative = [ Xs_desired_relative_output_max_c1( :, 1 ); flipud( Xs_desired_relative_output_min_c1( :, 1 ) ) ];
% zs_patch_xupper_decoded_relative = [ Xs_desired_relative_output_max_c1( :, end ); flipud( Xs_desired_relative_output_min_c1( :, end ) ) ];
% zs_patch_ylower_decoded_relative = [ Xs_desired_relative_output_max_c1( 1, : ), fliplr( Xs_desired_relative_output_min_c1( 1, : ) ) ]';
% zs_patch_yupper_decoded_relative = [ Xs_desired_relative_output_max_c1( end, : ), fliplr( Xs_desired_relative_output_min_c1( end, : ) ) ]';
% zs_patch_zlower_decoded_relative = [ Xs_desired_relative_output_max_c1( :, 1 ); Xs_desired_relative_output_max_c1( end, : )'; flipud( Xs_desired_relative_output_max_c1( :, end ) ); flipud( Xs_desired_relative_output_max_c1( 1, : )' ) ];
% zs_patch_zupper_decoded_relative = [ Xs_desired_relative_output_min_c1( :, 1 ); Xs_desired_relative_output_min_c1( end, : )'; flipud( Xs_desired_relative_output_min_c1( :, end ) ); flipud( Xs_desired_relative_output_min_c1( 1, : )' ) ];
% 
% % Plot a summary of the absolute decoded steady state behavior over the formulation parameters (variable c1).
% fig = figure( 'Color', 'w', 'Name', 'Inversion: Absolute Encoded Steady State Response (c1 Summary)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c1 Summary)' )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_absolute_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_absolute_output_min_c1, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_absolute_output_max_c1, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
% surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_absolute_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color1( 1:end - 1 ), 'Facealpha', 0.90 )
% patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% saveas( fig, [ save_directory, '\', 'inversion_absolute_decoded_ss_response_summary_c1' ] ) 
% 
% % Plot a summary of the relative decoded steady state behavior over the formulation parameters (variable c1).
% fig = figure( 'Color', 'w', 'Name', 'Inversion: Relative Encoded Steady State Response (c1 Summary)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c1 Summary)' )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_relative_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_relative_output_min_c1, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
% % surf( C1s_input, scale*Xs_input_c1, scale*xs_desired_relative_output_max_c1, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
% surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_relative_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color2( 1:end - 1 ), 'Facealpha', 0.90 )
% patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% saveas( fig, [ save_directory, '\', 'inversion_relative_decoded_ss_response_summary_c1' ] )
% 
% % Plot a summary of the decoded steady state behavior over the fomrualtion aprameters (variable c1).
% fig = figure( 'Color', 'w', 'Name', 'Inversion: Encoded Steady State Response (c1 Summary)' );
% subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c1 Summary)' )
% surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_absolute_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color1( 1:end - 1 ), 'Facealpha', 0.90 )
% patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% 
% subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c1 Summary)' )
% surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_relative_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color2( 1:end - 1 ), 'Facealpha', 0.90 )
% patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
% saveas( fig, [ save_directory, '\', 'inversion_decoded_ss_response_summary_c1' ] )

% Plot a summary of the absolute decoded steady state behavior over the formulation parameters (variable c1).
fig_absolute_decoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch( C1s_input, Xs_input_c1, Xs_desired_absolute_output_mean_c1, Xs_desired_absolute_output_min_c1, Xs_desired_absolute_output_max_c1, color1, scale, [ 145, 15 ], 'Inversion', 'Absolute', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(c1 Summary)', save_flag, save_directory, 'c1_summary' );

% Plot a summary of the relative decoded steady state behavior over the formulation parameters (variable c1).
fig_relative_decoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch( C1s_input, Xs_input_c1, Xs_desired_relative_output_mean_c1, Xs_desired_relative_output_min_c1, Xs_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Relative', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(c1 Summary)', save_flag, save_directory, 'c1_summary' );

% Plot a summary of the decoded steady state behavior over the fomrualtion aprameters (variable c1).
fig_decoded_srr_summary_c1_compact = plotting_utilities.surf_steady_state_response_patch_comparison( C1s_input, Xs_input_c1, Xs_desired_absolute_output_mean_c1, Xs_desired_absolute_output_min_c1, Xs_desired_absolute_output_max_c1, color1, C1s_input, Xs_input_c1, Xs_desired_relative_output_mean_c1, Xs_desired_relative_output_min_c1, Xs_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Summary, Variable c1)', true, save_flag, save_directory, 'c1_summary_compact' );
fig_decoded_srr_summary_c1 = plotting_utilities.surf_steady_state_response_patch_comparison( C1s_input, Xs_input_c1, Xs_desired_absolute_output_mean_c1, Xs_desired_absolute_output_min_c1, Xs_desired_absolute_output_max_c1, color1, C1s_input, Xs_input_c1, Xs_desired_relative_output_mean_c1, Xs_desired_relative_output_min_c1, Xs_desired_relative_output_max_c1, color2, scale, [ 145, 15 ], 'Inversion', 'Decoded', { 'c1', 'x1', 'x2' }, { '-', '-', '-' }, '(Summary, Variable c1)', false, save_flag, save_directory, 'c1_summary' );


%% Plot a Summary of the Steady State Behavior Over the Formulation Parameters (Variable c1).

% Plot a summary of the steady state behavior over the formulation parameters(variable c1).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Encoded Steady State Response (c1 Summary)' );
subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c1 Summary)' )
surf( C1s_input, scale*Us_input_c1, scale*Us_desired_absolute_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color1( 1:end - 1 ), 'Facealpha', 0.90 )
patch( xs_patch_xlower, scale*ys_patch_xlower_encoded, scale*zs_patch_xlower_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_xupper, scale*ys_patch_xupper_encoded, scale*zs_patch_xupper_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_ylower, scale*ys_patch_ylower_encoded, scale*zs_patch_ylower_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_yupper, scale*ys_patch_yupper_encoded, scale*zs_patch_yupper_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zlower, scale*ys_patch_zlower_encoded, scale*zs_patch_zlower_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zupper, scale*ys_patch_zupper_encoded, scale*zs_patch_zupper_encoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )

subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c1 Summary)' )
surf( C1s_input, scale*Us_input_c1, scale*Us_desired_relative_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color2( 1:end - 1 ), 'Facealpha', 0.90 )
patch( xs_patch_xlower, scale*ys_patch_xlower_encoded, scale*zs_patch_xlower_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_xupper, scale*ys_patch_xupper_encoded, scale*zs_patch_xupper_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_ylower, scale*ys_patch_ylower_encoded, scale*zs_patch_ylower_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_yupper, scale*ys_patch_yupper_encoded, scale*zs_patch_yupper_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zlower, scale*ys_patch_zlower_encoded, scale*zs_patch_zlower_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zupper, scale*ys_patch_zupper_encoded, scale*zs_patch_zupper_encoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )

subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c1 Summary)' )
surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_absolute_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color1( 1:end - 1 ), 'Facealpha', 0.90 )
patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_absolute, color1( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )

subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c1 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c1 Summary)' )
surf( C1s_input, scale*Xs_input_c1, scale*Xs_desired_relative_output_mean_c1, 'Edgecolor', 'None', 'Facecolor', color2( 1:end - 1 ), 'Facealpha', 0.90 )
patch( xs_patch_xlower, scale*ys_patch_xlower_decoded, scale*zs_patch_xlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_xupper, scale*ys_patch_xupper_decoded, scale*zs_patch_xupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_ylower, scale*ys_patch_ylower_decoded, scale*zs_patch_ylower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_yupper, scale*ys_patch_yupper_decoded, scale*zs_patch_yupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zlower, scale*ys_patch_zlower_decoded, scale*zs_patch_zlower_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
patch( xs_patch_zupper, scale*ys_patch_zupper_decoded, scale*zs_patch_zupper_decoded_relative, color2( 1:end - 1 ), 'FaceAlpha', 0.25, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'inversion_ss_response_summary_c1' ] )


%% Plot the Encoded Steady State Behavior for Median Formulation Parameters (Variable c3).

% Plot the encoded absolute steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Absolute Encoded Steady State Response (c3 Median)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_absolute_encoded_ss_response_median_c3' ] ) 

% Plot the encoded relative steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Relative Encoded Steady State Response (c3 Median)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_relative_encoded_ss_response_median_c3' ] ) 

% Plot the encoded steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Encoded Steady State Response (c3 Median)' );
subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_encoded_ss_response_median_c3' ] )


%% Plot the Decoded Steady State Behavior for Median Formulation Parameters (Variable c3).

% Plot the decoded absolute steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Absolute Decoded Steady State Response (c3 Median)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Absolute Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_absolute_decoded_ss_response_median_c3' ] ) 

% Plot the decoded relative steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Relative Decoded Steady State Response (c3 Median)' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Relative Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_relative_decoded_ss_response_median_c3' ] )

% Plot the decoded steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Decoded Steady State Response (c3 Median)' );
subplot( 2, 1, 1 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Absolute Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

subplot( 2, 1, 2 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Relative Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_decoded_ss_response_median_c3' ] )


%% Plot the Steady State Behavior for Median Formulation Parameters (Variable c3).

% Plot the steady state behavior for the median formulation parameters (variable c3).
fig = figure( 'Color', 'w', 'Name', 'Inversion: Steady State Response (c3 Median)' );
subplot( 2, 2, 1 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Absolute Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

subplot( 2, 2, 2 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Inversion: Relative Encoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Us_input_c3, scale*Us_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Us_input_c3, scale*Us_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

subplot( 2, 2, 3 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Absolute Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_absolute_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )

subplot( 2, 2, 4 ), hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c3 [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Inversion: Relative Decoded Steady State Response (c3 Median)' )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_desired_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_theoretical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( C1s_input, scale*Xs_input_c3, scale*Xs_numerical_relative_output_median_c3, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'inversion_ss_response_median_c3' ] )


%% OLD PLOTS BELOW 





%% Plot the Encoded Steady State Behavior.

% Plot the encoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Absolute Encoded Steady State Response' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Transmission: Absolute Encoded Steady State Response' ), zlim( [ 0, 0.160*scale ] )
surf( Cs, scale*Us_input, scale*Us_desired_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_theoretical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_numerical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_absolute_encoded_ss_response_gain' ] ) 

fig = figure( 'Color', 'w', 'Name', 'Transmission: Relative Encoded Steady State Response' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c [-]' ), ylabel( 'Encoded Input, U1 [mV]' ), zlabel( 'Encoded Output, U2 [mV]' ), title( 'Transmission: Relative Encoded Steady State Response' ), zlim( [ 0, 0.020*scale ] )
surf( Cs, scale*Us_input, scale*Us_desired_relative_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_theoretical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*Us_input, scale*Us_numerical_relative_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_relative_encoded_ss_response_gain' ] ) 


%% Plot the Decoded Steady State Behavior.

% Plot the absolute decoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Absolute Decoded Steady State Response' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Transmission: Absolute Decoded Steady State Response' )
surf( Cs, scale*xs_input, scale*Xs_desired_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
surf( Cs, scale*xs_input, scale*Xs_theoretical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.5 )
surf( Cs, scale*xs_input, scale*Xs_numerical_absolute_output, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
legend( { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'transmission_absolute_decoded_ss_response_gain' ] ) 

% Plot the relative decoded steady state behavior.
fig = figure( 'Color', 'w', 'Name', 'Transmission: Relative Decoded Steady State Response' ); hold on, grid on, rotate3d on, view( 145, 15 ), xlabel( 'Gain, c [-]' ), ylabel( 'Decoded Input, x1 [-]' ), zlabel( 'Decoded Output, x2 [-]' ), title( 'Transmission: Relative Decoded Steady State Response' )
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

