%% Absolute Linear Combination Subnetwork Example

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the level of verbosity.
b_verbose = true;                                   % [T/F] Printing Flag.

% Define the network integration step size.
network_dt = 1.3e-4;                                % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                     % [s] Simulation Duration.

% Define the number of excitatory and inhibitory inputs.
num_excitatory_inputs = 3;                          % [#] Number of Excitatory Input Neurons.
num_inhibitory_inputs = 2;                          % [#] Number of Inhibitory Input Neurons.


%% Define Absolute Linear Combination Subnetwork Parameters.

% Compute the total number of neurons and synapses.
num_neurons = num_excitatory_inputs + num_inhibitory_inputs + 1;        % [#] Number of Neurons.
num_synapses = num_excitatory_inputs + num_inhibitory_inputs;           % [#] Number of Synapses.

% Define the maximum membrane voltages.
Rs = ( 20e-3 )*ones( num_neurons, 1 );                                  % [V] Maximum Membrane Voltages.

% Define the membrane conductances.
Gms = ( 1e-6 )*ones( num_neurons, 1 );                                  % [S] Membrane Conductances.

% Define the membrane capacitances.
Cms = ( 5e-9 )*ones( num_neurons, 1 );                                  % [F] Membrance Capacitances.

% Define the sodium channel conductances.
Gnas = zeros( num_neurons, 1 );                                         % [S] Sodium Channel Conductances.

% Define the synaptic reversal potentials.
dEs_excitatory = ( 194e-3 )*ones( num_excitatory_inputs, 1 );           % [V] Excitatory Synaptic Reversal Potentials.
dEs_inhibitory = ( -194e-3 )*ones( num_inhibitory_inputs, 1 );          % [V] Inhibitory Synaptic Reversal Potentials.
dEs = [ dEs_excitatory; dEs_inhibitory ];                               % [V] Synaptic Reversal Potentials.

% Define the applied currents.
Ias = Rs.*Gms;                                                          % [A] Applied Currents.
Ias( end ) = 0;                                                         % [A] Applied Currents (Output neuron current zeroed).

% Define the current states.
% current_states = ones( num_synapses, 1 );                               % [-] Current States.  (Specified as a ratio of the total applied currents that is active.)
current_states = [ 1; 0; 0; 0.5; 0 ];

% Define the subnetwork design constants.
cs = ones( num_synapses, 1 );                                           % [-] Design Constants.

% Define the input signatures.
ss_excitatory = ones( num_excitatory_inputs, 1 );                       % [-1/1] Excitatory Input Signatures.
ss_inhibitory = -ones( num_inhibitory_inputs, 1 );                      % [-1/1] Inhibitory Input Signatures.
ss = [ ss_excitatory; ss_inhibitory ];                                  % [-1/1] Input Signatures.


%% Compute Derived Absolute Linear Combination Subnetwork Constraints.

% Retrieve the input maximum membrane voltages.
Rs_inputs = Rs( 1:end - 1 );                                        % [V] Maximum Membrane Voltages of Input Neurons.

% Retrieve the input indexes associated with excitatory and inhibitory inputs.
i_excitatory = ss == 1;                                             % [#] Excitatory Input Neuron Indexes.
i_inhibitory = ss == -1;                                            % [#] Inhibitory Input Neuron Indexes.

% Compute the maximum membrane voltages required for the excitatory and inhibitory inputs.
Rn_inhibitory = cs( i_inhibitory )'*Rs_inputs( i_inhibitory );     	% [V] Maximum Membrane Voltage To Capture Inhibitory Neuron Inputs.
Rn_excitatory = cs( i_excitatory )'*Rs_inputs( i_excitatory );     	% [V] Maximum Membrane Voltage To Capture Excitatory Neuron Inputs.

% Compute the maximum membrane voltage of the output neuron.
Rn = max( Rn_inhibitory, Rn_excitatory );                           % [V] Maximum Membrane Voltage (Output Neuron).

% Add the maximum membrane voltage of the output neuron to the maximum membrane voltage array.
Rs( end ) = Rn;                                                     % [V] Maximum Membrane Voltages (# neurons x 1).

% Preallocate an array to store the synaptic conductances.
gs = zeros( num_synapses, 1 );                                      % [S] Synaptic Conductances (# synapses x 1).

% Compute the synaptic conductaances.
for k = 1:num_synapses                                              % Iterate through each of the synapses...
    
    % Compute the synaptic conductance associated with this synapse.
    gs( k ) = ( Ias( end ) - ss( k )*cs( k )*Rs( k )*Gms( end ) )/( ss( k )*cs( k )*Rs( k ) - dEs( k ) );           % [S] Synaptic Conductances (# synapses x 1).

end


%% Print Absolute Linear Combination Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'ABSOLUTE LINEAR COMBINATION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )

% Print out the maximum membrane voltages.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the maximum membrane voltage for this neuron.
    fprintf( 'R%0.0f \t\t= \t%0.2f \t[mV]\n', k, Rs( k )*( 10^3 ) )

end

% Print out the membrane conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane conductance for this neuron.
    fprintf( 'Gm%0.0f \t= \t%0.2f \t[muS]\n', k, Gms( k )*( 10^6 ) )

end

% Print out the membrane capacitances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane capacitance for this neuron.
    fprintf( 'Cm%0.0f \t= \t%0.2f \t[nF]\n', k, Cms( k )*( 10^9 ) )

end

% Print out the sodium channel conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the sodium channel conductance for this neuron.
    fprintf( 'Gna%0.0f \t= \t%0.2f \t[muS]\n', k, Gnas( k )*( 10^6 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )

% Print out the synaptic reversal potentials.
for k = 1:num_synapses              % Iterate through each of the synapses....

    % Print the synaptic reversal potential for this synapse.
    fprintf( 'dEs%0.0f%0.0f \t= \t%0.2f \t[mV]\n', num_neurons, k, dEs( k )*( 10^3 ) )
    
end

% Print out the synaptic conductances.
for k = 1:num_synapses              % Iterate through each of the synapses...
   
    % Print the synaptic conductance for this synapse.
    fprintf( 'gs%0.0f%0.0f \t= \t%0.2f \t[muS]\n', num_neurons, k, gs( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )

% Print out the applied currents.
for k = 1:num_neurons               % Iterate through each of the neurons...

    % Print out the applied current for this neuron.
    fprintf( 'Ia%0.0f \t= \t%0.2f \t[nA]\n', k, Ias( k )*( 10^9 ) )
    
end

% Print out a new line.
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )

% Print the input gains.
for k = 1:num_synapses                   % Iterate through each of the synapses...
   
    % Print out the gain for this synapse.
    fprintf( 'c%0.0f \t\t= \t%0.2f \t[-]\n', k, cs( k ) )
    
end

% Print the input signatures.
for k = 1:num_synapses                  % Iterate through each of the synpases...
   
    % Print out the signature for this synapse.
    fprintf( 's%0.0f \t\t= \t%0.0f \t\t[-]\n', k, ss( k ) )
    
end

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Absolute Linear Combination Subnetwork.

% Create an instance of the network class.
network = network_class( network_dt, network_tf );

% Create the network components.
[ network.neuron_manager, neuron_IDs ] = network.neuron_manager.create_neurons( num_neurons );
[ network.synapse_manager, synapse_IDs ] = network.synapse_manager.create_synapses( num_synapses );
[ network.applied_current_manager, applied_current_IDs ] = network.applied_current_manager.create_applied_currents( num_neurons );

% Set the neuron parameters.
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, Rs, 'R' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, Gms, 'Gm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, Cms, 'Cm' );
network.neuron_manager = network.neuron_manager.set_neuron_property( neuron_IDs, Gnas, 'Gna' );

% Set the synapse parameters.
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, 1:num_synapses, 'from_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, num_neurons, 'to_neuron_ID' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, gs, 'g_syn_max' );
network.synapse_manager = network.synapse_manager.set_synapse_property( synapse_IDs, dEs, 'dE_syn' );

% Set the applied current parameters.
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, 1:num_neurons, 'neuron_ID' );
network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs, [ current_states; 0 ].*Ias, 'I_apps' );


%% Compute Absolute Linear Combination Numerical Stability Analysis Parameters.

% Compute the maximum RK4 step size and condition number.
[ A, dt_max, condition_number ] = network.RK4_stability_analysis( cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) ), cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) ), network.get_gsynmaxs( 'all' ), network.get_dEsyns( 'all' ), zeros( network.neuron_manager.num_neurons, 1 ), 1e-6 );

% Print out the stability information.
fprintf( '\nSTABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( A )
fprintf( 'Max RK4 Step Size: \tdt_max = %0.3e [s]\n', dt_max )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \tcond( A ) = %0.3e [-]\n', condition_number )


%% Simulate the Absolute Linear Combination Subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );

% End the timer.
toc


%% Plot the Absolute Linear Combination Subnetwork Results.

% Plot the network currents over time.
fig_network_currents = network.network_utilities.plot_network_currents( ts, I_leaks, I_syns, I_nas, I_apps, I_totals, neuron_IDs );

% Plot the network states over time.
fig_network_states = network.network_utilities.plot_network_states( ts, Us, hs, neuron_IDs );

% Animate the network states over time.
fig_network_animation = network.network_utilities.animate_network_states( Us, hs, neuron_IDs );


