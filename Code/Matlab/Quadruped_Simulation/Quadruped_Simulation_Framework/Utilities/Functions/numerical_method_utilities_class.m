classdef numerical_method_utilities_class

    % This class contains properties and methods related to numerical methods utilities.
    
    
    %% NUMERICAL METHODS UTILITIES PROPERTIES
    
    % Define class properties.
    properties
        
        method_names
        
    end
    
    
    %% NUMERICAL METHODS UTILITIES METHODS SETUP
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = numerical_method_utilities_class(  )

            % Define the method names.
            self.method_names = {'Forward Euler'};
            
        end
 
        
        %% Numerical Integration Methods
        
        % Implement a function to perform a single forward Euler step.
        function U = forward_euler_step( ~, U, dU, dt)

            % Estimate the simulation states at the next time step.
            U = U + dt*dU;

        end
        
        
        %% Numerical Differentiation Methods
        
        
        
    end
end

