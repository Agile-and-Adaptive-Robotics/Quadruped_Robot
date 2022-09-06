%% Split Voltage Based Integration Subnetwork Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-4;
% network_tf = 3;
network_tf = 3.25;


%% Create an Integration Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Set the integration subnetwork properties.
T = 2;
n = 4;
% ki_mean = 0.01e9;
% ki_range = 0.01e9;
% ki_mean = 0.01e9;
% ki_range = 0.01e8;
ki_mean = 0.01e10;
ki_range = 0.01e9;
% k_sub = 1;
k_sub1 = 2;
k_sub2 = 1;
c_mod = 0.05;

% Create an integration subnetwork.
[ network, neuron_IDs, synapse_IDs, applied_current_IDs ] = network.create_mod_split_sub_vb_integration_subnetwork( T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod );


%% Setup Applied Currents.

% Define the input current time vector.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the applied current magnitudes.
Imag_low1 = 0e-9; Imag_middle1 = 10e-9; Imag_high1 = 20e-9;
Imag_low2 = 0e-9; Imag_middle2 = 10e-9; Imag_high2 = 20e-9;

% Define the applied current magnitude vectors.
% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.25 ) + Imag_middle1*( ts >= 0.25 & ts < 0.75 ) + Imag_high1*( ts >= 0.75 & ts < 1.25 ) + Imag_low1*( ts >= 1.25 & ts < 1.75 ) + Imag_low1*( ts >= 1.75 & ts < 2.25 ) + Imag_low1*( ts >= 2.25 & ts < 2.75 ) + Imag_low1*( ts >= 2.75 & ts < 3.25 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.25 ) + Imag_low2*( ts >= 0.25 & ts < 0.75 ) + Imag_low2*( ts >= 0.75 & ts < 1.25 ) + Imag_low2*( ts >= 1.25 & ts < 1.75 ) + Imag_middle2*( ts >= 1.75 & ts < 2.25 ) + Imag_high2*( ts >= 2.25 & ts < 2.75 ) + Imag_low2*( ts >= 2.75 & ts < 3.25 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.25 ) + Imag_high1*( ts >= 0.25 & ts < 0.75 ) + Imag_low1*( ts >= 0.75 & ts < 1.25 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.375 ) + Imag_high2*( ts >= 0.375 & ts < 0.875 ) + Imag_low2*( ts >= 0.875 & ts < 1.375 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.25 ) + Imag_high1*( ts >= 0.25 & ts < 0.75 ) + Imag_low1*( ts >= 0.75 & ts < 1.25 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.50 ) + Imag_high2*( ts >= 0.50 & ts < 1.00 ) + Imag_low2*( ts >= 1.00 & ts < 1.50 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.25 ) + Imag_high1*( ts >= 0.25 & ts < 1.25 ) + Imag_low1*( ts >= 1.25 & ts < 2.25 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.75 ) + Imag_high2*( ts >= 0.75 & ts < 1.75 ) + Imag_low2*( ts >= 1.75 & ts < 2.75 );

I_apps1 = Imag_low1*( ts >= 0 & ts < 0.75 ) + Imag_high1*( ts >= 0.75 & ts < 1.75 ) + Imag_low1*( ts >= 1.75 & ts < 2.75 );
I_apps2 = Imag_low2*( ts >= 0 & ts < 0.25 ) + Imag_high2*( ts >= 0.25 & ts < 1.25 ) + Imag_low2*( ts >= 1.25 & ts < 2.25 );



% Create the applied current inputs.
[ network.applied_current_manager, applied_current_IDs_in ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, { 'In 1', 'In 2' }, 'name' );
% network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs( ( end - 3 ):( end - 2 ) ), 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs( 1:2 ), 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 1 ), { I_apps1 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 2 ), { I_apps2 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, network.tf, 'tf' );


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 1:4, : ), hs( 1:4, : ), neuron_IDs( 1:4 ) );
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 5:8, : ), hs( 5:8, : ), neuron_IDs( 5:8 ) );
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 9:12, : ), hs( 9:12, : ), neuron_IDs( 9:12 ) );
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 13, : ), hs( 13, : ), neuron_IDs( 13 ) );
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 14:16, : ), hs( 14:16, : ), neuron_IDs( 14:16 ) );

% fig_network_states = network.network_utilities.plot_network_states( ts, Us( 1:4, : ), hs( 1:4, : ), neuron_IDs( 1:4 ) );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us( 5:8, : ), hs( 5:8, : ), neuron_IDs( 5:8 ) );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us( 9, : ), hs( 9, : ), neuron_IDs( 9 ) );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us( 10:12, : ), hs( 10:12, : ), neuron_IDs( 10:12 ) );
% fig_network_states = network.network_utilities.plot_network_states( ts, Us( 13:16, : ), hs( 13:16, : ), neuron_IDs( 13:16 ) );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

