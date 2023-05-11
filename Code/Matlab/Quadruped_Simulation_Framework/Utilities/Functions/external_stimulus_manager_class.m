classdef external_stimulus_manager_class
    
    % This class contains properties and methods related to managing external stimuli.
    
    
    %% EXTERNAL STIMULUS MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        applied_current_manager
        applied_voltage_manager

    end
    
    
    %% EXTERNAL STIMULUS MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = external_stimulus_manager_class( applied_current_manager, applied_voltage_manager )
            
            % Set the default properties.
            if nargin < 2, self.applied_voltage_manager = applied_voltage_manager_class(  ); else, self.applied_voltage_manager = applied_voltage_manager; end
            if nargin < 1, self.applied_current_manager = applied_current_manager_class(  ); else, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
    end
end