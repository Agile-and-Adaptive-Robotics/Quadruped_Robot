%% Absolute Addition Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1.0e-2;
network_dt = 1e-3;
network_tf = 3;


%% Create Absolute Addition Subnetwork.

% Define the network parameters.
num_addition_neurons = 3;
c = 1;

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create an addition subnetwork.
[ network, neuron_IDs_add, synapse_IDs_add, applied_current_IDs_add ] = network.create_absolute_addition_subnetwork( num_addition_neurons, c );

% Create applied currents.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add(1), 16e-9, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add(2), 4e-9, 'I_apps' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_add, neuron_IDs_add(1:2), 'neuron_ID' );

% % Disable the addition subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_add );


%% Numerical Stability Analysis.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network.RK4_stability_analysis( cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) ), network.get_gsynmaxs( 'all' ), network.get_dEsyns( 'all' ), zeros( network.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Compute Desired Absolute, Desired Relative, and Achieved Addition Formulations.

% Retrieve network information.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );
gs = network.get_gsynmaxs( 'all' );
dEs = network.get_dEsyns( 'all' );

% Define the addition subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

% Compute the desired and achieved absolute addition steady state output.
U3s_flat_desired_absolute = network.compute_desired_absolute_addition_steady_state_output( [ U1s_flat, U2s_flat ], c );
U3s_flat_achieved_absolute = network.compute_achieved_addition_steady_state_output( [ U1s_flat, U2s_flat ], Rs, Gms, Ias, gs, dEs );

% Convert the flat steady state output results to grids.
U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid ) );
U3s_grid_achieved_absolute = reshape( U3s_flat_achieved_absolute, size( U1s_grid ) );


%% Plot the Desired Absolute, Desired Relative, and Achieved Addition Formulations.

% Plot the desired absolute addition formulation results.
figure( 'color', 'w', 'name', 'Absolute Addition Theory' ), hold on, grid on, rotate3d on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U3 [mV]' ), title( 'Absolute Addition Theory' )
surf( U1s_grid, U2s_grid, U3s_grid_desired_absolute, 'facecolor', 'b', 'edgecolor', 'none' )
surf( U1s_grid, U2s_grid, U3s_grid_achieved_absolute, 'facecolor', 'r', 'edgecolor', 'none' )
legend( 'Desired', 'Achieved' )


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

