classdef body_class

    % This class contains properties and methods related to bodies.
    
    % Define the body properties.
    properties
        
        ID
        name
        
        mass
        length
        width
        height
        
        p_cm
        R_cm
        M_cm
        T_cm
        I_cm
        v_cm
        w_cm
       
        ps_mesh
        Ms_mesh
        Ts_mesh
        mesh_type
        
        mesh_utilities
        physics_manager
        
    end
    
    % Define the body methods.
    methods
        
        % Define the class constructor.
        function self = body_class( ID, name, mass, body_length, body_width, body_height, p_cm, R_cm, v_cm, w_cm, mesh_type )
        
            % Create an instance of the mesh utilities class.
            self.mesh_utilities = mesh_utilities_class(  );
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Set the default class properties.
            if nargin < 11, self.mesh_type = ''; else, self.mesh_type = mesh_type; end
            if nargin < 10, self.w_cm = zeros( 3, 1 ); else, self.w_cm = w_cm; end
            if nargin < 9, self.v_cm = zeros( 3, 1 ); else, self.v_cm = v_cm; end
            if nargin < 8, self.R_cm = eye(3); else, self.R_cm = R_cm; end
            if nargin < 7, self.p_cm = zeros( 3, 1 ); else, self.p_cm = p_cm; end
            if nargin < 6, self.height = 0; else, self.height = body_height; end
            if nargin < 5, self.width = 0; else, self.width = body_width; end
            if nargin < 4, self.length = 0; else, self.length = body_length; end
            if nargin < 3, self.mass = 0; else, self.mass = mass; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

            % Define the home configuration of the center of mass.
            self.M_cm = RpToTrans( self.R_cm, self.p_cm );

            % Set the current configuration of the center of mass to be the home configuration.
            self.T_cm = self.M_cm;

            % Compute the moment of inertia of the body.
            self.I_cm = self.mesh_utilities.compute_Icm( self.mesh_type, self.mass, [ self.length; self.height; self.width ] );

            % Compute the mesh points of the body.
            self.ps_mesh = self.mesh_utilities.generate_mesh( self.mesh_type, [ self.length; self.height; self.width ], self.p_cm, [0; 0; 0] );

            % Compute the home configuration of the body's mesh.
            self.Ms_mesh = self.physics_manager.PR2T( self.ps_mesh, self.R_cm );
            
            % Set the current mesh configuration to be the home configuration.
            self.Ts_mesh = self.Ms_mesh;
            
        end

        %% Get & Set Functions
        
        
        
        
        %% Plotting Functions
        
        % Implement a function to plot the body center of mass.
        function fig = plot_body_com_point( self, fig, plotting_options )
        
            % Determine whether we need to set default plotting options.
            if nargin < 3, plotting_options = { '.c', 'Markersize', 15 }; end
       
            % Determine whether we need to create a figure to store the body center of mass.
            if nargin < 2
               
                % Create a figure to store teh body center of mass plot.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Body COM Point')
                
            end
        
            % Plot the body center of mass point.
            plot3( self.p_cm(1), self.p_cm(2), self.p_cm(3), plotting_options{:} )
            
        end
        
        
        % Implement a function to plot the body mesh.
        function fig = plot_body_mesh_points( self, fig, plotting_options )
            
           % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || isempty( plotting_options ) ), plotting_options = { '.-k', 'Markersize', 15, 'Linewidth', 1 }; end
            
            % Determine whether we want to add these body mesh points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Body Mesh Points')
                
            end
            
            % Plot the body mesh points.
            plot3( self.ps_mesh(1, :), self.ps_mesh(2, :), self.ps_mesh(3, :), plotting_options{:} )
            
        end
        
        
        % Implement a function to plot all of the body points.
        function fig = plot_body_points( self, fig, plotting_options )
            
           % Determine whether to specify default plotting options.
            if ( nargin < 3 ), plotting_options = {  }; end
            
            % Determine whether we want to add these body mesh points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Body Points')
                
            end
            
            % Plot the body center of mass points.
            fig = self.plot_body_com_point( fig, plotting_options );
            
            % Plot the body mesh points.
            fig = self.plot_body_mesh_points( fig, plotting_options );
            
        end
        
    end
end

