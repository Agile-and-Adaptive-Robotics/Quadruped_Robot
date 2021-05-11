classdef synapse_manager_class

    % This class contains properties and methods related to managing synapses.
    
    %% SYNAPSE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        synapses
        num_synapses
%         delta_oscillatory
%         delta_bistable
    end
    
    
    %% SYNAPSE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_manager_class( synapses )

            % Set the default synapse properties.
            if nargin < 1, self.synapses = synapse_class(); else, self.synapses = synapses; end
            
            % Compute the number of synapses.
            self.num_synapses = length(self.synapses);
            
        end


    end
end

