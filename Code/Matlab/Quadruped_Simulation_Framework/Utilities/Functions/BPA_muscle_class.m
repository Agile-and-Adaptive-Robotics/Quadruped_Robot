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
        min_tension
        max_tension
        
        desired_pressure
        measured_pressure
        min_pressure
        max_pressure
        
        muscle_length
        muscle_length_equilibrium
        resting_muscle_length
        
        tendon_length
        
        total_muscle_tendon_length
        
        muscle_strain
        muscle_strain_equilibrium
        min_muscle_strain
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
        
        num_convergence_attempts
        convergence_threshold
        noise_percentage
        
        num_reference_strains
        num_reference_forces
        strain_field
        force_field
        pressure_field
        
        physics_manager
        conversion_manager
        
    end
    
    
    %% BPA MUSCLE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = BPA_muscle_class( ID, name, desired_tension, measured_tension, desired_pressure, measured_pressure, max_pressure, muscle_length, resting_muscle_length, tendon_length, max_muscle_strain, velocity, yank, ps, Rs, Js, c0, c1, c2, c3, c4, c5, c6, muscle_type, num_convergence_attempts, convergence_threshold, noise_percentage, num_reference_strains, num_reference_forces )
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
            % Set the default class properties.
            if nargin < 29, self.num_reference_forces = 100; else, self.num_reference_forces = num_reference_forces; end
            if nargin < 28, self.num_reference_strains = 100; else, self.num_reference_strains = num_reference_strains; end
            if nargin < 27, self.noise_percentage = 0.03; else, self.noise_percentage = noise_percentage; end
            if nargin < 26, self.convergence_threshold = 0.05; else, self.convergence_threshold = convergence_threshold; end
            if nargin < 25, self.num_convergence_attempts = 10; else, self.num_convergence_attempts = num_convergence_attempts; end
            if nargin < 24, self.muscle_type = ''; else, self.muscle_type = muscle_type; end
            if nargin < 23, self.c6 = 15.6e3; else, self.c6 = c6; end
            if nargin < 22, self.c5 = 1.23e3; else, self.c5 = c5; end
            if nargin < 21, self.c4 = -0.331e-3; else, self.c4 = c4; end
            if nargin < 20, self.c3 = -0.461; else, self.c3 = c3; end
            if nargin < 19, self.c2 = 2.0265; else, self.c2 = c2; end
            if nargin < 18, self.c1 = 192e3; else, self.c1 = c1; end
            if nargin < 17, self.c0 = 254.3e3; else, self.c0 = c0; end
            if nargin < 16, self.Js = zeros( 3, 1 ); else, self.Js = Js; end
            if nargin < 15, self.Rs = repmat( eye( 3, 3 ), [ 1, 1, 3 ] ); else, self.Rs = Rs; end
            if nargin < 14, self.ps = zeros( 3, 3 ); else, self.ps = ps; end
            if nargin < 13, self.yank = 0; else, self.yank = yank; end
            if nargin < 12, self.velocity = 0; else, self.velocity = velocity; end
            if nargin < 11, self.max_muscle_strain = 0; else, self.max_muscle_strain = max_muscle_strain; end
            if nargin < 10, self.tendon_length = 0; else, self.tendon_length = tendon_length; end
            if nargin < 9, self.resting_muscle_length = 0; else, self.resting_muscle_length = resting_muscle_length; end
            if nargin < 8, self.muscle_length = 0; else, self.muscle_length = muscle_length; end
            if nargin < 7, self.max_pressure = 620528; else, self.max_pressure = max_pressure; end
            if nargin < 6, self.measured_pressure = 0; else, self.measured_pressure = measured_pressure; end
            if nargin < 5, self.desired_pressure = 0; else, self.desired_pressure = desired_pressure; end
            if nargin < 4, self.measured_tension = 0; else, self.measured_tension = measured_tension; end
            if nargin < 3, self.desired_tension = 0; else, self.desired_tension = desired_tension; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end
            
            % Set the minimum BPA muscle pressure and minimum BPA muscle tension to zero.
            self.min_pressure = 0;
            self.min_tension = 0;
            self.min_muscle_strain = 0;
            
            % Compute the maximum BPA muscle force.
            self = self.get_BPA_muscle_maximum_force(  );
            
            % Compute the strain, force, and pressure fields.
            self = self.get_reference_strain_force_pressure_fields(  );
            
            % Compute the muscle strain associated with the current muscle length.
            self = self.muscle_length2muscle_strain(  );

            % Compute the total muscle tendon length associated with the current muscle and tendon lengths.
            self = self.muscle_tendon_length2total_muscle_tendon_length(  );
            
            % Compute the BPA muscle equilibrium strain (Type I).
            self = self.get_BPA_muscle_strain_equilibrium(  );
            
            % Compute the BPA muscle equilibrium length.
            self = self.equilibrium_strain2equilibrium_length(  ); 
           
            % Compute the BPA muscle attachment point home configurations.
            self.Ms = self.physics_manager.PR2T( self.ps, self.Rs );
            
            % Set the current BPA muscle attachment point configuration to be the home configuration.
            self.Ts = self.Ms;
        
        end
        
        
        %% BPA Muscle Static Model Functions
        
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
        
        
        % Implement a function to compute the inverse BPA muscle model (epsilon, F -> P).
        function P = inverse_BPA_model( ~, F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Compute the BPA pressure.
            P = c0 + c1*tan( c2*( epsilon/(c4*F + epsilon_max) + c3 ) ) + c5*F + c6*S;
            
        end
        
        
        % Implement a function to compute the forward BPA muscle model (epsilon, P -> F).
        function F = forward_BPA_model( self, P, F_guess, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Define the modified inverse BPA anonymous function.
            inv_BPA_func = @(F) P - self.inverse_BPA_model( F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
            
            % Compute the total BPA tension.
            F = fzero( inv_BPA_func, F_guess );
            
        end
        
        
        % Implement a function to compute the BPA muscle strain (Type I) associated with the BPA muscle pressure and BPA muscle force.
        function epsilon = strain_BPA_model( ~, P, F, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
        
            % Compute the BPA muscle strain (Type I) associated with the BPA muscle pressure and BPA muscle force.
            epsilon = ( c4*F + epsilon_max )*( (1/c2)*atan( (1/c1)*( P - c0 - c5*F - c6*S ) ) - c3 );
            
        end
        
        
        % Implement a function to compute the BPA muscle equilibrium strain (Type I) associated with the BPA muscle pressure.
        function epsilon_equilibrium = strain_equilibrium_BPA_model( self, P, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
        
            % Set the BPA muscle force to zero.
            F = 0;
            
            % Compute the BPA muscle equilibrium strain (Type I).
            epsilon_equilibrium = self.strain_BPA_model( P, F, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
            
        end
        
        
        %% BPA Muscle Field Functions
        
        % Implement a function to generate the pressure field associated with a strain field and force field.
        function Ps = compute_pressure_field( self, Epsilons, Fs )
           
            % Set the hystersis factors.
            Ss = [ 0, 1 ];
            
            % Retrieve the field size.
            num_forces = size( Fs, 1 );
            num_epsilons = size( Epsilons, 2 );
            num_hystersis_factors = length( Ss );
            
            % Initialize a variable to store the pressure field.
            Ps = zeros( num_forces, num_epsilons, num_hystersis_factors );
            
            % Compute the pressure at each point in the field.
            for k1 = 1:num_forces                               % Iterate through each force...
                for k2 = 1:num_epsilons                         % Iterate through each strain...
                    for k3 = 1:num_hystersis_factors            % Iterate through each hystersis factor...
                    
                        % Compute the pressure associated with this force, strain, and hystersis factor.
                        Ps( k1, k2, k3 ) = self.inverse_BPA_model( Fs( k1, k2, k3 ), Epsilons( k1, k2, k3 ), self.max_muscle_strain, Ss( k3 ), self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
                    end
                end
            end
            
        end
        
        
        % Implement a function to generate the strain field associated with a pressure and force field.
        function Epsilons = compute_strain_field( self, Ps, Fs )
        
            % Set the hystersis factors.
            Ss = [ 0, 1 ];
            
            % Retrieve the field size.
            num_forces = size( Fs, 1 );
            num_pressures = size( Ps, 2 );
            num_hystersis_factors = length( Ss );
            
            % Initialize a variable to store the strain field.
            Epsilons = zeros( num_forces, num_pressures, num_hystersis_factors );

            % Compute the pressure at each point in the field.
            for k3 = 1:num_hystersis_factors            % Iterate through each hystersis factor...
                for k2 = 1:num_pressures                         % Iterate through each strain...
                    
                    % Set a flag variable that indicates whether we have reached an invalid force.
                    bInvalidForce = false;
                    
                    % Initialize a counter variable for the upcoming loop.
                    k1 = 1;
                    
                    while ~bInvalidForce && ( k1 <= num_forces )
                                                
                        % Compute the strain associated with this pressure and force.
                        epsilon = self.strain_BPA_model( Ps( k1, k2, k3 ), Fs( k1, k2, k3 ), self.max_muscle_strain, Ss( k3 ), self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
                        
                        % Determine how to set the strain.
                        if epsilon < 0                      % If the estimated strain is negative...
                            
                            % Set the rest of the strains in this column to zero.
                            Epsilons( k1:end, k2, k3 ) = zeros( [ length( k1:size( Epsilons, 1 ) ), 1, 1 ] );

                            % Set the invalid force flag to true.
                            bInvalidForce = true;
                            
                        else                                % Otherwise...
                            
                            % Store this strain value.
                            Epsilons( k1, k2, k3 ) = epsilon;
                            
                            % Advance the counter.
                            k1 = k1 + 1;
                            
                        end
                        
                    end
                end
            end

        end
        
        
        % Implement a function to define the reference strain field.
        function self = get_reference_strain_force_pressure_fields( self )
            
            % Define the strain vector.
            pressures = linspace( self.min_pressure, self.max_pressure, 100 );
            
            % Define the force vector.
            forces = linspace( self.min_tension, self.max_tension, self.num_reference_forces );
            
            % Define the strain and force grids.
            [ Pressures, Forces ] = meshgrid( pressures, forces );
            
            % Extend the pressure and force grids in the 3rd dimension to account for the two possible hystersis factors.
            self.pressure_field = cat( 3, Pressures, Pressures );
            self.force_field = cat( 3, Forces, Forces );
            
            % Compute the strain field.
            self.strain_field = self.compute_strain_field( self.pressure_field, self.force_field );
            
        end
        
        
        %% BPA Muscle Saturation Functions
        
        % Implement a function to saturate a given pressure.
        function pressure = saturate_pressure( self, pressure, bVerbose )
            
            % Set the default input arguments.
            if nargin < 3, bVerbose = false; end
            
            % Determine how to saturate the pressure.
            if pressure < self.min_pressure                            % If the pressure is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('Pressure %0.0f [psi] is below the minimum pressure of %0.0f [psi].  Setting pressure to %0.0f [psi].', self.conversion_manager.pa2psi( pressure ), self.conversion_manager.pa2psi( self.min_pressure ), self.conversion_manager.pa2psi( self.min_pressure ) ); end
                
                % Set the pressure to be zero.
               pressure = self.min_pressure;
                
            elseif pressure > self.max_pressure        % If the pressure is greater than the maximum pressure...
               
                % Determine whether to throw a warning.
               if bVerbose, warning('Pressure %0.0f [psi] is above the maximum pressure of %0.0f [psi].  Setting pressure to %0.0f [psi].', self.conversion_manager.pa2psi( pressure ), self.conversion_manager.pa2psi( self.max_pressure ), self.conversion_manager.pa2psi( self.max_pressure ) ); end
                
                % Set the pressure to be the maximum pressure.
                pressure = self.max_pressure;
                
            end
            
        end
        
        
        % Implement a function to saturate a given force.
        function force = saturate_force( self, force, bVerbose )
            
            % Set the default input arguments.
            if nargin < 3, bVerbose = false; end
            
            % Determine how to saturate the force.
            if force < self.min_tension                            % If the force is less than the minimum force...
                
                % Determine whether to throw a warning.
                if bVerbose, warning('Force %0.0f [lb] is below the minimum force of %0.0f [lb].  Setting force to %0.0f [lb].', self.conversion_manager.n2lb( force ), self.conversion_manager.n2lb( self.min_tension ), self.conversion_manager.n2lb( self.min_tension ) ); end
                
                % Set the force to be the minimum force.
                force = self.min_tension;
                
            elseif force > self.max_tension        % If the force is greater than the maximum force...
                
                % Determine whether to throw a warning.
                if bVerbose, warning('Force %0.0f [lb] is above the maximum force of %0.0f [lb].  Setting force to %0.0f [lb].', self.conversion_manager.n2lb( force ), self.conversion_manager.n2lb( self.max_tension ), self.conversion_manager.n2lb( self.max_tension ) ); end
                
                % Set the force to be the maximum force.
                force = self.max_tension;
                
            end
            
        end
        
        
        % Implement a function to saturate a given strain.
        function strain = saturate_strain( self, strain, bVerbose )
            
            % Set the default input arguments.
            if nargin < 3, bVerbose = false; end
            
            % Determine how to saturate the strain.
            if strain < self.min_muscle_strain                            % If the strain is less than the minimum strain...
                
                % Determine whether to throw a warning.
                if bVerbose, warning('Strain %0.0f [-] is below the minimum strain of %0.0f [-].  Setting strain to %0.0f [-].', strain, self.min_muscle_strain, self.min_muscle_strain ); end
                
                % Set the force to be the minimum force.
                strain = self.min_muscle_strain;
                
            elseif strain > self.max_muscle_strain        % If the force is greater than the maximum strain...
                
                % Determine whether to throw a warning.
                if bVerbose, warning('Strain %0.0f [-] is above the maximum strain of %0.0f [-].  Setting strain to %0.0f [-].', strain, self.max_muscle_strain, self.max_muscle_strain ); end
                
                % Set the force to be the maximum force.
                strain = self.max_muscle_strain;
                
            end
            
        end
        
        
        % Implement a function to saturate the BPA muscle desired pressure.
        function self = saturate_BPA_muscle_desired_pressure( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to saturate the desired pressure.
            if self.desired_pressure < 0                            % If the desired pressure is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('Desired pressure %0.0f [psi] is below the minimum pressure of %0.0f [psi].  Setting desired pressure to %0.0f [psi].', self.conversion_manager.pa2psi( self.desired_pressure ), self.conversion_manager.pa2psi( self.min_pressure ), self.conversion_manager.pa2psi( self.min_pressure ) ); end
                
                % Set the desired pressure to be zero.
               self.desired_pressure = 0;
                
            elseif self.desired_pressure > self.max_pressure        % If the desired pressure is greater than the maximum pressure...
               
                % Determine whether to throw a warning.
               if bVerbose, warning('Desired pressure %0.0f [psi] is above the maximum pressure of %0.0f [psi].  Setting desired pressure to %0.0f [psi].', self.conversion_manager.pa2psi( self.desired_pressure ), self.conversion_manager.pa2psi( self.max_pressure ), self.conversion_manager.pa2psi( self.max_pressure ) ); end
                
                % Set the desired pressure to be the maximum pressure.
                self.desired_pressure = self.max_pressure;
                
            end
            
        end
        
        
        % Implement a function to saturate the BPA muscle measured pressure.
        function self = saturate_BPA_muscle_measured_pressure( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to saturate the desired pressure.
            if self.measured_pressure < 0                            % If the measured pressure is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('Measured pressure %0.0f [psi] is below the minimum pressure of %0.0f [psi].  Setting measured pressure to %0.0f [psi].', self.conversion_manager.pa2psi( self.measured_pressure ), self.conversion_manager.pa2psi( self.min_pressure ), self.conversion_manager.pa2psi( self.min_pressure ) ); end
                
                % Set the measured pressure to be zero.
               self.measured_pressure = 0;
                
            elseif self.measured_pressure > self.max_pressure        % If the measured pressure is greater than the maximum pressure...
                
                % Determine whether to throw a warning.
                if bVerbose, warning('Measured pressure %0.0f [psi] is above the maximum pressure of %0.0f [psi].  Setting measured pressure to %0.0f [psi].', self.conversion_manager.pa2psi( self.measured_pressure ), self.conversion_manager.pa2psi( self.max_pressure ), self.conversion_manager.pa2psi( self.max_pressure ) ); end
                
                % Set the measured pressure to be the maximum pressure.
                self.measured_pressure = self.max_pressure;
                
            end
            
        end
        
        
        % Implement a function to saturate the BPA muscle desired tension.
        function self = saturate_BPA_muscle_desired_tension( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to saturate the desired tension.
            if self.desired_tension < 0                            % If the desired tension is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('Desired tension %0.0f [lbf] is below the minimum tension of %0.0f [lbf].  Setting desired tension to %0.0f [lbf].', self.conversion_manager.n2lb( self.desired_tension ), self.conversion_manager.n2lb( self.min_tension ), self.conversion_manager.n2lb( self.min_tension ) ); end
                
                % Set the desired tension to be zero.
               self.desired_tension = 0;
                
            elseif self.desired_tension > self.max_tension        % If the desired tension is greater than the maximum tension...
               
                % Determine whether to throw a warning.
               if bVerbose, warning('Desired tension %0.0f [lbf] is above the maximum tension of %0.0f [lbf].  Setting desired tension to %0.0f [lbf].', self.conversion_manager.n2lb( self.desired_tension ), self.conversion_manager.n2lb( self.max_tension ), self.conversion_manager.n2lb( self.max_tension ) ); end
                
                % Set the desired tension to be the maximum tension.
                self.desired_tension = self.max_tension;
                
            end
            
        end
        
        
        % Implement a function to saturate the BPA muscle measured tension.
        function self = saturate_BPA_muscle_measured_tension( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to saturate the measured tension.
            if self.measured_tension < 0                            % If the measured tension is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('Measured tension %0.0f [lbf] is below the minimum tension of %0.0f [lbf].  Setting measured tension to %0.0f [lbf].', self.conversion_manager.n2lb( self.measured_tension ), self.conversion_manager.n2lb( self.min_tension ), self.conversion_manager.n2lb( self.min_tension ) ); end
                
                % Set the measured tension to be zero.
               self.measured_tension = 0;
                
            elseif self.measured_tension > self.max_tension        % If the measured tension is greater than the maximum tension...
               
                % Determine whether to throw a warning.
               if bVerbose, warning('Measured tension %0.0f [psi] is above the maximum tension of %0.0f [lbf].  Setting measured tension to %0.0f [lbf].', self.conversion_manager.n2lb( self.measured_tension ), self.conversion_manager.n2lb( self.max_tension ), self.conversion_manager.n2lb( self.max_tension ) ); end
                
                % Set the measured tension to be the maximum tension.
                self.measured_tension = self.max_tension;
                
            end
            
        end
        
        
        % Implement a function to saturte the BPA muscle strain (Type I).
        function self = saturate_BPA_muscle_strain( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to saturate the measured tension.
            if self.muscle_strain < 0                            % If the muscle strain is less than zero...
                
               % Determine whether to throw a warning.
               if bVerbose, warning('BPA muscle strain %0.0f [-] is below the minimum BPA muscle strain of %0.0f [-].  Setting BPA muscle strain to %0.0f [-].', self.muscle_strain, 0, self.muscle_strain ); end
                
                % Set the BPA muscle strain to zero.
               self.muscle_strain = 0;
                
            elseif self.muscle_strain > self.max_muscle_strain        % If the muscle strain is greater than the maximum muscle strain...
               
                % Determine whether to throw a warning.
               if bVerbose, warning('BPA muscle strain %0.0f [-] is above the maximum BPA muscle strain of %0.0f [-].  Setting BPA muscle strain to %0.0f [-].', self.muscle_strain, self.max_muscle_strain, self.muscle_strain ); end
                
                % Set the BPA muscle strain to be the maximum muscle strain.
                self.muscle_strain = self.max_muscle_strain;
                
            end
            
        end
        
        
        %% BPA Muscle Validation Functions
        
        % Implement a function to validate the hystersis factor.
        function S = validate_hystersis_factor( ~, S )
           
            % Determine whether this is a valid hystersis factor.
            if ~( ( S == 0 ) || ( S == 1 ) )                         % If the hystersis factor is invalid...
                
                % Throw a warning.
                warning('Invalid hystersis factor %0.0f detected.  Hytersis factor must be either 0 or 1. Setting hystersis factor to 0', S)
                
                % Set the hystersis factor to zero.
                S = 0;
                
            end
            
        end
        
        
        % Implement a function to validate a pressure and strain combination.
        function [ strain, bValidStrain ] = validate_pressure_strain( self, pressure, strain, S, bVerbose )
            
            % Define the default input arguments.
            if nargin < 5, bVerbose = false; end
            
           % Compute the equilibrium strain.
            strain_equilibrium = self.strain_equilibrium_BPA_model( pressure, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
            % Determine whether this strain is valid.
            if strain <= strain_equilibrium                  % If the strain is less than the strain equilibrium...
                
                % Set the valid strain flag to be true.
                bValidStrain = true;
                
            else                                            % Otherwise...
              
                % Throw a warning.
                if bVerbose, warning( 'Strain %0.2f [-] is greater than the equilibrium strain of %0.2f [-] at pressure %0.2f [psi].', strain, strain_equilibrium, self.conversion_manager.pa2psi( pressure ) ), end
                
                % Set the strain to be the strain equilibrium.
                strain = strain_equilibrium;
                
                % Set the valid strain flag to be false.
                bValidStrain = false;
                
            end
            
        end
        
        
        %% BPA Muscle Length & Strain Functions
        
        % Implement a function to compute the BPA muscle equilibrium strain (Type I) associated with the current BPA muscle pressure.
        function self = get_BPA_muscle_strain_equilibrium( self )
            
            % Get the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Set the BPA muscle equilibrium strain (Type I).
            self.muscle_strain_equilibrium = self.strain_equilibrium_BPA_model( self.measured_pressure, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
        end
        
            
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
        function self = total_muscle_tendon_length2muscle_length( self, bVerbose )
            
            % Set the default input argument.
            if nargin < 2, bVerbose = false; end
            
            % Infer the BPA muscle length from the total BPA muscle-tendon length and the BPA tendon length.
            inferred_muscle_length = self.total_muscle_tendon_length - self.tendon_length;
            
            % Determine how to set the muscle length.
            if inferred_muscle_length < self.muscle_length_equilibrium           % If the inferred muscle length is less than the muscle length equilibrium...
                                
                % Set the muscle length to be the muscle length equilibrium.
                self.muscle_length = self.muscle_length_equilibrium;
                
                % Determine whether to throw a warning.
                if bVerbose, warning( 'BPA muscle length %0.0 [in] inferred from the current robot geometry is less than the BPA muscle equilibrium length %0.0f [in] at the current BPA muscle measured pressure %0.0f [psi].  Setting BPA muscle length to %0.0f [in].', 39.3701*inferred_muscle_length, 39.3701*self.muscle_length_equilibrium, 0.000145038*self.measured_pressure, 39.3701*self.muscle_length_equilibrium ), end
                
            else                                                                 % Otherwise...
                
                % Set the muscle length to be the muscle length inferred by the geometry.
                self.muscle_length = inferred_muscle_length;
                
            end
            
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
        

        % Implement a function to compute the BPA muscle equilibrium length associated with the BPA muscle equilibrium strain.
        function self = equilibrium_strain2equilibrium_length( self )
            
            % Compute the BPA muscle equilibrium length associated with the BPA muscle equilibrium strain.
            self.muscle_length_equilibrium = self.strain2length( self.muscle_strain_equilibrium, self.resting_muscle_length );
            
        end
        
        
        % Implement a function to compute the BPA muscle equilibrium strain associated with the BPA muscle equilibrium length.
        function self = equilibrium_length2equilibrium_strain( self )
            
            % Compute the BPA muscle equilibrium strain associated with the BPA muscle equilibrium length.
            self.muscle_strain_equilibrium = self.length2strain( self.muscle_length_equilibrium, self.resting_muscle_length );
            
        end
        
        
        %% Interpolation Functions
        
        % Implement a function to interpolate a pressure from the BPA muscle's strain, force, and pressure fields.
        function pressure = interpolate_pressure( self, strain, force, S )
                      
            % Saturate the strain.
            strain = self.saturate_strain( strain );
            
            % Saturate the force.
            force = self.saturate_force( force );

            % Validate the hystersis factor.
            S = self.validate_hystersis_factor( S );
            
            % Interpolate a pressure value from the reference strain, force, and pressure fields.
            pressure = griddata( self.strain_field( :, :, S + 1 ), self.force_field( :, :, S + 1 ), self.pressure_field( :, :, S + 1 ), strain, force );
            
        end
        
        
        % Implement a function to interpolate a strain from the BPA muscle's strain, force, and pressure fields.
        function strain = interpolate_strain( self, pressure, force, S )
            
            % Saturate the pressure.
            pressure = self.saturate_pressure( pressure );
            
            % Saturate the force.
            force = self.saturate_force( force );            
            
            % Validate the hystersis factor.
            S = self.validate_hystersis_factor( S );
            
           % Interpolate a strain value from the reference strain, force, and pressure fields.
           strain = griddata( self.pressure_field( :, :, S + 1 ), self.force_field( :, :, S + 1 ), self.strain_field( :, :, S + 1 ), pressure, force );
            
        end
        
        
        % Implement a function to interpolate a force from the BPA muscle's strain, force, and pressure fields.
        function force = interpolate_force( self, pressure, strain, S )
                     
            % Saturate the pressure.
            pressure = self.saturate_pressure( pressure );
            
            % Saturate the strain.
            strain = self.saturate_strain( strain );
            
            % Validate this pressure and strain combination.
            [ strain, bValidStrain ] = self.validate_pressure_strain( pressure, strain, S );
            
            % Validate the hystersis factor.
            S = self.validate_hystersis_factor( S );
            
            % Determine how to interpolate the force.
            if ( ~bValidStrain ) || ( strain == self.max_muscle_strain )                    % If the strain is at a maximum...
            
                % Set the force to zero.
                force = 0;
                
            else                                            % Otherwise...
                
                % Interpolate a force value from the reference strain, force, and pressure fields.
                force = griddata( self.pressure_field( :, :, S + 1 ), self.strain_field( :, :, S + 1 ), self.force_field( :, :, S + 1 ), pressure, strain );
            
            end
            
        end
        
        
        %% BPA Force-Pressure Functions
        
        % Implement a function to compute the BPA muscle maximum force.
        function max_force = compute_BPA_muscle_maximum_force( ~, Pmax, S, c0, c1, c2, c3, c5, c6 )
            
            % Compute the maximum BPA muscle maximum force.
            max_force = (1/c5)*( Pmax - c0 - c1*tan( c2*c3 ) - c6*S );
            
        end
        
        
        % Implemenent a function to set the BPA muscle maximum force.
        function self = get_BPA_muscle_maximum_force( self )
            
            % The maximum BPA muscle force occurs when the BPA muscle strain (Type I) is minimized (i.e., zero) and the BPA muscle pressure is maximized (i.e., Pmax).    
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the maximum BPA muscle force.
            self.max_tension = self.compute_BPA_muscle_maximum_force( self.max_pressure, S, self.c0, self.c1, self.c2, self.c3, self.c5, self.c6 );
        
        end
        
        
        % Implement a function to compute the desired BPA muscle pressure associated with the current desired BPA muscle tension.
        function self = desired_tension2desired_pressure( self )
            
            % Saturate the BPA muscle desired tension.
            self = self.saturate_BPA_muscle_desired_tension(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the desired pressure associated with this desired tension.
            self.desired_pressure = self.inverse_BPA_model( self.desired_tension, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );

            % Saturate the BPA muscle desired pressure.
            self = self.saturate_BPA_muscle_desired_pressure(  );
            
        end
        
        
        % Implement a function to compute the desired BPA muscle pressure from the current desired BPA muscle tension.
        function self = desired_pressure2desired_tension( self )
            
            % Saturate the BPA muscle desired pressure.
            self = self.saturate_BPA_muscle_desired_pressure(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Initialize a flag variable that detects convergence.
            bConvergenceDetected = false;
            
            % Compute the initial the BPA muscle desired tension guess for the forward BPA model numerical method (we are storing this in a separate variable because we don't want to override it in case we need it later).
            F_guess0 = self.interpolate_force( self.desired_pressure, self.muscle_strain, S );
            
            % Initialize the BPA muscle desired tension guess for the forward BPA model numerical method.
            F_guess = F_guess0;
            
            % Initialize a loop counter variable.
            k = 1;
            
            % Compute the BPA muscle desired tension via numerical method until a convergent result is achieved.
            while ~bConvergenceDetected && ( k <= self.num_convergence_attempts )                                   % While we have not found a convergent result and we have not yet attempted to find one the specified number of times...
                
                fprintf('F_guess = %0.16f [N]', F_guess)
                
                % Compute the BPA muscle desired tension associated with this guess.
                F = self.forward_BPA_model( self.desired_pressure, F_guess, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
                
                % Compute the percent change in the BPA muscle desired tension result relative to the guess.
                percent_change = abs( (F - F_guess)/F_guess );
                
                % Determine whether the BPA muscle desired tension has converged.
                if ( self.min_tension <= F ) && ( self.max_tension >= F ) && ( percent_change <= self.convergence_threshold )                % If the BPA muscle desired tension result is within bounds and "nearby" the guess...
                
                    % Set the BPA muscle desired tension to be the numerical method result.
                    self.desired_tension = F;
                    
                    % Set the convergence flag to true.
                    bConvergenceDetected = true;
                
                else                                                                                                                    % Otherwise...
                    
                    % Update the BPA muscle desired tension guess by adding a small amount of noise.
                    F_guess = F_guess + normrnd( 0, self.noise_percentage*self.max_tension );
                    
                end
                    
                % Advance the counter variable.
                k = k + 1;
                
            end
            
            % Determine whether we still need to set the BPA muscle desired tension.
            if ~bConvergenceDetected                                                    % If convergence was not achieved...
                
                % Throw a warning.
                warning('Forward BPA muscle model (E = %0.2f [-], P = %0.2f [psi] -> F) did not converge after %0.0f attempts. Setting desired tension to interpolated value F = %0.2f [lb].', self.muscle_strain, self.conversion_manager.pa2psi( self.desired_pressure ), self.num_convergence_attempts, self.conversion_manager.n2lb( self.desired_tension ) )
                
                % Set the BPA muscle desired tension to be the original guess.
                self.desired_tension = F_guess0;
                
            end

            % Saturate the BPA muscle desired tension.
            self = self.saturate_BPA_muscle_desired_tension(  );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure associated with the current measured BPA muscle tension.
        function self = measured_tension2measured_pressure( self )
            
            % Saturate the BPA muscle measured tension.
            self = self.saturate_BPA_muscle_measured_tension(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Compute the measured BPA muscle pressure associated with this measured BPA muscle tension.
            self.measured_pressure = self.inverse_BPA_model( self.measured_tension, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );

            % Saturate the BPA muscle measured pressure.
            self = self.saturate_BPA_muscle_measured_pressure(  );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure from the current measured BPA muscle tension.
        function self = measured_pressure2measured_tension( self )
            
            % Saturate the BPA muscle measured pressure.
            self = self.saturate_BPA_muscle_measured_pressure(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hystersis factor.
            S = self.get_hystersis_factor(  );
            
            % Initialize a flag variable that detects convergence.
            bConvergenceDetected = false;
            
            % Compute the initial the BPA muscle measured tension guess for the forward BPA model numerical method (we are storing this in a separate variable because we don't want to override it in case we need it later).
            F_guess0 = self.interpolate_force( self.measured_pressure, self.muscle_strain, S );
            
            % Initialize the BPA muscle measured tension guess for the forward BPA model numerical method.
            F_guess = F_guess0;
            
            % Compute the BPA muscle measured tension via numerical method until a convergent result is achieved.
            while ~bConvergenceDetected && ( k <= self.num_convergence_attempts )                                   % While we have not found a convergent result and we have not yet attempted to find one the specified number of times...
                
                % Compute the BPA muscle measured tension associated with this guess.
                F = self.forward_BPA_model( self.measured_pressure, F_guess, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
                
                % Compute the percent change in the BPA muscle measured tension result relative to the guess.
                percent_change = (F - F_guess)/F_guess;
                
                % Determine whether the BPA muscle measured tension has converged.
                if ( self.min_tension <= F ) && ( self.max_tension >= F ) && ( percent_change <= self.convergence_threshold )                % If the BPA muscle measured tension result is within bounds and "nearby" the guess...
                
                    % Set the BPA muscle measured tension to be the numerical method result.
                    self.measured_tension = F;
                    
                    % Set the convergence flag to true.
                    bConvergenceDetected = true;
                
                else                                                                                                                    % Otherwise...
                    
                    % Update the BPA muscle measured tension guess by adding a small amount of noise.
                    F_guess = F_guess + normrnd( 0, self.noise_percentage*self.max_tension );
                    
                end
                    
            end
            
            % Determine whether we still need to set the BPA muscle measured tension.
            if ~bConvergenceDetected                                                    % If convergence was not achieved...
                
                % Set the BPA muscle measured tension to be the original guess.
                self.measured_tension = F_guess0;
                
            end

            % Saturate the BPA muscle measured tension.
            self = self.saturate_BPA_muscle_measured_tension(  );
            
        end
        
        
        
        
        %% Plotting Functions
        
        % Implement a function to plot the attachment points of this BPA muscle.
        function fig = plot_BPA_muscle_points( self, fig, plotting_options )
           
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { '.-b', 'Markersize', 15, 'Linewidth', 1 }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the BPA attachment points.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle Attachment Points' ); hold on, grid on, xlabel('x [in]'), ylabel('y [in]'), zlabel('z [in]'), title('BPA Muscle Attachment Points')
                
            end
            
            % Plot the BPA muscle attachment points.
            plot3( self.conversion_manager.m2in( self.ps( 1, : ) ), self.conversion_manager.m2in( self.ps( 2, : ) ), self.conversion_manager.m2in( self.ps( 3, : ) ), plotting_options{:} )
            
        end
        
        
%         % Implement a function to plot the BPA muscle strain, force, and pressure fields.
%         function fig = plot_BPA_muscle_strain_force_pressure_field( self, fig, plotting_options )
%             
%             % Determine whether to specify default plotting options.
%             if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
%             
%             % Determine whether we want to add these attachment points to an existing plot or create a new plot.
%             if ( nargin < 2 ) || ( isempty(fig) )
%                 
%                 % Create a figure to store the BPA attachment points.
%                 fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Pressure vs Strain & Force (Reference Fields)' );
%                 
%                 % Create the first subplot.
%                 subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
%                 xlabel('Strain (Type I) [-]'), ylabel('Force [lb]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Strain & Force (Ref. Fields) (S = 0)')
%                 xlim( [ self.min_muscle_strain, self.max_muscle_strain ] ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )
%                 
%                 subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
%                 xlabel('Strain (Type I) [-]'), ylabel('Force [lb]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Strain & Force (Ref. Fields) (S = 1)')
%                 xlim( [ self.min_muscle_strain, self.max_muscle_strain ] ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )
%                 
%             end
%             
%             % Plot the strain, force, and pressure fields.
%             subplot( 1, 2, 1 ), surf( self.strain_field( :, :, 1 ), self.conversion_manager.n2lb( self.force_field( :, :, 1 ) ), self.conversion_manager.pa2psi( self.pressure_field( :, :, 1 ) ), plotting_options{:} )
%             subplot( 1, 2, 2 ), surf( self.strain_field( :, :, 2 ), self.conversion_manager.n2lb( self.force_field( :, :, 2 ) ), self.conversion_manager.pa2psi( self.pressure_field( :, :, 2 ) ), plotting_options{:} )
% 
%         end
        

        % Implement a function to plot the BPA muscle strain, force, and pressure fields.
        function fig = plot_BPA_muscle_strain_force_pressure_field( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )
                
                % Create a figure to store the BPA attachment points.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Strain vs Pressure & Force (Reference Fields)' );
                
                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Ref. Fields) (S = 0)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )
                
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Ref. Fields) (S = 1)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )
                
            end
            
            % Plot the strain, force, and pressure fields.
            subplot( 1, 2, 1 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 1 ) ), self.conversion_manager.n2lb( self.force_field( :, :, 1 ) ), self.strain_field( :, :, 1 ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 2 ) ), self.conversion_manager.n2lb( self.force_field( :, :, 2 ) ), self.strain_field( :, :, 2 ), plotting_options{:} )

        end


        
    end
end

