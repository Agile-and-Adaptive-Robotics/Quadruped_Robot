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
        
        physics_manager
        
    end
    
    
    %% LIMB METHODS SETUP

    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = limb_class( ID, name, origin, link_manager, joint_manager, BPA_muscle_manager )

            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Define the class properties.
            if nargin < 6, self.BPA_muscle_manager = BPA_muscle_manager_class(); else, self.BPA_muscle_manager = BPA_muscle_manager; end
            if nargin < 5, self.joint_manager = joint_manager_class(); else, self.joint_manager = joint_manager; end
            if nargin < 4, self.link_manager = link_manager_class(); else, self.link_manager = link_manager; end
            if nargin < 3, self.origin = []; else, self.origin = origin; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end
            
            % Set the end effector position, orientation, configuration, and home configuration.
            self = self.set_end_effector_state( );
            
        end
        
        
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
        
        
        %% Configuration Functions.
        
        % Implement a function to compute the position, orientation, and configuration of the end effector based on the current joint angles of this limb.
        function self = joint_angles2end_effector_configuration( self )
            
            % Retrieve the angles of the joints on this limb.
            thetas = self.joint_manager.get_joint_property( 'all', 'theta' )';
            
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
            thetas = self.joint_manager.get_joint_property( 'all', 'theta' )';
            
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
            thetas = self.joint_manager.get_joint_property( 'all', 'theta' )';
            
            % Compute the configuration of the BPA muscles.
            self.BPA_muscle_manager.Ts = self.physics_manager.forward_kinematics( self.link_manager.Ms_cms, self.link_manager.Js_cms, self.joint_manager.Ss, thetas );

            % Compute the position and configuration of the BPA muscles.
            [ ps, Rs ] = self.physics_manager.T2PR( self.link_manager.Ts_cms );

            % Create cells to store the update BPA muscle positions, orientations, and configurations.
            [ ps_cell, Rs_cell, Ts_cell ] = deal( cell( 1, self.link_manager.num_links ) );
            
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
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_link_property( 'all', ps_cell, 'ps' );

            % Update the BPA muscle orientation properties.
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_link_property( 'all', Rs_cell, 'Rs' );

            % Update the BPA muscle configuration properties.
            self.BPA_muscle_manager = self.BPA_muscle_manager.set_link_property( 'all', Ts_cell, 'Ts' );

            
        end
        
        
        % Implement a function to compute the position, orientation, and configuration of all of the points on this limb given the current joint angles of this limb.
        function self = joint_angles2limb_configurations( self )
            
            
            
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

