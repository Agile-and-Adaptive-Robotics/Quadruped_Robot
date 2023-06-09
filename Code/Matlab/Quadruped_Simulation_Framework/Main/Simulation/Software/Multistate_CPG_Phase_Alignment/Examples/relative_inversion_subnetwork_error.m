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
<<<<<<< Updated upstream
R1 = 20e-3;
R2 = 20e-3;
c3 = 1e-6;
delta = 1e-3;
=======
R1 = 20e-3;                                         % [V] Activation Domain 1
R2 = 20e-3;                                         % [V] Activation Domain 2
c3 = 1e-6;                                          % [S] Relative Inversion Parameter 3
delta = 1e-3;                                       % [V] Minimum Output Membrane Voltage
>>>>>>> Stashed changes

% R1 = 20e-3;
% R2 = 20e-3;
% c3 = 20e-9;
% delta = 1e-3;


%% Create Relative Subtraction Subnetwork.

% Compute the network properties.
<<<<<<< Updated upstream
c1 = c3;
c2 = ( ( R2 - delta )*c3 )/( delta );
Gm2 = c3;
Iapp2 = R2*c3;
dEs21 = 0;
gs21 = ( ( R2 - delta )*c3 )/( delta );

% Print a summary of the relevant network parameters.
fprintf( 'NETWORK PARAMETERS:\n' )
=======
c1 = c3;                                            % [S] Relative Inversion Parameter 1
c2 = ( ( R2 - delta )*c3 )/( delta );               % [S] Relative Inversion Parameter 2
Gm2 = c3;                                           % [S] Membrane Conductance
Iapp2 = R2*c3;                                      % [A] Applied Current
dEs21 = 0;                                          % [V] Synaptic Reversal Potential
gs21 = ( ( R2 - delta )*c3 )/( delta );             % [S] Maximum Synaptic Conductance

% Print a summary of the relevant network parameters.
fprintf( 'RELATIVE INVERSION SUBNETWORK PARAMETERS:\n' )
>>>>>>> Stashed changes
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


%% Simulate the Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents to use.
    n_applied_currents = 20;
    
    % Create the applied currents.
    applied_currents = linspace( 0, network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents );
        
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
figure( 'color', 'w' ), hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response (Desired)' )
plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 )

% Create a plot of the achieved membrane voltage output.
figure( 'color', 'w' ), hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response (Achieved)' )
plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '-', 'Linewidth', 3 )

% Create a plot of the desired and achieved membrane voltage outputs.
figure( 'color', 'w' ), hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Response' )
h1 = plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 );
h2 = plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '-', 'Linewidth', 3 );
legend( [ h1, h2 ], { 'Desired', 'Achieved' }, 'Location', 'Best' )

% Create a surface that shows the membrane voltage error.
figure( 'color', 'w' ), hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Relative Inversion Subnetwork Steady State Error' )
plot( Us_achieved( :, 1 ), error, '-', 'Linewidth', 3 )


