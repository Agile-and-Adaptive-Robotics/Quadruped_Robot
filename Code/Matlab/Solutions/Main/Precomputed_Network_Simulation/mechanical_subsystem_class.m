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
        

    end
end

