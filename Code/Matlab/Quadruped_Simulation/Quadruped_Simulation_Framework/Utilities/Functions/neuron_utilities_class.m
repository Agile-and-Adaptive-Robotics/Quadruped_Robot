classdef neuron_utilities_class

    % This class contains properties and methods related to neuron utilities.
    
    
    %% NEURON UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    %% NEURON UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_utilities_class(  )

            
            
        end
        
        
        %% Sodium Channel Functions
        
        % Implement a function to compute the steady state sodium channel activation and deactivation parameters.
        function mhinf = compute_mhinf( ~, U, Amh, Smh, dEmh )

            % Compute the steady state sodium channel activation / deactivation parameter.
            mhinf = 1./( 1 + Amh.*exp( -Smh.*( dEmh - U ) ) );
            
        end
        
        
        % Implement a function to compute the sodium channel conductances for a CPG subnetwork.
        function Gna = compute_CPG_Gna( self, R, Gm, Am, Sm, dEm, Ah, Sh, dEh, dEna )
            
            % Compute the steady state sodium channel activation & devactivation parameters at the upper equilibrium.
            minf_upper = self.compute_mhinf( R, Am, Sm, dEm );
            hinf_upper = self.compute_mhinf( R, Ah, Sh, dEh );

            % Compute the sodium channel conductance for each half-center neuron.
            Gna = ( Gm.*R )./( minf_upper.*hinf_upper.*( dEna - R ) );       % [S] Sodium Channel Conductance.  Equation straight from Szczecinski's CPG example.

        end
        
        
        %% Conductance Functions
        
        % Implement a function to compute the synpatic conductance of a synapse leaving this neuron.
        function G_syn = compute_synaptic_conductance( ~, U, R, g_syn_max )

            % Compute the synaptic conductance associated with this neuron.
            G_syn = g_syn_max.*( min( max( U./R, 0 ), 1 ) );

        end


        
        %% Current Functions
        
        % Implement a function to compute leak currents.
        function I_leak = compute_leak_current( ~, U, Gm )
        
            I_leak = -Gm.*U;
        
        end
        
        
        % Implement a function to compute a synaptic current.
        function I_syn = compute_synapse_current( self, U, R, g_syn_max, dE_syn )
                  
            % Compute the synaptic conductance of this synapse leaving this neuron.
            G_syn = self.compute_synaptic_conductance( U, R, g_syn_max );

            % Compute the synaptic current for this neuron.
            I_syn = G_syn.*( dE_syn - U );
            
        end
            
        
        % Implement a function to compute sodium channel currents.
        function I_na = compute_sodium_current( self, U, Gna, Am, Sm, dEm, Ah, Sh, dEh, dEna )
         
            % Compute the steady state sodium channel activation parameter.
            m_inf = self.compute_mhinf( U, Am, Sm, dEm );
                       
            % Compute the steady state sodium channel deactivaiton parameter.
            h_inf = self.compute_mhinf( UU, Ah, Sh, dEh );

            % Compute the sodium channel current.
            I_na = Gna.*m_inf.*h_inf.*( dEna - U );
            
        end
        
        
    end
    
    
end