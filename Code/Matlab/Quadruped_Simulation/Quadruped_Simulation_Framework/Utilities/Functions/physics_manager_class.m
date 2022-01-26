classdef physics_manager_class
    
    % This class contains properties and methods related to managing mechanical system dynamics.
    
    %% PHYSICS MANAGER PROPERTIES
    
    % Define the properties of this class.
    properties
        
    end
    
    
    %% PHYSICS MANAGER METHODS SETUP.
    
    % Define the methods of this class.
    methods
        
        % Implement the class constructor.
        function self = physics_manager_class(  )
            
            
        end
        
        
        %% Basic Conversion Functions
        
        % Implement a function to compute the twists associated with the given configurations.
        function Vs = T2V( ~, Ts )
            
            % Retrieve the configuration dimensions.
            num_pts_per_body = size( Ts, 3 );
            num_bodies = size( Ts, 4 );
            num_angles = size( Ts, 5 );
            
            % Preallocate the twists.
            Vs = zeros( 6, num_pts_per_body, num_bodies, num_angles );
            
            % Compute the twist associated with each configuration.
            for k1 = 1:num_angles                               % Iterate through each of the angles...
                for k2 = 1:num_bodies                           % Iterate through each of the bodies...
                    for k3 = 1:num_pts_per_body                 % Iterate through each point on this body...
                        
                        % Compute the twist associated with this configuration.
                        Vs( :, k3, k2, k1 ) = se3ToVec( Ts( :, :, k3, k2, k1 ) );
                        
                    end
                end
            end
            
        end
        
        
        % Implement a function to compute the translational and rotational velocity associated with the given twist.
        function [ vs, ws ] = V2VW( ~, Vs )
            
            % Retrieve the configuration dimensions.
            num_pts_per_body = size( Vs, 2 );
            num_bodies = size( Vs, 3 );
            num_angles = size( Vs, 4 );
            
            % Preallocate the twists.
            [ vs, ws ] = deal( zeros( 3, num_pts_per_body, num_bodies, num_angles ) );
            
            % Compute the translational and rotational velocity associated with each twist.
            for k1 = 1:num_angles                               % Iterate through each of the angles...
                for k2 = 1:num_bodies                           % Iterate through each of the bodies...
                    for k3 = 1:num_pts_per_body                 % Iterate through each point on this body...
                        
                        % Compute the translational and rotational velocity associated with this twist.
                        ws(:, k3, k2, k1) = Vs( 1:3, k3, k2, k1 );
                        vs(:, k3, k2, k1) = Vs( 4:6, k3, k2, k1 );
                        
                    end
                end
            end
            
        end
        
        
        % Implement a function to create configuration matrices from position and orientation matrices.
        function Ts = PR2T( ~, Ps, Rs )
            
            % Set the default orientation matrix to be the identity matrix.
            if nargin < 3, Rs = eye(3); end
            
            % Retrieve the number of bodies.
            num_bodies = size( Ps, 3 );
            
            % Retrieve the number of points per body.
            num_body_pts = size( Ps, 2 );
            
            % Determine whether we need to augment the orientation matrix.
            if size( Rs, 3 ) == 1                       % If only one orientation matrix was provided...
                
                % Repeat the orientation matrix as necessary.
                Rs = repmat( Rs, [ 1, 1, num_body_pts, num_bodies ] );
                
            end
            
            % Preallocate a multidimensional array to store the configuration matrices.
            Ts = zeros( 4, 4, num_body_pts, num_bodies );
            
            % Compute the configuration matrices.
            for k1 = 1:num_bodies                              % Iterate through each of the bodies...
                for k2 = 1:num_body_pts                        % Iterate through each of the points on this body...
                    
                    % Compute this configuration.
                    Ts( :, :, k2, k1 ) = RpToTrans( Rs( :, :, k2, k1 ), Ps( :, k2, k1 ) );
                    
                end
            end
            
        end
        
        
        % Implement a function to create configuration matrices from position and orientation matrices.
        function [ Ps, Rs ] = T2PR( ~, Ts )
            
            % Retrieve the number of bodies.
            num_bodies = size( Ts, 4 );
            
            % Retrieve the number of points per body.
            num_body_pts = size( Ts, 3 );
            
            % Preallocate an array to store the positions associated with each transformation matrix.
            Ps = zeros( 3, num_body_pts, num_bodies );
            Rs = zeros( 3, 3, num_body_pts, num_bodies);
            
            % Compute the position and orientation matrices.
            for k1 = 1:num_bodies                              % Iterate through each of the bodies...
                for k2 = 1:num_body_pts                        % Iterate through each of the points on this body...
                    
                    % Compute the position and orientation matrices.
                    [ Rs( :, :, k2, k1 ), Ps( :, k2, k1 ) ] = TransToRp( Ts( :, :, k2, k1 ) );
                    
                end
            end
            
        end
        
        
        %% Relative Position, Orientation, & Configuration Functions
        
        % Implement a function to compute the position of point P2 with respect to point P1.
        function P21 = PwrtP( ~, P1, P2 )
                        
            % Compute the position of P2 with respect to P1.
            P21 = P2 - P1;              % P2 w.r.t. P1.
            
        end
        
        
        % Implement a function to compute the orientation matrix that maps between two given orientations. ( i.e., R21 = R2 with repsect to R1 )
        function R21 = RwrtR( ~, R1, R2 )
            
            % This function computes the orientation of R2 with respect to R1.
            
            % Compute the orientation of R2 with respect to R1.
            R21 = R1\R2;        % R2 w.r.t. R1.
            
        end
        
        
        % Implement a function to compute the transformation matrix that maps between two given configurations. ( i.e., T21 = T2 with respect to T1 )
        function T21 = TwrtT( self, T1, T2 )
           
            % Convert the transformation matrices to their rotational and translational components.
            [ P1, R1 ] = self.T2PR( T1 );
            [ P2, R2 ] = self.T2PR( T2 );

            % Compute the orientation of R2 with respect to R1.
            R21 = self.RwrtR( R1, R2 );

            % Compute the position of P2 with respect to P1.
            P21 = self.PwrtP( P1, P2 );

            % Construct teh transformation matrix associated with this new orientation and position.
            T21 = self.PR2T( P21, R21 );
            
        end
        
        
        % Implement a function to convert a high dimensional array of configuration matrices defined in the space frame to a high dimensional array of configuration matrices defined relative to one another (in the given order).
        function Ts_relative = Tspace2Trelative( self, Ts_space )
            
            % Retrieve the size information associated with the transformation matrix array in the space frame.
            num_rows = size( Ts_space, 1 );
            num_cols = size( Ts_space, 2 );
            num_joints = size( Ts_space, 3 );
            num_angles = size( Ts_space, 4 );

            % Create a high order matrix to store the relative transformation matrices.
            Ts_relative = zeros( [ num_rows, num_cols, num_joints - 1, num_angles ] );

            % Compute the relative transformation matrix for each joint at each angle.
            for k1 = 1:num_angles                           % Iterate through each of the angles...
                for k2 = 1:(num_joints - 1)                 % Iterate through each of the joints less one...

                    % Compute the relative transformation matrix for this joint at this angle.
                    Ts_relative( :, :, k2, k1 ) = self.TwrtT( Ts_space( :, :, k2, k1 ), Ts_space( :, :, k2 + 1, k1 ) );

                end
            end
            
        end
        
        
        %% Joint Assignment Functions
        
        % Implement a function to create the standard joint assignment matrix from a given number of body points and bodies.
        function Js = get_standard_joint_assignments( ~, num_body_pts, num_bodies )
            
            % Preallocate the joint assignment matrix.
            Js = zeros( num_body_pts, num_bodies );
            
            % Compute the standard joint assignment matrix.
            for k1 = 1:num_bodies                              % Iterate through each of the bodies...
                for k2 = 1:num_body_pts                        % Iterate through each of the points on this body...
                    
                    % Compute this joint assignment.
                    Js( k2, k1 ) = k1;
                    
                end
            end
            
        end
        
        
        
        
        %% Forward & Inverse Kinematics Functions
        
        % Implement a function to perform forward kinematics. ( Joint Angles -> End Effector Configuration )
        function Ts = forward_kinematics( ~, Ms, Js, Ss, thetas )
            
            % This functions computes the transformation matrices associated with each given home matrix in an open kinematic chain.
            
            % Retrieve information about the size of our input arguments.
            num_angles = size(thetas, 2);
            num_pts_per_body = size(Ms, 3);
            num_bodies = size(Ms, 4);
            
            % Initialize a matrix to store the transformation matrix associated with each of the joints.
            Ts = zeros(4, 4, num_pts_per_body, num_bodies, num_angles);
            
            % Compute the transformation matrix associated with each angle and each joint.
            for k1 = 1:num_angles                       % Iterate through each of the angles...
                for k2 = 1:num_bodies                       % Iterate through each of the bodies...
                    for k3 = 1:num_pts_per_body                   % Iterate through each of the body points...
                        
                        % Retrieve the applicable joints.
                        joint_indexes = 1:Js(k3, k2);
                        
                        % Determine how to compute the current transformation matrix.
                        if ~isempty(joint_indexes)          % If the joint index variable is not empty...
                            
                            % Compute the transformation matrix associated with the current joint and the current angles.
                            Ts(:, :, k3, k2, k1) = FKinSpace( Ms(:, :, k3, k2), Ss(:, joint_indexes), thetas(joint_indexes, k1) );
                            
                        else
                            
                            % Use the home matrix in place of the current transformation martix.
                            Ts(:, :, k3, k2, k1) = Ms(:, :, k3, k2);
                            
                        end
                        
                    end
                end
            end
            
        end
        
        
        % Implement a function to perform inverse kinematics. ( End Effector Configuration -> Joint Angles )
        function [ thetas, successes ] = inverse_kinematics( ~, Ms, Js, Ss, Ts, theta_guesses, eomg, ev, theta_noise, max_attempts )
            
            % Define the default input arguments.
            if nargin < 9, max_attempts = 10; end
            if nargin < 8, theta_noise = 2*pi/100; end
            if nargin < 7, ev = 1e-6; end
            if nargin < 6, eomg = 1e-6; end
            
            % Retrieve size information from the inputs.
            num_dof = size( theta_guesses, 1 );
            num_configs = size( Ts, 5 );
            num_bodies = size( Ts, 4 );
            num_pts_per_body = size( Ts, 3 );
            
            % Initialize an array to store the required angles.
            thetas = zeros( num_dof, num_pts_per_body, num_bodies, num_configs );
            
            % Initialize an array to store whether the
            successes = zeros( num_pts_per_body, num_bodies, num_configs );
            
            % Compute the inverse kinematics solution for each configuration...
            for k1 = 1:num_configs                  % Iterate through each configuration...
                for k2 = 1:num_bodies               % Iterate through each body...
                    for k3 = 1:num_pts_per_body     % Iterate through each body point...
                        
                        % Define the current attempt number.
                        attempt_number = 1;
                        
                        % Retrieve the applicable joints.
                        joint_indexes = 1:Js( k3, k2 );
                        
                        % Attempt the inverse kinematics solution a maximum number of times using different initial conditions.
                        while ( ~successes( k3, k2, k1 ) ) && ( attempt_number <= max_attempts )                % While the inverse kinematics solution has not been successful and the number of attempts is still less than or equal to the maximum allowable number of attempts.
                            
                            % Compute the inverse kinematics solution at this time step.
                            [ thetas( :, k3, k2, k1 ), successes( k3, k2, k1 ) ] = IKinSpace( Ss( :, joint_indexes ), Ms( :, :, k3, k2 ), Ts( :, :, k3, k2, k1 ), theta_guesses( :, k3, k2 ), eomg, ev );
                            
                            % Perturb the theta guess value.
                            theta_guesses( :, k3, k2 ) = theta_guesses( :, k3, k2 ) + theta_noise*rand( num_dof, 1 );
                            
                            % Advance the attempt counter.
                            attempt_number = attempt_number + 1;
                            
                        end
                        
                        % Determine how to update the necessary joint angles if an inverse kinematics solution was not achieved.
                        if ~successes( k3, k2, k1 )            % If an inverse kinematics solution was not achieved...
                            
                            % Determine how to update the necessary joint angles.
                            if k1 ~= 1           % If this is not the first iteration...
                                
                                % Set the current joint angle to be the same as the last.
                                thetas( :, k3, k2, k1 ) = thetas( :, k3, k2, k1 - 1 );
                                
                            else                % Otherwise...
                                
                                % Set the current joint angle to zero.
                                thetas( :, k3, k2, k1 ) = zeros( num_dof, 1, 1, 1 );
                                
                            end
                            
                        end
                        
                        % Update the theta guess value to be the most recent value.
                        theta_guesses( :, k3, k2 ) = thetas( :, k3, k2, k1 );
                        
                    end

                end
                
            end
            
            % Determine whether there were any convergence failures.
            if ~all(successes)              % If not all of the inverse kinematics solutions were successful...

                % Throw a warning if at least one of the desired points did not converge.
                warning('At least one solution to the inverse kinematics problem could not be found.')

            end
                        
        end
        
        
        %% Forward & Inverse Dynamics Functions
        
        % Implement a function to compute the dynamics relative home configuration matrix list given the center of mass and end point home configuration matrices in the space frame.
        function Ms_relative = get_dynamics_home_matrices( self, Mcms, Mend )
            
            % Determine the number of joints.
%             num_joints = size( theta0, 1 );
            num_joints = size( Mcms, 4 );

            % Concatenate the home matrices.
            Ms_space = cat( 4, Mcms, Mend );
            
            % Reshape the home matrices to have the shape expected by our spatial to relative configuration function.
            Ms_space = reshape( Ms_space, [ 4, 4, num_joints + 1, 1 ] );
            
            % Convert the space frame home configuration matrices to relative home configuration matrices.
            Ms_relative = self.Tspace2Trelative( Ms_space );
            
            % Reshape the relative home configuration matrices to have the shape expected by the forward dynamics trajectory function.
            Ms_relative = reshape( Ms_relative, [ 4, 4, 1, num_joints ] );
            
            % Add the initial home configuration matrix to our list of relative home configuration matrices.  ( This is necessary because it is dropped by the space to relative frames functions. )
            Ms_relative = cat( 4, Mcms( :, :, 1, 1 ), Ms_relative );
            
        end
        
        
        % Implement a function to perform forward dynamics. ( Joint Torques -> Joint Angles )
        function [ thetas, dthetas ] = forward_dynamics( self, theta0, dtheta0, taus, g, Ftipmat, Mcms, Mend, Gs, Ss, dt, intRes )
            
            % Define the default input arguments.
            if nargin < 12, intRes = 10; end
            
            % Compute the relative home configuration matrices necessary for the forward dynamics calculation.
            Ms_relative = self.get_dynamics_home_matrices( Mcms, Mend );

            % Ensure that there are at least two sets of joint torques.
            if size( taus, 1 ) == 1                                 % If there are only one set of joint torques...
               
                % Augment the single set of joint torques with a row of zeros to make it have at least two rows.
                taus = [ taus; zeros( 1, size( taus, 2 ) ) ];
                
            end
            
            % Perform the forward dynamics calculation.
            [ thetas, dthetas ] = ForwardDynamicsTrajectory( theta0', dtheta0', taus, g, Ftipmat', Ms_relative, Gs, Ss, dt, intRes );      
                                 
        end
        
        
        % Implement a function to perform inverse dynamics. ( Joint Angles -> Joint Torques )
        function taus = inverse_dynamics( self, thetas, dthetas, ddthetas, g, Ftipmat, Mcms, Mend, Gs, Ss )
        
            % Compute the relative home configuration matrices necessary for the forward dynamics calculation.
            Ms_relative = self.get_dynamics_home_matrices( Mcms, Mend );
            
            % Perform the inverse dynamics calculation.
            taus = InverseDynamicsTrajectory( thetas, dthetas, ddthetas, g, Ftipmat, Ms_relative, Gs, Ss );
            
        end
        
        
    end
end

