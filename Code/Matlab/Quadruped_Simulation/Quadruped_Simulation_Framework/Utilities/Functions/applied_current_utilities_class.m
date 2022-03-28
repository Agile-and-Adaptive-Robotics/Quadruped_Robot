classdef applied_current_utilities_class

    % This class contains properties and methods related to applied current utilities.
    
    
    %% APPLIED CURRENT UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    %% APPLIED CURRENT UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_utilities_class(  )

            
            
        end
        
        
        %% Applied Current Design Functions
        
        % Implement a function to compute the magnitude of multiplication subnetwork applied currents.
        function I_apps = compute_multiplication_Iapps( ~, Gm, R )
           
            % Compute the magnitude of multiplication subnetwork applied currents.
            I_apps = Gm.*R;
            
        end
        
        
    end
end