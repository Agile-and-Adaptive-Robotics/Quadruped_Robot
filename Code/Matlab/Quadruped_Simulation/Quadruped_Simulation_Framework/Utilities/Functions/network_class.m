classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager
        synapse_manager
        applied_current_manager
        
        dt
        tf
        
        network_utilities
        numerical_method_utilities
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( dt, tf, neuron_manager, synapse_manager, applied_current_manager )
            
            % Create an instance of the numeriacl methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );
            
            % Create an instance of the network utilities class.
            self.network_utilities = network_utilities_class(  );
            
            % Set the default network properties.
            if nargin < 5, self.applied_current_manager = applied_current_manager_class(  ); else, self.applied_current_manager = applied_current_manager; end
            if nargin < 4, self.synapse_manager = synapse_manager_class(  ); else, self.synapse_manager = synapse_manager; end
            if nargin < 3, self.neuron_manager = neuron_manager_class(  ); else, self.neuron_manager = neuron_manager; end
            if nargin < 2, self.tf = 1; else, self.tf = tf; end
            if nargin < 1, self.dt = 1e-3; else, self.dt = dt; end
            
            % Compute and set the synaptic conductances.
            self = self.compute_set_Gsyns(  );
            
        end
        
        
        %% Specific Get Functions
        
        % Implement a function to construct the delta matrix from the stored delta scalars.
        function deltas = get_deltas( self, neuron_IDs )
            
            % Set the default input arugments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = self.synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = self.synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            
            % Retrieve the number of relevant synapses.
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            deltas = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                         % Iterate through each synapse...
                
                % Determine how to assign the delta value.
                if ( synapse_indexes(k) > 0 ) && ( self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )                   % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the delta matrix associated with this neuron.
                    deltas( to_neuron_index_local_logical, from_neuron_index_local_logical ) = self.synapse_manager.synapses( synapse_indexes(k) ).delta;
                    
                elseif ( synapse_indexes(k) == -1 ) || ( ~self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )            % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes(k) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic reversal potential matrix from the stored synaptic reversal potential scalars.
        function dE_syns = get_dEsyns( self, neuron_IDs )
            
            % Set the default input arugments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = self.synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = self.synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            
            % Retrieve the number of relevant synapses.
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            dE_syns = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                         % Iterate through each synapse...
                
                % Determine how to assign the synaptic reversal potential value.
                if ( synapse_indexes(k) > 0 ) && ( self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )                   % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron logical index.
                    from_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron logical index.
                    to_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic reversal potential matrix associated with this neuron.
                    dE_syns( to_neuron_index_local_logical, from_neuron_index_local_logical ) = self.synapse_manager.synapses( synapse_indexes(k) ).dE_syn;
                    
                elseif ( synapse_indexes(k) == -1 ) || ( ~self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )            % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes(k) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the maximum synaptic conductance matrix from the stored maximum synaptic conductance scalars.
        function g_syn_maxs = get_gsynmaxs( self, neuron_IDs )
            
            % Set the default input arugments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = self.synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = self.synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            
            % Retrieve the number of relevant synapses.
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the maximum synaptic conductance matrix.
            g_syn_maxs = zeros( num_neurons );
            
            % Retrieve the entries of the maximum synaptic conductance matrix.
            for k = 1:num_syanpses                         % Iterate through each synapse...
                
                % Determine how to assign the maximum synaptic conductance value.
                if ( synapse_indexes(k) > 0 ) && ( self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )                   % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the maximum synaptic conductance matrix associated with this neuron.
                    g_syn_maxs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = self.synapse_manager.synapses( synapse_indexes(k) ).g_syn_max;
                    
                elseif ( synapse_indexes(k) == -1 ) || ( ~self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )            % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes(k) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic condcutance matrix from the stored synaptic conductance scalars.
        function G_syns = get_Gsyns( self, neuron_IDs )
            
            % Set the default input arugments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = self.synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = self.synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            
            % Retrieve the number of relevant synapses.
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the synaptic conductance matrix.
            G_syns = zeros( num_neurons );
            
            % Retrieve the entries of the synaptic conductance matrix.
            for k = 1:num_syanpses                         % Iterate through each synapse...
                
                % Determine how to assign the synaptic conductance value.
                if ( synapse_indexes(k) > 0 ) && ( self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )                   % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = self.synapse_manager.synapses( synapse_indexes(k) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic conductance matrix associated with this neuron.
                    G_syns( to_neuron_index_local_logical, from_neuron_index_local_logical ) = self.synapse_manager.synapses( synapse_indexes(k) ).G_syn;
                    
                elseif ( synapse_indexes(k) == -1 ) || ( ~self.synapse_manager.synapses( synapse_indexes(k) ).b_enabled )            % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes(k) )
                    
                end
                
            end
            
        end
        
        
        %% Specific Set Functions
        
        % Implement a function to set the deltas of each synapse based on the delta matrix.
        function self = set_deltas( self, deltas, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the delta of each of the synapses in this network to agree with the delta matrix.
            for k1 = 1:num_neurons                           % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                       % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(k2), neuron_IDs(k1), 'ignore' );
                    
                    % Retrieve the synpase index.
                    synapse_index = self.synapse_manager.get_synapse_index( synapse_ID );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( self.synapse_manager.synapses( synapse_index ).b_enabled )                                % If the synapse ID is greater than zero...
                        
                        % Set the value of this synapse.
                        self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, deltas( k1, k2 ), 'delta' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~self.synapse_manager.synapses( synapse_index ).b_enabled )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                            % Otherwise...
                        
                        % Throw an error.
                        
                    end
                    
                end
            end
            
        end
        
        
        % Implement a function to set the synaptic reversal potentials of each synapse based on the synaptic reversal matrix.
        function self = set_dEsyns( self, dE_syns, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the synaptic reversal potential of each of the synapses in this network to agree with the synaptic reversal potential matrix.
            for k1 = 1:num_neurons                           % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                       % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(k2), neuron_IDs(k1), 'ignore' );
                    
                    % Retrieve the synpase index.
                    synapse_index = self.synapse_manager.get_synapse_index( synapse_ID );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( self.synapse_manager.synapses( synapse_index ).b_enabled )                                % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, dE_syns( k1, k2 ), 'dE_syn' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~self.synapse_manager.synapses( synapse_index ).b_enabled )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                            % Otherwise...
                        
                        % Throw an error.
                        
                    end
                    
                end
            end
            
        end
        
        
        % Implement a function to set the maximum synaptic conductances of each synapse based on the maximum synaptic conductance matrix.
        function self = set_gsynmaxs( self, g_syn_maxs, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
            for k1 = 1:num_neurons                           % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                       % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(k2), neuron_IDs(k1), 'ignore' );
                    
                    % Retrieve the synpase index.
                    synapse_index = self.synapse_manager.get_synapse_index( synapse_ID );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( self.synapse_manager.synapses( synapse_index ).b_enabled )                                % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, g_syn_maxs( k1, k2 ), 'g_syn_max' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~self.synapse_manager.synapses( synapse_index ).b_enabled )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                            % Otherwise...
                        
                        % Throw an error.
                        
                    end
                    
                end
            end
            
        end
        
        
        % Implement a function to set the synaptic conductance of each synapse based on the synaptic conductance matrix.
        function self = set_Gsyns( self, G_syns, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the synaptic conductance matrix.
            for k1 = 1:num_neurons                           % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                       % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(k2), neuron_IDs(k1), 'ignore' );
                    
                    % Retrieve the synapse index.
                    synapse_index = self.synapse_manager.get_synapse_index( synapse_ID, 'ignore' );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID >= 0) && ( self.synapse_manager.synapses( synapse_index ).b_enabled )                                % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, G_syns( k1, k2 ), 'G_syn' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~self.synapse_manager.synapses( synapse_index ).b_enabled )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                            % Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )
                        
                    end
                    
                end
            end
            
        end
        
        
        %% Compute Functions
        
        % Implement a function to compute the synaptic conductance for each synapse.
        function G_syns = compute_Gsyns( self )
            
            % Retrieve the neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'U' ) )';
            Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the maximum synaptic conductances.
            g_syn_maxs = self.get_gsynmaxs( 'all' );
            
            % Compute the synaptic conductance.
            G_syns = self.network_utilities.compute_Gsyn( Us, Rs, g_syn_maxs );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
        function g_syn_maxs = compute_cpg_gsynmaxs( self, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron membrane conductances.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) )';
            
            % Retrieve the neuron membrane voltage ranges.
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the sodium channel conductances.
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gna' ) )';
            
            % Retrieve the neuron sodium channel activation parameters.
            Ams = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Am' ) )';
            Sms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sm' ) )';
            dEms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEm' ) )';
            
            % Retrieve the neuron sodium channel deactivation parameters.
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Ah' ) )';
            Shs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sh' ) )';
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEh' ) )';
            
            % Retrieve the sodium channel reversal potentials.
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEna' ) )';
            
            % Retrieve the tonic currents.
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic' ) )';
            
            % Retrieve the synapse properties.
            deltas = self.get_deltas( neuron_IDs );
            dE_syns = self.get_dEsyns( neuron_IDs );
            
            % Compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
            g_syn_maxs = self.network_utilities.compute_cpg_gsynmax_matrix( deltas, Gms, Rs, dE_syns, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, I_tonics );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a transmission subnetwork with the specified parameters.
        function g_syn_max12 = compute_transmission_gsynmax( self, neuron_IDs, synapse_ID, I_app2, k )
        
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app2 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse ID.
            synapse_ID = self.synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Retrieve the neuron properties.
            Gm2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) );

            % Retrieve the synaptic reversal potential.
            dE_syn12 = cell2mat( self.synapse_manager.get_synapse_property( synapse_ID, 'dE_syn' ) );
                        
            % Compute the required maximum synaptic conductances required to design a transmission subnetwork.
            g_syn_max12 = self.network_utilities.compute_transmission_gsynmax( Gm2, R1, dE_syn12, I_app2, k );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a modulation subnetwork with the specified parameters.
        function g_syn_max12 = compute_modulation_gsynmax( self, neuron_IDs, synapse_ID, I_app2, c )
            
            % Set the default input arugments.
            if nargin < 5, c = 1; end
            if nargin < 4, I_app2 = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse ID.
            synapse_ID = self.synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Retrieve the neuron properties.
            Gm2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) );
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );

            % Retrieve the synaptic reversal potential.
            dE_syn12 = cell2mat( self.synapse_manager.get_synapse_property( synapse_ID, 'dE_syn' ) );
            
            % Compute the maximum synaptic conductance for a modulation subnetwork.
            g_syn_max12 = self.network_utilities.compute_modulation_gsynmax( Gm2, R1, R2, dE_syn12, I_app2, c );
        
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design an addition subnetwork with the specified parameters.
        function g_syn_maxs = compute_addition_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) )';

            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syn13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this addition subnetwork.            
            [ g_syn_max13, g_syn_max23 ] = self.network_utilities.compute_addition_gsynmax( Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k );
            
            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max13, g_syn_max23 ];
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a subtraction subnetwork with the specified parameters.
        function g_syn_maxs = compute_subtraction_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syn13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ g_syn_max13, g_syn_max23 ] = self.network_utilities.compute_subtraction_gsynmax( Gm3, R1, dE_syn13, dE_syn23, I_app3, k );

            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max13, g_syn_max23 ];
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a division subnetwork with the specified parameters.
        function g_syn_maxs = compute_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = 1; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) )';
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) )';

            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syn13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this division subnetwork.
            [ g_syn_max13, g_syn_max23 ] = self.network_utilities.compute_division_gsynmax( Gm3, R1, R2, R3, dE_syn13, dE_syn23, I_app3, k, c );
            
            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max13, g_syn_max23 ];
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multiplication subnetwork with the specifed parameters.
        function g_syn_maxs = compute_multiplication_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, I_app4, k )
        
            % Set the default input arguments.
            if nargin < 6, k = 1; end
            if nargin < 5, I_app4 = 0; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            Gm4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) )';
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) )';
            R4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R' ) )';

            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syn14 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';
            dE_syn34 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 3 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this multiplication subnetwork.
            [ g_syn_max14, g_syn_max23, g_syn_max34 ] = self.network_utilities.compute_multiplication_gsynmax( Gm3, Gm4, R1, R2, R3, R4, dE_syn14, dE_syn23, dE_syn34, I_app3, I_app4, k );
            
            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max14, g_syn_max23, g_syn_max34 ];
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a derivation subnetwork with the specified parameters.
        function g_syn_maxs = compute_derivation_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syn13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ g_syn_max13, g_syn_max23 ] = self.network_utilities.compute_derivation_gsynmax( Gm3, R1, dE_syn13, dE_syn23, I_app3, k );

            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max13, g_syn_max23 ];

        end
            
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function g_syn_max = compute_integration_gsynmax( self, neuron_IDs, ki_range )
        
            % Set the default input arguments.
            if nargin < 3, ki_range = 1/( 2*( 1e-9 ) ); end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the membrane conductances and membrane capacitances of these neurons.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) );
            Cms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Cm' ) );

            % Ensure that the integration neurons are symmetrical.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Cms( 1 ) == Cms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance capacitances.' );

            % Compute the integration subnetwork maximum synaptic conductances.
            g_syn_max = self.network_utilities.compute_integration_gsynmax( Gms( 1 ), Cms( 1 ), ki_range );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function dEsyn = compute_integration_dEsyn( self, neuron_IDs, synapse_IDs )
        
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the membrane conductancs and voltage domains.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) );

            % Retrieve the maximum synaptic conductances
            g_syn_maxs = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs, 'g_syn_max' ) )';

            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            assert( g_syn_maxs( 1 ) == g_syn_maxs( 2 ), 'Integration subnetwork neurons must have symmetrical maximum synaptic conductances.' );

           % Compute the synaptic reversal potentials for an integration subnetwork.
            dEsyn = self.network_utilities.compute_integration_dEsyn( Gms( 1 ), Rs( 1 ), g_syn_maxs( 1 ) );
            
        end
        
        
        % Implement a function to compute the applied current for an integration network.
        function Iapp = compute_integration_Iapp( self, neuron_IDs )
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) );
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Compute the applied current.
            Iapp = Gms( 1 )*Rs( 1 );
            
        end
        
        
        %% Compute-Set Functions
        
        % Implement a function to compute and set the synaptic conductance of each synapse.
        function self = compute_set_Gsyns( self )
            
            % Compute the synaptic conductances.
            G_syns = self.compute_Gsyns(  );
            
            % Set the synaptic conductances.
            self = self.set_Gsyns( G_syns );
            
        end
        
        
        % Implement a funciton to compute and set the maximum synaptic conductances for a multistate cpg subnetwork.
        function self = compute_set_cpg_gsynmaxs( self, neuron_IDs )
            
            % Set the default neuron IDs.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Compute the maximum synaptic conductance matrix.
            g_syn_maxs = self.compute_cpg_gsynmaxs( neuron_IDs );
            
            % Set the synaptic conductance of all of constinuent synapses.
            self = self.set_gsynmaxs( g_syn_maxs, neuron_IDs );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for a transmission subnetwork.
        function self = compute_set_transmission_gsynmax( self, neuron_IDs, synapse_ID, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_ID = self.synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Compute the maximum synaptic conductance for a transmission subnetwork.
            g_syn_max12 = self.compute_transmission_gsynmax( neuron_IDs, synapse_ID, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, g_syn_max12, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for a modulation subnetwork.
        function self = compute_set_modulation_gsynmax( self, neuron_IDs, synapse_ID, I_app, c )
            
            % Set the default input arguments.
            if nargin < 5, c = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_ID = self.synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Compute the maximum synaptic conductance for a modulation subnetwork.
            g_syn_max12 = self.compute_modulation_gsynmax( neuron_IDs, synapse_ID, I_app, c );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, g_syn_max12, 'g_syn_max' );   
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for an addition subnetwork.
        function self = compute_set_addition_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end

        
        % Implement a function to compute and set the maximum synaptic conductances for a subtraction subnetwork.
        function self = compute_set_subtraction_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_subtraction_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a division subnetwork.
        function self = compute_set_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.            
            g_syn_maxs = self.compute_division_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k, c );
                        
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a multiplication subnetwork.
        function self = compute_set_multiplication_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, I_app4, k )
            
            % Set the default input arguments.
            if nargin < 6, k = 1; end
            if nargin < 5, I_app4 = 0; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.                                    
            g_syn_maxs = self.compute_multiplication_gsynmaxs( neuron_IDs, synapse_IDs, I_app3, I_app4, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a derivation subnetwork.
        function self = compute_set_derivation_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
        
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_derivation_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );   
        
        end
            

        % Implement a function to compute and set the maximum synaptic conductances for an integration subnetwork.
        function self = compute_set_integration_gsynmaxs( self, neuron_IDs, synapse_IDs, ki_range )
        
            % Set the default input arguments.
            if nargin < 4, ki_range = 1/( 2*( 1e-9 ) ); end
            
            % Compute the maximum synaptic conductances for thi
            g_syn_max = self.compute_integration_gsynmax( neuron_IDs, ki_range );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_max*ones( 1, 2 ), 'g_syn_max' );   
        
        end
        
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function self = compute_set_integration_dEsyns( self, neuron_IDs, synapse_IDs )
            
            % Compute the synaptic reversal potentials for an integration subnetwork.
            dEsyn = self.compute_integration_dEsyn( neuron_IDs, synapse_IDs );

            % Set the synaptic reversal potentials of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, dEsyn*ones( 1, 2 ), 'dE_syn' );   
        
        end
        
        
        %% Network Deletion Functions
        
        % Implement a function to delete all of the components in a network.
        function self = delete_all( self )
            
            % Delete all of the neurons.
            self.neuron_manager = self.neuron_manager.delete_neurons( 'all' );
            
            % Delete all of the synapses.
            self.synapse_manager = self.synapse_manager.delete_synapses( 'all' );
            
            % Delete all of the applied currents.
            self.applied_current_manager = self.applied_current_manager.delete_applied_currents( 'all' );
           
        end        
        
        
        %% Subnetwork Applied Current Design Functions
        
        % Implement a function to design the applied currents for a multistate cpg subnetwork.
        function self = design_multistate_cpg_applied_currents( self, neuron_IDs )
            
            % Design the applied currents for a multistate cpg subnetwork.
            self.applied_current_manager = self.applied_current_manager.design_multistate_cpg_applied_current( neuron_IDs, self.dt, self.tf );
            
        end
        
        
        % Implement a function to design the applied currents for a multiplication subnetwork.
        function self = design_multiplication_applied_currents( self, neuron_IDs )
            
            % Retrieve the necessary neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );
            
            % Design the multiplication subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_multiplication_applied_current( neuron_IDs, Gm3, R3 );
             
        end
        
        
        % Implement a function to design the applied currents for an integration subnetwork.
        function self = design_integration_applied_currents( self, neuron_IDs )
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) );
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Design the multiplication subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_integration_applied_currents( neuron_IDs, Gms( 1 ), Rs( 1 ) );
            
        end
        
        
        %% Subnetwork Synapse Design Functions
        
        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function self = design_multistate_cpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable )
           
            % Design the multistate cpg subnetwork synapses.
            self.synapse_manager = self.synapse_manager.design_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable );

            % Compute and set the maximum synaptic conductances required to achieve these delta values.
            self = self.compute_set_cpg_gsynmaxs( neuron_IDs );
            
        end
        
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function self = design_transmission_synapse( self, neuron_IDs, k, b_applied_current_compensation )
           
            % Set the default input arugments.
            if nargin < 4, b_applied_current_compensation = true; end
            if nargin < 3, k = 1; end
            
            % Design the transmission subnetwork neurons.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.design_transmission_synapse( neuron_IDs );
            
            % Determine whether to consider the applied current.
            if b_applied_current_compensation                       % If we want to compensate for the applied current...
            
                % Get the applied current associated with the final neuron.
                I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );

                % Determine whether to throw a warning.
                if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

                % Set the applied current to be the average current.
                I_app = mean( I_apps );

            else                                                    % Otherwise...

                % Set the applied current magnitude to zero.
                I_app = 0;
                
            end
            
            % Compute and set the maximum synaptic conductance for a transmission subnetwork.
            self = self.compute_set_transmission_gsynmax( neuron_IDs, synapse_ID, I_app, k );
            
        end
        
        
        % Implement a function to design the synapses for a modulation subnetwork.
        function self = design_modulation_synapses( self, neuron_IDs, c )
            
            % Set the default input arugments.
            if nargin < 3, c = 1; end
            
           % Design the modulation synapses.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.design_modulation_synapse( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

            % Set the applied current to be the average current.
            I_app = mean( I_apps );
            
            % Compute and set the maximum synaptic conductance for a transmission subnetwork.
            self = self.compute_set_modulation_gsynmax( neuron_IDs, synapse_ID, I_app, c ); 
            
        end
        
        
        % Implement a function to design the synapses for an addition subnetwork.
        function self = design_addition_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % Design the addition subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_addition_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            I_app = mean( I_apps );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
        end
        
        
        % Implement a function to design the synapses for a subtraction subnetwork.
        function self = design_subtraction_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % Design the subtraction subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_subtraction_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            I_app = mean( I_apps );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_subtraction_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
        end
        
        
        % Implement a function to design the synapses for a multiplication subnetwork.
        function self = design_multiplication_synapses( self, neuron_IDs, k )
            
           % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % Design the multiplication subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_multiplication_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps4 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 4 ), [  ], [  ], 'ignore' );

            % Determine whether to throw a warning.
            if ~all( I_apps4 == I_apps4( 1 ) ), warning( 'The basic multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

            % Set the applied current to be the average current.
            I_app3 = 0;
            I_app4 = mean( I_apps4 );
                
            % Compute and set the maximum synaptic reversal potentials necessary to design this multiplication subnetwork.
            self = self.compute_set_multiplication_gsynmaxs( neuron_IDs, synapse_IDs, I_app3, I_app4, k ); 
            
        end
        
        
        % Implement a function to design the synapses of a division subnetwork.
        function self = design_division_synapses( self, neuron_IDs, k, c )
        
            % Set the default input arguments.
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = 1; end
            
            % Design the division subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_division_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic division subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

            % Set the applied current to be the average current.
            I_app = mean( I_apps );
                
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_division_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k, c );
            
        end
        
        
        % Implement a function to design the synapses for a derivation subnetwork.
        function self = design_derivation_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
           if nargin < 3, k = 1e6; end            
            
            % Design the derivation subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_derivation_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps3 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );

            % Determine whether to throw a warning.
            if ~all( I_apps3 == I_apps3( 1 ) ), warning( 'The basic multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

            % Set the applied current to be the average current.
            I_app3 = mean( I_apps3 );
            
            % Compute the subtraction subnetwork gain.
            k_sub = ( 1e6 )/k;

            % Compute and set the maximum synaptic conductances associated with this derivation subnetwork.
            self = self.compute_set_derivation_gsynmaxs( neuron_IDs, synapse_IDs, I_app3, k_sub ); 
            
        end
        
        
        % Implement a function to design the synapses for an integration subnetwork.
        function self = design_integration_synapses( self, neuron_IDs, ki_range )
            
            % Set the default input arugments.
            if nargin < 3, ki_range = 1/( 2*( 1e-9 ) ); end
            
            % Get the synapse IDs that connect the two neurons.
            synapse_ID12 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            synapse_ID21 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 1 ) );
            synapse_IDs = [ synapse_ID12 synapse_ID21 ];

            % Compute and set the integration subnetwork maximum synaptic conductances.
            self = self.compute_set_integration_gsynmaxs( neuron_IDs, synapse_IDs, ki_range );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.
            self = self.compute_set_integration_dEsyns( neuron_IDs, synapse_IDs );    
            
        end
        
        
        %% Subnetwork Design Functions
        
        % Implement a function to design a multistate CPG oscillator subnetwork using existing neurons.
        function self = design_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable )
            
            % Set the default input arguments.
            if nargin < 4, delta_bistable = -10e-3; end
            if nargin < 3, delta_oscillatory = 0.01e-3; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the multistate cpg subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_multistate_cpg_neurons( neuron_IDs );
            
            % Design the multistate cpg subnetwork applied current.
            self = self.design_multistate_cpg_applied_currents( neuron_IDs );
            
            % Design the multistate cpg subnetwork synapses.
            self = self.design_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
            
        
        % Implement a function to design a transmission subnetwork using existing neurons.
        function self = design_transmission_subnetwork( self, neuron_IDs, k )
        
            % Set the default input arugments.
            if nargin < 3, k = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the transmission subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_transmission_neurons( neuron_IDs );
            
            % Design the tranmission subnetwork synapses.
            self = self.design_transmission_synapse( neuron_IDs, k );
            
        end
        
            
        % Implement a function to design a modulation subnetwork using existing neurons.
        function self = design_modulation_subnetwork( self, neuron_IDs, c )
            
            % Set the default input arugments.
            if nargin < 3, c = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulation neurons.
            self.neuron_manager = self.neuron_manager.design_modulation_neurons( neuron_IDs );

            % Design the modulation synapses.
            self = self.design_modulation_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design an addition subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_addition_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_addition_neurons( neuron_IDs );
            
            % Design the addition subnetwork synapses.
            self = self.design_addition_synapses( neuron_IDs, k );
                        
        end
        
        
        % Implement a function to design a subtraction subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_subtraction_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_subtraction_neurons( neuron_IDs );
            
            % Design the subtraction subnetwork synapses.
            self = self.design_subtraction_synapses( neuron_IDs, k );
                        
        end
        
        
        % Implement a function to design a multiplication subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_multiplication_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the multiplication subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_multiplication_neurons( neuron_IDs );

            % Design the multiplication subnetwork applied currents.
            self = self.design_multiplication_applied_currents( neuron_IDs );
            
            % Design the multiplication subnetwork synapses.
            self = self.design_multiplication_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design a division subnetwork ( using the specified neurons & their existin synapses ).
        function self = design_division_subnetwork( self, neuron_IDs, k, c )
            
            % Set the default input arguments.
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = 1; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the division subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_division_neurons( neuron_IDs );
            
            % Design the division subnetwork synapses.
            self = self.design_division_synapses( neuron_IDs, k, c );
            
        end
        
                
        % Implement a function to design a derivation subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_derivation_subnetwork( self, neuron_IDs, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = 0.05; end
            if nargin < 4, w = 1; end
            if nargin < 3, k = 1e6; end            

            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the derivation subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_derivation_neurons( neuron_IDs, k, w, safety_factor );

            % Design the derivation subnetwork synapses.
            self = self.design_derivation_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_integration_subnetwork( self, neuron_IDs, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 4, ki_range = 1/( 2*( 1e-9 ) ); end
            if nargin < 3, ki_mean = 1/( 2*( 1e-9 ) ); end

            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_integration_neurons( neuron_IDs, ki_mean );
            
            % Design the integration applied currents.
            self = self.design_integration_applied_currents( neuron_IDs );
            
            % Design the integration synapses.
            self = self.design_integration_synapses( neuron_IDs, ki_range );
            
        end
        
        
        %% Subnetwork Component Creation Functions
        
        % Implement a function to create the multistate CPG subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multistate_cpg_subnetwork_components( self, num_cpg_neurons )
            
            % Create the multistate cpg neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_multistate_cpg_neurons( num_cpg_neurons );

            % Create the multistate cpg synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_multistate_cpg_synapses( neuron_IDs );

            % Create the multistate cpg applied current.
            [ self.applied_current_manager, applied_current_ID ] = self.applied_current_manager.create_multistate_cpg_applied_currents( neuron_IDs );    
            
        end
        
        
        % Implement a function to create the transmission subnetwork components.
        function [ self, neuron_IDs, synapse_ID ] = create_transmission_subnetwork_components( self )
            
            % Create the transmission neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_transmission_neurons(  );

            % Create the transmission synapses.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.create_transmission_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the modulation subnetwork components.
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork_components( self )
            
            % Create the modulation neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_modulation_neurons(  );

            % Create the modulation synapses.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.create_modulation_synapses( neuron_IDs );    
            
        end
        
        
        % Implement a function to create the addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork_components( self )
           
            % Create the addition neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_addition_neurons(  );

            % Create the addition synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork_components( self )
        
            % Create the subtraction neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_subtraction_neurons(  );

            % Create the subtraction synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork_components( self )
            
            % Create the multiplication neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_multiplication_neurons(  );

            % Create the multiplication synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_multiplication_synapses( neuron_IDs );
            
            % Create the multiplication applied currents.
            [ self.applied_current_manager, applied_current_ID ] = self.applied_current_manager.create_multiplication_applied_currents( neuron_IDs );    
            
        end
        
        
        % Implement a function to create the division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork_components( self )
        
            % Create the division neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_division_neurons(  );
            
            % Create the division synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the derivation subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_derivation_subnetwork_components( self )
        
            % Create the derivation neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_derivation_neurons(  );

            % Create the derivation synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_derivation_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_integration_subnetwork_components( self )
            
            % Create the integration neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_integration_neurons(  );
            
            % Create the integration synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_integration_synapses( neuron_IDs );
            
            % Create the integration applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_integration_applied_currents( neuron_IDs );
            
        end
        
        
        %% Subnetwork Creation Functions
        
        % Implement a function to create a multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multistate_cpg_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable )
        
            % Set the default input arguments.
            if nargin < 4, delta_bistable = -10e-3; end
            if nargin < 3, delta_oscillatory = 0.01e-3; end
            if nargin < 2, num_cpg_neurons = 2; end
                
            % Create the multistate cpg subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multistate_cpg_subnetwork_components( num_cpg_neurons );
            
            % Design the multistate cpg subnetwork.
            self = self.design_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
    
        % Implement a function to create a transmission subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_transmission_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = 1; end
            
            % Create the transmission subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_transmission_subnetwork_components(  );
            
            % Design a transmission subnetwork.
            self = self.design_transmission_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a modulation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork( self, c )
            
            % Set the default input arugments.
            if nargin < 2, c = 0.05; end
            
            % Create the modulation subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_modulation_subnetwork_components(  );
            
            % Design a modulation subnetwork.
            self = self.design_modulation_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create an addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = 1; end
            
            % Create addition subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_addition_subnetwork_components(  );
            
            % Design the addition subnetwork.
            self = self.design_addition_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = 1; end
            
            % Create the subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_subtraction_subnetwork_components(  );
            
            % Design the addition subnetwork.
            self = self.design_subtraction_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = 1; end
            
            % Create the multiplication subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multiplication_subnetwork_components(  );
            
            % Design the multiplication subnetwork.
            self = self.design_multiplication_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a division subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork( self, k, c )
        
            % Set the default input arugments.
            if nargin < 3, c = [  ]; end
            if nargin < 2, k = 1; end
            
            % Create division subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_division_subnetwork_components(  );
            
            % Design the division subnetwork.
            self = self.design_division_subnetwork( neuron_IDs, k, c );
        
        end
        
        
        % Implement a function to create a derivation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_derivation_subnetwork( self, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 4, safety_factor = 0.05; end           
            if nargin < 3, w = 1; end
            if nargin < 2, k = 1e6; end 

            % Create the derivation subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_derivation_subnetwork_components(  );
            
            % Design the derivation subnetwork.
            self = self.design_derivation_subnetwork( neuron_IDs, k, w, safety_factor );

        end
        
        
        % Implement a function to create an integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_integration_subnetwork( self, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 3, ki_range = 0.01e9; end
            if nargin < 2, ki_mean = 0.01e9; end
            
            % Create the integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_integration_subnetwork_components(  );
            
            % Design the integration subnetwork.
            self = self.design_integration_subnetwork( neuron_IDs, ki_mean, ki_range );
            
        end
        
        
        %% Network Validation Functions
        
        % Implement a function to validate the network is setup correctly to simulate.
        function validate_network( self )
                        
            % Ensure that the neuron IDs are unique.
            b_valid = self.neuron_manager.unique_existing_neuron_IDs(  );

            % Throw an error if the neuron IDs were not unique.
            if ~b_valid, error( 'Invalid network.  Neuron IDs must be unique.' ), end
            
            % Ensure that the synapse IDs are unique.
            b_valid = self.synapse_manager.unique_existing_synapse_IDs(  );
            
            % Throw an error if the synapse IDs were not unique.
            if ~b_valid, error( 'Invalid network.  Synapse IDs must be unique.' ), end
            
            % Ensure that the applied current IDs are unique.
            b_valid = self.applied_current_manager.unique_existing_applied_current_IDs(  );
            
            % Throw an error if the synapse IDs were not unique.
            if ~b_valid, error( 'Invalid network.  Applied current IDs must be unique.' ), end
            
            % Ensure that only one synapse connects each pair of neurons.
            b_valid = self.synapse_manager.one_to_one_synapses(  );
            
            % Throw an error if there are multiple synapses per pair of neurons.
            if ~b_valid, error( 'Invalid network.  There must be only one synapse per pair of neurons.' ), end
            
            % Ensure that only one applied current applies to each neuron.
            b_valid = self.applied_current_manager.one_to_one_applied_currents(  );
            
            % Throw an error if there are multiple applied currents per neuron.
            if ~b_valid, error( 'Invalid network.  There must be only one applied current per neuron.' ), end
            
        end
            
        
        %% Simulation Functions
        
        % Implement a function to compute a single network simulation step.
        function [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation_step( self )
            
            % Ensure that the network is constructed properly.
            self.validate_network(  )
            
            % Retrieve the IDs associated with the enabled neurons.
            neuron_IDs = self.neuron_manager.get_enabled_neuron_IDs(  );
            
            % Retrieve basic neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'U' ) );
            hs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'h' ) );
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) );
            Cms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Cm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) )'; Rs = repmat( Rs', [ self.neuron_manager.num_neurons, 1 ] );
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic' ) );
            
            % Retrieve sodium channel neuron properties.
            Ams = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Am' ) );
            Sms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sm' ) );
            dEms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEm' ) );
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Ah' ) );
            Shs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sh' ) );
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEh' ) );
            tauh_maxs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max' ) );
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gna' ) );
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEna' ) );
            
            % Retrieve synaptic properties.
            g_syn_maxs = self.get_gsynmaxs( neuron_IDs );
            dE_syns = self.get_dEsyns( neuron_IDs );
            
            % Retrieve applied currents.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs, self.dt, self.tf )';
            
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
            [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation_step(  );
            
            % Set the neuron properties.
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, Us, 'U' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, hs, 'h' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_leaks, 'I_leak' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_syns, 'I_syn' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_nas, 'I_na' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_totals, 'I_total' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, m_infs, 'm_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, h_infs, 'h_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, tauhs, 'tauh' );
            
            % Set the synapse properties.
            self = self.set_Gsyns( G_syns, neuron_IDs );
            
        end
        
        
        % Implement a function to compute network simulation results.
        function [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation( self, dt, tf, method )
            
            % Set the default simulation duration.
            if nargin < 4, method = 'RK4'; end
            if nargin < 3, tf = self.tf; end
            if nargin < 2, dt = self.dt; end
            
            % Ensure that the network is constructed properly.
            self.validate_network(  )
            
            % Retrieve the IDs associated with the enabled neurons.
            neuron_IDs = self.neuron_manager.get_enabled_neuron_IDs(  );
            
            % Retrieve the neuron properties.
            Us = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'U' ) )';
            hs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'h' ) )';
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gm' ) )';
            Cms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Cm' ) )';
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'R' ) )'; Rs = repmat( Rs', [ length( Rs ), 1 ] );
            Ams = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Am' ) )';
            Sms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sm' ) )';
            dEms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEm' ) )';
            Ahs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Ah' ) )';
            Shs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Sh' ) )';
            dEhs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEh' ) )';
            tauh_maxs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max' ) )';
            Gnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'Gna' ) )';
            dEnas = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'dEna' ) )';
            I_tonics = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic' ) )';
            
            % Retrieve the synapse properties.
            g_syn_maxs = self.get_gsynmaxs( neuron_IDs );
            dE_syns = self.get_dEsyns( neuron_IDs );
            
            % Retrieve the applied currents.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs, self.dt, self.tf, 'ignore' )';
            
%             Us = (1e3)*Us;
%             Gms = (1e6)*Gms;
%             Cms = (1e9)*Cms;
%             Rs = (1e3)*Rs;
%             Sms = (1e-3)*Sms;
%             dEms = (1e3)*dEms;
%             Shs = (1e-3)*Shs;
%             dEhs = (1e3)*dEhs;
%             Gnas = (1e6)*Gnas;
%             dEnas = (1e3)*dEnas;
%             I_tonics = (1e9)*I_tonics;
%             g_syn_maxs = (1e6)*g_syn_maxs;
%             dE_syns = (1e3)*dE_syns;
%             I_apps = (1e9)*I_apps;
            
            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs ] = self.network_utilities.simulate( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, tf, dt, method );
            
%             Us = (1e-3)*Us;
%             Gms = (1e-6)*Gms;
%             Cms = (1e-9)*Cms;
%             Rs = (1e-3)*Rs;
%             Sms = (1e3)*Sms;
%             dEms = (1e-3)*dEms;
%             Shs = (1e3)*Shs;
%             dEhs = (1e-3)*dEhs;
%             Gnas = (1e-6)*Gnas;
%             dEnas = (1e-3)*dEnas;
%             I_tonics = (1e-9)*I_tonics;
%             g_syn_maxs = (1e-6)*g_syn_maxs;
%             dE_syns = (1e-3)*dE_syns;
%             I_apps = (1e-9)*I_apps;
            
        end
        
        
        % Implement a function to compute and set network simulation results.
        function [ self, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_set_simulation( self, dt, tf, method )
            
            % Set the default input arguments.
            if nargin < 4, method = 'RK4'; end
            if nargin < 3, tf = self.tf; end
            if nargin < 2, dt = self.dt; end
            
            % Compute the network simulation results.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = self.compute_simulation( dt, tf, method );
            
            % Set the neuron properties.
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, Us( :, end ), 'U' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, hs( :, end ), 'h' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_leaks( :, end ), 'I_leak' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_syns( :, end ), 'I_syn' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_nas( :, end ), 'I_na' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, I_totals( :, end ), 'I_total' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, m_infs( :, end ), 'm_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, h_infs( :, end ), 'h_inf' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, tauhs( :, end ), 'tauh' );
            
            % Set the synapse properties.
            self = self.set_Gsyns( G_syns( :, :, end ), neuron_IDs );
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save network data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Network.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, 'self' )
            
        end
        
        
        % Implement a function to load network data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Network.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load network data from a xlsx file.
        function self = load_xlsx( self, directory, file_name_neuron, file_name_synapse, file_name_applied_current, b_append, b_verbose )
            
            % Set the default input arguments.
            if nargin < 7, b_verbose = true; end
            if nargin < 6, b_append = false; end
            if nargin < 5, file_name_applied_current = 'Applied_Current_Data.xlsx'; end
            if nargin < 4, file_name_synapse = 'Synapse_Data.xlsx'; end
            if nargin < 3, file_name_neuron = 'Neuron_Data.xlsx'; end
            if nargin < 2, directory = '.'; end
            
            % Create an instance of the neuron manager class.
            self.neuron_manager = neuron_manager_class(  );
            
            % Load the neuron data.
            self.neuron_manager = self.neuron_manager.load_xlsx( file_name_neuron, directory, b_append, b_verbose );
            
            % Create an instance of the synapse manager class.
            self.synapse_manager = synapse_manager_class(  );
            
            % Load the synpase data.
            self.synapse_manager = self.synapse_manager.load_xlsx( file_name_synapse, directory, b_append, b_verbose );
            
            % Create an instance of the applied current manager class.
            self.applied_current_manager = applied_current_manager_class(  );
            
            % Load the applied current data.
            self.applied_current_manager = self.applied_current_manager.load_xlsx( file_name_applied_current, directory, b_append, b_verbose );
            
        end
        
        
    end
end

