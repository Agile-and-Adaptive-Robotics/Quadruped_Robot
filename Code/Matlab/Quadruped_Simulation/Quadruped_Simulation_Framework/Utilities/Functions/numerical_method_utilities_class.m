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
        
        
        % Implement a function to perform a single forward euler step.
        function [ x, dx ] = FE( ~, f, t, x, dt )
            
            % Compute the forward euler derivative estimate.
            dx = f( t, x );
            
            % Apply the forward euler derivative estimate.
            x = x + dt*dx;
            
        end
        
        
        % Implement a function to perform a single RK4 step.
        function [ x, dx ] = RK4( ~, f, t, x, dt )
            
            % Compute half the step size.
            dt_half = dt/2;
            
            % Compute the middle time.
            t_mid = t + dt_half;
            
            % Compute the final time.
            t_final = t + dt;
            
            % Compute the RK4 intermediate steps.
            k1 = f( t, x );
            k2 = f( t_mid, x + dt_half*k1 );
            k3 = f( t_mid, x + dt_half*k2 );
            k4 = f( t_final, x + dt*k3 );
            
            % Compute the RK4 derivative estimate.
            dx = ( 1/6 )*( k1 + 2*k2 + 2*k3 + k4 );
            
            % Apply the RK4 derivative estimate.
            x = x + dt*dx;
            
        end
        
        
        %% Numerical Differentiation Methods
        
        
        
    end
end

