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
        
        
        %% BPA Muscle Manager Set & Get Functions
        
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
%                 
%                 % Throw an error.
%                 error('No muscle with ID %0.0f.', BPA_muscle_ID)
                
                % Set the muscle index to -1.
                muscle_index = -1;

            end
            
        end
        
        
        % Implement a function to validate the BPA muscle IDs.
        function BPA_muscle_IDs = validate_muscle_IDs( self, BPA_muscle_IDs )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa( BPA_muscle_IDs, 'char' )                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( BPA_muscle_IDs, 'all' ) || strcmp( BPA_muscle_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
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
        
        
        % Implement a function to retrieve the properties of specific muscles.
        function xs = get_muscle_property( self, BPA_muscle_IDs, muscle_property )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_muscle_IDs( BPA_muscle_IDs );
            
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
            BPA_muscle_IDs = self.validate_muscle_IDs( BPA_muscle_IDs );
            
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
        
        
        %% BPA Muscle Manager Call Muscle Methods Function
        
        % Implement a function to that calls a specified muscle method for each of the specified muscles.
        function self = call_muscle_method( self, BPA_muscle_IDs, muscle_method )
            
            % Validate the BPA muscle IDs.
            BPA_muscle_IDs = self.validate_muscle_IDs( BPA_muscle_IDs );
            
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

