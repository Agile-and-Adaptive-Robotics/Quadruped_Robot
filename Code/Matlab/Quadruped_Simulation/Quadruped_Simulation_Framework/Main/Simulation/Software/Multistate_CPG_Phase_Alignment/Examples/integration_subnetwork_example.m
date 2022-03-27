%% Integration Subnetwork Testing

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
ki_mean = 0.01e9;
ki_range = 0.01e9;

% Create an integration subnetwork.
[ network, neuron_IDs_int, synapse_IDs_int, applied_current_IDs_int ] = network.create_integration_subnetwork( ki_mean, ki_range );

% Define the properties of the applied currents that are shared between both integration subnetwork neurons.
Gm = cell2mat( network.neuron_manager.get_neuron_property( neuron_IDs_int( 1 ), 'Gm' ) );
R = cell2mat( network.neuron_manager.get_neuron_property( neuron_IDs_int( 1 ), 'R' ) );
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the properties of the applied current for the first integration subnetwork neuron.
% I_mag_constant1 = 0e-9;
% I_mag_temp1 = 0e-9;
% I_mag_constant1 = 10e-9;
% I_mag_temp1 = 0e-9;
% I_mag_constant1 = 20e-9;
% I_mag_temp1 = 0e-9;
I_mag_constant1 = 20e-9;
I_mag_temp1 = 1e-9;
I_apps1 = I_mag_constant1*ones( num_timesteps, 1 ) + I_mag_temp1*( ts > 0.5 & ts < 0.75 );

% Define the properties of the applied current for the first integration subnetwork neuron.
% I_mag_constant2 = 0e-9;
% I_mag_temp2 = 0e-9;
I_mag_constant2 = 20e-9;
I_mag_temp2 = 0e-9;
I_apps2 = I_mag_constant2*ones( num_timesteps, 1 ) + I_mag_temp2*( ts > 0.5 & ts < 0.75 );

% Set the properties of the applied current for the first integration subnetwork neuron.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 1 ), { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 1 ), { I_apps1 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 1 ), num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 1 ), network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 1 ), network.tf, 'tf' );

% Set the properties of the applied current for the first integration subnetwork neuron.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 2 ), { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 2 ), { I_apps2 }, 'I_apps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 2 ), num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 2 ), network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs_int( 2 ), network.tf, 'tf' );

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

