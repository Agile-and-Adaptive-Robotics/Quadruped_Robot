classdef BPA_muscle_class
    
    % This class contains properties and methods related to BPA muscles.
    
    %% BPA MUSCLE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        muscle_type
        
        desired_tension
        measured_tension
        
        desired_pressure
        measured_pressure
        max_pressure
        
        muscle_length
        resting_muscle_length
        
        tendon_length
        
        total_muscle_tendon_length
        
        muscle_strain
        max_muscle_strain
        
        velocity
        
        yank
        
        ps
        Rs
        Ms
        Ts
        Js
        
        c0
        c1
        c2
        c3
        c4
        c5
        c6
        
        physics_manager
        
    end
    
    
    %% BPA MUSCLE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = BPA_muscle_class( ID, name, desired_tension, measured_tension, desired_pressure, measured_pressure, max_pressure, muscle_length, resting_muscle_length, tendon_length, max_muscle_strain, velocity, yank, ps, Rs, Js, c0, c1, c2, c3, c4, c5, c6, muscle_type )
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Set the default class properties.
            if nargin < 23, self.muscle_type = ''; else, self.muscle_type = muscle_type; end
            if nargin < 22, self.c6 = 15.6e3; else, self.c6 = c6; end
            if nargin < 21, self.c5 = 1.23e3; else, self.c5 = c5; end
            if nargin < 20, self.c4 = -0.331e-3; else, self.c4 = c4; end
            if nargin < 19, self.c3 = -0.461; else, self.c3 = c3; end
            if nargin < 18, self.c2 = 2.0265; else, self.c2 = c2; end
            if nargin < 17, self.c1 = 192e3; else, self.c1 = c1; end
            if nargin < 16, self.c0 = 254.3e3; else, self.c0 = c0; end
            if nargin < 15, self.Js = zeros( 3, 1 ); else, self.Js = Js; end
            if nargin < 14, self.Rs = repmat( eye( 3, 3 ), [ 1, 1, 3 ] ); else, self.Rs = Rs; end
            if nargin < 13, self.ps = zeros( 3, 3 ); else, self.ps = ps; end
            if nargin < 12, self.yank = 0; else, self.yank = yank; end
            if nargin < 11, self.velocity = 0; else, self.velocity = velocity; end
            if nargin < 10, self.max_muscle_strain = 0; else, self.max_muscle_strain = max_muscle_strain; end
            if nargin < 9, self.tendon_length = 0; else, self.tendon_length = tendon_length; end
            if nargin < 8, self.resting_muscle_length = 0; else, self.resting_muscle_length = resting_muscle_length; end
            if nargin < 7, self.muscle_length = 0; else, self.muscle_length = muscle_length; end
            if nargin < 7, self.max_pressure = 620528; else, self.max_pressure = max_pressure; end
            if nargin < 6, self.measured_pressure = 0; else, self.measured_pressure = measured_pressure; end
            if nargin < 5, self.desired_pressure = 0; else, self.desired_pressure = desired_pressure; end
            if nargin < 4, self.measured_tension = 0; else, self.measured_tension = measured_tension; end
            if nargin < 3, self.desired_tension = 0; else, self.desired_tension = desired_tension; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Compute the muscle strain associated with the current muscle length.
            self = self.muscle_length2muscle_strain(  );

            % Compute the total muscle tendon length associated with the current muscle and tendon lengths.
            self = self.muscle_tendon_length2total_muscle_tendon_length(  );
            
            % Compute the BPA muscle attachment point home configurations.
            self.Ms = self.physics_manager.PR2T( self.ps, self.Rs );
            
            % Set the current BPA muscle attachment point configuration to be the home configuration.
            self.Ts = self.Ms;
        
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
        
        
        %% BPA Length & Strain Functions
        
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
        
        
        % Implement a function to compute the muscle strain associated with the current muscle length and resting muscle length.
        function self = muscle_length2muscle_strain( self )
        
            % Compute the muscle strain associated with the current muscle length and resting muscle length.
            self.muscle_strain = self.length2strain( self.muscle_length, self.resting_muscle_length );
            
        end
            
        
        % Implement a function to compute the muscle length associated with the current muscle strain.
        function self = muscle_strain2muscle_length( self )
            
           % Compute the muscle length associated with the current muscle strain.
           self.muscle_length = self.strain2length( self.muscle_strain, self.resting_muscle_length );
            
        end
        
        
        % Implement a function to compute the total muscle-tendon length associated with the current muscle and tendon lengths.
        function self = muscle_tendon_length2total_muscle_tendon_length( self )
            
            % Compute the total muscle-tendon length associated with the current muscle and tendon lengths.
            self.total_muscle_tendon_length = self.muscle_length + self.tendon_length;

        end
        
        
        % Implement a function to compute the muscle length associated with the current total muscle-tendon length and tendon length.
        function self = total_muscle_tendon_length2muscle_length( self )
            
           % Compute the muscle length associated with the current total and tendon lengths.
           self.muscle_length = self.total_muscle_tendon_length - self.tendon_length;
            
        end
        
        
        % Implement a function to compute the total muscle tendon length given the current muscle attachment point locations.
        function self = ps2total_muscle_tendon_length( self )
        
            % Compute the distance between the muscle attachment points for this muscle at this time step.
            dps = diff( self.ps, 1, 2 );

            % Compute the length of this muscle at this time step.
            self.total_muscle_tendon_length = sum( vecnorm( dps, 2, 1 ) );
        
        end
        
        
        % Implement a function to compute the muscle length given the current muscle attachment point locations.
        function self = ps2muscle_length( self )
            
           % Compute the total muscle tendon length associated with  the current muscle attachment point locations.
           self = self.ps2total_muscle_tendon_length(  );
           
           % Compute the muscle length associated with the current total muscle tendon length.
           self = self.total_muscle_tendon_length2muscle_length(  );
            
        end
        

        %% BPA Force-Pressure Functions
        
        % Implement a function to compute the desired BPA muscle pressure associated with the current desired BPA muscle tension.
        function self = desired_tension2desired_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired pressure associated with this desired tension.
            self.desired_pressure = self.inverse_BPA_model( self.desired_tension, abs(self.muscle_strain), self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the desired BPA muscle pressure from the current desired BPA muscle tension.
        function self = desired_pressure2desired_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired tension.
            self.desired_tension = self.forward_BPA_model( self.desired_pressure, self.desired_tension, abs(self.muscle_strain), self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure associated with the current measured BPA muscle tension.
        function self = measured_tension2measured_pressure( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured BPA muscle pressure associated with this measured BPA muscle tension.
            self.measured_pressure = self.inverse_BPA_model( self.measured_tension, abs(self.muscle_strain), self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure from the current measured BPA muscle tension.
        function self = measured_pressure2measured_tension( self )
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured total tension.
            self.measured_tension = self.forward_BPA_model( self.measured_pressure, self.measured_tension, abs(self.muscle_strain), self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
        
        
        
        %% Plotting Functions
        
        % Implement a function to plot the attachment points of this BPA muscle.
        function fig = plot_BPA_muscle_points( self, fig, plotting_options )
           
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { '.-b', 'Markersize', 15, 'Linewidth', 1 }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the BPA attachment points.
                fig = figure( 'Color', 'w' ); hold on, grid on, xlabel('x [m]'), ylabel('y [m]'), zlabel('z [m]'), title('BPA Muscle Attachment Points')
                
            end
            
            % Plot the BPA muscle attachment points.
            plot3( self.ps(1, :), self.ps(2, :), self.ps(3, :), plotting_options{:} )
            
        end
        
        
    end
end

