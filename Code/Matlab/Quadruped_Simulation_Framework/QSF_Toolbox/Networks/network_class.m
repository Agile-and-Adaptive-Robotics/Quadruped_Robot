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
        Ia_DEFAULT = 0;                                                                                                         % [A] Applied Current
        Id_max_DEFAULT = 1.25e-9;                                                                                           % [A] Maximum Drive Current.
        
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
        
        % Define default simulation properties.
        tf_DEFAULT = 1;
        dt_DEFAULT = 1e-3;
        
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( dt, tf, neuron_manager, synapse_manager, applied_current_manager, applied_voltage_manager, network_utilities, numerical_method_utilities )
            
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
            
            % Set the default input arguments.
            if nargin < 8, numerical_method_utilities = numerical_method_utilities_class(  ); end
            if nargin < 7, network_utilities = network_utilities_class(  ); end
            if nargin < 6, applied_voltage_manager = applied_voltage_manager_class(  ); end
            if nargin < 5, applied_current_manager = applied_current_manager_class(  ); end
            if nargin < 4, synapse_manager = synapse_manager_class(  ); end
            if nargin < 3, neuron_manager = neuron_manager_class(  ); end
            if nargin < 2, tf = self.tf_DEFAULT; end
            if nargin < 1, dt = self.dt_DEFAULT; end
            
            % Store the utility classes.
            self.numerical_method_utilities = numerical_method_utilities;
            self.network_utilities = network_utilities;
            
            % Store the managers.
            self.applied_voltage_manager = applied_voltage_manager;
            self.applied_current_manager = applied_current_manager;
            self.synapse_manager = synapse_manager;
            self.neuron_manager = neuron_manager;

            % Store the simulation information.
            self.tf = tf;
            self.dt = dt;
            
            % Compute and set the synaptic conductances.
            [ ~, ~, ~, self ] = self.compute_Gs( neuron_manager, synapse_manager, true, 'ignore', network_utilities );
            
        end
        
        
        %% Specific Get Functions.
        
        % Implement a function to construct the delta matrix from the stored delta scalars.
        function deltas = get_deltas( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the delta matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs	=   [#] Neuron IDs.
                
            Output(s):
                deltas      =   [V] Network Bifurcation Parameters.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            deltas = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                         % Iterate through each synapse...
                
                % Determine how to assign the delta value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                   % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the delta matrix associated with this neuron.
                    deltas( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).delta;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )            % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic reversal potential matrix from the stored synaptic reversal potential scalars.
        function dEs = get_dEs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the synaptic reversal potential matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                dEs     =   [V] Synaptic Reversal Potentials.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            dEs = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                                                                                                                          % Iterate through each synapse...
                
                % Determine how to assign the synaptic reversal potential value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                        	% If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron logical index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron logical index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic reversal potential matrix associated with this neuron.
                    dEs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).dEs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                    % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the maximum synaptic conductance matrix from the stored maximum synaptic conductance scalars.
        function gs = get_gs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the synaptic conductance matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs	=	[#] Neuron IDs.
            
            Output(s):
                gs          =   [S] Maximum Synaptic Conductances.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_synapses = length( synapse_IDs );
            
            % Preallocate the maximum synaptic conductance matrix.
            gs = zeros( num_neurons );
            
            % Retrieve the entries of the maximum synaptic conductance matrix.
            for k = 1:num_synapses                                                                                                                              % Iterate through each synapse...
                
                % Determine how to assign the maximum synaptic conductance value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                               % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the maximum synaptic conductance matrix associated with this neuron.
                    gs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).gs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                        % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic condcutance matrix from the stored synaptic conductance scalars.
        function Gs = get_Gs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieve the synaptic conductance matrix for the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                Gs      =   [S] Synaptic Conductances.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the synaptic conductance matrix.
            Gs = zeros( num_neurons );
            
            % Retrieve the entries of the synaptic conductance matrix.
            for k = 1:num_syanpses                                                                                                                              % Iterate through each synapse...
                
                % Determine how to assign the synaptic conductance value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                            % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic conductance matrix associated with this neuron.
                    Gs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).Gs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                     % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        %% Specific Set Functions.
        
        % Implement a function to set the deltas of each synapse based on the delta matrix.
        function [ synapses, synapse_manager, self ] = set_deltas( self, deltas, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the bifurcation parameter values of the neurons specified by neuron_IDs based on the entries of the given delta matrix.
            
            %{
            Input(s):
                deltas      =   [V] Bifurcation Parameter Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the delta of each of the synapses in this network to agree with the delta matrix.
            for k1 = 1:num_neurons                                                                                                  % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                              % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                                 % If the synapse ID is greater than zero...
                        
                        % Set the value of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, deltas( k1, k2 ), 'delta' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                                            % Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )       
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the synaptic reversal potentials of each synapse based on the synaptic reversal matrix.
        function [ synapses, synapse_manager, self ] = set_dEs( self, dEs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the synaptic reversal potentials of the neurons specified by neuron_IDs based on the entries of the given dEs matrix.
            
            %{
            Input(s):
                dEs         =   [V] Synaptic Reversal Potential Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the synaptic reversal potential of each of the synapses in this network to agree with the synaptic reversal potential matrix.
            for k1 = 1:num_neurons                                                                                                  % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                            	% Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                                 % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, dEs( k1, k2 ), 'dEs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                                            % Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID ) 
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the maximum synaptic conductances of each synapse based on the maximum synaptic conductance matrix.
        function [ synapses, synapse_manager, self ] = set_gs( self, gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the maximum synaptic conductance of the neurons specified by neuron_IDs based on the entries of the given g_syn_maxs matrix.
            
            %{
            Input(s):
                gs          =   [V] Maximum Synaptic Conductance Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
            for k1 = 1:num_neurons                                                                                                  % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                              % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                                 % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, gs( k1, k2 ), 'gs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                                            % Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the synaptic conductance of each synapse based on the synaptic conductance matrix.
        function [ synapses, synapse_manager, self ] = set_Gs( self, Gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the synaptic conductance of the neurons specified by neuron_IDs based on the entries of the given Gs matrix.
            
            %{
            Input(s):
                G_syns      =   [V] Synaptic Conductance Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the synaptic conductance matrix.
            for k1 = 1:num_neurons                                                                                                  % Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                              % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synapse index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID >= 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                                % If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, Gs( k1, k2 ), 'Gs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )                         % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                                            % Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        %% Compute Functions.
        
        % Implement a function to compute the synaptic conductance for each synapse.
        function [ Gs, synapses, synapse_manager, self ] = compute_Gs( self, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Define the default input arguments.
            if nargin < 6, network_utilities = self.network_utilities; end
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, synapse_manager = self.synapse_manager; end
            if nargin < 2, neuron_manager = self.neuron_manager; end
            
            % Retrieve the neuron properties.
            Us = neuron_manager.get_neuron_property( 'all', 'U', true, neuron_manager.neurons, undetected_option )';
            Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the maximum synaptic conductances.
            gs = self.get_gs( 'all', neuron_manager, synapse_manager );
            
            % Compute the synaptic conductance.
            Gs = network_utilities.compute_Gs( Us, Rs, gs );
            
            % Set the synaptic conductances (if appropriate).
            [ synapses, synapse_manager, self ] = self.set_Gs( Gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
        function [ gs, synapses, synapse_manager, self ] = compute_cpg_gs( self, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default neuron IDs.
            if nargin < 7, network_utilities = self.network_utilities; end
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron membrane conductances.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron membrane voltage ranges.
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the sodium channel conductances.
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron sodium channel activation parameters.
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option )';
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option )';
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron sodium channel deactivation parameters.
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option )';
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option )';
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the sodium channel reversal potentials.
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the tonic currents.
            Itonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synapse properties.
            deltas = self.get_deltas( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
            gs = network_utilities.compute_cpg_gs_matrix( deltas, Gms, Rs, dEs, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Itonics, neuron_manager.neuron_utilities );
            
            % Set the synaptic conductances (if appropriate).
            [ synapses, synapse_manager, self ] = self.set_gs( gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a transmission subnetwork with the specified parameters.
        function [ gs12, synapses, synapse_manager, self ] = compute_transmission_gs( self, neuron_IDs, synapse_ID, Ia2, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_transmission_DEFAULT; end
            if nargin < 4, Ia2 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_ID = synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Retrieve the neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve the synaptic reversal potential.
            dEs12 = synapse_manager.get_synapse_property( synapse_ID, 'dEs', true, synapse_manager.synapses, undetected_option );
            
            % Compute the required maximum synaptic conductances required to design a transmission subnetwork.
            gs12 = network_utilities.compute_transmission_gs( Gm2, R1, dEs12, Ia2, k );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_ID, gs12, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a modulation subnetwork with the specified parameters.
        function [ gs12, synapses, synapse_manager, self ] = compute_modulation_gs( self, neuron_IDs, synapse_ID, Ia2, c, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, c = self.c_modulation_DEFAULT; end
            if nargin < 4, Ia2 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_ID = synapse_manager.validate_synapse_IDs( synapse_ID );
            
            % Retrieve the neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve the synaptic reversal potential.
            dEs12 = synapse_manager.get_synapse_property( synapse_ID, 'dEs', true, synapse_manager.synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for a modulation subnetwork.
            gs12 = network_utilities.compute_modulation_gs( Gm2, R1, R2, dEs12, Ia2, c );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_ID, gs12, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design an addition subnetwork with the specified parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_addition_gs( self, neuron_IDs, synapse_IDs, Ia3, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ gs13, gs23 ] = network_utilities.compute_addition_gs( Gm3, R1, R2, dEs13, dEs23, Ia3, k );
            
            % Store the maximum synaptic conductances.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a relative addition subnetwork with the specified parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_relative_addition_gs( self, neuron_IDs, synapse_IDs, Ia3, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_addition_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ gs13, gs23 ] = network_utilities.compute_relative_addition_gsynmax( Gm3, R1, R2, dEs13, dEs23, Ia3, k );
            
            % Store the maximum synaptic conductances.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a subtraction subnetwork with the specified parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_subtraction_gs( self, neuron_IDs, synapse_IDs, Ia3, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_subtraction_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ gs13, gs23 ] = network_utilities.compute_subtraction_gs( Gm3, R1, dEs13, dEs23, Ia3, k );
            
            % Store the maximum synaptic conductances.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a multiplication subnetwork with the specifed parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_multiplication_gs( self, neuron_IDs, synapse_IDs, Ia3, Ia4, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, synapse_manager = self.synapse_manager; end
            if nargin < 7, neuron_manager = self.neuron_manager; end
            if nargin < 6, k = self.c_multiplication_DEFAULT; end
            if nargin < 5, Ia4 = self.Ia_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );            
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the membrane conductances.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            Gm4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the maximum membrane voltages.
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs14 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs34 = synapse_manager.get_synapse_property( synapse_IDs( 3 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this multiplication subnetwork.
            [ gs14, gs23, gs34 ] = network_utilities.compute_multiplication_gs( Gm3, Gm4, R1, R2, R3, R4, dEs14, dEs23, dEs34, Ia3, Ia4, k );
            
            % Store the maximum synaptic conductances.
            gs = [ gs14, gs23, gs34 ];
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design an inversion subnetwork with the specified parameters.
        function [ gs12, synapses, synapse_manager, self ] = compute_inversion_gs( self, neuron_IDs, Ia2, epsilon, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_inversion_DEFAULT; end
            if nargin < 4, epsilon = self.epsilon_inversion_DEFAULT; end
            if nargin < 3, Ia2 = self.Ia_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Compute the maximum synaptic conductances for this inversion subnetwork.
            gs12 = network_utilities.compute_inversion_gs( Gm2, R1, Ia2, k, epsilon );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_ID, gs12, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the input offset for a relative inversion subnetwork.
        function epsilon = compute_relative_inversion_epsilon( self, c, network_utilities )
            
            % Define the default input arguments.
            if nargin < 3, network_utilities = self.network_utilities; end
            if nargin < 2, c = self.c_inversion_DEFAULT; end                    % [-] Inversion Subnetwork Gain
            
            % Compute the input offset.
            epsilon = network_utilities.compute_relative_inversion_epsilon( c );
            
        end
        
        
        % Implement a function to compute the output offset for a relative inversion subnetwork.
        function delta = compute_relative_inversion_delta( self, c, network_utilities )
            
            % Define the default input arguments.
            if nargin < 3, network_utilities = self.network_utilities; end
            if nargin < 2, c = self.c_inversion_DEFAULT; end                    % [-] Inversion Subnetwork Gain
            
            % Compute the output offset.
            delta = network_utilities.compute_relative_inversion_delta( c );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a division subnetwork with the specified parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_division_gs( self, neuron_IDs, synapse_IDs, Ia3, k, c, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, synapse_manager = self.synapse_manager; end
            if nargin < 7, neuron_manager = self.neuron_manager; end
            if nargin < 6, c = [  ]; end
            if nargin < 5, k = self.c_division_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option )';
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this division subnetwork.
            [ gs13, gs23 ] = network_utilities.compute_division_gs( Gm3, R1, R2, R3, dEs13, dEs23, Ia3, k, c );
            
            % Store the maximum synaptic conductances.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances required to design a derivation subnetwork with the specified parameters.
        function [ gs, synapses, synapse_manager, self ] = compute_derivation_gs( self, neuron_IDs, synapse_IDs, Ia3, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k = self.c_derivation_DEFAULT; end
            if nargin < 4, Ia3 = self.Ia_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option )';
            R1 = neuron_manager.get_neuron_property( neuron_IDs( 1 ), 'R', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synaptic reversal potentials associated with these synapses.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option )';
            
            % Compute the maximum synaptic conductances for this addition subnetwork.
            [ gs13, gs23 ] = network_utilities.compute_derivation_gs( Gm3, R1, dEs13, dEs23, Ia3, k );
            
            % Store the maximum synaptic conductances.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function [ gs, synapses, synapse_manager, self ] = compute_integration_gs( self, neuron_IDs, synapse_IDs, ki_range, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 9, network_utilities = self.network_utilities; end
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, synapse_manager = self.synapse_mangaer; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );

            % Retrieve the membrane conductances and membrane capacitances of these neurons.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Cms = neuron_manager.get_neuron_property( neuron_IDs, 'Cm', true, neuron_manager.neurons, undetected_option );
            
            % Ensure that the integration neurons are symmetrical.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Cms( 1 ) == Cms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance capacitances.' );
            
            % Compute the integration subnetwork maximum synaptic conductances.
            gs = network_utilities.compute_integration_gs( Gms( 1 ), Cms( 1 ), ki_range );
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, gs*ones( 1, 2 ), 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function [ dEs, synapses, synapse_manager, self ] = compute_integration_dEs( self, neuron_IDs, synapse_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the membrane conductances and voltage domains.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve the maximum synaptic conductances
            gs = synapse_manager.get_synapse_property( synapse_IDs, 'gs', true, synapse_manager.synapses, undetected_option )';
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            assert( gs( 1 ) == gs( 2 ), 'Integration subnetwork neurons must have symmetrical maximum synaptic conductances.' );
            
            % Compute the synaptic reversal potentials for an integration subnetwork.
            dEs = network_utilities.compute_integration_dEs( Gms( 1 ), Rs( 1 ), gs( 1 ) );
            
            % Set the synaptic reversal potentials of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, dEs*ones( 1, 2 ), 'dEs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for an integration subnetwork.
        function [ gs, synapses, synapse_manager, self ] = compute_vbi_gs( self, neuron_IDs, synapse_IDs, T, n, ki_mean, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, synapse_manager = self.synapse_manager; end
            if nargin < 7, neuron_manager = self.neuron_manager; end
            if nargin < 6, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the relevant neuron data.
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve the relevant synpase data.
            dEs13 = synapse_manager.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapse_manager.synapses, undetected_option );
            dEs23 = synapse_manager.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapse_manager.synapses, undetected_option );
            
            % Compute activation period of the associated multistate cpg subnetwork.
            Ta = network_utilities.compute_activation_period( T, n );
            
            % Compute the voltage based integration subnetwork intermediate synaptic conductances.
            Is13 = network_utilities.compute_vbi_Is( R3, Ta, ki_mean, false );
            Is23 = network_utilities.compute_vbi_Is( R3, Ta, ki_mean, true );
            
            % Compute the voltage based integration subnetwork maximum synaptic conductances.
            gs13 = network_utilities.compute_vbi_gs( R3, dEs13, Is13 );
            gs23 = network_utilities.compute_vbi_gs( R3, dEs23, Is23 );
            
            % Store the voltage based integration subnetwork maximum synaptic conductances in an array.
            gs = [ gs13, gs23 ];
            
            % Set the maximum synaptic conductances of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs( 1:2 ), gs, 'gs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        

        %% Network Deletion Functions.
        
        % Implement a function to delete network components.
        function [ objects, object_managers, self ] = delete( self, object_types, object_ids, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            %{
            Input(s):
                object_types    =   [cell, str] Type of Network Object to Delete.  Must be one of: Neurons, Synapses, or Currents.
                object_ids      =   [cell, #] IDs Associated with Objects that Should be Deleted.
            
            Output(s):
                self            =   [class] Updated Network Object.
            %}
            
            % Define default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            
            % Retrieve the number of different object types to delete.
            num_types = length( object_types );
            
            % Preallocate cells to store the updated objects and object managers.
            objects = cell( 1, num_types );
            object_managers = cell( 1, num_types );
            
            % Delete each of the specified objects for each of the given types.
            for k = 1:num_types                                                                                                 % Iterate through each of the object types...
                
                % Determine which type of objects should be deleted.
                if strcmpi( object_types{ k }, 'neuron' ) || strcmpi( object_types{ k }, 'neurons' )                            % If we want to delete neurons...
                    
                    % Delete the specified neurons.
                    [ objects{ k }, object_managers{ k } ] = neuron_manager.delete_neurons( object_ids{ k }, neuron_manager.neurons, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.neuron_manager = object_managers{ k }; end
                    
                elseif strcmpi( object_types{ k }, 'synapse' ) || strcmpi( object_types{ k }, 'synapses' )                      % If we want to delete synapses...
                    
                    % Delete the specified synapses.
                    [ objects{ k }, object_managers{ k } ] = synapse_manager.delete_synapses( object_ids{ k }, synapse_manager.synapses, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.synapse_manager = object_managers{ k }; end
                    
                elseif strcmpi( object_types{ k }, 'current' ) || strcmpi( object_types{ k }, 'currents' )                      % If we want to delete applied currents...
                    
                    % Delete the specified applied currents.                    
                    [ objects{ k }, object_managers{ k } ] = applied_current_manager.delete_applied_currents( object_ids{ k }, applied_current_manager.applied_currents, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.applied_current_manager = object_managers{ k }; end
                    
                else                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid network object type %s selected for deletion.', object_types{ k } )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to delete all of the components in a network.
        function [ neuron_manager, synapse_manager, applied_current_manager, self ] = delete_all( self, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, synapse_manager = self.synapse_manager; end
            if nargin < 2, neuron_manager = self.neuron_manager; end
            
            % Delete all of the neurons.
            [ ~, neuron_manager ] = neuron_manager.delete_neurons( 'all', neuron_manager.neurons, true, undetected_option );
            
            % Delete all of the synapses.
            [ ~, synapse_manager ] = synapse_manager.delete_synapses( 'all', synapse_manager.synapses, true, undetected_option );
            
            % Delete all of the applied currents.
            [ ~, applied_current_manager ] = applied_current_manager.delete_applied_currents( 'all', applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag                                                                         % If we want to update the network object...
               
                % Update the network's neuron manager.
                self.neuron_manager = neuron_manager;
                
                % Update the network's synapse manager.
                self.synapse_manager = synapse_manager;
                
                % Update the applied current manager.
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        %% Subnetwork Applied Current Design Functions.
        
        % Implement a function to design the applied currents for a multistate cpg subnetwork.
        function [ ts, Ias, applied_currents, applied_current_manager, self ] = design_mcpg_applied_currents( self, neuron_IDs, dt, tf, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, process_option = self.process_option_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 5, applied_current_manager = self.applied_current_manager; end
            if nargin < 4, tf = self.tf; end
            if nargin < 3, dt = self.dt; end
            
            % Design the applied currents for a multistate cpg subnetwork.            
            [ ts, Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_mcpg_applied_current( neuron_IDs, dt, tf, applied_current_manager.applied_currents, filter_disabled_flag, true, process_option, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a driven multistate cpg subnetwork.
        function [ ts, Ias, applied_currents, applied_current_manager, self ] = design_dmcpg_applied_currents( self, neuron_IDs, dt, tf, neuron_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, process_option = self.process_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, tf = self.tf; end
            if nargin < 3, dt = self.dt; end
            
            % Design the multistate cpg applied currents.            
            [ ts_mcpg, Ias_mcpg, applied_currents, applied_current_manager, ~ ] = self.design_mcpg_applied_currents( neuron_IDs( 1:( end - 1 ) ), dt, tf, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option );
            
            % Retrieve the relevant neuron properties of the drive neuron.
            Gm = neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R = neuron_manager.get_neuron_property( neuron_IDs( end ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Design the driven multistate cpg applied current.            
            [ ts_d, Ias_d, applied_currents, applied_current_manager ] = applied_current_manager.design_dmcpg_applied_current( neuron_IDs( end ), Gm, R, dt, tf, applied_currents, filter_disabled_flag, true, process_option, undetected_option );
            
            % Store the applied current time and magnitude vectors as arrays.
            ts = [ ts_mcpg, ts_d ];
            Ias = [ Ias_mcpg, Ias_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
         %{
%         % Implement a function to design the applied currents for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end
%             if nargin < 5, neuron_manager = self.neuron_manager; end
%             if nargin < 4, tf = self.tf; end
%             if nargin < 3, dt = self.dt; end
%             
%             % Retrieve the number of cpg neurons.
%             num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Design the applied currents for the driven multistate cpg subnetworks.
%             self = self.design_dmcpg_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             self = self.design_dmcpg_applied_currents( neuron_IDs_cell{ 2 }, dt, tf, neuron_manager, applied_current_manager );
% 
%             % Design the applied currents for the modulated split subtraction voltage based integration subnetworks.
%             for k = 1:num_cpg_neurons                               % Iterate through each of the cpg neurons...
%                 
%                 % Design the applied currents for this modulated split subtraction voltage based integration subnetwork
%                 self = self.design_mssvbi_applied_currents( neuron_IDs_cell{ k + 2 }, neuron_manager, applied_current_manager );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for a driven multistate cpg double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end
%             if nargin < 5, neuron_manager = self.neuron_manager; end
%             if nargin < 4, tf = self.tf; end
%             if nargin < 3, dt = self.dt; end
%             
%             % Design the applied currents for the driven multistate cpg split lead lag subnetwork.
%             self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             
%             % Design the applied currents for a double centering subnetwork.
%             self = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents that connect the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
%         function self = design_dmcpgdcll2cds_applied_current( self, neuron_ID, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 4, applied_current_manager = self.applied_current_manager; end
%             if nargin < 3, neuron_manager = self.neuron_manager; end
%             
%             % Retrieve the necessary neuron properties.
%             Gm = neuron_manager.get_neuron_property( neuron_ID, 'Gm', true, neuron_manager.neurons, undetected_option );
%             R = neuron_manager.get_neuron_property( neuron_ID, 'R', true, neuron_manager.neurons, undetected_option );
%             
%             % Design the centering subnetwork applied current.
%             applied_current_manager = applied_current_manager.design_dmcpgdcll2cds_applied_current( neuron_ID, Gm, R );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end
%             if nargin < 5, neuron_manager = self.neuron_manager; end
%             if nargin < 4, tf = self.tf; end
%             if nargin < 3, dt = self.dt; end
%             
%             % Design the applied currents for the driven multistate cpg double centered lead lag subnetwork.
%             self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             
%             % Design the applied currents for the centered double subtraction subnetwork.
%             self = self.design_cds_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager );
%             
%             % Design the desired lead lag applied current.
%             self = self.design_dmcpgdcll2cds_applied_current( neuron_IDs_cell{ 3 }, neuron_manager, applied_current_manager );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for a closed loop proportional controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_applied_currents( self, neuron_IDs_cell, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 4, applied_current_manager = self.applied_current_manager; end
%             if nargin < 3, neuron_manager = self.neuron_manager; end
%             
%             % Design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager );
%             
%         end
        %}
        
        % Implement a function to design the applied currents for a addition subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_addition_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, applied_current_manager = self.applied_current_manager; end
            
            % Design the absolute addition applied currents.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_addition_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a subtraction subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_subtraction_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, applied_current_manager = self.applied_current_manager; end
            
            % Design the absolute subtraction applied currents.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_subtraction_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a centering subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_centering_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the necessary neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Design the centering subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_centering_applied_current( neuron_IDs, Gm2, R2, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a double centering subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_double_centering_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the double centering applied currents (in the same way as the single centering applied currents).            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the applied currents for a centered double subtraction subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_cds_applied_currents( self, neuron_IDs_cell, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the applied currents for a double centering subnetwork.
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the applied current for an inversion subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_inversion_applied_current( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the necessary neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm2, R2 };
            
            % Design the inversion subnetwork applied current.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_inversion_applied_current( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option ); 
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied current for a division subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_division_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, applied_current_manager = self.applied_current_manager; end
            
            % Design the absolute division applied currents.                        
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_division_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a multiplication subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_multiplication_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the necessary neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm3, R3 };
            
            % Design the multiplication subnetwork applied current.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_multiplication_applied_currents( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for an integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_integration_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option );
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms( 1 ), Rs( 1 ) };
            
            % Design the integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_integration_applied_currents( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_vbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms( 1 ), Rs( 1 ) };
            
            % Design the voltage based integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_vbi_applied_currents( neuron_IDs( 3:4 ), parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a split voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_svbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Retrieve the relevant membrane conductance.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gm4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gm9 = neuron_manager.get_neuron_property( neuron_IDs( 9 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gms = [ Gm3, Gm4, Gm9 ];
            
            % Retrieve the relevant voltage domains.
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            R4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R', true, neuron_manager.neurons, undetected_option );
            Rs = [ R3, R4 ];
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gm3 == Gm4, 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( R3 == R4, 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms, Rs };
            
            % Design the voltage based integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_svbi_applied_currents( [ neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 9 ) ], parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a modulated split voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_msvbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_svbi_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the applied currents for a modulated split difference voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_mssvbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, applied_current_manager = self.applied_current_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the modulated split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_msvbi_applied_currents( neuron_IDs( 5:end ), neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option );
            
        end
        
        
        %% Subnetwork Neuron Design Functions.
        
        % Implement a function to design the neurons for a multistate cpg subnetwork.
        function [ Gnas, neurons, neuron_manager, self ] = design_mcpg_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the multistate cpg subnetwork neurons.            
            [ Gnas, neurons, neuron_manager ] = neuron_manager.design_mcpg_neurons( neuron_IDs, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg subnetwork.
        function [ Gnas, neurons, neuron_manager, self ] = design_dmcpg_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the multistate cpg neurons.
            [ Gnas_mcpg, ~, neuron_manager, ~ ] = self.design_mcpg_neurons( neuron_IDs( 1:( end - 1 ) ), neuron_manager, set_flag, undetected_option );
            
            % Design the drive neuron.            
            [ Gnas_d, neurons, neuron_manager ] = neuron_manager.design_dmcpg_neurons( neuron_IDs( end ), neuron_manager.neurons, true, undetected_option );
            
            % Concatenate the sodium channel conductances.
            Gnas = [ Gnas_mcpg, Gnas_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
         %{
%         % Implement a function to design the neurons for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Retrieve the number of cpg neurons.
%             num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Design the driven multistate CPG neurons.
%             self = self.design_dmcpg_neurons( neuron_IDs_cell{ 1 }, neuron_manager );
%             self = self.design_dmcpg_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%             % Design the modulated split subtraction voltage based integration subnetwork neurons.
%             for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
%                 
%                 % Design the neurons of this modulated split subtraction voltage based integration subnetworks.
%                 self = self.design_mssvbi_neurons( neuron_IDs_cell{ k + 2 }, ki_mean, neuron_manager );
%                 
%             end
%             
%             % Design the split lead lag subnetwork neurons.
%             self = self.design_addition_neurons( neuron_IDs_cell{ end }( 1:2 ), neuron_manager );
%             self = self.design_slow_transmission_neurons( neuron_IDs_cell{ end }( 3:4 ), num_cpg_neurons, T, r, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for a driven multistate double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for the driven multistate split lead lag subnetwork.
%             self = self.design_dmcpg_sll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r, neuron_manager );
%             
%             % Design the neurons for the double centering subnetwork.
%             self = self.design_double_centering_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for the driven multiple cpg double centered lead lag subnetwork.
%             self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r, neuron_manager );
%             
%             % Design the neurons for the centered double subtraction subnetwork.
%             self = self.design_cds_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%             % Design the neurons for the transmission subnetwork neurons.
%             self = self.design_transmission_neurons( neuron_IDs_cell{ 3 }, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%         end
        %}
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_transmission_neurons( self, neuron_IDs, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the transmission subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_transmission_neurons( neuron_IDs, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_slow_transmission_neurons( self, neuron_IDs, num_cpg_neurons, T, r, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            
            % Design the slow transmission subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_slow_transmission_neurons( neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulation subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_modulation_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the modulation subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_modulation_neurons( neuron_IDs, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for an addition subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_addition_neurons( self, neuron_IDs, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the addition subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager ] = neuron_manager.design_addition_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a subtraction subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_subtraction_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the subtraction subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager ] = neuron_manager.design_subtraction_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a double subtraction subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_double_subtraction_neurons( self, neuron_IDs, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the double subtraction subnetwork neurons.
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_double_subtraction_neurons( neuron_IDs, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a centering subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_centering_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the addition subnetwork neurons.            
            [ Gnas_addition, Gms_addition, Cms_addition, Rs_addition, ~, neuron_manager, network ] = self.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ], neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the subtraction subnetwork neurons.            
            [ Gnas_subtraction, Gms_subtraction, Cms_subtraction, Rs_subtraction, neurons, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_addition, Gnas_subtraction ];
            Gms = [ Gms_addition, Gms_subtraction ];
            Cms = [ Cms_addition, Cms_subtraction ];
            Rs = [ Rs_addition, Rs_subtraction ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the neurons for a double centering subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_double_centering_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the addition subnetwork neurons.
            [ Gnas_addition1, Gms_addition1, Cms_addition1, Rs_addition1, ~, neuron_manager, network ] = self.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ], neuron_manager, encoding_scheme, true, undetected_option );
            [ Gnas_addition2, Gms_addition2, Cms_addition2, Rs_addition2, ~, neuron_manager, network ] = network.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ], neuron_manager, encoding_scheme, true, undetected_option );

            % Design the subtraction subnetwork neurons.
            [ Gnas_subtraction1, Gms_subtraction1, Cms_subtraction1, Rs_subtraction1, ~, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 6 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );
            [ Gnas_subtraction2, Gms_subtraction2, Cms_subtraction2, Rs_subtraction2, neurons, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 5 ), neuron_IDs( 1 ), neuron_IDs( 7 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );

            % Concatenate the neuron properties.
            Gnas = [ Gnas_addition1, Gnas_addition2, Gnas_subtraction1, Gnas_subtraction2 ];
            Gms = [ Gms_addition1, Gms_addition2, Gms_subtraction1, Gms_subtraction2 ];
            Cms = [ Cms_addition1, Cms_addition2, Cms_subtraction1, Cms_subtraction2 ];
            Rs = [ Rs_addition1, Rs_addition2, Rs_subtraction1, Rs_subtraction2 ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the neurons for a centered double subtraction subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_cds_neurons( self, neuron_IDs_cell, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the double subtraction subnetwork neurons.            
            [ Gnas_ds, Cms_ds, ~, neuron_manager, network ] = self.design_double_subtraction_neurons( neuron_IDs_cell{ 1 }, neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the double centering subnetwork neurons.            
            [ Gnas_dc, Gms, Cms_dc, Rs, neurons, neuron_manager, network ] = network.design_double_centering_neurons( neuron_IDs_cell{ 2 }, neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_ds, Gnas_dc ];
            Cms = [ Cms_ds, Cms_dc ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the neurons for a multiplication subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_multiplication_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end

            % Design the multiplication subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager ] = neuron_manager.design_multiplication_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for an inversion subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_inversion_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end                                       % { k_inversion, epsilon_inversion }.
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the inversion subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager ] = neuron_manager.design_inversion_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a division subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_division_neurons( self, neuron_IDs, neuron_manager, parameters, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, parameters = {  }; end                                           % { c, alpha, epsilon }
            if nargin < 3, neuron_manager = self.neuron_manager; end
            
            % Design the division subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager ] = neuron_manager.design_division_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a derivation subnetwork.
        function [ Gnas, Gms, Cms, neurons, neuron_manager, self ] = design_derivation_neurons( self, neuron_IDs, k, w, safety_factor, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            
            % Design the derivation subnetwork neurons.            
            [ Gnas, Gms, Cms, neurons, neuron_manager ] = neuron_manager.design_derivation_neurons( neuron_IDs, k, w, safety_factor, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for an integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_integration_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_integration_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_vbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_vbi_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a split voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_svbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_svbi_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulated split voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_msvbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the split voltage based integration neurons.            
            [ Gnas_svbi, Cms_svbi, ~, neuron_manager ] = neuron_manager.design_svbi_neurons( neuron_IDs( 1:9 ), ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Design the modulation neurons.            
            [ Gnas_mod, Cms_mod, neurons, neuron_manager ] = neuron_manager.design_modulation_neurons( neuron_IDs( 10:12 ), neuron_manager.neurons, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_svbi, Gnas_mod ];
            Cms = [ Cms_svbi, Cms_mod ];
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulated split difference voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_mssvbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the double subtraction neurons.            
            [ Gnas_ds, Cms_ds, ~, neuron_manager, network ] = self.design_double_subtraction_neurons( neuron_IDs( 1:4 ), neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the modulated split voltage based integration neurons.            
            [ Gnas_msvbi, Cms_msvbi, neurons, neuron_manager, network ] = network.design_msvbi_neurons( neuron_IDs( 5:end ), ki_mean, neuron_manager, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_ds, Gnas_msvbi ];
            Cms = [ Cms_ds, Cms_msvbi ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        
        %% Subnetwork Synapse Design Functions.
        
        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function [ gs, synapses, synapse_manager, self ] = design_mcpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 9, network_utilities = self.network_utilities; end
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            
            % Design the multistate cpg subnetwork synapses.
            [ ~, synapse_manager ] = synapse_manager.design_mcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, synapse_manager.synapses, true, undetected_option, synapse_manager.array_utilities );
            
            % Compute and set the maximum synaptic conductances required to achieve these delta values.            
            [ gs, synapses, synapse_manager, self ] = self.compute_cpg_gs( neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
                        
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_dmcpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            
            % Design the synapses of the multistate cpg subnetwork.            
            [ gs_mcpg, synapses, synapse_manager, ~ ] = self.design_mcpg_synapses( neuron_IDs( 1:( end - 1 ) ), delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Design the driven multistate cpg subnetwork synapses.            
            [ dEs, gs_d, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_dmcpg_synapses( neuron_IDs, delta_oscillatory, Id_max, synapses, true, undetected_option );
            
            % Concatenate the neuron properties.
            gs = [ gs_mcpg, gs_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        %{
%         % Implement a function to design the synapses for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities )
%             
%             % Set the default input arguments.
%             if nargin < 1, network_utilities = self.network_utilities; end
%             if nargin < 14, applied_current_manager = self.applied_current_manager; end
%             if nargin < 13, synapse_manager = self.synapse_manager; end
%             if nargin < 12, neuron_manager = self.neuron_manager; end
%             if nargin < 11, c_mod = self.c_modulation_DEFAULT; end
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the synapses of the driven multistate cpg subnetworks.
%             self = self.design_dmcpg_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities );
%             self = self.design_dmcpg_synapses( neuron_IDs_cell{ 2 }, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities );
%             
%             % Compute the number of cpg neurons.
%             num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Compute the number of transmission pathways to design.
%             num_transmission_synapses = 4*num_cpg_neurons + 2;
%             
%             % Preallocate an array to store the from and to neuron IDs.
%             [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_transmission_synapses ) );
%             
%             % Design the synapses of the modulated split subtraction voltage based integration subnetworks.
%             for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
%                 
%                 % Design the synapses of this modulated split subtraction voltage based integration subnetwork.
%                 self = self.design_mod_split_sub_vb_integration_synapses( neuron_IDs_cell{ k + 2 }, T, num_cpg_neurons, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
%                 
%                 % Compute the index variable.
%                 index = 4*(k - 1) + 1;
%                 
%                 % Store these pairs of from and to neuron IDs.
%                 from_neuron_IDs( index ) = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_IDs( index ) = neuron_IDs_cell{ end }( 1 );
%                 from_neuron_IDs( index + 1 ) = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_IDs( index + 1 ) = neuron_IDs_cell{ end }( 2 );
%                 from_neuron_IDs( index + 2 ) = neuron_IDs_cell{ 1 }( k ); to_neuron_IDs( index + 2 ) = neuron_IDs_cell{ k + 2 }( 1 );
%                 from_neuron_IDs( index + 3 ) = neuron_IDs_cell{ 2 }( k ); to_neuron_IDs( index + 3 ) = neuron_IDs_cell{ k + 2 }( 2 );
%                 
%             end
%             
%             % Define the final pair of from and to neuron IDs.
%             from_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 1 ); to_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 3 );
%             from_neuron_IDs( end ) = neuron_IDs_cell{ end }( 2 ); to_neuron_IDs( end ) = neuron_IDs_cell{ end }( 4 );
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the synapses for a driven multistate cpg double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod )
%             
%             % Set the default input arguments.
%             if nargin < 13, c_mod = self.c_modulation_DEFAULT; end
%             if nargin < 12, k_sub3 = self.c_addition_DEFAULT; end
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the driven multistate cpg split lead lag synapses.
%             self = self.design_dmcpg_sll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%             
%             % Design the double centering subnetwork synapses.
%             self = self.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_add, k_sub3, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ end }( end - 1 ) neuron_IDs_cell{ 1 }{ end }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 0.5, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod )
%             
%             % Set the default input arguments.
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the driven multistate cpg double centered lead lag subnetwork synapses.
%             self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add1, c_mod );
%             
%             % Design the centered double subtraction subnetwork synapses.
%             self = self.design_cds_synapses( neuron_IDs_cell{ 2 }, k_sub4, k_sub5, k_add2 );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 2 }( end - 1 ) neuron_IDs_cell{ 3 } ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 1 }( 1 ) neuron_IDs_cell{ 2 }{ 1 }( 2 ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%             
%         end
%         
%         
%         % Implement a function to design the synapses for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain )
%             
%             % Set the default input arguments.
%             if nargin < 17, kp_gain = self.kp_gain_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 2 }( end - 1 ), neuron_IDs_cell{ 2 }{ 2 }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 1 }{ 2 }( end ), neuron_IDs_cell{ 1 }{ 1 }{ 1 }( end ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ), to_neuron_IDs( k ) ], kp_gain, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
        %}
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function [ dEs12, gs12, synapse_ID, synapses, synapse_manager, self ] = design_transmission_synapse( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, applied_current_compensation_flag, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, process_option = self.process_option_DEFAULT; end
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 8, applied_current_compensation_flag = true; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, k = self.c_transmission_DEFAULT; end
            
            % Design the transmission subnetwork neurons.            
            [ dEs12, synapse_ID, ~, synapse_manager ] = synapse_manager.design_transmission_synapse( neuron_IDs, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to consider the applied current.
            if applied_current_compensation_flag                       % If we want to compensate for the applied current...
                
                % Get the applied current associated with the final neuron.                
                [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 2 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
                
                % Determine whether to throw a warning.
                if ~all( Ias == Ias( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
                
                % Set the applied current to be the average current.
                Ia = mean( Ias );
                
            else                                                    % Otherwise...
                
                % Set the applied current magnitude to zero.
                Ia = 0;
                
            end
            
            % Compute and set the maximum synaptic conductance for a transmission subnetwork.            
            [ gs12, synapses, synapse_manager, self ] = self.compute_transmission_gs( neuron_IDs, synapse_ID, Ia, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
                        
        end
        
        
        % Implement a function to design the synapses for a modulation subnetwork.
        function [ dEs12, gs12, synapse_ID, synapses, synapse_manager, self ] = design_modulation_synapses( self, neuron_IDs, c, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilites; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, process_option = self.process_option_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, c = self.c_modulation_DEFAULT; end
            
            % Design the modulation synapses.            
            [ dEs12, synapse_ID, ~, synapse_manager ] = synapse_manager.design_modulation_synapse( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 2 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic conductance for a transmission subnetwork.
            [ gs12, synapses, synapse_manager, self ] = self.compute_modulation_gs( neuron_IDs, synapse_ID, Ia, c, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
                        
        end
        
        
        % Implement a function to design the synapses for an addition subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_addition_synapses( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, process_option = self.process_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, k = self.c_addition_DEFAULT; end
            
            % Design the addition subnetwork synapses.            
            [ dEs, synapse_IDs, ~, synapse_manager ] = synapse_manager.design_addition_synapses( neuron_IDs, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.            
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic conductances necessary to design this addition subnetwork.                        
            [ gs, synapses, synapse_manager, self ] = self.compute_addition_gs( neuron_IDs, synapse_IDs, Ia, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapses for a subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_subtraction_synapses( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, process_option = self.process_option; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % Design the subtraction subnetwork synapses.            
            [ dEs, synapse_IDs, ~, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );

            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.                        
            [ gs, synapses, synapse_manager, self ] = self.compute_subtraction_gs( neuron_IDs, synapse_IDs, Ia, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapses for a double subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_double_subtraction_synapses( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, process_option = self.process_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % Retrieve the neuron IDs associated with each subtraction subnetwork.
            neuron_IDs1 = neuron_IDs( 1:3 );
            neuron_IDs2 = [ neuron_IDs( 2 ), neuron_IDs( 1 ), neuron_IDs( 4 ) ];
            
            % Design the subtraction subnetwork synapses.
            [ dEs31, synapse_IDs1, ~, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs1, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            [ dEs32, synapse_IDs2, ~, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs2, encoding_scheme, synapse_manager.synapses, true, undetected_option );

            % Get the applied current associated with the final neuron.
            [ ~, Ias1 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            [ ~, Ias2 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 4 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );

            % Determine whether to throw a warning.
            if ~all( Ias1 == Ias1( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            if ~all( Ias2 == Ias2( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia1 = mean( Ias1 );
            Ia2 = mean( Ias2 );
            
            % Create an instance of the network.
            network = self;
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            [ gs31, ~, synapse_manager, network ] = network.compute_subtraction_gs( neuron_IDs1, synapse_IDs1, Ia1, k, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            [ gs32, synapses, synapse_manager, network ] = network.compute_subtraction_gs( neuron_IDs2, synapse_IDs2, Ia2, k, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Store the synapse properties.
            synapse_IDs = [ synapse_IDs1, synapse_IDs2 ];
            gs = [ gs31, gs32 ];
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a centering subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_centering_synapses( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, process_option = self.process_option_DEFAULT; end
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 8, applied_current_manager = self.applied_current_manager; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end
            
            % Define the addition and subtraction neuron IDs.
            neuron_IDs_addition = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ];
            neuron_IDs_subtraction = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            
            % Create an instance of the network object.
            network = self;
            
            % Design the addition subnetwork synapses.            
            [ dEs_addition, gs_addition, synapse_IDs_addition, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                        
            % Design the subtraction subnetwork synapses.            
            [ dEs_subtraction, gs_subtraction, synapse_IDs_subtraction, synapses, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                        
            % Concatenate the synapse properties.
            synapse_IDs = [ synapse_IDs_addition, synapse_IDs_subtraction ];
            dEs = [ dEs_addition, dEs_subtraction ];
            gs = [ gs_addition, gs_subtraction ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a double centering subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_double_centering_synapses( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, process_option = self.process_option_DEFAULT; end
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 8, applied_current_manager = self.applied_current_manager; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end
            
            % Define the addition and subtraction neuron IDs.
            neuron_IDs_addition1 = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ];
            neuron_IDs_addition2 = [ neuron_IDs( 2 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            neuron_IDs_subtraction1 = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 6 ) ];
            neuron_IDs_subtraction2 = [ neuron_IDs( 5 ), neuron_IDs( 1 ), neuron_IDs( 7 ) ];

            % Create an instance of the network object.
            network = self;
            
            % Design the addition subnetwork neurons.
            [ dEs_addition1, gs_addition1, synapse_IDs_addition1, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition1, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_addition2, gs_addition2, synapse_IDs_addition2, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Design the subtraction subnetwork neurons.
            [ dEs_subtraction1, gs_subtraction1, synapse_IDs_subtraction1, ~, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction1, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_subtraction2, gs_subtraction2, synapse_IDs_subtraction2, synapses, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction2, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            synapse_IDs = [ synapse_IDs_addition1, synapse_IDs_addition2, synapse_IDs_subtraction1, synapse_IDs_subtraction2 ];
            dEs = [ dEs_addition1, dEs_addition2, dEs_subtraction1, dEs_subtraction2 ];
            gs = [ gs_addition1, gs_addition2, gs_subtraction1, gs_subtraction2 ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a centered double subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_cds_synapses( self, neuron_IDs_cell, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 12, process_option = self.process_option_DEFAULT; end
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 9, applied_current_manager = self.applied_current_manager; end
            if nargin < 8, synapse_manager = self.synapse_manager; end
            if nargin < 7, neuron_manager = self.neuron_manager; end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 5, k_addition = self.c_addition_DEFAULT; end
            if nargin < 4, k_subtraction2 = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_subtraction1 = self.c_subtraction_DEFAULT; end
            
            % Create an instance of the network.
            network = self;
            
            % Design the double subtraction subnetwork synapses.            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_cell{ 1 }, k_subtraction1, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the double centering subnetwork synpases.            
            [ dEs_dc, gs_dc, synapse_IDs_dc, ~, synapse_manager, network ] = network.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_addition, k_subtraction2, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }( 3 ), neuron_IDs_cell{ 1 }( 4 ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ), neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Preallocate arrays to store the transmission synapse properties.
            dEs_transmission = zeros( 1, num_transmission_synapses );
            gs_transmission = zeros( 1, num_transmission_synapses );
            synapse_IDs_transmission = zeros( 1, num_transmission_synapses );
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.                
                [ dEs_transmission( k ), gs_transmission( k ), synapse_IDs_transmission( k ), synapses, synapse_manager, network ] = network.design_transmission_synapse( [ from_neuron_IDs( k ), to_neuron_IDs( k ) ], 0.5, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, applied_current_compensation_flag, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                
            end
            
            % Concatenate the synapse properties.
            dEs = [ dEs_ds, dEs_dc, dEs_transmission ];
            gs = [ gs_ds, gs_dc, gs_transmission ];
            synapse_IDs = [ synapse_IDs_ds, synapse_IDs_dc, synapse_IDs_transmission ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a multiplication subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_multiplication_synapses( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, filter_disabled_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, process_option = self.process_option; end
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, synapse_manager = self.synapse_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, k = self.c_multiplication_DEFAULT; end
            
            % Design the multiplication subnetwork synapses.
            [ dEs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_multiplication_synapses( neuron_IDs, encoding_scheme, synapse_manager.synapses, true, undetected_option );
                        
            % Get the applied current associated with the final neuron.
            [ ~, Ias4 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 4 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias4 == Ias4( 1 ) ), warning( 'The basic multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia3 = 0;
            Ia4 = mean( Ias4 );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this multiplication subnetwork.            
            [ gs, synapse_manager, self ] = self.compute_multiplication_gs( neuron_IDs, synapse_IDs, Ia3, Ia4, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapse of an inversion subnetwork.
        function [ dEs12, gs12, synapse_ID, synapses, synapse_manager, self ] = design_inversion_synapse( self, neuron_IDs, epsilon, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, filter_disabled_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, process_option = self.process_option; end
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, applied_current_manager = self.applied_current_manager; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, k = self.c_inversion_DEFAULT; end
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end
            
            % Design the inversion subnetwork synapse.
            [ dEs12, synapse_ID, synapses, synapse_manager ] = synapse_manager.design_inversion_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 2 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic division subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.            
            [ gs12, synapse_manager, self ] = self.compute_inversion_gs( neuron_IDs, Ia, epsilon, k, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapses of a division subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_division_synapses( self, neuron_IDs, k, c, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, filter_disabled_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, process_option = self.process_option; end
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, applied_current_manager = self.applied_current_manager; end
            if nargin < 7, synapse_manager = self.synapse_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = self.c_division_DEFAULT; end
            
            % Design the division subnetwork synapses.
            [ dEs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_division_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.            
             [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( to_neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic division subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.            
            [ gs, synapse_manager, self ] = self.compute_division_gs( neuron_IDs, synapse_IDs, Ia, k, c, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapses for a derivation subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_derivation_synapses( self, neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, set_flag, filter_disabled_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, process_option = self.process_option; end
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end
            
            % Design the derivation subnetwork synapses.
            [ dEs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_derivation_synapses( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias3 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias3 == Ias3( 1 ) ), warning( 'The basic multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia3 = mean( Ias3 );
            
            % Compute the subtraction subnetwork gain.
            ksub = ( 1e6 )/k;
            
            % Compute and set the maximum synaptic conductances associated with this derivation subnetwork.            
            [ gs, synapse_manager, self ] = self.compute_derivation_gs( neuron_IDs, synapse_IDs, Ia3, ksub, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to design the synapses for an integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_integration_synapses( self, neuron_IDs, ki_range, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            
            % Design the integration subnetwork synapses.            
            [ ~, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_integration_synapses( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Compute and set the integration subnetwork maximum synaptic conductances.
            [ gs, synapse_manager, network ] = self.compute_integration_gs( neuron_IDs, synapse_IDs, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.
            [ dEs, synapse_manager, network ] = network.compute_integration_dEs( neuron_IDs, synapse_IDs, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_vbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end
            if nargin < 8, synapse_manager = self.synapse_manager; end
            if nargin < 7, neuron_manager = self.neuron_manager; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Design the derivation subnetwork synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.design_vbi_synapses( neuron_IDs );
            
            % Get the synapse IDs that connect the two neurons.
            synapse_ID34 = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 3 ), neuron_IDs( 4 ) );
            synapse_ID43 = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 4 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_IDs, synapse_ID34, synapse_ID43 ];
            
            % Compute and set the integration subnetwork maximum synaptic conductances.            
            [ gs_integration, synapse_manager, network ] = self.compute_integration_gs( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ), ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.            
            [ dEs, synapse_manager, network ] = network.compute_integration_dEs( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ), neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compue and set the voltage based integration subnetwork maximum synaptic conductance.            
            [ gs_vbi, synapse_manager, network ] = network.compute_vbi_gs( neuron_IDs, synapse_IDs, T, n, ki_mean, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
            % Retrieve the synapses.
            synapses = synapse_manager.synapses;
            
            % Store the synaptic conductances in an array.
            gs = [ gs_integration, gs_vbi ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a split voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_svbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 14, process_option = self.process_option_DEFAULT; end
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end
            if anrgin < 12, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 11, applied_current_manager = self.applied_current_manager; end
            if nargin < 10, synapse_manager = self.synapse_manager; end
            if anrgin < 9, neuron_manager = self.neuron_manager; end
            if nargin < 8, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 7, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create an instance of the network object.
            network = self;
            
            % Retrieve the neuron ID components.
            neuron_IDs_vbi = neuron_IDs( 1:4 );
            neuron_IDs_ds = neuron_IDs( 5:8 );
            neuron_IDs_transmission1 = [ neuron_IDs( 9 ), neuron_IDs( 6 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 3 ), neuron_IDs( 5 ) ];

            % Design the voltage based integration synapses.            
            [ dEs_vbi, gs_vbi, synapse_IDs_vbi, ~, synapse_manager, network ] = network.design_vbi_synapses( neuron_IDs_vbi, T, n, ki_mean, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Design the double subtraction synapses.            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_ds, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the transmission synapses. NOTE: Neuron IDs are in this order: { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1' }
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synpase properties.
            dEs = [ dEs_vbi, dEs_ds, dEs_transmission1, dEs_transmission2 ];
            gs = [ gs_vbi, gs_ds, gs_transmission1, gs_transmission2 ];
            synapse_IDs = [ synapse_IDs_vbi, synapse_IDs_ds, synapse_ID_transmission1, synapse_ID_transmission2 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a modulated split voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_msvbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 17, network_utilities = self.network_utilities; end
            if nargin < 16, undetected_option = self.undetected_option_DEFAULT; end
            if anrgin < 15, process_option = self.process_option_DEFAULT; end
            if anrgin < 14, set_flag = self.set_flag_DEFAULT; end
            if nargin < 13, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 12, applied_current_manager = self.applied_current_manager; end
            if nargin < 11, synapse_manager = self.synapse_manager; end
            if nargin < 10, neuron_manager = self.neuron_manager; end
            if nargin < 9, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create an instance of the network class.
            network = self;
            
            % Retrieve the neuron IDs.
            neuron_IDs_modulation1 = [ neuron_IDs( 10 ), neuron_IDs( 11 ) ];
            neuron_IDs_modulation2 = [ neuron_IDs( 10 ), neuron_IDs( 12 ) ];
            neuron_IDs_transmission1 = [ neuron_IDs( 7 ), neuron_IDs( 11 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 8 ), neuron_IDs( 12 ) ];
            neuron_IDs_transmission3 = [ neuron_IDs( 1 ), neuron_IDs( 10 ) ];
            neuron_IDs_transmission4 = [ neuron_IDs( 2 ), neuron_IDs( 10 ) ];

            % Design the synapses for a split voltage based integration subnetwork.            
            [ dEs_svbi, gs_svbi, synapse_IDs_svbi, ~, synapse_manager, network ] = network.design_svbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the modulation synapses.
            [ dEs_modulation1, gs_modulation1, synapse_ID_modulation1, ~, synapse_manager, network ] = network.design_modulation_synapses( neuron_IDs_modulation1, c_mod, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_modulation2, gs_modulation2, synapse_ID_modulation2, ~, synapse_manager, network ] = network.design_modulation_synapses( neuron_IDs_modulation2, c_mod, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Design the transmission synapses.
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission3, gs_transmission3, synapse_ID_transmission3, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission3, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission4, gs_transmission4, synapse_ID_transmission4, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission4, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            dEs = [ dEs_svbi, dEs_modulation1, dEs_modulation2, dEs_transmission1, dEs_transmission2, dEs_transmission3, dEs_transmission4 ];
            gs = [ gs_svbi, gs_modulation1, gs_modulation2, gs_transmission1, gs_transmission2, gs_transmission3, gs_transmission4 ];
            synapse_IDs = [ synapse_IDs_svbi, synapse_ID_modulation1, synapse_ID_modulation2, synapse_ID_transmission1, synapse_ID_transmission2, synapse_ID_transmission3, synapse_ID_transmission4 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a modulated split difference voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_mod_split_sub_vb_integration_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 18, network_utilities = self.network_utilities; end
            if nargin < 17, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 16, process_option = self.process_option_DEFAULT; end
            if nargin < 15, set_flag = self.set_flag_DEFAULT; end
            if nargin < 14, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end
            if nargin < 13, applied_current_manager = self.applied_current_manager; end
            if nargin < 12, synapse_manager = self.synapse_manager; end
            if nargin < 11, neuron_manager = self.neuron_manager; end
            if nargin < 10, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 9, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 8, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 7, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create an instance of the network class.
            network = self;
            
            % Retrieve the neuron ID components.
            neuron_IDs_ds = neuron_IDs( 1:4 );
            neuron_IDs_msvbi = neuron_IDs( 5:end );
            neuron_IDs_transmission1 = [ neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 4 ), neuron_IDs( 6 ) ];
            
            % Design the double subtraction synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs( 1:4 ), k_sub2, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_ds, k_sub2, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the modulated split voltage based integration synapses.            
            [ dEs_msvbi, gs_msvbi, synapse_IDs_msvbi, ~, synapse_manager, network ] = network.design_msvbi_synapses( neuron_IDs_msvbi, T, n, ki_mean, ki_range, k_sub1, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the transmission synapses.
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            dEs = [ dEs_ds, dEs_msvbi, dEs_transmission1, dEs_transmission2 ];
            gs = [ gs_ds, gs_msvbi, gs_transmission1, gs_transmission2 ];
            synapse_IDs = [ synapse_IDs_ds, synapse_IDs_msvbi, synapse_ID_transmission1, synapse_ID_transmission2 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        %% Subnetwork Design Functions
        
        % Implement a function to design a multistate CPG oscillator subnetwork using existing neurons.
        function self = design_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the multistate cpg subnetwork neurons.
            self = self.design_mcpg_neurons( neuron_IDs, neuron_manager );
            
            % Design the multistate cpg subnetwork applied current.
            self = self.design_mcpg_applied_currents( neuron_IDs, applied_current_manager );
            
            % Design the multistate cpg subnetwork synapses.
            self = self.design_mcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
        
        % Implement a function to design a driven multistate CPG oscillator subnetwork using existing neurons.
        function self = design_driven_multistate_cpg_subnetwork( self, neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate cpg subnetwork neurons.
            self = self.design_dmcpg_neurons( neuron_IDs, neuron_manager );
            
            % Design the driven multistate cpg subnetwork applied current.
            self = self.design_dmcpg_applied_currents( neuron_IDs );
            
            % Design the driven multistate cpg subnetwork synapses.
            self = self.design_dmcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, I_drive_max );
            
        end
        
        
        % Implement a function to design a driven multistate CPG split lead lag subnetwork using existing neurons.
        function self = design_dmcpg_sll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r, dt, tf, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 16, applied_current_manager = self.applied_current_manager; end
            if nargin < 15, neuron_manager = self.neuron_manager; end
            if nargin < 14, tf = self.tf; end
            if nargin < 13, dt = self.dt; end
            if nargin < 12, r = self.r_oscillation_DEFAULT; end
            if nargin < 11, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate CPG split lead lag subnetwork neurons.
            self = self.design_dmcpg_sll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
            
            % Design the driven multistate CPG split lead lag subnetwork applied currents.
            self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager );
            
            % Design the driven multistate CPG split lead lag subnetwork synapses.
            self = self.design_dmcpg_sll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
        end
        
        
        % Implement a function to design a driven multistate CPG double centered lead lag subnetwork using existing neurons.
        function self = design_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 15, neuron_manager = self.neuron_manager; end
            if nargin < 14, r = self.r_oscillation_DEFAULT; end
            if nargin < 13, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 12, k_add = self.c_addition_DEFAULT; end
            if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end
            if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end
            if nargin < 6, T = self.T_oscillation_DEFAULT; end
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the driven multistate CPG double centered lead lag subnetwork neurons.
            self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
            
            % Design the driven multistate CPG double centered lead lag subnetwork applied currents.
            self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
            % Design the driven multistate CPG double centered lead lag subnetwork synapses.
            self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod );
            
        end
        
        
        % Implement a function to design an open loop driven multistate CPG double centered lead lag error subnetwork using existing neurons.
        function self = design_ol_dmcpg_dclle_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 18, neuron_manager = self.neuron_manager; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
            self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
            self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
            
            % Design the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
            
        end
        
        
        % Implement a function to design a closed loop P controlled driven multistate CPG double centered lead lag subnetwork using existing neurons.
        function self = design_clpc_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 20, applied_current_manager = self.applied_current_manager; end
            if nargin < 19, neuron_manager = self.neuron_manager; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork neurons.
            self = self.design_clpc_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork applied currents.
            self = self.design_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager );
            
            % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork synapses.
            self = self.design_clpc_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, I_drive_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain );
            
        end
        
        
        % Implement a function to design a transmission subnetwork using existing neurons.
        function self = design_transmission_subnetwork( self, neuron_IDs, k )
            
            % Set the default input arguments.
            if nargin < 3, k = self.c_transmission_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the transmission subnetwork neurons.
            self = self.design_transmission_neurons( neuron_IDs );
            
            % Design the tranmission subnetwork synapses.
            self = self.design_transmission_synapse( neuron_IDs, k, true, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
        end
        
        
        % Implement a function to design a modulation subnetwork using existing neurons.
        function self = design_modulation_subnetwork( self, neuron_IDs, c, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, c = self.c_modulation_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulation neurons.
            self = self.design_modulation_neurons( neuron_IDs, neuron_manager );
            
            % Design the modulation synapses.
            self = self.design_modulation_synapses( neuron_IDs, c );
            
        end
        
        
        % Implement a function to design an addition subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_addition_subnetwork( self, neuron_IDs, k, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, k = self.c_addition_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the addition subnetwork neurons.
            self = self.design_addition_neurons( neuron_IDs, neuron_manager );
            
            % Design the addition subnetwork synapses.
            self = self.design_addition_synapses( neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
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
        function self = design_subtraction_subnetwork( self, neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, network_utilities )
            
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the subtraction subnetwork neurons.
            self = self.design_subtraction_neurons( neuron_IDs, neuron_manager );
            
            % Design the subtraction subnetwork synapses.
            self = self.design_subtraction_synapses( neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
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
        function self = design_double_subtraction_subnetwork( self, neuron_IDs, k, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, k = self.c_subtraction_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the double subtraction subnetwork neurons.
            self = self.design_double_subtraction_neurons( neuron_IDs, neuron_manager );
            
            % Design the double subtraction subnetwork synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
        end
        
        
        % Implement a function to design a centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_centering_subnetwork( self, neuron_IDs, k_add, k_sub, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the centering subnetwork neurons.
            self = self.design_centering_neurons( neuron_IDs );
            
            % Design the centering subnetwork applied currents.
            self = self.design_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager );
            
            % Design the centering subnetwork synapses.
            self = self.design_centering_synapses( neuron_IDs, k_add, k_sub, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
        end
        
        
        % Implement a function to design a double centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_double_centering_subnetwork( self, neuron_IDs, k_add, k_sub, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end
            if nargin < 5, neuron_manager = self.neuron_manager; end
            if nargin < 4, k_sub = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_add = self.c_addition_DEFAULT; end
            
            % Design the double centering subnetwork neurons.
            self = self.design_double_centering_neurons( neuron_IDs, neuron_manager );
            
            % Design the double centering subnetwork applied currents.
            self = self.design_double_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager );
            
            % Design the double centering subnetwork synapses.
            self = self.design_double_centering_synapses( neuron_IDs, k_add, k_sub, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
        end
        
        
        % Implement a function to design a centered double subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function self = design_centered_double_subtraction_subnetwork( self, neuron_IDs_cell, k_sub1, k_sub2, k_add, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end
            if nargin < 6, neuron_manager = self.neuron_manager; end
            if nargin < 5, k_add = self.c_addition_DEFAULT; end
            if nargin < 4, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 3, k_sub1 = self.c_subtraction_DEFAULT; end
            
            % Design the centered double subtraction neurons.
            self = self.design_cds_neurons( neuron_IDs_cell, neuron_manager );
            
            % Design the centered double subtraction applied currents.
            self = self.design_cds_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager );
            
            % Design the centered double subtraction synapses.
            self = self.design_cds_synapses( neuron_IDs_cell, k_sub1, k_sub2, k_add );
            
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
            epsilon = self.compute_relative_inversion_epsilon( c, network_utilities );                                                 % [V] Inversion Subnetwork Input Offset
            delta = self.compute_relative_inversion_delta( c, network_utilities );                                                     % [V] Inversion Subnetwork Output Offset
            
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
            
            % Set the default input arguments.
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
            self = self.design_vbi_neurons( neuron_IDs, ki_mean );
            
            % Design the voltage based integration applied currents.
            self = self.design_vbi_applied_currents( neuron_IDs );
            
            % Design the voltage based integration synapses.
            self = self.design_vbi_synapses( neuron_IDs, T, n, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to design a split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_split_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, neuron_manager )
            
            % Set the default input arguments.
            if nargin < 8, neuron_manager = self.neuron_manager; end
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the split voltage based integration subnetwork neurons.
            self = self.design_svbi_neurons( neuron_IDs, ki_mean, neuron_manager );
            
            % Design the split voltage based integration applied currents.
            self = self.design_svbi_applied_currents( neuron_IDs );
            
            % Design the split voltage based integration synapses.
            self = self.design_svbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub );
            
        end
        
        
        % Implement a function to design a modulated split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_mod_split_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod, neuron_manager, synapse_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 11, applied_current_manager = self.applied_current_manager; end
            if nargin < 10, synapse_manager = self.synapse_manager; end
            if nargin < 9, neuron_manager = self.neuron_manager; end
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulated split voltage based integration subnetwork neurons.
            self = self.design_msvbi_neurons( neuron_IDs, ki_mean, neuron_manager );
            
            % Design the modulated split voltage based integration applied currents.
            self = self.design_msvbi_applied_currents( neuron_IDs, neuron_manager, applied_current_manager );
            
            % Design the modulated split voltage based integration synapses.
            self = self.design_msvbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod, synapse_manager, applied_current_manager );
            
        end
        
        
        % Implement a function to design a modulated difference split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function self = design_mod_split_sub_vb_integration_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 11, applied_current_manager = self.applied_current_manager; end
            if nargin < 10, neuron_manager = self.neuron_manager; end
            if nargin < 9, c_mod = self.c_modulation_DEFAULT; end
            if nargin < 8, k_sub2 = self.c_subtraction_DEFAULT; end
            if nargin < 7, k_sub1 = 2*self.c_subtraction_DEFAULT; end
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Design the modulated split voltage based integration subnetwork neurons.
            self = self.design_mssvbi_neurons( neuron_IDs, ki_mean, neuron_manager );
            
            % Design the modulated split voltage based integration applied currents.
            self = self.design_mssvbi_applied_currents( neuron_IDs, neuron_manager, applied_current_manager );
            
            % Design the modulated split voltage based integration synapses.
            self = self.design_mod_split_sub_vb_integration_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
            
        end
        
        
        %% Subnetwork Component Creation Functions
        
        % Implement a function to create the multistate CPG subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multistate_cpg_subnetwork_components( self, num_cpg_neurons )
            
            % Create the multistate cpg neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_multistate_cpg_neurons( num_cpg_neurons );
            
            % Create the multistate cpg synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_multistate_cpg_synapses( neuron_IDs );
            
            % Create the multistate cpg applied current.
            [ applied_current_manager, applied_current_ID ] = applied_current_manager.create_multistate_cpg_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the driven multistate CPG subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_driven_multistate_cpg_subnetwork_components( self, num_cpg_neurons )
            
            % Create the driven multistate cpg neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_driven_multistate_cpg_neurons( num_cpg_neurons );
            
            % Create the driven multistate cpg synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_driven_multistate_cpg_synapses( neuron_IDs );
            
            % Create the driven multistate cpg applied current.
            [ applied_current_manager, applied_current_ID ] = applied_current_manager.create_driven_multistate_cpg_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the driven multistate CPG split lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg neurons.
            [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_dmcpg_sll_neurons( num_cpg_neurons );
            
            % Create the driven multistate cpg synapses.
            [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_dmcpg_sll_synapses( neuron_IDs_cell );
            
            % Create the driven multistate cpg applied current.
            [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_dmcpg_sll_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the driven multistate cpg double centered lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the driven multistate cpg double centered lead lag subnetwork neurons.
            [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Create the driven multistate cpg double centered lead lag subnetwork synapses.
            [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_dmcpg_dcll_synapses( neuron_IDs_cell );
            
            % Create the driven multistate cpg double centered lead lag subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the open loop driven multistate cpg double centered lead lag error subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_ol_dmcpg_dclle_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
            [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_ol_dmcpg_dclle_neurons( num_cpg_neurons );
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_ol_dmcpg_dclle_synapses( neuron_IDs_cell );
            
            % Create the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_clpc_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork neurons.
            [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_clpc_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork synapses.
            [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_clpc_dmcpg_dcll_synapses( neuron_IDs_cell );
            
            % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the transmission subnetwork components.
        function [ self, neuron_IDs, synapse_ID ] = create_transmission_subnetwork_components( self )
            
            % Create the transmission neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_transmission_neurons(  );
            
            % Create the transmission synapses.
            [ synapse_manager, synapse_ID ] = synapse_manager.create_transmission_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the modulation subnetwork components.
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork_components( self )
            
            % Create the modulation neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_modulation_neurons(  );
            
            % Create the modulation synapses.
            [ synapse_manager, synapse_ID ] = synapse_manager.create_modulation_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_addition_subnetwork_components( self )
            
            % Create the addition neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_addition_neurons(  );
            
            % Create the addition synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_addition_subnetwork_components( self, num_addition_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                            % [#] Number of Addition Neurons
            
            % Create the neurons for an absolute addition subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_absolute_addition_neurons( num_addition_neurons );
            
            % Create the applied currents for an absolute addition subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_absolute_addition_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute addition subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_absolute_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative addition subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_addition_subnetwork_components( self, num_addition_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end                            % [#] Number of Addition Neurons
            
            % Create the neurons for a relative addition subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_relative_addition_neurons( num_addition_neurons );
            
            % Create the applied currents for a relative addition subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_relative_addition_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative addition subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_relative_addition_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_subtraction_subnetwork_components( self, neuron_manager, synapse_manager )
            
            % Set the default input arguments.
            if nargin < 3, synapse_manager = self.synapse_manager; end
            if nargin < 2, neuron_manager = self.neuron_manager; end
            
            % Create the subtraction neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_subtraction_neurons(  );
            
            % Create the subtraction synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_subtraction_subnetwork_components( self, num_subtraction_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                            % [#] Number of Subtraction Neurons
            
            % Create the neurons for an absolute subtraction subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_absolute_subtraction_neurons( num_subtraction_neurons );
            
            % Create the applied currents for an absolute subtraction subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_absolute_subtraction_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute subtraction subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_absolute_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_subtraction_subnetwork_components( self, num_subtraction_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end                            % [#] Number of Subtraction Neurons
            
            % Create the neurons for a relative subtraction subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_relative_subtraction_neurons( num_subtraction_neurons );
            
            % Create the applied currents for a relative subtraction subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_relative_subtraction_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative subtraction subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_relative_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the double subtraction subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_double_subtraction_subnetwork_components( self )
            
            % Create the double subtraction neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_double_subtraction_neurons(  );
            
            % Create the double subtraction synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_double_subtraction_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the centering subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_centering_subnetwork_components( self )
            
            % Create the centering subnetwork neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_centering_neurons(  );
            
            % Create the centering subnetwork synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_centering_synapses( neuron_IDs );
            
            % Create the centering subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_centering_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the double centering subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_double_centering_subnetwork_components( self )
            
            % Create the double centering subnetwork neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_double_centering_neurons(  );
            
            % Create the double centering subnetwork synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_double_centering_synapses( neuron_IDs );
            
            % Create the double centering subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_double_centering_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the centered double subtraction subnetwork components.
        function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_centered_double_subtraction_subnetwork_components( self )
            
            % Create the centered double subtraction subnetwork neurons.
            [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_centered_double_subtraction_neurons(  );
            
            % Create the centered double subtraction subnetwork synapses.
            [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_centered_double_subtraction_synapses( neuron_IDs_cell );
            
            % Create the centered double subtraction subnetwork applied currents.
            [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_centered_double_subtraction_applied_currents( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_ID ] = create_multiplication_subnetwork_components( self )
            
            % Create the multiplication neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_multiplication_neurons(  );
            
            % Create the multiplication synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_multiplication_synapses( neuron_IDs );
            
            % Create the multiplication applied currents.
            [ applied_current_manager, applied_current_ID ] = applied_current_manager.create_multiplication_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_multiplication_subnetwork_components( self )
            
            % Create the neurons for an absolute multiplication subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_absolute_multiplication_neurons(  );
            
            % Create the applied currents for an absolute multiplication subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_absolute_multiplication_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute multiplication subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_absolute_multiplication_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative multiplication subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_multiplication_subnetwork_components( self )
            
            % Create the neurons for a relative multiplication subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_relative_multiplication_neurons(  );
            
            % Create the applied currents for a relative multiplication subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_relative_multiplication_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative multiplication subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_relative_multiplication_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the inversion subnetwork components.
        function [ self, neuron_IDs, synapse_ID, applied_current_ID ] = create_inversion_subnetwork_components( self )
            
            % Create the inversion neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_inversion_neurons(  );
            
            % Create the inversion synapse.
            [ synapse_manager, synapse_ID ] = synapse_manager.create_inversion_synapse( neuron_IDs );
            
            % Create the inversion applied current.
            [ applied_current_manager, applied_current_ID ] = applied_current_manager.create_inversion_applied_current( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute inversion subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_inversion_subnetwork_components( self )
            
            % Create the neurons for an absolute inversion subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_absolute_inversion_neurons(  );
            
            % Create the applied currents for an absolute inversion subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_absolute_inversion_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute inversion subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_absolute_inversion_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative inversion subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_inversion_subnetwork_components( self )
            
            % Create the neurons for a relative inversion subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_relative_inversion_neurons(  );
            
            % Create the applied currents for a relative inversion subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_relative_inversion_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative inversion subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_relative_inversion_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_division_subnetwork_components( self )
            
            % Create the division neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_division_neurons(  );
            
            % Create the division synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the absolute division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_absolute_division_subnetwork_components( self )
            
            % Create the neurons for an absolute division subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_absolute_division_neurons(  );
            
            % Create the applied currents for an absolute division subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_absolute_division_applied_currents( neuron_IDs );
            
            % Create the synapses for an absolute division subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_absolute_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the relative division subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_relative_division_subnetwork_components( self )
            
            % Create the neurons for a relative division subnetwork.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_relative_division_neurons(  );
            
            % Create the applied currents for a relative division subnetwork.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_relative_division_applied_currents( neuron_IDs );
            
            % Create the synapses for a relative division subnetwork.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_relative_division_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the derivation subnetwork components.
        function [ self, neuron_IDs, synapse_IDs ] = create_derivation_subnetwork_components( self )
            
            % Create the derivation neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_derivation_neurons(  );
            
            % Create the derivation synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_derivation_synapses( neuron_IDs );
            
        end
        
        
        % Implement a function to create the integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_integration_subnetwork_components( self )
            
            % Create the integration neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_integration_neurons(  );
            
            % Create the integration synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_integration_synapses( neuron_IDs );
            
            % Create the integration applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_vb_integration_subnetwork_components( self )
            
            % Create the voltage based integration neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_vb_integration_neurons(  );
            
            % Create the voltage based integration synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_vb_integration_synapses( neuron_IDs );
            
            % Create the voltage based integration applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_vb_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the split voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_split_vb_integration_subnetwork_components( self )
            
            % Create the split voltage based integration neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_split_vb_integration_neurons(  );
            
            % Create the split voltage based integration synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_split_vb_integration_synapses( neuron_IDs );
            
            % Create the split voltage based integration applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_split_vb_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the modulated split voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_vb_integration_subnetwork_components( self )
            
            % Create the modulated split voltage based integration neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_mod_split_vb_integration_neurons(  );
            
            % Create the modulated split voltage based integration synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_mod_split_vb_integration_synapses( neuron_IDs );
            
            % Create the modulated split voltage based integration applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_mod_split_vb_integration_applied_currents( neuron_IDs );
            
        end
        
        
        % Implement a function to create the modulated split difference voltage based integration subnetwork components.
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_mod_split_sub_vb_integration_subnetwork_components( self )
            
            % Create the modulated split difference voltage based integration neurons.
            [ neuron_manager, neuron_IDs ] = neuron_manager.create_mod_split_sub_vb_integration_neurons(  );
            
            % Create the modulated split difference voltage based integration synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.create_mod_split_sub_vb_integration_synapses( neuron_IDs );
            
            % Create the modulated split difference voltage based integration applied currents.
            [ applied_current_manager, applied_current_IDs ] = applied_current_manager.create_mod_split_sub_vb_integration_applied_currents( neuron_IDs );
            
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
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
            if nargin < 5, I_drive_max = self.Id_max_DEFAULT; end
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
            
            % Set the default input arguments.
            if nargin < 2, k = self.c_transmission_DEFAULT; end
            
            % Create the transmission subnetwork components.
            [ self, neuron_IDs, synapse_ID ] = self.create_transmission_subnetwork_components(  );
            
            % Design a transmission subnetwork.
            self = self.design_transmission_subnetwork( neuron_IDs, k );
            
        end
        
        
        % Implement a function to create a modulation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_ID ] = create_modulation_subnetwork( self, c )
            
            % Set the default input arguments.
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
            
            % Set the default input arguments.
            if nargin < 2, k = self.c_subtraction_DEFAULT; end
            
            % Create the subtraction subnetwork components.
            [ self, neuron_IDs, synapse_IDs ] = self.create_subtraction_subnetwork_components(  );
            
            % Design the subtraction subnetwork.
            self = self.design_subtraction_subnetwork( neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
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
            
            % Set the default input arguments.
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
            
            % Set the default input arguments.
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
        %             % Set the default input arguments.
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
            
            % Set the default input arguments.
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_integration_subnetwork_components(  );
            
            % Design the integration subnetwork.
            self = self.design_integration_subnetwork( neuron_IDs, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_vb_integration_subnetwork( self, T, n, ki_mean, ki_range )
            
            % Set the default input arguments.
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Create the voltage based integration subnetwork components.
            [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = self.create_vb_integration_subnetwork_components(  );
            
            % Design the voltage based integration subnetwork.
            self = self.design_vb_integration_subnetwork( neuron_IDs, T, n, ki_mean, ki_range );
            
        end
        
        
        % Implement a function to create a split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ self, neuron_IDs, synapse_IDs, applied_current_IDs ] = create_split_vb_integration_subnetwork( self, T, n, ki_mean, ki_range, k_sub )
            
            % Set the default input arguments.
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
            
            % Set the default input arguments.
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
            
            % Set the default input arguments.
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
            valid_flag = neuron_manager.unique_existing_neuron_IDs(  );
            
            % Throw an error if the neuron IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Neuron IDs must be unique.' ), end
            
            % Ensure that the synapse IDs are unique.
            valid_flag = synapse_manager.unique_existing_synapse_IDs(  );
            
            % Throw an error if the synapse IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Synapse IDs must be unique.' ), end
            
            % Ensure that the applied current IDs are unique.
            valid_flag = applied_current_manager.unique_existing_applied_current_IDs(  );
            
            % Throw an error if the synapse IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Applied current IDs must be unique.' ), end
            
            % Ensure that only one synapse connects each pair of neurons.
            valid_flag = synapse_manager.one_to_one_synapses(  );
            
            % Throw an error if there are multiple synapses per pair of neurons.
            if ~valid_flag, error( 'Invalid network.  There must be only one synapse per pair of neurons.' ), end
            
            % Ensure that only one applied current applies to each neuron.
            valid_flag = applied_current_manager.one_to_one_applied_currents(  );
            
            % Throw an error if there are multiple applied currents per neuron.
            if ~valid_flag, error( 'Invalid network.  There must be only one applied current per neuron.' ), end
            
        end
        
        
        %% Network Linearization Functions
        
        % Implement a function to compute the linearized system matrix for this neural network about a given operating point.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function A = compute_linearized_system_matrix( self, Cms, Gms, Rs, gs, dEs, Us0 )
            
            % Set the default input arguments.
            if nargin < 7, Us0 = zeros( length( Cm2 ), 1 ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end

            % Compute the linearized system matrix.
            A = network_utilities.compute_linearized_system_matrix( Cms, Gms, Rs, gs, dEs, Us0 );
            
        end
        
        
        % Implement a function to compute the linearized input matrix for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function B = compute_linearized_input_matrix( self, Cms, Ias )
        
            % Set the default input arguments.
            if nargin < 3, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the linearized input matrix.
            B = network_utilitities.compute_linearized_input_matrix( Cms, Ias );
            
        end
        
        
        % Implement a function to compute the linearized system for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function [ A, B ] = get_linearized_system( self, Cms, Gms, Rs, gs, dEs, Ias, Us0 )
        
            % Set the default input arguments.
            if nargin < 8, Us0 = zeros( neuron_manager.num_neurons, 1 ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end

            % Compute the linearized system.
            [ A, B ] = network_utilities.get_linearized_system( Cms, Gms, Rs, gs, dEs, Ias, Us0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at a specific operating point.
        function [ A, dt, condition_number ] = RK4_stability_analysis_at_point( self, Cms, Gms, Rs, gs, dEs, Us0, dt0 )
        
            % Set the default input arguments.
            if nargin < 8, dt0 = 1e-6; end
            if nargin < 7, Us0 = zeros( neuron_manager.num_neurons, 1 ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the maximum RK4 step size and condition number.            
            [ A, dt, condition_number ] = network_utilities.RK4_stability_analysis_at_point( Cms, Gms, Rs, gs, dEs, Us0, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at multiple operating points.
        function [ As, dts, condition_numbers ] = RK4_stability_analysis( self, Cms, Gms, Rs, gs, dEs, Us, dt0 )
        
           % Set the default input arguments.
            if nargin < 8, dt0 = 1e-6; end
            if nargin < 7, Us = zeros( 1, neuron_manager.num_neurons ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
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
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
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
            U2s = network_utilities.compute_desired_absolute_transmission_steady_state_output( U1s, c );
        
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative transmission subnetwork.
        function U2s = compute_desired_relative_transmission_steady_state_output( self, U1s, c, R1, R2 )
 
            % Set the default input arguments.
            if nargin < 5, R2 = 20e-3; end
            if nargin < 4, R1 = 20e-3; end
            if nargin < 3, c = 1; end
            if nargin < 2, U1s = 0; end
            
            % Compute the steady state network outputs.
            U2s = network_utilities.compute_desired_relative_transmission_steady_state_output( U1s, c, R1, R2 );
        
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
            U2s = network_utilities.compute_achieved_transmission_steady_state_output( U1s, R1, Gm2, Ia2, gs21, dEs21 );
            
        end
        
            
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute addition subnetwork.
        function U_outputs = compute_desired_absolute_addition_steady_state_output( self, U_inputs, c )
        
            % Set the default input arguments.
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_desired_absolute_addition_steady_state_output( U_inputs, c );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative addition subnetwork.
        function U_outputs = compute_desired_relative_addition_steady_state_output( self, U_inputs, Rs, c )
           
            % Set the default input arguments.
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, U_inputs = neuron_manager.get_neuron_property( 'all', 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_desired_relative_addition_steady_state_output( U_inputs, Rs, c );
        
        end
            
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an addition subnetwork.
        function U_outputs = compute_achieved_addition_steady_state_output( self, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            % Set the default input arguments.
            if nargin < 7, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_achieved_addition_steady_state_output( U_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute subtraction subnetwork.
        function U_outputs = compute_desired_absolute_subtraction_steady_state_output( self, U_inputs, c, ss )
            
            % Set the default input arguments.
            if nargin < 4, ss = [ 1, -1 ]; end
            if nargin < 3, c = 1; end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_desired_absolute_subtraction_steady_state_output( U_inputs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative subtraction subnetwork.
        function U_outputs = compute_desired_relative_subtraction_steady_state_output( self, U_inputs, Rs, c, ss )
           
            % Set the default input arguments.
            if nargin < 5, ss = [ 1, -1 ]; end
            if nargin < 4, c = 1; end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, U_inputs = zeros( 1, 2 ); end
            
            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_desired_relative_subtraction_steady_state_output( U_inputs, Rs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a subtraction subnetwork.
        function U_outputs = compute_achieved_subtraction_steady_state_output( self, U_inputs, Rs, Gms, Ias, gs, dEs )
            
            % Set the default input arguments.
            if nargin < 7, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            U_outputs = network_utilities.compute_achieved_subtraction_steady_state_output( U_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute inversion subnetwork.
        function U2s = compute_desired_absolute_inversion_steady_state_output( self, U1s, c1, c2, c3 )
            
            % Set the default input arguments.
            if nargin < 5, c3 = 20e-9; end                          % [A] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                          % [S] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                        % [W] Design Constant 1.
            
            % Compute the steady state output.
            U2s = network_utilities.compute_desired_absolute_inversion_steady_state_output( U1s, c1, c2, c3 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute inversion subnetwork.
        function U2s = compute_desired_reduced_absolute_inversion_steady_state_output( self, U1s, c1, c2 )
            
            % Set the default input arguments.
            if nargin < 4, c2 = 21.05e-6; end                       % [mV] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                        % [mV^2] Design Constant 1.
            
            % Compute the steady state output.
            U2s = network_utilities.compute_desired_reduced_absolute_inversion_steady_state_output( U1s, c1, c2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative inversion subnetwork.
        function U2s = compute_desired_relative_inversion_steady_state_output( self, Us1, c1, c2, c3, R1, R2 )
        
            % Set the default input arguments.
            if nargin < 7, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                                                                                               % [-] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                                                                                              % [-] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                                                                                               % [-] Design Constant 1.
            
            % Compute the steady state output.
            U2s = network_utilities.compute_desired_relative_inversion_steady_state_output( Us1, c1, c2, c3, R1, R2 );             % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative inversion subnetwork.
        function U2s = compute_desired_reduced_relative_inversion_steady_state_output( self, Us1, c1, c2, R1, R2 )
        
            % Set the default input arguments.
            if nargin < 6, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 52.6e-3; end                                                                                            % [-] Design Constant 2.
            if nargin < 3, c1 = 52.6e-3; end                                                                                            % [-] Design Constant 1.
            
            % Compute the steady state output.
            U2s = network_utilities.compute_desired_reduced_relative_inversion_steady_state_output( Us1, c1, c2, R1, R2 );         % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an inversion subnetwork.
        function U2s = compute_achieved_inversion_steady_state_output( self, U1s, R1, Gm2, Ia2, gs21, dEs21 )
            
            % Set the default input arguments.
            if nargin < 7, dEs21 = self.get_dEs( [ 1, 2 ], neuron_manager, synapse_manager ); end                                                                     % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = self.get_gs( [ 1, 2 ], neuron_manager, synapse_manager ); end                                                                    % [S] Maximum Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = neuron_manager.get_neuron_property( 2, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end                               % [A] Applied Currents (Neuron 2).
            if nargin < 4, Gm2 = neuron_manager.get_neuron_property( 2, 'Gm', true, neuron_manager.neurons, undetected_option ); end                                    % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).

            % Compute the steady state output.
            U2s = network_utilities.compute_achieved_inversion_steady_state_output( U1s, R1, Gm2, Ia2, gs21, dEs21 );              % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_desired_absolute_division_steady_state_output( self, U_inputs, c1, c2, c3 )
            
            % Set the default input arguments.
            if nargin < 5, c3 = 0.40e-9; end                                                                                            % [W] Design Constant 3.
            if nargin < 4, c2 = 380e-9; end                                                                                             % [A] Design Constant 2.
            if nargin < 3, c1 = 0.40e-9; end                                                                                            % [W] Design Constant 1.
            
            % Compute the steady state output.
            U3s = network_utilities.compute_desired_absolute_division_steady_state_output( U_inputs, c1, c2, c3 );                 % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_desired_reduced_absolute_division_steady_state_output( self, U_inputs, c1, c2 )
            
            % Set the default input arguments.
            if nargin < 4, c2 = 1.05e-3; end                                                                                            % [V] Design Constant 2.
            if nargin < 3, c1 = 1.05e-3; end                                                                                            % [V] Design Constant 1.
            
            % Compute the steady state output.
            U3s = network_utilities.compute_desired_reduced_absolute_division_steady_state_output( U_inputs, c1, c2 );           	% [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative division subnetwork.
        function U3s = compute_desired_relative_division_steady_state_output( self, U_inputs, c1, c2, c3, R1, R2, R3 )
            
            % Set the default input arguments.
            if nargin < 8, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 7, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = 1e-6; end                                                                                                   % [S] Design Constant 3.
            if nargin < 4, c2 = 19e-6; end                                                                                                  % [S] Design Constant 2.
            if nargin < 3, c1 = 1e-6; end                                                                                                   % [S] Design Constant 1.
            
            % Compute the steady state output.
            U3s = network_utilities.compute_desired_relative_division_steady_state_output( U_inputs, c1, c2, c3, R1, R2, R3 );         % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative division subnetwork.
        function U3s = compute_desired_reduced_relative_division_steady_state_output( self, U_inputs, c1, c2, R1, R2, R3 )
            
            % Set the default input arguments.
            if nargin < 7, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 6, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = 0.0526; end                                                                                                 % [-] Design Constant 2.
            if nargin < 3, c1 = 0.0526; end                                                                                                 % [-] Design Constant 1.
            
            % Compute the steady state output.
            U3s = network_utilities.compute_desired_reduced_relative_division_steady_state_output( U_inputs, c1, c2, R1, R2, R3 );     % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a division subnetwork.
        function U3s = compute_achieved_division_steady_state_output( self, U_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 )
            
            % Set the default input arguments.
            if nargin < 10, dEs32 = self.get_dEs( [ 2, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [V] Synaptic Reversal Potential (Synapse 32).
            if nargin < 9, dEs31 = self.get_dEs( [ 1, 3 ], neuron_manager, synapse_manager ); end                                                                                     % [V] Synaptic Revesal Potential (Synapse 31).
            if nargin < 8, gs32 = self.get_gs( [ 2, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [S] Synaptic Conductance (Synapse 32).
            if nargin < 7, gs31 = self.get_gs( [ 1, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [S] Synaptic Conductance (Synapse 31).
            if nargin < 6, Ia3 = neuron_manager.get_neuron_property( 3, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end                                               % [A] Applied Current (Neuron 3).
            if nargin < 5, Gm3 = neuron_manager.get_neuron_property( 3, 'Gm', true, neuron_manager.neurons, undetected_option ); end                                                    % [S] Membrane Conductance (Neuron 3).
            if nargin < 4, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                                      % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                                      % [V] Maximum Membrane Voltage (Neuron 1).
            
            % Compute the steady state output.
            U3s = network_utilities.compute_achieved_division_steady_state_output( U_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 );         % [V] Membrane Voltage (Neuron 3).
            
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
            [ U4s, U3s ] = network_utilities.compute_desired_absolute_multiplication_steady_state_output( U_inputs, c1, c2, c3, c4, c5, c6 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_abs_mult_ss_output( self, U_inputs, c1, c2, c3, c4 )
            
            % Set the default input arguments.
            if nargin < 6, c4 = 1.05e-3; end                      	% [V] Reduced Absolute Multiplication Design Constant 4 (Reduced Absolute Division Design Constant 2).
            if nargin < 5, c3 = 1.05e-3; end                       	% [V] Reduced Absolute Multiplication Design Constant 3 (Reduced Absolute Division Design Constant 1).
            if nargin < 4, c2 = 21.05e-6; end                       % [mV] Reduced Absolute Multiplication Design Constant 2 (Reduced Absolute Inversion Design Constant 2).
            if nargin < 3, c1 = 1.05e-3; end                        % [mV^2] Reduced Absolute Multiplication Design Constant 1 (Reduced Absolute Inversion Design Constant 1).
            
            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_desired_red_abs_mult_ss_output( U_inputs, c1, c2, c3, c4 );
            
        end
        
                    
            
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_relative_multiplication_steady_state_output( self, U_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 )
            
            % Set the default input arguments.
            if nargin < 12, R4 = neuron_manager.get_neuron_property( 4, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 11, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 10, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 9, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, c6 = 1e-6; end
            if nargin < 7, c5 = 19e-6; end
            if nargin < 6, c4 = 1e-6; end
            if nargin < 5, c3 = 1e-6; end
            if nargin < 4, c2 = 19e-6; end
            if nargin < 3, c1 = 1e-6; end
            
            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_desired_relative_multiplication_steady_state_output( U_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_desired_red_rel_mult_ss_output( self, U_inputs, c1, c2, c3, c4, R1, R2, R3, R4 )
            
            % Set the default input arguments.
            if nargin < 10, R4 = neuron_manager.get_neuron_property( 4, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 9, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 7, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, c4 = 1e-6; end
            if nargin < 5, c3 = 1e-6; end
            if nargin < 4, c2 = 19e-6; end
            if nargin < 3, c1 = 1e-6; end
            
            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_desired_red_rel_mult_ss_output( U_inputs, c1, c2, c3, c4, R1, R2, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a multiplication subnetwork.
        function [ U4s, U3s ] = compute_achieved_multiplication_steady_state_output( self, U_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 )
        
            % Set the default input arguments.
            if nargin < 15, dEs43 = self.get_dEs( [ 3, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 14, dEs41 = self.get_dEs( [ 1, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 13, dEs32 = self.get_dEs( [ 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 12, gs43 = self.get_gs( [ 3, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 11, gs41 = self.get_gs( [ 1, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 10, gs32 = self.get_gs( [ 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 9, Ia4 = neuron_manager.get_neuron_property( 4, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, Ia3 = neuron_manager.get_neuron_property( 3, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 7, Gm4 = neuron_manager.get_neuron_property( 4, 'G', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Gm3 = neuron_manager.get_neuron_property( 3, 'G', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_achieved_multiplication_steady_state_output( U_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 );
            
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
            Us_output = network_utilities.compute_desired_absolute_linear_combination_steady_state_output( Us_inputs, cs, ss );
            
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
            Us_output = network_utilities.compute_desired_relative_linear_combination_steady_state_output( Us_inputs, Rs, cs, ss );
            
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
            Us_output = network_utilities.compute_achieved_linear_combination_ss_output( Us_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        %% Simulation Functions
        
        % Implement a function to compute a single network simulation step.
        function [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation_step( self )
            
            % Ensure that the network is constructed properly.
            self.validate_network(  )
            
            % Retrieve the IDs associated with the enabled neurons.
            neuron_IDs = neuron_manager.get_enabled_neuron_IDs(  );
            
            % Retrieve basic neuron properties.
            Us = neuron_manager.get_neuron_property( neuron_IDs, 'U', true, neuron_manager.neurons, undetected_option );
            hs = neuron_manager.get_neuron_property( neuron_IDs, 'h', true, neuron_manager.neurons, undetected_option );
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Cms = neuron_manager.get_neuron_property( neuron_IDs, 'Cm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            I_tonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve sodium channel neuron properties.
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option );
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option );
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option );
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option );
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option );
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option );
            tauh_maxs = neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max', true, neuron_manager.neurons, undetected_option );
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option );
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve synaptic properties.
            g_syn_maxs = self.get_gs( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Retrieve applied currents.
            I_apps = applied_current_manager.neuron_IDs2Iapps( neuron_IDs, self.dt, self.tf )';
            
            % Perform a single simulation step.
            [ dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = network_utilities.simulation_step( Us, hs, Gms, Cms, Rs, g_syn_maxs, dEs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps );
            
            % Compute the membrane voltages at the next time step.
            Us = numerical_method_utilities.forward_euler_step( Us, dUs, self.dt );
            
            % Compute the sodium channel deactivation parameters at the next time step.
            hs = numerical_method_utilities.forward_euler_step( hs, dhs, self.dt );
            
        end
        
        
        % Implement a function to compute and set a single network simulation step.
        function self = compute_set_simulation_step( self )
            
            % Compute and set a single network simulation step.
            [ Us, hs, G_syns, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = compute_simulation_step(  );
            
            % Set the neuron properties.
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, Us, 'U' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, hs, 'h' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_leaks, 'I_leak' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_syns, 'I_syn' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_nas, 'I_na' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_totals, 'I_total' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, m_infs, 'm_inf' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, h_infs, 'h_inf' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, tauhs, 'tauh' );
            
            % Set the synapse properties.
            self = self.set_Gs( G_syns, neuron_IDs );
            
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
            neuron_IDs = neuron_manager.get_enabled_neuron_IDs(  );
            
            % Retrieve the neuron properties.
            Us = neuron_manager.get_neuron_property( neuron_IDs, 'U', true, neuron_manager.neurons, undetected_option )';
            hs = neuron_manager.get_neuron_property( neuron_IDs, 'h', true, neuron_manager.neurons, undetected_option )';
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option )';
            Cms = neuron_manager.get_neuron_property( neuron_IDs, 'Cm', true, neuron_manager.neurons, undetected_option )';
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ length( Rs ), 1 ] );
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option )';
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option )';
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option )';
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option )';
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option )';
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option )';
            tauh_maxs = neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max', true, neuron_manager.neurons, undetected_option )';
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option )';
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option )';
            I_tonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option )';

            % Retrieve the synapse properties.
            g_syn_maxs = self.get_gs( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Retrieve the applied currents.
            I_apps = applied_current_manager.neuron_IDs2Iapps( neuron_IDs, self.dt, self.tf, 'ignore' )';
            
            % Retrieve the applied voltages.
            V_apps_cell = applied_voltage_manager.neuron_IDs2Vapps( neuron_IDs, self.dt, self.tf, 'ignore' )';
            
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
            %             dEs = (1e3)*dEs;
            %             I_apps = (1e9)*I_apps;
            
            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, G_syns, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs ] = network_utilities.simulate( Us, hs, Gms, Cms, Rs, g_syn_maxs, dEs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, I_apps, V_apps_cell, tf, dt, method );
            
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
            %             dEs = (1e-3)*dEs;
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
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, Us( :, end ), 'U' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, hs( :, end ), 'h' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_leaks( :, end ), 'I_leak' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_syns( :, end ), 'I_syn' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_nas( :, end ), 'I_na' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, I_totals( :, end ), 'I_total' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, m_infs( :, end ), 'm_inf' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, h_infs( :, end ), 'h_inf' );
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs, tauhs( :, end ), 'tauh' );
            
            % Set the synapse properties.
            self = self.set_Gs( G_syns( :, :, end ), neuron_IDs );
            
        end
        
        
        % Implement a function to compute simulation results for given applied currents.
        function [ self, ts, Us_flat, hs_flat, dUs_flat, dhs_flat, Gsyns_flat, Ileaks_flat, Isyns_flat, Inas_flat, Iapps_flat, Itotals_flat, minfs_flat, hinfs_flat, tauhs_flat, neuron_IDs ] = simulate_flat( self, applied_current_IDs, applied_currents_flat, dt, tf, method )
                       
            % Retrieve the number of neurons.
            num_neurons = neuron_manager.num_neurons;

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
                    applied_current_manager = applied_current_manager.set_applied_current_property( applied_current_IDs( k2 ), applied_currents_flat( k1, k2 ), 'I_apps' );
                    
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
        function [ data, self ] = load( self, directory, file_name, set_flag )
            
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, file_name = 'Network.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            if set_flag, self = data; end   
            
        end
        
        
        % Implement a function to load network data from a xlsx file.
        function [ neuron_manager, synapse_manager, applied_current_manager, self ] = load_xlsx( self, directory, file_name_neuron, file_name_synapse, file_name_applied_current, append_flag, verbose_flag, set_flag )
            
            % Set the default input arguments.
            if nargin < 7, verbose_flag = true; end
            if nargin < 6, append_flag = false; end
            if nargin < 5, file_name_applied_current = 'Applied_Current_Data.xlsx'; end
            if nargin < 4, file_name_synapse = 'Synapse_Data.xlsx'; end
            if nargin < 3, file_name_neuron = 'Neuron_Data.xlsx'; end
            if nargin < 2, directory = '.'; end
            
            % Create an instance of the neuron manager class.
            neuron_manager = neuron_manager_class(  );
            
            % Load the neuron data.
            neuron_manager = neuron_manager.load_xlsx( file_name_neuron, directory, append_flag, verbose_flag );
            
            % Create an instance of the synapse manager class.
            synapse_manager = synapse_manager_class(  );
            
            % Load the synpase data.
            synapse_manager = synapse_manager.load_xlsx( file_name_synapse, directory, append_flag, verbose_flag );
            
            % Create an instance of the applied current manager class.
            applied_current_manager = applied_current_manager_class(  );
            
            % Load the applied current data.
            applied_current_manager = applied_current_manager.load_xlsx( file_name_applied_current, directory, append_flag, verbose_flag );
            
            % Determine whether to update the network object.
            if set_flag                 % If we want to update the network object...
                
                % Update the neuron manager.
                self.neuron_manager = neuron_manager;
                
                % Update the synapse manager.
                self.synapse_manager = synapse_manager;
                
                % Update the applied current manager.
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
    end
end

