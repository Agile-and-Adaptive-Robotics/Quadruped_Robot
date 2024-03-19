%% Linear Combination Subnetwork Encoding Comparison.

% Clear Everything.
clear, close( 'all' ), clc


%% Initialize Project Options.

% Define the save and load directories.
save_directory = '.\Save';                                                              % [str] Save Directory.
load_directory = '.\Load';                                                              % [str] Load Directory.

% Define the network simulation time step.
% network_dt = 1e-3;                                                                    % [s] Simulation Time Step.
network_dt = 1e-5;                                                                      % [s] Simulation Time Step.

% Define the network simulation duration.
network_tf = 3;     


%% Define Basic Absolute Linear Combination Subnetwork Parameters.

% Define the maximum membrane voltages.
R1_absolute = 20e-3;                                             % [V] Maximum Membrane Voltages (Neuron 1).
R2_absolute = 20e-3;                                             % [V] Maximum Membrane Voltage (Neuron 2).

% Define the membrane conductances.
Gm1_absolute = 1e-6;                                             % [S] Membrane Conductance (Neuron 1).
Gm2_absolute = 1e-6;                                             % [S] Membrane Conductance (Neuron 2).
Gm3_absolute = 1e-6;                                             % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1_absolute = 5e-9;                                             % [F] Membrane Capacitance (Neuron 1).
Cm2_absolute = 5e-9;                                             % [F] Membrane Capacitance (Neuron 2).
Cm3_absolute = 5e-9;                                             % [F] Membrane Capacitance (Neuron 3).

% Define the sodium channel conductances.
Gna1_absolute = 0;                                               % [S] Sodium Channel Conductance (Neuron 1).
Gna2_absolute = 0;                                               % [S] Sodium Channel Conductance (Neuron 2).
Gna3_absolute = 0;                                               % [S] Sodium Channel Conductance (Neuron 3).

% Define the synaptic reversal potentials.
dEs31_absolute = 194e-3;                                         % [V] Synaptic Reversal Potential (Synapse 31).
dEs32_absolute = -194e-3;                                        % [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1_absolute = R1_absolute*Gm1_absolute;                                           % [A] Applied Current (Neuron 1)
Ia2_absolute = R2_absolute*Gm2_absolute;                                           % [A] Applied Current (Neuron 2).
Ia3_absolute = 0;                                                % [A] Applied Current (Neuron 3).

% Define the current states.
current_state1_absolute = 0;                                     % [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)
current_state2_absolute = 0;                                  % [-] Current State (Neuron 2). (Specified as a ratio of the total applied current that is active.)

% Define the subnetwork design constants.
c1_absolute = 1;                                                 % [-] Design Constant 1.
c2_absolute = 1;                                                 % [-] Design Constant 2.

% Define the input signatures.
s1_absolute = 1;                                                 % [-1/1] Input Signature 1.
s2_absolute = -1;                                                % [-1/1] Input Signature 2.


%% Compute Absolute Linear Combination Subnetwork Parameter Arrays.

% Construct the maximum membrane voltage array.
Rs_absolute = [ R1_absolute; R2_absolute; 0 ];                                     % [V] Maximum Membrane Voltages (# neurons x 1).

% Construct the membrane conductance array.
Gms_absolute = [ Gm1_absolute; Gm2_absolute; Gm3_absolute ];                                % [S] Membrane Conductance (# neurons x 1).

% Construct the membrane capacitance array.
Cms_absolute = [ Cm1_absolute; Cm2_absolute; Cm3_absolute ];                                % [F] Membrane Capacitance (# neurons x 1).

% Construct the sodium channel conductance array.
Gnas_absolute = [ Gna1_absolute; Gna2_absolute; Gna3_absolute ];                            % [S] Sodium Channel Conductances (# neurons x 1).

% Construct the synaptic reversal potential array.
dEs_absolute = [ dEs31_absolute; dEs32_absolute ];                                 % [V] Synaptic Reversal Potentials (# synapses x 1).

% Construct the applied current array.
Ias_absolute = [ Ia1_absolute; Ia2_absolute; Ia3_absolute ];                                % [A] Applied Currents (# neurons x 1).

% Construct the current state array.
current_states_absolute = [ current_state1_absolute; current_state2_absolute ];    % [-] Current States (# neurons - 1 x 1).

% Construct the design constant array.
cs_absolute = [ c1_absolute; c2_absolute ];                                        % [-] Input Gains (# neurons - 1 x 1).

% Construct the input signature array.
ss_absolute = [ s1_absolute; s2_absolute ];                                        % [-1/1] Input Signatures (# neurons - 1 x 1).


%% Compute Derived Absolute Linear Combination Subnetwork Constraints.

% Compute network structure information.
num_neurons_absolute = length( Rs_absolute );                                         % [#] Number of Neurons.
num_synapses_absolute = length( dEs_absolute );                                       % [#] Number of Synapses.

% Retrieve the input maximum membrane voltages.
Rs_inputs_absolute = Rs_absolute( 1:end - 1 );                                        % [V] Maximum Membrane Voltages of Input Neurons.

% Retrieve the input indexes associated with excitatory and inhibitory inputs.
i_excitatory_absolute = ss_absolute == 1;                                             % [#] Excitatory Input Neuron Indexes.
i_inhibitory_absolute = ss_absolute == -1;                                            % [#] Inhibitory Input Neuron Indexes.

% Compute the maximum membrane voltages required for the excitatory and inhibitory inputs.
Rn_inhibitory_absolute = cs_absolute( i_inhibitory_absolute )'*Rs_inputs_absolute( i_inhibitory_absolute );     	% [V] Maximum Membrane Voltage To Capture Inhibitory Neuron Inputs.
Rn_excitatory_absolute = cs_absolute( i_excitatory_absolute )'*Rs_inputs_absolute( i_excitatory_absolute );     	% [V] Maximum Membrane Voltage To Capture Excitatory Neuron Inputs.

% Compute the maximum membrane voltage of the output neuron.
Rn_absolute = max( Rn_inhibitory_absolute, Rn_excitatory_absolute );                           % [V] Maximum Membrane Voltage (Output Neuron).

% Add the maximum membrane voltage of the output neuron to the maximum membrane voltage array.
Rs_absolute( end ) = Rn_absolute;                                                     % [V] Maximum Membrane Voltages (# neurons x 1).

% Preallocate an array to store the synaptic conductances.
gs_absolute = zeros( num_synapses_absolute, 1 );                                      % [S] Synaptic Conductances (# synapses x 1).

% Compute the synaptic conductaances.
for k = 1:num_synapses_absolute                                              % Iterate through each of the synapses...
    
    % Compute the synaptic conductance associated with this synapse.
    gs_absolute( k ) = ( Ias_absolute( end ) - ss_absolute( k )*cs_absolute( k )*Rs_absolute( k )*Gms_absolute( end ) )/( ss_absolute( k )*cs_absolute( k )*Rs_absolute( k ) - dEs_absolute( k ) );           % [S] Synaptic Conductances (# synapses x 1).
    
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
for k = 1:num_neurons_absolute               % Iterate through each of the neurons...
    
    % Print the maximum membrane voltage for this neuron.
    fprintf( 'R%0.0f \t\t= \t%0.2f \t[mV]\n', k, Rs_absolute( k )*( 10^3 ) )
    
end

% Print out the membrane conductances.
for k = 1:num_neurons_absolute               % Iterate through each of the neurons...
    
    % Print the membrane conductance for this neuron.
    fprintf( 'Gm%0.0f \t= \t%0.2f \t[muS]\n', k, Gms_absolute( k )*( 10^6 ) )
    
end

% Print out the membrane capacitances.
for k = 1:num_neurons_absolute               % Iterate through each of the neurons...
    
    % Print the membrane capacitance for this neuron.
    fprintf( 'Cm%0.0f \t= \t%0.2f \t[nF]\n', k, Cms_absolute( k )*( 10^9 ) )
    
end

% Print out the sodium channel conductances.
for k = 1:num_neurons_absolute               % Iterate through each of the neurons...
    
    % Print the sodium channel conductance for this neuron.
    fprintf( 'Gna%0.0f \t= \t%0.2f \t[muS]\n', k, Gnas_absolute( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )

% Print out the synaptic reversal potentials.
for k = 1:num_synapses_absolute              % Iterate through each of the synapses....
    
    % Print the synaptic reversal potential for this synapse.
    fprintf( 'dEs%0.0f%0.0f \t= \t%0.2f \t[mV]\n', num_neurons_absolute, k, dEs_absolute( k )*( 10^3 ) )
    
end

% Print out the synaptic conductances.
for k = 1:num_synapses_absolute              % Iterate through each of the synapses...
    
    % Print the synaptic conductance for this synapse.
    fprintf( 'gs%0.0f%0.0f \t= \t%0.2f \t[muS]\n', num_neurons_absolute, k, gs_absolute( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )

% Print out the applied currents.
for k = 1:num_neurons_absolute               % Iterate through each of the neurons...
    
    % Print out the applied current for this neuron.
    fprintf( 'Ia%0.0f \t= \t%0.2f \t[nA]\n', k, Ias_absolute( k )*( 10^9 ) )
    
end

% Print out a new line.
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )

% Print the input gains.
for k = 1:num_synapses_absolute                   % Iterate through each of the synapses...
    
    % Print out the gain for this synapse.
    fprintf( 'c%0.0f \t\t= \t%0.2f \t[-]\n', k, cs_absolute( k ) )
    
end

% Print the input signatures.
for k = 1:num_synapses_absolute                  % Iterate through each of the synpases...
    
    % Print out the signature for this synapse.
    fprintf( 's%0.0f \t\t= \t%0.0f \t\t[-]\n', k, ss_absolute( k ) )
    
end

% Print out ending information.
fprintf( '------------------------------------------------------------\n' )
fprintf( '------------------------------------------------------------\n' )


%% Create an Absolute Linear Combination Subnetwork.

% Create an instance of the network class.
network_absolute = network_class( network_dt, network_tf );

% Create the network components.
[ network_absolute.neuron_manager, neuron_IDs_absolute ] = network_absolute.neuron_manager.create_neurons( num_neurons_absolute );
[ network_absolute.synapse_manager, synapse_IDs_absolute ] = network_absolute.synapse_manager.create_synapses( num_synapses_absolute );
[ network_absolute.applied_current_manager, applied_current_IDs_absolute ] = network_absolute.applied_current_manager.create_applied_currents( num_neurons_absolute );

% Set the neuron parameters.
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Rs_absolute, 'R' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Gms_absolute, 'Gm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Cms_absolute, 'Cm' );
network_absolute.neuron_manager = network_absolute.neuron_manager.set_neuron_property( neuron_IDs_absolute, Gnas_absolute, 'Gna' );

% Set the synapse parameters.
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, 1:num_synapses_absolute, 'from_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, num_neurons_absolute, 'to_neuron_ID' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, gs_absolute, 'g_syn_max' );
network_absolute.synapse_manager = network_absolute.synapse_manager.set_synapse_property( synapse_IDs_absolute, dEs_absolute, 'dE_syn' );

% Set the applied current parameters.
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, 1:num_neurons_absolute, 'neuron_ID' );
network_absolute.applied_current_manager = network_absolute.applied_current_manager.set_applied_current_property( applied_current_IDs_absolute, [ current_states_absolute; 0 ].*Ias_absolute, 'I_apps' );


%% Define Relative Linear Combination Subnetwork Parameters.

% Define the maximum membrane voltages.
R1_relative = 20e-3;                                             % [V] Maximum Membrane Voltages (Neuron 1).
R2_relative = 20e-3;                                             % [V] Maximum Membrane Voltage (Neuron 2).
R3_relative = 20e-3;                                             % [V] Maximum Membrane Voltage (Neuron 3).

% Define the membrane conductances.
Gm1_relative = 1e-6;                                             % [S] Membrane Conductance (Neuron 1).
Gm2_relative = 1e-6;                                             % [S] Membrane Conductance (Neuron 2).
Gm3_relative = 1e-6;                                             % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1_relative = 5e-9;                                             % [F] Membrane Capacitance (Neuron 1).
Cm2_relative = 5e-9;                                             % [F] Membrane Capacitance (Neuron 2).
Cm3_relative = 5e-9;                                             % [F] Membrane Capacitance (Neuron 3).

% Define the sodium channel conductances.
Gna1_relative = 0;                                               % [S] Sodium Channel Conductance (Neuron 1).
Gna2_relative = 0;                                               % [S] Sodium Channel Conductance (Neuron 2).
Gna3_relative = 0;                                               % [S] Sodium Channel Conductance (Neuron 3).

% Define the synaptic reversal potentials.
dEs31_relative = 194e-3;                                         % [V] Synaptic Reversal Potential (Synapse 31).
dEs32_relative = -194e-3;                                        % [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1_relative = R1_relative*Gm1_relative;                                           % [A] Applied Current (Neuron 1)
Ia2_relative = R2_relative*Gm2_relative;                                           % [A] Applied Current (Neuron 2).
Ia3_relative = 0;                                                % [A] Applied Current (Neuron 3).

% Define the current states.
current_state1_relative = 1;                                     % [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)
current_state2_relative = 0.25;                                  % [-] Current State (Neuron 2). (Specified as a ratio of the total applied current that is active.)

% Define the subnetwork design constants.
c1_relative = 1;                                                 % [-] Design Constant 1.
c2_relative = 1;                                                 % [-] Design Constant 2.

% Define the input signatures.
s1_relative = 1;                                                 % [-1/1] Input Signature 1.
s2_relative = -1;                                                % [-1/1] Input Signature 2.


%% Compute Relative Linear Combination Subnetwork Parameter Arrays.

% Construct the maximum membrane voltage array.
Rs_relative = [ R1_relative; R2_relative; R3_relative ];                                     % [V] Maximum Membrane Voltages (# neurons x 1).

% Construct the membrane conductance array.
Gms_relative = [ Gm1_relative; Gm2_relative; Gm3_relative ];                                % [S] Membrane Conductance (# neurons x 1).

% Construct the membrane capacitance array.
Cms_relative = [ Cm1_relative; Cm2_relative; Cm3_relative ];                                % [F] Membrane Capacitance (# neurons x 1).

% Construct the sodium channel conductance array.
Gnas_relative = [ Gna1_relative; Gna2_relative; Gna3_relative ];                            % [S] Sodium Channel Conductances (# neurons x 1).

% Construct the synaptic reversal potential array.
dEs_relative = [ dEs31_relative; dEs32_relative ];                                 % [V] Synaptic Reversal Potentials (# synapses x 1).

% Construct the applied current array.
Ias_relative = [ Ia1_relative; Ia2_relative; Ia3_relative ];                                % [A] Applied Currents (# neurons x 1).

% Construct the current state array.
current_states_relative = [ current_state1_relative; current_state2_relative ];    % [-] Current States (# neurons - 1 x 1).

% Construct the design constant array.
cs_relative = [ c1_relative; c2_relative ];                                        % [-] Input Gains (# neurons - 1 x 1).

% Construct the input signature array.
ss_relative = [ s1_relative; s2_relative ];                                        % [-1/1] Input Signatures (# neurons - 1 x 1).


%% Compute Derived Relative Linear Combination Subnetwork Constraints.

% Compute network structure information.
num_neurons_relative = length( Rs_relative );                                         % [#] Number of Neurons.
num_synapses_relative = length( dEs_relative );                                       % [#] Number of Synapses.

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
gs_relative = zeros( num_synapses_relative, 1 );                                      % [S] Synaptic Conductances (# synapses x 1).

% Compute the synaptic conductaances.
for k = 1:num_synapses_relative                                              % Iterate through each of the synapses...
    
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
for k = 1:num_neurons_relative               % Iterate through each of the neurons...
    
    % Print the maximum membrane voltage for this neuron.
    fprintf( 'R%0.0f \t\t= \t%0.2f \t[mV]\n', k, Rs_relative( k )*( 10^3 ) )

end

% Print out the membrane conductances.
for k = 1:num_neurons_relative               % Iterate through each of the neurons...
    
    % Print the membrane conductance for this neuron.
    fprintf( 'Gm%0.0f \t= \t%0.2f \t[muS]\n', k, Gms_relative( k )*( 10^6 ) )

end

% Print out the membrane capacitances.
for k = 1:num_neurons_relative               % Iterate through each of the neurons...
    
    % Print the membrane capacitance for this neuron.
    fprintf( 'Cm%0.0f \t= \t%0.2f \t[nF]\n', k, Cms_relative( k )*( 10^9 ) )

end

% Print out the sodium channel conductances.
for k = 1:num_neurons_relative               % Iterate through each of the neurons...
    
    % Print the sodium channel conductance for this neuron.
    fprintf( 'Gna%0.0f \t= \t%0.2f \t[muS]\n', k, Gnas_relative( k )*( 10^6 ) )

end

% Print a new line.
fprintf( '\n' )

% Print out the synapse information.
fprintf( 'Synapse Parameters:\n' )

% Print out the synaptic reversal potentials.
for k = 1:num_synapses_relative              % Iterate through each of the synapses....

    % Print the synaptic reversal potential for this synapse.
    fprintf( 'dEs%0.0f%0.0f \t= \t%0.2f \t[mV]\n', num_neurons_relative, k, dEs_relative( k )*( 10^3 ) )
    
end

% Print out the synaptic conductances.
for k = 1:num_synapses_relative              % Iterate through each of the synapses...
   
    % Print the synaptic conductance for this synapse.
    fprintf( 'gs%0.0f%0.0f \t= \t%0.2f \t[muS]\n', num_neurons_relative, k, gs_relative( k )*( 10^6 ) )
    
end

% Print a new line.
fprintf( '\n' )

% Print out the applied current information.
fprintf( 'Applied Curent Parameters:\n' )

% Print out the applied currents.
for k = 1:num_neurons_relative               % Iterate through each of the neurons...

    % Print out the applied current for this neuron.
    fprintf( 'Ia%0.0f \t= \t%0.2f \t[nA]\n', k, Ias_relative( k )*( 10^9 ) )
    
end

% Print out a new line.
fprintf( '\n' )

% Print out the network design parameters.
fprintf( 'Network Design Parameters:\n' )

% Print the input gains.
for k = 1:num_synapses_relative                   % Iterate through each of the synapses...
   
    % Print out the gain for this synapse.
    fprintf( 'c%0.0f \t\t= \t%0.2f \t[-]\n', k, cs_relative( k ) )
    
end

% Print the input signatures.
for k = 1:num_synapses_relative                  % Iterate through each of the synpases...
   
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
[ network_relative.neuron_manager, neuron_IDs_relative ] = network_relative.neuron_manager.create_neurons( num_neurons_relative );
[ network_relative.synapse_manager, synapse_IDs_relative ] = network_relative.synapse_manager.create_synapses( num_synapses_relative );
[ network_relative.applied_current_manager, applied_current_IDs_relative ] = network_relative.applied_current_manager.create_applied_currents( num_neurons_relative );

% Set the neuron parameters.
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Rs_relative, 'R' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Gms_relative, 'Gm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Cms_relative, 'Cm' );
network_relative.neuron_manager = network_relative.neuron_manager.set_neuron_property( neuron_IDs_relative, Gnas_relative, 'Gna' );

% Set the synapse parameters.
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, 1:num_synapses_relative, 'from_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, num_neurons_relative, 'to_neuron_ID' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, gs_relative, 'g_syn_max' );
network_relative.synapse_manager = network_relative.synapse_manager.set_synapse_property( synapse_IDs_relative, dEs_relative, 'dE_syn' );

% Set the applied current parameters.
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, 1:num_neurons_relative, 'neuron_ID' );
network_relative.applied_current_manager = network_relative.applied_current_manager.set_applied_current_property( applied_current_IDs_relative, [ current_states_relative; 0 ].*Ias_relative, 'I_apps' );



%% Load the Absolute & Relative Linear Combination Subnetworks.

% Load the simulation results.
absolute_linear_combination_simulation_data = load( [ load_directory, '\', 'absolute_linear_combination_subnetwork_error' ] );
relative_linear_combination_simulation_data = load( [ load_directory, '\', 'relative_linear_combination_subnetwork_error' ] );

% Store the absolute simulation results in separate variables.
grid_mask_absolute = absolute_linear_combination_simulation_data.grid_mask;
grid_dims_absolute = absolute_linear_combination_simulation_data.grid_dims;
applied_currents_flat_absolute = absolute_linear_combination_simulation_data.applied_currents_flat;
applied_currents_grid_absolute = absolute_linear_combination_simulation_data.applied_currents_grid;
Us_achieved_flat_absolute = absolute_linear_combination_simulation_data.Us_achieved_flat;
Us_achieved_grid_absolute = absolute_linear_combination_simulation_data.Us_achieved_grid;

% Store the relative simulation results in separate variables.
grid_mask_relative = relative_linear_combination_simulation_data.grid_mask;
grid_dims_relative = relative_linear_combination_simulation_data.grid_dims;
applied_currents_flat_relative = relative_linear_combination_simulation_data.applied_currents_flat;
applied_currents_grid_relative = relative_linear_combination_simulation_data.applied_currents_grid;
Us_achieved_flat_relative = relative_linear_combination_simulation_data.Us_achieved_flat;
Us_achieved_grid_relative = relative_linear_combination_simulation_data.Us_achieved_grid;


%% Compute the Error in the Steady State Linea Combination Subnetwork Responses.

% Compute the desired steady state output membrane voltage.
Us_desired_flat_absolute_output = network_absolute.compute_desired_absolute_linear_combination_steady_state_output( Us_achieved_flat_absolute( :, 1:( end - 1 ) ), cs_absolute, ss_absolute );
Us_desired_flat_relative_output = network_relative.compute_desired_relative_linear_combination_steady_state_output( Us_achieved_flat_relative( :, 1:( end - 1 ) ), Rs_relative, cs_relative, ss_relative );

% Construct desired steady state membrane voltage arrays.
Us_desired_flat_absolute = Us_achieved_flat_absolute; Us_desired_flat_absolute( :, end ) = Us_desired_flat_absolute_output;
Us_desired_flat_relative = Us_achieved_flat_relative; Us_desired_flat_relative( :, end ) = Us_desired_flat_relative_output;

% Construct the desired steady state membrane votlage grids.
Us_desired_grid_absolute = reshape( Us_desired_flat_absolute, [ grid_dims_absolute, num_neurons_absolute ] );
Us_desired_grid_relative = reshape( Us_desired_flat_relative, [ grid_dims_relative, num_neurons_relative ] );

% Compute the error between the achieved and desired results.
error_flat_absolute = Us_achieved_flat_absolute( :, end ) - Us_desired_flat_absolute( :, end );
error_flat_relative = Us_achieved_flat_relative( :, end ) - Us_desired_flat_relative( :, end );

% Convert the flat error to a grid.
error_grid_absolute = reshape( error_flat_absolute, grid_dims_absolute );
error_grid_relative = reshape( error_flat_relative, grid_dims_relative );

% Compute the percent error between the achieve and desired results.
error_flat_absolute_percent = 100*( error_flat_absolute/Rs_absolute( end ) );
error_flat_relative_percent = 100*( error_flat_relative/Rs_relative( end ) );

% Convert the flat error percentage to a grid.
error_grid_absolute_percent = reshape( error_flat_absolute_percent, grid_dims_absolute );
error_grid_relative_percent = reshape( error_flat_relative_percent, grid_dims_relative );

% Compute the mean squared error summary statistic.
mse_absolute = ( 1/numel( error_flat_absolute ) )*sqrt( sum( error_flat_absolute.^2, 'all' ) );
mse_relative = ( 1/numel( error_flat_relative ) )*sqrt( sum( error_flat_relative.^2, 'all' ) );

% Compute the mean error percentage.
mse_absolute_percent = 100*( mse_absolute/Rs_absolute( end ) );
mse_relative_percent = 100*( mse_relative/Rs_relative( end ) );

% Compute the standard deviation of the error.
std_absolute = std( error_flat_absolute, 0, 'all' );
std_relative = std( error_flat_relative, 0, 'all' );

% Compute the standard deviation of the error percentage.
std_absolute_percent = 100*( std_absolute/Rs_absolute( end ) );
std_relative_percent = 100*( std_relative/Rs_relative( end ) );

% Compute the maximum errors.
[ error_absolute_max, index_absolute_max ] = max( abs( error_flat_absolute ), [  ], 'all', 'linear' );
[ error_relative_max, index_relative_max ] = max( abs( error_flat_relative ), [  ], 'all', 'linear' );

% Compute the maximum error percentages.
error_absolute_max_percent = 100*( error_absolute_max/Rs_absolute( end ) );
error_relative_max_percent = 100*( error_relative_max/Rs_relative( end ) );

% Compute the minimum errors.
[ error_absolute_min, index_absolute_min ] = min( abs( error_flat_absolute ), [  ], 'all', 'linear' );
[ error_relative_min, index_relative_min ] = min( abs( error_flat_relative ), [  ], 'all', 'linear' );

% Compute the minimum error percentages.
error_absolute_min_percent = 100*( error_absolute_min/Rs_absolute( end ) );
error_relative_min_percent = 100*( error_relative_min/Rs_relative( end ) );

% Compute the range of the error.
error_absolute_range = error_absolute_max - error_absolute_min;
error_relative_range = error_relative_max - error_relative_min;

% Compute the range of the error percentages.
error_absolute_range_percent = 100*( error_absolute_range/Rs_absolute( end ) );
error_relative_range_percent = 100*( error_relative_range/Rs_relative( end ) );

% Compute the difference in error between the absolute and relative encoding schemes.
error_difference_flat = abs( error_flat_relative ) - abs( error_flat_absolute );
error_difference_flat_percent = abs( error_flat_relative_percent ) - abs( error_flat_absolute_percent );

% Convert the flat error difference to a grid.
error_difference_grid = reshape( error_difference_flat, grid_dims_absolute );
error_difference_grid_percent = reshape( error_difference_flat_percent, grid_dims_absolute );

% Compute the mean squared error difference.
error_difference_mse = abs( mse_relative ) - abs( mse_absolute );
error_difference_mse_percent = abs( mse_relative_percent ) - abs( mse_absolute_percent );

% Compute the standard deviation difference.
error_difference_std = abs( std_relative ) - abs( std_absolute );
error_difference_std_percent = abs( std_relative_percent ) - abs( std_absolute_percent );

% Compute the maximum error difference.
error_difference_max = abs( error_relative_max ) - abs( error_absolute_max );
error_difference_max_percent = abs( error_relative_max_percent ) - abs( error_absolute_max_percent );


%% Print Out the Linear Combination Subnetwork Summary Information.

% Print out the absolute division summary statistics.
fprintf( 'Absolute Linear Combination Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_absolute, mse_absolute_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_absolute, std_absolute_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_max, error_absolute_max_percent, Us_achieved_flat_absolute( index_absolute_max, 1 ), Us_achieved_flat_absolute( index_absolute_max, 2 ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_absolute_min, error_absolute_min_percent, Us_achieved_flat_absolute( index_absolute_min, 1 ), Us_achieved_flat_absolute( index_absolute_min, 2 ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_absolute_range, error_absolute_range_percent )

fprintf( '\n' )
fprintf( 'Relative Linear Combination Summary Statistics\n' )
fprintf( 'MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', mse_relative, mse_relative_percent )
fprintf( 'STD: \t\t\t%9.3e [mV] (%6.2f [%%])\n', std_relative, std_relative_percent )
fprintf( 'Max Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_max, error_relative_max_percent, Us_achieved_flat_relative( index_relative_max, 1 ), Us_achieved_flat_relative( index_relative_max, 2 ), 20e-3 )
fprintf( 'Min Error: \t\t%9.3e [mV] (%6.2f [%%]) @ (%9.3e [mV], %9.3e [mV], %9.3e [mV])\n', error_relative_min, error_relative_min_percent, Us_achieved_flat_relative( index_relative_min, 1 ), Us_achieved_flat_relative( index_relative_min, 2 ), 20e-3 )
fprintf( 'Range Error: \t%0.3e [mV] (%6.2f [%%])\n', error_relative_range, error_relative_range_percent )

fprintf( '\n' )
fprintf( 'Absolute vs Relative Linear Combination Summary Statistics:\n' )
fprintf( 'delta MSE: \t\t\t%9.3e [mV] (%6.2f [%%])\n', error_difference_mse, error_difference_mse_percent )
fprintf( 'delta STD:\t%9.3e [V] (%6.2f [%%])\n', error_difference_std, error_difference_std_percent )
fprintf( 'delta Max Error:\t%9.3e [mV] (%6.2f [%%])\n', error_difference_max, error_difference_max_percent )


%% Convert Linear Combination Grids to Plotting Grids.

% Convert the absolute grids to plotting grids.
Us_desired_grid_absolute_plot = permute( Us_desired_grid_absolute, [ 2, 1, 3 ] );        
Us_achieved_grid_absolute_plot = permute( Us_achieved_grid_absolute, [ 2, 1, 3 ] );
error_grid_absolute_plot = error_grid_absolute';
error_grid_absolute_percent_plot = error_grid_absolute_percent';

% Convert the relative grids to plotting grids.
Us_desired_grid_relative_plot = permute( Us_desired_grid_relative, [ 2, 1, 3 ] );        
Us_achieved_grid_relative_plot = permute( Us_achieved_grid_relative, [ 2, 1, 3 ] );
error_grid_relative_plot = error_grid_relative';
error_grid_relative_percent_plot = error_grid_relative_percent';

% Convert the error difference grid to a plotting grid.
error_difference_grid_plot = error_difference_grid';
error_difference_grid_percent_plot = error_difference_grid_percent';


%% Plot the Steady State Linear Combination Subnetwork Error Surfaces.

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, view( -45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Linear Combination Steady State Response (Comparison)' )
surf( Us_desired_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_desired_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), Us_desired_grid_absolute_plot( grid_mask_absolute{ : }, 3 )*( 10^3 ), 'EdgeColor', 'None', 'FaceColor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 3 )*( 10^3 ), 'EdgeColor', 'None', 'FaceColor', 'r', 'FaceAlpha', 0.75 )
% scatter3( Us_desired_flat_absolute( :, 1 ), Us_desired_flat_absolute( :, 2 ), Us_desired_flat_absolute( :, 3 ), 15, 'black', 'filled', 'MarkerFaceAlpha', 0.25 )
% scatter3( Us_desired_flat_absolute( :, 1 ), Us_desired_flat_absolute( :, 2 ), Us_desired_flat_absolute( :, 3 ), 15, 'red', 'filled', 'MarkerFaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_comparison' ] )

% Create a surface that shows the desired membrane voltage output.
fig = figure( 'Color', 'w', 'Name', 'Relative Linear Combination Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, view( -45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Relative Linear Combination Steady State Response (Comparison)' )
surf( Us_desired_grid_relative_plot( grid_mask_relative{ : }, 1 )*(10^3), Us_desired_grid_relative_plot( grid_mask_relative{ : }, 2 )*(10^3), Us_desired_grid_relative_plot( grid_mask_relative{ : }, 3 )*(10^3), 'EdgeColor', 'None', 'FaceColor', 'k', 'FaceAlpha', 0.25 )
surf( Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 1 )*(10^3), Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 2 )*(10^3), Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 3 )*(10^3), 'EdgeColor', 'None', 'FaceColor', 'r', 'FaceAlpha', 0.75 )
% scatter3( Us_desired_flat_relative( :, 1 ), Us_desired_flat_relative( :, 2 ), Us_desired_flat_relative( :, 3 ), 15, 'black', 'filled', 'MarkerFaceAlpha', 0.25 )
% scatter3( Us_desired_flat_relative( :, 1 ), Us_desired_flat_relative( :, 2 ), Us_desired_flat_relative( :, 3 ), 15, 'red', 'filled', 'MarkerFaceAlpha', 0.75 )
legend( { 'Desired', 'Achieved' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
saveas( fig, [ save_directory, '\', 'relative_linear_combination_ss_response_comparison' ] )

% Create a surface that shows the membrane voltage error.
fig = figure( 'Color', 'w', 'Name', 'Achieved Linear Combination Steady State Error' ); hold on, grid on, rotate3d on, view( 45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error, E [mV]' ), title( 'Achieved Linear Combination Steady State Error' )
surf( Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), error_grid_absolute_plot*( 10^3 ), 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 1 )*( 10^3 ), Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 2 )*( 10^3 ), error_grid_relative_plot*( 10^3 ), 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% colormap( get_bichromatic_colormap(  ) ), colorbar(  )
saveas( fig, [ save_directory, '\', 'linear_combination_error_comparison.png' ] )

% Create a surface that shows the membrane voltage error percentage.
fig = figure( 'Color', 'w', 'Name', 'Achieved Linear Combination Steady State Error Percentage' ); hold on, grid on, rotate3d on, view( 45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Percentage, E [%]' ), title( 'Achieved Linear Combination Steady State Error Percentage' )
surf( Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), error_grid_absolute_percent_plot, 'Edgecolor', 'None', 'Facecolor', 'r', 'FaceAlpha', 0.75 )
surf( Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 1 )*( 10^3 ), Us_achieved_grid_relative_plot( grid_mask_relative{ : }, 2 )*( 10^3 ), error_grid_relative_percent_plot, 'Edgecolor', 'None', 'Facecolor', 'b', 'FaceAlpha', 0.75 )
legend( { 'Absolute', 'Relative' }, 'Location', 'Bestoutside', 'Orientation', 'Horizontal' )
% colormap( get_bichromatic_colormap(  ) ), colorbar(  )
saveas( fig, [ save_directory, '\', 'linear_combination_error_percentage_comparison.png' ] )

% Create a surface that shows the difference in error between the absolute and relative division subnetworks.
fig = figure( 'Color', 'w', 'Name', 'Linear Combination Steady State Error Difference' ); hold on, grid on, rotate3d on, view( 45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference, dE [mV]' ), title( 'Linear Combination Steady State Error Difference' )
surf( Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), error_difference_grid_plot*( 10^3 ), 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
% colormap( get_bichromatic_colormap(  ) ), colorbar(  )
saveas( fig, [ save_directory, '\', 'linear_combination_error_difference.png' ] )

% Create a surface that shows the difference in error between the absolute and relative percent division subnetworks.
fig = figure( 'Color', 'w', 'Name', 'Linear Combination Steady State Error Percentage Difference' ); hold on, grid on, rotate3d on, view( 45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [mV]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [mV]' ), zlabel( 'Membrane Voltage Error Difference Percentage, dE [%]' ), title( 'Linear Combination Steady State Error Percentage Difference' )
surf( Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 1 )*( 10^3 ), Us_achieved_grid_absolute_plot( grid_mask_absolute{ : }, 2 )*( 10^3 ), error_difference_grid_percent_plot, 'Edgecolor', 'Interp', 'Facecolor', 'Interp' )
% colormap( get_bichromatic_colormap(  ) ), colorbar(  )
saveas( fig, [ save_directory, '\', 'linear_combination_error_percentage_difference.png' ] )

