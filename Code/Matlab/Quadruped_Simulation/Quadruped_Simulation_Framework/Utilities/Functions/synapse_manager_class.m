classdef synapse_manager_class
    
    % This class contains properties and methods related to managing synapses.
    
    %% SYNAPSE MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        synapses
        num_synapses
        
        array_utilities
        data_loader_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
    
        NUM_TRANSMISSION_SYNAPSES = 1;                          % [#] Number of Transmission Synapses.
        NUM_MODULATION_SYNAPSES = 1;                            % [#] Number of Modulation Synapses.
        NUM_ADDITION_SYNAPSES = 2;                              % [#] Number of Addition Synapses.
        NUM_SUBTRACTION_SYNAPSES = 2;                           % [#] Number of Subtraction Synapses.
        NUM_MULTIPLICATION_SYNAPSES = 3;                        % [#] Number of Multiplication Synapses.
        NUM_DIVISION_SYNAPSES = 2;                              % [#] Number of Division Synapses.
        NUM_DERIVATION_SYNAPSES = 2;                            % [#] Number of Derivation Synapses.
        NUM_INTEGRATION_SYNAPSES = 2;                           % [#] Number of Integration Synapses.
        
    end
    
    
    %% SYNAPSE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_manager_class( synapses )
            
            % Create an instance of the array manager class.
            self.array_utilities = array_utilities_class(  );
            
            % Create an instance of the data loader utilities class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Set the default synapse properties.
%             if nargin < 1, self.synapses = synapse_class(  ); else, self.synapses = synapses; end
            if nargin < 1, self.synapses = [  ]; else, self.synapses = synapses; end

            % Compute the number of synapses.
            self.num_synapses = length( self.synapses );
            
        end
        
        
        %% General Get & Set Synapse Property Functions
        
        % Implement a function to retrieve the properties of specific synapses.
        function xs = get_synapse_property( self, synapse_IDs, synapse_property )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_properties_to_get = length( synapse_IDs );
            
            % Preallocate a variable to store the synapse properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given synapse property for each synapse.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.synapses(%0.0f).%s;', synapse_index, synapse_property );
                
                % Evaluate the given synapse property.
                eval( eval_str );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific synapses.
        function self = set_synapse_property( self, synapse_IDs, synapse_property_values, synapse_property )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Retreive the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
            
            % Retrieve the number of synapse property values.
            num_synapse_property_values = length( synapse_property_values );
            
            % Ensure that the provided synapse property values have the same length as the provided synapse IDs.
            if ( num_synapse_IDs ~= num_synapse_property_values )                                     % If the number of provided synapse IDs does not match the number of provided property values...
               
                % Determine whether to agument the property values.
                if num_synapse_property_values == 1                                                  % If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
                    synapse_property_values = synapse_property_values*ones( 1, num_synapse_IDs );
                    
                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided synapse propety values must match the number of provided synapse IDs, unless a single synapse property value is provided.' )
                    
                end
                
            end
            
            
            % Validate the synapse property values.
            if ~isa( synapse_property_values, 'cell' )                    % If the synapse property values are not a cell array...
                
                % Convert the synapse property values to a cell array.
                synapse_property_values = num2cell( synapse_property_values );
                
            end
            
            % Set the properties of each synapse.
            for k = 1:self.num_synapses                   % Iterate through each synapse...
                
                % Determine the index of the synapse property value that we want to apply to this synapse (if we want to set a property of this synapse).
                index = find( self.synapses(k).ID == synapse_IDs, 1 );
                
                % Determine whether to set a property of this synapse.
                if ~isempty( index )                         % If a matching synapse ID was detected...
                    
                    % Create an evaluation string that sets the desired synapse property.
                    eval_string = sprintf( 'self.synapses(%0.0f).%s = synapse_property_values{%0.0f};', k, synapse_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end
        
        
        %% Call Methods Functions
        
        % Implement a function to that calls a specified synapse method for each of the specified synapses.
        function self = call_synapse_method( self, synapse_IDs, synapse_method )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each synapse.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.synapses(%0.0f) = self.synapses(%0.0f).%s();', synapse_index, synapse_index, synapse_method );
                
                % Evaluate the given synapse method.
                eval( eval_str );
                
            end
            
        end
        
        
        %% Specific Get & Set Synapse Property Functions
        
        % Implement a function to retrieve the index associated with a given synapse ID.
        function synapse_index = get_synapse_index( self, synapse_ID, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Set a flag variable to indicate whether a matching synapse index has been found.
            b_match_found = false;
            
            % Initialize the synapse index.
            synapse_index = 0;
            
            while ( synapse_index < self.num_synapses ) && ( ~b_match_found )
                
                % Advance the synapse index.
                synapse_index = synapse_index + 1;
                
                % Check whether this synapse index is a match.
                if self.synapses(synapse_index).ID == synapse_ID                       % If this synapse has the correct synapse ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the synapse index.
            if ~b_match_found                                                       % If a match was not found...
            
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                            % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No synapse with ID %0.0f.', synapse_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                     % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No synapse with ID %0.0f.', synapse_ID )
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                       % If the undetected option is set to 'ignore'...
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;                    
                    
                else                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
            
            end
            
        end
        
        
        % Implement a function to retrieve the index associated with a given array of synapse IDs.
        function synapse_indexes = get_synapse_indexes( self, synapse_IDs )
            
            % Set the default synapse IDs.
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
            
            % Preallocate an array of synapse indexes.
            synapse_indexes = zeros( 1, num_synapse_IDs );
            
            % Retrieve the synapse index of each synapse ID.
            for k = 1:num_synapse_IDs                           % Iterate through each synapse ID...
            
                % Determine how to compute the synapse index.
                if synapse_IDs(k) >= 0                           % If the synapse ID is positive... (this means that the synapse ID exists...)
                
                    % Retrieve the synapse index associated with this synapse ID.
                    synapse_indexes(k) = self.get_synapse_index( synapse_IDs(k) );
            
                elseif synapse_IDs(k) == -1                     % If the synapse ID is -1... (this means that the synapse ID does not exist...)
                    
                    % Set the synapse index to negative one (to indicate that it doesn't exist).
                    synapse_indexes(k) = -1;
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse ID %0.2f not recognized.', synapse_IDs(k) )
                    
                end
                    
            end
            
        end
        
        
        % Implement a function to get all of the synapse IDs.
        function synapse_IDs = get_all_synapse_IDs( self )
            
            % Preallocate an array to store the synapse IDs.
           synapse_IDs = zeros( 1,  self.num_synapses );
           
           % Retrieve each synapse ID.
           for k = 1:self.num_synapses                  % Iterate through each synapse...
              
               % Retrieve the ID of this synapse.
               synapse_IDs(k) = self.synapses(k).ID;
               
           end
            
        end
        
        
        % Implement a function to retrieve all self connecting synapses.
        function synapse_IDs = get_self_connecting_sypnapse_IDs( self )
            
            % Initialize a loop counter.
            index = 0;
            
            % Preallocate an array to store the synapses IDs.
            synapse_IDs = zeros( 1, self.num_synapses );
            
            % Retrieve all self-connecting synapse IDs.
            for k = 1:self.num_synapses                         % Iterate through each synapse...
            
                % Determine whether this synapse is a self-connection.
                if ( self.synapses(k).from_neuron_ID == self.synapses(k).to_neuron_ID )             % If this synapse is a self-connection...

                    % Advance the synapse ID index.
                    index = index + 1;
                    
                    % Retrieve this synapse index.
                    synapse_IDs(index) = self.synapses(k).ID;
                    
                end
                    
            end
            
            % Keep only the relevant synapse IDs.
            synapse_IDs = synapse_IDs( 1:index );
                
        end
                
        
        %% Synapse ID Functions
        
        % Implement a function to validate synapse IDs.
        function synapse_IDs = validate_synapse_IDs( self, synapse_IDs )
            
            % Determine whether we want get the desired synapse property from all of the synapses.
            if isa( synapse_IDs, 'char' )                                                      % If the synapse IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( synapse_IDs, 'all' )                 % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the synapse IDs.
                    synapse_IDs = zeros( 1, self.num_synapses );
                    
                    % Retrieve the synapse ID associated with each synapse.
                    for k = 1:self.num_synapses                   % Iterate through each synapse...
                        
                        % Store the synapse ID associated with the current synapse.
                        synapse_IDs(k) = self.synapses(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse_IDs must be either an array of valid synapse IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to generate a unique synapse ID.
        function synapse_ID = generate_unique_synapse_ID( self )
            
            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs(  );
            
            % Generate a unique synapse ID.
            synapse_ID = self.array_utilities.get_lowest_natural_number( existing_synapse_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique synapse IDs.
        function synapse_IDs = generate_unique_synapse_IDs( self, num_IDs )

            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs(  );
            
            % Preallocate an array to store the newly generated synapse IDs.
            synapse_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                           % Iterate through each of the new IDs...
            
                % Generate a unique synapse ID.
                synapse_IDs(k) = self.array_utilities.get_lowest_natural_number( [ existing_synapse_IDs, synapse_IDs( 1:(k - 1) ) ] );
            
            end
                
        end
        
        
        % Implement a function to check if a proposed synapse ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_synapse_ID( self, synapse_ID )
            
            % Retrieve all of the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs(  );
            
            % Determine whether the given synapse ID is one of the existing synapse IDs ( if so, provide the matching logicals and indexes ).
            [ b_match_found, match_logicals, match_indexes ] = self.array_utilities.is_value_in_array( synapse_ID, existing_synapse_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to check whether a proposed synapse ID is a unique natural.
        function b_unique_natural = unique_natural_synapse_ID( self, synapse_ID )

            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this synapse ID is unique.
            b_unique = self.unique_synapse_ID( synapse_ID );
            
            % Determine whether this synapse ID is a unique natural.
            if b_unique && ( synapse_ID > 0 ) && ( round( synapse_ID ) == synapse_ID )                     % If this neuron ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end
        
        
        % Implement a function to check if the existing synapse IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_synapse_IDs( self )
            
            % Retrieve all of the existing synapse IDs.
            synapse_IDs = self.get_all_synapse_IDs(  );
            
            % Determine whether all entries are unique.
            if length( unique( synapse_IDs ) ) == self.num_synapses                    % If all of the synapse IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_synapses );
                
            else                                                                     % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.synapses );
                
                % Determine which synapses have duplicate IDs.
                for k1 = 1:self.num_synapses                          % Iterate through each synapse...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another synapse with the same ID.
                    while ( k2 < self.num_synapses ) && ( ~match_logicals(k1) ) && ( k1 ~= ( k2 + 1 ) )                    % While we haven't checked all of the synapses and we haven't found a match...
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this synapse is a match.
                        if self.synapses(k2).ID == synapse_IDs(k1)                              % If this synapse ID is a match...

                            % Set this match logical to true.
                            match_logicals(k1) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
                        
        end
        
        
        %% From-To Neuron ID Functions
        
        % Implement a function to retrieve the synapse ID of the synapse that connect two specified neurons.
        function synapse_ID = from_to_neuron_ID2synapse_ID( self, from_neuron_ID, to_neuron_ID, undetected_option )
            
            % NOTE: This function assumes that only one synapse connects each set of neurons.
            
            % Set the default input argument.
            if nargin < 4, undetected_option = 'error'; end
            
            % Initialize the  synapse detected flag.
            b_synapse_detected = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the synapse(s) that connect the specified neurons.
            while ( ~b_synapse_detected ) && ( k < self.num_synapses )              % While a matching synapse has not yet been detected and we haven't looked through all of the synapses...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this synapse connects the specified neurons.
                if ( self.synapses(k).from_neuron_ID == from_neuron_ID ) && ( self.synapses(k).to_neuron_ID == to_neuron_ID )
                    
                    % Set the synapse detected flag to true.
                    b_synapse_detected = true;
                    
                end
                
            end
            
            % Determine whether a matching synapse was detected.
            if b_synapse_detected                                   % If we found a matching synapse....
                
                % Retrieve the ID of the matching synapse.
                synapse_ID = self.synapses(k).ID;
                
            else                                                    % Otherwise...
                
                % Determine how to handle the situation where we can not find a synapse that connects the selected neurons.
                if strcmpi( undetected_option, 'error' )                                    % If the error option is selected...
                    
                    % Throw an error.
                    error( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                              % If the warning option is selected...
                    
                    % Throw a warning.
                    warning( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                               % If the ignore option is selected...
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the synpase IDs associated with the synapses that connect an array of specified neurons.
        function synapse_IDs = from_to_neuron_IDs2synapse_IDs( self, from_neuron_IDs, to_neuron_IDs, undetected_option )
            
            % Set the default input argument.
            if nargin < 4, undetected_option = 'error'; end
            
            % Ensure that the same number of from and to neuron IDs are specified.
            assert( length( from_neuron_IDs ) == length( to_neuron_IDs ), 'length(from_neuron_IDs) must equal length(to_neuron_IDs).' )
            
            % Retrieve the number of synapses to find.
            num_synapses_to_find = length( from_neuron_IDs );
            
            % Preallocate an array to store the syanpse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_find );
            
            % Search for each synapse ID.
            for k = 1:num_synapses_to_find                              % Iterate through each set of neurons for which we are searching for a connecting synapse...
                
                % Retrieve the ID of the synapse that connects these neurons.
                synapse_IDs(k) = self.from_to_neuron_ID2synapse_ID( from_neuron_IDs(k), to_neuron_IDs(k), undetected_option );
                
            end
            
        end
        

        % Implement a function to convert a specific neuron ID order to oscillatory from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2oscillatory_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Retrieve the number of pairs of neurons.
                num_pairs = length( neuron_ID_order );
                
                % Augment the neuron ID order.
                neuron_ID_order = [ neuron_ID_order neuron_ID_order(1) ];
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k = 1:num_pairs                         % Iterate through each pair of neurons...
                    
                    % Retrieve the from neuron ID.
                    from_neuron_IDs(k) = neuron_ID_order(k);
                    
                    % Retrieve the to neuron ID.
                    to_neuron_IDs(k) = neuron_ID_order(k + 1);
                    
                end
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to self connecting from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2self_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Set the from-to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( neuron_ID_order );
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to all from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2all_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Retrieve the number of pairs of neurons.
                num_neurons = length( neuron_ID_order );
                num_pairs = num_neurons^2;
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Preallocate a counter variable.
                k3 = 0;
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k1 = 1:num_neurons                         % Iterate through each pair of neurons...
                    for k2 = 1:num_neurons                         % Iterate through each pair of neurons...

                        % Advance the counter variable.
                        k3 = k3 + 1;
                        
                        % Retrieve the from neuron ID.
                        from_neuron_IDs(k3) = neuron_ID_order(k1);

                        % Retrieve the to neuron ID.
                        to_neuron_IDs(k3) = neuron_ID_order(k2);
                    
                    end
                end
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to retrieve the synapse IDs relevant to a set of neuron IDs.
        function synapse_IDs = neuron_IDs2synapse_IDs( self, neuron_IDs, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Retrieve the IDs of all relevant from and to neurons.
            [ from_neuron_IDs, to_neuron_IDs ] = self.neuron_ID_order2all_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the synapse IDs associated with the given neuron IDs.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs, undetected_option );
        
        end
        
        
        % Implement a function to determine whether only a single synapse connects each pair of neurons.
        function b_one_to_one = one_to_one_synapses( self )
           
            % Set the one-to-one flag.
            b_one_to_one = true;
            
            % Initialize a counter variable.
            k = 0;
            
            % Preallocate arrays to store the from and to neuron IDs.
            [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, self.num_synapses ) );
            b_enableds = false( 1, self.num_synapses );
            
            % Determine whether there is only one synapse between each neuron.
            while ( b_one_to_one ) && ( k < self.num_synapses )                             % While we haven't found a synapse repetition and we haven't checked all of the synpases...
               
                % Advance the loop counter.
                k = k + 1;
                
                % Store these from neuron and to neuron IDs.
                from_neuron_IDs(k) = self.synapses(k).from_neuron_ID;
                to_neuron_IDs(k) = self.synapses(k).to_neuron_ID;
                b_enableds(k) = self.synapses(k).b_enabled;
                
                % Determine whether we need to check this synapse for repetition.
                if k ~= 1                               % If this is not the first iteration...

                    % Determine whether the from and to neuron IDs are unique.
                    [ from_neuron_ID_match, from_neuron_ID_match_logicals ] = self.array_utilities.is_value_in_array( from_neuron_IDs(k), from_neuron_IDs( 1:( k  - 1 ) ) );
                    [ to_neuron_ID_match, to_neuron_ID_match_logicals ] = self.array_utilities.is_value_in_array( to_neuron_IDs(k), to_neuron_IDs( 1:( k  - 1) ) );

                    % Determine whether this synapse is a duplicate.
                    if from_neuron_ID_match && to_neuron_ID_match && b_enableds(k) && any( from_neuron_ID_match_logicals & to_neuron_ID_match_logicals & b_enableds( 1:( k  - 1 ) ) )                           % If both the from neuron ID match flag and to neuron ID match flag are true, and we detect that these flags are aligned...

                        % Set the one-to-one flag to false (this synapse is duplicate).
                        b_one_to_one = false;

                    end
                
                end
                
            end
            
        end
        
        
        %% Multistate CPG Design Functions
        
        % Implement a function to assign the desired delta value to each synapse based on the neuron order that we want to follow.
        function self = compute_set_cpg_deltas( self, neuron_IDs, delta_oscillatory, delta_bistable )
            
            % Retrieve the IDs of all relevant from and to neurons.
            [ from_neuron_IDs_all, to_neuron_IDs_all ] = self.neuron_ID_order2all_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the IDs of the oscillatory from and to neurons.
            [ from_neuron_IDs_oscillatory, to_neuron_IDs_oscillatory ] = self.neuron_ID_order2oscillatory_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the IDs of relevant self connecting from and to neurons.
            [ from_neuron_IDs_self, to_neuron_IDs_self ] = self.neuron_ID_order2self_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve all of the relevant synapse IDs.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_all, to_neuron_IDs_all );
            
            % Retrieve the synapse IDs for each synapse the connects the specified neurons.
            synapse_IDs_oscillatory = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_oscillatory, to_neuron_IDs_oscillatory );
            
            % Retrieve the synapse IDs for all relevant self-connections.
            synapse_IDs_self_connections = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_self, to_neuron_IDs_self );
            
            % Retrieve the synapse IDs for all of the other neurons.
            synapse_IDs_bistable = self.array_utilities.remove_entries( synapse_IDs, synapse_IDs_oscillatory );
            synapse_IDs_bistable = self.array_utilities.remove_entries( synapse_IDs_bistable, synapse_IDs_self_connections );
            
            % Set the delta value of each of the oscillatory synapses.
            self = self.set_synapse_property( synapse_IDs_oscillatory, delta_oscillatory*ones( 1, length( synapse_IDs_oscillatory ) ), 'delta' );
            
            % Set the delta value of each of the bistable synapses.
            self = self.set_synapse_property( synapse_IDs_bistable, delta_bistable*ones( 1, length( synapse_IDs_bistable ) ), 'delta' );
            
            % Set the delta value of each of the self-connecting synapses.
            self = self.set_synapse_property( synapse_IDs_self_connections, zeros( 1, length( synapse_IDs_self_connections ) ), 'delta' );
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to enable synapses.
        function self = enable_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
                        
            % Determine the number of synapses to enable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Enable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Enable this synapse.
                self.synapses( synapse_index ).b_enabled = true;
                
            end
            
        end
        
        
        % Implement a function to disable synapses.
        function self = disable_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
                        
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Disable this synapse.
                self.synapses( synapse_index ).b_enabled = false;
                
            end
            
        end
        
        
        % Implement a function to toggle synapse enable state.
        function self = toggle_enabled_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
                        
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Toggle this synapse.
                self.synapses( synapse_index ).b_enabled = ~self.synapses( synapse_index ).b_enabled;
                
            end
            
        end
        
        
        %% Synapse Creation Functions
        
        % Implement a function to create a new synapse.
        function [ self, ID ] = create_synapse( self, ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled )

            % Set the default synapse properties.
            if nargin < 9, b_enabled = true; end
            if nargin < 8, delta = 0; end
            if nargin < 7, to_neuron_ID = 0; end
            if nargin < 6, from_neuron_ID = 0; end
            if nargin < 5, g_syn_max = 1e-6; end
            if nargin < 4, dE_syn = -40e-3; end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = self.generate_unique_synapse_ID(  ); end
            
            % Ensure that this synapse ID is a unique natural.
            assert( self.unique_natural_synapse_ID( ID ), 'Proposed synapse ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the synapse class.
            synapse = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled );
            
            % Append this synapse to the array of existing synapses.
            self.synapses = [ self.synapses synapse ];
            
            % Increase the number of synapses counter.
            self.num_synapses = self.num_synapses + 1;
            
        end
            
            
        % Implement a function to create multiple synapses.
        function [ self, IDs ] = create_synapses( self, IDs, names, dE_syns, g_syn_maxs, from_neuron_IDs, to_neuron_IDs, deltas, b_enableds )
            
            % Determine whether number of synapses to create.
            if nargin > 2                                               % If more than just synapse IDs were provided...
                
                % Set the number of synapses to create to be the number of provided IDs.
                num_synapses_to_create = length( IDs );
                
            elseif nargin == 2                                          % If just the synapse IDs were provided...
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                % Determine who to interpret this number of IDs.
                if num_IDs == 1                                     % If the number of IDs is one...
                    
                    % Then create a number of synapses equal to the specific ID.  (i.e., in this case we are treating the single provided ID value as the number of synapses that we want to create.)
                    num_synapses_to_create = IDs;
                    
                    % Preallocate an array of IDs.
                    IDs = self.generate_unique_synapse_IDs( num_synapses_to_create );
                    
                else                                                % Otherwise... ( More than one ID was provided... )
                    
                    % Set the number of synapses to create to be the number of provided synapse IDs.
                    num_synapses_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1                                      % If no input arguments were provided... ( Beyond the default self argument.)
                
                % Set the number of synapses to create to one.
                num_synapses_to_create = 1;
                
            end
            
            % Set the default synapse properties.
            if nargin < 9, b_enableds = true( 1, num_synapses_to_create ); end
            if nargin < 8, deltas = zeros( 1, num_synapses_to_create ); end
            if nargin < 7, to_neuron_IDs = zeros( 1, num_synapses_to_create ); end
            if nargin < 6, from_neuron_IDs = zeros( 1, num_synapses_to_create ); end
            if nargin < 5, g_syn_maxs = 1e-6*ones( 1, num_synapses_to_create ); end
            if nargin < 4, dE_syns = -40e-3*ones( 1, num_synapses_to_create ); end
            if nargin < 3, names = repmat( { '' }, 1, num_synapses_to_create ); end
            if nargin < 2, IDs = self.generate_unique_synapse_IDs( num_synapses_to_create ); end
            
            % Create each of the spcified synapses.
            for k = 1:num_synapses_to_create                         % Iterate through each of the synapses we want to create...
       
                % Create this synapse.
                self = self.create_synapse( IDs(k), names{k}, dE_syns(k), g_syn_maxs(k), from_neuron_IDs(k), to_neuron_IDs(k), deltas(k), b_enableds(k) );
            
            end
            
        end
        
        
        % Implement a function to delete a synapse.
        function self = delete_synapse( self, synapse_ID )
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID );
            
            % Remove this synapse from the array of synapses.
            self.synapses( synapse_index ) = [  ];
            
            % Decrease the number of synapses counter.
            self.num_synapses = self.num_synapses - 1;
            
        end
        
        
        % Implement a function to delete multiple synapses. 
        function self = delete_synapses( self, synapse_IDs )
            
            % Set the default input arguments.
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the number of synapses to delete.
            num_synapses_to_delete = length( synapse_IDs );
            
            % Delete each of the specified synapses.
            for k = 1:num_synapses_to_delete                      % Iterate through each of the synapses we want to delete...
                
                % Delete this synapse.
                self = self.delete_synapse( synapse_IDs(k) );
                
            end
            
        end
        
        
        % Implement a function to connect a synapse to neurons.
        function self = connect_synapse( self, synapse_ID, from_neuron_ID, to_neuron_ID )
            
           % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID );
           
            % Set the from neuron ID property of this synapse.
            self.synapses( synapse_index ).from_neuron_ID = from_neuron_ID;
            
            % Set the to neuron ID property of this synapse.
            self.synapses( synapse_index ).to_neuron_ID = to_neuron_ID;
            
        end
        
        
        % Implement a function to connet multiple synapses to multiple neurons.
        function self = connect_synapses( self, synapse_IDs, from_neuron_IDs, to_neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the number of synapses to connect.
            num_synapses_to_connect = length( synapse_IDs );
            
            % Ensure that the synapse IDs, from neuron IDs, and to neuron IDs have the same length.
            assert( ( num_synapses_to_connect == length( from_neuron_IDs ) ) && ( num_synapses_to_connect == length( to_neuron_IDs ) ), 'The number of from and to neuron IDs must match the number of specified synapse IDs.' )
            
            % Connect each of the specified synapses.
            for k = 1:num_synapses_to_connect                      % Iterate through each of the synapses we want to connect...
                
                % Connect this synapse.
                self = connect_synapse( self, synapse_IDs(k), from_neuron_IDs(k), to_neuron_IDs(k) );
                
            end
            
        end
        
        
        %% Subnetwork Synapse Creation Functions
        
        % Implement a function to create the synapses for a multistate CPG subnetwork.
        function [ self, synapse_IDs ] = create_multistate_cpg_synapses( self, neuron_IDs )
           
            % Compute the number of CPG neurons.
            num_cpg_neurons = length( neuron_IDs );
            
            % Generate unique synapse IDs for the multistate CPG subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( num_cpg_neurons^2 );
            
            % Create the multistate cpg subnetwork synapses.
            self = self.create_synapses( synapse_IDs ); 

            % Initialize a counter variable.
            k3 = 0;
            
            % Edit the network properties.
            for k1 = 1:num_cpg_neurons                              % Iterate through each of the CPG neurons (from which the synapses are starting)...
                for k2 = 1:num_cpg_neurons                          % Iterate through each of the CPG neurons (to which the synapses are going)...
                   
                    % Advance the counter variable.
                    k3 = k3 + 1;
                    
                    % Get the index associated with this synapse.
                    synapse_index = self.get_synapse_index( synapse_IDs( k3 ) );
                                        
                    % Set the from neuron ID and to neuron ID.
                    self.synapses( synapse_index ).from_neuron_ID = neuron_IDs( k1 );
                    self.synapses( synapse_index ).to_neuron_ID = neuron_IDs( k2 );
                    
                    % Set the name of this synapse.
                    self.synapses( synapse_index ).name = sprintf( 'CPG %0.0f%0.0f', neuron_IDs( k1 ), neuron_IDs( k2 ) );
                    
                    % Set the reversal potential of this synapse (if necessary).
                    if k1 == k2, self.synapses( synapse_index ).dE_syn = 0; end
                    
                end
            end

        end
        
        
        % Implement a function to create the synapses for a transmission subnetwork.
        function [ self, synapse_ID ] = create_transmission_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the transmission subnetwork.
            synapse_ID = self.generate_unique_synapse_IDs( self.NUM_TRANSMISSION_SYNAPSES );
            
            % Create the transmission subnetwork synapses.
            self = self.create_synapses( synapse_ID );
            
            % Set the names of the transmission subnetwork synapses.
            self = self.set_synapse_property( synapse_ID, { 'Trans 12' }, 'name' );
            
            % Connect the transmission subnetwork synapses to the transmission subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapses for a modulation subnetwork.
        function [ self, synapse_ID ] = create_modulation_synapses( self )
            
            % Generate unique synapse IDs for the modulation subnetwork.
            synapse_ID = self.generate_unique_synapse_IDs( self.NUM_MODULATION_SYNAPSES );
            
            % Create the modulation subnetwork synapses.
            self = self.create_synapses( synapse_ID );
            
            % Set the names of the modulation subnetwork synapses.
            self = self.set_synapse_property( synapse_ID, { 'Mod 12' }, 'name' );
            
            % Connect the modulation subnetwork synapses to the modulation subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapses for an addition subnetwork.
        function [ self, synapse_IDs ] = create_addition_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the addition subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_ADDITION_SYNAPSES );
            
            % Create the addition subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the addition subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Add 13', 'Add 23' }, 'name' );
            
            % Connect the addition subnetwork synapses to the addition subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a subtraction subnetwork.
        function [ self, synapse_IDs ] = create_subtraction_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the addition subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_SUBTRACTION_SYNAPSES );
            
            % Create the subtraction subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the subtraction subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Sub 13', 'Sub 23' }, 'name' );
            
            % Connect the subtraction subnetwork synapses to the subtraction subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a multiplication subnetwork.
        function [ self, synapse_IDs ] = create_multiplication_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the multiplication subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_MULTIPLICATION_SYNAPSES );
            
            % Create the multiplication subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the multiplication subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Mult 14', 'Mult 23', 'Mult 34' }, 'name' );
            
            % Connect the multiplication subnetwork synapses to the multiplication subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 3 ) ], [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ] );
            
        end
        
        
        % Implement a function to create the synpases for a division subnetwork.
        function [ self, synapse_IDs ] = create_division_synapses( self, neuron_IDs )

            % Generate unique synapse IDs for the division subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_DIVISION_SYNAPSES );
            
            % Create the division subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the division subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Div 13', 'Div 23' }, 'name' );
            
            % Connect the division subnetwork synapses to the division subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synpases for a derivation subnetwork.
        function [ self, synapse_IDs ] = create_derivation_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the derivation subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_DERIVATION_SYNAPSES );
            
            % Create the derivation subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the derivation subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Der 13', 'Der 23' }, 'name' );
            
            % Connect the derivation subnetwork synapses to the derivation subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for an integration subnetwork.
        function [ self, synapse_IDs ] = create_integration_synapses( self, neuron_IDs )
            
            % Generate unique synapse IDs for the integration subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( self.NUM_INTEGRATION_SYNAPSES );
            
            % Create the integration subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Set the names of the integration subnetwork synapses.
            self = self.set_synapse_property( synapse_IDs, { 'Int 12', 'Int 21' }, 'name' );
            
            % Connect the integration subnetwork synapses to the integration subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 2 ) neuron_IDs( 1 ) ] );
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save synapse manager data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load synapse manager data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load synapse from a xlsx data.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
        
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Synapse_Data.xlsx'; end
        
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING SYNAPSE DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic

            % Load the synapse data.
            [ synapse_IDs, synapse_names, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = self.data_loader_utilities.load_synapse_data( file_name, directory );
            
            % Define the number of synapses.
            num_synapses_to_load = length( synapse_IDs );

            % Preallocate an array of synapses.
            synapses_to_load = repmat( synapse_class(  ), 1, num_synapses_to_load );

            % Create each synapse object.
            for k = 1:num_synapses_to_load               % Iterate through each of the synapses...

                % Create this synapse.
                synapses_to_load(k) = synapse_class( synapse_IDs(k), synapse_names{k}, synapse_dEsyns(k), synapse_gsyn_maxs(k), synapse_from_neuron_IDs(k), synapse_to_neuron_IDs(k) );

            end
            
            % Determine whether to append the synapses we just loaded.
            if b_append                         % If we want to append the synapses we just loaded...
                
                % Append the synapses we just loaded to the array of existing synapses.
                self.synapses = [ self.synapses synapses_to_load ];
                
                % Update the number of synapses.
                self.num_synapses = length( self.synapses );
                
            else                                % Otherwise...
                
                % Replace the existing synapses with the synapses we just loaded.
                self.synapses = synapses_to_load;
                
                % Update the number of synapses.
                self.num_synapses = length( self.synapses );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING SYNAPSE DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        
    end
end

