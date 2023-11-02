%% Relative Inversion Subnetwork Error

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
network_dt = 1e-4;
% network_dt = 1e-5;
network_tf = 3;

% Define the number of neurons.
num_neurons = 2;

% Set the network parameters.
R1 = 20e-3;                                         % [V] Activation Domain 1
R2 = 20e-3;                                         % [V] Activation Domain 2
% R2 = 10e-3;                                         % [V] Activation Domain 2
c3 = 1e-6;                                          % [S] Relative Inversion Parameter 3
delta = 1e-3;                                       % [V] Minimum Output Membrane Voltage

% R1 = 20e-3;
% R2 = 20e-3;
% c3 = 20e-9;
% delta = 1e-3;


%% Create Relative Subtraction Subnetwork.

% Compute the network properties.
c1 = c3;                                            % [S] Relative Inversion Parameter 1
c2 = ( ( R2 - delta )*c3 )/( delta );               % [S] Relative Inversion Parameter 2
% Gm2 = c3;                                           % [S] Membrane Conductance
Gm2 = 1e-6;                                           % [S] Membrane Conductance
Iapp2 = R2*c3;                                      % [A] Applied Current
dEs21 = 0;                                          % [V] Synaptic Reversal Potential
gs21 = ( ( R2 - delta )*c3 )/( delta );             % [S] Maximum Synaptic Conductance

% Print a summary of the relevant network parameters.
fprintf( 'RELATIVE INVERSION SUBNETWORK PARAMETERS:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2*( 10^3 ) )
fprintf( 'c1 = %0.2f [muS]\n', c1*( 10^6 ) )
fprintf( 'c2 = %0.2f [muS]\n', c2*( 10^6 ) )
fprintf( 'c3 = %0.2f [muS]\n', c3*( 10^6 ) )
fprintf( 'delta = %0.2f [mV]\n', delta*( 10^3 ) )
fprintf( 'dEs21 = %0.2f [mV]\n', dEs21*( 10^3 ) )
fprintf( 'gs21 = %0.2f [muS]\n', gs21*( 10^6 ) )
fprintf( 'Gm2 = %0.2f [muS]\n', Gm2*( 10^6 ) )
fprintf( 'Iapp2 = %0.2f [nA]\n', Iapp2*( 10^9 ) )

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 2 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 1 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 2 );

% Set the network parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), 0, 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 1 ), R1, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), R2, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs( 2 ), Gm2, 'Gm' );

network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), 2, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), gs21, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs( 1 ), dEs21, 'dE_syn' );

network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1, 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), 2, 'neuron_ID' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 0*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), 1*network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 2 ), Iapp2, 'I_apps' );


%% Compute Desired & Achieved Inversion Formulations.

% Retrieve network information.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );
% Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );
Ias = [ 0, Iapp2 ];
gs = network.get_gsynmaxs( 'all' );
dEs = network.get_dEsyns( 'all' );
dt0 = 1e-6;

% Define the inversion subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 100  );

% Create the input points.
U1s_flat = reshape( U1s, [ numel( U1s ), 1 ] );

% Compute the desired and achieved relative inversion steady state output.
U2s_flat_desired_relative = network.compute_desired_relative_inversion_steady_state_output( U1s_flat, c1, c2, c3, R1, R2 );
[ U2s_flat_achieved_relative, As, dts, condition_numbers ] = network.achieved_inversion_RK4_stability_analysis( U1s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = max( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Desired and Achieved Inversion Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ %0.2f [mV]\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ %0.2f [mV]\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ) )


%% Plot the Desired and Achieved Inversion Formulation Results.

% Plot the desired and achieved relative inversion formulation results.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Theory' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Output), U2 [mV]' ), title( 'Relative Inversion Theory' )
plot( U1s_flat, U2s_flat_desired_relative, '-', 'Linewidth', 3 )
plot( U1s_flat, U2s_flat_achieved_relative, '--', 'Linewidth', 3 )
legend( 'Desired', 'Achieved' )
saveas( fig, [ save_directory, '\', 'relative_inversion_theory' ] )

% Plot the RK4 maximum timestep.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion RK4 Maximum Timestep' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'Relative Inversion RK4 Maximum Timestep' )
plot( U1s_flat, dts, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_inversion_rk4_maximum_timestep' ] )

% Plot the linearized system condition numbers.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Condition Numbers' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Condition Number [-]' ), title( 'Relative Inversion Condition Number' )
plot( U1s_flat, condition_numbers, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_inversion_condition_numbers' ] )


%% Simulate the Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents = 20;
    
    % Create the applied currents.
%     applied_currents = linspace( 0, network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents );
    applied_currents = linspace( 0, network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, n_applied_currents );

    % Create a matrix to store the membrane voltages.
    Us_achieved = zeros( n_applied_currents, num_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k = 1:n_applied_currents                          % Iterate through each of the currents applied to the input neuron...
            
            % Create applied currents.
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), applied_currents( k ), 'I_apps' );

            % Simulate the network.
            [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
            
            % Retrieve the final membrane voltages.
            Us_achieved( k, : ) = Us( :, end );
            
    end

    % Save the simulation results.
    save( [ save_directory, '\', 'relative_inversion_subnetwork_error' ], 'applied_currents', 'Us_achieved' )
    
else                % Otherwise... ( We must want to load data from an existing simulation... )
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'relative_inversion_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    applied_currents = data.applied_currents;
    Us_achieved = data.Us_achieved;

end


%% Plot the Network Results.

% Compute the desired membrane voltage output.
Us_desired_output =  c1*R1*R2./( c2*Us_achieved( :, 1 ) + c3*R1 );

% Compute the desired membrane voltage output.
Us_desired = Us_achieved; Us_desired( :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, end ) - Us_desired( :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );

% Create a plot of the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Subnetwork Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response (Desired)' )
plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_inversion_ss_response_desired' ] )

% Create a plot of the achieved membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Subnetwork Steady State Response (Achieved)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response (Achieved)' )
plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_inversion_ss_response_achieved' ] )

% Create a plot of the desired and achieved membrane voltage outputs.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Subnetwork Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response (Comparison)' )
h1 = plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 );
h2 = plot( U1s_flat, U2s_flat_achieved_relative, '-', 'Linewidth', 3 );
h3 = plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '-', 'Linewidth', 3 );
legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best' )
saveas( fig, [ save_directory, '\', 'relative_inversion_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Relative Inversion Subnetwork Steady State Error' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Error' )
plot( Us_achieved( :, 1 ), error, '-', 'Linewidth', 3 )
saveas( fig, [ save_directory, '\', 'relative_inversion_ss_response_error' ] )

