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
 
        
        %% Numerical Stability Methods
                
        % Implement a function to determine whether a stability metric is stable.
        function b_stable = is_metric_stable( R )
        
            % Determine whether this metric is stable.
            if any( abs( R ) >= 1 )      	% If the absolute value of the stability metric is greater than or equal to one...
               
                % Set the stable flag to false.
                b_stable = false;
                
            else                            % Otherwise...
                
                % Set the stable flag to true.
                b_stable = true;
                
            end
            
        end
        
            
        % Implement a function to compute the RK4 stability metric.
        function R = compute_RK4_stability( mu )
        
            % Compute the RK4 stability.
            R = 1 + mu + ( 1/2 )*mu.^2 + ( 1/6 )*mu.^3 + ( 1/24 )*mu.^4;
            
        end
        
        
        % Implement a function to compute the RK4 stability metric associated with a given eigenvalue and step size.
        function R = eigenvalues2RK4_stability( lambdas, dt )
           
            % Compute the stability metric input.
            mu = dt*lambdas;
            
            % Compute the RK4 stability metric.
            R = compute_RK4_stability( mu );
            
        end
        
        
        % Implement a function to compute the compute the RK4 stability metric associated with a given system and step size.
        function R = system_matrix2RK4_stability( A, dt )
            
            % Compute the eigenvalues associated with this matrix.
            lambdas = eig( A );
            
            % Compute the RK4 stability metric associated with these eigenvalues.
            R = eigenvalues2RK4_stability( lambdas, dt );
            
        end
        
        
        % Implement a function to compute the maximum step size for RK4 given a system matrix.
        function dt = compute_max_RK4_step_size( A, dt0 )
        
            % Define the default input arguments.
            if nargin < 2, dt0 = 1; end
            
            % Create the stability function.
            f_stability = @( dt ) max( abs( system_matrix2RK4_stability( A, dt ) ) );
            
            % Compute the maximum timestep.
            dt = fzero( f_stability, dt0 );
            
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

