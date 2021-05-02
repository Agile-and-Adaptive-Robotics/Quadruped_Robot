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
                    [ Rs( :, :, k2, k1 ), Ps( :, k2, k1 ) ] = Trans2Rp( Ts( :, :, k2, k1 ) );
                    
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
        
        
        
    end
end

