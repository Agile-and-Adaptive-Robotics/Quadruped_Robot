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

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;

% Set the subtraction subnetwork properties.
num_subtraction_neurons = 4;
c = 1;
npm_k = [ 2, 1 ];
s_ks = [ 1, -1, 1 ];


%% Create Absolute Subtraction Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create a subtraction subnetwork.
[ network, neuron_IDs, synapse_IDs, applied_current_IDs ] = network.create_relative_subtraction_subnetwork( num_subtraction_neurons, c, npm_k, s_ks );


%% Simulate the Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents1 = 10;
    n_applied_currents2 = 10;
    
    % Create the applied currents.
    applied_currents1 = linspace( 0, 20e-9, n_applied_currents1 );
    applied_currents2 = linspace( 0, 20e-9, n_applied_currents2 );
    
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
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 3 ), 20e-9, 'I_apps' );

            % Simulate the network.
            [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
            
            % Retrieve the final membrane voltages.
            Us_achieved( k2, k1, : ) = Us( :, end );
            
        end
    end

    % Save the simulation results.
    save( [ save_directory, '\', 'relative_subtraction_subnetwork_error' ], 'Applied_Currents1', 'Applied_Currents2', 'Us_achieved' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'relative_subtraction_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    Applied_Currents1 = data.Applied_Currents1;
    Applied_Currents2 = data.Applied_Currents2;
    Us_achieved = data.Us_achieved;

end


%% Plot the Network Results.

% Get the activation domains of the neurons.
R1 = network.neuron_manager.get_neuron_property( 1, 'R' ); R1 = R1{ 1 };
R2 = network.neuron_manager.get_neuron_property( 2, 'R' ); R2 = R2{ 1 };
R3 = network.neuron_manager.get_neuron_property( 3, 'R' ); R3 = R3{ 1 };
R4 = network.neuron_manager.get_neuron_property( 4, 'R' ); R4 = R4{ 1 };

% Compute the desired membrane voltage output.
Us_desired_output = c*R4*( ( 1/npm_k( 1 ) )*( Us_achieved( :, :, 1 )/R1 + Us_achieved( :, :, 3 )/R3 ) - ( 1/npm_k( 2 ) )*( Us_achieved( :, :, 2 )/R2 ) );

% Store the desired membrane voltage in a matrix.
Us_desired = Us_achieved; Us_desired( :, :, end ) = Us_desired_output;

% Compute the error between the achieved and desired results.
error = Us_achieved( :, :, end ) - Us_desired( :, :, end );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error.^2, 'all' ) );

% Create a surface that shows the desired membrane voltage output.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Relative Subtraction Subnetwork Steady State Response (Desired)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None' )

% Create a surface that shows the achieved membrane voltage output.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Relative Subtraction Subnetwork Steady State Response (Achieved)' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None' )

% Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Relative Subtraction Subnetwork Steady State Response (Comparison)' )
surf( Us_desired( :, :, 1 ), Us_desired( :, :, 2 ), Us_desired( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'b' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), Us_achieved( :, :, end ), 'Edgecolor', 'None', 'Facecolor', 'r' )
legend( 'Desired', 'Achieved' )

% Create a surface that shows the membrane voltage error.
figure( 'color', 'w' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Relative Subtraction Subnetwork Steady State Error' )
surf( Us_achieved( :, :, 1 ), Us_achieved( :, :, 2 ), error, 'Edgecolor', 'None' )


