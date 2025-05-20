%% Transmission Subnetwork Encoding Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                         	% [str] Save Directory.
load_directory = '.\Load';                         	% [str] Load Directory.

% Set a flag to determine whether to simulate.
simulate_flag = true;                             	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
% simulate_flag = false;                            % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
verbose_flag = true;                            	% [T/F] Printing Flag. (Determines whether to print out information.)

% Define the undetected option.
undetected_option = 'Error';                        % [str] Undetected Option.

% Define the network simulation time step.
network_dt = 1e-3;                                 	% [s] Simulation Time Step.
% network_dt = 1e-4;                             	% [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Compute the number of simulation timesteps.
n_timesteps = floor( network_tf / network_dt ) + 1; % [#] Number of Simulation Timesteps.

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the number of input signals.
n_input_signals = 20;                               % [#] Number of Input Signals.

% Define whether to save the figures.
save_flag = true;                                   % [T/F] Save Flag.

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );
numerical_method_utilities = numerical_method_utilities_class(  );
plotting_utilities = plotting_utilities_class(  );


%% Define Subnetwork Parameters.

% Define the subnetwork formulation parameters (shared by both encoding schemes).
c = 3.0;
x1_max = 20e-3;

% Define the absolute subnetwork design parameters.
% x1max_absolute = 20e-3;                                     % [-] Maximum Encoded Input.
Gm1_absolute = 1e-6;                                        % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                      	% [S] Membrane Conductance (Neuron 2).
Cm1_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                        % [F] Membrane Capacitance (Neuron 2).

% Store the absolute subnetwork design parameters in a cell.
absolute_transmission_input_parameters.c = c;
absolute_transmission_input_parameters.x1_max = x1_max;
absolute_transmission_input_parameters.Gm1 = Gm1_absolute;
absolute_transmission_input_parameters.Gm2 = Gm2_absolute;
absolute_transmission_input_parameters.Cm1 = Cm1_absolute;
absolute_transmission_input_parameters.Cm2 = Cm2_absolute;

% Define the relative subnetwork design parameters.
% x1max_relative = 20;                                         % [-] Maximum Encoded Input.
R1_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 1).
R2_relative = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 2).
Gm1_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                         % [S] Membrane Conductance (Neuron 2).
Cm1_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                         % [F] Membrane Capacitance (Neuron 2).
 
% Store the relative subnetwork design parameters in a cell.
relative_transmission_input_parameters.c = c;
relative_transmission_input_parameters.x1_max = x1_max;
relative_transmission_input_parameters.R1 = R1_relative;
relative_transmission_input_parameters.R2 = R2_relative;
relative_transmission_input_parameters.Gm1 = Gm1_relative;
relative_transmission_input_parameters.Gm2 = Gm2_relative;
relative_transmission_input_parameters.Cm1 = Cm1_relative;
relative_transmission_input_parameters.Cm2 = Cm2_relative;


%% Define the Encoding & Decoding Operations.

% Define the absolute encoding maps.
f_encode1_absolute = @( x1 ) network_utilities.encode_absolute_transmission_input( x1 );
f_encode2_absolute = @( x2 ) network_utilities.encode_absolute_transmission_output( x2 );
f_encode_absolute = @( Xs ) [ f_encode1_absolute( Xs( :, 1 ) ), f_encode2_absolute( Xs( :, 2 ) ) ];

% Define the absolute decoding maps.
f_decode1_absolute = @( U1 ) network_utilities.decode_absolute_transmission_input( U1 );
f_decode2_absolute = @( U2 ) network_utilities.decode_absolute_transmission_output( U2 );
f_decode_absolute = @( Us ) [ f_decode1_absolute( Us( :, 1 ) ), f_decode2_absolute( Us( :, 2 ) ) ];

% Define the relative encoding maps.
f_encode1_relative = @( x1 ) network_utilities.encode_relative_transmission_input( x1, x1_max, R1_relative );
f_encode2_relative = @( x2 ) network_utilities.encode_relative_transmission_output( x2, c, x1_max, R2_relative );
f_encode_relative = @( Xs ) [ f_encode1( Xs( :, 1 ) ), f_encode2( Xs( :, 2 ) ) ];

% Define the relative decoding maps.
f_decode1_relative = @( U1 ) network_utilities.decode_relative_transmission_input( U1, x1_max, R1_relative );
f_decode2_relative = @( U2 ) network_utilities.decode_relative_transmission_output( U2, c, x1_max, R2_relative );
f_decode_relative = @( Us ) [ f_decode1_relative( Us( :, 1 ) ), f_decode2_relative( Us( :, 2 ) ) ];


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


%% Create the Subnetworks.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );
network_relative = network_class( network_dt, network_tf );

% Create a transmission subnetwork.
[ absolute_transmission_output_parameters, neurons_absolute, synapses_absolute, neuron_manager_absolute, synapse_manager_absolute, network_absolute ] = network_absolute.create_transmission_subnetwork( absolute_transmission_input_parameters, 'absolute', network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, true, true, false, undetected_option );
[ relative_transmission_output_parameters, neurons_relative, synapses_relative, neuron_manager_relative, synapse_manager_relative, network_relative ] = network_relative.create_transmission_subnetwork( relative_transmission_input_parameters, 'relative', network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, true, true, false, undetected_option );

% Unpack the transmission subnetwork output parameters.
[ x2max_absolute, R1_absolute, R2_absolute, Gna1_absolute, Gna2_absolute, dEs21_absolute, gs21_absolute, Ia2_absolute ] = network_absolute.unpack_absolute_transmission_output_parameters( absolute_transmission_output_parameters, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option );
[ x2max_relative, Gna1_relative, Gna2_relative, dEs21_relative, gs21_relative, Ia2_relative ] = network_relative.unpack_relative_transmission_output_parameters( relative_transmission_output_parameters, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option );

% Create the input applied current.
[ ~, ~, ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.create_applied_current( input_current_ID_absolute, input_current_name_absolute, input_current_to_neuron_ID_absolute, ts, Ias1_absolute, true, network_absolute.applied_current_manager.applied_currents, true, false, network_absolute.applied_current_manager.array_utilities );
[ ~, ~, ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.create_applied_current( input_current_ID_relative, input_current_name_relative, input_current_to_neuron_ID_relative, ts, Ias1_relative, true, network_relative.applied_current_manager.applied_currents, true, false, network_relative.applied_current_manager.array_utilities );


%% Print Subnetwork Information.

% Print absolute transmission subnetwork information.
fprintf( '----------------------------------- ABSOLUTE TRANSMISSION SUBNETWORK -----------------------------------\n\n' )
network_absolute.print( network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, verbose_flag );
fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )

% Print the relative transmission subnetwork information.
fprintf( '----------------------------------- RELATIVE TRANSMISSION SUBNETWORK -----------------------------------\n\n' )
network_relative.print( network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, verbose_flag );
fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )


%% Simulate the Transmission Network.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
set_flag = true;                            % [T/F] Set Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';               % [str] Undetected Option.

% Determine whether to simulate the network.
if simulate_flag                            % If we want to simulate the network...

    % Define the decoded input signals.
    xs_numerical_input = linspace( 0, x1_max, n_input_signals )';

    % Compute the decoded steady state simulation results.
    [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.compute_steady_state_simulation_decoded( network_dt, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_absolute, f_decode2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, network_absolute.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_absolute.network_utilities );
    [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.compute_steady_state_simulation_decoded( network_dt, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_relative, f_decode2_relative, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, network_relative.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_relative.network_utilities );

    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_transmission_subnetwork_error' ], 'Ias_magnitude_absolute', 'Us_numerical_absolute', 'xs_numerical_absolute' )
    save( [ save_directory, '\', 'relative_transmission_subnetwork_error' ], 'Ias_magnitude_relative', 'Us_numerical_relative', 'xs_numerical_relative' )

else                % Otherwise... ( We must want to load data from an existing simulation... )

    % Load the simulation results.
    data_absolute = load( [ load_directory, '\', 'absolute_transmission_subnetwork_error' ] );
    data_relative = load( [ load_directory, '\', 'relative_transmission_subnetwork_error' ] );

    % Unpack the steady state simulation data.
    [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.unpack_steady_state_simulation_data( data_absolute );
    [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.unpack_steady_state_simulation_data( data_relative );

end


%% Compute the Absolute & Relative Transmission Desired & Achieved (Theory) Network Output.

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
Us_desired_absolute( :, 2 ) = network_absolute.compute_encoded_desired_absolute_transmission_sso( Us_desired_absolute( :, 1 ), c, network_absolute.network_utilities );
Us_desired_relative( :, 2 ) = network_relative.compute_encoded_desired_relative_transmission_sso( Us_desired_relative( :, 1 ), R1_relative, R2_relative, network_relative.neuron_manager, undetected_option, network_relative.network_utilities );

% Compute the absolute and relative achieved theoretical subnetwork output.
Us_theoretical_absolute( :, 2 ) = network_absolute.compute_encoded_achieved_transmission_sso( Us_theoretical_absolute( :, 1 ), R1_absolute, Gm2_absolute, gs21_absolute, dEs21_absolute, Ia2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option, network_absolute.network_utilities );
Us_theoretical_relative( :, 2 ) = network_relative.compute_encoded_achieved_transmission_sso( Us_theoretical_relative( :, 1 ), R1_relative, Gm2_relative, gs21_relative, dEs21_relative, Ia2_relative, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option, network_relative.network_utilities );

% Compute the decoded desired absolute and relative network outputs.
xs_desired_absolute( :, 2 ) = f_decode2_absolute( Us_desired_absolute( :, 2 ) );
xs_desired_relative( :, 2 ) = f_decode2_relative( Us_desired_relative( :, 2 ) );

% Compute the decoded achieved theoretical absolute and relative network outputs.
xs_theoretical_absolute( :, 2 ) = f_decode2_absolute( Us_theoretical_absolute( :, 2 ) );
xs_theoretical_relative( :, 2 ) = f_decode2_relative( Us_theoretical_relative( :, 2 ) );


%% Compute the Absolute & Relative Subnetwork Error.

% Compute the error between the encoded theoretical output and the desired output.
[ errors_theoretical_encoded_absolute, error_percentages_theoretical_encoded_absolute, error_rmse_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_absolute, error_std_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_absolute, error_min_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_absolute, index_min_theoretical_encoded_absolute, error_max_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_absolute, index_max_theoretical_encoded_absolute, error_range_theoretical_encoded_absolute, error_range_percentage_theoretical_encoded_absolute ] = numerical_method_utilities.compute_error_statistics( Us_theoretical_absolute, Us_desired_absolute, R2_absolute );
[ errors_theoretical_encoded_relative, error_percentages_theoretical_encoded_relative, error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_relative, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_relative, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_relative, index_min_theoretical_encoded_relative, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_relative, index_max_theoretical_encoded_relative, error_range_theoretical_encoded_relative, error_range_percentage_theoretical_encoded_relative ] = numerical_method_utilities.compute_error_statistics( Us_theoretical_relative, Us_desired_relative, R2_relative );

% Compute the error between the encoded numerical output and the desired output.
[ errors_numerical_encoded_absolute, error_percentages_numerical_encoded_absolute, error_rmse_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_absolute, error_std_numerical_encoded_absolute, error_std_percentage_numerical_encoded_absolute, error_min_numerical_encoded_absolute, error_min_percentage_numerical_encoded_absolute, index_min_numerical_encoded_absolute, error_max_numerical_encoded_absolute, error_max_percentage_numerical_encoded_absolute, index_max_numerical_encoded_absolute, error_range_numerical_encoded_absolute, error_range_percentage_numerical_encoded_absolute ] = numerical_method_utilities.compute_error_statistics( Us_numerical_absolute, Us_desired_absolute, R2_absolute );
[ errors_numerical_encoded_relative, error_percentages_numerical_encoded_relative, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_relative, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_relative, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_relative, index_min_numerical_encoded_relative, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_relative, index_max_numerical_encoded_relative, error_range_numerical_encoded_relative, error_range_percentage_numerical_encoded_relative ] = numerical_method_utilities.compute_error_statistics( Us_numerical_relative, Us_desired_relative, R2_relative );

% Compute the error between the decoded theoretical output and the desired output.
[ errors_theoretical_decoded_absolute, error_percentages_theoretical_decoded_absolute, error_rmse_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_absolute, error_std_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_absolute, error_min_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_absolute, index_min_theoretical_decoded_absolute, error_max_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_absolute, index_max_theoretical_decoded_absolute, error_range_theoretical_decoded_absolute, error_range_percentage_theoretical_decoded_absolute ] = numerical_method_utilities.compute_error_statistics( xs_theoretical_absolute, xs_desired_absolute, x2max_absolute );
[ errors_theoretical_decoded_relative, error_percentages_theoretical_decoded_relative, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_relative, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_relative, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_relative, index_min_theoretical_decoded_relative, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_relative, index_max_theoretical_decoded_relative, error_range_theoretical_decoded_relative, error_range_percentage_theoretical_decoded_relative ] = numerical_method_utilities.compute_error_statistics( xs_theoretical_relative, xs_desired_relative, x2max_relative );

% Compute the error between the decoded numerical output and the desired output.
[ errors_numerical_decoded_absolute, error_percentages_numerical_decoded_absolute, error_rmse_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_absolute, error_std_numerical_decoded_absolute, error_std_percentage_numerical_decoded_absolute, error_min_numerical_decoded_absolute, error_min_percentage_numerical_decoded_absolute, index_min_numerical_decoded_absolute, error_max_numerical_decoded_absolute, error_max_percentage_numerical_decoded_absolute, index_max_numerical_decoded_absolute, error_range_numerical_decoded_absolute, error_range_percentage_numerical_decoded_absolute ] = numerical_method_utilities.compute_error_statistics( xs_numerical_absolute, xs_desired_absolute, x2max_absolute );
[ errors_numerical_decoded_relative, error_percentages_numerical_decoded_relative, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_relative, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_relative, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_relative, index_min_numerical_decoded_relative, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_relative, index_max_numerical_decoded_relative, error_range_numerical_decoded_relative, error_range_percentage_numerical_decoded_relative ] = numerical_method_utilities.compute_error_statistics( xs_numerical_relative, xs_desired_relative, x2max_relative );


%% Print the Absolute & Relative Subnetwork Summary Statistics.

% Define the absolute header strings.
header_str_encoded_absolute = 'Absolute Transmission Encoded Error Statistics';
header_str_decoded_absolute = 'Absolute Transmission Decoded Error Statistics';

% Define the relative header strings.
header_str_encoded_relative = 'Relative Transmission Encoded Error Statistics';
header_str_decoded_relative = 'Relative Transmission Decoded Error Statistics';

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
xs_critmin_theoretical_relative = f_decode_relative( Us_critmin_theoretical_relative );
xs_critmin_numerical_relative = f_decode_relative( Us_critmin_numerical_relative );
xs_critmax_theoretical_relative = f_decode_relative( Us_critmax_theoretical_relative );
xs_critmax_numerical_relative = f_decode_relative( Us_critmax_numerical_relative );

% Print the absolute transmission summary statistics.
network_absolute.numerical_method_utilities.print_error_statistics( header_str_encoded_absolute, unit_str_encoded, 10^( -3 ), error_rmse_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_absolute, error_rmse_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_absolute, error_std_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_absolute, error_std_numerical_encoded_absolute, error_std_percentage_numerical_encoded_absolute, error_min_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_absolute, Us_critmin_theoretical_absolute, error_min_numerical_encoded_absolute, error_min_percentage_numerical_encoded_absolute, Us_critmin_numerical_absolute, error_max_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_absolute, Us_critmax_theoretical_absolute, error_max_numerical_encoded_absolute, error_max_percentage_numerical_encoded_absolute, Us_critmax_numerical_absolute, error_range_theoretical_encoded_absolute, error_range_percentage_theoretical_encoded_absolute, error_range_numerical_encoded_absolute, error_range_percentage_numerical_encoded_absolute )
network_absolute.numerical_method_utilities.print_error_statistics( header_str_decoded_absolute, unit_str_decoded, 1, error_rmse_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_absolute, error_rmse_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_absolute, error_std_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_absolute, error_std_numerical_decoded_absolute, error_std_percentage_numerical_decoded_absolute, error_min_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_absolute, xs_critmin_theoretical_absolute, error_min_numerical_decoded_absolute, error_min_percentage_numerical_decoded_absolute, xs_critmin_numerical_absolute, error_max_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_absolute, xs_critmax_theoretical_absolute, error_max_numerical_decoded_absolute, error_max_percentage_numerical_decoded_absolute, xs_critmax_numerical_absolute, error_range_theoretical_decoded_absolute, error_range_percentage_theoretical_decoded_absolute, error_range_numerical_decoded_absolute, error_range_percentage_numerical_decoded_absolute )

% Print the relative transmission summary statistics.
network_relative.numerical_method_utilities.print_error_statistics( header_str_encoded_relative, unit_str_encoded, 10^( -3 ), error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_relative, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_relative, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_relative, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_relative, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_relative, Us_critmin_theoretical_relative, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_relative, Us_critmin_numerical_relative, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_relative, Us_critmax_theoretical_relative, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_relative, Us_critmax_numerical_relative, error_range_theoretical_encoded_relative, error_range_percentage_theoretical_encoded_relative, error_range_numerical_encoded_relative, error_range_percentage_numerical_encoded_relative )
network_relative.numerical_method_utilities.print_error_statistics( header_str_decoded_relative, unit_str_decoded, 1, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_relative, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_relative, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_relative, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_relative, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_relative, xs_critmin_theoretical_relative, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_relative, xs_critmin_numerical_relative, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_relative, xs_critmax_theoretical_relative, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_relative, xs_critmax_numerical_relative, error_range_theoretical_decoded_relative, error_range_percentage_theoretical_decoded_relative, error_range_numerical_decoded_relative, error_range_percentage_numerical_decoded_relative )


%% Compute the Difference between the Absolute & Relative Subnetwork Errors.

% Compute the difference between the theoretical absolute and relative network errors.
[ error_diff_theoretical_encoded, error_percent_diff_theoretical_encoded, error_mse_diff_theoretical_encoded, error_mse_percent_diff_theoretical_encoded, error_std_diff_theoretical_encoded, error_std_percent_diff_theoretical_encoded, error_min_diff_theoretical_encoded, error_min_percent_diff_theoretical_encoded, error_max_diff_theoretical_encoded, error_max_percent_diff_theoretical_encoded ] = numerical_method_utilities.compute_error_difference_statistics( errors_theoretical_encoded_absolute, errors_theoretical_encoded_relative, error_percentages_theoretical_encoded_absolute, error_percentages_theoretical_encoded_relative, error_rmse_theoretical_encoded_absolute, error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_relative, error_std_theoretical_encoded_absolute, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_relative, error_min_theoretical_encoded_absolute, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_relative, error_max_theoretical_encoded_absolute, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_relative );
[ error_diff_theoretical_decoded, error_percent_diff_theoretical_decoded, error_mse_diff_theoretical_decoded, error_mse_percent_diff_theoretical_decoded, error_std_diff_theoretical_decoded, error_std_percent_diff_theoretical_decoded, error_min_diff_theoretical_decoded, error_min_percent_diff_theoretical_decoded, error_max_diff_theoretical_decoded, error_max_percent_diff_theoretical_decoded ] = numerical_method_utilities.compute_error_difference_statistics( errors_theoretical_decoded_absolute, errors_theoretical_decoded_relative, error_percentages_theoretical_decoded_absolute, error_percentages_theoretical_decoded_relative, error_rmse_theoretical_decoded_absolute, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_relative, error_std_theoretical_decoded_absolute, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_relative, error_min_theoretical_decoded_absolute, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_relative, error_max_theoretical_decoded_absolute, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_relative );

% Compute the difference between the numerical absolute and relative network errors.
[ error_diff_numerical_encoded, error_percent_diff_numerical_encoded, error_mse_diff_numerical_encoded, error_mse_percent_diff_numerical_encoded, error_std_diff_numerical_encoded, error_std_percent_diff_numerical_encoded, error_min_diff_numerical_encoded, error_min_percent_diff_numerical_encoded, error_max_diff_numerical_encoded, error_max_percent_diff_numerical_encoded ] = numerical_method_utilities.compute_error_difference_statistics( errors_numerical_encoded_absolute, errors_numerical_encoded_relative, error_percentages_numerical_encoded_absolute, error_percentages_numerical_encoded_relative, error_rmse_numerical_encoded_absolute, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_relative, error_std_numerical_encoded_absolute, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_absolute, error_std_percentage_numerical_encoded_relative, error_min_numerical_encoded_absolute, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_absolute, error_min_percentage_numerical_encoded_relative, error_max_numerical_encoded_absolute, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_absolute, error_max_percentage_numerical_encoded_relative );
[ error_diff_numerical_decoded, error_percent_diff_numerical_decoded, error_mse_diff_numerical_decoded, error_mse_percent_diff_numerical_decoded, error_std_diff_numerical_decoded, error_std_percent_diff_numerical_decoded, error_min_diff_numerical_decoded, error_min_percent_diff_numerical_decoded, error_max_diff_numerical_decoded, error_max_percent_diff_numerical_decoded ] = numerical_method_utilities.compute_error_difference_statistics( errors_numerical_decoded_absolute, errors_numerical_decoded_relative, error_percentages_numerical_decoded_absolute, error_percentages_numerical_decoded_relative, error_rmse_numerical_decoded_absolute, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_relative, error_std_numerical_decoded_absolute, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_absolute, error_std_percentage_numerical_decoded_relative, error_min_numerical_decoded_absolute, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_absolute, error_min_percentage_numerical_decoded_relative, error_max_numerical_decoded_absolute, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_absolute, error_max_percentage_numerical_decoded_relative );

% Compute the improvement between the theoretical absolute and relative network errors.
[ error_improv_theoretical_encoded, error_percent_improv_theoretical_encoded, error_mse_improv_theoretical_encoded, error_mse_percent_improv_theoretical_encoded, error_std_improv_theoretical_encoded, error_std_percent_improv_theoretical_encoded, error_min_improv_theoretical_encoded, error_min_percent_improv_theoretical_encoded, error_max_improv_theoretical_encoded, error_max_percent_improv_theoretical_encoded ] = numerical_method_utilities.compute_error_improvement_statistics( errors_theoretical_encoded_absolute, errors_theoretical_encoded_relative, error_percentages_theoretical_encoded_absolute, error_percentages_theoretical_encoded_relative, error_rmse_theoretical_encoded_absolute, error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_relative, error_std_theoretical_encoded_absolute, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_relative, error_min_theoretical_encoded_absolute, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_relative, error_max_theoretical_encoded_absolute, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_relative );
[ error_improv_theoretical_decoded, error_percent_improv_theoretical_decoded, error_mse_improv_theoretical_decoded, error_mse_percent_improv_theoretical_decoded, error_std_improv_theoretical_decoded, error_std_percent_improv_theoretical_decoded, error_min_improv_theoretical_decoded, error_min_percent_improv_theoretical_decoded, error_max_improv_theoretical_decoded, error_max_percent_improv_theoretical_decoded ] = numerical_method_utilities.compute_error_improvement_statistics( errors_theoretical_decoded_absolute, errors_theoretical_decoded_relative, error_percentages_theoretical_decoded_absolute, error_percentages_theoretical_decoded_relative, error_rmse_theoretical_decoded_absolute, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_relative, error_std_theoretical_decoded_absolute, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_relative, error_min_theoretical_decoded_absolute, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_relative, error_max_theoretical_decoded_absolute, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_relative );

% Compute the improvement between the numerical absolute and relative network errors.
[ error_improv_numerical_encoded, error_percent_improv_numerical_encoded, error_mse_improv_numerical_encoded, error_mse_percent_improv_numerical_encoded, error_std_improv_numerical_encoded, error_std_percent_improv_numerical_encoded, error_min_improv_numerical_encoded, error_min_percent_improv_numerical_encoded, error_max_improv_numerical_encoded, error_max_percent_improv_numerical_encoded ] = numerical_method_utilities.compute_error_improvement_statistics( errors_numerical_encoded_absolute, errors_numerical_encoded_relative, error_percentages_numerical_encoded_absolute, error_percentages_numerical_encoded_relative, error_rmse_numerical_encoded_absolute, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_relative, error_std_numerical_encoded_absolute, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_absolute, error_std_percentage_numerical_encoded_relative, error_min_numerical_encoded_absolute, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_absolute, error_min_percentage_numerical_encoded_relative, error_max_numerical_encoded_absolute, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_absolute, error_max_percentage_numerical_encoded_relative );
[ error_improv_numerical_decoded, error_percent_improv_numerical_decoded, error_mse_improv_numerical_decoded, error_mse_percent_improv_numerical_decoded, error_std_improv_numerical_decoded, error_std_percent_improv_numerical_decoded, error_min_improv_numerical_decoded, error_min_percent_improv_numerical_decoded, error_max_improv_numerical_decoded, error_max_percent_improv_numerical_decoded ] = numerical_method_utilities.compute_error_improvement_statistics( errors_numerical_decoded_absolute, errors_numerical_decoded_relative, error_percentages_numerical_decoded_absolute, error_percentages_numerical_decoded_relative, error_rmse_numerical_decoded_absolute, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_relative, error_std_numerical_decoded_absolute, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_absolute, error_std_percentage_numerical_decoded_relative, error_min_numerical_decoded_absolute, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_absolute, error_min_percentage_numerical_decoded_relative, error_max_numerical_decoded_absolute, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_absolute, error_max_percentage_numerical_decoded_relative );


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
[ dt_max_absolute, indexes_dt_absolute ] = max( dts_absolute );
[ dt_max_relative, indexes_dt_relative ] = max( dts_relative );

% Retrieve the maximum condition number.
[ condition_number_max_absolute, indexes_condition_number_absolute ] = max( condition_numbers_absolute );
[ condition_number_max_relative, indexes_condition_number_relative ] = max( condition_numbers_relative );


%% Print the Numerical Stability Information.

% Print out the stability information.
network_absolute.numerical_method_utilities.print_numerical_stability_info( As_absolute, dts_absolute, network_dt, condition_numbers_absolute );
network_relative.numerical_method_utilities.print_numerical_stability_info( As_relative, dts_relative, network_dt, condition_numbers_relative );


%% Plot the Subnetwork Steady State Response.

% Define the membrane voltage plotting scale factor.
scale = 10^3;

% Define the line colors.
color_absolute = [ 0.0000, 0.4470, 0.7410, 1.0000 ];
color_relative = [ 0.8500, 0.3250, 0.0980, 1.0000 ];

% Define the subnetwork name.
subnetwork_name = 'Transmission';

% Create plots of the absolute and relative encoded and decoded steady state responses.
fig_absolute_encoded_ss_response = plotting_utilities.plot_steady_state_response( Us_desired_absolute( :, 1 ), Us_desired_absolute( :, 2 ), Us_theoretical_absolute( :, 2 ), Us_numerical_absolute( :, 2 ), scale, subnetwork_name, 'Absolute', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory );
fig_absolute_decoded_ss_response = plotting_utilities.plot_steady_state_response( xs_desired_absolute( :, 1 ), xs_desired_absolute( :, 2 ), xs_theoretical_absolute( :, 2 ), xs_numerical_absolute( :, 2 ), scale, subnetwork_name, 'Absolute', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory );
fig_relative_encoded_ss_response = plotting_utilities.plot_steady_state_response( Us_desired_relative( :, 1 ), Us_desired_relative( :, 2 ), Us_theoretical_relative( :, 2 ), Us_numerical_relative( :, 2 ), scale, subnetwork_name, 'Relative', 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory );
fig_relative_decoded_ss_response = plotting_utilities.plot_steady_state_response( xs_desired_relative( :, 1 ), xs_desired_relative( :, 2 ), xs_theoretical_relative( :, 2 ), xs_numerical_relative( :, 2 ), scale, subnetwork_name, 'Relative', 'Decoded', 'x1', 'x2', '-', save_flag, save_directory );

% Create a plot that compares the absolute and relative steady state responses using both encoded and decoded.
fig_encoded_ss_response = plotting_utilities.plot_steady_state_response_comparison( Us_desired_absolute( :, 1 ), Us_desired_absolute( :, 2 ), Us_theoretical_absolute( :, 2 ), Us_numerical_absolute( :, 2 ), color_absolute, Us_desired_relative( :, 1 ), Us_desired_relative( :, 2 ), Us_theoretical_relative( :, 2 ), Us_numerical_relative( :, 2 ), color_relative, scale, subnetwork_name, 'Encoded', 'U1', 'U2', 'mV', save_flag, save_directory );
fig_decoded_ss_response = plotting_utilities.plot_steady_state_response_comparison( xs_desired_absolute( :, 1 ), xs_desired_absolute( :, 2 ), xs_theoretical_absolute( :, 2 ), xs_numerical_absolute( :, 2 ), color_absolute, xs_desired_relative( :, 1 ), xs_desired_relative( :, 2 ), xs_theoretical_relative( :, 2 ), xs_numerical_relative( :, 2 ), color_relative, scale, subnetwork_name, 'Decoded', 'x1', 'x2', '-', save_flag, save_directory );


%% Plot the Subnetwork Steady State Error.

% Plot the encoded and decoded steady state error.
fig_encoded_ss_error = plotting_utilities.plot_steady_state_error_comparison( Us_theoretical_absolute( :, 1 ), errors_theoretical_encoded_absolute, errors_numerical_encoded_absolute, color_absolute, Us_theoretical_relative( :, 1 ), errors_theoretical_encoded_relative, errors_numerical_encoded_relative, color_relative, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error = plotting_utilities.plot_steady_state_error_comparison( xs_theoretical_absolute( :, 1 ), errors_theoretical_decoded_absolute, errors_numerical_decoded_absolute, color_absolute, xs_theoretical_relative( :, 1 ), errors_theoretical_decoded_relative, errors_numerical_decoded_relative, color_relative, scale, subnetwork_name, 'Decoded', 'x', 'E', '-', save_flag, save_directory );

% Plot the encoded and decoded steady state error percentage.
fig_encoded_ss_error_percentage = plotting_utilities.plot_steady_state_error_percentage_comparison( Us_theoretical_absolute( :, 1 ), error_percentages_theoretical_encoded_absolute, error_percentages_numerical_encoded_absolute, color_absolute, Us_theoretical_relative( :, 1 ), error_percentages_theoretical_encoded_relative, error_percentages_numerical_encoded_relative, color_relative, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error_percentage = plotting_utilities.plot_steady_state_error_percentage_comparison( xs_theoretical_absolute( :, 1 ), error_percentages_theoretical_decoded_absolute, error_percentages_numerical_decoded_absolute, color_absolute, xs_theoretical_absolute( :, 1 ), error_percentages_theoretical_decoded_relative, error_percentages_numerical_decoded_relative, color_relative, scale, subnetwork_name, 'Decoded', 'x1', 'E', '-', save_flag, save_directory );


%% Plot the Subnetwork Steady State Error Difference.

% Plot the encoded and decoded steady state error difference between the absolute and relative transmission formulations.
fig_encoded_ss_error_difference = plotting_utilities.plot_steady_state_error_difference( Us_theoretical_absolute( :, 1 ), error_diff_theoretical_encoded, Us_numerical_absolute( :, 1 ), error_diff_numerical_encoded, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error_difference = plotting_utilities.plot_steady_state_error_difference( xs_theoretical_absolute( :, 1 ), error_diff_theoretical_decoded, xs_numerical_absolute( :, 1 ), error_diff_numerical_decoded, scale, subnetwork_name, 'Decoded', 'x1', 'dE', '-', save_flag, save_directory );

% Plot the encoded and decoded steady state error percentage difference between the absolute and relative transmission formulations.
fig_encoded_ss_error_percentage_difference = plotting_utilities.plot_steady_state_error_percentage_difference( Us_theoretical_absolute( :, 1 ), error_percent_diff_theoretical_encoded, Us_numerical_absolute( :, 1 ), error_percent_diff_numerical_encoded, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error_percentage_difference = plotting_utilities.plot_steady_state_error_percentage_difference( xs_theoretical_absolute( :, 1 ), error_percent_diff_theoretical_decoded, xs_numerical_absolute( :, 1 ), error_percent_diff_numerical_decoded, scale, subnetwork_name, 'Decoded', 'x1', 'dE', '-', save_flag, save_directory );


%% Plot the Subnetwork Steady State Error Improvement.

% Plot the encoded and encoded steady state error improvement between the absolute and relative transmission formulations.
fig_encoded_ss_error_improvement = plotting_utilities.plot_steady_state_error_improvement( Us_theoretical_absolute( :, 1 ), error_improv_theoretical_encoded, Us_numerical_absolute( :, 1 ), error_improv_numerical_encoded, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error_improvement = plotting_utilities.plot_steady_state_error_improvement( xs_theoretical_absolute( :, 1 ), error_improv_theoretical_decoded, xs_numerical_absolute( :, 1 ), error_improv_numerical_decoded, scale, subnetwork_name, 'Decoded', 'x1', 'dE', '-', save_flag, save_directory );

% Plot the encoded and decoded steady state error percentage improvement between the absolute and relative transmission formulations.
fig_encoded_ss_error_percentage_improvement = plotting_utilities.plot_steady_state_error_percentage_improvement( Us_theoretical_absolute( :, 1 ), error_percent_improv_theoretical_encoded, Us_numerical_absolute( :, 1 ), error_percent_improv_numerical_encoded, scale, subnetwork_name, 'Encoded', 'U1', 'dU', 'mV', save_flag, save_directory );
fig_decoded_ss_error_percentage_improvement = plotting_utilities.plot_steady_state_error_percentage_improvement( xs_theoretical_absolute( :, 1 ), error_percent_improv_theoretical_decoded, xs_numerical_absolute( :, 1 ), error_percent_improv_numerical_decoded, scale, subnetwork_name, 'Decoded', 'x1', 'dE', '-', save_flag, save_directory );


%% Plot the Numerical Stability Information.

% Plot the RK4 maximum timestep vs the encoded and decoded input.
fig_rk4_maximum_timestep_encoded = plotting_utilities.plot_rk4_maximum_timestep( Us_desired_absolute( :, 1 ), dts_absolute, color_absolute, Us_desired_relative( :, 1 ), dts_relative, color_relative, scale, subnetwork_name, 'Encoded', 'U1', 'mV', save_flag, save_directory );
fig_rk4_maximum_timestep_decoded = plotting_utilities.plot_rk4_maximum_timestep( xs_desired_absolute( :, 1 ), dts_absolute, color_absolute, xs_desired_relative( :, 1 ), dts_relative, color_relative, scale, subnetwork_name, 'Decoded', 'x1', '-', save_flag, save_directory );

% Plot the linearized system condition numbers vs the encoded and decoded input.
fig_condition_numbers_encoded = plotting_utilities.plot_condition_numbers( Us_desired_absolute( :, 1 ), condition_numbers_absolute, color_absolute, Us_desired_relative( :, 1 ), condition_numbers_relative, color_relative, scale, subnetwork_name, 'Encoded', 'U1', 'mV', save_flag, save_directory );
fig_condition_numbers_decoded = plotting_utilities.plot_condition_numbers( xs_desired_absolute( :, 1 ), condition_numbers_absolute, color_absolute, xs_desired_relative( :, 1 ), condition_numbers_relative, color_relative, scale, subnetwork_name, 'Decoded', 'x1', '-', save_flag, save_directory );
  
