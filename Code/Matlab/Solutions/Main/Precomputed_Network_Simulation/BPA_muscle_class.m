classdef BPA_muscle_class
    
    % This class contains properties and methods related to BPA muscles.
    
    %% BPA MUSCLE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        
        desired_tension
        measured_tension
        
        desired_pressure
        measured_pressure
        max_pressure
        
        length
        resting_length
        strain
        max_strain
        
        velocity
        
        yank
        
        c0
        c1
        c2
        c3
        c4
        c5
        c6
        
    end
    
    
    %% BPA MUSCLE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = BPA_muscle_class( ID, name, desired_tension, measured_tension, desired_pressure, measured_pressure, max_pressure, muscle_length, resting_length, max_strain, velocity, yank, c0, c1, c2, c3, c4, c5, c6 )
            
            % Set the default class properties.
            if nargin < 18, self.c6 = 15.6e3; else, self.c6 = c6; end
            if nargin < 17, self.c5 = 1.23e3; else, self.c5 = c5; end
            if nargin < 16, self.c4 = -0.331e-3; else, self.c4 = c4; end
            if nargin < 15, self.c3 = -0.461; else, self.c3 = c3; end
            if nargin < 14, self.c2 = 2.0265; else, self.c2 = c2; end
            if nargin < 13, self.c1 = 192e3; else, self.c1 = c1; end
            if nargin < 12, self.c0 = 254.3e3; else, self.c0 = c0; end
            if nargin < 11, self.yank = 0; else, self.yank = yank; end
            if nargin < 10, self.velocity = 0; else, self.velocity = velocity; end
            if nargin < 9, self.max_strain = 0; else, self.max_strain = max_strain; end
            if nargin < 8, self.resting_length = 0; else, self.resting_length = resting_length; end
            if nargin < 7, self.length = 0; else, self.length = muscle_length; end
            if nargin < 7, self.max_pressure = 620528; else, self.max_pressure = max_pressure; end
            if nargin < 6, self.measured_pressure = 0; else, self.measured_pressure = measured_pressure; end
            if nargin < 5, self.desired_pressure = 0; else, self.desired_pressure = desired_pressure; end
            if nargin < 4, self.measured_tension = 0; else, self.measured_tension = measured_tension; end
            if nargin < 3, self.desired_tension = 0; else, self.desired_tension = desired_tension; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Compute the muscle strain.
            self.strain = self.length2strain( self.length, self.resting_length );
            
        end
        
        
        %% BPA Static Model Functions
        
        % Implement a function to compute the forward BPA muscle model (epsilon, P -> F).
        function F = forward_BPA_model( self, P, F_guess, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
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
        
        
        %% BPA Length-Strain Functions
        
        % Implement a function to compute the muscle strain associated with a given muscle length and resting length.
        function strain = length2strain( ~, muscle_length, resting_length )
            
            % Compute the current muscle strain.
            strain = 1 - muscle_length/resting_length;
            
        end
        
        
        % Implement a function to compute the current muscle length given the current muscle strain.
        function muscle_length = strain2length( ~, strain, resting_length )
            
            % Compute the current muscle length.
            muscle_length = resting_length*(1 - strain);
            
        end
        
        
        %% BPA Force-Pressure Functions
        
        % Implement a function to compute the desired BPA muscle pressure associated with the current desired BPA muscle tension.
        function self = desired_tension2desired_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired pressure associated with this desired tension.
            self.desired_pressure = self.inverse_BPA_model( self.desired_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the desired BPA muscle pressure from the current desired BPA muscle tension.
        function self = desired_pressure2desired_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired tension.
            self.desired_tension = self.forward_BPA_model( self.desired_pressure, self.desired_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure associated with the current measured BPA muscle tension.
        function self = measured_tension2measured_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured BPA muscle pressure associated with this measured BPA muscle tension.
            self.measured_pressure = self.inverse_BPA_model( self.measured_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure from the current measured BPA muscle tension.
        function self = measured_pressure2measured_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured total tension.
            self.measured_tension = self.forward_BPA_model( self.measured_pressure, self.measured_tension, abs(self.strain), self.max_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
    end
end

