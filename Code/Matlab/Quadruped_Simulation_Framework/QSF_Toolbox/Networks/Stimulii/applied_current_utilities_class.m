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
        Ia_max_DEFAULT = 20e-9;                                                                                       % [A] Maximum Applied Current
        Ia_no_current_DEFAULT = 0e-9;                                                                                 % [A] Zero Applied Current
        
    end
    
    
    %% APPLIED CURRENT UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_utilities_class(  )

            
            
        end
        
        
        %% Applied Current Design Functions
        
        % Implement a function to compute the time vector of multistate cpg subnetwork applied currents.
        function ts = compute_mcpg_ts( ~, dt, tf )
        
            % Compute the time vector of multistate cpg subnetwork applied currents.
            ts = ( 0:dt:tf )';
            
        end
        
                
        % Implement a function to compute the magnitude of multistate cpg subnetwork applied currents.
        function Ias = compute_mcpg_Ias( self, dt, tf )
        
            % Compute the number of applied currents.
            n_applied_currents = floor( tf/dt ) + 1;                                            % [#] Number of Applied Currents.
            
            % Create the applied current magnitude vector.
            Ias = zeros( n_applied_currents, 1 ); Ias( 1 ) = self.Ia_max_DEFAULT;             % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of driven multistate cpg subnetwork applied currents.
        function Ias = compute_dmcpg_Ias( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
             
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                          % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the applied current magnitudes that connect the dmcpgdcll and cds subnetworks.
        function Ias = compute_dmcpgdcll2cds_Ias( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                          % [A] Applied Current
            
        end
                
        
        % Implement a function to compute the magnitude of centering subnetwork applied currents.
        function Ias = compute_centering_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                          % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute addition applied currents.
        function Ias = compute_absolute_addition_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative addition applied currents.
        function Ias = compute_relative_addition_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute subtraction applied currents.
        function Ias = compute_absolute_subtraction_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative subtraction applied currents.
        function Ias = compute_relative_subtraction_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of inversion subnetwork applied currents.
        function Ias = compute_inversion_Ias( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of input absolute inversion subnetwork applied currents.
        function Ias = compute_absolute_inversion_Ias_input( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of output absolute inversion subnetwork applied currents.
        function Ias = compute_absolute_inversion_Ias_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of input relative inversion subnetwork applied currents.
        function Ias = compute_relative_inversion_Ias_input( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of output relative inversion subnetwork applied currents.
        function Ias = compute_relative_inversion_Ias_output( self, Gm, R )
            
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute division applied currents.
        function Ias = compute_absolute_division_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative division applied currents.
        function Ias = compute_relative_division_Ias( self )
            
            % Define the applied current.
            Ias = self.Ia_no_current_DEFAULT;                         % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of absolute multiplication subnetwork applied currents.
        function Ias = compute_absolute_multiplication_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of relative multiplication subnetwork applied currents.
        function Ias = compute_relative_multiplication_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of integration subnetwork applied currents.
        function Ias = compute_integration_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of integration subnetwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the magnitude of voltage based integration subnetwork applied currents.
        function Ias = compute_vbi_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the magnitude of voltage based integration subnetwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the first magnitude of split voltage based integration subnetwork applied currents.
        function Ias = compute_svbi_Ias1( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the first magnitude of split voltage based integration subnetwork applied currents.
            Ias = Gm.*R;                                                % [A] Applied Current
            
        end
        
        
        % Implement a function to compute the second magnitude of split voltage based integration subnetwork applied currents.
        function Ias = compute_svbi_Ias2( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                      % [V] Activation Domain
            if nargin < 2, Gm = self.Gm_DEFAULT; end                    % [S] Membrane Conductance
            
            % Compute the second magnitude of split voltage based integration subnetwork applied currents.
            Ias = ( Gm.*R )/2;                                          % [A] Applied Current
            
        end

    end
end