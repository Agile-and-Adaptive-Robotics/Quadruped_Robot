classdef synapse_utilities_class
    
    % This class contains properties and methods related to synapse utilities.
    
    
    %% SYNAPSE UTILITIES PROPERTIES
    
    % Define the class properties.
    properties
        
        
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                     	% [V] Activation Domain.
        Gm_DEFAULT = 1e-6;                                  	% [S] Membrane Conductance.
        
        % Define the synaptic reversal potential parameters.
        dEs_max_DEFAULT = 194e-3;                             	% [V] Maximum Synaptic Reversal Potential.
        dEs_min_DEFAULT = -40e-3;                             	% [V] Minimum Synaptic Reversal Potential.
        dEs_small_negative_DEFAULT = -1e-3;                   	% [V] Small Negative Synaptic Reversal Potential.
        
        % Define the applied current parameters.
        Id_max_DEFAULT = 1.25e-9;                              	% [A] Maximum Drive Current.
        Ia_absolute_addition_DEFAULT = 0;                      	% [A] Absolute Addition Applied Current.
        Ia_relative_addition_DEFAULT = 0;                      	% [A] Relative Addition Applied Current.
        Ia_absolute_subtraction_DEFAULT = 0;                  	% [A] Absolute Subtraction Applied Current.
        Ia_relative_subtraction_DEFAULT = 0;                  	% [A] Relative Subtraction Applied Current.
        Ia1_absolute_inversion_DEFAULT = 0;                    	% [A] Absolute Inversion Applied Current 1.
        Ia2_absolute_inversion_DEFAULT = 2e-8;              	% [A] Absolute Inversion Applied Current 2.
        Ia1_relative_inversion_DEFAULT = 0;                  	% [A] Relative Inversion Applied Current 1.
        Ia2_relative_inversion_DEFAULT = 2e-8;                	% [A] Relative Inversion Applied Current 2.
        Ia_absolute_division_DEFAULT = 0;                      	% [A] Absolute Division Applied Current.
        Ia_relative_division_DEFAULT = 0;                    	% [A] Relative Division Applied Current.
        
        % Define the CPG parameters.
        delta_oscillatory_DEFAULT = 0.01e-3;                  	% [-] CPG Oscillatory Delta.
        delta_bistable_DEFAULT = -10e-3;                     	% [-] CPG Bistable Delta.
        delta_noncpg_DEFAULT = 0;                            	% [-] CPG Delta.

        % Define the subnetwork design parameters.
        c_absolute_addition_DEFAULT = 1;                      	% [-] Absolute Addition Subnetwork Gain.
        c_relative_addition_DEFAULT = 1;                       	% [-] Relative Addition Subnetwork Gain.
        c_absolute_subtraction_DEFAULT = 1;                    	% [-] Absolute Subtraction Subnetwork Gain.
        c_relative_subtraction_DEFAULT = 1;                    	% [-] Relative Subtraction Subnetwork Gain.
        c_absolute_inversion_DEFAULT = 1;                      	% [-] Absolute Inversion Subnetwork Gain.
        c_relative_inversion_DEFAULT = 1;                      	% [-] Relative Inversion Subnetwork Gain.
        c_absolute_division_DEFAULT = 1;                       	% [-] Absolute Division Subnetwork Gain.
        c_relative_division_DEFAULT = 1;                    	% [-] Relative Division Subnetwork Gain.
        c_absolute_multiplication_DEFAULT = 1;                	% [-] Absolute Multiplication Subnetwork Gain.
        c_relative_multiplication_DEFAULT = 1;                  % [-] Relative Multiplication Subnetwork Gain.
        
        % Define the subnetwork neuron numbers.
        num_addition_neurons_DEFAULT = 3;                      	% [#] Number of Addition Neurons.
        
        % Define inversion and division subnetwork parameters.
        epsilon_DEFAULT = 1e-6;                               	% [V] Subnetwork Input Offset.
        delta_DEFAULT = 1e-6;                                 	% [V] Subnetwork Output Offset.
        alpha_DEFAULT = 1e-6;                                 	% [V] Division Subnetwork Denominator Offset.
        
    end
    
    
    %% SYNAPSE UTILITIES METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_utilities_class(  )
            
            
            
        end
        
        
        %% Name Functions.
        
        % Implement a function to generate a name from an ID.
        function name = ID2name( ~, ID )
            
            % Generate a name for the synapse.
            name = sprintf( 'Synapse %s', ID );
            
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
        
        
        %% Synaptic Reversal Potential Compute Functions.
        
        % Implement a function to compute the synaptic reversal potential for a driven multistate cpg subnetwork.
        function dEs = compute_dmcpg_dEs( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute transmission subnetwork.
        function dEs = compute_absolute_transmission_dEs( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
                
        % Implement a function to compute the synaptic reversal potential for a relative transmission subnetwork.
        function dEs = compute_relative_transmission_dEs( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a modulation subnetwork.
        function dEs = compute_modulation_dEs( ~ )
            
            % Compute the synaptic reversal potential.
            dEs = 0;                                                        % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the first synaptic reversal potential for an absolute addition subnetwork.
        function dEs1 = compute_absolute_addition_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the first synaptic reversal potential for a relative subnetwork.
        function dEs1 = compute_relative_addition_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the second synaptic reversal potential for an absolute addition subnetwork.
        function dEs2 = compute_absolute_addition_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the second synaptic reversal potential for a relative addition subnetwork.
        function dEs2 = compute_relative_addition_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        
        % Implement a function to compute the synaptic reversal potential for absolute addition subnetwork synapses.
        function dEs = compute_absolute_addition_dEs( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative addition subnetwork synapses.
        function dEs = compute_relative_addition_dEs( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute subtraction subnetwork.
        function dEs1 = compute_absolute_subtraction_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a relative subtraction subnetwork.
        function dEs1 = compute_relative_subtraction_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute subtraction subnetwork.
        function dEs2 = compute_absolute_subtraction_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_min_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a relative subtraction subnetwork.
        function dEs2 = compute_relative_subtraction_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_min_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute subtraction subnetwork excitatory synapses.
        function dEs = compute_absolute_subtraction_dEs_excitatory( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute subtraction subnetwork inhibitory synapses.
        function dEs = compute_absolute_subtraction_dEs_inhibitory( self )
            
            % Compute the synaptic reversal potential.
%             dEs = self.dEs_min_DEFAULT;                                   % [V] Synaptic Reversal Potential.
            dEs = -self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative subtraction subnetwork excitatory synapses.
        function dEs = compute_relative_subtraction_dEs_excitatory( self )
            
            % Compute the synaptic reversal potential.
            dEs = self.dEs_max_DEFAULT;                                     % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative subtraction subnetwork inhibitory synapses.
        function dEs = compute_relative_subtraction_dEs_inhibitory( self )
            
            % Compute the synaptic reversal potential.
%             dEs = self.dEs_min_DEFAULT;                                   % [V] Synaptic Reversal Potential.
            dEs = -self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute multiplication subnetwork.
        function dEs1 = compute_absolute_multiplication_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a relative multiplication subnetwork.
        function dEs1 = compute_relative_multiplication_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute multiplication subnetwork.
        function dEs2 = compute_absolute_multiplication_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_small_negative_DEFAULT;                         % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a relative multiplication subnetwork.
        function dEs2 = compute_relative_multiplication_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_small_negative_DEFAULT;                         % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for an absolute multiplication subnetwork.
        function dEs3 = compute_absolute_multiplication_dEs3( self )
            
            % Compute the synaptic reversal potential.
            dEs3 = self.dEs_small_negative_DEFAULT;                         % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a relative multiplication subnetwork.
        function dEs3 = compute_relative_multiplication_dEs3( self )
            
            % Compute the synaptic reversal potential.
            dEs3 = self.dEs_small_negative_DEFAULT;                         % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute inversion subnetwork synapses.
        function dEs = compute_absolute_inversion_dEs( self, c, delta )
            
            % Define the default input arguments.
            if nargin < 3, delta = self.delta_DEFAULT; end                  % [V] Absolute Inversion Output Offset.
            if nargin < 2, c = self.c_absolute_inversion_DEFAULT; end       % [V] Absolute Inversion Subnetwork Gain.
            
            % Compute the synaptic reversal potential.
            dEs = -c.*delta;                                              	% [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative inversion subnetwork synapses.
        function dEs = compute_relative_inversion_dEs( self, epsilon, delta, R2 )
            
            % Define the default input arguments.
            if nargin < 4, R2 = self.R_DEFAULT; end                        	% [V] Activation Domain.
            if nargin < 3, delta = self.delta_DEFAULT; end                	% [V] Output Offset.
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end              % [V] Input Offset.
            
            % Compute the synaptic reversal potential.
            dEs = ( -epsilon.*delta.*R2 )./( 1 - epsilon.*delta );         	% [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute division synapses.
        function dEs = compute_absolute_division_dEs1( self, c, alpha )
            
            % Define the default input arguments.
            if nargin < 3, alpha = self.alpha_DEFAULT; end                  % [V] Division Subnetwork Denominator Offset.
            if nargin < 2, c = self.c_absolute_division_DEFAULT; end        % [-] Absolute Division Gain.
            
            % Compute the synaptic reversal potential.
            dEs = c./alpha;                                                 % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for absolute division synapses.
        function dEs = compute_absolute_division_dEs2( ~ )
            
            % Compute the synaptic reversal potential.
            % dEs = self.dEs_small_negative_DEFAULT;                      	% [V] Synaptic Reversal Potential.
            dEs = 0;                                                        % [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative division synapses.
        function dEs = compute_relative_division_dEs1( self, c, alpha )
            
            % Define the default input arguments.
            if nargin < 3, alpha = self.alpha_DEFAULT; end                 	% [V] Division Subnetwork Denominator Offset.
            if nargin < 2, c = self.c_relative_division_DEFAULT; end        % [-] Relative Division Gain.
            
            % Compute the synaptic reversal potential.
            dEs = c./alpha;                                                 % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for relative division synapses.
        function dEs = compute_relative_division_dEs2( ~ )
            
            % Compute the synaptic reversal potential.
%             dEs = self.dEs_small_negative_DEFAULT;                     	% [V] Synaptic Reversal Potential.
            dEs = 0;                                                        % [V] Synaptic Reversal Potential.

        end
        
        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dEs1 = compute_derivation_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a derivation subnetwork.
        function dEs2 = compute_derivation_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_min_DEFAULT;                                	% [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dEs1 = compute_integration_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_min_DEFAULT;                                    % [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a integration subnetwork.
        function dEs2 = compute_integration_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = self.dEs_min_DEFAULT;                                	% [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dEs1 = compute_vbi_dEs1( self )
            
            % Compute the synaptic reversal potential.
            dEs1 = self.dEs_max_DEFAULT;                                 	% [V] Synaptic Reversal Potential.
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential for a voltage based integration subnetwork.
        function dEs2 = compute_vbi_dEs2( self )
            
            % Compute the synaptic reversal potential.
            dEs2 = -self.dEs_max_DEFAULT;                                  	% [V] Synaptic Reversal Potential.
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions.
        
        % Implement a function to compute the maximum synaptic conductance for a driven multistate cpg subnetwork.
        function gs = compute_dmcpg_gs( self, dEs, delta_oscillatory, Id_max )
            
            % Define the default input arguments.
            if nargin < 4, Id_max = self.Id_max_DEFAULT; end                                            % [A] Maximum Drive Current.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end                      % [-] Oscillatory Delta.
            if nargin < 2, dEs = self.dEs_max_DEFAULT; end                                              % [V] Synaptic Reversal Potential.
            
            % Compute the maximum synaptic conductance.
            gs = Id_max./( dEs - delta_oscillatory );                                                   % [S] Maximum Synaptic Conductance.
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute addition subnetwork synapses.
        function gs_nk = compute_absolute_addition_gs( self, c, R_k, Gm_n, dEs_nk, Ia_n )
            
            % Define the default input arguments.
            if nargin < 6, Ia_n = self.Ia_absolute_addition_DEFAULT; end                                % [A] Applied Current.
            if nargin < 5, dEs_nk = self.dEs_max_DEFAULT; end                                           % [V] Synaptic Reversal Potential.
            if nargin < 4, Gm_n = self.Gm_DEFAULT; end                                                  % [S] Membrane Conductance.
            if nargin < 3, R_k = self.R_DEFAULT; end                                                    % [V] Activation Domain.
            if nargin < 2, c = self.c_absolute_addition_DEFAULT; end                                    % [-] Absolute Addition Subnetwork Gain.
            
            % Compute the maximum synaptic conductance.
            gs_nk = ( c.*R_k.*Gm_n - Ia_n )./( dEs_nk - c.*R_k );                                       % [S] Maximum Synaptic Conductance.
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative addition subnetwork synapses.
        function gs_nk = compute_relative_addition_gs( self, c, n, R_n, Gm_n, dEs_nk, Ia_n )
            
            % Define the default input arguments.
            if nargin < 7, Ia_n = self.Ia_relative_addition_DEFAULT; end                                % [A] Applied Current.
            if nargin < 6, dEs_nk = self.dEs_max_DEFAULT; end                                           % [V] Synaptic Reversal Potential.
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                  % [S] Membrane Conductance.
            if nargin < 4, R_n = self.R_DEFAULT; end                                                    % [V] Activation Domain.
            if nargin < 3, n = self.num_addition_neurons_DEFAULT; end                                   % [#] Number of Addition Neurons.
            if nargin < 2, c = self.c_relative_addition_DEFAULT; end                                    % [-] Absolute Addition Subnetwork Gain.
            
            % Compute the maximum synaptic conductance.
            gs_nk = ( ( n - 1 ).*Ia_n - c.*R_n.*Gm_n )./( c.*R_n - ( n - 1 ).*dEs_nk );                 % [S] Maximum Synaptic Conductance.
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of absolute subtraction subnetwork synapses.
        function gs_nk = compute_absolute_subtraction_gs( self, c, s_k, R_k, Gm_n, dEs_nk, Ia_n )
            
            % Define the default input arguments.
            if nargin < 7, Ia_n = self.Ia_absolute_subtraction_DEFAULT; end                             % [A] Applied Current.
            if nargin < 6, dEs_nk = self.dEs_max_DEFAULT; end                                           % [V] Synaptic Reversal Potential.
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                  % [S] Membrane Conductance.
            if nargin < 4, R_k = self.R_DEFAULT; end                                                    % [V] Activation Domain.
            if nargin < 3, s_k = 1; end                                                                 % [-] Excitation / Inhibition Sign.
            if nargin < 2, c = self.c_absolute_subtraction_DEFAULT; end                                 % [-] Absolute Subtraction Subnetwork Gain.
            
            % Compute the maximum synaptic conductance.
            gs_nk = ( Ia_n - c.*s_k.*Gm_n.*R_k )./( c.*s_k.*R_k - dEs_nk );                             % [S] Maximum Synaptic Conductance.
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative subtraction subnetwork synapses.
        function gs_nk = compute_relative_subtraction_gs( self, c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n )
            
            % Define the default input arguments.
            if nargin < 8, Ia_n = self.Ia_relative_subtraction_DEFAULT; end                             % [A] Applied Current.
            if nargin < 7, dEs_nk = self.dEs_max_DEFAULT; end                                           % [V] Synaptic Reversal Potential.
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                  % [S] Membrane Conductance.
            if nargin < 5, R_n = self.R_DEFAULT; end                                                    % [V] Activation Domain.
            if nargin < 4, s_k = 1; end                                                                 % [-] Excitation / Inhibition Sign.
            if nargin < 3, npm_k = 1; end                                                               % [#] Number of Excitatory / Inhibitory Synapses.
            if nargin < 2, c = self.c_relative_subtraction_DEFAULT; end                                 % [-] Relative Subtraction Subnetwork Gain.
            
            % Compute the maximum synaptic conductance.
            gs_nk = ( npm_k.*Ia_n - c.*s_k.*Gm_n.*R_n )./( c.*s_k.*R_n - npm_k.*dEs_nk );	% [S] Maximum Synaptic Conductance.
            
        end
        

        % Implement a function to compute the maximum synaptic conductance of absolute inversion subnetwork synapses.
        function gs21 = compute_absolute_inversion_gs( self, dEs21, Ia2 )
            
            % Define the default input arguments.
            if nargin < 3, Ia2 = self.Ia2_absolute_inversion_DEFAULT; end                               % [A] Applied Current.
            if nargin < 2, dEs21 = self.dEs_small_negative_DEFAULT; end                                 % [V] Synaptic Reversal Potential.
            
            % Compute the maximum synaptic conductance.
            gs21 = -Ia2./dEs21;                                                                         % [S] Maximum Synaptic Conductance.

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of relative inversion subnetwork synapses.
        function gs21 = compute_relative_inversion_gs( self, dEs21, Ia2 )
            
            % Define the default input arguments.
            if nargin < 3, Ia2 = self.Ia2_absolute_inversion_DEFAULT; end                               % [A] Applied Current.
            if nargin < 2, dEs21 = self.dEs_small_negative_DEFAULT; end                                 % [V] Synaptic Reversal Potential.
            
            % Compute the maximum synaptic conductance.
            gs21 = -Ia2./dEs21;                                                                         % [S] Maximum Synaptic Conductance.

        end


        % Implement a function to compute the maximum synaptic conductance of numerator absolute division subnetwork synapses.
        function gs31 = compute_absolute_division_gs31( self, alpha, epsilon, R1, Gm3 )
            
            % Define the default input arugments.
            if nargin < 5, Gm3 = self.Gm_DEFAULT; end                                                   % [S] Membrane Conductance.
            if nargin < 4, R1 = self.R_DEFAULT; end                                                     % [V] Activation Domain.
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                          % [-] Absolute Division Subnetwork Offset.
            if nargin < 2, alpha = self.alpha_DEFAULT; end                                              % [-] Absolute Division Subnetwork Denominator Adjustment.
            
            % Compute the maximum synaptic conductance.
            gs31 = ( alpha.*R1.*Gm3 )./epsilon;                                                         % [S] Maximum Synaptic Conductance.
            
        end

        
        % Implement a function to compute the maximum synaptic conductance of denominator absolute division subnetwork synapses.
        function gs32 = compute_absolute_division_gs32( self, epsilon, R2, Gm3 )
            
            % Define the default input arugments.
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end                                                   % [S] Membrane Conductance.
            if nargin < 3, R2 = self.R_DEFAULT; end                                                     % [V] Activation Domain.
            if nargin < 2, epsilon = self.epsilon_DEFAULT; end                                          % [V] Absolute Division Subnetwork Offset.
            
            % Compute the maximum synaptic conductance.
            gs32 = R2.*Gm3./epsilon;                                                                    % [S] Maximum Synaptic Conductance.
            
        end

        
        % Implement a function to compute the maximum synaptic conductance of numerator relative division subnetwork synapses.
        function gs31 = compute_relative_division_gs31( self, R3, Gm3, dEs31 )
            
            % Define the default input arguments.
            if nargin < 4, dEs31 = self.dEs_max_DEFAULT; end                                            % [V] Synaptic Reversal Potential.
            if nargin < 3, Gm3 = self.Gm_DEFAULT; end                                                   % [S] Membrane Conductance.
            if nargin < 2, R3 = self.R_DEFAULT; end                                                     % [V] Activation Domain.

            % Compute the maximum synaptic conductance.
            gs31 = ( R3.*Gm3 )./( dEs31 - R3 );                                                         % [S] Maximum Synaptic Conductance.
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of denominator relative division subnetwork synapses.
        function gs32 = compute_relative_division_gs32( self, c, alpha, epsilon, R3, Gm3, dEs31 )
            
            % Define the default input arguments.
            if nargin < 7, dEs31 = self.dEs_max_DEFAULT; end                                            % [V] Synaptic Reversal Potential.
            if nargin < 6, Gm3 = self.Gm_DEFAULT; end                                                   % [S] Membrane Conductance.
            if nargin < 5, R3 = self.R_DEFAULT; end                                                     % [V] Activation Domain.
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                          % [-] Relative Division Subnetwork Offset.
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                              % [V] Relative Division Subnetwork Denominator Offset.
            if nargin < 2, c = self.c_relative_division_DEFAULT; end                                    % [-] Relative Division Subnetwork Gain.
            
            % Compute the maximum synaptic conductance.
            gs32 = ( ( ( 1 - alpha ).*dEs31 + c*R3 )./( ( epsilon + alpha ).*dEs31 - c.*R3 ) )*Gm3;     % [S] Maximum Synaptic Conductance.
            
        end
        
        
    end
end