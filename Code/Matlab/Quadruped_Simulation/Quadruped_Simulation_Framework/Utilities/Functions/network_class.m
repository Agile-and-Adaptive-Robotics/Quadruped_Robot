classdef network_class

    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        neuron_manager
        synapse_manager
        applied_current_manager
        network_dt
    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( neuron_manager, synapse_manager, applied_current_manager, network_dt )

            % Set the default network properties.
            if nargin < 4, self.network_dt = 1e-3; else, self.network_dt = network_dt; end
            if nargin < 3, self.applied_current_manager = applied_current_manager_class(  ); else, self.applied_current_manager = applied_current_manager; end
            if nargin < 2, self.synapse_manager = synapse_manager_class(  ); else, self.synapse_manager = synapse_manager; end
            if nargin < 1, self.neuron_manager = neuron_manager_class(  ); else, self.neuron_manager = neuron_manager; end
            
        end
        

        %% Sodium Channel Conductance Functions
        
        % Implement a function to set the two neuron CPG sodium channel conductance for all neurons.
        function self = set_two_neuron_CPG_Gna_for_all_neurons( self )
            
            % Call the lower level neuron manager function that serves this purpose.
            self.neuron_manager = self.neuron_manager.set_two_neuron_CPG_Gna_for_all_neurons(  );       
            
        end
        

        
    end
end

