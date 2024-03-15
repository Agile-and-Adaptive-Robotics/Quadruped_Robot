%% Absolute Linear Combination Subnetwork Error.

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                              % [str] Save Directory.
load_directory = '.\Load';                              % [str] Load Directory.

% Set a flag to determine whether to simulate.
b_simulate = true;                                      % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

% Set the level of verbosity.
b_verbose = true;                                       % [T/F] Printing Flag. (Determines whether to print out information.)

% Define the network simulation timestep.
network_dt = 1e-4;                                      % [s] Simulation Timestep.

% Define the network simulation duration.
network_tf = 3;                                         % [s] Simulation Duration.


%% Define Absolute Linear Combination Subnetwork Parameters.

% Define the maximum membrane voltages.
R1 = 20e-3;                                             % [V] Maximum Membrane Voltages (Neuron 1).
R2 = 20e-3;                                             % [V] Maximum Membrane Voltage (Neuron 2).

% Define the membrane conductances.
Gm1 = 1e-6;                                             % [S] Membrane Conductance (Neuron 1).
Gm2 = 1e-6;                                             % [S] Membrane Conductance (Neuron 2).
Gm3 = 1e-6;                                             % [S] Membrane Conductance (Neuron 3).

% Define the membrane capacitances.
Cm1 = 5e-9;                                             % [F] Membrane Capacitance (Neuron 1).
Cm2 = 5e-9;                                             % [F] Membrane Capacitance (Neuron 2).
Cm3 = 5e-9;                                             % [F] Membrane Capacitance (Neuron 3).

% Define the sodium channel conductances.
Gna1 = 0;                                               % [S] Sodium Channel Conductance (Neuron 1).
Gna2 = 0;                                               % [S] Sodium Channel Conductance (Neuron 2).
Gna3 = 0;                                               % [S] Sodium Channel Conductance (Neuron 3).

% Define the synaptic reversal potentials.
dEs31 = 194e-3;                                         % [V] Synaptic Reversal Potential (Synapse 31).
dEs32 = -194e-3;                                        % [V] Synaptic Reversal Potential (Synapse 32).

% Define the applied currents.
Ia1 = R1*Gm1;                                           % [A] Applied Current (Neuron 1)
Ia2 = R2*Gm2;                                           % [A] Applied Current (Neuron 2).
Ia3 = 0;                                                % [A] Applied Current (Neuron 3).

% Define the current states.
current_state1 = 1;                                     % [-] Current State (Neuron 1). (Specified as a ratio of the total applied current that is active.)
current_state2 = 0.25;                                  % [-] Current State (Neuron 2). (Specified as a ratio of the total applied current that is active.)

% Define the subnetwork design constants.
c1 = 1;                                                 % [-] Design Constant 1.
c2 = 1;                                                 % [-] Design Constant 2.

% Define the input signatures.
s1 = 1;                                                 % [-1/1] Input Signature 1.
s2 = -1;                                                % [-1/1] Input Signature 2.


%% Compute Absolute Linear Combination Subnetwork Parameter Arrays.

% Construct the maximum membrane voltage array.
Rs = [ R1; R2; 0 ];                                     % [V] Maximum Membrane Voltages (# neurons x 1).

% Construct the membrane conductance array.
Gms = [ Gm1; Gm2; Gm3 ];                                % [S] Membrane Conductance (# neurons x 1).

% Construct the membrane capacitance array.
Cms = [ Cm1; Cm2; Cm3 ];                                % [F] Membrane Capacitance (# neurons x 1).

% Construct the sodium channel conductance array.
Gnas = [ Gna1; Gna2; Gna3 ];                            % [S] Sodium Channel Conductances (# neurons x 1).

% Construct the synaptic reversal potential array.
dEs = [ dEs31; dEs32 ];                                 % [V] Synaptic Reversal Potentials (# synapses x 1).

% Construct the applied current array.
Ias = [ Ia1; Ia2; Ia3 ];                                % [A] Applied Currents (# neurons x 1).

% Construct the current state array.
current_states = [ current_state1; current_state2 ];    % [-] Current States (# neurons - 1 x 1).

% Construct the design constant array.
cs = [ c1; c2 ];                                        % [-] Input Gains (# neurons - 1 x 1).

% Construct the input signature array.
ss = [ s1; s2 ];                                        % [-1/1] Input Signatures (# neurons - 1 x 1).


%% Compute Derived Absolute Linear Combination Subnetwork Constraints.

% Compute network structure information.
num_neurons = length( Rs );                                         % [#] Number of Neurons.
num_synapses = length( dEs );                                       % [#] Number of Synapses.

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


%% Compute Desired & Achieved Absolute Inversion Formulations.

% Retrieve the maximum membrane voltages.
Rs = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'R' ) );                      % [V] Maximum Membrane Voltages.

% Retrieve the membrane capacitances.
Cms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Cm' ) );                    % [F] Membrane Capacitances.

% Retrieve the membrane conductances.
Gms = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'Gm' ) );                    % [S] Membrane Conductances.

% Retrieve the applied currents.
% Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );             % [A] Applied Currents.
Ias = [ 0, Ia2 ];                                                                               % [A] Applied Currents.

% Retrieve the synaptic conductances.
gs = network.get_gsynmaxs( 'all' );                                                             % [S] Synaptic Conductances.

% Retrieve the synaptic reversal potentials.
dEs = network.get_dEsyns( 'all' );                                                              % [V] Synaptic Reversal Potential.

% Define the numerical stability timestep.
dt0 = 1e-6;                                                                                     % [s] Numerical Stability Time Step.

% Define the division subnetwork inputs.
U1s = linspace( 0, Rs( 1 ), 20  );
U2s = linspace( 0, Rs( 2 ), 20  );

% Create an input grid.
[ U1s_grid, U2s_grid ] = meshgrid( U1s, U2s );

% Create the input points.
U1s_flat = reshape( U1s_grid, [ numel( U1s_grid ), 1 ] );
U2s_flat = reshape( U2s_grid, [ numel( U2s_grid ), 1 ] );

Us_flat_desired_absolute_output = network.compute_desired_absolute_linear_combination_steady_state_output( Us_inputs, cs, ss );

% Compute the desired and achieved absolute division steady state output.
U3s_flat_desired_absolute = network.compute_desired_absolute_division_steady_state_output( [ U1s_flat, U2s_flat ], c1, c2, c3 );
[ U3s_flat_achieved_absolute, As, dts, condition_numbers ] = network.achieved_division_RK4_stability_analysis( U1s_flat, U2s_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts, size( U1s_grid ) );
condition_numbers_grid = reshape( condition_numbers, size( U1s_grid ) );
U3s_grid_desired_absolute = reshape( U3s_flat_desired_absolute, size( U1s_grid ) );
U3s_grid_achieved_absolute = reshape( U3s_flat_achieved_absolute, size( U1s_grid ) );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = min( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Desired and Achieved Absolute Inversion Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ %0.2f [mV]\n', dt_max, U1s_flat( indexes_dt )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( 'Condition Number: \t\tcond( A ) = %0.3e [-] @ %0.2f [mV]\n', condition_number_max, U1s_flat( indexes_condition_number )*( 10^3 ) )


% %% Plot the Desired and Achieved Absolute Inversion Formulation Results.
% 
% % Plot the desired and achieved relative inversion formulation results.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Theory' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Output), U2 [mV]' ), title( 'Absolute Inversion Theory' )
% plot( U1s_flat, U2s_flat_desired_absolute, '-', 'Linewidth', 3 )
% plot( U1s_flat, U2s_flat_achieved_absolute, '--', 'Linewidth', 3 )
% legend( 'Desired', 'Achieved' )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_theory' ] )
% 
% % Plot the RK4 maximum timestep.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion RK4 Maximum Timestep' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'Absolute Inversion RK4 Maximum Timestep' )
% plot( U1s_flat, dts, '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_rk4_maximum_timestep' ] )
% 
% % Plot the linearized system condition numbers.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Condition Numbers' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Condition Number [-]' ), title( 'Absolute Inversion Condition Number' )
% plot( U1s_flat, condition_numbers, '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_condition_numbers' ] )
% 
% 
% %% Simulate the Absolute Inversion Network.
% 
% % Determine whether to simulate the network.
% if b_simulate               % If we want to simulate the network....
%     
%     % Define the number of applied currents to use.
%     n_applied_currents = 20;                                    % [#] Number of Applied Currents.
%     
%     % Create the applied currents.
% %     applied_currents = linspace( 0, network.neuron_manager.neurons( 2 ).R*network.neuron_manager.neurons( 2 ).Gm, n_applied_currents );
%     applied_currents = linspace( 0, network.neuron_manager.neurons( 1 ).R*network.neuron_manager.neurons( 1 ).Gm, n_applied_currents );
% 
%     % Create a matrix to store the membrane voltages.
%     Us_achieved = zeros( n_applied_currents, num_neurons );
%     
%     % Simulate the network for each of the applied current combinations.
%     for k = 1:n_applied_currents                          % Iterate through each of the currents applied to the input neuron...
%             
%             % Create applied currents.
%             network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( 1 ), applied_currents( k ), 'I_apps' );
% 
%             % Simulate the network.
%             [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
%             
%             % Retrieve the final membrane voltages.
%             Us_achieved( k, : ) = Us( :, end );
%             
%     end
% 
%     % Save the simulation results.
%     save( [ save_directory, '\', 'absolute_inversion_subnetwork_error' ], 'applied_currents', 'Us_achieved' )
%     
% else                % Otherwise... ( We must want to load data from an existing simulation... )
%     
%     % Load the simulation results.
%     data = load( [ load_directory, '\', 'absolute_inversion_subnetwork_error' ] );
%     
%     % Store the simulation results in separate variables.
%     applied_currents = data.applied_currents;
%     Us_achieved = data.Us_achieved;
% 
% end
% 
% 
% %% Compute the Absolute Inversion Network Error.
% 
% % Compute the desired membrane voltage output.
% Us_desired_output =  c1./( c2*Us_achieved( :, 1 ) + c3 );
% 
% % Compute the desired membrane voltage output.
% Us_desired = Us_achieved; Us_desired( :, end ) = Us_desired_output;
% 
% % Compute the error between the achieved and desired results.
% error = Us_achieved( :, end ) - Us_desired( :, end );
% 
% % Compute the mean squared error summary statistic.
% mse = sqrt( sum( error.^2, 'all' ) );
% 
% 
% %% Plot the Absolute Inversion Network Results.
% 
% % Create a plot of the desired membrane voltage output.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Subnetwork Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Inversion Subnetwork Steady State Response (Desired)' )
% plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_desired' ] )
% 
% % Create a plot of the achieved membrane voltage output.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Subnetwork Steady State Response (Achieved)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Inversion Subnetwork Steady State Response (Achieved)' )
% plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_achieved' ] )
% 
% % Create a plot of the desired and achieved membrane voltage outputs.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Subnetwork Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Inversion Subnetwork Steady State Response (Comparison)' )
% h1 = plot( Us_desired( :, 1 ), Us_desired( :, 2 ), '-', 'Linewidth', 3 );
% h2 = plot( U1s_flat, U2s_flat_achieved_absolute, '--', 'Linewidth', 3 );
% h3 = plot( Us_achieved( :, 1 ), Us_achieved( :, 2 ), '.', 'Linewidth', 3 );
% legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best' )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_comparison' ] )
% 
% % Create a surface that shows the membrane voltage error.
% fig = figure( 'Color', 'w', 'Name', 'Absolute Inversion Subnetwork Steady State Error' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Inversion Subnetwork Steady State Error' )
% plot( Us_achieved( :, 1 ), error, '-', 'Linewidth', 3 )
% saveas( fig, [ save_directory, '\', 'absolute_inversion_ss_response_error' ] )

