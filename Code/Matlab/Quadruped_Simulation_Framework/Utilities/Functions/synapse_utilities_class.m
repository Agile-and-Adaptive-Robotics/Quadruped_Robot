classdef synapse_utilities_class

    % This class contains properties and methods related to synapse utilities.
    
    
    %% SYNAPSE UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        dE_SYN_MAXIMUM = 194e-3;
        dE_SYN_MINIMUM = -40e-3;
        dE_SYN_SMALL_NEGATIVE = -1e-3;
        
    end
    
    
    %% SYNAPSE UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_utilities_class(  )

            
            
        end
        
        
        %% Synaptic Reversal Potential Compute Functions
        
        % Implement a function to compute the synaptic reversal potential for a driven multistate cpg subnetwork.
        function dE_syn = compute_driven_multistate_cpg_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a transmission subnetwork.
        function dE_syn = compute_transmission_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a modulation subnetwork.
        function dE_syn = compute_modulation_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = 0;
            
        end
        
                
        % Implement a function to compute the first synaptic reversal potential for an addition subnetwork.
        function dE_syn1 = compute_addition_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the second synaptic reversal potential for an addition subnetwork.
        function dE_syn2 = compute_addition_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute addition subnetwork synapses.
        function dE_syn = compute_absolute_addition_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative addition subnetwork synapses.
        function dE_syn = compute_relative_addition_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a subtraction subnetwork.
        function dE_syn1 = compute_subtraction_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a subtraction subnetwork.
        function dE_syn2 = compute_subtraction_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = self.dE_SYN_MINIMUM;
            
        end

        
        % Implement a function to compute the synaptic reversal potential for absolute subtraction subnetwork excitatory synapses.
        function dE_syn = compute_absolute_subtraction_dEsyn_excitatory( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute subtraction subnetwork inhibitory synapses.
        function dE_syn = compute_absolute_subtraction_dEsyn_inhibitory( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MINIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative subtraction subnetwork excitatory synapses.
        function dE_syn = compute_relative_subtraction_dEsyn_excitatory( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative subtraction subnetwork inhibitory synapses.
        function dE_syn = compute_relative_subtraction_dEsyn_inhibitory( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MINIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn1 = compute_multiplication_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn2 = compute_multiplication_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = self.dE_SYN_SMALL_NEGATIVE;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn3 = compute_multiplication_dEsyn3( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn3 = self.dE_SYN_SMALL_NEGATIVE;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for an inversion subnetwork.
        function dE_syn = compute_inversion_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_SMALL_NEGATIVE;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute inversion subnetwork synapses.
        function dE_syn = compute_absolute_inversion_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_SMALL_NEGATIVE;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative inversion subnetwork synapses.
        function dE_syn = compute_relative_inversion_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_SMALL_NEGATIVE;
            
        end
        
        
        
        % Implement a function to compute the synaptic reversal potential for a division subnetwork.
        function dE_syn1 = compute_division_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a division subnetwork.
        function dE_syn2 = compute_division_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = 0;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for absolute division synapses.
        function dE_syn = compute_absolute_division_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute division synapses.
        function dE_syn = compute_absolute_division_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_SMALL_NEGATIVE;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative division synapses.
        function dE_syn = compute_relative_division_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_MAXIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative division synapses.
        function dE_syn = compute_relative_division_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.dE_SYN_SMALL_NEGATIVE;
            
        end

        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dE_syn1 = compute_derivation_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dE_syn2 = compute_derivation_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = self.dE_SYN_MINIMUM;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dE_syn1 = compute_integration_dEsyn1( ~ )
           
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MINIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dE_syn2 = compute_integration_dEsyn2( ~ )
           
            % Compute the synaptic reversal potential.
            dE_syn2 = self.dE_SYN_MINIMUM;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dE_syn1 = compute_vb_integration_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = self.dE_SYN_MAXIMUM;
            
        end         
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dE_syn2 = compute_vb_integration_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = -self.dE_SYN_MAXIMUM;
            
        end      
        
        
        %% Maximum Synaptic Conductance Compute Functions
        
        % Implement a function to compute the maximum synaptic conductance for a driven multistate cpg subnetwork.
        function g_syn_max = compute_driven_multistate_cpg_gsynmax( ~, dE_syn, delta_oscillatory, I_drive_max )
        
            % Compute the maximum synaptic conductance.
            g_syn_max = I_drive_max./( dE_syn - delta_oscillatory );
%             g_syn_max = 0;

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute addition subnetwork synapses.
        function gsyn_nk = compute_absolute_addition_gsyn( ~, c, R_k, Gm_n, dEsyn_nk, Iapp_n ) 
        
            % Compute the maximum synaptic conductance.
            gsyn_nk = ( c.*R_k.*Gm_n - Iapp_n )./( dEsyn_nk - c.*R_k );

        end
        
            
        % Implement a function to compute the maximum synaptic conductance of relative addition subnetwork synapses.
        function gsyn_nk = compute_relative_addition_gsyn( ~, c, n, R_n, Gm_n, dEsyn_nk, Iapp_n )

            % Compute the maximum synaptic conductance.
            gsyn_nk = ( ( n - 1 ).*Iapp_n - c.*R_n.*Gm_n )./( c.*R_n - ( n - 1 ).*dEsyn_nk );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute subtraction subnetwork synapses.
        function gsyn_nk = compute_absolute_subtraction_gsyn( ~, c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n )
        
            % Compute the maximum synaptic conductance.
            gsyn_nk = ( Iapp_n - c.*s_k.*Gm_n.*R_k )./( c.*s_k.*R_k - dEsyn_nk );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative subtraction subnetwork synapses.
        function gsyn_nk = compute_relative_subtraction_gsyn( ~, c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n )
            
           % Compute the maximum synaptic conductance.
           gsyn_nk = ( npm_k.*Iapp_n - c.*s_k.*Gm_n.*R_n )./( c.*s_k.*R_n - npm_k.*dEsyn_nk );
           
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute inversion subnetwork synapses.
        function gsyn_21 = compute_absolute_inversion_gsyn( ~, c, epsilon, R_1, Gm_2, Iapp_2 )
            
            % Compute the maximum synaptic conductance.
            gsyn_21 = ( ( epsilon + R_1 ).*Iapp_2 - c.*Gm_2 )./c;
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative inversion subnetwork synapses.
        function gsyn_21 = compute_relative_inversion_gsyn( ~, c, epsilon, R_2, Gm_2, Iapp_2 )
            
            % Compute the maximum synaptic conductance.
            gsyn_21 = ( ( 1 + epsilon ).*Iapp_2 - c.*R_2.*Gm_2 )./( c.*R_2 );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of numerator absolute division subnetwork synapses.
        function gsyn_31 = compute_absolute_division_gsyn31( ~, c, epsilon, R_1, Gm_3, dEsyn_31 )
            
            % Compute the maximum synaptic conductance.
            gsyn_31 = ( R_1.*Gm_3 )./( dEsyn_31.*epsilon - c.*R_1 );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of denominator absolute division subnetwork synapses.
        function gsyn_32 = compute_absolute_division_gsyn32( ~, c, epsilon, R_1, R_2, Gm_3, dEsyn_31 )
            
           % Compute the maximum synaptic conductance.
           gsyn_32 = ( ( ( epsilon + R_2 ).*dEsyn_31 )./( dEsyn_31.*epsilon - c.*R_1 ) - 1 ).*( Gm_3./c );
           
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of numerator relative division subnetwork synapses.
        function gsyn_31 = compute_relative_division_gsyn31( ~, c, epsilon, R_3, Gm_3, dEsyn_31 )

            % Compute the maximum synaptic conductance.
            gsyn_31 = ( c.*R_3.*Gm_3 )./( epsilon.*dEsyn_31 - c.*R_3 );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of denominator relative division subnetwork synapses.
        function gsyn_32 = compute_relative_division_gsyn32( ~, c, epsilon, R_3, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            gsyn_32 = ( ( ( ( 1 + epsilon ).*dEsyn_31 )./( epsilon.*dEsyn_31 - c.*R_3 ) ) - 1 ).*Gm_3;
            
        end
        
        
    end
end