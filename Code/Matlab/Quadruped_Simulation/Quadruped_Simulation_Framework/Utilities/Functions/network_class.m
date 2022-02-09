classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager
        synapse_manager
        applied_current_manager
        
        dt
        
        network_utilities
        numerical_method_utilities
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( neuron_manager, synapse_manager, applied_current_manager, dt )
            
            % Create an instance of the numeriacl methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );
            
            % Create an instance of the network utilities class.
            self.network_utilities = network_utilities_class(  );
            
            % Set the default network properties.
            if nargin < 4, self.dt = 1e-3; else, self.dt = dt; end
            if nargin < 3, self.applied_current_manager = applied_current_manager_class(  ); else, self.applied_current_manager = applied_current_manager; end
            if nargin < 2, self.synapse_manager = synapse_manager_class(  ); else, self.synapse_manager = synapse_manager; end
            if nargin < 1, self.neuron_manager = neuron_manager_class(  ); else, self.neuron_manager = neuron_manager; end
            
            % Compute and set the synaptic conductances.
            self = self.compute_set_synaptic_conductances(  );
            
        end
        
        
        
        %% Synapse Functions
               
        % Implement a function to compute the delta matrix.
        function deltas = get_deltas( self )
            
            % Retrieve the from neuron IDs.
            from_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'from_neuron_ID' ) ) );
            
            % Retrieve the to neuron IDs.
            to_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'to_neuron_ID' ) ) );
            
            % Ensure that the unique from and to neuron IDs match exactly.
            assert( all( from_neuron_IDs_unique == to_neuron_IDs_unique ), 'Unique from neuron IDs must equal unique to neuron IDs.' )
            
            % Preallocate the deltas matrix.
            deltas = zeros( self.neuron_manager.num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:self.synapse_manager.num_synapses
                
                % Retrieve the from neuron index.
                from_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).from_neuron_ID );
                
                % Retrieve the to neuron index.
                to_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).to_neuron_ID );
                
                % Set the component of the delta matrix associated with this neuron.
                deltas( to_neuron_index, from_neuron_index ) = self.synapse_manager.synapses(k).delta;
                
            end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials.
        function dE_syns = get_synaptic_reversal_potentials( self )
            
            % Retrieve the from neuron IDs.
            from_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'from_neuron_ID' ) ) );
            
            % Retrieve the to neuron IDs.
            to_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'to_neuron_ID' ) ) );
            
            % Ensure that the unique from and to neuron IDs match exactly.
            assert( all( from_neuron_IDs_unique == to_neuron_IDs_unique ), 'Unique from neuron IDs must equal unique to neuron IDs.' )
            
            % Preallocate the synaptic reversal potential matrix.
            dE_syns = zeros( self.neuron_manager.num_neurons );
            
            % Retrieve the entries of the synaptic reversal potential matrix.
            for k = 1:self.synapse_manager.num_synapses
                
                % Retrieve the from neuron index.
                from_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).from_neuron_ID );
                
                % Retrieve the to neuron index.
                to_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).to_neuron_ID );
                
                % Set the component of the synaptic reversal potential matrix associated with this neuron.
                dE_syns( to_neuron_index, from_neuron_index ) = self.synapse_manager.synapses(k).dE_syn;
                
            end
            
        end

        
        % Implement a function to compute the synaptic reversal potentials.
        function g_syn_maxs = get_max_synaptic_conductances( self )
            
            % Retrieve the from neuron IDs.
            from_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'from_neuron_ID' ) ) );
            
            % Retrieve the to neuron IDs.
            to_neuron_IDs_unique = unique( cell2mat( self.synapse_manager.get_synapse_property( 'all', 'to_neuron_ID' ) ) );
            
            % Ensure that the unique from and to neuron IDs match exactly.
            assert( all( from_neuron_IDs_unique == to_neuron_IDs_unique ), 'Unique from neuron IDs must equal unique to neuron IDs.' )
            
            % Preallocate the synaptic reversal potential matrix.
            g_syn_maxs = zeros( self.neuron_manager.num_neurons );
            
            % Retrieve the entries of the synaptic reversal potential matrix.
            for k = 1:self.synapse_manager.num_synapses
                
                % Retrieve the from neuron index.
                from_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).from_neuron_ID );
                
                % Retrieve the to neuron index.
                to_neuron_index = self.neuron_manager.get_neuron_index( self.synapse_manager.synapses(k).to_neuron_ID );
                
                % Set the component of the synaptic reversal potential matrix associated with this neuron.
                g_syn_maxs( to_neuron_index, from_neuron_index ) = self.synapse_manager.synapses(k).g_syn_max;
                
            end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
        function g_syn_maxs = compute_max_synaptic_conductance( self )

            % Retrieve the neuron membrane conductances.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) )';

            % Retrieve the neuron membrane voltage ranges.
            Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );

            % Retrieve the sodium channel conductances.
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gna' ) )';

            % Retrieve the neuron sodium channel activation parameters.
            Ams = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Am' ) )';
            Sms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sm' ) )';
            dEms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEm' ) )';

            % Retrieve the neuron sodium channel deactivation parameters.
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Ah' ) )';
            Shs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sh' ) )';
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEh' ) )';

            % Retrieve the sodium channel reversal potentials.
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEna' ) )';
            
            % Retrieve the tonic currents.
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) )';
            
            % Retrieve the synapse properties.
            deltas = self.get_deltas(  );
            dE_syns = self.get_synaptic_reversal_potentials(  );
            
            % Compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
            g_syn_maxs = self.network_utilities.compute_max_synaptic_conductance( deltas, Gms, Rs, dE_syns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
        
            
        end
      
        
        % Implement a function to set the maximum synaptic conductances of each synapse based on the maximum synaptic conductance matrix.
        function self = set_max_synaptic_conductances( self, g_syn_maxs )
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
           for k1 = 1:self.neuron_manager.num_neurons                           % Iterate through each of the to neurons...
               for k2 = 1:self.neuron_manager.num_neurons                       % Iterate through each of the from neurons...
                  
                   % Retrieve the synapse ID.
                   synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( self.neuron_manager.neurons(k2).ID, self.neuron_manager.neurons(k1).ID, 'error' );

                   % Set the maximum synaptic conductance of this synapse.
                   self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, g_syn_maxs( k1, k2 ), 'g_syn_max' );
                   
               end 
           end
            
        end
        
        
        % Implement a funciton to compute and set the maximum synaptic conductance matrix.
        function self = compute_set_max_synaptic_conductances( self )
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_maxs = self.compute_max_synaptic_conductance(  );
            
            % Set the synaptic conductance of all of constinuent synapses.
            self = self.set_max_synaptic_conductances( g_syn_maxs );
            
        end
        
        
        % Implement a function to compute the synaptic conductance for each synapse.
        function G_syns = compute_synaptic_conductances( self )
            
            % Retrieve the neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'U' ) )';
            Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the maximum synaptic conductances.
            g_syn_maxs = self.get_max_synaptic_conductances(  );
            
            % Compute the synaptic conductance.
            G_syns = self.network_utilities.compute_synaptic_conductance( Us, Rs, g_syn_maxs );
            
        end
        
        
        % Implement a function to set the synaptic conductance of each synapse based on the synaptic conductance matrix.
        function self = set_synaptic_conductances( self, G_syns )
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
           for k1 = 1:self.neuron_manager.num_neurons                           % Iterate through each of the to neurons...
               for k2 = 1:self.neuron_manager.num_neurons                       % Iterate through each of the from neurons...
                  
                   % Retrieve the synapse ID.
                   synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( self.neuron_manager.neurons(k2).ID, self.neuron_manager.neurons(k1).ID, 'error' );

                   % Set the synaptic conductance of this synapse.
                   self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, G_syns( k1, k2 ), 'G_syn' );
                   
               end 
           end
            
        end
        
        
        % Implement a function to compute and set the synaptic conductance of each synapse.
        function self = compute_set_synaptic_conductances( self )
            
            % Compute the synaptic conductances.
            G_syns = self.compute_synaptic_conductances(  );
            
            % Set the synaptic conductances.
            self = self.set_synaptic_conductances( G_syns );
            
        end
        
        
        
        %% Simulation Functions
        
        % Implement a function to compute a single network simulation step.
        function [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = compute_simulation_step( self )
        
            % Retrieve basic neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'U' ) );
            hs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'h' ) );
            Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) );
            Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) );

            % Retrieve sodium channel neuron properties.
            Ams = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Am' ) );
            Sms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sm' ) );
            dEms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEm' ) );
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Ah' ) );
            Shs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sh' ) );
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEh' ) );
            tauh_maxs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'tauh_max' ) );
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gna' ) );
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEna' ) );
            
            % Retrieve synaptic properties.
%             g_syn_maxs = cell2mat( self.synapse_manager.get_synapse_property( 'all', 'g_syn_max' ) );
%             dE_syns = cell2mat( self.synapse_manager.get_synapse_property( 'all', 'dE_syn' ) );
            g_syn_maxs = self.get_max_synaptic_conductances(  );
            dE_syns = self.get_synaptic_reversal_potentials(  );
            
            % Retrieve applied currents.
            I_apps = self.applied_current_manager.get_applied_currents( 'all' )';

            % Perform a single simulation step.
            [ dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = self.network_utilities.simulation_step( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps );
            
            % Compute the membrane voltages at the next time step.
            Us = self.numerical_method_utilities.forward_euler_step( Us, dUs, self.dt );

            % Compute the sodium channel deactivation parameters at the next time step.
            hs = self.numerical_method_utilities.forward_euler_step( hs, dhs, self.dt );
            
        end
        
        
        % Implement a function to compute and set a single network simulation step.
        function self = compute_set_simulation_step( self )
        
            % Compute and set a single network simulation step.
            [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = compute_simulation_step(  );
            
            % Set the neuron properties.
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', Us, 'U' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', hs, 'h' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_leaks, 'I_leak' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_syns, 'I_syn' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_nas, 'I_na' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_totals, 'I_total' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', m_infs, 'm_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', h_infs, 'h_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', tauhs, 'tauh' );

            % Set the synapse properties.
            self = self.set_synaptic_conductances( G_syns );
            
        end
            
        
        % Implement a function to compute network simulation results.
        function [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = compute_simulation( self, tf )
            
            % Retrieve the neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'U' ) )';
            hs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'h' ) )';
            Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) )';
            Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) )';
            Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            Ams = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Am' ) )';
            Sms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sm' ) )';
            dEms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEm' ) )';
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Ah' ) )';
            Shs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Sh' ) )';
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEh' ) )';
            tauh_maxs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'tauh_max' ) )';
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gna' ) )';
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'dEna' ) )';
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) )';
            
            % Retrieve the synapse properties.
            g_syn_maxs = self.get_max_synaptic_conductances(  );
            dE_syns = self.get_synaptic_reversal_potentials(  );
            
            % Retrieve the applied currents.
            I_apps = self.applied_current_manager.get_applied_currents( 'all' )';
            
            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = self.network_utilities.simulate( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, tf, self.dt );
            
        end
        
        
        % Implement a function to compute and set network simulation results.
        function [ self, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = compute_set_simulation( self, tf )
        
            % Compute the network simulation results.
           [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = self.compute_simulation( tf );
           
           % Set the neuron properties.
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', Us( :, end ), 'U' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', hs( :, end ), 'h' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_leaks( :, end ), 'I_leak' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_syns( :, end ), 'I_syn' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_nas( :, end ), 'I_na' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', I_totals( :, end ), 'I_total' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', m_infs( :, end ), 'm_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', h_infs( :, end ), 'h_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( 'all', tauhs( :, end ), 'tauh' );
           
            % Set the synapse properties.
            self = self.set_synaptic_conductances( G_syns( :, :, end ) );
            
        end
        
    end
end

