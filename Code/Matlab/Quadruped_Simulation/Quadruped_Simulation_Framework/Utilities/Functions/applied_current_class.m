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
        
        b_enabled
        
        data_loader_utilities
        
    end
    
    
    %% APPLIED CURRENT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_class( ID, name, neuron_ID, ts, I_apps, b_enabled )
            
            % Set the default properties.
            if nargin < 6, self.b_enabled = true; else, self.b_enabled = b_enabled; end
            if nargin < 5, self.I_apps = 0; else, self.I_apps = I_apps; end
            if nargin < 4, self.ts = 0; else, self.ts = ts; end
            if nargin < 3, self.neuron_ID = 0; else, self.neuron_ID = neuron_ID; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this applied current is enabled.
        function self = toggle_enabled( self )
            
            % Toggle whether the applied current is enabled.
           self.b_enabled = ~self.b_enabled; 
            
        end
        
        
        % Implement a function to enable this applied current.
        function self = enable( self )
            
           % Enable this applied current.
           self.b_enabled = true;
            
        end
        
        
        % Implement a function to disable this applied current.
        function self = disable( self )
            
           % Disable this applied current.
           self.b_enabled = false;
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save applied current data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load applied current data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current.mat'; end
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

