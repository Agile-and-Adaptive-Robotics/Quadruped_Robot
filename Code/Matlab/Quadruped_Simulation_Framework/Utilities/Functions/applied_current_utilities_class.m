classdef applied_current_utilities_class

    % This class contains properties and methods related to applied current utilities.
    
    
    %% APPLIED CURRENT UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance
        
        % Define the applied current parameters.
        Iapp_max_DEFAULT = 20e-9;                                                                                       % [A] Maximum Applied Current
        Iapp_no_current_DEFAULT = 0e-9;                                                                                 % [A] Zero Applied Current
        
    end
    
    
    %% APPLIED CURRENT UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_utilities_class(  )

            
            
        end
        
        
        %% Applied Current Design Functions
        
        % Implement a function to compute the time vector of multistate cpg subnetwork applied currents.
        function ts = compute_multistate_cpg_ts( ~, dt, tf )
        
            % Compute the time vector of multistate cpg subnetwork applied currents.
            ts = ( 0:dt:tf )';
            
        end
        
                
        % Implement a function to compute the magnitude of multistate cpg subnetwork applied currents.
        function I_apps = compute_multistate_cpg_Iapps( self, dt, tf )
        
            % Compute the number of applied currents.
            num_applied_currents = floor( tf/dt ) + 1;
            
            % Create the applied current magnitude vector.
            I_apps = zeros( num_applied_currents, 1 ); I_apps( 1 ) = self.Iapp_max_DEFAULT;             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of driven multistate cpg subnetwork applied currents.
        function I_apps = compute_driven_multistate_cpg_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
             
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;                                       % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the applied current magnitudes that connect the dmcpgdcll and cds subnetworks.
        function I_apps = compute_dmcpgdcll2cds_Iapps( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;                                       % [A] Applied Current
            
        end
                
        
        % Implement a function to compute the magnitude of centering subnetwork applied currents.
        function I_apps = compute_centering_Iapps( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;                                       % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute addition applied currents.
        function I_apps = compute_absolute_addition_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative addition applied currents.
        function I_apps = compute_relative_addition_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute subtraction applied currents.
        function I_apps = compute_absolute_subtraction_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative subtraction applied currents.
        function I_apps = compute_relative_subtraction_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of inversion subnetwork applied currents.
        function I_apps = compute_inversion_Iapps( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of input absolute inversion subnetwork applied currents.
        function I_apps = compute_absolute_inversion_Iapps_input( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of output absolute inversion subnetwork applied currents.
        function I_apps = compute_absolute_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of input relative inversion subnetwork applied currents.
        function I_apps = compute_relative_inversion_Iapps_input( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of output relative inversion subnetwork applied currents.
        function I_apps = compute_relative_inversion_Iapps_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute division applied currents.
        function I_apps = compute_absolute_division_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative division applied currents.
        function I_apps = compute_relative_division_Iapps( self )
            
            % Define the applied current.
            I_apps = self.Iapp_no_current_DEFAULT;                      % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of multiplication subnetwork applied currents.
        function I_apps = compute_multiplication_Iapps( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of integration subnetwork applied currents.
        function I_apps = compute_integration_Iapps( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of integration subnetwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of voltage based integration subnetwork applied currents.
        function I_apps = compute_vb_integration_Iapps( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of voltage based integration subnetwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the first magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps1( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the first magnitude of split voltage based integration subnetwork applied currents.
            I_apps = Gm.*R;                                             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the second magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps2( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the second magnitude of split voltage based integration subnetwork applied currents.
            I_apps = ( Gm.*R )/2;                                       % [A] Applied Current
            
        end

    end
end