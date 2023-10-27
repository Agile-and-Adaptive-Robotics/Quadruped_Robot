%% Absolute Subtraction Subnetwork Error

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Define the save and load directories.
save_directory = '.\Save';
load_directory = '.\Load';

% Set a flag to determine whether to simulate.
b_simulate = true;
% b_simulate = false;

% Set the level of verbosity.
b_verbose = true;


% %% Create Absolute Subtraction Subnetwork.
% 
% % Define the network integration step size.
% network_dt = 1e-3;
% network_tf = 3;
% 
% % Set the subtraction subnetwork properties.
% % num_subtraction_neurons = 4;
% % c = 1;
% % s_ks = [ 1, -1, 1 ];
% 
% num_subtraction_neurons = 3;
% c = 1;
% s_ks = [ 1, -1 ];
% 
% % Create an instance of the network class.
% network = network_class( network_dt, network_tf );
% 
% % Create a subtraction subnetwork.
% [ network, neuron_IDs, synapse_IDs, applied_current_IDs ] = network.create_absolute_subtraction_subnetwork( num_subtraction_neurons, c, s_ks );


%% Create Absolute Subtraction Subnetwork.

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;

% Define the number of subtraction neurons.
num_subtraction_neurons = 3;

% Define the network parameters.
R1 = 40e-3;
R2 = 20e-3;
c = 1;
s1 = 1;
s2 = -1;
Ia3 = 0;
Gm3 = 1e-7;
dEs31 = 194e-3;
dEs32 = -194e-3;
s_ks = [ s1, s2 ];

% Compute the derived parameters.
R3 = c*R1;
gs31 = ( Ia3 - c*s1*Gm3*R1 )/( c*s1*R1 - dEs31 );
gs32 = ( Ia3 - c*s2*Gm3*R2 )/( c*s2*R2 - dEs32 );

% Print a summary of the relevant network parameters.
fprintf( 'NETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', R3*( 10^3 ) )
fprintf( 'c = %0.2f [-]\n', c )
fprintf( 'dEs31 = %0.2f [mV]\n', dEs31*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs32*( 10^3 ) )
fprintf( 'gs31 = %0.2f [muS]\n', gs31*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs32*( 10^6 ) )
fprintf( 'Gm3 = %0.2f [muS]\n', Gm3*( 10^6 ) )
fprintf( 'Ia3 = %0.2f [nA]\n', Ia3*( 10^9 ) )
fprintf( '\n\n' )

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 3 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 3 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 3 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'Gna' );

network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), R1, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), R2, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), R3, 'R' );

network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Gm3, 'Gm' );
% network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), Ia3, 'I_tonic' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 3 ), 0, 'I_tonic' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 3, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), gs31, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), dEs31, 'dE_syn' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 2, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 2 ), 3, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 2 ), gs32, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 2 ), dEs32, 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), Ia3, 'I_apps' );


%% Compute Desired & Achieved Subtraction Formulations.

% Retrieve network information.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );
gs = network.get_gsynmaxs( 'all' );
dEs = network.get_dEsyns( 'all' );
dt0 = 1e-6;

% Define the subtraction subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute subtraction steady state output.
U3s_flat_desired_absolute = network.compute_desired_absolute_subtraction_steady_state_output( [ U1s_flat, U2s_flat ], c, s_ks );
[ U3s_flat_achieved_absolute, As, dts, condition_numbers ] = network.achieved_subtraction_RK4_stability_analysis( U1s_flat, U2s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts, size( U1s_grid ) );
condition_numbers_grid = reshape( condition_numbers, size( U1s_grid ) );
U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid ) );
U3s_grid_achieved_absolute = reshape( U3s_flat_achieved_absolute, size( U1s_grid ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = max( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );

% Print a summary of the relevant network parameters.
fprintf( 'NETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', Rs( 1 )*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', Rs( 2 )*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', Rs( 3 )*( 10^3 ) )
fprintf( 'c = %0.2f [-]\n', c )
fprintf( 'dEs31 = %0.2f [mV]\n', dEs( 3, 1 )*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs( 3, 2 )*( 10^3 ) )
fprintf( 'gs31 = %0.2f [muS]\n', gs( 3, 1 )*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs( 3, 2 )*( 10^6 ) )
fprintf( 'Gm3 = %0.2f [muS]\n', Gms( 3 )*( 10^6 ) )
fprintf( 'Ia3 = %0.2f [nA]\n', Ias( 3 )*( 10^9 ) )
fprintf( '\n\n' )


%% Print the Desired Absolute, Desired Relative, and Achieved Subtraction Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ ( %0.2f [mV], %0.2f [mV] )\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ), U2s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ ( %0.2f [mV], %0.2f [mV] )\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ), U2s_flat( indexes_condition_number )*( 10^3 ) )


%% Plot the Desired Absolute, Desired Relative, and Achieved Subtraction Formulation Results.

% Plot the desired and achieved absolute subtraction formulation results.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Subtraction Theory' )
surf( U1s_grid, U2s_grid, U3s_grid_desired_absolute, 'FaceColor', 'b', 'EdgeColor', 'None' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'FaceColor', 'r', 'EdgeColor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_theory' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction RK4 Maximum Timestep' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Rk4 Maximum Timestep, dt [s]' ), title( 'Absolute Subtraction RK4 Maximum Timestep' )
surf( U1s_grid, U2s_grid, dts_grid, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Condition Numbers' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Condition Number [-]' ), title( 'Absolute Subtraction Condition Number' )
surf( U1s_grid, U2s_grid, condition_numbers_grid, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_condition_numbers' ] )


%% Simulate the Network.

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
    Us_achieved = zeros( n_applied_currents2, n_applied_currents1, num_subtraction_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k1 = 1:n_applied_currents1                          % Iterate through each of the currents applied to the first neuron...
        for k2 = 1:n_applied_currents2                      % Iterate through each of the currents applied to the second neuron...
            
            % Create applied currents.
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), Applied_Currents1( k2, k1 ), 'I_apps' );
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), Applied_Currents2( k2, k1 ), 'I_apps' );
%             network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), 20e-9, 'I_apps' );

            % Simulate the network.
            [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
            
            % Retrieve the final membrane voltages.
            Us_achieved( k2, k1, : ) = Us( :, end );
            
        end
    end

    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_subtraction_subnetwork_error' ], 'Applied_Currents1', 'Applied_Currents2', 'Us_achieved' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_subtraction_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    Applied_Currents1 = data.Applied_Currents1;
    Applied_Currents2 = data.Applied_Currents2;
    Us_achieved = data.Us_achieved;

end


%% Plot the Network Results.

% Compute the desired membrane voltage output.
% Us_desired_output =  Us_achieved( :, :, 1 ) - Us_achieved( :, :, 2 ) + Us_achieved( :, :, 3 );
Us_desired_output =  Us_achieved( :, :, 1 ) - Us_achieved( :, :, 2 );

% Compute the desired membrane voltage output.
Us_desired = Us_achieved; Us_desired( :, :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, :, end ) - Us_desired( :, :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Subnetwork Steady State Response (Desired)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Subtraction Subnetwork Steady State Response (Desired)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_ss_response_desired' ] )

% Create a surface that shows the achieved membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Subnetwork Steady State Response (Achieved)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Subtraction Subnetwork Steady State Response (Achieved)' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_ss_response_achieved' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Subnetwork Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Subtraction Subnetwork Steady State Response (Comparison)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'EdgeColor', 'None', 'FaceColor', 'b' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'EdgeColor', 'None', 'FaceColor', 'g' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'EdgeColor', 'None', 'FaceColor', 'r' )
legend( 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Absolute Subtraction Subnetwork Steady State Error' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Absolute Subtraction Subnetwork Steady State Error' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), error, 'EdgeColor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_subtraction_ss_response_error' ] )

