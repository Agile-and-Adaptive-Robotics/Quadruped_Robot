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
        
        num_reference_pressures
        num_reference_forces
        num_reference_strains
        
        strain_field
        force_field
        pressure_field
        
        strain_interpolant_S0
        strain_interpolant_S1

        force_interpolant_S0
        force_interpolant_S1
        
        pressure_interpolant_S0
        pressure_interpolant_S1
        
        negative_strain_policy
        
        data_validation_policy
        
        physics_manager
        conversion_manager
        
    end
    
    
    %% BPA MUSCLE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = BPA_muscle_class( ID, name, desired_tension, measured_tension, desired_pressure, measured_pressure, max_pressure, muscle_length, resting_muscle_length, tendon_length, max_muscle_strain, velocity, yank, ps, Rs, Js, c0, c1, c2, c3, c4, c5, c6, muscle_type, num_convergence_attempts, convergence_threshold, noise_percentage, num_reference_pressures, num_reference_forces, num_reference_strains, negative_strain_policy, data_validation_policy )
            
            % Create an instance of the physics manager class.
            self.physics_manager = physics_manager_class(  );
            
            % Create an instance of the conversion manager class.
            self.conversion_manager = conversion_manager_class(  );
            
            % Set the default class properties.
            if nargin < 31, self.data_validation_policy = 'error'; else, self.data_validation_policy = data_validation_policy; end
            if nargin < 31, self.negative_strain_policy = 'Nan'; else, self.negative_strain_policy = negative_strain_policy; end
            if nargin < 30, self.num_reference_strains = 100; else, self.num_reference_strains = num_reference_strains; end
            if nargin < 29, self.num_reference_forces = 100; else, self.num_reference_forces = num_reference_forces; end
            if nargin < 28, self.num_reference_pressures = 100; else, self.num_reference_pressures = num_reference_pressures; end
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
            
            % Compute the maximum BPA muscle force.
            self = self.get_BPA_muscle_maximum_force(  );
            
            % Compute the strain, force, and pressure fields.
            self = self.get_reference_strain_force_pressure_fields(  );
                        
            % Set the minimum BPA muscle strain 
            self.min_muscle_strain = min(self.strain_field, [], 'all');

            % Compute the BPA muscle equilibrium strain (Type I).
            self = self.measured_pressure2equilibrium_strain(  );
            
            % Compute the BPA muscle equilibrium length.
            self = self.equilibrium_strain2equilibrium_length(  ); 
            
            % Compute the muscle strain associated with the current muscle length.
            self = self.muscle_length2muscle_strain(  );

            % Compute the total muscle tendon length associated with the current muscle and tendon lengths.
            self = self.muscle_tendon_length2total_muscle_tendon_length(  );
            
            % Compute the BPA muscle attachment point home configurations.
            self.Ms = self.physics_manager.PR2T( self.ps, self.Rs );
            
            % Set the current BPA muscle attachment point configuration to be the home configuration.
            self.Ts = self.Ms;
        
        end
        
        
        %% BPA Muscle Static Model Functions
        
        % Implement a function to compute the hysteresis factor.
        function S = get_hysteresis_factor( self )
            
            % Determine the hytersis factor.
            if self.velocity <= 0                       % If the muscle is contracting or not moving...
                
                % Set the hysteresis factor to zero.
                S = 0;
                
            else                                        % Otherwise...
                
                % Set the hysteresis factor to one.
                S = 1;
                
            end
            
        end
        
        
        % Implement a function to compute the inverse BPA muscle model (epsilon, F -> P).
        function P = inverse_BPA_model( ~, F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Compute the BPA pressure.
            P = c0 + c1*tan( c2*( epsilon/(c4*F + epsilon_max) + c3 ) ) + c5*F + c6*S;
            
        end
        
        
        % Implement a function to compute the forward BPA muscle model (epsilon, P -> F) (simple numerical method that requires a guess).
        function F = forward_BPA_model_with_guess( self, P, F_guess, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Define the modified inverse BPA anonymous function.
            inv_BPA_func = @(F) P - self.inverse_BPA_model( F, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
            
            % Compute the total BPA tension.
            F = fzero( inv_BPA_func, F_guess );
            
        end
        
        
        % Implement a function to compute the forward BPA muscle model (epsilon, P -> F).
        function F = forward_BPA_model( self, P, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 )
            
            % Initialize a flag variable that detects convergence.
            bConvergenceDetected = false;
            
            % Compute the initial BPA muscle tension guess for the forward BPA model numerical method (we are storing this in a separate variable because we don't want to override it in case we need it later).
            F_guess0 = self.interpolate_force( P, epsilon, S );
            
            % Initialize the BPA muscle tension guess for the forward BPA model numerical method.
            F_guess = F_guess0;
            
            % Initialize a loop counter variable.
            k = 1;
            
            % Compute the BPA muscle tension via numerical method until a convergent result is achieved.
            while ~bConvergenceDetected && ( k <= self.num_convergence_attempts )                                   % While we have not found a convergent result and we have not yet attempted to find one the specified number of times...
                
                % Compute the BPA muscle tension associated with this guess.
                F = self.forward_BPA_model_with_guess( P, F_guess, epsilon, epsilon_max, S, c0, c1, c2, c3, c4, c5, c6 );
                
                % Compute the percent change in the BPA muscle tension result relative to the guess.
                percent_change = (F - F_guess)/F_guess;
                
                % Determine whether the BPA muscle tension has converged.
                if ( self.min_tension <= F ) && ( self.max_tension >= F ) && ( percent_change <= self.convergence_threshold )                % If the BPA muscle measured tension result is within bounds and "nearby" the guess...
                    
                    % Set the convergence flag to true.
                    bConvergenceDetected = true;
                
                else                                                                                                                    % Otherwise...
                    
                    % Update the BPA muscle tension guess by adding a 'small' amount of noise.
                    F_guess = F_guess + normrnd( 0, self.noise_percentage*self.max_tension );
                    
                end
                   
                % Advance the counter variable.
                k = k + 1;
                
            end
            
            % Determine whether we still need to set the BPA muscle tension.
            if ~bConvergenceDetected                                                    % If convergence was not achieved...
                
                % Set the BPA muscle tension to be the original guess.
                F = F_guess0;
                
            end            
            
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
           
            % Set the hysteresis factors.
            Ss = [ 0, 1 ];
            
            % Retrieve the field size.
            num_forces = size( Fs, 1 );
            num_epsilons = size( Epsilons, 2 );
            num_hysteresis_factors = length( Ss );
            
            % Initialize a variable to store the pressure field.
            Ps = zeros( num_forces, num_epsilons, num_hysteresis_factors );
            
            % Compute the pressure at each point in the field.
            for k1 = 1:num_forces                               % Iterate through each force...
                for k2 = 1:num_epsilons                         % Iterate through each strain...
                    for k3 = 1:num_hysteresis_factors            % Iterate through each hysteresis factor...
                    
                        % Compute the pressure associated with this force, strain, and hysteresis factor.
                        Ps( k1, k2, k3 ) = self.inverse_BPA_model( Fs( k1, k2, k3 ), Epsilons( k1, k2, k3 ), self.max_muscle_strain, Ss( k3 ), self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
                    end
                end
            end
            
        end
        
        
        % Implement a function to generate the strain field associated with a pressure and force field.
        function Epsilons = compute_strain_field( self, Ps, Fs )
            
            % Set the hysteresis factors.
            Ss = [ 0, 1 ];
            
            % Retrieve the field size.
            num_forces = size( Fs, 1 );
            num_pressures = size( Ps, 2 );
            num_hysteresis_factors = length( Ss );
            
            % Initialize a variable to store the strain field.
            Epsilons = zeros( num_forces, num_pressures, num_hysteresis_factors );

            % Compute the pressure at each point in the field.
            for k3 = 1:num_hysteresis_factors            % Iterate through each hysteresis factor...
                for k2 = 1:num_pressures                         % Iterate through each strain...
                    
                    % Set a flag variable that indicates whether we have reached an invalid force.
                    bInvalidForce = false;
                    
                    % Initialize a counter variable for the upcoming loop.
                    k1 = 1;
                    
                    % Determine whether to compute strains at these force values.
                    while ~bInvalidForce && ( k1 <= num_forces )                    % If we have a valid force and we haven't exhausted this set of forces...
                                                
                        % Compute the strain associated with this pressure and force.
                        epsilon = self.strain_BPA_model( Ps( k1, k2, k3 ), Fs( k1, k2, k3 ), self.max_muscle_strain, Ss( k3 ), self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
                        
                        % Determine how to set the strain.
                        if epsilon < 0                      % If the estimated strain is negative...
                            
                            % Determine how to handle this negative strain value based on the negative strain policy.
                            if strcmp( self.negative_strain_policy, 'Keep' ) || strcmp( self.negative_strain_policy, 'keep' )               % If we want to keep the negative strain values...
                                
                                % Store this strain value.
                                Epsilons( k1, k2, k3 ) = epsilon;

                                % Advance the counter.
                                k1 = k1 + 1;
                                
                            elseif strcmp( self.negative_strain_policy, 'Zero' ) || strcmp( self.negative_strain_policy, 'zero' )           % If we want to zero out the negative strain values...
                                
                                % Set the rest of the strains in this column to zero.
                                Epsilons( k1:end, k2, k3 ) = zeros( [ length( k1:size( Epsilons, 1 ) ), 1, 1 ] );

                                % Set the invalid force flag to true.
                                bInvalidForce = true;
                                
                            elseif strcmp( self.negative_strain_policy, 'Nan' ) || strcmp( self.negative_strain_policy, 'nan' )             % If we want to set the negative strain values to nan.
                               
                                % Set the rest of the strains in this column to nan.
                                Epsilons( k1:end, k2, k3 ) = nan( [ length( k1:size( Epsilons, 1 ) ), 1, 1 ] );

                                % Set the invalid force flag to true.
                                bInvalidForce = true;
                                
                            else                                                                                                                % Otherwise...
                                
                                % Throw an error.
                                error( 'Unrecognized negative_strain_policy %s.  negative_strain_policy must be either: ''Keep'', ''Zero'', or ''Nan''', self.negative_strain_policy )
                                
                            end
                            
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
            pressures = linspace( self.min_pressure, self.max_pressure, self.num_reference_forces );
            
            % Define the force vector.
            forces = linspace( self.min_tension, self.max_tension, self.num_reference_forces );
            
            % Define the strain and force grids.
            [ Pressures, Forces ] = meshgrid( pressures, forces );
            
            % Extend the pressure and force grids in the 3rd dimension to account for the two possible hysteresis factors.
            self.pressure_field = cat( 3, Pressures, Pressures );
            self.force_field = cat( 3, Forces, Forces );
            
            % Compute the strain field.
            self.strain_field = self.compute_strain_field( self.pressure_field, self.force_field );
            
            % Retrieve the strain fields.
            strain_field_S0 = self.strain_field( :, :, 1 );
            strain_field_S1 = self.strain_field( :, :, 2 );

            % Create the strain interpolant.
            self.strain_interpolant_S0 = scatteredInterpolant( Pressures( ~isnan( strain_field_S0 ) ), Forces( ~isnan( strain_field_S0 ) ), strain_field_S0( ~isnan( strain_field_S0 ) ), 'linear', 'nearest' );     
            self.strain_interpolant_S1 = scatteredInterpolant( Pressures( ~isnan( strain_field_S1 ) ), Forces( ~isnan( strain_field_S1 ) ), strain_field_S1( ~isnan( strain_field_S1 ) ), 'linear', 'nearest' );     

            % Create the force interpolant.
            self.force_interpolant_S0 = scatteredInterpolant( Pressures( ~isnan( strain_field_S0 ) ), strain_field_S0( ~isnan( strain_field_S0 ) ), Forces( ~isnan( strain_field_S0 ) ), 'linear', 'nearest' );     
            self.force_interpolant_S1 = scatteredInterpolant( Pressures( ~isnan( strain_field_S1 ) ), strain_field_S1( ~isnan( strain_field_S1 ) ), Forces( ~isnan( strain_field_S1 ) ), 'linear', 'nearest' );     

            % Turn a warning off.
            warning( 'off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId' )
            
            % Create the pressure interpolant.
            self.pressure_interpolant_S0 = scatteredInterpolant( Forces( ~isnan( strain_field_S0 ) ), strain_field_S0( ~isnan( strain_field_S0 ) ), Pressures( ~isnan( strain_field_S0 ) ), 'linear', 'nearest' );     
            self.pressure_interpolant_S1 = scatteredInterpolant( Forces( ~isnan( strain_field_S1 ) ), strain_field_S1( ~isnan( strain_field_S1 ) ), Pressures( ~isnan( strain_field_S1 ) ), 'linear', 'nearest' );     
            
            % Turn a warning on.
            warning( 'on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId' )
            
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
        function strain = saturate_muscle_strain( self, strain, bVerbose )
            
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
            
            % Saturate the desired pressure.
            self.desired_pressure = self.saturate_pressure( self.desired_pressure, bVerbose );
            
        end
        
        
        % Implement a function to saturate the BPA muscle measured pressure.
        function self = saturate_BPA_muscle_measured_pressure( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Saturate the measured pressure.
            self.measured_pressure = self.saturate_pressure( self.measured_pressure, bVerbose );
            
        end
        
        
        % Implement a function to saturate the BPA muscle desired tension.
        function self = saturate_BPA_muscle_desired_tension( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Saturate the desired tension.
            self.desired_tension = self.saturate_force( self.desired_tension, bVerbose );
            
        end
        
        
        % Implement a function to saturate the BPA muscle measured tension.
        function self = saturate_BPA_muscle_measured_tension( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Saturate the measured tension.
            self.measured_tension = self.saturate_force( self.measured_tension, bVerbose );
            
        end
        
        
        % Implement a function to saturate the BPA muscle strain (Type I).
        function self = saturate_BPA_muscle_strain( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Saturate the muscle strain.
            self.muscle_strain = self.saturate_muscle_strain( self.muscle_strain, bVerbose );
            
        end
        
        
        % Implement a function to saturate the BPA muscle length.
        function self = saturate_BPA_muscle_length( self, bVerbose )
            
            % Set the default input arguments.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to set the muscle length.
            if self.muscle_length < self.muscle_length_equilibrium           % If the muscle length is less than the muscle length equilibrium...
                           
                % Determine whether to throw a warning.
                if bVerbose, warning( 'BPA muscle length %0.2f [in] is less than the BPA muscle equilibrium length %0.2f [in] at the current BPA muscle measured pressure %0.2f [psi].  Setting BPA muscle length to %0.2f [in].', self.conversion_manager.m2in( self.muscle_length ), self.conversion_manager.m2in( self.muscle_length_equilibrium ), self.conversion_manager.pa2psi( self.measured_pressure ), self.conversion_manager.m2in( self.muscle_length_equilibrium ) ), end
            
                % Set the muscle length to be the muscle length equilibrium.
                self.muscle_length = self.muscle_length_equilibrium;
                
            elseif self.muscle_length > self.resting_muscle_length          % If the muscle length is greater than the muscle equilibrium length...
                
                % Determine whether to throw a warning.
                if bVerbose, warning( 'BPA muscle length %0.2f [in] is greater than the BPA muscle resting length %0.2f [in].  Setting BPA muscle length to %0.2f [in].', self.conversion_manager.m2in( self.muscle_length ), self.conversion_manager.m2in( self.resting_muscle_length ), self.conversion_manager.m2in( self.resting_muscle_length ) ), end
            
                % Set the muscle length to be the resting muscle length.
                self.muscle_length = self.resting_muscle_length;
                
            end

        end
        
        
        %% BPA Muscle Error Check Functions
        
        % Implement a function to error check the BPA muscle pressure.
        function error_check_pressure( self, pressure )
        
            % Validate the given pressure.
            if ( pressure < self.min_pressure ) || ( pressure > self.max_pressure )                 % Ensure that the given pressure is in bounds...
            
                % Throw an error.
                error( 'Pressure %0.2f [psi] is out of bounds.  Pressure must be in the domain [%0.2f, %0.2f] [psi].', self.conversion_manager.pa2psi( pressure ), self.conversion_manager.pa2psi( self.min_pressure ), self.conversion_manager.pa2psi( self.max_pressure ) )
                
            end
                
        end
        
        
        % Implement a function to error check the BPA muscle tension.
        function error_check_force( self, force )
        
            % Validate the given force.
            if ( force < self.min_tension ) || ( force > self.max_tension )                 % Ensure that the given force is in bounds...
            
                % Throw an error.
                error( 'Force %0.2f [lb] is out of bounds.  Force must be in the domain [%0.2f, %0.2f] [lb].', self.conversion_manager.n2lb( force ), self.conversion_manager.n2lb( self.min_force ), self.conversion_manager.n2lb( self.max_force ) )
                
            end
                
        end
        
        
        % Implement a function to error check the BPA muscle strain.
        function error_check_muscle_strain( self, muscle_strain )
        
            % Validate the given muscle strain.
            if ( muscle_strain < self.min_muscle_strain ) || ( muscle_strain > self.max_muscle_strain )                 % Ensure that the given muscle strain is in bounds...
            
                % Throw an error.
                error( 'Muscle strain %0.2f [-] is out of bounds.  Muscle strain must be in the domain [%0.2f, %0.2f] [-].', muscle_strain, self.min_muscle_strain, self.max_muscle_strain )
                
            end
                
        end
        
        
        % Implement a function to error check a BPA muscle length.
        function error_check_muscle_length( self, muscle_length )
            
           % Determine whether the current muscle length is within the acceptable bounds.
           if ( muscle_length < self.muscle_length_equilibrium ) || ( muscle_length > self.resting_muscle_length )                % If the muscle length is less than the muscle equilibrium length or greater than the muscle resting length...
            
               % Throw an error.
               error( 'Muscle length %0.2f [in] out of bounds.  Muscle length must be greater than or equal to the current muscle equilibrium length %0.2f [in] (i.e., the no load, pressurized length) and less than or equal to the resting muscle length %0.2f [in].', self.conversion_manager.m2in( muscle_length ), self.conversion_manager.m2in( self.muscle_length_equilibrium ), self.conversion_manager.m2in( self.resting_muscle_length ) )
                
           end
               
        end
        
        
        
        
        
        %% BPA Muscle Validation Functions
        
        % Implement a function to validate the hysteresis factor.
        function S = validate_hysteresis_factor( ~, S )
           
            % Determine whether this is a valid hysteresis factor.
            if ~( ( S == 0 ) || ( S == 1 ) )                         % If the hysteresis factor is invalid...
                
                % Throw a warning.
                warning('Invalid hysteresis factor %0.0f detected.  Hytersis factor must be either 0 or 1. Setting hysteresis factor to 0', S)
                
                % Set the hysteresis factor to zero.
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
        
        
        % Implement a function to validate the plot type selection.
        function validate_plot_type( ~, plot_type )
           
            % Ensure that the plot type is valid.
            if ~( strcmp( plot_type, 'Strain') || strcmp( plot_type, 'strain') || strcmp( plot_type, 'Force') || strcmp( plot_type, 'force') || strcmp( plot_type, 'Pressure') || strcmp( plot_type, 'pressure') || strcmp( plot_type, 'All') || strcmp( plot_type, 'all') )
            
                % Throw an error.
                error( 'plot_type %s unrecognized.  plot_type must be either: ''Strain'', ''strain'', ''Force'', ''force'', ''Pressure'', ''pressure'', ''All'', or ''all''', plot_type )
                
            end
            
        end
        
        
        % Implement a function to validate the figure selection.
        function validate_figure_selection( ~, figs, plot_type )
            
            % Ensure that the figures and plot types match.
            if isempty(plot_type) || ( ~isempty(figs) && ( ( ( strcmpi( plot_type, 'strain' ) || strcmpi( plot_type, 'force' ) || strcmpi( plot_type, 'pressure' ) ) && length(figs) ~= 1 ) || ( strcmpi( plot_type, 'all' ) && length(figs) ~= 3 ) ) )  
                
                % Throw an error.
                error('plot_type %s and figs %0.0f are not compatible.  plot_type must be non-empty.  If figs is of length one, then plot_type must be either: ''strain'', ''force'', or ''pressure''.  If figs is of length 3, then plot type must be ''all''. ', plot_type, figs)
                
            end
            
            
        end
        
        
        % Implement a function to validate the BPA muscle pressure.
        function pressure = validate_pressure( self, pressure, bVerbose )
        
            % Set the default verbosity.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to validate the pressure.
            if strcmpi( self.data_validation_policy, 'error' )                      % If the data validation policy is set to 'error'...
                
                % Error check the pressure.
                self.error_check_pressure( pressure )
                
            elseif strcmpi( self.data_validation_policy, 'saturate' )               % If the data validation policy is set to 'saturate'...
                
                % Saturate the pressure.
                pressure = self.saturate_pressure( pressure, bVerbose );
                
            elseif strcmpi( self.data_validation_policy, 'none' )                   % If the data validation policy is set to 'none'...
                
                % Do nothing.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'data_validation_policy %s not recognized.  data_validation_policy must be either: ''error'', ''saturate'', or ''none''.', self.data_validation_policy )
                
            end
                
        end
        
        
        % Implement a function to validate the BPA muscle tension.
        function force = validate_force( self, force, bVerbose )
        
            % Set the default verbosity.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to validate the force.
            if strcmpi( self.data_validation_policy, 'error' )                      % If the data validation policy is set to 'error'...
                
                % Error check the force.
                self.error_check_force( force )
                
            elseif strcmpi( self.data_validation_policy, 'saturate' )               % If the data validation policy is set to 'saturate'...
                
                % Saturate the force.
                force = self.saturate_force( force, bVerbose );
                
            elseif strcmpi( self.data_validation_policy, 'none' )                   % If the data validation policy is set to 'none'...
                
                % Do nothing.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'data_validation_policy %s not recognized.  data_validation_policy must be either: ''error'', ''saturate'', or ''none''.', self.data_validation_policy )
                
            end
                
        end
        
        
        % Implement a function to validate the BPA muscle strain.
        function muscle_strain = validate_muscle_strain( self, muscle_strain, bVerbose )
        
            % Set the default verbosity.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to validate the muscle strain.
            if strcmpi( self.data_validation_policy, 'error' )                      % If the data validation policy is set to 'error'...
                
                % Error check the muscle strain.
                self.error_check_muscle_strain( muscle_strain )
                
            elseif strcmpi( self.data_validation_policy, 'saturate' )               % If the data validation policy is set to 'saturate'...
                
                % Saturate the muscle strain.
                muscle_strain = self.saturate_muscle_strain( muscle_strain, bVerbose );
                
            elseif strcmpi( self.data_validation_policy, 'none' )                   % If the data validation policy is set to 'none'...
                
                % Do nothing.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'data_validation_policy %s not recognized.  data_validation_policy must be either: ''error'', ''saturate'', or ''none''.', self.data_validation_policy )
                
            end
            
        end
        
        
        % Implement a function to validate a BPA muscle length.
        function muscle_length = validate_muscle_length( self, muscle_length, bVerbose )

            % Set the default verbosity.
            if nargin < 2, bVerbose = false; end
            
            % Determine how to validate the muscle length.
            if strcmpi( self.data_validation_policy, 'error' )                      % If the data validation policy is set to 'error'...
                
                % Error check the muscle length.
                self.error_check_muscle_length( muscle_length )
                
            elseif strcmpi( self.data_validation_policy, 'saturate' )               % If the data validation policy is set to 'saturate'...
                
                % Saturate the muscle length.
                muscle_length = self.saturate_muscle_length( muscle_length, bVerbose );
                
            elseif strcmpi( self.data_validation_policy, 'none' )                   % If the data validation policy is set to 'none'...
                
                % Do nothing.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'data_validation_policy %s not recognized.  data_validation_policy must be either: ''error'', ''saturate'', or ''none''.', self.data_validation_policy )
                
            end
               
        end
        
        
        %% BPA Muscle Length & Strain Functions
        
        % Implement a function to compute the BPA muscle equilibrium strain (Type I) associated with the current measured BPA muscle pressure.
        function self = measured_pressure2equilibrium_strain( self )

            % Get the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
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
        
            % Validate muscle length.
            self.muscle_length = self.validate_muscle_length( self.muscle_length );
            
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

            % Infer the BPA muscle length from the total BPA muscle-tendon length and the BPA tendon length.
            inferred_muscle_length = self.total_muscle_tendon_length - self.tendon_length;

            % Validate the inferred muscle length.
            self.muscle_length = self.validate_muscle_length( inferred_muscle_length );

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
        function pressure = interpolate_pressure( self, force, strain, S )
                      
            % Saturate the force.
            force = self.saturate_force( force );
            
            % Saturate the strain.
            strain = self.saturate_muscle_strain( strain );

            % Validate the hysteresis factor.
            S = self.validate_hysteresis_factor( S );
            
            % Determine how to compute the pressure.
            if S == 0                                   % If the hysteresis factor is 0...

                % Compute the pressure.
                pressure = self.pressure_interpolant_S0( force, strain );

            elseif S == 1                               % If the hysteresis factor is 1...

                % Compute the pressure.
                pressure = self.pressure_interpolant_S1( force, strain );

            else                                        % Otherwise...

                % Throw an error.
                error( 'Hysteresis factor %0.0f invald.  Hysteresis factor must be either 0 or 1.', S )

            end
            
        end

        
        % Implement a function to interpolate a strain from the BPA muscle's strain, force, and pressure fields.
        function strain = interpolate_strain( self, pressure, force, S )
            
            % Saturate the pressure.
            pressure = self.saturate_pressure( pressure );
            
            % Saturate the force.
            force = self.saturate_force( force );            
            
            % Validate the hysteresis factor.
            S = self.validate_hysteresis_factor( S );
            
            % Determine how to compute the strain.
            if S == 0                                   % If the hysteresis factor is 0...

                % Compute the strain.
                strain = self.strain_interpolant_S0( pressure, force );

            elseif S == 1                               % If the hysteresis factor is 1...

                % Compute the strain.
                strain = self.strain_interpolant_S1( pressure, force );

            else                                        % Otherwise...

                % Throw an error.
                error( 'Hysteresis factor %0.0f invald.  Hysteresis factor must be either 0 or 1.', S )

            end
                        
        end


        % Implement a function to interpolate a force from the BPA muscle's strain, force, and pressure fields.
        function force = interpolate_force( self, pressure, strain, S )
                     
            % Saturate the pressure.
            pressure = self.saturate_pressure( pressure );
            
            % Saturate the strain.
            strain = self.saturate_muscle_strain( strain );
            
            % Validate this pressure and strain combination.
            [ strain, bValidStrain ] = self.validate_pressure_strain( pressure, strain, S );
            
            % Validate the hysteresis factor.
            S = self.validate_hysteresis_factor( S );
            
            % Determine how to interpolate the force.
            if ( ~bValidStrain ) || ( strain == self.max_muscle_strain )                    % If the strain is at a maximum...
            
                % Set the force to zero.
                force = 0;
                
            else                                            % Otherwise...
                
                % Determine how to compute the force.
                if S == 0                                   % If the hysteresis factor is 0...
                
                    % Compute the force.
                    force = self.force_interpolant_S0( pressure, strain );
                
                elseif S == 1                               % If the hysteresis factor is 1...
                    
                    % Compute the force.
                    force = self.force_interpolant_S1( pressure, strain );
                    
                else                                        % Otherwise...
                   
                    % Throw an error.
                    error( 'Hysteresis factor %0.0f invald.  Hysteresis factor must be either 0 or 1.', S )
                    
                end
                    
            end
            
        end


        
        %% BPA Force-Pressure Functions
        
        % Implement a function to compute the BPA muscle maximum force.
        function max_tension = compute_BPA_muscle_maximum_force( ~, Pmax, S, c0, c1, c2, c3, c5, c6 )
            
            % Compute the maximum BPA muscle maximum force.
            max_tension = (1/c5)*( Pmax - c0 - c1*tan( c2*c3 ) - c6*S );
            
        end
        
        
        % Implemenent a function to set the BPA muscle maximum force.
        function self = get_BPA_muscle_maximum_force( self )
            
            % The maximum BPA muscle force occurs when the BPA muscle strain (Type I) is minimized (i.e., zero) and the BPA muscle pressure is maximized (i.e., Pmax).    
            
            % Compute the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
            % Compute the maximum BPA muscle force.
            self.max_tension = self.compute_BPA_muscle_maximum_force( self.max_pressure, S, self.c0, self.c1, self.c2, self.c3, self.c5, self.c6 );
        
        end
        
        
        % Implement a function to compute the desired BPA muscle pressure associated with the current desired BPA muscle tension.
        function self = desired_tension2desired_pressure( self )
            
            % Saturate the BPA muscle desired tension.
            self = self.saturate_BPA_muscle_desired_tension(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
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
            
            % Compute the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
            % Compute the BPA muscle desired tension.
            self.desired_tension = self.forward_BPA_model( self.desired_pressure, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
            % Saturate the BPA muscle desired tension.
            self = self.saturate_BPA_muscle_desired_tension(  );
            
        end
        
        
        % Implement a function to compute the measured BPA muscle pressure associated with the current measured BPA muscle tension.
        function self = measured_tension2measured_pressure( self )
            
            % Saturate the BPA muscle measured tension.
            self = self.saturate_BPA_muscle_measured_tension(  );
            
            % Saturate the BPA muscle strain (Type I).
            self = self.saturate_BPA_muscle_strain(  );
            
            % Compute the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
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
            
            % Compute the hysteresis factor.
            S = self.get_hysteresis_factor(  );
            
            % Compute the BPA muscle measured tension.
            self.measured_tension = self.forward_BPA_model( self.measured_pressure, self.muscle_strain, self.max_muscle_strain, S, self.c0, self.c1, self.c2, self.c3, self.c4, self.c5, self.c6 );
            
            % Saturate the BPA muscle desired tension.
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
        

        % Implement a function to plot the BPA muscle strain reference field.
        function fig = plot_BPA_muscle_reference_strain_field( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
        
            % Determine whether we need to create a new figure.
            if ( nargin < 2 ) || ( isempty(fig) )                                  % If we need to create a new figure...
            
                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Strain vs Pressure & Force (Reference)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Reference) (S = 0)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Reference) (S = 1)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )
               
            end
            
            % Plot the BPA muscle strain vs pressure and force reference field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 1 ) ), self.conversion_manager.n2lb( self.force_field( :, :, 1 ) ), self.strain_field( :, :, 1 ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 2 ) ), self.conversion_manager.n2lb( self.force_field( :, :, 2 ) ), self.strain_field( :, :, 2 ), plotting_options{:} )

        end
        
            
        % Implement a function to plot the BPA muscle force reference field.
        function fig = plot_BPA_muscle_reference_force_field( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
        
            % Determine whether we need to create a new figure.
            if ( nargin < 2 ) || ( isempty(fig) )                                  % If we need to create a new figure...
            
                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Force vs Pressure & Strain (Reference Fields)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Strain (Type I) [-]'), zlabel('Force [lb]'), title('BPA Muscle: Force vs Pressure & Strain (Ref. Fields) (S = 0)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Strain (Type I) [-]'), zlabel('Force [lb]'), title('BPA Muscle: Force vs Pressure & Strain (Ref. Fields) (S = 1)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) )
                    
            end
            
            % Plot the BPA muscle force vs pressure and strain reference field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 1 ) ), self.strain_field( :, :, 1 ), self.conversion_manager.n2lb( self.force_field( :, :, 1 ) ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.pa2psi( self.pressure_field( :, :, 2 ) ), self.strain_field( :, :, 2 ), self.conversion_manager.n2lb( self.force_field( :, :, 2 ) ), plotting_options{:} )

        end
        
        
        % Implement a function to plot the BPA muscle pressure reference field.
        function fig = plot_BPA_muscle_reference_pressure_field( self, fig, plotting_options )
            
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
        
            % Determine whether we need to create a new figure.
            if ( nargin < 2 ) || ( isempty(fig) )                                  % If we need to create a new figure...
            
                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Pressure vs Force & Strain (Reference Fields)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Force [lb]'), ylabel('Strain (Type I) [-]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Force & Strain (Ref. Fields) (S = 0)')
                xlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Force [lb]'), ylabel('Strain (Type I) [-]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Force & Strain (Ref. Fields) (S = 1)')
                xlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )
                        
            end
            
            % Plot the BPA muscle pressure vs force and strain reference field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.n2lb( self.force_field( :, :, 1 ) ), self.strain_field( :, :, 1 ), self.conversion_manager.pa2psi( self.pressure_field( :, :, 1 ) ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.n2lb( self.force_field( :, :, 2 ) ), self.strain_field( :, :, 2 ), self.conversion_manager.pa2psi( self.pressure_field( :, :, 2 ) ), plotting_options{:} )

        end
        
        
        % Implement a function to plot the BPA muscle strain, force, and pressure interpolant.
        function figs_output = plot_BPA_muscle_reference_field( self, figs, plotting_options, plot_type )
        
            if ( ( nargin < 4 ) || ( isempty(plot_type) ) ), plot_type = 'all'; end
        
            % Ensure that the plot type is valid.
            self.validate_plot_type( plot_type );
                
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether to specify an empty figure.
            if ( nargin < 2 ) || ( isempty(figs) ), figs = []; end

            % Validate the figure selection.
            self.validate_figure_selection( figs, plot_type );
            
            % Determine which reference fields to plot.
            if strcmp( plot_type, 'strain' )                               % If we want to plot the strain reference field...
            
                % Plot the BPA muscle strain reference field.
                figs_output = self.plot_BPA_muscle_reference_strain_field( figs, plotting_options );
                
            elseif strcmp( plot_type, 'force' )                            % If we want to plot the force reference field...
                
                % Plot the BPA muscle force reference field.
                figs_output = self.plot_BPA_muscle_reference_force_field( figs, plotting_options );
                
            elseif strcmp( plot_type, 'pressure' )                         % If we want to plot the pressure reference field...
                   
                % Plot the BPA muscle pressure reference field.
                figs_output = self.plot_BPA_muscle_reference_pressure_field( figs, plotting_options );
                
            elseif strcmp( plot_type, 'all' )                      % If we want to plot all of the reference fields...
                
                % Initialize an array of graphics objects.
                figs_output = gobjects(3);
                
                % Plot the BPA muscle strain interpolant.
                figs_output(1) = self.plot_BPA_muscle_reference_strain_field( figs, plotting_options );
          
                % Plot the BPA muscle force interpolant.
                figs_output(2) = self.plot_BPA_muscle_reference_force_field( figs, plotting_options );
                
                % Plot the BPA muscle pressure interpolant.
                figs_output(3) = self.plot_BPA_muscle_reference_pressure_field( figs, plotting_options );
                
            else                                                % Otherwise...
                
                % Ensure that the plot type is valid.
                self.validate_plot_type( plot_type );
                
            end
            
        end
        
        
        % Implement a function to plot the BPA muscle strain interpolant.
        function fig = plot_BPA_muscle_strain_interpolant( self, fig, plotting_options )
           
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )

                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Strain vs Pressure & Force (Interpolant)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Interpolant) (S = 0)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Force [lb]'), zlabel('Strain (Type I) [-]'), title('BPA Muscle: Strain vs Pressure & Force (Interpolant) (S = 1)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), zlim( [ self.min_muscle_strain, self.max_muscle_strain ] )
               
            end
                
            % Create the pressure interpolation points.
            pressures = linspace( self.min_pressure, self.max_pressure, 2*self.num_reference_pressures );

            % Create the force interpolation points.
            forces = linspace( self.min_tension, self.max_tension, 2*self.num_reference_forces );

            % Create the interpolation meshes.
            [ Ps, Fs ] = meshgrid( pressures, forces );

            % Compute the associated strains.
            Ss_S0 = self.strain_interpolant_S0( Ps, Fs );
            Ss_S1 = self.strain_interpolant_S1( Ps, Fs );

            % Plot the strain vs pressure & force field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.pa2psi( Ps ), self.conversion_manager.n2lb( Fs ), Ss_S0, plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.pa2psi( Ps ), self.conversion_manager.n2lb( Fs ), Ss_S1, plotting_options{:} )
            
        end
        
        
        % Implement a function to plot the BPA muscle force interpolant.
        function fig = plot_BPA_muscle_force_interpolant( self, fig, plotting_options )
           
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )

                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Force vs Pressure & Strain (Interpolant)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Strain (Type I) [-]'), zlabel('Force [lb]'), title('BPA Muscle: Force vs Pressure & Strain (Interpolant) (S = 0)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Pressure [psi]'), ylabel('Strain (Type I) [-]'), zlabel('Force [lb]'), title('BPA Muscle: Force vs Pressure & Strain (Interpolant) (S = 1)')
                xlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) )
                
            end
                
            % Create the pressure interpolation points.
            pressures = linspace( self.min_pressure, self.max_pressure, 2*self.num_reference_pressures );

            % Create the strain interpolation points.
            strains = linspace( self.min_muscle_strain, self.max_muscle_strain, 2*self.num_reference_strains );

            % Create the interpolation meshes.
            [ Ps, Ss ] = meshgrid( pressures, strains );

            % Compute the associated forces.
            Fs_S0 = self.force_interpolant_S0( Ps, Ss );
            Fs_S1 = self.force_interpolant_S1( Ps, Ss );

            % Plot the force vs pressure & strain field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.pa2psi( Ps ), Ss, self.conversion_manager.n2lb( Fs_S0 ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.pa2psi( Ps ), Ss, self.conversion_manager.n2lb( Fs_S1 ), plotting_options{:} )
            
        end
    
        
        % Implement a function to plot the BPA muscle pressure interpolant.
        function fig = plot_BPA_muscle_pressure_interpolant( self, fig, plotting_options )
           
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether we want to add these attachment points to an existing plot or create a new plot.
            if ( nargin < 2 ) || ( isempty(fig) )

                % Create a figure to store the BPA reference fields.
                fig = figure( 'Color', 'w', 'Name', 'BPA Muscle: Pressure vs Force & Strain (Interpolant)' );

                % Create the first subplot.
                subplot( 1, 2, 1 ), hold on, grid on,  rotate3d on
                xlabel('Force [lb]'), ylabel('Strain (Type I) [-]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Force & Strain (Interpolant) (S = 0)')
                xlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )

                % Create the second subplot.
                subplot( 1, 2, 2 ), hold on, grid on,  rotate3d on
                xlabel('Force [lb]'), ylabel('Strain (Type I) [-]'), zlabel('Pressure [psi]'), title('BPA Muscle: Pressure vs Force & Strain (Interpolant) (S = 1)')
                xlim( self.conversion_manager.n2lb( [ self.min_tension, self.max_tension ] ) ), ylim( [ self.min_muscle_strain, self.max_muscle_strain ] ), zlim( self.conversion_manager.pa2psi( [ self.min_pressure, self.max_pressure ] ) )
                    
            end
                
            % Create the force interpolation points.
            forces = linspace( self.min_tension, self.max_tension, 2*self.num_reference_forces );

            % Create the strain interpolation points.
            strains = linspace( self.min_muscle_strain, self.max_muscle_strain, 2*self.num_reference_strains );

            % Create the interpolation meshes.
            [ Fs, Ss ] = meshgrid( forces, strains );

            % Compute the associated pressures.
            Ps_S0 = self.pressure_interpolant_S0( Fs, Ss );
            Ps_S1 = self.pressure_interpolant_S1( Fs, Ss );

            % Plot the pressure vs force & strain field.
            figure( fig )
            subplot( 1, 2, 1 ), surf( self.conversion_manager.n2lb( Fs ), Ss, self.conversion_manager.pa2psi( Ps_S0 ), plotting_options{:} )
            subplot( 1, 2, 2 ), surf( self.conversion_manager.n2lb( Fs ), Ss, self.conversion_manager.pa2psi( Ps_S1 ), plotting_options{:} )
            
        end
        
        
        % Implement a function to plot the BPA muscle strain, force, and pressure interpolant.
        function figs_output = plot_BPA_muscle_interpolant( self, figs, plotting_options, plot_type )
        
            if ( ( nargin < 4 ) || ( isempty(plot_type) ) ), plot_type = 'all'; end
        
            % Ensure that the plot type is valid.
            self.validate_plot_type( plot_type );
                
            % Determine whether to specify default plotting options.
            if ( ( nargin < 3 ) || ( isempty( plotting_options ) ) ), plotting_options = { 'Edgecolor', 'None' }; end
            
            % Determine whether to specify an empty figure.
            if ( nargin < 2 ) || ( isempty(figs) ), figs = []; end

            % Validate the figure selection.
            self.validate_figure_selection( figs, plot_type );
            
            % Determine which reference fields to plot.
            if strcmp( plot_type, 'strain' )                               % If we want to plot the strain reference field...
            
                % Plot the BPA muscle strain interpolant.
                figs_output = self.plot_BPA_muscle_strain_interpolant( figs, plotting_options );
                
            elseif strcmp( plot_type, 'force' )                            % If we want to plot the force reference field...
                
                % Plot the BPA muscle force interpolant.
                figs_output = self.plot_BPA_muscle_force_interpolant( figs, plotting_options );
                
            elseif strcmp( plot_type, 'pressure' )                         % If we want to plot the pressure reference field...
                   
                % Plot the BPA muscle pressure interpolant.
                figs_output = self.plot_BPA_muscle_pressure_interpolant( figs, plotting_options );
                
            elseif strcmp( plot_type, 'all' )                      % If we want to plot all of the reference fields...
                
                % Initialize an array of graphics objects.
                figs_output = gobjects(3);
                
                % Plot the BPA muscle strain interpolant.
                figs_output(1) = self.plot_BPA_muscle_strain_interpolant( figs, plotting_options );
          
                % Plot the BPA muscle force interpolant.
                figs_output(2) = self.plot_BPA_muscle_force_interpolant( figs, plotting_options );
                
                % Plot the BPA muscle pressure interpolant.
                figs_output(3) = self.plot_BPA_muscle_pressure_interpolant( figs, plotting_options );
                
            else                                                % Otherwise...
                
                % Ensure that the plot type is valid.
                self.validate_plot_type( plot_type );
                
            end
            
        end
        
        
            
    end
end

