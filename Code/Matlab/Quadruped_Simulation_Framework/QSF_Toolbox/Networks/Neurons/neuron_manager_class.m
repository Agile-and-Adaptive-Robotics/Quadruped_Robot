classdef neuron_manager_class
    
    % This class contains properties and methods related to managiing neurons.
    
    %% NEURON MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        neurons
        num_neurons
        
        array_utilities
        data_loader_utilities
        neuron_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        Cm_DEFAULT = 5e-9;                                                                                              % [C] Membrane Capacitance
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance
        Er_DEFAULT = -60e-3;                                                                                            % [V] Equilibrium Voltage
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain
        Am_DEFAULT = 1;                                                                                                 % [-] Sodium Channel Activation Parameter Amplitude
        Sm_DEFAULT = -50;                                                                                               % [-] Sodium Channel Activation Parameter Slope
        dEm_DEFAULT = 40e-3;                                                                                            % [V] Sodium Channel Activation Reversal Potential
        Ah_DEFAULT = 0.5;                                                                                               % [-] Sodium Channel Deactivation Parameter Amplitude
        Sh_DEFAULT = 50;                                                                                                % [-] Sodium Channel Deactivation Parameter Slope
        dEh_DEFAULT = 0;                                                                                                % [V] Sodium Channel Deactivation Reversal Potential
        dEna_DEFAULT = 110e-3;                                                                                          % [V] Sodium Channel Reversal Potential
        tauh_max_DEFAULT = 0.25;                                                                                        % [s] Maximum Sodium Channel Steady State Time Constant
        Gna_DEFAULT = 1e-6;                                                                                             % [S] Sodium Channel Conductance
        Ileak_DEFAULT = 0;                                                                                              % [A] Leak Current
        Isyn_DEFAULT = 0;                                                                                               % [A] Synaptic Current
        Ina_DEFAULT = 0;                                                                                                % [A] Sodium Channel Current
        Itonic_DEFAULT = 0;                                                                                             % [A] Tonic Current
        Iapp_DEFAULT = 0;                                                                                               % [A] Applied Current
        Itotal_DEFAULT = 0;                                                                                             % [A] Total Current
        
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
        num_derivation_neurons_DEFAULT = 3;                                                                                     % [#] Number of Derivation Neurons.
        num_integration_neurons_DEFAULT = 2;                                                                                    % [#] Number of Integration Neurons.
        num_vb_integration_neurons_DEFAULT = 4;                                                                                 % [#] Number of Voltage Based Integration Neurons.
        num_split_vb_integration_neurons_DEFAULT = 9;                                                                           % [#] Number of Split Voltage Based Integration Neurons.
        num_mod_split_vb_integration_neurons_DEFAULT = 3;                                                                       % [#] Number of Unique Modualted Split Voltage Based Integration Neurons.
        num_mssvb_integration_neurons_total_DEFAULT = 16;                                                                       % [#] Total Number of Modualted Split Subtraction Voltage Based Integration Neurons.
        num_dmcpg_sll_neurons_DEFAULT = 4;                                                                                      % [#] Number of Unique Driven Multistate Central Pattern Generator Split Lead Lag Neurons.
        
        c_inversion_DEFAULT = 1;                                                                                                % [-] Inversion Subnetwork Gain.
        epsilon_inversion_DEFAULT = 1e-6;                                                                                       % [V] Inversion Subnetwork Input Offset.
        delta_inversion_DEFAULT = 1e-6;                                                                                         % [V] Inversion Subnetwork Output Offset.

        c_division_DEFAULT = 1;                                                                                                 % [-] Division Subnetwork Gain.
        epsilon_division_DEFAULT = 1e-6;                                                                                        % [-] Division Subnetwork Offset.
        alpha_DEFAULT = 1e-6;                                                                                                   % [-] Subnetwork Denominator Adjustment

        
        c_multiplication_DEFAULT = 1;                                                                                           % [-] Multiplication Subnetwork Gain.
        
        c_derivation_DEFAULT = 1e6;                                                                                             % [-] Derivative Subnetwork Gain
        w_derivation_DEFAULT = 1;                                                                                               % [Hz?] Derivative Subnetwork Cutoff Frequency?
        sf_derivation_DEFAULT = 0.05;                                                                                           % [-] Derivative Subnetwork Safety Factor
        
        c_integration_mean_DEFAULT = 0.01e9;                                                                                    % [-] Average Integration Gain

        T_oscillation_DEFAULT = 2;                                                                                              % [s] Oscillation Period. 
        r_oscillation_DEFAULT = 0.90;                                                                                           % [-] Oscillation Decay.
                
    end
    
    
    %% NEURON MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_manager_class( neurons )
            
            % Create an instance of the array utilities class.
            self.array_utilities = array_utilities_class(  );
            
            % Create an instance of the data loader class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Create an instance of the neuron utilities class.
            self.neuron_utilities = neuron_utilities_class(  );
            
            % Set the default class properties.
            if nargin < 1, self.neurons = [  ]; else, self.neurons = neurons; end

            % Compute the number of neurons.
            self.num_neurons = length( self.neurons );
            
        end
        
        
        %% Neuron Index & ID Functions
        
        % Implement a function to retrieve the index associated with a given neuron ID.
        function neuron_index = get_neuron_index( self, neuron_ID )
            
            % Set a flag variable to indicate whether a matching neuron index has been found.
            b_match_found = false;
            
            % Initialize the neuron index.
            neuron_index = 0;
            
            while ( neuron_index < self.num_neurons ) && ( ~b_match_found )
                
                % Advance the neuron index.
                neuron_index = neuron_index + 1;
                
                % Check whether this neuron index is a match.
                if self.neurons( neuron_index ).ID == neuron_ID                       % If this neuron has the correct neuron ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the neuron index.
            if ~b_match_found                                                       % If a match was not found...
            
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                            % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No neuron with ID %0.0f.', neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                     % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No neuron with ID %0.0f.', neuron_ID )
                    
                    % Set the neuron index to negative one.
                    neuron_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                       % If the undetected option is set to 'ignore'...
                    
                    % Set the neuron index to negative one.
                    neuron_index = -1;                    
                    
                else                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
            
            end
            
        end
        
        
        % Implement a function to validate neuron IDs.
        function neuron_IDs = validate_neuron_IDs( self, neuron_IDs )
            
            % Determine whether we want get the desired neuron property from all of the neurons.
            if isa( neuron_IDs, 'char' )                                                      % If the neuron IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( neuron_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the neuron IDs.
                    neuron_IDs = zeros( 1, self.num_neurons );
                    
                    % Retrieve the neuron ID associated with each neuron.
                    for k = 1:self.num_neurons                   % Iterate through each neuron...
                        
                        % Store the neuron ID associated with the current neuron.
                        neuron_IDs(k) = self.neurons(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Neuron_IDs must be either an array of valid neuron IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to check if a proposed neuron ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_neuron_ID( self, neuron_ID )
            
            % Retrieve all of the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Determine whether the given neuron ID is one of the existing neuron IDs (if so, provide the matching logicals and indexes).
            [ b_match_found, match_logicals, match_indexes ] = self.array_utilities.is_value_in_array( neuron_ID, existing_neuron_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to check whether a proposed neuron ID is a unique natural.
        function b_unique_natural = unique_natural_neuron_ID( self, neuron_ID )

            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this neuron ID is unique.
            b_unique = self.unique_neuron_ID( neuron_ID );
            
            % Determine whether this neuron ID is a unique natural.
            if b_unique && ( neuron_ID > 0 ) && ( round( neuron_ID ) == neuron_ID )                     % If this neuron ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end

        
        % Implement a function to check if an array of proposed neuron IDs are unique.
        function [ b_uniques, match_logicals, match_indexes ] = unique_neuron_IDs( self, neuron_IDs )
            
            % Retrieve all of the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Determine whether the given neuron IDs are in the existing neuron IDs array (if so, provide the matching logicals and indexes).
            [ b_match_founds, match_logicals, match_indexes ] = self.array_utilities.are_values_in_array( neuron_IDs, existing_neuron_IDs );
            
            % Determine the uniqueness flags.
            b_uniques = ~b_match_founds;
            
        end
        
        
        % Implement a function to check if the existing neuron IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_neuron_IDs( self )
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Determine whether all entries are unique.
            if length( unique( neuron_IDs ) ) == self.num_neurons                    % If all of the neuron IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_neurons );
                
            else                                                                     % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_neurons );
                
                % Determine which neurons have duplicate IDs.
                for k1 = 1:self.num_neurons                          % Iterate through each neuron...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another neuron with the same ID.
                    while ( k2 < self.num_neurons ) && ( ~match_logicals(k1) ) && ( k1 ~= ( k2 + 1 ) )                    % While we haven't checked all of the neurons and we haven't found a match.
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this neuron is a match.
                        if self.neurons(k2).ID == neuron_IDs(k1)                              % If this neuron ID is a match...

                            % Set this match logical to true.
                            match_logicals(k1) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
                        
        end
        
        
        % Implement a function to generate a unique neuron ID.
        function neuron_ID = generate_unique_neuron_ID( self )
            
            % Retrieve the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Generate a unique neuron ID.
            neuron_ID = self.array_utilities.get_lowest_natural_number( existing_neuron_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique neuron IDs.
        function neuron_IDs = generate_unique_neuron_IDs( self, num_IDs )

            % Retrieve the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Preallocate an array to store the newly generated neuron IDs.
            neuron_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                           % Iterate through each of the new IDs...
            
                % Generate a unique neuron ID.
                neuron_IDs(k) = self.array_utilities.get_lowest_natural_number( [ existing_neuron_IDs, neuron_IDs( 1:(k - 1) ) ] );
            
            end
                
        end
        
        
        % Implement a function to enforce the uniqueness of the existing neuron IDs.
        function self = make_neuron_IDs_unique( self )
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Determine whether all entries are unique.
            if length( unique( neuron_IDs ) ) ~= self.num_neurons                    % If the neuron IDs are not unique...
                
                % Preallocate an array to store the unique neuron IDs.
                unique_neuron_IDs = zeros( 1, self.num_neurons );
                
                % Create an array of unique neuron IDs.
                for k = 1:self.num_neurons                  % Iterate through each neuron...
                    
                    % Determine whether this neuron ID is non-unique.
                    b_match_found = self.array_utilities.is_value_in_array( self.neurons(k).ID, unique_neuron_IDs );
                    
                    % Determine whether to keep this neuron ID or generate a new one.
                    if b_match_found                                                        % If this neuron ID already exists...
                       
                        % Generate a new neuron ID.
                        unique_neuron_IDs(k) = self.generate_unique_neuron_ID(  );

                        % Set the ID of this neuron.
                        self.neurons(k).ID = unique_neuron_IDs(k);
                        
                    else                                                                    % Otherwise...
                        
                        % Keep the existing neuron ID.
                        unique_neuron_IDs(k) = self.neurons(k).ID;
                        
                    end
                    
                end
                                
            end
            
        end
        
        
        % Implement a function to enforce the positivity of the existing neuron IDs.
        function self = make_neuron_IDs_positive( self )
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Ensure that all of the neuron IDs are positive.
            for k = 1:self.num_neurons                          % Iterate through each of the neurons...
                
               % Determine whether this neuron ID is non-positive.
               if self.neurons(k).ID <= 0                               % If this neuron ID is non-positive...
                  
                   % Generate a new unique ID for this neuron.
                   self.neurons(k).ID = self.array_utilities.get_lowest_natural_number( neuron_IDs );
                   
               end
                
            end
                        
        end
        
        
        % Implement a function to ensure that the neuron IDs are integers.
        function self = make_neuron_IDs_integers( self )
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Ensure that all of the neuron IDs are integers.
            for k = 1:self.num_neurons                          % Iterate through each of the neurons...
                
               % Determine whether this neuron ID is an integer.
               if round( self.neurons(k).ID ) ~= self.neurons(k).ID                               % If this neuron ID is not an integer...
                  
                   % Generate a new unique ID for this neuron.
                   self.neurons(k).ID = self.array_utilities.get_lowest_natural_number( neuron_IDs );
                   
               end
                
            end
                        
        end
        
        
        % Implement a function to ensure that the neuron IDs are natural numbers.
        function self = make_neuron_IDs_naturals( self )
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs(  );
            
            % Ensure that all of the neuron IDs are naturals.
            for k = 1:self.num_neurons                          % Iterate through each of the neurons...
                
               % Determine whether this neuron ID is natural.
               if ( round( self.neurons(k).ID ) ~= self.neurons(k).ID ) || ( self.neurons(k).ID <= 0 )                              % If this neuron ID is not a natural...
                  
                   % Generate a new unique ID for this neuron.
                   self.neurons(k).ID = self.array_utilities.get_lowest_natural_number( neuron_IDs );
                   
               end
                
            end
            
        end
        
        
        % Implement a function to ensure that the neuron IDs are natural numbers.
        function self = make_neuron_IDs_unique_naturals( self )
            
            % Ensure that all of the neuron IDs are naturals.
            for k = 1:self.num_neurons                          % Iterate through each of the neurons...
                
                % Retrieve all of the existing neuron IDs.
                neuron_IDs = self.get_all_neuron_IDs(  );
                          
                % Remove the kth entry.
                neuron_IDs(k) = [  ];
                
                % Determine whether this neuron ID is non-unique.
                b_match_found = self.array_utilities.is_value_in_array( self.neurons(k).ID, neuron_IDs );
                
               % Determine whether this neuron ID is natural.
               if ( round( self.neurons(k).ID ) ~= self.neurons(k).ID ) || ( self.neurons(k).ID <= 0 ) || b_match_found                             % If this neuron ID is not a unique natural...
                  
                   % Generate a new unique ID for this neuron.
                   self.neurons(k).ID = self.array_utilities.get_lowest_natural_number( neuron_IDs );
                   
               end
                
            end
            
        end
        
        
        % Implement a function to retrieve all of the neuron IDs.
        function neuron_IDs = get_all_neuron_IDs( self )
            
            % Preallocate a variable to store the neuron IDs.
            neuron_IDs = zeros( 1, self.num_neurons );
            
            % Retrieve the ID associated with each neuron.
            for k = 1:self.num_neurons
                
                neuron_IDs(k) = self.neurons(k).ID;
                
            end
            
        end
        
        
        % Implement a function to get all enabled neuron IDs.
        function neuron_IDs = get_enabled_neuron_IDs( self )
            
            % Preallocate an array to store the neuron IDs.
            neuron_IDs = zeros( 1, self.num_neurons );
            
            % Initialize a counter variable.
            k2 = 0;
            
            % Retrieve the IDs of the enabled neurons.
            for k1 = 1:self.num_neurons                       % Iterate through each of the neurons...
                
                % Determine whether to store this neuron ID.
                if self.neurons(k1).b_enabled                        % If this neuron is enabled...
                    
                    % Advance the counter variable.
                    k2 = k2 + 1;
                    
                    % Store this neuron ID.
                    neuron_IDs(k2) = self.neurons(k1).ID;
                    
                end
                
            end
            
            % Remove extra neuron IDs.
            neuron_IDs = neuron_IDs(1:k2);
            
        end
        
        
        %% General Get & Set Neuron Property Functions
        
        % Implement a function to retrieve the properties of specific neurons.
        function xs = get_neuron_property( self, neuron_IDs, neuron_property, as_matrix )
            
            % Set the default input arguments.
            if nargin < 4, as_matrix = false; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_properties_to_get = length( neuron_IDs );
            
            % Preallocate a variable to store the neuron properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given neuron property for each neuron.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.neurons(%0.0f).%s;', neuron_index, neuron_property );
                
                % Evaluate the given neuron property.
                eval( eval_str );
                
            end
            
            % Determine whether to convert the network properties to a matrix.
            if as_matrix                                    % If we want the neuron properties as a matrix instead of a cell...
               
                % Convert the neuron properties from a cell to a matrix.
                xs = cell2mat( xs );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific neurons.
        function self = set_neuron_property( self, neuron_IDs, neuron_property_values, neuron_property )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retreive the number of neuron IDs.
            num_neuron_IDs = length( neuron_IDs );
            
            % Retrieve the number of neuron property values.
            num_neuron_property_values = length( neuron_property_values );
            
            % Ensure that the provided neuron property values have the same length as the provided neuron IDs.
            if ( num_neuron_IDs ~= num_neuron_property_values )                                     % If the number of provided neuron IDs does not match the number of provided property values...
               
                % Determine whether to agument the property values.
                if num_neuron_property_values == 1                                                  % If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
                    neuron_property_values = neuron_property_values*ones( 1, num_neuron_IDs );
                    
                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided neuron propety values must match the number of provided neuron IDs, unless a single neuron property value is provided.' )
                    
                end
                
            end
            
            % Validate the neuron property values.
            if ~isa( neuron_property_values, 'cell' )                    % If the neuron property values are not a cell array...
                
                % Convert the neuron property values to a cell array.
                neuron_property_values = num2cell( neuron_property_values );
                
            end
            
            % Set the properties of each neuron.
            for k = 1:self.num_neurons                   % Iterate through each neuron...
                
                % Determine the index of the neuron property value that we want to apply to this neuron (if we want to set a property of this neuron).
                index = find( self.neurons(k).ID == neuron_IDs, 1 );
                
                % Determine whether to set a property of this neuron.
                if ~isempty( index )                         % If a matching neuron ID was detected...
                    
                    % Create an evaluation string that sets the desired neuron property.
                    eval_string = sprintf( 'self.neurons(%0.0f).%s = neuron_property_values{%0.0f};', k, neuron_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end

        
        %% Enable & Disable Functions
        
        % Implement a function to enable a neuron.
        function self = enable_neuron( self, neuron_ID )
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID );
            
            % Enable this neuron.
            self.neurons( neuron_index ).b_enabled = true;
            
        end
        
        
        % Implement a function to enable neurons.
        function self = enable_neurons( self, neuron_IDs )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
                        
            % Determine the number of neurons to enable.
            num_neurons_to_enable = length( neuron_IDs );
            
            % Enable all of the specified neurons.
            for k = 1:num_neurons_to_enable                      % Iterate through all of the specified neurons...
                
                % Enable this neuron.
                self = self.enable_neuron( neuron_IDs(k) );
                
            end
            
        end
        
        
        % Implement a function to disable a neuron.
        function self = disable_neuron( self, neuron_ID )
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID );
            
            % Disable this neuron.
            self.neurons( neuron_index ).b_enabled = false;
            
        end
        
        
        % Implement a function to disable neurons.
        function self = disable_neurons( self, neuron_IDs )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
                        
            % Determine the number of neurons to disable.
            num_neurons_to_enable = length( neuron_IDs );
            
            % Disable all of the specified neurons.
            for k = 1:num_neurons_to_enable                      % Iterate through all of the specified neurons...
                
                % Disable this neuron.
                self = self.disable_neuron( neuron_IDs(k) );
                
            end
            
        end
        
        
        % Implement a function to toggle neuron enable state.
        function self = toggle_enabled_neurons( self, neuron_IDs )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
                        
            % Determine the number of neurons to disable.
            num_neurons_to_enable = length( neuron_IDs );
            
            % Disable all of the specified neurons.
            for k = 1:num_neurons_to_enable                      % Iterate through all of the specified neurons...
                
                % Retrieve this neuron index.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Disable this neuron.
                self.neurons( neuron_index ).b_enabled = ~self.neurons( neuron_index ).b_enabled;
                
            end
            
        end
        
        
        %% Call Neuron Methods Functions
        
        % Implement a function to that calls a specified neuron method for each of the specified neurons.
        function self = call_neuron_method( self, neuron_IDs, neuron_method )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.neurons(%0.0f) = self.neurons(%0.0f).%s();', neuron_index, neuron_index, neuron_method );
                
                % Evaluate the given neuron method.
                eval( eval_str );
                
            end
            
        end
        
        
        %% Compute Multiplication-Division Subgain Functions

        % Implement a function to compute the absolute multiplication division subgain.
        function c2 = compute_absolute_multiplication_c2( self, c, c1, epsilon1, epsilon2, R2 )

            % Define the default input arguments.
            if nargin < 6, R2 = self.R_DEFAULT; end
            if nargin < 5, epsilon2 = self.epsilon_DEFAULT; end
            if nargin < 4, epsilon1 = self.epsilon_DEFAULT; end
            if nargin < 3, c1 = self.c_DEFAULT; end
            if nargin < 2, c = self.c_DEFAULT; end
            
            % Compute the division subnetwork gain.
            c2 = ( ( c*R2 )/( R2 + epsilon1 ) )*c1 + c*epsilon2*R2;
            
        end
                    
        
        %% Sodium Channel Conductance Compute & Set Functions
                
        % Implement a function to compute and set the sodium channel conductance for a two neuron CPG subnetwork for each neuron.
        function self = compute_set_cpg_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_cpg_Gna( self.neurons( neuron_index ).R, self.neurons( neuron_index ).Gm, self.neurons( neuron_index ).Am, self.neurons( neuron_index ).Sm, self.neurons( neuron_index ).dEm, self.neurons( neuron_index ).Ah, self.neurons( neuron_index ).Sh, self.neurons( neuron_index ).dEh, self.neurons( neuron_index ).dEna );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of driven multistate cpg neurons.
        function self = compute_set_driven_multistate_cpg_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_driven_multistate_cpg_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of transmission neurons.
        function self = compute_set_transmission_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_transmission_Gna(  );
                
            end
            
        end
        
                
        % Implement a function to compute and set the sodium channel conductance of modulation neurons.
        function self = compute_set_modulation_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_modulation_Gna(  );
                
            end
            
        end

        
        % Implement a function to compute and set the sodium channel conductance of addition neurons.
        function self = compute_set_addition_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_addition_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute addition neurons.
        function self = compute_set_absolute_addition_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative addition neurons.
        function self = compute_set_relative_addition_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of subtraction neurons.
        function self = compute_set_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute subtraction neurons.
        function self = compute_set_absolute_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative subtraction neurons.
        function self = compute_set_relative_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of double subtraction neurons.
        function self = compute_set_double_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_double_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute double subtraction neurons.
        function self = compute_set_absolute_double_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_double_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative double subtraction neurons.
        function self = compute_set_relative_double_subtraction_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_double_subtraction_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of multiplication neurons.
        function self = compute_set_multiplication_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_multiplication_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute multiplication neurons.
        function self = compute_set_absolute_multiplication_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_multiplication_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative multiplication neurons.
        function self = compute_set_relative_multiplication_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_multiplication_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of inversion neurons.
        function self = compute_set_inversion_Gna( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_inversion_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute inversion neurons.
        function self = compute_set_absolute_inversion_Gna( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative inversion neurons.
        function self = compute_set_relative_inversion_Gna( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of division neurons.
        function self = compute_set_division_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_division_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of absolute division neurons.
        function self = compute_set_absolute_division_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of relative division neurons.
        function self = compute_set_relative_division_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of derivation neurons.
        function self = compute_set_derivation_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_derivation_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of integration neurons.
        function self = compute_set_integration_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_integration_Gna(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of voltage based integration neurons.
        function self = compute_set_vb_integration_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_vb_integration_Gna(  );
                
            end
            
        end
                
        
        % Implement a function to compute and set the sodium channel conductance of split voltage based integration neurons.
        function self = compute_set_split_vb_integration_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_split_vb_integration_Gna(  );
                
            end
            
        end
        
        
        %% Membrane Conductance Compute & Set Functions
        
        % Implement a function to compute and set the membrane conductance of absolute addition input neurons.
        function self = compute_set_absolute_addition_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_Gm_input(  );
                                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute addition output neurons.
        function self = compute_set_absolute_addition_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );
            
            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_Gm_output(  );
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of relative addition input neurons.
        function self = compute_set_relative_addition_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_Gm_input(  );
                                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of relative addition output neurons.
        function self = compute_set_relative_addition_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );
                
            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_Gm_output(  );
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute subtraction input neurons.
        function self = compute_set_absolute_subtraction_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_Gm_input(  );
                                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute subtraction output neurons.
        function self = compute_set_absolute_subtraction_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_Gm_output(  );
            
        end

        
        % Implement a function to compute and set the membrane conductance of relative subtraction input neurons.
        function self = compute_set_relative_subtraction_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_Gm_input(  );
                                
            end
            
        end

       
        % Implement a function to compute and set the membrane conductance of relative subtraction output neurons.
        function self = compute_set_relative_subtraction_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_Gm_output(  );
                        
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute inversion input neurons.
        function self = compute_set_absolute_inversion_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the input neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ) );

            % Compute and set the membrane conductance for the input neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_Gm_input(  );
            
        end


        % Implement a function to compute and set the membrane conductance of absolute inversion output neurons.
        function self = compute_set_absolute_inversion_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_Gm_output(  );
                        
        end
        
        
        % Implement a function to compute and set the membrane conductance of relative inversion input neurons.
        function self = compute_set_relative_inversion_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the input neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ) );

            % Compute and set the membrane conductance for the input neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_Gm_input(  );
                        
        end

                
        % Implement a function to compute and set the membrane conductance of relative inversion output neurons.
        function self = compute_set_relative_inversion_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_Gm_output(  );
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute division input neurons.
        function self = compute_set_absolute_division_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_Gm_input(  );
                                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of absolute division output neurons.
        function self = compute_set_absolute_division_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_Gm_output(  );
            
        end
        

        % Implement a function to compute and set the membrane conductance of relative division input neurons.
        function self = compute_set_relative_division_Gm_input( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_Gm_input(  );
                                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of relative division output neurons.
        function self = compute_set_relative_division_Gm_output( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the membrane conductance for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_Gm_output(  );
            
        end
        
        
        % Implement a function to compute and set the membrane conductance of derivation neurons.
        function self = compute_set_derivation_Gm( self, neuron_IDs, k_gain, w, safety_factor )
            
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end                                  % [-] Derivative Subnetwork Safety Factor
            if nargin < 4, w = self.w_derivation_DEFAULT; end                                               % [Hz?] Derivative Subnetwork Cutoff Frequency
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end                                          % [-] Derivative Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                                  % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_derivation_Gm( k_gain, w, safety_factor );
                                
            end
            
        end
        
        
        %% Membrane Capacitance Compute & Set Functions
        
        % Implement a function to compute and set the membrane capacitance of transmission subnetwork neurons.
        function self = compute_set_transmission_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_transmission_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of slow transmission subnetwork neurons.
        function self = compute_set_slow_transmission_Cm( self, neuron_IDs, num_cpg_neurons, T, r )

            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end                                          % [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end                                          % [s] Oscillation Period
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                          % [#] Number of CPG Neurons
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_slow_transmission_Cm( self.neurons( neuron_index ).Gm, num_cpg_neurons, T, r );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of modulation subnetwork neurons.
        function self = compute_set_modulation_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_modulation_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of addition subnetwork neurons.
        function self = compute_set_addition_Cm( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_addition_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute addition subnetwork neurons.
        function self = compute_set_absolute_addition_Cm( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative subnetwork neurons.
        function self = compute_set_relative_addition_Cm( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of subtraction subnetwork neurons.
        function self = compute_set_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute subtraction subnetwork neurons.
        function self = compute_set_absolute_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative subtraction subnetwork neurons.
        function self = compute_set_relative_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of double subtraction subnetwork neurons.
        function self = compute_set_double_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_double_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute double subtraction subnetwork neurons.
        function self = compute_set_absolute_double_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_double_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative double subtraction subnetwork neurons.
        function self = compute_set_relative_double_subtraction_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_double_subtraction_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of multiplication subnetwork neurons.
        function self = compute_set_multiplication_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_multiplication_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute multiplication subnetwork neurons.
        function self = compute_set_absolute_multiplication_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_multiplication_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative multiplication subnetwork neurons.
        function self = compute_set_relative_multiplication_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_multiplication_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of inversion subnetwork neurons.
        function self = compute_set_inversion_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_inversion_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute inversion subnetwork neurons.
        function self = compute_set_absolute_inversion_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative inversion subnetwork neurons.
        function self = compute_set_relative_inversion_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of division subnetwork neurons.
        function self = compute_set_division_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_division_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of absolute division subnetwork neurons.
        function self = compute_set_absolute_division_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the membrane capacitance of relative division subnetwork neurons.
        function self = compute_set_relative_division_Cm( self, neuron_IDs )

            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_Cm(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the first membrane capacitance of derivation subnetwork neurons.
        function self = compute_set_derivation_Cm1( self, neuron_IDs, k_gain )
            
            % Set the default input arguments.            
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end                                  % [-] Derivative Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs

            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the membrane capacitance of the second neuron.
            Cm2 = cell2mat( self.get_neuron_property( neuron_IDs( 2 ), 'Cm' ) );            % [F] Membrane Capacitance
            Gm2 = cell2mat( self.get_neuron_property( neuron_IDs( 2 ), 'Gm' ) );            % [S] Membrane Conductance

            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ) );

            % Compute and set the membrane capacitance for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_derivation_Cm1( Gm2, Cm2, k_gain );

        end
        
        
        % Implement a function to compute and set the second memebrane capacitance of derivation subnetwork neurons.
        function self = compute_set_derivation_Cm2( self, neuron_IDs, w )
            
            % Set the default input arguments.            
            if nargin < 3, w = self.w_derivation_DEFAULT; end                                       % [Hz?] Derivative Subnetwork Cutoff Frequency?
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs

            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( 2 ) );

            % Compute and set the membrane capacitance for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_derivation_Cm2( self.neurons( neuron_index ).Gm, w );

        end
        
        
        % Implement a function to compute and set the membrane capacitance of integration neurons.
        function self = compute_set_integration_Cm( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                           % [-] Average Integration Mean
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_integration_Cm( ki_mean );
                
            end

        end
        
        
        % Implement a function to compute and set the membrane capacitance of voltage based integration neurons.
        function self = compute_set_vb_integration_Cm( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                               % [-] Average Integration Gain
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_vb_integration_Cm( ki_mean );
                
            end

        end
        
        
        % Implement a function to compute and set the first membrane capacitance of split voltage based integration neurons.
        function self = compute_set_split_vb_integration_Cm1( self, neuron_IDs, ki_mean )
            
            % Set the default input arguments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                               % [-] Average Integration Gain
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_split_vb_integration_Cm1( ki_mean );
                
            end

        end
        
        
        % Implement a function to compute and set the second membrane capacitance of split voltage based integration neurons.
        function self = compute_set_split_vb_integration_Cm2( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the membrane capacitance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_split_vb_integration_Cm2(  );
                
            end

        end
        
        
        %% Activation Domain Compute & Set Functions
        
        % Implement a function to compute and set the operational domain for absolute addition input neurons.
        function self = compute_set_absolute_addition_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute addition output neurons.
        function self = compute_set_absolute_addition_R_output( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the activation domains of the input neurons.
            Rs = cell2mat( self.get_neuron_property( neuron_IDs( 1:( end - 1 ) ) , 'R' ) );     % [V] Activation Domains
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );
            
            % Compute and set the activation domain for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_addition_R_output( Rs );
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative addition input neurons.
        function self = compute_set_relative_addition_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );                                % [-] Neuron IDs
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this input neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative addition output neurons.
        function self = compute_set_relative_addition_R_output( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_addition_R_output(  );
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute subtraction input neurons.
        function self = compute_set_absolute_subtraction_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this input neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute subtraction output neurons.
        function self = compute_set_absolute_subtraction_R_output( self, neuron_IDs, s_ks )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the activation domains of the input neurons.
            Rs = cell2mat( self.get_neuron_property( neuron_IDs( 1:( end - 1 ) ) , 'R' ) );     % [V] Activation Domain
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_subtraction_R_output( Rs, s_ks );
                        
        end
        
        
        % Implement a function to compute and set the operational domain for relative subtraction input neurons.
        function self = compute_set_relative_subtraction_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative subtraction output neurons.
        function self = compute_set_relative_subtraction_R_output( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_subtraction_R_output(  );
                        
        end
        
        
        % Implement a function to compute and set the sodium channel conductance of inversion neurons.
        function self = compute_set_absolute_inversion_R2( self, neuron_IDs, epsilon, k_gain )
        
            % Set the default input arguments.
            if nargin < 4, k_gain = self.c_inversion_DEFAULT; end                                       % [-] Inversion Subnetwork Gain
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end                                % [-] Inversion Subnetwork Offset
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_R2( epsilon, k_gain );
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute inversion input neurons.
        function self = compute_set_absolute_inversion_R_input( self, neuron_IDs, epsilon, delta )
        
            % Set the default input arguments.
            if nargin < 4, delta = self.delta_inversion_DEFAULT; end                        	% [-] Inversion Subnetwork Output Offset
            if nargin < 3, epsilon = self.epsilon_inversion_DEFAULT; end                      	% [-] Inversion Subnetwork Input Offset
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the input neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ) );

            % Compute and set the activation domain for the input neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_R_input( epsilon, delta );
            
        end
        
        
%         % Implement a function to compute and set the operational domain for absolute inversion output neurons.
%         function self = compute_set_absolute_inversion_R_output( self, neuron_IDs, c, epsilon )
%         
%             % Set the default input arguments.
%             if nargin < 4, epsilon = self.epsilon_inversion_DEFAULT; end                         	% [-] Inversion Subnetwork Offset
%             if nargin < 3, c = self.c_inversion_DEFAULT; end                                      % [-] Inversion Subnetwork Gain
%             if nargin < 2, neuron_IDs = 'all'; end                                                % [-] Neuron IDs
%             
%             % Validate the neuron IDs.
%             neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
%             
%             % Retrieve the index associated with this neuron ID.
%             neuron_index = self.get_neuron_index( neuron_IDs( end ) );
% 
%             % Compute and set the activation domain for this neuron.
%             self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_R_output( c, epsilon );
%             
%         end
        

        % Implement a function to compute and set the operational domain for absolute inversion output neurons.
        function self = compute_set_absolute_inversion_R_output( self, neuron_IDs, c, epsilon, delta )
        
            % Set the default input arguments.
            if nargin < 5, delta = self.delta_inversion_DEFAULT; end                          	% [-] Inversion Subnetwork Output Offset
            if nargin < 4, epsilon = self.epsilon_inversion_DEFAULT; end                      	% [-] Inversion Subnetwork Input Offset
            if nargin < 3, c = self.c_DEFAULT; end                                              % [-] Inversion Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for this neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_inversion_R_output( c, epsilon, delta );
            
        end

        
        % Implement a function to compute and set the operational domain for relative inversion input neurons.
        function self = compute_set_relative_inversion_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the input neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ) );

            % Compute and set the activation domain for the input neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_R_input(  );
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative inversion output neurons.
        function self = compute_set_relative_inversion_R_output( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with this output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for this output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_inversion_R_output(  );
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute division input neurons.
        function self = compute_set_absolute_division_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this input neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this input neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for absolute division output neurons.
        function self = compute_set_absolute_division_R_output( self, neuron_IDs, c, alpha, epsilon )
                    
            % Set the default input arguments.
            if nargin < 5, epsilon = self.epsilon_division_DEFAULT; end                        	% [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                                     	% [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.c_division_DEFAULT; end                                   	% [-] Division Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the numerator activation domain.
            R_numerator = cell2mat( self.get_neuron_property( neuron_IDs( 1 ) , 'R' ) );        % [V] Numerator Activation Domain

            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the action domain for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_absolute_division_R_output( c, alpha, epsilon, R_numerator );
                       
        end
        
        
        % Implement a function to compute and set the operational domain for relative division input neurons.
        function self = compute_set_relative_division_R_input( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this input neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Compute and set the activation domain for this input neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_R_input(  );
                
            end
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative division output neurons.
        function self = compute_set_relative_division_R_output( self, neuron_IDs )
        
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the output neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( end ) );

            % Compute and set the activation domain for the output neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_division_R_output(  );
            
        end
        
        
        % Implement a function to compute and set the operational domain for relative multiplication output neurons.
        function self = compute_set_relative_multiplication_R3( self, neuron_IDs, c, c1, c2, epsilon1, epsilon2 )
                 
            % Set the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_division_DEFAULT; end                                % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_inversion_DEFAULT; end                               % [-] Inversion Subnetwork Offset
            if nargin < 5, c2 = self.c_division_DEFAULT; end                                            % [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_inversion_DEFAULT; end                                           % [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_multiplication_DEFAULT; end                                       % [-] Multiplication Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the index associated with the third neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( 3 ) );

            % Compute and set the activation domain for the third neuron.
            self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_relative_multiplication_R3( c, c1, c2, epsilon1, epsilon2 );
            
        end
        
        
        %% Basic Neuron Creation & Deletion Functions
        
        % Implement a function to create a new neuron.
        function [ self, ID ] = create_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled )
            
            % Set the default neuron properties.
            if nargin < 25, b_enabled = true; end                                                               % [T/F] Neuron Enabled Flag
            if nargin < 24, I_total = self.Itotal_DEFAULT; end                                                  % [A] Total Current
            if nargin < 23, I_app = self.Iapp_DEFFAULT; end                                                     % [A] Applied Current
            if nargin < 22, I_tonic = self.Itonic_DEFAULT; end                                                  % [A] Tonic Current
            if nargin < 21, I_na = self.Ina_DEFAULT; end                                                        % [A] Sodium Channel Current
            if nargin < 20, I_syn = self.Isyn_DEFAULT; end                                                      % [A] Synaptic Current
            if nargin < 19, I_leak = self.Ileak_DEFAULT; end                                                    % [A] Leak Current
            if nargin < 18, Gna = self.Gna_DEFAULT; end                                                         % [S] Sodium Channel Conductance
            if nargin < 17, tauh_max = self.tauh_max_DEFAULT; end                                               % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEna = self.dEna_DEFAULT; end                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEh = self.dEh_DEFAULT; end                                                         % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Sh = self.Sh_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ah = self.Ah_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEm = self.dEm_DEFAULT; end                                                         % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sm = self.Sm_DEFAULT; end                                                           % [-] Sodium Channel Activation Slope
            if nargin < 10, Am = self.Am_DEFAULT; end                                                           % [-] Sodium Channel Activation Amplitude
            if nargin < 9, R = self.R_DEFAULT; end                                                              % [V] Activation Domain
            if nargin < 8, Er = self.Er_DEFAULT; end                                                            % [V] Membrane Equilibrium Potential
            if nargin < 7, Gm = self.Gm_DEFAULT; end                                                            % [S] Membrane Conductance
            if nargin < 6, Cm = self.Cm_DEFAULT; end                                                            % [F] Membrane Capacitance
            if nargin < 5, h = [  ]; end                                                                        % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, U = 0; end                                                                           % [V] Membrane Voltage
            if nargin < 3, name = ''; end                                                                       % [-] Neuron Name
            if nargin < 2, ID = self.generate_unique_neuron_ID(  ); end                                         % [#] Neuron ID
            
            % Ensure that this neuron ID is a unique natural.
            assert( self.unique_natural_neuron_ID( ID ), 'Proposed neuron ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the neuron class.
            neuron = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled );
            
            % Append this neuron to the array of existing neurons.
            self.neurons = [ self.neurons neuron ];
            
            % Increase the number of neurons counter.
            self.num_neurons = self.num_neurons + 1;
            
        end
        
        
        % Implement a function to create multiple neurons.
        function [ self, IDs ] = create_neurons( self, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds )
            
            % Determine whether number of neurons to create.
            if nargin > 2                                               % If more than just neuron IDs were provided...
                
                % Set the number of neurons to create to be the number of provided IDs.
                num_neurons_to_create = length( IDs );
                
            elseif nargin == 2                                          % If just the neuron IDs were provided...
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                % Determine who to interpret this number of IDs.
                if num_IDs == 1                                     % If the number of IDs is one...
                    
                    % Then create a number of neurons equal to the specific ID.  (i.e., in this case we are treating the single provided ID value as the number of neurons that we want to create.)
                    num_neurons_to_create = IDs;
                    
                    % Preallocate an array of IDs.
                    IDs = self.generate_unique_neuron_IDs( num_neurons_to_create );
                    
                else                                                % Otherwise... ( More than one ID was provided... )
                    
                    % Set the number of neurons to create to be the number of provided neuron IDs.
                    num_neurons_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1                                      % If no input arguments were provided... ( Beyond the default self argument.)
                
                % Set the number of neurons to create to one.
                num_neurons_to_create = 1;
                
            end
            
            % Set the default neuron properties.
            if nargin < 25, b_enableds = true( 1, num_neurons_to_create ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 24, I_totals = self.Itotal_DEFAULT*ones( 1, num_neurons_to_create ); end                                    % [A] Total Current
            if nargin < 23, I_apps = self.Iapp_DEFAULT*ones( 1, num_neurons_to_create ); end                                        % [A] Applied Current
            if nargin < 22, I_tonics = self.Itonic_DEFAULT*ones( 1, num_neurons_to_create ); end                                    % [A] Tonic Current
            if nargin < 21, I_nas = self.Ina_DEFAULT*ones( 1, num_neurons_to_create ); end                                          % [A] Sodium Channel Current
            if nargin < 20, I_syns = self.Isyn_DEFAULT*ones( 1, num_neurons_to_create ); end                                        % [A] Synaptic Current
            if nargin < 19, I_leaks = self.Ileak_DEFAULT*ones( 1, num_neurons_to_create ); end                                     % [A] Leak Current
            if nargin < 18, Gnas = self.Gna_DEFAULT*ones( 1, num_neurons_to_create ); end                                           % [S] Sodium Channel Conductance
            if nargin < 17, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, num_neurons_to_create ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEnas = self.dEna_DEFAULT*ones( 1, num_neurons_to_create ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEhs = self.dEh_DEFAULT*ones( 1, num_neurons_to_create ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Shs = self.Sh_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ahs = self.Ah_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEms = self.dEm_DEFAULT*ones( 1, num_neurons_to_create ); end                                          % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sms = self.Sm_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 10, Ams = self.Am_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 9, Rs = self.R_DEFAULT*ones( 1, num_neurons_to_create ); end                                                % [V] Activation Domain
            if nargin < 8, Ers = self.Er_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 7, Gms = self.Gm_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [S] Membrane Conductance
            if nargin < 6, Cms = self.Cm_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [F] Membrane Capacitance
            if nargin < 5, hs = repmat( { [  ] }, 1, num_neurons_to_create ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, Us = zeros( 1, num_neurons_to_create ); end                                                              % [V] Membrane Voltage
            if nargin < 3, names = repmat( { '' }, 1, num_neurons_to_create ); end                                                  % [-] Neuron Name
            if nargin < 2, IDs = self.generate_unique_neuron_IDs( num_neurons_to_create ); end                                      % [#] Neuron ID
            
            % Create each of the spcified neurons.
            for k = 1:num_neurons_to_create                         % Iterate through each of the neurons we want to create...
       
                % Create this neuron.
                self = self.create_neuron( IDs(k), names{k}, Us(k), hs{k}, Cms(k), Gms(k), Ers(k), Rs(k), Ams(k), Sms(k), dEms(k), Ahs(k), Shs(k), dEhs(k), dEnas(k), tauh_maxs(k), Gnas(k), I_leaks(k), I_syns(k), I_nas(k), I_tonics(k), I_apps(k), I_totals(k), b_enableds(k) );
            
            end
            
        end
        
        
        % Implement a function to delete a neuron.
        function self = delete_neuron( self, neuron_ID )
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID );
            
            % Remove this neuron from the array of neurons.
            self.neurons( neuron_index ) = [  ];
            
            % Decrease the number of neurons counter.
            self.num_neurons = self.num_neurons - 1;
            
        end
        
        
        % Implement a function to delete multiple neurons.
        function self = delete_neurons( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons to delete.
            num_neurons_to_delete = length( neuron_IDs );
            
            % Delete each of the specified neurons.
            for k = 1:num_neurons_to_delete                      % Iterate through each of the neurons we want to delete...
                
                % Delete this neuron.
                self = self.delete_neuron( neuron_IDs(k) );
                
            end
            
        end
        
       
        %% Subnetwork Neuron Creation Functions
                
        % Implement a function to create the neurons for a multistate CPG oscillator subnetwork.
        function [ self, neuron_IDs ] = create_multistate_cpg_neurons( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Determine whether to generate unique neuron IDs or use the specified neuron IDs.
            if length( num_cpg_neurons ) > 1                            % If more than one "number of cpg neurons" was specified...
            
                % Set the neuron IDs to be those specified by the first input argument. ( We assume that this variable is instead the IDs that we would like to use for the newly created neurons.)
                neuron_IDs = num_cpg_neurons;

            else                                                        % Otherwise...
                
                % Generate unique neuron IDs for the multistate CPG subnetwork.
                neuron_IDs = self.generate_unique_neuron_IDs( num_cpg_neurons );

            end
                
            % Create the multistate cpg subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Edit the network properties.
            for k = 1:num_cpg_neurons                              % Iterate through each of the CPG neurons (from which the synapses are starting)...
                
                % Get the index associated with this neuron.
                neuron_index = self.get_neuron_index( neuron_IDs( k ) );
                
                % Set this neurons name.
                self.neurons( neuron_index ).name = sprintf( 'Neuron %0.0f', neuron_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to create the neurons for a multistate CPG oscillator subnetwork.
        function [ self, neuron_IDs ] = create_driven_multistate_cpg_neurons( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the neurons for a multistate cpg subnetwork.
            [ self, neuron_IDs_cpg ] = self.create_multistate_cpg_neurons( num_cpg_neurons );
            
            % Create an additional neuron to drive the multistate cpg.
            [ self, neuron_ID_drive ] = self.create_neuron(  );
           
            % Set the name of the drive neuron.
            self = self.set_neuron_property( neuron_ID_drive, { 'CPG Drive' }, 'name' );
            
            % Concatenate the neuron IDs.
            neuron_IDs = [ neuron_IDs_cpg, neuron_ID_drive ];
            
        end
        
            
        % Implement a function to create the neurons for a driven multistate cpg split lead lag subnetwork.
        function [ self, neuron_IDs_cell ] = create_dmcpg_sll_neurons( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Preallocat a cell array to store the neuron IDs.
            neuron_IDs_cell = cell( 1, num_cpg_neurons + 3 );
            
            % Create the driven multistate cpg subnetwork neurons.
            [ self, neuron_IDs_cell{ 1 } ] = self.create_driven_multistate_cpg_neurons( num_cpg_neurons );
            [ self, neuron_IDs_cell{ 2 } ] = self.create_driven_multistate_cpg_neurons( num_cpg_neurons );

            % Create the modulated split subtraction voltage based integration subnetwork neurons for each pair of driven multistate cpg neurons.
            for k = 1:num_cpg_neurons                               % Iterate through each of the cpg neurons...
                
                % Create the modulated split difference voltage based integration subnetwork neurons.
                [ self, neuron_IDs_cell{ k + 2 } ] = self.create_mod_split_sub_vb_integration_neurons(  );
            
            end
            
            % Create the unique driven multistate cpg split lead lag neurons.
            [ self, neuron_IDs_cell{ end } ] = self.create_neurons( self.num_dmcpg_sll_neurons_DEFAULT );

            % Set the names of these addition neurons.
            self = self.set_neuron_property( neuron_IDs_cell{ end }, { 'Fast Lead', 'Fast Lag', 'Slow Lead', 'Slow Lag' }, 'name' );

        end
        
        
        % Implement a function to create the neurons for a driven multistate cpg double centered lead lag subnetwork.
        function [ self, neuron_IDs_cell ] = create_dmcpg_dcll_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the neurons for a driven multistate cpg split lead lag subnetwork.
            [ self, neuron_IDs_dmcpgsll ] = self.create_dmcpg_sll_neurons( num_cpg_neurons );
            
            % Create the neurons for a double centering subnetwork.
            [ self, neuron_IDs_dc ] = self.create_double_centering_neurons(  );
           
            % Concatenate the neuron IDs.
            neuron_IDs_cell = { neuron_IDs_dmcpgsll, neuron_IDs_dc };

        end
        
        
        % Implemenet a function to create the neurons that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the double centered subtraction subnetwork.
        function [ self, neuron_ID ] = create_dmcpgdcll2cds_neuron( self )

            % Create the desired lead lag input neuron.
            [ self, neuron_ID ] = self.create_neuron(  );
            
            % Set the name of this neuron.
            self = self.set_neuron_property( neuron_ID, { 'Desired Lead / Lag' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function [ self, neuron_IDs_cell ] = create_ol_dmcpg_dclle_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the neurons for a driven multistate cpg double centered lead lag subnetwork.
            [ self, neuron_IDs_dmcpgdcll ] = self.create_dmcpg_dcll_neurons( num_cpg_neurons );
        
            % Create the neurons for a centered double subtraction subnetwork.
            [ self, neuron_IDs_cds ] = self.create_centered_double_subtraction_neurons(  );
            
            % Create the neurons that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the double centered subtraction subnetwork.
            [ self, neuron_IDs_dmcpgdcll2cds ] = self.create_dmcpgdcll2cds_neuron(  );
            
            % Concatenate the neuron IDs.
            neuron_IDs_cell = { neuron_IDs_dmcpgdcll, neuron_IDs_cds, neuron_IDs_dmcpgdcll2cds };
            
        end
        
        
        % Implement a function to create the neurons for an closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
        function [ self, neuron_IDs_cell ] = create_clpc_dmcpg_dcll_neurons( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
            [ self, neuron_IDs_cell ] = self.create_ol_dmcpg_dclle_neurons( num_cpg_neurons );
            
        end
        
        
        % Implement a function to create the neurons for a transmission subnetwork.
        function [ self, neuron_IDs ] = create_transmission_neurons( self )
                
            % Create the transmission subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_transmission_neurons_DEFAULT );
            
            % Set the names of the transmission subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Trans 1', 'Trans 2' }, 'name'  );

        end
        
            
        % Implement a function to create the neurons for a modulation subnetwork.
        function [ self, neuron_IDs ] = create_modulation_neurons( self )

            % Create the modulation subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_modulation_neurons_DEFAULT );
            
            % Set the names of the modulation subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Mod 1', 'Mod 2' }, 'name'  );
                 
        end
        
        
        % Implement a function to create the neurons for an addition subnetwork.
        function [ self, neuron_IDs ] = create_addition_neurons( self )
 
            % Create the addition subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_addition_neurons_DEFAULT );
            
            % Set the names of the addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Add 1', 'Add 2', 'Sum' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for an absolute addition subnetwork.
        function [ self, neuron_IDs ] = create_absolute_addition_neurons( self, num_addition_neurons )
 
            % Define the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end
            
            % Create the absolute addition subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_addition_neurons );
            
            % Set hte names of the absolute addition subnetwork neurons.
            for k = 1:( num_addition_neurons - 1 )                  % Iterate through each of the subnetwork input neurons...
            
                % Set the name of this absolute addition subnetwork input neuron.
                self = self.set_neuron_property( neuron_IDs( k ), { sprintf( 'Absolute Addition Input %0.0f', k ) }, 'name' );
                
            end
            
            % Set the names of the absolute addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs( end ), { 'Absolute Addition Output' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for a relative addition subnetwork.
        function [ self, neuron_IDs ] = create_relative_addition_neurons( self, num_addition_neurons )
 
            % Define the default input arguments.
            if nargin < 2, num_addition_neurons = self.num_addition_neurons_DEFAULT; end
            
            % Create the relative addition subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_addition_neurons );
            
            % Set hte names of the relative addition subnetwork neurons.
            for k = 1:( num_addition_neurons - 1 )                  % Iterate through each of the subnetwork input neurons...
            
                % Set the name of this relative addition subnetwork input neuron.
                self = self.set_neuron_property( neuron_IDs( k ), { sprintf( 'Relative Addition Input %0.0f', k ) }, 'name' );
                
            end
            
            % Set the names of the relative addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs( end ), { 'Relative Addition Output' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for a multi absolute addition subnetwork.
        function [ self, neuron_IDs ] = create_multi_absolute_addition_neurons( self, num_inputs )
 
            % Set the default input arguments.
            if nargin < 2, num_inputs = 2; end
            
            % Create the absolute addition subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_inputs + 1 );
            
            % Create a variable to store the input names.
            input_names = cell( 1, num_inputs );
            
            % Create the input names.
            for k = 1:num_inputs                % Iterate through each of the inputs...
                
                % Create this input name.
                input_names{ k } = sprintf( 'Abs Add In %0.0f', k );
                
            end
            
            % Set the names of the absolute addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, [ input_names, 'Abs Sum' ], 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a multi relative addition subnetwork.
        function [ self, neuron_IDs ] = create_multi_relative_addition_neurons( self, num_inputs )
 
            % Set the default input arguments.
            if nargin < 2, num_inputs = 2; end
            
            % Create the relative addition subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_inputs + 1 );
            
            % Create a variable to store the input names.
            input_names = cell( 1, num_inputs );
            
            % Create the input names.
            for k = 1:num_inputs                % Iterate through each of the inputs...
                
                % Create this input name.
                input_names{ k } = sprintf( 'Rel Add In %0.0f', k );
                
            end
            
            % Set the names of the relative addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, [ input_names, 'Rel Sum' ], 'name'  );
            
        end
        
            
        % Implement a function to create the neurons for a subtraction subnetwork.
        function [ self, neuron_IDs ] = create_subtraction_neurons( self )
                
            % Create the subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_subtraction_neurons_DEFAULT );
            
            % Set the names of the subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Sub 1', 'Sub 2', 'Sub 3' }, 'name'  );

        end
        
        
        % Implement a function to create the neurons for an absolute subtraction subnetwork.
        function [ self, neuron_IDs ] = create_absolute_subtraction_neurons( self, num_subtraction_neurons )
                
            % Define the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end
            
            % Create the absolute subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_subtraction_neurons );
            
            % Set hte names of the absolute subtraction subnetwork neurons.
            for k = 1:( num_subtraction_neurons - 1 )                  % Iterate through each of the subnetwork input neurons...
            
                % Set the name of this absolute subtraction subnetwork input neuron.
                self = self.set_neuron_property( neuron_IDs( k ), { sprintf( 'Absolute Subtraction Input %0.0f', k ) }, 'name' );
                
            end
            
            % Set the names of the absolute subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs( end ), { 'Absolute Subtraction Output' }, 'name' );

        end
        
        
        % Implement a function to create the neurons for a relative subtraction subnetwork.
        function [ self, neuron_IDs ] = create_relative_subtraction_neurons( self, num_subtraction_neurons )
                
            % Define the default input arguments.
            if nargin < 2, num_subtraction_neurons = self.num_subtraction_neurons_DEFAULT; end
            
            % Create the relative subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_subtraction_neurons );
            
            % Set hte names of the relative subtraction subnetwork neurons.
            for k = 1:( num_subtraction_neurons - 1 )                  % Iterate through each of the subnetwork input neurons...
            
                % Set the name of this relative subtraction subnetwork input neuron.
                self = self.set_neuron_property( neuron_IDs( k ), { sprintf( 'Relative Subtraction Input %0.0f', k ) }, 'name' );
                
            end
            
            % Set the names of the relative subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs( end ), { 'Relative Subtraction Output' }, 'name' );

        end
        
        
        % Implement a function to create the neurons for a multi absolute subtraction subnetwork.
        function [ self, neuron_IDs ] = create_multi_absolute_subtraction_neurons( self, num_inputs )
 
            % Set the default input arguments.
            if nargin < 2, num_inputs = 2; end
            
            % Create the absolute subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_inputs + 1 );
            
            % Create a variable to store the input names.
            input_names = cell( 1, num_inputs );
            
            % Create the input names.
            for k = 1:num_inputs                % Iterate through each of the inputs...
                
                % Create this input name.
                input_names{ k } = sprintf( 'Abs Sub In %0.0f', k );
                
            end
            
            % Set the names of the multi absolute subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, [ input_names, 'Abs Diff' ], 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a multi relative subtraction subnetwork.
        function [ self, neuron_IDs ] = create_multi_relative_subtraction_neurons( self, num_inputs )
 
            % Set the default input arguments.
            if nargin < 2, num_inputs = 2; end
            
            % Create the multi relative subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( num_inputs + 1 );
            
            % Create a variable to store the input names.
            input_names = cell( 1, num_inputs );
            
            % Create the input names.
            for k = 1:num_inputs                % Iterate through each of the inputs...
                
                % Create this input name.
                input_names{ k } = sprintf( 'Rel Sub In %0.0f', k );
                
            end
            
            % Set the names of the multi relative subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, [ input_names, 'Rel Diff' ], 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a double subtraction subnetwork.
        function [ self, neuron_IDs ] = create_double_subtraction_neurons( self )
                
            % Create the double subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_double_subtraction_neurons_DEFAULT );
            
            % Set the names of the double subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4' }, 'name'  );

        end
        
        
        % Implement a function to create the neurons for an absolute double subtraction subnetwork.
        function [ self, neuron_IDs ] = create_absolute_double_subtraction_neurons( self )
                
            % Create the absolute double subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_double_subtraction_neurons_DEFAULT );
            
            % Set the names of the absolute double subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Abs Sub 1', 'Abs Sub 2', 'Abs Sub 3', 'Abs Sub 4' }, 'name'  );

        end
        
        
        % Implement a function to create the neurons for a relative double subtraction subnetwork.
        function [ self, neuron_IDs ] = create_relative_double_subtraction_neurons( self )
                
            % Create the relative double subtraction subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_double_subtraction_neurons_DEFAULT );
            
            % Set the names of the relative double subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Rel Sub 1', 'Rel Sub 2', 'Rel Sub 3', 'Rel Sub 4' }, 'name'  );

        end
        
        
        % Implement a function to create the neurons for a centering subnetwork.
        function [ self, neuron_IDs ] = create_centering_neurons( self )
            
            % Create the centering subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_centering_neurons_DEFAULT );
            
            % Set the names of the centering subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Center 1', 'Center 2', 'Center 3', 'Center 4', 'Center 5' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for a double centering subnetwork.
        function [ self, neuron_IDs ] = create_double_centering_neurons( self )
            
            % Create the centering subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_double_centering_neurons_DEFAULT );
            
            % Set the names of the centering subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Center 1', 'Center 2', 'Center 3', 'Center 4', 'Center 5', 'Center 6', 'Center 7' }, 'name' );
            
        end

        
        % Implement a function to create the neurons for a centered double subtraction subnetwork.
        function [ self, neuron_IDs_cell ] = create_centered_double_subtraction_neurons( self )
            
            % Create the double subtraction subnetwork neurons.
            [ self, neuron_IDs_double_subtraction ] = self.create_double_subtraction_neurons(  );
            
            % Create the double centering subnetwork neurons.
            [ self, neuron_IDs_double_centering ] = self.create_double_centering_neurons(  );
            
            % Concatenate the neuron IDs.
            neuron_IDs_cell = { neuron_IDs_double_subtraction, neuron_IDs_double_centering };
            
        end
        
        
        % Implement a function to create the neurons for a multiplication subnetwork.
        function [ self, neuron_IDs ] = create_multiplication_neurons( self )

            % Create the multiplication subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_multiplication_neurons_DEFAULT );
            
            % Set the names of the multiplication subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Mult1', 'Mult2', 'Mult Inter', 'Prod' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for an absolute multiplication subnetwork.
        function [ self, neuron_IDs ] = create_absolute_multiplication_neurons( self )

            % Create the absolute multiplication subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_multiplication_neurons_DEFAULT );
            
            % Set the names of the absolute multiplication subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Absolute Multiplication Input 1', 'Absolute Multiplication Input 2', 'Absolute Multiplication Interneuron', 'Absolute Multiplication Output' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a relative multiplication subnetwork.
        function [ self, neuron_IDs ] = create_relative_multiplication_neurons( self )

            % Create the relative multiplication subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_multiplication_neurons_DEFAULT );
            
            % Set the names of the relative multiplication subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Relative Multiplication Input 1', 'Relative Multiplication Input 2', 'Relative Multiplication Interneuron', 'Relative Multiplication Output' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for an inversion subnetwork.
        function [ self, neuron_IDs ] = create_inversion_neurons( self )
            
            % Create the inversion subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_inversion_neurons_DEFAULT );
            
            % Set the names of the inversion subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Inv In', 'Inv Out' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for an absolute inversion subnetwork.
        function [ self, neuron_IDs ] = create_absolute_inversion_neurons( self )
            
            % Create the absolute inversion subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_inversion_neurons_DEFAULT );
            
            % Set the names of the absolute inversion subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Absolute Inversion Input', 'Absolute Inversion Output' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for a relative inversion subnetwork.
        function [ self, neuron_IDs ] = create_relative_inversion_neurons( self )
            
            % Create the relative inversion subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_inversion_neurons_DEFAULT );
            
            % Set the names of the relative inversion subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Relative Inversion Input', 'Relative Inversion Output' }, 'name' );
            
        end
        
        
        % Implement a function to create the neurons for a division subnetwork.
        function [ self, neuron_IDs ] = create_division_neurons( self )
                
            % Create the division subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_division_neurons_DEFAULT );
            
            % Set the names of the division subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Division Numerator', 'Division Denominator', 'Division Output' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for an absolute division subnetwork.
        function [ self, neuron_IDs ] = create_absolute_division_neurons( self )
                
            % Create the absolute division subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_division_neurons_DEFAULT );
            
            % Set the names of the absolute division subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Absolute Division Numerator', 'Absolute Division Denominator', 'Absolute Division Output' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a relative division subnetwork.
        function [ self, neuron_IDs ] = create_relative_division_neurons( self )
                
            % Create the relative division subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_division_neurons_DEFAULT );
            
            % Set the names of the relative division subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Relative Division Numerator', 'Relative Division Denominator', 'Relative Division Output' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for a derivation subnetwork.
        function [ self, neuron_IDs ] = create_derivation_neurons( self )

            % Create the derivation subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_derivation_neurons_DEFAULT );
            
            % Set the names of the derivation subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Der 1', 'Der 2', 'Der 3' }, 'name'  );
            
        end
        
        
        % Implement a function to create the neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_integration_neurons( self )

            % Create the integration subnetwork neurons.
            [ self, neuron_IDs ] = self.create_neurons( self.num_integration_neurons_DEFAULT );
            
            % Set the names of the integration subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Int 1', 'Int 2' }, 'name'  );
            
        end
        
        
        % Implement a function to create the voltage based neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_vb_integration_neurons( self )
            
            % Create the voltage based integration subnetwork neurons..
            [ self, neuron_IDs ] = self.create_neurons( self.num_vb_integration_neurons_DEFAULT );
            
            % Set the names of the voltage based integration subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Pos', 'Neg', 'Int 1', 'Int 2' }, 'name' );
            
        end
        
        
        % Implement a function to create the split voltage based neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_split_vb_integration_neurons( self )
            
            % Create the split voltage based integration subnetwork neurons..
            [ self, neuron_IDs ] = self.create_neurons( self.num_split_vb_integration_neurons_DEFAULT );
            
            % Set the names of the split voltage based integration subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs, { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1' }, 'name' );
            
        end
        
        
        % Implement a function to create the modulated split voltage based neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_mod_split_vb_integration_neurons( self )
            
            % Create the split voltage based integration neurons.
            [ self, neuron_IDs1 ] = self.create_split_vb_integration_neurons(  );            
            
            % Create the modulated split voltage based integration subnetwork neurons..
            [ self, neuron_IDs2 ] = self.create_neurons( self.num_mod_split_vb_integration_neurons_DEFAULT );
            
            % Set the names of the modulated split voltage based integration subnetwork neurons.
            self = self.set_neuron_property( neuron_IDs2, { 'Mod 1', 'Mod 2', 'Mod 3' }, 'name' );
            
            % Concatenate the neuron IDs.
            neuron_IDs = [ neuron_IDs1 neuron_IDs2 ];
            
        end
                
        
        % Implement a function to create the modulated split difference voltage based neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_mod_split_sub_vb_integration_neurons( self )
            
            % Create the double subtraction neurons.
            [ self, neuron_IDs1 ] = self.create_double_subtraction_neurons(  );
            
            % Create the modulated split voltage based integration neurons.
            [ self, neuron_IDs2 ] = self.create_mod_split_vb_integration_neurons(  );
            
            % Concatenate the neuron IDs.
            neuron_IDs = [ neuron_IDs1 neuron_IDs2 ];
            
        end
        
        
        %% Subnetwork Neuron Design Functions
        
        % Implement a function to design the neurons for a multistate cpg subnetwork.
        function self = design_multistate_cpg_neurons( self, neuron_IDs )
        
            % Set the sodium channel conductance of every neuron in the network using the CPG approach.
            self = self.compute_set_cpg_Gna( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg subnetwork.
        function self = design_driven_multistate_cpg_neurons( self, neuron_IDs )
        
            % Compute and set the sodium channel conductance of the driven multistate cpg neuron.
            self = self.compute_set_driven_multistate_cpg_Gna( neuron_IDs );
            
        end
        

        % Implement a function to design the neurons for a transmission subnetwork.
        function self = design_transmission_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the transmission subnetwork neurons.
            self = self.compute_set_transmission_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the transmission subnetwork neurons.
            self = self.compute_set_transmission_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a slow transmission subnetwork.
        function self = design_slow_transmission_neurons( self, neuron_IDs, num_cpg_neurons, T, r )
           
            % Set the default input arguments.
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, T = self.T_oscillation_DEFAULT; end
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end

            % Compute and set the sodium channel conductance of the transmission subnetwork neurons.
            self = self.compute_set_transmission_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the transmission subnetwork neurons.
            self = self.compute_set_slow_transmission_Cm( neuron_IDs, num_cpg_neurons, T, r );
            
        end
        
        
        % Implement a function to design the neurons for a modulation subnetwork.
        function self = design_modulation_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the modulation subnetwork neurons.
            self = self.compute_set_modulation_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the modulation subnetwork neurons.
            self = self.compute_set_modulation_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an addition subnetwork.
        function self = design_addition_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the addition subnetwork neurons.
            self = self.compute_set_addition_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the addition subnetwork neurons.
            self = self.compute_set_addition_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute addition subnetwork.
        function self = design_absolute_addition_neurons( self, neuron_IDs )
           
            % Define the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                          % [-] Neuron IDs
            
            % Compute and set the sodium channel conductance of the absolute addition subnetwork neurons.
            self = self.compute_set_absolute_addition_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the absolute addition subnetwork neurons.
            self = self.compute_set_absolute_addition_Gm_input( neuron_IDs );
            self = self.compute_set_absolute_addition_Gm_output( neuron_IDs );

            % Compute and set the membrane capacitance of the absolute addition subnetwork neurons.
            self = self.compute_set_absolute_addition_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the absolute addition subnetwork neurons.
            self = self.compute_set_absolute_addition_R_input( neuron_IDs );
            self = self.compute_set_absolute_addition_R_output( neuron_IDs );

        end
        
        
        % Implement a function to design the neurons for a relative addition subnetwork.
        function self = design_relative_addition_neurons( self, neuron_IDs )
           
            % Define the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                          % [-] Neuron IDs
            
            % Compute and set the sodium channel conductance of the relative addition subnetwork neurons.
            self = self.compute_set_relative_addition_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the relative addition subnetwork neurons.
            self = self.compute_set_relative_addition_Gm_input( neuron_IDs );
            self = self.compute_set_relative_addition_Gm_output( neuron_IDs );

            % Compute and set the membrane capacitance of the relative addition subnetwork neurons.
            self = self.compute_set_relative_addition_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the relative addition subnetwork neurons.
            self = self.compute_set_relative_addition_R_input( neuron_IDs );
            self = self.compute_set_relative_addition_R_output( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a subtraction subnetwork.
        function self = design_subtraction_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the subtraction subnetwork neurons.
            self = self.compute_set_subtraction_Gna( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the subtraction subnetwork neurons.
            self = self.compute_set_subtraction_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute subtraction subnetwork.
        function self = design_absolute_subtraction_neurons( self, neuron_IDs, s_ks )
           
            % Define the default input arguments.
            if nargin < 3, s_ks = [ 1, -1 ]; end                                                              % [-] Absolute Subtraction Subnetwork Excitatory / Inhibitory Signs
            if nargin < 2, neuron_IDs = 'all'; end                                                          % [-] Neuron IDs
            
            % Compute and set the sodium channel conductance of the absolute subtraction subnetwork neurons.
            self = self.compute_set_absolute_subtraction_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the absolute subtraction subnetwork neurons.
            self = self.compute_set_absolute_subtraction_Gm_input( neuron_IDs );
            self = self.compute_set_absolute_subtraction_Gm_output( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the absolute subtraction subnetwork neurons.
            self = self.compute_set_absolute_subtraction_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the absolute subtraction subnetwork neurons.
            self = self.compute_set_absolute_subtraction_R_input( neuron_IDs );
            self = self.compute_set_absolute_subtraction_R_output( neuron_IDs, s_ks );

        end
        
        
        % Implement a function to design the neurons for a relative subtraction subnetwork.
        function self = design_relative_subtraction_neurons( self, neuron_IDs )
           
            % Define the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end                                                          % [-] Neuron IDs
            
            % Compute and set the sodium channel conductance of the relative subtraction subnetwork neurons.
            self = self.compute_set_relative_subtraction_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the relative subtraction subnetwork neurons.
            self = self.compute_set_relative_subtraction_Gm_input( neuron_IDs );
            self = self.compute_set_relative_subtraction_Gm_output( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the relative subtraction subnetwork neurons.
            self = self.compute_set_relative_subtraction_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the relative subtraction subnetwork neurons.
            self = self.compute_set_relative_subtraction_R_input( neuron_IDs );
            self = self.compute_set_relative_subtraction_R_output( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a double subtraction subnetwork.
        function self = design_double_subtraction_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the double subtraction subnetwork neurons.
            self = self.compute_set_double_subtraction_Gna( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the double subtraction subnetwork neurons.
            self = self.compute_set_double_subtraction_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute double subtraction subnetwork.
        function self = design_absolute_double_subtraction_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the absolute double subtraction subnetwork neurons.
            self = self.compute_set_absolute_double_subtraction_Gna( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the absolute double subtraction subnetwork neurons.
            self = self.compute_set_absolute_double_subtraction_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a relative double subtraction subnetwork.
        function self = design_relative_double_subtraction_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the relative double subtraction subnetwork neurons.
            self = self.compute_set_relative_double_subtraction_Gna( neuron_IDs );
            
            % Compute and set the sodium channel conductance of the relative double subtraction subnetwork neurons.
            self = self.compute_set_relative_double_subtraction_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a multiplication subnetwork.
        function self = design_multiplication_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the multiplication subnetwork neurons.
            self = self.compute_set_multiplication_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the multiplication subnetwork neurons.
            self = self.compute_set_multiplication_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for an absolute multiplication subnetwork.
        function self = design_absolute_multiplication_neurons( self, neuron_IDs, c, c1, alpha, epsilon1, epsilon2 )
           
            % Define the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                                 % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                                 % [-] Inversion Subnetwork Offset
            if nargin < 5, alpha = self.alpha_DEFAULT; end                                                      % [-] Division Subnetwork Denominator Adjustment
            if nargin < 4, c1 = self.c_DEFAULT; end                                                             % [-] Division Subnetwork Gain
            if nargin < 3, c = self.c_DEFAULT; end                                                              % [-] Inversion Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                                              % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Design the absolute inversion subnetwork neurons.
            self = self.design_absolute_inversion_neurons( neuron_IDs( 2:3 ), c1, epsilon1 );
            
            % Compute the absolute division subnetwork gain.
            c2 = self.compute_absolute_multiplication_c2( c, c1, epsilon1, epsilon2, R2 );

            % Design the absolute division subnetwork neurons.
            self = self.design_absolute_division_neurons( neuron_IDs( [ 1, 3, 4 ] ), c2, alpha, epsilon2 );
            
        end
        
        
        % Implement a function to design the neurons for a relative multiplication subnetwork.
        function self = design_relative_multiplication_neurons( self, neuron_IDs, c, c1, c2, epsilon1, epsilon2 )
           
            % Define the default input arguments.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                                 % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                                 % [-] Inversion Subnetwork Offset
            if nargin < 5, c2 = self.c_DEFAULT; end                                                             % [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_DEFAULT; end                                                             % [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_DEFAULT; end                                                              % [-] Multiplication Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                                              % [-] Neuron IDs
            
            % Design the relative inversion subnetwork neurons.
            self  = self.design_relative_inversion_neurons( neuron_IDs );
            
            % Design the relative division subnetwork neurons.
            self = self.design_relative_division_neurons( neuron_IDs );
            
            % Update the inversion subnetwork output neuron activation domain.
            self = self.compute_set_relative_multiplication_R3( neuron_IDs( 3 ), c, c1, c2, epsilon1, epsilon2 );
            
        end
        

        % Implement a function to design the neurons for an absolute inversion subnetwork.
        function self = design_absolute_inversion_neurons( self, neuron_IDs, c, epsilon, delta )
        
            % Set the default input arguments.
            if nargin < 5, delta = self.delta_inversion_DEFAULT; end                        	% [-] Inversion Subnetwork Output Offset
            if nargin < 4, epsilon = self.epsilon_inversion_DEFAULT; end                      	% [-] Inversion Subnetwork Input Offset
            if nargin < 3, c = self.c_DEFAULT; end                                              % [-] Inversion Subnetwork Gain
            
            % Compute and set the sodium channel conductance of the absolute inversion subnetwork neurons.
            self = self.compute_set_absolute_inversion_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the absolute inversion subnetwork neurons.
            self = self.compute_set_absolute_inversion_Gm_input( neuron_IDs );
            self = self.compute_set_absolute_inversion_Gm_output( neuron_IDs );
            
            % Compute and set the membrane capacitance for the absolute inversion subnetwork neurons.
            self = self.compute_set_absolute_inversion_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the absolute inversion subnetwork neurons.
            self = self.compute_set_absolute_inversion_R_input( neuron_IDs, epsilon, delta );
            self = self.compute_set_absolute_inversion_R_output( neuron_IDs, c, epsilon, delta );
            
        end

        
        % Implement a function to design the neurons for a relative inversion subnetwork.
        function self = design_relative_inversion_neurons( self, neuron_IDs )
            
            % Compute and set the sodium channel conductance of the relative inversion subnetwork neurons.
            self = self.compute_set_relative_inversion_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the relative inversion subnetwork neurons.
            self = self.compute_set_relative_inversion_Gm_input( neuron_IDs );
            self = self.compute_set_relative_inversion_Gm_output( neuron_IDs );
            
            % Compute and set the membrane capacitance for the relative inversion subnetwork neurons.
            self = self.compute_set_relative_inversion_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the relative inversion subnetwork neurons.
            self = self.compute_set_relative_inversion_R_input( neuron_IDs );
            self = self.compute_set_relative_inversion_R_output( neuron_IDs );
            
        end
                    
        
        % Implement a function to design the neurons for a division subnetwork.
        function self = design_division_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the division subnetwork neurons.
            self = self.compute_set_division_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the division subnetwork neurons.
            self = self.compute_set_division_Cm( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a absolute division subnetwork.
        function self = design_absolute_division_neurons( self, neuron_IDs, c, alpha, epsilon )
           
            % Set the default input arguments.
            if nargin < 5, epsilon = self.epsilon_division_DEFAULT; end                                     % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                                                  % [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.C_DIVISION; end                                                         % [-] Division Subnetwork Gain
            
            % Compute and set the sodium channel conductance of the absolute division subnetwork neurons.
            self = self.compute_set_absolute_division_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the absolute division subnetwork neurons.
            self = self.compute_set_absolute_division_Gm_input( neuron_IDs );
            self = self.compute_set_absolute_division_Gm_output( neuron_IDs );
            
            % Compute and set the membrane capacitance for the absolute division subnetwork neurons.
            self = self.compute_set_absolute_division_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the absolute division subnetwork neurons.
            self = self.compute_set_absolute_division_R_input( neuron_IDs );
            self = self.compute_set_absolute_division_R_output( neuron_IDs, c, alpha, epsilon );

        end
        
        
        % Implement a function to design the neurons for a relative division subnetwork.
        function self = design_relative_division_neurons( self, neuron_IDs )
           
            % Compute and set the sodium channel conductance of the relative division subnetwork neurons.
            self = self.compute_set_relative_division_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance of the relative division subnetwork neurons.
            self = self.compute_set_relative_division_Gm_input( neuron_IDs );
            self = self.compute_set_relative_division_Gm_output( neuron_IDs );
            
            % Compute and set the membrane capacitance for the relative division subnetwork neurons.
            self = self.compute_set_relative_division_Cm( neuron_IDs );
            
            % Compute and set the activation domain of the relative division subnetwork neurons.
            self = self.compute_set_relative_division_R_input( neuron_IDs );
            self = self.compute_set_relative_division_R_output( neuron_IDs );
            
        end
        
        
        % Implement a function to design the neurons for a derivation subnetwork.
        function self = design_derivation_neurons( self, neuron_IDs, k_gain, w, safety_factor )
           
            % Set the default input arguments.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end
            
            % Compute and set the sodium channel conductance of the derivation subnetwork neurons.
            self = self.compute_set_derivation_Gna( neuron_IDs );
            
            % Compute and set the membrane conductance for a derivation subnetwork.
            self = self.compute_set_derivation_Gm( neuron_IDs, k_gain, w, safety_factor );
            
            % Compute and set the membrane capacitance of the second derivation subnetwork neuron.
            self = self.compute_set_derivation_Cm2( neuron_IDs, w );     

            % Compute and set the membrane capacitance of the first derivation subnetwork neuron.
            self = self.compute_set_derivation_Cm1( neuron_IDs, k_gain );
            
        end
        
        
        % Implement a function to design the neurons for an integration subnetwork.
        function self = design_integration_neurons( self, neuron_IDs, ki_mean )

            % Set the default input arugments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end

            % Compute and set the sodium channel conductance of the integration subnetwork neurons.
            self = self.compute_set_integration_Gna( neuron_IDs );

            % Compute and set the membrane capacitance of the integration neurons.
            self = self.compute_set_integration_Cm( neuron_IDs, ki_mean );
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function self = design_vb_integration_neurons( self, neuron_IDs, ki_mean )

            % Set the default input arugments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute and set the sodium channel conductance of the voltage based integration subnetwork neurons.
            self = self.compute_set_vb_integration_Gna( neuron_IDs );

            % Compute and set the membrane capacitance of the integration neurons.
            self = self.compute_set_vb_integration_Cm( neuron_IDs( 3:4 ), ki_mean );
            
        end
        
        
        % Implemenet a function to design the neurons for a split voltage based integration subnetwork.
        function self = design_split_vb_integration_neurons( self, neuron_IDs, ki_mean )
        
            % Set the default input arugments.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute and set the sodium channel conductance of the split voltage based integration subnetwork neurons.
            self = self.compute_set_split_vb_integration_Gna( neuron_IDs );
            
            % Compute and set the membrane capacitance of the split voltage based integration subnetwork neurons.
            self = self.compute_set_split_vb_integration_Cm1( neuron_IDs( 3:4 ), ki_mean );
            self = self.compute_set_split_vb_integration_Cm2( neuron_IDs( 5:8 ) );
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save neuron manager data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load neuron manager data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load neuron data from a xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
            
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Neuron_Data.xlsx'; end
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING NEURON DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic
            
            % Load the neuron data.
            [ neuron_IDs, neuron_names, neuron_U0s, neuron_Cms, neuron_Gms, neuron_Ers, neuron_Rs, neuron_Ams, neuron_Sms, neuron_dEms, neuron_Ahs, neuron_Shs, neuron_dEhs, neuron_dEnas, neuron_tauh_maxs, neuron_Gnas ] = self.data_loader_utilities.load_neuron_data( file_name, directory );
            
            % Define the number of neurons.
            num_neurons_to_load = length( neuron_IDs );
            
            % Preallocate an array of neurons.
            neurons_to_load = repmat( neuron_class(  ), 1, num_neurons_to_load );
            
            % Create each neuron object.
            for k = 1:num_neurons_to_load               % Iterate through each of the neurons...
                
                % Compute the initial sodium channel deactivation parameter.
                neuron_h0 = neurons_to_load(k).neuron_utilities.compute_mhinf( neuron_U0s(k), neuron_Ahs(k), neuron_Shs(k), neuron_dEhs(k) );
                
                % Create this neuron.
                neurons_to_load(k) = neuron_class( neuron_IDs(k), neuron_names{k}, neuron_U0s(k), neuron_h0, neuron_Cms(k), neuron_Gms(k), neuron_Ers(k), neuron_Rs(k), neuron_Ams(k), neuron_Sms(k), neuron_dEms(k), neuron_Ahs(k), neuron_Shs(k), neuron_dEhs(k), neuron_dEnas(k), neuron_tauh_maxs(k), neuron_Gnas(k) );
                
            end
            
            % Determine whether to append the neurons we just loaded.
            if b_append                         % If we want to append the neurons we just loaded...
                
                % Append the neurons we just loaded to the array of existing neurons.
                self.neurons = [ self.neurons neurons_to_load ];
                
                % Update the number of neurons.
                self.num_neurons = length( self.neurons );
                
            else                                % Otherwise...
                
                % Replace the existing neurons with the neurons we just loaded.
                self.neurons = neurons_to_load;
                
                % Update the number of neurons.
                self.num_neurons = length( self.neurons );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING NEURON DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end

        
    end
end

