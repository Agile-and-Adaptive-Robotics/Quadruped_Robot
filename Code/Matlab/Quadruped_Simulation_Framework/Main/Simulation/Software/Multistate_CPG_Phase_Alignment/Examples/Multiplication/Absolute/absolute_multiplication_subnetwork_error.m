%% Absolute Multiplication Subnetwork Error

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

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 5e-4;
% network_dt = 1e-4;
% network_dt = 1e-5;
network_tf = 3;

% Set the necessary parameters.
R1 = 20e-3;                                 % [V] Activation Domain
R2 = 20e-3;                                 % [V] Activation Domain
c1 = 8.00e-12;                              % [W] Absolute Inversion Parameter 1
c3 = 0.40e-9;                               % [A] Absolute Inversion Parameter 3
% c6 = 0.40e-9;                               % [W] Absolute Division Parameter 3 
c6 = 0.070175438596491236e-09;                               % [W] Absolute Division Parameter 3 R4 = 30e-3
% c6 = 0.12631578947368420e-9;                               % [W] Absolute Division Parameter 3 R4 = 25e-3
% c6 = 0.19047619047619049e-9;                               % [W] Absolute Division Parameter 3 R4 = 21e-3
% c6 = 0.21052631578947373e-9;                               % [W] Absolute Division Parameter 3 R4 = 20e-3
% c6 = 40.040040040040048e-9;                               % [W] Absolute Division Parameter 3
% c6 = -0.18947368421052636e-9;                               % [W] Absolute Division Parameter 3 
delta1 = 1e-3;                              % [V] Inversion Offset Voltage
delta2 = 2e-3;                              % [V] Division Offset Voltage
dEs41 = 194e-3;                             % [V] Synaptic Reversal Potential

% Set the number of multiplication neurons.
num_multiplication_neurons = 4;


%% Create Absolute Multiplication Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Compute the network properties.
R3 = c1/c3;
R4 = ( c1*c3*R1*delta2 )/( ( c3^2 )*R1*delta1 + c1*c6*delta2 - c3*c6*delta1*delta2 );

c2 = ( c1 - delta1*c3 )/( delta1*R2 );
c4 = c3;
c5 = ( ( c3*R1 - c6*delta2 )*c3 )/( delta2*c1 );

Iapp3 = c1/R2;
Iapp4 = 0;

Gm3 = c3/R2;
Gm4 = ( c3*c6 )/( R1*c1 );

% Gm3 = 1e-6;
% Gm4 = 0.1e-6;

dEs32 = 0;
dEs43 = 0;

gs32 = ( c1 - delta1*c3 )/( delta1*R2 );
gs41 = ( ( c3^2 )*c6 )/( ( dEs41*c6 - R1*c3 )*c1 );
gs43 = ( ( delta2*c6 - R1*c3 )*dEs41*c3*c6 )/( ( R1*c3 - dEs41*c6 )*R1*c1*delta2 );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 4 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 3 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 4 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3, R4 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( [ neuron_IDs( 3 ), neuron_IDs( 4 ) ], [ Gm3, Gm4 ], 'Gm' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2, 3 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 4, 3, 4 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs41, gs32, gs43 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs41, dEs32, dEs43 ], 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3, 4 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3:4 ), [ Iapp3, Iapp4 ], 'I_apps' );


%% Compute Desired & Achieved Multiplication Formulations.

% Retrieve network information.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );
Ias = [ 0, 0, Iapp3, Iapp4 ];
gs = network.get_gsynmaxs( 'all' );
dEs = network.get_dEsyns( 'all' );
dt0 = 1e-6;

% Define the multiplication subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute multiplication steady state output.
[ U4s_flat_desired_absolute, U3s_flat_desired_absolute ] = network.compute_desired_absolute_multiplication_steady_state_output( [ U1s_flat, U2s_flat ], c1, c2, c3, c4, c5, c6 );
[ U4s_flat_achieved_absolute, U3s_flat_achieved_absolute, As, dts, condition_numbers ] = network.achieved_multiplication_RK4_stability_analysis( U1s_flat, U2s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts, size( U1s_grid ) );
condition_numbers_grid = reshape( condition_numbers, size( U1s_grid ) );

U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid ) );
U3s_grid_achieved_absolute = reshape( U3s_flat_achieved_absolute, size( U1s_grid ) );

U4s_grid_desired_absolute = reshape( U4s_flat_desired_absolute, size( U1s_grid ) );
U4s_grid_achieved_absolute = reshape( U4s_flat_achieved_absolute, size( U1s_grid ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = min( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );

% Print a summary of the relevant network parameters.
fprintf( 'NETWORK PARAMETERS:\n' )

fprintf( 'R1 = %0.2f [mV]\n', Rs( 1 )*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', Rs( 2 )*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', Rs( 3 )*( 10^3 ) )
fprintf( 'R4 = %0.2f [mV]\n', Rs( 4 )*( 10^3 ) )

fprintf( 'c1 = %0.2e [-]\n', c1 )
fprintf( 'c2 = %0.2e [-]\n', c2 )
fprintf( 'c3 = %0.2e [-]\n', c3 )
fprintf( 'c4 = %0.2e [-]\n', c4 )
fprintf( 'c5 = %0.2e [-]\n', c5 )
fprintf( 'c6 = %0.2e [-]\n', c6 )

fprintf( 'dEs41 = %0.2f [mV]\n', dEs( 4, 1 )*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs( 3, 2 )*( 10^3 ) )
fprintf( 'dEs43 = %0.2f [mV]\n', dEs( 4, 3 )*( 10^3 ) )

fprintf( 'gs41 = %0.2f [muS]\n', gs( 4, 1 )*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs( 3, 2 )*( 10^6 ) )
fprintf( 'gs43 = %0.2f [muS]\n', gs( 4, 3 )*( 10^6 ) )

fprintf( 'Gm3 = %0.2f [muS]\n', Gms( 3 )*( 10^6 ) )
fprintf( 'Gm4 = %0.2f [muS]\n', Gms( 4 )*( 10^6 ) )

fprintf( 'Ia3 = %0.2f [nA]\n', Ias( 3 )*( 10^9 ) )
fprintf( 'Ia4 = %0.2f [nA]\n', Ias( 4 )*( 10^9 ) )

fprintf( '\n\n' )


%% Print the Desired Absolute, Desired Relative, and Achieved Multiplication Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ ( %0.2f [mV], %0.2f [mV] )\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ), U2s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ ( %0.2f [mV], %0.2f [mV] )\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ), U2s_flat( indexes_condition_number )*( 10^3 ) )


%% Plot the Desired Absolute, Desired Relative, and Achieved Multiplication Formulation Results.

% Plot the desired and achieved absolute inversion formulation results.
fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Inversion Theory' )
surf( U1s_grid, U2s_grid, U3s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'absolute_inversion_theory' ] )

% Plot the desired and achieved absolute division formulation results.
fig = figure( 'Color', 'w', 'Name', 'Absolute Division Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Division Theory' )
surf( U1s_grid, U3s_grid_desired_absolute, U4s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U3s_grid_achieved_absolute, U4s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'absolute_division_theory' ] )

% Plot the desired and achieved absolute multiplication formulation results.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Multiplication Theory' )
surf( U1s_grid, U2s_grid, U4s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U2s_grid, U4s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_theory' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication RK4 Maximum Timestep' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Rk4 Maximum Timestep, dt [s]' ), title( 'Absolute Multiplication RK4 Maximum Timestep' )
surf( U1s_grid, U2s_grid, dts_grid, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Condition Numbers' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Condition Number [-]' ), title( 'Absolute Multiplication Condition Number' )
surf( U1s_grid, U2s_grid, condition_numbers_grid, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_condition_numbers' ] )


%% Simulate the Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents1 = 10;
    n_applied_currents2 = 10;
    
    % Create the applied currents.
    applied_currents1 = linspace( 0, R1*network.neuron_manager.neurons( 1 ).Gm, n_applied_currents1 );
    applied_currents2 = linspace( 0, R2*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents2 );
    
    % Create a grid of the applied currents.
    [ Applied_Currents1, Applied_Currents2 ] = meshgrid( applied_currents1, applied_currents2 );
    
    % Create a matrix to store the membrane voltages.
    Us_achieved = zeros( n_applied_currents2, n_applied_currents1, num_multiplication_neurons );
    
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
    save( [ save_directory, '\', 'absolute_multiplication_subnetwork_error' ], 'Applied_Currents1', 'Applied_Currents2', 'Us_achieved' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_multiplication_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    Applied_Currents1 = data.Applied_Currents1;
    Applied_Currents2 = data.Applied_Currents2;
    Us_achieved = data.Us_achieved;

end


%% Plot the Network Results.

% Compute the desired membrane voltage output.
Us_desired_output =  ( c2*c4*Us_achieved( :, :, 1 ).*Us_achieved( :, :, 2 ) + c3*c4*Us_achieved( :, :, 1 ) )./( c2*c6*Us_achieved( :, :, 2 ) + c1*c5 + c3*c6 );

% Compute the desired membrane voltage output.
Us_desired = Us_achieved; Us_desired( :, :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, :, end ) - Us_desired( :, :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Subnetwork Steady State Response (Desired)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Multiplication Subnetwork Steady State Response (Desired)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_ss_response_desired' ] )

% Create a surface that shows the achieved membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Subnetwork Steady State Response (Achieved)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Multiplication Subnetwork Steady State Response (Achieved)' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_ss_response_achieved' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Subnetwork Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Multiplication Subnetwork Steady State Response (Comparison)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( U1s_grid, U2s_grid, U4s_grid_achieved_absolute, 'Edgecolor', 'None', 'Facecolor', 'g' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Absolute Multiplication Subnetwork Steady State Error' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Absolute Multiplication Subnetwork Steady State Error' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), error, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_ss_response_error' ] )

