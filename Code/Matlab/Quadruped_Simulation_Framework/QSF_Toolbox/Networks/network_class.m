classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager                                                                                                          % [class] Manages Neuron Classes.
        synapse_manager                                                                                                         % [class] Manages Synapse Classes.
        applied_current_manager                                                                                                 % [class] Manages Applied Currents.
        applied_voltage_manager                                                                                                 % [class] Manages Applied Voltages.
        
        dt                                                                                                                      % [s] Network Simulation Timestep.
        tf                                                                                                                      % [s] Network Simulation Duration.
        
        network_utilities                                                                                                       % [class] Performs Fundamental Network Operations.
        numerical_method_utilities                                                                                              % [class] Performs Fundamental Numerical Method Operations.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the gain parameters.
        c_transmission_DEFAULT = 1;                                                                                             % [-] Transmission Subnetwork Gain
        c_modulation_DEFAULT = 0.05;                                                                                            % [-] Modulation Subnetwork Gain
        c_addition_DEFAULT = 1;                                                                                                 % [-] Addition Subnetwork Gain
        c_subtraction_DEFAULT = 1;                                                                                              % [-] Subtraction Subnetwork Gain
        c_inversion_DEFAULT = 1;                                                                                                % [-] Inversion Subnetwork Gain
        epsilon_inversion_DEFAULT = 1e-6;                                                                                       % [-] Inversion Subnetwork Offset
        c_multiplication_DEFAULT = 1;                                                                                           % [-] Multiplication Subnetwork Gain
        c_division_DEFAULT = 1;                                                                                                 % [-] Division Subnetwork Gain
        alpha_DEFAULT = 1e-6;                                                                                                   % [-] Division Subnetwork Denominator Adjustment
        c_derivation_DEFAULT = 1e6;                                                                                             % [-] Derivation Subnetwork Gain
        w_derivation_DEFAULT = 1;                                                                                               % [Hz?] Derivation Subnetwork Cutoff Frequency?
        sf_derivation_DEFAULT = 0.05;                                                                                           % [-] Derivation Subnetwork Safety Factor
        c_integration_mean_DEFAULT = 0.01e9;                                                                                    % [-] Integratin Subnetwork Gain Average
        c_integration_range_DEFAULT = 0.01e9;                                                                                   % [-] Integration Subnetwork Gain Range
        
        % Define applied current parameters.
        Iapp_DEFAULT = 0;                                                                                                       % [A] Applied Current
        Idrive_max_DEFAULT = 1.25e-9;                                                                                           % [A] Maximum Drive Current.
        
        % Define the cpg parameters.
        T_oscillation_DEFAULT = 2;                                                                                              % [s] Oscillation Period.
        r_oscillation_DEFAULT = 0.90;                                                                                           % [-] Oscillation Decay.
        delta_bistable_DEFAULT = -10e-3;
        delta_oscillatory_DEFAUT = 0.01e-3;
        
        % Define the subnetwork neuron quantities.
        num_cpg_neurons_DEFAULT = 2;                                                                                            % [#] Number of CPG Neurons.
        num_transmission_neurons_DEFAULT = 2;                                                                                   % [#] Number of Transmission Neurons.
        num_modulation_neurons_DEFAULT = 2;                                                                                     % [#] Number of Modulation Neurons.
        num_addition_neurons_DEFAULT = 3;                                                                                       % [#] Number of Addition Neurons.
        num_subtraction_neurons_DEFAULT = 3;                                                                                    % [#] Number of Subtraction Neurons.
        num_double_subtraction_neurons_DEFAULT = 4;                                                                             % [#] Number of Double Subtraction Neurons.
        num_centering_neurons_DEFAULT = 5;                                                                                      % [#] Number of Centering Neurons.
        num_double_centering_neurons_DEFAULT = 7;                                                                               % [#] Number of Double Centering Neurons.
        num_multiplication_neurons_DEFAULT = 4;                                                                                 % [#] Number of Multiplication Neurons.
        num_inversion_neurons_DEFAULT = 2;                                                                                      % [#] Number of Inversion Neurons.
        num_division_neurons_DEFAULT = 3;                                                                                       % [#] Number of Division Neurons.
        
        % Define the control parameters.
        kp_gain_DEFAULT = 1;                                                                                                    % [-] Proportional Controller Gain.
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( dt, tf, neuron_manager, synapse_manager, applied_current_manager, applied_voltage_manager )
            
            %{
            Input(s):
                dt                          =   [s] Simulation Timestep.
                tf                          =   [s] Simulation Duration.
                neuron_manager              =   [class] Neuron Manager Class.
                synapse_manager             =   [class] Synapse Manager Class.
                applied_current_manager     =   [class] Applied Current Manager Class.
                applied_voltage_manager     =   [class] Applied Voltage Manager Class.
                
            Output(s):
                self                        =   [class] Neural Network Class.
            %}
            
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
            
            %{
            Input(s):
                neuron_IDs	=   [#] Neuron IDs.
                
            Output(s):
                deltas      =   [V] Network Bifurcation Parameters.
            %}
            
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
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                dE_syns     =   [V] Synaptic Reversal Potentials.
            %}
            
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
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                g_syn_maxs	=   [S] Maximum Synaptic Conductances.
            %}
            
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
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                G_syns      =   [S] Synaptic Conductances.
            %}
            
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
            if nargin < 5, k = self.c_transmission_DEFAULT; end
            if nargin < 4, I_app2 = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, c = self.c_modulation_DEFAULT; end
            if nargin < 4, I_app2 = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a relative addition subnetwork with the specified parameters.
        function g_syn_maxs = compute_relative_addition_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
            [ g_syn_max13, g_syn_max23 ] = self.network_utilities.compute_relative_addition_gsynmax( Gm3, R1, R2, dE_syn13, dE_syn23, I_app3, k );
            
            % Store the maximum synaptic conductances.
            g_syn_maxs = [ g_syn_max13, g_syn_max23 ];
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a subtraction subnetwork with the specified parameters.
        function g_syn_maxs = compute_subtraction_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.c_subtraction_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
            if nargin < 6, k = self.c_multiplication_DEFAULT; end
            if nargin < 5, I_app4 = self.Iapp_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
        
        
        % Implement a function to compute the maximum synaptic conductances required to design an inversion subnetwork with the specified parameters.
        function g_syn_max = compute_inversion_gsynmax( self, neuron_IDs, I_app2, epsilon, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.c_inversion_DEFAULT; end
            if nargin < 4, epsilon = self.epsilon_inversion_DEFAULT; end
            if nargin < 3, I_app2 = self.Iapp_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron properties.
            Gm2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) )';
            R1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) )';
            
            % Compute the maximum synaptic conductances for this inversion subnetwork.
            g_syn_max = self.network_utilities.compute_inversion_gsynmax( Gm2, R1, I_app2, k, epsilon );
            
        end
        
        
        % Implement a function to compute the input offset for a relative inversion subnetwork.
        function epsilon = compute_relative_inversion_epsilon( self, c )
            
            % Define the default input arguments.
            if nargin < 2, c = self.c_inversion_DEFAULT; end                    % [-] Inversion Subnetwork Gain
            
            % Compute the input offset.
            epsilon = self.network_utilities.compute_relative_inversion_epsilon( c );
            
        end
        
        
        % Implement a function to compute the output offset for a relative inversion subnetwork.
        function delta = compute_relative_inversion_delta( self, c )
            
            % Define the default input arguments.
            if nargin < 2, c = self.c_inversion_DEFAULT; end                    % [-] Inversion Subnetwork Gain
            
            % Compute the output offset.
            delta = self.network_utilities.compute_relative_inversion_delta( c );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a division subnetwork with the specified parameters.
        function g_syn_maxs = compute_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app3, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = self.c_division_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, k = self.c_derivation_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
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
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            
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
            if nargin < 6, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 5, k = self.c_transmission_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, c = self.c_modulation_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a relative addition subnetwork.
        function self = compute_set_relative_addition_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_relative_addition_gsynmaxs( neuron_IDs, synapse_IDs, I_app, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a subtraction subnetwork.
        function self = compute_set_subtraction_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k )
            
            % Set the default input arguments.
            if nargin < 5, k = self.c_subtraction_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
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
            if nargin < 6, k = self.c_multiplication_DEFAULT; end
            if nargin < 5, I_app4 = self.Iapp_DEFAULT; end
            if nargin < 4, I_app3 = self.Iapp_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_IDs = self.synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Compute the maximum synaptic conductances.
            g_syn_maxs = self.compute_multiplication_gsynmaxs( neuron_IDs, synapse_IDs, I_app3, I_app4, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_IDs, g_syn_maxs, 'g_syn_max' );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for an inversion subnetwork.
        function self = compute_set_inversion_gsynmax( self, neuron_IDs, synapse_ID, I_app, epsilon, k )
            
            % Set the default input arguments.
            if nargin < 6, k = self.c_inversion_DEFAULT; end
            if nargin < 5, epsilon = self.epsilon_inversion_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Validate the synapse IDs.
            synapse_ID = self.synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Compute the maximum synaptic conductances.
            g_syn_max = self.compute_inversion_gsynmax( neuron_IDs, I_app, epsilon, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            self.synapse_manager = self.synapse_manager.set_synapse_property( synapse_ID, g_syn_max, 'g_syn_max' );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductances for a division subnetwork.
        function self = compute_set_division_gsynmaxs( self, neuron_IDs, synapse_IDs, I_app, k, c )
            
            % Set the default input arguments.
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = self.c_division_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
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
            if nargin < 5, k = self.c_derivation_DEFAULT; end
            if nargin < 4, I_app = self.Iapp_DEFAULT; end
            
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
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            
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
            if nargin < 6, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
        
        
        % Implement a function to design the applied currents for a driven multistate cpg double centered lead lag subnetwork.
        function self = design_dmcpg_dcll_applied_currents( self, neuron_IDs_cell )
            
            % Design the applied currents for the driven multistate cpg split lead lag subnetwork.
            self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell{ 1 } );
            
            % Design the applied currents for a double centering subnetwork.
            self = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 } );
            
        end
        
        
        % Implement a function to design the applied currents that connect the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
        function self = design_dmcpgdcll2cds_applied_current( self, neuron_ID )
            
            % Retrieve the necessary neuron properties.
            Gm = cell2mat( self.neuron_manager.get_neuron_property( neuron_ID, 'Gm' ) );
            R = cell2mat( self.neuron_manager.get_neuron_property( neuron_ID, 'R' ) );
            
            % Design the centering subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_dmcpgdcll2cds_applied_current( neuron_ID, Gm, R );
            
        end
        
        
        % Implement a function to design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function self = design_ol_dmcpg_dclle_applied_currents( self, neuron_IDs_cell )
            
            % Design the applied currents for the driven multistate cpg double centered lead lag subnetwork.
            self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell{ 1 } );
            
            % Design the applied currents for the centered double subtraction subnetwork.
            self = self.design_centered_double_subtraction_applied_currents( neuron_IDs_cell{ 2 } );
            
            % Design the desired lead lag applied current.
            self = self.design_dmcpgdcll2cds_applied_current( neuron_IDs_cell{ 3 } );
            
        end
        
        
        % Implement a function to design the applied currents for a closed loop proportional controlled driven multistate cpg double centered lead lag subnetwork.
        function self = design_clpc_dmcpg_dcll_applied_currents( self, neuron_IDs_cell )
            
            % Design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
            self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to design the applied currents for an absolute addition subnetwork.
        function self = design_absolute_addition_applied_currents( self, neuron_IDs )
            
            % Design the absolute addition applied currents.
            self.applied_current_manager = self.applied_current_manager.design_absolute_addition_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a relative addition subnetwork.
        function self = design_relative_addition_applied_currents( self, neuron_IDs )
            
            % Design the relative addition applied currents.
            self.applied_current_manager = self.applied_current_manager.design_relative_addition_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for an absolute subtraction subnetwork.
        function self = design_absolute_subtraction_applied_currents( self, neuron_IDs )
            
            % Design the absolute subtraction applied currents.
            self.applied_current_manager = self.applied_current_manager.design_absolute_subtraction_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a relative subtraction subnetwork.
        function self = design_relative_subtraction_applied_currents( self, neuron_IDs )
            
            % Design the relative subtraction applied currents.
            self.applied_current_manager = self.applied_current_manager.design_relative_subtraction_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a centering subnetwork.
        function self = design_centering_applied_currents( self, neuron_IDs )
            
            % Retrieve the necessary neuron properties.
            Gm2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
            
            % Design the centering subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_centering_applied_current( neuron_IDs, Gm2, R2 );
            
        end
        
        
        % Implement a function to design the applied currents for a double centering subnetwork.
        function self = design_double_centering_applied_currents( self, neuron_IDs )
            
            % Design the double centering applied currents (in the same way as the single centering applied currents).
            self = self.design_centering_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a centered double subtraction subnetwork.
        function self = design_centered_double_subtraction_applied_currents( self, neuron_IDs_cell )
            
            % Design the applied currents for a double centering subnetwork.
            self = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 } );
            
        end
        
        
        % Implement a function to design the applied current for an inversion subnetwork.
        function self = design_inversion_applied_current( self, neuron_IDs )
            
            % Retrieve the necessary neuron properties.
            Gm2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
            R2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
            
            % Design the inversion subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_inversion_applied_current( neuron_IDs, Gm2, R2 );
            
        end
        
        
        % Implement a function to design the applied current for an absolute inversion subnetwork.
        function self = design_absolute_inversion_applied_currents( self, neuron_IDs )
            
            % Retrieve the relevant design input arguments.
            R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );                                  % [V] Inversion Output Activation Domain.
            Gm_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );                                % [S] Inversion Output Membrane Conductance
            
            % Design the absolute inversion applied currents.
            self.applied_current_manager = self.applied_current_manager.design_absolute_inversion_applied_currents( neuron_IDs, Gm_2, R_2 );
            
        end
        
        
        % Implement a function to design the applied current for a relative inversion subnetwork.
        function self = design_relative_inversion_applied_currents( self, neuron_IDs )
            
            % Retrieve the relevant design input arguments.
            R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );                                  % [V] Inversion Output Activation Domain.
            Gm_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );                                % [S] Inversion Output Membrane Conductance
            
            % Design the relative inversion applied currents.
            self.applied_current_manager = self.applied_current_manager.design_relative_inversion_applied_currents( neuron_IDs, Gm_2, R_2 );
            
        end
        
        
        % Implement a function to design the applied current for an absolute division subnetwork.
        function self = design_absolute_division_applied_currents( self, neuron_IDs )
            
            % Design the absolute division applied currents.
            self.applied_current_manager = self.applied_current_manager.design_absolute_division_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied current for a relative division subnetwork.
        function self = design_relative_division_applied_currents( self, neuron_IDs )
            
            % Design the relative division applied currents.
            self.applied_current_manager = self.applied_current_manager.design_relative_division_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to design the applied currents for a multiplication subnetwork.
        function self = design_multiplication_applied_currents( self, neuron_IDs )
            
            % Retrieve the necessary neuron properties.
            Gm3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            R3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );
            
            % Design the multiplication subnetwork applied current.
            self.applied_current_manager = self.applied_current_manager.design_multiplication_applied_current( neuron_IDs, Gm3, R3 );
            
        end
        
        
        % Implement a function to design the applied currents for an absolute multiplication subnetwork.
        function self = design_absolute_multiplication_applied_currents( self, neuron_IDs )
            
            % Retrieve the relevant design input arguments.
            R_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );                                  % [V] Division Output Activation Domain.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );                                % [S] Division Output Membrane Conductance
            
            % Design the absolute multiplication applied currents.
            self.applied_current_manager = self.applied_current_manager.design_absolute_multiplication_applied_currents( neuron_IDs, Gm_3, R_3 );
            
        end
        
        
        % Implement a function to design the applied currents for a relative multiplication subnetwork.
        function self = design_relative_multiplication_applied_currents( self, neuron_IDs )
            
            % Retrieve the relevant design input arguments.
            R_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );                                  % [V] Division Output Activation Domain.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );                                % [S] Division Output Membrane Conductance
            
            % Design the relative multiplication applied currents.
            self.applied_current_manager = self.applied_current_manager.design_relative_multiplication_applied_currents( neuron_IDs, Gm_3, R_3 );
            
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
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 3, T = self.T_oscillation_DEFAULT; end
            
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
        
        
        % Implement a function to design the neurons for a driven multistate double centered lead lag subnetwork.
        function self = design_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r )
            
            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 3, T = self.T_oscillation_DEFAULT; end
            
            % Design the neurons for the driven multistate split lead lag subnetwork.
            self = self.design_dmcpg_sll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r );
            
            % Design the neurons for the double centering subnetwork.
            self = self.design_double_centering_neurons( neuron_IDs_cell{ 2 } );
            
        end
        
        
        % Implement a function to design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function self = design_ol_dmcpg_dclle_neurons( self, neuron_IDs_cell, T, ki_mean, r )
            
            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 3, T = self.T_oscillation_DEFAULT; end
            
            % Design the neurons for the driven multiple cpg double centered lead lag subnetwork.
            self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r );
            
            % Design the neurons for the centered double subtraction subnetwork.
            self = self.design_centered_double_subtraction_neurons( neuron_IDs_cell{ 2 } );
            
            % Design the neurons for the transmission subnetwork neurons.
            self = self.design_transmission_neurons( neuron_IDs_cell{ 3 } );
            
        end
        
        
        % Implement a function to design the neurons for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
        function self = design_clpc_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r )
            
            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 3, T = self.T_oscillation_DEFAULT; end
            
            % Design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
            self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r );
            
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
        
        
        % Implement a function to design the neurons for an absolute addition subnetwork.
        function self = design_absolute_addition_neurons( self, neuron_IDs )
            
            % Design the absolute addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_absolute_addition_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a relative addition subnetwork.
        function self = design_relative_addition_neurons( self, neuron_IDs )
            
            % Design the relative addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_relative_addition_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a subtraction subnetwork.
        function self = design_subtraction_neurons( self, neuron_IDs )
            
            % Design the subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_subtraction_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute subtraction subnetwork.
        function self = design_absolute_subtraction_neurons( self, neuron_IDs, s_ks )
            
            % Define the default input arguments.
            if nargin < 3, s_ks = [ 1, -1 ]; end                                                              % [-] Absolute Subtraction Subnetwork Excitatory / Inhibitory Signs
            
            % Design the absolute subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_absolute_subtraction_neurons( neuron_IDs, s_ks );
            
        end
        
        
        % Implement a function to design the neurons for a relative subtraction subnetwork.
        function self = design_relative_subtraction_neurons( self, neuron_IDs )
            
            % Design the relative subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_relative_subtraction_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a double subtraction subnetwork.
        function self = design_double_subtraction_neurons( self, neuron_IDs )
            
            % Design the double subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_double_subtraction_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a centering subnetwork.
        function self = design_centering_neurons( self, neuron_IDs )
            
            % Design the addition subnetwork neurons.
            self = self.design_addition_neurons( [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 4 ) ] );
            
            % Design the subtraction subnetwork neurons.
            self = self.design_subtraction_neurons( [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 5 ) ] );
            
        end
        
        
        % Implement a function to design the neurons for a double centering subnetwork.
        function self = design_double_centering_neurons( self, neuron_IDs )
            
            % Design the addition subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_addition_neurons( [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 4 ) ] );
            self.neuron_manager = self.neuron_manager.design_addition_neurons( [ neuron_IDs( 1 ) neuron_IDs( 3 ) neuron_IDs( 5 ) ] );
            
            % Design the subtraction subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_subtraction_neurons( [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 6 ) ] );
            self.neuron_manager = self.neuron_manager.design_subtraction_neurons( [ neuron_IDs( 5 ) neuron_IDs( 1 ) neuron_IDs( 7 ) ] );
            
        end
        
        
        % Implement a function to design the neurons for a centered double subtraction subnetwork.
        function self = design_centered_double_subtraction_neurons( self, neuron_IDs_cell )
            
            % Design the double subtraction subnetwork neurons.
            self = self.design_double_subtraction_neurons( neuron_IDs_cell{ 1 } );
            
            % Design the double centering subnetwork neurons.
            self = self.design_double_centering_neurons( neuron_IDs_cell{ 2 } );
            
        end
        
        
        % Implement a function to design the neurons for a multiplication subnetwork.
        function self = design_multiplication_neurons( self, neuron_IDs )
            
            % Design the multiplication subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_multiplication_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute multiplication subnetwork.
        function self = design_absolute_multiplication_neurons( self, neuron_IDs, c, c1, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                                 % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                                 % [-] Inversion Subnetwork Offset
            if nargin < 4, c1 = self.c_inversion_DEFAULT; end                                           % [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_multiplication_DEFAULT; end                                       % [-] Multiplication Subnetwork Gain
            
            % Design the absolute multiplication neurons.
            self.neuron_manager = self.neuron_manager.design_absolute_multiplication_neurons( neuron_IDs, c, c1, epsilon1, epsilon2 );
            
        end
        
        
        % Implement a function to design the neurons for a relative multiplication subnetwork.
        function self = design_relative_multiplication_neurons( self, neuron_IDs, c, c1, c2, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                 % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                 % [-] Inversion Subnetwork Offset
            if nargin < 5, c2 = self.c_division_DEFAULT; end                                            % [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_inversion_DEFAULT; end                                           % [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_multiplication_DEFAULT; end                                       % [-] Multiplication Subnetwork Gain
            
            % Design the absolute multiplication neurons.
            self.neuron_manager = self.neuron_manager.design_relative_multiplication_neurons( neuron_IDs, c, c1, c2, epsilon1, epsilon2 );
            
        end
        
        
        % Implement a function to design the neurons for an inversion subnetwork.
        function self = design_inversion_neurons( self, neuron_IDs, epsilon, k )
            
            % Set the default input arguments.
            if nargin < 4, k = self.c_inversion_DEFAULT; end
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end
            
            % Design the inversion subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_inversion_neurons( neuron_IDs, epsilon, k );
            
        end
        
        
        % Implement a function to design the neurons for an absolute inversion subnetwork.
        function self = design_absolute_inversion_neurons( self, neuron_IDs, c, epsilon, delta )
            
            % Define the default input arguments.
            if nargin < 5, delta = self.delta_DEFAULT; end                                      % [-] Inversion Subnetwork Output Offset
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                  % [-] Inversion Subnetwork Input Offset
            if nargin < 3, c = self.c_inversion_DEFAULT; end                                              % [-] Inversion Subnetwork Gain
            
            % Design the absolute inversion neurons.
            self.neuron_manager = self.neuron_manager.design_absolute_inversion_neurons( neuron_IDs, c, epsilon, delta );
            
        end
        
        
        % Implement a function to design the neurons for a relative inversion subnetwork.
        function self = design_relative_inversion_neurons( self, neuron_IDs )
            
            % Design the relative inversion neurons.
            self.neuron_manager = self.neuron_manager.design_relative_inversion_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a division subnetwork.
        function self = design_division_neurons( self, neuron_IDs )
            
            % Design the division subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_division_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute division subnetwork.
        function self = design_absolute_division_neurons( self, neuron_IDs, c, alpha, epsilon )
            
            % Define the default input arguments.
            if nargin < 5, epsilon = self.espilon_DEFAULT; end                                      % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                                          % [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.c_division_DEFAULT; end                                        	% [-] Division Subnetwork Gain
            
            % Design the absolute division neurons.
            self.neuron_manager = self.neuron_manager.design_absolute_division_neurons( neuron_IDs, c, alpha, epsilon );
            
        end
        
        
        % Implement a function to design the neurons for a relative division subnetwork.
        function self = design_relative_division_neurons( self, neuron_IDs )
            
            % Design the relative division neurons.
            self.neuron_manager = self.neuron_manager.design_relative_division_neurons( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a derivation subnetwork.
        function self = design_derivation_neurons( self, neuron_IDs, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            
            % Design the derivation subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_derivation_neurons( neuron_IDs, k, w, safety_factor );
            
        end
        
        
        % Implement a function to design the neurons for an integration subnetwork.
        function self = design_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_integration_neurons( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function self = design_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_vb_integration_neurons( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a split voltage based integration subnetwork.
        function self = design_split_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.
            self.neuron_manager = self.neuron_manager.design_split_vb_integration_neurons( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a modulated split voltage based integration subnetwork.
        function self = design_mod_split_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the split voltage based integration neurons.
            self = self.design_split_vb_integration_neurons( neuron_IDs( 1:9 ), ki_mean );
            
            % Design the modulation neurons.
            self = self.design_modulation_neurons( neuron_IDs( 10:12 ) );
            
        end
        
        
        % Implement a function to design the neurons for a modulated split difference voltage based integration subnetwork.
        function self = design_mod_split_sub_vb_integration_neurons( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 11, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
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
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg double centered lead lag subnetwork.
        function self = design_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod )
            
            % Set the default input arguments.
            if nargin < 13, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 12, k_sub3 = self.c_addition_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % Design the driven multistate cpg split lead lag synapses.
            self = self.design_dmcpg_sll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
            % Design the double centering subnetwork synapses.
            self = self.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_add, k_sub3 );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ end }( end - 1 ) neuron_IDs_cell{ 1 }{ end }( end ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 0.5, false );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function self = design_ol_dmcpg_dclle_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod )
            
            % Set the default input arguments.
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % Design the driven multistate cpg double centered lead lag subnetwork synapses.
            self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add1, c_mod );
            
            % Design the centered double subtraction subnetwork synapses.
            self = self.design_centered_double_subtraction_synapses( neuron_IDs_cell{ 2 }, k_sub4, k_sub5, k_add2 );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 2 }( end - 1 ) neuron_IDs_cell{ 3 } ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 1 }( 1 ) neuron_IDs_cell{ 2 }{ 1 }( 2 ) ];
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false );
                
            end
            
            
        end
        
        
        % Implement a function to design the synapses for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
        function self = design_clpc_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain )
            
            % Set the default input arguments.
            if nargin < 17, kp_gain = self.kp_gain_DEFAULT; end
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % Design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
            self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 2 }( end - 1 ) neuron_IDs_cell{ 2 }{ 2 }( end ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 1 }{ 2 }( end ) neuron_IDs_cell{ 1 }{ 1 }{ 1 }( end ) ];
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], kp_gain, false );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function self = design_transmission_synapse( self, neuron_IDs, k, b_applied_current_compensation )
            
            % Set the default input arugments.
            if nargin < 4, b_applied_current_compensation = true; end
            if nargin < 3, k = self.c_transmission_DEFAULT; end
            
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
            if nargin < 3, c = self.c_modulation_DEFAULT; end
            
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
            if nargin < 3, k = self.c_addition_DEFAULT; end
            
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
        
        
        % Implement a function to design the synapses for an absolute addition subnetwork.
        function self = design_absolute_addition_synapses( self, neuron_IDs, c )
            
            % Define the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                             % [-] Addition Subnetwork Gain
            
            % Retrieve the magnitude of the current applied to the output neuron.
            Iapp_n = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( end ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_n == Iapp_n( 1 ) )                                % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The absolute addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_n = mean( Iapp_n );
                
            end
            
            % Retrieve the membrane conductance of the output neuron.
            Gm_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) );
            
            % Retrieve the activation domains of the input neurons.
            R_ks = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1:( end - 1 ) ), 'R' ) );
            
            % Design the absolute addition synapses.
            self.synapse_manager = self.synapse_manager.design_absolute_addition_synapses( neuron_IDs, c, R_ks, Gm_n, Iapp_n );
            
        end
        
        
        % Implement a function to design the synapses for a relative addition subnetwork.
        function self = design_relative_addition_synapses( self, neuron_IDs, c )
            
            % Define the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                             % [-] Addition Subnetwork Gain
            
            % Compute the number of addition neurons.
            n = length( neuron_IDs );
            
            % Retrieve the magnitude of the current applied to the output neuron.
            Iapp_n = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( end ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_n == Iapp_n( 1 ) )                                % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The relative addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_n = mean( Iapp_n );
                
            end
            
            % Retrieve the membrane conductance of the output neuron.
            Gm_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) );
            
            % Retrieve the activation domains of the output neuron.
            R_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'R' ) );
            
            % Design the absolute addition synapses.
            self.synapse_manager = self.synapse_manager.design_relative_addition_synapses( neuron_IDs, c, n, R_n, Gm_n, Iapp_n );
            
        end
        
        
        % Implement a function to design the synapses for a subtraction subnetwork.
        function self = design_subtraction_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
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
        
        
        % Implement a function to design the synapses for an absolute subtraction subnetwork.
        function self = design_absolute_subtraction_synapses( self, neuron_IDs, c, s_ks )
            
            % Define the default input arguments.
            if nargin < 4, s_ks = [ 1, -1 ]; end                                    % [-] Subtraction Subnetwork Input Excitatory / Inhibitory Sign
            if nargin < 3, c = self.c_subtraction_DEFAULT; end                              % [-] Subtraction Subnetwork Gain
            
            % Retrieve the magnitude of the current applied to the output neuron.
            Iapp_n = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( end ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_n == Iapp_n( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The absolute subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_n = mean( Iapp_n );
                
            end
            
            % Retrieve the membrane conductance of the output neuron.
            Gm_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) );
            
            % Retrieve the activation domains of the input neurons.
            R_ks = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1:( end - 1 ) ), 'R' ) );
            
            % Design the absolute subtraction synapses.
            self.synapse_manager = self.synapse_manager.design_absolute_subtraction_synapses( neuron_IDs, c, s_ks, R_ks, Gm_n, Iapp_n );
            
        end
        
        
        % Implement a function to design the synapses for a relative subtraction subnetwork.
        function self = design_relative_subtraction_synapses( self, neuron_IDs, c, npm_k, s_ks )
            
            % Define the default input arguments.
            if nargin < 5, s_ks = [ 1, -1 ]; end                                    % [-] Subtraction Subnetwork Input Excitatory / Inhibitory Sign
            if nargin < 4, npm_k = [ 1, 1 ]; end                                    % [#] Subtraction Subnetwork Number of Excitatory / Inhibitory Inputs
            if nargin < 3, c = self.c_subtraction_DEFAULT; end                              % [-] Subtraction Subnetwork Gain
            
            % Retrieve the magnitude of the current applied to the output neuron.
            Iapp_n = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( end ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_n == Iapp_n( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The relative subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_n = mean( Iapp_n );
                
            end
            
            % Retrieve the membrane conductance of the output neuron.
            Gm_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm' ) );
            
            % Retrieve the activation domains of the input neurons.
            R_n = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( end ), 'R' ) );
            
            % Design the absolute subtraction synapses.
            self.synapse_manager = self.synapse_manager.design_relative_subtraction_synapses( neuron_IDs, c, npm_k, s_ks, R_n, Gm_n, Iapp_n );
            
        end
        
        
        % Implement a function to design the synapses for a double subtraction subnetwork.
        function self = design_double_subtraction_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
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
        
        
        % Implement a function to design the synapses for a centering subnetwork.
        function self = design_centering_synapses( self, neuron_IDs, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the addition subnetwork synapses.
            self = self.design_addition_synapses( [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 4 ) ], k_add );
            
            % Design the subtraction subnetwork synapses.
            self = self.design_subtraction_synapses( [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 5 ) ], k_sub );
            
        end
        
        
        % Implement a function to design the synapses for a double centering subnetwork.
        function self = design_double_centering_synapses( self, neuron_IDs, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the addition subnetwork neurons.
            self = self.design_addition_synapses( [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 4 ) ], k_add );
            self = self.design_addition_synapses( [ neuron_IDs( 2 ) neuron_IDs( 3 ) neuron_IDs( 5 ) ], k_add );
            
            % Design the subtraction subnetwork neurons.
            self = self.design_subtraction_synapses( [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 6 ) ], k_sub );
            self = self.design_subtraction_synapses( [ neuron_IDs( 5 ) neuron_IDs( 1 ) neuron_IDs( 7 ) ], k_sub );
            
        end
        
        
        % Implement a function to design the synapses for a centered double subtraction subnetwork.
        function self = design_centered_double_subtraction_synapses( self, neuron_IDs_cell, k_sub1, k_sub2, k_add )
            
            % Set the default input arguments.
            if nargin < 5, k_add = self.c_addition_DEFAULT; end
            if nargin < 4, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_sub1 = self.c_subtraction_DEFAULT; end
            
            % Design the double subtraction subnetwork synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs_cell{ 1 }, k_sub1 );
            
            % Design the double centering subnetwork synpases.
            self = self.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_add, k_sub2 );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }( 3 ) neuron_IDs_cell{ 1 }( 4 ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.
                self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 0.5, false );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a multiplication subnetwork.
        function self = design_multiplication_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_multiplication_DEFAULT; end
            
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
        
        
        % Implement a function to design the synapses for an absolute multiplication subnetwork.
        function self = design_absolute_multiplication_synapses( self, neuron_IDs, c1, c2, alpha, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                         % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                         % [-] Inversion Subnetwork Offset
            if nargin < 5, alpha = self.alpha_DEFAULT; end                              % [-] Division Subnetwork Denominator Adjustment
            if nargin < 4, c2 = self.c_division_DEFAULT; end                           	% [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_inversion_DEFAULT; end                          	% [-] Inverison Subentwork Gain
            
            % Retrieve the magnitude of the current applied to the inversion output neuron.
            Iapp_3 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_3 == Iapp_3( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The absolute multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_3 = mean( Iapp_3 );
                
            end
            
            % Retrieve the relevant membrane conductances.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            Gm_4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm' ) );
            
            % Retrieve the relevant activation domains.
            R_1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) );
            R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
            R_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );
            
            % Design the absolute multiplication synapses.
            self.synapse_manager = self.synapse_manager.design_absolute_multiplication_synapses( neuron_IDs, c1, c2, alpha, epsilon1, epsilon2, R_1, R_2, R_3, Gm_3, Gm_4, Iapp_3 );
            
        end
        
        
        % Implement a function to design the synapses for a relative multiplication subnetwork.
        function self = design_relative_multiplication_synapses( self, neuron_IDs, c1, c2, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_DEFAULT; end                         % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_DEFAULT; end                         % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_division_DEFAULT; end                                    % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_inversion_DEFAULT; end                                   % [-] Inverison Subentwork Gain
            
            % Retrieve the magnitude of the current applied to the inversion output neuron.
            Iapp_3 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 3 ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_3 == Iapp_3( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The relative multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_3 = mean( Iapp_3 );
                
            end
            
            % Retrieve the relevant membrane conductances.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            Gm_4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm' ) );
            
            % Retrieve the relevant activation domains.
            R_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );
            R_4 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R' ) );
            
            % Design the relative multiplication synapses.
            self.synapse_manager = self.synapse_manager.design_relative_multiplication_synapses( neuron_IDs, c1, c2, epsilon1, epsilon2, R_3, R_4, Gm_3, Gm_4, Iapp_3 );
            
        end
        
        
        % Implement a function to design the synapse of an inversion subnetwork.
        function self = design_inversion_synapse( self, neuron_IDs, epsilon, k )
            
            % Set the default input arugments.
            if nargin < 4, k = self.c_inversion_DEFAULT; end
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end
            
            % Design the inversion subnetwork synapse.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.design_inversion_synapse( neuron_IDs );
            
            % Get the applied current associated with the final neuron.
            I_apps = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
            
            % Determine whether to throw a warning.
            if ~all( I_apps == I_apps( 1 ) ), warning( 'The basic division subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            I_app = mean( I_apps );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            self = self.compute_set_inversion_gsynmax( neuron_IDs, synapse_ID, I_app, epsilon, k );
            
        end
        
        
        %         % Implement a function to design the synapses for an absolute inversion subnetwork.
        %         function self = design_absolute_inversion_synapses( self, neuron_IDs, c, epsilon )
        %
        %             % Define the default input arguments.
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                         % [-] Inverison Subnetwork Offset
        %             if nargin < 3, c = self.c_inversion_DEFAULT; end                                   % [-] Inverison Subentwork Gain
        %
        %             % Retrieve the magnitude of the current applied to the inversion output neuron.
        %             Iapp_2 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
        %
        %             % Determine whether to use the average applied current.
        %             if ~all( Iapp_2 == Iapp_2( 1 ) )                                        % If the applied current is not constant...
        %
        %                 % Throw a warning.
        %                 warning( 'The absolute inversion subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
        %
        %                 % Set the applied current to be the average current.
        %                 Iapp_2 = mean( Iapp_2 );
        %
        %             end
        %
        %             % Retrieve the relevant membrane conductances.
        %             Gm_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
        %
        %             % Retrieve the relevant activation domains.
        %             R_1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) );
        %
        %             % Design the absolute inversion synapses.
        %             self.synapse_manager = self.synapse_manager.design_absolute_inversion_synapse( neuron_IDs, c, epsilon, R_1, Gm_2, Iapp_2 );
        %
        %
        %         end
        
        
        % Implement a function to design the synapses for an absolute inversion subnetwork.
        function self = design_absolute_inversion_synapses( self, neuron_IDs, c, delta )
            
            % Define the default input arguments.
            if nargin < 4, delta = self.delta_DEFAULT; end                              % [V] Inverison Subnetwork Output Offset
            if nargin < 3, c = self.c_inversion_DEFAULT; end                            % [-] Inverison Subnetwork Gain
            
            % Retrieve the magnitude of the current applied to the inversion output neuron.
            Iapp_2 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_2 == Iapp_2( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The absolute inversion subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_2 = mean( Iapp_2 );
                
            end
            
            % Design the absolute inversion synapses.
            self.synapse_manager = self.synapse_manager.design_absolute_inversion_synapse( neuron_IDs, c, delta, Iapp_2 );
            
        end
        
        
        %         % Implement a function to design the synapses for a relative inversion subnetwork.
        %         function self = design_relative_inversion_synapses( self, neuron_IDs, c, epsilon )
        %
        %             % Define the default input arguments.
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                         % [-] Inverison Subnetwork Offset
        %             if nargin < 3, c = self.c_inversion_DEFAULT; end                                   % [-] Inverison Subentwork Gain
        %
        %             % Retrieve the magnitude of the current applied to the inversion output neuron.
        %             Iapp_2 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
        %
        %             % Determine whether to use the average applied current.
        %             if ~all( Iapp_2 == Iapp_2( 1 ) )                                        % If the applied current is not constant...
        %
        %                 % Throw a warning.
        %                 warning( 'The relative inversion subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
        %
        %                 % Set the applied current to be the average current.
        %                 Iapp_2 = mean( Iapp_2 );
        %
        %             end
        %
        %             % Retrieve the relevant membrane conductances.
        %             Gm_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );
        %
        %             % Retrieve the relevant activation domains.
        %             R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
        %
        %             % Design the relative inversion synapses.
        %             self.synapse_manager = self.synapse_manager.design_relative_inversion_synapse( neuron_IDs, c, epsilon, R_2, Gm_2, Iapp_2 );
        %
        %         end
        
        
        % Implement a function to design the synapses for a relative inversion subnetwork.
        function self = design_relative_inversion_synapses( self, neuron_IDs, epsilon, delta )
            
            % Define the default input arguments.
            if nargin < 4, delta = self.delta_DEFAULT; end                              % [V] Inverison Subnetwork Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                          % [V] Inverison Subnetwork Input Offset
            
            % Retrieve the magnitude of the current applied to the inversion output neuron.
            Iapp_2 = self.applied_current_manager.neuron_IDs2Iapps( neuron_IDs( 2 ), [  ], [  ], 'ignore' );
            
            % Determine whether to use the average applied current.
            if ~all( Iapp_2 == Iapp_2( 1 ) )                                        % If the applied current is not constant...
                
                % Throw a warning.
                warning( 'The relative inversion subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' )
                
                % Set the applied current to be the average current.
                Iapp_2 = mean( Iapp_2 );
                
            end
            
            % Retrieve the relevant activation domains.
            R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
            
            % Design the relative inversion synapses.
            self.synapse_manager = self.synapse_manager.design_relative_inversion_synapse( neuron_IDs, epsilon, delta, R_2, Iapp_2 );
            
        end
        
        
        % Implement a function to design the synapses of a division subnetwork.
        function self = design_division_synapses( self, neuron_IDs, k, c )
            
            % Set the default input arguments.
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = self.c_division_DEFAULT; end
            
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
        
        
        % Implement a function to design the synapses for an absolute division subnetwork.
        function self = design_absolute_division_synapses( self, neuron_IDs, c, alpha, epsilon )
            
            % Define the default input arguments.
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                          % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                              % [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.c_division_DEFAULT; end                            	% [-] Division Subentwork Gain
            
            % Retrieve the relevant membrane conductances.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            
            % Retrieve the relevant activation domains.
            R_1 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R' ) );
            R_2 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R' ) );
            
            % Design the absolute division synapses.
            self.synapse_manager = self.synapse_manager.design_absolute_division_synapses( neuron_IDs, c, alpha, epsilon, R_1, R_2, Gm_3 );
            
        end
        
        
        % Implement a function to design the synapses for a relative division subnetwork.
        function self = design_relative_division_synapses( self, neuron_IDs, c, alpha, epsilon )
            
            % Define the default input arguments.
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                          % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end
            if nargin < 3, c = self.c_division_DEFAULT; end                                     % [-] Division Subentwork Gain
            
            % Retrieve the relevant membrane conductances.
            Gm_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm' ) );
            
            % Retrieve the relevant activation domains.
            R_3 = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R' ) );
            
            % Design the relative division synapses.
            self.synapse_manager = self.synapse_manager.design_relative_division_synapses( neuron_IDs, c, alpha, epsilon, R_3, Gm_3 );
            
        end
        
        
        % Implement a function to design the synapses for a derivation subnetwork.
        function self = design_derivation_synapses( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            
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
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            
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
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 7, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 9, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 8, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 7, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
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
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
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
            if nargin < 12, r = self.r_oscillation_DEFAULT; end
            if nargin < 11, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate CPG split lead lag subnetwork neurons.
            self = self.design_dmcpg_sll_neurons( neuron_IDs_cell, T, ki_mean, r );
            
            % Design the driven multistate CPG split lead lag subnetwork applied currents.
            self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell );
            
            % Design the driven multistate CPG split lead lag subnetwork synapses.
            self = self.design_dmcpg_sll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
        end
        
        
        % Implement a function to design a driven multistate CPG double centered lead lag subnetwork using existing neurons.
        function self = design_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r )
            
            % Set the default input arguments.
            if nargin < 14, r = self.r_oscillation_DEFAULT; end
            if nargin < 13, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 12, k_add = self.c_addition_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate CPG double centered lead lag subnetwork neurons.
            self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r );
            
            % Design the driven multistate CPG double centered lead lag subnetwork applied currents.
            self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
            % Design the driven multistate CPG double centered lead lag subnetwork synapses.
            self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod );
            
        end
        
        
        % Implement a function to design an open loop driven multistate CPG double centered lead lag error subnetwork using existing neurons.
        function self = design_ol_dmcpg_dclle_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r )
            
            % Set the default input arguments.
            if nargin < 17, r = self.r_oscillation_DEFAULT; end
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
            self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r );
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
            self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
            
        end
        
        
        % Implement a function to design a closed loop P controlled driven multistate CPG double centered lead lag subnetwork using existing neurons.
        function self = design_clpc_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain )
            
            % Set the default input arguments.
            if nargin < 18, kp_gain = self.kp_gain_DEFAULT; end
            if nargin < 17, r = self.r_oscillation_DEFAULT; end
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork neurons.
            self = self.design_clpc_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r );
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork applied currents.
            self = self.design_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork synapses.
            self = self.design_clpc_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain );
            
        end
        
        
        % Implement a function to design a transmission subnetwork using existing neurons.
        function self = design_transmission_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arugments.
            if nargin < 3, k = self.c_transmission_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the transmission subnetwork neurons.
            self = self.design_transmission_neurons( neuron_IDs );
            
            % Design the tranmission subnetwork synapses.
            self = self.design_transmission_synapse( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design a modulation subnetwork using existing neurons.
        function self = design_modulation_subnetwork( self, neuron_IDs, c )
            
            % Set the default input arugments.
            if nargin < 3, c = self.c_modulation_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulation neurons.
            self = self.design_modulation_neurons( neuron_IDs );
            
            % Design the modulation synapses.
            self = self.design_modulation_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design an addition subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_addition_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_addition_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the addition subnetwork neurons.
            self = self.design_addition_neurons( neuron_IDs );
            
            % Design the addition subnetwork synapses.
            self = self.design_addition_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an absolute addition subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_absolute_addition_subnetwork( self, neuron_IDs, c )
            
            % Define the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                     % [-] Absolute Addition Subnetwork Gain
            
            % Design the absolute addition neurons.
            self = self.design_absolute_addition_neurons( neuron_IDs );
            
            % Design the absolute addition applied currents.
            self = self.design_absolute_addition_applied_currents( neuron_IDs );
            
            % Design the absolute addition synapses.
            self = self.design_absolute_addition_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design a relative addition subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_relative_addition_subnetwork( self, neuron_IDs, c )
            
            % Define the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                     % [-] Relative Addition Subnetwork Gain
            
            % Design the relative addition neurons.
            self = self.design_relative_addition_neurons( neuron_IDs );
            
            % Design the relative addition applied currents.
            self = self.design_relative_addition_applied_currents( neuron_IDs );
            
            % Design the relative addition synapses.
            self = self.design_relative_addition_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design a subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_subtraction_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the subtraction subnetwork neurons.
            self = self.design_subtraction_neurons( neuron_IDs );
            
            % Design the subtraction subnetwork synapses.
            self = self.design_subtraction_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an absolute subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_absolute_subtraction_subnetwork( self, neuron_IDs, c, s_ks )
            
            % Define the default input arguments.
            if nargin < 4, s_ks = [ 1, -1 ]; end                        % [-] Excitatory / Inhibitory Signs
            if nargin < 3, c = self.c_subtraction_DEFAULT; end                     % [-] Absolute Subtraction Subnetwork Gain
            
            % Design the absolute subtraction neurons.
            self = self.design_absolute_subtraction_neurons( neuron_IDs, s_ks );
            
            % Design the absolute subtraction applied currents.
            self = self.design_absolute_subtraction_applied_currents( neuron_IDs );
            
            % Design the absolute subtraction synapses.
            self = self.design_absolute_subtraction_synapses( neuron_IDs, c, s_ks );
            
        end
        
        
        % Implement a function to design a relative subtraciton subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_relative_subtraction_subnetwork( self, neuron_IDs, c, npm_k, s_ks )
            
            % Define the default input arguments.
            if nargin < 5, s_ks = [ 1, -1 ]; end                            % [-] Excitatory / Inhibitory Signs
            if nargin < 4, npm_k = [ 1, 1 ]; end                            % [#] Number of Excitatory / Inhibitory Inputs
            if nargin < 3, c = self.c_subtraction_DEFAULT; end                      % [-] Absolute Subtraction Subnetwork Gain
            
            % Design the relative subtraction neurons.
            self = self.design_relative_subtraction_neurons( neuron_IDs );
            
            % Design the relative subtraction applied currents.
            self = self.design_relative_subtraction_applied_currents( neuron_IDs );
            
            % Design the relative subtraction synapses.
            self = self.design_relative_subtraction_synapses( neuron_IDs, c, npm_k, s_ks );
            
        end
        
        
        % Implement a function to design a double subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_double_subtraction_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the double subtraction subnetwork neurons.
            self = self.design_double_subtraction_neurons( neuron_IDs );
            
            % Design the double subtraction subnetwork synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design a centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_centering_subnetwork( self, neuron_IDs, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the centering subnetwork neurons.
            self = self.design_centering_neurons( neuron_IDs );
            
            % Design the centering subnetwork applied currents.
            self = self.design_centering_applied_currents( neuron_IDs );
            
            % Design the centering subnetwork synapses.
            self = self.design_centering_synapses( neuron_IDs, k_add, k_sub );
            
        end
        
        
        % Implement a function to design a double centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_double_centering_subnetwork( self, neuron_IDs, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the double centering subnetwork neurons.
            self = self.design_double_centering_neurons( neuron_IDs );
            
            % Design the double centering subnetwork applied currents.
            self = self.design_double_centering_applied_currents( neuron_IDs );
            
            % Design the double centering subnetwork synapses.
            self = self.design_double_centering_synapses( neuron_IDs, k_add, k_sub );
            
        end
        
        
        % Implement a function to design a centered double subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_centered_double_subtraction_subnetwork( self, neuron_IDs_cell, k_sub1, k_sub2, k_add )
            
            % Set the default input arguments.
            if nargin < 5, k_add = self.c_addition_DEFAULT; end
            if nargin < 4, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_sub1 = self.c_subtraction_DEFAULT; end
            
            % Design the centered double subtraction neurons.
            self = self.design_centered_double_subtraction_neurons( neuron_IDs_cell );
            
            % Design the centered double subtraction applied currents.
            self = self.design_centered_double_subtraction_applied_currents( neuron_IDs_cell );
            
            % Design the centered double subtraction synapses.
            self = self.design_centered_double_subtraction_synapses( neuron_IDs_cell, k_sub1, k_sub2, k_add );
            
        end
        
        
        % Implement a function to design a multiplication subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_multiplication_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_multiplication_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the multiplication subnetwork neurons.
            self = self.design_multiplication_neurons( neuron_IDs );
            
            % Design the multiplication subnetwork applied currents.
            self = self.design_multiplication_applied_currents( neuron_IDs );
            
            % Design the multiplication subnetwork synapses.
            self = self.design_multiplication_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an absolute multiplication subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_absolute_multiplication_subnetwork( self, neuron_IDs, c, c1, c2, alpha, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 8, epsilon2 = self.epsilon_DEFAULT; end                                                 % [-] Division Subnetwork Offset
            if nargin < 7, epsilon1 = self.epsilon_DEFAULT; end                                                 % [-] Inversion Subnetwork Offset
            if nargin < 6, alpha = self.alpha_DEFAULT; end                                                      % [-] Division Subnetwork Denominator Adjustment
            if nargin < 5, c2 = self.c_division_DEFAULT; end                                                   	% [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_inversion_DEFAULT; end                                                  	% [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_multiplication_DEFAULT; end                                              	% [-] Multiplication Subnetwork Gain
            
            % Design the absolute multiplication neurons.
            self = self.design_absolute_multiplication_neurons( neuron_IDs, c, c1, epsilon1, epsilon2 );
            
            % Design the absolute multiplication applied currents.
            self = self.design_absolute_multiplication_applied_currents( neuron_IDs );
            
            % Design the absolute multiplication synapses.
            self = self.design_absolute_multiplication_synapses( neuron_IDs, c1, c2, alpha, epsilon1, epsilon2 );
            
        end
        
        
        % Implement a function to design a relative multiplication subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_relative_multiplication_subnetwork( self, neuron_IDs, c, c1, c2, epsilon1, epsilon2 )
            
            % Define the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                                 % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                                 % [-] Inversion Subnetwork Offset
            if nargin < 5, c2 = self.c_division_DEFAULT; end                                                            % [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_inversion_DEFAULT; end                                                           % [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_multiplication_DEFAULT; end                                                       % [-] Multiplication Subnetwork Gain
            
            % Design the relative multiplication neurons.
            self = self.design_relative_multiplication_neurons( neuron_IDs, c, c1, c2, epsilon1, epsilon );
            
            % Design the relative multiplication applied currents.
            self = self.design_relative_multiplication_applied_currents( neuron_IDs );
            
            % Design the relative multiplication synapses.
            self = self.design_relative_multiplication_synapses( neuron_IDs, c1, c2, epsilon1, epsilon2 );
            
        end
        
        
        % Implement a function to design an inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_inversion_subnetwork( self, neuron_IDs, epsilon, k )
            
            % Set the default input arguments.
            if nargin < 4, k = self.c_inversion_DEFAULT; end
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the inversion subnetwork neurons.
            self = self.design_inversion_neurons( neuron_IDs, epsilon, k );
            
            % Design the inversion subnetwork applied current.
            self = self.design_inversion_applied_current( neuron_IDs );
            
            % Design the inversion subnetwork synapse.
            self = self.design_inversion_synapse( neuron_IDs, epsilon, k );
            
        end
        
        
        %         % Implement a function to design an absolute inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        %         function self = design_absolute_inversion_subnetwork( self, neuron_IDs, c, epsilon )
        %
        %             % Define the default input arguments.
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                          	% [-] Inversion Subnetwork Offset
        %             if nargin < 3, c = self.c_inversion_DEFAULT; end                                                        % [-] Inversion Subnetwork Gain
        %
        %             % Design the absolute inversion neurons.
        %             self = self.design_absolute_inversion_neurons( neuron_IDs, c, epsilon );
        %
        %             % Design the absolute inversion applied currents.
        %             self = self.design_absolute_inversion_applied_currents( neuron_IDs );
        %
        %             % Design the absolute inversion synapses.
        %             self = self.design_absolute_inversion_synapses( neuron_IDs, c, epsilon );
        %
        %         end
        
        
        % Implement a function to design an absolute inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_absolute_inversion_subnetwork( self, neuron_IDs, c, epsilon, delta )
            
            % Define the default input arguments.
            if nargin < 5, delta = self.delta_DEFAULT; end                                                  % [-] Inversion Subnetwork Output Offset
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                          	% [-] Inversion Subnetwork Input Offset
            if nargin < 3, c = self.c_inversion_DEFAULT; end                                                          % [-] Inversion Subnetwork Gain
            
            % Design the absolute inversion neurons.
            self = self.design_absolute_inversion_neurons( neuron_IDs, c, epsilon, delta );
            
            % Design the absolute inversion applied currents.
            self = self.design_absolute_inversion_applied_currents( neuron_IDs );
            
            % Design the absolute inversion synapses.
            self = self.design_absolute_inversion_synapses( neuron_IDs, c, delta );
            
        end
        
        
        % Implement a function to design an relative inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_relative_inversion_subnetwork( self, neuron_IDs, c )
            
            % Define the default input arguments.
            if nargin < 3, c = self.c_inversion_DEFAULT; end                                                        % [-] Inversion Subnetwork Gain
            
            % Design the relative subnetwork offsets.
            epsilon = self.compute_relative_inversion_epsilon( c );                                                 % [V] Inversion Subnetwork Input Offset
            delta = self.compute_relative_inversion_delta( c );                                                     % [V] Inversion Subnetwork Output Offset
            
            % Design the relative inversion neurons.
            self = self.design_relative_inversion_neurons( neuron_IDs );
            
            % Design the relative inversion applied currents.
            self = self.design_relative_inversion_applied_currents( neuron_IDs );
            
            % Design the relative inversion synapses.
            self = self.design_relative_inversion_synapses( neuron_IDs, epsilon, delta );
            
        end
        
        
        % Implement a function to design a division subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_division_subnetwork( self, neuron_IDs, k, c )
            
            % Set the default input arguments.
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = self.c_division_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the division subnetwork neurons.
            self = self.design_division_neurons( neuron_IDs );
            
            % Design the division subnetwork synapses.
            self = self.design_division_synapses( neuron_IDs, k, c );
            
        end
        
        
        % Implement a function to design an absolute division subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_absolute_division_subnetwork( self, neuron_IDs, c, alpha, epsilon )
            
            % Define the default input arguments.
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                                          	% [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                                                  % [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.c_division_DEFAULT; end                                                 % [-] Division Subnetwork Gain
            
            % Design the absolute division neurons.
            self = self.design_absolute_division_neurons( neuron_IDs, c, alpha, epsilon );
            
            % Design the absolute division applied currents.
            self = self.design_absolute_division_applied_currents( neuron_IDs );
            
            % Design the absolute division synapses.
            self = self.design_absolute_division_synapses( neuron_IDs, c, alpha, epsilon );
            
        end
        
        
        % Implement a function to design an relative division subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_relative_division_subnetwork( self, neuron_IDs, c, alpha, epsilon )
            
            % Define the default input arguments.
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                                              % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end
            if nargin < 3, c = self.c_division_DEFAULT; end                                                         % [-] Division Subnetwork Gain
            
            % Design the relative division neurons.
            self = self.design_relative_division_neurons( neuron_IDs );
            
            % Design the relative division applied currents.
            self = self.design_relative_division_applied_currents( neuron_IDs );
            
            % Design the relative division synapses.
            self = self.design_relative_division_synapses( neuron_IDs, c, alpha, epsilon );
            
        end
        
        
        % Implement a function to design a derivation subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_derivation_subnetwork( self, neuron_IDs, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the derivation subnetwork neurons.
            self = self.design_derivation_neurons( neuron_IDs, k, w, safety_factor );
            
            % Design the derivation subnetwork synapses.
            self = self.design_derivation_synapses( neuron_IDs, k );
            
        end
        
        
        % Implement a function to design an integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_integration_subnetwork( self, neuron_IDs, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 9, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 8, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 7, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_dmcpg_sll_neurons( num_cpg_neurons );
            
            % Create the driven multistate cpg synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_dmcpg_sll_synapses( neuron_IDs_cell );
            
            % Create the driven multistate cpg applied current.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_dmcpg_sll_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the driven multistate cpg double centered lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg double centered lead lag subnetwork neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Create the driven multistate cpg double centered lead lag subnetwork synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_dmcpg_dcll_synapses( neuron_IDs_cell );
            
            % Create the driven multistate cpg double centered lead lag subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the open loop driven multistate cpg double centered lead lag error subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_ol_dmcpg_dclle_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_ol_dmcpg_dclle_neurons( num_cpg_neurons );
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_ol_dmcpg_dclle_synapses( neuron_IDs_cell );
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_clpc_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_clpc_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_clpc_dmcpg_dcll_synapses( neuron_IDs_cell );
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
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
        
        
        % Implement a function to create the absolute addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_addition_subnetwork_components( self, num_addition_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                            % [#] Number of Addition Neurons
            
            % Create the neurons for an absolute addition subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_absolute_addition_neurons( num_addition_neurons );
            
            % Create the applied currents for an absolute addition subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_absolute_addition_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute addition subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_absolute_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_addition_subnetwork_components( self, num_addition_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                            % [#] Number of Addition Neurons
            
            % Create the neurons for a relative addition subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_relative_addition_neurons( num_addition_neurons );
            
            % Create the applied currents for a relative addition subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_relative_addition_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative addition subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_relative_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork_components( self )
            
            % Create the subtraction neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_subtraction_neurons(  );
            
            % Create the subtraction synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_subtraction_subnetwork_components( self, num_subtraction_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                            % [#] Number of Subtraction Neurons
            
            % Create the neurons for an absolute subtraction subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_absolute_subtraction_neurons( num_subtraction_neurons );
            
            % Create the applied currents for an absolute subtraction subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_absolute_subtraction_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute subtraction subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_absolute_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_subtraction_subnetwork_components( self, num_subtraction_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                            % [#] Number of Subtraction Neurons
            
            % Create the neurons for a relative subtraction subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_relative_subtraction_neurons( num_subtraction_neurons );
            
            % Create the applied currents for a relative subtraction subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_relative_subtraction_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative subtraction subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_relative_subtraction_synapses( neuron_IDs );
            
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
        
        
        % Implement a function to create the double centering subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_double_centering_subnetwork_components( self )
            
            % Create the double centering subnetwork neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_double_centering_neurons(  );
            
            % Create the double centering subnetwork synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_double_centering_synapses( neuron_IDs );
            
            % Create the double centering subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_double_centering_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the centered double subtraction subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_centered_double_subtraction_subnetwork_components( self )
            
            % Create the centered double subtraction subnetwork neurons.
            [ self.neuron_manager, neuron_IDs_cell ] = self.neuron_manager.create_centered_double_subtraction_neurons(  );
            
            % Create the centered double subtraction subnetwork synapses.
            [ self.synapse_manager, synapse_IDs_cell ] = self.synapse_manager.create_centered_double_subtraction_synapses( neuron_IDs_cell );
            
            % Create the centered double subtraction subnetwork applied currents.
            [ self.applied_current_manager, applied_current_IDs_cell ] = self.applied_current_manager.create_centered_double_subtraction_applied_currents( neuron_IDs_cell );
            
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
        
        
        % Implement a function to create the absolute multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_multiplication_subnetwork_components( self )
            
            % Create the neurons for an absolute multiplication subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_absolute_multiplication_neurons(  );
            
            % Create the applied currents for an absolute multiplication subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_absolute_multiplication_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute multiplication subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_absolute_multiplication_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_multiplication_subnetwork_components( self )
            
            % Create the neurons for a relative multiplication subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_relative_multiplication_neurons(  );
            
            % Create the applied currents for a relative multiplication subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_relative_multiplication_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative multiplication subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_relative_multiplication_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the inversion subnetwork components.
        function [ self, neuron_IDs, synapse_ID, applied_current_ID ] = create_inversion_subnetwork_components( self )
            
            % Create the inversion neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_inversion_neurons(  );
            
            % Create the inversion synapse.
            [ self.synapse_manager, synapse_ID ] = self.synapse_manager.create_inversion_synapse( neuron_IDs );
            
            % Create the inversion applied current.
            [ self.applied_current_manager, applied_current_ID ] = self.applied_current_manager.create_inversion_applied_current( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute inversion subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_inversion_subnetwork_components( self )
            
            % Create the neurons for an absolute inversion subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_absolute_inversion_neurons(  );
            
            % Create the applied currents for an absolute inversion subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_absolute_inversion_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute inversion subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_absolute_inversion_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative inversion subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_inversion_subnetwork_components( self )
            
            % Create the neurons for a relative inversion subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_relative_inversion_neurons(  );
            
            % Create the applied currents for a relative inversion subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_relative_inversion_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative inversion subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_relative_inversion_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork_components( self )
            
            % Create the division neurons.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_division_neurons(  );
            
            % Create the division synapses.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_division_subnetwork_components( self )
            
            % Create the neurons for an absolute division subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_absolute_division_neurons(  );
            
            % Create the applied currents for an absolute division subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_absolute_division_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute division subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_absolute_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_division_subnetwork_components( self )
            
            % Create the neurons for a relative division subnetwork.
            [ self.neuron_manager, neuron_IDs ] = self.neuron_manager.create_relative_division_neurons(  );
            
            % Create the applied currents for a relative division subnetwork.
            [ self.applied_current_manager, applied_current_IDs ] = self.applied_current_manager.create_relative_division_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative division subnetwork.
            [ self.synapse_manager, synapse_IDs ] = self.synapse_manager.create_relative_division_synapses( neuron_IDs );
            
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
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = 2; end
            
            % Create the multistate cpg subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multistate_cpg_subnetwork_components( num_cpg_neurons );
            
            % Design the multistate cpg subnetwork.
            self = self.design_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
        
        % Implement a function to create a driven multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_driven_multistate_cpg_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max )
            
            % Set the default input arguments.
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = 2; end
            
            % Create the driven multistate cpg subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_driven_multistate_cpg_subnetwork_components( num_cpg_neurons );
            
            % Design the driven multistate cpg subnetwork.
            self = self.design_driven_multistate_cpg_subnetwork( neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max );
            
        end
        
        
        % Implement a function to create a driven multistate cpg split lead lag subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r )
            
            % Set the default input arguments.
            if nargin < 12, r = self.r_oscillation_DEFAULT; end
            if nargin < 11, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg subnetwork components.
            [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_dmcpg_sll_subnetwork_components( num_cpg_neurons );
            
            % Design the driven multistate cpg subnetwork.
            self = self.design_dmcpg_sll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r );
            
        end
        
        
        % Implement a function to create a driven multistate cpg double centered lead lag subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_dcll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r )
            
            % Set the default input arguments.
            if nargin < 14, r = self.r_oscillation_DEFAULT; end
            if nargin < 13, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 12, k_add = self.c_addition_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg double centered lead lag subnetwork components.
            [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_dmcpg_dcll_subnetwork_components( num_cpg_neurons );
            
            % Design the driven multistate cpg double centered lead lag  subnetwork.
            self = self.design_dmcpg_dcll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r );
            
        end
        
        
        % Implement a function to create an open loop driven multistate cpg double centered lead lag error subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_ol_dmcpg_dclle_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r )
            
            % Set the default input arguments.
            if nargin < 17, r = self.r_oscillation_DEFAULT; end
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork components.
            [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_ol_dmcpg_dclle_subnetwork_components( num_cpg_neurons );
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork.
            self = self.design_ol_dmcpg_dclle_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r );
            
        end
        
        
        % Implement a function to create the closed loop P controlled double centered dmcpg lead lag subnetwork.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_clpc_dmcpg_dcll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain )
            
            % Set the default input arguments.
            if nargin < 18, kp_gain = self.kp_gain_DEFAULT; end
            if nargin < 17, r = self.r_oscillation_DEFAULT; end
            if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
            if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
            if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
            if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Idrive_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the closed loop P controlled double centered dmcpg lead lag subnetwork components.
            [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_clpc_dmcpg_dcll_subnetwork_components( num_cpg_neurons );
            
            % Design the closed loop P controlled double centered dmcpg lead lag subnetwork.
            self = self.design_clpc_dmcpg_dcll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain );
            
        end
        
        
        % Implement a function to create a transmission subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_transmission_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.c_transmission_DEFAULT; end
            
            % Create the transmission subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_transmission_subnetwork_components(  );
            
            % Design a transmission subnetwork.
            self = self.design_transmission_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a modulation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork( self, c )
            
            % Set the default input arugments.
            %             if nargin < 2, c = 0.05; end
            if nargin < 2, c = self.c_modulation_DEFAULT; end
            
            % Create the modulation subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_modulation_subnetwork_components(  );
            
            % Design a modulation subnetwork.
            self = self.design_modulation_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create an addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork( self, k )
            
            % Set the default input arguments.
            if nargin < 2, k = self.c_addition_DEFAULT; end
            
            % Create addition subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_addition_subnetwork_components(  );
            
            % Design the addition subnetwork.
            self = self.design_addition_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create an absolute addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_addition_subnetwork( self, num_addition_neurons, c )
            
            % Set the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                                                                 % [-] Addition Subnetwork Gain
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                                    % [#] Numebr of Addition Neurons
            
            % Create the absolute addition subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_addition_subnetwork_components( num_addition_neurons );
            
            % Design the absolute addition subnetwork.
            self = self.design_absolute_addition_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create a relative addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_addition_subnetwork( self, num_addition_neurons, c )
            
            % Set the default input arguments.
            if nargin < 3, c = self.c_addition_DEFAULT; end                                                                 % [-] Addition Subnetwork Gain
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                                    % [#] Number of Addition Neurons
            
            % Create the absolute addition subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_addition_subnetwork_components( num_addition_neurons );
            
            % Design the absolute addition subnetwork.
            self = self.design_relative_addition_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create a subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.c_subtraction_DEFAULT; end
            
            % Create the subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_subtraction_subnetwork_components(  );
            
            % Design the subtraction subnetwork.
            self = self.design_subtraction_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create an absolute subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_subtraction_subnetwork( self, num_subtraction_neurons, c, s_ks )
            
            % Set the default input arguments.
            if nargin < 4, s_ks = [ 1, -1 ]; end                                                                                    % [-] Excitatory / Inhibitory Input Synapse Code
            if nargin < 3, c = self.c_addition_DEFAULT; end                                                                         % [-] Addition Subnetwork Gain
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                                      % [#] Number of Subtraction Neurons
            
            % Create the absolute subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_subtraction_subnetwork_components( num_subtraction_neurons );
            
            % Design the absolute subtraction subnetwork.
            self = self.design_absolute_subtraction_subnetwork( neuron_IDs, c, s_ks );
            
        end
        
        
        % Implement a function to create a relative subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_subtraction_subnetwork( self, num_subtraction_neurons, c, npm_k, s_ks )
            
            % Set the default input arguments.
            if nargin < 5, s_ks = [ 1, -1 ]; end                                                                                    % [-] Excitatory / Inhibitory Input Synapse Code
            if nargin < 4, npm_k = [ 1, 1 ]; end                                                                                    % [-] Number of Excitatory / Inhibitory Inputs
            if nargin < 3, c = self.c_addition_DEFAULT; end                                                                         % [-] Addition Subnetwork Gain
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                                      % [#] Number of Subtraction Neurons
            
            % Create the relative subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_subtraction_subnetwork_components( num_subtraction_neurons );
            
            % Design the relative subtraction subnetwork.
            self = self.design_relative_subtraction_subnetwork( neuron_IDs, c, npm_k, s_ks );
            
        end
        
        
        % Implement a function to create a double subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_double_subtraction_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.c_subtraction_DEFAULT; end
            
            % Create the double subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_double_subtraction_subnetwork_components(  );
            
            % Design the double subtraction subnetwork.
            self = self.design_double_subtraction_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a centering subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_centering_subnetwork( self, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 3, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 2, k_add = self.c_addition_DEFAULT; end
            
            % Create the centering subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_centering_subnetwork_components(  );
            
            % Design the centering subnetwork.
            self = self.design_centering_subnetwork( neuron_IDs, k_add, k_sub );
            
        end
        
        
        % Implement a function to create a double centering subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_double_centering_subnetwork( self, k_add, k_sub )
            
            % Set the default input arguments.
            if nargin < 3, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 2, k_add = self.c_addition_DEFAULT; end
            
            % Create the double centering subnetwork components.
            [  self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_double_centering_subnetwork_components(  );
            
            % Design the double centering subnetwork.
            self = self.design_double_centering_subnetwork( neuron_IDs, k_add, k_sub );
            
            
        end
        
        
        % Implement a function to create a centered double subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_ID_cell ] = create_centered_double_subtraction_subnetwork( self, k_sub1, k_sub2, k_add )
            
            % Set the default input arguments.
            if nargin < 4, k_add = self.c_addition_DEFAULT; end
            if nargin < 3, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 2, k_sub1 = self.c_subtraction_DEFAULT; end
            
            % Create the centered double subtraction subnetwork components.
            [  self, neuron_IDs_cell, synapse_IDs_cell, applied_current_ID_cell ] = self.create_centered_double_subtraction_subnetwork_components(  );
            
            % Design the centered double subtraction subnetwork.
            self = self.design_centered_double_subtraction_subnetwork( neuron_IDs_cell, k_sub1, k_sub2, k_add );
            
        end
        
        
        % Implement a function to create an inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID, applied_current_ID ] = create_inversion_subnetwork( self, epsilon, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_inversion_DEFAULT; end
            if nargin < 2, epsilon = self.epsilon_inversion_DEFAULT; end
            
            % Create inversion subnetwork components.
            [ self, neuron_IDs, synapse_ID, applied_current_ID ] = self.create_inversion_subnetwork_components(  );
            
            % Design the inversion subnetwork.
            self = self.design_inversion_subnetwork( neuron_IDs, epsilon, k );
            
        end
        
        
        %         % Implement a function to create an absolute inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        %         function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_inversion_subnetwork( self, c, epsilon )
        %
        %             % Set the default input arguments.
        %             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                  	% [-] Inversion Subnetwork Offset
        %             if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Inversion Subnetwork Gain
        %
        %             % Create the absolute inversion subnetwork components.
        %             [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_inversion_subnetwork_components(  );
        %
        %             % Design the absolute inversion subnetwork.
        %             self = self.design_absolute_inversion_subnetwork( neuron_IDs, c, epsilon );
        %
        %         end
        
        
        % Implement a function to create an absolute inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_inversion_subnetwork( self, c, epsilon, delta )
            
            % Set the default input arguments.
            if nargin < 4, delta = self.delta_DEFAULT; end                                                                          % [V] Inversion Subnetwork Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                  	% [V] Inversion Subnetwork Input Offset
            if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Inversion Subnetwork Gain
            
            % Create the absolute inversion subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_inversion_subnetwork_components(  );
            
            % Design the absolute inversion subnetwork.
            self = self.design_absolute_inversion_subnetwork( neuron_IDs, c, epsilon, delta );
            
        end
        
        
        %         % Implement a function to create a relative inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        %         function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_inversion_subnetwork( self, c, epsilon )
        %
        %             % Set the default input arguments.
        %             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                  	% [-] Inversion Subnetwork Offset
        %             if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Inversion Subnetwork Gain
        %
        %             % Create the relative inversion subnetwork components.
        %             [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_inversion_subnetwork_components(  );
        %
        %             % Design the relative inversion subnetwork.
        %             self = self.design_relative_inversion_subnetwork( neuron_IDs, c, epsilon );
        %
        %         end
        
        
        % Implement a function to create a relative inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_inversion_subnetwork( self, c )
            
            % Set the default input arguments.
            if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Inversion Subnetwork Gain
            
            % Create the relative inversion subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_inversion_subnetwork_components(  );
            
            % Design the relative inversion subnetwork.
            self = self.design_relative_inversion_subnetwork( neuron_IDs, c );
            
        end
        
        
        % Implement a function to create a division subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork( self, k, c )
            
            % Set the default input arguments.
            if nargin < 3, c = [  ]; end
            if nargin < 2, k = self.c_division_DEFAULT; end
            
            % Create division subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_division_subnetwork_components(  );
            
            % Design the division subnetwork.
            self = self.design_division_subnetwork( neuron_IDs, k, c );
            
        end
        
        
        % Implement a function to create an absolute division subnetwork ( generatin neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_division_subnetwork( self, c, alpha, epsilon )
            
            % Set the default input arguments.
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                  	% [-] Division Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                                                          % [-] Division Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Division Subnetwork Gain
            
            % Create the absolute division subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_division_subnetwork_components(  );
            
            % Design the absolute division subnetwork.
            self = self.design_absolute_division_subnetwork( neuron_IDs, c, alpha, epsilon );
            
        end
        
        
        % Implement a function to create a relative division subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_division_subnetwork( self, c, alpha, epsilon )
            
            % Set the default input arguments.
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                  	% [-] Division Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end
            if nargin < 2, c = self.c_inversion_DEFAULT; end                                                                      	% [-] Division Subnetwork Gain
            
            % Create the relative division subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_division_subnetwork_components(  );
            
            % Design the relative division subnetwork.
            self = self.design_relative_division_subnetwork( neuron_IDs, c, alpha, epsilon );
            
        end
        
        
        % Implement a function to create a multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork( self, k )
            
            % Set the default input arugments.
            if nargin < 2, k = self.c_multiplication_DEFAULT; end
            
            % Create the multiplication subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multiplication_subnetwork_components(  );
            
            % Design the multiplication subnetwork.
            self = self.design_multiplication_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create an absolute multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_multiplication_subnetwork( self, c, c1, c2, epsilon1, epsilon2 )
            
            % Set the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_division_DEFAULT; end                                                                    % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_inversion_DEFAULT; end                                                                   % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_division_DEFAULT; end                                                                                % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_inversion_DEFAULT; end                                                                               % [-] Inverion Subnetwork Gain
            if nargin < 2, c = self.c_multiplication_DEFAULT; end                                                                           % [-] Multiplication Subnetwork Gain
            
            % Create the absolute multiplication subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_absolute_multiplication_subnetwork_components(  );
            
            % Design the absolute multiplication subnetwork.
            self = self.design_absolute_multiplication_subnetwork( neuron_IDs, c, c1, c2, epsilon1, epsilon2 );
            
        end
        
        
        % Implement a function to create a relative multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_multiplication_subnetwork( self, c, c1, c2, epsilon1, epsilon2 )
            
            % Set the default input arguments.
            if nargin < 6, epsilon2 = self.epsilon_division_DEFAULT; end                                                                    % [-] Division Subnetwork Offset
            if nargin < 5, epsilon1 = self.epsilon_inversion_DEFAULT; end                                                                   % [-] Inversion Subnetwork Offset
            if nargin < 4, c2 = self.c_division_DEFAULT; end                                                                                % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_inversion_DEFAULT; end                                                                               % [-] Inverion Subnetwork Gain
            if nargin < 2, c = self.c_multiplication_DEFAULT; end                                                                           % [-] Multiplication Subnetwork Gain
            
            % Create the relative multiplication subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_relative_multiplication_subnetwork_components(  );
            
            % Design the relative multiplication subnetwork.
            self = self.design_relative_multiplication_subnetwork( neuron_IDs, c, c1, c2, epsilon1, epsilon2 );
            
        end
        
        
        %         % Implement a function to create a multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        %         function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork( self, k )
        %
        %             % Set the default input arugments.
        %             if nargin < 2, k = self.c_multiplication_DEFAULT; end
        %
        %             % Create the multiplication subnetwork components.
        %             [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = self.create_multiplication_subnetwork_components(  );
        %
        %             % Design the multiplication subnetwork.
        %             self = self.design_multiplication_subnetwork( neuron_IDs, k );
        %
        %         end
        
        
        % Implement a function to create a derivation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs ] = create_derivation_subnetwork( self, k, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 3, w = self.w_derivation_DEFAULT; end
            if nargin < 2, k = self.c_derivation_DEFAULT; end
            
            % Create the derivation subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_derivation_subnetwork_components(  );
            
            % Design the derivation subnetwork.
            self = self.design_derivation_subnetwork( neuron_IDs, k, w, safety_factor );
            
        end
        
        
        % Implement a function to create an integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_integration_subnetwork( self, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_integration_subnetwork_components(  );
            
            % Design the integration subnetwork.
            self = self.design_integration_subnetwork( neuron_IDs, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_vb_integration_subnetwork( self, T, n, ki_mean, ki_range )
            
            % Set the default input arugments.
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the voltage based integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_vb_integration_subnetwork_components(  );
            
            % Design the voltage based integration subnetwork.
            self = self.design_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_split_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub )
            
            % Set the default input arugments.
            if nargin < 6, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the split voltage based integration subnetwork specific components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_split_vb_integration_subnetwork_components(  );
            
            % Design the split voltage based integration subnetwork.
            self = self.design_split_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_sub );
            
        end
        
        
        % Implement a function to create a modulated split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub, c_mod )
            
            % Set the default input arugments.
            if nargin < 7, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 6, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the modulated split voltage based integration subnetwork specific components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_mod_split_vb_integration_subnetwork_components(  );
            
            % Design the modulated split voltage based integration subnetwork.
            self = self.design_mod_split_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod );
            
        end
        
        
        % Implement a function to create a modulated split difference voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_sub_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod )
            
            % Set the default input arugments.
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 7, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 6, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
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
        
        
        %% Network Linearization Functions
        
        % Implement a function to compute the linearized system matrix for this neural network about a given operating point.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function A = compute_linearized_system_matrix( self, Cms, Gms, Rs, gs, dEs, Us0 )
            
            % Set the default input arguments.
            if nargin < 7, Us0 = zeros( length( Cm2 ), 1 ); end
            if nargin < 6, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 5, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 4, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 3, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 2, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end

            % Compute the linearized system matrix.
            A = self.network_utilities.compute_linearized_system_matrix( Cms, Gms, Rs, gs, dEs, Us0 );
            
        end
        
        
        % Implement a function to compute the linearized input matrix for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function B = compute_linearized_input_matrix( self, Cms, Ias )
        
            % Set the default input arguments.
            if nargin < 3, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 2, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            
            % Compute the linearized input matrix.
            B = self.network_utilitities.compute_linearized_input_matrix( Cms, Ias );
            
        end
        
        
        % Implement a function to compute the linearized system for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function [ A, B ] = get_linearized_system( self, Cms, Gms, Rs, gs, dEs, Ias, Us0 )
        
            % Set the default input arguments.
            if nargin < 8, Us0 = zeros( self.neuron_manager.num_neurons, 1 ); end
            if nargin < 7, Ias = cell2mat( self.neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic' ) ); end
            if nargin < 6, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 5, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 4, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 3, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 2, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end

            % Compute the linearized system.
            [ A, B ] = self.network_utilities.get_linearized_system( Cms, Gms, Rs, gs, dEs, Ias, Us0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at a specific operating point.
        function [ A, dt, condition_number ] = RK4_stability_analysis_at_point( self, Cms, Gms, Rs, gs, dEs, Us0, dt0 )
        
            % Set the default input arguments.
            if nargin < 8, dt0 = 1e-6; end
            if nargin < 7, Us0 = zeros( self.neuron_manager.num_neurons, 1 ); end
            if nargin < 6, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 5, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 4, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 3, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 2, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            
            % Compute the maximum RK4 step size and condition number.            
            [ A, dt, condition_number ] = self.network_utilities.RK4_stability_analysis_at_point( Cms, Gms, Rs, gs, dEs, Us0, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at multiple operating points.
        function [ As, dts, condition_numbers ] = RK4_stability_analysis( self, Cms, Gms, Rs, gs, dEs, Us, dt0 )
        
           % Set the default input arguments.
            if nargin < 8, dt0 = 1e-6; end
            if nargin < 7, Us = zeros( 1, self.neuron_manager.num_neurons ); end
            if nargin < 6, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 5, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 4, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 3, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 2, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            
            % Retrieve the number of operating points.
            num_points = size( Us, 1 );
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 2 );
            
            % Preallocate an array to store the condition numbers.
            condition_numbers = zeros( num_points, 1 );
            
            % Preallocate an array to store the maximum step sizes.
            dts = zeros( num_points, 1 );
            
            % Preallocate an array to store the linearized system matrices.
            As = zeros( [ num_neurons, num_neurons, num_points ] );
            
            % Perform RK4 stability analysis at each of the operating points.
            for k = 1:num_points                    % Iterate through each of the operating points...

                % Perform RK4 stability analysis at this operating point.
                [ As( :, :, k ), dts( k ), condition_numbers( k ) ] = self.RK4_stability_analysis_at_point( Cms, Gms, Rs, gs, dEs, Us( k, : ) , dt0 );
            
            end
            
        end
            
        
        % Implement a function to perform RK4 stability analysis on a transmission subnetwork.
        function [ U2s, As, dts, condition_numbers ] = achieved_transmission_RK4_stability_analysis( self, U1s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
        
            % Set the default input arguments.
            if nargin < 9, dt0 = 1e-6; end
            if nargin < 8, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 7, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 6, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 5, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 4, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 3, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved transmission steady state output at each of the provided inputs.
            U2s = self.compute_achieved_transmission_steady_state_output( U1s, Rs( 1 ), Gms( 2 ), Ias( 2 ), gs( 2, 1 ), dEs( 2, 1 ) );
            
            % Create the operating points array.
            Us = [ U1s, U2s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );  
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on an addition subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_addition_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
            
           % Set the default input arguments.
            if nargin < 10, dt0 = 1e-6; end
            if nargin < 9, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 8, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 7, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 6, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 5, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 4, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved addition steady state output at each of the provided inputs.
            U3s = self.compute_achieved_addition_steady_state_output( [ U1s, U2s ], Rs, Gms, Ias, gs, dEs );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a subtraction subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_subtraction_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
            
            % Set the default input arguments.
            if nargin < 10, dt0 = 1e-6; end
            if nargin < 9, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 8, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 7, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 6, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 5, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 4, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved subtraction steady state output at each of the provided inputs.
            U3s = self.compute_achieved_subtraction_steady_state_output( [ U1s, U2s ], Rs, Gms, Ias, gs, dEs );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on an inversion subnetwork.
        function [ U2s, As, dts, condition_numbers ] = achieved_inversion_RK4_stability_analysis( self, U1s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
        
            % Set the default input arguments.
            if nargin < 9, dt0 = 1e-6; end
            if nargin < 8, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 7, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 6, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 5, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 4, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 3, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved inversion steady state output at each of the provided inputs.
            U2s = self.compute_achieved_inversion_steady_state_output( U1s, Rs( 1 ), Gms( 2 ), Ias( 2 ), gs( 2, 1 ), dEs( 2, 1 ) );
            
            % Create the operating points array.
            Us = [ U1s, U2s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );  
            
        end
        
            
        % Implement a function to perform RK4 stability analysis on a division subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_division_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
            
            % Set the default input arguments.
            if nargin < 10, dt0 = 1e-6; end
            if nargin < 9, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 8, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 7, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 6, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 5, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 4, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved division steady state output at each of the provided inputs.
            U3s = self.compute_achieved_division_steady_state_output( [ U1s, U2s ], Rs( 1 ), Rs( 2 ), Gms( 3 ), Ias( 3 ), gs( 3, 1 ), gs( 3, 2 ), dEs( 3, 1 ), dEs( 3, 2 ) );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a multiplication subnetwork.
        function [ U4s, U3s, As, dts, condition_numbers ] = achieved_multiplication_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
           
            % Set the default input arguments.
            if nargin < 10, dt0 = 1e-6; end
            if nargin < 9, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 8, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 7, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 6, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 5, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 4, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved multiplication steady state output at each of the provided inputs.
            [ U4s, U3s ] = self.compute_achieved_multiplication_steady_state_output( [ U1s, U2s ], Rs( 1 ), Rs( 2 ), Rs( 3 ), Gms( 3 ), Gms( 4 ), Ias( 3 ), Ias( 4 ), gs( 3, 2 ), gs( 4, 1 ), gs( 4, 3 ), dEs( 3, 2 ), dEs( 4, 1 ), dEs( 4, 3 ) );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s, U4s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a linear combination subnetwork.
        function [ Us_outputs, As, dts, condition_numbers ] = achieved_linear_combination_RK4_stability_analysis( self, Us_inputs, Cms, Gms, Rs, Ias, gs, dEs, dt0 )
            
            % Set the default input arguments.
            if nargin < 9, dt0 = 1e-6; end
            if nargin < 8, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 7, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 6, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 5, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 4, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 3, Cms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Cm' ) ); end
            if nargin < 2, Us_inputs = zeros( 1, length( Rs ) - 1 ); end
            
            % Compute the achieved division steady state output at each of the provided inputs.            
            Us_outputs = self.compute_achieved_linear_combination_ss_output( Us_inputs', Rs', Gms', Ias', gs( end, 1:( end - 1 ) )', dEs( end , 1:( end - 1 ) )' )';
            
            % Create the operating points array.
            Us = [ Us_inputs, Us_outputs ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0 );
            
        end
        
        
        %% Steady State Functions.
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute transmission subnetwork.
        function U2s = compute_desired_absolute_transmission_steady_state_output( self, U1s, c )
 
            % Set the default input arguments.
            if nargin < 3, c = 1; end
            if nargin < 2, U1s = 0; end
            
            % Compute the steady state network outputs.
            U2s = self.network_utilities.compute_desired_absolute_transmission_steady_state_output( U1s, c );
        
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative transmission subnetwork.
        function U2s = compute_desired_relative_transmission_steady_state_output( self, U1s, c, R1, R2 )
 
            % Set the default input arguments.
            if nargin < 5, R2 = 20e-3; end
            if nargin < 4, R1 = 20e-3; end
            if nargin < 3, c = 1; end
            if nargin < 2, U1s = 0; end
            
            % Compute the steady state network outputs.
            U2s = self.network_utilities.compute_desired_relative_transmission_steady_state_output( U1s, c, R1, R2 );
        
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a transmission subnetwork.
        function U2s = compute_achieved_transmission_steady_state_output( self, U1s, R1, Gm2, Ia2, gs21, dEs21 )
        
            % Set the default input arguments.
            if nargin < 7, dEs21 = 194e-3; end                                  % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = 19e-6; end                                    % [S] Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = 20e-9; end                                     % [A] Applied Current (Neuron 2).
            if nargin < 4, Gm2 = 1e-6; end                                      % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = 20e-3; end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            
            % Compute the steady state network outputs.
            U2s = self.network_utilities.compute_achieved_transmission_steady_state_output( U1s, R1, Gm2, Ia2, gs21, dEs21 );
            
        end
        
            
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute addition subnetwork.
        function U_outputs = compute_desired_absolute_addition_steady_state_output( self, U_inputs, c )
        
            % Set the default input arguments.
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_desired_absolute_addition_steady_state_output( U_inputs, c );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative addition subnetwork.
        function U_outputs = compute_desired_relative_addition_steady_state_output( self, U_inputs, Rs, c )
           
            % Set the default input arguments.
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 2, U_inputs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'U' ) ); end
            
            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_desired_relative_addition_steady_state_output( U_inputs, Rs, c );
        
        end
            
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an addition subnetwork.
        function U_outputs = compute_achieved_addition_steady_state_output( self, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            % Set the default input arguments.
            if nargin < 7, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 6, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 5, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 4, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 3, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end

            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_achieved_addition_steady_state_output( U_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute subtraction subnetwork.
        function U_outputs = compute_desired_absolute_subtraction_steady_state_output( self, U_inputs, c, ss )
            
            % Set the default input arguments.
            if nargin < 4, ss = [ 1, -1 ]; end
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_desired_absolute_subtraction_steady_state_output( U_inputs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative subtraction subnetwork.
        function U_outputs = compute_desired_relative_subtraction_steady_state_output( self, U_inputs, Rs, c, ss )
           
            % Set the default input arguments.
            if nargin < 5, ss = [ 1, -1 ]; end
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_desired_relative_subtraction_steady_state_output( U_inputs, Rs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a subtraction subnetwork.
        function U_outputs = compute_achieved_subtraction_steady_state_output( self, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            % Set the default input arguments.
            if nargin < 7, dEs = self.get_dEsyns( 'all' ); end
            if nargin < 6, gs = self.get_gsynmaxs( 'all' ); end
            if nargin < 5, Ias = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'I_tonic' ) ); end
            if nargin < 4, Gms = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'Gm' ) ); end
            if nargin < 3, Rs = cell2mat( self.neuron_manager.get_neuron_property( 'all', 'R' ) ); end
            
            % Compute the steady state network outputs.
            U_outputs = self.network_utilities.compute_achieved_subtraction_steady_state_output( U_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute inversion subnetwork.
        function U2s = compute_desired_absolute_inversion_steady_state_output( self, U1s, c1, c2, c3 )
            
            % Set the default input arguments.
            if nargin < 5, c3 = 20e-9; end                          % [A] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                          % [S] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                        % [W] Design Constant 1.
            
            % Compute the steady state output.
            U2s = self.network_utilities.compute_desired_absolute_inversion_steady_state_output( U1s, c1, c2, c3 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute inversion subnetwork.
        function U2s = compute_desired_reduced_absolute_inversion_steady_state_output( self, U1s, c1, c2 )
            
            % Set the default input arguments.
            if nargin < 4, c2 = 21.05e-6; end                       % [mV] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                        % [mV^2] Design Constant 1.
            
            % Compute the steady state output.
            U2s = self.network_utilities.compute_desired_reduced_absolute_inversion_steady_state_output( U1s, c1, c2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative inversion subnetwork.
        function U2s = compute_desired_relative_inversion_steady_state_output( self, Us1, c1, c2, c3, R1, R2 )
        
            % Set the default input arguments.
            if nargin < 7, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                                                                                               % [-] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                                                                                              % [-] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                                                                                               % [-] Design Constant 1.
            
            % Compute the steady state output.
            U2s = self.network_utilities.compute_desired_relative_inversion_steady_state_output( Us1, c1, c2, c3, R1, R2 );             % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative inversion subnetwork.
        function U2s = compute_desired_reduced_relative_inversion_steady_state_output( self, Us1, c1, c2, R1, R2 )
        
            % Set the default input arguments.
            if nargin < 6, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 52.6e-3; end                                                                                            % [-] Design Constant 2.
            if nargin < 3, c1 = 52.6e-3; end                                                                                            % [-] Design Constant 1.
            
            % Compute the steady state output.
            U2s = self.network_utilities.compute_desired_reduced_relative_inversion_steady_state_output( Us1, c1, c2, R1, R2 );         % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an inversion subnetwork.
        function U2s = compute_achieved_inversion_steady_state_output( self, U1s, R1, Gm2, Ia2, gs21, dEs21 )
            
            % Set the default input arguments.
            if nargin < 7, dEs21 = self.get_dEsyns( [ 1, 2 ] ); end                                                                     % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = self.get_gsynmaxs( [ 1, 2 ] ); end                                                                    % [S] Maximum Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'I_tonic' ) ); end                               % [A] Applied Currents (Neuron 2).
            if nargin < 4, Gm2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'Gm' ) ); end                                    % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).

            % Compute the steady state output.
            U2s = self.network_utilities.compute_achieved_inversion_steady_state_output( U1s, R1, Gm2, Ia2, gs21, dEs21 );              % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_desired_absolute_division_steady_state_output( self, U_inputs, c1, c2, c3 )
            
            % Set the default input arguments.
            if nargin < 5, c3 = 0.40e-9; end                                                                                            % [W] Design Constant 3.
            if nargin < 4, c2 = 380e-9; end                                                                                             % [A] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                                                                                            % [W] Design Constant 1.
            
            % Compute the steady state output.
            U3s = self.network_utilities.compute_desired_absolute_division_steady_state_output( U_inputs, c1, c2, c3 );                 % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_desired_reduced_absolute_division_steady_state_output( self, U_inputs, c1, c2 )
            
            % Set the default input arguments.
            if nargin < 4, c2 = 1.05e-3; end                                                                                            % [V] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                                                                                            % [V] Design Constant 1.
            
            % Compute the steady state output.
            U3s = self.network_utilities.compute_desired_reduced_absolute_division_steady_state_output( U_inputs, c1, c2 );           	% [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative division subnetwork.
        function U3s = compute_desired_relative_division_steady_state_output( self, U_inputs, c1, c2, c3, R1, R2, R3 )
            
            % Set the default input arguments.
            if nargin < 8, R3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 7, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                                                                                                   % [S] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                                                                                                  % [S] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                                                                                                   % [S] Design Constant 1.
            
            % Compute the steady state output.
            U3s = self.network_utilities.compute_desired_relative_division_steady_state_output( U_inputs, c1, c2, c3, R1, R2, R3 );         % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative division subnetwork.
        function U3s = compute_desired_reduced_relative_division_steady_state_output( self, U_inputs, c1, c2, R1, R2, R3 )
            
            % Set the default input arguments.
            if nargin < 7, R3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 6, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 0.0526; end                                                                                                 % [-] Design Constant 2.
            if nargin < 3, c1 = 0.0526; end                                                                                                 % [-] Design Constant 1.
            
            % Compute the steady state output.
            U3s = self.network_utilities.compute_desired_reduced_relative_division_steady_state_output( U_inputs, c1, c2, R1, R2, R3 );     % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a division subnetwork.
        function U3s = compute_achieved_division_steady_state_output( self, U_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 )
            
            % Set the default input arguments.
            if nargin < 10, dEs32 = self.get_dEsyns( [ 2, 3 ] ); end                                                                                    % [V] Synaptic Reversal Potential (Synapse 32).
            if nargin < 9, dEs31 = self.get_dEsyns( [ 1, 3 ] ); end                                                                                     % [V] Synaptic Revesal Potential (Synapse 31).
            if nargin < 8, gs32 = self.get_gsynmaxs( [ 2, 3 ] ); end                                                                                    % [S] Synaptic Conductance (Synapse 32).
            if nargin < 7, gs31 = self.get_gsynmaxs( [ 1, 3 ] ); end                                                                                    % [S] Synaptic Conductance (Synapse 31).
            if nargin < 6, Ia3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'I_tonic' ) ); end                                               % [A] Applied Current (Neuron 3).
            if nargin < 5, Gm3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'Gm' ) ); end                                                    % [S] Membrane Conductance (Neuron 3).
            if nargin < 4, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end                                                      % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 3, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end                                                      % [V] Maximum Membrane Voltage (Neuron 1).
            
            % Compute the steady state output.
            U3s = self.network_utilities.compute_achieved_division_steady_state_output( U_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 );         % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_absolute_multiplication_steady_state_output( self, U_inputs, c1, c2, c3, c4, c5, c6 )
            
            % Set the default input arguments.
            if nargin < 8, c6 = 0.40e-9; end
            if nargin < 7, c5 = 380e-9; end
            if nargin < 6, c4 = 0.40e-9; end
            if nargin < 5, c3 = 20e-9; end
            if nargin < 4, c2 = 19e-6; end
            if nargin < 3, c1 = 0.40e-9; end
            
            % Compute the steady state output.
            [ U4s, U3s ] = self.network_utilities.compute_desired_absolute_multiplication_steady_state_output( U_inputs, c1, c2, c3, c4, c5, c6 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_abs_mult_ss_output( self, U_inputs, c1, c2, c3, c4 )
            
            % Set the default input arguments.
            if nargin < 6, c4 = 1.05e-3; end                      	% [V] Reduced Absolute Multiplication Design Constant 4 (Reduced Absolute Division Design Constant 2).
            if nargin < 5, c3 = 1.05e-3; end                       	% [V] Reduced Absolute Multiplication Design Constant 3 (Reduced Absolute Division Design Constant 1).
            if nargin < 4, c2 = 21.05e-6; end                       % [mV] Reduced Absolute Multiplication Design Constant 2 (Reduced Absolute Inversion Design Constant 2).
            if nargin < 3, c1 = 1.05e-3; end                        % [mV^2] Reduced Absolute Multiplication Design Constant 1 (Reduced Absolute Inversion Design Constant 1).
            
            % Compute the steady state output.
            [ U4s, U3s ] = self.network_utilities.compute_desired_red_abs_mult_ss_output( U_inputs, c1, c2, c3, c4 );
            
        end
        
                    
            
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_relative_multiplication_steady_state_output( self, U_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 )
            
            % Set the default input arguments.
            if nargin < 12, R4 = cell2mat( self.neuron_manager.get_neuron_property( 4, 'R' ) ); end
            if nargin < 11, R3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'R' ) ); end
            if nargin < 10, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end
            if nargin < 9, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end
            if nargin < 8, c6 = 1e-6; end
            if nargin < 7, c5 = 19e-6; end
            if nargin < 6, c4 = 1e-6; end
            if nargin < 5, c3 = 1e-6; end
            if nargin < 4, c2 = 19e-6; end
            if nargin < 3, c1 = 1e-6; end
            
            % Compute the steady state output.
            [ U4s, U3s ] = self.network_utilities.compute_desired_relative_multiplication_steady_state_output( U_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_rel_mult_ss_output( self, U_inputs, c1, c2, c3, c4, R1, R2, R3, R4 )
            
            % Set the default input arguments.
            if nargin < 10, R4 = cell2mat( self.neuron_manager.get_neuron_property( 4, 'R' ) ); end
            if nargin < 9, R3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'R' ) ); end
            if nargin < 8, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end
            if nargin < 7, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end
            if nargin < 6, c4 = 1e-6; end
            if nargin < 5, c3 = 1e-6; end
            if nargin < 4, c2 = 19e-6; end
            if nargin < 3, c1 = 1e-6; end
            
            % Compute the steady state output.
            [ U4s, U3s ] = self.network_utilities.compute_desired_red_rel_mult_ss_output( U_inputs, c1, c2, c3, c4, R1, R2, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a multiplication subnetwork.
        function [ U4s, U3s ] = compute_achieved_multiplication_steady_state_output( self, U_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 )
        
            % Set the default input arguments.
            if nargin < 15, dEs43 = self.get_dEsyns( [ 3, 4 ] ); end
            if nargin < 14, dEs41 = self.get_dEsyns( [ 1, 4 ] ); end
            if nargin < 13, dEs32 = self.get_dEsyns( [ 2, 3 ] ); end
            if nargin < 12, gs43 = self.get_gsynmaxs( [ 3, 4 ] ); end
            if nargin < 11, gs41 = self.get_gsynmaxs( [ 1, 4 ] ); end
            if nargin < 10, gs32 = self.get_gsynmaxs( [ 2, 3 ] ); end
            if nargin < 9, Ia4 = cell2mat( self.neuron_manager.get_neuron_property( 4, 'I_tonic' ) ); end
            if nargin < 8, Ia3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'I_tonic' ) ); end
            if nargin < 7, Gm4 = cell2mat( self.neuron_manager.get_neuron_property( 4, 'G' ) ); end
            if nargin < 6, Gm3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'G' ) ); end
            if nargin < 5, R3 = cell2mat( self.neuron_manager.get_neuron_property( 3, 'R' ) ); end
            if nargin < 4, R2 = cell2mat( self.neuron_manager.get_neuron_property( 2, 'R' ) ); end
            if nargin < 3, R1 = cell2mat( self.neuron_manager.get_neuron_property( 1, 'R' ) ); end

            % Compute the steady state output.
            [ U4s, U3s ] = self.network_utilities.compute_achieved_multiplication_steady_state_output( U_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 );
            
        end
           
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute linear combination subnetwork.
        function Us_output = compute_desired_absolute_linear_combination_steady_state_output( self, Us_inputs, cs, ss )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output  	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 4, ss = [ 1; -1 ]; end
            if nargin < 3, cs = [ 1; 1 ]; end
            if nargin < 2, Us_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            Us_output = self.network_utilities.compute_desired_absolute_linear_combination_steady_state_output( Us_inputs, cs, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative linear combination subnetwork.
        function Us_output = compute_desired_relative_linear_combination_steady_state_output( self, Us_inputs, Rs, cs, ss )
        
            %{
            Input(s):
                U_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltages.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output 	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 5, ss = [ 1; -1 ]; end
            if nargin < 4, cs = [ 1; 1 ]; end
            if nargin < 3, Rs = [ 20e-3; 20e-3; 20e-3 ]; end
            if nargin < 2, Us_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            Us_output = self.network_utilities.compute_desired_relative_linear_combination_steady_state_output( Us_inputs, Rs, cs, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a linear combination subnetwork.
        function Us_output = compute_achieved_linear_combination_ss_output( self, Us_inputs, Rs, Gms, Ias, gs, dEs )
        
            %{
            Input(s):
                Us_inputs = [V] Membrane Voltage Inputs (# of timesteps x # of inputs).
                Rs = [V] Maximum Membrane Voltage (# of inputs).
                Gms = [S] Membrane Conductances (# of inputs).
                Ias = [S] Applied Currents (# of neurons).
                gs = [S] Synaptic Conductances (# of synapses).
                dEs = [V] Synaptic Reversal Potentials (# of synapses).
            
            Output(s):
                Us_output = [V] Membrane Voltage Outputs (# of timesteps).
            %}
 
            % Set the default input arguments.
            if nargin < 7, dEs = [ 194e-3; -194e-3 ]; end
            if nargin < 6, gs = [ 0.10e-6; 0.10e-6 ]; end
            if nargin < 5, Ias = [ 0; 0; 0 ]; end
            if nargin < 4, Gms = [ 1e-6; 1e-6; 1e-6 ]; end
            if nargin < 3, Rs = [ 20e-3; 20e-3; 20e-3 ]; end
            if nargin < 2, Us_inputs = zeros( 2, 1 ); end
            
            % Compute the membrane voltage outputs.
            Us_output = self.network_utilities.compute_achieved_linear_combination_ss_output( Us_inputs, Rs, Gms, Ias, gs, dEs );
            
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
        
        
        % Implement a function to compute simulation results for given applied currents.
        function [ self, ts, Us_flat, hs_flat, dUs_flat, dhs_flat, Gsyns_flat, Ileaks_flat, Isyns_flat, Inas_flat, Iapps_flat, Itotals_flat, minfs_flat, hinfs_flat, tauhs_flat, neuron_IDs ] = simulate_flat( self, applied_current_IDs, applied_currents_flat, dt, tf, method )
                       
            % Retrieve the number of neurons.
            num_neurons = self.neuron_manager.num_neurons;

            % Retrieve size information.
            num_applied_currents = size( applied_currents_flat, 1 );
            num_input_neurons = size( applied_currents_flat, 2 );
            
            % Compute the number of simulation timesteps.
            num_timesteps = tf/dt + 1;
            
            % Create a matrix to store the membrane voltages.
            Us_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            hs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            dUs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            dhs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            Gsyns_flat = zeros( num_applied_currents, num_neurons, num_neurons, num_timesteps );
            Ileaks_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            Isyns_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            Inas_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            Iapps_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            Itotals_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            minfs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            hinfs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
            tauhs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );

            % Simulate the network for each of the applied current combinations.
            for k1 = 1:num_applied_currents                      % Iterate through each of the applied currents...
                
                % Create applied currents.
                for k2 = 1:num_input_neurons                    % Iterate through each of the input neurons...
                    
                    % Set the applied current for this input neuron.
                    self.applied_current_manager = self.applied_current_manager.set_applied_current_property( applied_current_IDs( k2 ), applied_currents_flat( k1, k2 ), 'I_apps' );
                    
                end
                
                % Simulate the network.
                [ self, ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = self.compute_set_simulation( dt, tf, method );
                
                % Retrieve the final membrane voltages.
                Us_flat( k1, :, : ) = Us;
                hs_flat( k1, :, : ) = hs;
                dUs_flat( k1, :, : ) = dUs;
                dhs_flat( k1, :, : ) = dhs;
                Gsyns_flat( k1, :, :, : ) = G_syns;
                Ileaks_flat( k1, :, : ) = I_leaks;
                Isyns_flat( k1, :, : ) = I_syns;
                Inas_flat( k1, :, : ) = I_nas;
                Iapps_flat( k1, :, : ) = I_apps;
                Itotals_flat( k1, :, : ) = I_totals;
                minfs_flat( k1, :, : ) = m_infs;
                hinfs_flat( k1, :, : ) = h_infs;
                tauhs_flat( k1, :, : ) = tauhs;

            end
            
        end
        
        
        %% Save & Load Functions.
        
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

