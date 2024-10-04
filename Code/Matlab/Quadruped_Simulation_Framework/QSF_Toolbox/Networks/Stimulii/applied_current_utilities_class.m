classdef applied_current_utilities_class

    % This class contains properties and methods related to applied current utilities.
    
    
    %% APPLIED CURRENT UTILITIES PROPERTIES.
    
    % Define the class properties.
    properties
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                   	% [V] Activation Domain.
        Gm_DEFAULT = 1e-6;                      % [S] Membrane Conductance.
        
        % Define the applied current parameters.
        Ia_max_DEFAULT = 20e-9;                 % [A] Maximum Applied Current.
        Ia_no_current_DEFAULT = 0e-9;           % [A] Zero Applied Current.
        
    end
    
    
    %% APPLIED CURRENT UTILITIES METHODS SETUP.
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_utilities_class(  )

            
            
        end
        
        
        %% Name Functions.
        
        % Implement a function to generate a name from an ID.
        function name = ID2name( ~, ID )
            
            % Generate a name for the applied current.
            name = sprintf( 'Applied Current %s', ID );
            
        end
        
        
        % Implement a function to generate names from IDs.
        function names = IDs2names( self, IDs )
        
            % Compute the number of IDs.
            num_IDs = length( IDs );
            
            % Preallocate a cell array to store the names.
            names = cell( 1, num_IDs );
            
            % Generate a name for each ID.
            for k = 1:num_IDs                 % Iterate through each of the IDs...
                
                % Generate the name associated with this ID.
                names{ k } = self.ID2name( IDs( k ) );
                
            end
            
        end
        
        
        %% Applied Current Magnitude Design Functions.        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of output absolute inversion subnetwork applied currents.
        function Ias2 = compute_absolute_inversion_Ias2( self, Gm2, R2 )
            
            % Define the default input arguments.
            if nargin < 3, R2 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm2 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias2 = Gm2.*R2;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output relative inversion subnetwork applied currents.
        function Ias2 = compute_relative_inversion_Ias2( self, Gm2, R2 )
            
            % Define the default input arguments.
            if nargin < 3, R2 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm2 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias2 = Gm2.*R2;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output inversion subnetwork applied currents.
        function Ias2 = compute_inversion_Ias2( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to compute the applied currents.
            if strcmpi( encoding_scheme, 'absolute' )
               
                % Unpack the parameters.
                Gm2 = parameters{ 1 };
                R2 = parameters{ 2 };
                
                % Compute the applied current using an absolute encoding scheme.
                Ias2 = self.compute_absolute_inversion_Ias2( Gm2, R2 );
                
            elseif strcmpi( encoding_scheme, 'relative' )
                
                % Unpack the parameters.
                Gm2 = parameters{ 1 };
                R2 = parameters{ 2 };
                
                % Compute the applied current using a relative encoding scheme.
                Ias2 = self.compute_relative_inversion_Ias_output( Gm2, R2 );
            
            else
            
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of output reduced absolute inversion subnetwork applied currents.
        function Ias2 = compute_reduced_absolute_inversion_Ias2( self, Gm2, R2 )
            
            % Define the default input arguments.
            if nargin < 3, R2 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm2 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias2 = Gm2.*R2;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output reduced relative inversion subnetwork applied currents.
        function Ias2 = compute_reduced_relative_inversion_Ias2( self, Gm2, R2 )
            
            % Define the default input arguments.
            if nargin < 3, R2 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm2 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of the inversion subentwork applied currents.
            Ias2 = Gm2.*R2;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output reduced inversion subnetwork applied currents.
        function Ias2 = compute_reduced_inversion_Ias2( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to compute the applied currents.
            if strcmpi( encoding_scheme, 'absolute' )
               
                % Unpack the parameters.
                Gm2 = parameters{ 1 };
                R2 = parameters{ 2 };
                
                % Compute the applied current using an absolute encoding scheme.
                Ias2 = self.compute_absolute_inversion_Ias2( Gm2, R2 );
                
            elseif strcmpi( encoding_scheme, 'relative' )
                
                % Unpack the parameters.
                Gm2 = parameters{ 1 };
                R2 = parameters{ 2 };
                
                % Compute the applied current using a relative encoding scheme.
                Ias2 = self.compute_relative_inversion_Ias_output( Gm2, R2 );
            
            else
            
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of absolute multiplication subnetwork applied currents.
        function Ias3 = compute_absolute_multiplication_Ias3( self, Gm3, R3 )
           
            % Define the default input arguments.
            if nargin < 3, R3 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm3 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias3 = self.compute_absolute_inversion_Ias2( Gm3, R3 );                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of relative multiplication subnetwork applied currents.
        function Ias3 = compute_relative_multiplication_Ias3( self, Gm3, R3 )
           
            % Define the default input arguments.
            if nargin < 3, R3 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm3 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias3 = self.compute_relative_inversion_Ias2( Gm3, R3 );                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output multiplication subnetwork applied currents.
        function Ias3 = compute_multiplication_Ias3( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to compute the applied currents.
            if strcmpi( encoding_scheme, 'absolute' )
               
                % Unpack the parameters.
                Gm3 = parameters{ 1 };
                R3 = parameters{ 2 };
                
                % Compute the applied current using an absolute encoding scheme.
                Ias3 = self.compute_absolute_inversion_Ias2( Gm3, R3 );
                
            elseif strcmpi( encoding_scheme, 'relative' )
                
                % Unpack the parameters.
                Gm3 = parameters{ 1 };
                R3 = parameters{ 2 };
                
                % Compute the applied current using a relative encoding scheme.
                Ias3 = self.compute_relative_inversion_Ias_output( Gm3, R3 );
            
            else
            
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of reduced absolute multiplication subnetwork applied currents.
        function Ias3 = compute_reduced_absolute_multiplication_Ias3( self, Gm3, R3 )
           
            % Define the default input arguments.
            if nargin < 3, R3 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm3 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias3 = self.compute_reduced_absolute_inversion_Ias2( Gm3, R3 );                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of reduced relative multiplication subnetwork applied currents.
        function Ias3 = compute_reduced_relative_multiplication_Ias3( self, Gm3, R3 )
           
            % Define the default input arguments.
            if nargin < 3, R3 = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm3 = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of multiplication subnetwork applied currents.
            Ias3 = self.compute_reduced_relative_inversion_Ias2( Gm3, R3 );                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the magnitude of output reduced multiplication subnetwork applied currents.
        function Ias3 = compute_reduced_multiplication_Ias3( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to compute the applied currents.
            if strcmpi( encoding_scheme, 'absolute' )
               
                % Unpack the parameters.
                Gm3 = parameters{ 1 };
                R3 = parameters{ 2 };
                
                % Compute the applied current using an absolute encoding scheme.
                Ias3 = self.compute_reduced_absolute_inversion_Ias2( Gm3, R3 );
                
            elseif strcmpi( encoding_scheme, 'relative' )
                
                % Unpack the parameters.
                Gm3 = parameters{ 1 };
                R3 = parameters{ 2 };
                
                % Compute the applied current using a relative encoding scheme.
                Ias3 = self.compute_reduced_relative_inversion_Ias2( Gm3, R3 );
            
            else
            
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of integration subnetwork applied currents.
        function Ias = compute_integration_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the magnitude of integration subnetwork applied currents.
            Ias = Gm.*R;                                                                    % [A] Applied Current.
            
        end
        
        
        %{
        
        % Implement a function to compute the desired intermediate synaptic current for a voltage based integration subnetwork.
        function Is12 = compute_vbi_Is( ~, R2, Ta, ki_mean, inhibition_flag )

            %{
            Input(s):
                R2              =   [V] Maximum Membrane Voltage.
                Ta              =   [s] Activation Period.
                ki_mean         =   [-] Integration Subnetwork Gain.
                inhibition_flag    =   [T/F] Inhibition Flag.
            
            Output(s):
                Is12            =   [A] Synaptic Current (Synapse 12).
            %}
            
            % Set the default input arguments.
            if nargin < 5, inhibition_flag = false; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the intermediate synaptic current.
            Is12 = R2./( 2*Ta.*ki_mean );    
            
            % Determine whether to switch the sign on the intermediate synaptic current.
            if inhibition_flag, Is12 = - Is12; end
            
        end
        
        %}
        
        
        % Implement a function to compute the magnitude of voltage based integration subnetwork applied currents.
        function Ias = compute_vbi_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                     	% [S] Membrane Conductance.
            
            % Compute the magnitude of voltage based integration subnetwork applied currents.
            Ias = Gm.*R;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the first magnitude of split voltage based integration subnetwork applied currents.
        function Ias = compute_svbi_Ias1( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the first magnitude of split voltage based integration subnetwork applied currents.
            Ias = Gm.*R;                                                                    % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the second magnitude of split voltage based integration subnetwork applied currents.
        function Ias = compute_svbi_Ias2( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the second magnitude of split voltage based integration subnetwork applied currents.
            Ias = ( Gm.*R )/2;                                                              % [A] Applied Current.
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------
        
        % Implement a function to compute the magnitude of centering subnetwork applied currents.
        function Ias = compute_centering_Ias( self, Gm, R )
           
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                                              % [A] Applied Current.
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to compute the time vector of multistate cpg subnetwork applied currents.
        function ts = compute_mcpg_ts( ~, dt, tf )
        
            % Compute the time vector of multistate cpg subnetwork applied currents.
            ts = ( 0:dt:tf )';
            
        end
        
                
        % Implement a function to compute the magnitude of multistate cpg subnetwork applied currents.
        function Ias = compute_mcpg_Ias( self, dt, tf )
        
            % Compute the number of applied currents.
            n_applied_currents = floor( tf/dt ) + 1;                                      	% [#] Number of Applied Currents.
            
            % Create the applied current magnitude vector.
            Ias = zeros( n_applied_currents, 1 ); Ias( 1 ) = self.Ia_max_DEFAULT;           % [A] Applied Current..
            
        end
        
        
        % Implement a function to compute the magnitude of driven multistate cpg subnetwork applied currents.
        function Ias = compute_dmcpg_Ias( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
             
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                                              % [A] Applied Current.
            
        end
        
        
        % Implement a function to compute the applied current magnitudes that connect the dmcpgdcll and cds subnetworks.
        function Ias = compute_dmcpgdcll2cds_Ias( self, Gm, R )
        
            % Define the default input arguments.
            if nargin < 3, R = self.R_DEFAULT; end                                          % [V] Activation Domain.
            if nargin < 2, Gm = self.Gm_DEFAULT; end                                        % [S] Membrane Conductance.
            
            % Compute the applied current magnitude.
            Ias = ( Gm.*R )/2;                                                              % [A] Applied Current.
            
        end
        
        
        %% Print Functions.
        
        % Implement a function to print applied current properties.
        
        

    end
end