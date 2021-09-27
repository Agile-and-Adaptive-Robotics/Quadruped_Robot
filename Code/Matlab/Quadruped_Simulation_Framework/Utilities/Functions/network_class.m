classdef network_class

    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        neuron_manager
        synapse_manager
        network_dt
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( neuron_manager, synapse_manager, network_dt )

            % Set the default network properties.
            if nargin < 3, self.network_dt = 1e-3; else, self.network_dt = network_dt; end
            if nargin < 2, self.synapse_manager = synapse_manager_class(); else, self.synapse_manager = synapse_manager; end
            if nargin < 1, self.neuron_manager = neuron_manager_class(); else, self.neuron_manager = neuron_manager; end
            
        end
        

    end
end

