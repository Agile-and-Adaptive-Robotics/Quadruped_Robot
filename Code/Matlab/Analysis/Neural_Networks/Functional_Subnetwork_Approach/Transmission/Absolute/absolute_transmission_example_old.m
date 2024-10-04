%% Absolute Transmission Subnetwork Example.

% Clear Everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                       	% [str] Save Directory.
load_directory = '.\Load';                         	% [str] Load Directory.

% Define the level of verbosity.
b_verbose = true;                                   % [T/F] Printing Flag.

% Define the network integration step size.
network_dt = 1.3e-4;                                % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                     % [s] Simulation Duration.


%% Define Absolute Transmission Subnetwork Parameters.

% Define the maximum membrane voltages.
R1 = 20e-3;                                         % [V] Maximum Membrane Voltage (Neuron 1).

% Define the membrane conductances.
Gm1 = 1e-6;                                       	% [S] Membrane Conductance (Neuron 1)
Gm2 = 1e-6;                                      	% [S] Membrane Conductance (Neuron 2) 

% Define the membrane capacitance.
Cm1 = 5e-9;                                     	% [F] Membrane Capacitance (Neuron 1)
Cm2 = 5e-9;                                      	% [F] Membrane Capacitance (Neuron 2)

% Define the sodium channel conductance.
Gna1 = 0;                                           % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                           % [S] Sodium Channel Conductance (Neuron 2).

% Define the synaptic conductances.
dEs21 = 194e-3;                                   	% [V] Synaptic Reversal Potential (Synapse 21).

% Define the applied currents.
Ia1 = R1*Gm1;                                      	% [A] Applied Current (Neuron 1)
Ia2 = 0;                                            % [A] Applied Current (Neuron 2).

% Define the current state.
current_state1 = 1;                                 % [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)

% Define the network design parameters.
c = 1;                                              % [-] Design Constant.


%% Compute Derived Absolute Transmission Subnetwork Constraints.

% Compute the maximum membrane voltages.
R2 = c*R1;                                          % [V] Maximum Membrane Voltage (Neuron 2).

% Compute the synaptic conductances.
gs21 = ( R2*Gm2 - Ia2 )/( dEs21 - R2 );             % [S] Synaptic Conductance (Synapse 21).


%% Print Absolute Transmission Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'ABSOLUTE TRANSMISSION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 \t\t= \t%0.2f \t[mV]\n', R1*( 10^3 ) )
fprintf( 'R2 \t\t= \t%0.2f \t[mV]\n', R2*( 10^3 ) )

fprintf( 'Gm1 \t= \t%0.2f \t[muS]\n', Gm1*( 10^6 ) )
fprintf( 'Gm2 \t= \t%0.2f \t[muS]\n', Gm2*( 10^6 ) )

fprintf( 'Cm1 \t= \t%0.2f \t[nF]\n', Cm1*( 10^9 ) )
fprintf( 'Cm2 \t= \t%0.2f \t[nF]\n', Cm2*( 10^9 ) )

fprintf( 'Gna1 \t= \t%0.2f \t[muS]\n', Gna1*( 10^6 ) )
fprintf( 'Gna2 \t= \t%0.2f \t[muS]\n', Gna2*( 10^6 ) )
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs21 \t= \t%0.2f \t[mV]\n', dEs21*( 10^3 ) )
fprintf( 'gs21 \t= \t%0.2f \t[muS]\n', gs21*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )
fprintf( 'Ia1 \t= \t%0.2f \t[nA]\n', current_state1*Ia1*( 10^9 ) )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c \t\t= \t%0.2f \t[-]\n', c )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Absolute Transmission Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 2 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 1 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 2 );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gna1, Gna2 ], 'Gna' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2 ], 'Cm' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 2, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, gs21, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, dEs21, 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_state1*Ia1, Ia2 ], 'I_apps' );


%% Compute Absolute Transmission Numerical Stability Analysis Parameters.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network.RK4_stability_analysis( cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) ), network.get_gsynmaxs( 'all' ), network.get_dEsyns( 'all' ), zeros( network.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Simulate the Absolute Transmission Subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );

% End the timer.
toc


%% Plot the Absolute Transmission Subnetwork Results.

% Compute the decoded output.
Us_decoded = Us*( 10^3 );

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Plot the absolute network decoding over time.
fig_network_decoding = figure( 'Color', 'w', 'Name', 'Absolute Transmission Decoding vs Time' ); hold on, grid on, xlabel( 'Time, t [s]' ), ylabel( 'Network Decoding [-]' ), title( 'Absolute Transmission Decoding vs Time' )
plot( ts, Us_decoded( 1, : ), '-', 'Linewidth', 3 )
plot( ts, Us_decoded( 2, : ), '-', 'Linewidth', 3 )
legend( 'Input', 'Output' )
saveas( fig_network_decoding, [ save_directory, '\', 'absolute_transmission_decoding_example' ] )

% Plot the absolute network dynamic decoding example.
fig_network_decoding = figure( 'Color', 'w', 'Name', 'Absolute Transmission Dynamic Decoding Example' ); hold on, grid on, xlabel( 'Input [-]' ), ylabel( 'Output [-]' ), title( 'Absolute Transmission Dynamic Decoding Example' )
plot( Us_decoded( 1, : ), Us_decoded( 2, : ), '-', 'Linewidth', 3 )
saveas( fig_network_decoding, [ save_directory, '\', 'absolute_transmission_dynamic_decoding_example' ] )

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

