classdef limb_class

    % This class contains properties and methods related to limbs (limbs are kinematic chains comprised of links and joints).

    %% LIMB PROPERTIES
    
    % Define the class properties.
    properties
        ID
        name
        links
        joints
        screw_axes
        home_matrices
        link_assignments
        origin
    end
    
    %% LIMB METHODS SETUP

    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = limb_class( ID, name, links, joints, screw_axes, home_matrices, link_assignments, origin )

            % Define the class properties.
            if nargin < 8, self.origin = []; else, self.origin = origin; end
            if nargin < 7, self.link_assignments = []; else, self.link_assignments = link_assignments; end
            if nargin < 6, self.home_matrices = []; else, self.home_matrices = home_matrices; end
            if nargin < 5, self.screw_axes = []; else, self.screw_axes = screw_axes; end
            if nargin < 4, self.joints = []; else, self.joints = joints; end
            if nargin < 3, self.links = []; else, self.links = links; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end

        end
        
        
    end
end

