classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager
        synapse_manager
        applied_current_manager
        
        network_dt
        
        deltas
        dE_syns
        g_syn_maxs
        
        network_utilities
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( neuron_manager, synapse_manager, applied_current_manager, network_dt )
            
            % Create an instance of the network utilities class.
            self.network_utilities = network_utilities_class(  );
            
            % Set the default network properties.
            if nargin < 4, self.network_dt = 1e-3; else, self.network_dt = network_dt; end
            if nargin < 3, self.applied_current_manager = applied_current_manager_class(  ); else, self.applied_current_manager = applied_current_manager; end
            if nargin < 2, self.synapse_manager = synapse_manager_class(  ); else, self.synapse_manager = synapse_manager; end
            if nargin < 1, self.neuron_manager = neuron_manager_class(  ); else, self.neuron_manager = neuron_manager; end
            
            % Construct and set the delta matrix.
            self = self.construct_set_delta_matrix(  );
            
            % Construct and set the synaptic reversal potential matrix.
            self = self.construct_set_synaptic_reversal_potential_matrix(  );
            
            % Compute and set the maximum synaptic conductance matrix.
            self = self.compute_set_max_synaptic_conductance_matrix(  );
            
        end
        
        
        
        %% Synapse Functions
               
        % Implement a function to compute the delta matrix.
        function deltas = construct_delta_matrix( self )
            
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
        
        
        % Implement a function to compute and set the delta matrix.
        function self = construct_set_delta_matrix( self )
            
            % Compute the delta matrix.
            self.deltas = self.construct_delta_matrix(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials.
        function dE_syns = construct_synaptic_reversal_potential_matrix( self )
            
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
        
            
        % Implement a funciton to comptue and set the synaptic reversal potentials.
        function self = construct_set_synaptic_reversal_potential_matrix( self )
            
            % Compute the synaptic reversal potential matrix.
            self.dE_syns = self.construct_synaptic_reversal_potential_matrix(  );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
        function g_syn_maxs = compute_max_synaptic_conductance_matrix( self )

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
            
            % Compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
            g_syn_maxs = self.network_utilities.compute_max_synaptic_conductance_matrix( self.deltas, Gms, Rs, self.dE_syns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
        
        end
      
        
        % Implement a function to set the synaptic conductances of each synapse based on the synaptic conductance matrix.
        function self = max_synaptic_conductance_matrix2synaptic_conductances( self )
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
           for k1 = 1:self.neuron_manager.num_neurons                           % Iterate through each of the to neurons...
               for k2 = 1:self.neuron_manager.num_neurons                       % Iterate through each of the from neurons...
                  
                   % Retrieve the synapse ID.
                   synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( self.neuron_manager.neurons(k2).ID, self.neuron_manager.neurons(k1).ID, 'error' );

                   % Set the maximum synaptic conductance of this synapse.
                   self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, self.g_syn_maxs( k1, k2 ), 'g_syn_max' );
                   
               end 
           end
            
        end
        
        
        
        % Implement a funciton to compute and set the maximum synaptic conductance matrix.
        function self = compute_set_max_synaptic_conductance_matrix( self )
            
            % Compute the maximum synaptic conductance matrix.
            self.g_syn_maxs = self.compute_max_synaptic_conductance_matrix(  );
            
            % Set the synaptic conductance of all of constinuent synapses.
            self = self.max_synaptic_conductance_matrix2synaptic_conductances(  );
            
        end
        
        
        
    end
end

