classdef applied_current_utilities_class

    % This class contains properties and methods related to applied current utilities.
    
    
    %% APPLIED CURRENT UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
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
        function I_apps = compute_multistate_cpg_Iapps( ~, dt, tf )
        
            % Compute the number of applied currents.
            num_applied_currents = floor( tf/dt ) + 1;
            
            % Create the applied current magnitude vector.
            I_apps = zeros( num_applied_currents, 1 ); I_apps( 1 ) = 20e-9;
            
        end
        
        
        % Implement a function to compute the magnitude of driven multistate cpg subnetwork applied currents.
        function I_apps = compute_driven_multistate_cpg_Iapps( ~, Gm, R )
        
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;
            
        end
        
        
        % Implement a function to compute the applied current magnitudes that connect the dmcpgdcll and cds subnetworks.
        function I_apps = compute_dmcpgdcll2cds_Iapps( ~, Gm, R )
        
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;
            
        end
                
        
        % Implement a function to compute the magnitude of centering subnetwork applied currents.
        function I_apps = compute_centering_Iapps( ~, Gm, R )
           
            % Compute the applied current magnitude.
            I_apps = ( Gm.*R )/2;     
            
        end
        
            
        % Implement a function to compute the magnitude of multiplication subnetwork applied currents.
        function I_apps = compute_multiplication_Iapps( ~, Gm, R )
           
            % Compute the magnitude of multiplication subnetwork applied currents.
            I_apps = Gm.*R;
            
        end
        
        
        % Implement a function to compute the magnitude of integration subnetwork applied currents.
        function I_apps = compute_integration_Iapps( ~, Gm, R )
           
            % Compute the magnitude of integration subnetwork applied currents.
            I_apps = Gm.*R;
            
        end
        
        
        % Implement a function to compute the magnitude of voltage based integration subnetwork applied currents.
        function I_apps = compute_vb_integration_Iapps( ~, Gm, R )
           
            % Compute the magnitude of voltage based integration subnetwork applied currents.
            I_apps = Gm.*R;
            
        end
        
        
        % Implement a function to compute the first magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps1( ~, Gm, R )
           
            % Compute the first magnitude of split voltage based integration subnetwork applied currents.
            I_apps = Gm.*R;
            
        end
        
        
        % Implement a function to compute the second magnitude of split voltage based integration subnetwork applied currents.
        function I_apps = compute_split_vb_integration_Iapps2( ~, Gm, R )
           
            % Compute the second magnitude of split voltage based integration subnetwork applied currents.
            I_apps = ( Gm.*R )/2;
            
        end
        
        
        
        
    end
end