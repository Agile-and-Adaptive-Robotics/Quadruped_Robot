classdef applied_current_manager_class

    % This class contains properties and methods related to managing applied currents.
    
    %% APPLIED CURRENT MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        applied_currents
        num_applied_currents
        
    end
    
    
    %% APPLIED CURRENT MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_manager_class( applied_currents )
            
            % Set the default properties.
            if nargin < 1, self.applied_currents = applied_current_class(  ); else, self.applied_currents = applied_currents; end
            
            % Compute the number of applied currents.
            self.num_applied_currents = length( self.applied_currents );
            
        end
        

    end
end

