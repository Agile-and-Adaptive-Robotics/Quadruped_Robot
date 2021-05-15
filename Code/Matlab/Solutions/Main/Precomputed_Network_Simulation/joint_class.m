classdef joint_class

    % This class contains properties and methods related to joints.
    
    
    %% JOINT PROPERTIES
    
    % Define the class properties.
    properties
        ID
        name
        parent_link_ID
        child_link_ID
        p
        R
        v
        w
        v_screw
        w_screw
        S
        M
        T
        theta
    end
    
    %% JOINT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = joint_class( ID, name, parent_link_ID, child_link_ID, p, R, v, w, w_screw, theta )

            % Set the default class properties.
            if nargin < 10, self.theta = 0; else, self.theta = theta; end
            if nargin < 9, self.w_screw = zeros(3, 1); else, self.w_screw = w_screw; end
            if nargin < 8, self.w = zeros(3, 1); else, self.w = w; end
            if nargin < 7, self.v = zeros(3, 1); else, self.v = v; end
            if nargin < 6, self.R = eye(3, 3); else, self.R = R; end
            if nargin < 5, self.p = zeros(3, 1); else, self.p = p; end
            if nargin < 4, self.child_link_ID = 0; else, self.child_link_ID = child_link_ID; end
            if nargin < 3, self.parent_link_ID = 0; else, self.parent_link_ID = parent_link_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

            % Compute the velocity component of the screw axis.
            self.v_screw = cross( self.p, self.w_screw );
            
            % Compute the screw axis.
            self.S = [self.w_screw; self.v_screw];
            
            % Compute the home configuration of this joint.
            self.M = RpToTrans( self.R, self.p );

            % Compute the current configuration of this joint.
            self.T = self.M;
            
        end        
        
        
        %% Configuration Functions
        
        % Implement a function to set the current configuration of this joint to its home configuration.
        function self = send_home( self )
            
            % Set the current configuration to the home configuration.
           self.T = self.M;
           
           % Set the current orientation and position to be the home configuration.
           [ self.R, self.p ] = TransToRp( self.M );
            
           % Set the current joint angle to zero (i.e., the home configuration).
           self.theta = 0;
           
        end
        
        
        %% Plotting Functions
        
        % Implement a function to plot the joint position.
        function fig = plot_joint_position( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { '.r', 'Markersize', 15 }; end
            
            % Determine whether we want to add these joint position to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the joint points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('Joint Position')
                
            end
            
            % Plot the joint position.
            plot3( self.p(1), self.p(2), self.p(3), plotting_options{:} )
            
        end
        
        
    end
end

