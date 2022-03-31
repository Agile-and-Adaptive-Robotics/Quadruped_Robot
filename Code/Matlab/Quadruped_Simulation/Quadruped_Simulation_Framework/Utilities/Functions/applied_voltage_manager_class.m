classdef applied_voltage_manager_class
    
    % This class contains properties and methods related to managing applied voltages.
    
    
    %% APPLIED VOLTAGE MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        applied_voltages
        num_applied_voltages
        
        array_utilities
        data_loader_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )

        
        
    end
    
    
    %% APPLIED VOLTAGE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_voltage_manager_class( applied_voltages )
            
            % Create an instance of the data loader utilities class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Create an instance of the array manager class.
            self.array_utilities = array_utilities_class(  );
            
            % Set the default properties.
            if nargin < 1, self.applied_voltages = [  ]; else, self.applied_voltages = applied_voltages; end
            
            % Compute the number of applied voltages.
            self.num_applied_voltages = length( self.applied_voltages );
            
        end
        
        
        %% General Get & Set Applied Voltage Property Functions
        
        % Implement a function to retrieve the properties of specific applied voltages.
        function xs = get_applied_voltage_property( self, applied_voltage_IDs, applied_voltage_property )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Determine how many applied voltages to which we are going to apply the given method.
            num_properties_to_get = length( applied_voltage_IDs );
            
            % Preallocate a variable to store the applied voltage properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given applied voltage property for each applied voltage.
            for k = 1:num_properties_to_get                                                                         % Iterate through each of the properties to get...
                
                % Retrieve the index associated with this applied voltage ID.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.applied_voltages(%0.0f).%s;', applied_voltage_index, applied_voltage_property );
                
                % Evaluate the given applied voltage property.
                eval( eval_str );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific applied voltages.
        function self = set_applied_voltage_property( self, applied_voltage_IDs, applied_voltage_property_values, applied_voltage_property )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Validate the applied voltage property values.
            if ~isa( applied_voltage_property_values, 'cell' )                    % If the applied voltage property values are not a cell array...
                
                % Convert the applied voltage property values to a cell array.
                applied_voltage_property_values = num2cell( applied_voltage_property_values );
                
            end
            
            % Retreive the number of applied voltage IDs.
            num_applied_voltage_IDs = length( applied_voltage_IDs );
            %             num_applied_voltage_IDs = size( applied_voltage_IDs, 2 );
            
            % Retrieve the number of applied voltage property values.
            num_applied_voltage_property_values = length( applied_voltage_property_values );
            
            % Ensure that the provided neuron property values have the same length as the provided applied voltage IDs.
            if ( num_applied_voltage_IDs ~= num_applied_voltage_property_values )                                     % If the number of provided applied voltage IDs does not match the number of provided property values...
                
                % Determine whether to agument the property values.
                if num_applied_voltage_property_values == 1                                                  % If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
                    %                     applied_voltage_property_values = applied_voltage_property_values*ones( 1, num_applied_voltage_IDs );
                    applied_voltage_property_values = repmat( applied_voltage_property_values, [ 1, num_applied_voltage_IDs ] );
                    
                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided applied voltage propety values must match the number of provided applied voltage IDs, unless a single applied voltage property value is provided.' )
                    
                end
                
            end
            
            
            % Set the properties of each applied voltage.
            for k = 1:self.num_applied_voltages                   % Iterate through each applied voltage...
                
                % Determine the index of the applied voltage property value that we want to apply to this applied voltage (if we want to set a property of this applied voltage).
                index = find( self.applied_voltages(k).ID == applied_voltage_IDs, 1 );
                
                % Determine whether to set a property of this applied voltage.
                if ~isempty( index )                         % If a matching applied voltage ID was detected...
                    
                    % Create an evaluation string that sets the desired applied voltage property.
                    eval_string = sprintf( 'self.applied_voltages(%0.0f).%s = applied_voltage_property_values{%0.0f};', k, applied_voltage_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end
        
        
        %% Specific Get & Set Functions
        
        % Implement a function to retrieve all of the neuron IDs.
        function applied_voltage_IDs = get_all_applied_voltage_IDs( self )
            
            % Preallocate a variable to store the applied voltage IDs.
            applied_voltage_IDs = zeros( 1, self.num_applied_voltages );
            
            % Retrieve the ID associated with each applied voltage.
            for k = 1:self.num_applied_voltages                             % Iterate through each of the applied voltages...
                
                % Retrieve this applied voltage ID.
                applied_voltage_IDs(k) = self.applied_voltages(k).ID;
                
            end
            
        end
        
        
        % Implement a function to retrieve the number of time steps of the specified applied voltages.
        function num_timesteps = get_num_timesteps( self, applied_voltage_IDs, process_option )
            
            % Set the default input arguments.
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the number of timesteps.
            if all( applied_voltage_IDs == -1 )                         % If all of the applied voltage IDs are invalid...
                
                % Set the number of timesteps to zero.
                num_timesteps = 0;
                
            else                                                        % Otherwise...
                
                % Remove any invalid applied voltage IDs.
                applied_voltage_IDs( applied_voltage_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied voltages (if desired).
                if b_filter_disabled, applied_voltage_IDs = self.remove_disabled_applied_voltage_IDs( applied_voltage_IDs ); end
                
                % Retrieve the number of timesteps associated with each applied voltage.
                num_timesteps = cell2mat( self.get_applied_voltage_property( applied_voltage_IDs, 'num_timesteps' ) );
                
                % Determine how to process the number of timesteps.
                if strcmpi( process_option, 'average' )                     % If we want the average time step...
                    
                    % Set the number of timesteps to be the average number of timesteps.
                    num_timesteps = mean( num_timesteps );
                    
                elseif strcmpi( process_option, 'max' )                    % If we want the maximum time step...
                    
                    % Set the number of timesteps to be the largest number of timesteps.
                    num_timesteps = max( num_timesteps );
                    
                elseif strcmpi( process_option, 'min' )                    % If we want the minimum time step...
                    
                    % Set the number of timesteps to be the smallest number of timesteps.
                    num_timesteps = min( num_timesteps );
                    
                elseif strcmpi( process_option, 'none' )                   % If we have selected no process options...
                    
                    % Do nothing.
                    
                else                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Process option %s not recognized.', process_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the step size of the specified applied voltages.
        function dt = get_dts( self, applied_voltage_IDs, process_option, b_filter_disabled )
            
            % Set the default input arguments.
            if nargin < 4, b_filter_disabled = false; end
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the step size.
            if all( applied_voltage_IDs == -1 )                         % If all of the applied voltage IDs are invalid...
                
                % Set the step size to zero.
                dt = 1e-3;
                
            else                                                        % Otherwise...
                
                % Remove any invalid applied voltage IDs.
                applied_voltage_IDs( applied_voltage_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied voltages (if desired).
                if b_filter_disabled, applied_voltage_IDs = self.remove_disabled_applied_voltage_IDs( applied_voltage_IDs ); end
                
                % Retrieve the step size associated with each applied voltage.
                dt = cell2mat( self.get_applied_voltage_property( applied_voltage_IDs, 'dt' ) );
                
                % Determine whether the step size needs to be set.
                if isempty( dt ), dt = 1e-3; end
                
                % Determine how to process the step size.
                if strcmpi( process_option, 'average' )                     % If we want the average step size...
                    
                    % Set the step size to be the average step size.
                    dt = mean( dt );
                    
                elseif strcmpi( process_option, 'max' )                    % If we want the maximum step size...
                    
                    % Set the step size to be the largest step size.
                    dt = max( dt );
                    
                elseif strcmpi( process_option, 'min' )                    % If we want the minimum step size...
                    
                    % Set the step size to be the smallest step size.
                    dt = min( dt );
                    
                elseif strcmpi( process_option, 'none' )                   % If we have selected no process options...
                    
                    % Do nothing.
                    
                else                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Process option %s not recognized.', process_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the final time of the specified applied voltages.
        function tf = get_tfs( self, applied_voltage_IDs, process_option, b_filter_disabled )
            
            % Set the default input arguments.
            if nargin < 4, b_filter_disabled = false; end
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the final time.
            if all( applied_voltage_IDs == -1 )             % If all of the applied voltage IDs are invalid...
                
                % Set the final time to zero.
                tf = 0;
                
            else                                            % Otherwise...
                
                % Remove any invalid applied voltage IDs.
                applied_voltage_IDs( applied_voltage_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied voltages (if desired).
                if b_filter_disabled, applied_voltage_IDs = self.remove_disabled_applied_voltage_IDs( applied_voltage_IDs ); end
                
                % Retrieve the final time associated with each applied voltage.
                tf = cell2mat( self.get_applied_voltage_property( applied_voltage_IDs, 'tf' ) );
                
                % Determine how to process the final time.
                if strcmpi( process_option, 'average' )                     % If we want the average final time...
                    
                    % Set the step size to be the average final time.
                    tf = mean( tf );
                    
                elseif strcmpi( process_option, 'max' )                    % If we want the maximum final time...
                    
                    % Set the step size to be the largest final time.
                    tf = max( tf );
                    
                elseif strcmpi( process_option, 'min' )                    % If we want the minimum final time...
                    
                    % Set the step size to be the smallest final time.
                    tf = min( tf );
                    
                elseif strcmpi( process_option, 'none' )                   % If we have selected no process options...
                    
                    % Do nothing.
                    
                else                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Process option %s not recognized.', process_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the applied voltages.
        function V_apps = get_Vapps( self, applied_voltage_IDs, dt, tf )
            
            % Set the default input arguments.
            if nargin < 4, tf = [  ]; end
            if nargin < 3, dt = [  ]; end
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Determine how many applied voltages to get.
            num_applied_voltages_to_get = length( applied_voltage_IDs );
            
            % Determine whether we need to set the final time.
            if isempty( tf )                                                                % If the final time is empty...
                
                % Compute the maximum final time among the given applied voltages.
                tf = self.get_tfs( applied_voltage_IDs, 'max' );
                
            end
            
            % Determine whether we need to set the step size.
            if isempty( dt )                                                                % If the step size is empty...
                
                % Compute the minimum step size among the given applied voltages.
                dt = self.get_dts( applied_voltage_IDs, 'min' );
                
            end
            
            % Compute the number of time steps.
            num_timesteps = floor( round( tf/dt, 8 ) ) + 1;
            
            % Preallocate a variable to store the applied voltage properties.
            V_apps = cell( num_timesteps, num_applied_voltages_to_get );
            
            % Retrieve the given neuron property for each applied voltage.
            for k = 1:num_applied_voltages_to_get                           % Iterate through each of the voltages to retrieve...
                
                % Retrieve the index associated with this applied voltage ID.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k), 'ignore' );
                
                % Determine how to retrieve this applied voltage.
                if ( applied_voltage_index >= 0 ) && ( self.applied_voltages( applied_voltage_index ).b_enabled )                                                      % If the applied voltage ID is greater than or equal to zero...
                    
                    % Retrieve the applied voltages.
                    V_apps( :, k ) = self.applied_voltages( applied_voltage_index ).sample_Vapp( dt, tf );
                    
                elseif ( applied_voltage_index == -1 ) || ( ~self.applied_voltages( applied_voltage_index ).b_enabled )                                                % If the applied voltage ID is negative one...
                    
%                     % Set the applied voltage to zero.
%                     V_apps( :, k ) = zeros( num_timesteps, 1 );
                    
                else                                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Applied voltage ID %0.2f not recognized.', applied_voltage_IDs(k) )
                    
                end
                
            end
            
        end
        
        
        %% Applied Voltage Index & ID Functions
        
        % Implement a function to retrieve the index associated with a given applied_voltage ID.
        function applied_voltage_index = get_applied_voltage_index( self, applied_voltage_ID, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Set a flag variable to indicate whether a matching applied_voltage index has been found.
            b_match_found = false;
            
            % Initialize the applied_voltage index.
            applied_voltage_index = 0;
            
            while ( applied_voltage_index < self.num_applied_voltages ) && ( ~b_match_found )
                
                % Advance the applied_voltage index.
                applied_voltage_index = applied_voltage_index + 1;
                
                % Check whether this applied_voltage index is a match.
                if self.applied_voltages( applied_voltage_index ).ID == applied_voltage_ID                       % If this applied_voltage has the correct applied_voltage ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the applied voltage index.
            if ~b_match_found                                                       % If a match was not found...
                
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                            % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No applied voltage with ID %0.0f.', applied_voltage_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                     % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No applied voltage with ID %0.0f.', applied_voltage_ID )
                    
                    % Set the applied voltage index to negative one.
                    applied_voltage_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                       % If the undetected option is set to 'ignore'...
                    
                    % Set the applied voltage index to negative one.
                    applied_voltage_index = -1;
                    
                else                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to validate applied_voltage IDs.
        function applied_voltage_IDs = validate_applied_voltage_IDs( self, applied_voltage_IDs )
            
            % Determine whether we want get the desired applied_voltage property from all of the applied_voltages.
            if isa( applied_voltage_IDs, 'char' )                                                      % If the applied_voltage IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( applied_voltage_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the applied_voltage IDs.
                    applied_voltage_IDs = zeros( 1, self.num_applied_voltages );
                    
                    % Retrieve the applied_voltage ID associated with each applied_voltage.
                    for k = 1:self.num_applied_voltages                   % Iterate through each applied_voltage...
                        
                        % Store the applied_voltage ID associated with the voltage applied_voltage.
                        applied_voltage_IDs(k) = self.applied_voltages(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Applied voltage ID must be either an array of valid applied_voltage IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to check if the existing applied voltage IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_applied_voltage_IDs( self )
            
            % Retrieve all of the existing applied voltage IDs.
            applied_voltage_IDs = self.get_all_applied_voltage_IDs(  );
            
            % Determine whether all entries are unique.
            if length( unique( applied_voltage_IDs ) ) == self.num_applied_voltages                    % If all of the applied voltage IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_applied_voltages );
                
            else                                                                     % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_applied_voltages );
                
                % Determine which applied voltages have duplicate IDs.
                for k1 = 1:self.num_applied_voltages                          % Iterate through each applied voltage...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another applied voltage with the same ID.
                    while ( k2 < self.num_applied_voltages ) && ( ~match_logicals(k1) ) && ( k1 ~= ( k2 + 1 ) )                    % While we haven't checked all of the applied voltages and we haven't found a match...
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this applied voltage is a match.
                        if self.applied_voltages(k2).ID == applied_voltage_IDs(k1)                              % If this applied voltage ID is a match...
                            
                            % Set this match logical to true.
                            match_logicals(k1) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        
        % Implement a function to check if a proposed applied voltage ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_applied_voltage_ID( self, applied_voltage_ID )
            
            % Retrieve all of the existing applied voltage IDs.
            applied_voltage_IDs = self.get_all_applied_voltage_IDs(  );
            
            % Determine whether the given applied voltage ID is one of the existing applied voltage IDs ( if so, provide the matching logicals and indexes ).
            [ b_match_found, match_logicals, match_indexes ] = self.array_utilities.is_value_in_array( applied_voltage_ID, applied_voltage_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to generate a unique applied voltage ID.
        function applied_voltage_ID = generate_unique_applied_voltage_ID( self )
            
            % Retrieve the existing applied voltage IDs.
            existing_applied_voltage_IDs = self.get_all_applied_voltage_IDs(  );
            
            % Generate a unique applied voltage ID.
            applied_voltage_ID = self.array_utilities.get_lowest_natural_number( existing_applied_voltage_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique applied voltage IDs.
        function applied_voltage_IDs = generate_unique_applied_voltage_IDs( self, num_IDs )
            
            % Retrieve the existing applied voltage IDs.
            existing_applied_voltage_IDs = self.get_all_applied_voltage_IDs(  );
            
            % Preallocate an array to store the newly generated applied voltage IDs.
            applied_voltage_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                           % Iterate through each of the new IDs...
                
                % Generate a unique applied voltage ID.
                applied_voltage_IDs(k) = self.array_utilities.get_lowest_natural_number( [ existing_applied_voltage_IDs, applied_voltage_IDs( 1:(k - 1) ) ] );
                
            end
            
        end
        
        
        % Implement a function to check whether a proposed applied voltage ID is a unique natural.
        function b_unique_natural = unique_natural_applied_voltage_ID( self, applied_voltage_ID )
            
            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this applied voltage ID is unique.
            b_unique = self.unique_applied_voltage_ID( applied_voltage_ID );
            
            % Determine whether this applied voltage ID is a unique natural.
            if b_unique && ( applied_voltage_ID > 0 ) && ( round( applied_voltage_ID ) == applied_voltage_ID )                     % If this applied voltage ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end
        
        
        % Implement a function to remove disabled applied voltage IDs.
        function applied_voltage_IDs = remove_disabled_applied_voltage_IDs( self, applied_voltage_IDs )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Retrieve the number of applied voltage IDs.
            num_applied_voltage_IDs = length( applied_voltage_IDs );
            
            % Create an array to store the indexes to remove.
            remove_indexes = zeros( 1, num_applied_voltage_IDs );
            
            % Remove any IDs associated with disabled applied voltages.
            for k = 1:num_applied_voltage_IDs                       % Iterate through each of the applied voltage IDs...
                
                % Retrieve the index associated with this applied voltage ID.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k), 'ignore' );
                
                % Determine whether to remove this applied voltage ID.
                if ( applied_voltage_index == -1 ) || ( ~self.applied_voltages( applied_voltage_index ).b_enabled )                         % If this applied voltage index is invalid or this applied voltage is disabled...
                    
                    % Store the indexes to remove.
                    remove_indexes(k) = k;
                    
                end
                
            end
            
            % Remove any extra zeros from the remove indexes.
            remove_indexes( remove_indexes == 0 ) = [  ];
            
            % Remove the applied voltage IDs.
            applied_voltage_IDs( remove_indexes ) = [  ];
            
        end
        
        
        %% Neuron ID Functions.
        
        % Implement a function to return the applied voltage ID associated with a given neuron ID.
        function applied_voltage_ID = neuron_ID2applied_voltage_ID( self, neuron_ID, undetected_option )
            
            % NOTE: This function assumes that only one applied voltage applies to each neuron.
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Initialize the applied voltage detected flag.
            b_applied_voltage_detected = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the applied voltage(s) that connect the specified neurons.
            while ( ~b_applied_voltage_detected ) && ( k < self.num_applied_voltages )              % While a matching applied voltage has not yet been detected and we haven't looked through all of the applied voltages...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this applied voltage connects the specified neurons.
                if ( self.applied_voltages(k).neuron_ID == neuron_ID )
                    
                    % Set the applied voltage detected flag to true.
                    b_applied_voltage_detected = true;
                    
                end
                
            end
            
            % Determine whether a matching applied voltage was detected.
            if b_applied_voltage_detected                                   % If we found a matching applied voltage....
                
                % Retrieve the ID of the matching applied voltage.
                applied_voltage_ID = self.applied_voltages(k).ID;
                
            else                                                    % Otherwise...
                
                % Determine how to handle the situation where we can not find a applied voltage that connects the selected neurons.
                if strcmpi( undetected_option, 'error' )                                    % If the error option is selected...
                    
                    % Throw an error.
                    error( 'No applied voltage found that stimulates neuron %0.0f.', neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                              % If the warning option is selected...
                    
                    % Throw a warning.
                    warning( 'No applied voltage found that stimulates neuron %0.0f.', neuron_ID )
                    
                    % Set the synapse ID to be negative one.
                    applied_voltage_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                               % If the ignore option is selected...
                    
                    % Set the applied voltage ID to be negative one.
                    applied_voltage_ID = -1;
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function return the applied voltage IDs associated with given neuron IDs.
        function applied_voltage_IDs = neuron_IDs2applied_voltage_IDs( self, neuron_IDs, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Retrieve the number of applied voltages to find.
            num_applied_voltages_to_find = length( neuron_IDs );
            
            % Preallocate an array to store the applied voltage IDs.
            applied_voltage_IDs = zeros( 1, num_applied_voltages_to_find );
            
            % Search for each applied voltage ID.
            for k = 1:num_applied_voltages_to_find                              % Iterate through each set of neurons for which we are searching for a connecting applied voltage...
                
                % Retrieve the ID of the applied voltage that connects to this neuron.
                applied_voltage_IDs(k) = self.neuron_ID2applied_voltage_ID( neuron_IDs(k), undetected_option );
                
            end
            
        end
        
        
        % Implement a function to return the applied voltages associated with given neuron IDs.
        function V_apps = neuron_IDs2Vapps( self, neuron_IDs, dt, tf, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'ignore'; end
            if nargin < 4, tf = [  ]; end
            if nargin < 3, dt = [  ]; end
            
            % Retrieve the applied voltage IDs.
            applied_voltage_IDs = self.neuron_IDs2applied_voltage_IDs( neuron_IDs, undetected_option );
            
            % Retrieve the applied voltages.
            V_apps = self.get_Vapps( applied_voltage_IDs, dt, tf );
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to enable applied voltages.
        function self = enable_applied_voltages( self, applied_voltage_IDs )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Determine the number of applied voltages to enable.
            num_applied_voltages_to_enable = length( applied_voltage_IDs );
            
            % Enable all of the specified applied voltages.
            for k = 1:num_applied_voltages_to_enable                      % Iterate through all of the specified applied voltages...
                
                % Retrieve this applied voltage index.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k) );
                
                % Enable this applied voltage.
                self.applied_voltages( applied_voltage_index ).b_enabled = true;
                
            end
            
        end
        
        
        % Implement a function to disable applied voltages.
        function self = disable_applied_voltages( self, applied_voltage_IDs )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_synapse_IDs( applied_voltage_IDs );
            
            % Determine the number of applied voltages to disable.
            num_applied_voltages_to_enable = length( applied_voltage_IDs );
            
            % Disable all of the specified applied voltages.
            for k = 1:num_applied_voltages_to_enable                      % Iterate through all of the specified applied voltages...
                
                % Retrieve this applied voltage index.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k) );
                
                % Disable this applied voltage.
                self.applied_voltages( applied_voltage_index ).b_enabled = false;
                
            end
            
        end
        
        
        % Implement a function to toggle applied voltage enable state.
        function self = toggle_enabled_applied_voltages( self, applied_voltage_IDs )
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Determine the number of applied voltages to disable.
            num_applied_voltages_to_enable = length( applied_voltage_IDs );
            
            % Disable all of the specified applied voltages.
            for k = 1:num_applied_voltages_to_enable                      % Iterate through all of the specified applied voltages...
                
                % Retrieve this applied voltage index.
                applied_voltage_index = self.get_applied_voltage_index( applied_voltage_IDs(k) );
                
                % Toggle this applied voltage.
                self.applied_voltages( applied_voltage_index ).b_enabled = ~self.applied_voltages( applied_voltage_index ).b_enabled;
                
            end
            
        end
        
        
        %% Validation Functions
        
        % Ensure that each neuron has only one applied voltage.
        function b_one_to_one = one_to_one_applied_voltages( self )
            
            % Set the one-to-one flag.
            b_one_to_one = true;
            
            % Initialize a counter variable.
            k = 0;
            
            % Preallocate arrays to store the neuron IDs.
            neuron_IDs = zeros( 1, self.num_applied_voltages );
            b_enableds = false( 1, self.num_applied_voltages );
            
            % Determine whether there is only one synapse between each neuron.
            while ( b_one_to_one ) && ( k < self.num_applied_voltages )                             % While we haven't found an applied voltage repetition and we haven't checked all of the applied voltages...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Store these from neuron and to neuron IDs.
                neuron_IDs(k) = self.applied_voltages(k).neuron_ID;
                
                % Determine whether we need to check this synapse for repetition.
                if k ~= 1                               % If this is not the first iteration...
                    
                    % Determine whether this neuron ID is unique.
                    [ neuron_ID_match, neuron_ID_match_logicals ] = self.array_utilities.is_value_in_array( neuron_IDs(k), neuron_IDs( 1:( k  - 1) ) );
                    
                    % Determine whether this applied voltage is a duplicate.
                    if neuron_ID_match && b_enableds(k) && any( neuron_ID_match_logicals & b_enableds( 1:( k  - 1 ) ) )                           % If this neuron ID is a match, this applied voltage is enabled, and the matching applied voltage is enabled...
                        
                        % Set the one-to-one flag to false (this applied voltage is a duplicate).
                        b_one_to_one = false;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        %% Applied Voltage Creation Functions
        
        % Implement a function to create a new applied voltage.
        function [ self, ID ] = create_applied_voltage( self, ID, name, neuron_ID, ts, V_apps, b_enabled )
            
            % Set the default input arguments.
            if nargin < 7, b_enabled = true; end
            if nargin < 6, V_apps = { [ ] }; end
            if nargin < 5, ts = 0; end
            if nargin < 4, neuron_ID = 0; end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = self.generate_unique_applied_voltage_ID(  ); end
            
            % Ensure that this neuron ID is a unique natural.
            assert( self.unique_natural_applied_voltage_ID( ID ), 'Proposed applied voltage ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the applied voltage class.
            applied_voltage = applied_voltage_class( ID, name, neuron_ID, ts, V_apps, b_enabled );
            
            % Append this applied voltage to the array of existing applied voltages.
            self.applied_voltages = [ self.applied_voltages applied_voltage ];
            
            % Increase the number of applied voltages counter.
            self.num_applied_voltages = self.num_applied_voltages + 1;
            
        end
        
        
        % Implement a function to create multiple applied voltages.
        function [ self, IDs ] = create_applied_voltages( self, IDs, names, neuron_IDs, ts, V_apps, b_enableds )
            
            % Determine whether number of applied voltages to create.
            if nargin > 2                                               % If more than just applied voltage IDs were provided...
                
                % Set the number of applied voltages to create to be the number of provided IDs.
                num_applied_voltages_to_create = length( IDs );
                
            elseif nargin == 2                                          % If just the applied voltage IDs were provided...
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                % Determine who to interpret this number of IDs.
                if num_IDs == 1                                     % If the number of IDs is one...
                    
                    % Then create a number of applied voltages equal to the specific ID.  (i.e., in this case we are treating the single provided ID value as the number of applied voltages that we want to create.)
                    num_applied_voltages_to_create = IDs;
                    
                    % Preallocate an array of IDs.
                    IDs = self.generate_unique_applied_voltage_IDs( num_applied_voltages_to_create );
                    
                else                                                % Otherwise... ( More than one ID was provided... )
                    
                    % Set the number of applied voltages to create to be the number of provided applied voltage IDs.
                    num_applied_voltages_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1                                      % If no input arguments were provided... ( Beyond the default self argument. )
                
                % Set the number of applied voltages to create to one.
                num_applied_voltages_to_create = 1;
                
            end
            
            % Set the default input arguments.
            if nargin < 7, b_enableds = true( 1, num_applied_voltages_to_create ); end
            if nargin < 6, V_apps = cell( 1, num_applied_voltages_to_create ); end
            if nargin < 5, ts = zeros( 1, num_applied_voltages_to_create ); end
            if nargin < 4, neuron_IDs = zeros( 1, num_applied_voltages_to_create ); end
            if nargin < 3, names = repmat( { '' }, 1, num_applied_voltages_to_create ); end
            if nargin < 2, IDs = self.generate_unique_applied_voltage_IDs( num_applied_voltages_to_create ); end
            
            % Create each of the spcified applied voltages.
            for k = 1:num_applied_voltages_to_create                         % Iterate through each of the applied voltages we want to create...
                
                % Create this applied voltage.
                self = self.create_applied_voltage( IDs(k), names{k}, neuron_IDs(k), ts( :, k ), V_apps( :, k ), b_enableds(k) );
                
            end
            
        end
        
        
        % Implement a function to delete an applied voltage.
        function self = delete_applied_voltage( self, applied_voltage_ID )
            
            % Retrieve the index associated with this applied voltage.
            applied_voltage_index = self.get_applied_voltage_index( applied_voltage_ID );
            
            % Remove this applied voltage from the array of applied voltages.
            self.applied_voltages( applied_voltage_index ) = [  ];
            
            % Decrease the number of applied voltages counter.
            self.num_applied_voltages = self.num_applied_voltages - 1;
            
        end
        
        
        % Implement a function to delete multiple applied voltages.
        function self = delete_applied_voltages( self, applied_voltage_IDs )
            
            % Set the default input arguments.
            if nargin < 2, applied_voltage_IDs = 'all'; end
            
            % Validate the applied voltage IDs.
            applied_voltage_IDs = self.validate_applied_voltage_IDs( applied_voltage_IDs );
            
            % Retrieve the number of applied voltages to delete.
            num_applied_voltages_to_delete = length( applied_voltage_IDs );
            
            % Delete each of the specified applied voltages.
            for k = 1:num_applied_voltages_to_delete                      % Iterate through each of the applied voltages we want to delete...
                
                % Delete this applied voltage.
                self = self.delete_applied_voltage( applied_voltage_IDs(k) );
                
            end
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save applied voltage manager data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Voltage_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load applied voltage manager data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Voltage_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load applied voltage data from an xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
            
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Applied_Voltage_Data.xlsx'; end
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED VOLTAGE DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic
            
            % Load the applied voltage data.
            [ applied_voltage_IDs, applied_voltage_names, applied_voltage_neuron_IDs, applied_voltage_ts, applied_voltage_V_apps ] = self.data_loader_utilities.load_applied_voltage_data( file_name, directory );
            
            % Define the number of synapses.
            num_applied_voltages_to_load = length( applied_voltage_IDs );
            
            % Preallocate an array of applied voltages.
            applied_voltages_to_load = repmat( applied_voltage_class(  ), 1, num_applied_voltages_to_load );
            
            % Create each applied voltage object.
            for k = 1:num_applied_voltages_to_load               % Iterate through each of the applied voltages...
                
                % Create this applied voltage.
                applied_voltages_to_load(k) = applied_voltage_class( applied_voltage_IDs(k), applied_voltage_names{k}, applied_voltage_neuron_IDs(k), applied_voltage_ts( :, k ), applied_voltage_V_apps( :, k ) );
                
            end
            
            % Determine whether to append the applied voltages we just loaded.
            if b_append                         % If we want to append the applied voltages we just loaded...
                
                % Append the applied voltages we just loaded to the array of existing applied voltages.
                self.applied_voltages = [ self.applied_voltages applied_voltages_to_load ];
                
                % Update the number of applied voltages.
                self.num_applied_voltages = length( self.applied_voltages );
                
            else                                % Otherwise...
                
                % Replace the existing applied voltages with the applied voltages we just loaded.
                self.applied_voltages = applied_voltages_to_load;
                
                % Update the number of applied voltages.
                self.num_applied_voltages = length( self.applied_voltages );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED VOLTAGE DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        
    end
end

