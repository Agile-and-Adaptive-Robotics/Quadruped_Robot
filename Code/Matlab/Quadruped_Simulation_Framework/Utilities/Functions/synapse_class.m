classdef synapse_class

    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
     
        ID
        name
        
        dE_syn
        g_syn_max
        G_syn
        
        from_neuron_ID
        to_neuron_ID
    
        delta
        
        b_enabled
        
        synapse_utilities
        
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled )

            % Create an instance of the synapse utilities class.
            self.synapse_utilities = synapse_utilities_class(  );
            
            % Set the default synapse properties.
            if nargin < 8, self.b_enabled = true; else, self.b_enabled = b_enabled; end
            if nargin < 7, self.delta = 0; else, self.delta = delta; end
            if nargin < 6, self.to_neuron_ID = 0; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 5, self.from_neuron_ID = 0; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 4, self.g_syn_max = 1e-6; else, self.g_syn_max = g_syn_max; end
            if nargin < 3, self.dE_syn = -40e-3; else, self.dE_syn = dE_syn; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = 0; else, self.ID = ID; end

        end
        
        
        %% Synaptic Reversal Potential Compute Functions
        
        % Implement a function to compute the synaptic reversal potential of a driven multistate cpg subnetwork.
        function dE_syn = compute_driven_multistate_cpg_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_driven_multistate_cpg_dEsyn(  );
            
        end
        
                
        % Implement a function to compute the synaptic reversal potential of a transmission subnetwork.
        function dE_syn = compute_transmission_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_transmission_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a modulation subnetwork.
        function dE_syn = compute_modulation_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_modulation_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function dE_syn1 = compute_addition_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_addition_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function dE_syn2 = compute_addition_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_addition_dEsyn2(  );
            
        end
        

        % Implement a function to compute the synaptic reversal potential of absolute addition subnetwork synapses.
        function dE_syn = compute_absolute_addition_dEsyn( self )
        
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_absolute_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative addition subnetwork synapses.
        function dE_syn = compute_relative_addition_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_relative_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function dE_syn1 = compute_subtraction_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_subtraction_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function dE_syn2 = compute_subtraction_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_subtraction_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute subtraction subnetwork excitatory synapses.
        function dE_syn = compute_absolute_subtraction_dEsyn_excitatory( self )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.synapse_utilities.compute_absolute_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute subtraction subnetwork inhibitory synapses.
        function dE_syn = compute_absolute_subtraction_dEsyn_inhibitory( self )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.synapse_utilities.compute_absolute_subtraction_dEsyn_inhibitory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative subtraction subnetwork excitatory synapses.
        function dE_syn = compute_relative_subtraction_dEsyn_excitatory( self )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.synapse_utilities.compute_relative_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative subtraction subnetwork inhibitory synapses.
        function dE_syn = compute_relative_subtraction_dEsyn_inhibitory( self )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.synapse_utilities.compute_relative_subtraction_dEsyn_inhibitory(  );
            
        end
        
   
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dE_syn1 = compute_multiplication_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_multiplication_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dE_syn2 = compute_multiplication_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_multiplication_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dE_syn3 = compute_multiplication_dEsyn3( self )
            
           % Compute the synaptic reversal potential.
           dE_syn3 = self.synapse_utilities.compute_multiplication_dEsyn3(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an inversion subnetwork.
        function dE_syn = compute_inversion_dEsyn( self )
            
            % Compute the synaptic reversal potential.
            dE_syn = self.synapse_utilities.compute_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute inversion subnetwork synapses.
        function dE_syn = compute_absolute_inversion_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_absolute_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative inversion subnetwork synapses.
        function dE_syn = compute_relative_inversion_dEsyn( self )
            
           % Compute the synaptic reversal potential.
           dE_syn = self.synapse_utilities.compute_relative_inversion_dEsyn(  );
            
        end
        
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function dE_syn1 = compute_division_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function dE_syn2 = compute_division_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute division subnetwork numerator synapses.
        function dE_syn1 = compute_absolute_division_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_absolute_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute division subnetwork denominator neurons.
        function dE_syn1 = compute_absolute_division_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_absolute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative division subnetwork numerator synapses.
        function dE_syn1 = compute_relative_division_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_relative_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative division subnetwork denominator neurons.
        function dE_syn1 = compute_relative_division_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_relative_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function dE_syn1 = compute_derivation_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_derivation_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function dE_syn2 = compute_derivation_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_derivation_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dE_syn1 = compute_integration_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dE_syn2 = compute_integration_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_integration_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dE_syn1 = compute_vb_integration_dEsyn1( self )
            
           % Compute the synaptic reversal potential.
           dE_syn1 = self.synapse_utilities.compute_vb_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dE_syn2 = compute_vb_integration_dEsyn2( self )
            
           % Compute the synaptic reversal potential.
           dE_syn2 = self.synapse_utilities.compute_vb_integration_dEsyn2(  );
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions
                
        % Implement a function to compute the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function g_syn_max = compute_driven_multistate_cpg_gsynmax( self, delta_oscillatory, I_drive_max )
            
           % Compute the maximum synaptic conductance.
           g_syn_max = self.synapse_utilities.compute_driven_multistate_cpg_gsynmax( self.dE_syn, delta_oscillatory, I_drive_max );
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute addition synapses.
        function gsyn_nk = compute_absolute_addition_gsyn( self, c, R_k, Gm_n, dEsyn_nk, Iapp_n )
            
            % Compute the maximum synaptic conductance.
            gsyn_nk = self.synapse_utilities.compute_absolute_addition_gsyn( c, R_k, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative addition synapses.
        function gsyn_nk = compute_relative_addition_gsyn( self, c, n, R_n, Gm_n, dEsyn_nk, Iapp_n )
        
            % Compute the maximum synaptic conductance.
            gsyn_nk = self.synapse_utilities.compute_relative_addition_gsyn( c, n, R_n, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute subtraction synapses.
        function gsyn_nk = compute_absolute_subtraction_gsyn( self, c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n )
        
            % Compute the maximum synaptic conductance.
            gsyn_nk = self.synapse_utilities.compute_absolute_subtraction_gsyn( c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative subtraction synapses.
        function gsyn_nk = compute_relative_subtraction_gsyn( self, c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n )
            
            % Compute the maximum synaptic conductance.
            gsyn_nk = self.synapse_utilities.compute_relative_subtraction_gsyn( c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute inversion synapses.
        function gsyn_21 = compute_absolute_inversion_gsyn( self, c, epsilon, R_1, Gm_2, Iapp_2 )
        
            % Compute the maximum synaptic conductance.
            gsyn_21 = self.synapse_utilities.compute_absolute_inversion_gsyn( c, epsilon, R_1, Gm_2, Iapp_2 );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative inversion synapses.
        function gsyn_21 = compute_relative_inversion_gsyn( self, c, epsilon, R_2, Gm_2, Iapp_2 )
        
            % Compute the maximum synaptic conductance.
            gsyn_21 = self.synapse_utilities.compute_relative_inversion_gsyn( c, epsilon, R_2, Gm_2, Iapp_2 );
        
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute division numerator synapses.
        function gsyn_31 = compute_absolute_division_gsyn31( self, c, epsilon, R_1, Gm_3, dEsyn_31 )
            
            % Compute the maximum synaptic conductance.
            gsyn_31 = self.synapse_utilities.compute_absolute_division_gsyn31( c, epsilon, R_1, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute division denominator synapses.
        function gsyn_32 = compute_absolute_division_gsyn32( self, c, epsilon, R_1, R_2, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            gsyn_32 = self.synapse_utilities.compute_absolute_division_gsyn32( c, epsilon, R_1, R_2, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative division numerator synapses.
        function gsyn_31 = compute_relative_division_gsyn31( self, c, epsilon, R_3, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            gsyn_31 = self.synapse_utilities.compute_relative_division_gsyn31( c, epsilon, R_3, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative division denominator synapses.
        function gsyn_32 = compute_relative_division_gsyn32( self, c, epsilon, R_3, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            gsyn_32 = self.synapse_utilities.compute_relative_division_gsyn32( c, epsilon, R_3, Gm_3, dEsyn_31 );

        end
        
        
        %% Synaptic Reversal Potential Compute & Set Functions

        % Implement a function to compute and set the synaptic reversal potential of a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_driven_multistate_cpg_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a transmission subnetwork.
        function self = compute_set_transmission_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_transmission_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a modulation subnetwork.
        function self = compute_set_modulation_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_modulation_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function self = compute_set_addition_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_addition_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function self = compute_set_addition_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_addition_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute addition subnetwork synapses.
        function self = compute_set_absolute_addition_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative addition subnetwork synapses.
        function self = compute_set_relative_addition_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function self = compute_set_subtraction_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_subtraction_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function self = compute_set_subtraction_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_subtraction_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction excitatory synapses.
        function self = compute_set_absolute_subtraction_dEsyn_excitatory( self )
        
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction inhibitory synapses.
        function self = compute_set_absolute_subtraction_dEsyn_inhibitory( self )
        
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_subtraction_dEsyn_inhibitory(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative subtraction excitatory synapses.
        function self = compute_set_relative_subtraction_dEsyn_excitatory( self )
        
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative subtraction inhibitory synapses.
        function self = compute_set_relative_subtraction_dEsyn_inhibitory( self )
        
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_subtraction_dEsyn_inhibitory(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn3( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn3(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an inversion subnetwork synapse.
        function self = compute_set_inversion_dEsyn( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute inversion subentwork synapses.
        function self = compute_set_absolute_inversion_dEsyn( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_absolute_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative inversion subentwork synapses.
        function self = compute_set_relative_inversion_dEsyn( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_relative_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function self = compute_set_division_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function self = compute_set_division_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute division numerator synapses.
        function self = compute_set_absolute_division_dEsyn1( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_absolute_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute division denominator synapses.
        function self = compute_set_absolute_division_dEsyn2( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_absolute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative division numerator synapses.
        function self = compute_set_relative_division_dEsyn1( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_relative_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative division denominator synapses.
        function self = compute_set_relative_division_dEsyn2( self )
            
           % Compute and set the synaptic reversal potential.
           self.dE_syn = self.compute_relative_division_dEsyn2(  );
            
        end

        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function self = compute_set_derivation_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_derivation_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function self = compute_set_derivation_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_derivation_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_integration_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_integration_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_integration_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_vb_integration_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_vb_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_vb_integration_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_vb_integration_dEsyn2(  );
            
        end
        
        
        %% Maximum Synaptic Conductance Compute & Set Functions

        % Implement a function to compute and set the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_gsynmax( self, delta_oscillatory, I_drive_max )
            
            % Compute and set the maximum synaptic conductance.
            self.g_syn_max = self.compute_driven_multistate_cpg_gsynmax( delta_oscillatory, I_drive_max );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute addition synapses.
        function self = compute_set_absolute_addition_gsyn( self, c, R_k, Gm_n, dEsyn_nk, Iapp_n )
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_addition_gsyn( c, R_k, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative addition synapses.
        function self = compute_set_relative_addition_gsyn( self, c, n, R_n, Gm_n, dEsyn_nk, Iapp_n )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_addition_gsyn( c, n, R_n, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute subtraction synapses.
        function self = compute_set_absolute_subtraction_gsyn( self, c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_subtraction_gsyn( c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative subtraction synapses.
        function self = compute_set_relative_subtraction_gsyn( self, c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n )
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_subtraction_gsyn( c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute inversion synapses.
        function self = compute_set_absolute_inversion_gsyn( self, c, epsilon, R_1, Gm_2, Iapp_2 )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_inversion_gsyn( c, epsilon, R_1, Gm_2, Iapp_2 );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative inversion synapses.
        function self = compute_set_relative_inversion_gsyn( self, c, epsilon, R_2, Gm_2, Iapp_2 )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_inversion_gsyn( c, epsilon, R_2, Gm_2, Iapp_2 );
        
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute division numerator synapses.
        function self = compute_set_absolute_division_gsyn31( self, c, epsilon, R_1, Gm_3, dEsyn_31 )
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_division_gsyn31( c, epsilon, R_1, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute division denominator synapses.
        function self = compute_set_absolute_division_gsyn32( self, c, epsilon, R_1, R_2, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_division_gsyn32( c, epsilon, R_1, R_2, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative division numerator synapses.
        function self = compute_set_relative_division_gsyn31( self, c, epsilon, R_3, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_division_gsyn31( c, epsilon, R_3, Gm_3, dEsyn_31 );

        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative division denominator synapses.
        function self = compute_set_relative_division_gsyn32( self, c, epsilon, R_3, Gm_3, dEsyn_31 )
        
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_division_gsyn32( c, epsilon, R_3, Gm_3, dEsyn_31 );

        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this syanpse is enabled.
        function self = toggle_enabled( self )
            
            % Toggle whether the syanpse is enabled.
           self.b_enabled = ~self.b_enabled; 
            
        end
        
        
        % Implement a function to enable this syanpse.
        function self = enable( self )
            
           % Enable this syanpse.
           self.b_enabled = true;
            
        end
        
        
        % Implement a function to disable this syanpse.
        function self = disable( self )
            
           % Disable this syanpse.
           self.b_enabled = false;
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save synapse data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load synapse data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse.mat'; end
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

