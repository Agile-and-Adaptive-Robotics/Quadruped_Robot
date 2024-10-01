classdef network_class
    
    % This class contains properties and methods related to networks.
    
    %% NETWORK PROPERTIES
    
    % Define the class properties.
    properties
        
        neuron_manager                                                                                                          % [class] Manages Neuron Classes.
        synapse_manager                                                                                                         % [class] Manages Synapse Classes.
        applied_current_manager                                                                                                 % [class] Manages Applied Currents.
        applied_voltage_manager                                                                                                 % [class] Manages Applied Voltages.
        
        dt                                                                                                                      % [s] Network Simulation Timestep.
        tf                                                                                                                      % [s] Network Simulation Duration.
        
        network_utilities                                                                                                       % [class] Performs Fundamental Network Operations.
        numerical_method_utilities                                                                                              % [class] Performs Fundamental Numerical Method Operations.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % ---------- Neuron Properties ----------
        
        % Define the neuron parameters.
        neuron_ID_DEFAULT = 0;                                                                                                  % [#] Default Neuron ID.
        neuron_name_DEFAULT = '';                                                                                               % [-] Default Neuron Name.
        U_DEFUALT = 0;                                                                                                          % [V] Default Membrane Voltage.
        h_DEFAULT = [  ];                                                                                                       % [-] Default Sodium Channel Deactivation Parameter.
        Cm_DEFAULT = 5e-9;                                                                                                      % [C] Default Membrane Capacitance.
        Gm_DEFAULT = 1e-6;                                                                                                      % [S] Default Membrane Conductance.
        Er_DEFAULT = -60e-3;                                                                                                    % [V] Default Equilibrium Voltage.
        R_DEFAULT = 20e-3;                                                                                                      % [V] Default Activation Domain.
        Am_DEFAULT = 1;                                                                                                         % [-] Default Sodium Channel Activation Parameter Amplitude.
        Sm_DEFAULT = -50;                                                                                                       % [-] Default Sodium Channel Activation Parameter Slope.
        dEm_DEFAULT = 40e-3;                                                                                                    % [V] Default Sodium Channel Activation Reversal Potential.
        Ah_DEFAULT = 0.5;                                                                                                       % [-] Default Sodium Channel Deactivation Parameter Amplitude.
        Sh_DEFAULT = 50;                                                                                                        % [-] Default Sodium Channel Deactivation Parameter Slope.
        dEh_DEFAULT = 0;                                                                                                        % [V] Default Sodium Channel Deactivation Reversal Potential.
        dEna_DEFAULT = 110e-3;                                                                                                  % [V] Default Sodium Channel Reversal Potential.
        tauh_max_DEFAULT = 0.25;                                                                                                % [s] Default Maximum Sodium Channel Steady State Time Constant.
        Gna_DEFAULT = 1e-6;                                                                                                     % [S] Default Sodium Channel Conductance.
        Ileak_DEFAULT = 0;                                                                                                      % [A] Default Leak Current.
        Isyn_DEFAULT = 0;                                                                                                       % [A] Default Synaptic Current.
        Ina_DEFAULT = 0;                                                                                                        % [A] Default Sodium Channel Current.
        Itonic_DEFAULT = 0;                                                                                                     % [A] Default Tonic Current.
        Iapp_DEFAULT = 0;                                                                                                       % [A] Default Applied Current.
        Itotal_DEFAULT = 0;                                                                                                     % [A] Default Total Current.
        neuron_enabled_flag_DEFAULT = true;                                                                                     % [T/F] Default Neuron Enabled Flag.

        
        % ---------- Synapse Properties ----------
        
        % Define the synapse parameters.
        synapse_ID_DEFAULT = 0;                                                                                                 % [#] Synapse ID.
        synapse_name_DEFAULT = '';                                                                                              % [-] Synapse Name.
        dEs_DEFAULT = 194e-3;                                                                                                   % [V] Synaptic Reversal Potential.
        gs_DEFAULT = 1e-6;                                                                                                      % [S] Maximum Synaptic Conductance.
        Gs_DEFAULT = 0;                                                                                                         % [S] Synaptic Conductance.
        from_neuron_ID_DEFAULT = -1;                                                                                            % [#] From Neuron ID.
        to_neuron_ID_DEFAULT = -1;                                                                                              % [#] To Neuron ID.
        delta_DEFAULT = 1e-6;                                                                                                   % [-] Subnetwork Output Offset.
        synapse_enabled_flag_DEFAULT = true;                                                                                    % [T/F] Synapse Enabled Flag.
        
        
        % ---------- Transmission Properties ----------

        % Define the number of transmission neurons.
        num_transmission_neurons_DEFAULT = 2;                      	% [#] Default Number of Transmission Neurons.

        % Define the transmission subnetwork gain.
        c_absolute_transmission_DEFAULT = 1;                       	% [-] Absolute Transmission Subnetwork Gain.
        c_relative_transmission_DEFAULT = 1;                      	% [-] Relative Transmission Subnetwork Gain.

        % Define the applied current magnitudes.
        Ian_absolute_transmission_DEFAULT = 0;                      % [A] Absolute Transmission Applied Current.
        Ian_relative_transmission_DEFAULT = 0;                      % [A] Relative Transmission Applied Current.
        
        
        % ---------- Addition Properties ----------

        % Define the number of addition neurons.
        num_addition_neurons_DEFAULT = 3;                        	% [#] Default Number of Addition Neurons.

        % Define the addition subnetwork gain.
        c_absolute_addition_DEFAULT = 1.0;                        	% [-] Absolute Addition Subnetwork Gain.
        c_relative_addition_DEFAULT = 1.0;                       	% [-] Relative Addition Subnetwork Gain.

        % Define the applied current magnitudes.
        Ian_absolute_addition_DEFAULT = 0;                          % [A] Absolute Addition Applied Current.
        Ian_relative_addition_DEFAULT = 0;                          % [A] Relative Addition Applied Current.
        
        
        % ---------- Subtraction Properties ----------

        % Define the number of subtraction neurons.
        num_subtraction_neurons_DEFAULT = 3;                      	% [#] Default Number of Subtraction Neurons.
        num_double_subtraction_neurons_DEFAULT = 4;                	% [#] Default Number of Double Subtraction Neurons.

        % Define subtraction subnetwork parameters.
        s_ks_DEFAULT = [ 1, -1 ];                                 	% [-] Default Subtraction Input Signature.
        
        % Define the subtraction subnetwork gain.
        c_absolute_subtraction_DEFAULT = 1.0;                     	% [-] Absolute Subtraction Subnetwork Gain.
        c_relative_subtraction_DEFAULT = 1.0;                    	% [-] Relative Subtraction Subnetwork Gain.
        
        % Define the applied current magnitude.
        Ian_absolute_subtraction_DEFAULT = 0;                       % [A] Absolute Subtraction Applied Current.
        Ian_relative_subtraction_DEFAULT = 0;                       % [A] Relative Subtraction Applied Current.
        
        
        % ---------- Inversion Properties ----------

        % Define the number of inversion neurons.
        num_inversion_neurons_DEFAULT = 2;                       	% [#] Default Number of Inversion Neurons.

        % Define absolute inversion subnetwork gains.
        c1_absolute_inversion_DEFAULT = 1.0;                      	% [-] Absolute Inversion Gain 1.
        c2_absolute_inversion_DEFAULT = 1.0;                     	% [-] Absolute Inversion Gain 2.
        c3_absolute_inversion_DEFAULT = 1.0;                      	% [-] Absolute Inversion Gain 3.
        
        % Define relative inversion subnetwork gains.
        c1_relative_inversion_DEFAULT = 1.0;                       	% [-] Relative Inversion Gain 1.
        c2_relative_inversion_DEFAULT = 1.0;                      	% [-] Relative Inversion Gain 2.
        c3_relative_inversion_DEFAULT = 1.0;                     	% [-] Relative Inversion Gain 3.
        
        % Define inversion subnetwork offsets.
        delta_absolute_inversion_DEFAULT = 1e-6;                   	% [V] Absolute Inversion Subnetwork Offset.
        delta_relative_inversion_DEFAULT = 1e-6;                 	% [V] Relative Inversion Subnetwork Offset.
        
        % Define the applied current magnitudes.
        Ia2_absolute_inversion_DEFAULT = 20e-9;                     % [A] Absolute Inversion Applied Current 2.
        Ia2_relative_inversion_DEFAULT = 20e-9;                     % [A] Relative Inversion Applied Current 2.
        
        
        % ---------- Reduced Inversion Properties ----------

        % Define the reduced absolute inversion subnetwork gain.
        c1_reduced_absolute_inversion_DEFAULT = 1.0;               	% [-] Reduced Absolute Inversion Gain 1.
        c2_reduced_absolute_inversion_DEFAULT = 1.0;              	% [-] Reduced Absolute Inversion Gain 2.
        
        % Define the reduced relative inversion subnetwork gain.
        c1_reduced_relative_inversion_DEFAULT = 1.0;            	% [-] Reduced Relative Inversion Gain 1.
        c2_reduced_relative_inversion_DEFAULT = 1.0;              	% [-] Reduced Relative Inversion Gain 2.
        
        % Define reduced inversion subnetwork offsets.
        delta_reduced_absolute_inversion_DEFAULT = 1e-3;            % [V] Reduced Absolute Inversion Offset.
        delta_reduced_relative_inversion_DEFAULT = 1e-3;          	% [V] Reduced Relative Inversion Offset.
        
        % Define the applied current magnitudes.
        Ia2_reduced_absolute_inversion_DEFAULT = 20e-9;          	% [A] Absolute Inversion Applied Current 2.
        Ia2_reduced_relative_inversion_DEFAULT = 20e-9;            	% [A] Relative Inversion Applied Current 2.
        
        
        % ---------- Division Properties ----------

        % Define the number of division neurons.
        num_division_neurons_DEFAULT = 3;                        	% [#] Number of Division Neurons.

        % Define the absolute division subnetwork gains.
        c1_absolute_division_DEFAULT = 1.0;                      	% [-] Absolute Division Gain 1.
        c2_absolute_division_DEFAULT = 1.0;                        	% [-] Absolute Division Gain 2.
        c3_absolute_division_DEFAULT = 1.0;                       	% [-] Absolute Division Gain 3.
        
        % Define the relative division subnetwork gains.
        c1_relative_division_DEFAULT = 1.0;                      	% [-] Relative Division Gain 1.
        c2_relative_division_DEFAULT = 1.0;                       	% [-] Relative Division Gain 2.
        c3_relative_division_DEFAULT = 1.0;                       	% [-] Relative Division Gain 3.
        
        % Define division subnetwork offsets.
        delta_absolute_division_DEFAULT = 1e-3;                   	% [V] Absolute Division Offset.
        delta_relative_division_DEFAULT = 1e-3;                    	% [V] Relative Division Offset.
        
        % Define the applied current magnitudes.
        Ia3_absolute_division_DEFAULT = 0;                          % [A] Absolute Division Applied Current.
        Ia3_relative_division_DEFAULT = 0;                          % [A] Relative Division Applied Current.
        
        
        % ---------- Reduced Division Properties ----------

        % Define the reduced absolute division subnetwork gains.
        c1_reduced_absolute_division_DEFAULT = 1.0;              	% [-] Reduced Absolute Division Gain 1.
        c2_reduced_absolute_division_DEFAULT = 1.0;              	% [-] Reduced Absolute Division Gain 2.
        
        % Define the reduced relative division subnetwork gains.
        c1_reduced_relative_division_DEFAULT = 1.0;               	% [-] Reduced Relative Division Gain 1.
        c2_reduced_relative_division_DEFAULT = 1.0;                	% [-] Reduced Relative Division Gain 2.
        
        % Define reduced division subnetwork offsets.
        delta_reduced_absolute_division_DEFAULT = 1e-3;           	% [V] Reduced Absolute Division Offset.
        delta_reduced_relative_division_DEFAULT = 1e-3;            	% [V] Reduced Relative Division Offset.
        
        % Define the applied current magnitudes.
        Ia3_reduced_absolute_division_DEFAULT = 0;                	% [A] Reduced Absolute Division Applied Current.
        Ia3_reduced_relative_division_DEFAULT = 0;                 	% [A] Reduced Relative Division Applied Current.
        
        
        % ---------- Division After Inversion Properties ----------

        % Define the number of division after inversion neurons.
        num_dai_neurons_DEFAULT = 3;                             	% [#] Number of Division After Inversion Neurons.
        
        % Define the absolute division after inversion subnetwork gains.
        c1_absolute_dai_DEFAULT = 1.0;                            	% [-] Absolute Division Gain 1.
        c2_absolute_dai_DEFAULT = 1.0;                            	% [-] Absolute Division Gain 2.
        c3_absolute_dai_DEFAULT = 1.0;                             	% [-] Absolute Division Gain 3.
        
        % Define the relative division after inversion subnetwork gains.
        c1_relative_dai_DEFAULT = 1.0;                           	% [-] Relative Division Gain 1.
        c2_relative_dai_DEFAULT = 1.0;                            	% [-] Relative Division Gain 2.
        c3_relative_dai_DEFAULT = 1.0;                            	% [-] Relative Division Gain 3.
        
        % Define division after inversion subnetwork offsets.
        delta_absolute_dai_DEFAULT = 2e-3;                       	% [V] Absolute Division After Inversion Offset.
        delta_relative_dai_DEFAULT = 2e-3;                        	% [V] Relative Division After Inversion Offset.
        
        % Define the applied current magnitudes.
        Ia3_absolute_dai_DEFAULT = 0;                               % [A] Absolute Division Applied Current.
        Ia3_relative_dai_DEFAULT = 0;                               % [A] Relative Division Applied Current.
        
        
        % ---------- Reduced Division After Inversion Properties ----------
        
        % Define the reduced absolute division after inversion subnetwork gains.
        c1_reduced_absolute_dai_DEFAULT = 1.0;                      % [-] Reduced Absolute Division Gain 1.
        c2_reduced_absolute_dai_DEFAULT = 1.0;                     	% [-] Reduced Absolute Division Gain 2.
        
        % Define the reduced relative division after inversion subnetwork gains.
        c1_reduced_relative_dai_DEFAULT = 1.0;                   	% [-] Reduced Relative Division Gain 1.
        c2_reduced_relative_dai_DEFAULT = 1.0;                   	% [-] Reduced Relative Division Gain 2.
        
        % Define reduced division after inversion subnetwork offsets.
        delta_reduced_absolute_dai_DEFAULT = 2e-3;              	% [V] Reduced Absolute Division After Inversion Offset.
        delta_reduced_relative_dai_DEFAULT = 2e-3;                	% [V] Reduced Relative Division After Inversion Offset.

        % Define the applied current magnitudes.
        Ia3_reduced_absolute_dai_DEFAULT = 0;                       % [A] Absolute Division Applied Current.
        Ia3_reduced_relative_dai_DEFAULT = 0;                       % [A] Relative Division Applied Current.
        
        
        % ---------- Multiplication Properties ----------

        % Define the number of multiplication neurons.
        num_multiplication_neurons_DEFAULT = 4;                 	% [#] Default Number of Multiplication Neurons.

        
        % ---------- Derivation Properties ----------

        % Define the number of derivation neurons.
        num_derivation_neurons_DEFAULT = 3;                     	% [#] Default Number of Derivation Neurons.

        % Define derivation subnetwork parameters.
        c_derivation_DEFAULT = 1e6;                              	% [-] Default Derivative Subnetwork Gain.
        w_derivation_DEFAULT = 1;                                 	% [Hz?] Default Derivative Subnetwork Cutoff Frequency.
        sf_derivation_DEFAULT = 0.05;                            	% [-] Default Derivative Subnetwork Safety Factor.
        
        
        % ---------- Integration Properties ----------
        
        % Define the number of integration neurons.
        num_integration_neurons_DEFAULT = 2;                    	% [#] Default Number of Integration Neurons.
        num_vbi_neurons_DEFAULT = 4;                               	% [#] Default Number of Voltage Based Integration Neurons.
        num_svbi_neurons_DEFAULT = 9;                             	% [#] Default Number of Split Voltage Based Integration Neurons.
        num_new_msvbi_neurons_DEFAULT = 3;                      	% [#] Default Number of New Modulated Subtraction Voltage Based Integration Neurons.
        num_msvbi_neurons_DEFAULT = 3;                             	% [#] Default Number of Unique Modualted Split Voltage Based Integration Neurons.
        num_mssvbi_neurons_DEFAULT = 16;                         	% [#] Default Total Number of Modualted Split Subtraction Voltage Based Integration Neurons.
        num_sll_neurons_DEFAULT = 4;                             	% [#] Default Number of Split Lead Lag Neurons.
        
        % Define integration subnetwork parameters.
        c_integration_mean_DEFAULT = 0.01e9;                     	% [-] Default Average Integration Gain.
        c_integration_range_DEFAULT = 0.01e9;                      	% [-] Integration Subnetwork Gain Range.

        
        % ---------- Centering Properties ----------

        % Define the number of centering neurons.
        num_centering_neurons_DEFAULT = 5;                       	% [#] Default Number of Centering Neurons.
        num_double_centering_neurons_DEFAULT = 7;                  	% [#] Default Number of Double Centering Neurons.
        num_cds_neurons_DEFAULT = 11;                              	% [#] Default Number of Centered Double Subtraction Neurons.

        
        % ---------- Central Pattern Generator Properties ----------

        % Define the number of cpg neurons.
        num_cpg_neurons_DEFAULT = 2;                              	% [#] Default Number of CPG Neurons.
        num_dcpg_neurons_DEFAULT = 3;                             	% [#] Default Number of Driven CPG Neurons.
        num_dmcpgdcll2cds_neurons_DEFAULT = 1;                    	% [#] Default Number of Driven Multistate CPG Double Centered Lead Lag to Centered Double Subtraction Neurons.

        % Define cpg subnetwork parameters.
        T_oscillation_DEFAULT = 2;                                	% [s] Default Oscillation Period.
        r_oscillation_DEFAULT = 0.90;                              	% [-] Default Oscillation Decay.
        
        % Define applied current parameters.
        Ia_DEFAULT = 0;                                            	% [A] Applied Current.
        Id_max_DEFAULT = 1.25e-9;                                 	% [A] Maximum Drive Current.
        
        % Define the cpg parameters.
        delta_bistable_DEFAULT = -10e-3;
        delta_oscillatory_DEFAUT = 0.01e-3;
            
        % ---------- Simulation Properties ----------
        
        % Define default simulation properties.
        tf_DEFAULT = 1;                                          	% [s] Simulation Duration.
        dt_DEFAULT = 1e-3;                                        	% [s] Simulation Time Step.
        
        % Save and load properties.
        file_name_DEFAULT = 'Network.mat';                        	% [str] Save & Load File Name.
        save_directory_DEFAULT = '.';                              	% [str] Save Directory.
        load_directory_DEFAULT = '.';                              	% [str] Load Directory.

    end
    
    
    %% NETWORK METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = network_class( dt, tf, neuron_manager, synapse_manager, applied_current_manager, applied_voltage_manager, network_utilities, numerical_method_utilities )
            
            %{
            Input(s):
                dt                          =   [s] Simulation Timestep.
                tf                          =   [s] Simulation Duration.
                neuron_manager              =   [class] Neuron Manager Class.
                synapse_manager             =   [class] Synapse Manager Class.
                applied_current_manager     =   [class] Applied Current Manager Class.
                applied_voltage_manager     =   [class] Applied Voltage Manager Class.
                
            Output(s):
                self                        =   [class] Neural Network Class.
            %}
            
            % Set the default input arguments.
            if nargin < 8, numerical_method_utilities = numerical_method_utilities_class(  ); end           % [class] Numerical Method Utilities Class.
            if nargin < 7, network_utilities = network_utilities_class(  ); end                             % [class] Network Utilities Class.
            if nargin < 6, applied_voltage_manager = applied_voltage_manager_class(  ); end                 % [class] Applied Voltage Manager Class.
            if nargin < 5, applied_current_manager = applied_current_manager_class(  ); end                 % [class] Applied Current Manager Class.
            if nargin < 4, synapse_manager = synapse_manager_class(  ); end                                 % [class] Synapse Manager.
            if nargin < 3, neuron_manager = neuron_manager_class(  ); end                                   % [class] Neuron Manager.
            if nargin < 2, tf = self.tf_DEFAULT; end                                                        % [s] Simulation Duration.
            if nargin < 1, dt = self.dt_DEFAULT; end                                                        % [s] Simulation Timestep.
            
            % Store the utility classes.
            self.numerical_method_utilities = numerical_method_utilities;
            self.network_utilities = network_utilities;
            
            % Store the managers.
            self.applied_voltage_manager = applied_voltage_manager;
            self.applied_current_manager = applied_current_manager;
            self.synapse_manager = synapse_manager;
            self.neuron_manager = neuron_manager;

            % Store the simulation information.
            self.tf = tf;
            self.dt = dt;
            
            % Compute and set the synaptic conductances.
            [ ~, ~, ~, self ] = self.compute_Gs( 'all', neuron_manager, synapse_manager, true, 'ignore', network_utilities );
            
        end
        
        
        %% Specific Get Functions.
        
        % Implement a function to construct the delta matrix from the stored delta scalars.
        function deltas = get_deltas( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the delta matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs	=   [#] Neuron IDs.
                
            Output(s):
                deltas      =   [V] Network Bifurcation Parameters.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                              % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                                % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                                	% [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            deltas = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                                                                                                      % Iterate through each synapse...
                
                % Determine how to assign the delta value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                    % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the delta matrix associated with this neuron.
                    deltas( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).delta;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )             % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic reversal potential matrix from the stored synaptic reversal potential scalars.
        function dEs = get_dEs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the synaptic reversal potential matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                dEs     =   [V] Synaptic Reversal Potentials.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                                  % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                                    % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the deltas matrix.
            dEs = zeros( num_neurons );
            
            % Retrieve the entries of the delta matrix.
            for k = 1:num_syanpses                                                                                                  	% Iterate through each synapse...
                
                % Determine how to assign the synaptic reversal potential value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                    % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron logical index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron logical index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic reversal potential matrix associated with this neuron.
                    dEs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).dEs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )             % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                  	% Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the maximum synaptic conductance matrix from the stored maximum synaptic conductance scalars.
        function gs = get_gs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieves the synaptic conductance matrix associated with the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs	=	[#] Neuron IDs.
            
            Output(s):
                gs          =   [S] Maximum Synaptic Conductances.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                              % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                                % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                                  % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons and synapses.
            num_neurons = length( neuron_IDs );
            num_synapses = length( synapse_IDs );
            
            % Preallocate the maximum synaptic conductance matrix.
            gs = zeros( num_neurons );
            
            % Retrieve the entries of the maximum synaptic conductance matrix.
            for k = 1:num_synapses                                                                                                      % Iterate through each synapse...
                
                % Determine how to assign the maximum synaptic conductance value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                    % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the maximum synaptic conductance matrix associated with this neuron.
                    gs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).gs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )             % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                 	% Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to construct the synaptic condcutance matrix from the stored synaptic conductance scalars.
        function Gs = get_Gs( self, neuron_IDs, neuron_manager, synapse_manager )
            
            % Retrieve the synaptic conductance matrix for the given neuron IDs.
            
            %{
            Input(s):
                neuron_IDs  =   [#] Neuron IDs.
            
            Output(s):
                Gs      =   [S] Synaptic Conductances.
            %}
            
            % Set the default input arguments.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                                                          % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                                                            % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                                                              % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Ensure that the neuron IDs are unique.
            assert( all( unique( neuron_IDs ) == neuron_IDs ), 'Neuron IDs must be unique.' )
            
            % Retrieve the synapse IDs relevant to the given neuron IDs.
            synapse_IDs = synapse_manager.neuron_IDs2synapse_IDs( neuron_IDs, 'ignore' );
            
            % Retrieve the synapse indexes associated with the given synapse IDs.
            synapse_indexes = synapse_manager.get_synapse_indexes( synapse_IDs );
            
            % Retrieve the number of relevant neurons.
            num_neurons = length( neuron_IDs );
            num_syanpses = length( synapse_IDs );
            
            % Preallocate the synaptic conductance matrix.
            Gs = zeros( num_neurons );
            
            % Retrieve the entries of the synaptic conductance matrix.
            for k = 1:num_syanpses                                                                                                                              % Iterate through each synapse...
                
                % Determine how to assign the synaptic conductance value.
                if ( synapse_indexes( k ) > 0 ) && ( synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                            % If the synapse index is greater than zero and this synapse is enabled...
                    
                    % Retrieve the from neuron index.
                    from_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).from_neuron_ID == neuron_IDs;
                    
                    % Retrieve the to neuron index.
                    to_neuron_index_local_logical = synapse_manager.synapses( synapse_indexes( k ) ).to_neuron_ID == neuron_IDs;
                    
                    % Set the component of the synaptic conductance matrix associated with this neuron.
                    Gs( to_neuron_index_local_logical, from_neuron_index_local_logical ) = synapse_manager.synapses( synapse_indexes( k ) ).Gs;
                    
                elseif ( synapse_indexes( k ) == -1 ) || ( ~synapse_manager.synapses( synapse_indexes( k ) ).enabled_flag )                                     % If the synapse index is negative one...
                    
                    % Do nothing. (This keeps the default value of zero.)
                    
                else                                                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid synapse index %0.2f.', synapse_indexes( k ) )
                    
                end
                
            end
            
        end
        
        
        %% Specific Set Functions.
        
        % Implement a function to set the deltas of each synapse based on the delta matrix.
        function [ synapses, synapse_manager, self ] = set_deltas( self, deltas, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the bifurcation parameter values of the neurons specified by neuron_IDs based on the entries of the given delta matrix.
            
            %{
            Input(s):
                deltas      =   [V] Bifurcation Parameter Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the delta of each of the synapses in this network to agree with the delta matrix.
            for k1 = 1:num_neurons                                                                                   	% Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                  % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                  % If the synapse ID is greater than zero...
                        
                        % Set the value of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, deltas( k1, k2 ), 'delta' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )          % If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                               	% Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )       
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the synaptic reversal potentials of each synapse based on the synaptic reversal matrix.
        function [ synapses, synapse_manager, self ] = set_dEs( self, dEs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the synaptic reversal potentials of the neurons specified by neuron_IDs based on the entries of the given dEs matrix.
            
            %{
            Input(s):
                dEs         =   [V] Synaptic Reversal Potential Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the synaptic reversal potential of each of the synapses in this network to agree with the synaptic reversal potential matrix.
            for k1 = 1:num_neurons                                                                                     	% Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                  % Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                	% If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, dEs( k1, k2 ), 'dEs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )         	% If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                              	% Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID ) 
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the maximum synaptic conductances of each synapse based on the maximum synaptic conductance matrix.
        function [ synapses, synapse_manager, self ] = set_gs( self, gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the maximum synaptic conductance of the neurons specified by neuron_IDs based on the entries of the given gs matrix.
            
            %{
            Input(s):
                gs          =   [V] Maximum Synaptic Conductance Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the maximum synaptic conductance matrix.
            for k1 = 1:num_neurons                                                                                  	% Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                	% Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synpase index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID > 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )                	% If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, gs( k1, k2 ), 'gs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )         	% If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                               	% Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % Implement a function to set the synaptic conductance of each synapse based on the synaptic conductance matrix.
        function [ synapses, synapse_manager, self ] = set_Gs( self, Gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Sets the synaptic conductance of the neurons specified by neuron_IDs based on the entries of the given Gs matrix.
            
            %{
            Input(s):
                Gs      =   [V] Synaptic Conductance Matrix.
                neuron_IDs  =   [#] IDs of Neurons Whose Parameters Should be Set.
            
            Output(s):
                self        =   [class] Updated Network.
            %}
            
            % Set the default neuron IDs.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Set the maximum synaptic conductnace of each of the synapses in this network to agree with the synaptic conductance matrix.
            for k1 = 1:num_neurons                                                                                   	% Iterate through each of the to neurons...
                for k2 = 1:num_neurons                                                                                 	% Iterate through each of the from neurons...
                    
                    % Retrieve the synapse ID.
                    synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( k2 ), neuron_IDs( k1 ), synapse_manager.synapses, undetected_option );
                    
                    % Retrieve the synapse index.
                    synapse_index = synapse_manager.get_synapse_index( synapse_ID, synapse_manager.synapses, undetected_option );
                    
                    % Determine how to set the value for this synapse.
                    if ( synapse_ID >= 0) && ( synapse_manager.synapses( synapse_index ).enabled_flag )              	% If the synapse ID is greater than zero...
                        
                        % Set the maximum synaptic conductance of this synapse.
                        synapse_manager = synapse_manager.set_synapse_property( synapse_ID, Gs( k1, k2 ), 'Gs' );
                        
                    elseif ( synapse_ID == -1 ) || ( ~synapse_manager.synapses( synapse_index ).enabled_flag )         	% If the synapse ID is negative one...
                        
                        % Do nothing.
                        
                    else                                                                                              	% Otherwise...
                        
                        % Throw an error.
                        error( 'Synapse ID %0.2f is not recognized.', synapse_ID )
                        
                    end
                    
                end
            end
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        %% Compute Synaptic Conductance Functions.
        
        % Implement a function to compute the synaptic conductance for each synapse.
        function [ Gs, synapses, synapse_manager, self ] = compute_Gs( self, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Define the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron properties.
            Us = neuron_manager.get_neuron_property( neuron_IDs, 'U', true, neuron_manager.neurons, undetected_option )';
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the maximum synaptic conductances.
            gs = self.get_gs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Compute the synaptic conductance.
            Gs = network_utilities.compute_Gs( Us, Rs, gs );
            
            % Set the synaptic conductances (if appropriate).
            [ synapses, synapse_manager, self ] = self.set_Gs( Gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option );
            
        end
        
        
        %% Compute Maximum Synaptic Conductance Functions.
             
        %{
        
        % Implement a function to compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
        function [ gs, synapses, synapse_manager, self ] = compute_cpg_gs( self, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default neuron IDs.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 2, neuron_IDs = 'all'; end                                                                      % [#] Neuron IDs.
            
            % Validate the neuron IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            
            % Retrieve the neuron membrane conductances.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron membrane voltage ranges.
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            
            % Retrieve the sodium channel conductances.
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron sodium channel activation parameters.
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option )';
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option )';
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the neuron sodium channel deactivation parameters.
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option )';
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option )';
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the sodium channel reversal potentials.
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the tonic currents.
            Itonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option )';
            
            % Retrieve the synapse properties.
            deltas = self.get_deltas( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Compute the maximum synaptic conductances required to design a multistate CPG with the specified deltas.
            gs = network_utilities.compute_cpg_gs_matrix( deltas, Gms, Rs, dEs, Gnas, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, Itonics, neuron_manager.neuron_utilities );
            
            % Set the synaptic conductances (if appropriate).
            [ synapses, synapse_manager, self ] = self.set_gs( gs, neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option );
            
        end
        
        %}
        
        
        %% Compute Synaptic Reversal Potential Functions.
        
        % Implement a function to compute the synaptic reversal potentials for an integration subnetwork.
        function [ dEs, synapses, synapse_manager, self ] = compute_integration_dEs( self, neuron_IDs, synapse_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Validate the neuron and synapse IDs.
            neuron_IDs = neuron_manager.validate_neuron_IDs( neuron_IDs );
            synapse_IDs = synapse_manager.validate_synapse_IDs( synapse_IDs );
            
            % Retrieve the membrane conductances and voltage domains.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve the maximum synaptic conductances
            gs = synapse_manager.get_synapse_property( synapse_IDs, 'gs', true, synapse_manager.synapses, undetected_option )';
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            assert( gs( 1 ) == gs( 2 ), 'Integration subnetwork neurons must have symmetrical maximum synaptic conductances.' );
            
            % Compute the synaptic reversal potentials for an integration subnetwork.
            dEs = network_utilities.compute_integration_dEs( Gms( 1 ), Rs( 1 ), gs( 1 ) );
            
            % Set the synaptic reversal potentials of the relevant synapses.
            synapse_manager = synapse_manager.set_synapse_property( synapse_IDs, dEs*ones( 1, 2 ), 'dEs' );
            
            % Retrieve the updated synapses.
            synapses = synapse_manager.synapses;
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        

        %% Network Deletion Functions.
        
        % Implement a function to delete network components.
        function [ objects, object_managers, self ] = delete( self, object_types, object_ids, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            %{
            Input(s):
                object_types    =   [cell, str] Type of Network Object to Delete.  Must be one of: Neurons, Synapses, or Currents.
                object_ids      =   [cell, #] IDs Associated with Objects that Should be Deleted.
            
            Output(s):
                self            =   [class] Updated Network Object.
            %}
            
            % Define default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the number of different object types to delete.
            num_types = length( object_types );
            
            % Preallocate cells to store the updated objects and object managers.
            objects = cell( 1, num_types );
            object_managers = cell( 1, num_types );
            
            % Delete each of the specified objects for each of the given types.
            for k = 1:num_types                                                                                                 % Iterate through each of the object types...
                
                % Determine which type of objects should be deleted.
                if strcmpi( object_types{ k }, 'neuron' ) || strcmpi( object_types{ k }, 'neurons' )                            % If we want to delete neurons...
                    
                    % Delete the specified neurons.
                    [ objects{ k }, object_managers{ k } ] = neuron_manager.delete_neurons( object_ids{ k }, neuron_manager.neurons, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.neuron_manager = object_managers{ k }; end
                    
                elseif strcmpi( object_types{ k }, 'synapse' ) || strcmpi( object_types{ k }, 'synapses' )                      % If we want to delete synapses...
                    
                    % Delete the specified synapses.
                    [ objects{ k }, object_managers{ k } ] = synapse_manager.delete_synapses( object_ids{ k }, synapse_manager.synapses, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.synapse_manager = object_managers{ k }; end
                    
                elseif strcmpi( object_types{ k }, 'current' ) || strcmpi( object_types{ k }, 'currents' )                      % If we want to delete applied currents...
                    
                    % Delete the specified applied currents.                    
                    [ objects{ k }, object_managers{ k } ] = applied_current_manager.delete_applied_currents( object_ids{ k }, applied_current_manager.applied_currents, true, undetected_option );
                    
                    % Determine whether to update the network object.
                    if set_flag, self.applied_current_manager = object_managers{ k }; end
                    
                else                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid network object type %s selected for deletion.', object_types{ k } )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to delete all of the components in a network.
        function [ neuron_manager, synapse_manager, applied_current_manager, self ] = delete_all( self, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 2, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Delete all of the neurons.
            [ ~, neuron_manager ] = neuron_manager.delete_neurons( 'all', neuron_manager.neurons, true, undetected_option );
            
            % Delete all of the synapses.
            [ ~, synapse_manager ] = synapse_manager.delete_synapses( 'all', synapse_manager.synapses, true, undetected_option );
            
            % Delete all of the applied currents.
            [ ~, applied_current_manager ] = applied_current_manager.delete_applied_currents( 'all', applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag                                                                                                 % If we want to update the network object...
               
                % Update the network's neuron manager.
                self.neuron_manager = neuron_manager;
                
                % Update the network's synapse manager.
                self.synapse_manager = synapse_manager;
                
                % Update the applied current manager.
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        %% Subnetwork Applied Current Design Functions.
        
        % ---------- Addition Subnetwork Functions ----------

        %{
        % Implement a function to design the applied currents for a addition subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_addition_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            
            % Design the absolute addition applied currents.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_addition_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        %}
        
        
        % ---------- Subtraction Subnetwork Functions ----------

        %{
        % Implement a function to design the applied currents for a subtraction subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_subtraction_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            
            % Design the absolute subtraction applied currents.
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_subtraction_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        %}
        
        
        % ---------- Inversion Subnetwork Functions ----------

        % Implement a function to design the applied current for an inversion subnetwork.
        function [ Ias2, applied_currents, applied_current_manager, self ] = design_inversion_applied_current( self, neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the necessary neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm2, R2 };
            
            % Design the inversion subnetwork applied current.
            [ Ias2, applied_currents, applied_current_manager ] = applied_current_manager.design_inversion_applied_current( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option ); 
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to design the applied current for a reduced inversion subnetwork.
        function [ Ias2, applied_currents, applied_current_manager, self ] = design_reduced_inversion_applied_current( self, neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the necessary neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm2, R2 };
            
            % Design the inversion subnetwork applied current.                        
            [ Ias2, applied_currents, applied_current_manager ] = applied_current_manager.design_reduced_inversion_applied_current( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------

        %{
        % Implement a function to design the applied current for a division subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_division_applied_currents( self, neuron_IDs, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            
            % Design the absolute division applied currents.                        
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_division_applied_currents( neuron_IDs, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        %}
              
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to design the applied currents for a multiplication subnetwork.
        function [ Ias3, applied_currents, applied_current_manager, self ] = design_multiplication_applied_current( self, neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)

            % Retrieve the necessary neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm3, R3 };
            
            % Design the multiplication subnetwork applied current.
            [ Ias3, applied_currents, applied_current_manager ] = applied_current_manager.design_multiplication_applied_current( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to design the applied currents for a multiplication subnetwork.
        function [ Ias3, applied_currents, applied_current_manager, self ] = design_reduced_multiplication_applied_current( self, neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)

            % Retrieve the necessary neuron properties.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gm3, R3 };
            
            % Design the multiplication subnetwork applied current.
            [ Ias3, applied_currents, applied_current_manager ] = applied_current_manager.design_reduced_multiplication_applied_current( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------

        % Implement a function to design the applied currents for an integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_integration_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option );
            
            % Ensure that the integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms( 1 ), Rs( 1 ) };
            
            % Design the integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_integration_applied_currents( neuron_IDs, parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_vbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the membrane conductances and voltage domain.
            Gms = neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs( 3:4 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gms( 1 ) == Gms( 2 ), 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( Rs( 1 ) == Rs( 2 ), 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms( 1 ), Rs( 1 ) };
            
            % Design the voltage based integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_vbi_applied_currents( neuron_IDs( 3:4 ), parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a split voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_svbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the relevant membrane conductance.
            Gm3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gm4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gm9 = neuron_manager.get_neuron_property( neuron_IDs( 9 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            Gms = [ Gm3, Gm4, Gm9 ];
            
            % Retrieve the relevant voltage domains.
            R3 = neuron_manager.get_neuron_property( neuron_IDs( 3 ), 'R', true, neuron_manager.neurons, undetected_option );
            R4 = neuron_manager.get_neuron_property( neuron_IDs( 4 ), 'R', true, neuron_manager.neurons, undetected_option );
            Rs = [ R3, R4 ];
            
            % Ensure that the voltage based integration network is symmetric.
            assert( Gm3 == Gm4, 'Integration subnetwork neurons must have symmetrical membrance conductances.' );
            assert( R3 == R4, 'Integration subnetwork neurons must have symmetrical voltage domains.' );
            
            % Store the neuron properties in a parameters cell.
            parameters = { Gms, Rs };
            
            % Design the voltage based integration subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_svbi_applied_currents( [ neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 9 ) ], parameters, encoding_scheme, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a modulated split voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_msvbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_svbi_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the applied currents for a modulated split difference voltage based integration subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_mssvbi_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the modulated split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_msvbi_applied_currents( neuron_IDs( 5:end ), neuron_manager, applied_current_manager, encoding_scheme, set_flag, undetected_option );
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------
                
        % Implement a function to design the applied currents for a centering subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_centering_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Retrieve the necessary neuron properties.
            Gm2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R2 = neuron_manager.get_neuron_property( neuron_IDs( 2 ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Design the centering subnetwork applied current.            
            [ Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_centering_applied_current( neuron_IDs, Gm2, R2, applied_current_manager.applied_currents, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a double centering subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_double_centering_applied_currents( self, neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the double centering applied currents (in the same way as the single centering applied currents).            
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the applied currents for a centered double subtraction subnetwork.
        function [ Ias, applied_currents, applied_current_manager, self ] = design_cds_applied_currents( self, neuron_IDs_cell, neuron_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the applied currents for a double centering subnetwork.
            [ Ias, applied_currents, applied_current_manager, self ] = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager, set_flag, undetected_option );
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to design the applied currents for a multistate cpg subnetwork.
        function [ ts, Ias, applied_currents, applied_current_manager, self ] = design_mcpg_applied_currents( self, neuron_IDs, dt, tf, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 5, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % Design the applied currents for a multistate cpg subnetwork.            
            [ ts, Ias, applied_currents, applied_current_manager ] = applied_current_manager.design_mcpg_applied_current( neuron_IDs, dt, tf, applied_current_manager.applied_currents, filter_disabled_flag, true, process_option, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
        % Implement a function to design the applied currents for a driven multistate cpg subnetwork.
        function [ ts, Ias, applied_currents, applied_current_manager, self ] = design_dmcpg_applied_currents( self, neuron_IDs, dt, tf, neuron_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                   	% [str] Undetected Option.
            if nargin < 9, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % Design the multistate cpg applied currents.            
            [ ts_mcpg, Ias_mcpg, applied_currents, applied_current_manager, ~ ] = self.design_mcpg_applied_currents( neuron_IDs( 1:( end - 1 ) ), dt, tf, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option );
            
            % Retrieve the relevant neuron properties of the drive neuron.
            Gm = neuron_manager.get_neuron_property( neuron_IDs( end ), 'Gm', true, neuron_manager.neurons, undetected_option );
            R = neuron_manager.get_neuron_property( neuron_IDs( end ), 'R', true, neuron_manager.neurons, undetected_option );
            
            % Design the driven multistate cpg applied current.            
            [ ts_d, Ias_d, applied_currents, applied_current_manager ] = applied_current_manager.design_dmcpg_applied_current( neuron_IDs( end ), Gm, R, dt, tf, applied_currents, filter_disabled_flag, true, process_option, undetected_option );
            
            % Store the applied current time and magnitude vectors as arrays.
            ts = [ ts_mcpg, ts_d ];
            Ias = [ Ias_mcpg, Ias_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.applied_current_manager = applied_current_manager; end
            
        end
        
        
         %{
%         % Implement a function to design the applied currents for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
%             if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
%             
%             % Retrieve the number of cpg neurons.
%             num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Design the applied currents for the driven multistate cpg subnetworks.
%             self = self.design_dmcpg_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             self = self.design_dmcpg_applied_currents( neuron_IDs_cell{ 2 }, dt, tf, neuron_manager, applied_current_manager );
% 
%             % Design the applied currents for the modulated split subtraction voltage based integration subnetworks.
%             for k = 1:num_cpg_neurons                               % Iterate through each of the cpg neurons...
%                 
%                 % Design the applied currents for this modulated split subtraction voltage based integration subnetwork
%                 self = self.design_mssvbi_applied_currents( neuron_IDs_cell{ k + 2 }, neuron_manager, applied_current_manager );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for a driven multistate cpg double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
%             if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
%             
%             % Design the applied currents for the driven multistate cpg split lead lag subnetwork.
%             self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             
%             % Design the applied currents for a double centering subnetwork.
%             self = self.design_double_centering_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents that connect the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
%         function self = design_dmcpgdcll2cds_applied_current( self, neuron_ID, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             
%             % Retrieve the necessary neuron properties.
%             Gm = neuron_manager.get_neuron_property( neuron_ID, 'Gm', true, neuron_manager.neurons, undetected_option );
%             R = neuron_manager.get_neuron_property( neuron_ID, 'R', true, neuron_manager.neurons, undetected_option );
%             
%             % Design the centering subnetwork applied current.
%             applied_current_manager = applied_current_manager.design_dmcpgdcll2cds_applied_current( neuron_ID, Gm, R );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_applied_currents( self, neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
%             if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
%             
%             % Design the applied currents for the driven multistate cpg double centered lead lag subnetwork.
%             self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell{ 1 }, dt, tf, neuron_manager, applied_current_manager );
%             
%             % Design the applied currents for the centered double subtraction subnetwork.
%             self = self.design_cds_applied_currents( neuron_IDs_cell{ 2 }, neuron_manager, applied_current_manager );
%             
%             % Design the desired lead lag applied current.
%             self = self.design_dmcpgdcll2cds_applied_current( neuron_IDs_cell{ 3 }, neuron_manager, applied_current_manager );
%             
%         end
%         
%         
%         % Implement a function to design the applied currents for a closed loop proportional controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_applied_currents( self, neuron_IDs_cell, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             
%             % Design the applied currents for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager );
%             
%         end
        %}
        
        
        %% Subnetwork Neuron Design Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function [ Gnas, R2, neurons, neuron_manager, self ] = design_transmission_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Neuron Design Parameters.
            
            % Design the transmission subnetwork neurons.            
            [ Gnas, R2, neurons, neuron_manager ] = neuron_manager.design_transmission_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        %{
        % Implement a function to design the neurons for a transmission subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_slow_transmission_neurons( self, neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the slow transmission subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_slow_transmission_neurons( neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        %}
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to design the neurons for an addition subnetwork.
        function [ Gnas, Rn, neurons, neuron_manager, self ] = design_addition_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Neuron Design Parameters.
            
            % Design the addition subnetwork neurons.                        
            [ Gnas, Rn, neurons, neuron_manager ] = neuron_manager.design_addition_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to design the neurons for a subtraction subnetwork.
        function [ Gnas, Rn, neurons, neuron_manager, self ] = design_subtraction_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Neuron Design Parameters.
            
            % Design the subtraction subnetwork neurons.                        
            [ Gnas, Rn, neurons, neuron_manager ] = neuron_manager.design_subtraction_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        %{
        % Implement a function to design the neurons for a double subtraction subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_double_subtraction_neurons( self, neuron_IDs, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the double subtraction subnetwork neurons.
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_double_subtraction_neurons( neuron_IDs, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        %}
        
        
        % ---------- Inversion Subnetwork Functions ----------

        % Implement a function to design the neurons for an inversion subnetwork.
        function [ Gnas, R2, neurons, neuron_manager, self ] = design_inversion_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { k_inversion, epsilon_inversion }.

            % Design the inversion subnetwork neurons.                        
            [ Gnas, R2, neurons, neuron_manager ] = neuron_manager.design_inversion_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to design the neurons for a reduced inversion subnetwork.
        function [ Gnas, R2, neurons, neuron_manager, self ] = design_reduced_inversion_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { k_inversion, epsilon_inversion }.

            % Design the inversion subnetwork neurons.                        
            [ Gnas, R2, neurons, neuron_manager ] = neuron_manager.design_reduced_inversion_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------

        % Implement a function to design the neurons for a division subnetwork.
        function [ Gnas, R3, neurons, neuron_manager, self ] = design_division_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { c, alpha, epsilon }
            
            % Design the division subnetwork neurons.            
            [ Gnas, R3, neurons, neuron_manager ] = neuron_manager.design_division_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to design the neurons for a reduced division subnetwork.
        function [ Gnas, R3, neurons, neuron_manager, self ] = design_reduced_division_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { c, alpha, epsilon }
            
            % Design the division subnetwork neurons.            
            [ Gnas, R3, neurons, neuron_manager ] = neuron_manager.design_reduced_division_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to design the neurons for a division after inversion subnetwork.
        function [ Gnas, R3, neurons, neuron_manager, self ] = design_dai_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { c, alpha, epsilon }
            
            % Design the division subnetwork neurons.            
            [ Gnas, R3, neurons, neuron_manager ] = neuron_manager.design_dai_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                                    
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to design the neurons for a reduced division after inversion subnetwork.
        function [ Gnas, R3, neurons, neuron_manager, self ] = design_reduced_dai_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { c, alpha, epsilon }
            
            % Design the division subnetwork neurons.            
            [ Gnas, R3, neurons, neuron_manager ] = neuron_manager.design_reduced_dai_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                                    
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to design the neurons for a multiplication subnetwork.
        function [ Gnas, Rs, neurons, neuron_manager, self ] = design_multiplication_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end

            % Design the multiplication subnetwork neurons.            
            [ Gnas, Rs, neurons, neuron_manager ] = neuron_manager.design_multiplication_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to design the neurons for a reduced multiplication subnetwork.
        function [ Gnas, Rs, neurons, neuron_manager, self ] = design_reduced_multiplication_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end

            % Design the multiplication subnetwork neurons.            
            [ Gnas, Rs, neurons, neuron_manager ] = neuron_manager.design_reduced_multiplication_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager.neurons, true, undetected_option );
                        
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------

        %{
        % Implement a function to design the neurons for a centering subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_centering_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the addition subnetwork neurons.            
            [ Gnas_addition, Gms_addition, Cms_addition, Rs_addition, ~, neuron_manager, network ] = self.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ], neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the subtraction subnetwork neurons.            
            [ Gnas_subtraction, Gms_subtraction, Cms_subtraction, Rs_subtraction, neurons, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_addition, Gnas_subtraction ];
            Gms = [ Gms_addition, Gms_subtraction ];
            Cms = [ Cms_addition, Cms_subtraction ];
            Rs = [ Rs_addition, Rs_subtraction ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the neurons for a double centering subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_double_centering_neurons( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the addition subnetwork neurons.
            [ Gnas_addition1, Gms_addition1, Cms_addition1, Rs_addition1, ~, neuron_manager, network ] = self.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ], neuron_manager, encoding_scheme, true, undetected_option );
            [ Gnas_addition2, Gms_addition2, Cms_addition2, Rs_addition2, ~, neuron_manager, network ] = network.design_addition_neurons( [ neuron_IDs( 1 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ], neuron_manager, encoding_scheme, true, undetected_option );

            % Design the subtraction subnetwork neurons.
            [ Gnas_subtraction1, Gms_subtraction1, Cms_subtraction1, Rs_subtraction1, ~, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 6 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );
            [ Gnas_subtraction2, Gms_subtraction2, Cms_subtraction2, Rs_subtraction2, neurons, neuron_manager, network ] = network.design_subtraction_neurons( [ neuron_IDs( 5 ), neuron_IDs( 1 ), neuron_IDs( 7 ) ], neuron_manager, parameters, encoding_scheme, true, undetected_option );

            % Concatenate the neuron properties.
            Gnas = [ Gnas_addition1, Gnas_addition2, Gnas_subtraction1, Gnas_subtraction2 ];
            Gms = [ Gms_addition1, Gms_addition2, Gms_subtraction1, Gms_subtraction2 ];
            Cms = [ Cms_addition1, Cms_addition2, Cms_subtraction1, Cms_subtraction2 ];
            Rs = [ Rs_addition1, Rs_addition2, Rs_subtraction1, Rs_subtraction2 ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the neurons for a centered double subtraction subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, self ] = design_cds_neurons( self, neuron_IDs_cell, parameters, encoding_scheme, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, parameters = {  }; end
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the double subtraction subnetwork neurons.            
            [ Gnas_ds, Cms_ds, ~, neuron_manager, network ] = self.design_double_subtraction_neurons( neuron_IDs_cell{ 1 }, neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the double centering subnetwork neurons.            
            [ Gnas_dc, Gms, Cms_dc, Rs, neurons, neuron_manager, network ] = network.design_double_centering_neurons( neuron_IDs_cell{ 2 }, neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_ds, Gnas_dc ];
            Cms = [ Cms_ds, Cms_dc ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        %}
        
        
        % ---------- Derivation Subnetwork Functions ----------

        % Implement a function to design the neurons for a derivation subnetwork.
        function [ Gnas, Gms, Cms, neurons, neuron_manager, self ] = design_derivation_neurons( self, neuron_IDs, k, w, safety_factor, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end                                                           % [-] Derivation Subnetwork Gain.
            
            % Design the derivation subnetwork neurons.            
            [ Gnas, Gms, Cms, neurons, neuron_manager ] = neuron_manager.design_derivation_neurons( neuron_IDs, k, w, safety_factor, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------

        % Implement a function to design the neurons for an integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_integration_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the integration subnetwork neurons.
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_integration_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_vbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_vbi_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a split voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_svbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_svbi_neurons( neuron_IDs, ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulated split voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_msvbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the split voltage based integration neurons.            
            [ Gnas_svbi, Cms_svbi, ~, neuron_manager ] = neuron_manager.design_svbi_neurons( neuron_IDs( 1:9 ), ki_mean, neuron_manager.neurons, true, undetected_option );
            
            % Design the modulation neurons.            
            [ Gnas_mod, Cms_mod, neurons, neuron_manager ] = neuron_manager.design_modulation_neurons( neuron_IDs( 10:12 ), neuron_manager.neurons, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_svbi, Gnas_mod ];
            Cms = [ Cms_svbi, Cms_mod ];
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulated split difference voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_mssvbi_neurons( self, neuron_IDs, ki_mean, neuron_manager, encoding_scheme, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the double subtraction neurons.            
            [ Gnas_ds, Cms_ds, ~, neuron_manager, network ] = self.design_double_subtraction_neurons( neuron_IDs( 1:4 ), neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the modulated split voltage based integration neurons.            
            [ Gnas_msvbi, Cms_msvbi, neurons, neuron_manager, network ] = network.design_msvbi_neurons( neuron_IDs( 5:end ), ki_mean, neuron_manager, true, undetected_option );
            
            % Concatenate the neuron properties.
            Gnas = [ Gnas_ds, Gnas_msvbi ];
            Cms = [ Cms_ds, Cms_msvbi ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------

        % Implement a function to design the neurons for a multistate cpg subnetwork.
        function [ Gnas, neurons, neuron_manager, self ] = design_mcpg_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the multistate cpg subnetwork neurons.            
            [ Gnas, neurons, neuron_manager ] = neuron_manager.design_mcpg_neurons( neuron_IDs, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg subnetwork.
        function [ Gnas, neurons, neuron_manager, self ] = design_dmcpg_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the multistate cpg neurons.
            [ Gnas_mcpg, ~, neuron_manager, ~ ] = self.design_mcpg_neurons( neuron_IDs( 1:( end - 1 ) ), neuron_manager, set_flag, undetected_option );
            
            % Design the drive neuron.            
            [ Gnas_d, neurons, neuron_manager ] = neuron_manager.design_dmcpg_neurons( neuron_IDs( end ), neuron_manager.neurons, true, undetected_option );
            
            % Concatenate the sodium channel conductances.
            Gnas = [ Gnas_mcpg, Gnas_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        
        
    	%{
%         % Implement a function to design the neurons for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Retrieve the number of cpg neurons.
%             num_cpg_neurons =  length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Design the driven multistate CPG neurons.
%             self = self.design_dmcpg_neurons( neuron_IDs_cell{ 1 }, neuron_manager );
%             self = self.design_dmcpg_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%             % Design the modulated split subtraction voltage based integration subnetwork neurons.
%             for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
%                 
%                 % Design the neurons of this modulated split subtraction voltage based integration subnetworks.
%                 self = self.design_mssvbi_neurons( neuron_IDs_cell{ k + 2 }, ki_mean, neuron_manager );
%                 
%             end
%             
%             % Design the split lead lag subnetwork neurons.
%             self = self.design_addition_neurons( neuron_IDs_cell{ end }( 1:2 ), neuron_manager );
%             self = self.design_slow_transmission_neurons( neuron_IDs_cell{ end }( 3:4 ), num_cpg_neurons, T, r, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for a driven multistate double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for the driven multistate split lead lag subnetwork.
%             self = self.design_dmcpg_sll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r, neuron_manager );
%             
%             % Design the neurons for the double centering subnetwork.
%             self = self.design_double_centering_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for the driven multiple cpg double centered lead lag subnetwork.
%             self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell{ 1 }, T, ki_mean, r, neuron_manager );
%             
%             % Design the neurons for the centered double subtraction subnetwork.
%             self = self.design_cds_neurons( neuron_IDs_cell{ 2 }, neuron_manager );
%             
%             % Design the neurons for the transmission subnetwork neurons.
%             self = self.design_transmission_neurons( neuron_IDs_cell{ 3 }, neuron_manager );
%             
%         end
%         
%         
%         % Implement a function to design the neurons for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_neurons( self, neuron_IDs_cell, T, ki_mean, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 5, r = self.r_oscillation_DEFAULT; end
%             if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 3, T = self.T_oscillation_DEFAULT; end
%             
%             % Design the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%         end
        %}
        
        
        %{
        % Implement a function to design the neurons for a modulation subnetwork.
        function [ Gnas, Cms, neurons, neuron_manager, self ] = design_modulation_neurons( self, neuron_IDs, neuron_manager, set_flag, undetected_option )
            
            % Set the default input argument.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 3, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the modulation subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager ] = neuron_manager.design_modulation_neurons( neuron_IDs, neuron_manager.neurons, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.neuron_manager = neuron_manager; end
            
        end
        %}
        
        
        %% Subnetwork Synapse Design Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function [ dEs21, gs21, synapse_ID, synapses, synapse_manager, self ] = design_transmission_synapse( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Parameters Cell.
            
            % Design the transmission subnetwork synapses.                        
            [ dEs21, gs21, synapse_ID, synapses, synapse_manager ] = synapse_manager.design_transmission_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
              
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
      	% ---------- Addition Subnetwork Functions ----------

        % Implement a function to design the synapses for an addition subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_addition_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Parameters Cell.
            
            % Design the addition subnetwork synapses.                        
            [ dEs, gs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_addition_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end

        end
                
        
    	% ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to design the synapses for a subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_subtraction_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                           	% [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                    	% [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                            	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                           % [-] Subtraction Gain.
            
            % Design the subtraction subnetwork synapses.                        
            [ dEs, gs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        %{
        % Implement a function to design the synapses for a double subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_double_subtraction_synapses( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, k = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Retrieve the neuron IDs associated with each subtraction subnetwork.
            neuron_IDs1 = neuron_IDs( 1:3 );
            neuron_IDs2 = [ neuron_IDs( 2 ), neuron_IDs( 1 ), neuron_IDs( 4 ) ];
            
            % Design the subtraction subnetwork synapses.
            [ dEs31, synapse_IDs1, ~, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs1, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            [ dEs32, synapse_IDs2, ~, synapse_manager ] = synapse_manager.design_subtraction_synapses( neuron_IDs2, encoding_scheme, synapse_manager.synapses, true, undetected_option );

            % Get the applied current associated with the final neuron.
            [ ~, Ias1 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            [ ~, Ias2 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 4 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );

            % Determine whether to throw a warning.
            if ~all( Ias1 == Ias1( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            if ~all( Ias2 == Ias2( 1 ) ), warning( 'The basic subtraction subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia1 = mean( Ias1 );
            Ia2 = mean( Ias2 );
            
            % Create an instance of the network.
            network = self;
            
            % Compute and set the maximum synaptic reversal potentials necessary to design this addition subnetwork.
            [ gs31, ~, synapse_manager, network ] = network.compute_subtraction_gs( neuron_IDs1, synapse_IDs1, Ia1, k, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            [ gs32, synapses, synapse_manager, network ] = network.compute_subtraction_gs( neuron_IDs2, synapse_IDs2, Ia2, k, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Store the synapse properties.
            synapse_IDs = [ synapse_IDs1, synapse_IDs2 ];
            gs = [ gs31, gs32 ];
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end   
        %}
        
        
     	% ---------- Inversion Subnetwork Functions ----------

        % Implement a function to design the synapse of an inversion subnetwork.
        function [ dEs21, gs21, synapse_ID, synapses, synapse_manager, self ] = design_inversion_synapse( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                    	% [class] Applied Current Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end            	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % { epsilon, k }
            
            % Design the inversion subnetwork synapse.            
            [ dEs21, gs21, synapse_ID, synapses, synapse_manager ] = synapse_manager.design_inversion_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end                    
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to design the synapse of a reduced inversion subnetwork.
        function [ dEs21, gs21, synapse_ID, synapses, synapse_manager, self ] = design_reduced_inversion_synapse( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                           	% [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                    	% [class] Applied Current Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end            	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % { epsilon, k }
            
            % Design the inversion subnetwork synapse.            
            [ dEs21, gs21, synapse_ID, synapses, synapse_manager ] = synapse_manager.design_reduced_inversion_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end  
        
                                        
       	% ---------- Division Subnetwork Functions ----------

        % Implement a function to design the synapses of a division subnetwork.
        function [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager, self ] = design_division_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                     	% [-] Parameter Cell.
            
            % Design the division subnetwork synapses.            
            [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_division_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
                                                
     	% ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to design the synapses of a reduced division subnetwork.
        function [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager, self ] = design_reduced_division_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                     	% [-] Parameter Cell.
            
            % Design the division subnetwork synapses.            
            [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_reduced_division_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
                                                        
     	% ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to design the synapses of a division subnetwork.
        function [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager, self ] = design_dai_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                     	% [-] Parameter Cell.
            
            % Design the division subnetwork synapses.                        
            [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_dai_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
                                                                
     	% ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to design the synapses of a reduced division after inversion subnetwork.
        function [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager, self ] = design_reduced_dai_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                     	% [-] Parameter Cell.
            
            % Design the division subnetwork synapses.                        
            [ dEs31, dEs32, gs31, gs32, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_reduced_dai_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end                       
        
        
     	% ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to design the synapses for a multiplication subnetwork.
        function [ dEs41, dEs32, dEs43, gs41, gs32, gs43, synapse_IDs, synapses, synapse_manager, self ] = design_multiplication_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                  	% [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                      	% [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                 	% [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                       	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                       % [-] Parameter Cell.
            
            % Design the multiplication subnetwork synapses.                        
            [ dEs41, dEs32, dEs43, gs41, gs32, gs43, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_multiplication_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
                                                                                
       	% ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to design the synapses for a reduced multiplication subnetwork.
        function [ dEs41, dEs32, dEs43, gs41, gs32, gs43, synapse_IDs, synapses, synapse_manager, self ] = design_reduced_multiplication_synapses( self, neuron_IDs, parameters, encoding_scheme, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                  	% [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                      	% [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                 	% [class] Synapse Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                       	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                       % [-] Parameter Cell.
            
            % Design the multiplication subnetwork synapses.                        
            [ dEs41, dEs32, dEs43, gs41, gs32, gs43, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_reduced_multiplication_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager.synapses, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------

        %{
        % Implement a function to design the synapses for a centering subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_centering_synapses( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Define the addition and subtraction neuron IDs.
            neuron_IDs_addition = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ];
            neuron_IDs_subtraction = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            
            % Create an instance of the network object.
            network = self;
            
            % Design the addition subnetwork synapses.            
            [ dEs_addition, gs_addition, synapse_IDs_addition, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                        
            % Design the subtraction subnetwork synapses.            
            [ dEs_subtraction, gs_subtraction, synapse_IDs_subtraction, synapses, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                        
            % Concatenate the synapse properties.
            synapse_IDs = [ synapse_IDs_addition, synapse_IDs_subtraction ];
            dEs = [ dEs_addition, dEs_subtraction ];
            gs = [ gs_addition, gs_subtraction ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a double centering subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_double_centering_synapses( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Define the addition and subtraction neuron IDs.
            neuron_IDs_addition1 = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ) ];
            neuron_IDs_addition2 = [ neuron_IDs( 2 ), neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            neuron_IDs_subtraction1 = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 6 ) ];
            neuron_IDs_subtraction2 = [ neuron_IDs( 5 ), neuron_IDs( 1 ), neuron_IDs( 7 ) ];

            % Create an instance of the network object.
            network = self;
            
            % Design the addition subnetwork neurons.
            [ dEs_addition1, gs_addition1, synapse_IDs_addition1, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition1, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_addition2, gs_addition2, synapse_IDs_addition2, ~, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs_addition2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Design the subtraction subnetwork neurons.
            [ dEs_subtraction1, gs_subtraction1, synapse_IDs_subtraction1, ~, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction1, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_subtraction2, gs_subtraction2, synapse_IDs_subtraction2, synapses, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs_subtraction2, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            synapse_IDs = [ synapse_IDs_addition1, synapse_IDs_addition2, synapse_IDs_subtraction1, synapse_IDs_subtraction2 ];
            dEs = [ dEs_addition1, dEs_addition2, dEs_subtraction1, dEs_subtraction2 ];
            gs = [ gs_addition1, gs_addition2, gs_subtraction1, gs_subtraction2 ];

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a centered double subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_cds_synapses( self, neuron_IDs_cell, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 5, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            if nargin < 4, k_subtraction2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_subtraction1 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Create an instance of the network.
            network = self;
            
            % Design the double subtraction subnetwork synapses.            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_cell{ 1 }, k_subtraction1, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the double centering subnetwork synpases.            
            [ dEs_dc, gs_dc, synapse_IDs_dc, ~, synapse_manager, network ] = network.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_addition, k_subtraction2, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Define the number of transmission synapses.
            num_transmission_synapses = 2;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }( 3 ), neuron_IDs_cell{ 1 }( 4 ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ), neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Preallocate arrays to store the transmission synapse properties.
            dEs_transmission = zeros( 1, num_transmission_synapses );
            gs_transmission = zeros( 1, num_transmission_synapses );
            synapse_IDs_transmission = zeros( 1, num_transmission_synapses );
            
            % Design each of the transmission synapses.
            for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
                
                % Design this transmission synapse.                
                [ dEs_transmission( k ), gs_transmission( k ), synapse_IDs_transmission( k ), synapses, synapse_manager, network ] = network.design_transmission_synapse( [ from_neuron_IDs( k ), to_neuron_IDs( k ) ], 0.5, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, applied_current_compensation_flag, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
                
            end
            
            % Concatenate the synapse properties.
            dEs = [ dEs_ds, dEs_dc, dEs_transmission ];
            gs = [ gs_ds, gs_dc, gs_transmission ];
            synapse_IDs = [ synapse_IDs_ds, synapse_IDs_dc, synapse_IDs_transmission ];
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        %}
        
        
        % ---------- Derivation Subnetwork Functions ----------

        % Implement a function to design the synapses for a derivation subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_derivation_synapses( self, neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, set_flag, filter_disabled_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, process_option = self.process_option; end
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, k = self.c_derivation_DEFAULT; end                                                           % [-] Derivation Subnetwork Gain.
            
            % Design the derivation subnetwork synapses.
            [ dEs, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_derivation_synapses( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias3 ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 3 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias3 == Ias3( 1 ) ), warning( 'The basic multiplication subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia3 = mean( Ias3 );
            
            % Compute the subtraction subnetwork gain.
            ksub = ( 1e6 )/k;
            
            % Compute and set the maximum synaptic conductances associated with this derivation subnetwork.            
            [ gs, synapse_manager, self ] = self.compute_derivation_gs( neuron_IDs, synapse_IDs, Ia3, ksub, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------

        % Implement a function to design the synapses for an integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_integration_synapses( self, neuron_IDs, ki_range, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            
            % Design the integration subnetwork synapses.            
            [ ~, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_integration_synapses( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Compute and set the integration subnetwork maximum synaptic conductances.
            [ gs, synapse_manager, network ] = self.compute_integration_gs( neuron_IDs, synapse_IDs, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.
            [ dEs, synapse_manager, network ] = network.compute_integration_dEs( neuron_IDs, synapse_IDs, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_vbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Design the derivation subnetwork synapses.
            [ synapse_manager, synapse_IDs ] = synapse_manager.design_vbi_synapses( neuron_IDs );
            
            % Get the synapse IDs that connect the two neurons.
            synapse_ID34 = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 3 ), neuron_IDs( 4 ) );
            synapse_ID43 = synapse_manager.from_to_neuron_ID2synapse_ID( neuron_IDs( 4 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_IDs, synapse_ID34, synapse_ID43 ];
            
            % Compute and set the integration subnetwork maximum synaptic conductances.            
            [ gs_integration, synapse_manager, network ] = self.compute_integration_gs( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ), ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compute and set the integration subnetwork synaptic reversal potentials.            
            [ dEs, synapse_manager, network ] = network.compute_integration_dEs( neuron_IDs( 3:4 ), synapse_IDs( 3:4 ), neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Compue and set the voltage based integration subnetwork maximum synaptic conductance.            
            [ gs_vbi, synapse_manager, network ] = network.compute_vbi_gs( neuron_IDs, synapse_IDs, T, n, ki_mean, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
            
            % Retrieve the synapses.
            synapses = synapse_manager.synapses;
            
            % Store the synaptic conductances in an array.
            gs = [ gs_integration, gs_vbi ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a split voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_svbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if anrgin < 12, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 11, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if anrgin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 7, k_sub = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Retrieve the neuron ID components.
            neuron_IDs_vbi = neuron_IDs( 1:4 );
            neuron_IDs_ds = neuron_IDs( 5:8 );
            neuron_IDs_transmission1 = [ neuron_IDs( 9 ), neuron_IDs( 6 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 3 ), neuron_IDs( 5 ) ];

            % Design the voltage based integration synapses.            
            [ dEs_vbi, gs_vbi, synapse_IDs_vbi, ~, synapse_manager, network ] = network.design_vbi_synapses( neuron_IDs_vbi, T, n, ki_mean, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Design the double subtraction synapses.            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_ds, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the transmission synapses. NOTE: Neuron IDs are in this order: { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1' }
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synpase properties.
            dEs = [ dEs_vbi, dEs_ds, dEs_transmission1, dEs_transmission2 ];
            gs = [ gs_vbi, gs_ds, gs_transmission1, gs_transmission2 ];
            synapse_IDs = [ synapse_IDs_vbi, synapse_IDs_ds, synapse_ID_transmission1, synapse_ID_transmission2 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a modulated split voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_msvbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 17, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 16, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if anrgin < 15, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if anrgin < 14, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 13, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 12, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 8, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 7, k_sub = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network class.
            network = self;
            
            % Retrieve the neuron IDs.
            neuron_IDs_modulation1 = [ neuron_IDs( 10 ), neuron_IDs( 11 ) ];
            neuron_IDs_modulation2 = [ neuron_IDs( 10 ), neuron_IDs( 12 ) ];
            neuron_IDs_transmission1 = [ neuron_IDs( 7 ), neuron_IDs( 11 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 8 ), neuron_IDs( 12 ) ];
            neuron_IDs_transmission3 = [ neuron_IDs( 1 ), neuron_IDs( 10 ) ];
            neuron_IDs_transmission4 = [ neuron_IDs( 2 ), neuron_IDs( 10 ) ];

            % Design the synapses for a split voltage based integration subnetwork.            
            [ dEs_svbi, gs_svbi, synapse_IDs_svbi, ~, synapse_manager, network ] = network.design_svbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_sub, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the modulation synapses.
            [ dEs_modulation1, gs_modulation1, synapse_ID_modulation1, ~, synapse_manager, network ] = network.design_modulation_synapses( neuron_IDs_modulation1, c_mod, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_modulation2, gs_modulation2, synapse_ID_modulation2, ~, synapse_manager, network ] = network.design_modulation_synapses( neuron_IDs_modulation2, c_mod, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Design the transmission synapses.
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission3, gs_transmission3, synapse_ID_transmission3, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission3, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission4, gs_transmission4, synapse_ID_transmission4, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission4, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            dEs = [ dEs_svbi, dEs_modulation1, dEs_modulation2, dEs_transmission1, dEs_transmission2, dEs_transmission3, dEs_transmission4 ];
            gs = [ gs_svbi, gs_modulation1, gs_modulation2, gs_transmission1, gs_transmission2, gs_transmission3, gs_transmission4 ];
            synapse_IDs = [ synapse_IDs_svbi, synapse_ID_modulation1, synapse_ID_modulation2, synapse_ID_transmission1, synapse_ID_transmission2, synapse_ID_transmission3, synapse_ID_transmission4 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design the synapses for a modulated split difference voltage based integration subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_mssvbi_synapses( self, neuron_IDs, T, n, ki_mean, ki_range, k_sub1, k_sub2, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 18, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 17, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 16, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 15, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 14, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 13, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 9, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 8, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 7, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network class.
            network = self;
            
            % Retrieve the neuron ID components.
            neuron_IDs_ds = neuron_IDs( 1:4 );
            neuron_IDs_msvbi = neuron_IDs( 5:end );
            neuron_IDs_transmission1 = [ neuron_IDs( 3 ), neuron_IDs( 5 ) ];
            neuron_IDs_transmission2 = [ neuron_IDs( 4 ), neuron_IDs( 6 ) ];
            
            % Design the double subtraction synapses.
            self = self.design_double_subtraction_synapses( neuron_IDs( 1:4 ), k_sub2, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
            
            [ dEs_ds, gs_ds, synapse_IDs_ds, ~, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs_ds, k_sub2, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the modulated split voltage based integration synapses.            
            [ dEs_msvbi, gs_msvbi, synapse_IDs_msvbi, ~, synapse_manager, network ] = network.design_msvbi_synapses( neuron_IDs_msvbi, T, n, ki_mean, ki_range, k_sub1, c_mod, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Design the transmission synapses.
            [ dEs_transmission1, gs_transmission1, synapse_ID_transmission1, ~, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission1, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            [ dEs_transmission2, gs_transmission2, synapse_ID_transmission2, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs_transmission2, 1.0, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, false, filter_disabled_flag, true, process_option, undetected_option, network_utilities );

            % Concatenate the synapse properties.
            dEs = [ dEs_ds, dEs_msvbi, dEs_transmission1, dEs_transmission2 ];
            gs = [ gs_ds, gs_msvbi, gs_transmission1, gs_transmission2 ];
            synapse_IDs = [ synapse_IDs_ds, synapse_IDs_msvbi, synapse_ID_transmission1, synapse_ID_transmission2 ];
            
            % Determine whether to update the neuron object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------

        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function [ gs, synapses, synapse_manager, self ] = design_mcpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 9, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the multistate cpg subnetwork synapses.
            [ ~, synapse_manager ] = synapse_manager.design_mcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, synapse_manager.synapses, true, undetected_option, synapse_manager.array_utilities );
            
            % Compute and set the maximum synaptic conductances required to achieve these delta values.            
            [ gs, synapses, synapse_manager, self ] = self.compute_cpg_gs( neuron_IDs, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
                        
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, synapse_manager, self ] = design_dmcpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Design the synapses of the multistate cpg subnetwork.            
            [ gs_mcpg, synapses, synapse_manager, ~ ] = self.design_mcpg_synapses( neuron_IDs( 1:( end - 1 ) ), delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Design the driven multistate cpg subnetwork synapses.            
            [ dEs, gs_d, synapse_IDs, synapses, synapse_manager ] = synapse_manager.design_dmcpg_synapses( neuron_IDs, delta_oscillatory, Id_max, synapses, true, undetected_option );
            
            % Concatenate the neuron properties.
            gs = [ gs_mcpg, gs_d ];
            
            % Determine whether to update the network object.
            if set_flag, self.synapse_manager = synapse_manager; end
            
        end
        
        %{
%         % Implement a function to design the synapses for a driven multistate cpg split lead lag subnetwork.
%         function self = design_dmcpg_sll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities )
%             
%             % Set the default input arguments.
%             if nargin < 1, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
%             if nargin < 14, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 13, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
%             if nargin < 12, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 11, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the synapses of the driven multistate cpg subnetworks.
%             self = self.design_dmcpg_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities );
%             self = self.design_dmcpg_synapses( neuron_IDs_cell{ 2 }, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities );
%             
%             % Compute the number of cpg neurons.
%             num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Compute the number of transmission pathways to design.
%             num_transmission_synapses = 4*num_cpg_neurons + 2;
%             
%             % Preallocate an array to store the from and to neuron IDs.
%             [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_transmission_synapses ) );
%             
%             % Design the synapses of the modulated split subtraction voltage based integration subnetworks.
%             for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
%                 
%                 % Design the synapses of this modulated split subtraction voltage based integration subnetwork.
%                 self = self.design_mssvbi_synapses( neuron_IDs_cell{ k + 2 }, T, num_cpg_neurons, ki_mean, ki_range, k_sub1, k_sub2, c_mod );
%                 
%                 % Compute the index variable.
%                 index = 4*(k - 1) + 1;
%                 
%                 % Store these pairs of from and to neuron IDs.
%                 from_neuron_IDs( index ) = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_IDs( index ) = neuron_IDs_cell{ end }( 1 );
%                 from_neuron_IDs( index + 1 ) = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_IDs( index + 1 ) = neuron_IDs_cell{ end }( 2 );
%                 from_neuron_IDs( index + 2 ) = neuron_IDs_cell{ 1 }( k ); to_neuron_IDs( index + 2 ) = neuron_IDs_cell{ k + 2 }( 1 );
%                 from_neuron_IDs( index + 3 ) = neuron_IDs_cell{ 2 }( k ); to_neuron_IDs( index + 3 ) = neuron_IDs_cell{ k + 2 }( 2 );
%                 
%             end
%             
%             % Define the final pair of from and to neuron IDs.
%             from_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 1 ); to_neuron_IDs( end - 1 ) = neuron_IDs_cell{ end }( 3 );
%             from_neuron_IDs( end ) = neuron_IDs_cell{ end }( 2 ); to_neuron_IDs( end ) = neuron_IDs_cell{ end }( 4 );
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the synapses for a driven multistate cpg double centered lead lag subnetwork.
%         function self = design_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod )
%             
%             % Set the default input arguments.
%             if nargin < 13, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 12, k_sub3 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the driven multistate cpg split lead lag synapses.
%             self = self.design_dmcpg_sll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%             
%             % Design the double centering subnetwork synapses.
%             self = self.design_double_centering_synapses( neuron_IDs_cell{ 2 }, k_add, k_sub3, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ end }( end - 1 ) neuron_IDs_cell{ 1 }{ end }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 0.5, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function self = design_ol_dmcpg_dclle_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod )
%             
%             % Set the default input arguments.
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the driven multistate cpg double centered lead lag subnetwork synapses.
%             self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell{ 1 }, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add1, c_mod );
%             
%             % Design the centered double subtraction subnetwork synapses.
%             self = self.design_cds_synapses( neuron_IDs_cell{ 2 }, k_sub4, k_sub5, k_add2 );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 2 }( end - 1 ) neuron_IDs_cell{ 3 } ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 1 }( 1 ) neuron_IDs_cell{ 2 }{ 1 }( 2 ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ) to_neuron_IDs( k ) ], 1, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%             
%         end
%         
%         
%         % Implement a function to design the synapses for a closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
%         function self = design_clpc_dmcpg_dcll_synapses( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain )
%             
%             % Set the default input arguments.
%             if nargin < 17, kp_gain = self.kp_gain_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % Design the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
%             
%             % Define the number of transmission synapses.
%             num_transmission_synapses = 2;
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 2 }( end - 1 ), neuron_IDs_cell{ 2 }{ 2 }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 1 }{ 2 }( end ), neuron_IDs_cell{ 1 }{ 1 }{ 1 }( end ) ];
%             
%             % Design each of the transmission synapses.
%             for k = 1:num_transmission_synapses                     % Iterate through each of the transmission pathways...
%                 
%                 % Design this transmission synapse.
%                 self = self.design_transmission_synapse( [ from_neuron_IDs( k ), to_neuron_IDs( k ) ], kp_gain, false, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%                 
%             end
%             
%         end
        %}
        
        
        %{
        
        % Implement a function to design the synapses for a modulation subnetwork.
        function [ dEs12, gs12, synapse_ID, synapses, synapse_manager, self ] = design_modulation_synapses( self, neuron_IDs, c, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilites; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, c = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            
            % Design the modulation synapses.            
            [ dEs12, synapse_ID, ~, synapse_manager ] = synapse_manager.design_modulation_synapse( neuron_IDs, synapse_manager.synapses, true, undetected_option );
            
            % Get the applied current associated with the final neuron.
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs( 2 ), [  ], [  ], applied_currents, filter_disabled_flag, process_option, undetected_option );
            
            % Determine whether to throw a warning.
            if ~all( Ias == Ias( 1 ) ), warning( 'The basic addition subnetwork will not operate ideally with a non-constant applied current.  Compensating for average current.' ), end
            
            % Set the applied current to be the average current.
            Ia = mean( Ias );
            
            % Compute and set the maximum synaptic conductance for a transmission subnetwork.
            [ gs12, synapses, synapse_manager, self ] = self.compute_modulation_gs( neuron_IDs, synapse_ID, Ia, c, neuron_manager, synapse_manager, set_flag, undetected_option, network_utilities );
                        
        end
        
        %}
        
        
        %% Subnetwork Design Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to design a transmission subnetwork using existing neurons.
        function [ Gnas, R2, dEs21, gs21, neurons, synapses, neuron_manager, synapse_manager, self ] = design_transmission_subnetwork( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                   	% [str] Undetected Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % [-] Parameters Cell.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the transmission subnetwork neurons.                        
            [ Gnas, R2, neurons, neuron_manager, network ] = network.design_transmission_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the tranmission subnetwork synapses.                        
            [ dEs21, gs21, ~, synapses, synapse_manager, network ] = network.design_transmission_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to design an addition subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Rn, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_addition_subnetwork( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                           	% [str] Undetected Option.
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                               	% [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                         	% [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                          	% [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                               	% [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                               % [-] Parameters Cell.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the addition subnetwork neurons.
            [ Gnas, Rn, neurons, neuron_manager, network ] = network.design_addition_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the addition subnetwork synapses.
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_addition_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to design a subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Rn, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_subtraction_subnetwork( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the subtraction subnetwork neurons.                        
            [ Gnas, Rn, neurons, neuron_manager, network ] = network.design_subtraction_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the subtraction subnetwork synapses.                        
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_subtraction_synapses( neuron_IDs, parameters, encoding_scheme, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        %{
        % Implement a function to design a double subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_double_subtraction_subnetwork( self, neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, k = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the double subtraction subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_double_subtraction_neurons( neuron_IDs, neuron_manager, encoding_scheme, true, undetected_option );
            
            % Design the double subtraction subnetwork synapses.           
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_double_subtraction_synapses( neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        %}
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to design an inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, R2, dEs21, gs21, Ias2, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_inversion_subnetwork( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { epsilon, k }
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the inversion subnetwork neurons.                        
            [ Gnas, R2, neurons, neuron_manager, network ] = network.design_inversion_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the inversion subnetwork applied current.                        
            [ Ias2, applied_currents, applied_current_manager, network ] = network.design_inversion_applied_current( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the inversion subnetwork synapse.                        
            [ dEs21, gs21, ~, synapses, synapse_manager, network ] = network.design_inversion_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------
        
        % Implement a function to design an inversion subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, R2, dEs21, gs21, Ias2, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_reduced_inversion_subnetwork( self, neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                                                       % { epsilon, k }
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the inversion subnetwork neurons.                        
            [ Gnas, R2, neurons, neuron_manager, network ] = network.design_reduced_inversion_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the inversion subnetwork applied current.                        
            [ Ias2, applied_currents, applied_current_manager, network ] = network.design_reduced_inversion_applied_current( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the inversion subnetwork synapse.                        
            [ dEs21, gs21, ~, synapses, synapse_manager, network ] = network.design_reduced_inversion_synapse( neuron_IDs, parameters, encoding_scheme, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to design a division subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_division_subnetwork( self, neuron_IDs, k, c, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 5, parameters = {  }; end                               
            if nargin < 4, c = [  ]; end
            if nargin < 3, k = self.c_division_DEFAULT; end                                                             % [-] Division Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the division subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, network ] = network.design_division_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the division subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_division_synapses( neuron_IDs, k, c, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, true, filter_disabled_flag, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to design a multiplication subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_multiplication_subnetwork( self, neuron_IDs, k, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, parameters = {  }; end
            if nargin < 3, k = self.c_multiplication_DEFAULT; end                                                       % [-] Multiplication Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the multiplication subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, network ] = network.design_multiplication_neurons( neuron_IDs, parameters, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the multiplication subnetwork applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_multiplication_applied_current( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the multiplication subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_multiplication_synapses( neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to design a derivation subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Gms, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_derivation_subnetwork( self, neuron_IDs, k, w, safety_factor, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k = self.c_derivation_DEFAULT; end                                                           % [-] Derivation Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the derivation subnetwork neurons.            
            [ Gnas, Gms, Cms, neurons, neuron_manager, network ] = network.design_derivation_neurons( neuron_IDs, k, w, safety_factor, neuron_manager, true, undetected_option );
            
            % Design the derivation subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_derivation_synapses( neuron_IDs, k, neuron_manager, synapse_manager, applied_current_manager, true, filter_disabled_flag, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to design an integration subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_integration_subnetwork( self, neuron_IDs, ki_mean, ki_range, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_integration_neurons( neuron_IDs, ki_mean, neuron_manager, true, undetected_option );
            
            % Design the integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_integration_applied_currents( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the integration synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_integration_synapses( neuron_IDs, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_vbi_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, set_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the voltage based integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_vbi_neurons( neuron_IDs, ki_mean, neuron_manager, true, undetected_option );
            
            % Design the voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_vbi_applied_currents( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the voltage based integration synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_vbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_svbi_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 12, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 11, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 7, k_subtraction = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the split voltage based integration subnetwork neurons.           
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_svbi_neurons( neuron_IDs, ki_mean, neuron_manager, true, undetected_option );
            
            % Design the split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_svbi_applied_currents( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the split voltage based integration synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_svbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a modulated split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_msvbi_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 17, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 16, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 15, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 14, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 13, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 12, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 8, c_modulation = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 7, k_subtraction = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the modulated split voltage based integration subnetwork neurons.            
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_msvbi_neurons( neuron_IDs, ki_mean, neuron_manager, true, undetected_option );
            
            % Design the modulated split voltage based integration applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_msvbi_applied_currents( neuron_IDs, encoding_scheme, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the modulated split voltage based integration synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_msvbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a modulated difference split voltage based integration subnetwork ( using the specified neurons & their existing synapses ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_mssvbi_subnetwork( self, neuron_IDs, T, n, ki_mean, ki_range, k_subtraction1, k_subtraction2, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 18, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 17, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 16, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 15, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 14, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 13, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 9, c_modulation = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 8, k_subtraction2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 7, k_subtraction1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 5, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the modulated split voltage based integration subnetwork neurons.
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_mssvbi_neurons( neuron_IDs, ki_mean, encoding_scheme, neuron_manager, true, undetected_option );
            
            % Design the modulated split voltage based integration applied currents.
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_mssvbi_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, encoding_scheme, true, undetected_option );
            
            % Design the modulated split voltage based integration synapses.
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_mssvbi_synapses( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction1, k_subtraction2, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------
        
        % Implement a function to design a centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_centering_subnetwork( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the centering subnetwork neurons.            
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, network ] = network.design_centering_neurons( neuron_IDs, neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Design the centering subnetwork applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the centering subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, self ] = design_centering_synapses( neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a double centering subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_double_centering_subnetwork( self, neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the double centering subnetwork neurons.
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, network ] = network.design_double_centering_neurons( neuron_IDs, neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Design the double centering subnetwork applied currents.
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_double_centering_applied_currents( neuron_IDs, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the double centering subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_double_centering_synapses( neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
             % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a centered double subtraction subnetwork ( using the specified neurons, synapses, and applied currents ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_cds_subnetwork( self, neuron_IDs_cell, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 5, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            if nargin < 4, k_subtraction2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, k_subtraction1 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the centered double subtraction neurons.
            [ Gnas, Gms, Cms, Rs, neurons, neuron_manager, network ] = network.design_cds_neurons( neuron_IDs_cell, neuron_manager, parameters, encoding_scheme, true, undetected_option );
            
            % Design the centered double subtraction applied currents.            
            [ Ias, applied_currents, applied_current_manager, network ] = network.design_cds_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager, true, undetected_option );
            
            % Design the centered double subtraction synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_cds_synapses( neuron_IDs_cell, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to design a multistate CPG oscillator subnetwork using existing neurons.
        function [ Gnas, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_mcpg_subnetwork( self, neuron_IDs, dt, tf, delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 5, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Create an instance of the network class.
            network = self;
            
            % Design the multistate cpg subnetwork neurons.
            [ Gnas, neurons, neuron_manager, network ] = network.design_mcpg_neurons( neuron_IDs, neuron_manager, true, undetected_option );
            
            % Design the multistate cpg subnetwork applied current.            
            [ ts, Ias, applied_currents, applied_current_manager, network ] = network.design_mcpg_applied_currents( neuron_IDs, dt, tf, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option );
            
            % Design the multistate cpg subnetwork synapses.            
            [ gs, synapses, synapse_manager, network ] = network.design_mcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to design a driven multistate CPG oscillator subnetwork using existing neurons.
        function [ Gnas, dEs, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = design_dmcpg_subnetwork( self, neuron_IDs, dt, tf, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 15, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if anrgin < 14, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 13, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 11, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, Id_max = self.Id_max_DEFAULT; end
            if nargin < 6, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 5, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 4, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 3, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % ENSURE THAT THE SPECIFIED NEURON IDS ARE FULLY CONNECTED BEFORE CONTINUING.  THROW AN ERROR IF NOT.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the driven multistate cpg subnetwork neurons.
            [ Gnas, neurons, neuron_manager, network ] = network.design_dmcpg_neurons( neuron_IDs, neuron_manager, true, undetected_option );
            
            % Design the driven multistate cpg subnetwork applied current.            
            [ ts, Ias, applied_currents, applied_current_manager, network ] = network.design_dmcpg_applied_currents( neuron_IDs, dt, tf, neuron_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option );
            
            % Design the driven multistate cpg subnetwork synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_dmcpg_synapses( neuron_IDs, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        %{
%         % Implement a function to design a driven multistate CPG split lead lag subnetwork using existing neurons.
%         function self = design_dmcpg_sll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r, dt, tf, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 16, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 15, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 14, tf = self.tf; end                                                                            % [s] Simulation Duration.
%             if nargin < 13, dt = self.dt; end                                                                            % [s] Simulation Time Step.
%             if nargin < 12, r = self.r_oscillation_DEFAULT; end
%             if nargin < 11, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
%             
%             % Design the driven multistate CPG split lead lag subnetwork neurons.
%             self = self.design_dmcpg_sll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%             % Design the driven multistate CPG split lead lag subnetwork applied currents.
%             self = self.design_dmcpg_sll_applied_currents( neuron_IDs_cell, dt, tf, neuron_manager, applied_current_manager );
%             
%             % Design the driven multistate CPG split lead lag subnetwork synapses.
%             self = self.design_dmcpg_sll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, neuron_manager, synapse_manager, applied_current_manager, network_utilities );
%             
%         end
%         
%         
%         % Implement a function to design a driven multistate CPG double centered lead lag subnetwork using existing neurons.
%         function self = design_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 15, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 14, r = self.r_oscillation_DEFAULT; end
%             if nargin < 13, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 12, k_add = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
%             
%             % Design the driven multistate CPG double centered lead lag subnetwork neurons.
%             self = self.design_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%             % Design the driven multistate CPG double centered lead lag subnetwork applied currents.
%             self = self.design_dmcpg_dcll_applied_currents( neuron_IDs_cell );
%             
%             % Design the driven multistate CPG double centered lead lag subnetwork synapses.
%             self = self.design_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod );
%             
%         end
%         
%         
%         % Implement a function to design an open loop driven multistate CPG double centered lead lag error subnetwork using existing neurons.
%         function self = design_ol_dmcpg_dclle_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, neuron_manager )
%             
%             % Set the default input arguments.
%             if nargin < 18, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 17, r = self.r_oscillation_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
%             
%             % Design the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
%             self = self.design_ol_dmcpg_dclle_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%             % Design the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
%             self = self.design_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
%             
%             % Design the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
%             self = self.design_ol_dmcpg_dclle_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod );
%             
%         end
%         
%         
%         % Implement a function to design a closed loop P controlled driven multistate CPG double centered lead lag subnetwork using existing neurons.
%         function self = design_clpc_dmcpg_dcll_subnetwork( self, neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain, neuron_manager, applied_current_manager )
%             
%             % Set the default input arguments.
%             if nargin < 20, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
%             if nargin < 19, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
%             if nargin < 18, kp_gain = self.kp_gain_DEFAULT; end
%             if nargin < 17, r = self.r_oscillation_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             
%             % ENSURE THAT THE SPECIFIED NEURON IDS ARE CONNECTED CORRECTLY BEFORE CONTINUING.  THROW AN ERROR IF NOT.
%             
%             % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork neurons.
%             self = self.design_clpc_dmcpg_dcll_neurons( neuron_IDs_cell, T, ki_mean, r, neuron_manager );
%             
%             % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork applied currents.
%             self = self.design_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell, neuron_manager, applied_current_manager );
%             
%             % Design the closed loop P controlled driven multistate CPG double centered lead lag subnetwork synapses.
%             self = self.design_clpc_dmcpg_dcll_synapses( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, kp_gain );
%             
%         end
        %}
        
        
        %{
        % Implement a function to design a modulation subnetwork using existing neurons.
        function [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = design_modulation_subnetwork( self, neuron_IDs, c, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, c = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            
            % ENSURE THAT THE GIVEN NEURONS DO IN FACT HAVE THE NECESSARY SYNAPTIC CONNECTIONS BEFORE PROCEEDING.  OTHERWISE THROW AN ERROR.
            
            % Create an instance of the network object.
            network = self;
            
            % Design the modulation neurons.            
            [ Gnas, Cms, neurons, neuron_manager, network ] = network.design_modulation_neurons( neuron_IDs, neuron_manager, true, undetected_option );
            
            % Design the modulation synapses.            
            [ dEs, gs, ~, synapses, synapse_manager, network ] = network.design_modulation_synapses( neuron_IDs, c, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        %}
         
        
        %% Network Component Pack & Unpack Functions.
        
        % ---------- Neuron Functions ----------
        
        % Implement a function to pack the default neuron creation input parameters.
        function parameters = pack_neuron_input_parameters( self, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags )
            
            % Set the default input arguments.
            if nargin < 25, neuron_enabled_flags = self.neuron_enabled_flags_DEFAULT; end
            if nargin < 24, I_totals = self.I_totals_DEFAULT; end
            if nargin < 23, I_apps = self.I_apps_DEFAULT; end
            if nargin < 22, I_tonics = self.I_tonics_DEFAULT; end
            if nargin < 21, I_nas = self.I_nas_DEFAULT; end
            if nargin < 20, I_syns = self.I_syns_DEFAULT; end
            if nargin < 19, I_leaks = self.I_leaks_DEFAULT; end
            if nargin < 18, Gnas = self.Gnas_DEFAULT; end
            if nargin < 17, tauh_maxs = self.tauh_maxs_DEFAULT; end
            if nargin < 16, dEnas = self.dEnas_DEFAULT; end
            if nargin < 15, dEhs = self.dEhs_DEFAULT; end
            if nargin < 14, Shs = self.Shs_DEFAULT; end
            if nargin < 13, Ahs = self.Ahs_DEFAULT; end
            if nargin < 12, dEms = self.dEms_DEFAULT; end
            if nargin < 11, Sms = self.Sms_DEFAULT; end
            if nargin < 10, Ams = self.Ams_DEFAULT; end
            if nargin < 9, Rs = self.Rs_DEFAULT; end
            if nargin < 8, Ers = self.Ers_DEFAULT; end
            if nargin < 7, Gms = self.Gms_DEFAULT; end
            if nargin < 6, Cms = self.Cms_DEFAULT; end
            if nargin < 5, hs = self.hs_DEFAULT; end
            if nargin < 4, Us = self.Us_DEFAULT; end
            if nargin < 3, neuron_names = self.neuron_names_DEFAULT; end
            if nargin < 2, neuron_IDs = self.neuron_IDs_DEFAULT; end
            
            % Pack the neuron input parameters.
            parameters{ 1 } = neuron_IDs;
            parameters{ 2 } = neuron_names;
            parameters{ 3 } = Us;
            parameters{ 4 } = hs;
            parameters{ 5 } = Cms;
            parameters{ 6 } = Gms;
            parameters{ 7 } = Ers;
            parameters{ 8 } = Rs;
            parameters{ 9 } = Ams;
            parameters{ 10 } = Sms;
            parameters{ 11 } = dEms;
            parameters{ 12 } = Ahs;
            parameters{ 13 } = Shs;
            parameters{ 14 } = dEhs;
            parameters{ 15 } = dEnas;
            parameters{ 16 } = tauh_maxs;
            parameters{ 17 } = Gnas;
            parameters{ 18 } = I_leaks;
            parameters{ 19 } = I_syns;
            parameters{ 20 } = I_nas;
            parameters{ 21 } = I_tonics;
            parameters{ 22 } = I_apps;
            parameters{ 23 } = I_totals;
            parameters{ 24 } = neuron_enabled_flags;
            
        end
        
        
        % Implement a function to unpack neuron creation inputs.
        function [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = unpack_neuron_input_parameters( self, parameters )
                
            % Set the default input arguments.
            if nargin < 2, parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack the neuron creation parameters.
            neuron_IDs = parameters{ 1 };
            neuron_names = parameters{ 2 };
            Us = parameters{ 3 };
            hs = parameters{ 4 };
            Cms = parameters{ 5 };
            Gms = parameters{ 6 };
            Ers = parameters{ 7 };
            Rs = parameters{ 8 };
            Ams = parameters{ 9 };
            Sms = parameters{ 10 };
            dEms = parameters{ 11 };
            Ahs = parameters{ 12 };
            Shs = parameters{ 13 };
            dEhs = parameters{ 14 };
            dEnas = parameters{ 15 };
            tauh_maxs = parameters{ 16 };
            Gnas = parameters{ 17 };
            I_leaks = parameters{ 18 };
            I_syns = parameters{ 19 };
            I_nas = parameters{ 20 };
            I_tonics = parameters{ 21 };
            I_apps = parameters{ 22 };
            I_totals = parameters{ 23 };
            neuron_enabled_flags = parameters{ 24 };
            
        end

        
        % Implement a function to pack the neuron creation outputs.
        function parameters = pack_neuron_output_parameters( self, neuron_IDs_new, neurons_new, neurons, neuron_manager )
        
            % Set the default input arguments.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, neurons = neuron_manager.neurons; end
            if nargin < 3, neurons_new = neurons; end
            if nargin < 2, neuron_IDs_new = neuron_manager.get_all_neuron_IDs( neurons ); end
            
            % Create a cell to store the parameters.
            parameters = cell( 1, 4 );
            
            % Pack the neuron parameters.
            parameters{ 1 } = neuron_IDs_new;
            parameters{ 2 } = neurons_new;
            parameters{ 3 } = neurons;
            parameters{ 4 } = neuron_manager;
            
        end
        
        
        % Implement a function to unpack the neuron creation outputs.
        function [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = unpack_neuron_output_parameters( self, parameters )
        
           % Set the default input arguments.
           if nargin < 2, parameters = self.pack_neuron_output_parameters(  ); end
            
           % Unpack the neuron creation outputs.
           neuron_IDs_new = parameters{ 1 };
           neurons_new = parameters{ 2 };
           neurons = parameters{ 3 };
           neuron_manager = parameters{ 4 };
            
        end
        

        % ---------- Synapse Functions ----------
        
        % Implement a function to pack the default synapse creation input parameters.
        function parameters = pack_synapse_input_parameters( self, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags )
            
            % Set the default input arguments.
            if nargin < 9, synapse_enabled_flags = self.synapse_enabled_flags_DEFAULT; end
            if nargin < 8, deltas = self.deltas_DEFAULT; end
            if nargin < 7, to_neuron_IDs = self.to_neuron_IDs_DEFAULT; end
            if nargin < 6, from_neuron_IDs = self.from_neuron_IDs_DEFAULT; end
            if nargin < 5, gs = self.gs_DEFAULT; end
            if nargin < 4, dEs = self.dEs_DEFAULT; end
            if nargin < 3, synapse_names = self.synapse_names_DEFAULT; end
            if nargin < 2, synapse_IDs = self.synapse_IDs_DEFAULT; end
            
            % Pack the synapse input parameters.
            parameters{ 1 } = synapse_IDs;
            parameters{ 2 } = synapse_names;
            parameters{ 3 } = dEs;
            parameters{ 4 } = gs;
            parameters{ 5 } = from_neuron_IDs;
            parameters{ 6 } = to_neuron_IDs;
            parameters{ 7 } = deltas;
            parameters{ 8 } = synapse_enabled_flags;

        end
        
        
        % Implement a function to unpack synapse creation inputs.
        function [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = unpack_synapse_input_parameters( self, parameters )
        
            % Set the default input arguments.
            if nargin < 2, parameters = self.pack_synapse_input_parameters(  ); end
            
            % Unpack the synapse creation parameters.
            synapse_IDs = parameters{ 1 };
            synapse_names = parameters{ 2 };
            dEs = parameters{ 3 };
            gs = parameters{ 4 };
            from_neuron_IDs = parameters{ 5 };
            to_neuron_IDs = parameters{ 6 };
            deltas = parameters{ 7 };
            synapse_enabled_flags = parameters{ 8 };
            
        end
            
        
        % Implement a function pack the synapse creation outputs.
        function parameters = pack_synapse_output_parameters( self, synapse_IDs_new, synapses_new, synapses, synapse_manager )
        
            % Set the default input arguments.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, synapses = synapse_manager.synapses; end
            if nargin < 3, synapses_new = synapses; end
            if nargin < 2, synapse_IDs_new = synapse_manager.get_all_synapse_IDs( synapses ); end
            
            % Create a cell to store the parameters.
            parameters = cell( 1, 4 );
            
            % Pack the synapse properties.
            parameters{ 1 } = synapse_IDs_new;
            parameters{ 2 } = synapses_new;
            parameters{ 3 } = synapses;
            parameters{ 4 } = synapse_manager;
            
        end

        
        % Implement a function to unpack the synapse creation outputs.
        function [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = unpack_synapse_output_parameters( self, parameters )
        
           % Set the default input arguments.
           if nargin < 2, parameters = self.pack_synapse_output_parameters(  ); end
            
           % Unpack the neuron creation outputs.
           synapse_IDs_new = parameters{ 1 };
           synapses_new = parameters{ 2 };
           synapses = parameters{ 3 };
           synapse_manager = parameters{ 4 };
            
        end
        
        
        % ---------- Applied Current Functions ----------
        
        % Implement a function to pack the default applied current creation input parameters.
        function parameters = pack_applied_current_input_parameters( self, applied_current_IDs, applied_current_names, to_neuron_IDs, ts, Ias, applied_current_enabled_flags )

            % Set the default input arguments.
            if nargin < 6, applied_current_enabled_flags = self.applied_current_enabled_flags_DEFAULT; end
            if nargin < 5, Ias = self.Ias_DEFAULT; end
            if nargin < 4, ts = self.ts_DEFAULT; end
            if nargin < 3, applied_current_names = self.applied_current_names_DEFAULT; end
            if nargin < 2, applied_current_IDs = self.applied_current_IDs_DEFAULT; end
            
            % Pack the applied current input parameters.
            parameters{ 1 } = applied_current_IDs;
            parameters{ 2 } = applied_current_names;
            parameters{ 3 } = to_neuron_IDs;
            parameters{ 4 } = ts;
            parameters{ 5 } = Ias;
            parameters{ 6 } = applied_current_enabled_flags;
        
        end
            
            
        % Implement a function to unpack applied current creation inputs.
        function [ applied_current_IDs, applied_current_names, to_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = unpack_applied_current_input_parameters( self, parameters )
           
            % Set the default input arguments.
            if nargin < 2, parameters = self.pack_applied_current_input_parameters(  ); end
            
            % Unpack the applied current creation parameters.
            applied_current_IDs = parameters{ 1 };
            applied_current_names = parameters{ 2 };
            to_neuron_IDs = parameters{ 3 };
            ts = parameters{ 4 };
            Ias = parameters{ 5 };
            applied_current_enabled_flags = parameters{ 6 };
            
        end
        
        
        % Implement a function to pack applied current creation outputs.
        function parameters = pack_applied_current_output_parameters( self, applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager )
        
            % Set the default input arguments.
            if nargin < 5, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 4, applied_currents = applied_current_manager.applied_currents; end
            if nargin < 3, applied_currents_new = applied_currents; end
            if nargin < 2, applied_current_IDs_new = applied_current_manager.get_all_applied_current_IDs( applied_currents ); end
            
            % Create a cell to store the parameters.
            parameters = cell( 1, 4 );
            
            % Pack the applied current properties.
            parameters{ 1 } = applied_current_IDs_new;
            parameters{ 2 } = applied_currents_new;
            parameters{ 3 } = applied_currents;
            parameters{ 4 } = applied_current_manager;
            
        end
        
        
        % Implement a function to unpack the applied current creation outputs.
        function [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = unpack_applied_current_output_parameters( self, parameters )
        
           % Set the default input arguments.
           if nargin < 2, parameters = self.pack_applied_current_output_parameters(  ); end
            
           % Unpack the neuron creation outputs.
           applied_current_IDs_new = parameters{ 1 };
           applied_currents_new = parameters{ 2 };
           applied_currents = parameters{ 3 };
           applied_current_manager = parameters{ 4 };
            
        end
        
        
        %% Network Design Pack & Unpack Parameters.
        
        % ---------- Transmission Packing & Unpacking Functions ----------
        
        % Implement a function to pack the absolute transmission design parameters.
        function transmission_parameters = pack_absolute_transmission_parameters( self, c, R1, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 7, Cm2 = self.Cm_DEFAULT; end
            if nargin < 6, Cm1 = self.Cm_DEFAULT; end
            if nargin < 5, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, Gm1 = self.Gm_DEFAULT; end
            if nargin < 3, R1 = self.R_DEFAULT; end
            if nargin < 2, c = self.c_transmission_DEFAULT; end
            
            % Create a cell to store the transmission parameters.
            transmission_parameters = cell( 1, 6 );
            
            % Pack the transmission parameters.
            transmission_parameters{ 1 } = c;
            transmission_parameters{ 2 } = R1;
            transmission_parameters{ 3 } = Gm1;
            transmission_parameters{ 4 } = Gm2;
            transmission_parameters{ 5 } = Cm1;
            transmission_parameters{ 6 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the absolute transmission design parameters.
        function [ c, R1, Gm1, Gm2, Cm1, Cm2 ] = unpack_absolute_transmission_parameters( transmission_parameters )
            
            % Set the default input arguments.
            if nargin < 2, transmission_parameters = self.pack_absolute_transmission_parameters(  ); end
            
            % Unpack the transmission parameters.
            c = transmission_parameters{ 1 };
            R1 = transmission_parameters{ 2 };
            Gm1 = transmission_parameters{ 3 };
            Gm2 = transmission_parameters{ 4 };
            Cm1 = transmission_parameters{ 5 };
            Cm2 = transmission_parameters{ 6 };
            
        end
        
        
        % Implement a function to pack the relative transmission design parameters.
        function transmission_parameters = pack_relative_transmission_parameters( self, R1, R2, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 7, Cm2 = self.Cm_DEFAULT; end
            if nargin < 6, Cm1 = self.Cm_DEFAULT; end
            if nargin < 5, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, Gm1 = self.Gm_DEFAULT; end
            if nargin < 3, R2 = self.R_DEFAULT; end
            if nargin < 2, R1 = self.R_DEFAULT; end

            % Create a cell to store the transmission parameters.
            transmission_parameters = cell( 1, 6 );
            
            % Pack the transmission parameters.
            transmission_parameters{ 1 } = R1;
            transmission_parameters{ 2 } = R2;
            transmission_parameters{ 3 } = Gm1;
            transmission_parameters{ 4 } = Gm2;
            transmission_parameters{ 5 } = Cm1;
            transmission_parameters{ 6 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the relative transmission design parameters.
        function [ R1, R2, Gm1, Gm2, Cm1, Cm2 ] = unpack_relative_transmission_parameters( self, transmission_parameters )
            
            % Set the default input arguments.
            if nargin < 2, transmission_parameters = self.pack_relative_transmission_parameters(  ); end
            
            % Unpack the transmission parameters.
            R1 = transmission_parameters{ 1 };
            R2 = transmission_parameters{ 2 };
            Gm1 = transmission_parameters{ 3 };
            Gm2 = transmission_parameters{ 4 };
            Cm1 = transmission_parameters{ 5 };
            Cm2 = transmission_parameters{ 6 };
            
        end
        
        
        % Implement a function to pack transmission design parameters.
        function transmission_parameters = pack_transmission_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the transmission parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute transmission parameters.
                transmission_parameters = self.pack_absolute_transmission_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative transmission parameters.
                transmission_parameters = self.pack_relative_transmission_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end

        
        % ---------- Addition Packing & Unpacking Functions ----------
        
        % Implement a function to pack the absolute addition design parameters.
        function addition_parameters = pack_absolute_addition_parameters( self, n_neurons, cs, Rs_input, Gms, Cms )
            
            % Ensure that the number of neurons is specified.
            if nargin < 2, n_neurons = self.n_addition_neurons_DEFAULT; end
            
            % Set the default input arguments.
            if nargin < 6, Cms = self.Cms_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 5, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 4, Rs_input = self.R_DEFAULT*ones( 1, n_neurons - 1 ); end
            if nargin < 3, cs = self.c_addition_DEFAULT*ones( 1, n_neurons - 1 ); end
            
            % Create a cell to store the addition parameters.
            addition_parameters = cell( 1, 4 );
            
            % Pack the addition parameters.
            addition_parameters{ 1 } = cs;
            addition_parameters{ 2 } = Rs_input;
            addition_parameters{ 3 } = Gms;
            addition_parameters{ 4 } = Cms;

        end
        
        
        % Implement a function to unpack the absolute addition design parameters.
        function [ cs, Rs_input, Gms, Cms ] = unpack_absolute_addition_parameters( self, addition_parameters )
            
            % Set the default input arguments.
            if nargin < 2, addition_parameters = self.pack_absolute_addition_parameters(  ); end
            
            % Unpack the inversion parameters.
            cs = addition_parameters{ 1 };
            Rs_input = addition_parameters{ 2 };
            Gms = addition_parameters{ 3 };
            Cms = addition_parameters{ 4 };
            
        end
        
        
        % Implement a function to pack the relative addition design parameters.
        function addition_parameters = pack_relative_addition_parameters( self, n_neurons, cs, Rs, Gms, Cms )
            
            % Ensure that the number of neurons is specified.
            if nargin < 2, n_neurons = self.n_addition_neurons_DEFAULT; end
            
            % Set the default input arguments.
            if nargin < 6, Cms = self.Cms_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 5, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 4, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 3, cs = self.c_addition_DEFAULT*ones( 1, n_neurons - 1 ); end
            
            % Create a cell to store the addition parameters.
            addition_parameters = cell( 1, 4 );
            
            % Pack the addition parameters.
            addition_parameters{ 1 } = cs;
            addition_parameters{ 2 } = Rs;
            addition_parameters{ 3 } = Gms;
            addition_parameters{ 4 } = Cms;

        end
        
        
        % Implement a function to unpack the relative addition design parameters.
        function [ cs, Rs, Gms, Cms ] = unpack_relative_addition_parameters( self, addition_parameters )
            
            % Set the default input arguments.
            if nargin < 2, addition_parameters = self.pack_relative_addition_parameters(  ); end
            
            % Unpack the inversion parameters.
            cs = addition_parameters{ 1 };
            Rs = addition_parameters{ 2 };
            Gms = addition_parameters{ 3 };
            Cms = addition_parameters{ 4 };
            
        end
        
        
        % Implement a function to pack the addition design parameters.
        function addition_parameters = pack_addition_parameters( self, n_neurons, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            if nargin < 2, n_neurons = self.n_addition_DEFAULT; end

            % Determine how to pack the addition parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute addition parameters.
                addition_parameters = self.pack_absolute_addition_parameters( n_neurons );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative addition parameters.
                addition_parameters = self.pack_relative_addition_parameters( n_neurons );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end

        
        % ---------- Subtraction Packing & Unpacking Functions ----------

        % Implement a function to pack the absolute subtraction design parameters.
        function subtraction_parameters = pack_absolute_subtraction_parameters( self, n_neurons, cs, ss, Rs_input, Gms, Cms )
            
            % Ensure that the number of neurons is specified.
            if nargin < 2, n_neurons = self.n_subtraction_neurons_DEFAULT; end
            
            % Set the default input arguments.
            if nargin < 7, Cms = self.Cms_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 6, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 5, Rs_input = self.R_DEFAULT*ones( 1, n_neurons - 1 ); end
            if nargin < 4, ss = self.ss_subtraction_DEFAULT*ones( 1, n_neurons - 1 ); end
        	if nargin < 3, cs = self.c_subtraction_DEFAULT*ones( 1, n_neurons - 1 ); end

            % Create a cell to store the addition parameters.
            subtraction_parameters = cell( 1, 5 );
            
            % Pack the addition parameters.
            subtraction_parameters{ 1 } = cs;
            subtraction_parameters{ 2 } = ss;
            subtraction_parameters{ 3 } = Rs_input;
            subtraction_parameters{ 4 } = Gms;
            subtraction_parameters{ 5 } = Cms;

        end
        
        
        % Implement a function to unpack the absolute subtraction design parameters.
        function [ cs, ss, Rs_input, Gms, Cms ] = unpack_absolute_subtraction_parameters( self, subtraction_parameters )
            
            % Set the default input arguments.
            if nargin < 2, subtraction_parameters = self.pack_absolute_subtraction_parameters(  ); end
            
            % Unpack the subtraction parameters.
            cs = subtraction_parameters{ 1 };
            ss = subtraction_parameters{ 2 };
            Rs_input = subtraction_parameters{ 3 };
            Gms = subtraction_parameters{ 4 };
            Cms = subtraction_parameters{ 5 };
            
        end
        
        
        % Implement a function to pack the relative subtraction design parameters.
        function subtraction_parameters = pack_relative_subtraction_parameters( self, n_neurons, cs, ss, Rs, Gms, Cms )
            
            % Ensure that the number of neurons is specified.
            if nargin < 2, n_neurons = self.n_subtraction_neurons_DEFAULT; end
            
            % Set the default input arguments.
            if nargin < 7, Cms = self.Cms_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 6, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 5, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end
            if nargin < 4, ss = self.ss_subtraction_DEFAULT*ones( 1, n_neurons - 1 ); end
            if nargin < 3, cs = self.c_subtraction_DEFAULT*ones( 1, n_neurons - 1 ); end
            
            % Create a cell to store the addition parameters.
            subtraction_parameters = cell( 1, 5 );
            
            % Pack the addition parameters.
            subtraction_parameters{ 1 } = cs;
            subtraction_parameters{ 2 } = ss;
            subtraction_parameters{ 3 } = Rs;
            subtraction_parameters{ 4 } = Gms;
            subtraction_parameters{ 5 } = Cms;

        end
        
        
        % Implement a function to unpack the relative subtraction design parameters.
        function [ cs, ss, Rs, Gms, Cms ] = unpack_relative_subtraction_parameters( self, subtraction_parameters )
            
            % Set the default input arguments.
            if nargin < 2, subtraction_parameters = self.pack_relative_subtraction_parameters(  ); end
            
            % Unpack the inversion parameters.
            cs = subtraction_parameters{ 1 };
            ss = subtraction_parameters{ 2 };
            Rs = subtraction_parameters{ 3 };
            Gms = subtraction_parameters{ 4 };
            Cms = subtraction_parameters{ 5 };
            
        end
        
        
        % Implement a function to pack the subtraction design parameters.
        function subtraction_parameters = pack_subtraction_parameters( self, n_neurons, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            if nargin < 2, n_neurons = self.n_addition_DEFAULT; end

            % Determine how to pack the subtraction parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute subtraction parameters.
                subtraction_parameters = self.pack_absolute_subtraction_parameters( n_neurons );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative subtraction parameters.
                subtraction_parameters = self.pack_relative_subtraction_parameters( n_neurons );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
                
        % ---------- Inversion Packing & Unpacking Functions ----------
        
        % Implement a function to pack the absolute inversion design parameters.
        function inversion_parameters = pack_absolute_inversion_parameters( self, c1, c3, delta, R1, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 9, Cm2 = self.Cm_DEFAULT; end
            if nargin < 8, Cm1 = self.Cm_DEFAULT; end
            if nargin < 7, Gm2 = self.Gm_DEFAULT; end
            if nargin < 6, Gm1 = self.Gm_DEFAULT; end
            if nargin < 5, R1 = self.R_DEFAULT; end
            if nargin < 4, delta = self.delta_inversion_DEFAULT; end
            if nargin < 3, c3 = self.c3_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_inversion_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            inversion_parameters = cell( 1, 8 );
            
            % Pack the inversion parameters.
            inversion_parameters{ 1 } = c1;
            inversion_parameters{ 2 } = c3;
            inversion_parameters{ 3 } = delta;
            inversion_parameters{ 4 } = R1;
            inversion_parameters{ 5 } = Gm1;
            inversion_parameters{ 6 } = Gm2;
            inversion_parameters{ 7 } = Cm1;
            inversion_parameters{ 8 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the absolute inversion design parameters.
        function [ c1, c3, delta, R1, Gm1, Gm2, Cm1, Cm2 ] = unpack_absolute_inversion_parameters( self, inversion_parameters )
            
            % Set the default input arguments.
            if nargin < 2, inversion_parameters = self.pack_absolute_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            c1 = inversion_parameters{ 1 };
            c3 = inversion_parameters{ 2 };
            delta = inversion_parameters{ 3 };
            R1 = inversion_parameters{ 4 };
            Gm1 = inversion_parameters{ 5 };
            Gm2 = inversion_parameters{ 6 };
            Cm1 = inversion_parameters{ 7 };
            Cm2 = inversion_parameters{ 8 };
            
        end
        
        
        % Implement a function to pack the relative inversion design parameters.
        function inversion_parameters = pack_relative_inversion_parameters( self, c3, delta, R1, R2, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 9, Cm2 = self.Cm_DEFAULT; end
            if nargin < 8, Cm1 = self.Cm_DEFAULT; end
            if nargin < 7, Gm2 = self.Gm_DEFAULT; end
            if nargin < 6, Gm1 = self.Gm_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta = self.delta_inversion_DEFAULT; end
            if nargin < 2, c3 = self.c3_inversion_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            inversion_parameters = cell( 1, 8 );
            
            % Pack the inversion parameters.
            inversion_parameters{ 1 } = c3;
            inversion_parameters{ 2 } = delta;
            inversion_parameters{ 3 } = R1;
            inversion_parameters{ 4 } = R2;
            inversion_parameters{ 5 } = Gm1;
            inversion_parameters{ 6 } = Gm2;
            inversion_parameters{ 7 } = Cm1;
            inversion_parameters{ 8 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the relative inversion design parameters.
        function [ c3, delta, R1, R2, Gm1, Gm2, Cm1, Cm2 ] = unpack_relative_inversion_parameters( self, inversion_parameters )
            
            % Set the default input arguments.
            if nargin < 2, inversion_parameters = self.pack_relative_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            c3 = inversion_parameters{ 1 };
            delta = inversion_parameters{ 2 };
            R1 = inversion_parameters{ 3 };
            R2 = inversion_parameters{ 4 };
            Gm1 = inversion_parameters{ 5 };
            Gm2 = inversion_parameters{ 6 };
            Cm1 = inversion_parameters{ 7 };
            Cm2 = inversion_parameters{ 8 };
            
        end
        
        
        % Implement a function to pack the inversion design parameters.
        function inversion_parameters = pack_inversion_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the inversion parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute inversion parameters.
                inversion_parameters = self.pack_absolute_inversion_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative inversion parameters.
                inversion_parameters = self.pack_relative_inversion_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Reduced Inversion Packing & Unpacking Functions ----------

        % Implement a function to pack the reduced absolute inversion design parameters.
        function inversion_parameters = pack_reduced_absolute_inversion_parameters( self, c1, delta, R1, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 8, Cm2 = self.Cm_DEFAULT; end
            if nargin < 7, Cm1 = self.Cm_DEFAULT; end
            if nargin < 6, Gm2 = self.Gm_DEFAULT; end
            if nargin < 5, Gm1 = self.Gm_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta = self.delta_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_inversion_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            inversion_parameters = cell( 1, 7 );
            
            % Pack the inversion parameters.
            inversion_parameters{ 1 } = c1;
            inversion_parameters{ 2 } = delta;
            inversion_parameters{ 3 } = R1;
            inversion_parameters{ 4 } = Gm1;
            inversion_parameters{ 5 } = Gm2;
            inversion_parameters{ 6 } = Cm1;
            inversion_parameters{ 7 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the reduced absolute inversion design parameters.
        function [ c1, delta, R1, Gm1, Gm2, Cm1, Cm2 ] = unpack_reduced_absolute_inversion_parameters( self, inversion_parameters )
            
            % Set the default input arguments.
            if nargin < 2, inversion_parameters = self.pack_reduced_absolute_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            c1 = inversion_parameters{ 1 };
            delta = inversion_parameters{ 2 };
            R1 = inversion_parameters{ 3 };
            Gm1 = inversion_parameters{ 4 };
            Gm2 = inversion_parameters{ 5 };
            Cm1 = inversion_parameters{ 6 };
            Cm2 = inversion_parameters{ 7 };
            
        end
        
        
        % Implement a function to pack the reduced relative inversion design parameters.
        function inversion_parameters = pack_reduced_relative_inversion_parameters( self, delta, R1, R2, Gm1, Gm2, Cm1, Cm2 )
            
            % Set the default input arguments.
            if nargin < 8, Cm2 = self.Cm_DEFAULT; end
            if nargin < 7, Cm1 = self.Cm_DEFAULT; end
            if nargin < 6, Gm2 = self.Gm_DEFAULT; end
            if nargin < 5, Gm1 = self.Gm_DEFAULT; end
            if nargin < 4, R2 = self.R_DEFAULT; end
            if nargin < 3, R1 = self.R_DEFAULT; end
            if nargin < 2, delta = self.delta_inversion_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            inversion_parameters = cell( 1, 7 );
            
            % Pack the transmission parameters.
            inversion_parameters{ 1 } = delta;
            inversion_parameters{ 2 } = R1;
            inversion_parameters{ 3 } = R2;
            inversion_parameters{ 4 } = Gm1;
            inversion_parameters{ 5 } = Gm2;
            inversion_parameters{ 6 } = Cm1;
            inversion_parameters{ 7 } = Cm2;
            
        end
        
        
        % Implement a function to unpack the relative inversion design parameters.
        function [ delta, R1, R2, Gm1, Gm2, Cm1, Cm2 ] = unpack_reduced_relative_inversion_parameters( self, inversion_parameters )
            
            % Set the default input arguments.
            if nargin < 2, inversion_parameters = self.pack_reduced_relative_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            delta = inversion_parameters{ 1 };
            R1 = inversion_parameters{ 2 };
            R2 = inversion_parameters{ 3 };
            Gm1 = inversion_parameters{ 4 };
            Gm2 = inversion_parameters{ 5 };
            Cm1 = inversion_parameters{ 6 };
            Cm2 = inversion_parameters{ 7 };
            
        end
        
        
        % Implement a function to pack the reduced inversion design parameters.
        function inversion_parameters = pack_reduced_inversion_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the inversion parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute inversion parameters.
                inversion_parameters = self.pack_reduced_absolute_inversion_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative inversion parameters.
                inversion_parameters = self.pack_reduced_relative_inversion_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Division Packing & Unpacking Functions ----------
        
        % Implement a function to pack the absolute division design parameters.
        function division_parameters = pack_absolute_division_parameters( self, c1, c3, delta, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 12, Cm3 = self.Cm_DEFAULT; end
            if nargin < 11, Cm2 = self.Cm_DEFAULT; end
            if nargin < 10, Cm1 = self.Cm_DEFAULT; end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, Gm2 = self.Gm_DEFAULT; end
            if nargin < 7, Gm1 = self.Gm_DEFAULT; end
            if nargin < 6, R2 = self.R_DEFAULT; end
            if nargin < 5, R1 = self.R_DEFAULT; end
            if nargin < 4, delta = self.delta_division_DEFAULT; end
            if nargin < 3, c3 = self.c3_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_division_DEFAULT; end
            
            % Create a cell to store the division parameters.
            division_parameters = cell( 1, 11 );
            
            % Pack the division parameters.
            division_parameters{ 1 } = c1;
            division_parameters{ 2 } = c3;
            division_parameters{ 3 } = delta;
            division_parameters{ 4 } = R1;
            division_parameters{ 5 } = R2;
            division_parameters{ 6 } = Gm1;
            division_parameters{ 7 } = Gm2;
            division_parameters{ 8 } = Gm3;
            division_parameters{ 9 } = Cm1;
            division_parameters{ 10 } = Cm2;
            division_parameters{ 11 } = Cm3;

        end
        
        
        % Implement a function to unpack the absolute division design parameters.
        function [ c1, c3, delta, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_absolute_division_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_absolute_division_parameters(  ); end
            
            % Unpack the division parameters.
            c1 = division_parameters{ 1 };
            c3 = division_parameters{ 2 };
            delta = division_parameters{ 3 };
            R1 = division_parameters{ 4 };
            R2 = division_parameters{ 5 };
            Gm1 = division_parameters{ 6 };
            Gm2 = division_parameters{ 7 };
            Gm3 = division_parameters{ 8 };
            Cm1 = division_parameters{ 9 };
            Cm2 = division_parameters{ 10 };
            Cm3 = division_parameters{ 11 };

        end
        
        
        % Implement a function to pack the relative division design parameters.
        function division_parameters = pack_relative_division_parameters( self, c3, delta, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 12, Cm3 = self.Cm_DEFAULT; end
            if nargin < 11, Cm2 = self.Cm_DEFAULT; end
            if nargin < 10, Cm1 = self.Cm_DEFAULT; end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, Gm2 = self.Gm_DEFAULT; end
            if nargin < 7, Gm1 = self.Gm_DEFAULT; end
            if nargin < 6, R3 = self.R_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta = self.delta_division_DEFAULT; end
            if nargin < 2, c3 = self.c3_division_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            division_parameters = cell( 1, 11 );
            
            % Pack the inversion parameters.
            division_parameters{ 1 } = c3;
            division_parameters{ 2 } = delta;
            division_parameters{ 3 } = R1;
            division_parameters{ 4 } = R2;
            division_parameters{ 5 } = R3;
            division_parameters{ 6 } = Gm1;
            division_parameters{ 7 } = Gm2;
            division_parameters{ 8 } = Gm3;
            division_parameters{ 9 } = Cm1;
            division_parameters{ 10 } = Cm2;
            division_parameters{ 11 } = Cm3;

        end
        
        
        % Implement a function to unpack the relative division design parameters.
        function [ c3, delta, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_relative_division_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_relative_division_parameters(  ); end
            
            % Unpack the inversion parameters.
            c3 = division_parameters{ 1 };
            delta = division_parameters{ 2 };
            R1 = division_parameters{ 3 };
            R2 = division_parameters{ 4 };
            R3 = division_parameters{ 5 };
            Gm1 = division_parameters{ 6 };
            Gm2 = division_parameters{ 7 };
            Gm3 = division_parameters{ 8 };
            Cm1 = division_parameters{ 9 };
            Cm2 = division_parameters{ 10 };
            Cm3 = division_parameters{ 11 };

        end
        
        
        % Implement a function to pack the division design parameters.
        function division_parameters = pack_division_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the division parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute division parameters.
                division_parameters = self.pack_absolute_division_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative division parameters.
                division_parameters = self.pack_relative_division_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Reduced Division Packing & Unpacking Functions ----------

        % Implement a function to pack the reduced absolute division design parameters.
        function division_parameters = pack_reduced_absolute_division_parameters( self, c1, delta, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 11, Cm3 = self.Cm_DEFAULT; end
            if nargin < 10, Cm2 = self.Cm_DEFAULT; end
            if nargin < 9, Cm1 = self.Cm_DEFAULT; end
            if nargin < 8, Gm3 = self.Gm_DEFAULT; end
            if nargin < 7, Gm2 = self.Gm_DEFAULT; end
            if nargin < 6, Gm1 = self.Gm_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta = self.delta_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_division_DEFAULT; end
            
            % Create a cell to store the division parameters.
            division_parameters = cell( 1, 10 );
            
            % Pack the division parameters.
            division_parameters{ 1 } = c1;
            division_parameters{ 2 } = delta;
            division_parameters{ 3 } = R1;
            division_parameters{ 4 } = R2;
            division_parameters{ 5 } = Gm1;
            division_parameters{ 6 } = Gm2;
            division_parameters{ 7 } = Gm3;
            division_parameters{ 8 } = Cm1;
            division_parameters{ 9 } = Cm2;
            division_parameters{ 10 } = Cm3;

        end
        
        
        % Implement a function to unpack the reduced absolute division design parameters.
        function [ c1, delta, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_reduced_absolute_division_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_reduced_absolute_division_parameters(  ); end
            
            % Unpack the division parameters.
            c1 = division_parameters{ 1 };
            delta = division_parameters{ 2 };
            R1 = division_parameters{ 3 };
            R2 = division_parameters{ 4 };
            Gm1 = division_parameters{ 5 };
            Gm2 = division_parameters{ 6 };
            Gm3 = division_parameters{ 7 };
            Cm1 = division_parameters{ 8 };
            Cm2 = division_parameters{ 9 };
            Cm3 = division_parameters{ 10 };

        end
        
        
        % Implement a function to pack the reduced relative division design parameters.
        function division_parameters = pack_reduced_relative_division_parameters( self, delta, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 12, Cm3 = self.Cm_DEFAULT; end
            if nargin < 11, Cm2 = self.Cm_DEFAULT; end
            if nargin < 10, Cm1 = self.Cm_DEFAULT; end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, Gm2 = self.Gm_DEFAULT; end
            if nargin < 7, Gm1 = self.Gm_DEFAULT; end
            if nargin < 6, R3 = self.R_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta = self.delta_division_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            division_parameters = cell( 1, 10 );
            
            % Pack the inversion parameters.
            division_parameters{ 1 } = delta;
            division_parameters{ 2 } = R1;
            division_parameters{ 3 } = R2;
            division_parameters{ 4 } = R3;
            division_parameters{ 5 } = Gm1;
            division_parameters{ 6 } = Gm2;
            division_parameters{ 7 } = Gm3;
            division_parameters{ 8 } = Cm1;
            division_parameters{ 9 } = Cm2;
            division_parameters{ 10 } = Cm3;

        end
        
        
        % Implement a function to unpack the reduced relative division design parameters.
        function [ delta, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_reduced_relative_division_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_relative_division_parameters(  ); end
            
            % Unpack the inversion parameters.
            delta = division_parameters{ 1 };
            R1 = division_parameters{ 2 };
            R2 = division_parameters{ 3 };
            R3 = division_parameters{ 4 };
            Gm1 = division_parameters{ 5 };
            Gm2 = division_parameters{ 6 };
            Gm3 = division_parameters{ 7 };
            Cm1 = division_parameters{ 8 };
            Cm2 = division_parameters{ 9 };
            Cm3 = division_parameters{ 10 };

        end
        
        
        % Implement a function to pack the reduced division design parameters.
        function division_parameters = pack_reduced_division_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the division parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the reduced absolute division parameters.
                division_parameters = self.pack_reduced_absolute_division_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the reduced relative division parameters.
                division_parameters = self.pack_reduced_relative_division_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Division After Inversion Packing & Unpacking Functions ----------

        % Implement a function to pack the absolute division after inversion design parameters.
        function division_parameters = pack_absolute_division_after_inversion_parameters( self, c1, c3, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 13, Cm3 = self.Cm_DEFAULT; end
            if nargin < 12, Cm2 = self.Cm_DEFAULT; end
            if nargin < 11, Cm1 = self.Cm_DEFAULT; end
            if nargin < 10, Gm3 = self.Gm_DEFAULT; end
            if nargin < 9, Gm2 = self.Gm_DEFAULT; end
            if nargin < 8, Gm1 = self.Gm_DEFAULT; end
            if nargin < 7, R2 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_division_DEFAULT; end
            if nargin < 4, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 3, c3 = self.c3_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_division_DEFAULT; end
            
            % Create a cell to store the division parameters.
            division_parameters = cell( 1, 12 );
            
            % Pack the division parameters.
            division_parameters{ 1 } = c1;
            division_parameters{ 2 } = c3;
            division_parameters{ 3 } = delta1;
            division_parameters{ 4 } = delta2;
            division_parameters{ 5 } = R1;
            division_parameters{ 6 } = R2;
            division_parameters{ 7 } = Gm1;
            division_parameters{ 8 } = Gm2;
            division_parameters{ 9 } = Gm3;
            division_parameters{ 10 } = Cm1;
            division_parameters{ 11 } = Cm2;
            division_parameters{ 12 } = Cm3;

        end
        
        
        % Implement a function to unpack the absolute division after inversion design parameters.
        function [ c1, c3, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_absolute_division_after_inversion_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_absolute_division_after_inversionparameters(  ); end
            
            % Unpack the division parameters.
            c1 = division_parameters{ 1 };
            c3 = division_parameters{ 2 };
            delta1 = division_parameters{ 3 };
            delta2 = division_parameters{ 4 };
            R1 = division_parameters{ 5 };
            R2 = division_parameters{ 6 };
            Gm1 = division_parameters{ 7 };
            Gm2 = division_parameters{ 8 };
            Gm3 = division_parameters{ 9 };
            Cm1 = division_parameters{ 10 };
            Cm2 = division_parameters{ 11 };
            Cm3 = division_parameters{ 12 };

        end
        
        
        % Implement a function to pack the relative division after inversion design parameters.
        function division_parameters = pack_relative_division_after_inversion_parameters( self, c3, delta1, delta2, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 13, Cm3 = self.Cm_DEFAULT; end
            if nargin < 12, Cm2 = self.Cm_DEFAULT; end
            if nargin < 11, Cm1 = self.Cm_DEFAULT; end
            if nargin < 10, Gm3 = self.Gm_DEFAULT; end
            if nargin < 9, Gm2 = self.Gm_DEFAULT; end
            if nargin < 8, Gm1 = self.Gm_DEFAULT; end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, R2 = self.R_DEFAULT; end
            if nargin < 5, R1 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 2, c3 = self.c3_division_DEFAULT; end
            
            % Create a cell to store the inversion parameters.
            division_parameters = cell( 1, 12 );
            
            % Pack the inversion parameters.
            division_parameters{ 1 } = c3;
            division_parameters{ 2 } = delta1;
            division_parameters{ 3 } = delta2;
            division_parameters{ 4 } = R1;
            division_parameters{ 5 } = R2;
            division_parameters{ 6 } = R3;
            division_parameters{ 7 } = Gm1;
            division_parameters{ 8 } = Gm2;
            division_parameters{ 9 } = Gm3;
            division_parameters{ 10 } = Cm1;
            division_parameters{ 11 } = Cm2;
            division_parameters{ 12 } = Cm3;

        end
        
        
        % Implement a function to unpack the relative division after inversion design parameters.
        function [ c3, delta1, delta2, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_relative_division_after_inversion_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_relative_division_after_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            c3 = division_parameters{ 1 };
            delta1 = division_parameters{ 2 };
            delta2 = division_parameters{ 3 };
            R1 = division_parameters{ 4 };
            R2 = division_parameters{ 5 };
            R3 = division_parameters{ 6 };
            Gm1 = division_parameters{ 7 };
            Gm2 = division_parameters{ 8 };
            Gm3 = division_parameters{ 9 };
            Cm1 = division_parameters{ 10 };
            Cm2 = division_parameters{ 11 };
            Cm3 = division_parameters{ 12 };

        end
        
        
        % Implement a function to pack the division after inversion design parameters.
        function division_parameters = pack_division_after_inversion_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the division after inversion parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute division after inversion parameters.
                division_parameters = self.pack_absolute_division_after_inversion_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative division after inversion parameters.
                division_parameters = self.pack_relative_division_after_inversion_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Reduced Division After Inversion Packing & Unpacking Functions ----------

        % Implement a function to pack the reduced absolute division after inversion design parameters.
        function division_parameters = pack_reduced_absolute_division_after_inversion_parameters( self, c1, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 12, Cm3 = self.Cm_DEFAULT; end
            if nargin < 11, Cm2 = self.Cm_DEFAULT; end
            if nargin < 10, Cm1 = self.Cm_DEFAULT; end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, Gm2 = self.Gm_DEFAULT; end
            if nargin < 7, Gm1 = self.Gm_DEFAULT; end
            if nargin < 6, R2 = self.R_DEFAULT; end
            if nargin < 5, R1 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_division_DEFAULT; end
            
            % Create a cell to store the division after inversion parameters.
            division_parameters = cell( 1, 11 );
            
            % Pack the division after inversion parameters.
            division_parameters{ 1 } = c1;
            division_parameters{ 2 } = delta1;
            division_parameters{ 3 } = delta2;
            division_parameters{ 4 } = R1;
            division_parameters{ 5 } = R2;
            division_parameters{ 6 } = Gm1;
            division_parameters{ 7 } = Gm2;
            division_parameters{ 8 } = Gm3;
            division_parameters{ 9 } = Cm1;
            division_parameters{ 10 } = Cm2;
            division_parameters{ 11 } = Cm3;

        end
        
        
        % Implement a function to unpack the reduced absolute division after inversion design parameters.
        function [ c1, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_reduced_absolute_after_inversion_division_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_reduced_absolute_division_after_inversion_parameters(  ); end
            
            % Unpack the division parameters.
            c1 = division_parameters{ 1 };
            delta1 = division_parameters{ 2 };
            delta2 = division_parameters{ 3 };
            R1 = division_parameters{ 4 };
            R2 = division_parameters{ 5 };
            Gm1 = division_parameters{ 6 };
            Gm2 = division_parameters{ 7 };
            Gm3 = division_parameters{ 8 };
            Cm1 = division_parameters{ 9 };
            Cm2 = division_parameters{ 10 };
            Cm3 = division_parameters{ 11 };
            
        end
        
        
        % Implement a function to pack the reduced relative division after inversion design parameters.
        function division_parameters = pack_reduced_relative_division_after_inversion_parameters( self, delta1, delta2, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 )
            
            % Set the default input arguments.
            if nargin < 12, Cm3 = self.Cm_DEFAULT; end
            if nargin < 11, Cm2 = self.Cm_DEFAULT; end
            if nargin < 10, Cm1 = self.Cm_DEFAULT; end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, Gm2 = self.Gm_DEFAULT; end
            if nargin < 7, Gm1 = self.Gm_DEFAULT; end
            if nargin < 6, R3 = self.R_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, R1 = self.R_DEFAULT; end
            if nargin < 3, delta2 = self.delta_division_DEFAULT; end
            if nargin < 2, delta1 = self.delta_inversion_DEFAULT; end

            % Create a cell to store the inversion parameters.
            division_parameters = cell( 1, 11 );
            
            % Pack the inversion parameters.
            division_parameters{ 1 } = delta1;
            division_parameters{ 2 } = delta2;
            division_parameters{ 3 } = R1;
            division_parameters{ 4 } = R2;
            division_parameters{ 5 } = R3;
            division_parameters{ 6 } = Gm1;
            division_parameters{ 7 } = Gm2;
            division_parameters{ 8 } = Gm3;
            division_parameters{ 9 } = Cm1;
            division_parameters{ 10 } = Cm2;
            division_parameters{ 11 } = Cm3;

        end
        
        
        % Implement a function to unpack the reduced relative division after inversion design parameters.
        function [ delta1, delta2, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = unpack_reduced_relative_division_after_inversion_parameters( self, division_parameters )
            
            % Set the default input arguments.
            if nargin < 2, division_parameters = self.pack_relative_division_after_inversion_parameters(  ); end
            
            % Unpack the inversion parameters.
            delta1 = division_parameters{ 1 };
            delta2 = division_parameters{ 2 };
            R1 = division_parameters{ 3 };
            R2 = division_parameters{ 4 };
            R3 = division_parameters{ 5 };
            Gm1 = division_parameters{ 6 };
            Gm2 = division_parameters{ 7 };
            Gm3 = division_parameters{ 8 };
            Cm1 = division_parameters{ 9 };
            Cm2 = division_parameters{ 10 };
            Cm3 = division_parameters{ 11 };

        end
        
        
        % Implement a function to pack the reduced division after inversion design parameters.
        function division_parameters = pack_reduced_division_after_inversion_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the division parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the reduced absolute division parameters.
                division_parameters = self.pack_reduced_absolute_division_after_inversion_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the reduced relative division parameters.
                division_parameters = self.pack_reduced_relative_division_after_inversion_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Multiplication Packing & Unpacking Functions ----------
        
        % Implement a function to pack the absolute multiplication design parameters.
        function multiplication_parameters = pack_absolute_multiplication_parameters( self, c1, c3, c4, c6, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 )
            
            % Set the default input arguments.
            if nargin < 17, Cm4 = self.Cm_DEFAULT; end
            if nargin < 16, Cm3 = self.Cm_DEFAULT; end
            if nargin < 15, Cm2 = self.Cm_DEFAULT; end
            if nargin < 14, Cm1 = self.Cm_DEFAULT; end
            if nargin < 13, Gm4 = self.Gm_DEFAULT; end
            if nargin < 12, Gm3 = self.Gm_DEFAULT; end
            if nargin < 11, Gm2 = self.Gm_DEFAULT; end
            if nargin < 10, Gm1 = self.Gm_DEFAULT; end
            if nargin < 9, R2 = self.R_DEFAULT; end
            if nargin < 8, R1 = self.R_DEFAULT; end
            if nargin < 7, delta2 = self.delta_division_DEFAULT; end
            if nargin < 6, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 5, c6 = self.c6_division_DEFAULT; end
            if nargin < 4, c4 = self.c4_division_DEFAULT; end
            if nargin < 3, c3 = self.c3_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_inversion_DEFAULT; end
            
            % Create a cell to store the division parameters.
            multiplication_parameters = cell( 1, 16 );
            
            % Pack the division parameters.
            multiplication_parameters{ 1 } = c1;
            multiplication_parameters{ 2 } = c3;
            multiplication_parameters{ 3 } = c4;
            multiplication_parameters{ 4 } = c6;
            multiplication_parameters{ 5 } = delta1;
            multiplication_parameters{ 6 } = delta2;
            multiplication_parameters{ 7 } = R1;
            multiplication_parameters{ 8 } = R2;
            multiplication_parameters{ 9 } = Gm1;
            multiplication_parameters{ 10 } = Gm2;
            multiplication_parameters{ 11 } = Gm3;
            multiplication_parameters{ 12 } = Gm4;
            multiplication_parameters{ 13 } = Cm1;
            multiplication_parameters{ 14 } = Cm2;
            multiplication_parameters{ 15 } = Cm3;
            multiplication_parameters{ 16 } = Cm4;

        end

        
        % Implement a function to unpack the absolute multiplication design parameters.
        function [ c1, c3, c4, c6, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = unpack_absolute_multiplication_parameters( self, multiplication_parameters )
            
            % Set the default input arguments.
            if nargin < 2, multiplication_parameters = self.pack_absolute_multiplication_parameters(  ); end
            
            % Unpack the division parameters.
            c1 = multiplication_parameters{ 1 };
            c3 = multiplication_parameters{ 2 };
            c4 = multiplication_parameters{ 3 };
            c6 = multiplication_parameters{ 4 };
            delta1 = multiplication_parameters{ 5 };
            delta2 = multiplication_parameters{ 6 };
            R1 = multiplication_parameters{ 7 };
            R2 = multiplication_parameters{ 8 };
            Gm1 = multiplication_parameters{ 9 };
            Gm2 = multiplication_parameters{ 10 };
            Gm3 = multiplication_parameters{ 11 };
            Gm4 = multiplication_parameters{ 12 };
            Cm1 = multiplication_parameters{ 13 };
            Cm2 = multiplication_parameters{ 14 };
            Cm3 = multiplication_parameters{ 15 };
            Cm4 = multiplication_parameters{ 16 };

        end
        
        
        % Implement a function to pack the relative multiplication design parameters.
        function multiplication_parameters = pack_relative_multiplication_parameters( self, c3, c6, delta1, delta2, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 )
            
            % Set the default input arguments.
            if nargin < 17, Cm4 = self.Cm_DEFAULT; end
            if nargin < 16, Cm3 = self.Cm_DEFAULT; end
            if nargin < 15, Cm2 = self.Cm_DEFAULT; end
            if nargin < 14, Cm1 = self.Cm_DEFAULT; end
            if nargin < 13, Gm4 = self.Gm_DEFAULT; end
            if nargin < 12, Gm3 = self.Gm_DEFAULT; end
            if nargin < 11, Gm2 = self.Gm_DEFAULT; end
            if nargin < 10, Gm1 = self.Gm_DEFAULT; end
            if nargin < 9, R4 = self.R_DEFAULT; end
            if nargin < 8, R3 = self.R_DEFAULT; end
            if nargin < 7, R2 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_division_DEFAULT; end
            if nargin < 4, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 3, c6 = self.c3_division_DEFAULT; end
            if nargin < 2, c3 = self.c3_inversion_DEFAULT; end

            % Create a cell to store the inversion parameters.
            multiplication_parameters = cell( 1, 16 );
            
            % Pack the inversion parameters.
            multiplication_parameters{ 1 } = c3;
            multiplication_parameters{ 2 } = c6;
            multiplication_parameters{ 3 } = delta1;
            multiplication_parameters{ 4 } = delta2;
            multiplication_parameters{ 5 } = R1;
            multiplication_parameters{ 6 } = R2;
            multiplication_parameters{ 7 } = R3;
            multiplication_parameters{ 8 } = R4;
            multiplication_parameters{ 9 } = Gm1;
            multiplication_parameters{ 10 } = Gm2;
            multiplication_parameters{ 11 } = Gm3;
            multiplication_parameters{ 12 } = Gm4;
            multiplication_parameters{ 13 } = Cm1;
            multiplication_parameters{ 14 } = Cm2;
            multiplication_parameters{ 15 } = Cm3;
            multiplication_parameters{ 16 } = Cm4;

        end
        
        
        % Implement a function to unpack the relative multiplication design parameters.
        function [ c3, c6, delta1, delta2, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = unpack_relative_multiplication_parameters( self, multiplication_parameters )
            
            % Set the default input arguments.
            if nargin < 2, multiplication_parameters = self.pack_relative_multiplication_parameters(  ); end
            
            % Unpack the inversion parameters.
            c3 = multiplication_parameters{ 1 };
            c6 = multiplication_parameters{ 2 };
            delta1 = multiplication_parameters{ 3 };
            delta2 = multiplication_parameters{ 4 };
            R1 = multiplication_parameters{ 5 };
            R2 = multiplication_parameters{ 6 };
            R3 = multiplication_parameters{ 7 };
            R4 = multiplication_parameters{ 8 };
            Gm1 = multiplication_parameters{ 9 };
            Gm2 = multiplication_parameters{ 10 };
            Gm3 = multiplication_parameters{ 11 };
            Gm4 = multiplication_parameters{ 12 };
            Cm1 = multiplication_parameters{ 13 };
            Cm2 = multiplication_parameters{ 14 };
            Cm3 = multiplication_parameters{ 15 };
            Cm4 = multiplication_parameters{ 16 };

        end
        
        
        % Implement a function to pack the multiplication design parameters.
        function multiplication_parameters = pack_multiplication_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the multiplication parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute multiplication parameters.
                multiplication_parameters = self.pack_absolute_multiplication_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative multiplication parameters.
                multiplication_parameters = self.pack_relative_multiplication_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Packing & Unpacking Functions ----------
        
        % Implement a function to pack the reduced absolute multiplication design parameters.
        function multiplication_parameters = pack_reduced_absolute_multiplication_parameters( self, c1, c3, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 )
            
            % Set the default input arguments.
            if nargin < 17, Cm4 = self.Cm_DEFAULT; end
            if nargin < 16, Cm3 = self.Cm_DEFAULT; end
            if nargin < 15, Cm2 = self.Cm_DEFAULT; end
            if nargin < 14, Cm1 = self.Cm_DEFAULT; end
            if nargin < 13, Gm4 = self.Gm_DEFAULT; end
            if nargin < 12, Gm3 = self.Gm_DEFAULT; end
            if nargin < 11, Gm2 = self.Gm_DEFAULT; end
            if nargin < 10, Gm1 = self.Gm_DEFAULT; end
            if nargin < 9, R2 = self.R_DEFAULT; end
            if nargin < 8, R1 = self.R_DEFAULT; end
            if nargin < 7, delta2 = self.delta_division_DEFAULT; end
            if nargin < 6, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 3, c3 = self.c1_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_inversion_DEFAULT; end
            
            % Create a cell to store the division parameters.
            multiplication_parameters = cell( 1, 14 );
            
            % Pack the division parameters.
            multiplication_parameters{ 1 } = c1;
            multiplication_parameters{ 2 } = c3;
            multiplication_parameters{ 3 } = delta1;
            multiplication_parameters{ 4 } = delta2;
            multiplication_parameters{ 5 } = R1;
            multiplication_parameters{ 6 } = R2;
            multiplication_parameters{ 7 } = Gm1;
            multiplication_parameters{ 8 } = Gm2;
            multiplication_parameters{ 9 } = Gm3;
            multiplication_parameters{ 10 } = Gm4;
            multiplication_parameters{ 11 } = Cm1;
            multiplication_parameters{ 12 } = Cm2;
            multiplication_parameters{ 13 } = Cm3;
            multiplication_parameters{ 14 } = Cm4;

        end

        
        % Implement a function to unpack the reduced absolute multiplication design parameters.
        function [ c1, c3, delta1, delta2, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = unpack_reduced_absolute_multiplication_parameters( self, multiplication_parameters )
            
            % Set the default input arguments.
            if nargin < 2, multiplication_parameters = self.pack_absolute_multiplication_parameters(  ); end
            
            % Unpack the division parameters.
            c1 = multiplication_parameters{ 1 };
            c3 = multiplication_parameters{ 2 };
            delta1 = multiplication_parameters{ 3 };
            delta2 = multiplication_parameters{ 4 };
            R1 = multiplication_parameters{ 5 };
            R2 = multiplication_parameters{ 6 };
            Gm1 = multiplication_parameters{ 7 };
            Gm2 = multiplication_parameters{ 8 };
            Gm3 = multiplication_parameters{ 9 };
            Gm4 = multiplication_parameters{ 10 };
            Cm1 = multiplication_parameters{ 11 };
            Cm2 = multiplication_parameters{ 12 };
            Cm3 = multiplication_parameters{ 13 };
            Cm4 = multiplication_parameters{ 14 };

        end
        
        
        % Implement a function to pack the reduced relative multiplication design parameters.
        function multiplication_parameters = pack_reduced_relative_multiplication_parameters( self, delta1, delta2, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 )
            
            % Set the default input arguments.
            if nargin < 17, Cm4 = self.Cm_DEFAULT; end
            if nargin < 16, Cm3 = self.Cm_DEFAULT; end
            if nargin < 15, Cm2 = self.Cm_DEFAULT; end
            if nargin < 14, Cm1 = self.Cm_DEFAULT; end
            if nargin < 13, Gm4 = self.Gm_DEFAULT; end
            if nargin < 12, Gm3 = self.Gm_DEFAULT; end
            if nargin < 11, Gm2 = self.Gm_DEFAULT; end
            if nargin < 10, Gm1 = self.Gm_DEFAULT; end
            if nargin < 9, R4 = self.R_DEFAULT; end
            if nargin < 8, R3 = self.R_DEFAULT; end
            if nargin < 7, R2 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_division_DEFAULT; end
            if nargin < 4, delta1 = self.delta_inversion_DEFAULT; end

            % Create a cell to store the inversion parameters.
            multiplication_parameters = cell( 1, 16 );
            
            % Pack the inversion parameters.
            multiplication_parameters{ 3 } = delta1;
            multiplication_parameters{ 4 } = delta2;
            multiplication_parameters{ 5 } = R1;
            multiplication_parameters{ 6 } = R2;
            multiplication_parameters{ 7 } = R3;
            multiplication_parameters{ 8 } = R4;
            multiplication_parameters{ 9 } = Gm1;
            multiplication_parameters{ 10 } = Gm2;
            multiplication_parameters{ 11 } = Gm3;
            multiplication_parameters{ 12 } = Gm4;
            multiplication_parameters{ 13 } = Cm1;
            multiplication_parameters{ 14 } = Cm2;
            multiplication_parameters{ 15 } = Cm3;
            multiplication_parameters{ 16 } = Cm4;

        end
        
        
        % Implement a function to unpack the reduced relative multiplication design parameters.
        function [ delta1, delta2, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = unpack_reduced_relative_multiplication_parameters( self, multiplication_parameters )
            
            % Set the default input arguments.
            if nargin < 2, multiplication_parameters = self.pack_relative_multiplication_parameters(  ); end
            
            % Unpack the inversion parameters.
            delta1 = multiplication_parameters{ 1 };
            delta2 = multiplication_parameters{ 2 };
            R1 = multiplication_parameters{ 3 };
            R2 = multiplication_parameters{ 4 };
            R3 = multiplication_parameters{ 5 };
            R4 = multiplication_parameters{ 6 };
            Gm1 = multiplication_parameters{ 7 };
            Gm2 = multiplication_parameters{ 8 };
            Gm3 = multiplication_parameters{ 9 };
            Gm4 = multiplication_parameters{ 10 };
            Cm1 = multiplication_parameters{ 11 };
            Cm2 = multiplication_parameters{ 12 };
            Cm3 = multiplication_parameters{ 13 };
            Cm4 = multiplication_parameters{ 14 };

        end
        
        
        % Implement a function to pack the reduced multiplication design parameters.
        function multiplication_parameters = pack_reduced_multiplication_parameters( self, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme ( Must be either: 'absolute' or 'relative'. )
            
            % Determine how to pack the multiplication parameters.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If the encoding scheme is absolute...
                
                % Pack the absolute multiplication parameters.
                multiplication_parameters = self.pack_reduced_absolute_multiplication_parameters(  );
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If the encoding scheme is relative...
            
                % Pack the relative multiplication parameters.
                multiplication_parameters = self.pack_reduced_relative_multiplication_parameters(  );
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be one of: ''absolute'' or ''relative''.' )
                                
            end
            
        end
        
        
        %% Subnetwork Design Parameter Conversion Functions.
        
        % ---------- Transmission Design Parameter Conversion Functions ----------
        
        % Implement a function to convert absolute transmission design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_transmission_parameters2network_parameters( self, transmission_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, transmission_parameters = self.pack_absolute_transmission_parameters(  ); end
            
            % Define the number of transmission neurons.
            n_neurons = self.n_transmission_neurons_DEFAULT;
            n_synapses = self.n_transmission_synapses_DEFAULT;
            
            % Unpack the transmission parameters.
            [ ~, R1, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_absolute_transmission_parameters( transmission_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative transmission design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_transmission_parameters2network_parameters( self, transmission_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, transmission_parameters = self.pack_relative_transmission_parameters(  ); end
            
            % Define the number of transmission neurons.
            n_neurons = self.n_transmission_neurons_DEFAULT;
            n_synapses = self.n_transmission_synapses_DEFAULT;
            
            % Unpack the transmission parameters.
            [ R1, R2, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_relative_transmission_parameters( transmission_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert transmission design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = transmission_parameters2network_parameters( self, transmission_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert transmission design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the transmission parameters have been defined.
                if nargin < 2, transmission_parameters = self.pack_absolute_transmission_parameters(  ); end

                % Convert absolue transmission parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_transmission_parameters2network_parameters( transmission_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the transmission parameters have been defined.
                if nargin < 2, transmission_parameters = self.pack_relative_transmission_parameters(  ); end
                
                % Convert relative transmission parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_transmission_parameters2network_parameters( transmission_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Addition Design Parameter Conversion Functions ----------
        
        % Implement a function to convert absolute addition design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_addition_parameters2network_parameters( self, addition_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, addition_parameters = self.pack_absolute_addition_parameters(  ); end
            
            % Define the number of addition neurons.
            n_neurons = self.n_addition_neurons_DEFAULT;
            n_synapses = self.n_addition_synapses_DEFAULT;
            
            % Unpack the addition parameters.            
            [ ~, Rs_input, Gms, Cms ] = self.unpack_absolute_addition_parameters( addition_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Ers = self.Er_DEFAULT;
            Rs = [ Rs_input, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative addition design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_addition_parameters2network_parameters( self, addition_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, addition_parameters = self.pack_relative_addition_parameters(  ); end
            
            % Define the number of addition neurons.
            n_neurons = self.n_addition_neurons_DEFAULT;
            n_synapses = self.n_addition_synapses_DEFAULT;
            
            % Unpack the addition parameters.                        
            [ ~, Rs, Gms, Cms ] = self.unpack_relative_addition_parameters( addition_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Ers = self.Er_DEFAULT;
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
                
        % Implement a function to convert addition design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = addition_parameters2network_parameters( self, addition_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert addition design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the addition parameters have been defined.
                if nargin < 2, addition_parameters = self.pack_absolute_addition_parameters(  ); end
                
                % Convert absolue addition parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_addition_parameters2network_parameters( addition_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the addition parameters have been defined.
                if nargin < 23, addition_parameters = self.pack_relative_addition_parameters(  ); end
                
                % Convert relative addition parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_addition_parameters2network_parameters( addition_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Subtraction Design Parameter Conversion Functions ----------
                 
        % Implement a function to convert absolute subtraction design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_subtraction_parameters2network_parameters( self, subtraction_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, subtraction_parameters = self.pack_absolute_subtraction_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_subtraction_neurons_DEFAULT;
            n_synapses = self.n_subtraction_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                        
            [ ~, ~, Rs_input, Gms, Cms ] = self.unpack_absolute_subtraction_parameters( subtraction_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Ers = self.Er_DEFAULT;
            Rs = [ Rs_input, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative subtraction design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_subtraction_parameters2network_parameters( self, subtraction_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, subtraction_parameters = self.pack_relative_subtraction_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_subtraction_neurons_DEFAULT;
            n_synapses = self.n_subtraction_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                        
            [ ~, ~, Rs, Gms, Cms ] = self.unpack_relative_subtraction_parameters( subtraction_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Ers = self.Er_DEFAULT;
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
                
        % Implement a function to convert subtraction design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = subtraction_parameters2network_parameters( self, subtraction_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert subtraction design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the subtraction parameters have been defined.
                if nargin < 2, subtraction_parameters = self.pack_absolute_subtraction_parameters(  ); end
                
                % Convert absolue subtraction parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_subtraction_parameters2network_parameters( subtraction_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the subtraction parameters have been defined.
                if nargin < 2, subtraction_parameters = self.pack_relative_subtraction_parameters(  ); end
                
                % Convert relative subtraction parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_subtraction_parameters2network_parameters( subtraction_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
    
        
        % ---------- Inversion Design Parameter Conversion Functions ----------

        % Implement a function to convert absolute inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_inversion_parameters2network_parameters( self, inversion_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, inversion_parameters = self.pack_absolute_inversion_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_inversion_neurons_DEFAULT;
            n_synapses = self.n_inversion_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                                    
            [ ~, ~, ~, R1, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_absolute_inversion_parameters( inversion_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_inversion_parameters2network_parameters( self, inversion_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, inversion_parameters = self.pack_relative_inversion_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_inversion_neurons_DEFAULT;
            n_synapses = self.n_inversion_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                        
            [ ~, ~, R1, R2, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_relative_inversion_parameters( inversion_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = inversion_parameters2network_parameters( self, inversion_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert inversion design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the inversion parameters have been defined.
                if nargin < 2, inversion_parameters = self.pack_absolute_inversion_parameters(  ); end
                
                % Convert absolue inversion parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_inversion_parameters2network_parameters( inversion_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the inversion parameters have been defined.
                if nargin < 2, inversion_parameters = self.pack_relative_inversion_parameters(  ); end
                
                % Convert relative inversion parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_inversion_parameters2network_parameters( inversion_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Inversion Design Parameter Conversion Functions ----------
        
        % Implement a function to convert reduced absolute inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_absolute_inversion_parameters2network_parameters( self, inversion_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, inversion_parameters = self.pack_absolute_inversion_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_inversion_neurons_DEFAULT;
            n_synapses = self.n_inversion_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                                    
            [ ~, ~, R1, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_reduced_absolute_inversion_parameters( inversion_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced relative inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_relative_inversion_parameters2network_parameters( self, inversion_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, inversion_parameters = self.pack_relative_inversion_parameters(  ); end
            
            % Define the number of subtraction neurons.
            n_neurons = self.n_inversion_neurons_DEFAULT;
            n_synapses = self.n_inversion_synapses_DEFAULT;
            
            % Unpack the subtraction parameters.                                    
            [ ~, R1, R2, Gm1, Gm2, Cm1, Cm2 ] = self.unpack_reduced_relative_inversion_parameters( inversion_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2 ];
            Gms = [ Gm1, Gm2 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced inversion design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_inversion_parameters2network_parameters( self, inversion_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert inversion design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the inversion parameters have been defined.
                if nargin < 2, inversion_parameters = self.pack_reduced_absolute_inversion_parameters(  ); end
                
                % Convert absolute inversion parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_absolute_inversion_parameters2network_parameters( inversion_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the inversion parameters have been defined.
                if nargin < 2, inversion_parameters = self.pack_relative_inversion_parameters(  ); end
                
                % Convert relative inversion parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_relative_inversion_parameters2network_parameters( inversion_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Division Design Parameter Conversion Functions ----------
        
        % Implement a function to convert absolute division design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_division_parameters2network_parameters( self, division_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, division_parameters = self.pack_absolute_division_parameters(  ); end
            
            % Define the number of division neurons.
            n_neurons = self.n_division_neurons_DEFAULT;
            n_synapses = self.n_division_synapses_DEFAULT;
            
            % Unpack the division parameters.                                                
            [ ~, ~, ~, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = self.unpack_absolute_division_parameters( division_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3 ];
            Gms = [ Gm1, Gm2, Gm3 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative division design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_division_parameters2network_parameters( self, division_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, division_parameters = self.pack_relative_division_parameters(  ); end
            
            % Define the number of division neurons.
            n_neurons = self.n_division_neurons_DEFAULT;
            n_synapses = self.n_division_synapses_DEFAULT;
            
            % Unpack the division parameters.                                    
            [ ~, ~, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = self.unpack_relative_division_parameters( division_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3 ];
            Gms = [ Gm1, Gm2, Gm3 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, R3 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert division design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = division_parameters2network_parameters( self, division_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert division design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the division parameters have been defined.
                if nargin < 2, division_parameters = self.pack_absolute_division_parameters(  ); end
                
                % Convert absolue division parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_division_parameters2network_parameters( division_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the division parameters have been defined.
                if nargin < 2, division_parameters = self.pack_relative_division_parameters(  ); end
                
                % Convert relative division parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_division_parameters2network_parameters( division_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Division Design Parameter Conversion Functions ----------

        % Implement a function to convert reduced absolute division parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_absolute_division_parameters2network_parameters( self, division_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, division_parameters = self.pack_absolute_division_parameters(  ); end
            
            % Define the number of division neurons.
            n_neurons = self.n_division_neurons_DEFAULT;
            n_synapses = self.n_division_synapses_DEFAULT;
            
            % Unpack the division parameters.                                                
            [ ~, ~, R1, R2, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = self.unpack_reduced_absolute_division_parameters( division_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3 ];
            Gms = [ Gm1, Gm2, Gm3 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced relative division parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_relative_division_parameters2network_parameters( self, division_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, division_parameters = self.pack_relative_division_parameters(  ); end
            
            % Define the number of division neurons.
            n_neurons = self.n_division_neurons_DEFAULT;
            n_synapses = self.n_division_synapses_DEFAULT;
            
            % Unpack the division parameters.                                                
            [ ~, R1, R2, R3, Gm1, Gm2, Gm3, Cm1, Cm2, Cm3 ] = self.unpack_reduced_relative_division_parameters( division_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3 ];
            Gms = [ Gm1, Gm2, Gm3 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, R3 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced division parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_division_parameters2network_parameters( self, division_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert division design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the division parameters have been defined.
                if nargin < 2, division_parameters = self.pack_reduced_absolute_division_parameters(  ); end
                
                % Convert absolue division parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_absolute_division_parameters2network_parameters( division_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the division parameters have been defined.
                if nargin < 2, division_parameters = self.pack_reduced_relative_division_parameters(  ); end
                
                % Convert relative division parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_relative_division_parameters2network_parameters( division_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Multiplication Design Parameter Conversion Functions ----------
        
        % Implement a function to convert absolute multiplication design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = absolute_multiplication_parameters2network_parameters( self, multiplication_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, multiplication_parameters = self.pack_absolute_multiplication_parameters(  ); end
            
            % Define the number of multiplication neurons.
            n_neurons = self.n_multiplication_neurons_DEFAULT;
            n_synapses = self.n_multiplication_synapses_DEFAULT;
            
            % Unpack the multiplication parameters.                                                
            [ ~, ~, ~, ~, ~, ~, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = self.unpack_absolute_multiplication_parameters( multiplication_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3, Cm4 ];
            Gms = [ Gm1, Gm2, Gm3, Gm4 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, self.R_DEFAULT, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert relative multiplication design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = relative_multiplication_parameters2network_parameters( self, multiplication_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, multiplication_parameters = self.pack_relative_multiplication_parameters(  ); end
            
            % Define the number of multiplication neurons.
            n_neurons = self.n_multiplication_neurons_DEFAULT;
            n_synapses = self.n_multiplication_synapses_DEFAULT;
            
            % Unpack the multiplication parameters.                                    
            [ ~, ~, ~, ~, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = self.unpack_relative_multiplication_parameters( multiplication_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3, Cm4 ];
            Gms = [ Gm1, Gm2, Gm3, Gm4 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, R3, R4 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        

        % Implement a function to convert multiplication design parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = multiplication_parameters2network_parameters( self, multiplication_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapse_manager = self.synapse_manager; end
            if nargin < 4, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert multiplication design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the multiplication parameters have been defined.
                if nargin < 2, multiplication_parameters = self.pack_absolute_multiplication_parameters(  ); end
                
                % Convert absolue multiplication parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.absolute_multiplication_parameters2network_parameters( multiplication_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the multiplication parameters have been defined.
                if nargin < 2, multiplication_parameters = self.pack_relative_multiplication_parameters(  ); end
                
                % Convert relative multiplication parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.relative_multiplication_parameters2network_parameters( multiplication_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Design Parameter Conversion Functions ----------

        % Implement a function to convert reduced absolute multiplication parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_absolute_multiplication_parameters2network_parameters( self, multiplication_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, multiplication_parameters = self.pack_absolute_multiplication_parameters(  ); end
            
            % Define the number of multiplication neurons.
            n_neurons = self.n_multiplication_neurons_DEFAULT;
            n_synapses = self.n_multiplication_synapses_DEFAULT;
            
            % Unpack the multiplication parameters.                                                
            [ ~, ~, ~, ~, R1, R2, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = self.unpack_reduced_absolute_multiplication_parameters( multiplication_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3, Cm4 ];
            Gms = [ Gm1, Gm2, Gm3, Gm4 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, self.R_DEFAULT, self.R_DEFAULT ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced relative multiplication parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_relative_multiplication_parameters2network_parameters( self, multiplication_parameters, neuron_manager, synapse_manager, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 2, multiplication_parameters = self.pack_relative_multiplication_parameters(  ); end
            
            % Define the number of multiplication neurons.
            n_neurons = self.n_multiplication_neurons_DEFAULT;
            n_synapses = self.n_multiplication_synapses_DEFAULT;
            
            % Unpack the multiplication parameters.                                                            
            [ ~, ~, R1, R2, R3, R4, Gm1, Gm2, Gm3, Gm4, Cm1, Cm2, Cm3, Cm4 ] = self.unpack_reduced_relative_multiplication_parameters( multiplication_parameters );
            
            % Define the neuron properties.
            neuron_IDs = neuron_manager.generate_unique_neuron_IDs( n_neurons, neuron_manager.neurons, neuron_manager.array_utilities );
            [ neuron_names, ~, ~ ] = neuron_manager.generate_names( neuron_IDs, neuron_manager.neurons, false, undetected_option );
            Us = self.U_DEFAULT*ones( 1, n_neurons );
            hs = self.h_DEFAULT*ones( 1, n_neurons );
            Cms = [ Cm1, Cm2, Cm3, Cm4 ];
            Gms = [ Gm1, Gm2, Gm3, Gm4 ];
            Ers = self.Er_DEFAULT;
            Rs = [ R1, R2, R3, R4 ];
            Ams = self.Am_DEFAULT*ones( 1, n_neurons );
            Sms = self.Sm_DEFAULT*ones( 1, n_neurons );
            dEms = self.dEm_DEFAULT*ones( 1, n_neurons );
            Ahs = self.Ah_DEFAULT*ones( 1, n_neurons );
            Shs = self.Sh_DEFAULT*ones( 1, n_neurons );
            dEhs = self.dEh_DEFAULT*ones( 1, n_neurons );
            dEnas = self.dEna_DEFAULT*ones( 1, n_neurons );
            tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons );
            Gnas = self.Gna_DEFAULT*ones( 1, n_neurons );
            Ileaks = self.Ileak_DEFAULT*ones( 1, n_neurons );
            Isyns = self.Isyn_DEFAULT*ones( 1, n_neurons );
            Inas = self.Ina_DEFAULT*ones( 1, n_neurons );
            Itonics = self.Itonic_DEFAULT*ones( 1, n_neurons );
            Ias = self.Iapp_DEFAULT*ones( 1, n_neurons );
            Itotals = self.Itotal_DEFAULT*ones( 1, n_neurons );
            neuron_enabled_flags = self.neuron_enabled_flag_DEFAULT*ones( 1, n_neurons );
            
            % Pack the neuron input parameters.
            neuron_parameters = self.pack_neuron_input_parameters( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, Ileaks, Isyns, Inas, Itonics, Ias, Itotals, neuron_enabled_flags );
            
            % Define the synapse properties.
            synapse_IDs = synapse_manager.generate_unique_synapse_IDs( n_synapses, synapse_manager.synapses, synapse_manager.array_utilities );
            [ synapse_names, ~, ~ ] = synapse_manager.generate_names( synapse_IDs, synapse_manager.synapses, false, undetected_option );
            dEs = self.dEs_DEFAULT*ones( 1, n_synapses );
            gs = self.gs_DEFAULT*ones( 1, n_synapses );
            from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses );
            to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses );
            deltas = self.detla_DEFAULT*ones( 1, n_synapses );
            synapse_enabled_flags = self.synapse_enabled_flag_DEFAULT*ones( 1, n_synapses );
            
            % Pack the synapse input parameters.
            synapse_parameters = self.pack_synapse_input_parameters( synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags );
            
        end
        
        
        % Implement a function to convert reduced multiplication parameters to network parameters.
        function [ neuron_parameters, synapse_parameters ] = reduced_multiplication_parameters2network_parameters( self, multiplication_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option )

            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapse_manager = self.synapse_manager; end
            if nargin < 3, neuron_manager = self.neuron_manager; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            
            % Determine how to convert multiplication design parameters to network parameters.
            if strcmpi( encoding_scheme, 'absolute' )               % If the encoding scheme is 'absolute'...
        
                % Ensure that the multiplication parameters have been defined.
                if nargin < 2, multiplication_parameters = self.pack_reduced_absolute_multiplication_parameters(  ); end
                
                % Convert absolue multiplication parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_absolute_multiplication_parameters2network_parameters( multiplication_parameters, neuron_manager, synapse_manager, undetected_option );
            
            elseif strcmpi( encoding_scheme, 'relative' )            % If the encoding scheme is 'relative'...
                
                % Ensure that the multiplication parameters have been defined.
                if nargin < 2, multiplication_parameters = self.pack_reduced_relative_multiplication_parameters(  ); end
                
                % Convert relative multiplication parameters to network parameters.
                [ neuron_parameters, synapse_parameters ] = self.reduced_relative_multiplication_parameters2network_parameters( multiplication_parameters, neuron_manager, synapse_manager, undetected_option );
                
            else                                                    % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        %% Subnetwork Component Creation Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to create the transmission subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_transmission_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 7, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the transmission neurons and synapses.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_transmission_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_ID_new, synapse_new, synapses, synapse_manager ] = synapse_manager.create_transmission_synapse( neuron_IDs, synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
           
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_ID_new, synapse_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to create the addition subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_addition_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 7, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the addition neurons and synapses.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_addition_neurons( encoding_scheme, n_neurons, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_addition_synapses( n_neurons, neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to create the subtraction subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_subtraction_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 7, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the subtraction neurons and synapses.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_subtraction_neurons( encoding_scheme, n_neurons, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_subtraction_synapses( n_neurons, neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % Implement a function to create the double subtraction subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_double_subtraction_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 8, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the double subtraction neurons.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_double_subtraction_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_double_subtraction_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to create the inversion subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_inversion_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the inversion neurons, synapses, applied currents.      
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_inversion_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_ID_new, synapse_new, synapses, synapse_manager ] = synapse_manager.create_inversion_synapse( neuron_IDs, synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_inversion_applied_current( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_ID_new, synapse_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to create the division subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_division_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 8, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the division neurons. and synapses.           
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_division_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_division_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to create the multiplication subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_multiplication_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the multiplication neurons, synapses, applied currents.
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_multiplication_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_multiplication_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_multiplication_applied_currents( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to create the derivation subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_derivation_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 8, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the derivation neurons and synapses.   
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_derivation_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_derivation_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to create the integration subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_integration_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the integration neurons, synapses, applied_currents.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_integration_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_integration_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_integration_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the voltage based integration subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_vbi_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the voltage based integration neurons, synapses, applied currents.          
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = create_vbi_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_vbi_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_vbi_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the split voltage based integration subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_svbi_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the split voltage based integration neurons, synapses, applied currents.           
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_svbi_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_svbi_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_svbi_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the modulated split voltage based integration subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_msvbi_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the modulated split voltage based integration neurons, synapses, applied currents.
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_msvbi_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_msvbi_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_msvbi_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the modulated split difference voltage based integration subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_mssvbi_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the modulated split difference voltage based integration neurons, synapses, applied currents.
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_mssvbi_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_mssvbi_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_mssvbi_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------
        
        % Implement a function to create the centering subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_centering_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 9, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the centering subnetwork neurons, synapses, applied currents.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_centering_neurons( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );            
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_centering_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_centering_applied_currents( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the double centering subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_double_centering_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 9, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the double centering subnetwork neurons, synapses, and applied currents.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_double_centering_neurons( neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_double_centering_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_double_centering_applied_currents( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the centered double subtraction subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_cds_subnetwork_components( self, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the centered double subtraction subnetwork neurons, synapses, applied currents.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_cds_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_cds_synapses( neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_cds_applied_currents( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );

            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to create the multistate CPG subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_mcpg_subnetwork_components( self, n_neurons, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, n_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the multistate cpg neurons, synapses, and applied currents.
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_mcpg_neurons( n_neurons, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_mcpg_synapses( n_neurons, neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities );
            [ applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager ] = applied_current_manager.create_mcpg_applied_currents( neuron_IDs, applied_current_ID, applied_current_name, target_neuron_ID, ts, Ias, applied_current_enabled_flag, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron, synapse, and applied current output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_ID_new, applied_current_new, applied_currents, applied_current_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron, synapse, and applied current managers.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
        % Implement a function to create the driven multistate CPG subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, self ] = create_dmcpg_subnetwork_components( self, n_neurons, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, n_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Unpack neuron, synapse, applied current input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            [ applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags ] = self.unpack_applied_current_input_parameters( applied_current_input_parameters );
            
            % Create the driven multistate cpg neurons, synapses, applied currents.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_dmcpg_neurons( n_neurons, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_IDs_new, synapses_new, synapses, synapse_manager ] = synapse_manager.create_dmcpg_synapses( n_neurons, neuron_IDs, synapse_IDs, synapse_names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, synapse_enabled_flags, synapse_manager.synapses, true, as_cell_flag, synapse_manager.array_utilities  );
            [ applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager ] = applied_current_manager.create_dmcpg_applied_currents( neuron_IDs, applied_current_IDs, applied_current_names, target_neuron_IDs, ts, Ias, applied_current_enabled_flags, applied_current_manager.applied_currents, true, as_cell_flag, applied_current_manager.array_utilities );
            
            % Pack the neuron, synapse, and applied current output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_IDs_new, synapses_new, synapses, synapse_manager );
            applied_current_output_parameters = self.pack_applied_current_output_parameters( applied_current_IDs_new, applied_currents_new, applied_currents, applied_current_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron, synapse, and applied current managers.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        %{  
%         % Implement a function to create the driven multistate CPG split lead lag subnetwork components.
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork_components( self, num_cpg_neurons )
%             
%             % Set the default input arguments.
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the driven multistate cpg neurons.
%             [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_dmcpg_sll_neurons( num_cpg_neurons );
%             
%             % Create the driven multistate cpg synapses.
%             [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_dmcpg_sll_synapses( neuron_IDs_cell );
%             
%             % Create the driven multistate cpg applied current.
%             [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_dmcpg_sll_applied_currents( neuron_IDs_cell );
%             
%         end
%         
%         
%         % Implement a function to create the driven multistate cpg double centered lead lag subnetwork components.
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
%             
%             % Set the default input arguments.
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the driven multistate cpg double centered lead lag subnetwork neurons.
%             [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_dmcpg_dcll_neurons( num_cpg_neurons );
%             
%             % Create the driven multistate cpg double centered lead lag subnetwork synapses.
%             [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_dmcpg_dcll_synapses( neuron_IDs_cell );
%             
%             % Create the driven multistate cpg double centered lead lag subnetwork applied currents.
%             [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_dmcpg_dcll_applied_currents( neuron_IDs_cell );
%             
%         end
%         
%         
%         % Implement a function to create the open loop driven multistate cpg double centered lead lag error subnetwork components.
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_ol_dmcpg_dclle_subnetwork_components( self, num_cpg_neurons )
%             
%             % Set the default input arguments.
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the open loop driven multistate cpg double centered lead lag error subnetwork neurons.
%             [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_ol_dmcpg_dclle_neurons( num_cpg_neurons );
%             
%             % Create the open loop driven multistate cpg double centered lead lag error subnetwork synapses.
%             [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_ol_dmcpg_dclle_synapses( neuron_IDs_cell );
%             
%             % Create the open loop driven multistate cpg double centered lead lag error subnetwork applied currents.
%             [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_ol_dmcpg_dclle_applied_currents( neuron_IDs_cell );
%             
%         end
%         
%         
%         % Implement a function to create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork components.
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_clpc_dmcpg_dcll_subnetwork_components( self, num_cpg_neurons )
%             
%             % Set the default input arguments.
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork neurons.
%             [ neuron_manager, neuron_IDs_cell ] = neuron_manager.create_clpc_dmcpg_dcll_neurons( num_cpg_neurons );
%             
%             % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork synapses.
%             [ synapse_manager, synapse_IDs_cell ] = synapse_manager.create_clpc_dmcpg_dcll_synapses( neuron_IDs_cell );
%             
%             % Create the closed loop P controlled driven multistate cpg double centered lead lag subnetwork applied currents.
%             [ applied_current_manager, applied_current_IDs_cell ] = applied_current_manager.create_clpc_dmcpg_dcll_applied_currents( neuron_IDs_cell );
%             
%         end
        %}
        
        %{
        % Implement a function to create the modulation subnetwork components.
        function [ neuron_output_parameters, synapse_output_parameters, self ] = create_modulation_subnetwork_components( self, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, set_flag, as_cell_flag )
            
            % Set the default input arguments.
            if nargin < 7, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 2, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            
            % Unpack neuron and synapse input parameters.
            [ neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags ] = self.unpack_neuron_input_parameters( neuron_input_parameters );
            [ synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag ] = self.unpack_synapse_input_parameters( synapse_input_parameters );
            
            % Create the modulation neurons and synapses.            
            [ neuron_IDs_new, neurons_new, neurons, neuron_manager ] = neuron_manager.create_modulation_neurons( encoding_scheme, neuron_IDs, neuron_names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, neuron_enabled_flags, neuron_manager.neurons, true, as_cell_flag, neuron_manager.array_utilities );
            [ synapse_ID_new, synapse_new, synapses, synapse_manager ] = synapse_manager.create_modulation_synapse( neuron_IDs, synapse_ID, synapse_name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, synapse_enabled_flag, synapse_manager.synapses, true, as_cell_flag, array_utilities );
            
            % Pack the neuron and synapse output parameters.
            neuron_output_parameters = self.pack_neuron_output_parameters( neuron_IDs_new, neurons_new, neurons, neuron_manager );
            synapse_output_parameters = self.pack_synapse_output_parameters( synapse_ID_new, synapse_new, synapses, synapse_manager );
            
            % Determine whether to update the network object.
            if set_flag                                                     % If we want to update the network object...
                
                % Update the neuron and synapse manager.
                self.neuron_manager = neuron_manager;
                self.synapse_manager = synapse_manager;
                
            end
            
        end
        %}
        
        
        %% Subnetwork Creation Functions.
        
        % ---------- Transmission Subnetwork Functions ----------

        % Implement a function to create a transmission subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_transmission_subnetwork( self, transmission_parameters, encoding_scheme, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                           	% [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                    	% [str] Undetected Option.
            if nargin < 9, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 8, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                % [T/F] As Cell Flag.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 6, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 2, transmission_parameters = self.pack_transmission_parameters( encoding_scheme ); end        	% [-] Transmission Gain.

            % Create an instance of the network object.
            network = self;
            
          	% Convert the transmission parameters to network parameters.
            [ neuron_input_parameters, synapse_input_parameters ] = self.transmission_parameters2network_parameters( transmission_parameters, encoding_scheme, neuron_manager, synapse_manager, undetected_option );
            
            % Create the transmission subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_transmission_subnetwork_components( neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design a transmission subnetwork.            
            [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_transmission_subnetwork( neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
       
        % Implement a function to create an addition subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_addition_subnetwork( self, k, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 4, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 2, k = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create addition subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_addition_subnetwork_components( neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design the addition subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_addition_subnetwork( neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
                
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to create a subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_subtraction_subnetwork( self, k, parameters, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 11, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 5, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = self.subtraction_parameters_DEFAULT; end
            if nargin < 2, k = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the subtraction subnetwork components.
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_subtraction_subnetwork_components( neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };

            % Design the subtraction subnetwork.
            [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_subtraction_subnetwork( self, neuron_IDs, k, parameters, encoding_scheme, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a double subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_double_subtraction_subnetwork( self, k, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 8, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 7, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 4, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 2, k = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the double subtraction subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_double_subtraction_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design the double subtraction subnetwork.            
            [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_double_subtraction_subnetwork( neuron_IDs, k, encoding_scheme, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to create an inversion subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_inversion_subnetwork( self, parameters, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 15, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 14, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 13, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 12, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 8, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 5, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 4, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 2, parameters = self.inversion_parameters_DEFAULT; end
            
            % Create an instance of the network object.
            network = self;
            
            % Create inversion subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_inversion_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the inversion subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_inversion_subnetwork( neuron_IDs, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to create a division subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_division_subnetwork( self, k, c, parameters, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 15, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 14, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 13, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 12, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 6, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, parameters = self.division_parameters_DEFAULT; end
            if nargin < 3, c = [  ]; end
            if nargin < 2, k = self.c_division_DEFAULT; end                                                             % [-] Division Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create division subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_division_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design the division subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_division_subnetwork( neuron_IDs, k, c, parameters, encoding_scheme, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to create a multiplication subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_multiplication_subnetwork( self, k, parameters, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 11, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 6, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 5, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, parameters = self.inversion_parameters_DEFAULT; end
            if nargin < 2, k = self.c_multiplication_DEFAULT; end                                                       % [-] Multiplication Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the multiplication subnetwork components.
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_multiplication_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the multiplication subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_multiplication_subnetwork( neuron_IDs, k, parameters, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------
        
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to create a derivation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_derivation_subnetwork( self, k, w, safety_factor, encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 15, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 14, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 13, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 12, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 6, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 3, w = self.w_derivation_DEFAULT; end
            if nargin < 2, k = self.c_derivation_DEFAULT; end                                                           % [-] Derivation Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the derivation subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_derivation_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design the derivation subnetwork.            
            [ Gnas, Gms, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_derivation_subnetwork( neuron_IDs, k, w, safety_factor, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to create an integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_integration_subnetwork( self, ki_mean, ki_range, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 6, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 5, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 2, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the integration subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_integration_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the integration subnetwork.            
            [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_integration_subnetwork( neuron_IDs, ki_mean, ki_range, neuron_manager, synapse_manager, applied_current_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network, self ] = create_vbi_subnetwork( self, T, n, ki_mean, ki_range, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, set_flag, as_cell_flag, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 12, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 8, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 7, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the voltage based integration subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_vbi_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the voltage based integration subnetwork.            
            [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_vbi_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, true, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_svbi_subnetwork( self, T, n, ki_mean, ki_range, k_subtraction, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 19, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 18, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 17, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 16, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 15, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 14, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 13, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 9, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 8, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 7, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 6, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the split voltage based integration subnetwork specific components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_svbi_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the split voltage based integration subnetwork.            
            [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_svbi_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a modulated split voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_msvbi_subnetwork( self, T, n, ki_mean, ki_range, k_subtraction, c_modulation, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 20, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 19, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 18, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 17, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 16, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 15, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 14, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 13, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 12, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 11, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 10, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 9, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 8, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 7, c_modulation = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 6, k_subtraction = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the modulated split voltage based integration subnetwork specific components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_msvbi_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the modulated split voltage based integration subnetwork.            
            [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_msvbi_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a modulated split difference voltage based integration subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_mssvbi_subnetwork( self, T, n, ki_mean, ki_range, k_subtraction1, k_subtraction2, c_modulation, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 21, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 20, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 19, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 18, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 17, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 16, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 15, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 14, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 13, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 12, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 11, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 10, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 9, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 8, c_modulation = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            if nargin < 7, k_subtraction2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 6, k_subtraction1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 5, ki_range = self.c_integration_range_DEFAULT; end
            if nargin < 4, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the modulated split difference voltage based integration subnetwork specific components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_mssvbi_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the modulated split difference voltage based integration subnetwork.            
            [ Gnas, Cms, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_mssvbi_subnetwork( neuron_IDs, T, n, ki_mean, ki_range, k_subtraction1, k_subtraction2, c_modulation, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Centering Subnetwork Functions ----------
        
        % Implement a function to create a centering subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_centering_subnetwork( self, k_addition, k_subtraction, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 11, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 6, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 5, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 2, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the centering subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_centering_subnetwork_components( neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };

            % Design the centering subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_centering_subnetwork( neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a double centering subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_double_centering_subnetwork( self, k_addition, k_subtraction, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 16, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 15, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 14, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 11, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 6, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 5, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 3, k_subtraction = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 2, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the double centering subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_double_centering_subnetwork_components( neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the double centering subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_double_centering_subnetwork( neuron_IDs, k_addition, k_subtraction, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a centered double subtraction subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_cds_subnetwork( self, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 17, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 16, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 15, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 12, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 11, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 7, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 6, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Must be either: 'absolute' or 'relative'.)
            if nargin < 4, k_addition = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            if nargin < 3, k_subtraction2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 2, k_subtraction1 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the centered double subtraction subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_cds_subnetwork_components( encoding_scheme, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the centered double subtraction subnetwork.            
            [ Gnas, Gms, Cms, Rs, dEs, gs, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_cds_subnetwork( neuron_IDs, k_subtraction1, k_subtraction2, k_addition, encoding_scheme, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to create a multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_mcpg_subnetwork( self, n_neurons, dt, tf, delta_oscillatory, delta_bistable, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 18, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 17, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 16, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 15, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 14, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 13, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 12, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 8, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 7, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 6, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 5, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 4, tf = self.tf_DEFAULT; end
            if nargin < 3, dt = self.dt_DEFAULT; end
            if nargin < 2, n_neurons = self.num_cpg_neurons_DEFAULT; end
            
            % Create an instance of the network object.
            network = self;
            
            % Create the multistate cpg subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_mcpg_subnetwork_components( n_neurons, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the multistate cpg subnetwork.
            [ Gnas, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_mcpg_subnetwork( neuron_IDs, dt, tf, delta_oscillatory, delta_bistable, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to create a driven multistate CPG oscillator subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, dEs, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, self ] = create_dmcpg_subnetwork( self, n_neurons, dt, tf, delta_oscillatory, delta_bistable, Id_max, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 19, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 18, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 17, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 16, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 15, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 14, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 13, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, applied_current_input_parameters = self.pack_applied_current_input_parameters(  ); end
            if nargin < 9, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 8, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 7, Id_max = self.Id_max_DEFAULT; end
            if nargin < 6, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 5, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
            if nargin < 4, tf = self.tf_DEFAULT; end
            if nargin < 3, dt = self.dt_DEFAULT; end
            if nargin < 2, n_neurons = 2; end
            
            % Create an instance of the network object.
            network = self;
            
            % Create the driven multistate cpg subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, applied_current_output_parameters, network ] = network.create_dmcpg_subnetwork_components( n_neurons, neuron_input_parameters, synapse_input_parameters, applied_current_input_parameters, neuron_manager, synapse_manager, applied_current_manager, true, as_cell_flag );
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            applied_current_manager = applied_current_output_parameters{ 4 };
            
            % Design the driven multistate cpg subnetwork.            
            [ Gnas, dEs, gs, ts, Ias, neurons, synapses, applied_currents, neuron_manager, synapse_manager, applied_current_manager, network ] = network.design_dmcpg_subnetwork( neuron_IDs, dt, tf, delta_oscillatory, delta_bistable, Id_max, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        %{
%         % Implement a function to create a driven multistate cpg split lead lag subnetwork ( generating neurons, synapses, etc. as necessary ).
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_sll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r )
%             
%             % Set the default input arguments.
%             if nargin < 12, r = self.r_oscillation_DEFAULT; end
%             if nargin < 11, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the driven multistate cpg subnetwork components.
%             [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_dmcpg_sll_subnetwork_components( num_cpg_neurons );
%             
%             % Design the driven multistate cpg subnetwork.
%             self = self.design_dmcpg_sll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, c_mod, r );
%             
%         end
%         
%         
%         % Implement a function to create a driven multistate cpg double centered lead lag subnetwork ( generating neurons, synapses, etc. as necessary ).
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_dmcpg_dcll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r )
%             
%             % Set the default input arguments.
%             if nargin < 14, r = self.r_oscillation_DEFAULT; end
%             if nargin < 13, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 12, k_add = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the driven multistate cpg double centered lead lag subnetwork components.
%             [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_dmcpg_dcll_subnetwork_components( num_cpg_neurons );
%             
%             % Design the driven multistate cpg double centered lead lag  subnetwork.
%             self = self.design_dmcpg_dcll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_add, c_mod, r );
%             
%         end
%         
%         
%         % Implement a function to create an open loop driven multistate cpg double centered lead lag error subnetwork ( generating neurons, synapses, etc. as necessary ).
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_ol_dmcpg_dclle_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r )
%             
%             % Set the default input arguments.
%             if nargin < 17, r = self.r_oscillation_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the open loop driven multistate cpg double centered lead lag error subnetwork components.
%             [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_ol_dmcpg_dclle_subnetwork_components( num_cpg_neurons );
%             
%             % Design the open loop driven multistate cpg double centered lead lag error subnetwork.
%             self = self.design_ol_dmcpg_dclle_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r );
%             
%         end
%         
%         
%         % Implement a function to create the closed loop P controlled double centered dmcpg lead lag subnetwork.
%         function [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = create_clpc_dmcpg_dcll_subnetwork( self, num_cpg_neurons, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain )
%             
%             % Set the default input arguments.
%             if nargin < 18, kp_gain = self.kp_gain_DEFAULT; end
%             if nargin < 17, r = self.r_oscillation_DEFAULT; end
%             if nargin < 16, c_mod = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
%             if nargin < 15, k_add2 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 14, k_add1 = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
%             if nargin < 13, k_sub5 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 12, k_sub4 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 11, k_sub3 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 10, k_sub2 = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 9, k_sub1 = 2*self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
%             if nargin < 8, ki_range = self.c_integration_range_DEFAULT; end
%             if nargin < 7, ki_mean = self.c_integration_mean_DEFAULT; end                                               % [-] Mean Integration Subnetwork Gain.
%             if nargin < 6, T = self.T_oscillation_DEFAULT; end
%             if nargin < 5, Id_max = self.Id_max_DEFAULT; end
%             if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
%             if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAUT; end
%             if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end
%             
%             % Create the closed loop P controlled double centered dmcpg lead lag subnetwork components.
%             [ self, neuron_IDs_cell, synapse_IDs_cell, applied_current_IDs_cell ] = self.create_clpc_dmcpg_dcll_subnetwork_components( num_cpg_neurons );
%             
%             % Design the closed loop P controlled double centered dmcpg lead lag subnetwork.
%             self = self.design_clpc_dmcpg_dcll_subnetwork( neuron_IDs_cell, delta_oscillatory, delta_bistable, Id_max, T, ki_mean, ki_range, k_sub1, k_sub2, k_sub3, k_sub4, k_sub5, k_add1, k_add2, c_mod, r, kp_gain );
%             
%         end
        %}
        
        %{
        % Implement a function to create a modulation subnetwork ( generating neurons, synapses, etc. as necessary ).
        function [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, self ] = create_modulation_subnetwork( self, c, neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, filter_disabled_flag, set_flag, as_cell_flag, process_option, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 9, as_cell_flag = self.as_cell_flag_DEFAULT; end
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, synapse_input_parameters = self.pack_synapse_input_parameters(  ); end
            if nargin < 3, neuron_input_parameters = self.pack_neuron_input_parameters(  ); end
            if nargin < 2, c = self.c_modulation_DEFAULT; end                                                           % [-] Modulation Gain.
            
            % Create an instance of the network object.
            network = self;
            
            % Create the modulation subnetwork components.            
            [ neuron_output_parameters, synapse_output_parameters, network ] = network.create_modulation_subnetwork_components( neuron_input_parameters, synapse_input_parameters, neuron_manager, synapse_manager, true, as_cell_flag );           
            
            % Unpack the neuron, synapse, and applied current properties.
            neuron_IDs = neuron_output_parameters{ 1 };
            neuron_manager = neuron_output_parameters{ 4 };
            synapse_manager = synapse_output_parameters{ 4 };
            
            % Design a modulation subnetwork.            
            [ Gnas, Cms, dEs, gs, neurons, synapses, neuron_manager, synapse_manager, network ] = network.design_modulation_subnetwork( neuron_IDs, c, neuron_manager, synapse_manager, network.applied_current_manager, filter_disabled_flag, true, process_option, undetected_option, network_utilities );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        %}
        
        
        %% Network Validation Functions
        
        % Implement a function to validate the network is setup correctly to simulate.
        function valid_flag = validate_network( self, neuron_manager, synapse_manager, applied_current_manager )
            
            % Set the default input arguments.
            if nargin < 4, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 3, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 2, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            
            % Ensure that the neuron IDs are unique.
            [ valid_flag, ~ ] = neuron_manager.unique_existing_neuron_IDs( neuron_manager.neurons );
            
            % Throw an error if the neuron IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Neuron IDs must be unique.' ), end
            
            % Ensure that the synapse IDs are unique.
            [ valid_flag, ~ ] = synapse_manager.unique_existing_synapse_IDs( synapses );
            
            % Throw an error if the synapse IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Synapse IDs must be unique.' ), end
            
            % Ensure that the applied current IDs are unique.            
            [ valid_flag, ~ ] = applied_current_manager.unique_existing_applied_current_IDs( applied_current_manager.applied_currents );
            
            % Throw an error if the synapse IDs were not unique.
            if ~valid_flag, error( 'Invalid network.  Applied current IDs must be unique.' ), end
            
            % Ensure that only one synapse connects each pair of neurons.
            valid_flag = synapse_manager.one_to_one_synapses( synapse_manager.synapses, synapse_manager.array_utilities );
            
            % Throw an error if there are multiple synapses per pair of neurons.
            if ~valid_flag, error( 'Invalid network.  There must be only one synapse per pair of neurons.' ), end
            
            % Ensure that only one applied current applies to each neuron.
            valid_flag = applied_current_manager.one_to_one_applied_currents( applied_currents, array_utilities );
            
            % Throw an error if there are multiple applied currents per neuron.
            if ~valid_flag, error( 'Invalid network.  There must be only one applied current per neuron.' ), end
            
        end
        
        
        %% Network Linearization Functions
        
        % Implement a function to compute the linearized system matrix for this neural network about a given operating point.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function A = compute_linearized_system_matrix( self, Cms, Gms, Rs, gs, dEs, Us0, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if anrgin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, Us0 = zeros( length( Cm2 ), 1 ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end

            % Compute the linearized system matrix.
            A = network_utilities.compute_linearized_system_matrix( Cms, Gms, Rs, gs, dEs, Us0 );
            
        end
        
        
        % Implement a function to compute the linearized input matrix for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function B = compute_linearized_input_matrix( self, Cms, Ias, neuron_manager, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the linearized input matrix.
            B = network_utilitities.compute_linearized_input_matrix( Cms, Ias );
            
        end
        
        
        % Implement a function to compute the linearized system for this neural network.  (This method is only valid for neural networks WITHOUT sodium channels.)
        function [ A, B ] = get_linearized_system( self, Cms, Gms, Rs, gs, dEs, Ias, Us0, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, Us0 = zeros( neuron_manager.num_neurons, 1 ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end

            % Compute the linearized system.
            [ A, B ] = network_utilities.get_linearized_system( Cms, Gms, Rs, gs, dEs, Ias, Us0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at a specific operating point.
        function [ A, dt, condition_number ] = RK4_stability_analysis_at_point( self, Cms, Gms, Rs, gs, dEs, Us0, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, dt0 = self.dt_DEFAULT; end
            if nargin < 7, Us0 = zeros( neuron_manager.num_neurons, 1 ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the maximum RK4 step size and condition number.            
            [ A, dt, condition_number ] = network_utilities.RK4_stability_analysis_at_point( Cms, Gms, Rs, gs, dEs, Us0, dt0 );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis at multiple operating points.
        function [ As, dts, condition_numbers ] = RK4_stability_analysis( self, Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, dt0 = self.dt_DEFAULT; end
            if nargin < 7, Us = zeros( 1, neuron_manager.num_neurons ); end
            if nargin < 6, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 4, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            
            % Retrieve the number of operating points.
            num_points = size( Us, 1 );
            
            % Retrieve the number of neurons.
            num_neurons = size( Us, 2 );
            
            % Preallocate an array to store the condition numbers.
            condition_numbers = zeros( num_points, 1 );
            
            % Preallocate an array to store the maximum step sizes.
            dts = zeros( num_points, 1 );
            
            % Preallocate an array to store the linearized system matrices.
            As = zeros( [ num_neurons, num_neurons, num_points ] );
            
            % Perform RK4 stability analysis at each of the operating points.
            for k = 1:num_points                    % Iterate through each of the operating points...

                % Perform RK4 stability analysis at this operating point.
                [ As( :, :, k ), dts( k ), condition_numbers( k ) ] = self.RK4_stability_analysis_at_point( Cms, Gms, Rs, gs, dEs, Us( k, : ) , dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
                
            end
            
        end
            
        
        % Implement a function to perform RK4 stability analysis on a transmission subnetwork.
        function [ U2s, As, dts, condition_numbers ] = achieved_transmission_RK4_stability_analysis( self, U1s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, applied_current_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, dt0 = self.dt_DEFAULT; end
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved transmission steady state output at each of the provided inputs.
            U2s = self.compute_achieved_transmission_sso( U1s, Rs( 1 ), Gms( 2 ), Ias( 2 ), gs( 2, 1 ), dEs( 2, 1 ), neuron_manager, synapse_manager, applied_current_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );  
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on an addition subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_addition_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, dt0 = self.dt_DEFAULT; end
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved addition steady state output at each of the provided inputs.
            U3s = self.compute_achieved_addition_sso( [ U1s, U2s ], Rs, Gms, Ias, gs, dEs, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a subtraction subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_subtraction_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, dt0 = self.dt_DEFAULT; end
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved subtraction steady state output at each of the provided inputs.
            U3s = self.compute_achieved_subtraction_sso( [ U1s, U2s ], Rs, Gms, Ias, gs, dEs, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on an inversion subnetwork.
        function [ U2s, As, dts, condition_numbers ] = achieved_inversion_RK4_stability_analysis( self, U1s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, dt0 = self.dt_DEFAULT; end
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved inversion steady state output at each of the provided inputs.
            U2s = self.compute_achieved_inversion_sso( U1s, Rs( 1 ), Gms( 2 ), Ias( 2 ), gs( 2, 1 ), dEs( 2, 1 ), neuron_manager, synapse_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );  
            
        end
        
            
        % Implement a function to perform RK4 stability analysis on a division subnetwork.
        function [ U3s, As, dts, condition_numbers ] = achieved_division_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, dt0 = self.dt_DEFAULT; end
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved division steady state output at each of the provided inputs.
            U3s = self.compute_achieved_division_sso( [ U1s, U2s ], Rs( 1 ), Rs( 2 ), Gms( 3 ), Ias( 3 ), gs( 3, 1 ), gs( 3, 2 ), dEs( 3, 1 ), dEs( 3, 2 ), neuron_manager, synapse_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a multiplication subnetwork.
        function [ U4s, U3s, As, dts, condition_numbers ] = achieved_multiplication_RK4_stability_analysis( self, U1s, U2s, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
           
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, dt0 = self.dt_DEFAULT; end
            if nargin < 9, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 8, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, U2s = linspace( 0, Rs( 2 ), 20 ); end
            if nargin < 2, U1s = linspace( 0, Rs( 1 ), 20 ); end
            
            % Compute the achieved multiplication steady state output at each of the provided inputs.
            [ U4s, U3s ] = self.compute_achieved_multiplication_sso( [ U1s, U2s ], Rs( 1 ), Rs( 2 ), Rs( 3 ), Gms( 3 ), Gms( 4 ), Ias( 3 ), Ias( 4 ), gs( 3, 2 ), gs( 4, 1 ), gs( 4, 3 ), dEs( 3, 2 ), dEs( 4, 1 ), dEs( 4, 3 ), neuron_manager, synapse_manager, undetected_option, network_utilities );
            
            % Create the operating points array.
            Us = [ U1s, U2s, U3s, U4s ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
        end
        
        
        % Implement a function to perform RK4 stability analysis on a linear combination subnetwork.
        function [ Us_outputs, As, dts, condition_numbers ] = achieved_linear_combination_RK4_stability_analysis( self, Us_inputs, Cms, Gms, Rs, Ias, gs, dEs, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 10, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 9, dt0 = self.dt_DEFAULT; end
            if nargin < 8, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 7, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Cms = neuron_manager.get_neuron_property( 'all', 'Cm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = zeros( 1, length( Rs ) - 1 ); end
            
            % Compute the achieved division steady state output at each of the provided inputs.            
            Us_outputs = self.compute_achieved_linear_combination_sso( Us_inputs', Rs', Gms', Ias', gs( end, 1:( end - 1 ) )', dEs( end , 1:( end - 1 ) )', neuron_manager, synapse_manager, undetected_option, network_utilities )';
            
            % Create the operating points array.
            Us = [ Us_inputs, Us_outputs ];
            
            % Compute the RK4 stability metrics.
            [ As, dts, condition_numbers ] = self.RK4_stability_analysis( Cms, Gms, Rs, gs, dEs, Us, dt0, neuron_manager, synapse_manager, undetected_option, network_utilities );
            
        end
        
        
        %% Steady State Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute transmission subnetwork.
        function U2s = compute_da_transmission_sso( self, U1s, c, neuron_manager, undetected_option, network_utilities )
 
            % Set the default input arguments.
            if nargin < 6, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, c = self.c_transmission_DEFAULT; end                                                         % [-] Transmission Gain.
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            U2s = network_utilities.compute_da_transmission_sso( U1s, c );
        
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative transmission subnetwork.
        function U2s = compute_dr_transmission_sso( self, U1s, c, R1, R2, neuron_manager, undetected_option, network_utilities )
 
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, c = self.c_transmission_DEFAULT; end                                                         % [-] Transmission Gain.
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            U2s = network_utilities.compute_dr_transmission_sso( U1s, c, R1, R2 );
        
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a transmission subnetwork.
        function U2s = compute_achieved_transmission_sso( self, U1s, R1, Gm2, Ia2, gs21, dEs21, neuron_manager, synapse_manager, applied_current_manager, undetected_option, network_utilities )
        
%             synapse_ID = synapse_manager.from_to_neuron_ID2synapse_ID( 1, 2, synapse_manager.synapses, undetected_option );
%             applied_current_ID = applied_current_manager.to_neuron_ID2applied_current_ID( 2, applied_current_manager.applied_currents, undetected_option );
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 10, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, dEs21 = synapse_manager.get_synapse_property( synapse_manager.from_to_neuron_ID2synapse_ID( 1, 2, synapse_manager.synapses, undetected_option ), 'dEs', true, synapse_manager.synapses, undetected_option ); end                                    % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = synapse_manager.get_synapse_property( synapse_manager.from_to_neuron_ID2synapse_ID( 1, 2, synapse_manager.synapses, undetected_option ), 'gs', true, synapse_manager.synapses, undetected_option ); end                                      % [S] Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = applied_current_manager.get_applied_current_property( applied_current_manager.to_neuron_ID2applied_current_ID( 2, applied_current_manager.applied_currents, undetected_option ), 'Ias', true, applied_current_manager.applied_currents, undetected_option ); end                                       % [A] Applied Current (Neuron 2).
            if nargin < 4, Gm2 = neuron_manager.get_neuron_property( 2, 'Gm', true, neuron_manager.neurons, undetected_option ); end                                        % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                     	% [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            U2s = network_utilities.compute_achieved_transmission_sso( U1s, R1, Gm2, Ia2, gs21, dEs21 );
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute addition subnetwork.
        function Us_outputs = compute_da_addition_sso( self, Us_inputs, c, neuron_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 6, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 4, neuron_manager = self.neuron_manaqer; end
            if nargin < 3, c = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_da_addition_sso( Us_inputs, c );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative addition subnetwork.
        function Us_outputs = compute_dr_addition_sso( self, Us_inputs, Rs, c, neuron_manager, undetected_option, network_utilities )
           
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, neuron_manager = self.neuron_manaqer; end
            if nargin < 4, c = self.c_addition_DEFAULT; end                                                             % [-] Addition Gain.
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_dr_addition_sso( Us_inputs, Rs, c );
        
        end
            
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an addition subnetwork.
        function Us_outputs = compute_achieved_addition_sso( self, Us_inputs, Rs, Gms, Ias, gs, dEs, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_achieved_addition_sso( Us_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute subtraction subnetwork.
        function Us_outputs = compute_da_subtraction_sso( self, Us_inputs, c, ss, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, ss = self.subtraction_signature_DEFAULT; end         % [ 1, -1 ]
            if nargin < 3, c = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_da_subtraction_sso( Us_inputs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative subtraction subnetwork.
        function Us_outputs = compute_dr_subtraction_sso( self, Us_inputs, Rs, c, ss, neuron_manager, undetected_option, network_utilities )
           
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, ss = self.subtraction_signature_DEFAULT; end
            if nargin < 4, c = self.c_subtraction_DEFAULT; end                                                          % [-] Subtraction Gain.
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_dr_subtraction_sso( Us_inputs, Rs, c, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a subtraction subnetwork.
        function Us_outputs = compute_achieved_subtraction_sso( self, Us_inputs, Rs, Gms, Ias, gs, dEs, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, dEs = self.get_dEs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 6, gs = self.get_gs( 'all', neuron_manager, synapse_manager ); end
            if nargin < 5, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state network outputs.
            Us_outputs = network_utilities.compute_achieved_subtraction_sso( Us_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute inversion subnetwork.
        function U2s = compute_da_inversion_sso( self, U1s, c1, c2, c3, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, c3 = self.c3_da_inversion_DEFAULT; end                          % [A] Design Constant 3. 20e-9
            if nargin < 4, c2 = self.c2_da_inversion_DEFAULT; end                          % [S] Design Constant 2. 19e-6
            if nargin < 3, c1 = self.c1_da_inversion_DEFAULT; end                          % [W] Design Constant 1. 0.40e-9
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U2s = network_utilities.compute_da_inversion_sso( U1s, c1, c2, c3 );
            
        end
        
                
        % Implement a function to compute the steady state output associated with the desired formulation of a relative inversion subnetwork.
        function U2s = compute_dr_inversion_sso( self, U1s, c1, c2, c3, R1, R2, neuron_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = self.c3_dr_inversion_DEFAULT; end                                                                                               % [-] Design Constant 3. 1e-6
            if nargin < 4, c2 = self.c2_dr_inversion_DEFAULT; end                                                                                              % [-] Design Constant 2. 19e-6
            if nargin < 3, c1 = self.c1_dr_inversion_DEFAULT; end                                                                                               % [-] Design Constant 1. 1e-6
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U2s = network_utilities.compute_dr_inversion_sso( U1s, c1, c2, c3, R1, R2 );             % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of an inversion subnetwork.
        function U2s = compute_achieved_inversion_sso( self, U1s, R1, Gm2, Ia2, gs21, dEs21, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, dEs21 = self.get_dEs( [ 1, 2 ], neuron_manager, synapse_manager ); end                                                                     % [V] Synaptic Reversal Potential (Synapse 21).
            if nargin < 6, gs21 = self.get_gs( [ 1, 2 ], neuron_manager, synapse_manager ); end                                                                    % [S] Maximum Synaptic Conductance (Synapse 21).
            if nargin < 5, Ia2 = neuron_manager.get_neuron_property( 2, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end                               % [A] Applied Currents (Neuron 2).
            if nargin < 4, Gm2 = neuron_manager.get_neuron_property( 2, 'Gm', true, neuron_manager.neurons, undetected_option ); end                                    % [S] Membrane Conductance (Neuron 2).
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U2s = network_utilities.compute_achieved_inversion_sso( U1s, R1, Gm2, Ia2, gs21, dEs21 );              % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute inversion subnetwork.
        function U2s = compute_dra_inversion_sso( self, U1s, c1, c2, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, c2 = self.c2_ra_inversion_DEFAULT; end                       % [mV] Design Constant 2.
            if nargin < 3, c1 = self.c1_ra_inversion_DEFAULT; end                        % [mV^2] Design Constant 1.
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U2s = network_utilities.compute_dra_inversion_sso( U1s, c1, c2 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative inversion subnetwork.
        function U2s = compute_drr_inversion_sso( self, U1s, c1, c2, R1, R2, neuron_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 9, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maxmimum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = self.c2_rr_inversion_DEFAULT; end                                                                                            % [-] Design Constant 2. 52.6e-3
            if nargin < 3, c1 = self.c1_rr_inversion_DEFAULT; end                                                                                            % [-] Design Constant 1. 52.6e-3
            if nargin < 2, U1s = neuron_manager.get_neuron_property( 1, 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U2s = network_utilities.compute_drr_inversion_sso( U1s, c1, c2, R1, R2 );         % [V] Membrane Voltage (Neuron 2).
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_da_division_sso( self, Us_inputs, c1, c2, c3, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, c3 = self.c3_da_division_DEFAULT; end                                                                                            % [W] Design Constant 3. 0.40e-9
            if nargin < 4, c2 = self.c2_da_division_DEFAULT; end                                                                                             % [A] Design Constant 2. 380e-9
            if nargin < 3, c1 = self.c1_da_division_DEFAULT; end                                                                                            % [W] Design Constant 1. 0.40e-9
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U3s = network_utilities.compute_da_division_sso( Us_inputs, c1, c2, c3 );                 % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative division subnetwork.
        function U3s = compute_dr_division_sso( self, Us_inputs, c1, c2, c3, R1, R2, R3, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 7, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 6, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 5, c3 = self.c3_dr_division_DEFAULT; end                                                                                                   % [S] Design Constant 3. 1e-6
            if nargin < 4, c2 = self.c2_dr_division_DEFAULT; end                                                                                                  % [S] Design Constant 2. 19e-6
            if nargin < 3, c1 = self.c1_dr_division_DEFAULT; end                                                                                                   % [S] Design Constant 1. 1e-6
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U3s = network_utilities.compute_dr_division_sso( Us_inputs, c1, c2, c3, R1, R2, R3 );         % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a division subnetwork.
        function U3s = compute_achieved_division_sso( self, Us_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32, neuron_manager, synapse_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 14, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 12, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, dEs32 = self.get_dEs( [ 2, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [V] Synaptic Reversal Potential (Synapse 32).
            if nargin < 9, dEs31 = self.get_dEs( [ 1, 3 ], neuron_manager, synapse_manager ); end                                                                                     % [V] Synaptic Revesal Potential (Synapse 31).
            if nargin < 8, gs32 = self.get_gs( [ 2, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [S] Synaptic Conductance (Synapse 32).
            if nargin < 7, gs31 = self.get_gs( [ 1, 3 ], neuron_manager, synapse_manager ); end                                                                                    % [S] Synaptic Conductance (Synapse 31).
            if nargin < 6, Ia3 = neuron_manager.get_neuron_property( 3, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end                                               % [A] Applied Current (Neuron 3).
            if nargin < 5, Gm3 = neuron_manager.get_neuron_property( 3, 'Gm', true, neuron_manager.neurons, undetected_option ); end                                                    % [S] Membrane Conductance (Neuron 3).
            if nargin < 4, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                                      % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                                      % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U3s = network_utilities.compute_achieved_division_sso( Us_inputs, R1, R2, Gm3, Ia3, gs31, gs32, dEs31, dEs32 );         % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute division subnetwork.
        function U3s = compute_dra_division_sso( self, Us_inputs, c1, c2, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, c2 = c2_dra_division_DEFAULT; end                                                                                            % [V] Design Constant 2. 1.05e-3
            if nargin < 3, c1 = self.c1_dra_division_DEFAULT; end                                                                                            % [V] Design Constant 1. 1.05e-3
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U3s = network_utilities.compute_dra_division_sso( Us_inputs, c1, c2 );           	% [V] Membrane Voltage (Neuron 3).
            
        end
                
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced relative division subnetwork.
        function U3s = compute_drr_division_sso( self, Us_inputs, c1, c2, R1, R2, R3, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 10, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 3).
            if nargin < 6, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 2).
            if nargin < 5, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end                                          % [V] Maximum Membrane Voltage (Neuron 1).
            if nargin < 4, c2 = self.c2_drr_division_DEFAULT; end                                                                                                 % [-] Design Constant 2. 0.0526
            if nargin < 3, c1 = self.c1_drr_division_DEFAULT; end                                                                                                 % [-] Design Constant 1. 0.0526
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            U3s = network_utilities.compute_drr_division_sso( Us_inputs, c1, c2, R1, R2, R3 );     % [V] Membrane Voltage (Neuron 3).
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_da_multiplication_sso( self, Us_inputs, c1, c2, c3, c4, c5, c6, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 8, c6 = self.c6_da_multiplication_DEFAULT; end        % 0.40e-9
            if nargin < 7, c5 = self.c5_da_multiplication_DEFAULT; end         % 380e-9
            if nargin < 6, c4 = self.c4_da_multiplication_DEFAULT; end        % 0.40e-9
            if nargin < 5, c3 = self.c3_da_multiplication_DEFAULT; end          % 20e-9
            if nargin < 4, c2 = self.c2_da_multiplication_DEFAULT; end          % 19e-6
            if nargin < 3, c1 = self.c1_da_multiplication_DEFAULT; end        % 0.40e-9
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_da_multiplication_sso( Us_inputs, c1, c2, c3, c4, c5, c6 );
            
        end
        
            
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_dr_multiplication_sso( self, Us_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 15, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 14, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 13, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 12, R4 = neuron_manager.get_neuron_property( 4, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 11, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 10, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 9, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, c6 = self.c6_dr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 7, c5 = self.c5_dr_multiplication_DEFAULT; end          % 19e-6
            if nargin < 6, c4 = self.c4_dr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 5, c3 = self.c3_dr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 4, c2 = self.c2_dr_multiplication_DEFAULT; end          % 19e-6
            if nargin < 3, c1 = self.c1_dr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_dr_multiplication_sso( Us_inputs, c1, c2, c3, c4, c5, c6, R1, R2, R3, R4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a multiplication subnetwork.
        function [ U4s, U3s ] = compute_achieved_multiplication_sso( self, Us_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            % Set the default input arguments.
            if nargin < 19, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 18, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 17, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 16, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 15, dEs43 = self.get_dEs( [ 3, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 14, dEs41 = self.get_dEs( [ 1, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 13, dEs32 = self.get_dEs( [ 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 12, gs43 = self.get_gs( [ 3, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 11, gs41 = self.get_gs( [ 1, 4 ], neuron_manager, synapse_manager ); end
            if nargin < 10, gs32 = self.get_gs( [ 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 9, Ia4 = neuron_manager.get_neuron_property( 4, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, Ia3 = neuron_manager.get_neuron_property( 3, 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 7, Gm4 = neuron_manager.get_neuron_property( 4, 'G', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, Gm3 = neuron_manager.get_neuron_property( 3, 'G', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 5, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_achieved_multiplication_sso( Us_inputs, R1, R2, R3, Gm3, Gm4, Ia3, Ia4, gs32, gs41, gs43, dEs32, dEs41, dEs43 );
            
        end
           
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of a reduced absolute multiplication subnetwork.
        function [ U4s, U3s ] = compute_dra_multiplication_sso( self, Us_inputs, c1, c2, c3, c4, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 9, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 7, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 6, c4 = self.c4_dra_multiplication_DEFAULT; end                      	% [V] Reduced Absolute Multiplication Design Constant 4 (Reduced Absolute Division Design Constant 2). 1.05e-3
            if nargin < 5, c3 = self.c3_dra_multiplication_DEFAULT; end                       	% [V] Reduced Absolute Multiplication Design Constant 3 (Reduced Absolute Division Design Constant 1). 1.05e-3
            if nargin < 4, c2 = self.c2_dra_multiplication_DEFAULT; end                       % [mV] Reduced Absolute Multiplication Design Constant 2 (Reduced Absolute Inversion Design Constant 2). 21.05e-6
            if nargin < 3, c1 = self.c1_dra_multiplication_DEFAULT; end                        % [mV^2] Reduced Absolute Multiplication Design Constant 1 (Reduced Absolute Inversion Design Constant 1). 1.05e-3
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_dra_multiplication_sso( Us_inputs, c1, c2, c3, c4 );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative multiplication subnetwork.
        function [ U4s, U3s ] = compute_drr_multiplication_sso( self, Us_inputs, c1, c2, c3, c4, R1, R2, R3, R4, neuron_manager, undetected_option, network_utilities )
            
            % Set the default input arguments.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 10, R4 = neuron_manager.get_neuron_property( 4, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 9, R3 = neuron_manager.get_neuron_property( 3, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 8, R2 = neuron_manager.get_neuron_property( 2, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 7, R1 = neuron_manager.get_neuron_property( 1, 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 6, c4 = self.c4_drr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 5, c3 = self.c3_drr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 4, c2 = self.c2_drr_multiplication_DEFAULT; end          % 19e-6
            if nargin < 3, c1 = self.c1_drr_multiplication_DEFAULT; end           % 1e-6
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( [ 1, 2 ], 'U', true, neuron_manager.neurons, undetected_option ); end

            % Compute the steady state output.
            [ U4s, U3s ] = network_utilities.compute_drr_multiplication_sso( Us_inputs, c1, c2, c3, c4, R1, R2, R3, R4 );
            
        end
        
        
        % ---------- Linear Combination Subnetwork Functions ----------
        
        % Implement a function to compute the steady state output associated with the desired formulation of an absolute linear combination subnetwork.
        function Us_output = compute_da_linear_combination_sso( self, Us_inputs, cs, ss, neuron_manager, undetected_option, network_utilities )
        
            %{
            Input(s):
                Us_inputs    =   [V] Membrane Voltage Inputs.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output  	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 7, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, ss = self.signature_linear_combination_DEFAULT; end             	% [ 1; -1 ]
            if nargin < 3, cs = self.c_linear_combination_DEFAULT; end                     	% [ 1; 1 ]
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_output = network_utilities.compute_da_linear_combination_sso( Us_inputs, cs, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the desired formulation of a relative linear combination subnetwork.
        function Us_output = compute_dr_linear_combination_sso( self, Us_inputs, Rs, cs, ss, neuron_manager, undetected_option, network_utilities )
        
            %{
            Input(s):
                Us_inputs    =   [V] Membrane Voltage Inputs.
                Rs          =   [V] Maximum Membrane Voltages.
                cs          =   [-] Input Gains.
                ss          =   [-1/1] Input Signatures.
            
            Output(s):
                Us_output 	=   [V] Membrane Voltage Outputs.
            %}
            
            % Set the default input arguments.
            if nargin < 8, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 6, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 5, ss = self.signature_linear_combination_DEFAULT; end
            if nargin < 4, cs = self.c_linear_combination_DEFAULT; end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the steady state network outputs.
            Us_output = network_utilities.compute_dr_linear_combination_sso( Us_inputs, Rs, cs, ss );
            
        end
        
        
        % Implement a function to compute the steady state output associated with the achieved formulation of a linear combination subnetwork.
        function Us_output = compute_achieved_linear_combination_sso( self, Us_inputs, Rs, Gms, Ias, gs, dEs, neuron_manager, synapse_manager, undetected_option, network_utilities )
        
            %{
            Input(s):
                Us_inputs = [V] Membrane Voltage Inputs (# of timesteps x # of inputs).
                Rs = [V] Maximum Membrane Voltage (# of inputs).
                Gms = [S] Membrane Conductances (# of inputs).
                Ias = [S] Applied Currents (# of neurons).
                gs = [S] Synaptic Conductances (# of synapses).
                dEs = [V] Synaptic Reversal Potentials (# of synapses).
            
            Output(s):
                Us_output = [V] Membrane Voltage Outputs (# of timesteps).
            %}
 
            % Set the default input arguments.
            if nargin < 11, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 8, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 7, dEs = self.get_dEs( [ 1, 3; 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 6, gs = self.get_gs( [ 1, 3; 2, 3 ], neuron_manager, synapse_manager ); end
            if nargin < 5, Ias = neuron_manager.get_neuron_property( 'all', 'I_tonic', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 4, Gms = neuron_manager.get_neuron_property( 'all', 'Gm', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 3, Rs = neuron_manager.get_neuron_property( 'all', 'R', true, neuron_manager.neurons, undetected_option ); end
            if nargin < 2, Us_inputs = neuron_manager.get_neuron_property( 1:( neuron_manager.num_neurons - 1 ), 'U', true, neuron_manager.neurons, undetected_option ); end
            
            % Compute the membrane voltage outputs.
            Us_output = network_utilities.compute_achieved_linear_combination_sso( Us_inputs, Rs, Gms, Ias, gs, dEs );
            
        end
        

        %% Simulation Functions
        
        % Implement a function to compute a single network simulation step.
        function [ Us, hs, Gs, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs, neurons, synapses, neuron_manager, synapse_manager, self ] = compute_simulation_step( self, dt, tf, neuron_manager, synapse_manager, applied_current_manager, filter_disabled_flag, set_flag, process_option, undetected_option, numerical_method_utilities, network_utilities )
            
            % Set the default input arguments.
            if nargin < 12, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 11, numerical_method_utilities = self.numerical_method_utilities; end
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 9, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 7, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 6, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 5, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 4, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 3, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 2, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % Ensure that the network is constructed properly.
            error( self.validate_network( neuron_manager, synapse_manager, applied_current_manager ), 'Invalid network detected.' )

            % Retrieve the IDs associated with the enabled neurons.
            neuron_IDs = neuron_manager.get_enabled_neuron_IDs( neuron_manager.neurons );
                        
            % Retrieve basic neuron properties.
            Us = neuron_manager.get_neuron_property( neuron_IDs, 'U', true, neuron_manager.neurons, undetected_option );
            hs = neuron_manager.get_neuron_property( neuron_IDs, 'h', true, neuron_manager.neurons, undetected_option );
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option );
            Cms = neuron_manager.get_neuron_property( neuron_IDs, 'Cm', true, neuron_manager.neurons, undetected_option );
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ neuron_manager.num_neurons, 1 ] );
            I_tonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve sodium channel neuron properties.
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option );
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option );
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option );
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option );
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option );
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option );
            tauh_maxs = neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max', true, neuron_manager.neurons, undetected_option );
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option );
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option );
            
            % Retrieve synaptic properties.
            gs = self.get_gs( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Retrieve applied currents.            
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs, dt, tf, applied_currents, filter_disabled_flag, process_option, undetected_option ); Ias = Ias';
            
            % Perform a single simulation step.
            [ dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_totals, m_infs, h_infs, tauhs ] = network_utilities.simulation_step( Us, hs, Gms, Cms, Rs, gs, dEs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, Ias );
            
            % Compute the membrane voltages at the next time step.
            Us = numerical_method_utilities.forward_euler_step( Us, dUs, dt );
            
            % Compute the sodium channel deactivation parameters at the next time step.
            hs = numerical_method_utilities.forward_euler_step( hs, dhs, dt );
            
            % Create an instance of the network class.
            network = self;
            
            % Set the neuron properties.
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, Us, 'U', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, hs, 'h', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_leaks, 'I_leak', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_syns, 'I_syn', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_nas, 'I_na', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_totals, 'I_total', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, m_infs, 'm_inf', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, h_infs, 'h_inf', neuron_manager.neurons, true );
            [ neurons, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, tauhs, 'tauh', neuron_manager.neurons, true );
                        
            % Update the network's neuron manager.
            network.neuron_manager = neuron_manager;
            
            % Set the synapse properties.            
            [ synapses, synapse_manager, network ] = self.set_Gs( Gs, neuron_IDs, neuron_manager, synapse_manager, true, undetected_option );
            
            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
        
        % Implement a function to compute network simulation results.
        function [ ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neurons, synapses, neuron_manager, synapse_manager, self ] = compute_simulation( self, dt, tf, method, neuron_manager, synapse_manager, applied_current_manager, applied_voltage_manager, filter_disabled_flag, set_flag, process_option, undetected_option, network_utilities )
            
            % Set the default simulation duration.
            if nargin < 13, network_utilities = self.network_utilities; end                                              % [class] Network Utilities Class.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option.
            if nargin < 11, process_option = self.process_option_DEFAULT; end                                            % [str] Process Option.
            if nargin < 10, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 9, filter_disabled_flag = self.filter_disabled_flag_DEFAULT; end                                % [T/F] Filter Disabled Flag.
            if nargin < 8, applied_voltage_manager = self.applied_voltage_manager; end
            if nargin < 7, applied_current_manager = self.applied_current_manager; end                                  % [class] Applied Current Manager Class.
            if nargin < 6, synapse_manager = self.synapse_manager; end                                                  % [class] Synapse Manager Class.
            if nargin < 5, neuron_manager = self.neuron_manager; end                                                    % [class] Neuron Manager Class.
            if nargin < 4, method = 'RK4'; end
            if nargin < 3, tf = self.tf; end                                                                            % [s] Simulation Duration.
            if nargin < 2, dt = self.dt; end                                                                            % [s] Simulation Time Step.
            
            % Ensure that the network is constructed properly.
            error( self.validate_network( neuron_manager, synapse_manager, applied_current_manager ), 'Invalid network detected.' )
            
            % Retrieve the IDs associated with the enabled neurons.
            neuron_IDs = neuron_manager.get_enabled_neuron_IDs( neuron_manager.neurons );
            
            % Retrieve the neuron properties.
            Us = neuron_manager.get_neuron_property( neuron_IDs, 'U', true, neuron_manager.neurons, undetected_option )';
            hs = neuron_manager.get_neuron_property( neuron_IDs, 'h', true, neuron_manager.neurons, undetected_option )';
            Gms = neuron_manager.get_neuron_property( neuron_IDs, 'Gm', true, neuron_manager.neurons, undetected_option )';
            Cms = neuron_manager.get_neuron_property( neuron_IDs, 'Cm', true, neuron_manager.neurons, undetected_option )';
            Rs = neuron_manager.get_neuron_property( neuron_IDs, 'R', true, neuron_manager.neurons, undetected_option )'; Rs = repmat( Rs', [ length( Rs ), 1 ] );
            Ams = neuron_manager.get_neuron_property( neuron_IDs, 'Am', true, neuron_manager.neurons, undetected_option )';
            Sms = neuron_manager.get_neuron_property( neuron_IDs, 'Sm', true, neuron_manager.neurons, undetected_option )';
            dEms = neuron_manager.get_neuron_property( neuron_IDs, 'dEm', true, neuron_manager.neurons, undetected_option )';
            Ahs = neuron_manager.get_neuron_property( neuron_IDs, 'Ah', true, neuron_manager.neurons, undetected_option )';
            Shs = neuron_manager.get_neuron_property( neuron_IDs, 'Sh', true, neuron_manager.neurons, undetected_option )';
            dEhs = neuron_manager.get_neuron_property( neuron_IDs, 'dEh', true, neuron_manager.neurons, undetected_option )';
            tauh_maxs = neuron_manager.get_neuron_property( neuron_IDs, 'tauh_max', true, neuron_manager.neurons, undetected_option )';
            Gnas = neuron_manager.get_neuron_property( neuron_IDs, 'Gna', true, neuron_manager.neurons, undetected_option )';
            dEnas = neuron_manager.get_neuron_property( neuron_IDs, 'dEna', true, neuron_manager.neurons, undetected_option )';
            I_tonics = neuron_manager.get_neuron_property( neuron_IDs, 'I_tonic', true, neuron_manager.neurons, undetected_option )';

            % Retrieve the synapse properties.
            gs = self.get_gs( neuron_IDs, neuron_manager, synapse_manager );
            dEs = self.get_dEs( neuron_IDs, neuron_manager, synapse_manager );
            
            % Retrieve the applied currents.
            [ ~, Ias ] = applied_current_manager.to_neuron_IDs2Ias( neuron_IDs, dt, tf, applied_currents, filter_disabled_flag, process_option, undetected_option ); Ias = Ias';

            % Retrieve the applied voltages.            
            [ ~, Vas ] = applied_voltage_manager.to_neuron_IDs2Vas( neuron_IDs, dt, tf, applied_voltages, filter_disabled_flag, undetected_option ); Vas = Vas';
            
            % Simulate the network.
            [ ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs ] = network_utilities.simulate( Us, hs, Gms, Cms, Rs, gs, dEs, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, I_tonics, Ias, Vas, tf, dt, method );
            
            % Create an instance of the network class.
            network = self;
            
            % Set the neuron properties.
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, Us( :, end ), 'U', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, hs( :, end ), 'h', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_leaks( :, end ), 'I_leak', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_syns( :, end ), 'I_syn', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_nas( :, end ), 'I_na', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, I_totals( :, end ), 'I_total', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, m_infs( :, end ), 'm_inf', neuron_manager.neurons, true );
            [ ~, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, h_infs( :, end ), 'h_inf', neuron_manager.neurons, true );
            [ neurons, neuron_manager ] = neuron_manager.set_neuron_property( neuron_IDs, tauhs( :, end ), 'tauh', neuron_manager.neurons, true );
            
            % Update the network's neuron manager.
            network.neuron_manager = neuron_manager;
            
            % Set the synapse properties.
            [ synapses, synapse_manager, network ] = self.set_Gs( Gs( :, :, end ), neuron_IDs, neuron_manager, synapse_manager, true, undetected_option );

            % Determine whether to update the network object.
            if set_flag, self = network; end
            
        end
        
      %{  
%         % Implement a function to compute simulation results for given applied currents.
%         function [ self, ts, Us_flat, hs_flat, dUs_flat, dhs_flat, Gsyns_flat, Ileaks_flat, Isyns_flat, Inas_flat, Iapps_flat, Itotals_flat, minfs_flat, hinfs_flat, tauhs_flat, neuron_IDs ] = simulate_flat( self, applied_current_IDs, applied_currents_flat, dt, tf, method )
%                        
%             % Retrieve the number of neurons.
%             num_neurons = neuron_manager.num_neurons;
% 
%             % Retrieve size information.
%             num_applied_currents = size( applied_currents_flat, 1 );
%             num_input_neurons = size( applied_currents_flat, 2 );
%             
%             % Compute the number of simulation timesteps.
%             num_timesteps = tf/dt + 1;
%             
%             % Create a matrix to store the membrane voltages.
%             Us_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             hs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             dUs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             dhs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             Gsyns_flat = zeros( num_applied_currents, num_neurons, num_neurons, num_timesteps );
%             Ileaks_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             Isyns_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             Inas_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             Iapps_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             Itotals_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             minfs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             hinfs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
%             tauhs_flat = zeros( num_applied_currents, num_neurons, num_timesteps );
% 
%             % Simulate the network for each of the applied current combinations.
%             for k1 = 1:num_applied_currents                      % Iterate through each of the applied currents...
%                 
%                 % Create applied currents.
%                 for k2 = 1:num_input_neurons                    % Iterate through each of the input neurons...
%                     
%                     % Set the applied current for this input neuron.
%                     applied_current_manager = applied_current_manager.set_applied_current_property( applied_current_IDs( k2 ), applied_currents_flat( k1, k2 ), 'I_apps' );
%                     
%                 end
%                 
%                 % Simulate the network.
%                 [ self, ts, Us, hs, dUs, dhs, Gs, I_leaks, I_syns, I_nas, I_apps, I_totals, m_infs, h_infs, tauhs, neuron_IDs ] = self.compute_set_simulation( dt, tf, method );
%                 
%                 % Retrieve the final membrane voltages.
%                 Us_flat( k1, :, : ) = Us;
%                 hs_flat( k1, :, : ) = hs;
%                 dUs_flat( k1, :, : ) = dUs;
%                 dhs_flat( k1, :, : ) = dhs;
%                 Gsyns_flat( k1, :, :, : ) = Gs;
%                 Ileaks_flat( k1, :, : ) = I_leaks;
%                 Isyns_flat( k1, :, : ) = I_syns;
%                 Inas_flat( k1, :, : ) = I_nas;
%                 Iapps_flat( k1, :, : ) = I_apps;
%                 Itotals_flat( k1, :, : ) = I_totals;
%                 minfs_flat( k1, :, : ) = m_infs;
%                 hinfs_flat( k1, :, : ) = h_infs;
%                 tauhs_flat( k1, :, : ) = tauhs;
% 
%             end
%             
%         end
        %}
        
        %% Save & Load Functions.
        
        % Implement a function to save network data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = self.file_name_DEFAULT; end
            if nargin < 2, directory = self.save_directory_DEFAULT; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, 'self' )
            
        end
        
        
        % Implement a function to load network data as a matlab object.
        function [ data, self ] = load( self, directory, file_name, set_flag )
            
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag.
            if nargin < 3, file_name = self.file_name_DEFAULT; end
            if nargin < 2, directory = self.load_directory_DEFAULT; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            if set_flag, self = data; end   
            
        end
        
        
        % Implement a function to load network data from a xlsx file.
        function [ neuron_manager, synapse_manager, applied_current_manager, self ] = load_xlsx( self, directory, file_name_neuron, file_name_synapse, file_name_applied_current, append_flag, verbose_flag, set_flag )
            
            % Set the default input arguments.
            if nargin < 7, verbose_flag = true; end
            if nargin < 6, append_flag = false; end
            if nargin < 5, file_name_applied_current = 'Applied_Current_Data.xlsx'; end
            if nargin < 4, file_name_synapse = 'Synapse_Data.xlsx'; end
            if nargin < 3, file_name_neuron = 'Neuron_Data.xlsx'; end
            if nargin < 2, directory = '.'; end
            
            % Create an instance of the neuron manager class.
            neuron_manager = neuron_manager_class(  );
            
            % Load the neuron data.
            neuron_manager = neuron_manager.load_xlsx( file_name_neuron, directory, append_flag, verbose_flag );
            
            % Create an instance of the synapse manager class.
            synapse_manager = synapse_manager_class(  );
            
            % Load the synpase data.
            synapse_manager = synapse_manager.load_xlsx( file_name_synapse, directory, append_flag, verbose_flag );
            
            % Create an instance of the applied current manager class.
            applied_current_manager = applied_current_manager_class(  );
            
            % Load the applied current data.
            applied_current_manager = applied_current_manager.load_xlsx( file_name_applied_current, directory, append_flag, verbose_flag );
            
            % Determine whether to update the network object.
            if set_flag                 % If we want to update the network object...
                
                % Update the neuron manager.
                self.neuron_manager = neuron_manager;
                
                % Update the synapse manager.
                self.synapse_manager = synapse_manager;
                
                % Update the applied current manager.
                self.applied_current_manager = applied_current_manager;
                
            end
            
        end
        
        
    end
end

