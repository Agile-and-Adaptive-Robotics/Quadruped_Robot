classdef synapse_utilities_class

    % This class contains properties and methods related to synapse utilities.
    
    
    %% SYNAPSE UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
    end
    
    
    %% SYNAPSE UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_utilities_class(  )

            
            
        end
        
        
        %% Synapse Design Functions
        
        % Implement a function to compute the synaptic reversal potential for a transmission subnetwork.
        function dE_syn = compute_transmission_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = 194e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a modulation subnetwork.
        function dE_syn = compute_modulation_dEsyn( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn = 0;
            
        end
        
                
        % Implement a function to compute the first synaptic reversal potential for an addition subnetwork.
        function dE_syn1 = compute_addition_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end
        
        % Implement a function to compute the second synaptic reversal potential for an addition subnetwork.
        function dE_syn2 = compute_addition_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = 194e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a subtraction subnetwork.
        function dE_syn1 = compute_subtraction_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a subtraction subnetwork.
        function dE_syn2 = compute_subtraction_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = -40e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn1 = compute_multiplication_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn2 = compute_multiplication_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = -1e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a multiplication subnetwork.
        function dE_syn3 = compute_multiplication_dEsyn3( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn3 = -1e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a division subnetwork.
        function dE_syn1 = compute_division_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a division subnetwork.
        function dE_syn2 = compute_division_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = 0;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dE_syn1 = compute_derivation_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dE_syn2 = compute_derivation_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = -40e-3;
            
        end 
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dE_syn1 = compute_integration_dEsyn1( ~ )
           
            % Compute the synaptic reversal potential.
            dE_syn1 = -40e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dE_syn2 = compute_integration_dEsyn2( ~ )
           
            % Compute the synaptic reversal potential.
            dE_syn2 = -40e-3;
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dE_syn1 = compute_vb_integration_dEsyn1( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn1 = 194e-3;
            
        end         
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dE_syn2 = compute_vb_integration_dEsyn2( ~ )
            
            % Compute the synaptic reversal potential.
            dE_syn2 = -194e-3;
            
        end      
        
        
    end
end