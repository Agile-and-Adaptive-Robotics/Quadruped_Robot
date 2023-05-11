%% Driven Multistate CPG Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Initialize Project Options.

% Set the level of verbosity.
b_verbose = true;

% Define the network integration step size.
network_dt = 1e-3;
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

% Create the first multistate cpg subnetwork.
[ network, neuron_IDs_cpg1, synapse_IDs_cpg1, applied_current_ID_cpg1 ] = network.create_driven_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max );

% Create the second multistate cpg subnetwork.
[ network, neuron_IDs_cpg2, synapse_IDs_cpg2, applied_current_ID_cpg2 ] = network.create_driven_multistate_cpg_subnetwork( num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max );

% % Disable the cpg subnetworks.
% network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg1 );
network.neuron_manager = network.neuron_manager.disable_neurons( neuron_IDs_cpg2 );


%% Setup the Drive Currents.

% Retrieve the drive current IDs.
applied_current_ID_drive1 = applied_current_ID_cpg1( end );
applied_current_ID_drive2 = applied_current_ID_cpg2( end );

% Define the drive current time vector.
ts = ( 0:network.dt:network.tf )';
num_timesteps = length( ts );

% Define the drive current magnitude.
Imag_low1 = 0; Imag_middle1 = 10e-9; Imag_high1 = 20e-9;
Imag_low2 = 0; Imag_middle2= 10e-9; Imag_high2 = 20e-9;

% Define the drive current applied magnitude vector.
% I_apps1 = Imag_low1*( ts >= 0 & ts < 1.00 ) + Imag_middle1*( ts >= 1.00 & ts < 2.00 ) + Imag_high1*( ts >= 2.00 & ts <= 3.00 );
% I_apps2 = Imag_low2*( ts >= 0 & ts < 1.00 ) + Imag_middle2*( ts >= 1.00 & ts < 2.00 ) + Imag_high2*( ts >= 2.00 & ts <= 3.00 );

I_apps1 = Imag_low1*( ts >= 0 & ts < 1.00 ) + Imag_middle1*( ts >= 1.00 & ts < 2.00 ) + Imag_high1*( ts >= 2.00 & ts < 3.00 ) + Imag_middle1*( ts >= 3.00 & ts < 4.00 ) + Imag_low1*( ts >= 4.00 & ts <= 5.00 );
I_apps2 = Imag_low2*( ts >= 0 & ts < 1.00 ) + Imag_middle2*( ts >= 1.00 & ts < 2.00 ) + Imag_high2*( ts >= 2.00 & ts < 3.00 ) + Imag_middle2*( ts >= 3.00 & ts < 4.00 ) + Imag_low2*( ts >= 4.00 & ts <= 5.00 );


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
Us = circshift( Us, [ 1, 0 ] );
hs = circshift( hs, [ 1, 0 ] );
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );
subplot( 2, 1, 1 ), legend( 'C1', 'C2', 'C3', 'C4', 'C5' )

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

