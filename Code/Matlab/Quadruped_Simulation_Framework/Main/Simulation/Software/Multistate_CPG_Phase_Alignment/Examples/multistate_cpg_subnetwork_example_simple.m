%% Multistate CPG Subnetwork Example Simple

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
network_tf = 3;


%% Create Multistate CPG Subnetworks.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Define the oscillatory and bistable delta CPG synapse design parameters.
delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Define the number of CPG neurons.
num_cpg_neurons = 4;

% Create the first multistate cpg subnetwork.
[ network, neuron_IDs_cpg1, synapse_IDs_cpg1, applied_current_ID_cpg1 ] = network.create_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable );


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

