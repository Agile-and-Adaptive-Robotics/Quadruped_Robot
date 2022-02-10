classdef synapse_class

    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
     
        ID
        name
        
        dE_syn
        g_syn_max
        G_syn
        
        from_neuron_ID
        to_neuron_ID
    
        delta
        
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta )

            % Set the default synapse properties.
            if nargin < 7, self.delta = 0; else, self.delta = delta; end
            if nargin < 6, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 5, self.from_neuron_ID = 0; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 4, self.g_syn_max = 1e-6; else, self.g_syn_max = g_syn_max; end
            if nargin < 3, self.dE_syn = -40e-3; else, self.dE_syn = dE_syn; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

        end
        
        
        %% CPG Functions
       


        

    end
end

