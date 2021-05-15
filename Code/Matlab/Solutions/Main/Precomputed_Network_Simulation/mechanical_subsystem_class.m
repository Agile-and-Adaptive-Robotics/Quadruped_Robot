classdef mechanical_subsystem_class

    % This class contains properties and methods related to the mechanical subsystem.
    
    %% MECHANICAL SUBSYSTEM PROPERTIES
    
    % Define the class properties.
    properties
        body
        limb_manager
    end
    
    
    %% MECHANICAL SUBSYSTEM METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = mechanical_subsystem_class( body, limb_manager )

            % Set the default mechanical subsystem properties.
            if nargin < 2, self.limb_manager = limb_manager_class(); else, self.limb_manager = limb_manager; end
            if nargin < 1, self.body = body_class(); else, self.body = body; end
            
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot all of the limb and body points.
        function fig = plot_mechanical_points( self, fig, plotting_options )
        
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || isempty( plotting_options ) ), plotting_options = {  }; end
            
            % Determine whether we want to add the mechanical subsystem points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the body mesh points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Mechanical Subsystem Points')
                
            end
            
            % Plot the body points.
            fig = self.body.plot_body_points( fig, plotting_options );
            
            % Plot the limb points.
            fig = self.limb_manager.plot_limb_points( fig, plotting_options );
            
        end
            

    end
end

