classdef applied_current_class

    % This class contains properties and methods related to applied currents.
    
    %% APPLIED CURRENT PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        neuron_ID
        
        ts
        I_apps
        
    end
    
    
    %% APPLIED CURRENT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_class( ID, name, neuron_ID, ts, I_apps )
            
            % Set the default properties.
            if nargin < 5, self.I_apps = 0; else, self.I_apps = I_apps; end
            if nargin < 4, self.ts = 0; else, self.ts = ts; end
            if nargin < 3, self.neuron_ID = 0; else, self.neuron_ID = neuron_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
        end
        

    end
end

