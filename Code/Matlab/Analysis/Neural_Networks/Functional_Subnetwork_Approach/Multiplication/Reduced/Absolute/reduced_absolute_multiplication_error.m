%% Reduced Absolute Multiplication Subnetwork Error.

% Clear Everything.
clear, close('all'), clc


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
network_dt = 2e-4;                                                           	% [s] Simulation Timestep.
% network_dt = 1e-5;                                                              % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                                                 % [s] Simulation Duration.

% Define the number of neurons.
num_neurons = 4;                                                                % [#] Number of Neurons.


%% Define Basic Reduced Absolute Multiplication Subnetwork Parameters.

% Define neuron maximum membrane voltages.
R1 = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 1).
R2 = 20e-3;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 2).
R3_target = 20e-3;                                                                                              % [V] Maximum Membrane Voltage Target (Neuron 3).
R4_target = 20e-3;                                                                                              % [V] Maximum Membrane Voltage Target (Neuron 4).

% Define the membrane conductances.
Gm1 = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 2).
Gm3 = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 3).
Gm4 = 1e-6;                                                                                                     % [S] Membrane Conductance (Neuron 4).

% Define the membrane capacitances.
Cm1 = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 1).
Cm2 = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 2).
Cm3 = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 3).
Cm4 = 5e-9;                                                                                                     % [F] Membrance Conductance (Neuron 4).

% Define the sodium channel conductances.
Gna1 = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 2).
Gna3 = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 3).
Gna4 = 0;                                                                                                       % [S] Sodium Channel Conductance (Neuron 4).

% Define the synaptic reversal potential.
dEs32 = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 32).
dEs41 = 194e-3;                                                                                                 % [V] Synaptic Reversal Potential (Synapse 41).
dEs43 = 0;                                                                                                      % [V] Synaptic Reversal Potential (Synapse 43).

% Define the applied currents.
Ia1 = R1*Gm1;                                                                                                   % [A] Applied Current (Neuron 1).
Ia2 = R2*Gm2;                                                                                                   % [A] Applied Current (Neuron 2).
Ia3 = R3_target*Gm3;                                                                                         	% [A] Applied Current (Neuron 3).
Ia4 = 0;                                                                                                        % [A] Applied Current (Neuron 4).

% Define the input current states.
% current_state1 = 0;                                                                                             % [%] Applied Current Activity Percentage (Neuron 1). 
current_state1 = 1;                                                                                           % [%] Applied Current Activity Percentage (Neuron 1). 
% current_state2 = 0;                                                                                           % [%] Applied Current Activity Percentage (Neuron 2). 
current_state2 = 1;                                                                                             % [%] Applied Current Activity Percentage (Neuron 2). 

% Define the subnetwork voltage offsets.
delta1 = 1e-3;                                                                                                  % [V] Inversion Membrane Voltage Offset.
delta2 = 2e-3;                                                                                                  % [V] Division Membrane Voltage Offset.

% Define subnetwork design constants.
c1 = ( delta1*R2*R3_target )/( R3_target - delta1 );                                                            % [V^2] Reduced Absolute Multiplication Design Parameter 1 (Reduced Absolute Inversion Design Parameter 1).
c3 = ( ( delta1 - R3_target )*delta2*R4_target )/( ( delta2 - R4_target )*R1 );                                 % [V] Reduced Absolute Multiplication Design Parameter 3 (Reduced Absolute Division Design Parameter 1)


%% Compute Derived Reduced Absolute Mutliplication Subnetwork Constraints.

% Compute the network design parameters.
c2 = ( c1 - delta1*R1 )/delta1;                                                                                 % [V] Design Constant 2.
c4 = ( R1*c3 - delta2*R3_target )/( delta2 );                                                                	% [A] Absolute Division Parameter 2.

% Compute the maximum membrane voltages.
R3 = c1/c2;                                                                                                     % [V] Maximum Membrane Voltage (Neuron 2).
R4 = ( R1*c3 )/( delta1 + c4 );                                                                                 % [V] Maximum Membrane Voltage (Neuron 3).

% Compute the synaptic conductances.
gs32 = ( R2*Ia3 )/( c1 - c2*dEs32 );                                                                            % [S] Synaptic Conductance (Synapse 21)
gs41 = ( ( delta1 - R3 )*delta2*R4*Gm4 )/( ( R3 - delta1 )*delta2*R4 + ( R4*delta1 - R3*delta2 )*dEs41 );       % [S] Maximum Synaptic Conductance (Synapse 41).
gs43 = ( ( delta2 - R4 )*dEs41*R3*Gm4 )/( ( R3 - delta1 )*delta2*R4 + ( R4*delta1 - R3*delta2 )*dEs41 );        % [S] Maximum Synaptic Conductance (Synapse 32).


%% Print Reduced Absolute Multiplication Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED ABSOLUTE MULTIPLICATION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2*( 10^3 ) )
fprintf( 'R3 \t\t= \t%0.2f \t[mV]\n', R3*( 10^3 ) )
fprintf( 'R4 \t\t= \t%0.2f \t[mV]\n', R4*( 10^3 ) )
fprintf( '\n' )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2*( 10^6 ) )
fprintf( 'Gm3 \t= \t%0.2f \t[muS]\n', Gm3*( 10^6 ) )
fprintf( 'Gm4 \t= \t%0.2f \t[muS]\n', Gm4*( 10^6 ) )
fprintf( '\n' )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2*( 10^9 ) )
fprintf( 'Cm3 \t= \t%0.2f \t[nF]\n', Cm3*( 10^9 ) )
fprintf( 'Cm4 \t= \t%0.2f \t[nF]\n', Cm4*( 10^9 ) )
fprintf( '\n' )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2*( 10^6 ) )
fprintf( 'Gna3 \t= \t%0.2f \t[muS]\n', Gna3*( 10^6 ) )
fprintf( 'Gna4 \t= \t%0.2f \t[muS]\n', Gna4*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs32 \t= \t%0.2f \t[mV]\n', dEs32*( 10^3 ) )
fprintf( 'dEs41 \t= \t%0.2f \t[mV]\n', dEs41*( 10^3 ) )
fprintf( 'dEs43 \t= \t%0.2f \t[mV]\n', dEs43*( 10^3 ) )
fprintf( '\n' )

fprintf( 'gs32 \t= \t%0.2f \t[muS]\n', gs32*( 10^6 ) )
fprintf( 'gs41 \t= \t%0.2f \t[muS]\n', gs41*( 10^6 ) )
fprintf( 'gs43 \t= \t%0.2f \t[muS]\n', gs43*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', Ia1*( 10^9 ) )
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2*( 10^9 ) )
fprintf( 'Ia3 \t= \t%0.2f \t[nA]\n', Ia3*( 10^9 ) )
fprintf( 'Ia4 \t= \t%0.2f \t[nA]\n', Ia4*( 10^9 ) )
fprintf( '\n' )

fprintf( 'p1 \t\t= \t%0.0f \t\t[-]\n', current_state1 )
fprintf( 'p2 \t\t= \t%0.0f \t\t[-]\n', current_state2 )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2f \t[mV^2]\n', c1*( 10^6 ) )
fprintf( 'c2 \t\t= \t%0.2f \t[mV]\n', c2*( 10^3 ) )
fprintf( 'c3 \t\t= \t%0.2f \t[mV]\n', c3*( 10^3 ) )
fprintf( 'c4 \t\t= \t%0.2f \t[mV]\n', c4*( 10^3 ) )
fprintf( '\n' )

fprintf( 'delta1 \t= \t%0.2f \t[mV]\n', delta1*( 10^3 ) )
fprintf( 'delta2 \t= \t%0.2f \t[mV]\n', delta2*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create a Reduced Absolute Multiplication Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 4 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 3 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 4 );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3, R4 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2, Gm3, Gm4 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2, Cm3, Cm4 ], 'Cm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gna1, Gna2, Gna3, Gna4 ], 'Gna' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 2, 1, 3 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 3, 4, 4 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs32, gs41, gs43 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs32, dEs41, dEs43 ], 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3, 4 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_state1*Ia1, current_state2*Ia2, Ia3, Ia4 ], 'I_apps' );


%% Compute Desired & Achieved Reduced Multiplication Formulations.

% Retrieve the maximum membrane voltages.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );                      % [V] Maximum Membrane Voltages.

% Retrieve the membrane capacitances.
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );                    % [F] Membrane Capacitances.

% Retrieve the membrane conductances.
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );                    % [S] Membrane Conductances.

% Retrieve the applied currents.
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );               % [A] Applied Currents.

% Retrieve the synaptic conductances.
gs = network.get_gsynmaxs( 'all' );                                                             % [S] Synaptic Conductances.

% Retrieve the synaptic reversal potentials.
dEs = network.get_dEsyns( 'all' );                                                              % [V] Synaptic Reversal Potential.

% Define the numerical stability timestep.
dt0 = 1e-6;                                                                                     % [s] Numerical Stability Time Step.

% Define the multiplication subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute multiplication steady state output.
[ U4s_flat_desired_absolute, U3s_flat_desired_absolute ] = network.compute_desired_red_abs_mult_ss_output( [ U1s_flat, U2s_flat ], c1, c2, c3, c4 );
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


%% Print the Desired Absolute, Desired Relative, and Achieved Reduced Multiplication Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ ( %0.2f [mV], %0.2f [mV] )\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ), U2s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ ( %0.2f [mV], %0.2f [mV] )\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ), U2s_flat( indexes_condition_number )*( 10^3 ) )


%% Plot the Desired Absolute, Desired Relative, and Achieved Reduced Multiplication Formulation Results.

% Plot the desired and achieved absolute inversion formulation results.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Inversion Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Reduced Absolute Inversion Theory' )
surf( U1s_grid, U2s_grid, U3s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_inversion_theory' ] )

% Plot the desired and achieved absolute division formulation results.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Division Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Reduced Absolute Division Theory' )
surf( U1s_grid, U3s_grid_desired_absolute, U4s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U3s_grid_achieved_absolute, U4s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_division_theory' ] )

% Plot the desired and achieved absolute multiplication formulation results.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Theory' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Reduced Absolute Multiplication Theory' )
surf( U1s_grid, U2s_grid, U4s_grid_desired_absolute, 'Facecolor', 'b', 'Edgecolor', 'None' )
surf( U1s_grid, U2s_grid, U4s_grid_achieved_absolute, 'Facecolor', 'r', 'Edgecolor', 'None' )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_theory' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication RK4 Maximum Timestep' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Rk4 Maximum Timestep, dt [s]' ), title( 'Reduced Absolute Multiplication RK4 Maximum Timestep' )
surf( U1s_grid, U2s_grid, dts_grid, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Condition Numbers' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Condition Number [-]' ), title( 'Reduced Absolute Multiplication Condition Number' )
surf( U1s_grid, U2s_grid, condition_numbers_grid, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'absolute_multiplication_condition_numbers' ] )


%% Simulate the Reduced Absolute Multiplication Subnetwork.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents1 = 10;                                                                               % [#] Number of Applied Currents (Neuron 1).
    n_applied_currents2 = 10;                                                                               % [#] Number of Applied Currents (Neuron 2).
    
    % Create the applied currents.
    applied_currents1 = linspace( 0, R1*network.neuron_manager.neurons( 1 ).Gm, n_applied_currents1 );      % [A] Applied Currents (Neuron 1).
    applied_currents2 = linspace( 0, R2*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents2 );      % [A] Applied Currents (Neuron 2).
    
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
    save( [ save_directory, '\', 'reduced_absolute_multiplication_error' ], 'Applied_Currents1', 'Applied_Currents2', 'Us_achieved' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'reduced_absolute_multiplication_error' ] );
    
    % Store the simulation results in separate variables.
    Applied_Currents1 = data.Applied_Currents1;
    Applied_Currents2 = data.Applied_Currents2;
    Us_achieved = data.Us_achieved;

end


%% Compute the Reduced Absolute Multiplication Subnetwork Error.

% Compute the desired membrane voltage output.
% Us_desired_output =  ( c2*c4*Us_achieved( :, :, 1 ).*Us_achieved( :, :, 2 ) + c3*c4*Us_achieved( :, :, 1 ) )./( c2*c6*Us_achieved( :, :, 2 ) + c1*c5 + c3*c6 );
Us_desired_output =  ( c3*Us_achieved( :, :, 1 ).*Us_achieved( :, :, 2 ) + c2*c3*Us_achieved( :, :, 1 ) )./( c4*Us_achieved( :, :, 2 ) + c2*c4 + c1 );

% Compute the desired membrane voltage output.
Us_desired = Us_achieved; Us_desired( :, :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, :, end ) - Us_desired( :, :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );


%% Plot the Reduced Absolute Multiplication Subnetwork Results.

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Steady State Response (Desired)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Reduced Absolute Multiplication Steady State Response (Desired)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_ss_response_desired' ] )

% Create a surface that shows the achieved membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Steady State Response (Achieved)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Reduced Absolute Multiplication Steady State Response (Achieved)' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_ss_response_achieved' ] )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Reduced Absolute Multiplication Steady State Response (Comparison)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( U1s_grid, U2s_grid, U4s_grid_achieved_absolute, 'Edgecolor', 'None', 'Facecolor', 'g' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Reduced Absolute Multiplication Steady State Error' ); hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Reduced Absolute Multiplication Steady State Error' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), error, 'Edgecolor', 'None' )
saveas( fig, [ save_directory, '\', 'reduced_absolute_multiplication_ss_response_error' ] )

