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
        theta_domain
        orientation
        torque
        
        conversion_manager
        
    end
    
    %% JOINT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = joint_class( ID, name, parent_link_ID, child_link_ID, p, R, v, w, w_screw, theta, theta_domain, orientation, torque )

            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
            % Set the default class properties.
            if nargin < 13, self.torque = 0; else, self.torque = torque; end
            if nargin < 12, self.orientation = 'Ext'; else, self.orientation = orientation; end
            if nargin < 11, self.theta_domain = [ 0; 2*pi ]; else, self.theta_domain = theta_domain; end
            if nargin < 10, self.theta = 0; else, self.theta = theta; end
            if nargin < 9, self.w_screw = zeros( 3, 1 ); else, self.w_screw = w_screw; end
            if nargin < 8, self.w = zeros( 3, 1 ); else, self.w = w; end
            if nargin < 7, self.v = zeros( 3, 1 ); else, self.v = v; end
            if nargin < 6, self.R = eye( 3, 3 ); else, self.R = R; end
            if nargin < 5, self.p = zeros( 3, 1 ); else, self.p = p; end
            if nargin < 4, self.child_link_ID = -1; else, self.child_link_ID = child_link_ID; end
            if nargin < 3, self.parent_link_ID = 0; else, self.parent_link_ID = parent_link_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

            % Compute the velocity component of the screw axis.
            self.v_screw = cross( self.p, self.w_screw );
            
            % Compute the screw axis.
            self.S = [ self.w_screw; self.v_screw ];
            
            % Compute the home configuration of this joint.
            self.M = RpToTrans( self.R, self.p );

            % Compute the current configuration of this joint.
            self.T = self.M;
            
        end        
        
        
        %% Get & Set Functions
        
        % Implement a function to retrieve the extensor / flexor joint limit associated with this joint.
        function joint_limit = get_joint_limit( self, limit_type )
            
            % Set the default limit type.
            if nargin < 2, limit_type = 'Ext'; end
            
            % Ensure that the limit type is valid before proceeding.
            if strcmp( limit_type, 'Ext' ) || strcmp( limit_type, 'ext' ) || strcmp( limit_type, 'Flx' ) || strcmp( limit_type, 'flx' )         % If the joint orientation is recognized...
                
                % Determine the joint limit index.
                if strcmp( limit_type, self.orientation )                   % If the joint limit type matches the joint orientation...
                    
                    % Set the joint limit index to two.
                    joint_limit_index = 2;
                    
                else                                                        % Otherwise...
                    
                    % Set the joint limit index to one.
                    joint_limit_index = 1;
                    
                end
                
                % Retrieve the joint limit.
                joint_limit = self.theta_domain(joint_limit_index);
                
            else                                % Otherwise...
                
                % Throw an error.
                error('Joint limit type %s not recognized.  Possible limit types: Ext, ext, Flx, flx', limit_type)
                
            end
            
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
                fig = figure( 'Color', 'w', 'Name', 'Joint Position' ); hold on, grid on, xlabel('x [in]'), ylabel('y [in]'), zlabel('z [in]'), title('Joint Position')
                
            end
            
            % Plot the joint position.
            plot3( self.conversion_manager.m2in( self.p(1) ), self.conversion_manager.m2in( self.p(2) ), self.conversion_manager.m2in( self.p(3) ), plotting_options{:} )
            
        end
        
        
    end
end

