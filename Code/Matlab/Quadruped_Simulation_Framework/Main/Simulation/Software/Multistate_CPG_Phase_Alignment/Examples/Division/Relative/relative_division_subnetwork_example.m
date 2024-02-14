%% Relative Division Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Set the level of verbosity.
b_verbose = true;                                                                   % [T/F] Verbosity Flag.

% Define the network integration step size.
network_dt = 1e-4;                                                                  % [s] Network Integration Time Step.

% Define the network integration duration.
network_tf = 3;                                                                     % [s] Network Simulation Duration.


%% Define Basic Network Parameters.

% Define the maximum membrane voltages.
R1 = 20e-3;                                                                         % [V] Maximum Membrane Voltage (Neuron 1)
R2 = 20e-3;                                                                         % [V] Maximum Membrane Voltage (Neuron 2)
R3 = 20e-3;                                                                         % [V] Maximum Membrane Voltage (Neuron 3)

% Define the membrane conductances.
Gm1 = 1e-6;                                                                         % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                                                         % [S] Membrane Conductance (Neuron 2).
Gm3 = 1e-6;                                                                         % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1 = 5e-9;                                                                         % [F] Membrance Conductance (Neuron 1).
Cm2 = 5e-9;                                                                         % [F] Membrance Conductance (Neuron 2).
Cm3 = 5e-9;                                                                         % [F] Membrance Conductance (Neuron 3).

% Define the synaptic reversal potential.
dEs31 = 194e-3;                                                                     % [V] Synaptic Reversal Potential

% Define the applied currents.
Ia1 = R1*Gm1;                                                                       % [A] Applied Current (Neuron 1).
Ia2 = R2*Gm2;                                                                       % [A] Applied Current (Neuron 2).

% Define the input current states.
% current_state1 = 0;                                                               % [%] Applied Current Activity Percentage (Neuron 1). 
current_state1 = 1;                                                                 % [%] Applied Current Activity Percentage (Neuron 1). 
% current_state2 = 0;                                                               % [%] Applied Current Activity Percentage (Neuron 2). 
current_state2 = 1;                                                                 % [%] Applied Current Activity Percentage (Neuron 2). 

% Define network design parameters.
c3 = 1e-6;                                                                          % [S] Relative Division Parameter 3
delta = 1e-3;                                                                       % [V] Voltage Offset.


%% Compute Relative Division Subnetwork Derived Parameters.

% Compute the necessary parameters.
c1 = c3;                                                                            % [S] Relative Division Parameter 1
c2 = ( R2*c1 - delta*c3 )/delta;                                                    % [S] Relative Division Parameter 2
dEs32 = 0;                                                                          % [V] Synaptic Reversal Potential (Synapse 32)
Ia3 = 0;                                                                            % [A] Applied Current (Neuron 3)
gs31 = ( R3*Gm3 - Ia3 )/( dEs31 - R3 );                                             % [S] Maximum Synaptic Conductance (Synapse 31)
gs32 = ( ( dEs31 - delta )*gs31 + Ia3 - delta*Gm3 )/( delta - dEs32 );              % [S] Maximum Synaptic Conductance (Synapse 32)


%% Print Relative Division Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'RELATIVE DIVISION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )
fprintf( 'R1 = %0.2f [mV]\n', R1*( 10^3 ) )
fprintf( 'R2 = %0.2f [mV]\n', R2*( 10^3 ) )
fprintf( 'R3 = %0.2f [mV]\n', R3*( 10^3 ) )

fprintf( 'Gm1 = %0.2f [muS]\n', Gm1*( 10^6 ) )
fprintf( 'Gm2 = %0.2f [muS]\n', Gm2*( 10^6 ) )
fprintf( 'Gm3 = %0.2f [muS]\n', Gm3*( 10^6 ) )

fprintf( 'Cm1 = %0.2f [nF]\n', Cm1*( 10^9 ) )
fprintf( 'Cm2 = %0.2f [nF]\n', Cm2*( 10^9 ) )
fprintf( 'Cm3 = %0.2f [nF]\n', Cm3*( 10^9 ) )
fprintf( '\n' )

% Print out synapse information.
fprintf( 'Synapse Parameters:\n' )
fprintf( 'dEs31 = %0.2f [mV]\n', dEs31*( 10^3 ) )
fprintf( 'dEs32 = %0.2f [mV]\n', dEs32*( 10^3 ) )

fprintf( 'gs31 = %0.2f [muS]\n', gs31*( 10^6 ) )
fprintf( 'gs32 = %0.2f [muS]\n', gs32*( 10^6 ) )
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Current Parameters:\n' )
fprintf( 'Ia1 = %0.2f [nA]\n', current_state1*Ia1*( 10^9 ) )
fprintf( 'Ia2 = %0.2f [nA]\n', current_state2*Ia2*( 10^9 ) )
fprintf( 'Ia3 = %0.2f [nA]\n', Ia3*( 10^9 ) )
fprintf( '\n' )

% Print out design parameters.
fprintf( 'Design Parameters:\n' )
fprintf( 'c1 = %0.2f [nW]\n', c1*( 10^9 ) )
fprintf( 'c2 = %0.2f [nA]\n', c2*( 10^9 ) )
fprintf( 'c3 = %0.2f [nW]\n', c3*( 10^9 ) )
fprintf( 'delta = %0.2f [mV]\n', delta*( 10^3 ) )

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Relative Division Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( 3 );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( 2 );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( 3 );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ R1, R2, R3 ], 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Gm1, Gm2, Gm3 ], 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, [ Cm1, Cm2, Cm3 ], 'Cm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, zeros( size( neuron_IDs ) ), 'Gna' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 1, 2 ], 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ 3, 3 ], 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ gs31, gs32 ], 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, [ dEs31, dEs32 ], 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ 1, 2, 3 ], 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_state1*Ia1, current_state2*Ia2, Ia3 ], 'I_apps' );


%% Numerical Stability Analysis.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network.RK4_stability_analysis( cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) ), network.get_gsynmaxs( 'all' ), network.get_dEsyns( 'all' ), zeros( network.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


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

