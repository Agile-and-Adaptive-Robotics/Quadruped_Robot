%% Inversion Subnetwork Conversion Example

% Clear everything.
clear, close( 'all' ), clc


%% Set the Simulation Parameters.

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1.3e-4;
network_tf = 3;

% Define the applied current state.
% current_state = 0;
current_state = 0.25;
% current_state = 1;


%% Create a Relative Inversion Subnetwork.

% Set the user specified parameters.
R1_relative = 20e-3;
R2_relative = 20e-3;
c3_relative = 20e-9;                                                                        % [S]
delta_relative = 1e-3;
Gm2_relative = 1e-6;

% Compute the network_absolute properties.
c1_relative = c3_relative;                                                                  % [S]
c2_relative = ( ( R2_relative - delta_relative )*c3_relative )/( delta_relative );          % [S]
Ia2_relative = R2_relative*Gm2_relative;
dEs21_relative = 0;
gs21_relative = ( delta_relative*Gm2_relative - Ia2_relative )/( dEs21_relative - delta_relative );

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network_relative components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( 2 );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( 1 );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( 2 );

% Set the network_relative parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 1 ), 0, 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 2 ), 0, 'Gna' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 1 ), R1_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 2 ), R2_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative( 2 ), Gm2_relative, 'Gm' );

network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative( 1 ), 1, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative( 1 ), 2, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative( 1 ), gs21_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative( 1 ), dEs21_relative, 'dE_syn' );

network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 1 ), 1, 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 2 ), 2, 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 1 ), current_state*network_relative.neuron_manager.neurons( 1 ).R*network_relative.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative( 2 ), Ia2_relative, 'I_apps' );


%% Create an Absolute Inversion Subnetwork.

% Set the user specified parameters.
% R1_absolute = 20e-3;
% c1_absolute = 0.40e-9;          % [W]
% c3_absolute = 20e-9;            % [A]
% delta_absolute = 1e-3;
% Gm2_absolute = 1e-6;

% R1_absolute = R1_relative;
% delta_absolute = delta_relative;
% c3_absolute = c3_relative;
% c1_absolute = R2_relative*c3_absolute;
% Gm2_absolute = 1e-6;

R1_absolute = R1_relative;
delta_absolute = delta_relative;
c2_absolute = 10*c2_relative;
c1_absolute =( delta_absolute*R1_absolute*R2_relative*c2_absolute )/( R2_relative - delta_absolute );
c3_absolute = ( delta_absolute*R1_absolute*c2_absolute )/( R2_relative - delta_absolute );
Gm2_absolute = 1e-6;

% Compute the network_absolute properties.
R2_absolute = c1_absolute/c3_absolute;
c2_absolute = ( c1_absolute - delta_absolute*c3_absolute )/( delta_absolute*R1_absolute );      % [S]
Ia2_absolute = R2_absolute*Gm2_absolute;
dEs21_absolute = 0;
gs21_absolute = ( delta_absolute*Gm2_absolute - Ia2_absolute )/( dEs21_absolute - delta_absolute );

% Create an instance of the network_absolute class.
network_absolute = network_class( network_dt, network_tf );

% Create the network_absolute components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( 2 );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( 1 );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( 2 );

% Set the network_absolute parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 1 ), 0, 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 2 ), 0, 'Gna' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 1 ), R1_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 2 ), R2_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute( 2 ), Gm2_absolute, 'Gm' );

network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute( 1 ), 1, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute( 1 ), 2, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute( 1 ), gs21_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute( 1 ), dEs21_absolute, 'dE_syn' );

network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 1 ), 1, 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 2 ), 2, 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 1 ), current_state*network_absolute.neuron_manager.neurons( 1 ).R*network_absolute.neuron_manager.neurons( 1 ).Gm, 'I_apps' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute( 2 ), Ia2_absolute, 'I_apps' );


%% Simulate the relative inversion subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network_relative, ts_relative, Us_relative, hs_relative, dUs_relative, dhs_relative, G_syns_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, m_infs_relative, h_infs_relative, tauhs_relative, neuron_IDs_relative ] = network_relative.compute_set_simulation(  );

% End the timer.
relative_simulation_duration = toc;


%% Simulate the absolute inversion subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network_absolute, ts_absolute, Us_absolute, hs_absolute, dUs_absolute, dhs_absolute, G_syns_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, m_infs_absolute, h_infs_absolute, tauhs_absolute, neuron_IDs_absolute ] = network_absolute.compute_set_simulation(  );

% End the timer.
absolute_simulation_duration = toc;


%% Plot the Inversion Subnetwork Results.

% Plot the network currents over time.
fig_relative_network_currents = network_relative.network_utilities.plot_network_currents( ts_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, neuron_IDs_relative );
fig_absolute_network_currents = network_absolute.network_utilities.plot_network_currents( ts_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, neuron_IDs_absolute );

% Plot the network states over time.
fig_relative_network_states = network_relative.network_utilities.plot_network_states( ts_relative, Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_states = network_absolute.network_utilities.plot_network_states( ts_absolute, Us_absolute, hs_absolute, neuron_IDs_absolute );

% Animate the network states over time.
fig_relative_network_animation = network_relative.network_utilities.animate_network_states( Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_animation = network_absolute.network_utilities.animate_network_states( Us_absolute, hs_absolute, neuron_IDs_absolute );





