classdef neuron_manager_class

    % This class contains properties and methods related to managiing neurons.
    
    %% NEURON MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        neurons
        num_neurons
    end
    
    
    %% NEURON MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_manager_class( neurons )

            % Set the default class properties.
            if nargin < 1, self.neurons = neuron_class(); else, self.neurons = neurons; end
            
            % Compute the number of neurons.
            self.num_neurons = length(self.neurons);
            
        end
        
        
    end
end

