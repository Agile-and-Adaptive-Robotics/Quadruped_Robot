%% Linear Combination Conversion Example.

% Clear everything.
clear, close( 'all' ), clc


%% Define Simulation Parameters.

% Define the level of verbosity.
b_verbose = true;                                       % [T/F] Printing Flag.

% Define the network integration step size.
network_dt = 1.3e-4;                                    % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                         % [s] Simulation Duration.

% Define the current states.
current_state1 = 1;                                     % [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)
current_state2 = 0.25;                                  % [-] Current State (Neuron 2). (Specified as a ratio of the total applied current that is active.)

% Construct the current state arrays.
current_states = [ current_state1; current_state2 ];    % [-] Current State. (Specified as a ratio of the total applied current that is active.)


%% Define Relative Linear Combination Subnetwork Parameters.

% Define the maximum membrane voltages.
R1_relative = 20e-3;                                            % [V] Maximum Membrane Voltages (Neuron 1).
R2_relative = 20e-3;                                            % [V] Maximum Membrane Voltage (Neuron 2).
R3_relative = 20e-3;                                            % [V] Maximum Membrane Voltage (Neuron 3).

% Define the membrane conductances.
Gm1_relative = 1e-6;                                            % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                            % [S] Membrane Conductance (Neuron 2).
Gm3_relative = 1e-6;                                            % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1_relative = 5e-9;                                            % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                            % [F] Membrane Capacitance (Neuron 2).
Cm3_relative = 5e-9;                                            % [F] Membrane Capacitance (Neuron 3).

% Define the sodium channel conductances.
Gna1_relative = 0;                                              % [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                              % [S] Sodium Channel Conductance (Neuron 2).
Gna3_relative = 0;                                              % [S] Sodium Channel Conductance (Neuron 3).

% Define the synaptic reversal potentials.
dEs31_relative = 194e-3;                                        % [V] Synaptic Reversal Potential (Synapse 31).
dEs32_relative = -194e-3;                                       % [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                        % [A] Applied Current (Neuron 1)
Ia2_relative = R2_relative*Gm2_relative;                      	% [A] Applied Current (Neuron 2).
Ia3_relative = 0;                                               % [A] Applied Current (Neuron 3).

% Define the subnetwork design constants.
c1_relative = 1;                                                % [-] Design Constant 1.
c2_relative = 1;                                                % [-] Design Constant 2.

% Define the input signatures.
s1_relative = 1;                                                % [-1/1] Input Signature 1.
s2_relative = -1;                                               % [-1/1] Input Signature 2.


%% Compute Relative Linear Combination Subnetwork Parameter Arrays.

% Construct the maximum membrane voltage array.
Rs_relative = [ R1_relative; R2_relative; R3_relative ];                            % [V] Maximum Membrane Voltages (# neurons x 1).

% Construct the membrane conductance array.
Gms_relative = [ Gm1_relative; Gm2_relative; Gm3_relative ];                        % [S] Membrane Conductance (# neurons x 1).

% Construct the membrane capacitance array.
Cms_relative = [ Cm1_relative; Cm2_relative; Cm3_relative ];                        % [F] Membrane Capacitance (# neurons x 1).

% Construct the sodium channel conductance array.
Gnas_relative = [ Gna1_relative; Gna2_relative; Gna3_relative ];                    % [S] Sodium Channel Conductances (# neurons x 1).

% Construct the synaptic reversal potential array.
dEs_relative = [ dEs31_relative; dEs32_relative ];                                  % [V] Synaptic Reversal Potentials (# synapses x 1).

% Construct the applied current array.
Ias_relative = [ Ia1_relative; Ia2_relative; Ia3_relative ];                        % [A] Applied Currents (# neurons x 1).

% Construct the design constant array.
cs_relative = [ c1_relative; c2_relative ];                                         % [-] Input Gains (# neurons - 1 x 1).

% Construct the input signature array.
ss_relative = [ s1_relative; s2_relative ];                                         % [-1/1] Input Signatures (# neurons - 1 x 1).


%% Compute Derived Relative Linear Combination Subnetwork Constraints.

% Compute network structure information.
num_neurons = length( Rs_relative );                                         % [#] Number of Neurons.
num_synapses = length( dEs_relative );                                       % [#] Number of Synapses.

% Retrieve the input indexes associated with excitatory and inhibitory inputs.
i_excitatory_relative = ss_relative == 1;                                             % [#] Excitatory Input Neuron Indexes.
i_inhibitory_relative = ss_relative == -1;                                            % [#] Inhibitory Input Neuron Indexes.

% Retrieve the excitatory and inhibitory gains.
cs_excitatory_relative = cs_relative( i_excitatory_relative );                                 % [-] Excitatory Gains.
cs_inhibitory_relative = cs_relative( i_inhibitory_relative );                                 % [-] Inhibitory Gains.

% Compute the relevant gain magnitude with respect to the 1-norm.
cs_magnitude_relative = max( norm( cs_inhibitory_relative, 1 ), norm( cs_excitatory_relative, 1 ) );

% Normalize the inhibitory and excitatory gains.
cs_excitatory_unit_relative = cs_excitatory_relative/cs_magnitude_relative;
cs_inhibitory_unit_relative = cs_inhibitory_relative/cs_magnitude_relative;

% Construct the normalized input gains vector.
cs_unit_relative = zeros( size( cs_relative ) );
cs_unit_relative( i_excitatory_relative ) = cs_excitatory_unit_relative;
cs_unit_relative( i_inhibitory_relative ) = cs_inhibitory_unit_relative;

% Preallocate an array to store the synaptic conductances.
gs_relative = zeros( num_synapses, 1 );                                      % [S] Synaptic Conductances (# synapses x 1).

% Compute the synaptic conductaances.
for k = 1:num_synapses                                              % Iterate through each of the synapses...
    
    % Compute the synaptic conductance associated with this synapse.
    gs_relative( k ) = ( Ias_relative( end ) - ss_relative( k )*cs_unit_relative( k )*Rs_relative( k )*Gms_relative( end ) )/( ss_relative( k )*cs_unit_relative( k )*Rs_relative( k ) - dEs_relative( k ) );           % [S] Synaptic Conductances (# synapses x 1).

end


%% Print Relative Linear Combination Subnetwork Parameters.

% Print out a header.
fprintf( '\n------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )
fprintf( 'RELATIVE LINEAR COMBINATION SUBNETWORK PARAMETERS:\n' )
fprintf( '------------------------------------------------------------\n' )

% Print out neuron information.
fprintf( 'Neuron Parameters:\n' )

% Print out the maximum membrane voltages.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the maximum membrane voltage for this neuron.
    fprintf( 'R%0.0f \t\t= \t%0.2f \t[mV]\n', k, Rs_relative( k )*( 10^3 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the membrane conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane conductance for this neuron.
    fprintf( 'Gm%0.0f \t= \t%0.2f \t[muS]\n', k, Gms_relative( k )*( 10^6 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the membrane capacitances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane capacitance for this neuron.
    fprintf( 'Cm%0.0f \t= \t%0.2f \t[nF]\n', k, Cms_relative( k )*( 10^9 ) )

end

% Print out the sodium channel conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the sodium channel conductance for this neuron.
    fprintf( 'Gna%0.0f \t= \t%0.2f \t[muS]\n', k, Gnas_relative( k )*( 10^6 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )

% Print out the synaptic reversal potentials.
for k = 1:num_synapses              % Iterate through each of the synapses....

    % Print the synaptic reversal potential for this synapse.
    fprintf( 'dEs%0.0f%0.0f \t= \t%0.2f \t[mV]\n', num_neurons, k, dEs_relative( k )*( 10^3 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the synaptic conductances.
for k = 1:num_synapses              % Iterate through each of the synapses...
   
    % Print the synaptic conductance for this synapse.
    fprintf( 'gs%0.0f%0.0f \t= \t%0.2f \t[muS]\n', num_neurons, k, gs_relative( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )

% Print out the applied currents.
for k = 1:num_neurons               % Iterate through each of the neurons...

    % Print out the applied current for this neuron.
    fprintf( 'Ia%0.0f \t= \t%0.2f \t[nA]\n', k, Ias_relative( k )*( 10^9 ) )
    
end

% Print out a new line.
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )

% Print the input gains.
for k = 1:num_synapses                   % Iterate through each of the synapses...
   
    % Print out the gain for this synapse.
    fprintf( 'c%0.0f \t\t= \t%0.2f \t[-]\n', k, cs_relative( k ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print the input signatures.
for k = 1:num_synapses                  % Iterate through each of the synpases...
   
    % Print out the signature for this synapse.
    fprintf( 's%0.0f \t\t= \t%0.0f \t\t[-]\n', k, ss_relative( k ) )
    
end

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Relative Linear Combination Subnetwork.

% Create an instance of the network class.
network_relative = network_class( network_dt, network_tf );

% Create the network components.
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( num_neurons );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( num_synapses );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( num_neurons );

% Set the neuron parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Rs_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Gms_relative, 'Gm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Cms_relative, 'Cm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Gnas_relative, 'Gna' );

% Set the synapse parameters.
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, 1:num_synapses, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, num_neurons, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, gs_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, dEs_relative, 'dE_syn' );

% Set the applied current parameters.
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, 1:num_neurons, 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_states; 0 ].*Ias_relative, 'I_apps' );


%% Convert the Relative Linear Combination Parameters to Fundamental Absolute Linear Combination Parameters.

% Convert the maximum membrane voltage array.
Rs_absolute = Rs_relative;                              % [V] Maximum Membrane Voltages (# neurons x 1).

% Convert the membrane conductance array.
Gms_absolute = Gms_relative;                            % [S] Membrane Conductance (# neurons x 1).

% Convert the membrane capacitance array.
Cms_absolute = Cms_relative;                            % [F] Membrane Capacitance (# neurons x 1).

% Convert the sodium channel conductance array.
Gnas_absolute = Gnas_relative;                          % [S] Sodium Channel Conductances (# neurons x 1).

% Convert the synaptic reversal potential array.
dEs_absolute = dEs_relative;                           	% [V] Synaptic Reversal Potentials (# synapses x 1).

% Convert the synaptic conductances array.
gs_absolute = gs_relative;                              % [V] Synaptic Conductance (# synapses x 1).

% Convert the applied current array.
Ias_absolute = Ias_relative;                            % [A] Applied Currents (# neurons x 1).

% Convert the input signature array.
ss_absolute = ss_relative;                            	% [-1/1] Input Signatures (# neurons - 1 x 1).


%% Compute the Derived Parameters of the Absolute Linear Combination Subnetwork.

% Compute the gains for the absolute linear combination subnetwork.
cs_absolute = cs_relative.*Rs_relative( end )./Rs_relative( 1:( end - 1 ) );


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
    fprintf( 'R%0.0f \t\t= \t%0.2f \t[mV]\n', k, Rs_absolute( k )*( 10^3 ) )

end

% Print out the membrane conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane conductance for this neuron.
    fprintf( 'Gm%0.0f \t= \t%0.2f \t[muS]\n', k, Gms_absolute( k )*( 10^6 ) )

end

% Print out the membrane capacitances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the membrane capacitance for this neuron.
    fprintf( 'Cm%0.0f \t= \t%0.2f \t[nF]\n', k, Cms_absolute( k )*( 10^9 ) )

end

% Print out the sodium channel conductances.
for k = 1:num_neurons               % Iterate through each of the neurons...
    
    % Print the sodium channel conductance for this neuron.
    fprintf( 'Gna%0.0f \t= \t%0.2f \t[muS]\n', k, Gnas_absolute( k )*( 10^6 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )

% Print out the synaptic reversal potentials.
for k = 1:num_synapses              % Iterate through each of the synapses....

    % Print the synaptic reversal potential for this synapse.
    fprintf( 'dEs%0.0f%0.0f \t= \t%0.2f \t[mV]\n', num_neurons, k, dEs_absolute( k )*( 10^3 ) )
    
end

% Print out the synaptic conductances.
for k = 1:num_synapses              % Iterate through each of the synapses...
   
    % Print the synaptic conductance for this synapse.
    fprintf( 'gs%0.0f%0.0f \t= \t%0.2f \t[muS]\n', num_neurons, k, gs_absolute( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )

% Print out the applied currents.
for k = 1:num_neurons               % Iterate through each of the neurons...

    % Print out the applied current for this neuron.
    fprintf( 'Ia%0.0f \t= \t%0.2f \t[nA]\n', k, Ias_absolute( k )*( 10^9 ) )
    
end

% Print out a new line.
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )

% Print the input gains.
for k = 1:num_synapses                   % Iterate through each of the synapses...
   
    % Print out the gain for this synapse.
    fprintf( 'c%0.0f \t\t= \t%0.2f \t[-]\n', k, cs_absolute( k ) )
    
end

% Print the input signatures.
for k = 1:num_synapses                  % Iterate through each of the synpases...
   
    % Print out the signature for this synapse.
    fprintf( 's%0.0f \t\t= \t%0.0f \t\t[-]\n', k, ss_absolute( k ) )
    
end

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create Absolute Linear Combination Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( num_neurons );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( num_synapses );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( num_neurons );

% Set the neuron parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Rs_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Gms_absolute, 'Gm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Cms_absolute, 'Cm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Gnas_absolute, 'Gna' );

% Set the synapse parameters.
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, 1:num_synapses, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, num_neurons, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, gs_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, dEs_absolute, 'dE_syn' );

% Set the applied current parameters.
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, 1:num_neurons, 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_states; 0 ].*Ias_absolute, 'I_apps' );


%% Simulate the Relative Linear Combination Subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network_relative, ts_relative, Us_relative, hs_relative, dUs_relative, dhs_relative, G_syns_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, m_infs_relative, h_infs_relative, tauhs_relative, neuron_IDs_relative ] = network_relative.compute_set_simulation(  );

% End the timer.
relative_simulation_duration = toc;


%% Simulate the Absolute Linear Combination Subnetwork.

% Start the timer.
tic

% Simulate the network.
[ network_absolute, ts_absolute, Us_absolute, hs_absolute, dUs_absolute, dhs_absolute, G_syns_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, m_infs_absolute, h_infs_absolute, tauhs_absolute, neuron_IDs_absolute ] = network_absolute.compute_set_simulation(  );

% End the timer.
absolute_simulation_duration = toc;


%% Plot the Linear Combination Subnetwork Results.

% Plot the network currents over time.
fig_relative_network_currents = network_relative.network_utilities.plot_network_currents( ts_relative, I_leaks_relative, I_syns_relative, I_nas_relative, I_apps_relative, I_totals_relative, neuron_IDs_relative );
fig_absolute_network_currents = network_absolute.network_utilities.plot_network_currents( ts_absolute, I_leaks_absolute, I_syns_absolute, I_nas_absolute, I_apps_absolute, I_totals_absolute, neuron_IDs_absolute );

% Plot the network states over time.
fig_relative_network_states = network_relative.network_utilities.plot_network_states( ts_relative, Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_states = network_absolute.network_utilities.plot_network_states( ts_absolute, Us_absolute, hs_absolute, neuron_IDs_absolute );

% Animate the network states over time.
fig_relative_network_animation = network_relative.network_utilities.animate_network_states( Us_relative, hs_relative, neuron_IDs_relative );
fig_absolute_network_animation = network_absolute.network_utilities.animate_network_states( Us_absolute, hs_absolute, neuron_IDs_absolute );

