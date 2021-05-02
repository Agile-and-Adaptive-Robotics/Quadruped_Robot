classdef limb_class

    % This class contains properties and methods related to limbs (limbs are kinematic chains comprised of links and joints).

    %% LIMB PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        origin

        link_manager
        joint_manager
        BPA_muscle_manager
        
        p_end_effector
        R_end_effector
        M_end_effector
        T_end_effector
        J_end_effector
        
    end
    
    
    %% LIMB METHODS SETUP

    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = limb_class( ID, name, origin, link_manager, joint_manager, BPA_muscle_manager )

            % Define the class properties.
            if nargin < 6, self.BPA_muscle_manager = BPA_muscle_manager_class(); else, self.BPA_muscle_manager = BPA_muscle_manager; end
            if nargin < 5, self.joint_manager = joint_manager_class(); else, self.joint_manager = joint_manager; end
            if nargin < 4, self.link_manager = link_manager_class(); else, self.link_manager = link_manager; end
            if nargin < 3, self.origin = []; else, self.origin = origin; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end
            
            % Set the end effector position, orientation, configuration, and home configuration.
            self = self.set_end_effector_state( );
            
        end
        
        
        % Implement a function to set the end effector position, orientation, and configuration.
        function self = set_end_effector_state( self )
            
            % Determine how to set the end efffector properties.
            if ~isempty( self.link_manager.links )                       % If there are link objects...
            
                % Retrieve the end effector position from the final link.
                self.p_end_effector = self.link_manager.links(end).p_end;

                % Retrieve the end effector orientation from the final link.
                self.R_end_effector = self.link_manager.links(end).R;

                % Compute the end effector home configuration.
                self.M_end_effector = RpToTrans( self.R_end_effector, self.p_end_effector );

                % Set the current end effector configuration.
                self.T_end_effector = self.M_end_effector;
            
                % Set the end effector joint assignment.
                self.J_end_effector = length(self.link_manager.num_links);
                
            else                                            % Otherwise...
                
                % Set the end effector variables to be empty.
                self.p_end_effector = [];
                self.R_end_effector = [];
                self.M_end_effector = [];
                self.T_end_effector = [];
                self.J_end_effector = [];
                
            end
            
        end
        
        
        % Implement a function to get the joint angles from e
        
        
    end
end

