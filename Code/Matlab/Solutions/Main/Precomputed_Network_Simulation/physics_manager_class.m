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
        
        
%         % Implement a function to create the BPA muscle joint assignment matrix from a given number of body points and bodies.
%         function Js = get_BPA_muscle_joint_assignments( ~, num_body_pts, num_bodies )
%         
%             % Preallocate the joint assignment matrix.
%             Js = zeros( num_body_pts, num_bodies );
%             
%             % Compute the standard joint assignment matrix.
%             for k1 = 1:num_bodies                              % Iterate through each of the bodies...
%                 for k2 = 1:num_body_pts                        % Iterate through each of the points on this body...
%                     
%                     % Compute this joint assignment.
%                     Js( k2, k1 ) = k1;
%                     
%                 end
%             end
%             
%         end
        
        
        % Implement a function to perform forward kinematics. ( Joint Angles -> End Effector Configuration )
        function Ts = forward_kinematics( ~, Ms, Js, Ss, thetas )
            
            % This functions computes the transformation matrices associated with each given home matrix in an open kinematic chain.
            
            % Retrieve information about the size of our input arguments.
            num_joints = size(thetas, 1);
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
        
        
        
        
    end
end

