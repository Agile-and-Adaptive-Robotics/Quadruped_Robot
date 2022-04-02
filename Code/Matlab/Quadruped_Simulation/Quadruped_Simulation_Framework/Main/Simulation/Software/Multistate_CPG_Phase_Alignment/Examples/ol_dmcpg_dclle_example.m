%% Open Loop Driven Multistate CPG Double Centered Lead Lag Error Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 0.5e-3;
% network_dt = 1e-4;
network_tf = 5;
% network_tf = 10;
% network_tf = 40;



%% Create Multistate CPG Subnetworks.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Define the oscillatory and bistable delta CPG synapse design parameters.
% delta_oscillatory = 0.01e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
% delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections
delta_oscillatory = 0e-3;                    % [-] Relative Inhibition Parameter for Oscillatory Connections
delta_bistable = -10e-3;                        % [-] Relative Inhibition Parameter for Bistable Connections

% Define the maximum driving current.
I_drive_max = 1.25e-9;                         % [A] Max Multistate CPG Driving Current

% Define the number of CPG neurons.
num_cpg_neurons = 4;

% Set the integration subnetwork properties.
T = 2;
n = 4;
ki_mean = 0.01e10;
ki_range = 0.01e9;
k_sub1 = 2;
k_sub2 = 1;
k_sub3 = 1;
k_sub4 = 1;
k_sub5 = 1;
k_add1 = 1;
k_add2 = 1;
c_mod = 0.05;
r = 0.5;

% Create the driven multistate cpg double centered lead lag subnetwork.
[ network, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = network.create_ol_dmcpg_dclle_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r );


%% Setup the Drive Currents.

% Retrieve the drive current IDs.
applied_current_ID_drive1 = applied_current_IDs_cell{ 1 }{ 1 }( end );
applied_current_ID_drive2 = applied_current_IDs_cell{ 1 }{ 2 }( end );

% Define the drive current time vector.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the drive current magnitude.
Imag_neg1 = -1e-9; Imag_low1 = 0; Imag_middle1 = 1e-9; Imag_high1 = 20e-9; Imag_veryhigh1 = 1000e-9;
Imag_neg2 = -1e-9; Imag_low2 = 0; Imag_middle2= 1e-9; Imag_high2 = 20e-9; Imag_veryhigh2 = 1000e-9;

% Define the drive current applied magnitude vector.
% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.75 ) + Imag_middle1*( ts >= 0.75 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.50 ) + Imag_middle2*( ts >= 0.50 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.50 ) + ( 0.1e-9 )*( ts >= 0.50 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.25 ) + ( 0.1e-9 )*( ts >= 0.25 );

I_apps1 = Imag_low1*( ts >= 0 & ts < 0.125 ) + ( 0.1e-9 )*( ts >= 0.125 );
I_apps2 = ( 0.1e-9 )*( ts >= 0 ); I_apps2( 1 ) = Imag_low2;

% Setup the first drive current.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive1, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive1, { I_apps1 }, 'I_apps' );
etwork.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive1, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive1, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive1, network.tf, 'tf' );

% Setup the second drive current.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive2, { ts }, 'ts' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive2, { I_apps2 }, 'I_apps' );
etwork.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive2, num_timesteps, 'num_timesteps' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive2, network.dt, 'dt' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_ID_drive2, network.tf, 'tf' );


%% Setup Applied Voltages.

% Initialize the applied voltages.
[ V_apps1, V_apps2 ] = deal( cell( size( ts ) ) );

% Define the applied voltage magnitudes.
% V_apps1( ts >= 0 & ts < 0.5 ) = { 0 };
% V_apps2( ts >= 0 & ts < 0.25 ) = { 0 };
% V_apps1( ts >= 0 & ts < 0.25 ) = { 0 };
% V_apps2( ts >= 0 & ts < 0.125 ) = { 0 };
V_apps1( ts >= 0 & ts < 0.125 ) = { 0 };
V_apps2( 1 ) = { 0 };


% Create the applied voltages.
[ network.applied_voltage_manager, applied_voltage_IDs_CPG ] = network.applied_voltage_manager.create_applied_voltages( 2*num_cpg_neurons );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG, [ neuron_IDs_cell{ 1 }{ 1 }( 1:4 ) neuron_IDs_cell{ 1 }{ 2 }( 1:4 ) ], 'neuron_ID' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG, { ts }, 'ts' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG( 1:4 ), { V_apps1 }, 'V_apps' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG( 5:8 ), { V_apps2 }, 'V_apps' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG, { num_timesteps }, 'num_timesteps' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG, { network.dt }, 'dt' );
network.applied_voltage_manager = network.applied_voltage_manager.set_applied_voltage_property( applied_voltage_IDs_CPG, { network.tf }, 'tf' );


%% Simulate the Network.

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );


%% Post-Process Simulation Results.

% Compute the transition logical indexes.
transition_logicals = logical( abs( diff( Us > 20e-3, 1, 2 ) ) );

% Preallocate an array to store the activation and deactivation periods.
[ Ts_activation, Ts_deactivation ] = deal( zeros( 1, num_cpg_neurons ) );

% Compute the activation and deactivation times for each of the CPG neurons.
for k = 1:num_cpg_neurons                           % Iterate through each of the CPG neurons.
    
    % Compute the transition times for this 
    transition_times = ts( transition_logicals( k, : ) );
    
    % Compute the duration between transitions.
    dTs = diff( transition_times );
    
    % Compute the average activation time for this neuron
    Ts_activation( k ) = mean( dTs( 1:2:end ) );
    
    % Compute the average deactivation time for this neuron.
    Ts_deactivation( k ) = mean( dTs( 2:2:end ) );
        
end

% Compute the period of oscillation.
Ts_period = Ts_activation + Ts_deactivation;                        % [s] Oscillation Period.

% Compute the frequency of oscillation.
fs_frequency = 1./Ts_period;                                        % [Hz] Oscillation Frequency.

% Print the oscillation period.
fprintf('Oscillation Period: [s]\n'), disp( Ts_period )
fprintf('Oscillation Frequency: [hz]\n'), disp( fs_frequency )


%% Plot the Network Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 1:5, : ), hs( 1:5, : ), neuron_IDs( 1:5 ) ); fig_network_states.Name = 'CPG 1';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 6:10, : ), hs( 6:10, : ), neuron_IDs( 6:10 ) ); fig_network_states.Name = 'CPG 2';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 11:14, : ), hs( 11:14, : ), neuron_IDs( 11:14 ) ); fig_network_states.Name = 'Sub 1';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 15:18, : ), hs( 15:18, : ), neuron_IDs( 15:18 ) ); fig_network_states.Name = 'Int 1';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 19:23, : ), hs( 19:23, : ), neuron_IDs( 19:23 ) ); fig_network_states.Name = 'Shifted Int 1';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 24:26, : ), hs( 24:26, : ), neuron_IDs( 24:26 ) ); fig_network_states.Name = 'Modulated Int 1';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 27:30, : ), hs( 27:30, : ), neuron_IDs( 27:30 ) ); fig_network_states.Name = 'Sub 2';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 31:34, : ), hs( 31:34, : ), neuron_IDs( 31:34 ) ); fig_network_states.Name = 'Int 2';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 35:39, : ), hs( 35:39, : ), neuron_IDs( 35:39 ) ); fig_network_states.Name = 'Shifted Int 2';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 40:42, : ), hs( 40:42, : ), neuron_IDs( 40:42 ) ); fig_network_states.Name = 'Modulated Int 2';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 43:46, : ), hs( 43:46, : ), neuron_IDs( 43:46 ) ); fig_network_states.Name = 'Sub 3';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 47:50, : ), hs( 47:50, : ), neuron_IDs( 47:50 ) ); fig_network_states.Name = 'Int 3';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 51:55, : ), hs( 51:55, : ), neuron_IDs( 51:55 ) ); fig_network_states.Name = 'Shifted Int 3';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 56:58, : ), hs( 56:58, : ), neuron_IDs( 56:58 ) ); fig_network_states.Name = 'Modulated Int 3';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 59:62, : ), hs( 59:62, : ), neuron_IDs( 59:62 ) ); fig_network_states.Name = 'Sub 4';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 63:66, : ), hs( 63:66, : ), neuron_IDs( 63:66 ) ); fig_network_states.Name = 'Int 4';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 67:71, : ), hs( 67:71, : ), neuron_IDs( 67:71 ) ); fig_network_states.Name = 'Shifted Int 4';
fig_network_states = network.network_utilities.plot_network_states( ts, Us( 72:74, : ), hs( 72:74, : ), neuron_IDs( 72:74 ) ); fig_network_states.Name = 'Modulated Int 4';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 75:78, : ), hs( 75:78, : ), neuron_IDs( 75:78 ) ); fig_network_states.Name = 'Split Lead / Lag';

fig_network_states = network.network_utilities.plot_network_states( ts, Us( 79:85, : ), hs( 79:85, : ), neuron_IDs( 79:85 ) ); fig_network_states.Name = 'Centered Lead / Lag';


% % Animate the network states over time.
% fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

