classdef synapse_class
    
    % This class contains properties and methods related to synapses.
    
    %% SYNAPSE PROPERTIES
    
    % Define the class properties.
    properties
        
        ID                                                    	% [#] Synapse ID.
        name                                                  	% [-] Synapse Name.
        
        dE_syn                                                	% [V] Synaptic Reversal Potential.
        g_syn_max                                             	% [S] Maximum Synaptic Conductance.
        G_syn                                                   % [S] Synaptic Conductance.
        
        from_neuron_ID                                       	% [#] From Neuron ID.
        to_neuron_ID                                           	% [#] To Neuron ID.
        
        delta                                                 	% [V] CPG Equilibrium Offset.
        
        b_enabled                                               % [T/F] Synapse Enabled Flag.
        
        synapse_utilities                                       % [-] Synapse Utilities Class.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                    	% [V] Activation Domain.
        Gm_DEFAULT = 1e-6;                                     	% [S] Membrane Conductance.
       
        % Define the maximum synaptic conductance.
        gs_DEFAULT = 1e-6;                                     	% [S] Maximum Synaptic Conductance.
        
        % Define the synaptic reversal potential parameters.
        dEs_maximum_DEFAULT = 194e-3;                        	% [V] Maximum Synaptic Reversal Potential.
        dEs_minimum_DEFAULT = -40e-3;                         	% [V] Minimum Synaptic Reversal Potential.
        dEs_small_negative_DEFAULT = -1e-3;                     % [V] Small Negative Synaptic Reversal Potential.
        
        % Define the applied current parameters.
        Id_max_DEFAULT = 1.25e-9;                             	% [A] Maximum Drive Current.
        Ia_absolute_addition_DEFAULT = 0;                   	% [A] Absolute Addition Applied Current.
        Ia_relative_addition_DEFAULT = 0;                      	% [A] Relative Addition Applied Current.
        Ia_absolute_subtraction_DEFAULT = 0;                  	% [A] Absolute Subtraction Applied Current.
        Ia_relative_subtraction_DEFAULT = 0;                	% [A] Relative Subtraction Applied Current.
        Ia1_absolute_inversion_DEFAULT = 0;                    	% [A] Absolute Inversion Applied Current 1.
        Ia2_absolute_inversion_DEFAULT = 2e-8;                 	% [A] Absolute Inversion Applied Current 2.
        Ia1_relative_inversion_DEFAULT = 0;                   	% [A] Relative Inversion Applied Current 1.
        Ia2_relative_inversion_DEFAULT = 2e-8;                 	% [A] Relative Inversion Applied Current 2.
        Ia_absolute_division_DEFAULT = 0;                    	% [A] Absolute Division Applied Current.
        Ia_relative_division_DEFAULT = 0;                      	% [A] Relative Division Applied Current.
        
        % Define the CPG parameters.
        delta_oscillatory_DEFAULT = 0.01e-3;                  	% [-] CPG Oscillatory Delta.
        delta_bistable_DEFAULT = -10e-3;                      	% [-] CPG Bistable Delta.
        delta_noncpg_DEFAULT = 0;                             	% [-] CPG Delta.
        
        % Define the subnetwork gain parameters.
        c_absolute_addition_DEFAULT = 1;                      	% [-] Absolute Addition Subnetwork Gain.
        c_relative_addition_DEFAULT = 1;                      	% [-] Relative Addition Subnetwork Gain.
        c_absolute_subtraction_DEFAULT = 1;                    	% [-] Absolute Subtraction Subnetwork Gain.
        c_relative_subtraction_DEFAULT = 1;                  	% [-] Relative Subtraction Subnetwork Gain.
        c_absolute_inversion_DEFAULT = 1;                      	% [-] Absolute Inversion Subnetwork Gain.
        c_relative_inversion_DEFAULT = 1;                      	% [-] Relative Inversion Subnetwork Gain.
        c_absolute_division_DEFAULT = 1;                      	% [-] Absolute Division Subnetwork Gain.
        c_relative_division_DEFAULT = 1;                      	% [-] Relative Division Subnetwork Gain.
        c_absolute_multiplication_DEFAULT = 1;               	% [-] Absolute Multiplication Subnetwork Gain.
        c_relative_multiplication_DEFAULT = 1;                	% [-] Relative Multiplication Subnetwork Gain.
        
        % Define the subnetwork offset parameters.
        epsilon_DEFAULT = 1e-6;                                	% [-] Subnetwork Input Offset.
        delta_DEFAULT = 1e-6;                                	% [-] Subnetwork Output Offset.
        
        % Define the subnetwork neuron numbers.
        num_addition_neurons_DEFAULT = 3;                    	% [#] Number of Addition Neurons.
               
        % Define the synapse identification parameters.
        to_neuron_ID_DEFAULT = 0;                            	% [#] To Neuron ID.
        from_neuron_ID_DEFAULT = 0;                           	% [#] From Neuron ID.
        ID_DEFAULT = 0;                                       	% [#] Synapse ID.

        % Define the division subnetwork properties.
        alpha_DEFAULT = 1e-6;                                	% [-] Division Subnetwork Denominator Offset.
        
        % Define the default encoding scheme.
        encoding_scheme_DEFAULT = 'Absolute';               	% [-] Encoding Scheme.
        
    end
    
    
    %% SYNAPSE METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled )
            
            % Create an instance of the synapse utilities class.
            self.synapse_utilities = synapse_utilities_class(  );
            
            % Set the default synapse properties.
            if nargin < 8, self.b_enabled = true; else, self.b_enabled = b_enabled; end                                                     % [T/F] Synapse Enabled Flag.
            if nargin < 7, self.delta = self.delta_noncpg_DEFAULT; else, self.delta = delta; end                                            % [V] CPG Equilibrium Offset.
            if nargin < 6, self.to_neuron_ID = self.to_neuron_ID_DEFAULT; else, self.to_neuron_ID = to_neuron_ID; end                       % [#] To Neuron ID.
            if nargin < 5, self.from_neuron_ID = self.from_neuron_ID_DEFAULT; else, self.from_neuron_ID = from_neuron_ID; end             	% [S] Synaptic Conductance.
            if nargin < 4, self.g_syn_max = self.gs_DEFAULT; else, self.g_syn_max = g_syn_max; end                                          % [S] Maximum Synaptic Conductance.
            if nargin < 3, self.dE_syn = self.dEs_minimum_DEFAULT; else, self.dE_syn = dE_syn; end                                          % [V] Synaptic Reversal Potential.
            if nargin < 2, self.name = ''; else, self.name = name; end                                                                      % [-] Synapse Name.
            if nargin < 1, self.ID = self.ID_DEFAULT; else, self.ID = ID; end                                                               % [#] Synapse ID.
            
        end
        
        
        %% Parameter Unpacking Functions.
        
        % Implement a function to unpack the parmaeters required to compute the absolute inversion synaptic reversal potentials.
        function [ c, delta ] = unpack_absolute_inversion_dEs_parameters( self, parameters )
            
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_inversion_DEFAULT;          % [-] Inversion Subnetwork Gain.
                delta = self.delta_DEFAULT;                   	% [V] Output Offset.
                
            elseif length( parameters ) == 2                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                            % [-] Inversion Subnetwork Gain.
                delta = parameters{ 2 };                        % [V] Output Offset.  
                
            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
                
        end
        
        
        % Implement a function to unpack the parameters required to compute the relative inversion synaptic reversal potentials.
        function [ epsilon, delta, R2 ] = unpack_relative_inversion_dEs_parameters( self, parameters )
            
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                epsilon = self.epsilon_DEFAULT;                 % [-] Inversion Subnetwork Input Offset.
                delta = self.delta_DEFAULT;                   	% [V] Inversion Subnetwork Output Offset.
                R2 = self.R_DEFAULT;                            % [V] Activation Domain.
                
            elseif length( parameters ) == 2                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                epsilon = parameters{ 1 };                     	% [-] Inversion Subnetwork Input Offset.
                delta = parameters{ 2 };                        % [V] Inversion Subnetwork Output Offset.  
                R2 = parameters{ 3 };                           % [V] Activation Domain.  

            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
                
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute division synaptic reversal potentials.
        function [ c, alpha ] = unpack_absolute_division_dEs_parameters( self, parameters )
            
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_division_DEFAULT;          	% [-] Division Subnetwork Input Offset.
                alpha = self.alpha_DEFAULT;                   	% [V] Division Subnetwork Denominator Offset.
                
            elseif length( parameters ) == 2                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                            % [-] Division Subnetwork Input Offset.
                alpha = parameters{ 2 };                        % [V] Division Subnetwork Denominator Offset. 

            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
            
        end
        

        % Implement a function to unpack the parameters required to compute the relative division synaptic reversal potentials.
        function [ c, alpha ] = unpack_relative_division_dEs_parameters( self, parameters )
           
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_division_DEFAULT;          	% [-] Division Subnetwork Input Offset.
                alpha = self.alpha_DEFAULT;                   	% [V] Division Subnetwork Denominator Offset.
                
            elseif length( parameters ) == 2                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                            % [-] Division Subnetwork Input Offset.
                alpha = parameters{ 2 };                        % [V] Division Subnetwork Denominator Offset. 

            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute addition synaptic conductance.
        function [ c, R_k, Gm_n, dEs_nk, Ia_n ] = unpack_absolute_addition_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_addition_DEFAULT;          	% [-] Absolute Addition Subnetwork Gain.
                R_k = self.R_DEFAULT;                          	% [V] Activation Domain.
                Gm_n = self.Gm_DEFAULT;                        	% [S] Membrane Conductance.
                dEs_nk = self.dE_syn;                         	% [V] Synaptic Reversal Potential.
                Ia_n = self.Ia_absolute_addition_DEFAULT;       % [A] Applied Current.
            
            elseif length( parameters ) == 5                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                            % [-] Absolute Addition Subnetwork Gain.
                R_k = parameters{ 2 };                          % [V] Activation Domain.
                Gm_n = parameters{ 3 };                         % [S] Membrane Conductance.
                dEs_nk = parameters{ 4 };                       % [V] Synaptic Reversal Potential.
                Ia_n = parameters{ 5 };                         % [A] Applied Current.
                
            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the relative addition synaptic conductance.
        function [ c, n, R_k, Gm_n, dEs_nk, Ia_n ] = unpack_relative_addition_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end               % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                            % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_addition_DEFAULT;          	% [-] Absolute Addition Subnetwork Gain.
                n = self.num_addition_neurons_DEFAULT;          % [#] Number of Addition Neurons.
                R_k = self.R_DEFAULT;                          	% [V] Activation Domain.
                Gm_n = self.Gm_DEFAULT;                        	% [S] Membrane Conductance.
                dEs_nk = self.dE_syn;                         	% [V] Synaptic Reversal Potential.
                Ia_n = self.Ia_absolute_addition_DEFAULT;       % [A] Applied Current.
            
            elseif length( parameters ) == 6                    % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                            % [-] Absolute Addition Subnetwork Gain.
                n = parameters{ 2 };                            % [#] Number of Addition Neurons.
                R_k = parameters{ 3 };                          % [V] Activation Domain.
                Gm_n = parameters{ 4 };                         % [S] Membrane Conductance.
                dEs_nk = parameters{ 5 };                       % [V] Synaptic Reversal Potential.
                Ia_n = parameters{ 6 };                         % [A] Applied Current.
                
            else                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        
        % Implement a function to unpack the parameters required to compute the absolute subtraction synaptic conductance.
        function [ c, s_k, R_k, Gm_n, dEs_nk, Ia_n ] = unpack_absolute_subtraction_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_absolute_subtraction_DEFAULT;           	% [-] Absolute Subtraction Subnetwork Gain.
                s_k = 1;                                          	% [-] Excitation / Inhibition Sign.
                R_k = self.R_DEFAULT;                             	% [V] Activation Domain.
                Gm_n = self.Gm_DEFAULT;                          	% [S] Membrane Conductance.
                dEs_nk = self.dE_syn;                               % [V] Synaptic Reversal Potential.
                Ia_n = self.Ia_absolute_subtraction_DEFAULT;        % [A] Applied Current.
                
            elseif length( parameters ) == 6                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                               	% [-] Absolute Subtraction Subnetwork Gain.
                s_k = parameters{ 2 };                            	% [-] Excitation / Inhibition Sign.
                R_k = parameters{ 3 };                              % [V] Activation Domain.
                Gm_n = parameters{ 4 };                             % [S] Membrane Conductance.
                dEs_nk = parameters{ 5 };                           % [V] Synaptic Reversal Potential.
                Ia_n = parameters{ 6 };                             % [A] Applied Current.
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the relative subtraction synaptic conductance.
        function [ c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n ] = unpack_relative_subtraction_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_relative_subtraction_DEFAULT;           	% [-] Absolute Subtraction Subnetwork Gain.
                npm_k = 1;                                          % [#] Number of Excitatory / Inhibitory Synapses
                s_k = 1;                                          	% [-] Excitation / Inhibition Sign.
                R_n = self.R_DEFAULT;                             	% [V] Activation Domain.
                Gm_n = self.Gm_DEFAULT;                          	% [S] Membrane Conductance.
                dEs_nk = self.dE_syn;                               % [V] Synaptic Reversal Potential.
                Ia_n = self.Ia_relative_subtraction_DEFAULT;        % [A] Applied Current.

            elseif length( parameters ) == 7                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                               	% [-] Absolute Subtraction Subnetwork Gain.
                npm_k = parameters{ 2 };                         	% [#] Number of Excitatory / Inhibitory Synapses
                s_k = parameters{ 3 };                            	% [-] Excitation / Inhibition Sign.
                R_n = parameters{ 4 };                              % [V] Activation Domain.
                Gm_n = parameters{ 5 };                             % [S] Membrane Conductance.
                dEs_nk = parameters{ 6 };                           % [V] Synaptic Reversal Potential.
                Ia_n = parameters{ 7 };                             % [A] Applied Current.
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end            
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute inversion synaptic conductance.
        function [ dEs21, Ia2 ] = unpack_absolute_inversion_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                dEs21 = self.dEs_small_negative_DEFAULT;            % [V] Synaptic Reversal Potential.
                Ia2 = self.Ia2_absolute_inversion_DEFAULT;          % [A] Applied Current.

            elseif length( parameters ) == 2                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                dEs21 = parameters{ 1 };
                Ia2 = parameters{ 2 };
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end
        
            
        % Implement a function to unpack the parameters required to compute the relative inversion synaptic conductance.
        function [ dEs21, Ia2 ] = unpack_relative_inversion_gs_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                dEs21 = self.dEs_small_negative_DEFAULT;            % [V] Synaptic Reversal Potential.
                Ia2 = self.Ia2_relative_inversion_DEFAULT;          % [A] Applied Current.

            elseif length( parameters ) == 2                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                dEs21 = parameters{ 1 };
                Ia2 = parameters{ 2 };
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end

        
        % Implement a function to unpack the parameters required to compute the absolute division synaptic conductance.
        function [ alpha, epsilon, R1, Gm3 ] = unpack_absolute_division_gs31_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                alpha = self.alpha_DEFAULT;                         % [-] Absolute Division Subnetwork Denominator Adjustment.
                epsilon = self.epsilon_DEFAULT;                     % [-] Absolute Division Subnetwork Offset.
                R1 = self.R_DEFAULT;                                % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                              % [S] Membrane Conductance.
                
            elseif length( parameters ) == 4                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                alpha = parameters{ 1 };                            % [-] Absolute Division Subnetwork Denominator Adjustment.
                epsilon = parameters{ 2 };                          % [-] Absolute Division Subnetwork Offset.
                R1 = parameters{ 3 };                               % [V] Activation Domain.
                Gm3 = parameters{ 4 };                              % [S] Membrane Conductance.
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the relative division synaptic conductance.
        function [ R3, Gm3, dEs31 ] = unpack_relative_division_gs31_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                R3 = self.R_DEFAULT;                                % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                              % [S] Membrane Conductance.
                dEs31 = self.dE_syn;                                % [V] Synaptic Reversal Potential.

            elseif length( parameters ) == 3                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                R3 = parameters{ 1 };                               % [V] Activation Domain.
                Gm3 = parameters{ 2 };                              % [S] Membrane Conductance.
                dEs31 = parameters{ 3 };                            % [V] Synaptic Reversal Potential.
            
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the absolute division synaptic conductance.
        function [ epsilon, R2, Gm3 ] = unpack_absolute_division_gs32_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                epsilon = self.epsilon_DEFAULT;                     % [-] Absolute Division Subnetwork Offset.
                R2 = self.R_DEFAULT;                                % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                              % [S] Membrane Conductance.
                
            elseif length( parameters ) == 3                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                epsilon = parameters{ 1 };                          % [-] Absolute Division Subnetwork Offset.
                R2 = parameters{ 2 };                               % [V] Activation Domain.
                Gm3 = parameters{ 3 };                              % [S] Membrane Conductance.
                
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the parameters required to compute the relative division synaptic conductance.
        function [ c, alpha, epsilon, R3, Gm3, dEs31 ] = unpack_relative_division_gs32_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = {  }; end                   % [-] Input Parameters Cell.
            
            % Determine how to set the parameters.
            if isempty( parameters )                                % If the parameters are empty...
            
                % Set the parameters to default values.
                c = self.c_relative_division_DEFAULT;               % [-] Relative Division Subnetwork Gain.
                alpha = self.alpha_DEFAULT;                         % [-] Division Subnetwork Denominator Offset.
                epsilon = self.epsilon_DEFAULT;                     % [-] Relative Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                              % [S] Membrane Conductance.
                dEs31 = self.dE_syn;                                % [V] Synaptic Reversal Potential.
                
            elseif length( parameters ) == 6                        % If there are a specific number of parameters...
                
                % Unpack the parameters.
                c = parameters{ 1 };                                % [-] Relative Division Subnetwork Gain.
                alpha = parameters{ 2 };                            % [-] Division Subnetwork Denominator Offset.
                epsilon = parameters{ 3 };                          % [-] Relative Division Subnetwork Offset.
                R3 = parameters{ 4 };                               % [V] Activation Domain.
                Gm3 = parameters{ 5 };                              % [S] Membrane Conductance.
                dEs31 = parameters{ 6 };                            % [V] Synaptic Reversal Potential.
                
            else                                                    % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack parameters.' )
                
            end 
            
        end
        
        
        %% Synaptic Reversal Potential Compute Functions.
        
        % Implement a function to compute the synaptic reversal potential of a driven multistate cpg subnetwork.
        function [ dEs, self ] = compute_dmcpg_dEs( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_dmcpg_dEs(  );                          % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a transmission subnetwork.
        function [ dEs, self ] = compute_transmission_dEs( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a transmission subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                               % If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue transmission subnetwork.
                dEs = synapse_utilities.compute_absolute_transmission_dEs(  );      % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative transmission subnetwork.
                dEs = synapse_utilities.compute_relative_transmission_dEs(  );      % [V] Synaptic Reversal Potential.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a modulation subnetwork.
        function [ dEs, self ] = compute_modulation_dEs( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs = synapse_utilities.compute_modulation_dEs(  );                     % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function [ dEs1, self ] = compute_addition_dEs1( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for an addition subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                           	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue addition subnetwork.
                dEs1 = synapse_utilities.compute_absolute_addition_dEs1(  );        % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative addition subnetwork.
                dEs1 = synapse_utilities.compute_relative_addition_dEs1(  );        % [V] Synaptic Reversal Potential.
                
            else                                                                  	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of an addition subnetwork.
        function [ dEs2, self ] = compute_addition_dEs2( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for an addition subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                           	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue addition subnetwork.
                dEs2 = synapse_utilities.compute_absolute_addition_dEs2(  );        % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative addition subnetwork.
                dEs2 = synapse_utilities.compute_relative_addition_dEs2(  );        % [V] Synaptic Reversal Potential.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of addition subnetwork synapses.
        function [ dEs, self ] = compute_addition_dEs( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for an addition subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                           	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue addition subnetwork.
                dEs = synapse_utilities.compute_absolute_addition_dEs(  );          % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative addition subnetwork.
                dEs = synapse_utilities.compute_relative_addition_dEs(  );          % [V] Synaptic Reversal Potential.
                
            else                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end

        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function [ dEs1, self ] = compute_subtraction_dEs1( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a subtraction subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                              	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue subtraction subnetwork.
                dEs1 = synapse_utilities.compute_absolute_subtraction_dEs1(  );  	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                          	% If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative subtraction subnetwork.
                dEs1 = synapse_utilities.compute_relative_subtraction_dEs1(  );   	% [V] Synaptic Reversal Potential.
                
            else                                                                  	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a subtraction subnetwork.
        function [ dEs2, self ] = compute_subtraction_dEs2( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                     % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a subtraction subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                              	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue subtraction subnetwork.
                dEs2 = synapse_utilities.compute_absolute_subtraction_dEs2(  );    	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                         	% If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative subtraction subnetwork.
                dEs2 = synapse_utilities.compute_relative_subtraction_dEs2(  );   	% [V] Synaptic Reversal Potential.
                
            else                                                                   	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of subtraction subnetwork excitatory synapses.
        function [ dEs, self ] = compute_subtraction_dEs_excitatory( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end                      % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                                 % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a subtraction subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                           % If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue subtraction subnetwork.
                dEs = synapse_utilities.compute_absolute_subtraction_dEs_excitatory(  );        % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                       % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative subtraction subnetwork.
                dEs = synapse_utilities.compute_relative_subtraction_dEs_excitatory(  );        % [V] Synaptic Reversal Potential.
                
            else                                                                              	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of subtraction subnetwork inhibitory synapses.
        function [ dEs, self ] = compute_subtraction_dEs_inhibitory( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end                      % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                                 % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a subtraction subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                               % If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue subtraction subnetwork.
                dEs = synapse_utilities.compute_absolute_subtraction_dEs_inhibitory(  );        % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                      	% If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative subtraction subnetwork.
                dEs = synapse_utilities.compute_relative_subtraction_dEs_inhibitory(  );      	% [V] Synaptic Reversal Potential.
                
            else                                                                              	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs1, self ] = compute_multiplication_dEs1( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end                      % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                                 % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a multiplication subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                        	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue multiplication subnetwork.
                dEs1 = synapse_utilities.compute_absolute_multiplication_dEs1(  );           	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                       % If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative multiplication subnetwork.
                dEs1 = synapse_utilities.compute_relative_multiplication_dEs1(  );          	% [V] Synaptic Reversal Potential.
                
            else                                                                              	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs2, self ] = compute_multiplication_dEs2( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end              % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                         % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a multiplication subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                 	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue multiplication subnetwork.
                dEs2 = synapse_utilities.compute_absolute_multiplication_dEs2(  );      % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                              	% If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative multiplication subnetwork.
                dEs2 = synapse_utilities.compute_relative_multiplication_dEs2(  );   	% [V] Synaptic Reversal Potential.
                
            else                                                                     	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs3, self ] = compute_multiplication_dEs3( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end              % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                         % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a multiplication subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue multiplication subnetwork.
                dEs3 = synapse_utilities.compute_absolute_multiplication_dEs3(  );    	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                             	% If the encoding scheme is set to relative...
            
                % Compute the synaptic reversal potential for a relative multiplication subnetwork.
                dEs3 = synapse_utilities.compute_relative_multiplication_dEs3(  );    	% [V] Synaptic Reversal Potential.
                
            else                                                                     	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs3; end

        end
        
        
        % Implement a function to compute the synaptic reversal potential of inversion subnetwork synapses.
        function [ dEs, self ] = compute_inversion_dEs( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                                      % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                                 % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                  % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                               % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic reversal potential for an inversion subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                                           % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic reversal potential for absolute inversion subnetworks.
                [ c, delta_offset ] = self.unpack_absolute_inversion_dEs_parameters( parameters );
                
                % Compute the synaptic reversal potential for an absolue inversion subnetwork.
                dEs = synapse_utilities.compute_absolute_inversion_dEs( c, delta_offset );                      % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                       % If the encoding scheme is set to relative...
            
                % Unpack the parmaeters required to compute the synaptic reversal potential for relative inversion subnetworks.
                [ epsilon, delta_offset, R2 ] = self.unpack_relative_inversion_dEs_parameters( parameters );
                
                % Compute the synaptic reversal potential for a relative inversion subnetwork.
                dEs = synapse_utilities.compute_relative_inversion_dEs( epsilon, delta_offset, R2 );            % [V] Synaptic Reversal Potential.
                
            else                                                                                                % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs; end

        end
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function [ dEs1, self ] = compute_division_dEs1( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                          % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                     % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                      % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                   % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic reversal potential for a division subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                               % If the encoding scheme is set to absolute...
                
                % Unpack absolute division synaptic reversal potential parameters.
                [ c, alpha ] = self.unpack_absolute_division_dEs_parameters( parameters );
                
                % Compute the synaptic reversal potential for an absolue division subnetwork.
                dEs1 = synapse_utilities.compute_absolute_division_dEs1( c, alpha );                % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                        	% If the encoding scheme is set to relative...
            
                % Unpack relative division synaptic reversal potential parameters.
                [ c, alpha ] = self.unpack_relative_division_dEs_parameters( parameters );
                
                % Compute the synaptic reversal potential for a relative division subnetwork.
                dEs1 = synapse_utilities.compute_relative_division_dEs1( c, alpha );                % [V] Synaptic Reversal Potential.
                
            else                                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a division subnetwork.
        function [ dEs2, self ] = compute_division_dEs2( self, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 4, synapse_utilities = self.synapse_utilities; end                  % [class] Synapse Utilities.
            if nargin < 3, set_flag = true; end                                             % [T/F] Set Flag.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme.
            
            % Determine how to compute the synaptic reversal potential for a division subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                     	% If the encoding scheme is set to absolute...
                
                % Compute the synaptic reversal potential for an absolue division subnetwork.
                dEs2 = synapse_utilities.compute_absolute_division_dEs2(  );                % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is set to relative...
                
                % Compute the synaptic reversal potential for a relative division subnetwork.
                dEs2 = synapse_utilities.compute_relative_division_dEs2(  );                % [V] Synaptic Reversal Potential.
                
            else                                                                          	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function [ dEs1, self ] = compute_derivation_dEs1( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_derivation_dEs1(  );                   % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a derivation subnetwork.
        function [ dEs2, self ] = compute_derivation_dEs2( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_derivation_dEs2(  );                   % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, self ] = compute_integration_dEs1( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_integration_dEs1(  );                  % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, self ] = compute_integration_dEs2( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_integration_dEs2(  );                  % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, self ] = compute_vbi_dEs1( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs1 = synapse_utilities.compute_vbi_dEs1(  );                          % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs1; end
            
        end
        
        
        % Implement a function to compute the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, self ] = compute_vbi_dEs2( self, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 3, synapse_utilities = self.synapse_utilities; end          % [class] Synapse Utilities.
            if nargin < 2, set_flag = true; end                                     % [T/F] Set Flag.
            
            % Compute the synaptic reversal potential.
            dEs2 = synapse_utilities.compute_vbi_dEs2(  );                          % [V] Synaptic Reversal Potential.
            
            % Determine whether to update the synapse object.
            if set_flag, self.dE_syn = dEs2; end
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions.
        
        % Implement a function to compute the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function [ gs, self ] = compute_dmcpg_gs( self, dEs, delta_oscillatory, Id_max, set_flag, synapse_utilities )
            
            % Define the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                              % [class] Synapse Utilities.
            if nargin < 4, Id_max = self.Id_max_DEFAULT; end                                            % [A] Maximum Drive Current.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end                      % [-] Oscillatory Delta.
            if nargin < 2, dEs = self.dE_syn; end                                                     	% [V] Synaptic Reversal Potential.
            
            % Compute the maximum synaptic conductance.
            gs = synapse_utilities.compute_dmcpg_gsynmax( dEs, delta_oscillatory, Id_max );             % [S] Maximum Synaptic Conductance
            
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance of addition synapses.
        function [ gs_nk, self ] = compute_addition_gs( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                                  % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                             % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                              % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                           % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic conductance for an addition subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                                       % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic conductance for an absolute addition subnetwork.
                [ c, R_k, Gm_n, dEs_nk, Ia_n ] = self.unpack_absolute_addition_gs_parameters( parameters );
                
                % Compute the synaptic conductance for an absolue addition subnetwork.
                gs_nk = synapse_utilities.compute_absolute_addition_gs( c, R_k, Gm_n, dEs_nk, Ia_n );       % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                   % If the encoding scheme is set to relative...
            
                % Unpack the parameters required to compute the synaptic conductance for a relative addition subnetwork.
                [  c, n, R_n, Gm_n, dEs_nk, Ia_n ] = self.unpack_relative_addition_gs_parameters( parameters );
                
                % Compute the synaptic conductance for a relative addition subnetwork.
                gs_nk = synapse_utilities.compute_relative_addition_gs( c, n, R_n, Gm_n, dEs_nk, Ia_n ); 	% [V] Synaptic Reversal Potential.
                
            else                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs_nk; end

        end
        
        
        % Implement a function to compute the maximum synaptic conductance of subtraction synapses.
        function [ gs_nk, self ] = compute_subtraction_gs( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                                              % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                                         % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                                       % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic conductance for a subtraction subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                                                   % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic conductance for an absolute subtraction subnetwork.
                [ c, s_k, R_k, Gm_n, dEs_nk, Ia_n ] = self.unpack_absolute_subtraction_gs_parameters( parameters );
                
                % Compute the synaptic conductance for an absolue subtraction subnetwork.
                gs_nk = synapse_utilities.compute_absolute_subtraction_gs( c, s_k, R_k, Gm_n, dEs_nk, Ia_n );          	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                               % If the encoding scheme is set to relative...
            
                % Unpack the parameters required to compute the synaptic conductance for a relative subtraction subnetwork.
                [  c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n ] = self.unpack_relative_subtraction_gs_parameters( parameters );
                
                % Compute the synaptic conductance for a relative subtraction subnetwork.
                gs_nk = synapse_utilities.compute_relative_subtraction_gs( c, npm_k, s_k, R_n, Gm_n, dEs_nk, Ia_n );   	% [V] Synaptic Reversal Potential.
                
            else                                                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs_nk; end
            
        end
        

        % Implement a function to compute the maximum synaptic conductance of inversion synapses.
        function [ gs21, self ] = compute_inversion_gs( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                          % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                     % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                      % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                   % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic conductance for an inversion subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                               % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic conductance for an absolute inversion subnetwork.
                [ dEs21, Ia2 ] = self.unpack_absolute_inversion_gs_parameters( parameters );
                
                % Compute the synaptic conductance for an absolue inversion subnetwork.
                gs21 = synapse_utilities.compute_absolute_inversion_gs( dEs21, Ia2 );           	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                          	% If the encoding scheme is set to relative...
            
                % Unpack the parameters required to compute the synaptic conductance for a relative inversion subnetwork.
                [  dEs21, Ia2 ] = self.unpack_relative_inversion_gs_parameters( parameters );
                
                % Compute the synaptic conductance for a relative inversion subnetwork.
                gs21 = synapse_utilities.compute_relative_inversion_gs( dEs21, Ia2 );            	% [V] Synaptic Reversal Potential.
                
            else                                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs21; end

        end


        % Implement a function to compute the maximum synaptic conductance of division numerator synapses.
        function [ gs31, self ] = compute_division_gs31( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                                  % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                             % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                              % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                           % [-] Input Parameters Cell.
            
            % Determine how to compute the synaptic conductance for an division subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                                       % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic conductance for an absolute division subnetwork.
                [ alpha, epsilon, R1, Gm3 ] = self.unpack_absolute_division_gs31_parameters( parameters );
                
                % Compute the synaptic conductance for an absolue division subnetwork.
                gs31 = synapse_utilities.compute_absolute_division_gs31( alpha, epsilon, R1, Gm3 );     	% [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                   % If the encoding scheme is set to relative...
            
                % Unpack the parameters required to compute the synaptic conductance for a relative division subnetwork.
                [  R3, Gm3, dEs31 ] = self.unpack_relative_division_gs31_parameters( parameters );
                
                % Compute the synaptic conductance for a relative division subnetwork.
                gs31 = synapse_utilities.compute_relative_division_gs31( R3, Gm3, dEs31 );                  % [V] Synaptic Reversal Potential.
                
            else                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs31; end
            
        end


        % Implement a function to compute the maximum synaptic conductance of division denominator synapses.
        function [ gs32, self ] = compute_division_gsyn32( self, parameters, encoding_scheme, set_flag, synapse_utilities )
            
            % Set the default input arguments.
            if nargin < 5, synapse_utilities = self.synapse_utilities; end                                          % [class] Synapse Utilities.
            if nargin < 4, set_flag = true; end                                                                     % [T/F] Set Flag.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                      % [str] Encoding Scheme.
            if nargin < 2, parameters = {  }; end                                                                   % [-] Input Parameter Cell.
            
            % Determine how to compute the synaptic conductance for an division subnetwork.
            if strcmpi( encoding_scheme, 'absolute' )                                                               % If the encoding scheme is set to absolute...
                
                % Unpack the parameters required to compute the synaptic conductance for an absolute division subnetwork.
                [ epsilon, R2, Gm3 ] = self.unpack_absolute_division_gs32_parameters( parameters );
                
                % Compute the synaptic conductance for an absolue division subnetwork.
                gs32 = synapse_utilities.compute_absolute_division_gs32( epsilon, R2, Gm3 );                        % [V] Synaptic Reversal Potential.
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                           % If the encoding scheme is set to relative...
            
                % Unpack the parameters required to compute the synaptic conductance for a relative division subnetwork.
                [  c, alpha, epsilon, R3, Gm3, dEs31 ] = self.unpack_relative_division_gs32_parameters( parameters );
                
                % Compute the synaptic conductance for a relative division subnetwork.
                gs32 = synapse_utilities.compute_relative_division_gs32( c, alpha, epsilon, R3, Gm3, dEs31 );       % [V] Synaptic Reversal Potential.
                
            else                                                                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme %s.  Encoding scheme must be one of: ''absolute'', ''relative''', encoding_scheme )
                
            end
                
            % Determine whether to update the synapse object.
            if set_flag, self.g_syn_max = gs32; end
           
        end

        
        %% Enable & Disable Functions
        
        % Implement a function to toogle whether this syanpse is enabled.
        function [ b_enabled, self ] = toggle_enabled( self, b_enabled, set_flag )
            
            % Set the default input arguments.
            if nargin < 3, set_flag = true; end                     % [T/F] Set Flag.
            if narign < 2, b_enabled = self.b_enabled; end          % [T/F] Enabled Flag.
            
            % Toggle whether the neuron is enabled.
            b_enabled = ~b_enabled;                                 % [T/F] Synapse Enabled Flag.
            
            % Determine whether to update the neuron object.
            if set_flag, self.b_enabled = b_enabled; end
            
        end
        
        
        % Implement a function to enable this neuron.
        function [ b_enabled, self ] = enable( self, set_flag )
            
            % Set the default input arguments.
            if nargin < 2, set_flag = true; end                     % [T/F] Set Flag.
            
            % Enable this neuron.
            b_enabled = true;                                   	% [T/F] Synapse Enabled Flag.
            
            % Determine whether to update the neuron object.
            if set_flag, self.b_enabled = b_enabled; end
            
        end
        
        
        % Implement a function to disable this neuron.
        function [ b_enabled, self ] = disable( self, set_flag )
            
            % Set the default input arguments.
            if anrgin < 2, set_flag = true; end                     % [T/F] Set Flag.
            
            % Disable this neuron.
            b_enabled = false;                                  	% [T/F] Synapse Enabled Flag.
            
            % Determine wehther to update the neuron object.
            if set_flag, self.b_enabled = b_enabled; end
            
        end
        
        
        %% Save & Load Functions.
        
        % Implement a function to save synapse data as a matlab object.
        function save( self, directory, file_name, synapse )
            
            % Set the default input arguments.
            if nargin < 4, synapse = self; end                      % [class] Synapse Object to Save.
            if nargin < 3, file_name = 'Synapse.mat'; end           % [str] File Name to Save.
            if nargin < 2, directory = '.'; end                     % [str] Save Directory.
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, synapse )
            
        end
        
        
        % Implement a function to load synapse data as a matlab object.
        function [ synapse, self ] = load( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse.mat'; end           % [str] File Name to Load.
            if nargin < 2, directory = '.'; end                     % [str] Load Directory.
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the synapse object from the loaded data object.
            synapse = data.synapse;
            
        end
        
        
    end
end

