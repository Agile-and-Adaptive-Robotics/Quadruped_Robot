%% Absolute Inversion Subnetwork Error.

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                        	% [str] Save Directory.
load_directory = '.\Load';                       	% [str] Load Directory.

% Set a flag to determine whether to simulate.
simulate_flag = true;                           	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
% simulate_flag = false;                           	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
verbose_flag = true;                             	% [T/F] Printing Flag. (Determines whether to print out information.)

% Define the undetected option.
undetected_option = 'Error';                        % [str] Undetected Option.

% Define the network simulation timestep.
% network_dt = 1e-3;                                 	% [s] Simulation Timestep.
network_dt = 1e-4;                             	% [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Compute the number of simulation timesteps.
n_timesteps = floor( network_tf / network_dt ) + 1;   % [#] Number of Simulation Timesteps.

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Define the number of neurons.
num_neurons = 2;                                    % [#] Number of Neurons.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the encoding scheme.
encoding_scheme = 'absolute';

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );


%% Define Subnetwork Design Parameters.

% Define the subnetwork design parameters.
c1 = 20e-6;                                         % [-] Subnetwork Gain 1.
c3 = 1e-3;                                          % [-] Subnetwork Gain 3.
delta = 1e-3;                                       % [V] Minimum Decoded Output.
x1_max = 20e-3;                                    	% [V] Maximum Membrane Voltage (Neuron 1).
Gm1 = 1e-6;                                         % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                       	% [S] Membrane Conductance (Neuron 2).
Cm1 = 5e-9;                                         % [F] Membrane Capacitance (Neuron 1).
Cm2 = 5e-9;                                         % [F] Membrane Capacitance (Neuron 2).

% Store the transmission subnetwork design parameters in a structure.
inversion_input_parameters.c1 = c1;
inversion_input_parameters.c3 = c3;
inversion_input_parameters.delta = delta;
inversion_input_parameters.x1_max = x1_max;
inversion_input_parameters.Gm1 = Gm1;
inversion_input_parameters.Gm2 = Gm2;
inversion_input_parameters.Cm1 = Cm1;
inversion_input_parameters.Cm2 = Cm2;


%% Define the Encoding & Decoding Operations.

% Define the encoding maps.
f_encode1 = @( x1 ) network_utilities.encode_absolute_inversion_input( x1 );
f_encode2 = @( x2 ) network_utilities.encode_absolute_inversion_output( x2 );
f_encode = @( Xs ) [ f_encode1( Xs( :, 1 ) ), f_encode2( Xs( :, 2 ) ) ];

% Define the decoding maps.
f_decode1 = @( U1 ) network_utilities.decode_absolute_inversion_input( U1 );
f_decode2 = @( U2 ) network_utilities.decode_absolute_inversion_output( U2 );
f_decode = @( Us ) [ f_decode1( Us( :, 1 ) ), f_decode2( Us( :, 2 ) ) ];


%% Define the Input Signal.

% Define the desired decoded input signal.
% xs1_desired = 0*ones( n_timesteps, 1 );
xs1_desired = x1_max*ones( n_timesteps, 1 );

% Encode the input signal.
Us1_desired = f_encode1( xs1_desired );


%% Define the Subnetwork Input Current Parameters.

% Define the current identification properties.
input_current_ID = 1;                               % [#] Input Current ID.
input_current_name = 'Applied Current 1';           % [str] Input Current Name.
input_current_to_neuron_ID = 1;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the magnitudes of the applied current input.
Ias1 = Us1_desired*Gm1;                           	% [A] Applied Currents.


%% Create the Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a inversion subnetwork.
[ inversion_output_parameters, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.create_inversion_subnetwork( inversion_input_parameters, encoding_scheme, network.neuron_manager, network.synapse_manager, network.applied_current_manager, true, true, false, undetected_option );

% Unpack the inversion subnetwork output parameters.
[ c2, x2_max, R1, R2, Gna1, Gna2, dEs21, gs21, Ia2 ] = network.unpack_absolute_inversion_output_parameters( inversion_output_parameters, network.neuron_manager, network.synapse_manager, network.applied_current_manager, undetected_option );

% Update the input current ID and name.
[ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( network.applied_current_manager.applied_currents( 1 ).ID, 2, 'ID', network.applied_current_manager.applied_currents, true );
[ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( network.applied_current_manager.applied_currents( 1 ).ID, { 'Applied Current 2' }, 'name', network.applied_current_manager.applied_currents, true );

% Create the input applied current.
[ ~, ~, ~, network.applied_current_manager ] = network.applied_current_manager.create_applied_current( input_current_ID, input_current_name, input_current_to_neuron_ID, ts, Ias1, true, network.applied_current_manager.applied_currents, true, false, network.applied_current_manager.array_utilities );

% Reverse the order of the applied currents in the applied current manager for cleanliness.
temporary_applied_current = network.applied_current_manager.applied_currents( 1 );
network.applied_current_manager.applied_currents( 1 ) = network.applied_current_manager.applied_currents( 2 );
network.applied_current_manager.applied_currents( 2 ) = temporary_applied_current;


%% Print Subnetwork Parameters.

% Print inversion subnetwork information.
network.print( network.neuron_manager, network.synapse_manager, network.applied_current_manager, verbose_flag );


%% Compute Desired & Achieved Subnetwork Formulations.

% Define the property retrieval settings.
as_matrix_flag = true;

% Retrieve properties from the existing network.
Cms = network.neuron_manager.get_neuron_property( 'all', 'Cm', as_matrix_flag, network.neuron_manager.neurons, undetected_option );         % [F] Membrane Capacitance.
Gms = network.neuron_manager.get_neuron_property( 'all', 'Gm', as_matrix_flag, network.neuron_manager.neurons, undetected_option );         % [S] Membrane Conductance.
Rs = network.neuron_manager.get_neuron_property( 'all', 'R', as_matrix_flag, network.neuron_manager.neurons, undetected_option );           % [V] Maximum Membrane Voltage.
gs = network.get_gs( 'all', network.neuron_manager, network.synapse_manager );                                                              % [S] Synaptic Conductance.
dEs = network.get_dEs( 'all', network.neuron_manager, network.synapse_manager );                                                            % [V] Synaptic Reversal Potential.
Ias = network.neuron_manager.get_neuron_property( 'all', 'Itonic', as_matrix_flag, network.neuron_manager.neurons, undetected_option );     % [A] Applied Currents.

% Update the applied current.
Ias( 2 ) = Ias( 2 ) + Ia2;

% Define the stability analysis timestep seed.
dt0 = 1e-6;                                                                                                                                 % [s] Numerical Stability Time Step.

% Define the transmission subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 100  )';

% Compute the desired and achieved absolute inversion steady state output.
U2s_desired = network.compute_encoded_desired_absolute_inversion_sso( U1s, c1, c3, delta, x1_max, network.network_utilities );
[ U2s_achieved_theoretical, As, dts, condition_numbers ] = network.achieved_inversion_RK4_stability_analysis( U1s, Cms, Gms, Rs, Ias, gs, dEs, dt0, network.neuron_manager, network.synapse_manager, undetected_option, network.network_utilities );

% Store the desired and theoretically achieved absolute inversion steady state results in arrays.
Us_desired = [ U1s, U2s_desired ];
Us_achieved_theoretical = [ U1s, U2s_achieved_theoretical ];

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = max( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Numerical Stability Information.

% Print out the stability information.
network.numerical_method_utilities.print_numerical_stability_info( As, dts, network_dt, condition_numbers );


%% Decode the Desired & Theoretically Achieved Subnetwork Results.

% Compute the decoded desired result.
xs1_desired = f_decode1( Us_desired( :, 1 ) );
xs2_desired = f_decode2( Us_desired( :, 2 ) );
Xs_desired = [ xs1_desired, xs2_desired ];

% Decode the achieved theoretical network output.
xs1_achieved_theoretical  = f_decode1( Us_achieved_theoretical( :, 1 ) );
xs2_achieved_theoretical = f_decode2( Us_achieved_theoretical( :, 2 ) );
Xs_achieved_theoretical = [ xs1_achieved_theoretical, xs2_achieved_theoretical ];


%% Plot the Desired and Achieved Formulation Results.

% Define a scaling factor.
scale = 1e3;

% Plot the encoded desired and achieved absolute transmission formulation results.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Desired & Achieved (Theory) SS Behavior' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Output, U2 [mV]' ), title( 'AI: Encoded Desired & Achieved (Theory) SS Behavior' )
plot( scale*Us_desired( :, 1 ), scale*Us_desired( :, 2 ), '-', 'Linewidth', 3 )
plot( scale*Us_achieved_theoretical( :, 1 ), scale*Us_achieved_theoretical( :, 2 ), '--', 'Linewidth', 3 )
legend( 'Desired', 'Achieved (Theory)' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_desired_achieved_theory_encoded' ] )

% Plot the decoded desired and achieved absolute transmission formulation results.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Desired & Achieved (Theory) SS Behavior' ); hold on, grid on, xlabel( 'Decoded Input, x [-]' ), ylabel( 'Decoded Output, y [-]' ), title( 'AI: Decoded Desired & Achieved (Theory) SS Behavior' )
plot( scale*Xs_desired( :, 1 ), scale*Xs_desired( :, 2 ), '-', 'Linewidth', 3 )
plot( scale*Xs_achieved_theoretical( :, 1 ), scale*Xs_achieved_theoretical( :, 2 ), '--', 'Linewidth', 3 )
legend( 'Desired', 'Achieved (Theory)' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_desired_achieved_theory_decoded' ] )

% Plot the RK4 maximum timestep vs the encoded input.
fig = figure( 'Color', 'w', 'Name', 'AI: RK4 Maximum Timestep vs Encoded Input' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'AI: RK4 Maximum Timestep vs Encoded Input' )
plot( scale*Us_desired( :, 1 ), dts, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_rk4_maximum_timestep_encoded' ] )

% Plot the RK4 maximum timestep vs the decoded input.
fig = figure( 'Color', 'w', 'Name', 'AI: RK4 Maximum Timestep vs Decoded Input' ); hold on, grid on, xlabel( 'Decoded Input, x [-]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'AI: RK4 Maximum Timestep vs Decoded Input' )
plot( scale*Xs_desired( :, 1 ), dts, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_rk4_maximum_timestep_decoded' ] )

% Plot the linearized system condition numbers vs the encoded input.
fig = figure( 'Color', 'w', 'Name', 'AI: Condition Numbers vs Encoded Input' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Condition Number [-]' ), title( 'AI: Condition Number vs Encoded Input' )
plot( scale*Us_desired( :, 1 ), condition_numbers, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_condition_numbers_encoded' ] )

% Plot the linearized system condition numbers vs the decoded input.
fig = figure( 'Color', 'w', 'Name', 'AI: Condition Numbers vs Decoded Input' ); hold on, grid on, xlabel( 'Decoded Input, x [-]' ), ylabel( 'Condition Number [-]' ), title( 'AI: Condition Number vs Decoded Input' )
plot( scale*Xs_desired( :, 1 ), condition_numbers, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_condition_numbers_decoded' ] )


%% Simulate the Subnetwork.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
set_flag = true;                            % [T/F] Set Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';               % [str] Undetected Option.

% Determine whether to simulate the network.
if simulate_flag                            % If we want to simulate the network...
    
    % Define the number of different input signals.
    n_input_signals = 20;                   % [#] Number of Input Signals.
    
    % Define the input signals.
    xs1_input = linspace( 0, x1_max, n_input_signals );
    
    % Encode the input signals.
    Us1_input = f_encode1( xs1_input );
    
    % Create the applied currents.
    Ias1_input = Gm1*Us1_input;
    
    % Create a matrix to store the membrane voltages.
    Us_achieved_numerical = zeros( n_input_signals, num_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k = 1:n_input_signals               % Iterate through each of the currents applied to the input neuron...
            
        % Create applied currents.
        [ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( input_current_ID, Ias1_input( k ), 'Ias', network.applied_current_manager.applied_currents, set_flag );

        % Simulate the network.            
        [ ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.compute_simulation( network_dt, network_tf, integration_method, network.neuron_manager, network.synapse_manager, network.applied_current_manager, network.applied_voltage_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network.network_utilities );

        % Retrieve the final membrane voltages.
        Us_achieved_numerical( k, : ) = Us( :, end );
            
    end
    
    % Decode the achieved membrane voltages.
    xs1_achieved_numerical = f_decode1( Us_achieved_numerical( :, 1 ) );
    xs2_achieved_numerical = f_decode2( Us_achieved_numerical( :, 2 ) );
    Xs_achieved_numerical = [ xs1_achieved_numerical, xs2_achieved_numerical ];
    
    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_inversion_subnetwork_error' ], 'xs1_input', 'Us1_input', 'Ias1_input', 'Us_achieved_numerical', 'Xs_achieved_numerical' )
    
else                % Otherwise... ( We must want to load data from an existing simulation... )
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_inversion_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    xs1_input = data.xs1_input;
    Us1_input = data.Us1_input;
    Ias1_input = data.Ias1_input;
    Us_achieved_numerical = data.Us_achieved_numerical;
    Xs_achieved_numerical = data.Xs_achieved_numerical;

end


%% Compute the Desired & Achieved (Theory) Subnetwork Output.

% Compute the encoded desired and achieved (theory) result output.
Us2_desired = network.compute_encoded_desired_absolute_inversion_sso( Us_achieved_numerical( :, 1 ), c1, c3, delta, x1_max, network.network_utilities );
Us2_achieved_theoretical = network.compute_encoded_achieved_inversion_sso( Us_achieved_numerical( :, 1 ), Rs( 1 ), Gms( 2 ), gs( 2, 1 ), dEs( 2, 1 ), Ias( 2 ), network.neuron_manager, network.synapse_manager, network.applied_current_manager, undetected_option, network.network_utilities );

% Compute the encoded desired and achieved (theory) result.
Us_desired = Us_achieved_numerical; Us_desired( :, end ) = Us2_desired;
Us_achieved_theoretical = Us_achieved_numerical; Us_achieved_theoretical( :, end ) = Us2_achieved_theoretical;

% Compute the decoded desired result.
xs1_desired = f_decode1( Us_desired( :, 1 ) );
xs2_desired = f_decode2( Us_desired( :, 2 ) );
Xs_desired = [ xs1_desired, xs2_desired ];

% Compute the decoded achieved (theory) result.
xs1_achieved_theoretical = f_decode1( Us_achieved_theoretical( :, 1 ) );
xs2_achieved_theoretical = f_decode2( Us_achieved_theoretical( :, 2 ) );
Xs_achieved_theoretical = [ xs1_achieved_theoretical, xs2_achieved_theoretical ];


%% Compute the Subnetwork Error.

% Compute the error between the encoded theoretical output and the desired output.
[ errors_theoretical_encoded, error_percentages_theoretical_encoded, error_rmse_theoretical_encoded, error_rmse_percentage_theoretical_encoded, error_std_theoretical_encoded, error_std_percentage_theoretical_encoded, error_min_theoretical_encoded, error_min_percentage_theoretical_encoded, index_min_theoretical_encoded, error_max_theoretical_encoded, error_max_percentage_theoretical_encoded, index_max_theoretical_encoded, error_range_theoretical_encoded, error_range_percentage_theoretical_encoded ] = network.numerical_method_utilities.compute_error_statistics( Us_achieved_theoretical, Us_desired, Rs( 2 ) );

% Compute the error between the encoded numerical output and the desired output.
[ errors_numerical_encoded, error_percentages_numerical_encoded, error_rmse_numerical_encoded, error_rmse_percentage_numerical_encoded, error_std_numerical_encoded, error_std_percentage_numerical_encoded, error_min_numerical_encoded, error_min_percentage_numerical_encoded, index_min_numerical_encoded, error_max_numerical_encoded, error_max_percentage_numerical_encoded, index_max_numerical_encoded, error_range_numerical_encoded, error_range_percentage_numerical_encoded ] = network.numerical_method_utilities.compute_error_statistics( Us_achieved_numerical, Us_desired, Rs( 2 ) );

% Compute the error between the decoded theoretical output and the desired output.
[ errors_theoretical_decoded, error_percentages_theoretical_decoded, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, index_min_theoretical_decoded, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, index_max_theoretical_decoded, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded ] = network.numerical_method_utilities.compute_error_statistics( Xs_achieved_theoretical, Xs_desired, x2_max );

% Compute the error between the decoded numerical output and the desired output.
[ errors_numerical_decoded, error_percentages_numerical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_numerical_decoded, error_min_percentage_numerical_decoded, index_min_numerical_decoded, error_max_numerical_decoded, error_max_percentage_numerical_decoded, index_max_numerical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded ] = network.numerical_method_utilities.compute_error_statistics( Xs_achieved_numerical, Xs_desired, x2_max );


%% Print the Subnetwork Summary Statistics.

% Define the header strings.
header_str_encoded = 'Absolute Inversion Encoded Summary Statistics\n';
header_str_decoded = 'Absolute Inversion Decoded Summary Statistics\n';

% Define the unit strings.
unit_str_encoded = 'mV';
unit_str_decoded = '-';

% Retrieve the minimum and maximum encoded theoretical and numerical network results.
Us_critmin_achieved_theoretical_steady = Us_achieved_theoretical( index_min_theoretical_encoded, : );
Us_critmin_achieved_numerical_steady = Us_achieved_numerical( index_min_numerical_encoded, : );
Us_critmax_achieved_theoretical_steady = Us_achieved_theoretical( index_max_theoretical_encoded, : );
Us_critmax_achieved_numerical_steady = Us_achieved_numerical( index_max_numerical_encoded, : );

% Retrieve the minimum and maximum decoded theoretical and numerical network results.
ys_critmin_achieved_theoretical_steady = f_decode( Us_critmin_achieved_theoretical_steady );
ys_critmin_achieved_numerical_steady = f_decode( Us_critmin_achieved_numerical_steady );
ys_critmax_achieved_theoretical_steady = f_decode( Us_critmax_achieved_theoretical_steady );
ys_critmax_achieved_numerical_steady = f_decode( Us_critmax_achieved_numerical_steady );

% Print the absolute transmission encoded summary statistics.
network.numerical_method_utilities.print_error_statistics( header_str_encoded, unit_str_encoded, 1/scale, error_rmse_theoretical_encoded, error_rmse_percentage_theoretical_encoded, error_rmse_numerical_encoded, error_rmse_percentage_numerical_encoded, error_std_theoretical_encoded, error_std_percentage_theoretical_encoded, error_std_numerical_encoded, error_std_percentage_numerical_encoded, error_min_theoretical_encoded, error_min_percentage_theoretical_encoded, Us_critmin_achieved_theoretical_steady, error_min_numerical_encoded, error_min_percentage_numerical_encoded, Us_critmin_achieved_numerical_steady, error_max_theoretical_encoded, error_max_percentage_theoretical_encoded, Us_critmax_achieved_theoretical_steady, error_max_numerical_encoded, error_max_percentage_numerical_encoded, Us_critmax_achieved_numerical_steady, error_range_theoretical_encoded, error_range_percentage_theoretical_encoded, error_range_numerical_encoded, error_range_percentage_numerical_encoded )    
network.numerical_method_utilities.print_error_statistics( header_str_decoded, unit_str_decoded, 1/scale, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, ys_critmin_achieved_theoretical_steady, error_min_numerical_decoded, error_min_percentage_numerical_decoded, ys_critmin_achieved_numerical_steady, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, ys_critmax_achieved_theoretical_steady, error_max_numerical_decoded, error_max_percentage_numerical_decoded, ys_critmax_achieved_numerical_steady, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded )    


%% Plot the Subnetwork Results.

% Create a plot of the encoded desired network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Output, U2 [mV]' ), title( 'AI: Encoded Steady State Response (Desired)' )
plot( scale*Us_desired( :, 1 ), scale*Us_desired( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_desired_encoded' ] )

% Create a plot of the decoded desired network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Output, x2 [-]' ), title( 'AI: Decoded Steady State Response (Desired)' )
plot( scale*Xs_desired( :, 1 ), scale*Xs_desired( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_desired_decoded' ] )

% Create a plot of the encoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Response (Achieved Theoretical)' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Output, U2 [mV]' ), title( 'AI: Encoded Steady State Response (Achieved Theoretical)' )
plot( scale*Us_achieved_theoretical( :, 1 ), scale*Us_achieved_theoretical( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_achieved_theoretical_encoded' ] )

% Create a plot of the decoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Response (Achieved Theoretical)' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Output, x2 [-]' ), title( 'AI: Decoded Steady State Response (Achieved Theoretical)' )
plot( scale*Xs_achieved_theoretical( :, 1 ), scale*Xs_achieved_theoretical( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_achieved_theoretical_decoded' ] )

% Create a plot of the encoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Response (Achieved Numerical)' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Input, U2 [mV]' ), title( 'AI: Encoded Steady State Response (Achieved Numerical)' )
plot( scale*Us_achieved_numerical( :, 1 ), scale*Us_achieved_numerical( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_achieved_numerical_encoded' ] )

% Create a plot of the decoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Response (Achieved Numerical)' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Output, x2 [-]' ), title( 'AI: Decoded Steady State Response (Achieved Numerical)' )
plot( scale*Xs_achieved_numerical( :, 1 ), scale*Xs_achieved_numerical( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_achieved_numerical_decoded' ] )

% Create a plot of the encoded desired, achieved (theory), and achieved (numerical) network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Output, U2 [mV]' ), title( 'AI: Encoded Steady State Response (Comparison)' )
h1 = plot( scale*Us_desired( :, 1 ), scale*Us_desired( :, 2 ), '-', 'Linewidth', 3 );
h2 = plot( scale*Us_achieved_theoretical( :, 1 ), scale*Us_achieved_theoretical( :, 2 ), '-.', 'Linewidth', 3 );
h3 = plot( Us_achieved_numerical( :, 1 )*( 10^3 ), Us_achieved_numerical( :, 2 )*( 10^3 ), '--', 'Linewidth', 3 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_comparison_encoded' ] )

% Create a plot of the decoded desired, achieved (theory), and achieved (numerical) network behavior.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Output, x2 [-]' ), title( 'AI: Decoded Steady State Response (Comparison)' )
h1 = plot( scale*Xs_desired( :, 1 ), scale*Xs_desired( :, 2 ), '-', 'Linewidth', 3 );
h2 = plot( scale*Xs_achieved_theoretical( :, 1 ), scale*Xs_achieved_theoretical( :, 2 ), '-.', 'Linewidth', 3 );
h3 = plot( scale*Xs_achieved_numerical( :, 1 ), scale*Xs_achieved_numerical( :, 2 ), '--', 'Linewidth', 3 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_comparison_decoded' ] )

% Create a plot of the encoded theoretical and numerical error.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Error' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Error, E [mV]' ), title( 'AI: Encoded Steady State Error' )
plot( scale*Us_achieved_theoretical( :, 1 ), scale*errors_theoretical_encoded, '-', 'Linewidth', 3 )
plot( scale*Us_achieved_numerical( :, 1 ), scale*errors_numerical_encoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_error_encoded' ] )

% Create a plot of the decoded theoretical and numerical error.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Error' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Error, E [-]' ), title( 'AI: Decoded Steady State Error' )
plot( scale*Xs_achieved_theoretical( :, 1 ), scale*errors_theoretical_decoded, '-', 'Linewidth', 3 )
plot( scale*Xs_achieved_numerical( :, 2 ), scale*errors_numerical_decoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_error_decoded' ] )

% Create a plot of the encoded theoretical and numerical percentage error.
fig = figure( 'Color', 'w', 'Name', 'AI: Encoded Steady State Error Percentage' ); hold on, grid on, xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Error Percentage, E [%]' ), title( 'AI: Encoded Steady State Error Percentage' )
plot( scale*Us_achieved_theoretical( :, 1 ), error_percentages_theoretical_encoded, '-', 'Linewidth', 3 )
plot( scale*Us_achieved_numerical( :, 1 ), error_percentages_numerical_encoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_error_percentage_encoded' ] )

% Create a plot of the decoded theoretical and numerical percentage error.
fig = figure( 'Color', 'w', 'Name', 'AI: Decoded Steady State Error Percentage' ); hold on, grid on, xlabel( 'Decoded Input, x1 [-]' ), ylabel( 'Decoded Error Percentage, E [%]' ), title( 'AI: Decoded Steady State Error Percentage' )
plot( scale*Xs_achieved_theoretical( :, 1 ), error_percentages_theoretical_decoded, '-', 'Linewidth', 3 )
plot( scale*Xs_achieved_numerical( :, 2 ), error_percentages_numerical_decoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_error_percentage_decoded' ] )

