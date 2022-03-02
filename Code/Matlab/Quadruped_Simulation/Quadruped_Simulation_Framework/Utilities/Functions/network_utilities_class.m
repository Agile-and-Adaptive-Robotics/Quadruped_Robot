classdef network_utilities_class
    
    % This class contains properties and methods related to network utilities.
    
    
    %% NETWORK UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        array_utilities
        neuron_utilities
        numerical_method_utilities
        
    end
    
    
    %% NETWORK UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_utilities_class(  )
            
            % Create an instance of the array utilities class.
            self.array_utilities = array_utilities_class(  );
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
            % Create an instance of the numerical methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );
            
        end
        
        
        %% Synapse Functions
        
        % Implement a function to compute the synpatic conductance of a synapse leaving this neuron.
        function G_syn = compute_Gsyn( ~, U, R, g_syn_max )
            
            % Compute the synaptic conductance associated with this neuron.
            G_syn = g_syn_max.*( min( max( U'./R, 0 ), 1 ) );
            
        end
        
        
        % Implement a function to compute synaptic current.
        function I_syn = compute_Isyn( ~, U, G_syn, dE_syn )
            
            % Compute the synaptic current.
            I_syn = sum( G_syn.*( dE_syn - U ), 2 );
            
        end
        
        
        % Implement a function to perform a synaptic current step.
        function [ I_syn, G_syn ] = Isyn_step( self, U, R, g_syn_max, dE_syn )
            
            % Compute the synaptic conductance of this synapse leaving this neuron.
            G_syn = self.compute_Gsyn( U, R, g_syn_max );
            
            % Compute the synaptic current for this neuron.
            I_syn = self.compute_Isyn( U, G_syn, dE_syn );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance.
        function g_syn_max_vector = compute_cpg_gsynmax_vector( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Iapps_tonic )
            
            % This function computes the maximum synaptic conductances for a chain of CPGs necessary to achieve the specified deltas with the given network properties.
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Define an anonymous function that is the opposite of the kronecker delta function.
            neq = @( a, b ) 1 - eq( a, b );
            
            % Compute the number of equations we need to solve.
            num_eqs = num_neurons.*( num_neurons - 1 );
            
            % Preallocate an array to store the system matrix and right-hand side.
            A = zeros( num_eqs, num_eqs );
            b = zeros( num_eqs, 1 );
            
            % Compute the system matrix and right-hand side entries.
            for k = 1:num_neurons               % Iterate through each of the neurons...
                
                % Compute the critical index p.
                p = mod( k, num_neurons ) + 1;
                
                % Compute the system matrix and right-hand side entries.
                for i = 1:num_neurons           % Iterate through each of the neurons...
                    
                    % Determine whether to compute system matrix and right-hand side entries for this synapse.
                    if i ~= k                   % If this synapse is not a self-connection...
                        
                        % Compute the leak current.
                        I_leak = self.neuron_utilities.compute_Ileak( deltas(i, k), Gms(i) );
                        
                        % Compute the sodium channel steady state activation and deactivation parameters.
                        m_inf = self.neuron_utilities.compute_mhinf( deltas(i, k), Ams(i), Sms(i), dEms(i) );
                        h_inf = self.neuron_utilities.compute_mhinf( deltas(i, k), Ahs(i), Shs(i), dEhs(i) );
                        
                        % Compute the sodium channel current.
                        I_na = self.neuron_utilities.compute_Ina( deltas(i, k), h_inf, m_inf, Gnas(i), dEnas(i) );
                        
                        % Compute the system and right-hand side coefficients.
                        aik1 = deltas( i, k ) - dEsyns( i, k );
                        aik2 = neq( p, k ).*( deltas( p, k )./Rs( p, k ) ).*( deltas( i, k ) - dEsyns( p, k ) );
                        bik = I_leak + I_na + Iapps_tonic(i);
                        
                        % Determine the row index at which to store these coefficients.
                        r = ( num_neurons - 1 ).*( k - 1 ) + i;
                        
                        % Determine whether to correct the row entry.
                        if i > k                % If this is an entry whose row index needs to be corrected...
                            
                            % Correct the row entry.
                            r = r - 1;
                            
                        end
                        
                        % Determine the column index at which to store the first coefficient.
                        c1 = ( num_neurons - 1 ).*( i - 1 ) + k;
                        
                        % Determine whether the first column index needs to be corrected.
                        if k > i                % If this is an entry whose first column index needs to be corrected...
                            
                            % Correct the first column index.
                            c1 = c1 - 1;
                            
                        end
                        
                        % Determine the column index at which to store the second coefficient.
                        c2 = ( num_neurons - 1 ).*( p - 1 ) + k;
                        
                        % Determine whether the second column index needs to be corrected.
                        if k > p                % If this is an entry whose second column index needs to be corrected...
                            
                            % Correct the second column index.
                            c2 = c2 - 1;
                            
                        end
                        
                        % Store the first and second system matrix coefficients.
                        A( r, c1 ) = A( r, c1 ) + aik1;
                        A( r, c2 ) = A( r, c2 ) + aik2;
                        
                        % Store the right-hand side coefficient.
                        b(r) = bik;
                        
                    end
                    
                end
            end
            
            % Solve the system of equations.
            g_syn_max_vector = A\b;
            
        end
        
        
        % Implement a function to convert a maximum synaptic conductance vector to a maximum synaptic conductance matrix.
        function g_syn_max_matrix = gsynmax_vector2gsynmax_matrix( ~, g_syn_max_vector, num_neurons )
            
            %             % Compute the number of neurons.
            %             num_neurons = sqrt( length( g_syn_max_vector ) );
            
            %             % Ensure that the number of neurons is an integer.
            %             assert( num_neurons == round( num_neurons ), 'Number of maximum synaptic conductances length( g_syn_max ) must be a perfect square.' )
            %
            % Preallocate the synaptic conductance matrix.
            g_syn_max_matrix = zeros( num_neurons );
            
            % Initialize the previous row variable.
            row_prev = 0;
            
            % Store each of the synaptic conductance vector entries into the synaptic conductance matrix.
            for k = 1:length( g_syn_max_vector )            % Iterate through each synaptic conductance...
                
                % Compute the relevant remainder and quotient.
                r = mod( k - 1, num_neurons - 1 );
                q = ( k - r - 1 )/( num_neurons - 1 );
                
                % Compute the row associated with this entry.
                row = q + 1;
                
                % Determine whether to reset the column associated with this entry.
                if row ~= row_prev              % If the current row is different than the previous row...
                    
                    % Reset the column index.
                    col = 0;
                    
                end
                
                % Advance the column index.
                col = col + 1;
                
                % Determine whether the column index needs to be advanced a second time.
                if row == col           % If this column would yield an entry on the diagonal...
                    
                    % Advance the column index a second time.
                    col = col + 1;
                    
                end
                
                % Store the current synaptic conductance vector entry into the correct synaptic conductance matrix location.
                g_syn_max_matrix( row, col ) = g_syn_max_vector(k);
                
                % Store the current row as the previous row for the next iteration.
                row_prev = row;
                
            end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance matrix.
        function g_syn_max_matrix = compute_cpg_gsynmax_matrix( self, deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics )
            
            % Compute the maximum synaptic conductance vector.
            g_syn_max_vector = self.compute_cpg_gsynmax_vector( deltas, Gms, Rs, dEsyns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
            
            % Retrieve the number of neurons.
            num_neurons = length( Gms );
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_max_matrix = self.gsynmax_vector2gsynmax_matrix( g_syn_max_vector, num_neurons );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for an signal transmission pathway.
        function g_syn_maxs12 = compute_transmission_gsynmax( ~, Gm2, Rs1, dE_syns12, I_app2, k )
            
            % Set the default input arguments.
            if nargin < 6, k = 1; end
            if nargin < 5, I_app2 = 0; end
            
            % NEED TO UPDATE THE FOLLOWING ASSERTION TO CONSIDER A POSSIBLE APPLIED CURRENT.
            
            % Ensure that the synaptic reversal potential is large enough.
            assert( all( dE_syns12 > k*Rs1 ), 'It is not possible to design an addition subnetwork with the specified gain k = %0.2f [-] given the current synaptic reversal potential dEsyn = %0.2f [V] and neuron operating domain R = %0.2f [V].  To fix this problem, ensure that dEsyn > k*R.', k, dE_syns12, Rs1 )
            
            % Compute the maximum synaptic conductances for an addition subnetwork.
            g_syn_maxs12 = ( I_app2 - k*Gm2*Rs1 )./( k*Rs1 - dE_syns12 );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for an addition subnetwork.
        function g_syn_maxs12 = compute_addition_gsynmax( self, Gm2, Rs1, dE_syns12, I_app2, k )
            
            % Set the default input arguments.
            if nargin < 6, k = 1; end
            if nargin < 5, I_app2 = 0; end
            
            % Compute the maximum synaptic conductances in the same way as for a transmission subnetwork.
            g_syn_maxs12 = self.compute_transmission_gsynmax( Gm2, Rs1, dE_syns12, I_app2, k );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a subtraction subnetwork.
        function [ g_syn_maxs1, g_syn_maxs2 ] = compute_subtraction_gsynmax( self, Gm3, Rs1, dE_syns13, dE_syns23, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 7, k = 1; end
            if nargin < 6, I_app3 = 0; end
            
            % NEED TO UPDATE THE FOLLOWING ASSERTION TO CONSIDER A POSSIBLE APPLIED CURRENT.
            
            % Ensure that the synaptic reversal potential is large enough.
            assert( all( dE_syns13 > k*Rs1 ), 'It is not possible to design an subtraction subnetwork with the specified gain k = %0.2f [-] given the current synaptic reversal potential dEsyn = %0.2f [V] and neuron operating domain R = %0.2f [V].  To fix this problem, ensure that dEsyn > k*R.', k, dE_syns13, Rs1 )
            
            % Compute the maximum synaptic conductances for the first neuron of the substraction subnetwork.            
            g_syn_maxs1 = self.compute_transmission_gsynmax( Gm3, Rs1, dE_syns13, I_app3, k );

            % Compute the maximum synaptic conductances for the second neuron of the subtraction subnetwork.
            g_syn_maxs2 = -( dE_syns13*g_syn_maxs1 + Iapp3 )/dE_syns23;
            
        end
        
        
        %% Simulation Functions
        
        % Implement a function to perform a single simulation step.
        function [ dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = simulation_step( self, Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps )
            
            % This function computes a single step of a neural network without sodium channels.
            
            % Inputs:
            % Us = num_neurons x 1 vector of neuron membrane voltages w.r.t. their resting potentials.
            % hs = num_neurons x 1 vector of neuron sodium channel deactivation parameters.
            % Gms = num_neurons x 1 vector of neuron membrane conductances.
            % Cms = num_neurons x 1 vector of neuron membrane capacitances.
            % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            % g_syn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            % dE_syns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            % I_tonics = num_neurons x 1 vector of applied currents for each neuron.
            % I_apps = num_neurons x 1 vector of applied currents for each neuron.
            
            % Outputs:
            % dUs = num_neurons x 1 vector of neuron membrane voltage derivatives w.r.t their resting potentials.
            % dhs = num_neurons x 1 vector of neuron sodium channel deactivation parameter derivatives.
            % Gsyns = num_neurons x num_neurons matrix of synaptic conductances.  Entry ij represents the synaptic conductance from neuron j to neuron i.
            % Ileaks = num_neurons x 1 vector of leak currents for each neuron.
            % Isyns = num_neurons x 1 vector of synaptic currents for each neuron.
            % Inas = num_neurons x 1 vector of sodium channel currents for each neuron.
            % Itotals = num_neurons x 1 vector of total currents for each neuron.
            % minfs = num_neurons x 1 vector of neuron steady state sodium channel activation values.
            % hinfs = num_neurons x 1 vector of neuron steady state sodium channel deactivation values.
            % tauhs = num_neurons x 1 vector of sodium channel deactivation parameter time constants.
            
            % Compute the leak currents.
            I_leaks = self.neuron_utilities.compute_Ileak( Us, Gms );
            
            % Compute synaptic currents.
            [ I_syns, G_syns ] = self.Isyn_step( Us, Rs, g_syn_maxs, dE_syns );
            
            % Compute the sodium channel currents.
            [ I_nas, m_infs ] = self.neuron_utilities.Ina_step( Us, hs, Gnas, Ams, Sms, dEms, dEnas );
            
            % Compute the sodium channel deactivation time constant.
            [ tauhs, h_infs ] = self.neuron_utilities.tauh_step( Us, tauh_maxs, Ahs, Shs, dEhs );
            
            % Compute the total currents.
            I_totals = self.neuron_utilities.compute_Itotal( I_leaks, I_syns, I_nas, I_tonics, I_apps );
            
            % Compute the membrane voltage derivatives.
            dUs = self.neuron_utilities.compute_dU( I_totals, Cms );
            
            % Compute the sodium channel deactivation parameter derivatives.
            dhs = self.neuron_utilities.compute_dh( hs, h_infs, tauhs );
            
        end
        
        
        % Implement a function to simulate the network.
        function [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = simulate( self, Us0, hs0, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, tf, dt )
            
            % This function simulates a neural network described by Gms, Cms, Rs, gsyn_maxs, dEsyns with an initial condition of U0, h0 for tf seconds with a step size of dt and an applied current of Iapp.
            
            % Inputs:
            % Us0 = num_neurons x 1 vector of initial membrane voltages of each neuron w.r.t their resting potentials.
            % hs0 = num_neurons x 1 vector of initial sodium channel deactivation parameters for each neuron.
            % Gms = num_neurons x 1 vector of neuron membrane conductances.
            % Cms = num_neurons x 1 vector of neuron membrane capacitances.
            % Rs = num_neurons x num_neurons matrix of synapse voltage ranges.  Entry ij represents the synapse voltage range from neuron j to neuron i.
            % gsyn_maxs = num_neurons x num_neurons matrix of maximum synaptic conductances.  Entry ij represents the maximum synaptic conductance from neuron j to neuron i.
            % dEsyns = num_neurons x num_neurons matrix of synaptic reversal potentials.  Entry ij represents the synaptic reversal potential from neuron j to neuron i.
            % Ams = num_neurons x 1 vector of sodium channel activation A parameter values.
            % Sms = num_neurons x 1 vector of sodium channel activation S parameter values.
            % dEms = num_neurons x 1 vector of sodium channel activation parameter reversal potentials.
            % Ahs = num_neurons x 1 vector of sodium channel deactivation A parameter values.
            % Shs = num_neurons x 1 vector of sodium channel deactivation S parameter values.
            % dEhs = num_neurons x 1 vector of sodium channel deactivation parameter reversal potentials.
            % tauh_maxs = num_neurons x 1 vector of maximum sodium channel deactivation parameter time constants.
            % Gnas = num_neurons x 1 vector of sodium channel conductances for each neuron.
            % dEnas = num_neurons x 1 vector of sodium channel reversal potentials for each neuron.
            % Iapp = num_neurons x num_timesteps vector of applied currents for each neuron.
            % tf = Scalar that represents the simulation duration.
            % dt = Scalar that represents the simulation time step.
            
            % Outputs:
            % ts = 1 x num_timesteps vector of the time associated with each simulation step.
            % Us = num_neurons x num_timesteps matrix of the neuron membrane voltages over time w.r.t. their resting potentials.
            % hs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameters.
            % dUs = num_neurons x num_timesteps matrix of neuron membrane voltage derivatives over time w.r.t their resting potentials.
            % dhs = num_neurons x num_timesteps matrix of neuron sodium channel deactivation parameter derivatives.
            % Gsyns = num_neurons x num_neurons x num_timesteps tensor of synapse conductances over time.  The ijk entry represens the synaptic condutance from neuron j to neuron i at time step k.
            % Ileaks = num_neurons x num_timsteps matrix of neuron leak currents over time.
            % Isyns = num_neurons x num_timesteps matrix of synaptic currents over time.
            % Inas = num_neurons x num_timesteps matrix of sodium channel currents for each neuron.
            % Itotals = num_neurons x num_timesteps matrix of total currents for each neuron.
            % minfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel activation values.
            % hinfs = num_neurons x num_timesteps matrix of neuron steady state sodium channel deactivation values.
            % tauhs = num_neurons x num_timesteps matrix of sodium channel deactivation parameter time constants.
            
            % Compute the simulation time vector.
            ts = 0:dt:tf;
            
            % Compute the number of time steps.
            num_timesteps = length( ts );
            
            % Ensure that there are the correct number of applied currents.
            if size( I_apps, 2 ) ~= num_timesteps                  % If the number of Iapps columns is not equal to the number of timesteps...
                
                % Throw an error.
                error( 'size(Iapps, 2) must equal the number of simulation time steps.' )
                
            end
            
            % Retrieve the number of neurons from the input dimensions.
            num_neurons = size( Us0, 1 );
            
            % Preallocate arrays to store the simulation data.
            [ Us, hs, dUs, dhs, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = deal( zeros( num_neurons, num_timesteps ) );
            
            % Preallocate a multidimensional array to store the synaptic conductances.
            G_syns = zeros( num_neurons, num_neurons, num_timesteps );
            
            % Set the initial network condition.
            Us(:, 1) = Us0; hs(:, 1) = hs0;
            
            % Simulate the network.
            for k = 1:( num_timesteps - 1 )               % Iterate through each timestep...
                
                % Compute the network state derivatives (as well as other intermediate network values).
                [ dUs(:, k), dhs(:, k), G_syns(:, :, k), I_leaks(:, k), I_syns(:, k), I_nas(:, k), I_totals(:, k), m_infs(:, k), h_infs(:, k), tauhs(:, k) ] = self.simulation_step( Us(:, k), hs(:, k), Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps(:, k) );
                
                % Compute the membrane voltages at the next time step.
                Us( :, k + 1 ) = self.numerical_method_utilities.forward_euler_step( Us(:, k), dUs(:, k), dt );
                
                % Compute the sodium channel deactivation parameters at the next time step.
                hs( :, k + 1 ) = self.numerical_method_utilities.forward_euler_step( hs(:, k), dhs(:, k), dt );
                
            end
            
            % Advance the loop counter variable to perform one more network step.
            k = k + 1;
            
            % Compute the network state derivatives (as well as other intermediate network values).
            [ dUs(:, k), dhs(:, k), G_syns(:, :, k), I_leaks(:, k), I_syns(:, k), I_nas(:, k), I_totals(:, k), m_infs(:, k), h_infs(:, k), tauhs(:, k) ] = self.simulation_step( Us(:, k), hs(:, k), Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps(:, k) );
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot the network states over time.
        function fig = plot_network_states( ~, ts, Us, hs, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 5, neuron_IDs = 1:size( Us, 1 ); end
            
            % Create a figure to store the network states.
            fig = figure( 'Color', 'w', 'Name', 'Network States vs Time' );
            subplot( 2, 1, 1 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex' ), title( 'CPG Membrane Voltage vs Time' )
            subplot( 2, 1, 2 ), hold on, grid on, xlabel( 'Time [s]' ), ylabel( 'Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex' ), title( 'CPG Sodium Channel Deactivation Parameter vs Time' )
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 1 );
            
            % Prellocate an array to store the legend entries.
            legstr = cell( 1, num_neurons );
            
            % Plot the states of each neuron over time.
            for k = 1:num_neurons           % Iterate through each of the neurons.
                
                % Plot the states associated with this neuron.
                subplot( 2, 1, 1 ), plot( ts, Us( k, : ), '-', 'Linewidth', 3 )
                subplot( 2, 1, 2 ), plot( ts, hs( k, : ), '-', 'Linewidth', 3 )
                
                % Add an entry to our legend string.
                legstr{k} = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
            % Add a legend to the plots.
            subplot( 2, 1, 1 ), legend( legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            subplot( 2, 1, 2 ), legend( legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            
        end
        
        
        % Implement a function to animate the network states over time.
        function fig = animate_network_states( self, Us, hs, neuron_IDs, num_playbacks, playback_speed )
            
            % Set the default input arguments.
            if nargin < 6, playback_speed = 1; end
            if nargin < 5, num_playbacks = 1; end
            if nargin < 4, neuron_IDs = 1:size( Us, 1 ); end
            
            % Compute the state space domain of interest.
            U_min = min( Us, [  ], 'all' ); U_max = max( Us, [  ], 'all' );
            h_min = min( hs, [  ], 'all' ); h_max = max( hs, [  ], 'all' );
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 1 );
            
            % Retrieve the number of time steps.
            num_timesteps = size( Us, 2 );
            
            % Ensure that the voltage domain is not degenerate.
            if U_min == U_max                           % If the minimum voltage is equal to the maximum voltage...
                
                % Scale the given domain.
                domain = self.array_utilities.scale_domain( [ U_min U_max ], 0.25, 'absolute' );
                
                % Set the minimum and maximum voltage domain.
                U_min = domain(1); U_max = domain(2);
                
            end
            
            % Ensure that the sodium deactivation domain is not degenerate.
            if h_min == h_max                           % If the minimum sodium deactivation parameter is equal to the maximum sodium deactivation parameter...
                
                % Scale the given domain.
                domain = self.array_utilities.scale_domain( [ h_min h_max ], 0.25, 'absolute' );
                
                % Set the minimum and maximum voltage domain.
                h_min = domain(1); h_max = domain(2);
                
            end
            
            % Create a plot to store the CPG's State Space Trajectory animation.
            fig = figure( 'Color', 'w', 'Name', 'Network State Trajectory Animation' ); hold on, grid on, xlabel( 'Membrane Voltage, $U$ [V]', 'Interpreter', 'Latex' ), ylabel( 'Sodium Channel Deactivation Parameter, $h$ [-]', 'Interpreter', 'Latex' ), title( 'Network State Space Trajectory' ), axis( [ U_min U_max h_min h_max ] )
            
            % Preallocate arrays to store the figure elements.
            line_paths = gobjects( num_neurons, 1 );
            line_ends = gobjects( num_neurons, 1 );
            
            % Prellocate an array to store the legend entries.
            legstr = cell( 1, num_neurons );
            
            % Create the figure elements associated with each of the neurons.
            for k = 1:num_neurons               % Iterate through each of the neurons...
                
                % Create data source strings for the path figure element.
                xdatastr_path = sprintf( 'Us(%0.0f, 1:k)', k );
                ydatastr_path = sprintf( 'hs(%0.0f, 1:k)', k );
                
                % Add this path figure element to the array of path figure elements.
                line_paths(k) = plot( 0, 0, '-', 'Linewidth', 2, 'XDataSource', xdatastr_path, 'YDataSource', ydatastr_path );
                
                % Create data source strings for each end point figure element.
                xdatastr_end = sprintf( 'Us(%0.0f, k)', k );
                ydatastr_end = sprintf( 'hs(%0.0f, k)', k );
                
                % Add this path figure element to the array of end figure elements.
                line_ends(k) = plot( 0, 0, 'o', 'Linewidth', 2, 'Markersize', 15, 'Color', line_paths(k).Color, 'XDataSource', xdatastr_end, 'YDataSource', ydatastr_end );
                
                % Add an entry to our legend string.
                legstr{k} = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
            % Add a legend to the plot.
            legend( line_ends, legstr, 'Location', 'Southoutside', 'Orientation', 'Horizontal' )
            
            % Animate the figure.
            for j = 1:num_playbacks                     % Iterate through each play back...
                for k = 1:playback_speed:num_timesteps              % Iterate through each of the angles...
                    
                    % Refresh the plot data.
                    refreshdata( [ line_paths, line_ends ], 'caller' )
                    
                    % Update the plot.
                    drawnow
                    
                end
            end
            
        end
        
        
        
        
    end
end

