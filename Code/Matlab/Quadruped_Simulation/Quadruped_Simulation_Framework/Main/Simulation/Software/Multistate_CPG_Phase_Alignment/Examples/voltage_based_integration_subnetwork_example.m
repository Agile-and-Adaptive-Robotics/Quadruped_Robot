%% Voltage Based Integration Subnetwork Testing

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
% network_dt = 1e-4;
% network_dt = 1e-5;
% network_dt = 1e-6;
% network_tf = 1;
network_tf = 3;


%% Create an Integration Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Set the integration subnetwork properties.
T = 2;
n = 4;
ki_mean = 0.01e9;
ki_range = 0.01e9;
% ki_mean = 0.001e9;
% ki_range = 0.001e9;

% Create an integration subnetwork.
[ network, neuron_IDs, synapse_IDs, applied_current_IDs ] = network.create_vb_integration_subnetwork( T, n, ki_mean, ki_range );

% Define the properties of the applied currents that are shared between both integration subnetwork neurons.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the properties of the applied current for the first integration subnetwork neuron.
% I_mag1 = 0e-9;
I_mag1 = 10e-9;
I_apps1 = I_mag1*( ts > 0.5 & ts < 0.75 );

% Define the properties of the applied current for the first integration subnetwork neuron.
% I_mag2 = 0e-9;
I_mag2 = 10e-9;
I_apps2 = I_mag2*( ts > 1.25 & ts < 1.5 );

% Create the applied current inputs.
[ network.applied_current_manager, applied_current_IDs_in ] = network.applied_current_manager.create_applied_currents( 2 );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, { 'In 1', 'In 2' }, 'name' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, neuron_IDs( 1:2 ), 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 1 ), { I_apps1 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in( 2 ), { I_apps2 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_in, network.tf, 'tf' );

% % Disable the integration subnetwork.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_int );


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

