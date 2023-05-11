classdef applied_current_class
    
    % This class contains properties and methods related to applied currents.
    
    
    %% APPLIED CURRENT PROPERTIES
    
    % Define the class properties.
    properties
        
        ID
        name
        neuron_ID
        
        ts
        I_apps
        
        num_timesteps
        dt
        tf
        
        b_enabled
        
        array_utilities
        applied_current_utilities
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance
        
        % Define the applied current properties.
        Iapp_DEFAULT = 0e-9;                                                                                            % [A] Applied Current Magnitudes
        ts_DEFAULT = 0;                                                                                                 % [s] Applied Current Times
        
    end
    
    
    %% APPLIED CURRENT METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_class( ID, name, neuron_ID, ts, I_apps, b_enabled )
            
            % Create an instance of the array manager class.
            self.array_utilities = array_utilities_class(  );
            
            % Create an instance of the array manager class.
            self.applied_current_utilities = applied_current_utilities_class(  );
            
            % Set the default properties.
            if nargin < 6, self.b_enabled = true; else, self.b_enabled = b_enabled; end                                     % [T/F] Applied Current Enabled Flag
            if nargin < 5, self.I_apps = self.Iapp_DEFAULT; else, self.I_apps = I_apps; end                                 % [A] Applied Current Magnitudes
            if nargin < 4, self.ts = self.ts_DEFAULT; else, self.ts = ts; end                                               % [s] Applied Current Times
            if nargin < 3, self.neuron_ID = 0; else, self.neuron_ID = neuron_ID; end                                        % [#] Application Neuron ID
            if nargin < 2, self.name = ''; else, self.name = name; end                                                      % [-] Applied Current Name
            if nargin < 1, self.ID = 0; else, self.ID = ID; end                                                             % [#] Applied Current ID
            
            % Validate the applied current.
            self.validate_applied_current(  )
            
            % Compute the number of timesteps.
            self = self.compute_set_num_timesteps(  );
            
            % Compute and set the step size.
            self = self.compute_set_dt(  );
            
            % Compute and set the final time.
            self = self.compute_set_tf(  );
            
        end
        
        
        %% Get & Set Functions
        
        % Implement a function to set the applied current vector.
        function self = set_applied_current( self, ts, I_apps )
            
            % Set the default input arugments.
            if nargin < 3, I_apps = self.Iapp_DEFAULT; end                                                                  % [A] Applied Current Magnitudes
            if nargin < 2, ts = self.ts_DEFAULT; end                                                                        % [s] Applied Current Times
            
            % Ensure that there are the same number of time steps as applied currents.
            assert( length( ts ) == length( I_apps ), 'The lengths of the time vector and applied current vectors must be equal.' )
            
            % Set the time vector.
            self.ts = ts;
            
            % Set the applied currents.
            self.I_apps;
            
            % Set the number of time steps.
            self.num_timesteps = length( self.ts );    
            
        end
        
        
        %% Validation Functions
        
        % Implement a function to validate the applied current.
        function validate_applied_current( self )
           
            % Validate the applied current.
            assert( length( self.ts ) == length( self.I_apps ), 'The lengths of the time vector and applied current vectors must be equal.' )
            
        end
        
        
        %% Compute Time Functions
        
        % Implement a function to compute the number of time steps.
        function num_timesteps = compute_num_timesteps( self )
           
            % Compute the number of time steps.
            num_timesteps = length( self.ts );                                                                              % [#] Number of Simulation Timesteps
            
        end
        
        
        % Implement a function to compute the time step.
        function dt = compute_dt( self )
            
            % Compute the step size.
            dt = self.array_utilities.compute_step_size( self.ts );                                                         % [s] Simulation Time Step Size
            
        end
        
        
        % Implement a function to compute the final time.
        function tf = compute_tf( self )
            
            % Compute the final time.
           tf = max( self.ts );                                                                                             % [s] Final Simulation Time
            
        end
        
        
        % Implement a function to compute the time vector of multistate cpg subnetwork applied currents.
        function ts = compute_multistate_cpg_ts( self, dt, tf )
            
           % Compute the time vector of multistate cpg subnetwork applied currents.
           ts = self.applied_current_utilities.compute_multistate_cpg_ts( dt, tf );                                         % [s] Applied Current Times
            
        end
        
        
        %% Compute Applied Current Functions
        
        % Implement a function to compute the magnitude of multistate cpg subnetwork applied currents.
        function I_apps = compute_multistate_cpg_Iapps( self, dt, tf )
            
           % Compute the magnitude of multistate cpg subnetwork applied currents.
           I_apps = self.applied_current_utilities.compute_multistate_cpg_Iapps( dt, tf );
            
        end
        
        
        % Implement a function to compute the magnitude of driven multistate cpg subnetwork applied currents.
        function I_apps = compute_driven_multistate_cpg_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
           % Compute the magnitude of driven multistate cpg subnetwork applied currents.
           I_apps = self.applied_current_utilities.compute_driven_multistate_cpg_Iapps( Gm, R );
            
        end
        
        
        % Implement a function to compute the applied current magnitude that connects the dmcpgdcll and cds subnetworks.
        function I_apps = compute_dmcpgdcll2cds_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
           % Compute the magnitude of these applied currents.
           I_apps = self.applied_current_utilities.compute_dmcpgdcll2cds_Iapps( Gm, R );
            
        end
                
        
        % Implement a function to compute the magnitude of centering subnetwork applied currents.
        function I_apps = compute_centering_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of centering subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_centering_Iapps( Gm, R );
            
        end
        
        
        % Implement a function to compute the magnitude of absolute addition applied currents.
        function I_apps = compute_absolute_addition_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_addition_Iapps(  );
            
        end
        
        
        % Implement a function to compute the magnitude of relative addition applied currents.
        function I_apps = compute_relative_addition_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_relative_addition_Iapps(  );
            
        end        
        
        
        % Implement a function to compute the magnitude of absolute subtraction applied currents.
        function I_apps = compute_absolute_subtraction_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_subtraction_Iapps(  );
            
        end
        
        
        % Implement a function to compute the magnitude of relative subtraction applied currents.
        function I_apps = compute_relative_subtraction_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_relative_subtraction_Iapps(  );
            
        end
        
        
        % Implement a function to compute the magnitude of inversion subnetwork applied currents.
        function I_apps = compute_inversion_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_inversion_Iapps( Gm, R ); 
            
        end
        
        
        % Implement a function to compute the magnitude of absolute inversion input applied currents.
        function I_apps = compute_absolute_inversion_Iapps_input( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_inversion_Iapps_input(  );
            
        end
        
        
        % Implement a function to compute the magnitude of absolute inversion output applied currents.
        function I_apps = compute_absolute_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_inversion_Iapps_output( Gm, R );
            
        end
        
        
        % Implement a function to compute the magnitude of relative inversion input applied currents.
        function I_apps = compute_relative_inversion_Iapps_input( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_relative_inversion_Iapps_input(  );
            
        end
        
        
        % Implement a function to compute the magnitude of relative inversion output applied currents.
        function I_apps = compute_relative_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_inversion_Iapps_output( Gm, R );
            
        end
        
        
        % Implement a function to compute the magnitude of absolute division applied currents.
        function I_apps = compute_absolute_division_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_absolute_division_Iapps(  );
            
        end
        
        
        % Implement a function to compute the magnitude of relative division applied currents.
        function I_apps = compute_relative_division_Iapps( self )
            
            % Compute the applied current.
            I_apps = self.applied_current_utilities.compute_relative_division_Iapps(  );
            
        end
        
        
        % Implement a function to compute the magnitude of multiplication subnetwork applied currents.
        function I_apps = compute_multiplication_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_multiplication_Iapps( Gm, R );
            
        end
        
        
        % Implement a function to compute the magnitude of integration subnetwork applied currents.
        function I_apps = compute_integration_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of integration subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_integration_Iapps( Gm, R );
            
        end
            
        
        % Implement a function to compute the magnitude of voltage based integration subnetwork applied currents.
        function I_apps = compute_vb_integration_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of voltage based integration subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_vb_integration_Iapps( Gm, R );
            
        end
        
        
        % Implement a function to compute the first magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps1( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                          % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                        % [S] Membrane Conductance
            
            % Compute the first magnitude of split voltage based integration subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_split_vb_integration_Iapps1( Gm, R );           % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the second magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps2( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                          % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                        % [S] Membrane Conductance
            
            % Compute the second magnitude of split voltage based integration subnetwork applied currents.
            I_apps = self.applied_current_utilities.compute_split_vb_integration_Iapps2( Gm, R );           % [A] Applied Current
            
        end
        
                
        %% Compute-Set Time Functions
        
        % Implement a function to compute and set the number of time steps.
        function self = compute_set_num_timesteps( self )
           
            % Compute and set the number of time steps.
            self.num_timesteps = self.compute_num_timesteps(  );
            
        end
        
        
        % Implement a function to compute and set the step size.
        function self = compute_set_dt( self )
            
            % Compute the step size.
            self.dt = self.compute_dt(  );
            
        end
        
        
        % Implement a function to compute and set the final time.
        function self = compute_set_tf( self )
            
            % Compute and set the final time.
            self.tf = self.compute_tf(  );
            
        end
        
        
        % Implement a function to compute and set the time vector of multistate cpg subnetwork applied currents.
        function self = compute_set_multistate_cpg_ts( self, dt, tf )
            
           % Compute and set the time vector of multistate cpg subnetwork applied currents.
            self.ts = self.compute_multistate_cpg_ts( dt, tf );
            
        end
        
        
        %% Compute-Set Applied Current Functions
        
        % Implement a function to compute and set the magnitude of multistate cpg subnetwork applied currents.
        function self = compute_set_multistate_cpg_Iapps( self, dt, tf )
            
           % Compute and set the magnitude of multistate cpg subnetwork applied currents.
            self.I_apps = self.compute_multistate_cpg_Iapps( dt, tf );                              % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of driven multistate cpg subnetwork applied currents.
        function self = compute_set_driven_multistate_cpg_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
           % Compute and set the magnitude of driven multistate cpg subnetwork applied currents.
            self.I_apps = self.compute_driven_multistate_cpg_Iapps( Gm, R );                    	% [A] Applied Current
            
        end
       
        
        % Implement a function to compute and set the applied current magnitude that connects the dmcpgdcll and cds subnetworks.
        function self = compute_set_dmcpgdcll2cds_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
           % Compute and set the magnitude of this applied current.
            self.I_apps = self.compute_dmcpgdcll2cds_Iapps( Gm, R );                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of centering subnetwork applied currents.
        function self = compute_set_centering_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the magnitude of centering subnetwork applied currents.
            self.I_apps = self.compute_centering_Iapps( Gm, R );                                    % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of absolute addition applied currents.
        function self = compute_set_absolute_addition_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_absolute_addition_Iapps(  );                                 % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of relative addition applied currents.
        function self = compute_set_relative_addition_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_relative_addition_Iapps(  );                                 % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of absolute subtraction applied currents.
        function self = compute_set_absolute_subtraction_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_absolute_subtraction_Iapps(  );                              % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of relative subtraction applied currents.
        function self = compute_set_relative_subtraction_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_relative_subtraction_Iapps(  );                              % [A] Applied Current
            
        end  
        
        
        % Implement a function to compute and set the magnitude of inversion subnetwork applied currents.
        function self = compute_set_inversion_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the magnitude of inversion subnetwork applied currents.
            self.I_apps = self.compute_inversion_Iapps( Gm, R );                                    % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of absolute inversion input applied currents.
        function self = compute_set_absolute_inversion_Iapps_input( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_absolute_inversion_Iapps_input(  );                          % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of absolute inversion output applied currents.
        function self = compute_set_absolute_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute the applied current.
            self.I_apps = self.compute_absolute_inversion_Iapps_output( Gm, R );                    % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of relative inversion input applied currents.
        function self = compute_set_relative_inversion_Iapps_input( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_relative_inversion_Iapps_input(  );                          % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of relative inversion output applied currents.        
        function self = compute_set_relative_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute the applied current.
            self.I_apps = self.compute_relative_inversion_Iapps_output( Gm, R );                  	% [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of absolute division applied currents.
        function self = compute_set_absolute_division_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_absolute_division_Iapps(  );                                 % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of relative division applied currents.
        function self = compute_set_relative_division_Iapps( self )
            
            % Compute the applied current.
            self.I_apps = self.compute_relative_division_Iapps(  );                                 % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of multiplication subnetwork applied currents.
        function self = compute_set_multiplication_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the magnitude of multiplication subnetwork applied currents.
            self.I_apps = self.compute_multiplication_Iapps( Gm, R );                               % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of integration subnetwork applied currents.
        function self = compute_set_integration_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the magnitude of integration subnetwork applied currents.
            self.I_apps = self.compute_integration_Iapps( Gm, R );                                  % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the magnitude of voltage based integration subnetwork applied currents.
        function self = compute_set_vb_integration_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the magnitude of voltage based integration subnetwork applied currents.
            self.I_apps = self.compute_vb_integration_Iapps( Gm, R );                               % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the first magnitude of split voltage based integration subnetwork applied currents.
        function self = compute_set_split_vb_integration_Iapps1( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the first magnitude of split voltage based integration subnetwork applied currents.
            self.I_apps = self.compute_split_vb_integration_Iapps1( Gm, R );                        % [A] Applied Current
            
        end
        
        
        % Implement a function to compute and set the second magnitude of split voltage based integration subnetwork applied currents.
        function self = compute_set_split_vb_integration_Iapps2( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                                  % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                                % [S] Membrane Conductance
            
            % Compute and set the second magnitude of split voltage based integration subnetwork applied currents.
            self.I_apps = self.compute_split_vb_integration_Iapps2( Gm, R );                        % [A] Applied Current
            
        end
        
        
        %% Sampling Functions
        
        % Implement a function to sample an applied current.
        function [ I_apps_sample, ts_sample ] = sample_Iapp( self, dt, tf )
            
            % Set the default input arguments.
            if nargin < 3, tf = max( self.ts ); end
            if nargin < 2, dt = [  ]; end
            
            % Determine how to sample the applied current.
            if ~isempty( dt ) && ( self.num_timesteps > 0 )                          % If the sample spacing and existing applied current data is not empty...
                
                % Create the sampled time vector.
                ts_sample = ( 0:dt:tf )';
                
                % Determine how to sample the applied current.
                if self.num_timesteps == 1                                           % If the number of timesteps is one.. ( The applied current is constant. )
                    
                    % Create the applied current sample as a constant vector.
                    I_apps_sample = self.I_apps*ones( self.num_timesteps, 1 );
                    
                else                                                                % Otherwise...
                    
                    % Create the applied current sample via interpolation.
                    I_apps_sample = interp1( self.ts, self.I_apps, ts_sample );
                    
                end
                
            else                                                                    % Otherwise...
                
                % Set the sampled time vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
                ts_sample = self.ts;
                
                % Set the sampled applied current vector to be the existing time vector (perhaps empty, perhaps a complete time vector).
                I_apps_sample = self.I_apps;
                
            end
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this applied current is enabled.
        function self = toggle_enabled( self )
            
            % Toggle whether the applied current is enabled.
            self.b_enabled = ~self.b_enabled;
            
        end
        
        
        % Implement a function to enable this applied current.
        function self = enable( self )
            
            % Enable this applied current.
            self.b_enabled = true;
            
        end
        
        
        % Implement a function to disable this applied current.
        function self = disable( self )
            
            % Disable this applied current.
            self.b_enabled = false;
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save applied current data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load applied current data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
    end
end

