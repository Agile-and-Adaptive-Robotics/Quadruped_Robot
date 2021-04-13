classdef link_class

    % This class contains properties and methods related to links (links and joints combine to form limbs).
    
    
    %% LINK PROPERTIES
    
    % Define class properties.
    properties
        ID
        name
        parent_joint_ID
        child_joint_ID
        start_point
        end_point
        mass
        length
        Icm
        pcm
        vcm
        wcm
        mesh
    end
    
    
    %% LINK METHODS SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = link_class( ID, name, parent_joint_ID, child_joint_ID, start_point, end_point, mass, length, Icm, pcm, vcm, wcm, mesh )
            
            % Set the class properties.
            if nargin < 13, self.mesh = []; else, self.mesh = mesh; end
            if nargin < 12, self.wcm = []; else, self.wcm = wcm; end
            if nargin < 11, self.vcm = []; else, self.vcm = vcm; end
            if nargin < 10, self.pcm = []; else, self.pcm = pcm; end
            if nargin < 9, self.Icm = []; else, self.Icm = Icm; end
            if nargin < 8, self.length = []; else, self.length = length; end
            if nargin < 7, self.mass = []; else, self.mass = mass; end
            if nargin < 6, self.end_point = []; else, self.end_point = end_point; end
            if nargin < 5, self.start_point = []; else, self.start_point = start_point; end
            if nargin < 4, self.child_joint_ID = []; else, self.child_joint_ID = child_joint_ID; end
            if nargin < 3, self.parent_joint_ID = []; else, self.parent_joint_ID = parent_joint_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = []; else, self.ID = ID; end
            
        end
        

        
        
    end
end

