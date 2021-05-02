classdef neural_subsystem_class

    % This class contains properties and methods related to the neural subsystem.
    
    %% NEURAL SUBSYSTEM PROPERTIES
    
    % Define the class properties.
    properties
        network
        hill_muscle_manager
    end
    
    
    %% NEURAL SUBSYSTEM METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neural_subsystem_class( network, hill_muscle_manager )

            % Set the default neural subsystem properties.
            if nargin < 2, self.hill_muscle_manager = hill_muscle_manager_class(); else, self.hill_muscle_manager = hill_muscle_manager; end
            if nargin < 1, self.network = network_class(); else, self.network = network; end

        end
        

    end
end

