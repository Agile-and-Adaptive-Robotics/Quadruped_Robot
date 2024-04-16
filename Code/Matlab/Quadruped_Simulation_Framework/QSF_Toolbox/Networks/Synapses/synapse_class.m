classdef synapse_class
    
    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID                                                                                                              % [#] Synapse ID
        name                                                                                                            % [-] Synapse Name
        
        dE_syn                                                                                                          % [V] Synaptic Reversal Potential
        g_syn_max                                                                                                       % [S] Maximum Synaptic Conductance
        G_syn                                                                                                           % [S] Synaptic Conductance
        
        from_neuron_ID                                                                                                  % [#] From Neuron ID
        to_neuron_ID                                                                                                    % [#] To Neuron ID
        
        delta                                                                                                           % [V] CPG Equilibrium Offset
        
        b_enabled                                                                                                       % [T/F] Synapse Enabled Flag
        
        synapse_utilities                                                                                               % [-] Synapse Utilities Class
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                                                                              % [V] Activation Domain
        Gm_DEFAULT = 1e-6;                                                                                              % [S] Membrane Conductance
       
        % Define the maximum synaptic conductance.
        gsyn_max_DEFAULT = 1e-6;                                                                                         % [S] Maximum Synaptic Conductance
        
        % Define the synaptic reversal potential parameters.
        dEsyn_maximum_DEFAULT = 194e-3;                                                                                 % [V] Maximum Synaptic Reversal Potential
        dEsyn_minimum_DEFAULT = -40e-3;                                                                                 % [V] Minimum Synaptic Reversal Potential
        dEsyn_small_negative_DEFAULT = -1e-3;                                                                           % [V] Small Negative Synaptic Reversal Potential
        
        % Define the applied current parameters.
        Idrive_max_DEFAULT = 1.25e-9;                                                                                   % [A] Maximum Drive Current
        Iapp_absolute_addition_DEFAULT = 0;                                                                             % [A] Absolute Addition Applied Current
        Iapp_relative_addition_DEFAULT = 0;                                                                             % [A] Relative Addition Applied Current
        Iapp_absolute_subtraction_DEFAULT = 0;                                                                          % [A] Absolute Subtraction Applied Current
        Iapp_relative_subtraction_DEFAULT = 0;                                                                          % [A] Relative Subtraction Applied Current
        Iapp1_absolute_inversion_DEFAULT = 0;                                                                           % [A] Absolute Inversion Applied Current 1
        Iapp2_absolute_inversion_DEFAULT = 2e-8;                                                                        % [A] Absolute Inversion Applied Current 2
        Iapp1_relative_inversion_DEFAULT = 0;                                                                           % [A] Relative Inversion Applied Current 1
        Iapp2_relative_inversion_DEFAULT = 2e-8;                                                                        % [A] Relative Inversion Applied Current 2
        Iapp_absolute_division_DEFAULT = 0;                                                                             % [A] Absolute Division Applied Current
        Iapp_relative_division_DEFAULT = 0;                                                                             % [A] Relative Division Applied Current
        
        % Define the CPG parameters.
        delta_oscillatory_DEFAULT = 0.01e-3;                                                                            % [-] CPG Oscillatory Delta
        delta_bistable_DEFAULT = -10e-3;                                                                                % [-] CPG Bistable Delta
        delta_noncpg_DEFAULT = 0;                                                                                      	% [-] CPG Delta
        
        % Define the subnetwork gain parameters.
        c_absolute_addition_DEFAULT = 1;                                                                                % [-] Absolute Addition Subnetwork Gain
        c_relative_addition_DEFAULT = 1;                                                                                % [-] Relative Addition Subnetwork Gain
        c_absolute_subtraction_DEFAULT = 1;                                                                             % [-] Absolute Subtraction Subnetwork Gain
        c_relative_subtraction_DEFAULT = 1;                                                                             % [-] Relative Subtraction Subnetwork Gain
        c_absolute_inversion_DEFAULT = 1;                                                                               % [-] Absolute Inversion Subnetwork Gain
        c_relative_inversion_DEFAULT = 1;                                                                               % [-] Relative Inversion Subnetwork Gain
        c_absolute_division_DEFAULT = 1;                                                                                % [-] Absolute Division Subnetwork Gain
        c_relative_division_DEFAULT = 1;                                                                                % [-] Relative Division Subnetwork Gain
        c_absolute_multiplication_DEFAULT = 1;                                                                          % [-] Absolute Multiplication Subnetwork Gain
        c_relative_multiplication_DEFAULT = 1;                                                                          % [-] Relative Multiplication Subnetwork Gain
        
        % Define the subnetwork offset parameters.
        epsilon_DEFAULT = 1e-6;                                                                                         % [-] Subnetwork Input Offset
        delta_DEFAULT = 1e-6;                                                                                           % [-] Subnetwork Output Offset
        
        % Define the subnetwork neuron numbers.
        num_addition_neurons_DEFAULT = 3;                                                                               % [#] Number of Addition Neurons
               
        % Define the synapse identification parameters.
        to_neuron_ID_DEFAULT = 0;                                                                                       % [#] To Neuron ID
        from_neuron_ID_DEFAULT = 0;                                                                                     % [#] From Neuron ID
        ID_DEFAULT = 0;                                                                                                 % [#] Synapse ID

        alpha_DEFAULT = 1e-6;                                                                                           % [-] Division Subnetwork Denominator Offset
        
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
            if nargin < 7, self.delta = self.delta_noncpg_DEFAULT; else, self.delta = delta; end
            if nargin < 6, self.to_neuron_ID = self.to_neuron_ID_DEFAULT; else, self.to_neuron_ID = to_neuron_ID; end
            if nargin < 5, self.from_neuron_ID = self.from_neuron_ID_DEFAULT; else, self.from_neuron_ID = from_neuron_ID; end
            if nargin < 4, self.g_syn_max = self.gsyn_max_DEFAULT; else, self.g_syn_max = g_syn_max; end
            if nargin < 3, self.dE_syn = self.dEsyn_minimum_DEFAULT; else, self.dE_syn = dE_syn; end
            if nargin < 2, self.name = ''; else, self.name = name; end
            if nargin < 1, self.ID = self.ID_DEFAULT; else, self.ID = ID; end
            
        end
        
        
        %% Synaptic Reversal Potential Compute Functions
        
        % Implement a function to compute the synaptic reversal potential of a driven multistate cpg subnetwork.
        function dEs = compute_driven_multistate_cpg_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_driven_multistate_cpg_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a transmission subnetwork.
        function dEs = compute_transmission_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_transmission_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a modulation subnetwork.
        function dEs = compute_modulation_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_modulation_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function dEs1 = compute_addition_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_addition_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function dEs2 = compute_addition_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_addition_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute addition subnetwork synapses.
        function dEs = compute_absolute_addition_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_absolute_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative addition subnetwork synapses.
        function dEs = compute_relative_addition_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_relative_addition_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function dEs1 = compute_subtraction_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_subtraction_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function dEs2 = compute_subtraction_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_subtraction_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute subtraction subnetwork excitatory synapses.
        function dEs = compute_absolute_subtraction_dEsyn_excitatory( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_absolute_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute subtraction subnetwork inhibitory synapses.
        function dEs = compute_absolute_subtraction_dEsyn_inhibitory( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_absolute_subtraction_dEsyn_inhibitory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative subtraction subnetwork excitatory synapses.
        function dEs = compute_relative_subtraction_dEsyn_excitatory( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_relative_subtraction_dEsyn_excitatory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative subtraction subnetwork inhibitory synapses.
        function dEs = compute_relative_subtraction_dEsyn_inhibitory( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_relative_subtraction_dEsyn_inhibitory(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dEs1 = compute_multiplication_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_multiplication_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dEs2 = compute_multiplication_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_multiplication_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function dEs3 = compute_multiplication_dEsyn3( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs3 = synapse_utilities.compute_multiplication_dEsyn3(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an inversion subnetwork.
        function dEs = compute_inversion_dEsyn( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_inversion_dEsyn(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute inversion subnetwork synapses.
        function dEs = compute_absolute_inversion_dEsyn( self, c, delta, synapse_utilities )
            
            % Define the default input argument.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end
            if nargin < 3, delta = self.delta_DEFAULT; end                                                                   	% [V] Output Offset
            if nargin < 2, c = self.c_absolute_inversion_DEFAULT; end                                                          	% [-] Gain
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_absolute_inversion_dEsyn( c, delta );                                       % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative inversion subnetwork synapses.
        function dEs = compute_relative_inversion_dEsyn( self, epsilon, delta, R_2, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end
            if nargin < 4, R_2 = self.R_DEFAULT; end                                    % [V] Activation Domain
            if nargin < 3, delta = self.delta_DEFAULT; end                              % [V] Output Offset
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                          % [V] Input Offset
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_relative_inversion_dEsyn( epsilon, delta, R_2 );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function dEs1 = compute_division_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_division_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function dEs2 = compute_division_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute division subnetwork numerator synapses.
        function dEs1 = compute_absolute_division_dEsyn1( self, c, alpha, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                      % [-] Division Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_absolute_division_DEFAULT; end                            % [-] Absolute Division Subnetwork Gain
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_absolute_division_dEsyn1( c, alpha );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of absolute division subnetwork denominator neurons.
        function dEs2 = compute_absolute_division_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_absolute_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative division subnetwork numerator synapses.
        function dEs1 = compute_relative_division_dEsyn1( self, c, alpha, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end
            if nargin < 3, alpha = self.alpha_DEFAULT; end
            if nargin < 2, c = self.c_absolute_division_DEFAULT; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_relative_division_dEsyn1( c, alpha );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of relative division subnetwork denominator neurons.
        function dEs1 = compute_relative_division_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_relative_division_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function dEs1 = compute_derivation_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_derivation_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function dEs2 = compute_derivation_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_derivation_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dEs1 = compute_integration_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dEs2 = compute_integration_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_integration_dEsyn2(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dEs1 = compute_vb_integration_dEsyn1( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_vb_integration_dEsyn1(  );
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function dEs2 = compute_vb_integration_dEsyn2( self, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 2, synapse_utilities = self.synapse_utilities; end
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_vb_integration_dEsyn2(  );
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions
        
        % Implement a function to compute the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function gs = compute_driven_multistate_cpg_gsynmax( self, dEs, delta_oscillatory, Idrive_max, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end
            if nargin < 4, Idrive_max = self.Idrive_max_DEFAULT; end                                                                          % [A] Maximum Drive Current
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end                                                                      % [-] Oscillatory Delta
            if nargin < 2, dEs = self.dE_syn; end                                                                                            % [V] Synaptic Reversal Potential
            
            % Compute the maximum synaptic conductance.
            gs = synapse_utilities.compute_driven_multistate_cpg_gsynmax( dEs, delta_oscillatory, Idrive_max );                 % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute addition synapses.
        function gs_nk = compute_absolute_addition_gsyn( self, c, R_k, Gm_n, dEs_nk, Ia_n, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 7, synapse_utilities = self.synapse_utilities; end
            if nargin < 6, Ia_n = self.Iapp_absolute_addition_DEFAULT; end                                                                    % [A] Applied Current
            if nargin < 5, dEs_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 4, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 3, R_k = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 2, c = self.c_absolute_addition_DEFAULT; end                                                                            % [-] Absolute Addition Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            gs_nk = synapse_utilities.compute_absolute_addition_gsyn( c, R_k, Gm_n, dEs_nk, Ia_n );                                  % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative addition synapses.
        function gs_nk = compute_relative_addition_gsyn( self, c, n, R_n, Gm_n, dEs_nk, Ia_n, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 8, synapse_utilities = self.synapse_utilities; end
            if nargin < 7, Ia_n = self.Iapp_relative_addition_DEFAULT; end                                                                    % [A] Applied Current
            if nargin < 6, dEs_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 4, R_n = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 3, n = self.num_addition_neurons_DEFAULT; end                                                                           % [#] Number of Addition Neurons
            if nargin < 2, c = self.c_relative_addition_DEFAULT; end                                                                            % [-] Relative Addition Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            gs_nk = synapse_utilities.compute_relative_addition_gsyn( c, n, R_n, Gm_n, dEs_nk, Ia_n );                               % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute subtraction synapses.
        function gs_nk = compute_absolute_subtraction_gsyn( self, c, s_k, R_k, Gm_n, dEs_nk, Ia_n, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 8, synapse_utilities = self.synapse_utilities; end
            if nargin < 7, Ia_n = self.Iapp_absolute_subtraction_DEFAULT; end                                                                 % [A] Applied Current
            if nargin < 6, dEs_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 4, R_k = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 3, s_k = 1; end                                                                                                         % [-] Excitation / Inhibition Sign
            if nargin < 2, c = self.c_absolute_subtraction_DEFAULT; end                                                                         % [-] Absolute Subtraction Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            gs_nk = synapse_utilities.compute_absolute_subtraction_gsyn( c, s_k, R_k, Gm_n, dEs_nk, Ia_n );                          % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative subtraction synapses.
        function gs_nk = compute_relative_subtraction_gsyn( self, c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 9, synapse_utilities = self.synapse_utilities; end
            if nargin < 8, Ia_n = self.Iapp_relative_subtraction_DEFAULT; end                                                                 % [A] Applied Current
            if nargin < 7, dEs_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 5, R_n = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 4, s_k = 1; end                                                                                                         % [-] Excitation / Inhibition Sign
            if nargin < 3, npm_k = 1; end                                                                                                       % [#] Number of Excitatory / Inhibitory Synapses
            if nargin < 2, c = self.c_relative_subtraction_DEFAULT; end                                                                         % [-] Relative Subtraction Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            gs_nk = synapse_utilities.compute_relative_subtraction_gsyn( c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n );                   % [S] Maximum Synaptic Conductance
            
        end
        
        
%         % Implement a function to compute the maximum synaptic conductance of absolute inversion synapses.
%         function gsyn_21 = compute_absolute_inversion_gsyn( self, c, epsilon, R_1, Gm_2, Iapp_2 )
%             
%             % Define the default input arguments.
%             if nargin < 6, Iapp_2 = self.Iapp2_absolute_inversion_DEFAULT; end                                                                  % [A] Applied Current
%             if nargin < 5, Gm_2 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Inversion Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_inversion_DEFAULT; end                                                                           % [-] Absolute Inversion Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             gsyn_21 = self.synapse_utilities.compute_absolute_inversion_gsyn( c, epsilon, R_1, Gm_2, Iapp_2 );                                  % [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute the maximum synaptic conductance of absolute inversion synapses.
        function gs_21 = compute_absolute_inversion_gsyn( self, dEs21, Ia2, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end
            if nargin < 3, Ia2 = self.Iapp2_absolute_inversion_DEFAULT; end                                          % [A] Applied Current
            if nargin < 2, dEs21 = self.dEsyn_small_negative_DEFAULT; end                                            % [V] Synaptic Reversal Potential
            
            % Compute the maximum synaptic conductance.
            gs_21 = synapse_utilities.compute_absolute_inversion_gsyn( dEs21, Ia2 );                    	% [S] Maximum Synaptic Conductance
            
        end

        
%         % Implement a function to compute the maximum synaptic conductance of relative inversion synapses.
%         function gsyn_21 = compute_relative_inversion_gsyn( self, c, epsilon, R_2, Gm_2, Iapp_2 )
%             
%             % Define the default input arguments.
%             if nargin < 6, Iapp_2 = self.Iapp2_relative_inversion_DEFAULT; end                                                                  % [A] Applied Current
%             if nargin < 5, Gm_2 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Relative Inversion Subnetwork Offset
%             if nargin < 2, c = self.c_relative_inversion_DEFAULT; end                                                                           % [-] Relative inversion Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             gsyn_21 = self.synapse_utilities.compute_relative_inversion_gsyn( c, epsilon, R_2, Gm_2, Iapp_2 );                                  % [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute the maximum synaptic conductance of relative inversion synapses.
        function gs21 = compute_relative_inversion_gsyn( self, dEs21, Ia2, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end
            if nargin < 3, Ia2 = self.Iapp2_absolute_inversion_DEFAULT; end                                          % [A] Applied Current
            if nargin < 2, dEs21 = self.dEsyn_small_negative_DEFAULT; end                                            % [V] Synaptic Reversal Potential
            
            % Compute the maximum synaptic conductance.
            gs21 = synapse_utilities.compute_relative_inversion_gsyn( dEs21, Ia2 );                      	% [S] Maximum Synaptic Conductance
            
        end


%         % Implement a function to compute the maximum synaptic conductance of absolute division numerator synapses.
%         function gsyn_31 = compute_absolute_division_gsyn31( self, c, epsilon, R_1, Gm_3, dEsyn_31 )
%             
%             % Define the default input arugments.
%             if nargin < 6, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
%             if nargin < 5, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_division_DEFAULT; end                                                                            % [-] Absolute Division Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             gsyn_31 = self.synapse_utilities.compute_absolute_division_gsyn31( c, epsilon, R_1, Gm_3, dEsyn_31 );                             	% [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute the maximum synaptic conductance of absolute division numerator synapses.
        function gs31 = compute_absolute_division_gsyn31( self, alpha, epsilon, R1, Gm3, synapse_utilities )
            
            % Define the default input arugments.
            if nargin < 6, synapse_utilities = self.synapse_utilities; end
            if nargin < 5, Gm3 = self.Gm_DEFAULT; end                                                                  % [S] Membrane Conductance
            if nargin < 4, R1 = self.R_DEFAULT; end                                                                    % [V] Activation Domain
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Absolute Division Subnetwork Offset
            if nargin < 2, alpha = self.alpha_DEFAULT; end                                                              % [-] Absolute Division Subnetwork Denominator Adjustment
            
            % Compute the maximum synaptic conductance.
            gs31 = synapse_utilities.compute_absolute_division_gsyn31( alpha, epsilon, R1, Gm3 );                             	% [S] Maximum Synaptic Conductance
            
        end

        
%         % Implement a function to compute the maximum synaptic conductance of absolute division denominator synapses.
%         function gsyn_32 = compute_absolute_division_gsyn32( self, c, epsilon, R_1, R_2, Gm_3, dEsyn_31 )
%             
%             % Define the default input arugments.
%             if nargin < 7, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
%             if nargin < 6, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 5, R_2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_division_DEFAULT; end                                                                            % [-] Absolute Division Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             gsyn_32 = self.synapse_utilities.compute_absolute_division_gsyn32( c, epsilon, R_1, R_2, Gm_3, dEsyn_31 );                        	% [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute the maximum synaptic conductance of absolute division denominator synapses.
        function gs32 = compute_absolute_division_gsyn32( self, epsilon, R2, Gm3, synapse_utilities )
            
            % Define the default input arugments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 3, R2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
            
            % Compute the maximum synaptic conductance.
            gs32 = synapse_utilities.compute_absolute_division_gsyn32( epsilon, R2, Gm3 );                                      % [S] Maximum Synaptic Conductance
                        
        end

        
        % Implement a function to compute the maximum synaptic conductance of relative division numerator synapses.
        function gs31 = compute_relative_division_gsyn31( self, R3, Gm3, dEs31, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end
            if nargin < 4, dEs31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 3, Gm3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 2, R3 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain

            % Compute the maximum synaptic conductance.
            gs31 = synapse_utilities.compute_relative_division_gsyn31( R3, Gm3, dEs31 );                               % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative division denominator synapses.
        function gs32 = compute_relative_division_gsyn32( self, c, alpha, epsilon, R3, Gm3, dEs31, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 8, synapse_utilities = self.synapse_utilities; end
            if nargin < 7, dEs31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 6, Gm3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 5, R3 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Relative Division Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end
            if nargin < 2, c = self.c_relative_division_DEFAULT; end                                                                            % [-] Relative Division Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            gs32 = synapse_utilities.compute_relative_division_gsyn32( c, alpha, epsilon, R3, Gm3, dEs31 );                               % [S] Maximum Synaptic Conductance
            
        end
        
        
        %% Synaptic Reversal Potential Compute & Set Functions
        
        % Implement a function to compute and set the synaptic reversal potential of a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_driven_multistate_cpg_dEsyn(  );                                                                         % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a transmission subnetwork.
        function self = compute_set_transmission_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_transmission_dEsyn(  );                                                                                  % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a modulation subnetwork.
        function self = compute_set_modulation_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_modulation_dEsyn(  );                                                                                    % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function self = compute_set_addition_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_addition_dEsyn1(  );                                                                                     % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function self = compute_set_addition_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_addition_dEsyn2(  );                                                                                     % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute addition subnetwork synapses.
        function self = compute_set_absolute_addition_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_addition_dEsyn(  );                                                                             % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative addition subnetwork synapses.
        function self = compute_set_relative_addition_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_addition_dEsyn(  );                                                                          	% [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function self = compute_set_subtraction_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_subtraction_dEsyn1(  );                                                                                  % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function self = compute_set_subtraction_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_subtraction_dEsyn2(  );                                                                                  % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction excitatory synapses.
        function self = compute_set_absolute_subtraction_dEsyn_excitatory( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_subtraction_dEsyn_excitatory(  );                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction inhibitory synapses.
        function self = compute_set_absolute_subtraction_dEsyn_inhibitory( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_subtraction_dEsyn_inhibitory(  );                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative subtraction excitatory synapses.
        function self = compute_set_relative_subtraction_dEsyn_excitatory( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_subtraction_dEsyn_excitatory(  );                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative subtraction inhibitory synapses.
        function self = compute_set_relative_subtraction_dEsyn_inhibitory( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_subtraction_dEsyn_inhibitory(  );                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn1(  );                                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn2(  );                                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function self = compute_set_multiplication_dEsyn3( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_multiplication_dEsyn3(  );                                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an inversion subnetwork synapse.
        function self = compute_set_inversion_dEsyn( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_inversion_dEsyn(  );                                                                                     % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute inversion subentwork synapses.
        function self = compute_set_absolute_inversion_dEsyn( self, c, delta )
            
            % Define the default input argument.
            if nargin < 3, delta = self.delta_DEFAULT; end                                                                   	% [V] Output Offset
            if nargin < 2, c = self.c_absolute_inversion_DEFAULT; end                                                         	% [-] Gain
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_inversion_dEsyn( c, delta );                                                   	% [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative inversion subentwork synapses.
        function self = compute_set_relative_inversion_dEsyn( self, epsilon, delta, R_2 )
            
            % Define the default input arguments.
            if nargin < 4, R_2 = self.R_DEFAULT; end                                                                            % [V] Activation Domain
            if nargin < 3, delta = self.delta_DEFAULT; end                                                                      % [V] Output Offset
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                                                  % [V] Input Offset
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_inversion_dEsyn( epsilon, delta, R_2 );                                       	% [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function self = compute_set_division_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_division_dEsyn1(  );                                                                                     % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function self = compute_set_division_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_division_dEsyn2(  );                                                                                     % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute division numerator synapses.
        function self = compute_set_absolute_division_dEsyn1( self, c, alpha )
            
            % Define the default input arguments.
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                      % [-] Division Subnetwork Denominator Adjustment
            if nargin < 2, c = self.c_absolute_division_DEFAULT; end                            % [-] Absolute Division Subnetwork Gain
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_division_dEsyn1( c, alpha );                                                                            % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute division denominator synapses.
        function self = compute_set_absolute_division_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_absolute_division_dEsyn2(  );                                                                            % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative division numerator synapses.
        function self = compute_set_relative_division_dEsyn1( self, c, alpha )
            
            % Define the default input arguments.
            if nargin < 3, alpha = self.alpha_DEFAULT; end
            if nargin < 2, c = self.c_absolute_division_DEFAULT; end
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_division_dEsyn1( c, alpha );                                                                            % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of relative division denominator synapses.
        function self = compute_set_relative_division_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_relative_division_dEsyn2(  );                                                                            % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function self = compute_set_derivation_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_derivation_dEsyn1(  );                                                                                   % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function self = compute_set_derivation_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_derivation_dEsyn2(  );                                                                                   % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_integration_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_integration_dEsyn1(  );                                                                                  % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_integration_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_integration_dEsyn2(  );                                                                                  % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_vb_integration_dEsyn1( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_vb_integration_dEsyn1(  );                                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function self = compute_set_vb_integration_dEsyn2( self )
            
            % Compute and set the synaptic reversal potential.
            self.dE_syn = self.compute_vb_integration_dEsyn2(  );                                                                               % [V] Synaptic Reversal Potential
            
        end
        
        
        %% Maximum Synaptic Conductance Compute & Set Functions
        
        % Implement a function to compute and set the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_gsynmax( self, dE_syn, delta_oscillatory, I_drive_max )
            
            % Define the default input arguments.
            if nargin < 4, I_drive_max = self.Idrive_max_DEFAULT; end                                                                          % [A] Maximum Drive Current
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end                                                                      % [-] Oscillatory Delta
            if nargin < 2, dE_syn = self.dE_syn; end                                                                                            % [V] Synaptic Reversal Potential
            
            % Compute and set the maximum synaptic conductance.
            self.g_syn_max = self.compute_driven_multistate_cpg_gsynmax( dE_syn, delta_oscillatory, I_drive_max );                              % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute addition synapses.
        function self = compute_set_absolute_addition_gsyn( self, c, R_k, Gm_n, dEsyn_nk, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 6, Iapp_n = self.Iapp_absolute_addition_DEFAULT; end                                                                    % [A] Applied Current
            if nargin < 5, dEsyn_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 4, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 3, R_k = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 2, c = self.c_absolute_addition_DEFAULT; end                                                                            % [-] Absolute Addition Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_addition_gsyn( c, R_k, Gm_n, dEsyn_nk, Iapp_n );                                             % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative addition synapses.
        function self = compute_set_relative_addition_gsyn( self, c, n, R_n, Gm_n, dEsyn_nk, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 7, Iapp_n = self.Iapp_relative_addition_DEFAULT; end                                                                    % [A] Applied Current
            if nargin < 6, dEsyn_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 4, R_n = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 3, n = self.num_addition_neurons_DEFAULT; end                                                                           % [#] Number of Addition Neurons
            if nargin < 2, c = self.c_relative_addition_DEFAULT; end                                                                            % [-] Relative Addition Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_addition_gsyn( c, n, R_n, Gm_n, dEsyn_nk, Iapp_n );                                          % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute subtraction synapses.
        function self = compute_set_absolute_subtraction_gsyn( self, c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 7, Iapp_n = self.Iapp_absolute_subtraction_DEFAULT; end                                                                 % [A] Applied Current
            if nargin < 6, dEsyn_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 4, R_k = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 3, s_k = 1; end                                                                                                         % [-] Excitation / Inhibition Sign
            if nargin < 2, c = self.c_absolute_subtraction_DEFAULT; end                                                                         % [-] Absolute Subtraction Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_subtraction_gsyn( c, s_k, R_k, Gm_n, dEsyn_nk, Iapp_n );                                     % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative subtraction synapses.
        function self = compute_set_relative_subtraction_gsyn( self, c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 8, Iapp_n = self.Iapp_relative_subtraction_DEFAULT; end                                                                 % [A] Applied Current
            if nargin < 7, dEsyn_nk = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 5, R_n = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 4, s_k = 1; end                                                                                                         % [-] Excitation / Inhibition Sign
            if nargin < 3, npm_k = 1; end                                                                                                       % [#] Number of Excitatory / Inhibitory Synapses
            if nargin < 2, c = self.c_relative_subtraction_DEFAULT; end                                                                         % [-] Relative Subtraction Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_subtraction_gsyn( c, npm_k, s_k, R_n, Gm_n, dEsyn_nk, Iapp_n );                              % [S] Maximum Synaptic Conductance
            
        end
        
        
%         % Implement a function to compute and set the maximum synaptic conductance of absolute inversion synapses.
%         function self = compute_set_absolute_inversion_gsyn( self, c, epsilon, R_1, Gm_2, Iapp_2 )
%             
%             % Define the default input arguments.
%             if nargin < 6, Iapp_2 = self.Iapp2_absolute_inversion_DEFAULT; end                                                                  % [A] Applied Current
%             if nargin < 5, Gm_2 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Inversion Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_inversion_DEFAULT; end                                                                           % [-] Absolute Inversion Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             self.g_syn_max = self.compute_absolute_inversion_gsyn( c, epsilon, R_1, Gm_2, Iapp_2 );                                             % [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute and set the maximum synaptic conductance of absolute inversion synapses.
        function self = compute_set_absolute_inversion_gsyn( self, dE_syn21, Iapp_2 )
            
            % Define the default input arguments.
            if nargin < 3, Iapp_2 = self.Iapp2_absolute_inversion_DEFAULT; end                                          % [A] Applied Current
            if nargin < 2, dE_syn21 = self.dEsyn_small_negative_DEFAULT; end                                            % [V] Synaptic Reversal Potential
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_inversion_gsyn( dE_syn21, Iapp_2 );                                	% [S] Maximum Synaptic Conductance
            
        end

        
%         % Implement a function to compute and set the maximum synaptic conductance of relative inversion synapses.
%         function self = compute_set_relative_inversion_gsyn( self, c, epsilon, R_2, Gm_2, Iapp_2 )
%             
%             % Define the default input arguments.
%             if nargin < 6, Iapp_2 = self.Iapp2_relative_inversion_DEFAULT; end                                                                  % [A] Applied Current
%             if nargin < 5, Gm_2 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Relative Inversion Subnetwork Offset
%             if nargin < 2, c = self.c_relative_inversion_DEFAULT; end                                                                           % [-] Relative inversion Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             self.g_syn_max = self.compute_relative_inversion_gsyn( c, epsilon, R_2, Gm_2, Iapp_2 );                                             % [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute and set the maximum synaptic conductance of relative inversion synapses.
        function self = compute_set_relative_inversion_gsyn( self, dE_syn21, Iapp_2 )
            
            % Define the default input arguments.
            if nargin < 3, Iapp_2 = self.Iapp2_absolute_inversion_DEFAULT; end                                          % [A] Applied Current
            if nargin < 2, dE_syn21 = self.dEsyn_small_negative_DEFAULT; end                                            % [V] Synaptic Reversal Potential
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_inversion_gsyn( dE_syn21, Iapp_2 );                                	% [S] Maximum Synaptic Conductance
            
        end

        
%         % Implement a function to compute and set the maximum synaptic conductance of absolute division numerator synapses.
%         function self = compute_set_absolute_division_gsyn31( self, c, epsilon, R_1, Gm_3, dEsyn_31 )
%             
%             % Define the default input arugments.
%             if nargin < 6, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
%             if nargin < 5, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_division_DEFAULT; end                                                                            % [-] Absolute Division Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             self.g_syn_max = self.compute_absolute_division_gsyn31( c, epsilon, R_1, Gm_3, dEsyn_31 );                                          % [S] Maximum Synaptic Conductance
%             
%         end


        % Implement a function to compute and set the maximum synaptic conductance of absolute division numerator synapses.
        function self = compute_set_absolute_division_gsyn31( self, alpha, epsilon, R_1, Gm_3 )
            
            % Define the default input arugments.
            if nargin < 5, Gm_3 = self.Gm_DEFAULT; end                                                                  % [S] Membrane Conductance
            if nargin < 4, R_1 = self.R_DEFAULT; end                                                                    % [V] Activation Domain
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                          % [-] Absolute Division Subnetwork Offset
            if nargin < 2, alpha = self.alpha_DEFAULT; end                                                              % [-] Absolute Division Subnetwork Denominator Adjustment
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_division_gsyn31( alpha, epsilon, R_1, Gm_3 );                                          % [S] Maximum Synaptic Conductance
            
        end
        
        
%         % Implement a function to compute and set the maximum synaptic conductance of absolute division denominator synapses.
%         function self = compute_set_absolute_division_gsyn32( self, c, epsilon, R_1, R_2, Gm_3, dEsyn_31 )
%             
%             % Define the default input arugments.
%             if nargin < 7, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
%             if nargin < 6, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
%             if nargin < 5, R_2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 4, R_1 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
%             if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
%             if nargin < 2, c = self.c_absolute_division_DEFAULT; end                                                                            % [-] Absolute Division Subnetwork Gain
%             
%             % Compute the maximum synaptic conductance.
%             self.g_syn_max = self.compute_absolute_division_gsyn32( c, epsilon, R_1, R_2, Gm_3, dEsyn_31 );                                     % [S] Maximum Synaptic Conductance
%             
%         end
        

        % Implement a function to compute and set the maximum synaptic conductance of absolute division denominator synapses.
        function self = compute_set_absolute_division_gsyn32( self, epsilon, R_2, Gm_3 )
            
            % Define the default input arugments.
            if nargin < 4, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 3, R_2 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Absolute Division Subnetwork Offset
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_absolute_division_gsyn32( epsilon, R_2, Gm_3 );                                     % [S] Maximum Synaptic Conductance
            
        end        


        % Implement a function to compute and set the maximum synaptic conductance of relative division numerator synapses.
        function self = compute_set_relative_division_gsyn31( self, R_3, Gm_3, dEsyn_31 )
            
            % Define the default input arguments.
            if nargin < 4, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 3, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 2, R_3 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_division_gsyn31( R_3, Gm_3, dEsyn_31 );                                          % [S] Maximum Synaptic Conductance
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative division denominator synapses.
        function self = compute_set_relative_division_gsyn32( self, c, alpha, epsilon, R_3, Gm_3, dEsyn_31 )
            
            % Define the default input arguments.
            if nargin < 7, dEsyn_31 = self.dE_syn; end                                                                                          % [V] Synaptic Reversal Potential
            if nargin < 6, Gm_3 = self.Gm_DEFAULT; end                                                                                          % [S] Membrane Conductance
            if nargin < 5, R_3 = self.R_DEFAULT; end                                                                                            % [V] Activation Domain
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                                  % [-] Relative Division Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end
            if nargin < 2, c = self.c_relative_division_DEFAULT; end                                                                            % [-] Relative Division Subnetwork Gain
            
            % Compute the maximum synaptic conductance.
            self.g_syn_max = self.compute_relative_division_gsyn32( c, alpha, epsilon, R_3, Gm_3, dEsyn_31 );                                          % [S] Maximum Synaptic Conductance
            
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

