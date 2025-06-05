%% Absolute Division Subnetwork Error.

% Clear Everything.
clear, close( 'all' ), clc


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
% network_dt = 1e-3;                              	% [s] Simulation Timestep.
network_dt = 1e-4;                                  % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 0.5;                                 	% [s] Simulation Duration.
% network_tf = 1;                                 	% [s] Simulation Duration.
% network_tf = 3;                                 	% [s] Simulation Duration.

% Construct the simulation times associated with the input currents.
ts = ( 0:network_dt:network_tf )';                 	% [s] Simulation Times.

% Compute the number of simulation timesteps.
n_timesteps = length( ts );                        	% [#] Number of Simulation Timesteps.

% Define the number of neurons.
num_neurons = 3;                                    % [#] Number of Neurons.

% Define the integration method.
integration_method = 'RK4';                         % [str] Integration Method (Either FE for Forward Euler or RK4 for Fourth Order Runge-Kutta).

% Define the encoding scheme.
encoding_scheme = 'absolute';

% Create an instance of the network utilities class.
network_utilities = network_utilities_class(  );


%% Define Subnetwork Design Parameters.

% Define the subnetwork design parameters.
% c1 = 20e-6;                                      	% [-] Subnetwork Gain 1.
c1 = 1e-3;                                          % [-] Subnetwork Gain 1.
c3 = 1e-3;                                          % [-] Subnetwork Gain 3.
delta = 1e-3;                                       % [V] Minimum Decoded Output.
x1_max = 20e-3;                                    	% [-] Maximum Decoded Input (Neuron 1).
x2_max = 20e-3;                                    	% [-] Maximum Decoded Input (Neuron 2).
Gm1 = 1e-6;                                         % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                       	% [S] Membrane Conductance (Neuron 2).
Gm3 = 1e-6;                                       	% [S] Membrane Conductance (Neuron 3).
Cm1 = 5e-9;                                         % [F] Membrane Capacitance (Neuron 1).
Cm2 = 5e-9;                                         % [F] Membrane Capacitance (Neuron 2).
Cm3 = 5e-9;                                         % [F] Membrane Capacitance (Neuron 3).

% Store the subnetwork design parameters in a structure.
division_input_parameters.c1 = c1;
division_input_parameters.c3 = c3;
division_input_parameters.delta = delta;
division_input_parameters.x1_max = x1_max;
division_input_parameters.x2_max = x2_max;
division_input_parameters.Gm1 = Gm1;
division_input_parameters.Gm2 = Gm2;
division_input_parameters.Gm3 = Gm3;
division_input_parameters.Cm1 = Cm1;
division_input_parameters.Cm2 = Cm2;
division_input_parameters.Cm3 = Cm3;


%% Define the Encoding & Decoding Operations.

% Define the encoding maps.
f_encode1 = @( x1 ) network_utilities.encode_absolute_division_input1( x1 );
f_encode2 = @( x2 ) network_utilities.encode_absolute_division_input2( x2 );
f_encode3 = @( x3 ) network_utilities.encode_absolute_division_output( x3 );
f_encode = @( Xs ) [ f_encode1( Xs( :, 1 ) ), f_encode2( Xs( :, 2 ) ), f_encode3( Xs( :, 3 ) ) ];

% Define the decoding maps.
f_decode1 = @( U1 ) network_utilities.decode_absolute_division_input1( U1 );
f_decode2 = @( U2 ) network_utilities.decode_absolute_division_input2( U2 );
f_decode3 = @( U3 ) network_utilities.decode_absolute_division_output( U3 );
f_decode = @( Us ) [ f_decode1( Us( :, 1 ) ), f_decode2( Us( :, 2 ) ), f_decode3( Us( :, 3 ) ) ];


%% Define the Desired Input Signal.

% Define the first desired decoded input signal.
% xs1_desired = 0*ones( n_timesteps, 1 );
xs1_desired = x1_max*ones( n_timesteps, 1 );

% Define the second desired decoded input signal.
% xs2_desired = 0*ones( n_timesteps, 1 );
xs2_desired = x2_max*ones( n_timesteps, 1 );

% Encode the input signals.
Us1_desired = f_encode1( xs1_desired );
Us2_desired = f_encode2( xs2_desired );


%% Define the Subnetwork Input Current Parameters.

% Define the identification properties for the first input current.
input_current_ID1 = 1;                               % [#] Input Current ID.
input_current_name1 = 'Applied Current 1';           % [str] Input Current Name.
input_current_to_neuron_ID1 = 1;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the identification properties for the second input current.
input_current_ID2 = 2;                               % [#] Input Current ID.
input_current_name2 = 'Applied Current 2';           % [str] Input Current Name.
input_current_to_neuron_ID2 = 2;                     % [#] Neuron ID to Which Input Current is Applied.

% Define the magnitudes of the input currents.
Ias1 = Us1_desired*Gm1;                           	% [A] Applied Currents.
Ias2 = Us2_desired*Gm2;                           	% [A] Applied Currents.


%% Create the Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the subnetwork.
[ division_output_params, neurons, synapses, neuron_manager, synapse_manager, network ] = network.create_division_subnetwork( division_input_parameters, encoding_scheme, network.neuron_manager, network.synapse_manager, network.applied_current_manager, true, true, false, undetected_option );

% Unpack the subnetwork output parameters.
[ c2, x3_max, R1, R2, R3, Gna1, Gna2, Gna3, dEs31, dEs32, gs31, gs32, Ia3 ] = network.unpack_absolute_division_output_params( division_output_params, network.neuron_manager, network.synapse_manager, network.applied_current_manager, undetected_option );

% Create the input applied current.
[ ~, ~, ~, network.applied_current_manager ] = network.applied_current_manager.create_applied_current( input_current_ID1, input_current_name1, input_current_to_neuron_ID1, ts, Ias1, true, network.applied_current_manager.applied_currents, true, false, network.applied_current_manager.array_utilities );
[ ~, ~, ~, network.applied_current_manager ] = network.applied_current_manager.create_applied_current( input_current_ID2, input_current_name2, input_current_to_neuron_ID2, ts, Ias2, true, network.applied_current_manager.applied_currents, true, false, network.applied_current_manager.array_utilities );


%% Print Subnetwork Parameters.

% Print subnetwork information.
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
Ias( 3 ) = Ias( 3 ) + Ia3;

% Define the stability analysis timestep seed.
dt0 = 1e-6;                                                                                                                                 % [s] Numerical Stability Time Step.

% Define the division subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute division steady state output.
U3s_flat_desired = network.compute_encoded_desired_absolute_division_sso( U1s_flat, U2s_flat, c1, c3, delta, x1_max, x2_max, network.network_utilities );
[ U3s_flat_achieved_theoretical, As, dts_flat, condition_numbers_flat ] = network.achieved_division_RK4_stability_analysis_encoded( U1s_flat, U2s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0, network.neuron_manager, network.synapse_manager, undetected_option, network.network_utilities );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts_flat, size( U1s_grid ) );
condition_numbers_grid = reshape( condition_numbers_flat, size( U1s_grid ) );
U3s_grid_desired = reshape( U3s_flat_desired, size( U1s_grid ) );
U3s_grid_achieved_theoretical = reshape( U3s_flat_achieved_theoretical, size( U1s_grid ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = max( dts_flat );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers_flat );

% Concatenate the encoded input and output signals.
Us_flat_desired = [ U1s_flat, U2s_flat, U3s_flat_desired ];
Us_flat_achieved_theoretical = [ U1s_flat, U2s_flat, U3s_flat_achieved_theoretical ];
Us_grid_desired = cat( 3, U1s_grid, U2s_grid, U3s_grid_desired );
Us_grid_achieved_theoretical = cat( 3, U1s_grid, U2s_grid, U3s_grid_achieved_theoretical );


%% Print the Numerical Stability Information.

% Print out the stability information.
network.numerical_method_utilities.print_numerical_stability_info( As, dts_flat, network_dt, condition_numbers_flat );


%% Decode the Desired & Theoretically Achieved Subnetwork Results.

% Compute the flat decoded input and output signals.
xs1_flat = f_decode1( Us_flat_desired( :, 1 ) );
xs2_flat = f_decode2( Us_flat_desired( :, 2 ) );
xs3_flat_desired = f_decode3( Us_flat_desired( :, 3 ) );
xs3_flat_achieved_theoretical = f_decode3( Us_flat_achieved_theoretical( :, 3 ) );

% Compute the grid decoded input and output signals.
xs1_grid = f_decode1( Us_grid_desired( :, :, 1 ) );
xs2_grid = f_decode2( Us_grid_desired( :, :, 2 ) );
xs3_grid_desired = f_decode3( Us_grid_desired( :, :, 3 ) );
xs3_grid_achieved_theoretical = f_decode3( Us_grid_achieved_theoretical( :, :, 3 ) );

% Concatenate the flat and grid decoded input and output signals.
Xs_flat_desired = [ xs1_flat, xs2_flat, xs3_flat_desired ];
Xs_flat_achieved_theoretical = [ xs1_flat, xs2_flat, xs3_flat_achieved_theoretical ];
Xs_grid_desired = cat( 3, xs1_grid, xs2_grid, xs3_grid_desired );
Xs_grid_achieved_theoretical = cat( 3, xs1_grid, xs2_grid, xs3_grid_achieved_theoretical );


%% Plot the Desired and Achieved Formulation Results.

% Define a scaling factor.
scale = 1e3;

% Plot the encoded desired and achieved absolute subnetwork formulation results.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Desired & Achieved (Theory) SS Behavior' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Output, U3 [mV]' ), title( 'AD: Encoded Desired & Achieved (Theory) SS Behavior' )
surf( scale*Us_grid_desired( :, :, 1 ), scale*Us_grid_desired( :, :, 2 ), scale*Us_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
surf( scale*Us_grid_achieved_theoretical( :, :, 1 ), scale*Us_grid_achieved_theoretical( :, :, 2 ), scale*Us_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.70 )
legend( 'Desired', 'Theoretically Achieved', 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_division_desired_achieved_theory_encoded' ] )

% Plot the decoded desired and achieved absolute subnetwork formulation results.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Desired & Achieved (Theory) SS Behavior' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Decoded Input 1, x1 [-]' ), xlabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Output, x3 [-]' ), title( 'AD: Decoded Desired & Achieved (Theory) SS Behavior' )
surf( scale*Xs_grid_desired( :, :, 1 ), scale*Xs_grid_desired( :, :, 2 ), scale*Xs_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
surf( scale*Xs_grid_achieved_theoretical( :, :, 1 ), scale*Xs_grid_achieved_theoretical( :, :, 2 ), scale*Xs_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.70 )
legend( 'Desired', 'Theoretically Achieved', 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_division_desired_achieved_theory_decoded' ] )

% Plot the RK4 maximum timestep vs the encoded input.
fig = figure( 'Color', 'w', 'Name', 'AD: RK4 Maximum Timestep vs Encoded Input' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'AD: RK4 Maximum Timestep vs Encoded Input' )
surf( scale*Us_grid_desired( :, :, 1 ), scale*Us_grid_desired( :, :, 2 ), dts_grid, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
saveas( fig, [ save_directory, '\', 'absolute_division_rk4_maximum_timestep_encoded' ] )

% Plot the RK4 maximum timestep vs the decoded input.
fig = figure( 'Color', 'w', 'Name', 'AD: RK4 Maximum Timestep vs Decoded Input' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'AD: RK4 Maximum Timestep vs Decoded Input' )
surf( scale*Xs_grid_desired( :, :, 1 ), scale*Xs_grid_desired( :, :, 2 ), dts_grid, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
saveas( fig, [ save_directory, '\', 'absolute_division_rk4_maximum_timestep_decoded' ] )

% Plot the linearized system condition numbers vs the encoded input.
fig = figure( 'Color', 'w', 'Name', 'AD: Condition Numbers vs Encoded Input' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Condition Number, k [-]' ), title( 'AD: Condition Number vs Encoded Input' )
surf( scale*Us_grid_desired( :, :, 1 ), scale*Us_grid_desired( :, :, 2 ), condition_numbers_grid, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
saveas( fig, [ save_directory, '\', 'absolute_division_condition_numbers_encoded' ] )

% Plot the linearized system condition numbers vs the decoded input.
fig = figure( 'Color', 'w', 'Name', 'AD: Condition Numbers vs Decoded Input' ); hold on, grid on, rotate3d on, view( 135, 15 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Condition Number, k [-]' ), title( 'AD: Condition Number vs Decoded Input' )
surf( scale*Xs_grid_desired( :, :, 1 ), scale*Xs_grid_desired( :, :, 2 ), condition_numbers_grid, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.70 )
saveas( fig, [ save_directory, '\', 'absolute_division_condition_numbers_decoded' ] )


%% Simulate the Subnetwork.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
set_flag = true;                            % [T/F] Set Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';               % [str] Undetected Option.

% Determine whether to simulate the network.
if simulate_flag                            % If we want to simulate the network...
    
    % Define the number of different input signals.
    num_input_signals = 20;                   % [#] Number of Input Signals.
    
    % Define the number of applied currents to use.
    num_input_signals1 = 10;
    num_input_signals2 = 10;
    
    % Define the input signals.
    xs1_input = linspace( 0, x1_max, num_input_signals1 );
    xs2_input = linspace( 0, x2_max, num_input_signals2 );

    % Encode the input signals.
    Us1_input = f_encode1( xs1_input );
    Us2_input = f_encode2( xs2_input );
    
    % Create the applied current inputs.
    Ias1_input = Gm1*Us1_input;
    Ias2_input = Gm2*Us2_input;

    % Create grids of the applied current inputs.
    % [ Ias1_input_grid, Ias2_input_grid ] = meshgrid( Ias1_input, Ias2_input );
    [ Ias1_input_grid, Ias2_input_grid ] = ndgrid( Ias1_input, Ias2_input );

    % Create a matrix to store the membrane voltages.
    Us_grid_achieved_numerical = zeros( num_input_signals1, num_input_signals2, num_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k1 = 1:num_input_signals1               % Iterate through each of the currents applied to the first input neuron...
        for k2 = 1:num_input_signals2           % Iterate through each of the currents applied to the second input neuron...
        
            % Create applied currents.
            [ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( input_current_ID1, Ias1_input_grid( k1, k2 ), 'Ias', network.applied_current_manager.applied_currents, set_flag );
            [ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( input_current_ID2, Ias2_input_grid( k1, k2 ), 'Ias', network.applied_current_manager.applied_currents, set_flag );

            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.compute_simulation( network_dt, network_tf, integration_method, network.neuron_manager, network.synapse_manager, network.applied_current_manager, network.applied_voltage_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network.network_utilities );
            
            % Retrieve the final membrane voltages.
            Us_grid_achieved_numerical( k1, k2, : ) = Us( :, end );
            
        end
    end
    
    % Decode the achieved membrane voltages.
    xs1_grid_achieved_numerical = f_decode1( Us_grid_achieved_numerical( :, :, 1 ) );
    xs2_grid_achieved_numerical = f_decode2( Us_grid_achieved_numerical( :, :, 2 ) );
    xs3_grid_achieved_numerical = f_decode3( Us_grid_achieved_numerical( :, :, 3 ) );
    Xs_grid_achieved_numerical = cat( 3, xs1_grid_achieved_numerical, xs2_grid_achieved_numerical, xs3_grid_achieved_numerical );
    
    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_division_subnetwork_error' ], 'xs1_input', 'xs2_input', 'Us1_input', 'Us2_input', 'Ias1_input', 'Ias2_input', 'Us_grid_achieved_numerical', 'Xs_grid_achieved_numerical' )
    
else                % Otherwise... ( We must want to load data from an existing simulation... )
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_division_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    xs1_input = data.xs1_input;
    xs2_input = data.xs2_input;
    Us1_input = data.Us1_input;
    Us2_input = data.Us2_input;
    Ias1_input = data.Ias1_input;
    Ias2_input = data.Ias2_input;
    Us_grid_achieved_numerical = data.Us_grid_achieved_numerical;
    Xs_grid_achieved_numerical = data.Xs_grid_achieved_numerical;

end


%% Compute the Desired & Achieved (Theory) Subnetwork Output.

% Retrieve the grid encoded achieved numerical signals.
Us1_grid = Us_grid_achieved_numerical( :, :, 1 );
Us2_grid = Us_grid_achieved_numerical( :, :, 2 );
Us3_grid_achieved_numerical = Us_grid_achieved_numerical( :, :, 3 );

% Retrieve the grid decoded achieved numerical signals.
xs1_grid = Xs_grid_achieved_numerical( :, :, 1 );
xs2_grid = Xs_grid_achieved_numerical( :, :, 2 );
xs3_grid_achieved_numerical = Xs_grid_achieved_numerical( :, :, 3 );

% Retrieve the flat encoded achieved numerical signals.
Us1_flat = reshape( Us1_grid, [ numel( Us1_grid ), 1 ] );
Us2_flat = reshape( Us2_grid, [ numel( Us2_grid ), 1 ] );
Us3_flat_achieved_numerical = reshape( Us3_grid_achieved_numerical, [ numel( Us3_grid_achieved_numerical ), 1 ] );
Us_flat_achieved_numerical = [ Us1_flat, Us2_flat, Us3_flat_achieved_numerical ];

% Retrieve the flat decoded achieved numerical signals.
xs1_flat = reshape( xs1_grid, [ numel( xs1_grid ), 1 ] );
xs2_flat = reshape( xs2_grid, [ numel( xs2_grid ), 1 ] );
xs3_flat_achieved_numerical = reshape( xs3_grid_achieved_numerical, [ numel( xs3_grid_achieved_numerical ), 1 ] );
Xs_flat_achieved_numerical = [ xs1_flat, xs2_flat, xs3_flat_achieved_numerical ];

% Compute the encoded desired and achieved (theory) result output.
Us3_flat_desired = network.compute_encoded_desired_absolute_division_sso( Us1_flat, Us2_flat, c1, c3, delta, x1_max, x2_max, network.network_utilities );
Us3_flat_achieved_theoretical = network.compute_encoded_achieved_division_sso( Us1_flat, Us2_flat, R1, R2, Gm3, gs31, gs32, dEs31, dEs32, Ia3, network.neuron_manager, network.synapse_manager, network.applied_current_manager, undetected_option, network.network_utilities );
Us3_grid_desired = reshape( Us3_flat_desired, size( Us3_grid_achieved_numerical ) );
Us3_grid_achieved_theoretical = reshape( Us3_flat_achieved_theoretical, size( Us3_grid_achieved_numerical ) );

% Compute the decoded desired and achieved (theory) result output.
xs3_flat_desired = f_decode3( Us3_flat_desired );
xs3_flat_achieved_theoretical = f_decode3( Us3_flat_achieved_theoretical );
xs3_grid_desired = reshape( xs3_flat_desired, size( xs3_grid_achieved_numerical ) );
xs3_grid_achieved_theoretical = reshape( xs3_flat_achieved_theoretical, size( xs3_grid_achieved_numerical ) );

% Concatenate the encoded desired and achieved (theory) result.
Us_flat_desired = [ Us1_flat, Us2_flat, Us3_flat_desired ];
Us_flat_achieved_theoretical = [ Us1_flat, Us2_flat, Us3_flat_achieved_theoretical ];
Us_grid_desired = cat( 3, Us1_grid, Us2_grid, Us3_grid_desired );
Us_grid_achieved_theoretical = cat( 3, Us1_grid, Us2_grid, Us3_grid_achieved_theoretical );

% Concatenate the decoded desired and achieved (theory) result.
Xs_flat_desired = [ xs1_flat, xs2_flat, xs3_flat_desired ];
Xs_flat_achieved_theoretical = [ xs1_flat, xs2_flat, xs3_flat_achieved_theoretical ];
Xs_grid_desired = cat( 3, xs1_grid, xs2_grid, xs3_grid_desired );
Xs_grid_achieved_theoretical = cat( 3, xs1_grid, xs2_grid, xs3_grid_achieved_theoretical );


%% Compute the Subnetwork Error.

% Compute the error between the encoded theoretical output and the desired output.
[ errors_flat_theoretical_encoded, error_flat_percentages_theoretical_encoded, error_rmse_theoretical_encoded, error_rmse_percentage_theoretical_encoded, error_std_theoretical_encoded, error_std_percentage_theoretical_encoded, error_min_theoretical_encoded, error_min_percentage_theoretical_encoded, index_min_theoretical_encoded, error_max_theoretical_encoded, error_max_percentage_theoretical_encoded, index_max_theoretical_encoded, error_range_theoretical_encoded, error_range_percentage_theoretical_encoded ] = network.numerical_method_utilities.compute_error_statistics( Us_flat_achieved_theoretical, Us_flat_desired, R3 );

% Convert the flat errors to grid errors.
errors_grid_theoretical_encoded = reshape( errors_flat_theoretical_encoded, size( Us_grid_achieved_theoretical( :, :, 3 ) ) );
error_grid_percentages_theoretical_encoded = reshape( error_flat_percentages_theoretical_encoded, size( Us_grid_achieved_theoretical( :, :, 3 ) ) );

% Compute the error between the encoded numerical output and the desired output.
[ errors_flat_numerical_encoded, error_flat_percentages_numerical_encoded, error_rmse_numerical_encoded, error_rmse_percentage_numerical_encoded, error_std_numerical_encoded, error_std_percentage_numerical_encoded, error_min_numerical_encoded, error_min_percentage_numerical_encoded, index_min_numerical_encoded, error_max_numerical_encoded, error_max_percentage_numerical_encoded, index_max_numerical_encoded, error_range_numerical_encoded, error_range_percentage_numerical_encoded ] = network.numerical_method_utilities.compute_error_statistics( Us_flat_achieved_numerical, Us_flat_desired, R3 );

% Convert the flat errors to grid errors.
errors_grid_numerical_encoded = reshape( errors_flat_numerical_encoded, size( Us_grid_achieved_numerical( :, :, 3 ) ) );
error_grid_percentages_numerical_encoded = reshape( error_flat_percentages_numerical_encoded, size( Us_grid_achieved_numerical( :, :, 3 ) ) );

% Compute the error between the decoded theoretical output and the desired output.
[ errors_flat_theoretical_decoded, error_flat_percentages_theoretical_decoded, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, index_min_theoretical_decoded, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, index_max_theoretical_decoded, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded ] = network.numerical_method_utilities.compute_error_statistics( Xs_flat_achieved_theoretical, Xs_flat_desired, x3_max );

% Convert the flat errors to grid errors.
errors_grid_theoretical_decoded = reshape( errors_flat_theoretical_decoded, size( Us_grid_achieved_theoretical( :, :, 3 ) ) );
error_grid_percentages_theoretical_decoded = reshape( error_flat_percentages_theoretical_decoded, size( Us_grid_achieved_theoretical( :, :, 3 ) ) );

% Compute the error between the decoded numerical output and the desired output.
[ errors_flat_numerical_decoded, error_flat_percentages_numerical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_numerical_decoded, error_min_percentage_numerical_decoded, index_min_numerical_decoded, error_max_numerical_decoded, error_max_percentage_numerical_decoded, index_max_numerical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded ] = network.numerical_method_utilities.compute_error_statistics( Xs_flat_achieved_numerical, Xs_flat_desired, x3_max );

% Convert the flat errors to grid errors.
errors_grid_numerical_decoded = reshape( errors_flat_numerical_decoded, size( Us_grid_achieved_numerical( :, :, 3 ) ) );
error_grid_percentages_numerical_decoded = reshape( error_flat_percentages_numerical_decoded, size( Us_grid_achieved_numerical( :, :, 3 ) ) );


%% Print the Subnetwork Summary Statistics.

% Define the header strings.
header_str_encoded = 'Absolute Division Encoded Summary Statistics\n';
header_str_decoded = 'Absolute Division Decoded Summary Statistics\n';

% Define the unit strings.
unit_str_encoded = 'mV';
unit_str_decoded = '-';

% Retrieve the minimum and maximum encoded theoretical and numerical network results.
Us_critmin_achieved_theoretical_steady = Us_flat_achieved_theoretical( index_min_theoretical_encoded, : );
Us_critmin_achieved_numerical_steady = Us_flat_achieved_numerical( index_min_numerical_encoded, : );
Us_critmax_achieved_theoretical_steady = Us_flat_achieved_theoretical( index_max_theoretical_encoded, : );
Us_critmax_achieved_numerical_steady = Us_flat_achieved_numerical( index_max_numerical_encoded, : );

% Retrieve the minimum and maximum decoded theoretical and numerical network results.
ys_critmin_achieved_theoretical_steady = f_decode( Us_critmin_achieved_theoretical_steady );
ys_critmin_achieved_numerical_steady = f_decode( Us_critmin_achieved_numerical_steady );
ys_critmax_achieved_theoretical_steady = f_decode( Us_critmax_achieved_theoretical_steady );
ys_critmax_achieved_numerical_steady = f_decode( Us_critmax_achieved_numerical_steady );

% Print the absolute subnetwork encoded summary statistics.
network.numerical_method_utilities.print_error_statistics( header_str_encoded, unit_str_encoded, 1/scale, error_rmse_theoretical_encoded, error_rmse_percentage_theoretical_encoded, error_rmse_numerical_encoded, error_rmse_percentage_numerical_encoded, error_std_theoretical_encoded, error_std_percentage_theoretical_encoded, error_std_numerical_encoded, error_std_percentage_numerical_encoded, error_min_theoretical_encoded, error_min_percentage_theoretical_encoded, Us_critmin_achieved_theoretical_steady, error_min_numerical_encoded, error_min_percentage_numerical_encoded, Us_critmin_achieved_numerical_steady, error_max_theoretical_encoded, error_max_percentage_theoretical_encoded, Us_critmax_achieved_theoretical_steady, error_max_numerical_encoded, error_max_percentage_numerical_encoded, Us_critmax_achieved_numerical_steady, error_range_theoretical_encoded, error_range_percentage_theoretical_encoded, error_range_numerical_encoded, error_range_percentage_numerical_encoded )    
network.numerical_method_utilities.print_error_statistics( header_str_decoded, unit_str_decoded, 1/scale, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, ys_critmin_achieved_theoretical_steady, error_min_numerical_decoded, error_min_percentage_numerical_decoded, ys_critmin_achieved_numerical_steady, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, ys_critmax_achieved_theoretical_steady, error_max_numerical_decoded, error_max_percentage_numerical_decoded, ys_critmax_achieved_numerical_steady, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded )    


%% Plot the Subnetwork Results.

% Create a plot of the encoded desired network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Response (Desired)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Output, U3 [mV]' ), title( 'AD: Encoded Steady State Response (Desired)' )
surf( scale*Us_grid_desired( :, :, 1 ), scale*Us_grid_desired( :, :, 2 ), scale*Us_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_desired_encoded' ] )

% Create a plot of the decoded desired network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Response (Desired)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Output, x3 [-]' ), title( 'AD: Decoded Steady State Response (Desired)' )
surf( scale*Xs_grid_desired( :, :, 1 ), scale*Xs_grid_desired( :, :, 2 ), scale*Xs_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_desired_decoded' ] )

% Create a plot of the encoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Response (Achieved Theoretical)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Output, U3 [mV]' ), title( 'AD: Encoded Steady State Response (Achieved Theoretical)' )
surf( scale*Us_grid_achieved_theoretical( :, :, 1 ), scale*Us_grid_achieved_theoretical( :, :, 2 ), scale*Us_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_achieved_theoretical_encoded' ] )

% Create a plot of the decoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Response (Achieved Theoretical)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Output, x3 [-]' ), title( 'AD: Decoded Steady State Response (Achieved Theoretical)' )
surf( scale*Xs_grid_achieved_theoretical( :, :, 1 ), scale*Xs_grid_achieved_theoretical( :, :, 2 ), scale*Xs_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_achieved_theoretical_decoded' ] )

% Create a plot of the encoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Response (Achieved Numerical)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Output, U3 [mV]' ), title( 'AD: Encoded Steady State Response (Achieved Numerical)' )
surf( scale*Us_grid_achieved_numerical( :, :, 1 ), scale*Us_grid_achieved_numerical( :, :, 2 ), scale*Us_grid_achieved_numerical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_achieved_numerical_encoded' ] )

% Create a plot of the decoded achieved numerical network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Response (Achieved Numerical)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Output, x3 [-]' ), title( 'AD: Decoded Steady State Response (Achieved Numerical)' )
surf( scale*Xs_grid_achieved_numerical( :, :, 1 ), scale*Xs_grid_achieved_numerical( :, :, 2 ), scale*Xs_grid_achieved_numerical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_achieved_numerical_decoded' ] )

% Create a plot of the encoded desired, achieved (theory), and achieved (numerical) network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input, U1 [mV]' ), ylabel( 'Encoded Output, U2 [mV]' ), title( 'AD: Encoded Steady State Response (Comparison)' )
h1 = surf( scale*Us_grid_desired( :, :, 1 ), scale*Us_grid_desired( :, :, 2 ), scale*Us_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.7 );
h2 = surf( scale*Us_grid_achieved_theoretical( :, :, 1 ), scale*Us_grid_achieved_theoretical( :, :, 2 ), scale*Us_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 );
h3 = surf( scale*Us_grid_achieved_numerical( :, :, 1 ), scale*Us_grid_achieved_numerical( :, :, 2 ), scale*Us_grid_achieved_numerical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_comparison_encoded' ] )

% Create a plot of the decoded desired, achieved (theory), and achieved (numerical) network behavior.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Output, x3 [-]' ), title( 'AD: Decoded Steady State Response (Comparison)' )
h1 = surf( scale*Xs_grid_desired( :, :, 1 ), scale*Xs_grid_desired( :, :, 2 ), scale*Xs_grid_desired( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.7 );
h2 = surf( scale*Xs_grid_achieved_theoretical( :, :, 1 ), scale*Xs_grid_achieved_theoretical( :, :, 2 ), scale*Xs_grid_achieved_theoretical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 );
h3 = surf( scale*Xs_grid_achieved_numerical( :, :, 1 ), scale*Xs_grid_achieved_numerical( :, :, 2 ), scale*Xs_grid_achieved_numerical( :, :, 3 ), 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'absolute_division_sso_comparison_decoded' ] )

% Create a plot of the encoded theoretical and numerical error.
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Error' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Error, E [mV]' ), title( 'AD: Encoded Steady State Error' )
surf( scale*Us_grid_achieved_theoretical( :, :, 1 ), scale*Us_grid_achieved_theoretical( :, :, 2 ), scale*errors_grid_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
surf( scale*Us_grid_achieved_numerical( :, :, 1 ), scale*Us_grid_achieved_numerical( :, :, 2 ), scale*errors_grid_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'absolute_division_sse_encoded' ] )

% Create a plot of the decoded theoretical and numerical error.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Error' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), ylabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Error, E [-]' ), title( 'AD: Decoded Steady State Error' )
surf( scale*Xs_grid_achieved_theoretical( :, :, 1 ), scale*Xs_grid_achieved_theoretical( :, :, 2 ), scale*errors_grid_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
surf( scale*Xs_grid_achieved_numerical( :, :, 1 ), scale*Xs_grid_achieved_numerical( :, :, 2 ), scale*errors_grid_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'absolute_division_sse_decoded' ] )

% Create a plot of the encoded theoretical and numerical percentage error. 
fig = figure( 'Color', 'w', 'Name', 'AD: Encoded Steady State Error Percentage' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Encoded Input 1, U1 [mV]' ), ylabel( 'Encoded Input 2, U2 [mV]' ), zlabel( 'Encoded Error Percentage, E [%]' ), title( 'AD: Encoded Steady State Error Percentage' )
surf( scale*Us_grid_achieved_theoretical( :, :, 1 ), scale*Us_grid_achieved_theoretical( :, :, 2 ), error_grid_percentages_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
surf( scale*Us_grid_achieved_numerical( :, :, 1 ), scale*Us_grid_achieved_numerical( :, :, 2 ), error_grid_percentages_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'absolute_division_ssep_encoded' ] )

% Create a plot of the decoded theoretical and numerical percentage error.
fig = figure( 'Color', 'w', 'Name', 'AD: Decoded Steady State Error Percentage' ); hold on, grid on, rotate3d on, view( 135, 30 ), xlabel( 'Decoded Input 1, x1 [-]' ), xlabel( 'Decoded Input 2, x2 [-]' ), zlabel( 'Decoded Error Percentage, E [%]' ), title( 'AD: Decoded Steady State Error Percentage' )
surf( scale*Xs_grid_achieved_theoretical( :, :, 1 ), scale*Xs_grid_achieved_theoretical( :, :, 2 ), error_grid_percentages_theoretical_encoded, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.7 )
surf( scale*Xs_grid_achieved_numerical( :, :, 1 ), scale*Xs_grid_achieved_numerical( :, :, 2 ), error_grid_percentages_numerical_encoded, 'Edgecolor', 'None', 'Facecolor', 'g', 'Facealpha', 0.7 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Vertical' )
saveas( fig, [ save_directory, '\', 'absolute_division_ssep_decoded' ] )


%{
%% Absolute Division Subnetwork Error.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                                                      % [str] Save Directory.
load_directory = '.\Load';                                                      % [str] Load Directory.

% Set a flag to determine whether to simulate.
b_simulate = true;                                                              % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
% b_simulate = false;                                                           % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
b_verbose = true;                                                               % [T/F] Printing Flag. (Determines whether to print out information.)

% Define the network simulation timestep.
% network_dt = 1e-3;                                                            % [s] Simulation Timestep.
network_dt = 2e-4;                                                              % [s] Simulation Timestep.
% network_dt = 1e-5;                                                            % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                                                 % [s] Simulation Duration.

% Define the number of neurons.
num_neurons = 3;                                                                % [#] Number of Neurons.


%% Define Basic Absolute Division Subnetwork Parameters.

% Define neuron maximum membrane voltages.
R1 = 20e-3;                                                                     % [V] Maximum Membrane Voltage (Neuron 1).
R2 = 20e-3;                                                                     % [V] Maximum Membrane Voltage (Neuron 2).]

% Define the membrane conductances.
Gm1 = 1e-6;                                                                     % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                                                     % [S] Membrane Conductance (Neuron 2).
Gm3 = 1e-6;                                                                     % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1 = 5e-9;                                                                     % [F] Membrance Conductance (Neuron 1).
Cm2 = 5e-9;                                                                     % [F] Membrance Conductance (Neuron 2).
Cm3 = 5e-9;                                                                     % [F] Membrance Conductance (Neuron 3).

% Define the sodium channel conductances.
Gna1 = 0;                                                                       % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                                                       % [S] Sodium Channel Conductance (Neuron 2).
Gna3 = 0;                                                                       % [S] Sodium Channel Conductance (Neuron3).

% Define the synaptic reversal potential.
dEs31 = 194e-3;                                                                 % [V] Synaptic Reversal Potential (Synapse 31).
dEs32 = 0;                                                                      % [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1 = R1*Gm1;                                                                   % [A] Applied Current (Neuron 1).
Ia2 = R2*Gm2;                                                                   % [A] Applied Current (Neuron 2).
Ia3 = 0;                                                                        % [A] Applied Current (Neuron 3).

% Define the input current states.
current_state1 = 0;                                                             % [%] Applied Current Activity Percentage (Neuron 1). 
% current_state1 = 1;                                                        	% [%] Applied Current Activity Percentage (Neuron 1). 
current_state2 = 0;                                                             % [%] Applied Current Activity Percentage (Neuron 2). 
% current_state2 = 1;                                                       	% [%] Applied Current Activity Percentage (Neuron 2). 

% Define subnetwork design constants.
c1 = 0.40e-9;                                                                   % [W] Absolute Division Parameter 1.
c3 = 0.40e-9;                                                                   % [W] Absolute Division Parameter 3.
delta = 1e-3;                                                                   % [V] Membrane Voltage Offset.


%% Compute Absolute Division Subnetwork Derived Parameters.

% Compute the network design parameters.
c2 = ( R1*c1 - delta*c3 )/( delta*R2 );                                         % [A] Absolute Division Parameter 2.

% Compute the maximum membrane voltages.
R3 = c1*R1/c3;                                                                  % [V] Maximum Membrane Voltage (Neuron 3).

% Compute the synaptic conductances.
gs31 = ( R3*Gm3 - Ia3 )/( dEs31 - R3 );                                         % [S] Maximum Synaptic Conductance (Synapse 31).
gs32 = ( ( dEs31 - delta )*gs31 + Ia3 - delta*Gm3 )/( delta - dEs32 );          % [S] Maximum Synaptic Conductance (Synapse 32).


%% Print Absolute Division Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'ABSOLUTE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3*( 10^6 ) )
fprintf( '\n' )

% Print out synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs31 \t= \t%0.2f \t[mV]\n', dEs31*( 10^3 ) )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32*( 10^3 ) )

fprintf( 'gs31 \t= \t%0.2f \t[muS]\n', gs31*( 10^6 ) )
fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Current Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1*Ia1*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', current_state2*Ia2*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3*( 10^9 ) )
fprintf( '\n' )

% Print out design parameters.
fprintf( 'Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[nW]\n', c1*( 10^9 ) )
fprintf( 'c2 \t\t= \t%0.2f \t[nA]\n', c2*( 10^9 ) )
fprintf( 'c3 \t\t= \t%0.2f \t[nW]\n', c3*( 10^9 ) )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta*( 10^3 ) )
fprintf( '\n' )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create an Absolute Division Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 3 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 2 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 3 );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2, Gm3 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2, Cm3 ], 'Cm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gna1, Gna2, Gna3 ], 'Gna' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 3, 3 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs31, gs32 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs31, dEs32 ], 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_state1*Ia1, current_state2*Ia2, Ia3 ], 'I_apps' );


%% Compute Desired & Achieved Absolute Division Formulations.

% Retrieve the maximum membrane voltages.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );                      % [V] Maximum Membrane Voltages.

% Retrieve the membrane capacitances.
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );                    % [F] Membrane Capacitances.

% Retrieve the membrane conductances.
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );                    % [S] Membrane Conductances.

% Retrieve the applied currents.
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );               % [A] Applied Currents.
% Ias = [ 0, Ia2 ];                                                                          	% [A] Applied Currents.

% Retrieve the synaptic conductances.
gs = network.get_gsynmaxs( 'all' );                                                             % [S] Synaptic Conductances.

% Retrieve the synaptic reversal potentials.
dEs = network.get_dEsyns( 'all' );                                                              % [V] Synaptic Reversal Potential.

% Define the numerical stability timestep.
dt0 = 1e-6;                                                                                     % [s] Numerical Stability Time Step.

% Define the division subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute division steady state output.
U3s_flat_desired_absolute = network.compute_desired_absolute_division_steady_state_output( [ U1s_flat, U2s_flat ], c1, c2, c3 );
[ U3s_flat_achieved_absolute, As, dts, condition_numbers ] = network.achieved_division_RK4_stability_analysis( U1s_flat, U2s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts, size( U1s_grid ) );
condition_numbers_grid = reshape( condition_numbers, size( U1s_grid ) );
U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid ) );
U3s_grid_achieved_absolute = reshape( U3s_flat_achieved_absolute, size( U1s_grid ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = min( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Desired Absolute, Desired Relative, and Achieved Division Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ ( %0.2f [mV], %0.2f [mV] )\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ), U2s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ ( %0.2f [mV], %0.2f [mV] )\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ), U2s_flat( indexes_condition_number )*( 10^3 ) )


%% Plot the Desired Absolute, Desired Relative, and Achieved Division Formulation Results.

% Plot the desired and achieved absolute division formulation results.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Division Theory' )
surf( U1s_grid, U2s_grid, U3s_grid_desired_absolute, 'FaceColor', 'b', 'EdgeColor', 'None' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'FaceColor', 'r', 'EdgeColor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'absolute_division_theory' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division RK4 Maximum Timestep' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Rk4 Maximum Timestep, dt [s]' ), title( 'Absolute Division RK4 Maximum Timestep' )
surf( U1s_grid, U2s_grid, dts_grid, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_division_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Condition Numbers' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Condition Number [-]' ), title( 'Absolute Division Condition Number' )
surf( U1s_grid, U2s_grid, condition_numbers_grid, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_division_condition_numbers' ] )


%% Simulate the Absolute Division Subnetwork.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents1 = 10;
    n_applied_currents2 = 10;
    
    % Create the applied currents.
    applied_currents1 = linspace( 0, network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, n_applied_currents1 );
    applied_currents2 = linspace( 0, network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents2 );
    
    % Create a grid of the applied currents.
    [ Applied_Currents1, Applied_Currents2 ] = meshgrid( applied_currents1, applied_currents2 );
    
    % Create a matrix to store the membrane voltages.
    Us_achieved = zeros( n_applied_currents2, n_applied_currents1, num_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k1 = 1:n_applied_currents1                          % Iterate through each of the currents applied to the first neuron...
        for k2 = 1:n_applied_currents2                      % Iterate through each of the currents applied to the second neuron...
            
            % Create applied currents.
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), Applied_Currents1( k2, k1 ), 'I_apps' );
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), Applied_Currents2( k2, k1 ), 'I_apps' );

            % Simulate the network.
            [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
            
            % Retrieve the final membrane voltages.
            Us_achieved( k2, k1, : ) = Us( :, end );
            
        end
    end

    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_division_subnetwork_error' ], 'Applied_Currents1', 'Applied_Currents2', 'Us_achieved' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_division_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    Applied_Currents1 = data.Applied_Currents1;
    Applied_Currents2 = data.Applied_Currents2;
    Us_achieved = data.Us_achieved;

end


%% Compute the Absolute Division Subnetwork Error.

% Compute the desired membrane voltage output.
Us_desired_output =  c1*Us_achieved( :, :, 1 )./( c2*Us_achieved( :, :, 2 ) + c3 );

% Compute the desired membrane voltage output.
Us_desired = Us_achieved; Us_desired( :, :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, :, end ) - Us_desired( :, :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );


%% Plot the Absolute Division Subnetwork Results.

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Subnetwork Steady State Response (Desired)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Division Subnetwork Steady State Response (Desired)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_division_ss_response_desired' ] )

% Create a surface that shows the achieved membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Subnetwork Steady State Response (Achieved)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Division Subnetwork Steady State Response (Achieved)' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_division_ss_response_achieved' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Subnetwork Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Division Subnetwork Steady State Response (Comparison)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'EdgeColor', 'None', 'FaceColor', 'b' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'EdgeColor', 'None', 'FaceColor', 'g' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'EdgeColor', 'None', 'FaceColor', 'r' )
legend( 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' )
saveas( fig, [ save_directory, '\', 'absolute_division_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Subnetwork Steady State Error' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Absolute Division Subnetwork Steady State Error' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), error, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_division_ss_response_error' ] )
%}

