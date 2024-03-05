%% Reduced Relative Inversion Subnetwork Example.

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the level of verbosity.
b_verbose = true;                                                       % [T/F] Printing Flag.

% Define the network integration step size.
network_dt = 1.3e-4;                                                    % [s] Simulation Timestep.

% Define the simulation duration.
network_tf = 3;                                                         % [s] Simulation Duration.


%% Define Basic Reduced Relative Inversion Subnetwork Parameters.

% Define the maximum membrane voltages.
R1 = 20e-3;                                                             % [V] Maximum Voltage (Neuron 1).
R2 = 20e-3;                                                             % [V] Maximum Voltage (Neuron 2).

% Define the membrane conductances.
Gm1 = 1e-6;                                                             % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                                             % [S] Membrane Conductance (Neuron 2).

% Define the membrane capacitance.
Cm1 = 5e-9;                                                             % [F] Membrane Capacitance (Neuron 1).
Cm2 = 5e-9;                                                             % [F] Membrane Capacitance (Neuron 2).

% Define the sodium channel conductance.
Gna1 = 0;                                                               % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                                               % [S] Sodium Channel Conductance (Neuron 2).

% Define the synaptic reversal potential.
dEs21 = 0;                                                              % [V] Synaptic Reversal Potential (Synapse 21).

% Define the applied currents.
Ia1 = R1*Gm1;                                                           % [A] Applied Current (Neuron 1).
Ia2 = R2*Gm2;                                                           % [A] Applied Current (Neuron 2).

% Define the current state.
current_state1 = 0;                                                     % [-] Current State (Neuron 1).  (Specified as a ratio of the maximum current.)
% current_state1 = 1;                                                   % [-] Current State (Neuron 1).  (Specified as a ratio of the maximum current.)

% Define the network design parameters.
delta = 1e-3;                                                           % [V] Membrane Voltage Offset.


%% Compute Derived Reduced Relative Inversion Network Parameters.

% Compute the design parameters.
c1 = delta/( R2 - delta );                                              % [-] Design Constant 1.
c2 = c1;                                                                % [-] Design Constant 2.

% Compute the synpatic conductance.
gs21 = ( Ia2 - delta*Gm2 )/( delta - dEs21 );                          	% [S] Synaptic Conductance (Synapse 21).


%% Print Reduced Relative Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'REDUCED RELATIVE INVERSION SUBNETWORK PARAMETERS:\n' )
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
fprintf( 'Ia2 \t= \t%0.2f \t[nA]\n', Ia2*( 10^9 ) )
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )
fprintf( 'c1 \t\t= \t%0.2e \t[-]\n', c1 )
fprintf( 'c2 \t\t= \t%0.2e \t[-]\n', c2 )
fprintf( 'delta \t= \t%0.2f \t[mV]\n', delta*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Reduced Relative Inversion Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 2 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 1 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 2 );

% Set neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2 ], 'Cm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gna1, Gna2 ], 'Gna' );

% Set synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 1, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 2, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, gs21, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, dEs21, 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ Ia1, Ia2 ], 'I_apps' );


%% Compute the Reduced Rlative Inversion Numerical Stability Analysis Parameters.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network.RK4_stability_analysis( cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) ), network.get_gsynmaxs( 'all' ), network.get_dEsyns( 'all' ), [ ( ( delta*Gm2 - Ia2 )*R1 )/( ( dEs21 - delta )*gs21 ); delta ], 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Simulate the Reduced Relative Inversion Subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );

% End the timer.
toc


%% Plot the Reduced Relative Inversion Subnetwork Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );

