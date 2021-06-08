classdef link_class
    
    % This class contains properties and methods related to links (links and joints combine to form limbs).
    
    
    %% LINK PROPERTIES
    
    % Define class properties.
    properties
        
        ID
        name
        
        parent_joint_ID
        child_joint_ID
        
        mass
        len
        width
        
        R
        
        p_start
        p_end
        
        p_cm
        M_cm
        T_cm
        
        I_cm
        G_cm
        v_cm
        w_cm
        
        ps_mesh
        Ms_mesh
        Ts_mesh
        
        ps_link
        Ms_link
        Ts_link
        
        mesh_type
        
    end
    
    
    %% LINK METHODS SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = link_class( ID, name, parent_joint_ID, child_joint_ID, p_start, p_end, len, width, mass, p_cm, v_cm, w_cm, R, mesh_type )
            
            % Set the class properties.
            if nargin < 14, self.mesh_type = ''; else, self.mesh_type = mesh_type; end
            if nargin < 13, self.R = eye(3); else, self.R = R; end
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
            
            % Compute the spatial inertia of the link.
            self = self.Im2G(  );
            
            % Define the link points.
            self.ps_link = [ self.p_start, self.p_end ];
            
            % Set the home matrices for the link's start point, end point, and com point.
            M_start = RpToTrans( self.R, self.p_start );
            M_end = RpToTrans( self.R, self.p_end );
            self.Ms_link = cat( 3, M_start, M_end );
            self.M_cm = RpToTrans( self. R, self.p_cm );
            
            % Preallocate the link's mesh home configurations.
            self.Ms_mesh = zeros( 4, 4, size( self.ps_mesh, 2 ) );
            
            % Set the link's mesh home configuration.
            for k = 1:size( self.ps_mesh, 2 )               % Iterate through each mesh point...
            
                % Set the home configuration for this mesh point.
                self.Ms_mesh(:, :, k) = RpToTrans( self.R, self.ps_mesh(:, k) );
            
            end
            
        end
        
        %% Link Length Functions
        
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
        
        
        %% Link Mesh Functions
        
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
        
        
        %% Inertia Functions
        
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
                self.I_cm = self.compute_cuboid_Icm( self.mass, self.width, self.len, self.width );

            elseif isempty( self.mesh_type )                                                                % If no mesh type was specified...
                
                % Set the moment of inertia to be the identity matrix.
                self.I_cm = eye(3);
                
            else
                
                % Throw an error.
                error('Mesh type %s not recognized.', self.mesh_type)
                
            end
            
        end
        
        
        % Implement a function to compute the spatial inertia of the link from the rotational and linear inertias.
        function self = Im2G( self )
            
            % Compute the spatial inertial.
            self.G_cm = [ self.I_cm, zeros(3, 3); zeros(3, 3), self.mass*eye(3, 3) ];                                                       % [-] Spatial Inertia Matrix for This Link.

        end
        
        
        % Implement a function to compute the linear and rotational inertias from the spatial inertia.
        function self = G2Im( self )
            
            % Retrieve the rotational moment of inertia.
            self.I_cm = self.G_cm( 1:3, 1:3 );
            
            % Retrieve the mass of the link.
            self.mass = self.G_cm( 4, 4 );
            
        end
        
        
        
        %% Plotting Functions
        
        % Implement a function to plot the start and end points of the link.
        function fig = plot_link_end_points( self, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || isempty( plotting_options ) ), plotting_options = { '.-m', 'Markersize', 15, 'Linewidth', 1 }; end
            
            % Determine whether we want to add these joint end points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the joint end points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Joint End Points')
                
            end
            
            % Plot the joint end points.
            plot3( self.ps_link(1, :), self.ps_link(2, :), self.ps_link(3, :), plotting_options{:} )
            
        end
           
        
        % Implement a function to plot the COM of the link.
        function fig = plot_link_com_point( self, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || isempty( plotting_options ) ), plotting_options = { '.c', 'Markersize', 15 }; end
            
            % Determine whether we want to add these joint end points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the joint com.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Joint COM Point')
                
            end
            
            % Plot the joint com.
            plot3( self.p_cm(1), self.p_cm(2), self.p_cm(3), plotting_options{:} )
            
        end
           
        
        % Implement a function to plot the mesh of the link.
        function fig = plot_link_mesh_points( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || isempty( plotting_options ) ), plotting_options = { '.-k', 'Markersize', 15, 'Linewidth', 1 }; end
            
            % Determine whether we want to add these joint mesh points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the joint mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Joint Mesh Points')
                
            end
            
            % Plot the joint mesh points.
            plot3( self.ps_mesh(1, :), self.ps_mesh(2, :), self.ps_mesh(3, :), plotting_options{:} )
            
        end
        
        
        % Implement a function to plot some subset of the link points.
        function fig = plot_link_points( self, fig, plotting_options, point_type )
        
            % Set the default types of points to plot.
            if nargin < 4, point_type = 'All'; end
            
            % Determine whether to specify default plotting options.
            if nargin < 3, plotting_options = {  }; end
            
            % Determine whether we want to add these joint mesh points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the joint mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Link Points')
                
            end
            
            % Validate the specified point types.
            if strcmp( point_type, 'all' ) || strcmp( point_type, 'All' )               % If we want to plot all of the link points...
            
                % Plot the link end points.
                fig = self.plot_link_end_points( fig, plotting_options );
                
                % Plot the link center of mass.
                fig = self.plot_link_com_point( fig, plotting_options );
                
                % Plot the link mesh.
                fig = self.plot_link_mesh_points( fig, plotting_options );
                
            elseif strcmp( point_type, 'end' ) || strcmp( point_type, 'End' )           % If we want to plot the link end points...
                
                % Plot the link end points.
                fig = self.plot_link_end_points( fig, plotting_options );
                
            elseif strcmp( point_type, 'com' ) || strcmp( point_type, 'COM' )           % If we want to plot the COM point...
                
                % Plot the link com.
                fig = self.plot_link_com_point( fig, plotting_options );

            elseif strcmp( point_type, 'mesh' ) || strcmp( point_type, 'mesh' )         % If we want to plot the mesh points...
                
                % Plot the link mesh points.
                fig = self.plot_link_mesh_points( fig, plotting_options );
                
            else                                                                        % Otherwise...
               
                % Throw an error.
                error( 'Specified point type %s not recognized.', point_type )
                
            end
                
        end
           
        
        
    end
end

