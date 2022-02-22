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
        
        b_enabled
        
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled )

            % Set the default synapse properties.
            if nargin < 8, self.b_enabled = true; else, self.b_enabled = b_enabled; end
            if nargin < 7, self.delta = 0; else, self.delta = delta; end
            if nargin < 6, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 5, self.from_neuron_ID = 0; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 4, self.g_syn_max = 1e-6; else, self.g_syn_max = g_syn_max; end
            if nargin < 3, self.dE_syn = -40e-3; else, self.dE_syn = dE_syn; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this syanpse is enabled.
        function self = toggle_enabled( self )
            
            % Toggle whether the syanpse is enabled.
           self.b_enabled = ~self.b_enabled; 
            
        end
        
        
        % Implement a function to enable this syanpse.
        function self = enable( self )
            
           % Enable this syanpse.
           self.b_enabled = true;
            
        end
        
        
        % Implement a function to disable this syanpse.
        function self = disable( self )
            
           % Disable this syanpse.
           self.b_enabled = false;
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save synapse data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load synapse data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end


        

    end
end

