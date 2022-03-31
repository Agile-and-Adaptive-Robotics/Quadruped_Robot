classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager
        synapse_manager
        applied_current_manager
        applied_voltage_manager
        
        dt
        tf
        
        network_utilities
        numerical_method_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
    
        K_TRANSMISSION = 1;
        C_MODULATION = 0.05;
        
        K_ADDITION = 1;
        K_SUBTRACTION = 1;
        
        K_MULTIPLICATION = 1;
        K_DIVISION = 1;
        
        K_DERIVATION = 1e6;
        W_DERIVATION = 1;
        SF_DERIVATION = 0.05;
        
        K_INTEGRATION_MEAN = 0.01e9;
        K_INTEGRATION_RANGE = 0.01e9;

        I_APP = 0;
        
        DELTA_BISTABLE = -10e-3;
        DELTA_OSCILLATORY = 0.01e-3;
        
        I_DRIVE_MAX = 1.25e-9;              % [A] Maximum Drive Current.
        
        T_OSCILLATION = 2;                  % [s] Oscillation Period. 
        r_OSCILLATION = 0.90;               % [-] Oscillation Decay.
        
        NUM_CPG_NEURONS = 2;                % [#] Number of CPG Neurons.
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( dt, tf, neuron_manager, synapse_manager, applied_current_manager, applied_voltage_manager )
            
            % Create an instance of the numeriacl methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class(  );
            
            % Create an instance of the network utilities class.
            self.network_utilities = network_utilities_class(  );
            
            % Set the default network properties.
            if nargin < 6, self.applied_voltage_manager = applied_voltage_manager_class(  ); else, self.applied_voltage_manager = applied_voltage_manager; end
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
            if nargin < 5, k = self.K_TRANSMISSION; end
            if nargin < 4, I_app2 = self.I_APP; end

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
            if nargin < 5, c = self.C_MODULATION; end
            if nargin < 4, I_app2 = self.I_APP; end
            
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
            if nargin < 5, k = self.K_ADDITION; end
            if nargin < 4, I_app3 = self.I_APP; end

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
            if nargin < 5, k = self.K_SUBTRACTION; end
            if nargin < 4, I_app3 = self.I_APP; end

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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multiplication subnetwork with the specifed parameters.
        function g_syn_maxs = compute_multiplication_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, I_app4, k )
        
            % Set the default input arguments.
            if nargin < 6, k = self.K_MULTIPLICATION; end
            if nargin < 5, I_app4 = self.I_APP; end
            if nargin < 4, I_app3 = self.I_APP; end

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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a division subnetwork with the specified parameters.
        function g_syn_maxs = compute_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = self.K_DIVISION; end
            if nargin < 4, I_app3 = self.I_APP; end

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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a derivation subnetwork with the specified parameters.
        function g_syn_maxs = compute_derivation_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.K_DERIVATION; end
            if nargin < 4, I_app3 = self.I_APP; end

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
            if nargin < 3, ki_range = self.K_INTEGRATION_RANGE; end
            
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
            
            % Retrieve the membrane conductances and voltage domains.
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
            Iapp = self.network_utilities.compute_integration_Iapp( Gms( 1 ), Rs( 1 ) );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function g_syn_maxs = compute_vb_integration_gsynmaxs( self, neuron_IDs, synapse_IDs, T, n, ki_mean )
        
            % Set the default input arguments.
            if nargin < 6, ki_mean = self.K_INTEGRATION_MEAN; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the relevant neuron data.
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );

            % Retrieve the relevant synpase data.
            dE_syn13 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dE_syn' ) );
            dE_syn23 = cell2mat( self.synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dE_syn' ) );

            % Compute activation period of the associated multistate cpg subnetwork.
            Ta = self.network_utilities.compute_activation_period( T, n );
            
            % Compute the voltage based integration subnetwork intermediate synaptic conductances.
            I_syn13 = self.network_utilities.compute_vb_integration_Isyn( R3, Ta, ki_mean, false );
            I_syn23 = self.network_utilities.compute_vb_integration_Isyn( R3, Ta, ki_mean, true );

            % Compute the voltage based integration subnetwork maximum synaptic conductances.
            g_syn_max13 = self.network_utilities.compute_vb_integration_gsynmax( R3, dE_syn13, I_syn13 );
            g_syn_max23 = self.network_utilities.compute_vb_integration_gsynmax( R3, dE_syn23, I_syn23 );

            % Store the voltage based integration subnetwork maximum synaptic conductances in an array.
            g_syn_maxs = [ g_syn_max13 g_syn_max23 ];
            
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
            if nargin < 5, k = self.K_TRANSMISSION; end
            if nargin < 4, I_app = self.I_APP; end
            
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
            if nargin < 5, c = self.C_MODULATION; end
            if nargin < 4, I_app = self.I_APP; end
            
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
            if nargin < 5, k = self.K_ADDITION; end
            if nargin < 4, I_app = self.I_APP; end
            
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
            if nargin < 5, k = self.K_SUBTRACTION; end
            if nargin < 4, I_app = self.I_APP; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_subtraction_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a multiplication subnetwork.
        function self = compute_set_multiplication_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, I_app4, k )
            
            % Set the default input arguments.
            if nargin < 6, k = self.K_MULTIPLICATION; end
            if nargin < 5, I_app4 = self.I_APP; end
            if nargin < 4, I_app3 = self.I_APP; end

            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.                                    
            g_syn_maxs = self.compute_multiplication_gsynmaxs( neuron_IDs, synapse_IDs, I_app3, I_app4, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a division subnetwork.
        function self = compute_set_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = self.K_DIVISION; end
            if nargin < 4, I_app = self.I_APP; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.            
            g_syn_maxs = self.compute_division_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k, c );
                        
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );            
        
        end
        
                
        % Implement a function to compute and set the maximum synaptic conductances for a derivation subnetwork.
        function self = compute_set_derivation_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
        
            % Set the default input arguments.
            if nargin < 5, k = self.K_DERIVATION; end
            if nargin < 4, I_app = self.I_APP; end
            
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
            if nargin < 4, ki_range = self.K_INTEGRATION_RANGE; end
            
            % Compute the maximum synaptic conductances for the integration subnetwork.
            g_syn_max = self.compute_integration_gsynmax( neuron_IDs, ki_range );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_max*ones( 1, 2 ), 'g_syn_max' );   
        
        end
        
        
        % Implement a function to compute and set the synaptic reversal potentials for an integration subnetwork.
        function self = compute_set_integration_dEsyns( self, neuron_IDs, synapse_IDs )
            
            % Compute the synaptic reversal potentials for an integration subnetwork.
            dEsyn = self.compute_integration_dEsyn( neuron_IDs, synapse_IDs );

            % Set the synaptic reversal potentials of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, dEsyn*ones( 1, 2 ), 'dE_syn' );   
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a voltage based integration subnetwork.
        function self = compute_set_vb_integration_gsynmaxs( self, neuron_IDs, synapse_IDs, T, n, ki_mean )
            
            % Set the default input arguments.
            if nargin < 6, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Compute the maximum synaptic conductances for the voltage based integration subnetwork neurons.
            g_syn_maxs = self.compute_vb_integration_gsynmaxs( neuron_IDs, synapse_IDs, T, n, ki_mean );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs( 1:2 ), g_syn_maxs, 'g_syn_max' );  
            
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
        
        
        % Implement a function to design the applied currents for a driven multistate cpg subnetwork.
        function self = design_driven_multistate_cpg_applied_currents( self, neuron_IDs )
            
            % Design the multistate cpg applied currents.
            self = self.design_multistate_cpg_applied_currents( neuron_IDs( 1:( end - 1 ) ) );
            
            % Retrieve the relevant neuron properties of the drive neuron.
            Gm = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) );
            R = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'R' ) );

            % Design the driven multistate cpg applied current.
            self.applied_current_manager = self.applied_current_manager.design_driven_multistate_cpg_applied_current( neuron_IDs( end ), Gm, R );
            
        end

        
        % Implement a function to design the applied currents for a driven multistate cpg split lead lag subnetwork.
        function self = design_dmcpg_sll_applied_currents( self, neuron_IDs_cell )
        
            % Retrieve the number of cpg neurons.
            num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Design the applied currents for the driven multistate cpg subnetworks.
            self = self.design_driven_multistate_cpg_applied_currents( neuron_IDs_cell{ 1 } );
            self = self.design_driven_multistate_cpg_applied_currents( neuron_IDs_cell{ 2 } );

            % Design the applied currents for the modulated split subtraction voltage based integration subnetworks.
            for k = 1:num_cpg_neurons                               % Iterate through each of the cpg neurons...
                
                % Design the applied currents for this modulated split subtraction voltage based integration subnetwork
                self = self.design_mod_split_sub_vb_integration_applied_currents( neuron_IDs_cell{ k + 2 } );
            
            end
        
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
            
            % Design the integration subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_integration_applied_currents( neuron_IDs, Gms( 1 ), Rs( 1 ) );
            
        end
        
        
        % Implement a function to design the applied currents for a voltage based integration subnetwork.
        function self = design_vb_integration_applied_currents( self, neuron_IDs )
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'Gm' ) );
            Rs = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'R' ) );
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Design the voltage based integration subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_integration_applied_currents( neuron_IDs( 3:4 ), Gms( 1 ), Rs( 1 ) );
            
        end
        
        
        % Implement a function to design the applied currents for a split voltage based integration subnetwork.
        function self = design_split_vb_integration_applied_currents( self, neuron_IDs )
            
            % Retrieve the relevant membrane conductance.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            Gm4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm' ) );
            Gm9 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 9 ), 'Gm' ) );
            Gms = [ Gm3 Gm4 Gm9 ];
            
            % Retrieve the relevant voltage domains.
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );            
            R4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R' ) );            
            Rs = [ R3 R4 ];
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gm3 == Gm4, 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( R3 == R4, 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Design the voltage based integration subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_split_vb_integration_applied_currents( [ neuron_IDs( 3 ) neuron_IDs( 4 ) neuron_IDs( 9 ) ], Gms, Rs );

        end
        
        
        % Implement a function to design the applied currents for a modulated split voltage based integration subnetwork.
        function self = design_mod_split_vb_integration_applied_currents( self, neuron_IDs )
            
            % Design the split voltage based integration applied currents.
            self = self.design_split_vb_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a modulated split difference voltage based integration subnetwork.
        function self = design_mod_split_sub_vb_integration_applied_currents( self, neuron_IDs )
            
            % Design the modulated split voltage based integration applied currents.
            self = self.design_mod_split_vb_integration_applied_currents( neuron_IDs( 5:end ) );
            
%             % Design the modulated split voltage based integration applied currents.
%             self = self.design_mod_split_vb_integration_applied_currents( neuron_IDs( 1:( end - 4 ) ) );
            
        end
                
                
        %% Subnetwork Neuron Design Functions
        
        % Implement a function to design the neurons for a multistate cpg subnetwork.
        function self = design_multistate_cpg_neurons( self, neuron_IDs )
            
            % Design the multistate cpg subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_multistate_cpg_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg subnetwork.
        function self = design_driven_multistate_cpg_neurons( self, neuron_IDs )
            
            % Design the multistate cpg neurons.
            self = self.design_multistate_cpg_neurons( neuron_IDs( 1:( end - 1 ) ) );
            
            % Design the drive neuron.
            self.neuron_manager = self.neuron_manager.design_driven_multistate_cpg_neurons( neuron_IDs( end ) );
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg split lead lag subnetwork.
        function self = design_dmcpg_sll_neurons( self, neuron_IDs_cell, T, ki_mean, r )
        
            % Set the default input arguments.
            if nargin < 5, r = self.r_OSCILLATION; end
            if nargin < 4, ki_mean = self.K_INTEGRATION_MEAN; end
            if nargin < 3, T = self.T_OSCILLATION; end
            
            % Retrieve the number of cpg neurons.
            num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Design the driven multistate CPG neurons.
            self = self.design_driven_multistate_cpg_neurons( neuron_IDs_cell{ 1 } );
            self = self.design_driven_multistate_cpg_neurons( neuron_IDs_cell{ 2 } );

            % Design the modulated split subtraction voltage based integration subnetwork neurons.
            for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
            
                % Design the neurons of this modulated split subtraction voltage based integration subnetworks.
                self = self.design_mod_split_sub_vb_integration_neurons( neuron_IDs_cell{ k + 2 }, ki_mean );
                
            end
            
            % Design the split lead lag subnetwork neurons.
            self = self.design_addition_neurons( neuron_IDs_cell{ end }( 1:2 ) );
            self = self.design_slow_transmission_neurons( neuron_IDs_cell{ end }( 3:4 ), num_cpg_neurons, T, r );
            
        end
        
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function self = design_transmission_neurons( self, neuron_IDs )
            
            % Design the transmission subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_transmission_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function self = design_slow_transmission_neurons( self, neuron_IDs, num_cpg_neurons, T, r )
            
            % Design the slow transmission subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_slow_transmission_neurons( neuron_IDs, num_cpg_neurons, T, r );
            
        end
        
                
        % Implement a function to design the neurons for a modulation subnetwork.
        function self = design_modulation_neurons( self, neuron_IDs )
            
            % Design the modulation subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_modulation_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an addition subnetwork.
        function self = design_addition_neurons( self, neuron_IDs )
            
            % Design the addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_addition_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a subtraction subnetwork.
        function self = design_subtraction_neurons( self, neuron_IDs )
            
            % Design the subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_subtraction_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a double subtraction subnetwork.
        function self = design_double_subtraction_neurons( self, neuron_IDs )
            
            % Design the double subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_double_subtraction_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a multiplication subnetwork.
        function self = design_multiplication_neurons( self, neuron_IDs )
            
            % Design the multiplication subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_multiplication_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a division subnetwork.
        function self = design_division_neurons( self, neuron_IDs )
            
            % Design the division subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_division_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a derivation subnetwork.
        function self = design_derivation_neurons( self, neuron_IDs, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.SF_DERIVATION; end
            if nargin < 4, w = self.W_DERIVATION; end
            if nargin < 3, k = self.K_DERIVATION; end     
            
            % Design the derivation subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_derivation_neurons( neuron_IDs, k, w, safety_factor );
            
        end
        
        
        % Implement a function to design the neurons for an integration subnetwork.
        function self = design_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end    
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_integration_neurons( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function self = design_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_vb_integration_neurons( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a split voltage based integration subnetwork.
        function self = design_split_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_split_vb_integration_neurons( neuron_IDs, ki_mean );
            
        end
            
        
        % Implement a function to design the neurons for a modulated split voltage based integration subnetwork.
        function self = design_mod_split_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % Design the split voltage based integration neurons.
            self = self.design_split_vb_integration_neurons( neuron_IDs( 1:9 ), ki_mean );
            
            % Design the modulation neurons.
            self = self.design_modulation_neurons( neuron_IDs( 10:12 ) );
            
        end
        
        
        % Implement a function to design the neurons for a modulated split difference voltage based integration subnetwork.
        function self = design_mod_split_sub_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end  
            
            % Design the double subtraction neurons.
            self = self.design_double_subtraction_neurons( neuron_IDs( 1:4 ) );
            
            % Design the modulated split voltage based integration neurons.
            self = self.design_mod_split_vb_integration_neurons( neuron_IDs( 5:end ), ki_mean );
            
        end
        
        
            
        %% Subnetwork Synapse Design Functions
        
        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function self = design_multistate_cpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable )
           
            % Design the multistate cpg subnetwork synapses.
            self.synapse_manager = self.synapse_manager.design_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable );

            % Compute and set the maximum synaptic conductances required to achieve these delta values.
            self = self.compute_set_cpg_gsynmaxs( neuron_IDs );
            
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg subnetwork.
        function self = design_driven_multistate_cpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max )
           
            % Design the synapses of the multistate cpg subnetwork.
            self = self.design_multistate_cpg_synapses( neuron_IDs( 1:( end - 1 ) ), delta_oscillatory, delta_bistable );
            
            % Design the driven multistate cpg subnetwork synapses.
            self.synapse_manager = self.synapse_manager.design_driven_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, I_drive_max );
            
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg split lead lag subnetwork.
        function self = design_dmcpg_sll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod )
           
            % Set the default input arguments.
            if nargin < 11, c_mod = self.C_MODULATION; end
            if nargin < 10, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 9, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 8, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 7, ki_mean = self.K_INTEGRATION_MEAN; end
            if nargin < 6, T = self.T_OSCILLATION; end
            if nargin < 5, I_drive_max = self.I_DRIVE_MAX; end
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
        
            % Design the synapses of the driven multistate cpg subnetworks.
            self = self.design_driven_multistate_cpg_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, I_drive_max );
            self = self.design_driven_multistate_cpg_synapses( neuron_IDs_cell{ 2 }, delta_oscillatory, delta_bistable, I_drive_max );

            % Compute the number of cpg neurons.
            num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Compute the number of transmission pathways to design.
            num_transmission_synapses = 4*num_cpg_neurons + 2;
            
            % Preallocate an array to store the from and to neuron IDs.
            [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_transmission_synapses ) );
            
            % Design the synapses of the modulated split subtraction voltage based integration subnetworks.
            for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
                
                % Design the synapses of this modulated split subtraction voltage based integration subnetwork.
                self = self.design_mod_split_sub_vb_integration_synapses( neuron_IDs_cell{ k + 2 }, T, num_cpg_neurons, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
                % Compute the index variable.
                index = 4*(k - 1) + 1;
                
                % Store these pairs of from and to neuron IDs.
                from_neuron_IDs( index ) = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_IDs( index ) = neuron_IDs_cell{ end }( 1 );
                from_neuron_IDs( index + 1 ) = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_IDs( index + 1 ) = neuron_IDs_cell{ end }( 2 );
                from_neuron_IDs( index + 2 ) = neuron_IDs_cell{ 1 }( k ); to_neuron_IDs( index + 2 ) = neuron_IDs_cell{ k + 2 }( 1 );
                from_neuron_IDs( index + 3 ) = neuron_IDs_cell{ 2 }( k ); to_neuron_IDs( index + 3 ) = neuron_IDs_cell{ k + 2 }( 2 );

            end
            
            % Define the final pair of from and to neuron IDs.
            from_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 1 ); to_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 3 );
            from_neuron_IDs( end ) = neuron_IDs_cell{ end }( 2 ); to_neuron_IDs( end ) = neuron_IDs_cell{ end }( 4 );

            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways.
               
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function self = design_transmission_synapse( self, neuron_IDs, k, b_applied_current_compensation )
           
            % Set the default input arugments.
            if nargin < 4, b_applied_current_compensation = true; end
            if nargin < 3, k = self.K_TRANSMISSION; end
            
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
            if nargin < 3, c = self.C_MODULATION; end
            
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
            if nargin < 3, k = self.K_ADDITION; end
            
            % Design the addition subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_addition_synapses( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            I_app = mean( I_apps );
            
            % Compute and set the maximum synaptic conductances necessary to design this addition subnetwork.
            self = self.compute_set_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
        end
        
        
        % Implement a function to design the synapses for a subtraction subnetwork.
        function self = design_subtraction_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_SUBTRACTION; end
            
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
        
        
        % Implement a function to design the synapses for a double subtraction subnetwork.
        function self = design_double_subtraction_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_SUBTRACTION; end
            
            % Retrieve the neuron IDs associated with each subtraction subnetwork.
            neuron_IDs1 = neuron_IDs( 1:3 );
            neuron_IDs2 = [ neuron_IDs( 2 ) neuron_IDs( 1 ) neuron_IDs( 4 ) ];
            
            % Design the subtraction subnetwork synapses.
            [ self.synapse_manager, synapse_IDs1 ] = self.synapse_manager.design_subtraction_synapses( neuron_IDs1 );
            [ self.synapse_manager, synapse_IDs2 ] = self.synapse_manager.design_subtraction_synapses( neuron_IDs2 );

            % Get the applied current associated with the final neuron.
            I_apps1 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            I_apps2 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 4 ), [  ], [  ], 'ignore' );

            % Determine whether to throw a warning.
            if ~all( I_apps1 == I_apps1( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            if ~all( I_apps2 == I_apps2( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end

            % Set the applied current to be the average current.
            I_app1 = mean( I_apps1 );
            I_app2 = mean( I_apps2 );

            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_subtraction_gsynmaxs( neuron_IDs1, synapse_IDs1, I_app1, k );
            self = self.compute_set_subtraction_gsynmaxs( neuron_IDs2, synapse_IDs2, I_app2, k );

        end
        
        
        % Implement a function to design the synapses for a multiplication subnetwork.
        function self = design_multiplication_synapses( self, neuron_IDs, k )
            
           % Set the default input arguments.
            if nargin < 3, k = self.K_MULTIPLICATION; end
            
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
            if nargin < 3, k = self.K_DIVISION; end
            
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
           if nargin < 3, k = self.K_DERIVATION; end            
            
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
            if nargin < 3, ki_range = self.K_INTEGRATION_RANGE; end
            
            % Design the integration subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_integration_synapses( neuron_IDs );
            
            % Compute and set the integration subnetwork maximum synaptic conductances.
            self = self.compute_set_integration_gsynmaxs( neuron_IDs, synapse_IDs, ki_range );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.
            self = self.compute_set_integration_dEsyns( neuron_IDs, synapse_IDs );    
            
        end
        
        
        % Implement a function to design the synapses for a voltage based integration subnetwork.
        function self = design_vb_integration_synapses( self, neuron_IDs, T, n, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end

            % Design the derivation subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.design_vb_integration_synapses( neuron_IDs );
            
            % Get the synapse IDs that connect the two neurons.
            synapse_ID34 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 3 ), neuron_IDs( 4 ) );
            synapse_ID43 = self.synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 4 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_IDs synapse_ID34 synapse_ID43 ];

            % Compute and set the integration subnetwork maximum synaptic conductances.
            self = self.compute_set_integration_gsynmaxs( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ), ki_range );                % Note: For a basic integration subnetwork, this calculation maximum synaptic conductance must be computed before the synaptic reversal potential.
            
            % Compute and set the integration subnetwork synaptic reversal potentials.
            self = self.compute_set_integration_dEsyns( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ) );                            % Note: For a basic integration subnetwork, this calculation maximum synaptic conductance must be computed before the synaptic reversal potential.
                        
            % Compue and set the voltage based integration subnetwork maximum synaptic conductance.
            self = self.compute_set_vb_integration_gsynmaxs( neuron_IDs, synapse_IDs, T, n, ki_mean );

        end
        
        
        % Implement a function to design the synapses for a split voltage based integration subnetwork.
        function self = design_split_vb_integration_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub )
            
            % Set the default input arugments.
            if nargin < 7, k_sub = self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Design the voltage based integration synapses.
            self = self.design_vb_integration_synapses( neuron_IDs( 1:4 ), T, n, ki_mean, ki_range );
            
            % Design the double subtraction synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs( 5:8 ), k_sub );
            
            % Design the transmission synapses. NOTE: Neuron IDs are in this order: { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1' }
            self = self.design_transmission_synapse( [ neuron_IDs( 9 ) neuron_IDs( 6 ) ], 1, false );
            self = self.design_transmission_synapse( [ neuron_IDs( 3 ) neuron_IDs( 5 ) ], 1, false );

        end
                
        
        % Implement a function to design the synapses for a modulated split voltage based integration subnetwork.
        function self = design_mod_split_vb_integration_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod )
    
            % Set the default input arugments.
            if nargin < 8, c_mod = self.C_MODULATION; end
            if nargin < 7, k_sub = 2*self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Design the synapses for a split voltage based integration subnetwork.
            self = self.design_split_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub );
            
            % Design the modulation synapses.
            self = self.design_modulation_synapses( [ neuron_IDs( 10 ) neuron_IDs( 11 ) ], c_mod )  ;          
            self = self.design_modulation_synapses( [ neuron_IDs( 10 ) neuron_IDs( 12 ) ], c_mod )  ;          

            % Design the transmission synapses.
            self = self.design_transmission_synapse( [ neuron_IDs( 7 ) neuron_IDs( 11 ) ], 1, false );
            self = self.design_transmission_synapse( [ neuron_IDs( 8 ) neuron_IDs( 12 ) ], 1, false );
            self = self.design_transmission_synapse( [ neuron_IDs( 1 ) neuron_IDs( 10 ) ], 1, false );
            self = self.design_transmission_synapse( [ neuron_IDs( 2 ) neuron_IDs( 10 ) ], 1, false );

        end
            
        
        % Implement a function to design the synapses for a modulated split difference voltage based integration subnetwork.
        function self = design_mod_split_sub_vb_integration_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod )
    
            % Set the default input arugments.
            if nargin < 9, c_mod = self.C_MODULATION; end
            if nargin < 8, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 7, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Design the double subtraction synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs( 1:4 ), k_sub2 );
            
            % Design the modulated split voltage based integration synapses.
            self = self.design_mod_split_vb_integration_synapses( neuron_IDs( 5:end ), T, n, ki_mean, ki_range, k_sub1, c_mod );
            
            % Design the transmission synapses.            
            self = self.design_transmission_synapse( [ neuron_IDs( 3 ) neuron_IDs( 5 ) ], 1, false );
            self = self.design_transmission_synapse( [ neuron_IDs( 4 ) neuron_IDs( 6 ) ], 1, false );
            
        end        
        
        
        %% Subnetwork Design Functions
        
        % Implement a function to design a multistate CPG oscillator subnetwork using existing neurons.
        function self = design_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable )
            
            % Set the default input arguments.
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the multistate cpg subnetwork neurons.
            self = self.design_multistate_cpg_neurons( neuron_IDs );
            
            % Design the multistate cpg subnetwork applied current.
            self = self.design_multistate_cpg_applied_currents( neuron_IDs );
            
            % Design the multistate cpg subnetwork synapses.
            self = self.design_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
            
        
        % Implement a function to design a driven multistate CPG oscillator subnetwork using existing neurons.
        function self = design_driven_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max )
            
            % Set the default input arguments.
            if nargin < 5, I_drive_max = self.I_DRIVE_MAX; end
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate cpg subnetwork neurons.
            self = self.design_driven_multistate_cpg_neurons( neuron_IDs );
            
            % Design the driven multistate cpg subnetwork applied current.
            self = self.design_driven_multistate_cpg_applied_currents( neuron_IDs );
            
            % Design the driven multistate cpg subnetwork synapses.
            self = self.design_driven_multistate_cpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max );
            
        end
        
        
        % Implement a function to design a driven multistate CPG split lead lag subnetwork using existing neurons.
        function self = design_dmcpg_sll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r )

            % Set the default input arguments.
            if nargin < 12, r = self.r_OSCILLATION; end
            if nargin < 11, c_mod = self.C_MODULATION; end
            if nargin < 10, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 9, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 8, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 7, ki_mean = self.K_INTEGRATION_MEAN; end
            if nargin < 6, T = self.T_OSCILLATION; end
            if nargin < 5, I_drive_max = self.I_DRIVE_MAX; end
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end

            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.

            % Design the driven multistate CPG split lead lag subnetwork neurons.
            self = self.design_dmcpg_sll_neurons( neuron_IDs_cell, T, ki_mean, r );
            
            % Design the driven multistate CPG split lead lag subnetwork applied currents.
            self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell );
            
            % Design the driven multistate CPG split lead lag subnetwork synapses.
            self = self.design_dmcpg_sll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
        end
        
                
        % Implement a function to design a transmission subnetwork using existing neurons.
        function self = design_transmission_subnetwork( self, neuron_IDs, k )
        
            % Set the default input arugments.
            if nargin < 3, k = self.K_TRANSMISSION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the transmission subnetwork neurons.
            self = self.design_transmission_neurons( neuron_IDs );
            
            % Design the tranmission subnetwork synapses.
            self = self.design_transmission_synapse( neuron_IDs, k );
            
        end
        
            
        % Implement a function to design a modulation subnetwork using existing neurons.
        function self = design_modulation_subnetwork( self, neuron_IDs, c )
            
            % Set the default input arugments.
            if nargin < 3, c = self.C_MODULATION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulation neurons.
            self = self.design_modulation_neurons( neuron_IDs );

            % Design the modulation synapses.
            self = self.design_modulation_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design an addition subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_addition_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_ADDITION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the addition subnetwork neurons.
            self = self.design_addition_neurons( neuron_IDs );
            
            % Design the addition subnetwork synapses.
            self = self.design_addition_synapses( neuron_IDs, k );
                        
        end
        
        
        % Implement a function to design a subtraction subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_subtraction_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_SUBTRACTION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the subtraction subnetwork neurons.
            self = self.design_subtraction_neurons( neuron_IDs );
            
            % Design the subtraction subnetwork synapses.
            self = self.design_subtraction_synapses( neuron_IDs, k );
                        
        end
        
        
        % Implement a function to design a double subtraction subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_double_subtraction_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_SUBTRACTION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the double subtraction subnetwork neurons.
            self = self.design_double_subtraction_neurons( neuron_IDs );
            
            % Design the double subtraction subnetwork synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs, k );
                        
        end
        
        
        % Implement a function to design a multiplication subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_multiplication_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.K_MULTIPLICATION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the multiplication subnetwork neurons.
            self = self.design_multiplication_neurons( neuron_IDs );

            % Design the multiplication subnetwork applied currents.
            self = self.design_multiplication_applied_currents( neuron_IDs );
            
            % Design the multiplication subnetwork synapses.
            self = self.design_multiplication_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design a division subnetwork ( using the specified neurons & their existin synapses ).
        function self = design_division_subnetwork( self, neuron_IDs, k, c )
            
            % Set the default input arguments.
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = self.K_DIVISION; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the division subnetwork neurons.
            self = self.design_division_neurons( neuron_IDs );
            
            % Design the division subnetwork synapses.
            self = self.design_division_synapses( neuron_IDs, k, c );
            
        end
        
                
        % Implement a function to design a derivation subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_derivation_subnetwork( self, neuron_IDs, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.SF_DERIVATION; end
            if nargin < 4, w = self.W_DERIVATION; end
            if nargin < 3, k = self.K_DERIVATION; end            

            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the derivation subnetwork neurons.
            self = self.design_derivation_neurons( neuron_IDs, k, w, safety_factor );

            % Design the derivation subnetwork synapses.
            self = self.design_derivation_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_integration_subnetwork( self, neuron_IDs, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 4, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 3, ki_mean = self.K_INTEGRATION_MEAN; end

            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the integration subnetwork neurons.
            self = self.design_integration_neurons( neuron_IDs, ki_mean );
            
            % Design the integration applied currents.
            self = self.design_integration_applied_currents( neuron_IDs );
            
            % Design the integration synapses.
            self = self.design_integration_synapses( neuron_IDs, ki_range );
            
        end
        
        
        % Implement a function to design a voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range )
        
            % Set the default input arguments.
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the voltage based integration subnetwork neurons.
            self = self.design_vb_integration_neurons( neuron_IDs, ki_mean );

            % Design the voltage based integration applied currents.
            self = self.design_vb_integration_applied_currents( neuron_IDs );
            
            % Design the voltage based integration synapses.
            self = self.design_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to design a split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_split_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub )
            
            % Set the default input arguments.
            if nargin < 7, k_sub = 2*self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the split voltage based integration subnetwork neurons.
            self = self.design_split_vb_integration_neurons( neuron_IDs, ki_mean );

            % Design the split voltage based integration applied currents.
            self = self.design_split_vb_integration_applied_currents( neuron_IDs );
            
            % Design the split voltage based integration synapses.
            self = self.design_split_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub );
            
        end
        
        
        % Implement a function to design a modulated split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_mod_split_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod )
            
            % Set the default input arguments.
            if nargin < 8, c_mod = self.C_MODULATION; end
            if nargin < 7, k_sub = 2*self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the modulated split voltage based integration subnetwork neurons.
            self = self.design_mod_split_vb_integration_neurons( neuron_IDs, ki_mean );

            % Design the modulated split voltage based integration applied currents.
            self = self.design_mod_split_vb_integration_applied_currents( neuron_IDs );
            
            % Design the modulated split voltage based integration synapses.
            self = self.design_mod_split_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod );
            
        end
        
        
        % Implement a function to design a modulated difference split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_mod_split_sub_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod )
            
            % Set the default input arguments.
            if nargin < 9, c_mod = self.C_MODULATION; end
            if nargin < 8, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 7, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 6, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 5, ki_mean = self.K_INTEGRATION_MEAN; end     
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.

            % Design the modulated split voltage based integration subnetwork neurons.
            self = self.design_mod_split_sub_vb_integration_neurons( neuron_IDs, ki_mean );

            % Design the modulated split voltage based integration applied currents.
            self = self.design_mod_split_sub_vb_integration_applied_currents( neuron_IDs );
            
            % Design the modulated split voltage based integration synapses.
            self = self.design_mod_split_sub_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
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
        
        
        % Implement a function to create the driven multistate CPG subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_driven_multistate_cpg_subnetwork_components( self, num_cpg_neurons )
            
            % Create the driven multistate cpg neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_driven_multistate_cpg_neurons( num_cpg_neurons );

            % Create the driven multistate cpg synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_driven_multistate_cpg_synapses( neuron_IDs );

            % Create the driven multistate cpg applied current.
            [ self.applied_current_manager, applied_current_ID ] = self.applied_current_manager.create_driven_multistate_cpg_applied_currents( neuron_IDs );    
            
        end
        
        
        % Implement a function to create the driven multistate CPG split lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.NUM_CPG_NEURONS; end
            
            % Create the driven multistate cpg neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_dmcpg_sll_neurons( num_cpg_neurons );

            % Create the driven multistate cpg synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_dmcpg_sll_synapses( neuron_IDs_cell );

            % Create the driven multistate cpg applied current.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_dmcpg_sll_applied_currents( neuron_IDs_cell );    
            
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
                
        
        % Implement a function to create the double subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_double_subtraction_subnetwork_components( self )
        
            % Create the double subtraction neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_double_subtraction_neurons(  );

            % Create the double subtraction synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_double_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the centering subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_centering_subnetwork_components( self )
           
            % Create the centering subnetwork neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_centering_neurons(  );
            
            % Create the centering subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_centering_synapses( neuron_IDs );
            
            % Create the centering subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_centering_applied_currents( neuron_IDs );
            
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
        
        
        % Implement a function to create the voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_vb_integration_subnetwork_components( self )
            
            % Create the voltage based integration neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_vb_integration_neurons(  );
            
            % Create the voltage based integration synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_vb_integration_synapses( neuron_IDs );
            
            % Create the voltage based integration applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_vb_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the split voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_split_vb_integration_subnetwork_components( self )
            
           % Create the split voltage based integration neurons.
           [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_split_vb_integration_neurons(  );
           
           % Create the split voltage based integration synapses.
           [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_split_vb_integration_synapses( neuron_IDs );

           % Create the split voltage based integration applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_split_vb_integration_applied_currents( neuron_IDs );

        end
        
        
        % Implement a function to create the modulated split voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_vb_integration_subnetwork_components( self )
            
           % Create the modulated split voltage based integration neurons.
           [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_mod_split_vb_integration_neurons(  );
           
           % Create the modulated split voltage based integration synapses.
           [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_mod_split_vb_integration_synapses( neuron_IDs );

           % Create the modulated split voltage based integration applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_mod_split_vb_integration_applied_currents( neuron_IDs );

        end
        
        
        % Implement a function to create the modulated split difference voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_sub_vb_integration_subnetwork_components( self )
            
           % Create the modulated split difference voltage based integration neurons.
           [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_mod_split_sub_vb_integration_neurons(  );
           
           % Create the modulated split difference voltage based integration synapses.
           [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_mod_split_sub_vb_integration_synapses( neuron_IDs );

           % Create the modulated split difference voltage based integration applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_mod_split_sub_vb_integration_applied_currents( neuron_IDs );

        end
        
        
        %% Subnetwork Creation Functions
        
        % Implement a function to create a multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multistate_cpg_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable )
        
            % Set the default input arguments.
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
            if nargin < 2, num_cpg_neurons = 2; end
                
            % Create the multistate cpg subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multistate_cpg_subnetwork_components( num_cpg_neurons );
            
            % Design the multistate cpg subnetwork.
            self = self.design_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
        
        % Implement a function to create a driven multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_driven_multistate_cpg_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max )
        
            % Set the default input arguments.
            if nargin < 5, I_drive_max = self.I_DRIVE_MAX; end
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
            if nargin < 2, num_cpg_neurons = 2; end
                
            % Create the driven multistate cpg subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_driven_multistate_cpg_subnetwork_components( num_cpg_neurons );
            
            % Design the driven multistate cpg subnetwork.
            self = self.design_driven_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max );
            
        end
    
        
        % Implement a function to create a driven multistate cpg split lead lag subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r )
        
            % Set the default input arguments.
            if nargin < 12, r = self.r_OSCILLATION; end
            if nargin < 11, c_mod = self.C_MODULATION; end
            if nargin < 10, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 9, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 8, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 7, ki_mean = self.K_INTEGRATION_MEAN; end
            if nargin < 6, T = self.T_OSCILLATION; end
            if nargin < 5, I_drive_max = self.I_DRIVE_MAX; end
            if nargin < 4, delta_bistable = self.DELTA_BISTABLE; end
            if nargin < 3, delta_oscillatory = self.DELTA_OSCILLATORY; end
            if nargin < 2, num_cpg_neurons = self.NUM_CPG_NEURONS; end
                
            % Create the driven multistate cpg subnetwork components.
            [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_dmcpg_sll_subnetwork_components( num_cpg_neurons );
            
            % Design the driven multistate cpg subnetwork.
            self = self.design_dmcpg_sll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r );
            
        end
    
        
        % Implement a function to create a transmission subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_transmission_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.K_TRANSMISSION; end
            
            % Create the transmission subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_transmission_subnetwork_components(  );
            
            % Design a transmission subnetwork.
            self = self.design_transmission_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a modulation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork( self, c )
            
            % Set the default input arugments.
%             if nargin < 2, c = 0.05; end
            if nargin < 2, c = self.C_MODULATION; end

            % Create the modulation subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_modulation_subnetwork_components(  );
            
            % Design a modulation subnetwork.
            self = self.design_modulation_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create an addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = self.K_ADDITION; end
            
            % Create addition subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_addition_subnetwork_components(  );
            
            % Design the addition subnetwork.
            self = self.design_addition_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = self.K_SUBTRACTION; end
            
            % Create the subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_subtraction_subnetwork_components(  );
            
            % Design the subtraction subnetwork.
            self = self.design_subtraction_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a double subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_double_subtraction_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.K_SUBTRACTION; end
            
            % Create the double subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_double_subtraction_subnetwork_components(  );
            
            % Design the double subtraction subnetwork.
            self = self.design_double_subtraction_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a centering subnetwork ( genearing neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_centering_subnetwork( self, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 3, k_sub = self.K_SUBTRACTION; end
            if nargin < 2, k_add = self.K_ADDITION; end
            
            % Create the centering subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_subtraction_subnetwork_components(  );
            
            % Design the centering subnetwork.
            self = self.design_centering_subnetwork( k_add, k_sub );
            
        end
        
        
        % Implement a function to create a multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork( self, k )
        
            % Set the default input arugments.
            if nargin < 2, k = self.K_MULTIPLICATION; end
            
            % Create the multiplication subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multiplication_subnetwork_components(  );
            
            % Design the multiplication subnetwork.
            self = self.design_multiplication_subnetwork( neuron_IDs, k );
        
        end
        
        
        % Implement a function to create a division subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork( self, k, c )
        
            % Set the default input arugments.
            if nargin < 3, c = [  ]; end
            if nargin < 2, k = self.K_DIVISION; end
            
            % Create division subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_division_subnetwork_components(  );
            
            % Design the division subnetwork.
            self = self.design_division_subnetwork( neuron_IDs, k, c );
        
        end
        
        
        % Implement a function to create a derivation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_derivation_subnetwork( self, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 4, safety_factor = self.SF_DERIVATION; end           
            if nargin < 3, w = self.W_DERIVATION; end
            if nargin < 2, k = self.K_DERIVATION; end 

            % Create the derivation subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_derivation_subnetwork_components(  );
            
            % Design the derivation subnetwork.
            self = self.design_derivation_subnetwork( neuron_IDs, k, w, safety_factor );

        end
        
        
        % Implement a function to create an integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_integration_subnetwork( self, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 3, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 2, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Create the integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_integration_subnetwork_components(  );
            
            % Design the integration subnetwork.
            self = self.design_integration_subnetwork( neuron_IDs, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_vb_integration_subnetwork( self, T, n, ki_mean, ki_range )
        
            % Set the default input arugments.
            if nargin < 5, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 4, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Create the voltage based integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_vb_integration_subnetwork_components(  );
            
            % Design the voltage based integration subnetwork.
            self = self.design_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_split_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub )
        
            % Set the default input arugments.
            if nargin < 6, k_sub = self.K_SUBTRACTION; end
            if nargin < 5, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 4, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Create the split voltage based integration subnetwork specific components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_split_vb_integration_subnetwork_components(  );
            
            % Design the split voltage based integration subnetwork.
            self = self.design_split_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_sub );

        end
        
        
        % Implement a function to create a modulated split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub, c_mod )
        
            % Set the default input arugments.
            if nargin < 7, c_mod = self.C_MODULATION; end
            if nargin < 6, k_sub = 2*self.K_SUBTRACTION; end
            if nargin < 5, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 4, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Create the modulated split voltage based integration subnetwork specific components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_mod_split_vb_integration_subnetwork_components(  );
            
            % Design the modulated split voltage based integration subnetwork.
            self = self.design_mod_split_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod );

        end
        
        
        % Implement a function to create a modulated split difference voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_sub_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod )
        
            % Set the default input arugments.
            if nargin < 8, c_mod = self.C_MODULATION; end
            if nargin < 7, k_sub2 = self.K_SUBTRACTION; end
            if nargin < 6, k_sub1 = 2*self.K_SUBTRACTION; end
            if nargin < 5, ki_range = self.K_INTEGRATION_RANGE; end
            if nargin < 4, ki_mean = self.K_INTEGRATION_MEAN; end
            
            % Create the modulated split difference voltage based integration subnetwork specific components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_mod_split_sub_vb_integration_subnetwork_components(  );
            
            % Design the modulated split difference voltage based integration subnetwork.
            self = self.design_mod_split_sub_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod );

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
            
            % Retrieve the applied voltages.
            V_apps_cell = self.applied_voltage_manager.neuron_IDs2Vapps( neuron_IDs, self.dt, self.tf, 'ignore' )';
            
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
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs ] = self.network_utilities.simulate( Us, hs, Gms, Cms, Rs, g_syn_maxs, dE_syns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, V_apps_cell, tf, dt, method );
            
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

