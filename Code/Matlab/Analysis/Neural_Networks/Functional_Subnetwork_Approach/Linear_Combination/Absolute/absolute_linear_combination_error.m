%% Absolute Linear Combination Subnetwork Error.

% Clear Everything.
clear, close('all'), clc


%% Define Simulation Parameters.

% Define the save and load directories.
save_directory = '.\Save';                              % [str] Save Directory.
load_directory = '.\Load';                              % [str] Load Directory.

% Set a flag to determine whether to simulate.
b_simulate = false;                                      % [T/F] Simulation Flag. (Determines whether to create a new simulation of the steady state error or to load a previous simulation.)

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
Ias = cell2mat( network.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );             % [A] Applied Currents.

% Retrieve the synaptic conductances.
gs = network.get_gsynmaxs( 'all' );                                                             % [S] Synaptic Conductances.

% Retrieve the synaptic reversal potentials.
dEs = network.get_dEsyns( 'all' );                                                              % [V] Synaptic Reversal Potential.

% Define the numerical stability timestep.
dt0 = 1e-6;                                                                                     % [s] Numerical Stability Time Step.

% Define the number of evaluation points.
num_eval_points = 20;

% Preallocte a cell array to store the membrane voltage inputs.
Us_inputs = cell( num_neurons - 1, 1 );

% Create a cell of the membrane voltage inputs.
for k = 1:( num_neurons - 1 )           % Iterate through each of the input neurons...
    
    % Generate the membrane voltages for this input.
    Us_inputs{ k } = linspace( 0, Rs( k ), num_eval_points );
    
end

% Preallocate a cell array to store the membrane voltage input grid.
Us_inputs_grid_cell = cell( num_neurons - 1, 1 );

% Create an input grid.
[ Us_inputs_grid_cell{ : } ] = ndgrid( Us_inputs{ : } );

% Stack the input grid.
Us_inputs_grid = cat( num_neurons, Us_inputs_grid_cell{ : } );

% Construct the input grid mask.
grid_mask = repmat( { ':' }, [ 1, num_neurons - 1 ] );

% Retrieve the grid dimensions.
grid_dims = size( Us_inputs_grid( grid_mask{ : }, 1 ) );

% Flatten the input grid.
Us_inputs_flat = reshape( Us_inputs_grid, [ numel( Us_inputs_grid( grid_mask{ : }, 1 ) ), num_neurons - 1 ] );

% Compute the desired and achieved absolute linear combination steady state output.
Us_outputs_flat_desired = network.compute_desired_absolute_linear_combination_steady_state_output( Us_inputs_flat, cs, ss );
[ Us_outputs_flat_achieved, As, dts, condition_numbers ] = network.achieved_linear_combination_RK4_stability_analysis( Us_inputs_flat, Cms, Gms, Rs, Ias, gs, dEs, dt0 );

% Convert the flat steady state output results to grids.
dts_grid = reshape( dts, grid_dims );
condition_numbers_grid = reshape( condition_numbers, grid_dims );
Us_outputs_grid_desired = reshape( Us_outputs_flat_desired, grid_dims );
Us_outputs_grid_achieved = reshape( Us_outputs_flat_achieved, grid_dims );

% Retrieve the maximum RK4 step size and condition number.
[ dt_max, indexes_dt ] = min( dts );
[ condition_number_max, indexes_condition_number ] = max( condition_numbers );


%% Print the Desired and Achieved Absolute Linear Combination Formulation Results.

% Print out the stability information.
fprintf( 'STABILITY SUMMARY:\n' )
fprintf( 'Linearized System Matrix: A =\n\n' ), disp( As( :, :, indexes_condition_number ) )
fprintf( [ 'Max RK4 Step Size: \t\tdt_max = %0.3e [s] @ [ ', repmat( '%0.2f ', [ 1, num_neurons - 1 ] ) ,'] [mV] \n' ], dt_max, Us_inputs_flat( indexes_dt, : )*( 10^3 ) )
fprintf( 'Proposed Step Size: \tdt = %0.3e [s]\n', network_dt )
fprintf( [ 'Condition Number: \t\tcond( A ) = %0.3e [-] @ [ ', repmat( '%0.2f ', [ 1, num_neurons - 1 ] ) ,'] [mV] \n' ], condition_number_max, Us_inputs_flat( indexes_condition_number, : )*( 10^3 ) )


%% Plot the Desired and Achieved Absolute Linear Combination Formulation Results.

% Determine how to plot the absolute linear combination formulation results.
if num_neurons == 2                 % If there are two neurons...
    
    % Plot the desired and achieved linear combination formulation results.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Theory' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Output), U2 [mV]' ), title( 'Absolute Linear Combination Theory' )
    plot( Us_inputs_flat, Us_outputs_flat_desired, '-', 'Linewidth', 3 )
    plot( Us_inputs_flat, Us_outputs_flat_achieved, '--', 'Linewidth', 3 )
    legend( 'Desired', 'Achieved' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_theory' ] )
    
    % Plot the RK4 maximum timestep.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination RK4 Maximum Timestep' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'Absolute Linear Combination RK4 Maximum Timestep' )
    plot( Us_inputs_flat, dts, '-', 'Linewidth', 3 )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_rk4_maximum_timestep' ] )
    
    % Plot the linearized system condition numbers.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Condition Numbers' ); hold on, grid on, xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Condition Number [-]' ), title( 'Absolute Linear Combination Condition Number' )
    plot( Us_inputs_flat, condition_numbers, '-', 'Linewidth', 3 )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_condition_numbers' ] )
    
elseif num_neurons == 3             % If there are three neurons...
    
    % Switch the first two dimensions of the grids for plotting.
    Us_inputs_grid_plot = permute( Us_inputs_grid, [ 2, 1, 3 ] );
    Us_outputs_grid_desired_plot = Us_outputs_grid_desired';
    Us_outputs_grid_achieved_plot = Us_outputs_grid_achieved';
    dts_grid_plot = dts_grid';
    condition_numbers_grid_plot = condition_numbers_grid';
    
    % Plot the desired and achieved linear combination formulation results.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Theory' ); hold on, grid on, rotate3d on, view( -45, 30 ), xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Membrane Voltage 3 (Output), U2 [mV]' ), title( 'Absolute Linear Combination Theory' )
    surf( Us_inputs_grid_plot( grid_mask{ : }, 1 ), Us_inputs_grid_plot( grid_mask{ : }, 2 ), Us_outputs_grid_desired_plot, 'Edgecolor', 'None', 'Facecolor', 'b', 'Facealpha', 0.5 )
    surf( Us_inputs_grid_plot( grid_mask{ : }, 1 ), Us_inputs_grid_plot( grid_mask{ : }, 2 ), Us_outputs_grid_achieved_plot, 'Edgecolor', 'None', 'Facecolor', 'r', 'Facealpha', 0.5 )
    legend( { 'Desired', 'Achieved' }, 'Orientation', 'Horizontal', 'Location', 'Best' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_theory' ] )
    
    % Plot the RK4 maximum timestep.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination RK4 Maximum Timestep' ); hold on, grid on, rotate3d on, view( 60, 30 ), xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'RK4 Maximum Timestep, dt [s]' ), title( 'Absolute Linear Combination RK4 Maximum Timestep' )
    surf( Us_inputs_grid_plot( grid_mask{ : }, 1 ), Us_inputs_grid_plot( grid_mask{ : }, 2 ), dts_grid_plot, 'Edgecolor', 'None', 'Facecolor', 'Interp' )
    scatter3( Us_inputs_flat( :, 1 ), Us_inputs_flat( :, 2 ), dts, 15, 'black', 'filled' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_rk4_maximum_timestep' ] )
    
    % Plot the linearized system condition numbers.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Condition Numbers' ); hold on, grid on, rotate3d on, view( 60, 30 ), xlabel( 'Membrane Voltage 1 (Input), U1 [mV]' ), ylabel( 'Membrane Voltage 2 (Input), U2 [mV]' ), zlabel( 'Condition Number [-]' ), title( 'Absolute Linear Combination Condition Number' )
    surf( Us_inputs_grid_plot( grid_mask{ : }, 1 ), Us_inputs_grid_plot( grid_mask{ : }, 2 ), condition_numbers_grid_plot, 'Edgecolor', 'None', 'Facecolor', 'Interp' )
    scatter3( Us_inputs_flat( :, 1 ), Us_inputs_flat( :, 2 ), condition_numbers, 15, 'black', 'filled' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_condition_numbers' ] )
    
else                % Otherwise...
    
    % Throw a warning.
    warning( 'Can not visualize absolute linear combination formulation results for more than two input neurons.' )
    
end

%% Simulate the Absolute Linear Combination Network.

% Determine whether to simulate the network.
if b_simulate               % If we want to simulate the network....
    
    % Define the number of applied currents.
    num_eval_points = 10*ones( num_neurons - 1, 1 );
    
    % Preallocte a cell array to store the applied voltages.
    applied_currents = cell( num_neurons - 1, 1 );
    
    % Create a cell of the membrane voltage inputs.
    for k = 1:( num_neurons - 1 )           % Iterate through each of the input neurons...
        
        % Generate the membrane voltages for this input.
        applied_currents{ k } = linspace( 0, Rs( k )*Gms( k ), num_eval_points( k ) );
        
    end
    
    % Preallocate a cell array to store the applied current grid.
    applied_currents_grid_cell = cell( num_neurons - 1, 1 );
    
    % Create an applied current grid.
    [ applied_currents_grid_cell{ : } ] = ndgrid( applied_currents{ : } );
    
    % Stack the applied current grid.
    applied_currents_grid = cat( num_neurons, applied_currents_grid_cell{ : } );
    
    % Construct the applied current grid mask.
    grid_mask = repmat( { ':' }, [ 1, num_neurons - 1 ] );
    
    % Retrieve the applied current grid dimensions.
    grid_dims = size( applied_currents_grid( grid_mask{ : }, 1 ) );
    
    % Flatten the input grid.
    applied_currents_flat = reshape( applied_currents_grid, [ numel( applied_currents_grid( grid_mask{ : }, 1 ) ), num_neurons - 1 ] );
    
    % Retrieve the number of applied currents.
    num_applied_currents = size( applied_currents_flat, 1 );
    
    % Create a matrix to store the membrane voltages.
    Us_achieved_flat = zeros( num_applied_currents, num_neurons );
    
    % Simulate the network for each of the applied current combinations.
    for k1 = 1:num_applied_currents                      % Iterate through each of the applied currents...
        
        % Create applied currents.
        for k2 = 1:( num_neurons - 1 )                   % Iterate through each of the input neurons...
        
            % Set the applied current for this input neuron.
            network.applied_current_manager = network.applied_current_manager.set_applied_current_property( applied_current_IDs( k2 ), applied_currents_flat( k1, k2 ), 'I_apps' );
        
        end
        
        % Simulate the network.
        [ network, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = network.compute_set_simulation(  );
        
        % Retrieve the final membrane voltages.
        Us_achieved_flat( k1, : ) = Us( :, end );
        
    end
    
    % Convert the achieved membrane voltages into a grid.
    Us_achieved_grid = reshape( Us_achieved_flat, [ grid_dims, num_neurons ] );
    
    % Save the simulation results.
    save( [ save_directory, '\', 'absolute_linear_combination_subnetwork_error' ], 'grid_mask', 'grid_dims', 'applied_currents_flat', 'applied_currents_grid', 'Us_achieved_flat', 'Us_achieved_grid' )
    
else                % Otherwise... (We must want to load data from an existing simulation...)
    
    % Load the simulation results.
    data = load( [ load_directory, '\', 'absolute_linear_combination_subnetwork_error' ] );
    
    % Store the simulation results in separate variables.
    grid_mask = data.grid_mask;
    grid_dims = data.grid_dims;
    applied_currents_flat = data.applied_currents_flat;
    applied_currents_grid = data.applied_currents_grid;
    Us_achieved_flat = data.Us_achieved_flat;
    Us_achieved_grid = data.Us_achieved_grid;
    
end


%% Compute the Absolute Linear Combination Subnetwork Error.

% Compute the flat desired membrane voltage ouputs.
Us_outputs_desired_flat = network.compute_desired_absolute_linear_combination_steady_state_output( Us_achieved_flat( :, 1:( end - 1 ) ), cs, ss );

% Construct teh flat desired membrane voltages.
Us_desired_flat = Us_achieved_flat; Us_desired_flat( :, end ) = Us_outputs_desired_flat;

% Convert the desired membrane voltages into a grid.
Us_desired_grid = reshape( Us_desired_flat, [ grid_dims, num_neurons ] );

% Compute the error between the achieved and desired results.
error_flat = Us_achieved_flat( :, end ) - Us_desired_flat( :, end );

% Convert the flat error to a grid.
error_grid = reshape( error_flat, grid_dims );

% Compute the mean squared error summary statistic.
mse = sqrt( sum( error_flat.^2, 'all' ) );


%% Plot the Absolute Linear Combination Subnetwork Results.

% Determine how to plot the absolute linear combination simulation results.
if num_neurons == 2                 % If there are two neurons...
    
    % Create a plot of the desired membrane voltage output.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Desired)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Desired)' )
    plot( Us_desired_flat( :, 1 ), Us_desired_flat( :, 2 ), '-', 'Linewidth', 3 )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_desired' ] )
    
    % Create a plot of the achieved membrane voltage output.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Achieved)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Achieved)' )
    plot( Us_achieved_flat( :, 1 ), Us_achieved_flat( :, 2 ), '-', 'Linewidth', 3 )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_achieved' ] )
    
    % Create a plot of the desired and achieved membrane voltage outputs.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Comparison)' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Comparison)' )
    h1 = plot( Us_desired_flat( :, 1 ), Us_desired_flat( :, 2 ), '-', 'Linewidth', 3 );
    h2 = plot( Us_inputs_flat, Us_outputs_flat_achieved, '--', 'Linewidth', 3 );
    h3 = plot( Us_achieved_flat( :, 1 ), Us_achieved_flat( :, 2 ), '.', 'Linewidth', 3 );
    legend( [ h1, h2, h3 ], { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_comparison' ] )
    
    % Create a surface that shows the membrane voltage error.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Error' ); hold on, grid on, xlabel( 'Membrane Voltage of Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Output Neuron, U2 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Error' )
    plot( Us_achieved_flat( :, 1 ), error_flat, '-', 'Linewidth', 3 )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_error' ] )


elseif num_neurons == 3             % If there are three neurons...
    
    % Switch the first two dimensions of the grids for plotting.
    Us_desired_grid_plot = permute( Us_desired_grid, [ 2, 1, 3 ] );        
    Us_achieved_grid_plot = permute( Us_achieved_grid, [ 2, 1, 3 ] );
    error_grid_plot = error_grid';
    
    % Create a surface that shows the desired membrane voltage output.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Desired)' ); hold on, grid on, rotate3d on, view( -45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Desired)' )
    surf( Us_desired_grid_plot( grid_mask{ : }, 1 ), Us_desired_grid_plot( grid_mask{ : }, 2 ), Us_desired_grid_plot( grid_mask{ : }, 3 ), 'EdgeColor', 'None', 'FaceColor', 'Interp' )
    scatter3( Us_desired_flat( :, 1 ), Us_desired_flat( :, 2 ), Us_desired_flat( :, 3 ), 15, 'black', 'filled' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_desired' ] )

    % Create a surface that shows the achieved membrane voltage output.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Achieved)' ); hold on, grid on, rotate3d on, view( -45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Achieved)' )
    surf( Us_achieved_grid_plot( grid_mask{ : }, 1 ), Us_achieved_grid_plot( grid_mask{ : }, 2 ), Us_achieved_grid_plot( grid_mask{ : }, 3 ), 'EdgeColor', 'None', 'FaceColor', 'Interp' )
    scatter3( Us_achieved_flat( :, 1 ), Us_achieved_flat( :, 2 ), Us_achieved_flat( :, 3 ), 15, 'black', 'filled' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_achieved' ] )

    % Create a figure that shows the differences between the achieved and desired membrane voltage outputs.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Response (Comparison)' ); hold on, grid on, rotate3d on, view( -45, 15 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage of Output Neuron, U3 [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Response (Comparison)' )
    surf( Us_desired_grid_plot( grid_mask{ : }, 1 ), Us_desired_grid_plot( grid_mask{ : }, 2 ), Us_desired_grid_plot( grid_mask{ : }, 3 ), 'EdgeColor', 'None', 'FaceColor', 'b', 'FaceAlpha', 0.5 )
    surf( Us_inputs_grid_plot( grid_mask{ : }, 1 ), Us_inputs_grid_plot( grid_mask{ : }, 2 ), Us_outputs_grid_achieved_plot, 'EdgeColor', 'None', 'FaceColor', 'g', 'FaceAlpha', 0.5 )
    surf( Us_achieved_grid_plot( grid_mask{ : }, 1 ), Us_achieved_grid_plot( grid_mask{ : }, 2 ), Us_achieved_grid_plot( grid_mask{ : }, 3 ), 'EdgeColor', 'None', 'FaceColor', 'r', 'FaceAlpha', 0.5 )
    legend( { 'Desired', 'Achieved (Theory)', 'Achieved (Numerical)' }, 'Location', 'Best' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_comparison' ] )

    % Create a surface that shows the membrane voltage error.
    fig = figure( 'Color', 'w', 'Name', 'Absolute Linear Combination Subnetwork Steady State Error' ); hold on, grid on, rotate3d on, view( -45, 45 ), xlabel( 'Membrane Voltage of First Input Neuron, U1 [V]' ), ylabel( 'Membrane Voltage of Second Input Neuron, U2 [V]' ), zlabel( 'Membrane Voltage Error, E [V]' ), title( 'Absolute Linear Combination Subnetwork Steady State Error' )
    surf( Us_achieved_grid_plot( grid_mask{ : }, 1 ), Us_achieved_grid_plot( grid_mask{ : }, 2 ), error_grid_plot, 'EdgeColor', 'None', 'FaceColor', 'Interp' )
    scatter3( Us_achieved_flat( :, 1 ), Us_achieved_flat( :, 2 ), error_flat, 15, 'black', 'filled' )
    saveas( fig, [ save_directory, '\', 'absolute_linear_combination_ss_response_error' ] )

else                % Otherwise...
    
    % Throw a warning.
    warning( 'Can not visualize absolute linear combination simulation results for more than two input neurons.' )
    
end
