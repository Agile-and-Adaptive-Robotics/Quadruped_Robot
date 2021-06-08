classdef limb_manager_class
    
    % This class contains properties and methods related to managing limbs.
    
    %% LIMB MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        limbs
        num_limbs
        
    end
    
    
    %% LIMB MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = limb_manager_class( limbs )
            
            % Set the default input arguments.
            if nargin < 1, self.limbs = limb_class(); else, self.limbs = limbs; end
            
            % Set the number of limbs.
            self.num_limbs = length(self.limbs);
            
        end
        
        
        %% Specific Get & Set Limb Property Functions
        
        % Implement a function to get the limb index associated with a limb ID.
        function limb_index = get_limb_index( self, limb_ID )
            
            % Set a flag variable to indicate whether a matching limb index has been found.
            bMatchFound = false;
            
            % Initialize the limb index.
            limb_index = 0;
            
            while (limb_index < self.num_limbs) && (~bMatchFound)
                
                % Advance the limb index.
                limb_index = limb_index + 1;
                
                % Check whether this limb index is a match.
                if self.limbs(limb_index).ID == limb_ID                       % If this limb has the correct limb ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No limb with ID %0.0f.', limb_ID)
                
            end
            
        end
        
        
        % Implement a function to validate the limb indexes.
        function limb_IDs = validate_limb_IDs( self, limb_IDs )
            
            % Determine whether we want get the desired limb property from all of the limbs.
            if isa( limb_IDs, 'char' )                                                      % If the limb IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( limb_IDs, 'all' ) || strcmp( limb_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the limb IDs.
                    limb_IDs = zeros( 1, self.num_limbs );
                    
                    % Retrieve the limb ID associated with each joint.
                    for k = 1:self.num_limbs                   % Iterate through each limb...
                        
                        % Store the joint ID associated with the current limb.
                        limb_IDs(k) = self.limbs(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Limb_IDs must be either an array of valid limb IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the end effector positions.
        function end_effector_positions = get_end_effector_positions( self, limb_IDs )
            
            % Validate the limb IDs.
            limb_IDs = self.validate_limb_IDs( limb_IDs );
            
            % Retrieve the number of limbs from which we want to retrieve end effector positions.
            num_limbs_to_get = length( limb_IDs );
            
            % Preallocate an array to store the end effector positions.
            end_effector_positions = zeros( 3, num_limbs_to_get );
            
            % Retrieve the position of each end effector limb.
            for k = 1:num_limbs_to_get                              % Iterate through each limb whose position we want to retrieve...
                
                % Retrieve the index associated with this limb ID.
                limb_index = self.get_limb_index( limb_IDs(k) );
                
                % Retrieve the position associated with this limb.
                end_effector_positions( :, k ) = self.limbs(limb_index).p_end_effector;
                
            end
            
        end
        
        
        % Implement a function to validate BPA muscle IDs at the limb manager level.
        function BPA_muscle_IDs = validate_BPA_muscle_IDs( self, BPA_muscle_IDs )
            
            % Determine whether we want get the desired muscle property from all of the muscles.
            if isa( BPA_muscle_IDs, 'char' )                                                      % If the muscle IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( BPA_muscle_IDs, 'all' ) || strcmp( BPA_muscle_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Retrieve all of the BPA muscle IDs.
                    BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Muscle_IDs must be either an array of valid muscle IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
        end
        
        
        %% Get Number of Joints, Links, and BPA Muscles Functions
        
        % Implement a function to get the total number of joints among all limbs.
        function num_joints = get_number_of_joints( self )
            
            % Set the joint counter to zero.
            num_joints = 0;
            
            % Compute the total number of joints.
            for k = 1:self.num_limbs                    % Iterate through each limb...
                
                % Add this limbs joints to the total number of joints.
                num_joints = num_joints + self.limbs(k).joint_manager.num_joints;
                
            end
            
        end
        
        
        % Implement a function to get the total number of links among all limbs.
        function num_links = get_number_of_links( self )
            
            % Set the link counter to zero.
            num_links = 0;
            
            % Compute the total number of links.
            for k = 1:self.num_limbs                    % Iterate through each limb...
                
                % Add this limbs links to the total number of links.
                num_links = num_links + self.limbs(k).link_manager.num_links;
                
            end
            
        end
        
        
        % Implement a function to get the total number of BPA muscle among all limbs.
        function num_BPA_muscles = get_number_of_BPA_muscles( self )
            
            % Set the BPA muscle counter to zero.
            num_BPA_muscles = 0;
            
            % Compute the total number of BPA muscles.
            for k = 1:self.num_limbs                         % Iterate through each limb...
                
                % Add this limbs BPA muscle to the total number of BPA muscles.
                num_BPA_muscles = num_BPA_muscles + self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
            end
            
        end
        
        
        % Implement a function to get the total number of some object in the limb manager.
        function num_objects = get_number_of_objects( self, object_type )
            
            if strcmp( object_type, 'Joints' ) || strcmp( object_type, 'joints' ) || strcmp( object_type, 'Joint' ) || strcmp( object_type, 'joint' )
                
                % Retrieve the number of joints.
                num_objects = self.get_number_of_joints(  );
                
            elseif strcmp( object_type, 'Links' ) || strcmp( object_type, 'links' ) || strcmp( object_type, 'Link' ) || strcmp( object_type, 'link' )
                
                % Retrieve the number of links.
                num_objects = self.get_number_of_links(  );
                
            elseif strcmp( object_type, 'BPA Muscles' ) || strcmp( object_type, 'BPA muscles' ) || strcmp( object_type, 'BPA Muscle' ) || strcmp( object_type, 'BPA muscle' ) || strcmp( object_type, 'BPAs' ) || strcmp( object_type, 'BPA' )
                
                % Retrieve the number of BPA muscles.
                num_objects = self.get_number_of_BPA_muscles(  );
                
            elseif strcmp( object_type, 'Limbs' ) || strcmp( object_type, 'limbs' ) || strcmp( object_type, 'Limb' ) || strcmp( object_type, 'limb' )
                
                % Retrieve the number of limbs.
                num_objects = self.num_limbs;
                
            else
                
                % Throw an error.
                error('object_type must be either: ''Joints'', ''Links'', ''BPA Muscles'', ''Limbs'', or an appropriate variation thereof')
                
            end
            
        end
        
        
        %% General Joint Get & Set Property Functions
        
        % Implement a function to get a property from all of the joints.
        function joint_property_value = get_property_from_all_joints( self, property_name )
            
            % Retrieve the total number of joints.
            num_joints = self.get_number_of_joints(  );
            
            % Preallocate an array to store the joint property values.
%             joint_property_value = zeros( 1, num_joints );
            joint_property_value = cell( 1, num_joints );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the joints properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of joints on this limb.
                num_joints_on_limb = self.limbs(k).joint_manager.num_joints;
                
                % Retrieve the joint properties from this limb.
                joint_property_value(index:(index + num_joints_on_limb - 1)) = self.limbs(k).joint_manager.get_joint_property( 'all', property_name );
%                 joint_property_value{ index:(index + num_joints_on_limb - 1) } = self.limbs(k).joint_manager.get_joint_property( 'all', property_name );

                % Advance the index variable.
                index = index + num_joints_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the joint property of each limb.
        function joint_property_value = get_joint_property( self, joint_IDs, joint_property )
            
            % Retrieve all of the existing joint IDs and joint angles from all of the limbs.
            existing_joint_IDs = self.get_property_from_all_joints( 'ID' );
            existing_joint_property_value = self.get_property_from_all_joints( joint_property );

            % Determine how to set the joint angles.
            if isa( joint_IDs, 'char' )                         % If the provided joint IDs are characters...
                
                % Determine how to set the joint angles.
                if strcmp( joint_IDs, 'All' ) || strcmp( joint_IDs, 'all' )         % If the joint_IDs is 'All' or 'all'...
                    
                    % Set the joint angles to be the existing joint angles.
                    joint_property_value = existing_joint_property_value;
                    
                else
                    
                    % Throw an error.
                    error('joint_IDs must either be a valid array of joint IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of joint IDs.
                num_joint_IDs = length(joint_IDs);
                
                % Preallocate an array to store the joint angles.
                joint_property_value = zeros( 1 , num_joint_IDs );
                
                % Retrieve the joint angles associated with each joint ID.
                for k1 = 1:num_joint_IDs                                        % Iterate through each joint ID...
                    
                    % Set the joint angle to match this existing joint angle.
                    joint_property_value(k1) = existing_joint_property_value( joint_IDs(k1) == existing_joint_IDs );
                    
                end
                
            end
            
        end
       
        
        % Implement a function to set the joint property for each limb.
        function self = set_joint_property( self, joint_IDs, joint_property_values, joint_property )
            
            % Set the joint property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the joint properties of this limb.
                self.limbs(k).joint_manager = self.limbs(k).joint_manager.set_joint_property( joint_IDs, joint_property_values, joint_property );
                
            end
            
        end
        
        
        %% Specific Joint Get & Set Property Functions
       
        % Implement a function to get the IDs from all joints.
        function IDs = get_IDs_from_all_joints( self )
            
            % Retrieve the total number of joints.
            num_joints = self.get_number_of_joints(  );
            
            % Preallocate an array to store the joint property values.
            IDs = zeros( 1, num_joints );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the joints properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of joints on this limb.
                num_joints_on_limb = self.limbs(k).joint_manager.num_joints;
                
                % Retrieve the joint properties from this limb.
                IDs( index:(index + num_joints_on_limb - 1) ) = self.limbs(k).joint_manager.get_all_joint_IDs(  );

                % Advance the index variable.
                index = index + num_joints_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the angles from all joints.
        function thetas = get_angles_from_all_joints( self )
            
            % Retrieve the total number of joints.
            num_joints = self.get_number_of_joints(  );
            
            % Preallocate an array to store the joint property values.
            thetas = zeros( 1, num_joints );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the joints properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of joints on this limb.
                num_joints_on_limb = self.limbs(k).joint_manager.num_joints;
                
                % Retrieve the joint properties from this limb.
                thetas( index:(index + num_joints_on_limb - 1) ) = self.limbs(k).joint_manager.get_joint_angles( 'all' );

                % Advance the index variable.
                index = index + num_joints_on_limb;
                
            end
            
        end
        
      
        % Implement a function to get the torques from all joints.
        function torques = get_torques_from_all_joints( self )
            
            % Retrieve the total number of joints.
            num_joints = self.get_number_of_joints(  );
            
            % Preallocate an array to store the joint property values.
            torques = zeros( 1, num_joints );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the joints properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of joints on this limb.
                num_joints_on_limb = self.limbs(k).joint_manager.num_joints;
                
                % Retrieve the joint properties from this limb.
                torques( index:(index + num_joints_on_limb - 1) ) = self.limbs(k).joint_manager.get_joint_torques( 'all' );

                % Advance the index variable.
                index = index + num_joints_on_limb;
                
            end
            
        end
        
        
        % Implement a function to retrieve the joint angles from the specified joints.
        function thetas = get_joint_angles( self, joint_IDs )
            
            % Retrieve all of the existing joint IDs and joint angles from all of the limbs.
            existing_joint_IDs = self.get_IDs_from_all_joints(  );
            existing_joint_angles = self.get_angles_from_all_joints(  );

            % Determine how to set the joint angles.
            if isa( joint_IDs, 'char' )                         % If the provided joint IDs are characters...
                
                % Determine how to set the joint angles.
                if strcmp( joint_IDs, 'All' ) || strcmp( joint_IDs, 'all' )         % If the joint_IDs is 'All' or 'all'...
                    
                    % Set the joint angles to be the existing joint angles.
                    thetas = existing_joint_angles;
                    
                else
                    
                    % Throw an error.
                    error('joint_IDs must either be a valid array of joint IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of joint IDs.
                num_joint_IDs = length( joint_IDs );
                
                % Preallocate an array to store the joint angles.
                thetas = zeros( 1 , num_joint_IDs );
                
                % Retrieve the joint angles associated with each joint ID.
                for k1 = 1:num_joint_IDs                                        % Iterate through each joint ID...
                    
                    % Set the joint angle to match this existing joint angle.
                    thetas(k1) = existing_joint_angles( joint_IDs(k1) == existing_joint_IDs );
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the joint torques from the specified joints.
        function torques = get_joint_torques( self, joint_IDs )
            
            % Retrieve all of the existing joint IDs and joint angles from all of the limbs.
            existing_joint_IDs = self.get_IDs_from_all_joints(  );
            existing_joint_torques = self.get_torques_from_all_joints(  );

            % Determine how to set the joint torques.
            if isa( joint_IDs, 'char' )                         % If the provided joint IDs are characters...
                
                % Determine how to set the joint torques.
                if strcmp( joint_IDs, 'All' ) || strcmp( joint_IDs, 'all' )         % If the joint_IDs is 'All' or 'all'...
                    
                    % Set the joint angles to be the existing joint torques.
                    torques = existing_joint_torques;
                    
                else
                    
                    % Throw an error.
                    error('joint_IDs must either be a valid array of joint IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of joint IDs.
                num_joint_IDs = length( joint_IDs );
                
                % Preallocate an array to store the joint torques.
                torques = zeros( 1 , num_joint_IDs );
                
                % Retrieve the joint torques associated with each joint ID.
                for k1 = 1:num_joint_IDs                                        % Iterate through each joint ID...
                    
                    % Set the joint torque to match this existing joint angle.
                    torques(k1) = existing_joint_torques( joint_IDs(k1) == existing_joint_IDs );
                    
                end
                
            end
            
        end
        
        
        %% General Link Get & Set Property Functions
        
        % Implement a function to get a property from all of the links.
        function link_property_value = get_property_from_all_links( self, property_name )
            
            % Retrieve the total number of links.
            num_links = self.get_number_of_links(  );
            
            % Preallocate an array to store the link property values.
%             link_property_value = zeros( 1, num_links );
            link_property_value = cell( 1, num_links );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the links properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of links on this limb.
                num_links_on_limb = self.limbs(k).link_manager.num_links;
                
                % Retrieve the link properties from this limb.
                link_property_value(index:(index + num_links_on_limb - 1)) = self.limbs(k).link_manager.get_link_property( 'all', property_name );
                
                % Advance the index variable.
                index = index + num_links_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the link property of each limb.
        function link_property_value = get_link_property( self, link_IDs, link_property )
            
            % Retrieve all of the existing link IDs and link property from all of the limbs.
            existing_link_IDs = self.get_property_from_all_links( 'ID' );
            existing_link_property_value = self.get_property_from_all_links( link_property );

            % Determine how to set the link property values.
            if isa( link_IDs, 'char' )                         % If the provided link IDs are characters...
                
                % Determine how to set the link angles.
                if strcmp( link_IDs, 'All' ) || strcmp( link_IDs, 'all' )         % If the link_IDs is 'All' or 'all'...
                    
                    % Set the link property values to be the existing link property values.
                    link_property_value = existing_link_property_value;
                    
                else
                    
                    % Throw an error.
                    error('link_IDs must either be a valid array of link IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of link IDs.
                num_link_IDs = length(link_IDs);
                
                % Preallocate an array to store the link angles.
                link_property_value = zeros( 1 , num_link_IDs );
                
                % Retrieve the link property value associated with each link ID.
                for k1 = 1:num_link_IDs                                        % Iterate through each link ID...
                    
                    % Set the link property value to match this existing link property value property.
                    link_property_value(k1) = existing_link_property_value( link_IDs(k1) == existing_link_IDs );
                    
                end
                
            end
            
        end

        
        % Implement a function to set the link property for each limb.
        function self = set_link_property( self, link_IDs, link_property_values, link_property )
            
            % Set the link property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the link properties of this limb.
                self.limbs(k).link_manager = self.limbs(k).link_manager.set_link_property( link_IDs, link_property_values, link_property );
                
            end
            
        end
        
        
        %% Specific Link Get & Set Property Functions
        
        
        %% General BPA Muscle Get & Set Property Functions
        
        % Implement a function to get a property from all of the BPA muscles.
        function BPA_muscle_property_value = get_property_from_all_BPA_muscles( self, property_name )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
%             BPA_muscle_property_value = zeros( 1, num_BPA_muscles );
            BPA_muscle_property_value = cell( 1, num_BPA_muscles );

            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_property_value(index:(index + num_BPA_muscles_on_limb - 1)) = self.limbs(k).BPA_muscle_manager.get_muscle_property( 'all', property_name );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the BPA muscle property of each limb.
        function BPA_muscle_property_value = get_BPA_muscle_property( self, BPA_muscle_IDs, BPA_muscle_property )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
%             existing_BPA_muscle_IDs = self.get_property_from_all_BPA_muscles( 'ID' );
%             existing_BPA_muscle_property_value = self.get_property_from_all_BPA_muscles( BPA_muscle_property );

            existing_BPA_muscle_IDs = cell2mat( self.get_property_from_all_BPA_muscles( 'ID' ) );
            existing_BPA_muscle_property_value = cell2mat( self.get_property_from_all_BPA_muscles( BPA_muscle_property ) );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_property_value = existing_BPA_muscle_property_value;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length(BPA_muscle_IDs);
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_property_value = zeros( 1 , num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k1 = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find(BPA_muscle_IDs(k1) == existing_BPA_muscle_IDs, 1);
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...

                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_property_value(k1) = existing_BPA_muscle_property_value( BPA_muscle_IDs(k1) == existing_BPA_muscle_IDs );

                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_property_value(k1) = nan;
                        
                    end
                    
                end
                
            end
            
            % Convert the BPA muscle property to a cell.
            BPA_muscle_property_value = num2cell( BPA_muscle_property_value );
                        
        end
        
        
        % Implement a function to set the BPA muscle property for each limb.
        function self = set_BPA_muscle_property( self, BPA_muscle_IDs, BPA_muscle_property_values, BPA_muscle_property )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_property_values, BPA_muscle_property );
                
            end
            
        end
                
        
        %% Specific BPA Muscle Get Property Functions
        
        % Implement a function to retrieve the IDs from all of the BPA muscles.
        function BPA_muscle_IDs = get_ID_from_all_BPA_muscles( self )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );

            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_IDs = zeros( 1, num_BPA_muscles );

            % Initialize an indexing variable.
            index = 1;

            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...

                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;

                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_IDs( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_all_BPA_muscle_IDs(  );

                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;

            end
            
        end
        
        
        % Implement a function to retrieve the names from all of the BPA muscles.
        function BPA_muscle_names = get_names_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_names = cell( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_names( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_names( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to retrieve the names from the specified BPA muscles.
        function BPA_muscle_names = get_BPA_muscle_names( self, BPA_muscle_IDs )
            
           % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_names = self.get_names_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_names = existing_BPA_muscle_names;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_names = cell( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_names{k} = existing_BPA_muscle_names{ index };
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_names{k} = nan;
                        
                    end
                    
                end
                
            end 
            
        end
        
        
        % Implement a function to retrieve the desired pressures from all of the BPA muscles.
        function BPA_muscle_desired_pressures = get_desired_pressure_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_desired_pressures = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_desired_pressures( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_desired_pressures( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to retrieve the measured pressures from all of the BPA muscles.
        function BPA_muscle_measured_pressures = get_measured_pressure_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_measured_pressures = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_measured_pressures( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_measured_pressures( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the desired pressures from the specified BPA muscles.
        function BPA_muscle_desired_pressures = get_BPA_muscle_desired_pressures( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_desired_pressures = self.get_desired_pressure_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_desired_pressures = existing_BPA_muscle_desired_pressures;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_desired_pressures = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_desired_pressures(k) = existing_BPA_muscle_desired_pressures( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_desired_pressures(k) = nan;
                        
                    end
                    
                end
                
            end
        
        end
            
        
        % Implement a function to get the desired pressures from the specified BPA muscles.
        function BPA_muscle_measured_pressures = get_BPA_muscle_measured_pressures( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_measured_pressures = self.get_measured_pressure_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_measured_pressures = existing_BPA_muscle_measured_pressures;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_measured_pressures = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_measured_pressures(k) = existing_BPA_muscle_measured_pressures( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_measured_pressures(k) = nan;
                        
                    end
                    
                end
                
            end
        
        end
        
        
        % Implement a function to retrieve the desired pressures from all of the BPA muscles.
        function BPA_muscle_desired_tensions = get_desired_tension_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_desired_tensions = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_desired_tensions( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_desired_tensions( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to retrieve the measured pressures from all of the BPA muscles.
        function BPA_muscle_measured_tensions = get_measured_tension_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_measured_tensions = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_measured_tensions( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_measured_tensions( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the desired pressures from the specified BPA muscles.
        function BPA_muscle_desired_tensions = get_BPA_muscle_desired_tensions( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_desired_tensions = self.get_desired_tension_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_desired_tensions = existing_BPA_muscle_desired_tensions;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_desired_tensions = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_desired_tensions(k) = existing_BPA_muscle_desired_tensions( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_desired_tensions(k) = nan;
                        
                    end
                    
                end
                
            end
        
        end
            
        
        % Implement a function to get the measured pressures from the specified BPA muscles.
        function BPA_muscle_measured_tensions = get_BPA_muscle_measured_tensions( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_measured_tensions = self.get_measured_tension_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_measured_tensions = existing_BPA_muscle_measured_tensions;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_measured_tensions = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_measured_tensions(k) = existing_BPA_muscle_measured_tensions( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_measured_tensions(k) = nan;
                        
                    end
                    
                end
                
            end
        
        end
        
        
        % Implement a function to retrieve the muscle length from all of the BPA muscles.
        function BPA_muscle_lengths = get_length_from_all_BPA_muscles( self )
           
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_lengths = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_lengths( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_lengths( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the muscle lengths from the specified BPA muscles.
        function BPA_muscle_lengths = get_BPA_muscle_lengths( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_lengths = self.get_length_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_lengths = existing_BPA_muscle_lengths;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_lengths = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_lengths(k) = existing_BPA_muscle_lengths( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_lengths(k) = nan;
                        
                    end
                    
                end
                
            end
            
        end
        
            
        % Implement a function to retrieve the muscle velocity from all of the BPA muscles.
        function BPA_muscle_velocities = get_velocity_from_all_BPA_muscles( self )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_velocities = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_velocities( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_velocities( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the muscle velocities from the specified BPA muscles.
        function BPA_muscle_velocities = get_BPA_muscle_velocities( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_velocities = self.get_velocity_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_velocities = existing_BPA_muscle_velocities;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_velocities = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_velocities(k) = existing_BPA_muscle_velocities( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_velocities(k) = nan;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get the muscle stains from all of the BPA muscles.
        function BPA_muscle_strains = get_strain_from_all_BPA_muscles( self )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_strains = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_strains( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_strains( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a function to get the muscle strains from the specified BPA muscles.
        function BPA_muscle_strains = get_BPA_muscle_strains( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_strains = self.get_strain_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_strains = existing_BPA_muscle_strains;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_strains = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_strains(k) = existing_BPA_muscle_strains( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_strains(k) = nan;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get the yanks from all of the BPA muscles.
        function BPA_muscle_yanks = get_yank_from_all_BPA_muscles( self )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_yanks = zeros( 1, num_BPA_muscles );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the BPA muscle properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of BPA muscles on this limb.
                num_BPA_muscles_on_limb = self.limbs(k).BPA_muscle_manager.num_BPA_muscles;
                
                % Retrieve the BPA muscle properties from this limb.
                BPA_muscle_yanks( index:(index + num_BPA_muscles_on_limb - 1) ) = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_yanks( 'all' );
                
                % Advance the index variable.
                index = index + num_BPA_muscles_on_limb;
                
            end
            
        end
        
        
        % Implement a funciton to get the yanks from the specified BPA muscles.
        function BPA_muscle_yanks = get_BPA_muscle_yanks( self, BPA_muscle_IDs )
            
            % Retrieve all of the existing BPA muscle IDs and BPA muscle property values from all of the limbs.
            existing_BPA_muscle_IDs = self.get_ID_from_all_BPA_muscles(  );
            existing_BPA_muscle_yanks = self.get_yank_from_all_BPA_muscles(  );
            
            % Determine how to set the BPA muscle property values.
            if isa( BPA_muscle_IDs, 'char' )                         % If the provided BPA muscle IDs are characters...
                
                % Determine how to set the BPA muscle property values.
                if strcmp( BPA_muscle_IDs, 'All' ) || strcmp( BPA_muscle_IDs, 'all' )         % If the BPA_muscle_IDs is 'All' or 'all'...
                    
                    % Set the BPA muscle property values to be the existing BPA muscle property values.
                    BPA_muscle_yanks = existing_BPA_muscle_yanks;
                    
                else
                    
                    % Throw an error.
                    error('BPA_muscle_IDs must either be a valid array of BPA muscle IDs or one of the following strings: ''All'' or ''all''')
                    
                end
                
            else                                                                    % Otherwise...
                
                % Retrieve the number of BPA muscle IDs.
                num_BPA_muscle_IDs = length( BPA_muscle_IDs );
                
                % Preallocate an array to store the BPA muscle values.
                BPA_muscle_yanks = zeros( 1, num_BPA_muscle_IDs );
                
                % Retrieve the BPA muscle property value associated with each link ID.
                for k = 1:num_BPA_muscle_IDs                                        % Iterate through each BPA muscle ID...
                    
                    % Retrieve the index of this muscle.
                    index = find( BPA_muscle_IDs(k) == existing_BPA_muscle_IDs, 1 );
                    
                    % Determine whether a matching muscle was found.
                    if ~isempty(index)                      % If a matching muscle was found...
                        
                        % Set the BPA muscle property value to match this existing BPA muscle property value property.
                        BPA_muscle_yanks(k) = existing_BPA_muscle_yanks( index );
                        
                    else
                        
                        % Set the muscle property to be nan.
                        BPA_muscle_yanks(k) = nan;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        
        %% BPA Muscle Set Property Functions
        
        % Implement a function to set the measured pressures of the specified BPA muscles.
        function self = set_BPA_muscle_measured_pressures( self, BPA_muscle_IDs, BPA_muscle_measured_pressures )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.                
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_measured_pressures( BPA_muscle_IDs, BPA_muscle_measured_pressures );
                
            end
            
        end
            
        
        % Implement a function to set the measured tensions of the specified BPA muscles.
        function self = set_BPA_muscle_measured_tensions( self, BPA_muscle_IDs, BPA_muscle_measured_tensions )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.                
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_measured_tensions( BPA_muscle_IDs, BPA_muscle_measured_tensions );
                
            end
            
        end
        
        
        % Implement a function to set the desired tensions of the specified BPA muscles.
        function self = set_BPA_muscle_desired_tensions( self, BPA_muscle_IDs, BPA_muscle_desired_tensions )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.                
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_desired_tensions( BPA_muscle_IDs, BPA_muscle_desired_tensions );
                
            end
            
        end
        
        
        % Implement a function to set the yanks of the specified BPA muscles.
        function self = set_BPA_muscle_yanks( self, BPA_muscle_IDs, BPA_muscle_yanks )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.                
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_yanks( BPA_muscle_IDs, BPA_muscle_yanks );
                
            end
            
        end
        
        
        %% Call Method Functions
        
        % Implement a function to call a BPA muscle method for each limb.
        function self = call_BPA_muscle_method( self, muscle_IDs, muscle_method )
            
            % Apply the given muscle method to the BPA muscles on each limb.
            for k = 1:self.num_limbs                    % Iterate through each limb...
                
                % Call the given method for the specified muscles on this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.call_muscle_method( muscle_IDs, muscle_method );
            
            end
            
        end
        
        
        %% Medium Level BPA Functions
        
        % Implement a function to compute the BPA muscle equilibrium strain (Type I) associated with the current BPA muscle measured pressure of the specified BPA muscles.
        function self = get_BPA_muscle_strain_equilibrium( self, BPA_muscle_IDs )
            
            % Compute the BPA muscle equilibrium strain (Type I) associated with the current BPA muscle measured pressure of the specified BPA muscles on each of the limbs.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Compute the BPA muscle equilibrium strain (Type I) associated with the current BPA muscle measured pressure of each of the specified BPA muscles on this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.get_BPA_muscle_strain_equilibrium( BPA_muscle_IDs );
                
            end
            
        end
        
        
        % Implement a function to compute the BPA muscle equilibrium length associated with the current BPA muscle equilibrium strain (Type I) of the specified BPA muscles.
        function self = equilibrium_strain2equilibrium_length( self, BPA_muscle_IDs )
        
            % Compute the BPA muscle equilibrium length associated with the current BPA muscle equilibrium strain (Type I) of the specified BPA muscles on each of the limbs.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Compute the BPA muscle equilibrium length associated with the current BPA muscle equilibrium strain (TYpe I) of the specified BPA muscles on this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.equilibrium_strain2equilibrium_length( BPA_muscle_IDs );
                
            end
            
        end
        
        
        % Implement a function to set the measured pessures of the BPA muscles on this limb to be the same as the desired pressures.
        function self = desired_pressures2measured_pressures( self, BPA_muscle_IDs )
        
            % Set the measured pressures of the BPA muscles on each limb to be the same as the desired pressures.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Set the measured pressures of the BPA muscles on this limb to be the same as the desired pressures.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.desired_pressures2measured_pressures( BPA_muscle_IDs );
                
            end
            
        end
        
        
        % Implement a function to set the measured tensions of the BPA muscles on this limb to be the same was the desired tensions.
        function self = desired_tensions2measured_tensions( self, BPA_muscle_IDs )
        
            % Set the measured tensions of the BPA muscles on each limb to be the same as the desired tensions.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Set the measured tensions of the BPA muscles on this limb to be the same as the desired tensions.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.desired_tensions2measured_tensions( BPA_muscle_IDs );
                
            end
            
        end
        
        
        % Implement a function to convert the desired BPA muscle pressures to desired BPA muscle tensions for each of the specified muscles.
        function self = desired_pressures2desired_tensions( self, BPA_muscle_IDs )
           
            % Compute the desired tensions associated with the desired pressure of each of the muscles.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Set the measured tensions of the BPA muscles on this limb to be the same as the desired tensions.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.desired_pressures2desired_tensions( BPA_muscle_IDs );
                
            end
            
        end
        
        
        % Implement a function to convert the desired BPA muscle tensions to desired BPA muscle pressures for each of the specified muscles.
        function self = desired_tensions2desired_pressures( self, BPA_muscle_IDs )
           
            % Compute the desired tensions associated with the desired pressure of each of the muscles.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Set the measured tensions of the BPA muscles on this limb to be the same as the desired tensions.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.desired_tensions2desired_pressures( BPA_muscle_IDs );
                
            end
            
        end
        
        
        %% High Level BPA Functions
        
        % Implement a function to update BPA muscle measured tension, BPA muscle length, & BPA muscle strain.
        function self = update_BPA_muscle_properties( self )
               
            % Compute the BPA muscle measured tension associated with the BPA muscle measured pressure. ( BPA Muscle Measured Pressure -> BPA Muscle Measured Tension )
            self = self.call_BPA_muscle_method( 'all', 'measured_pressure2measured_tension' );

            % Compute the BPA muscle length associated with the joint angles. ( BPA Muscle Attachment Positions -> BPA Muscle Length )
            self = self.call_BPA_muscle_method( 'all', 'ps2muscle_length' );

            % Compute the BPA muscle strain associated with the BPA muscle length. ( BPA Muscle Length -> BPA Muscle Strain )
            self = self.call_BPA_muscle_method( 'all', 'muscle_length2muscle_strain' );
            
        end
        
        
        %% High Level Limb Functions
        
        % Implement a function to compute the joint torque generated by the associated BPA muscles at each joint on each limb.
        function self = BPA_muscle_tensions2joint_torques( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Compute the joint torques generated by the associated BPA muscles at each joint on each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Compute the joint torques generated by the associated BPA muscles at each joint on this limb.
                self.limbs(k) = self.limbs(k).BPA_muscle_tensions2joint_torques( bVerbose );
            
            end
            
        end
        
        
        % Implement a function to compute the joint angles produced by the current joint torques on each limb. ( Forward Dynamics: Joint Torques -> Joint Angles )
        function self = joint_torques2joint_angles( self, dt, g, dyn_int_steps )
            
            % Set the default input arguments.
            if nargin < 4, dyn_int_steps = 10; end
            if nargin < 3, g = [ 0; -9.81; 0 ]; end
            
            % Compute the joint angles associated with the joint torques on each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
            
                % Compute the joint angles associated with the joint torques on this limb.
                self.limbs(k) = self.limbs(k).joint_torques2joint_angles( dt, g, dyn_int_steps );
        
            end
            
        end
        
        
        % Implement a function to compute the joint torques required to maintain the current joint angles on each limb ( (Partial) Inverse Dynamics: Joint Angles -> Joint Torques )
        function self = joint_angles2joint_torques( self, g )
            
            % Set the default input arguments.
            if nargin < 2, g = [ 0; -9.81; 0 ]; end
            
            % Compute the joint torques associated with the joint angles on each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
            
                % Compute the joint torques associated with the joint angles on this limb.
                self.limbs(k) = self.limbs(k).joint_angles2joint_torques( g );
        
            end
                        
        end
        
        
        %% Configuration Functions.
        
        % Implement a function to compute the position, orientation, and configuration of the end effector given the current joint angles for each limb.
        function self = joint_angles2end_effector_configurations( self )
            
            % Compute the end effector configuration associated with the joint angles of each limb.
            for k = 1:self.num_limbs                        % Iterate through each limb...
                
                % Compute the end effector configuration associated with the joint angles of this limb.
                self.limbs(k) = self.limbs(k).joint_angles2end_effector_configuration(  );
                
            end
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the joints given the current joint angles for each limb.
        function self = joint_angles2joint_configurations( self )
            
            % Compute the position, orientation, and configuration of the joints given the current joint angles for each limb.
            for k = 1:self.num_limbs                    % Iterate through each limb....
            
                % Compute the position, orientation, and configuration of the joints given the current joint angles for this limb.
                self.limbs(k) = self.limbs(k).joint_angles2joint_configurations(  );

            end
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the links given the current joint angles for each limb.
        function self = joint_angles2link_configurations( self )
        
            % Compute the position, orientation, and configuration of the links given the current joint angles for each limb.
            for k = 1:self.num_limbs                    % Iterate through each limb....
            
                % Compute the position, orientation, and configuration of the links given the current joint angles for this limb.
                self.limbs(k) = self.limbs(k).joint_angles2link_configurations(  );

            end

        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the BPA muscles given the current joint angles for each limb.
        function self = joint_angles2BPA_muscle_configurations( self )
            
            % Compute the position, orientation, and configuration of the BPA muscles given the current joint angles for each limb.
            for k = 1:self.num_limbs                    % Iterate through each limb....
            
                % Compute the position, orientation, and configuration of the BPA muscles given the current joint angles for this limb.
                self.limbs(k) = self.limbs(k).joint_angles2BPA_muscle_configurations(  );

            end
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the points on each limb given the limb's current joint angles.
        function self = joint_angles2limb_configurations( self )
            
            % Compute the position, orientation, and configuration of all of the points on each limb given the limb's current joint angles.
            for k = 1:self.num_limbs                    % Iterate through each limb....
            
                % Compute the position, orientation, and configuration of all of the points on this limb given the limb's current joint angles.
                self.limbs(k) = self.limbs(k).joint_angles2limb_configurations(  );

            end
            
        end
        
        
        % Implement a function to set the position, orientation, and configuration of the points of each limb given a set of desired limb joint angles.
        function self = set_limb_configuration( self, thetas )
            
            % Set the all of the joint angles on each limb.
            self = self.set_joint_property( 'all', thetas, 'theta' );
            
            % Compute the configuration of all of the limb points given these joint angles.
            self = self.joint_angles2limb_configurations(  );
            
        end
        
        
        %% High Level Dynamics Functions
        
        % Implement a function to compute a single forward dynamics step.
        function self = forward_dynamics_step( self, dt, g, dyn_int_steps, bVerbose )
            
            % Set the default input arguments.
            if nargin < 5, bVerbose = false; end
            if nargin < 4, dyn_int_steps = 10; end
            if nargin < 3, g = [ 0; -9.81; 0 ]; end
            
            % Compute BPA muscle desired tension associated with the current BPA muscle desired pressure. ( BPA Muscle Desired Pressure -> BPA Muscle Desired Tension )
            self = self.desired_pressures2desired_tensions( 'all' );
            
            % Compute the joint torques associated with the BPA muscle desired tensions. ( BPA Muscle Desired Tensions -> Joint Torques )
            self = self.BPA_muscle_tensions2joint_torques( bVerbose );

            % Compute the joint angles associated with the current joint torques. ( Joint Torques -> Joint Angles )
            self = self.joint_torques2joint_angles( dt, g, dyn_int_steps );

            % Set the BPA muscle measured pressure to be the same as the BPA muscle desired pressure.
            self = self.desired_pressures2measured_pressures( 'all' );
            
            % Compute the BPA muscle equilibrium strain (Type I) associated with the BPA muscle measured pressure.
            self = self.get_BPA_muscle_strain_equilibrium( 'all' );
            
            % Compute the BPA muscle equilibrium length associated with the BPA muscle equilibrium strain (Type I).
            self = self.equilibrium_strain2equilibrium_length( 'all' ); 

            % Set the BPA muscle measured tension to be the same as the BPA muscle desired tension.
            self = self.desired_tensions2measured_tensions( 'all' );
            
        end
        
        
        
        %% Plotting Functions
        
        % Implement a function to plot the all of the points for each limb.
        function fig = plot_limb_points( self, fig, plotting_options )
            
           % Determine whether we need to set the default plotting options.
           if nargin < 3, plotting_options = {  }; end
           
           % Determine whether we need to create a figure to store the limb points.
           if nargin < 2
               
               % Create a figure to store the limb points.
                fig = figure('Color', 'w'); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Limb Points')
               
           end
           
           % Plot the limb points.
           for k = 1:self.num_limbs                 % Iterate through each limb...
               
               % Plot the points associated with this limb.
               fig = self.limbs(k).plot_limb_points( fig, plotting_options );
               
           end
           
            
        end
        
        
    end
end

