classdef joint_manager_class
    
    % This class contains properties and methods related to managing joints.
    
    %% JOINT MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        joints
        num_joints
        
        Ss
        Ms_joints
        Ts_joints
        Js_joints
        
        physics_manager
        
    end
    
    %% JOINT MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = joint_manager_class( joints )
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Define the default class properties.
            if nargin < 1, self.joints = joint_class(  ); else, self.joints = joints; end

            % Compute the number of joints.
            self.num_joints = length(self.joints);
            
            % Get the screw axes of the joints.
            self.Ss = self.get_screw_axes( );
            
            % Get the home configurations of the joints.
            self.Ms_joints = get_home_configurations( self );
            
            % Set the current configurations of the joints to be equal to the home configurations.
            self.Ts_joints = self.Ms_joints;
            
            % Set the joint assignments in the standard way (each joint is assigned to itself).
            self.Js_joints = self.physics_manager.get_standard_joint_assignments( 1, self.num_joints );
                        
        end
        
        
        %% Joint Manager Initialization Functions
        
        % Implement a function to validate the input properties.
        function x = validate_property( self, x, var_name )
            
            % Retrieve the number of dimensions of this variable.
            num_dims = length(size(x));
            
            % Retrieve the length of the final dimension.
            n = size( x, num_dims );
            
            % Define the repetition pattern.
            rep_pattern = ones( 1, n ); rep_pattern(end) = n;
            
            % Set the default variable name.
            if nargin < 3, var_name = 'properties'; end
            
            % Determine whether we need to repeat this property for each object.
            if n ~= self.num_joints                % If the number of instances of this property do not agree with the number of objects...
                
                % Determine whether to repeat this property for each object.
                if length(x) == 1                               % If only one property was provided...
                    
                    % Repeat the link property.
                    x = repmat( x, rep_pattern );
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided %s must match the number of objects being created.', var_name )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get the screw axes from the joints.
        function Ss = get_screw_axes( self )
            
            % Preallocate the screw axes.
            Ss = zeros( 6, self.num_joints );
            
            % Compute each screw axis.
            for k = 1:self.num_joints                       % Iterate through each of the screw axes...
                
                % Store this screw axis.
                Ss(:, k) = self.joints(k).S;
                
            end
            
        end
        
        
        % Implement a function to get the home configurations from the joints.
        function Ms_joints = get_home_configurations( self )
            
            % Preallocate the joint configuration matrix.
            Ms_joints = zeros( 4, 4, 1, self.num_joints );
            
            for k = 1:self.num_joints
                
                Ms_joints( :, :, 1, k ) = self.joints(k).M;
                
            end
            
        end
        
        
        % Implement a function to initialize the joint manager from joint data.
        function self = initialize_from_joint_data( IDs, names, parent_link_IDs, child_link_IDs, ps, Rs, vs, ws, ws_screws, thetas )
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class();
            
            % Define the default class properties.
            if nargin < 10, thetas = 0; end
            if nargin < 9, ws_screws = zeros( 3, 1 ); end
            if nargin < 8, ws = zeros( 3, 1 ); end
            if nargin < 7, vs = eye( 3, 1 ); end
            if nargin < 6, Rs = eye(3); end
            if nargin < 5, ps = zeros( 3, 1 ); end
            if nargin < 4, child_link_IDs = 0; end
            if nargin < 3, parent_link_IDs = 0; end
            if nargin < 2, names = {''}; end
            if nargin < 1, IDs = 0; end
            
            % Define the number of joints.
            self.num_joints = length(IDs);
            
            % Ensure that we have the correct number of properties for each joint.
            IDs = self.validate_property( IDs, 'IDs' );
            names = self.validate_property( names, 'names' );
            parent_link_IDs = self.validate_property( parent_link_IDs, 'parent_link_IDs' );
            child_link_IDs = self.validate_property( child_link_IDs, 'child_link_IDs' );
            ps = self.validate_property( ps, 'ps' );
            Rs = self.validate_property( Rs, 'Rs' );
            vs = self.validate_property( vs, 'vs' );
            ws = self.validate_property( ws, 'ws' );
            ws_screws = self.validate_property( ws_screws, 'ws_screws' );
            thetas = self.validate_property( thetas, 'thetas' );
            
            % Preallocate an array of joints.
            self.joints = repmat( joint_class(), 1, self.num_joints );
            
            % Create each joint object.
            for k = 1:self.num_joints               % Iterate through each of the joints...
                
                % Create this joint.
                self.joints(k) = joint_class( IDs(k), names{k}, parent_link_IDs(k), child_link_IDs(k), ps(:, k), Rs(:, :, k), vs(:, k), ws(:, k), ws_screws(:, k), thetas(k) );
                
            end
            
            % Get the screw axes of the joints.
            self.Ss = self.get_screw_axes( );
            
            % Get the home configurations of the joints.
            self.Ms_joints = get_home_configurations( self );
            
            % Set the current configurations of the joints to be equal to the home configurations.
            self.Ts_joints = self.Ms_joints;
            
            % Set the joint assignments in the standard way (each joint is assigned to itself).
            self.Js_joints = self.physics_manager.get_standard_joint_assignments( 1, self.num_joints );
            
        end
        
        
        %% Joint Manager Get and Set Properties Functions
        
        % Implement a function to retrieve the index associated with a given joint ID.
        function joint_index = get_joint_index( self, joint_ID )
            
            % Set a flag variable to indicate whether a matching joint index has been found.
            bMatchFound = false;
            
            % Initialize the joint index.
            joint_index = 0;
            
            while (joint_index < self.num_joints) && (~bMatchFound)
                
                % Advance the joint index.
                joint_index = joint_index + 1;
                
                % Check whether this joint index is a match.
                if self.joints(joint_index).ID == joint_ID                       % If this joint has the correct joint ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No joint with ID %0.0f.', joint_ID)
                
            end
            
        end
        
        
        % Implement a function to retrieve the properties of specific joints.
        function xs = get_joint_property( self, joint_IDs, joint_property )
            
            % Determine whether we want get the desired joint property from all of the joints.
            if isa(joint_IDs, 'char')                                                      % If the joint IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp(joint_IDs, 'all') || strcmp(joint_IDs, 'All')                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the joint IDs.
                    joint_IDs = zeros(1, self.num_joints);
                    
                    % Retrieve the joint ID associated with each joint.
                    for k = 1:self.num_joints                   % Iterate through each joint...
                        
                        % Store the joint ID associated with the current joint.
                        joint_IDs(k) = self.joints(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Joint_IDs must be either an array of valid joint IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
            % Determine how many joints to which we are going to apply the given method.
            num_properties_to_get = length(joint_IDs);
            
            % Preallocate a variable to store the joint properties.
            xs = zeros(1, num_properties_to_get);
            
            % Retrieve the given joint property for each joint.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this joint ID.
                joint_index = self.get_joint_index( joint_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs(k) = self.joints(%0.0f).%s;', joint_index, joint_property );
                
                % Evaluate the given joint property.
                eval(eval_str);
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific joints.
        function self = set_joint_property( self, joint_IDs, joint_property_values, joint_property)
            
            % Set the properties of each joint.
            for k = 1:self.num_joints                   % Iterate through each joint...
                
                % Determine the index of the joint property value that we want to apply to this joint (if we want to set a property of this joint).
                index = find(self.joints(k).ID == joint_IDs, 1);
                
                % Determine whether to set a property of this joint.
                if ~isempty(index)                         % If a matching joint ID was detected...
                    
                    % Create an evaluation string that sets the desired joint property.
                    eval_string = sprintf('self.joints(%0.0f).%s = joint_property_values(%0.0f);', k, joint_property, index);
                    
                    % Evaluate the evaluation string.
                    eval(eval_string);
                    
                end
            end
            
        end
        
                
        %% Joint Manager Call Joint Methods Function
        
        % Implement a function to that calls a specified joint method for each of the specified joints.
        function self = call_joint_method( self, joint_IDs, joint_method )
            
            % Determine whether we want get the desired joint property from all of the joints.
            if isa( joint_IDs, 'char' )                                                      % If the joint IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( joint_IDs, 'all' ) || strcmp( joint_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the joint IDs.
                    joint_IDs = zeros( 1, self.num_joints );
                    
                    % Retrieve the joint ID associated with each muscle.
                    for k = 1:self.num_joints                   % Iterate through each joint...
                        
                        % Store the joint ID associated with the current joint ID.
                        joint_IDs(k) = self.joints(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Joint_IDs must be either an array of valid joint IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
            % Determine how many joints to which we are going to apply the given method.
            num_joints_to_evaluate = length(joint_IDs);
            
            % Evaluate the given joint method for each joint.
            for k = 1:num_joints_to_evaluate               % Iterate through each of the joints of interest...
                
                % Retrieve the index associated with this joint ID.
                joint_index = self.get_joint_index( joint_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.joints(%0.0f) = self.joints(%0.0f).%s();', joint_index, joint_index, joint_method );
                
                % Evaluate the given muscle method.
                eval(eval_str);
                
            end
            
        end
        
        
    end
end

