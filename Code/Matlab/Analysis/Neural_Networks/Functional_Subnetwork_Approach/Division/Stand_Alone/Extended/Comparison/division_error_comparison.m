%% Division Subnetwork Encoding Comparison.

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
undetected_option = 'Ignore';                        % [str] Undetected Option.

% Define the network simulation time step.
network_dt = 1e-2;                               	% [s] Simulation Timestep.
% network_dt = 1e-3;                               	% [s] Simulation Timestep.
% network_dt = 1e-4;                                  % [s] Simulation Timestep.
% network_dt = 4e-5;                                  % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Compute the number of simulation timesteps.
num_timesteps = length( ts );                       % [#] Number of Simulation Timesteps.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the number of input signals.
num_input_signals1 = 20;                               % [#] Number of Input Signals.
num_input_signals2 = 20;                               % [#] Number of Input Signals.

% Define whether to save the figures.
save_flag = true;                                   % [T/F] Save Flag.

% Define whether to adapt the simulation step sizes.
adapt_step_size_flag = true;                        % [T/F] Adapt Step Size Flag.

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );
numerical_method_utilities = numerical_method_utilities_class(  );
plotting_utilities = plotting_utilities_class(  );


%% Define Subnetwork Parameters.

% Define universal design parameters.
c1 = 1e-3;                                                  % [-] Subnetwork Gain 1.
c3 = 1e-3;                                                  % [-] Subnetwork Gain 3.
delta = 1e-3;                                               % [V] Minimum Decoded Output.
x1_max = 20e-3;                                             % [-] Maximum Decoded Input (Neuron 1).
x2_max = 20e-3;                                          	% [-] Maximum Decoded Input (Neuron 2).

% Define absolute design parameters.
Gm1_absolute = 1e-6;                                      	% [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                       	% [S] Membrane Conductance (Neuron 2).
Gm3_absolute = 1e-6;                                      	% [S] Membrane Conductance (Neuron 3).
Cm1_absolute = 5e-9;                                       	% [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 2).
Cm3_absolute = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 3).

% Define relative design parameters.
R1_relative = 20e-3;
R2_relative = 20e-3;
R3_relative = 20e-3;
Gm1_relative = 1e-6;                                       	% [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                       	% [S] Membrane Conductance (Neuron 2).
Gm3_relative = 1e-6;                                       	% [S] Membrane Conductance (Neuron 3).
Cm1_relative = 5e-9;                                       	% [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 2).
Cm3_relative = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 3).

% Store the absolute subnetwork design parameters into a structure.
absolute_division_input_params.c1 = c1;
absolute_division_input_params.c3 = c3;
absolute_division_input_params.delta = delta;
absolute_division_input_params.x1_max = x1_max;
absolute_division_input_params.x2_max = x2_max;
absolute_division_input_params.Gm1 = Gm1_absolute;
absolute_division_input_params.Gm2 = Gm2_absolute;
absolute_division_input_params.Gm3 = Gm3_absolute;
absolute_division_input_params.Cm1 = Cm1_absolute;
absolute_division_input_params.Cm2 = Cm2_absolute;
absolute_division_input_params.Cm3 = Cm3_absolute;

% Store the relative subnetwork design parameters into a structure.
relative_division_input_params.c1 = c1;
relative_division_input_params.c3 = c3;
relative_division_input_params.delta = delta;
relative_division_input_params.x1_max = x1_max;
relative_division_input_params.x2_max = x2_max;
relative_division_input_params.R1 = R1_relative;
relative_division_input_params.R2 = R2_relative;
relative_division_input_params.R3 = R3_relative;
relative_division_input_params.Gm1 = Gm1_relative;
relative_division_input_params.Gm2 = Gm2_relative;
relative_division_input_params.Gm3 = Gm3_relative;
relative_division_input_params.Cm1 = Cm1_relative;
relative_division_input_params.Cm2 = Cm2_relative;
relative_division_input_params.Cm3 = Cm3_relative;


%% Define the Encoding & Decoding Operations.

% Define the absolute encoding maps.
f_encode1_absolute = @( x1 ) network_utilities.encode_absolute_division_input1( x1 );
f_encode2_absolute = @( x2 ) network_utilities.encode_absolute_division_input2( x2 );
f_encode3_absolute = @( x3 ) network_utilities.encode_absolute_division_output( x3 );
f_encode_absolute = @( Xs ) [ f_encode1_absolute( Xs( :, 1 ) ), f_encode2_absolute( Xs( :, 2 ) ), f_encode3_absolute( Xs( :, 3 ) ) ];

% Define the absolute decoding maps.
f_decode1_absolute = @( U1 ) network_utilities.decode_absolute_division_input1( U1 );
f_decode2_absolute = @( U2 ) network_utilities.decode_absolute_division_input2( U2 );
f_decode3_absolute = @( U3 ) network_utilities.decode_absolute_division_output( U3 );
f_decode_absolute = @( Us ) [ f_decode1_absolute( Us( :, 1 ) ), f_decode2_absolute( Us( :, 2 ) ), f_decode3_absolute( Us( :, 3 ) ) ];

% Define the encoding maps.
f_encode1_relative = @( x1 ) network_utilities.encode_relative_division_input1( x1, x1_max, R1_relative );
f_encode2_relative = @( x2 ) network_utilities.encode_relative_division_input2( x2, x2_max, R2_relative );
f_encode3_relative = @( x3 ) network_utilities.encode_relative_division_output( x3, c1, c3, x1_max, R3_relative );
f_encode_relative = @( Xs ) [ f_encode1_relative( Xs( :, 1 ) ), f_encode2_relative( Xs( :, 2 ) ), f_encode3_relative( Xs( :, 3 ) ) ];

% Define the decoding maps.
f_decode1_relative = @( U1 ) network_utilities.decode_relative_division_input1( U1, x1_max, R1_relative );
f_decode2_relative = @( U2 ) network_utilities.decode_relative_division_input2( U2, x2_max, R2_relative );
f_decode3_relative = @( U3 ) network_utilities.decode_relative_division_output( U3, c1, c3, x1_max, R3_relative );
f_decode_relative = @( Us ) [ f_decode1_relative( Us( :, 1 ) ), f_decode2_relative( Us( :, 2 ) ), f_decode3_relative( Us( :, 3 ) ) ];


%% Define the Desired Input Signal.

% Define the first desired decoded input signal.
% xs1_desired = 0*ones( n_timesteps, 1 );
xs1_desired = x1_max*ones( n_timesteps, 1 );

% Define the second desired decoded input signal.
% xs2_desired = 0*ones( n_timesteps, 1 );
xs2_desired = x2_max*ones( n_timesteps, 1 );

% Encode the input signals.
Us1_desired_absolute = f_encode1_absolute( xs1_desired );
Us2_desired_absolute = f_encode2_absolute( xs2_desired );

Us1_desired_relative = f_encode1_relative( xs1_desired );
Us2_desired_relative = f_encode2_relative( xs2_desired );


%% Define the Absolute & Relative Subnetwork Input Currents.

% Define the identification properties for the first input current.
input_current_ID1_absolute = 1;                               % [#] Input Current ID.
input_current_name1_absolute = 'Applied Current 1';           % [str] Input Current Name.
input_current_to_neuron_ID1_absolute = 1;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the identification properties for the second input current.
input_current_ID2_absolute = 2;                               % [#] Input Current ID.
input_current_name2_absolute = 'Applied Current 2';           % [str] Input Current Name.
input_current_to_neuron_ID2_absolute = 2;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the magnitudes of the input currents.
Ias1_absolute = Us1_desired_absolute*Gm1_absolute;                           	% [A] Applied Currents.
Ias2_absolute = Us2_desired_absolute*Gm2_absolute;                           	% [A] Applied Currents.

% Define the identification properties for the first input current.
input_current_ID1_relative = 1;                               % [#] Input Current ID.
input_current_name1_relative = 'Applied Current 1';           % [str] Input Current Name.
input_current_to_neuron_ID1_relative = 1;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the identification properties for the second input current.
input_current_ID2_relative = 2;                               % [#] Input Current ID.
input_current_name2_relative = 'Applied Current 2';           % [str] Input Current Name.
input_current_to_neuron_ID2_relative = 2;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the magnitudes of the input currents.
Ias1_relative = Us1_desired_relative*Gm1_relative;                           	% [A] Applied Currents.
Ias2_relative = Us2_desired_relative*Gm2_relative;                           	% [A] Applied Currents.


%% Create the Subnetworks.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );
network_relative = network_class( network_dt, network_tf );

% Create the subnetwork.
[ absolute_division_output_params, neurons_absolute, synapses_absolute, neuron_manager_absolute, synapse_manager_absolute, network_absolute ] = network_absolute.create_division_subnetwork( absolute_division_input_parameters, encoding_scheme, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, true, true, false, undetected_option );
[ relative_division_output_params, neurons_relative, synapses_relative, neuron_manager_relative, synapse_manager_relative, network_relative ] = network_relative.create_division_subnetwork( relative_division_input_parameters, encoding_scheme, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, true, true, false, undetected_option );

% Unpack the subnetwork output parameters.
[ c2_absolute, x3_max_absolute, R1_absolute, R2_absolute, R3_absolute, Gna1_absolute, Gna2_absolute, Gna3_absolute, dEs31_absolute, dEs32_absolute, gs31_absolute, gs32_absolute, Ia3_absolute ] = network_absolute.unpack_absolute_division_output_params( absolute_division_output_params, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option );
[ c2_relative, x3_max_relative, Gna1_relative, Gna2_relative, Gna3_relative, dEs31_relative, dEs32_relative, gs31_relative, gs32_relative, Ia3_relative ] = network_relative.unpack_relative_division_output_params( relative_division_output_params, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option );

% Create the input applied current.
[ ~, ~, ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.create_applied_current( input_current_ID1_absolute, input_current_name1_absolute, input_current_to_neuron_ID1_absolute, ts, Ias1_absolute, true, network_absolute.applied_current_manager.applied_currents, true, false, network_absolute.applied_current_manager.array_utilities );
[ ~, ~, ~, network_absolute.applied_current_manager ] = network_absolute.applied_current_manager.create_applied_current( input_current_ID2_absolute, input_current_name2_absolute, input_current_to_neuron_ID2_absolute, ts, Ias2_absolute, true, network_absolute.applied_current_manager.applied_currents, true, false, network_absolute.applied_current_manager.array_utilities );
[ ~, ~, ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.create_applied_current( input_current_ID1_relative, input_current_name1_relative, input_current_to_neuron_ID1_relative, ts, Ias1_relative, true, network_relative.applied_current_manager.applied_currents, true, false, network_relative.applied_current_manager.array_utilities );
[ ~, ~, ~, network_relative.applied_current_manager ] = network_relative.applied_current_manager.create_applied_current( input_current_ID2_relative, input_current_name2_relative, input_current_to_neuron_ID2_relative, ts, Ias2_relative, true, network_relative.applied_current_manager.applied_currents, true, false, network_relative.applied_current_manager.array_utilities );


%% Print Subnetwork Information.

% Print absolute subnetwork information.
fprintf( '----------------------------------- ABSOLUTE INVERSION SUBNETWORK -----------------------------------\n\n' )
network_absolute.print( network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, verbose_flag );
fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )

% Print the relative subnetwork information.
fprintf( '----------------------------------- RELATIVE INVERSION SUBNETWORK -----------------------------------\n\n' )
network_relative.print( network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, verbose_flag );
fprintf( '---------------------------------------------------------------------------------------------------------\n\n\n' )


%% Compute the Subnetwork Numerical Stability Information.

% Define the property retrieval settings.
as_matrix_flag = true;

% Define the stability analysis timestep seed.
dt0 = 1e-6;

% Retrieve properties from the existing network.
Cms_absolute = network_absolute.neuron_manager.get_neuron_property( 'all', 'Cm', as_matrix_flag, network_absolute.neuron_manager.neurons, undetected_option );         % [F] Membrane Capacitance.
Gms_absolute = network_absolute.neuron_manager.get_neuron_property( 'all', 'Gm', as_matrix_flag, network_absolute.neuron_manager.neurons, undetected_option );         % [S] Membrane Conductance.
Rs_absolute = network_absolute.neuron_manager.get_neuron_property( 'all', 'R', as_matrix_flag, network_absolute.neuron_manager.neurons, undetected_option );           % [V] Maximum Membrane Voltage.
gs_absolute = network_absolute.get_gs( 'all', network_absolute.neuron_manager, network_absolute.synapse_manager );                                                              % [S] Synaptic Conductance.
dEs_absolute = network_absolute.get_dEs( 'all', network_absolute.neuron_manager, network_absolute.synapse_manager );                                                            % [V] Synaptic Reversal Potential.
Ias_absolute = network_absolute.neuron_manager.get_neuron_property( 'all', 'Itonic', as_matrix_flag, network_absolute.neuron_manager.neurons, undetected_option );     % [A] Applied Currents.

Cms_relative = network_relative.neuron_manager.get_neuron_property( 'all', 'Cm', as_matrix_flag, network_relative.neuron_manager.neurons, undetected_option );         % [F] Membrane Capacitance.
Gms_relative = network_relative.neuron_manager.get_neuron_property( 'all', 'Gm', as_matrix_flag, network_relative.neuron_manager.neurons, undetected_option );         % [S] Membrane Conductance.
Rs_relative = network_relative.neuron_manager.get_neuron_property( 'all', 'R', as_matrix_flag, network_relative.neuron_manager.neurons, undetected_option );           % [V] Maximum Membrane Voltage.
gs_relative = network_relative.get_gs( 'all', network_relative.neuron_manager, network_relative.synapse_manager );                                                              % [S] Synaptic Conductance.
dEs_relative = network_relative.get_dEs( 'all', network_relative.neuron_manager, network_relative.synapse_manager );                                                            % [V] Synaptic Reversal Potential.
Ias_relative = network_relative.neuron_manager.get_neuron_property( 'all', 'Itonic', as_matrix_flag, network_relative.neuron_manager.neurons, undetected_option );     % [A] Applied Currents.

% Update the applied current.
Ias_absolute( 3 ) = Ias_absolute( 3 ) + Ia3_absolute;                                                                                                                     % [s] Numerical Stability Time Step.
Ias_relative( 3 ) = Ias_relative( 3 ) + Ia3_relative;                                                                                                                     % [s] Numerical Stability Time Step.

% Define the division subnetwork inputs.
U1s_absolute = linspace( 0, Rs_absolute( 1 ), 20  );
U2s_absolute = linspace( 0, Rs_absolute( 2 ), 20  );

U1s_relative = linspace( 0, Rs_relative( 1 ), 20  );
U2s_relative = linspace( 0, Rs_relative( 2 ), 20  );

% Create an input grid.
[ U1s_grid_absolute, U2s_grid_absolute ] = meshgrid( U1s_absolute, U2s_absolute );
[ U1s_grid_relative, U2s_grid_relative ] = meshgrid( U1s_relative, U2s_relative );

% Create the input points.
U1s_flat_absolute = reshape( U1s_grid_absolute, [ numel( U1s_grid_absolute ), 1 ] );
U2s_flat_absolute = reshape( U2s_grid_absolute, [ numel( U2s_grid_absolute ), 1 ] );

U1s_flat_relative = reshape( U1s_grid_relative, [ numel( U1s_grid_relative ), 1 ] );
U2s_flat_relative = reshape( U2s_grid_relative, [ numel( U2s_grid_relative ), 1 ] );

% Compute the desired and achieved absolute division steady state output.
U3s_flat_desired_absolute = network_absolute.compute_encoded_desired_absolute_division_sso( U1s_flat_absolute, U2s_flat_absolute, c1, c3, delta, x1_max, x2_max, network.network_utilities );
[ U3s_flat_achieved_theoretical_absolute, As_absolute, dts_flat_absolute, condition_numbers_flat_absolute ] = network_absolute.achieved_division_RK4_stability_analysis_encoded( U1s_flat_absolute, U2s_flat_absolute, Cms_absolute, Gms_absolute, Rs_absolute, Ias_absolute, gs_absolute, dEs_absolute, dt0, network_absolute.neuron_manager, network_absolute.synapse_manager, undetected_option, network_absolute.network_utilities );

U3s_flat_desired_relative = network_relative.compute_encoded_desired_relative_division_sso( U1s_flat_relative, U2s_flat_relative, c1, c3, delta, x1_max, R1_relative, R2_relative, R3_relative, network_relative.neuron_manager, undetected_option, network_relative.network_utilities );
[ U3s_flat_achieved_theoretical_relative, As_relative, dts_flat_relative, condition_numbers_flat_relative ] = network_relative.achieved_division_RK4_stability_analysis_encoded( U1s_flat_relative, U2s_flat_relative, Cms_relative, Gms_relative, Rs_relative, Ias_relative, gs_relative, dEs_relative, dt0, network_relative.neuron_manager, network_relative.synapse_manager, undetected_option, network_relative.network_utilities );

% Convert the flat steady state output results to grids.
dts_grid_absolute = reshape( dts_flat_absolute, size( U1s_grid_absolute ) );
condition_numbers_grid_absolute = reshape( condition_numbers_flat_absolute, size( U1s_grid_absolute ) );
U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid_absolute ) );
U3s_grid_achieved_theoretical_absolute = reshape( U3s_flat_achieved_theoretical_absolute, size( U1s_grid_absolute ) );

dts_grid_relative = reshape( dts_flat_relative, size( U1s_grid_relative ) );
condition_numbers_grid_relative = reshape( condition_numbers_flat_relative, size( U1s_grid_relative ) );
U3s_grid_desired_relative = reshape( U3s_flat_desired_relative, size( U1s_grid_relative ) );
U3s_grid_achieved_theoretical_relative = reshape( U3s_flat_achieved_theoretical_relative, size( U1s_grid_relative ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max_absolute, indexes_dt_absolute ] = max( dts_flat_absolute );
[ condition_number_max_absolute, indexes_condition_number_absolute ] = max( condition_numbers_flat_absolute );

[ dt_max_relative, indexes_dt_relative ] = max( dts_flat_relative );
[ condition_number_max_relative, indexes_condition_number_relative ] = max( condition_numbers_flat_relative );

% Concatenate the encoded input and output signals.
Us_flat_desired_absolute = [ U1s_flat_absolute, U2s_flat_absolute, U3s_flat_desired_absolute ];
Us_flat_achieved_theoretical_absolute = [ U1s_flat_absolute, U2s_flat_absolute, U3s_flat_achieved_theoretical_absolute ];
Us_grid_desired_absolute = cat( 3, U1s_grid_absolute, U2s_grid_absolute, U3s_grid_desired_absolute );
Us_grid_achieved_theoretical_absolute = cat( 3, U1s_grid_absolute, U2s_grid_absolute, U3s_grid_achieved_theoretical_absolute );

Us_flat_desired_relative = [ U1s_flat_relative, U2s_flat_relative, U3s_flat_desired_relative ];
Us_flat_achieved_theoretical_relative = [ U1s_flat_relative, U2s_flat_relative, U3s_flat_achieved_theoretical_relative ];
Us_grid_desired_relative = cat( 3, U1s_grid_relative, U2s_grid_relative, U3s_grid_desired_relative );
Us_grid_achieved_theoretical_relative = cat( 3, U1s_grid_relative, U2s_grid_relative, U3s_grid_achieved_theoretical_relative );


%% Print the Numerical Stability Information.

% Print out the stability information.
network_absolute.numerical_method_utilities.print_numerical_stability_info( As_absolute, dts_absolute, network_dt, condition_numbers_absolute );
network_relative.numerical_method_utilities.print_numerical_stability_info( As_relative, dts_relative, network_dt, condition_numbers_relative );


%% Process Simulation Step Sizes.

% Define the simulation step size threshold.
epsilon = 0.80;

% Create an array to store the step sizes.
network_dts_absolute = network_dt*ones( num_input_signals, 1 );
network_dts_relative = network_dt*ones( num_input_signals, 1 );

% Determine whether to adapt the step sizes.
if adapt_step_size_flag                     % If we want to adapt the step sizes...
    
    % Adapt the step sizes.
    network_dts_absolute = network_utilities.adapt_step_sizes( network_dts_absolute, dts_absolute, epsilon );
    network_dts_relative = network_utilities.adapt_step_sizes( network_dts_relative, dts_relative, epsilon );

end


%% Simulate the Subnetwork.

% Determine whether to simulate the network.
if simulate_flag                            % If we want to simulate the network...

    % Set additional simulation properties.
    filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
    process_option = 'None';                    % [str] Process Option.
    
    % Compute the decoded steady state simulation results.
    [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.compute_steady_state_simulation_decoded( network_dts_absolute, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_absolute, f_decode2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, network_absolute.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_absolute.network_utilities );
    [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.compute_steady_state_simulation_decoded( network_dts_relative, network_tf, integration_method, input_current_ID_absolute, xs_numerical_input, f_encode1_relative, f_decode2_relative, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, network_relative.applied_voltage_manager, filter_disabled_flag, process_option, undetected_option, network_relative.network_utilities );

    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_division_subnetwork_error' ], 'Ias_magnitude_absolute', 'Us_numerical_absolute', 'xs_numerical_absolute' )
    save( [ save_directory, '\', 'relative_division_subnetwork_error' ], 'Ias_magnitude_relative', 'Us_numerical_relative', 'xs_numerical_relative' )

else                % Otherwise... ( We must want to load data from an existing simulation... )

    % Load the simulation results.
    data_absolute = load( [ load_directory, '\', 'absolute_division_subnetwork_error' ] );
    data_relative = load( [ load_directory, '\', 'relative_division_subnetwork_error' ] );

    % Unpack the steady state simulation data.
    [ xs_numerical_absolute, Us_numerical_absolute, Ias_magnitude_absolute ] = network_absolute.unpack_steady_state_simulation_data( data_absolute );
    [ xs_numerical_relative, Us_numerical_relative, Ias_magnitude_relative ] = network_relative.unpack_steady_state_simulation_data( data_relative );

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
Us_desired_absolute( :, 2 ) = network_absolute.compute_encoded_desired_absolute_division_sso( Us_desired_absolute( :, 1 ), c1, c3, delta, x1_max, network_absolute.network_utilities );
Us_desired_relative( :, 2 ) = network_relative.compute_encoded_desired_relative_division_sso( Us_desired_relative( :, 1 ), c1, c3, delta, R1_relative, R2_relative, network_relative.neuron_manager, undetected_option, network_relative.network_utilities );

% Compute the absolute and relative achieved theoretical subnetwork output.
Us_theoretical_absolute( :, 2 ) = network_absolute.compute_encoded_achieved_division_sso( Us_theoretical_absolute( :, 1 ), R1_absolute, Gm2_absolute, gs21_absolute, dEs21_absolute, Ia2_absolute, network_absolute.neuron_manager, network_absolute.synapse_manager, network_absolute.applied_current_manager, undetected_option, network_absolute.network_utilities );
Us_theoretical_relative( :, 2 ) = network_relative.compute_encoded_achieved_division_sso( Us_theoretical_relative( :, 1 ), R1_relative, Gm2_relative, gs21_relative, dEs21_relative, Ia2_relative, network_relative.neuron_manager, network_relative.synapse_manager, network_relative.applied_current_manager, undetected_option, network_relative.network_utilities );

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

% Define a scale factor.
scale = 1e3;

% Define the absolute header strings.
header_str_encoded_absolute = 'Absolute Division Encoded Error Statistics';
header_str_decoded_absolute = 'Absolute Division Decoded Error Statistics';

% Define the relative header strings.
header_str_encoded_relative = 'Relative Division Encoded Error Statistics';
header_str_decoded_relative = 'Relative Division Decoded Error Statistics';

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

% Print the absolute division summary statistics.
network_absolute.numerical_method_utilities.print_error_statistics( header_str_encoded_absolute, unit_str_encoded, 1/scale, error_rmse_theoretical_encoded_absolute, error_rmse_percentage_theoretical_encoded_absolute, error_rmse_numerical_encoded_absolute, error_rmse_percentage_numerical_encoded_absolute, error_std_theoretical_encoded_absolute, error_std_percentage_theoretical_encoded_absolute, error_std_numerical_encoded_absolute, error_std_percentage_numerical_encoded_absolute, error_min_theoretical_encoded_absolute, error_min_percentage_theoretical_encoded_absolute, Us_critmin_theoretical_absolute, error_min_numerical_encoded_absolute, error_min_percentage_numerical_encoded_absolute, Us_critmin_numerical_absolute, error_max_theoretical_encoded_absolute, error_max_percentage_theoretical_encoded_absolute, Us_critmax_theoretical_absolute, error_max_numerical_encoded_absolute, error_max_percentage_numerical_encoded_absolute, Us_critmax_numerical_absolute, error_range_theoretical_encoded_absolute, error_range_percentage_theoretical_encoded_absolute, error_range_numerical_encoded_absolute, error_range_percentage_numerical_encoded_absolute )
network_absolute.numerical_method_utilities.print_error_statistics( header_str_decoded_absolute, unit_str_decoded, 1/scale, error_rmse_theoretical_decoded_absolute, error_rmse_percentage_theoretical_decoded_absolute, error_rmse_numerical_decoded_absolute, error_rmse_percentage_numerical_decoded_absolute, error_std_theoretical_decoded_absolute, error_std_percentage_theoretical_decoded_absolute, error_std_numerical_decoded_absolute, error_std_percentage_numerical_decoded_absolute, error_min_theoretical_decoded_absolute, error_min_percentage_theoretical_decoded_absolute, xs_critmin_theoretical_absolute, error_min_numerical_decoded_absolute, error_min_percentage_numerical_decoded_absolute, xs_critmin_numerical_absolute, error_max_theoretical_decoded_absolute, error_max_percentage_theoretical_decoded_absolute, xs_critmax_theoretical_absolute, error_max_numerical_decoded_absolute, error_max_percentage_numerical_decoded_absolute, xs_critmax_numerical_absolute, error_range_theoretical_decoded_absolute, error_range_percentage_theoretical_decoded_absolute, error_range_numerical_decoded_absolute, error_range_percentage_numerical_decoded_absolute )

% Print the relative division summary statistics.
network_relative.numerical_method_utilities.print_error_statistics( header_str_encoded_relative, unit_str_encoded, 1/scale, error_rmse_theoretical_encoded_relative, error_rmse_percentage_theoretical_encoded_relative, error_rmse_numerical_encoded_relative, error_rmse_percentage_numerical_encoded_relative, error_std_theoretical_encoded_relative, error_std_percentage_theoretical_encoded_relative, error_std_numerical_encoded_relative, error_std_percentage_numerical_encoded_relative, error_min_theoretical_encoded_relative, error_min_percentage_theoretical_encoded_relative, Us_critmin_theoretical_relative, error_min_numerical_encoded_relative, error_min_percentage_numerical_encoded_relative, Us_critmin_numerical_relative, error_max_theoretical_encoded_relative, error_max_percentage_theoretical_encoded_relative, Us_critmax_theoretical_relative, error_max_numerical_encoded_relative, error_max_percentage_numerical_encoded_relative, Us_critmax_numerical_relative, error_range_theoretical_encoded_relative, error_range_percentage_theoretical_encoded_relative, error_range_numerical_encoded_relative, error_range_percentage_numerical_encoded_relative )
network_relative.numerical_method_utilities.print_error_statistics( header_str_decoded_relative, unit_str_decoded, 1/scale, error_rmse_theoretical_decoded_relative, error_rmse_percentage_theoretical_decoded_relative, error_rmse_numerical_decoded_relative, error_rmse_percentage_numerical_decoded_relative, error_std_theoretical_decoded_relative, error_std_percentage_theoretical_decoded_relative, error_std_numerical_decoded_relative, error_std_percentage_numerical_decoded_relative, error_min_theoretical_decoded_relative, error_min_percentage_theoretical_decoded_relative, xs_critmin_theoretical_relative, error_min_numerical_decoded_relative, error_min_percentage_numerical_decoded_relative, xs_critmin_numerical_relative, error_max_theoretical_decoded_relative, error_max_percentage_theoretical_decoded_relative, xs_critmax_theoretical_relative, error_max_numerical_decoded_relative, error_max_percentage_numerical_decoded_relative, xs_critmax_numerical_relative, error_range_theoretical_decoded_relative, error_range_percentage_theoretical_decoded_relative, error_range_numerical_decoded_relative, error_range_percentage_numerical_decoded_relative )


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

% % Define the property retrieval settings.
% as_matrix_flag = true;
% 
% % Define the stability analysis timestep seed.
% dt0 = 1e-6;                                                                                                                                                             % [s] Numerical Stability Time Step.
% 
% % Retrieve the properties necessary to compute the numerical stability params for an absolute and relative transmission subnetwork.
% [ Cms_absolute, Gms_absolute, Rs_absolute, gs_absolute, dEs_absolute, Ias_absolute ] = network_absolute.get_numerical_stability_params( network_absolute.neuron_manager, network_absolute.synapse_manager, as_matrix_flag, undetected_option );
% [ Cms_relative, Gms_relative, Rs_relative, gs_relative, dEs_relative, Ias_relative ] = network_relative.get_numerical_stability_params( network_relative.neuron_manager, network_relative.synapse_manager, as_matrix_flag, undetected_option );
% 
% % Compute the relative division steady state output.
% [ ~, As_absolute, dts_absolute, condition_numbers_absolute ] = network_absolute.achieved_division_RK4_stability_analysis( Us_desired_absolute( :, 1 ), Cms_absolute, Gms_absolute, Rs_absolute, Ias_absolute, gs_absolute, dEs_absolute, dt0, network_absolute.neuron_manager, network_absolute.synapse_manager, undetected_option, network_absolute.network_utilities );
% [ ~, As_relative, dts_relative, condition_numbers_relative ] = network_relative.achieved_division_RK4_stability_analysis( Us_desired_relative( :, 1 ), Cms_relative, Gms_relative, Rs_relative, Ias_relative, gs_relative, dEs_relative, dt0, network_relative.neuron_manager, network_relative.synapse_manager, undetected_option, network_relative.network_utilities );
% 
% % Retrieve the maximum RK4 step size.
% [ dt_max_absolute, indexes_dt_absolute ] = min( dts_absolute );
% [ dt_max_relative, indexes_dt_relative ] = min( dts_relative );
% 
% % Retrieve the maximum condition number.
% [ condition_number_max_absolute, indexes_condition_number_absolute ] = max( condition_numbers_absolute );
% [ condition_number_max_relative, indexes_condition_number_relative ] = max( condition_numbers_relative );


%% Print the Numerical Stability Information.

% % Print out the stability information.
% network_absolute.numerical_method_utilities.print_numerical_stability_info( As_absolute, dts_absolute, network_dt, condition_numbers_absolute );
% network_relative.numerical_method_utilities.print_numerical_stability_info( As_relative, dts_relative, network_dt, condition_numbers_relative );


%% Plot the Subnetwork Steady State Response.

% Define the line colors.
color_absolute = [ 0.0000, 0.4470, 0.7410, 1.0000 ];
color_relative = [ 0.8500, 0.3250, 0.0980, 1.0000 ];

% Define the subnetwork name.
subnetwork_name = 'Division';

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

