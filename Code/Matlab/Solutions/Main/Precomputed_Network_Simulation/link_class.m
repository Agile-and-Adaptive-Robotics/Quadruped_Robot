classdef link_class
    
    % This class contains properties and methods related to links (links and joints combine to form limbs).
    
    
    %% LINK PROPERTIES
    
    % Define class properties.
    properties
        ID
        name
        parent_joint_ID
        child_joint_ID
        p_start
        p_end
        mass
        len
        width
        I_cm
        p_cm
        v_cm
        w_cm
        ps_mesh
        mesh_type
    end
    
    
    %% LINK METHODS SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = link_class( ID, name, parent_joint_ID, child_joint_ID, p_start, p_end, len, width, mass, p_cm, v_cm, w_cm, mesh_type )
            
            % Set the class properties.
            if nargin < 13, self.mesh_type = ''; else, self.mesh_type = mesh_type; end
            if nargin < 12, self.w_cm = zeros(3, 1); else, self.w_cm = w_cm; end
            if nargin < 11, self.v_cm = zeros(3, 1); else, self.v_cm = v_cm; end
            if nargin < 10, self.p_cm = zeros(3, 1); else, self.p_cm = p_cm; end
            if nargin < 9, self.mass = 0; else, self.mass = mass; end
            if nargin < 8, self.width = 0; else, self.width = width; end
            if nargin < 7, self.len = 0; else, self.len = len; end
            if nargin < 6, self.p_end = zeros(3, 1); else, self.p_end = p_end; end
            if nargin < 5, self.p_start = zeros(3, 1); else, self.p_start = p_start; end
            if nargin < 4, self.child_joint_ID = []; else, self.child_joint_ID = child_joint_ID; end
            if nargin < 3, self.parent_joint_ID = []; else, self.parent_joint_ID = parent_joint_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end
            
            % Generate the link mesh.
            self = self.generate_mesh(  );
            
            % Compute the moment of inertia of the link.
            self = self.compute_Icm(  );
            
        end
        
        
        % Implement a function to compute the length of the link.
        function link_length = compute_link_length( self )
            
            % Compute the link length.
            link_length = norm( self.p_end - self.p_start, 2 );
            
        end
        
        
        % Implement a function to set the length of the link.
        function self = set_link_length( self, link_length )
            
            % Determine whether to set or to compute the link length.
            if nargin < 2               % If a link length was not provided...
                
                % Compute the link length.
                self.len = self.compute_link_length(  );
                
            else                        % Otherwise...
                
                % Set the link length to be the provided length.
                self.len = link_length;
                
            end
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
        function self = generate_mesh( self )
            
            % Determine how to set the link mesh.
            if strcmp( self.mesh_type, 'Cuboid' ) || strcmp( self.mesh_type, 'cuboid' )               % If the mesh type is cuboid...
                
                % Compute the cuboid mesh points.
%                 self.ps_mesh = self.get_cuboid_points( self.len, self.width, self.width, self.p_cm(1), self.p_cm(2), self.p_cm(3), 0, 0, 0 );
                self.ps_mesh = self.get_cuboid_points( self.width, self.len, self.width, self.p_cm(1), self.p_cm(2), self.p_cm(3), 0, 0, 0 );

            elseif isempty( self.mesh_type )                                                          % If the mesh type is empty...
                
                % Set the mesh to be empty.
                self.ps_mesh = [];
                
            else                                                                                      % Otherwise...
                
                % Throw an error.
                error( 'Mesh type %s not recognized.', self.mesh_type )
                
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
        function self = compute_Icm( self )
            
            % Determine how to compute the moment of inertia of the link.
            if strcmp( self.mesh_type, 'Cuboid' ) || strcmp( self.mesh_type, 'cuboid' )                     % If the link is a cuboid...
                
                % Compute the moment of inertia of the link as a cuboid.
%                 self.I_cm = self.compute_cuboid_Icm( self.mass, self.len, self.width, self.width );
                self.I_cm = self.compute_cuboid_Icm( self.mass, self.width, self.len, self.width );

            elseif isempty( self.mesh_type )                                                                % If no mesh type was specified...
                
                % Set the moment of inertia to be the identity matrix.
                self.I_cm = eye(3);
                
            else
                
                % Throw an error.
                error('Mesh type %s not recognized.', self.mesh_type)
                
            end
            
        end
        
        
    end
end

