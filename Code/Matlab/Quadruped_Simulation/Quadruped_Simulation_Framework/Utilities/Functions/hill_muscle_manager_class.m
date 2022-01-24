classdef hill_muscle_manager_class
    
    % This class contains properties and methods related to hill muscles.
    
    %% HILL MUSCLE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        hill_muscles
        num_hill_muscles
        
        activation_type
        
        conversion_manager
        
    end
    
    
    %% HILL MUSCLE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = hill_muscle_manager_class( hill_muscles, activation_type )
            
            % Set the default hill muscle manager properties.
            if nargin < 2, self.activation_type = 'total'; else, self.activation_type = activation_type; end
            if nargin < 1, self.hill_muscles = hill_muscle_class(  ); else, self.hill_muscles = hill_muscles; end
            
            % Set the number of hill muscles.
            self.num_hill_muscles = length( self.hill_muscles );
            
            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
        end
        
        
        %% Hill Muscle Manager General Get & Set Functions
        
        % Implement a function to retrieve the index associated with a given muscle ID.
        function muscle_index = get_muscle_index( self, muscle_ID )
            
            % Set a flag variable to indicate whether a matching muscle index has been found.
            bMatchFound = false;
            
            % Initialize the muscle index.
            muscle_index = 0;
            
            while (muscle_index < self.num_hill_muscles) && (~bMatchFound)
                
                % Advance the muscle index.
                muscle_index = muscle_index + 1;
                
                % Check whether this muscle index is a match.
                if self.hill_muscles(muscle_index).ID == muscle_ID                       % If this muscle has the correct muscle ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No muscle with ID %0.0f.', muscle_ID)
                
            end
            
        end
        
        
        % Implement a function to retrieve the properties of specific muscles.
        function xs = get_muscle_property( self, muscle_IDs, muscle_property )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa(muscle_IDs, 'char')                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp(muscle_IDs, 'all') || strcmp(muscle_IDs, 'All')                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the muscle IDs.
                    muscle_IDs = zeros(1, self.num_hill_muscles);
                    
                    % Retrieve the muscle ID associated with each muscle.
                    for k = 1:self.num_hill_muscles                   % Iterate through each muscle...
                        
                        % Store the muscle ID associated with the current muscle ID.
                        muscle_IDs(k) = self.hill_muscles(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Muscle_IDs must be either an array of valid muscle IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
            % Determine how many muscles to which we are going to apply the given method.
            num_properties_to_get = length(muscle_IDs);
            
            % Preallocate a variable to store the muscle properties.
%             xs = zeros(1, num_properties_to_get);
            xs = cell( 1, num_properties_to_get );

            % Retrieve the given muscle property for each muscle.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Define the eval string.
%                 eval_str = sprintf( 'xs(k) = self.hill_muscles(%0.0f).%s;', muscle_index, muscle_property );
                eval_str = sprintf( 'xs{k} = self.hill_muscles(%0.0f).%s;', muscle_index, muscle_property );

                % Evaluate the given muscle property.
                eval(eval_str);
                
            end
            
        end
        
        
        % Implement a function to store given a given muscle property into the muscle manager.
        function self = set_muscle_property( self, muscle_IDs, muscle_property_values, muscle_property, bSaturateValues )
            
            % Set the default staturate value flag.
            if nargin < 5, bSaturateValues = false; end
            
            % Ensure that the number of muscle IDs matches the number of provided muscle property values.
            if length(muscle_IDs) ~= length(muscle_property_values)                     % If the number of muscle IDs does not match the number of muscle property values...
                
                % Throw an error.
                error('The number of provided muscle IDs must match the number of provided muscle property values.')
                
            end
            
            % Retrieve the number of muscle property values.
            num_muscle_IDs = length(muscle_IDs);
            
            % Store each muscle muscle property value in the appropriate muscle of the muscle manager.
            for k = 1:num_muscle_IDs                   % Iterate through each muscle ID whose property we want to set...
                
                % Determine the muscle index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Define the eval string.
                if bSaturateValues                      % Determine whether we want to saturate the muscle propery...
                    
                    % Create the evaluation string including saturation.
                    eval_str = sprintf( 'self.hill_muscles(%0.0f).%s = self.hill_muscles(%0.0f).saturate_value( muscle_property_values(%0.0f), self.hill_muscles(%0.0f).%s );', muscle_index, muscle_property, muscle_index, k, muscle_index, strcat(muscle_property, '_domain') );
                
                else                                    % Otherwise...
                    
                    % Create the evaluation string excluding saturation.
                    eval_str = sprintf( 'self.hill_muscles(%0.0f).%s = muscle_property_values(%0.0f);', muscle_index, muscle_property, k );
                    
                end
                
                % Evaluate the given muscle property.
                eval(eval_str);
                
            end
            
        end
        
        
        %% Hill Muscle Manager Validation Functions
        
        % Implement a function to validate hill muscle IDs.
        function hill_muscle_IDs = validate_hill_muscle_IDs( self, hill_muscle_IDs )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa( hill_muscle_IDs, 'char' )                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( hill_muscle_IDs, 'all' ) || strcmp( hill_muscle_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the muscle IDs.
                    hill_muscle_IDs = zeros( 1, self.num_hill_muscles );
                    
                    % Retrieve the muscle ID associated with each muscle.
                    for k = 1:self.num_hill_muscles                   % Iterate through each muscle...
                        
                        % Store the muscle ID associated with the current muscle ID.
                        hill_muscle_IDs(k) = self.hill_muscles(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Muscle_IDs must be either an array of valid muscle IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end 
            
        end
        
        
        % Implement a function to validate the activation type.
        function self = validate_activation_type( self )
           
            % Ensure that the activation type is valid.
            if ~( strcmp( self.activation_type, 'total' ) || strcmp( self.activation_type, 'Total' ) || strcmp( self.activation_type, 'active' ) || strcmp( self.activation_type, 'Active' ) )                  % If the activation type is invalid...
               
                % Set the activation type to total.
                self.activation_type = 'total';
                
            end
            
        end
        
        
        %% Hill Muscle Manager Specific Get Functions
                
        % Implement a function to retrieve the name of the specified hill muscles.
        function hill_muscle_names = get_hill_muscle_names( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of hill muscles of interest.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the hill muscle property.
            hill_muscle_names = cell( 1, num_hill_muscle_IDs );

            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Determine whether we have found a matching muscle.
                if muscle_index ~= -1           % If we have found a matching muscle...
                    
                    % Retrieve the name associated with this muscle.
                    hill_muscle_names{k} = self.hill_muscles(muscle_index).name;
                    
                end
                
            end 
            
        end
        
        
        % Implement a function to retrieve the activations associated with the specified hill muscles.
        function hill_muscle_activations = get_hill_muscle_activations( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of hill muscles of interest.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_activations = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_activations(k) = self.hill_muscles(muscle_index).activation;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the desired total muscle tensions associated with the specified hill muscles.
        function hill_muscle_desired_total_tensions = get_hill_muscle_desired_total_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_desired_total_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_desired_total_tensions(k) = self.hill_muscles(muscle_index).desired_total_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the desired active muscle tensions associated with the specified hill muscles.
        function hill_muscle_desired_active_tensions = get_hill_muscle_desired_active_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of muscles of interest.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_desired_active_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_desired_active_tensions(k) = self.hill_muscles(muscle_index).desired_active_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the desired passive muscle tensions associated with the specified hill muscles.
        function hill_muscle_desired_passive_tensions = get_hill_muscle_desired_passive_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of muscles of interest.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_desired_passive_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                hill_muscle_desired_passive_tensions(k) = self.hill_muscles(muscle_index).desired_passive_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the measured total muscle tensions associated with the specified hill muscles.
        function hill_muscle_measured_total_tensions = get_hill_muscle_measured_total_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of hill muscles.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_measured_total_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                hill_muscle_measured_total_tensions(k) = self.hill_muscles(muscle_index).measured_total_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the measured active muscle tensions associated with the specified hill muscles.
        function hill_muscle_measured_active_tensions = get_hill_muscle_measured_active_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine the number of hill muscles of interest.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_measured_active_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                hill_muscle_measured_active_tensions(k) = self.hill_muscles(muscle_index).measured_active_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the measured passive muscle tensions associated with the specified hill muscles.
        function hill_muscle_measured_passive_tensions = get_hill_muscle_measured_passive_tension( self, hill_muscle_IDs )
            
           % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_measured_passive_tensions = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_measured_passive_tensions(k) = self.hill_muscles(muscle_index).measured_passive_tension;
                
            end 
            
        end
        
        
        % Implement a function to retrieve the yank associated with the specified hill muscles.
        function hill_muscle_yanks = get_hill_muscle_yanks( self, hill_muscle_IDs )
            
            % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_yanks = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_yanks(k) = self.hill_muscles(muscle_index).yank;
                
            end
            
        end
        
        
        % Implement a function to retrieve the length associated with the specified hill muscles.
        function hill_muscle_lengths = get_hill_muscle_lengths( self, hill_muscle_IDs )
            
            % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_lengths = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_lengths(k) = self.hill_muscles(muscle_index).muscle_length;
                
            end
            
        end
        
        
        % Implement a function to retrieve the strains associated with the specified hill muscles.
        function hill_muscle_strains = get_hill_muscle_strains( self, hill_muscle_IDs )
            
            % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_strains = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_strains(k) = self.hill_muscles(muscle_index).muscle_strain;
                
            end
            
        end
        
        
        % Implement a function to retrieve the velocities associated with the specified hill muscles.
        function hill_muscle_velocities = get_hill_muscle_velocities( self, hill_muscle_IDs )
            
            % Validate the hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_hill_muscle_IDs = length( hill_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            hill_muscle_velocities = zeros( 1, num_hill_muscle_IDs );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_hill_muscle_IDs                  % Iterate through each of the specified muscles...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Retrieve the property associated with this muscle.
                hill_muscle_velocities(k) = self.hill_muscles(muscle_index).velocity;
                
            end
            
        end
        
        
        
        %% Hill Muscle Manager Call Muscle Method Function
        
        % Implement a function to that calls a specified muscle method for each of the specified muscles.
        function self = call_muscle_method( self, muscle_IDs, muscle_method )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa( muscle_IDs, 'char' )                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( muscle_IDs, 'all' ) || strcmp( muscle_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the muscle IDs.
                    muscle_IDs = zeros( 1, self.num_hill_muscles );
                    
                    % Retrieve the muscle ID associated with each muscle.
                    for k = 1:self.num_hill_muscles                   % Iterate through each muscle...
                        
                        % Store the muscle ID associated with the current muscle ID.
                        muscle_IDs(k) = self.hill_muscles(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Muscle_IDs must be either an array of valid muscle IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.hill_muscles(%0.0f) = self.hill_muscles(%0.0f).%s();', muscle_index, muscle_index, muscle_method );
                
                % Evaluate the given muscle method.
                eval( eval_str );
                
            end
            
        end
        
        
        %% Hill Muscle Manager Tension Functions
        
        % Implement a function to compute the measured active & measured passive tension associated with the measured total tension of the specified muscle IDs.
        function self = measured_total_tensions2measured_active_passive_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the measured active and passive muscle tension associated with the measured total muscle tension of this hill muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).measured_total_tension2measured_active_passive_tension(  );
                
            end
            
        end
            
       
        % Implement a function to compute the measured total & passive tension associated with the measured active tension of the specified muscle IDs.
        function self = measured_active_tensions2measured_total_passive_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the measured total & passive tension associated with the measured active tension tension of this muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).measured_active_tension2measured_total_passive_tension(  );
                
            end

        end
        
        
        % Implement a function to compute the desired active & desired passive tension associated with the desired total tension of the specified muscle IDs.
        function self = desired_total_tensions2desired_active_passive_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the desired active and passive muscle tension associated with the desired total muscle tension of this hill muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).desired_total_tension2desired_active_passive_tension(  );
                
            end
            
        end
        
        
        % Implement a function to compute the desired total & passive tension associated with the desired active tension of the specified muscle IDs.
        function self = desired_active_tensions2desired_total_passive_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the desired total & passive tension associated with the desired active tension tension of this muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).desired_active_tension2desired_total_passive_tension(  );
                
            end

        end
        
        
        % Implement a function to compute the desired active tensions associated with the activation levels of the specified hill muscles.
        function self = activations2desired_active_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the measured active and passive muscle tension associated with the measured total muscle tension of this hill muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).activation2desired_active_tension(  );
                
            end
                
        end
        
        
        % Implement a function to compute the desired total tensions associated with the activation levels of the specified hill muscles.
        function self = activations2desired_total_tensions( self, hill_muscle_IDs )
            
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length( hill_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( hill_muscle_IDs(k) );
                
                % Compute the measured active and passive muscle tension associated with the measured total muscle tension of this hill muscle.
                self.hill_muscles(muscle_index) = self.hill_muscles(muscle_index).activation2desired_total_tension(  );
                
            end
                
        end
        
        
        % Implement a function to compute the tension associated with the activation levels of the specified hill muscles.
        function self = activation2desired_tension( self, hill_muscle_IDs )
           
            % Validate the provided hill muscle IDs.
            hill_muscle_IDs = self.validate_hill_muscle_IDs( hill_muscle_IDs );
            
            % Validate the activation type.
            self = validate_activation_type( self );
            
            % Determine how to compute the desired tension.
            if strcmp( self.activation_type, 'total' ) || strcmp( self.activation_type, 'Total' )                   % If the activation type is set to total...
                
                % Compute the desired total tension associated with the activation of the specified hill muscles.
                self = self.activations2desired_total_tensions( hill_muscle_IDs );
                
                % Compute the desired active and passive tension associated with the desired total tension of the specified hill muscles.
                self = self.desired_total_tensions2desired_active_passive_tensions( hill_muscle_IDs );
            
            elseif strcmp( self.activation_type, 'active' ) || strcmp( self.activation_type, 'Active' )             % If the activation type is set to active...
                
                % Compute the desired active tension associated with the activation of the specified hill muscles.
                self = self.activations2desired_active_tensions( hill_muscle_IDs );
                
                % Compute the desired passive and total tension associated with the desired active tension of the specified hill muscles.
                self = self.desired_active_tensions2desired_total_passive_tensions( hill_muscle_IDs );
                
            else                                                                                                    % Otherwise...
               
                % Throw an error.
                error('Activation type %s not recognized.  Valid activation types are: ''total'', ''Total'', ''active'', and ''Active''.')
                
            end
                
        end
        
            
        %% Feedback Functions
        
        % Implement a function to compute the type Ia, type Ib, and type II feedback associated with the current hill muscle velocity, measured total tension, and length, respectively.
        function self = muscle_properties2muscle_feedback( self )
            
            % Compute the hill muscle Type Ia (muscle velocity) feedback from the hill muscle velocity. ( Hill Muscle Velocity -> Hill Muscle Type Ia (Velocity) Feedback )
            self = self.call_muscle_method( 'all', 'velocity2typeIa_feedback' );

            % Compute the hill muscle Type Ib (muscle tension) feedback from the hill muscle total tension. ( Hill Muscle Total Tension -> Hill Muscle Type Ib (Tension) Feedback )
            self = self.call_muscle_method( 'all', 'measured_total_tension2typeIb_feedback' );

            % Compute the hill muscle Type II (muscle velocity) feedback from the hill muscle length. ( Hill Muscle Length -> Hill Muscle Type II (Length) Feedback )
            self = self.call_muscle_method( 'all', 'length2typeII_feedback' );
            
        end
        
        
    end
end

