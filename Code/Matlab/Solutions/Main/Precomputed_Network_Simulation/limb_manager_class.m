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
                num_objects = get_number_of_joints(  );
                
            elseif strcmp( object_type, 'Links' ) || strcmp( object_type, 'links' ) || strcmp( object_type, 'Link' ) || strcmp( object_type, 'link' )
                
                % Retrieve the number of links.
                num_objects = get_number_of_links(  );
                
            elseif strcmp( object_type, 'BPA Muscles' ) || strcmp( object_type, 'BPA muscles' ) || strcmp( object_type, 'BPA Muscle' ) || strcmp( object_type, 'BPA muscle' ) || strcmp( object_type, 'BPAs' ) || strcmp( object_type, 'BPA' )
                
                % Retrieve the number of BPA muscles.
                num_objects = get_number_of_BPA_muscles(  );
                
            elseif strcmp( object_type, 'Limbs' ) || strcmp( object_type, 'limbs' ) || strcmp( object_type, 'Limb' ) || strcmp( object_type, 'limb' )
                
                % Retrieve the number of limbs.
                num_objects = self.num_limbs;
                
            else
                
                % Throw an error.
                error('object_type must be either: ''Joints'', ''Links'', ''BPA Muscles'', ''Limbs'', or an appropriate variation thereof')
                
            end
            
        end
        
        
        %% Joint Set & Get Property Functions
        
        % Implement a function to get a property from all of the joints.
        function joint_property_value = get_property_from_all_joints( self, property_name )
            
            % Retrieve the total number of joints.
            num_joints = self.get_number_of_joints(  );
            
            % Preallocate an array to store the joint property values.
            joint_property_value = zeros( 1, num_joints );
            
            % Initialize an indexing variable.
            index = 1;
            
            % Retrieve the joints properties from each limb.
            for k = 1:self.num_limbs                % Iterate through each limb...
                
                % Retrieve the number of joints on this limb.
                num_joints_on_limb = self.limbs(k).joint_manager.num_joints;
                
                % Retrieve the joint properties from this limb.
                joint_property_value(index:(index + num_joints_on_limb - 1)) = self.limbs(k).joint_manager.get_joint_property( 'all', property_name );
                
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
        
        
        %% Link Set & Get Property Functions
        
        % Implement a function to get a property from all of the links.
        function link_property_value = get_property_from_all_links( self, property_name )
            
            % Retrieve the total number of links.
            num_links = self.get_number_of_links(  );
            
            % Preallocate an array to store the link property values.
            link_property_value = zeros( 1, num_links );
            
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
        
        
        %% BPA Muscle Set & Get Property Functions
        
        % Implement a function to get a property from all of the BPA muscles.
        function BPA_muscle_property_value = get_property_from_all_BPA_muscles( self, property_name )
            
            % Retrieve the total number of BPA muscles.
            num_BPA_muscles = self.get_number_of_BPA_muscles(  );
            
            % Preallocate an array to store the BPA muscle property values.
            BPA_muscle_property_value = zeros( 1, num_BPA_muscles );
            
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
            existing_BPA_muscle_IDs = self.get_property_from_all_BPA_muscles( 'ID' );
            existing_BPA_muscle_property_value = self.get_property_from_all_BPA_muscles( BPA_muscle_property );

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
            
        end
        
        
        % Implement a function to set the BPA muscle property for each limb.
        function self = set_BPA_muscle_property( self, BPA_muscle_IDs, BPA_muscle_property_values, BPA_muscle_property )
            
            % Set the BPA muscle property values for each limb.
            for k = 1:self.num_limbs                                                           % Iterate through each limb...
                
                % Set the BPA muscle properties of this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.set_BPA_muscle_property( BPA_muscle_IDs, BPA_muscle_property_values, BPA_muscle_property );
                
            end
            
        end
        
        
        % Implement a function to call a BPA muscle method for each limb.
        function self = call_BPA_muscle_method( self, muscle_IDs, muscle_method )
            
            % Apply the given muscle method to the BPA muscles on each limb.
            for k = 1:self.num_limbs                    % Iterate through each limb...
                
                % Call the given method for the specified muscles on this limb.
                self.limbs(k).BPA_muscle_manager = self.limbs(k).BPA_muscle_manager.call_muscle_method( muscle_IDs, muscle_method );
            
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
        
        
    end
end

