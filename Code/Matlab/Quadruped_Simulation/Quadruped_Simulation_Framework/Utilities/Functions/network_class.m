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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design an addition subnetwork with the specified parameters.
        function g_syn_maxs = compute_addition_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) )';
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1:(end - 1) ), 'R' ) )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syns = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs, 'dE_syn' ) )';
            
            % Compute the maximum synaptic conductances for this addition subnetwork.
            g_syn_maxs = self.network_utilities.compute_addition_gsynmax( Gm, Rs, dE_syns, I_app, k );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a subtraction subnetwork with the specified parameters.
        function [ g_syn_maxs1, g_syn_maxs2 ] = compute_subtraction_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = 1; end
            if nargin < 4, I_app3 = 0; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) )';
            Rs1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dE_syns13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) )';
            dE_syns23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) )';

            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ g_syn_maxs1, g_syn_maxs2 ] = self.network_utilities.compute_subtraction_gsynmax( Gm3, Rs1, dE_syns13, dE_syns23, I_app3, k );

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
        
        
        
        %% Subnetwork Design Functions
        
        % Implement a function to design a multistate CPG oscillator subnetwork using existing neurons.
        function self = design_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable )
            
            % Set the default input arguments.
            if nargin < 4, delta_bistable = -10e-3; end
            if nargin < 3, delta_oscillatory = 0.01e-3; end

            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            
            % Set the sodium channel conductance of every neuron in the network using the CPG approach.
            self.neuron_manager = self.neuron_manager.compute_set_cpg_Gna( neuron_IDs );

            % Set the synapse delta values.
            self.synapse_manager = self.synapse_manager.compute_set_cpg_deltas( neuron_IDs, delta_oscillatory, delta_bistable );

            % Compute and set the maximum synaptic conductances required to achieve these delta values.
            self = self.compute_set_cpg_gsynmaxs( neuron_IDs );
            
        end
            
        
        % Implement a function to design an addition subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_addition_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 4, k = 1; end

            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            
            % Set the neuron properties.
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, 10e-9, 'Cm' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, 1e-6, 'Gm' );
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, 20e-3, 'R' );
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(1), neuron_IDs(3) );
            synapse_ID23 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs(2), neuron_IDs(3) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Get the synapse indexes associated with these synapse IDs.
            synapse_index13 = self.synapse_manager.get_synapse_index( synapse_ID13 );
            synapse_index23 = self.synapse_manager.get_synapse_index( synapse_ID23 );

            % Set the synapse reversal potentials.
            self.synapse_manager.synapses( synapse_index13 ).dE_syn = 194e-3;               % [mV] Reversal Potential of Calcium
            self.synapse_manager.synapses( synapse_index23 ).dE_syn = 194e-3;               % [mV] Reversal Potential of Calcium

            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs(end), [  ], [  ], 'ignore' );
            
            % Determine whether this applied current is constant.
            if all( I_apps == I_apps(1) )                % If the applied current is constant...
                
                % Set the applied current to be a scalar version of this applied current.
                I_app = I_apps(1);
            
            else                                        % Otherwise...
                
                % Throw a warning.
                warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to eb the average of the applied current.
                I_app = mean( I_apps );
                
            end
                
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
                        
        end
        
        
        %% Subnetwork Creation Functions
        
        % Implement a function to create a multistate CPG oscillator subnetwork.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multistate_cpg_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable )
        
            % Set the default input arguments.
            if nargin < 4, delta_bistable = -10e-3; end
            if nargin < 3, delta_oscillatory = 0.01e-3; end
            if nargin < 2, num_cpg_neurons = 2; end
                        
            % Determine whether to generate unique neuron IDs or use the specified neuron IDs.
            if length( num_cpg_neurons ) > 1                            % If more than one "number of cpg neurons" was specified...
            
                % Set the neuron IDs to be those specified by the first input argument. ( We assume that this variable is instead the IDs that we would like to use for the newly created neurons.)
                neuron_IDs = num_cpg_neurons;

            else
                
                % Generate unique neuron IDs for the multistate CPG subnetwork.
                neuron_IDs = self.neuron_manager.generate_unique_neuron_IDs( num_cpg_neurons );

            end
                
            % Create the multistate cpg subnetwork neurons.
            self.neuron_manager = self.neuron_manager.create_neurons( neuron_IDs );
            
            % Generate unique synapse IDs for the multistate CPG subnetwork.
            synapse_IDs = self.synapse_manager.generate_unique_synapse_IDs( num_cpg_neurons^2 );
            
            % Create the multistate cpg subnetwork synapses.
            self.synapse_manager = self.synapse_manager.create_synapses( synapse_IDs );
            
            % Generate a unique applied current ID.
            applied_current_ID = self.applied_current_manager.generate_unique_applied_current_ID(  );
            
            % Create the applied current time and current vectors.
            ts = ( 0:self.dt:self.tf )';
            I_apps = zeros( length( ts ), 1 ); I_apps(1) = 20e-9;
            
            % Define the applied current name.
            applied_current_name = sprintf( 'Applied Current %0.0f', applied_current_ID );
            
            % Create an applied current for the first neuron in this multistate cpg subnetwork.
            self.applied_current_manager = self.applied_current_manager.create_applied_current( applied_current_ID, applied_current_name, neuron_IDs(end), ts, I_apps, true );
            
            % Initialize a counter variable.
            k3 = 0;
            
            % Edit the network properties.
            for k1 = 1:num_cpg_neurons                              % Iterate through each of the CPG neurons (from which the synapses are starting)...
                
                % Get the index associated with this neuron.
                neuron_index = self.neuron_manager.get_neuron_index( neuron_IDs(k1) );
                
                % Set this neurons name.
                self.neuron_manager.neurons( neuron_index ).name = sprintf( 'Neuron %0.0f', neuron_IDs(k1) );
                
                for k2 = 1:num_cpg_neurons                          % Iterate through each of the CPG neurons (to which the synapses are going)...
                   
                    % Advance the counter variable.
                    k3 = k3 + 1;
                    
                    % Get the index associated with this synapse.
                    synapse_index = self.synapse_manager.get_synapse_index( synapse_IDs(k3) );
                                        
                    % Set the from neuron ID and to neuron ID.
                    self.synapse_manager.synapses( synapse_index ).from_neuron_ID = neuron_IDs( k1 );
                    self.synapse_manager.synapses( synapse_index ).to_neuron_ID = neuron_IDs( k2 );
                    
                    % Set the name of this synapse.
                    self.synapse_manager.synapses( synapse_index ).name = sprintf( 'Syn %0.0f%0.0f', neuron_IDs( k1 ), neuron_IDs( k2 ) );
                    
                    % Set the reversal potential of this synapse (if necessary).
                    if k1 == k2, self.synapse_manager.synapses( synapse_index ).dE_syn = 0; end
                    
                end
            end
            
            % Design the multistate cpg subnetwork.
            self = self.design_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
    
        % Implement a function to create an addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = 1; end
            
            % Specify the (constant) number of neuron IDs to generate.
            num_neuron_IDs = 3;
            
            % Generate unique neuron IDs for the addition subnetwork.
            neuron_IDs = self.neuron_manager.generate_unique_neuron_IDs( num_neuron_IDs );
                
            % Create the addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.create_neurons( neuron_IDs );
            
            % Set the names of the addition subnetwork neurons. 
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, { 'Add 1', 'Add 2', 'Sum' }, 'name'  );
            
            % Set the sodium channel conductance of the addition neurons to zero.
            self.neuron_manager = self.neuron_manager.set_neuron_property( neuron_IDs, zeros( 1, num_neuron_IDs ), 'Gna' );
            
            % Specify the (constant) number of synapse IDs to generate.
            num_synapse_IDs = 2;
            
            % Generate unique synapse IDs for the addition subnetwork.
            synapse_IDs = self.synapse_manager.generate_unique_synapse_IDs( num_synapse_IDs );
            
            % Create the addition subnetwork synapses.
            self.synapse_manager = self.synapse_manager.create_synapses( synapse_IDs );
            
            % Set the names of the addition subnetwork synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, { 'Add 13', 'Add 23' }, 'name' );
            
            % Connect the addition subnetwork synapses to the addition subnetwork neurons.
            self.synapse_manager = self.synapse_manager.connect_synapses( synapse_IDs, [ neuron_IDs(1) neuron_IDs(2) ], [ neuron_IDs(3) neuron_IDs(3) ] );
            
            % Design the addition subnetwork.
            self = self.design_addition_subnetwork( neuron_IDs, k );
        
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
        function [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation( self, dt, tf )
            
            % Set the default simulation duration.
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
            
            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = self.network_utilities.simulate( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, tf, dt );
            
        end
        
        
        % Implement a function to compute and set network simulation results.
        function [ self, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_set_simulation( self, dt, tf )
            
            % Set the default input arguments.
            if nargin < 3, tf = self.tf; end
            if nargin < 2, dt = self.dt; end
            
            % Compute the network simulation results.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = self.compute_simulation( dt, tf );
            
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

