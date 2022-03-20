classdef neuron_manager_class
    
    % This class contains properties and methods related to managiing neurons.
    
    %% NEURON MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        neurons
        num_neurons
        
        array_utilities
        data_loader_utilities
        
    end
    
    
    % Define privateconstant class properties.
    properties ( Access = private, Constant = true )
    
        NUM_TRANSMISSION_NEURONS = 2;                   % [#] Number of Transmission Neurons.
        NUM_MODULATION_NEURONS = 2;                     % [#] Number of Modulation Neurons.
        NUM_ADDITION_NEURONS = 3;                       % [#] Number of Addition Neurons.
        NUM_SUBTRACTION_NEURONS = 3;                    % [#] Number of Subtraction Neurons.
        NUM_MULTIPLICATION_NEURONS = 4;                 % [#] Number of Multiplication Neurons.
        NUM_DIVISION_NEURONS = 3;                       % [#] Number of Division Neurons.
        NUM_DERIVATION_NEURONS = 3;                     % [#] Number of Derivation Neurons.
        NUM_INTEGRATION_NEURONS = 2;                    % [#] Number of Integration Neurons.
        
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
            
            % Set the default class properties.
%             if nargin < 1, self.neurons = neuron_class(  ); else, self.neurons = neurons; end
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
        function xs = get_neuron_property( self, neuron_IDs, neuron_property )
            
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
        
        
        %% Sodium Channel Conductance Functions
        
        % Implement a function to set the sodium channel conductance for a two neuron CPG subnetwork for each neuron.
        function self = compute_set_cpg_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_cpg_Gna(  );
                
            end
            
        end
        
        
        %% Neuron Creation Functions
        
        % Implement a function to create a new neuron.
        function [ self, ID ] = create_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled )
            
            % Set the default neuron properties.
            if nargin < 25, b_enabled = true; end
            if nargin < 24, I_total = 0; end
            if nargin < 23, I_app = 0; end
            if nargin < 22, I_tonic = 0; end
            if nargin < 21, I_na = 0; end
            if nargin < 20, I_syn = 0; end
            if nargin < 19, I_leak = 0; end
            if nargin < 18, Gna = 1e-6; end
            if nargin < 17, tauh_max = 0.25; end
            if nargin < 16, dEna = 110e-3; end
            if nargin < 15, dEh = 0; end
            if nargin < 14, Sh = 50; end
            if nargin < 13, Ah = 0.5; end
            if nargin < 12, dEm = 40e-3; end
            if nargin < 11, Sm = -50; end
            if nargin < 10, Am = 1; end
            if nargin < 9, R = 20e-3; end
            if nargin < 8, Er = -60e-3; end
            if nargin < 7, Gm = 1e-6; end
            if nargin < 6, Cm = 5e-9; end
            if nargin < 5, h = [  ]; end
            if nargin < 4, U = 0; end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = self.generate_unique_neuron_ID(  ); end
            
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
            if nargin < 25, b_enableds = true( 1, num_neurons_to_create ); end
            if nargin < 24, I_totals = zeros( 1, num_neurons_to_create ); end
            if nargin < 23, I_apps = zeros( 1, num_neurons_to_create ); end
            if nargin < 22, I_tonics = zeros( 1, num_neurons_to_create ); end
            if nargin < 21, I_nas = zeros( 1, num_neurons_to_create ); end
            if nargin < 20, I_syns = zeros( 1, num_neurons_to_create ); end
            if nargin < 19, I_leaks = zeros( 1, num_neurons_to_create ); end
            if nargin < 18, Gnas = 1e-6*ones( 1, num_neurons_to_create ); end
            if nargin < 17, tauh_maxs = 0.25*ones( 1, num_neurons_to_create ); end
            if nargin < 16, dEnas = 110e-3*ones( 1, num_neurons_to_create ); end
            if nargin < 15, dEhs = zeros( 1, num_neurons_to_create ); end
            if nargin < 14, Shs = 50*ones( 1, num_neurons_to_create ); end
            if nargin < 13, Ahs = 0.5*ones( 1, num_neurons_to_create ); end
            if nargin < 12, dEms = 40e-3*ones( 1, num_neurons_to_create ); end
            if nargin < 11, Sms = -50*ones( 1, num_neurons_to_create ); end
            if nargin < 10, Ams = 1*ones( 1, num_neurons_to_create ); end
            if nargin < 9, Rs = 20e-3*ones( 1, num_neurons_to_create ); end
            if nargin < 8, Ers = -60e-3*ones( 1, num_neurons_to_create ); end
            if nargin < 7, Gms = 1e-6*ones( 1, num_neurons_to_create ); end
            if nargin < 6, Cms = 5e-9*ones( 1, num_neurons_to_create ); end
            if nargin < 5, hs = repmat( { [  ] }, 1, num_neurons_to_create ); end
            if nargin < 4, Us = zeros( 1, num_neurons_to_create ); end
            if nargin < 3, names = repmat( { '' }, 1, num_neurons_to_create ); end
            if nargin < 2, IDs = self.generate_unique_neuron_IDs( num_neurons_to_create ); end
            
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
        
            
        % Implement a function to create the neurons for a transmission subnetwork.
        function [ self, neuron_IDs ] = create_transmission_neurons( self )
            
            % Generate unique neuron IDs for the transmission subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_TRANSMISSION_NEURONS );
                
            % Create the transmission subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the transmission subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Trans 1', 'Trans 2' }, 'name'  );
            
            % Set the sodium channel conductance of the transmission neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_TRANSMISSION_NEURONS ), 'Gna' );
            
        end
        
            
        % Implement a function to create the neurons for a modulation subnetwork.
        function [ self, neuron_IDs ] = create_modulation_neurons( self )
            
            % Generate unique neuron IDs for the modulation subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_MODULATION_NEURONS );
                
            % Create the modulation subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the modulation subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Mod 1', 'Mod 2' }, 'name'  );
            
            % Set the sodium channel conductance of the modulation neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_MODULATION_NEURONS ), 'Gna' );
                        
        end
        
        
        % Implement a function to create the neurons for an addition subnetwork.
        function [ self, neuron_IDs ] = create_addition_neurons( self )
            
            % Generate unique neuron IDs for the addition subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_ADDITION_NEURONS );
                
            % Create the addition subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the addition subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Add 1', 'Add 2', 'Sum' }, 'name'  );
            
            % Set the sodium channel conductance of the addition neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_ADDITION_NEURONS ), 'Gna' );
            
        end
        
            
        % Implement a function to create the neurons for a subtraction subnetwork.
        function [ self, neuron_IDs ] = create_subtraction_neurons( self )
            
            % Generate unique neuron IDs for the subtraction subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_SUBTRACTION_NEURONS );
                
            % Create the subtraction subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the subtraction subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Sub 1', 'Sub 2', 'Sub 3' }, 'name'  );
            
            % Set the sodium channel conductance of the subtraction neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_SUBTRACTION_NEURONS ), 'Gna' );
            
        end
        
        
        % Implement a function to create the neurons for a multiplication subnetwork.
        function [ self, neuron_IDs ] = create_multiplication_neurons( self )
            
            % Generate unique neuron IDs for the multiplication subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_MULTIPLICATION_NEURONS );
                
            % Create the multiplication subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the multiplication subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Mult1', 'Mult2', 'Mult Inter', 'Prod' }, 'name'  );
            
            % Set the sodium channel conductance of the multiplication neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_MULTIPLICATION_NEURONS ), 'Gna' );
            
        end
        
        
        % Implement a function to create the neurons for a division subnetwork.
        function [ self, neuron_IDs ] = create_division_neurons( self )
            
            % Generate unique neuron IDs for the division subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_DIVISION_NEURONS );
                
            % Create the division subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the division subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Div Num', 'Div Denom', 'Div Result' }, 'name'  );
            
            % Set the sodium channel conductance of the division neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_DIVISION_NEURONS ), 'Gna' );
            
        end
        
        
        % Implement a function to create the neurons for a derivation subnetwork.
        function [ self, neuron_IDs ] = create_derivation_neurons( self )
            
            % Generate unique neuron IDs for the derivation subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_DERIVATION_NEURONS );
                
            % Create the derivation subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the derivation subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Der 1', 'Der 2', 'Der 3' }, 'name'  );
            
            % Set the sodium channel conductance of the derivation neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_DERIVATION_NEURONS ), 'Gna' );
            
        end
        
        
        % Implement a function to create the neurons for an integration subnetwork.
        function [ self, neuron_IDs ] = create_integration_neurons( self )

            % Generate unique neuron IDs for the integration subnetwork.
            neuron_IDs = self.generate_unique_neuron_IDs( self.NUM_INTEGRATION_NEURONS );
                
            % Create the integration subnetwork neurons.
            self = self.create_neurons( neuron_IDs );
            
            % Set the names of the integration subnetwork neurons. 
            self = self.set_neuron_property( neuron_IDs, { 'Int 1', 'Int 2' }, 'name'  );
            
            % Set the sodium channel conductance of the integration neurons to zero.
            self = self.set_neuron_property( neuron_IDs, zeros( 1, self.NUM_INTEGRATION_NEURONS ), 'Gna' );
            
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

