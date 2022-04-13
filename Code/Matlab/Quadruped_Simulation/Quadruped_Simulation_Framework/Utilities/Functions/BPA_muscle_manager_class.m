classdef BPA_muscle_manager_class
    
    % This class contains properties and methods related to managing the BPA muscles.
    
    %% BPA MUSCLE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        BPA_muscles
        num_BPA_muscles
        
        Ms
        Ts
        Js
        
    end
    
    
    %% BPA MUSCLE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = BPA_muscle_manager_class( BPA_muscles )
            
            % Define the default class properties.
            if nargin < 1, self.BPA_muscles = BPA_muscle_class(  ); else, self.BPA_muscles = BPA_muscles; end
            
            % Compute the number of BPA muscles.
            self.num_BPA_muscles = length( self.BPA_muscles );
            
            % Retrieve the home configuration of the BPA muscle attachment points of each BPA muscle.
            self.Ms = self.get_home_configurations(  );
            
            % Set the current configuration of the BPA muscle attachment points to be the home configuration of each BPA muscle.
            self.Ts = self.Ms;
                        
            % Retrieve the joint assignments of the BPA muscles.
            self.Js = self.get_joint_assignments(  );
            
        end
        
        
        %% Initialization Functions
        
        % Implement a function to propogate the home configurations from the constituent BPA muscles to the BPA muscle manager.
        function Ms = get_home_configurations( self )
            
            % Retrieve the number of BPA muscle attachment points.
            num_attachment_points = size( self.BPA_muscles(1).Ms, 3 );
            
            % Preallocate the BPA muscle attachment points configuration matrix.
            Ms = zeros( 4, 4, num_attachment_points, self.num_BPA_muscles );
            
            % Compute the BPA muscle attachment points configuration matrix.
            for k1 = 1:self.num_BPA_muscles                                     % Iterate through each of the BPA muscles...
                for k2 = 1:num_attachment_points                                % Iterate through each of the BPA muscle attachment points...
                
                    % Retrieve this BPA muscles home configuration.
                    Ms( :, :, k2, k1 ) = self.BPA_muscles(k1).Ms( :, :, k2 );
                
                end
            end
            
        end
        
        
        % Implement a function to propogate the joint assignments from the consistuent BPA muscles to the BPA muscle manager.
        function Js = get_joint_assignments( self )
            
            % Retrieve the number of BPA muscle attachment points.
            num_attachment_points = size( self.BPA_muscles(1).Js, 1 );
            
            % Preallocate the BPA muscle attachment point joint assignment matrix.
            Js = zeros( num_attachment_points, self.num_BPA_muscles );
            
            % Set the BPA muscle attachment point joint assignment matrix for each BPA muscle.
            for k = 1:self.num_BPA_muscles                  % Iterate through each BPA muscle...
               
                % Store the joint assignment matrix associated with this BPA muscle.
                Js( :, k ) = self.BPA_muscles(k).Js;
                
            end
            
        end
        
        
        %% BPA Muscle Manager Index & ID Validation Functions
        
        % Implement a function to retrieve the index associated with a given muscle ID.
        function muscle_index = get_muscle_index( self, BPA_muscle_ID )
            
            % Set a flag variable to indicate whether a matching muscle index has been found.
            bMatchFound = false;
            
            % Initialize the muscle index.
            muscle_index = 0;
            
            while (muscle_index < self.num_BPA_muscles) && (~bMatchFound)
                
                % Advance the muscle index.
                muscle_index = muscle_index + 1;
                
                % Check whether this muscle index is a match.
                if self.BPA_muscles(muscle_index).ID == BPA_muscle_ID                       % If this muscle has the correct muscle ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Set the muscle index to -1.
                muscle_index = -1;

            end
            
        end
        
        
        % Implement a function to validate the BPA muscle IDs.
        function BPA_muscle_IDs = validate_BPA_muscle_IDs( self, BPA_muscle_IDs )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa( BPA_muscle_IDs, 'char' )                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( BPA_muscle_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the muscle IDs.
                    BPA_muscle_IDs = zeros( 1, self.num_BPA_muscles );
                    
                    % Retrieve the muscle ID associated with each muscle.
                    for k = 1:self.num_BPA_muscles                   % Iterate through each muscle...
                        
                        % Store the muscle ID associated with the current muscle ID.
                        BPA_muscle_IDs(k) = self.BPA_muscles(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Muscle_IDs must be either an array of valid muscle IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
        end
        
        
        %% BPA Muscle Manager General Get & Set Functions
        
        % Implement a function to retrieve the properties of specific muscles.
        function xs = get_muscle_property( self, BPA_muscle_IDs, muscle_property )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_properties_to_get = length(BPA_muscle_IDs);
            
            % Preallocate a variable to store the muscle properties.
%             xs = zeros(1, num_properties_to_get);
            xs = cell( 1, num_properties_to_get );

            % Retrieve the given muscle property for each muscle.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Define the eval string.
%                 eval_str = sprintf( 'xs(k) = self.BPA_muscles(%0.0f).%s;', muscle_index, muscle_property );
                eval_str = sprintf( 'xs{k} = self.BPA_muscles(%0.0f).%s;', muscle_index, muscle_property );

                % Evaluate the given muscle property.
                eval(eval_str);
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific BPA muscles.
        function self = set_BPA_muscle_property( self, BPA_muscle_IDs, BPA_muscle_property_values, BPA_muscle_property )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Validate the BPA muscle property values.
            if ~isa( BPA_muscle_property_values, 'cell' )               % If the provided muscle property values are not a cell array...
               
                % Convert the BPA muscle property values to a cell array.
                BPA_muscle_property_values = num2cell( BPA_muscle_property_values );
                
            end
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find(self.BPA_muscles(k).ID == BPA_muscle_IDs, 1);
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Create an evaluation string that sets the desired BPA muscle property.
                    eval_string = sprintf('self.BPA_muscles(%0.0f).%s = BPA_muscle_property_values{%0.0f};', k, BPA_muscle_property, index);
                    
                    % Evaluate the evaluation string.
                    eval(eval_string);
                    
                end
            end
            
        end
        
        
        %% BPA Muscle Manager Specific Get Functions
        
        % Implement a function to get the names of BPAs specified by IDs.
        function BPA_names = get_BPA_muscle_names( self, BPA_muscle_IDs )
        
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_names_to_get = length(BPA_muscle_IDs);
            
            % Preallocate a variable to store the muscle properties.
            BPA_names = cell( 1, num_names_to_get );

            % Retrieve the given muscle property for each muscle.
            for k = 1:num_names_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether we have found a matching muscle.
                if muscle_index ~= -1           % If we have found a matching muscle...
                    
                    % Retrieve the name associated with this muscle.
                    BPA_names{k} = self.BPA_muscles(muscle_index).name;
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the IDs from all of the BPA muscles.
        function BPA_muscle_IDs = get_all_BPA_muscle_IDs( self )
        
            % Preallocate a variable to store the BPA muscle IDs.
            BPA_muscle_IDs = zeros( 1, self.num_BPA_muscles );
            
            % Retrieve each BPA muscle ID.
            for k = 1:self.num_BPA_muscles              % Iterate through all of the BPA muscles...
                
                BPA_muscle_IDs(k) = self.BPA_muscles(k).ID;
                
            end
                        
        end
        
        
        % Implement a function to retrieve the desired pressures from the specified BPA muscles.
        function BPA_muscle_desired_pressures = get_BPA_muscle_desired_pressures( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_desired_pressures_to_get = length(BPA_muscle_IDs);
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_desired_pressures = zeros( 1, num_desired_pressures_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_desired_pressures_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_desired_pressures(k) = self.BPA_muscles(muscle_index).desired_pressure;
                
            end
            
        end
        
        
        % Implement a function to retrieve the measured pressures from the specified BPA muscles.
        function BPA_muscle_measured_pressures = get_BPA_muscle_measured_pressures( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_measured_pressures_to_get = length(BPA_muscle_IDs);
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_measured_pressures = zeros( 1, num_measured_pressures_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_measured_pressures_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_measured_pressures(k) = self.BPA_muscles(muscle_index).measured_pressure;
                
            end
            
        end
        
        
        % Implement a function to retrieve the desired tensions from the specified BPA muscles.
        function BPA_muscle_desired_tensions = get_BPA_muscle_desired_tensions( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_desired_tensions_to_get = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_desired_tensions = zeros( 1, num_desired_tensions_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_desired_tensions_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_desired_tensions(k) = self.BPA_muscles(muscle_index).desired_tension;
                
            end
            
        end
        
        
        % Implement a function to retrieve the measured tensions from the specified BPA muscles.
        function BPA_muscle_measured_tensions = get_BPA_muscle_measured_tensions( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_measured_tensions_to_get = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_measured_tensions = zeros( 1, num_measured_tensions_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_measured_tensions_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_measured_tensions(k) = self.BPA_muscles(muscle_index).measured_tension;
                
            end
            
        end
        
        
        % Implement a function to retrieve the lengths associated with the specified BPA muscles.
        function BPA_muscle_lengths = get_BPA_muscle_lengths( self, BPA_muscle_IDs )
        
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_lengths_to_get = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_lengths = zeros( 1, num_lengths_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_lengths_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_lengths(k) = self.BPA_muscles(muscle_index).muscle_length;
                
            end
           
        end
        
        
        % Implement a function to retrieve the velocities associated with the specified BPA muscles.
        function BPA_muscle_velocities = get_BPA_muscle_velocities( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_velocities_to_get = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_velocities = zeros( 1, num_velocities_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_velocities_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_velocities(k) = self.BPA_muscles(muscle_index).velocity;
                
            end
            
        end
        
            
        % Implement a function to retrieve the strains associated with the specified BPA muscles.
        function BPA_muscle_strains = get_BPA_muscle_strains( self, BPA_muscle_IDs )
        
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_strains_to_get = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_strains = zeros( 1, num_strains_to_get );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_strains_to_get                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the name associated with this muscle.
                BPA_muscle_strains(k) = self.BPA_muscles(muscle_index).muscle_strain;
                
            end
            
        end
        
        
        % Implement a function to retrieve the yanks associated with the specified BPA muscles.
        function BPA_muscle_yanks = get_BPA_muscle_yanks( self, BPA_muscle_IDs )
        
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine the number of BPA muscles of interest.
            num_muscles = length( BPA_muscle_IDs );
            
            % Preallocate a variable to store the muscle properties.
            BPA_muscle_yanks = zeros( 1, num_muscles );
            
            % Retrieve the given muscle property for each muscle.
            for k = 1:num_muscles                  % Iterate through each of the specified BPAs...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Retrieve the value associated with this muscle.
                BPA_muscle_yanks(k) = self.BPA_muscles(muscle_index).yank;
                
            end
            
        end
        
        
        %% BPA Muscle Manager Specific Set Functions
        
        % Implement a function to set the measured pressure of specific BPA muscles.
        function self = set_BPA_muscle_measured_pressures( self, BPA_muscle_IDs, BPA_muscle_measured_pressures )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find( self.BPA_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Set the measured pressure of the matching BPA muscle.
                    self.BPA_muscles(k).measured_pressure = BPA_muscle_measured_pressures(index);
                    
                end
            end
            
        end
        
        
        % Implement a function to set the measured tension of specific BPA muscles.
        function self = set_BPA_muscle_measured_tensions( self, BPA_muscle_IDs, BPA_muscle_measured_tensions )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find( self.BPA_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Set the measured tension of the matching BPA muscle.
                    self.BPA_muscles(k).measured_tension = BPA_muscle_measured_tensions(index);
                    
                end
            end
            
        end
        
        
        % Implement a function to set the desired pressure of specific BPA muscles.
        function self = set_BPA_muscle_desired_pressures( self, BPA_muscle_IDs, BPA_muscle_desired_pressures )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find( self.BPA_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Set the desired pressure of the matching BPA muscle.
                    self.BPA_muscles(k).desired_pressure = BPA_muscle_desired_pressures(index);
                    
                end
            end
            
        end
        
        
        % Implement a function to set the desired tension of specific BPA muscles.
        function self = set_BPA_muscle_desired_tensions( self, BPA_muscle_IDs, BPA_muscle_desired_tensions )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find( self.BPA_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Set the desired tension of the matching BPA muscle.
                    self.BPA_muscles(k).desired_tension = BPA_muscle_desired_tensions(index);
                    
                end
            end
            
        end
        
        
        % Implement a function to set the yanks of the specified BPA muscles.
        function self = set_BPA_muscle_yanks( self, BPA_muscle_IDs, BPA_muscle_yanks )
        
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Set the properties of each BPA muscle.
            for k = 1:self.num_BPA_muscles                   % Iterate through each BPA muscle...
                
                % Determine the index of the BPA muscle property value that we want to apply to this BPA muscle (if we want to set a property of this BPA muscle).
                index = find( self.BPA_muscles(k).ID == BPA_muscle_IDs, 1 );
                
                % Determine whether to set a property of this BPA muscle.
                if ~isempty(index)                         % If a matching BPA muscle ID was detected...
                    
                    % Set the desired tension of the matching BPA muscle.
                    self.BPA_muscles(k).yank = BPA_muscle_yanks(index);
                    
                end
            end
            
        end
        
        
        %% BPA Muscle Manager Pressure-Force Functions
        
        % Implement a function to set the measure pressure of each BPA muscle to be the same as the desired pressure of each BPA muscle.
        function self = desired_pressures2measured_pressures( self, BPA_muscle_IDs )

            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Set the measured pressure of this muscle to be the same as the desired pressure.
                   self.BPA_muscles(muscle_index).measured_pressure = self.BPA_muscles(muscle_index).desired_pressure;
                
                end
                
            end
           
        end
       
        
        % Implement a function to set the measure tension of each BPA muscle to be the same as the desired tension of each BPA muscle.
        function self = desired_tensions2measured_tensions( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Set the measured tension of this muscle to be the same as the desired tension.
                   self.BPA_muscles(muscle_index).measured_tension = self.BPA_muscles(muscle_index).desired_tension;
                
                end
                
            end
           
        end
        
        
        % Implement a function to compute the desired pressure associated with the desired tension of each BPA muscle in this BPA muscle mananger.
        function self = desired_pressures2desired_tensions( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Compute the desired tension associated the desired pressure of this muscle.
                   self.BPA_muscles(muscle_index) = self.BPA_muscles(muscle_index).desired_pressure2desired_tension(  );
                
                end
                
            end
            
        end
        
        
        % Implement a function to compute the desired tension associated with the desired pressure of each BPA muscle in this BPA muscle mananger.
        function self = desired_tensions2desired_pressures( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Compute the desired tension associated the desired pressure of this muscle.
                   self.BPA_muscles(muscle_index) = self.BPA_muscles(muscle_index).desired_tension2desired_pressure(  );
                
                end
                
            end
            
        end
        
        
        %% BPA Muscle Manager Length-Strain Functions
        
        % Implement a function to compute the BPA muscle equilibrium strain associated with the BPA muscle measured pressure of the specified BPA muscle IDs.
        function self = get_BPA_muscle_strain_equilibrium( self, BPA_muscle_IDs )            
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                    
                    % Compute the BPA muscle equilibrium strain associated with the current BPA muscle measured pressure.
                    self.BPA_muscles(muscle_index) = self.BPA_muscles(muscle_index).measured_pressure2equilibrium_strain(  );
                    
                end
                
            end
            
        end
        
        
        % Implement a function to compute the BPA muscle equilibrium length associated with the BPA muscle equilibrium strain of the specified BPA muscle IDs.
        function self = equilibrium_strain2equilibrium_length( self, BPA_muscle_IDs )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles = length( BPA_muscle_IDs );
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Compute the BPA muscle equilibrium length associated with the current BPA muscle equilibrium strain.
                   self.BPA_muscles(muscle_index) = self.BPA_muscles(muscle_index).equilibrium_strain2equilibrium_length(  );
                
                end
                
            end
            
        end
        
        
        %% BPA Muscle Manager Call Muscle Methods Function
        
        % Implement a function to that calls a specified muscle method for each of the specified muscles.
        function self = call_muscle_method( self, BPA_muscle_IDs, muscle_method )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_BPA_muscle_IDs( BPA_muscle_IDs );
            
            % Determine how many muscles to which we are going to apply the given method.
            num_muscles_to_evaluate = length(BPA_muscle_IDs);
            
            % Evaluate the given muscle method for each muscle.
            for k = 1:num_muscles_to_evaluate               % Iterate through each of the muscles of interest...
                
                % Retrieve the index associated with this muscle ID.
                muscle_index = self.get_muscle_index( BPA_muscle_IDs(k) );
                
                % Determine whether to evaluate the given method for this BPA muscle.
                if muscle_index ~= -1                   % If a valid BPA muscle index was found...
                
                    % Define the eval string.
                    eval_str = sprintf( 'self.BPA_muscles(%0.0f) = self.BPA_muscles(%0.0f).%s();', muscle_index, muscle_index, muscle_method );

                    % Evaluate the given muscle method.
                    eval(eval_str);
                
                end
                
            end
            
        end
        
        
        %% Plotting Functions.
        
        % Implement a function to plot the BPA muscle attachment points of the constituent BPA muscles.
        function fig = plot_BPA_muscle_points( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if nargin < 2
                
                % Create a figure to store the BPA attachment points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('BPA Muscle Attachment Points')
                
            end
            
            % Plot the points of each BPA muscle.
            for k = 1:self.num_BPA_muscles          % Iterate through each BPA muscle...
            
                % Plot the points for this BPA muscle.
                fig = self.BPA_muscles(k).plot_BPA_muscle_points( fig, plotting_options );
            
            end
            
        end
        
        
    end
end

