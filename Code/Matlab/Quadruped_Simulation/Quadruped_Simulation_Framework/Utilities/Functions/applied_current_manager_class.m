classdef applied_current_manager_class

    % This class contains properties and methods related to managing applied currents.
    
    %% APPLIED CURRENT MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        applied_currents
        num_applied_currents
        
        array_utilities
        data_loader_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
    
       NUM_MULTISTATE_CPG_APPLIED_CURRENTS = 1;                     % [#] Number of Multistate CPG Applied Currents.
       NUM_MULTIPLICATION_APPLIED_CURRENTS = 1;                     % [#] Number of Multiplication Applied Currents.
       NUM_INTEGRATION_APPLIED_CURRENTS = 2;                        % [#] Number of Integration Applied Currents.
        
    end
    
    
    %% APPLIED CURRENT MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_manager_class( applied_currents )
            
            % Create an instance of the data loader utilities class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Create an instance of the array manager class.
            self.array_utilities = array_utilities_class(  );
            
            % Set the default properties.
%             if nargin < 1, self.applied_currents = applied_current_class(  ); else, self.applied_currents = applied_currents; end
            if nargin < 1, self.applied_currents = [  ]; else, self.applied_currents = applied_currents; end

            % Compute the number of applied currents.
            self.num_applied_currents = length( self.applied_currents );
            
        end
        
        
        %% General Get & Set Applied Current Property Functions
        
        % Implement a function to retrieve the properties of specific applied currents.
        function xs = get_applied_current_property( self, applied_current_IDs, applied_current_property )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Determine how many applied currents to which we are going to apply the given method.
            num_properties_to_get = length( applied_current_IDs );
            
            % Preallocate a variable to store the applied current properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given applied current property for each applied current.
            for k = 1:num_properties_to_get                                                                         % Iterate through each of the properties to get...
                
                % Retrieve the index associated with this applied current ID.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.applied_currents(%0.0f).%s;', applied_current_index, applied_current_property );
                
                % Evaluate the given applied current property.
                eval( eval_str );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific applied currents.
        function self = set_applied_current_property( self, applied_current_IDs, applied_current_property_values, applied_current_property )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Validate the applied current property values.
            if ~isa( applied_current_property_values, 'cell' )                    % If the applied current property values are not a cell array...
                
                % Convert the applied current property values to a cell array.
                applied_current_property_values = num2cell( applied_current_property_values );
                
            end
            
            % Retreive the number of applied current IDs.
            num_applied_current_IDs = length( applied_current_IDs );
%             num_applied_current_IDs = size( applied_current_IDs, 2 );

            % Retrieve the number of applied current property values.
            num_applied_current_property_values = length( applied_current_property_values );
            
            % Ensure that the provided neuron property values have the same length as the provided applied current IDs.
            if ( num_applied_current_IDs ~= num_applied_current_property_values )                                     % If the number of provided applied current IDs does not match the number of provided property values...
               
                % Determine whether to agument the property values.
                if num_applied_current_property_values == 1                                                  % If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
%                     applied_current_property_values = applied_current_property_values*ones( 1, num_applied_current_IDs );
                    applied_current_property_values = repmat( applied_current_property_values, [ 1, num_applied_current_IDs ] );

                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided applied current propety values must match the number of provided applied current IDs, unless a single applied current property value is provided.' )
                    
                end
                
            end
            
            
            % Set the properties of each applied current.
            for k = 1:self.num_applied_currents                   % Iterate through each applied current...
                
                % Determine the index of the applied current property value that we want to apply to this applied current (if we want to set a property of this applied current).
                index = find( self.applied_currents(k).ID == applied_current_IDs, 1 );
                
                % Determine whether to set a property of this applied current.
                if ~isempty( index )                         % If a matching applied current ID was detected...
                    
                    % Create an evaluation string that sets the desired applied current property.
                    eval_string = sprintf( 'self.applied_currents(%0.0f).%s = applied_current_property_values{%0.0f};', k, applied_current_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end
        
        
        %% Specific Get & Set Functions
        
        % Implement a function to retrieve all of the neuron IDs.
        function applied_current_IDs = get_all_applied_current_IDs( self )
            
            % Preallocate a variable to store the applied current IDs.
            applied_current_IDs = zeros( 1, self.num_applied_currents );
            
            % Retrieve the ID associated with each applied current.
            for k = 1:self.num_applied_currents                             % Iterate through each of the applied currents...
                
                % Retrieve this applied current ID.
                applied_current_IDs(k) = self.applied_currents(k).ID;
                
            end
            
        end
        
        
        % Implement a function to retrieve the number of time steps of the specified applied currents.
        function num_timesteps = get_num_timesteps( self, applied_current_IDs, process_option )
            
            % Set the default input arguments.
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the number of timesteps.
            if all( applied_current_IDs == -1 )                         % If all of the applied current IDs are invalid...
            
                % Set the number of timesteps to zero.
                num_timesteps = 0;
                
            else                                                        % Otherwise...
                
                % Remove any invalid applied current IDs.
                applied_current_IDs( applied_current_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied currents (if desired).
                if b_filter_disabled, applied_current_IDs = self.remove_disabled_applied_current_IDs( applied_current_IDs ); end
                
                % Retrieve the number of timesteps associated with each applied current.
                num_timesteps = cell2mat( self.get_applied_current_property( applied_current_IDs, 'num_timesteps' ) );
                
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
        
        
        % Implement a function to retrieve the step size of the specified applied currents.
        function dt = get_dts( self, applied_current_IDs, process_option, b_filter_disabled )
            
            % Set the default input arguments.
            if nargin < 4, b_filter_disabled = false; end
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the step size.
            if all( applied_current_IDs == -1 )                         % If all of the applied current IDs are invalid...
                
                % Set the step size to zero.
                dt = 1e-3;
                
            else                                                        % Otherwise...
                
                % Remove any invalid applied current IDs.
                applied_current_IDs( applied_current_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied currents (if desired).
                if b_filter_disabled, applied_current_IDs = self.remove_disabled_applied_current_IDs( applied_current_IDs ); end
                
                % Retrieve the step size associated with each applied current.
                dt = cell2mat( self.get_applied_current_property( applied_current_IDs, 'dt' ) );
                
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
        
        
        % Implement a function to retrieve the final time of the specified applied currents.
        function tf = get_tfs( self, applied_current_IDs, process_option, b_filter_disabled )
            
            % Set the default input arguments.
            if nargin < 4, b_filter_disabled = false; end
            if nargin < 3, process_option = 'none'; end
            
            % Determine how to compute the final time.
            if all( applied_current_IDs == -1 )             % If all of the applied current IDs are invalid...
            
                % Set the final time to zero.
                tf = 0;
                
            else                                            % Otherwise...
                
                % Remove any invalid applied current IDs.
                applied_current_IDs( applied_current_IDs == -1 ) = [  ];
                
                % Remove IDs associated with disabled applied currents (if desired).
                if b_filter_disabled, applied_current_IDs = self.remove_disabled_applied_current_IDs( applied_current_IDs ); end
                
                % Retrieve the final time associated with each applied current.
                tf = cell2mat( self.get_applied_current_property( applied_current_IDs, 'tf' ) );
                
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
        
        
        % Implement a function to retrieve the applied currents.
        function I_apps = get_Iapps( self, applied_current_IDs, dt, tf )
            
            % Set the default input arguments.
            if nargin < 4, tf = [  ]; end
            if nargin < 3, dt = [  ]; end
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Determine how many applied currents to get.
            num_applied_currents_to_get = length( applied_current_IDs );
                        
            % Determine whether we need to set the final time.
            if isempty( tf )                                                                % If the final time is empty...
               
                % Compute the maximum final time among the given applied currents.
                tf = self.get_tfs( applied_current_IDs, 'max' );
                
            end
            
            % Determine whether we need to set the step size.
            if isempty( dt )                                                                % If the step size is empty...
                
                % Compute the minimum step size among the given applied currents.
                dt = self.get_dts( applied_current_IDs, 'min' );
                
            end
            
            % Compute the number of time steps.
            num_timesteps = floor( round( tf/dt, 8 ) ) + 1;
            
            % Preallocate a variable to store the applied current properties.
            I_apps = zeros( num_timesteps, num_applied_currents_to_get );

            % Retrieve the given neuron property for each applied current.
            for k = 1:num_applied_currents_to_get                           % Iterate through each of the currents to retrieve...
                
                % Retrieve the index associated with this applied current ID.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k), 'ignore' );
                
                % Determine how to retrieve this applied current.
                if ( applied_current_index >= 0 ) && ( self.applied_currents( applied_current_index ).b_enabled )                                                      % If the applied current ID is greater than or equal to zero...

                    % Retrieve the applied currents.
                    I_apps( :, k ) = self.applied_currents( applied_current_index ).sample_Iapp( dt, tf );
                                    
                elseif ( applied_current_index == -1 ) || ( ~self.applied_currents( applied_current_index ).b_enabled )                                                % If the applied current ID is negative one...
                    
                    % Set the applied current to zero.
                    I_apps( :, k ) = zeros( num_timesteps, 1 );
                    
                else                                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Applied current ID %0.2f not recognized.', applied_current_IDs(k) )
                    
                end
                
            end
            
        end
        
        
        %% Applied Current Index & ID Functions
        
        % Implement a function to retrieve the index associated with a given applied_current ID.
        function applied_current_index = get_applied_current_index( self, applied_current_ID, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Set a flag variable to indicate whether a matching applied_current index has been found.
            b_match_found = false;
            
            % Initialize the applied_current index.
            applied_current_index = 0;
            
            while ( applied_current_index < self.num_applied_currents ) && ( ~b_match_found )
                
                % Advance the applied_current index.
                applied_current_index = applied_current_index + 1;
                
                % Check whether this applied_current index is a match.
                if self.applied_currents( applied_current_index ).ID == applied_current_ID                       % If this applied_current has the correct applied_current ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the applied current index.
            if ~b_match_found                                                       % If a match was not found...
            
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                            % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No applied current with ID %0.0f.', applied_current_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                     % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No applied current with ID %0.0f.', applied_current_ID )
                    
                    % Set the applied current index to negative one.
                    applied_current_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                       % If the undetected option is set to 'ignore'...
                    
                    % Set the applied current index to negative one.
                    applied_current_index = -1;                    
                    
                else                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
            
            end
            
        end
        
        
        % Implement a function to validate applied_current IDs.
        function applied_current_IDs = validate_applied_current_IDs( self, applied_current_IDs )
            
            % Determine whether we want get the desired applied_current property from all of the applied_currents.
            if isa( applied_current_IDs, 'char' )                                                      % If the applied_current IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( applied_current_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the applied_current IDs.
                    applied_current_IDs = zeros( 1, self.num_applied_currents );
                    
                    % Retrieve the applied_current ID associated with each applied_current.
                    for k = 1:self.num_applied_currents                   % Iterate through each applied_current...
                        
                        % Store the applied_current ID associated with the current applied_current.
                        applied_current_IDs(k) = self.applied_currents(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Applied current ID must be either an array of valid applied_current IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to check if the existing applied current IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_applied_current_IDs( self )
            
            % Retrieve all of the existing applied current IDs.
            applied_current_IDs = self.get_all_applied_current_IDs(  );
            
            % Determine whether all entries are unique.
            if length( unique( applied_current_IDs ) ) == self.num_applied_currents                    % If all of the applied current IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_applied_currents );
                
            else                                                                     % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, self.num_applied_currents );
                
                % Determine which applied currents have duplicate IDs.
                for k1 = 1:self.num_applied_currents                          % Iterate through each applied current...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another applied current with the same ID.
                    while ( k2 < self.num_applied_currents ) && ( ~match_logicals(k1) ) && ( k1 ~= ( k2 + 1 ) )                    % While we haven't checked all of the applied currents and we haven't found a match...
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this applied current is a match.
                        if self.applied_currents(k2).ID == applied_current_IDs(k1)                              % If this applied current ID is a match...

                            % Set this match logical to true.
                            match_logicals(k1) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
                        
        end
        
        
        % Implement a function to check if a proposed applied current ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_applied_current_ID( self, applied_current_ID )
            
            % Retrieve all of the existing applied current IDs.
            applied_current_IDs = self.get_all_applied_current_IDs(  );
            
            % Determine whether the given applied current ID is one of the existing applied current IDs ( if so, provide the matching logicals and indexes ).
            [ b_match_found, match_logicals, match_indexes ] = self.array_utilities.is_value_in_array( applied_current_ID, applied_current_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to generate a unique applied current ID.
        function applied_current_ID = generate_unique_applied_current_ID( self )
            
            % Retrieve the existing applied current IDs.
            existing_applied_current_IDs = self.get_all_applied_current_IDs(  );
            
            % Generate a unique applied current ID.
            applied_current_ID = self.array_utilities.get_lowest_natural_number( existing_applied_current_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique applied current IDs.
        function applied_current_IDs = generate_unique_applied_current_IDs( self, num_IDs )

            % Retrieve the existing applied current IDs.
            existing_applied_current_IDs = self.get_all_applied_current_IDs(  );
            
            % Preallocate an array to store the newly generated applied current IDs.
            applied_current_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                           % Iterate through each of the new IDs...
            
                % Generate a unique applied current ID.
                applied_current_IDs(k) = self.array_utilities.get_lowest_natural_number( [ existing_applied_current_IDs, applied_current_IDs( 1:(k - 1) ) ] );
            
            end
                
        end
        
        
        % Implement a function to check whether a proposed applied current ID is a unique natural.
        function b_unique_natural = unique_natural_applied_current_ID( self, applied_current_ID )

            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this applied current ID is unique.
            b_unique = self.unique_applied_current_ID( applied_current_ID );
            
            % Determine whether this applied current ID is a unique natural.
            if b_unique && ( applied_current_ID > 0 ) && ( round( applied_current_ID ) == applied_current_ID )                     % If this applied current ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end
         
        
        % Implement a function to remove disabled applied current IDs.
        function applied_current_IDs = remove_disabled_applied_current_IDs( self, applied_current_IDs )

            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Retrieve the number of applied current IDs.
            num_applied_current_IDs = length( applied_current_IDs );

            % Create an array to store the indexes to remove.
            remove_indexes = zeros( 1, num_applied_current_IDs );
            
            % Remove any IDs associated with disabled applied currents.
            for k = 1:num_applied_current_IDs                       % Iterate through each of the applied current IDs...
               
                % Retrieve the index associated with this applied current ID.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k), 'ignore' );
                
                % Determine whether to remove this applied current ID.
                if ( applied_current_index == -1 ) || ( ~self.applied_currents( applied_current_index ).b_enabled )                         % If this applied current index is invalid or this applied current is disabled...
                    
                    % Store the indexes to remove.
                    remove_indexes(k) = k;
                    
                end
                
            end
            
            % Remove any extra zeros from the remove indexes.
            remove_indexes( remove_indexes == 0 ) = [  ];
            
            % Remove the applied current IDs.
            applied_current_IDs( remove_indexes ) = [  ];
            
        end
        
        
        %% Neuron ID Functions.
        
        % Implement a function to return the applied current ID associated with a given neuron ID.
        function applied_current_ID = neuron_ID2applied_current_ID( self, neuron_ID, undetected_option )
           
            % NOTE: This function assumes that only one applied current applies to each neuron.
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Initialize the applied current detected flag.
            b_applied_current_detected = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the applied current(s) that connect the specified neurons.
            while ( ~b_applied_current_detected ) && ( k < self.num_applied_currents )              % While a matching applied current has not yet been detected and we haven't looked through all of the applied currents...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this applied current connects the specified neurons.
                if ( self.applied_currents(k).neuron_ID == neuron_ID )
                    
                    % Set the applied current detected flag to true.
                    b_applied_current_detected = true;
                    
                end
                
            end
            
            % Determine whether a matching applied current was detected.
            if b_applied_current_detected                                   % If we found a matching applied current....
                
                % Retrieve the ID of the matching applied current.
                applied_current_ID = self.applied_currents(k).ID;
                
            else                                                    % Otherwise...
                
                % Determine how to handle the situation where we can not find a applied current that connects the selected neurons.
                if strcmpi( undetected_option, 'error' )                                    % If the error option is selected...
                    
                    % Throw an error.
                    error( 'No applied current found that stimulates neuron %0.0f.', neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                              % If the warning option is selected...
                    
                    % Throw a warning.
                    warning( 'No applied current found that stimulates neuron %0.0f.', neuron_ID )
                    
                    % Set the synapse ID to be negative one.
                    applied_current_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                               % If the ignore option is selected...
                    
                    % Set the applied current ID to be negative one.
                    applied_current_ID = -1;
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function return the applied current IDs associated with given neuron IDs.
        function applied_current_IDs = neuron_IDs2applied_current_IDs( self, neuron_IDs, undetected_option )
            
            % Set the default input argument.
            if nargin < 3, undetected_option = 'error'; end
            
            % Retrieve the number of applied currents to find.
            num_applied_currents_to_find = length( neuron_IDs );
            
            % Preallocate an array to store the applied current IDs.
            applied_current_IDs = zeros( 1, num_applied_currents_to_find );
            
            % Search for each applied current ID.
            for k = 1:num_applied_currents_to_find                              % Iterate through each set of neurons for which we are searching for a connecting applied current...
                
                % Retrieve the ID of the applied current that connects to this neuron.
                applied_current_IDs(k) = self.neuron_ID2applied_current_ID( neuron_IDs(k), undetected_option );
                
            end
            
        end
        
        
        % Implement a function to return the applied currents associated with given neuron IDs.
        function I_apps = neuron_IDs2Iapps( self, neuron_IDs, dt, tf, undetected_option )

            % Set the default input arguments.
            if nargin < 5, undetected_option = 'ignore'; end
            if nargin < 4, tf = [  ]; end
            if nargin < 3, dt = [  ]; end
            
            % Retrieve the applied current IDs.
            applied_current_IDs = self.neuron_IDs2applied_current_IDs( neuron_IDs, undetected_option );
            
            % Retrieve the applied currents.
            I_apps = self.get_Iapps( applied_current_IDs, dt, tf );
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to enable applied currents.
        function self = enable_applied_currents( self, applied_current_IDs )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
                        
            % Determine the number of applied currents to enable.
            num_applied_currents_to_enable = length( applied_current_IDs );
            
            % Enable all of the specified applied currents.
            for k = 1:num_applied_currents_to_enable                      % Iterate through all of the specified applied currents...
                
                % Retrieve this applied current index.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k) );
                
                % Enable this applied current.
                self.applied_currents( applied_current_index ).b_enabled = true;
                
            end
            
        end
        
        
        % Implement a function to disable applied currents.
        function self = disable_applied_currents( self, applied_current_IDs )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_synapse_IDs( applied_current_IDs );
                        
            % Determine the number of applied currents to disable.
            num_applied_currents_to_enable = length( applied_current_IDs );
            
            % Disable all of the specified applied currents.
            for k = 1:num_applied_currents_to_enable                      % Iterate through all of the specified applied currents...
                
                % Retrieve this applied current index.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k) );
                
                % Disable this applied current.
                self.applied_currents( applied_current_index ).b_enabled = false;
                
            end
            
        end
        
        
        % Implement a function to toggle applied current enable state.
        function self = toggle_enabled_applied_currents( self, applied_current_IDs )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
                        
            % Determine the number of applied currents to disable.
            num_applied_currents_to_enable = length( applied_current_IDs );
            
            % Disable all of the specified applied currents.
            for k = 1:num_applied_currents_to_enable                      % Iterate through all of the specified applied currents...
                
                % Retrieve this applied current index.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k) );
                
                % Toggle this applied current.
                self.applied_currents( applied_current_index ).b_enabled = ~self.applied_currents( applied_current_index ).b_enabled;
                
            end
            
        end
        
        
        %% Validation Functions
        
        % Ensure that each neuron has only one applied current.
        function b_one_to_one = one_to_one_applied_currents( self )
            
            % Set the one-to-one flag.
            b_one_to_one = true;
            
            % Initialize a counter variable.
            k = 0;
            
            % Preallocate arrays to store the neuron IDs.
            neuron_IDs = zeros( 1, self.num_applied_currents );
            b_enableds = false( 1, self.num_applied_currents );
            
            % Determine whether there is only one synapse between each neuron.
            while ( b_one_to_one ) && ( k < self.num_applied_currents )                             % While we haven't found an applied current repetition and we haven't checked all of the applied currents...
               
                % Advance the loop counter.
                k = k + 1;
                
                % Store these from neuron and to neuron IDs.
                neuron_IDs(k) = self.applied_currents(k).neuron_ID;

                % Determine whether we need to check this synapse for repetition.
                if k ~= 1                               % If this is not the first iteration...

                    % Determine whether this neuron ID is unique.
                    [ neuron_ID_match, neuron_ID_match_logicals ] = self.array_utilities.is_value_in_array( neuron_IDs(k), neuron_IDs( 1:( k  - 1) ) );

                    % Determine whether this applied current is a duplicate.
                    if neuron_ID_match && b_enableds(k) && any( neuron_ID_match_logicals & b_enableds( 1:( k  - 1 ) ) )                           % If this neuron ID is a match, this applied current is enabled, and the matching applied current is enabled...

                        % Set the one-to-one flag to false (this applied current is a duplicate).
                        b_one_to_one = false;

                    end
                
                end
                
            end            
            
        end
        
        
        %% Applied Current Creation Functions
        
        % Implement a function to create a new applied current.
        function [ self, ID ] = create_applied_current( self, ID, name, neuron_ID, ts, I_apps, b_enabled )
            
            % Set the default input arguments.
            if nargin < 7, b_enabled = true; end
            if nargin < 6, I_apps = 0; end
            if nargin < 5, ts = 0; end
            if nargin < 4, neuron_ID = 0; end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = self.generate_unique_applied_current_ID(  ); end
            
            % Ensure that this neuron ID is a unique natural.
            assert( self.unique_natural_applied_current_ID( ID ), 'Proposed applied current ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the applied current class.
            applied_current = applied_current_class( ID, name, neuron_ID, ts, I_apps, b_enabled );
            
            % Append this applied current to the array of existing applied currents.
            self.applied_currents = [ self.applied_currents applied_current ];
            
            % Increase the number of applied currents counter.
            self.num_applied_currents = self.num_applied_currents + 1;
                        
        end
            
            
        % Implement a function to create multiple applied currents.
        function [ self, IDs ] = create_applied_currents( self, IDs, names, neuron_IDs, tss, I_appss, b_enableds )
            
            % Determine whether number of applied currents to create.
            if nargin > 2                                               % If more than just applied current IDs were provided...
                
                % Set the number of applied currents to create to be the number of provided IDs.
                num_applied_currents_to_create = length( IDs );
                
            elseif nargin == 2                                          % If just the applied current IDs were provided...
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                % Determine who to interpret this number of IDs.
                if num_IDs == 1                                     % If the number of IDs is one...
                    
                    % Then create a number of applied currents equal to the specific ID.  (i.e., in this case we are treating the single provided ID value as the number of applied currents that we want to create.)
                    num_applied_currents_to_create = IDs;
                    
                    % Preallocate an array of IDs.
                    IDs = self.generate_unique_applied_current_IDs( num_applied_currents_to_create );
                    
                else                                                % Otherwise... ( More than one ID was provided... )
                    
                    % Set the number of applied currents to create to be the number of provided applied current IDs.
                    num_applied_currents_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1                                      % If no input arguments were provided... ( Beyond the default self argument. )
                
                % Set the number of applied currents to create to one.
                num_applied_currents_to_create = 1;
                
            end
            
            % Set the default input arguments.
            if nargin < 7, b_enableds = true( 1, num_applied_currents_to_create ); end
            if nargin < 6, I_appss = zeros( 1, num_applied_currents_to_create ); end
            if nargin < 5, tss = zeros( 1, num_applied_currents_to_create ); end
            if nargin < 4, neuron_IDs = zeros( 1, num_applied_currents_to_create ); end
            if nargin < 3, names = repmat( { '' }, 1, num_applied_currents_to_create ); end
            if nargin < 2, IDs = self.generate_unique_applied_current_IDs( num_applied_currents_to_create ); end
            
            % Create each of the spcified applied currents.
            for k = 1:num_applied_currents_to_create                         % Iterate through each of the applied currents we want to create...
       
                % Create this applied current.
                self = self.create_applied_current( IDs(k), names{k}, neuron_IDs(k), tss( :, k ), I_appss( :, k ), b_enableds(k) );
            
            end
            
        end
        
        
        % Implement a function to delete an applied current.
        function self = delete_applied_current( self, applied_current_ID )
            
            % Retrieve the index associated with this applied current.
            applied_current_index = self.get_applied_current_index( applied_current_ID );
            
            % Remove this applied current from the array of applied currents.
            self.applied_currents( applied_current_index ) = [  ];
            
            % Decrease the number of applied currents counter.
            self.num_applied_currents = self.num_applied_currents - 1;
            
        end
        
        
        % Implement a function to delete multiple applied currents. 
        function self = delete_applied_currents( self, applied_current_IDs )
            
            % Set the default input arguments.
            if nargin < 2, applied_current_IDs = 'all'; end
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Retrieve the number of applied currents to delete.
            num_applied_currents_to_delete = length( applied_current_IDs );
            
            % Delete each of the specified applied currents.
            for k = 1:num_applied_currents_to_delete                      % Iterate through each of the applied currents we want to delete...
                
                % Delete this applied current.
                self = self.delete_applied_current( applied_current_IDs(k) );
                
            end
            
        end
       
        
        %% Subnetwork Applied Current Creation Functions
        
        % Implement a function to create the applied currents for a multistate CPG subnetwork.
        function [ self, applied_current_ID ] = create_multistate_cpg_applied_currents( self, neuron_IDs )
            
            % Create an applied current for the third neuron.
            [ self, applied_current_ID ] = self.create_applied_currents( self.NUM_MULTISTATE_CPG_APPLIED_CURRENTS );
            
            % Set the applied current name.
            self = self.set_applied_current_property( applied_current_ID, { sprintf( 'CPG %0.0f', applied_current_ID ) }, 'name' );
            
            % Connect the applied current to the final neuron.
            self = self.set_applied_current_property( applied_current_ID, neuron_IDs( end ), 'neuron_ID' );
            
        end
        
        
        % Implement a function to create the applied currents for a multiplication subnetwork.
        function [ self, applied_current_IDs ] = create_multiplication_applied_currents( self, neuron_IDs )
            
            % Create an applied current for the third neuron.
            [ self, applied_current_IDs ] = self.create_applied_currents( self.NUM_MULTIPLICATION_APPLIED_CURRENTS );
            
            % Set the name of the applied current.
            self = self.set_applied_current_property( applied_current_IDs, { 'Inter' }, 'name' );

            % Connect the multiplication subnetwork applied currents to the multiplication subnetwork neurons.
            self = self.set_applied_current_property( applied_current_IDs, neuron_IDs( 3 ), 'neuron_ID' ); 
            
        end
        
        
        % Implement a function to create the applied currents for an integration subnetwork.
        function [ self, applied_current_IDs ] = create_integration_applied_currents( self, neuron_IDs )
            
            % Create an applied current for each neuron.
            [ self, applied_current_IDs ] = self.create_applied_currents( self.NUM_INTEGRATION_APPLIED_CURRENTS );
            
            % Set the name of the applied currents.
            self = self.set_applied_current_property( applied_current_IDs, { 'Int1', 'Int2' }, 'name' );
            
            % Connect the integration subnetwork applied currents to the integration subnetwork neurons.
            self = self.set_applied_current_property( applied_current_IDs, neuron_IDs, 'neuron_ID' );
            
        end
        
        
        %% Subnetwork Applied Current Design Functions
        
        % Implement a function to design the applied currents for a multistate cpg subnetwork.
        function self = design_multistate_cpg_applied_current( self, neuron_IDs, dt, tf )
            
            % Create the applied current time vector.
            ts = ( 0:dt:tf )';
            
            % Create the applied current magnitude vector.
            I_apps = zeros( length( ts ), 1 ); I_apps( 1 ) = 20e-9;
                        
            % Retrieve the applied current ID associated with the given final neuron ID.
            applied_current_ID = self.neuron_ID2applied_current_ID( neuron_IDs( end ) );
            
            % Set the applied current time vector.
            self = self.set_applied_current_property( applied_current_ID, { ts }, 'ts' );
            
            % Set the applied current magnitude vector.
            self = self.set_applied_current_property( applied_current_ID, { I_apps }, 'I_apps' );
            
        end
        
        
        % Implement a function to design the applied currents for a multiplication subnetwork.
        function self = design_multiplication_applied_current( self, neuron_IDs, Gm3, R3 )
            
            % Get the applied currents IDs that comprise this multiplication subnetwork.            
            applied_current_ID3 = self.neuron_ID2applied_current_ID( neuron_IDs( 3 ), 'ignore' );
            
            % Set the applied current magnitude.
            self = self.set_applied_current_property( applied_current_ID3, Gm3*R3, 'I_apps' );
            
        end
        
        
        % Implement a function to design the applied currents for an integration subnetwork.
        function self = design_integration_applied_currents( self, neuron_IDs, Gm, R )
            
            % Get the applied current IDs that comprise this integration subnetwork.
            applied_current_IDs = self.neuron_IDs2applied_current_IDs( neuron_IDs, 'ignore' );
            
            % Set the applied current magnitude.
            self = self.set_applied_current_property( applied_current_IDs, Gm*R, 'I_apps' );
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save applied current manager data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load applied current manager data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load applied current data from an xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
        
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Applied_Current_Data.xlsx'; end
        
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED CURRENT DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic

            % Load the applied current data.
            [ applied_current_IDs, applied_current_names, applied_current_neuron_IDs, applied_current_ts, applied_current_I_apps ] = self.data_loader_utilities.load_applied_current_data( file_name, directory );
            
            
            % Define the number of synapses.
            num_applied_currents_to_load = length( applied_current_IDs );

            % Preallocate an array of applied currents.
            applied_currents_to_load = repmat( applied_current_class(  ), 1, num_applied_currents_to_load );

            % Create each applied current object.
            for k = 1:num_applied_currents_to_load               % Iterate through each of the applied currents...

                % Create this applied current.
                applied_currents_to_load(k) = applied_current_class( applied_current_IDs(k), applied_current_names{k}, applied_current_neuron_IDs(k), applied_current_ts( :, k ), applied_current_I_apps( :, k ) );

            end
            
            % Determine whether to append the applied currents we just loaded.
            if b_append                         % If we want to append the applied currents we just loaded...
                
                % Append the applied currents we just loaded to the array of existing applied currents.
                self.applied_currents = [ self.applied_currents applied_currents_to_load ];
                
                % Update the number of applied currents.
                self.num_applied_currents = length( self.applied_currents );
                
            else                                % Otherwise...
                
                % Replace the existing applied currents with the applied currents we just loaded.
                self.applied_currents = applied_currents_to_load;
                
                % Update the number of applied currents.
                self.num_applied_currents = length( self.applied_currents );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED CURRENT DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        

    end
end

