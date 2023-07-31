classdef mesh_utilities_class
    
    % This class contains properties and methods related to mesh utilities.
    
    
    %% MESH UTILITIES PROPERTIES
    
    % Define class properties.
    properties
      
    end
    
    
    %% MESH UTILITIES SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = mesh_utilities_class(  )
            
            
        end
       
        
        % Implement a function to compute a links mesh assuming that it is a cuboid.
        function Ps = get_cuboid_points( ~, sx, sy, sz, dx, dy, dz, thetax, thetay, thetaz )
            
            % Define default input arguments.
            if nargin < 10, thetaz = 0; end
            if nargin < 9, thetay = 0; end
            if nargin < 8, thetax = 0; end
            if nargin < 7, dz = 0; end
            if nargin < 6, dy = 0; end
            if nargin < 5, dx = 0; end
            if nargin < 4, sz = 1; end
            if nargin < 3, sy = 1; end
            if nargin < 2, sx = 1; end
            
            % Create a scaling matrix.
            S = [ sx 0 0 0; 0 sy 0 0; 0 0 sz 0; 0 0 0 1 ];
            
            % Create a rotation matrix.
            Rx = [ 1 0 0 0; 0 cos(thetax) -sin(thetax) 0; 0 sin(thetax) cos(thetax) 0; 0 0 0 1 ];
            Ry = [ cos(thetay) 0 sin(thetay) 0; 0 1 0 0; -sin(thetay) 0 cos(thetay) 0; 0 0 0 1 ];
            Rz = [ cos(thetaz) sin(thetaz) 0 0; -sin(thetaz) cos(thetaz) 0 0; 0 0 1 0; 0 0 0 1 ];
            R = Rz*Ry*Rx;
            
            % Create a translation matrix.
            T = [ 1 0 0 dx; 0 1 0 dy; 0 0 1 dz; 0 0 0 1 ];
            
            % Define the template cubiod points.
            xs = 0.5*[ -1 -1 -1 -1 -1 1 1 -1 1 1 -1 1 1 -1 1 1 ];
            ys = 0.5*[ -1 1 1 -1 -1 -1 1 1 1 1 1 1 -1 -1 -1 -1 ];
            zs = 0.5*[ -1 -1 1 1 -1 -1 -1 -1 -1 1 1 1 1 1 1 -1 ];
            Ps = [ xs; ys; zs; ones(1, length(xs)) ];
            
            % Transform the cuboid based on the desired properties.
            Ps = T*R*S*Ps;
            
            % Remove the last row that is filled with ones.
            Ps(end, :) = [];
            
        end
        
        
        % Implement a function to set the link mesh.
        function ps_mesh = generate_mesh( self, mesh_type, mesh_dimensions, mesh_position, mesh_orientation )
                        
            % Determine how to set the link mesh.
            if strcmp( mesh_type, 'Cuboid' ) || strcmp( mesh_type, 'cuboid' )               % If the mesh type is cuboid...
                
                % Unpack the mesh properties.
                sx = mesh_dimensions(1); sy = mesh_dimensions(2); sz = mesh_dimensions(3);
                dx = mesh_position(1); dy = mesh_position(2); dz = mesh_position(3);
                thetax = mesh_orientation(1); thetay = mesh_orientation(2); thetaz = mesh_orientation(3);
                
                % Compute the cuboid mesh points.
                ps_mesh = self.get_cuboid_points( sx, sy, sz, dx, dy, dz, thetax, thetay, thetaz );

            elseif isempty( mesh_type )                                                          % If the mesh type is empty...
                
                % Set the mesh to be empty.
                ps_mesh = [];
                
            else                                                                                      % Otherwise...
                
                % Throw an error.
                error( 'Mesh type %s not recognized.', mesh_type )
                
            end
            
        end
        
        
        % Implement a function to compute the moment of inertia of a cuboid link.
        function I_cm = compute_cuboid_Icm( ~, m, sx, sy, sz )
            
            % Compute the moment of inertia of the specified cuboid.
            I_cm = [ (1/12)*m*(sy^2 + sz^2), 0, 0;
                     0, (1/12)*m*(sx^2 + sz^2), 0;
                     0, 0, (1/12)*m*(sx^2 + sy^2) ];
            
        end
        
        
        % Implement a function to compute the moment of inertia for the link.
        function I_cm = compute_Icm( self, mesh_type, mesh_mass, mesh_dimensions )
            
            % Determine how to compute the moment of inertia of the link.
            if strcmp( mesh_type, 'Cuboid' ) || strcmp( mesh_type, 'cuboid' )                     % If the link is a cuboid...
                
                % Retrieve the mesh dimensions.
                sx = mesh_dimensions(1); sy = mesh_dimensions(2); sz = mesh_dimensions(3);
                
                % Compute the moment of inertia of the link as a cuboid.
                I_cm = self.compute_cuboid_Icm( mesh_mass, sx, sy, sz );

            elseif isempty( mesh_type )                                                                % If no mesh type was specified...
                
                % Set the moment of inertia to be the identity matrix.
                I_cm = eye(3);
                
            else
                
                % Throw an error.
                error('Mesh type %s not recognized.', mesh_type)
                
            end
            
        end
        
        
    end
end

