classdef numerical_method_utilities_class

    % Define class properties.
    properties
        method_names
    end
    
    
    % Define class methods.
    methods
        
        % Implement the class constructor.
        function self = numerical_method_utilities_class(  )

            % Define the method names.
            self.method_names = {'Forward Euler'};
            
        end
        
        
        % Implement a function to perform a single forward Euler step.
        function U = forward_euler_step( ~, U, dU, dt)

            % Estimate the simulation states at the next time step.
            U = U + dt*dU;

        end
        
    end
end

