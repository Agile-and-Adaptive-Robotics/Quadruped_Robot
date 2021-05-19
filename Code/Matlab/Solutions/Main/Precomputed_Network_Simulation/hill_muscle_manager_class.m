classdef hill_muscle_manager_class
    
    % This class contains properties and methods related to hill muscles.
    
    %% HILL MUSCLE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        hill_muscles
        num_hill_muscles
        conversion_manager
    end
    
    
    %% HILL MUSCLE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = hill_muscle_manager_class( hill_muscles )
            
            % Set the default hill muscle manager properties.
            if nargin < 1, self.hill_muscles = hill_muscle_class(); else, self.hill_muscles = hill_muscles; end
            
            % Set the number of hill muscles.
            self.num_hill_muscles = length(self.hill_muscles);
            
            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
        end
        
        
        %% Hill Muscle Manager Get & Set Functions
        
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
            xs = zeros(1, num_properties_to_get);
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs(k) = self.hill_muscles(%0.0f).%s;', muscle_index, muscle_property );
                
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
            num_muscles_to_evaluate = length(muscle_IDs);
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( muscle_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.hill_muscles(%0.0f) = self.hill_muscles(%0.0f).%s();', muscle_index, muscle_index, muscle_method );
                
                % Evaluate the given muscle method.
                eval(eval_str);
                
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
            self = self.hill_muscle_manager.call_muscle_method( 'all', 'length2typeII_feedback' );
            
        end
        
        
    end
end

