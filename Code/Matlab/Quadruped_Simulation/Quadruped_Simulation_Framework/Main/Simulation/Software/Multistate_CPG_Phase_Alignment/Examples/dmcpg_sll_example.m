%% Driven Multistate CPG Split Lead Lag Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
% network_dt = 1e-3;
network_dt = 1e-4;
network_tf = 5;


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
c_mod = 0.05;

[ network, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = network.create_dmcpg_sll_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod );

% % Disable the cpg subnetworks.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg1 );
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg2 );


%% Setup the Drive Currents.

% Retrieve the drive current IDs.
applied_current_ID_drive1 = applied_current_IDs_cell{ 1 }( end );
applied_current_ID_drive2 = applied_current_IDs_cell{ 2 }( end );

% Define the drive current time vector.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the drive current magnitude.
Imag_low1 = 0; Imag_middle1 = 1e-9; Imag_high1 = 20e-9;
Imag_low2 = 0; Imag_middle2= 1e-9; Imag_high2 = 20e-9;

% Define the drive current applied magnitude vector.
% I_apps1 = Imag_low1*( ts >= 0 & ts < 1.00 ) + Imag_middle1*( ts >= 1.00 & ts < 2.00 ) + Imag_high1*( ts >= 2.00 & ts <= 3.00 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 1.00 ) + Imag_middle2*( ts >= 1.00 & ts < 2.00 ) + Imag_high2*( ts >= 2.00 & ts <= 3.00 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 1.00 ) + Imag_middle1*( ts >= 1.00 & ts < 2.00 ) + Imag_high1*( ts >= 2.00 & ts < 3.00 ) + Imag_middle1*( ts >= 3.00 & ts < 4.00 ) + Imag_low1*( ts >= 4.00 & ts <= 5.00 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 1.00 ) + Imag_middle2*( ts >= 1.00 & ts < 2.00 ) + Imag_high2*( ts >= 2.00 & ts < 3.00 ) + Imag_middle2*( ts >= 3.00 & ts < 4.00 ) + Imag_low2*( ts >= 4.00 & ts <= 5.00 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.75 ) + Imag_middle1*( ts >= 0.75 & ts < 1.75 ) + Imag_low1*( ts >= 1.75 & ts < 2.75 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.25 ) + Imag_middle2*( ts >= 0.25 & ts < 1.25 ) + Imag_low2*( ts >= 1.25 & ts < 2.25 );

% I_apps1 = Imag_low1*( ts >= 0 & ts < 0.75 ) + Imag_middle1*( ts >= 0.75 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 0.50 ) + Imag_middle2*( ts >= 0.50 );

I_apps1 = Imag_middle1*( ts >= 0 );
I_apps2 = Imag_high2*( ts >= 0 & ts < 0.25 ) + Imag_middle2*( ts >= 0.25 );


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

fig_network_states = network.network_utilities.plot_network_states( ts, Us( ( end - 3  ):end, : ), hs( ( end - 3  ):end, : ), neuron_IDs( ( end - 3  ):end ) ); fig_network_states.Name = 'Lead / Lag';


% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

