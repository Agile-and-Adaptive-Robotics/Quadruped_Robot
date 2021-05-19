classdef hill_muscle_class
    
    % This class contains properties and methods related to hill muscles.
    
    %% HILL MUSCLE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        
        activation
        activation_domain
        
        desired_total_tension
        desired_active_tension
        desired_passive_tension
        
        measured_total_tension
        measured_active_tension
        measured_passive_tension
        
        tension_domain
        
        muscle_length
        resting_muscle_length
        length_domain
        
        muscle_strain
        max_muscle_strain
        
        velocity
        velocity_domain
        
        yank
        
        typeIa_feedback
        typeIb_feedback
        typeII_feedback
        
        kse
        kpe
        b
        
        network_dt
        num_int_steps
        
        numerical_method_utilities
        
    end
    
    
    %% HILL MUSCLE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = hill_muscle_class( ID, name, activation, activation_domain, desired_active_tension, measured_total_tension, tension_domain, muscle_length, resting_muscle_length, max_muscle_strain, velocity, yank, kse, kpe, b, network_dt, num_int_steps )
            
            % Create an instance of the numerical methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class();
            
            % Set the default hill muscle properties.
            if nargin < 17, self.num_int_steps = 10; else, self.num_int_steps = num_int_steps; end
            if nargin < 16, self.network_dt = 1e-3; else, self.network_dt = network_dt; end
            if nargin < 15, self.b = 1; else, self.b = b; end
            if nargin < 14, self.kpe = 30; else, self.kpe = kpe; end
            if nargin < 13, self.kse = 30; else, self.kse = kse; end
            if nargin < 12, self.yank = 0; else, self.yank = yank; end
            if nargin < 11, self.velocity = 0; else, self.velocity = velocity; end
            if nargin < 10, self.max_muscle_strain = 0.16; else, self.max_muscle_strain = max_muscle_strain; end
            if nargin < 9, self.resting_muscle_length = 1; else, self.resting_muscle_length = resting_muscle_length; end
            if nargin < 8, self.muscle_length = self.resting_muscle_length; else, self.muscle_length = muscle_length; end
            if nargin < 7, self.tension_domain = [0, 450]; else, self.tension_domain = tension_domain; end
            if nargin < 6, self.measured_total_tension = 0; else, self.measured_total_tension = measured_total_tension; end
            if nargin < 5, self.desired_active_tension = 0; else, self.desired_active_tension = desired_active_tension; end
            if nargin < 4, self.activation_domain = [-0.050, -0.019]; else, self.activation_domain = activation_domain; end
            if nargin < 3, self.activation = 0; else, self.activation = activation; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Compute the muscle strain.
            self.muscle_strain = self.length2strain( self.muscle_length, self.resting_muscle_length );
            
            % Compute the length domain.
            self.length_domain = [ self.max_muscle_strain*self.resting_muscle_length, self.resting_muscle_length ];
            
            % Compute the muscle strain.
            self.muscle_strain = self.length2strain( self.muscle_length, self.resting_muscle_length );
            
            % Compute the maximum muscle speed.
            self.velocity_domain = ( range( self.length_domain )/self.network_dt )*[-1, 1];
            
            % Compute the desired total and passive tension associated with the desired active tension. ( Desired Active Tension -> Desired Total Tension, Desired Passive Tension )
            self = self.desired_active_tension2desired_total_passive_tension(  );
            
            % Compute the measured active and passive tension associated with the measured total tension. ( Measured Total Tension -> Measured Active Tension, Measured Passive Tension )
            self = self.measured_total_tension2measured_active_passive_tension(  );
            
            % Compute the feedback sources.
            self.typeIa_feedback = self.muscle_value2muscle_feedback( self.velocity, self.velocity_domain, self.activation_domain );
            self.typeIb_feedback = self.muscle_value2muscle_feedback( self.measured_total_tension, self.tension_domain, self.activation_domain );
            self.typeII_feedback = self.muscle_value2muscle_feedback( self.muscle_length, self.length_domain, self.activation_domain );
            
        end
        
        
        
        
        %% LENGTH-STRAIN FUNCTIONS
        
        % Implement a function to compute the muscle strain associated with a given muscle length and resting length.
        function muscle_strain = length2strain( ~, muscle_length, resting_muscle_length )
            
            % Compute the current muscle strain.
            muscle_strain = 1 - muscle_length/resting_muscle_length;
            
        end
        
        
        % Implement a function to compute the current muscle length given the current muscle strain.
        function muscle_length = strain2length( ~, muscle_strain, resting_muscle_length )
            
            % Compute the current muscle length.
            muscle_length = resting_muscle_length*(1 - muscle_strain);
            
        end
        
        
        %% MUSCLE FEEDBACK FUNCTIONS
        
        % Implement a function to saturate a muscle property.
        function value = saturate_value( ~, value, domain )
            
            % Saturate the given value.
            if value < domain(1)                 % If the measured total tension is below the lower tension bound...
                
                % Set the saturated tension to be the lower tension bound.
                value = domain(1);
                
            elseif value > domain(2)                 % If the measured total tension is below the upper tension bound...
                
                % Set the saturated tension to be the upper tension bound.
                value = domain(2);
                
            end
            
        end
        
        
        % Implement a function to compute a source of muscle feedback.
        function feedback = muscle_value2muscle_feedback( self, value, value_domain, feedback_domain )
            
            % Saturate the given muscle value.
            saturated_value = self.saturate_value( value, value_domain );
            
            % Compute the feedback associated with the given saturated muscle value.
            feedback = interp1( value_domain, feedback_domain, saturated_value );
            
        end
        
        
        % Implement a function to compute the Type Ia (muscle velocity) feedback associated with the current hill muscle velocity.
        function self = velocity2typeIa_feedback( self )
            
            % Compute the type Ia feedback associated with the current hill muscle velocity.
            self.typeIa_feedback = self.muscle_value2muscle_feedback( self.velocity, self.velocity_domain, self.activation_domain );
            
        end
        
        
        % Implement a function to compute the Type Ib (total muscle tension) feedback associated with the current hill muscle total tension.
        function self = measured_total_tension2typeIb_feedback( self )
            
            % Compute the type Ib feedback associated with the current hill muscle measured total tension.
            self.typeIb_feedback = self.muscle_value2muscle_feedback( self.measured_total_tension, self.tension_domain, self.activation_domain );

        end
        
        
        % Implement a function to compute the Type II (muscle length) feedback associated with the current hill muscle length.
        function self = length2typeII_feedback( self )
            
            % Compute the type II feeedback associated with the current hill muscle length.
            self.typeII_feedback = self.muscle_value2muscle_feedback( self.muscle_length, self.length_domain, self.activation_domain );

        end
        
        
        %% MUSCLE ACTIVATION FUNCTIONS
        
        % Implement a function to compute the muscle tension (total or active) associated with a given muscle activation.
        function tension = activation2tension( ~, activation_domain, tension_domain, activation )
            
            % Convert the muscle activation to muscle tension (total or active).
            tension = interp1( activation_domain, tension_domain, activation );
            
        end
        
        
        % Implement a function to compute the muscle activation associated with the given muscle tension (total or active).
        function activation = tension2activation( ~, tension_domain, activation_domain, tension )
            
            % Convert the muscle tension (total or active) to muscle activation.
            activation = interp1( tension_domain, activation_domain, tension );
            
        end
        
        
        % Implement a function to compute the desired total muscle tension associated with the current muscle activation.
        function self = activation2desired_total_tension( self )
            
            % Convert the muscle activation to a desired total muscle tension.
            self.desired_total_tension = self.activation2tension( self.activation_domain, self.tension_domain, self.activation );
            
        end
        
        
        % Implement a function to compute the desired active muscle tension associated with the current muscle activation.
        function self = activation2desired_active_tension( self )
            
            % Convert the muscle activation to a desired total muscle tension.
            self.desired_active_tension = self.activation2tension( self.activation_domain, self.tension_domain, self.activation );
            
        end
        
        
        %% HILL MUSCLE DYNAMICS FUNCTIONS
        
        % Implement a function to compute a single step of the forward hill muscle model.  (Active Tension, Yank, Length, Velocity -> Total Tension)
        function dT = forward_hill_muscle_step( ~, T, L, dL, A, kse, kpe, b )
            
            % This function computes a single step of the foward hill muscle simulation.
            
            % Inputs:
            % T = Total Muscle Tension.
            % L = Muscle Lengths.
            % dL = Muscle Velocity.
            % A = Active Muscle Force.
            % kse = Series Muscle Stiffness.
            % kpe = Parallel Muscle Stiffness.
            % b = Damping Coefficient.
            
            % Outputs:
            % dT = Rate of change of total muscle force with respect to time (i.e., yank).
            
            % Compute the rate of change of the total muscle force with respect to time (i.e., yank).
            dT = (kse./b).*(kpe.*L + b.*dL - (1 + (kpe./kse)).*T + A);
            
        end
        
        
        % Implement a function to integrate the forward hill muscle model.
        function [T, dT] = integrate_forward_hill_muscle( self, T0, L0, dL, A, kse, kpe, b, dt, num_steps )
            
            % This function integrates the forward hill muscle model to compute the total muscle tension T developed after dt seconds as a result of a constant active muscle A, given the current length, velocity, and total muscle tension, as well as relevant muscle properties.
            
            % Inputs:
            % T0 = [N] Total Muscle Tension at t = 0.
            % L0 = [m] Muscle Length at t = 0.
            % dL = [m/s] Muscle Velocity (Assumed constant over the time interval dt).
            % A = [N] Active Muscle Tension (Assumed constant over the time interval dt).
            % kse = [N/m] Series Muscle Stiffness.
            % kpe = [N/m] Parallel Muscle Stiffness.
            % b = [Ns/m] Damping Coefficient.
            % dt = [s] Integration Time Interval (Time domain is [0, dt]).
            % num_steps = [#] Number of Integration Steps to Perform Over the Integration Time Interval.
            
            % Outputs:
            % T = [N] Total Muscle Tension at t = dt.
            % dT = [N/s] Total Muscle Yank at t = dt.
            
            % Initialize the muscle length and total muscle tension.
            L = L0;
            T = T0;
            
            % Integrate the forward hill muscle model for the specified number of steps.
            for k = 1:num_steps                       % Iterate through each of the integration steps...
                
                % Compute the rate of change of the muscle tension at this time step.
                dT = self.forward_hill_muscle_step( T, L, dL, A, kse, kpe, b );
                
                % Compute the muscle length and total muscle tension at the next time step.
                L = self.numerical_method_utilities.forward_euler_step( L, dL, dt/num_steps );
                T = self.numerical_method_utilities.forward_euler_step( T, dT, dt/num_steps );
                
            end
            
        end
        
        
        % Implement a funciton to compute the inverse hill muscle model. (Total Tension, Yank, Length, Velocity -> Active Tension)
        function A = inverse_hill_muscle( ~, T, dT, L, dL, kse, kpe, b )
            
            % This function computes the active muscle force of a Hill Muscle given muscle parameters.
            
            % Inputs:
            % T = Total Muscle Tension.
            % dT = Muscle Yank (Derivative of muscle tension with respect to time).
            % L = Muscle Length.
            % dL = Muscle Velocity.
            % kse = Series Muscle Stiffness.
            % kpe = Parallel Muscle Stiffness.
            % b = Damping Coefficient.
            
            % Outputs:
            % A = Active Muscle Tension.
            
            % Compute the muscle activation.
            A = (b./kse).*dT + (1 + (kpe./kse)).*T - b.*dL - kpe.*L;
            
        end
        
        
        %% AUGMENTED HILL MUSCLE DYNAMICS FUNCTIONS
        
        % Implement a function to compute the active and passive muscle tension associated with a given total muscle tension.
        function [ active_tension, passive_tension ] = total_tension2active_passive_tension( self, total_tension, yank, delta_L, velocity, kse, kpe, b )
            
            % Compute the active muscle tension.
            active_tension = self.inverse_hill_muscle( total_tension, yank, delta_L, velocity, kse, kpe, b );
            
            % Compute the passive muscle tension.
            passive_tension = total_tension - active_tension;
            
        end
        
        
        % Implement a function to compute the total and passive muscle tension associated with a given active muscle tension.
        function [ total_tension, passive_tension ] = active_tension2total_passive_tension( self, total_tension0, delta_L0, velocity, active_tension, kse, kpe, b, dt, num_steps )
            
            % Compute the total tension associated with the current active tension.
            total_tension = self.integrate_forward_hill_muscle( total_tension0, delta_L0, velocity, active_tension, kse, kpe, b, dt, num_steps );
            
            % Compute the passive tension associated with the current active tension.
            passive_tension = total_tension - active_tension;
            
        end
        
        
        %% ACTIVE, PASSIVE, & TOTAL MUSCLE FORCE FUNCTIONS
        
        % Implement a function to compute the desired active and desired passive muscle tension associated with the current desired total muscle tension.
        function self = desired_total_tension2desired_active_passive_tension( self )
            
            % Compute the desired active and desired passive tension associated with the current desired total tension.
            [ self.desired_active_tension, self.desired_passive_tension ] = self.total_tension2active_passive_tension( self.desired_total_tension, self.yank, self.muscle_length - self.resting_muscle_length, self.velocity, self.kse, self.kpe, self.b );
            
        end
        
        
        % Implement a function to compute the desired total and desired passive muscle tension associated with the current desired active muscle tension.
        function self = desired_active_tension2desired_total_passive_tension( self )
            
            [ self.desired_total_tension, self.desired_passive_tension ] = self.active_tension2total_passive_tension( self.measured_total_tension, self.muscle_length - self.resting_muscle_length, self.velocity, self.desired_active_tension, self.kse, self.kpe, self.b, self.network_dt, self.num_int_steps );
            
        end
        
        
        % Implement a function to compute the measured active and measured passive muscle tension associated with the current measured total muscle tension.
        function self = measured_total_tension2measured_active_passive_tension( self )
            
            % Compute the desired active and desired passive tension associated with the current desired total tension.
            [ self.measured_active_tension, self.measured_passive_tension ] = self.total_tension2active_passive_tension( self.measured_total_tension, self.yank, self.muscle_length - self.resting_muscle_length, self.velocity, self.kse, self.kpe, self.b );
            
        end
        
        
        % Implement a function to compute the measured total and measured passive muscle tension associated with the current measured active muscle tension.
        function self = measured_active_tension2measured_total_passive_tension( self )
            
            [ self.measured_total_tension, self.measured_passive_tension ] = self.active_tension2total_passive_tension( self.measured_total_tension, self.muscle_length - self.resting_muscle_length, self.velocity, self.measured_active_tension, self.kse, self.kpe, self.b, self.network_dt, self.num_int_steps );
            
        end
        
        
    end
end

