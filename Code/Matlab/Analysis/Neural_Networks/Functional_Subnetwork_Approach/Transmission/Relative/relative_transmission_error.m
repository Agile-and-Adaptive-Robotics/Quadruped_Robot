%% Relative Transmission Subnetwork Error.

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                              % [str] Save Directory.
load_directory = '.\Load';                              % [str] Load Directory.

% Set a flag to determine whether to simulate.
b_simulate = true;                                  	% [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)
% b_simulate = false;                                     % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
b_verbose = true;                                       % [T/F] Printing Flag. (Determines whether to print out information.)

% Define the network simulation timestep.
network_dt = 1e-2;                                    % [s] Simulation Timestep.
% network_dt = 1e-3;                                    % [s] Simulation Timestep.
% network_dt = 1e-4;                                      % [s] Simulation Timestep.
% network_dt = 1e-5;                                    % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                         % [s] Simulation Duration.

% Define the number of neurons.
num_neurons = 2;                                        % [#] Number of Neurons.


%% Define Relative Transmission Subnetwork Parameters.

% Define the maximum membrane voltages.
R1 = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 1).
R2 = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 2).

% Define the absolute transmission comparison example.
R1_absolute = 20e-3;                                % [V] Relative Maximum Membrane Voltage (Neuron 1).  (Used for decoding.)
R2_absolute = 20e-3;                                % [V] Relative Maximum Membrane Voltage (Neuron 2).  (Used for decoding.)

% Define the membrane conductances.
Gm1 = 1e-6;                                       	% [S] Membrane Conductance (Neuron 1)
Gm2 = 1e-6;                                      	% [S] Membrane Conductance (Neuron 2) 

% Define the membrane capacitance.
Cm1 = 5e-9;                                     	% [F] Membrane Capacitance (Neuron 1)
Cm2 = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 2)

% Define the sodium channel conductance.
Gna1 = 0;                                           % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                           % [S] Sodium Channel Conductance (Neuron 2).

% Define the synaptic conductances.
dEs21 = 194e-3;                                   	% [V] Synaptic Reversal Potential (Synapse 21).

% Define the applied currents.
Ia1 = R1*Gm1;                                      	% [A] Applied Current (Neuron 1)
Ia2 = 0;                                            % [A] Applied Current (Neuron 2).

% Define the current state.
current_state1 = 1.0;                           	% [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)

% Define the network design parameters.
c = 1;                                              % [-] Design Constant.

% Define the decoding operations.
f_decode1 = @( x ) ( R1_absolute/R1 )*x*( 10^3 );
f_decode2 = @( x ) ( R2_absolute/R2 )*x*( 10^3 );
f_decode = @( x ) [ ( R1_absolute/R1 )*x( :, 1 )*( 10^3 ), ( R2_absolute/R2 )*x( :, 2 )*( 10^3 ) ];


%% Compute the Derived Relative Transmission Subnetwork Parameters.

% Compute the synaptic conductances.
gs21 = ( R2*Gm2 - Ia2 )/( dEs21 - R2 );             % [S] Synaptic Conductance (Synapse 21).


%% Print Relative Transmission Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'RELATIVE TRANSMISSION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs21 \t= \t%0.2f \t[mV]\n', dEs21*( 10^3 ) )
fprintf( 'gs21 \t= \t%0.2f \t[muS]\n', gs21*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1*Ia1*( 10^9 ) )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c \t\t= \t%0.2f \t[-]\n', c )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create the Relative Transmission Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 2 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 1 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 2 );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gna1, Gna2 ], 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2 ], 'Cm' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 2, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, gs21, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, dEs21, 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_state1*Ia1, Ia2 ], 'I_apps' );


%% Compute Desired & Achieved Relative Transmission Formulations.

% Retrieve the maximum membrane voltages.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );                      % [V] Maximum Membrane Voltages.

% Retrieve the membrane capacitances.
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );                    % [F] Membrane Capacitances.

% Retrieve the membrane conductances.
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );                    % [S] Membrane Conductances.

% Retrieve the applied currents.
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );             % [A] Applied Currents.

% Retrieve the synaptic conductances.
gs = network.get_gsynmaxs( 'all' );                                                             % [S] Synaptic Conductances.

% Retrieve the synaptic reversal potentials.
dEs = network.get_dEsyns( 'all' );                                                              % [V] Synaptic Reversal Potential.

% Define the numerical stability timestep.
dt0 = 1e-6;                                                                                     % [s] Numerical Stability Time Step.

% Define the transmission subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 100  );

% Create the input points.
U1s_flat = reshape( U1s, [ numel( U1s ), 1 ] );

% Compute the desired and achieved relative transmission steady state output.
U2s_flat_desired = network.compute_desired_relative_transmission_steady_state_output( U1s_flat, c, R1, R2 );
[ U2s_flat_achieved_theoretical, As, dts, condition_numbers ] = network.achieved_transmission_RK4_stability_analysis( U1s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Store the desired and theoretically achieved relative transmission steady state results in arrays.
Us_flat_desired = [ U1s_flat, U2s_flat_desired ];
Us_flat_achieved_theoretical = [ U1s_flat, U2s_flat_achieved_theoretical ];

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = max( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Desired and Achieved Relative Transmission Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ %0.2f [mV]\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ %0.2f [mV]\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ) )
fprintf( '\n' )


%% Plot the Desired and Achieved Relative Transmission Formulation Results.

% Decode the input and output membrane voltages.
Us_flat_desired_decoded = f_decode( Us_flat_desired );
Us_flat_achieved_theoretical_decoded = f_decode( Us_flat_achieved_theoretical );

% Plot the desired and achieved relative transmission formulation results.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Theory' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Output), U2 [mV]' ), title( 'Relative Transmission Theory' )
plot( Us_flat_desired( :, 1 )*( 10^3 ), Us_flat_desired( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 )
plot( Us_flat_achieved_theoretical( :, 1 )*( 10^3 ), Us_flat_achieved_theoretical( :, 2 )*( 10^3 ), '--', 'Linewidth', 3 )
legend( 'Desired', 'Achieved (Theory)' )
saveas( fig, [ save_directory, '\', 'relative_transmission_theory' ] )

% Plot the decoded desired and achieved relative transmission formulation results.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Theory Decoded' ); hold on, grid on, xlabel( 'Input, x [-]' ), ylabel( 'Output, y [-]' ), title( 'Relative Transmission Theory Decoded' )
plot( Us_flat_desired_decoded( :, 1 )*( 10^3 ), Us_flat_desired_decoded( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 )
plot( Us_flat_achieved_theoretical_decoded( :, 1 )*( 10^3 ), Us_flat_achieved_theoretical_decoded( :, 2 )*( 10^3 ), '--', 'Linewidth', 3 )
legend( 'Desired', 'Achieved (Theory)' )
saveas( fig, [ save_directory, '\', 'relative_transmission_theory_decoded' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission RK4 Maximum Timestep' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'Relative Transmission RK4 Maximum Timestep' )
plot( Us_flat_desired( :, 1 )*( 10^3 ), dts, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_transmission_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Condition Numbers' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Condition Number [-]' ), title( 'Relative Transmission Condition Number' )
plot( Us_flat_desired( :, 1 )*( 10^3 ), condition_numbers, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_transmission_condition_numbers' ] )


%% Simulate the Relative Transmission Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    num_applied_currents = 20;                                    % [#] Number of Applied Currents.
    
    % Create the applied currents.
    applied_currents_flat = linspace( 0, network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, num_applied_currents )';

    % Simulate the network for each of the applied currents.
    [ network, ts, Us_flat_achieved_numerical, hs_flat_achieved_numerical, dUs_flat_achieved_numerical, dhs_flat_achieved_numerical, Gsyns_flat_achieved_numerical, Ileaks_flat_achieved_numerical, Isyns_flat_achieved_numerical, Inas_flat_achieved_numerical, Iapps_flat_achieved_numerical, Itotals_flat_achieved_numerical, minfs_flat_achieved_numerical, hinfs_flat_achieved_numerical, tauhs_flat_achieved_numerical, neuron_IDs ] = network.simulate_flat( applied_current_IDs( 1 ), applied_currents_flat, network_dt, network_tf, 'RK4' );

    % Retrieve the steady state results from the flat network simulation data. 
    Us_flat_achieved_numerical_steady = Us_flat_achieved_numerical( :, :, end );
    hs_flat_achieved_numerical_steady = hs_flat_achieved_numerical( :, :, end );
    dUs_flat_achieved_numerical_steady = dUs_flat_achieved_numerical( :, :, end );
    dhs_flat_achieved_numerical_steady = dhs_flat_achieved_numerical( :, :, :, end );
    Gsyns_flat_achieved_numerical_steady = Gsyns_flat_achieved_numerical( :, :, end );
    Ileaks_flat_achieved_numerical_steady = Ileaks_flat_achieved_numerical( :, :, end );
    Isyns_flat_achieved_numerical_steady = Isyns_flat_achieved_numerical( :, :, end );
    Inas_flat_achieved_numerical_steady = Inas_flat_achieved_numerical( :, :, end );
    Iapps_flat_achieved_numerical_steady = Iapps_flat_achieved_numerical( :, :, end );
    Itotals_flat_achieved_numerical_steady = Itotals_flat_achieved_numerical( :, :, end );
    minfs_flat_achieved_numerical_steady = minfs_flat_achieved_numerical( :, :, end );
    hinfs_flat_achieved_numerical_steady = hinfs_flat_achieved_numerical( :, :, end );
    tauhs_flat_achieved_numerical_steady = tauhs_flat_achieved_numerical( :, :, end );
    
    % Save the simulation results.
    save( [ save_directory, '\', 'relative_transmission_subnetwork_error' ], 'applied_currents_flat', 'Us_flat_achieved_numerical', 'Us_flat_achieved_numerical_steady' )
    
else                % Otherwise... ( We must want to load data from an existing simulation... )
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'relative_transmission_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    applied_currents_flat = data.applied_currents_flat;
    Us_flat_achieved_numerical = data.Us_flat_achieved_numerical;
    Us_flat_achieved_numerical_steady = data.Us_flat_achieved_numerical_steady;

end


%% Compute the Relative Transmission Network Error.

% Compute the desired membrane voltage output.
Us_flat_desired_steady_output = network.compute_desired_relative_transmission_steady_state_output( Us_flat_achieved_numerical_steady( :, 1 ), c, Rs( 1 ), Rs( 2 ) );
Us_flat_achieved_theoretical_steady_output = network.compute_achieved_transmission_steady_state_output( Us_flat_achieved_numerical_steady( :, 1 ), Rs( 1 ), Gms( 2 ), Ias( 2 ), gs( 2, 1 ), dEs( 2, 1 ) );

% Compute the desired membrane voltage output.
Us_flat_desired_steady = Us_flat_achieved_numerical_steady; Us_flat_desired_steady( :, end ) = Us_flat_desired_steady_output;
Us_flat_achieved_theoretical_steady = Us_flat_achieved_numerical_steady; Us_flat_achieved_theoretical_steady( :, end ) = Us_flat_achieved_theoretical_steady_output;

% Decode the achieved and desired decoded membrane voltage output.
R2_decoded = f_decode2( R2 );
Us_flat_desired_steady_decoded = f_decode( Us_flat_desired_steady );
Us_flat_achieved_theoretical_steady_decoded = f_decode( Us_flat_achieved_theoretical_steady );
Us_flat_achieved_numerical_steady_decoded = f_decode( Us_flat_achieved_numerical_steady );

% Compute the summary statistics associated with the decoded and non-decoded theoretical and achieved results.
[ errors_theoretical, error_percentages_theoretical, error_rmse_theoretical, error_rmse_percentage_theoretical, error_std_theoretical, error_std_percentage_theoretical, error_min_theoretical, error_min_percentage_theoretical, index_min_theoretical, error_max_theoretical, error_max_percentage_theoretical, index_max_theoretical, error_range_theoretical, error_range_percentage_theoretical ] = network.numerical_method_utilities.compute_summary_statistics( Us_flat_achieved_theoretical_steady, Us_flat_desired_steady, R2 );
[ errors_numerical, error_percentages_numerical, error_rmse_numerical, error_rmse_percentage_numerical, error_std_numerical, error_std_percentage_numerical, error_min_numerical, error_min_percentage_numerical, index_min_numerical, error_max_numerical, error_max_percentage_numerical, index_max_numerical, error_range_numerical, error_range_percentage_numerical ] = network.numerical_method_utilities.compute_summary_statistics( Us_flat_achieved_numerical_steady, Us_flat_desired_steady, R2 );
[ errors_theoretical_decoded, error_percentages_theoretical_decoded, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, index_min_theoretical_decoded, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, index_max_theoretical_decoded, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded ] = network.numerical_method_utilities.compute_summary_statistics( Us_flat_achieved_theoretical_steady_decoded, Us_flat_desired_steady_decoded, R2_decoded );
[ errors_numerical_decoded, error_percentages_numerical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_numerical_decoded, error_min_percentage_numerical_decoded, index_min_numerical_decoded, error_max_numerical_decoded, error_max_percentage_numerical_decoded, index_max_numerical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded ] = network.numerical_method_utilities.compute_summary_statistics( Us_flat_achieved_numerical_steady_decoded, Us_flat_desired_steady_decoded, R2_decoded );


%% Print the Relative Tranmission Summary Statistics.

% Retrieve the membrane voltage associated min and max theoretical and numerical error.
Us_critmin_achieved_numerical_steady = Us_flat_achieved_numerical_steady( index_min_theoretical, : );
Us_critmax_achieved_numerical_steady = Us_flat_achieved_numerical_steady( index_max_theoretical, : );
Us_critmin_achieved_theoretical_steady = Us_flat_achieved_theoretical_steady( index_min_theoretical, : );
Us_critmax_achieved_theoretical_steady = Us_flat_achieved_theoretical_steady( index_max_theoretical, : );

% Retrieve the decoded result associated min and max theoretical and numerical error.
Us_critmin_achieved_numerical_steady_decoded = Us_flat_achieved_numerical_steady_decoded( index_min_theoretical_decoded, : );
Us_critmax_achieved_numerical_steady_decoded = Us_flat_achieved_numerical_steady_decoded( index_max_theoretical_decoded, : );
Us_critmin_achieved_theoretical_steady_decoded = Us_flat_achieved_theoretical_steady_decoded( index_min_theoretical_decoded, : );
Us_critmax_achieved_theoretical_steady_decoded = Us_flat_achieved_theoretical_steady_decoded( index_max_theoretical_decoded, : );

% Define the membrane voltage summary statistic printing information.
header_mv = 'Relative Transmission Summary Statistics (Membrane Voltages)\n';
unit_mv = 'mV';
scale_mv = 10^3;

% Print the summary statistics for the membrane voltage results.
network.numerical_method_utilities.print_summary_statistics( header_mv, unit_mv, scale_mv, error_rmse_theoretical, error_rmse_percentage_theoretical, error_rmse_numerical, error_rmse_percentage_numerical, error_std_theoretical, error_std_percentage_theoretical, error_std_numerical, error_std_percentage_numerical, error_min_theoretical, error_min_percentage_theoretical, Us_critmin_achieved_theoretical_steady, error_min_numerical, error_min_percentage_numerical, Us_critmin_achieved_numerical_steady, error_max_theoretical, error_max_percentage_theoretical, Us_critmax_achieved_theoretical_steady, error_max_numerical, error_max_percentage_numerical, Us_critmax_achieved_numerical_steady, error_range_theoretical, error_range_percentage_theoretical, error_range_numerical, error_range_percentage_numerical ) 

% Define the membrane voltage summary statistic printing information.
header_decoded = 'Relative Transmission Summary Statistics (Decoded)\n';
unit_decoded = '-';
scale_decoded = 1;

% Print the summary statistics for the decoded results.
network.numerical_method_utilities.print_summary_statistics( header_decoded, unit_decoded, scale_decoded, error_rmse_theoretical_decoded, error_rmse_percentage_theoretical_decoded, error_rmse_numerical_decoded, error_rmse_percentage_numerical_decoded, error_std_theoretical_decoded, error_std_percentage_theoretical_decoded, error_std_numerical_decoded, error_std_percentage_numerical_decoded, error_min_theoretical_decoded, error_min_percentage_theoretical_decoded, Us_critmin_achieved_theoretical_steady_decoded, error_min_numerical_decoded, error_min_percentage_numerical_decoded, Us_critmin_achieved_numerical_steady_decoded, error_max_theoretical_decoded, error_max_percentage_theoretical_decoded, Us_critmax_achieved_theoretical_steady_decoded, error_max_numerical_decoded, error_max_percentage_numerical_decoded, Us_critmax_achieved_numerical_steady_decoded, error_range_theoretical_decoded, error_range_percentage_theoretical_decoded, error_range_numerical_decoded, error_range_percentage_numerical_decoded ) 


%% Plot the Relative Transmission Network Results.

% Create a plot of the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Input Neuron Membrane Voltage, U1 [mV]' ), ylabel( 'Output Neuron Membrane Voltage, U2 [mV]' ), title( 'Relative Transmission Steady State Response (Desired)' )
plot( Us_flat_desired_steady( :, 1 )*( 10^3 ), Us_flat_desired_steady( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_desired' ] )

% Create a plot of the achieved numerical membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Response (Achieved Theoretical)' ); hold on, grid on, xlabel( 'Input Neuron Membrane Voltage, U1 [mV]' ), ylabel( 'Output Neuron Membrane Voltage, U2 [mV]' ), title( 'Relative Transmission Steady State Response (Achieved Theoretical)' )
plot( Us_flat_achieved_theoretical_steady( :, 1 )*( 10^3 ), Us_flat_achieved_theoretical_steady( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_achieved_theoretical' ] )

% Create a plot of the achieved numerical membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Response (Achieved Numerical)' ); hold on, grid on, xlabel( 'Input Neuron Membrane Voltage, U1 [mV]' ), ylabel( 'Output Neuron Membrane Voltage, U2 [mV]' ), title( 'Relative Transmission Steady State Response (Achieved Numerical)' )
plot( Us_flat_achieved_numerical_steady( :, 1 )*( 10^3 ), Us_flat_achieved_numerical_steady( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_achieved_numerical' ] )

% Create a plot of the desired and achieved membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Input Neuron Membrane Voltage, U1 [mV]' ), ylabel( 'Output Neuron Membrane Voltage, U2 [mV]' ), title( 'Relative Transmission Steady State Response (Comparison)' )
h1 = plot( Us_flat_desired_steady( :, 1 )*( 10^3 ), Us_flat_desired_steady( :, 2 )*( 10^3 ), '-', 'Linewidth', 3 );
h2 = plot( Us_flat_achieved_theoretical_steady( :, 1 )*( 10^3 ), Us_flat_achieved_theoretical_steady( :, 2 )*( 10^3 ), '-.', 'Linewidth', 3 );
h3 = plot( Us_flat_achieved_numerical_steady( :, 1 )*( 10^3 ), Us_flat_achieved_numerical_steady( :, 2 )*( 10^3 ), '--', 'Linewidth', 3 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_comparison' ] )

% Create a plot of the desired and achieved membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Decoding (Comparison)' ); hold on, grid on, xlabel( 'Input, x [-]' ), ylabel( 'Output, y [-]' ), title( 'Relative Transmission Steady State Decoding (Comparison)' )
h1 = plot( Us_flat_desired_steady_decoded( :, 1 ), Us_flat_desired_steady_decoded( :, 2 ), '-', 'Linewidth', 3 );
h2 = plot( Us_flat_achieved_theoretical_steady_decoded( :, 1 ), Us_flat_achieved_theoretical_steady_decoded( :, 2 ), '-.', 'Linewidth', 3 );
h3 = plot( Us_flat_achieved_numerical_steady_decoded( :, 1 ), Us_flat_achieved_numerical_steady_decoded( :, 2 ), '--', 'Linewidth', 3 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theoretical)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_decoding_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Error' ); hold on, grid on, xlabel( 'Input Neuron Membrane Voltage, U1 [mV]' ), ylabel( 'Membrane Voltage Error, E [mV]' ), title( 'Relative Transmission Steady State Error' )
plot( Us_flat_achieved_theoretical_steady( :, 1 )*( 10^3 ), errors_theoretical*( 10^3 ), '-', 'Linewidth', 3 )
plot( Us_flat_achieved_numerical_steady( :, 1 )*( 10^3 ), errors_numerical*( 10^3 ), '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_error' ] )

% Create a surface that shows the decoding error.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Decoding Error' ); hold on, grid on, xlabel( 'Input, x [-]' ), ylabel( 'Decoding Error, E [-]' ), title( 'Relative Transmission Steady State Decoding Error' )
plot( Us_flat_achieved_theoretical_steady_decoded( :, 1 ), errors_theoretical_decoded, '-', 'Linewidth', 3 )
plot( Us_flat_achieved_numerical_steady_decoded( :, 1 ), errors_numerical_decoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_decoding_error' ] )

% Create a surface that shows the decoding error.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Error Percentage' ); hold on, grid on, xlabel( 'Input, x [-]' ), ylabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Relative Transmission Steady State Error Percentage' )
plot( Us_flat_achieved_theoretical_steady( :, 1 ), error_percentages_theoretical, '-', 'Linewidth', 3 )
plot( Us_flat_achieved_numerical_steady( :, 1 ), error_percentages_numerical, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_error_percentage' ] )

% Create a surface that shows the decoding error.
fig = figure( 'Color', 'w', 'Name', 'Relative Transmission Steady State Decoding Error Percentage' ); hold on, grid on, xlabel( 'Input, x [-]' ), ylabel( 'Membrane Voltage Decoding Error Percentage, E [%]' ), title( 'Relative Transmission Steady State Decoding Error Percentage' )
plot( Us_flat_achieved_theoretical_steady_decoded( :, 1 ), error_percentages_theoretical_decoded, '-', 'Linewidth', 3 )
plot( Us_flat_achieved_numerical_steady_decoded( :, 1 ), error_percentages_numerical_decoded, '--', 'Linewidth', 3 )
legend( { 'Theoretical', 'Numerical' }, 'Location', 'Best', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'relative_transmission_ss_response_decoding_error_percentage' ] )


