classdef limb_class

    % This class contains properties and methods related to limbs (limbs are kinematic chains comprised of links and joints).

    %% LIMB PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        origin

        link_manager
        joint_manager
        BPA_muscle_manager
        
        p_end_effector
        R_end_effector
        M_end_effector
        T_end_effector
        J_end_effector
        F_end_effector
        
        physics_manager
        
    end
    
    
    %% LIMB METHODS SETUP

    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = limb_class( ID, name, origin, link_manager, joint_manager, BPA_muscle_manager, F_end_effector )

            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Define the class properties.
            if nargin < 7, self.F_end_effector = zeros( 6, 1 ); else, self.F_end_effector = F_end_effector; end
            if nargin < 6, self.BPA_muscle_manager = BPA_muscle_manager_class(); else, self.BPA_muscle_manager = BPA_muscle_manager; end
            if nargin < 5, self.joint_manager = joint_manager_class(); else, self.joint_manager = joint_manager; end
            if nargin < 4, self.link_manager = link_manager_class(); else, self.link_manager = link_manager; end
            if nargin < 3, self.origin = []; else, self.origin = origin; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end
            
            % Set the end effector position, orientation, configuration, and home configuration.
            self = self.set_end_effector_state(  );
            
            % Set the tendon length of the muscles on this limb.
            self = self.set_tendon_lengths(  );
            
        end
        
        
        %% Get & Set Functions
        
        % Implement a function to set the end effector position, orientation, and configuration.
        function self = set_end_effector_state( self )
            
            % Determine how to set the end efffector properties.
            if ~isempty( self.link_manager.links )                       % If there are link objects...
            
                % Retrieve the end effector position from the final link.
                self.p_end_effector = self.link_manager.links(end).p_end;

                % Retrieve the end effector orientation from the final link.
                self.R_end_effector = self.link_manager.links(end).R;

                % Compute the end effector home configuration.
                self.M_end_effector = RpToTrans( self.R_end_effector, self.p_end_effector );

                % Set the current end effector configuration.
                self.T_end_effector = self.M_end_effector;
            
                % Set the end effector joint assignment.
                self.J_end_effector = length(self.link_manager.num_links);
                
            else                                            % Otherwise...
                
                % Set the end effector variables to be empty.
                self.p_end_effector = [];
                self.R_end_effector = [];
                self.M_end_effector = [];
                self.T_end_effector = [];
                self.J_end_effector = [];
                
            end
            
        end
        
        
        % Implement a function to set the joint angles of this limb.
        function self = set_joint_angles( self, thetas )
            
            % Set the joint angles.
            self.joint_manager = self.joint_manager.set_joint_property( 'all', thetas, 'theta' );
            
        end
          
        
        % Implement a function to set the tendon lengths of the BPA muscles on this limb.
        function self = set_tendon_lengths( self )
           
            % NOTE: This function assumes that the BPA muscle manager for this limb contains only MONOARITICULAR muscles.  This function will have to be modified to accomodate biarticular muscles.
            
            % Ensure that a joint manager and BPA muscle manager exist before attempting to compute tendon lengths.
            if ~isempty( self.joint_manager ) && ~isempty( self.BPA_muscle_manager )            % If both a joint manager and BPA muscle manager have been defined for this limb...
                
                % Retrieve the current joint angles to which we will reset the joints after computing tendon lengths.
                thetas0 = cell2mat( self.joint_manager.get_joint_property( 'all', 'theta' ) );
                
                % Retrieve the BPA muscle resting lengths.
                resting_muscle_lengths = cell2mat( self.BPA_muscle_manager.get_muscle_property( 'all', 'resting_muscle_length' ) );
                
                % Retrieve the muscle types of the BPA muscles on this limb.
                muscle_types = self.BPA_muscle_manager.get_muscle_property( 'all', 'muscle_type' );
                
                % Retrieve the muscle IDs.
                muscle_IDs = cell2mat( self.BPA_muscle_manager.get_muscle_property( 'all', 'ID' ) );
                
                % Set the plausible joint orientations.
                joint_orientations = { 'Ext', 'Flx' };
                
                % Retrieve the number of different joint orientations.
                num_joint_orientations = length( joint_orientations );
                
                % Set the tendon length of each BPA muscle.
                for k = 1:num_joint_orientations                    % Iterate through each of the limb orientations...
                    
                    % Retrieve the joint angles associated with this joint orientation.
                    thetas = self.joint_manager.get_joint_limits( joint_orientations{k} );
                    
                    % Set the current joint angles of this limb to be those that would put the limb into the desired configuration.
                    self.joint_manager = self.joint_manager.set_joint_property( 'all', thetas, 'theta' );
                    
                    % Put the BPA muscles into this configuration.
                    self = self.joint_angles2BPA_muscle_configurations(  );
                    
                    % Compute the BPA muscle total muscle-tendon lengths in this configuration.
                    self.BPA_muscle_manager = self.BPA_muscle_manager.call_muscle_method( 'all', 'ps2muscle_length' );
                    
                    % Retrieve the BPA muscle lengths associated with this limb in this configuration.
                    total_muscle_tendon_lengths = cell2mat( self.BPA_muscle_manager.get_muscle_property( 'all', 'total_muscle_tendon_length' ) );
                    
                    % Compute the tendon length of each BPA muscle.
                    tendon_lengths = total_muscle_tendon_lengths - resting_muscle_lengths;
                    
                    % Retrieve the muscle indexes.
                    muscle_indexes = strcmp( muscle_types, joint_orientations{k} );
                    
                    % Retrieve the muscle IDs to set.
                    muscle_IDs_to_set = muscle_IDs(muscle_indexes);
                    
                    % Retrieve the tendon lengths to set.
                    tendon_lengths_to_set = tendon_lengths(muscle_indexes);
                    
                    % Store these tendon lengths for each muscle that matches the current joint orientation.
                    self.BPA_muscle_manager = self.BPA_muscle_manager.set_BPA_muscle_property( muscle_IDs_to_set, tendon_lengths_to_set, 'tendon_length' );
                                        
                end
                
                % Return the joint angles to their original configuration.
                self.joint_manager = self.joint_manager.set_joint_property( 'all', thetas0, 'theta' );
                
                % Return this BPA muscles to their original configuration.
                self = self.joint_angles2BPA_muscle_configurations(  );

                % Compute the BPA muscle lengths in this configuration.
                self.BPA_muscle_manager = self.BPA_muscle_manager.call_muscle_method( 'all', 'ps2muscle_length' );
                
            end
            
        end
        
        
        %% Dynamics Functions
        
        % Implement a function to determine the IDs of the muscles that straddle a given joint ID.
        function matching_BPA_muscle_IDs = get_straddling_muscle_IDs( self, joint_ID )
            
            % Compute the joint order index.
            joint_order_index = find( joint_ID == self.joint_manager.joint_order, 1 );
            
            % Determine the muscle attachment points that attach to the link above this joint.
            BPA_muscle_points_above_joint = self.BPA_muscle_manager.Js == joint_order_index - 1;
            
            % Determine the muscle attachment points that attach to the link below this joint.
            BPA_muscle_points_below_joint = self.BPA_muscle_manager.Js == joint_order_index;
            
            % Compute the BPA muscle logical indexes.
            BPA_muscle_logical_indexes = BPA_muscle_points_above_joint( end - 1, : ) & BPA_muscle_points_below_joint( end, : );
            
            % Retrieve the BPA muscle IDs on this limb.
            BPA_muscle_IDs = self.BPA_muscle_manager.get_all_BPA_muscle_IDs(  );
            
            % Retrieve the matching BPA muscle IDs on this limb.
            matching_BPA_muscle_IDs = BPA_muscle_IDs( BPA_muscle_logical_indexes );
            
        end
        
        
        % Implement a function to compute the joint torques associated with the current BPA muscle tensions on this limb.
        function self = BPA_muscle_tensions2joint_torques( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Retrieve relevant size information.
            num_muscles = self.BPA_muscle_manager.num_BPA_muscles;
            num_joints = self.joint_manager.num_joints;
            
            % Ensure that there are two muscles assigned to each joint.
            if ( self.BPA_muscle_manager.num_BPA_muscles ~= 2*self.joint_manager.num_joints ) && bVerbose          % If there are not two muscles per joint...
                
                % Throw an error stating that we must have two muscles per joint.
                warning( 'This limb has %0.0f joints and %0.0f muscles, while the current algorithm assumes that there are two muscles per joint.\n', num_joints, num_muscles )

                
            end
            
            % Compute the force required in each muscle.
            for k1 = 1:num_joints               % Iterate through each joint...
                
                % Retrieve the current joint ID.
                joint_ID = self.joint_manager.joints(k1).ID;
                
                % Retrieve the indexes of the muscles that straddle this joint.
                BPA_muscle_IDs = self.get_straddling_muscle_IDs( joint_ID );
                
                % Compute the number of muscles straddling this joint.
                num_muscles_straddling_joint = length( BPA_muscle_IDs );
                
                % Initialize the joint torque associated with this joint.
                joint_torque = 0;
                
                % Compute the torque about this joint generated by each muscle.
                for k2 = 1:num_muscles_straddling_joint                     % Iterate through each muscle straddling this joint...
                    
                    % Compute the BPA muscle index associated with this BPA muscle.
                    BPA_muscle_index = self.BPA_muscle_manager.get_muscle_index( BPA_muscle_IDs(k2) );
                    
                    % Compute the position of the second to last muscle attachment point with respect to the last muscle attachment point.
                    p = self.BPA_muscle_manager.BPA_muscles( BPA_muscle_index ).ps( :, end ) - self.BPA_muscle_manager.BPA_muscles( BPA_muscle_index ).ps( :, end - 1 );
                    
                    % Compute the line of action of the force generated by this muscle.
                    Fhat = p/norm( p, 2 );
                    
                    % Compute the moment arm for the force generated by this muscle.
                    r = self.BPA_muscle_manager.BPA_muscles( BPA_muscle_index ).ps( :, end ) - self.joint_manager.joints( k1 ).p;
                   
                    % Retrieve the desired tension associated with this muscle.
                    F = self.BPA_muscle_manager.BPA_muscles( BPA_muscle_index ).desired_tension;
                    
                    % Compute the moment about this joint generated by this muscle.
                    joint_torque = joint_torque + norm( cross( r, F*Fhat ), 2 );
                    
                end
                
                % Store the torque associated with this joint.
                self.joint_manager.joints(k1).torque = joint_torque;

            end
            
        end
        
        
        % Implement a function to compute the next joint angles of this limb if the current joint torques are maintained for a single time step. ( Forward Dynamics: Joint Torque -> Joint Angle )
        function self = joint_torques2joint_angles( self, dt, g, dyn_int_steps )

            % Define the default input arguments.
            if nargin < 4, dyn_int_steps = 10; end
            if nargin < 3, g = [ 0; -9.81; 0 ]; end
            
            % Retrieve the starting joint angles.
            theta0 = self.joint_manager.get_joint_angles( 'all' );
            
            % Retrieve the starting joint velocities.
            dtheta0 = self.joint_manager.get_joint_angular_velocities( 'all' );
            
            % Retrieve the joint torques.
            taus = self.joint_manager.get_joint_torques( 'all' );
            
            % Define the tip wrench.
            Ftipmat = self.F_end_effector;
            
            % Define the home configuration matrices of the center of mass of the links.
            Mcms = self.link_manager.Ms_cms;
            
            % Define the home configuration of the end effector.
            Mend = self.M_end_effector;
            
            % Retrieve the spatial inertia matrix.
            Gs = self.link_manager.Gs_cms;
            
            % Retrieve the screw axes.
            Ss = self.joint_manager.Ss;
            
            % Compute the joint angles and velocities generated by these joint torques.
            [ thetas, dthetas ] = self.physics_manager.forward_dynamics( theta0, dtheta0, taus, g, Ftipmat, Mcms, Mend, Gs, Ss, dt, dyn_int_steps );
            
            % Set the joint angles.
            self.joint_manager = self.joint_manager.set_joint_angles( 'all', thetas );
            
            % Set the joint angular velocities.
            self.joint_manager = self.joint_manager.set_joint_angular_velocities( 'all', dthetas );
            
        end
        
        
        % Implement a function to compute the joint torques required to maintain the current joint angles on this limb. ( (Partial) Inverse Dynamics: Joint Angle -> Joint Torque )
        function self = joint_angles2joint_torques( self, g )
            
            % Set the default input arguments.
            if nargin < 2, g = [ 0; -9.81; 0 ]; end
            
            % Retrieve the current joint angles.
            thetas = self.joint_manager.get_joint_angles( 'all' );
            
            % Retrieve the current joint angular velocities.
            dthetas = self.joint_manager.get_joint_angular_velocities( 'all' );

            % Set the desired joint angular acceleration to zero.
            ddthetas = zeros( size( thetas ) );
            
            % Define the tip wrench.
            Ftipmat = self.F_end_effector';
            
            % Define the home configuration matrices of the center of mass of the links.
            Mcms = self.link_manager.Ms_cms;
            
            % Define the home configuration of the end effector.
            Mend = self.M_end_effector;
            
            % Retrieve the spatial inertia matrix.
            Gs = self.link_manager.Gs_cms;
            
            % Retrieve the screw axes.
            Ss = self.joint_manager.Ss;
            
            % Compute the required joint torques.
            taus = self.physics_manager.inverse_dynamics( thetas, dthetas, ddthetas, g, Ftipmat, Mcms, Mend, Gs, Ss );
            
            % Set the joint torques.
            self.joint_manager = self.joint_manager.set_joint_torques( 'all', taus );
            
        end
        
        
        %% Configuration Functions
        
        % Implement a function to compute the position, orientation, and configuration of the end effector based on the current joint angles of this limb.
        function self = joint_angles2end_effector_configuration( self )
            
            % Retrieve the angles of the joints on this limb.
            thetas = cell2mat( self.joint_manager.get_joint_property( 'all', 'theta' ) )';
            
            % Compute the current configuration of the end effector.
            self.T_end_effector = self.physics_manager.forward_kinematics( self.M_end_effector, self.J_end_effector, self.joint_manager.Ss, thetas );
            
            % Compute the end effector position and orientation.
            [ self.p_end_effector, self.R_end_effector ] = self.physics_manager.T2PR( self.T_end_effector );
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the joints based on the current joint angles of this limb.
        function self = joint_angles2joint_configurations( self )
        
            % Use the joint manager to compute the position, orientation, and configuration of the joints based on the current joint angles of this limb.
            self.joint_manager = self.joint_manager.joint_angles2joint_configurations(  );
            
        end
            
        
        % Implement a function to compute the position, orientation, and configuration of the links based on the current joint angles of this limb.
        function self = joint_angles2link_configurations( self )
            
            % Retrieve the angles of the joints on this limb.
            thetas = cell2mat( self.joint_manager.get_joint_property( 'all', 'theta' ) )';
            
            % Compute the configuration of the links.
            self.link_manager.Ts_cms = self.physics_manager.forward_kinematics( self.link_manager.Ms_cms, self.link_manager.Js_cms, self.joint_manager.Ss, thetas );
            self.link_manager.Ts_links = self.physics_manager.forward_kinematics( self.link_manager.Ms_links, self.link_manager.Js_links, self.joint_manager.Ss, thetas );
            self.link_manager.Ts_meshes = self.physics_manager.forward_kinematics( self.link_manager.Ms_meshes, self.link_manager.Js_meshes, self.joint_manager.Ss, thetas );

            % Compute the end effector position and orientation of the links.
            [ ps_cms, Rs_cms ] = self.physics_manager.T2PR( self.link_manager.Ts_cms );
            [ ps_links, ~ ] = self.physics_manager.T2PR( self.link_manager.Ts_links );
            [ ps_meshes, ~ ] = self.physics_manager.T2PR( self.link_manager.Ts_meshes );

            % Create cells to store the update link positions, orientations, and configurations.
            [ ps_cms_cell, ps_links_cell, ps_meshes_cell, Rs_cell, Ts_cms_cell, Ts_links_cell, Ts_meshes_cell ] = deal( cell( 1, self.link_manager.num_links ) );
            
            % Store the updated link positions, orientations, and configurations into cell arrays.
            for k = 1:self.link_manager.num_links               % Iterate through each link...
                
                % Store the updated positions of this link.
                ps_cms_cell{k} = ps_cms( :, :, k );
                ps_links_cell{k} = ps_links( :, :, k );
                ps_meshes_cell{k} = ps_meshes( :, :, k );

                % Store the updated orientations of this link.
                Rs_cell{k} = Rs_cms( :, :, :, k );
                
                % Store the updated configurations of this link.
                Ts_cms_cell{k} = self.link_manager.Ts_cms( :, :, :, k );
                Ts_links_cell{k} = self.link_manager.Ts_links( :, :, :, k );
                Ts_meshes_cell{k} = self.link_manager.Ts_meshes( :, :, :, k );

            end
            
            % Update the link position properties.
            self.link_manager = self.link_manager.set_link_property( 'all', ps_cms_cell, 'p_cm' );
            self.link_manager = self.link_manager.set_link_property( 'all', ps_links_cell, 'ps_link' );
            self.link_manager = self.link_manager.set_link_property( 'all', ps_meshes_cell, 'ps_mesh' );

            % Update the link orientation properties.
            self.link_manager = self.link_manager.set_link_property( 'all', Rs_cell, 'R' );

            % Update the link configuration properties.
            self.link_manager = self.link_manager.set_link_property( 'all', Ts_cms_cell, 'T_cm' );
            self.link_manager = self.link_manager.set_link_property( 'all', Ts_links_cell, 'Ts_link' );
            self.link_manager = self.link_manager.set_link_property( 'all', Ts_meshes_cell, 'Ts_mesh' );
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of the BPA muscles based on the current joint angles of this limb.
        function self = joint_angles2BPA_muscle_configurations( self )
            
            % Retrieve the angles of the joints on this limb.
            thetas = cell2mat( self.joint_manager.get_joint_property( 'all', 'theta' ) )';
            
            % Compute the configuration of the BPA muscles.
            self.BPA_muscle_manager.Ts = self.physics_manager.forward_kinematics( self.BPA_muscle_manager.Ms, self.BPA_muscle_manager.Js, self.joint_manager.Ss, thetas );

            % Compute the position and configuration of the BPA muscles.
            [ ps, Rs ] = self.physics_manager.T2PR( self.BPA_muscle_manager.Ts );

            % Create cells to store the update BPA muscle positions, orientations, and configurations.
            [ ps_cell, Rs_cell, Ts_cell ] = deal( cell( 1, self.BPA_muscle_manager.num_BPA_muscles ) );
            
            % Store the updated BPA muscle positions, orientations, and configurations into cell arrays.
            for k = 1:self.BPA_muscle_manager.num_BPA_muscles               % Iterate through each BPA muscle...
                
                % Store the updated positions of this BPA muscle.
                ps_cell{k} = ps( :, :, k );

                % Store the updated orientations of this BPA muscle.
                Rs_cell{k} = Rs( :, :, :, k );
                
                % Store the updated configurations of this BPA muscle.
                Ts_cell{k} = self.BPA_muscle_manager.Ts( :, :, :, k );

            end
            
            % Update the BPA muscle position properties.
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_BPA_muscle_property( 'all', ps_cell, 'ps' );

            % Update the BPA muscle orientation properties.
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_BPA_muscle_property( 'all', Rs_cell, 'Rs' );

            % Update the BPA muscle configuration properties.
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_BPA_muscle_property( 'all', Ts_cell, 'Ts' );
            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of all of the points on this limb given the current joint angles of this limb.
        function self = joint_angles2limb_configurations( self )
            
            % Compute the position, orientation, and configuration of the end effector based on the current limb joint angles.
            self = self.joint_angles2end_effector_configuration(  );
            
            % Compute the position, orientation, and configuration of the joint points based on the current limb joint angles.
            self = self.joint_angles2joint_configurations(  );
            
            % Compute the position, orientation, and configuration of the link points based on the current limb joint angles.
            self = self.joint_angles2link_configurations(  );
            
            % Compute the position, orientation, and configuration fo the BPA muscle points based on the current limb joint angles.
            self = self.joint_angles2BPA_muscle_configurations(  );
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot all of the points that comprise this limb ( BPA muscle attachment points, link points, and joint points ).
        function fig = plot_limb_points( self, fig, plotting_options )
        
            % Determine whether we need to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
          
            % Determine whether we need to create a figure for the limb points.
            if nargin < 2
               
                % Create a figure to store the limb points.
                fig = figure('Color', 'w'); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Limb Points')
                
            end
            
            % Plot the BPA muscle attachment points associated with this limb.
            fig = self.BPA_muscle_manager.plot_BPA_muscle_points( fig, plotting_options );

            % Plot the link points associated with this limb.
            fig = self.link_manager.plot_link_points( fig, plotting_options );

            % Plot the joint points associated with this limb.
            fig = self.joint_manager.plot_joint_points( fig, plotting_options );
            
        end
            
        
    end
end

