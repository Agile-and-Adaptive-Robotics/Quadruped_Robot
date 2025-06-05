%% Relative Division Subnetwork Example.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                        	% [str] Save Directory.
load_directory = '.\Load';                         	% [str] Load Directory.

% Define the level of verbosity.
verbose_flag = true;                             	% [T/F] Printing Flag.

% Define the undetected option.
undetected_option = 'error';                        % [str] Undetected Option.

% Define the network integration step size.
% network_dt = 1e-3;                               	% [s] Simulation Timestep.
network_dt = 1e-4;                                  % [s] Simulation Timestep.

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

% Define the encoding scheme.
encoding_scheme = 'relative';

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
R1 = 20e-3;                                         % [V] Maximum Encoded Input (Neuron 1).
R2 = 20e-3;                                         % [V] Maximum Encoded Input (Neuron 2).
R3 = 20e-3;                                         % [V] Maximum Encoded Input (Neuron 3).
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
division_input_parameters.R1 = R1;
division_input_parameters.R2 = R2;
division_input_parameters.R3 = R3;
division_input_parameters.Gm1 = Gm1;
division_input_parameters.Gm2 = Gm2;
division_input_parameters.Gm3 = Gm3;
division_input_parameters.Cm1 = Cm1;
division_input_parameters.Cm2 = Cm2;
division_input_parameters.Cm3 = Cm3;


%% Define the Encoding & Decoding Operations.

% Define the encoding maps.
f_encode1 = @( x1 ) network_utilities.encode_relative_division_input1( x1, x1_max, R1 );
f_encode2 = @( x2 ) network_utilities.encode_relative_division_input2( x2, x2_max, R2 );
f_encode3 = @( x3 ) network_utilities.encode_relative_division_output( x3, c1, c3, x1_max, R3 );
f_encode = @( Xs ) [ f_encode1( Xs( :, 1 ) ), f_encode2( Xs( :, 2 ) ), f_encode3( Xs( :, 3 ) ) ];

% Define the decoding maps.
f_decode1 = @( U1 ) network_utilities.decode_relative_division_input1( U1, x1_max, R1 );
f_decode2 = @( U2 ) network_utilities.decode_relative_division_input2( U2, x2_max, R2 );
f_decode3 = @( U3 ) network_utilities.decode_relative_division_output( U3, c1, c3, x1_max, R3 );
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

% Create a division subnetwork.
[ division_output_parameters, neurons, synapses, neuron_manager, synapse_manager, network ] = network.create_division_subnetwork( division_input_parameters, encoding_scheme, network.neuron_manager, network.synapse_manager, network.applied_current_manager, true, true, false, undetected_option );

% % Update the input current ID and name.
% [ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( network.applied_current_manager.applied_currents( 1 ).ID, 3, 'ID', network.applied_current_manager.applied_currents, true );
% [ ~, network.applied_current_manager ] = network.applied_current_manager.set_applied_current_property( network.applied_current_manager.applied_currents( 1 ).ID, { 'Applied Current 3' }, 'name', network.applied_current_manager.applied_currents, true );

% Create the input applied current.
[ ~, ~, ~, network.applied_current_manager ] = network.applied_current_manager.create_applied_current( input_current_ID1, input_current_name1, input_current_to_neuron_ID1, ts, Ias1, true, network.applied_current_manager.applied_currents, true, false, network.applied_current_manager.array_utilities );
[ ~, ~, ~, network.applied_current_manager ] = network.applied_current_manager.create_applied_current( input_current_ID2, input_current_name2, input_current_to_neuron_ID2, ts, Ias2, true, network.applied_current_manager.applied_currents, true, false, network.applied_current_manager.array_utilities );

% % Reverse the order of the applied currents in the applied current manager for cleanliness.
% temporary_applied_current = network.applied_current_manager.applied_currents( 1 );
% network.applied_current_manager.applied_currents( 1 ) = network.applied_current_manager.applied_currents( 2 );
% network.applied_current_manager.applied_currents( 2 ) = network.applied_current_manager.applied_currents( 3 );
% network.applied_current_manager.applied_currents( 3 ) = temporary_applied_current;


%% Print Subnetwork Parameters.

% Print division subnetwork information.
network.print( network.neuron_manager, network.synapse_manager, network.applied_current_manager, verbose_flag );


%% Compute Numerical Stability Analysis Parameters.

% Define the property retrieval settings.
as_matrix_flag = true;

% Retrieve properties from the existing network.
Cms = network.neuron_manager.get_neuron_property( 'all', 'Cm', as_matrix_flag, network.neuron_manager.neurons, undetected_option );         % [F] Membrane Capacitance.
Gms = network.neuron_manager.get_neuron_property( 'all', 'Gm', as_matrix_flag, network.neuron_manager.neurons, undetected_option );         % [S] Membrane Conductance.
Rs = network.neuron_manager.get_neuron_property( 'all', 'R', as_matrix_flag, network.neuron_manager.neurons, undetected_option );           % [V] Maximum Membrane Voltage.
gs = network.get_gs( 'all', network.neuron_manager, network.synapse_manager );                                                              % [S] Synaptic Conductance.
dEs = network.get_dEs( 'all', network.neuron_manager, network.synapse_manager );                                                            % [V] Synaptic Reversal Potential.
Us = zeros( 1, network.neuron_manager.num_neurons );                                                                                        % [V] Membrane Voltage.

% Define the stability analysis timestep seed.
dt0 = 1e-6;                                                                                                                                 % [s] Stability Analysis Time Step Seed.

% Compute the maximum RK4 step size and condition number.
[ As, dts, condition_numbers ] = network.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, network.neuron_manager, network.synapse_manager, undetected_option, network.network_utilities );


%% Print the Numerical Stability Information.

% Print out the stability information.
network.numerical_method_utilities.print_numerical_stability_info( As, dts, network_dt, condition_numbers );


%% Simulate the Subnetwork.

% Set additional simulation properties.
filter_disabled_flag = true;                % [T/F] Filter Disabled Flag.
set_flag = true;                            % [T/F] Set Flag.
process_option = 'None';                    % [str] Process Option.
undetected_option = 'Ignore';               % [str] Undetected Option.

% Start the timer.
tic

% Simulate the network.
[ ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, ~, ~, ~, ~, network ] = network.compute_simulation( network_dt, network_tf, integration_method, network.neuron_manager, network.synapse_manager, network.applied_current_manager, network.applied_voltage_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network.network_utilities );

% End the timer.
toc


%% Decode the Subnetwork Output.

% Decode the network input and output signals.
xs1 = f_decode1( Us( 1, : ) );
xs2 = f_decode2( Us( 2, : ) );
xs3 = f_decode3( Us( 3, : ) );

% Concatenate the decoded input and output signals.
Xs = [ xs1; xs2; xs3 ];


%% Plot the Subnetwork Results.

% Retrieve the neuron IDs.
neuron_IDs = network.neuron_manager.get_all_neuron_IDs( network.neuron_manager.neurons );

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Plot the encoded network input and output over time.
fig_network_encoded = figure( 'Color', 'w', 'Name', 'RI: Encoded Input & Output vs Time' ); hold on, grid on, xlabel( 'Time, t [s]' ), ylabel( 'RI: Encoded Input & Output, U [V]' ), title( 'RI: Encoded Input & Output vs Time' )
plot( ts, Us( 1, : ), '-', 'Linewidth', 3 )
plot( ts, Us( 2, : ), '-', 'Linewidth', 3 )
plot( ts, Us( 3, : ), '-', 'Linewidth', 3 )
legend( 'Encoded Input 1', 'Encoded Input 2', 'Encoded Output' )
saveas( fig_network_encoded, [ save_directory, '\', 'relative_division_example_encoded' ] )

% Plot the decoded network input and output over time.
fig_network_decoded = figure( 'Color', 'w', 'Name', 'RI: Decoded Input & Output vs Time' ); hold on, grid on, xlabel( 'Time, t [s]' ), ylabel( 'RI: Decoded Input & Output [-]' ), title( 'RI: Decoded Input & Output vs Time' )
plot( ts, Xs( 1, : ), '-', 'Linewidth', 3 )
plot( ts, Xs( 2, : ), '-', 'Linewidth', 3 )
plot( ts, Xs( 3, : ), '-', 'Linewidth', 3 )
legend( 'Decoded Input 1', 'Decoded Input 2', 'Decoded Output' )
saveas( fig_network_decoded, [ save_directory, '\', 'relative_division_example_decoded' ] )

% Plot the encoded network input and output.
fig_network_encoded = figure( 'Color', 'w', 'Name', 'RI: Decoded Output vs Decoded Input' ); hold on, grid on, rotate3d on, view( 45, 30 ), xlabel( 'Encoded Input 1, U1 [V]' ), ylabel( 'Encoded Input 2, U2 [V]' ), zlabel( 'Encoded Output, U3 [V]' ), title( 'RI: Encoded Output vs Encoded Input' )
plot3( Us( 1, : ), Us( 2, : ), Us( 3, : ), '-', 'Linewidth', 3 )
saveas( fig_network_encoded, [ save_directory, '\', 'relative_division_dynamic_example_encoded' ] )

% Plot the decoded network input and output.
fig_network_decoding = figure( 'Color', 'w', 'Name', 'RI: Decoded Output vs Decoded Input' ); hold on, grid on, rotate3d on, view( 45, 30 ), xlabel( 'Decoded Input 1, X1 [-]' ), ylabel( 'Decoded Input 2, X2 [-]' ), zlabel( 'Decoded Output, X3 [-]' ), title( 'RI: Decoded Output vs Decoded Input' )
plot3( Xs( 1, : ), Xs( 2, : ), Xs( 3, : ), '-', 'Linewidth', 3 )
saveas( fig_network_decoding, [ save_directory, '\', 'relative_division_dynamic_example_decoded' ] )

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

