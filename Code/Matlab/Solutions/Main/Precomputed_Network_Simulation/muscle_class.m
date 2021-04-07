classdef muscle_class
    
    % This class contains properties and methods related to muscles.
    
    %% MUSCLE PROPERTIES
    
    % Define the muscle data class properties.
    properties
        ID
        name
        activation
        activation_domain
        desired_total_tension           % [N] Desired Total Muscle Tension.  The "total" muscle tension is the real muscle tension that would be observed in the muscle if measured.  This tension is relevant to both BPA muscles and real muscles.
        desired_active_tension          % [N] Desired Active Muscle Tension.  The "active" muscle tension is the tension in the muscle that is developed due to motor neuron activation.  This tension is only relevant to real muscles (not BPAs).
        desired_passive_tension         % [N] Desired Passive Muscle Tension.  The "passive" muscle tension is the tension in the muscle that is developed naturally due to the internal dynamics of the muscle.  This tension is only relevant to real muscles (not BPAs).
        measured_total_tension          % [N] Measured Total Muscle Tension.
        measured_active_tension         % [N] Measured Active Muscle Tension.  The "measured" active tension is inferred active muscle tension that would result from the measured total muscle tension.
        measured_passive_tension        % [N] Measured Passive Muscle Tension.  The "measured" passive tension is the inferred passive muscle tension that would result from the measured total muscle tension.
        tension_domain
        desired_pressure
        measured_pressure
        pressure_domain
        length
        resting_length
        length_domain
        strain
        max_strain
        velocity
        velocity_domain
        yank
        typeIa_feedback                 % [V] Velocity Feedback
        typeIb_feedback                 % [V] Tension Feedback
        typeII_feedback                 % [V] Length Feedback
        kse
        kpe
        b
        c0
        c1
        c2
        c3
        c4
        c5
        c6
        network_dt
        num_int_steps
        numerical_method_utilities
    end
    
    
    %% MUSCLE METHODS SETUP
    
    % Define the muscle class methods.
    methods
        
        % Implement the class constructor.
        function self = muscle_class( ID, name, activation, activation_domain, desired_total_tension, desired_active_tension, desired_passive_tension, measured_total_tension, measured_active_tension, measured_passive_tension, tension_domain, desired_pressure, measured_pressure, pressure_domain, length, resting_length, strain, max_strain, velocity, yank, typeIa_feedback, typeIb_feedback, typeII_feedback, kse, kpe, b, c0, c1, c2, c3, c4, c5, c6, network_dt, num_int_steps )
            
            % Define the default class properties.
            if nargin < 35, self.num_int_steps = 10; else, self.num_int_steps = num_int_steps; end
            if nargin < 34, self.network_dt = 1e-3; else, self.network_dt = network_dt; end
            if nargin < 33, self.c6 = 1; else, self.c6 = c6; end
            if nargin < 32, self.c5 = 1; else, self.c5 = c5; end
            if nargin < 31, self.c4 = 1; else, self.c4 = c4; end
            if nargin < 30, self.c3 = 1; else, self.c3 = c3; end
            if nargin < 29, self.c2 = 1; else, self.c2 = c2; end
            if nargin < 28, self.c1 = 1; else, self.c1 = c1; end
            if nargin < 27, self.c0 = 1; else, self.c0 = c0; end
            if nargin < 26, self.b = 1; else, self.b = b; end
            if nargin < 25, self.kpe = 30; else, self.kpe = kpe; end
            if nargin < 24, self.kse = 30; else, self.kse = kse; end
            if nargin < 23, self.typeII_feedback = 0; else, self.typeII_feedback = typeII_feedback; end
            if nargin < 22, self.typeIb_feedback = 0; else, self.typeIb_feedback = typeIb_feedback; end
            if nargin < 21, self.typeIa_feedback = 0; else, self.typeIa_feedback = typeIa_feedback; end
            if nargin < 20, self.yank = 0; else, self.yank = yank; end
            if nargin < 19, self.velocity = 0; else, self.velocity = velocity; end
            if nargin < 18, self.max_strain = 0; else, self.max_strain = max_strain; end
            if nargin < 17, self.strain = 0; else, self.strain = strain; end
            if nargin < 16, self.resting_length = 0; else, self.resting_length = resting_length; end
            if nargin < 15, self.length = 0; else, self.length = length; end
            if nargin < 14, self.pressure_domain = [0, 620528]; else, self.pressure_domain = pressure_domain; end
            if nargin < 13, self.measured_pressure = 0; else, self.measured_pressure = measured_pressure; end
            if nargin < 12, self.desired_pressure = 0; else, self.desired_pressure = desired_pressure; end
            if nargin < 11, self.tension_domain = [0, 450]; else, self.tension_domain = tension_domain; end
            if nargin < 10, self.measured_passive_tension = 0; else, self.measured_passive_tension = measured_passive_tension; end
            if nargin < 9, self.measured_active_tension = 0; else, self.measured_active_tension = measured_active_tension; end
            if nargin < 8, self.measured_total_tension = 0; else, self.measured_total_tension = measured_total_tension; end
            if nargin < 7, self.desired_passive_tension = 0; else, self.desired_passive_tension = desired_passive_tension; end
            if nargin < 6, self.desired_active_tension = 0; else, self.desired_active_tension = desired_active_tension; end
            if nargin < 5, self.desired_total_tension = 0; else, self.desired_total_tension = desired_total_tension; end
            if nargin < 4, self.activation_domain = [-0.050, -0.019]; else, self.activation_domain = activation_domain; end
            if nargin < 3, self.activation = 0; else, self.activation = activation; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Compute the length domain.
            self.length_domain = [ self.max_strain*self.resting_length, self.resting_length ];
            
            % Compute the maximum muscle speed.
            self.velocity_domain = ( range( self.length_domain )/self.network_dt )*[-1, 1];
            
            % Create an instance of the numerical methods utilities class.
            self.numerical_method_utilities = numerical_method_utilities_class();
            
        end
        
        
        %% HILL MUSCLE MODEL FUNCTIONS
        
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
        
        
        %% BPA FUNCTIONS
        
        % Implement a function to compute the forward BPA muscle model (epsilon, P -> F).
        function F = forward_BPA_model( ~, P, F_guess, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Define the modified inverse BPA anonymous function.
            inv_BPA_func = @(F) P - self.inverse_BPA_model( F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
            
            % Compute the total BPA tension.
            F = fzero( inv_BPA_func, F_guess );
            
        end
        
        
        % Implement a function to compute the inverse BPA muscle model (epsilon, F -> P).
        function P = inverse_BPA_model( ~, F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Compute the BPA pressure.
            P = c0 + c1*tan( c2*( epsilon/(c4*F + epsilon_max) + c3 ) ) + c5*F + c6*S;
            
        end
        
        
        % Implement a function to compute the hystersis factor.
        function S = get_hystersis_factor( self )
            
            % Determine the hytersis factor.
            if self.velocity <= 0                       % If the muscle is contracting or not moving...
                
                % Set the hystersis factor to zero.
                S = 0;
                
            else                                        % Otherwise...
                
                % Set the hystersis factor to one.
                S = 1;
                
            end
            
        end
        
        
        %% STRAIN FUNCTIONS
        
        % Implement a function to compute the muscle strain associated with the current muscle length.
        function self = length2strain( self )
            
            % Compute the current muscle strain.
            self.strain = self.length/self.resting_length;
            
        end
        
        
        % Implement a function to compute the current muscle length given the current muscle strain.
        function self = strain2length( self )
            
            % Compute the current muscle length.
            self.length = self.strain*self.resting_length;
            
        end
        
        
        %% MUSCLE ACTIVATION FUNCTIONS
        
        % Implement a function to compute the muscle tension (total or active) associated with a given muscle activation.
        function tension = activation2tension( ~, activation_domain, tension_domain, activation )
            
            % Convert the muscle activation to muscle tension (desired or active).
            tension = interp1( activation_domain, tension_domain, activation );
            
        end
        
        
        % Implement a function to compute the muscle activation associated with the a given muscle tension (total or active).
        function activation = tension2activation( ~, tension_domain, activation_domain, tension )
            
            % Convert the muscle tension (desired or active) to muscle activation.
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
        
        
        %% TOTAL, ACTIVE, AND PASSIVE MUSCLE TENSION FUNCTIONS
        
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
        
        
        % Implement a function to compute the desired active and desired passive muscle tension associated with the current desired total muscle tension.
        function self = desired_total_tension2desired_active_passive_tension( self )
            
            % Compute the desired active and desired passive tension associated with the current desired total tension.
            [ self.desired_active_tension, self.desired_passive_tension ] = self.total_tension2active_passive_tension( self.desired_total_tension, self.yank, self.length - self.resting_length, self.velocity, self.kse, self.kpe, self.b );
            
        end
        
        
        % Implement a function to compute the desired total and desired passive muscle tension associated with the current desired active muscle tension.
        function self = desired_active_tension2desired_total_passive_tension( self )
            
            [ self.desired_total_tension, self.desired_passive_tension ] = self.active_tension2total_passive_tension( self.measured_total_tension, self.length - self.resting_length, self.velocity, self.desired_active_tension, self.kse, self.kpe, self.b, self.network_dt, self.num_int_steps );
            
        end
        
        
        % Implement a function to compute the measured active and measured passive muscle tension associated with the current measured total muscle tension.
        function self = measured_total_tension2measured_active_passive_tension( self )
            
            % Compute the desired active and desired passive tension associated with the current desired total tension.
            [ self.measured_active_tension, self.measured_passive_tension ] = self.total_tension2active_passive_tension( self.measured_total_tension, self.yank, self.length - self.resting_length, self.velocity, self.kse, self.kpe, self.b );
            
        end
        
        
        % Implement a function to compute the measured total and measured passive muscle tension associated with the current measured active muscle tension.
        function self = measured_active_tension2measured_total_passive_tension( self )
            
            [ self.measured_total_tension, self.measured_passive_tension ] = self.active_tension2total_passive_tension( self.measured_total_tension, self.length - self.resting_length, self.velocity, self.measured_active_tension, self.kse, self.kpe, self.b, self.network_dt, self.num_int_steps );
            
        end
        
        
        % Implement a function to compute the desired muscle pressure associated with the current desired total muscle tension.
        function self = desired_total_tension2desired_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired pressure associated with this desired total tension.
            self.desired_pressure = self.inverse_BPA_model( self.desired_total_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the desired total muscle pressure from the current desired total muscle tension.
        function self = desired_pressure2desired_total_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired total tension.
            self.desired_total_tension = self.forward_BPA_model( self.desired_pressure, self.desired_total_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured muscle pressure associated with the current measured total muscle tension.
        function self = measured_total_tension2measured_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured pressure associated with this measured total tension.
            self.measured_pressure = self.inverse_BPA_model( self.measured_total_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured total muscle pressure from the current measured total muscle tension.
        function self = measured_pressure2measured_total_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured total tension.
            self.measured_total_tension = self.forward_BPA_model( self.measured_pressure, self.measured_total_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        %% MUSCLE FEEDBACK FUNCTIONS
        
        % Implement a function to saturate a muscle property.
        function value = saturate_value( value, domain )
            
            % Saturate the given value.
            if value < domain(1)                 % If the measured total tension is below the lower tension bound...
                
                % Set the saturated tension to be the lower tension bound.
                value = domain(1);
                
            elseif value > domain(2)                 % If the measured total tension is below the upper tension bound...
                
                % Set the saturated tension to be the upper tension bound.
                value = domain(2);
                
            end
            
        end
        
        
        % Implement a function to compute Type Ia feedback from muscle velocity.
        function self = velocity2typeIa_feedback( self )
            
            % Saturate the muscle velocity.
            saturated_velocity = self.saturate_value( self.velocity, self.velocity_domain );
            
            % Compute the Typa Ia feedback from the saturated muscle velocity.
            self.typeIa_feedback = interp1( self.velocity_domain, self.activation_domain, saturated_velocity );
            
        end
        
        
        % Implement a function to compute Type Ib feedback from the measured total tension.
        function self = measured_total_tension2typeIb_feedback( self )
            
            % Saturate the measured total tension.
            saturated_tension = self.saturate_value( self.measured_total_tension, self.tension_domain );
            
            % Compute the type Ib feedback associated with the saturated muscle tension.
            self.typeIb_feedback = interp1( self.tension_domain, self.activation_domain, saturated_tension );
            
        end
        
        
        % Implement a function to compute Type II feedback from the muscle length.
        function self = length2typeII_feedback( self )
            
            % Saturate the muscle length.
            saturated_length = self.saturate_value( self.length, self.length_domain );
            
            % Compute the typeII feedback associated with the saturated muscle length.
            self.typeII_feedback = interp1( self.length_domain, self.activation_domain, saturated_length );
            
        end
        
        
    end
    
end

