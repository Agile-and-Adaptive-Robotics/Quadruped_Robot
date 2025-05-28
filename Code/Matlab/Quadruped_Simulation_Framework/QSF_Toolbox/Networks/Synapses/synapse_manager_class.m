classdef synapse_manager_class
    
    % This class contains properties and methods related to managing synapses.
    
    %% SYNAPSE MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        synapses                                            % [class] Synapse Array.
        num_synapses                                        % [#] Number of Synapses.
        
        array_utilities                                     % [class] Array Utilities.
        data_loader_utilities                               % [class] Data Loader Utilities.
        synapse_utilities                                   % [class] Synapse Utilities.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % ---------- Neuron Properties ----------
        
        % Define the neuron params.
        R_DEFAULT = 20e-3;                                 	% [V] Activation Domain.
        Gm_DEFAULT = 1e-6;                              	% [S] Membrane Conductance.
        
        
        % ---------- Synapse Properties ----------
        
        % Define the synapse properties.
        ID_DEFAULT = 0;                                  	% [#] Synapse ID.
        name_DEFAULT = '';                                 	% [-] Synapse Name.
        dEs_DEFAULT = 194e-3;                             	% [V] Synaptic Reversal Potential.
        gs_DEFAULT = 1e-6;                                  % [S] Maximum Synaptic Conductance.
        Gs_DEFAULT = 0;                                     % [S] Synaptic Conductance.
        from_neuron_ID_DEFAULT = -1;                       	% [#] From Neuron ID.
        to_neuron_ID_DEFAULT = -1;                         	% [#] To Neuron ID.
        delta_DEFAULT = 1e-6;                               % [-] Subnetwork Output Offset.
        enabled_flag_DEFAULT = true;                      	% [T/F] Synapse Enabled Flag.
                
        % Define the synaptic reversal potential params.
        dEs_maximum_DEFAULT = 194e-3;                      	% [V] Maximum Synaptic Reversal Potential.
        dEs_minimum_DEFAULT = -40e-3;                      	% [V] Minimum Synaptic Reversal Potential.
        dEs_small_negative_DEFAULT = -1e-3;             	% [V] Small Negative Synaptic Reversal Potential.
        
        
        % ---------- Transmission Properties ----------
        
        % Define the number of transmission neurons & synapses.
        n_transmission_neurons_DEFAULT = 2;                 % [#] Number of Transmission Neurons.
        n_transmission_synapses_DEFAULT = 1;            	% [#] Number of Transmission Synapses.

        % Define the gain properties.
        c_absolute_transmission_DEFAULT = 1.0;              % [-] Absolute Transmission Gain.
        c_relative_transmission_DEFAULT = 1.0;              % [-] Relative Transmission Gain.
        
        % Define the applied current magnitudes.
        Ian_absolute_transmission_DEFAULT = 0;          	% [A] Absolute Transmission Applied Current.
        Ian_relative_transmission_DEFAULT = 0;             	% [A] Relative Transmission Applied Current.
        
        % ---------- Addition Properties ----------
           
        % Define the number of neurons & synapses.
        n_addition_neurons_DEFAULT = 3;                 	% [#] Number of Addition Neurons.
        n_addition_synapses_DEFAULT = 2;                    % [#] Number of Addition Synapses.

        % Define the gain properties.
        c_absolute_addition_DEFAULT = 1;                   	% [-] Absolute Addition Subnetwork Gain.
        c_relative_addition_DEFAULT = 1;                   	% [-] Relative Addition Subnetwork Gain.
                
        % Define the applied current magnitudes.
        Ian_absolute_addition_DEFAULT = 0;                	% [A] Absolute Addition Applied Current.
        Ian_relative_addition_DEFAULT = 0;                 	% [A] Relative Addition Applied Current.
        
        
        % ---------- Subtraction Properties ----------

        % Define the number of neurons.
        n_subtraction_neurons_DEFAULT = 3;              	% [#] Number of Subtraction Neurons.
        n_double_subtraction_neurons_DEFAULT = 4;       	% [#] Number of Double Subtraction Neurons.
        
        % Define the number of synapses.
        n_subtraction_synapses_DEFAULT = 2;                 % [#] Number of Subtraction Synapses.
        n_double_subtraction_synapses_DEFAULT = 4;       	% [#] Number of Double Subtraction Synapses.

        % Define the gain properties.
        c_absolute_subtraction_DEFAULT = 1;             	% [-] Absolute Subtraction Subnetwork Gain.
        c_relative_subtraction_DEFAULT = 1;              	% [-] Relative Subtraction Subnetwork Gain.
                    
        % Define the applied current magnitude.
        Ian_absolute_subtraction_DEFAULT = 0;             	% [A] Absolute Subtraction Applied Current.
        Ian_relative_subtraction_DEFAULT = 0;             	% [A] Relative Subtraction Applied Current.
        
        
        % ---------- Inversion Properties ----------
        
        % Define the number of neurons & synapses.
        n_inversion_neurons_DEFAULT = 2;                	% [#] Number of Inversion Neurons.
        n_inversion_synapses_DEFAULT = 1;                	% [#] Number of Inversion Synapses.
        
        % Define the gain properties.
        c_absolute_inversion_DEFAULT = 1;                	% [-] Absolute Inversion Subnetwork Gain.
        c_relative_inversion_DEFAULT = 1;                 	% [-] Relative Inversion Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia2_absolute_inversion_DEFAULT = 20e-9;          	% [A] Absolute Inversion Applied Current 2.
        Ia2_relative_inversion_DEFAULT = 20e-9;            	% [A] Relative Inversion Applied Current 2.
        
        
        % ---------- Reduced Inversion Properties ----------

        % Define the number of neurons.
        n_reduced_inversion_neurons_DEFAULT = 2;        	% [#] Number of Inversion Neurons.        
        n_reduced_inversion_synapses_DEFAULT = 1;       	% [#] Number of Inversion Synapses.
        
        % Define the gain properties.
        c_reduced_absolute_inversion_DEFAULT = 1;         	% [-] Absolute Inversion Subnetwork Gain.
        c_reduced_relative_inversion_DEFAULT = 1;          	% [-] Relative Inversion Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia2_reduced_absolute_inversion_DEFAULT = 20e-9;   	% [A] Absolute Inversion Applied Current 2.
        Ia2_reduced_relative_inversion_DEFAULT = 20e-9;    	% [A] Relative Inversion Applied Current 2.
        
        
        % ---------- Division Properties ----------

        % Define the number of neurons & synapses.
        n_division_neurons_DEFAULT = 3;                     % [#] Number of Division Neurons.
        n_division_synapses_DEFAULT = 2;                    % [#] Number of Division Synapses.
        
        % Define the gain properties.
        c_absolute_division_DEFAULT = 1;                  	% [-] Absolute Division Subnetwork Gain.
        c_relative_division_DEFAULT = 1;                  	% [-] Relative Division Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia3_absolute_division_DEFAULT = 0;                	% [A] Absolute Division Applied Current.
        Ia3_relative_division_DEFAULT = 0;                 	% [A] Relative Division Applied Current.
        
        
        % ---------- Reduced Division Properties ----------

        % Define the number of neurons & synapses.
        n_reduced_division_neurons_DEFAULT = 3;             % [#] Number of Reduced Division Neurons. 
        n_reduced_division_synapses_DEFAULT = 2;         	% [#] Number of Reduced Division Synapses.
        
        % Define the gain properties.
        c_reduced_absolute_division_DEFAULT = 1;           	% [-] Reduced Absolute Division Subnetwork Gain.
        c_reduced_relative_division_DEFAULT = 1;           	% [-] Reduced Relative Division Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia3_reduced_absolute_division_DEFAULT = 0;         	% [A] Reduced Absolute Division Applied Current.
        Ia3_reduced_relative_division_DEFAULT = 0;        	% [A] Reduced Relative Division Applied Current.
        
        
        % ---------- Division After Inversion Properties ----------

        % Define the number of neurons & synapses.
        n_dai_neurons_DEFAULT = 3;                          % [#] Number of Division Neurons.
        n_dai_synapses_DEFAULT = 2;                         % [#] Number of Division Synapses.
        
        % Define the gain properties.
        c_absolute_dai_DEFAULT = 1;                         % [-] Absolute Division Subnetwork Gain.
        c_relative_dai_DEFAULT = 1;                         % [-] Relative Division Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia3_absolute_dai_DEFAULT = 0;                       % [A] Absolute Division Applied Current.
        Ia3_relative_dai_DEFAULT = 0;                       % [A] Relative Division Applied Current.
        
                        
        % ---------- Reduced Division After Inversion Properties ----------

        % Define the number of neurons & synapses.
        n_reduced_dai_neurons_DEFAULT = 3;                  % [#] Number of Division Neurons.
        n_reduced_dai_synapses_DEFAULT = 2;                 % [#] Number of Division Synapses.
        
        % Define the gain properties.
        c_reduced_absolute_dai_DEFAULT = 1;                	% [-] Absolute Division Subnetwork Gain.
        c_reduced_relative_dai_DEFAULT = 1;               	% [-] Relative Division Subnetwork Gain.
        
        % Define the applied current magnitudes.
        Ia3_reduced_absolute_dai_DEFAULT = 0;            	% [A] Absolute Division Applied Current.
        Ia3_reduced_relative_dai_DEFAULT = 0;              	% [A] Relative Division Applied Current.
        
        
        % ---------- Centering Properties ----------
      
        % Define the number of neurons.
        n_centering_neurons_DEFAULT = 4;                    % [#] Number of Centering Neurons.
        n_double_centering_neurons_DEFAULT = 7;             % [#] Number of Double Centering Neurions.
        n_ds2dc_neurons_DEFAULT = 11;                       % [#] Number of Double Subtraction to Double Centering Neurons.

        % Define the number of synapses.
        n_centering_synapses_DEFAULT = 4;               	% [#] Number of Centering Synapses.
        n_double_centering_synapses_DEFAULT = 8;        	% [#] Number of Double Centering Synapses.
        n_ds2dc_synapses_DEFAULT = 2;                       % [#] Number of Double Subtraction to Double Centering Synapses.

        
        % ---------- Multiplication Properties ----------

        % Define the number of neurons & synapses.
        n_multiplication_neurons_DEFAULT = 4;               % [#] Number of Multiplication Neurons.
        n_multiplication_synapses_DEFAULT = 3;          	% [#] Number of Multiplication Synapses.

        
        % ---------- Derivation Properties ----------

        % Define the number of synapses.
        n_derivation_synapses_DEFAULT = 2;              	% [#] Number of Derivation Synapses.

        
        % ---------- Integration Properties ----------

        % Define the number of synapses.
        n_integration_synapses_DEFAULT = 2;             	% [#] Number of Integration Synapses.
        n_vbi_synapses_DEFAULT = 4;                     	% [#] Number of Voltage Based Integration Synapses.
        n_svbi_synapses =  10;                          	% [#] Number of Split Voltage Based Integration Synapses.
        n_msvbi_synapses = 6;                               % [#] Number of Modulated Split Voltage Based Integration Synapses.
        n_mssvbi_synapses = 2;                           	% [#] Number fo Modulated Split Difference Voltage Based Integration Synapses.
        
        
        % ---------- Central Pattern Generator Properties ----------

        % Define the central pattern generator offsets.
        delta_bistable_DEFAULT = -10e-3;                  	% [V] Bistable CPG Equilibrium Offset.
        delta_oscillatory_DEFAULT = 0.01e-3;              	% [V] Oscillatory CPG Equilibrium Offset.
        delta_noncpg_DEFAULT = 0;                         	% [V] Generic CPG Equilibrium Offset.
        
        % Define the applied current magnitudes.
        Id_max_DEFAULT = 1.25e-9;                         	% [A] Maximum Drive Current.

                
        % ---------- Design Properties ----------
                
        % Define the default undetected option.
        undetected_option_DEFAULT = 'error';                % [str] Undetect ID Handling Option: Determines Desired Behavior When Current ID is not Detected.
        
        % Define the default set flag parameter.
        set_flag_DEFAULT = true;                            % [T/F] Set Flag: Determines Whether Computed Values Should be used to Updated Class Properties.
        
    end
    
    
    %% SYNAPSE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_manager_class( synapses, synapse_utilities, data_loader_utilities, array_utilities )
            
            % Set the default class properties.
            if nargin < 4, array_utilities = array_utilities_class(  ); end                         % [class] Array Utilities.
            if nargin < 3, data_loader_utilities = data_loader_utilities_class(  ); end             % [class] Data Loader Utilities.
            if nargin < 2, synapse_utilities = synapse_utilities_class(  ); end                     % [class] Synapse Utilities.
            if nargin < 1, synapses = [  ]; end                                                     % [class] Synapse Array.
            
            % Store utilities class properties.
            self.array_utilities = array_utilities;
            self.data_loader_utilities = data_loader_utilities;
            self.synapse_utilities = synapse_utilities;
            
            % Store the synapse property.
            self.synapses = synapses;                                               
            
            % Compute the number of synapses.
            self.num_synapses = length( synapses );                                                 % [#] Number of Synapses.
            
        end
        
        
        %% Synapse Name Functions.
            
        % Implement a function to generate names for synapses.
        function [ names, synapses, self ] = generate_names( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = self.get_all_synapse_IDs( synapses ); end
            
            % Determine how to generate the synapse names.
            if isempty( synapses )                      	% If there are no existing synapses...

                % Convert the synapse IDs to synapse names.
                names = self.synapse_utilities.IDs2names( synapse_IDs );
                
            else                                            % If there are existing neurons...

                % Determine the number of synapses.
                n_synapses = length( synapses );

                % Preallocate a cell to store the synapse names.
                names = cell( 1, n_synapses );

                % Generate names for each of the synapses.
                for k = 1:n_synapses                         % Iterate through each of the synapses...

                    % Retrieve the index associated with this synapse.
                    synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );

                   % Generate a name for this synapse.
                   [ names{ k }, synapses( synapse_index ) ] = synapses( synapse_index ).generate_name( synapse_IDs( k ), true );

                end

                % Determine whether to update the synapse manager object.
                if set_flag, self.synapses = synapses; end

            end
            
        end
        
        
        %% General Get & Set Synapse Property Functions.
        
        % Implement a function to retrieve the properties of specific synapses.
        function xs = get_synapse_property( self, synapse_IDs, synapse_property, as_matrix_flag, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, as_matrix_flag = self.as_matrix_flag_DEFAULT; end                    % [T/F] As Matrix Flag (Determines whether to return the neuron property as a matrix or as a cell.)                                               % [T/F] As Matrix Flag (Determines whether to return the neuron property as a matrix or as a cell.)
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_properties_to_get = length( synapse_IDs );
            
            % Preallocate a variable to store the synapse properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given synapse property for each synapse.
            for k = 1:num_properties_to_get                                                     % Iterate through each of the properties to get...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{ k } = synapses( %0.0f ).%s;', synapse_index, synapse_property );
                
                % Evaluate the given synapse property.
                eval( eval_str );
                
            end
            
            % Determine whether to convert the network properties to a matrix.
            if as_matrix_flag                                                                   % If we want the neuron properties as a matrix instead of a cell...
               
                % Convert the synapse properties from a cell to a matrix.
                xs = cell2mat( xs );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific synapses.
        function [ synapses, self ] = set_synapse_property( self, synapse_IDs, synapse_property_values, synapse_property, synapses, set_flag )
            
            % Set the default input arguments.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retreive the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
            
            % Retrieve the number of synapse property values.
            num_synapse_property_values = length( synapse_property_values );
            
            % Ensure that the provided synapse property values have the same length as the provided synapse IDs.
            if ( num_synapse_IDs ~= num_synapse_property_values )                                	% If the number of provided synapse IDs does not match the number of provided property values...
                
                % Determine whether to agument the property values.
                if num_synapse_property_values == 1                                                	% If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
                    synapse_property_values = synapse_property_values*ones( 1, num_synapse_IDs );
                    
                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided synapse propety values must match the number of provided synapse IDs, unless a single synapse property value is provided.' )
                    
                end
                
            end
            
            % Validate the synapse property values.
            if ~isa( synapse_property_values, 'cell' )                                              % If the synapse property values are not a cell array...
                
                % Convert the synapse property values to a cell array.
                synapse_property_values = num2cell( synapse_property_values );
                
            end
            
            % Set the properties of each synapse.
            for k = 1:n_synapses                                                                    % Iterate through each synapse...
                
                % Determine the index of the synapse property value that we want to apply to this synapse (if we want to set a property of this synapse).
                index = find( synapses( k ).ID == synapse_IDs, 1 );
                
                % Determine whether to set a property of this synapse.
                if ~isempty( index )                                                                % If a matching synapse ID was detected...
                    
                    % Create an evaluation string that sets the desired synapse property.
                    eval_string = sprintf( 'synapses( %0.0f ).%s = synapse_property_values{ %0.0f };', k, synapse_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        %% Call Methods Functions.
        
        % Implement a function to that calls a specified synapse method for each of the specified synapses.
        function [ values, synapses, self ] = call_synapse_method( self, synapse_IDs, synapse_method, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            values = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each synapse.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Define the eval string.
                eval_str = sprintf( '[ values( k ), synapses( %0.0f ) ] = synapses( %0.0f ).%s(  );', synapse_index, synapse_index, synapse_method );
                
                % Evaluate the given synapse method.
                eval( eval_str );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        %% Specific Get Synapse Property Functions.
        
        % Implement a function to retrieve the index associated with a given synapse ID.
        function synapse_index = get_synapse_index( self, synapse_ID, synapses, undetected_option )
            
            % Set the default input argument.
            if nargin < 4, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );                                                 	% [#] Number of Synapses.
            
            % Set a flag variable to indicate whether a matching synapse index has been found.
            match_found_flag = false;
            
            % Initialize the synapse index.
            synapse_index = 0;
            
            % Search for a synapse whose ID matches the target value.
            while ( synapse_index < n_synapses ) && ( ~match_found_flag )                          % While we have not yet checked all of the synapses and have not yet found an ID match...
                
                % Advance the synapse index.
                synapse_index = synapse_index + 1;
                
                % Check whether this synapse index is a match.
                if self.synapses( synapse_index ).ID == synapse_ID                              % If this synapse has the correct synapse ID...
                    
                    % Set the match found flag to true.
                    match_found_flag = true;
                    
                end
                
            end
            
            % Determine whether to adjust the synapse index.
            if ~match_found_flag                                                                   % If a match was not found...
                
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                                        % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No synapse with ID %0.0f.', synapse_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                                  % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No synapse with ID %0.0f.', synapse_ID )
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                                   % If the undetected option is set to 'ignore'...
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;
                    
                else                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the index associated with a given array of synapse IDs.
        function synapse_indexes = get_synapse_indexes( self, synapse_IDs, synapses, undetected_option )
            
            % Set the default synapse IDs.
            if nargin < 4, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
            
            % Preallocate an array of synapse indexes.
            synapse_indexes = zeros( 1, num_synapse_IDs );
            
            % Retrieve the synapse index of each synapse ID.
            for k = 1:num_synapse_IDs                                                           % Iterate through each synapse ID...
                
                % Determine how to compute the synapse index.
                if synapse_IDs( k ) >= 0                                                        % If the synapse ID is positive... (this means that the synapse ID exists...)
                    
                    % Retrieve the synapse index associated with this synapse ID.
                    synapse_indexes( k ) = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                    
                elseif synapse_IDs( k ) == -1                                                   % If the synapse ID is -1... (this means that the synapse ID does not exist...)
                    
                    % Set the synapse index to negative one (to indicate that it doesn't exist).
                    synapse_indexes( k ) = -1;
                    
                else                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse ID %0.2f not recognized.', synapse_IDs( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get all of the synapse IDs.
        function synapse_IDs = get_all_synapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1,  n_synapses );
            
            % Retrieve each synapse ID.
            for k = 1:n_synapses                                                                % Iterate through each synapse...
                
                % Retrieve the ID of this synapse.
                synapse_IDs( k ) = synapses( k ).ID;
                
            end
            
        end
        
        
        % Implement a function to retrieve all self connecting synapses.
        function synapse_IDs = get_self_connecting_sypnapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Initialize a loop counter.
            index = 0;
            
            % Preallocate an array to store the synapses IDs.
            synapse_IDs = zeros( 1, n_synapses );
            
            % Retrieve all self-connecting synapse IDs.
            for k = 1:n_synapses                                                                % Iterate through each synapse...
                
                % Determine whether this synapse is a self-connection.
                if ( synapses( k ).from_neuron_ID == synapses( k ).to_neuron_ID )               % If this synapse is a self-connection...
                    
                    % Advance the synapse ID index.
                    index = index + 1;
                    
                    % Retrieve this synapse index.
                    synapse_IDs( index ) = synapses( k ).ID;
                    
                end
                
            end
            
            % Keep only the relevant synapse IDs.
            synapse_IDs = synapse_IDs( 1:index );
            
        end
        
        
        %% Synapse ID Functions.
        
        % Implement a function to validate synapse IDs.
        function synapse_IDs = validate_synapse_IDs( self, synapse_IDs, synapses )
            
            % Set the default input arguments.
            if nargin < 3, synapses = self.synapses; end             	% [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Determine whether we want get the desired synapse property from all of the synapses.
            if isa( synapse_IDs, 'char' )                               % If the synapse IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( synapse_IDs, 'all' )                       % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the synapse IDs.
                    synapse_IDs = zeros( 1, n_synapses );
                    
                    % Retrieve the synapse ID associated with each synapse.
                    for k = 1:n_synapses                                % Iterate through each synapse...
                        
                        % Store the synapse ID associated with the current synapse.
                        synapse_IDs( k ) = synapses( k ).ID;
                        
                    end
                    
                else                                                  	% Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse_IDs must be either an array of valid synapse IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to generate a unique synapse ID.
        function synapse_ID = generate_unique_synapse_ID( self, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 3, array_utilities = self.array_utilities; end                          % [class] Array Utilities Class.
            if nargin < 2, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Generate a unique synapse ID.
            synapse_ID = array_utilities.get_lowest_natural_number( existing_synapse_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique synapse IDs.
        function synapse_IDs = generate_unique_synapse_IDs( self, num_IDs, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      	% [class] Array Utilities Class.
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Preallocate an array to store the newly generated synapse IDs.
            synapse_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                                                                 	% Iterate through each of the new IDs...
                
                % Generate a unique synapse ID.
                synapse_IDs( k ) = array_utilities.get_lowest_natural_number( [ existing_synapse_IDs, synapse_IDs( 1:( k - 1 ) ) ] );
                
            end
            
        end
        
        
        % Implement a function to check if a proposed synapse ID is unique.
        function [ unique_flag, match_logicals, match_indexes ] = unique_synapse_ID( self, synapse_ID, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                        	% [class] Array Utilities Class.
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve all of the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Determine whether the given synapse ID is one of the existing synapse IDs ( if so, provide the matching logicals and indexes ).
            [ match_found_flag, match_logicals, match_indexes ] = array_utilities.is_value_in_array( synapse_ID, existing_synapse_IDs );
            
            % Define the uniqueness flag.
            unique_flag = ~match_found_flag;
            
        end
        
        
        % Implement a function to check whether a proposed synapse ID is a unique natural.
        function unique_flag_natural = unique_natural_synapse_ID( self, synapse_ID, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                          % [class] Array Utilities Class.
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Initialize the unique natural to false.
            unique_flag_natural = false;
            
            % Determine whether this synapse ID is unique.
            unique_flag = self.unique_synapse_ID( synapse_ID, synapses, array_utilities );
            
            % Determine whether this synapse ID is a unique natural.
            if unique_flag && ( synapse_ID > 0 ) && ( round( synapse_ID ) == synapse_ID )          % If this neuron ID is a unique natural...
                
                % Set the unique natural flag to true.
                unique_flag_natural = true;
                
            end
            
        end
        
        
        % Implement a function to check if the existing synapse IDs are unique.
        function [ unique_flag, match_logicals ] = unique_existing_synapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end                                                    % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Retrieve all of the existing synapse IDs.
            synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Determine whether all entries are unique.
            if length( unique( synapse_IDs ) ) == n_synapses                                                % If all of the synapse IDs are unique...
                
                % Set the unique flag to true.
                unique_flag = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, n_synapses );
                
            else                                                                                            % Otherwise...
                
                % Set the unique flag to false.
                unique_flag = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, synapses );
                
                % Determine which synapses have duplicate IDs.
                for k1 = 1:n_synapses                                                                       % Iterate through each synapse...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another synapse with the same ID.
                    while ( k2 < n_synapses ) && ( ~match_logicals( k1 ) ) && ( k1 ~= ( k2 + 1 ) )          % While we haven't checked all of the synapses and we haven't found a match...
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this synapse is a match.
                        if synapses( k2 ).ID == synapse_IDs( k1 )                                           % If this synapse ID is a match...
                            
                            % Set this match logical to true.
                            match_logicals( k1 ) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        
        %% From-To Neuron ID Functions.
        
        % Implement a function to retrieve the synapse ID of the synapse that connect two specified neurons.
        function synapse_ID = from_to_neuron_ID2synapse_ID( self, from_neuron_ID, to_neuron_ID, synapses, undetected_option )
            
            % NOTE: This function assumes that only one synapse connects each set of neurons.
            
            % Set the default input argument.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end                                              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, synapses = self.synapses; end                                                                        % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Initialize the  synapse detected flag.
            synapse_detected_flag = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the synapse(s) that connect the specified neurons.
            while ( ~synapse_detected_flag ) && ( k < n_synapses )                                                                 % While a matching synapse has not yet been detected and we haven't looked through all of the synapses...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this synapse connects the specified neurons.
                if ( synapses( k ).from_neuron_ID == from_neuron_ID ) && ( synapses( k ).to_neuron_ID == to_neuron_ID )         % If this synapse connects the specified neurons...
                    
                    % Set the synapse detected flag to true.
                    synapse_detected_flag = true;
                    
                end
                
            end
            
            % Determine whether a matching synapse was detected.
            if synapse_detected_flag                                                                                               % If we found a matching synapse....
                
                % Retrieve the ID of the matching synapse.
                synapse_ID = synapses( k ).ID;
                
            else                                                                                                                % Otherwise...
                
                % Determine how to handle the situation where we can not find a synapse that connects the selected neurons.
                if strcmpi( undetected_option, 'error' )                                                                      	% If the error option is selected...
                    
                    % Throw an error.
                    error( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                                                                  % If the warning option is selected...
                    
                    % Throw a warning.
                    warning( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                                                                  	% If the ignore option is selected...
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                else                                                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the synpase IDs associated with the synapses that connect an array of specified neurons.
        function synapse_IDs = from_to_neuron_IDs2synapse_IDs( self, from_neuron_IDs, to_neuron_IDs, synapses, undetected_option )
            
            % Set the default input argument.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Ensure that the same number of from and to neuron IDs are specified.
            assert( length( from_neuron_IDs ) == length( to_neuron_IDs ), 'length( from_neuron_IDs ) must equal length( to_neuron_IDs ).' )
            
            % Retrieve the number of synapses to find.
            num_synapses_to_find = length( from_neuron_IDs );
            
            % Preallocate an array to store the syanpse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_find );
            
            % Search for each synapse ID.
            for k = 1:num_synapses_to_find                                                   	% Iterate through each set of neurons for which we are searching for a connecting synapse...
                
                % Retrieve the ID of the synapse that connects these neurons.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( from_neuron_IDs( k ), to_neuron_IDs( k ), synapses, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to oscillatory from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2oscillatory_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                              % If the neuron ID order was specified...
                
                % Retrieve the number of pairs of neurons.
                num_pairs = length( neuron_ID_order );
                
                % Augment the neuron ID order.
                neuron_ID_order = [ neuron_ID_order, neuron_ID_order( 1 ) ];
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k = 1:num_pairs                                                     % Iterate through each pair of neurons...
                    
                    % Retrieve the from neuron ID.
                    from_neuron_IDs( k ) = neuron_ID_order( k );
                    
                    % Retrieve the to neuron ID.
                    to_neuron_IDs( k ) = neuron_ID_order( k + 1 );
                    
                end
                
            else                                                                        % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to self connecting from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2self_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                      % If the neuron ID order was specified...
                
                % Set the from-to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( neuron_ID_order );
                
            else                                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to all from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2all_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Retrieve the number of pairs of neurons.
                num_neurons = length( neuron_ID_order );
                num_pairs = num_neurons^2;
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Preallocate a counter variable.
                k3 = 0;
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k1 = 1:num_neurons                                      % Iterate through each pair of neurons...
                    for k2 = 1:num_neurons                                 	% Iterate through each pair of neurons...
                        
                        % Advance the counter variable.
                        k3 = k3 + 1;
                        
                        % Retrieve the from neuron ID.
                        from_neuron_IDs( k3 ) = neuron_ID_order( k1 );
                        
                        % Retrieve the to neuron ID.
                        to_neuron_IDs( k3 ) = neuron_ID_order( k2 );
                        
                    end
                end
                
            else                                                            % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to retrieve the synapse IDs relevant to a set of neuron IDs.
        function synapse_IDs = neuron_IDs2synapse_IDs( self, neuron_IDs, synapses, undetected_option )
            
            % Set the default input argument.
            if nargin < 4, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the IDs of all relevant from and to neurons.
            [ from_neuron_IDs, to_neuron_IDs ] = self.neuron_ID_order2all_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the synapse IDs associated with the given neuron IDs.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs, synapses, undetected_option );
            
        end
        
        
        % Implement a function to determine whether only a single synapse connects each pair of neurons.
        function one_to_one_flag = one_to_one_synapses( self, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 3, array_utilities = self.array_utilities; end                                                                                                                              % [class] Array Utilities Class.
            if nargin < 2, synapses = self.synapses; end                                                                                                                                            % [class] Array of Synapse Class Objects.
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Set the one-to-one flag.
            one_to_one_flag = true;
            
            % Initialize a counter variable.
            k = 0;
            
            % Preallocate arrays to store the from and to neuron IDs.
            [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, n_synapses ) );
            enabled_flags = false( 1, n_synapses );
            
            % Determine whether there is only one synapse between each neuron.
            while ( one_to_one_flag ) && ( k < n_synapses )                                                                                                                                            % While we haven't found a synapse repetition and we haven't checked all of the synapses...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Store these from neuron and to neuron IDs.
                from_neuron_IDs( k ) = synapses( k ).from_neuron_ID;
                to_neuron_IDs( k ) = synapses( k ).to_neuron_ID;
                enabled_flags( k ) = synapses( k ).enabled_flag;
                
                % Determine whether we need to check this synapse for repetition.
                if k ~= 1                                                                                                                                                                           % If this is not the first iteration...
                    
                    % Determine whether the from and to neuron IDs are unique.
                    [ from_neuron_ID_match, from_neuron_ID_match_logicals ] = array_utilities.is_value_in_array( from_neuron_IDs( k ), from_neuron_IDs( 1:( k  - 1 ) ) );
                    [ to_neuron_ID_match, to_neuron_ID_match_logicals ] = array_utilities.is_value_in_array( to_neuron_IDs( k ), to_neuron_IDs( 1:( k  - 1 ) ) );
                    
                    % Determine whether this synapse is a duplicate.
                    if from_neuron_ID_match && to_neuron_ID_match && enabled_flags( k ) && any( from_neuron_ID_match_logicals & to_neuron_ID_match_logicals & enabled_flags( 1:( k  - 1 ) ) )             % If both the from neuron ID match flag and to neuron ID match flag are true, and we detect that these flags are aligned...
                        
                        % Set the one-to-one flag to false (this synapse is duplicate).
                        one_to_one_flag = false;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        %% CPG Delta Compute Functions.
        
        % Implement a function to assign the desired delta value to each synapse based on the neuron order that we want to follow.
        function [ synapses, self ] = compute_cpg_deltas( self, neuron_IDs, delta_oscillatory, delta_bistable, synapses, set_flag, undetected_option, array_utilities )
            
            % Set the default input arguments.
            if nargin < 8, array_utilities = self.array_utilities; end                        	% [class] Array Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end                    % [V] Bistable CPG Bifurcation Parameter.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end              % [V] Oscillatory CPG Bifurcation Parameter.              % [V] Oscillatory CPG Bifurcation Parameter.
            
            % Retrieve the IDs of all relevant from and to neurons.
            [ from_neuron_IDs_all, to_neuron_IDs_all ] = self.neuron_ID_order2all_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the IDs of the oscillatory from and to neurons.
            [ from_neuron_IDs_oscillatory, to_neuron_IDs_oscillatory ] = self.neuron_ID_order2oscillatory_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the IDs of relevant self connecting from and to neurons.
            [ from_neuron_IDs_self, to_neuron_IDs_self ] = self.neuron_ID_order2self_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve all of the relevant synapse IDs.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_all, to_neuron_IDs_all, synapses, undetected_option );
            
            % Retrieve the synapse IDs for each synapse the connects the specified neurons.
            synapse_IDs_oscillatory = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_oscillatory, to_neuron_IDs_oscillatory, synapses, undetected_option );
            
            % Retrieve the synapse IDs for all relevant self-connections.
            synapse_IDs_self_connections = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs_self, to_neuron_IDs_self, synapses, undetected_option );
            
            % Retrieve the synapse IDs for all of the other neurons.
            synapse_IDs_bistable = array_utilities.remove_entries( synapse_IDs, synapse_IDs_oscillatory );
            synapse_IDs_bistable = array_utilities.remove_entries( synapse_IDs_bistable, synapse_IDs_self_connections );
            
            % Set the delta value of each of the oscillatory synapses.
            [ synapses, synapse_manager ] = self.set_synapse_property( synapse_IDs_oscillatory, delta_oscillatory*ones( 1, length( synapse_IDs_oscillatory ) ), 'delta', synapses, true );

%             deltas_temp = [ 0.01e-3, 0.01e-3, 0.01e-3, 0.01e-3 ];                       % No syncopation.
%             deltas_temp = [ 0.01e-3, 0.05e-3, 0.01e-3, 0.05e-3 ];                       % Low level of syncopation.
%             deltas_temp = [ 0.01e-3, 0.15e-3, 0.01e-3, 0.15e-3 ];                       % Medium level of syncopation.
%             deltas_temp = [ 0.01e-3, 0.30e-3, 0.01e-3, 0.30e-3 ];                       % High level of syncopation.
%             deltas_temp = [ 0.01e-3, 0.45e-3, 0.01e-3, 0.45e-3 ];                       % High level of syncopation.

%             self = self.set_synapse_property( synapse_IDs_oscillatory, deltas_temp, 'delta' );

            % Set the delta value of each of the bistable synapses.
            [ synapses, synapse_manager ] = synapse_manager.set_synapse_property( synapse_IDs_bistable, delta_bistable*ones( 1, length( synapse_IDs_bistable ) ), 'delta', synapses, true );
            
            % Set the delta value of each of the self-connecting synapses.
            [ synapses, synapse_manager ] = synapse_manager.set_synapse_property( synapse_IDs_self_connections, zeros( 1, length( synapse_IDs_self_connections ) ), 'delta', synapses, true );
            
            % Determine whether to update the synapse object.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        %% General Processing Functions.

        % Implement a function to process the to from neuron IDs.
        function [ to_from_neuron_IDs, to_from_neuron_IDs_flag ] = process_to_from_neuron_IDs( ~, to_from_neuron_IDs )
            
            % Compute the number of synapses.
            n_synapses = length( to_from_neuron_IDs );
            
            % Determine whether to generate to from neuron IDs.
            if all( to_from_neuron_IDs == -1 )                                  % If the to neuron IDs were not provided...
                
                % Preallocate an array to store the to from neuron IDs.
                to_from_neuron_IDs = zeros( 1, n_synapses );
                
                % Set the to neuron IDs flag to true.
                to_from_neuron_IDs_flag = true;
                
            else                                                                % Otherwise...
                
                % Set the to neuron IDs flag to false.
                to_from_neuron_IDs_flag = false;
                
            end
            
        end
        
        
        % Implement a function to process synapse names.
        function [ names, names_flag ] = process_names( ~, names )
           
            % Compute the number of synapses.
            n_synapses = length( names );
            
            % Determine whether to generate names.
            if isempty( names )                                         % If the names are empty...
                
                % Preallocate an array to store the names.
                names = cell( 1, n_synapses );
                
                % Set the names flag to true.
                names_flag = true;
                
            else                                                        % Otherwise...
               
                % Set the names flag to false.
                names_flag = false;
                
            end
            
        end
        
                
        %% Maximum Synaptic Conductance Parameter Processing Functions.
        
        % ---------- Transmission Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance params for synapse 21 of a transmission subnetwork.
        function params = process_transmission_gs21_params( self, synapse_ID, params, encoding_scheme, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                      % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                          % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                           	% [struct] Parameters Struct.  (Absolute: R2, Gm2, dEs21, Ia2; Relative: R2, Gm2, dEs21, Ia2)
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                   % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                % If no params were provided...
                    
                    % Set the default parameter values.
                    c = self.c_absolute_transmission_DEFAULT;                                                         	% [-] Subnetwork Gain.
                    x1_max = self.x1max_absolute_transmission_DEFAULT;                                                  % [-] Maximum Decoded Input.
                    Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.
                    dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c = c;
                    params.x1_max = x1_max;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    
                else                                                                                                   	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                       	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                              	% If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                              	% If no params were provided...
                    
                    % Set the default parameter values.
                    R2 = self.R_DEFAULT;                                                                                % [V] Activation Domain.
                    Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.
                    dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.R2 = R2;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    
                else                                                                                                  	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 3                                                                     	% If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                      	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the design params for a transmission subnetwork.
        function params = process_transmission_params( self, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                           	% [struct] Parameters Struct.  (Absolute: R2, Gm2, dEs21, Ia2; Relative: R2, Gm2, dEs21, Ia2)
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                 	% If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                              	% If no params were provided...
                    
                    % Set the default parameter values.
                    c = self.c_absolute_transmission_DEFAULT;                           % [-] Subnetwork Gain.
                    x1_max = self.x1max_absolute_transmission_DEFAULT;                  % [-] Maximum Decoded Input.
                    Gm2 = self.Gm_DEFAULT;                                            	% [S] Membrane Conductance.
                    
                    % Store the required params.
                    params.c = c;
                    params.x1_max = x1_max;
                    params.Gm2 = Gm2;
                    
                else                                                                    % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 3                                    	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                            	% If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                              	% If no params were provided...
                    
                    % Set the default parameter values.
                    R2 = self.R_DEFAULT;                                             	% [V] Activation Domain.
                    Gm2 = self.Gm_DEFAULT;                                            	% [S] Membrane Conductance.
                    
                    % Store the required params.
                    params.R2 = R2;
                    params.Gm2 = Gm2;
                    
                else                                                                 	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 2                                      	% If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                    	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to process the addition subnetwork synaptic conductance params.
        function params = process_addition_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                                                                   % [-] Subnetwork Gain.
                    R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                        % [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                                                                 % [S] Membrane Conductance.
                    dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                    Ia_n = self.Ia_DEFAULT;                                                                                 % [A] Applied Current.
                                        
                    % Store the required params.
                    params.c_k = c_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.dEs_nk = dEs_nk;
                    params.Ia_n = Ia_n;                    
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                                                                   % [-] Subnetwork Gain.
                    R_n = self.R_DEFAULT;                                                                                   % [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                                                                 % [S] Membrane Conductance.
                    dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                    Ia_n = self.Ia_DEFAULT;                                                                                 % [A] Applied Current.
                    
                    % Store the required params.
                    params.c_k = c_k;
                    params.R_n = R_n;
                    params.Gm_n= Gm_n;
                    params.dEs_nk = dEs_nk;
                    params.Ia_n = Ia_n;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end

        
        % Implement a function to process the design params for an addition subnetwork.
        function params = process_addition_params( self, synapse_IDs, params, encoding_scheme )
                    
            % Set the default input arguments.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end          % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                    	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                              	% If no params were provided...
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                             	% [-] Subnetwork Gain.
                    R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                  	% [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                           	% [S] Membrane Conductance.
                    Ia_n = self.Ia_DEFAULT;                                           	% [A] Applied Current.
                                        
                    % Store the required params.
                    params.c_k = c_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.Ia_n = Ia_n;
                    
                else                                                                 	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                       	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                            	% If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                               	% If no params were provided...
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                              	% [-] Subnetwork Gain.
                    R_n = self.R_DEFAULT;                                            	% [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                            	% [S] Membrane Conductance.
                    Ia_n = self.Ia_DEFAULT;                                          	% [A] Applied Current.
                    
                    % Store the required params.
                    params.c_k = c_k;
                    params.R_n = R_n;
                    params.Gm_n = Gm_n;
                    params.Ia_n = Ia_n;
                    
                else                                                                 	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                        % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to process the subtraction subnetwork synaptic conductance params.
        function params = process_subtraction_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                        	% [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                   	% [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                             	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                         	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                    	% If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                  	% If no params were provided...
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                                                                 	% [-] Subnetwork Gain.
                    s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                       	% [-] Input Signature.
                    R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                       	% [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                                                                	% [S] Membrane Conductance.
                    dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                    Ia_n = self.Ia_DEFAULT;                                                                                	% [A] Applied Current.
                    
                    % Store the required params.
                    params.c_k = c_k;
                    params.s_k = s_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.dEs_nk = dEs_nk;
                    params.Ia_n = Ia_n;
                    
                else                                                                                                      	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                           	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                	% If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                  	% If no params were provided... 
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                                                                 	% [-] Subnetwork Gain.
                    s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                      	% [-] Input Signature.
                    R_k = self.R_DEFAULT;                                                                                 	% [V] Maximum Membrane Voltage. 
                    Gm_n = self.Gm_DEFAULT;                                                                                	% [S] Membrane Conductance.
                    dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );           	% [V] Synaptic Reversal Potential.
                    Ia_n = self.Ia_DEFAULT;                                                                                	% [A] Applied Current.
                    
                    % Store the required params.
                    params.c_k = c_k;
                    params.s_k = s_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.dEs_nk = dEs_nk;
                    params.Ia_n = Ia_n;
                    
                else                                                                                                      	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                         	% If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                          	% Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end

        
        % Implement a function to process the design params for a subtraction subnetwork.
        function params = process_subtraction_params( self, synapse_IDs, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                               % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                           % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                        % If no params were provided...
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT;                                                                                     	% [-] Subnetwork Gain.
                    s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [-] Input Signature.
                    R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [V] Maximum Membrane Voltage.
                    Gm_n = self.Gm_DEFAULT;                                                                                     % [S] Membrane Conductance.
                    Ia_n = self.Ia_DEFAULT;                                                                                     % [A] Applied Current.
                    
                    % Store the required params.
                    params.c_k = c_k;
                    params.s_k = s_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.Ia_n = Ia_n;
                    
                else                                                                                                            % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                                % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                       % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                        % If no params were provided... 
                    
                    % Compute the number of synapse IDs.
                    num_synapse_IDs = length( synapse_IDs );
                    
                    % Set the default parameter values.
                    c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs );                                                          	% [-] Subnetwork Gain.
                    s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [-] Input Signature.
                    R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                          	% [V] Maximum Membrane Voltage. 
                    Gm_n = self.Gm_DEFAULT;                                                                                     % [S] Membrane Conductance.
                    Ia_n = self.Ia_DEFAULT;                                                                                     % [A] Applied Current.
                    
                    % Store the required params.                    
                    params.c_k = c_k;
                    params.s_k = s_k;
                    params.R_k = R_k;
                    params.Gm_n = Gm_n;
                    params.Ia_n = Ia_n;
                    
                else                                                                                                            % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                             	% If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                                % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end

        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to process the inversion subnetwork synaptic conductance params.
        function params = process_inversion_gs21_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_inversion_DEFAULT;
                    c3 = self.c3_absolute_inversion_DEFAULT;
                    delta = self.delta_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;
                    dEs21 = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );           	% [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_inversion_DEFAULT;
                    c3 = self.c3_absolute_inversion_DEFAULT;
                    delta = self.delta_absolute_inversion_DEFAULT;
                    R2 = self.R_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;
                    dEs21 = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );           	% [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.R2 = R2;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end


        % Implement a function to process the design params for an inversion subnetwork.
        function params = process_inversion_params( self, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_inversion_DEFAULT;
                    c3 = self.c3_absolute_inversion_DEFAULT;
                    delta = self.delta_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.Gm2 = Gm2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_inversion_DEFAULT;
                    c3 = self.c3_absolute_inversion_DEFAULT;
                    delta = self.delta_absolute_inversion_DEFAULT;
                    R2 = self.R_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.R2 = R2;
                    params.Gm2 = Gm2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end

        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to process the reduced inversion subnetwork synaptic conductance params.
        function params = process_reduced_inversion_gs21_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_reduced_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.
                    dEs21 = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia2 = self.Ia_DEFAULT;                                                                                  % [A] Applied Current.
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    params.Ia2 = Ia2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_reduced_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.
                    dEs21 = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia2 = self.Ia_DEFAULT;                                                                                  % [A] Applied Current.                                                                                 % [A] Applied Current.
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.Gm2 = Gm2;
                    params.dEs21 = dEs21;
                    params.Ia2 = Ia2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        

        % Implement a function to process the design params for a reduced inversion subnetwork.
        function params = process_reduced_inversion_params( self, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_inversion_DEFAULT;
                    delta = self.delta_reduced_absolute_inversion_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.Gm2 = Gm2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_inversion_DEFAULT;
                    delta = self.delta_reduced_absolute_inversion_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_inversion_DEFAULT;
                    Gm2 = self.Gm_DEFAULT;  
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.Gm2 = Gm2;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to process the maximum synaptic conductance for synapse 31 of a division subnetwork.
        function params = process_division_gs31_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_division_DEFAULT;
                    c3 = self.c3_absolute_division_DEFAULT;
                    x1_max = self.x1max_absolute_division_DEFAULT;
                    Gm3 = self.Gm_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;

                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    R3 = self.R_DEFAULT;                                                                                    % [V] Maximum Membrane Voltage.
                    Gm3 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 3                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a division subnetwork.
        function params = process_division_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                            	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_division_DEFAULT;
                    c3 = self.c3_absolute_division_DEFAULT;
                    delta = self.delta_absolute_division_DEFAULT;
                    x1_max = self.x1max_absolute_division_DEFAULT;
                    Gm3 = self.Gm_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_division_DEFAULT;
                    c3 = self.c3_relative_division_DEFAULT;
                    delta = self.delta_relative_division_DEFAULT;
                    x1_max = self.x1max_relative_division_DEFAULT;
                    R3 = self.R_relative_division_DEFAULT;
                    Gm3 = self.Gm_relative_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
                
        % Implement a function to process the params for computing the synaptic conductances of a division subnetwork.
        function params = process_division_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            %{ 
            
                % Absolute: delta, R3, Gm3, dEs31, dEs32, Ia3

                % Absolute gs31: R3, Gm3, dEs31, Ia3
                % Absolute gs32: delta, Gm3, gs31, dEs31, dEs32, Ia3

                % Relative: delta, R3, gm3, dEs31, dEs32, Ia3

                % Relative gs31: R3, Gm3, dEs31, Ia3
                % Relative gs32: delta, Gm3, gs31, dEs31, dEs32, Ia3
            
            %}
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                    	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_division_DEFAULT;
                    c3 = self.c3_absolute_division_DEFAULT;
                    delta = self.delta_absolute_division_DEFAULT;
                    x1_max = self.x1max_absolute_division_DEFAULT;
                    Gm3 = self.Gm_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );       	% [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_division_DEFAULT;
                    c3 = self.c3_relative_division_DEFAULT;
                    delta = self.delta_relative_division_DEFAULT;
                    x1_max = self.x1max_relative_division_DEFAULT;
                    R3 = self.R_relative_division_DEFAULT;
                    Gm3 = self.Gm_relative_division_DEFAULT;
                    dEs31 = self.dEs_relative_division_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the design params for a division subnetwork.
        function params = process_division_params( self, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                    	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_division_DEFAULT;
                    c3 = self.c3_absolute_division_DEFAULT;
                    delta = self.delta_absolute_division_DEFAULT;
                    x1_max = self.x1max_absolute_division_DEFAULT;
                    Gm3 = self.Gm_absolute_division_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_division_DEFAULT;
                    c3 = self.c3_relative_division_DEFAULT;
                    delta = self.delta_relative_division_DEFAULT;
                    x1_max = self.x1max_relative_division_DEFAULT;
                    R3 = self.R_relative_division_DEFAULT;
                    Gm3 = self.Gm_relative_division_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance for synapse 31 of a reduced division subnetwork.
        function params = process_reduced_division_gs31_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                   	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                        % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_division_DEFAULT;
                    delta = self.delta_reduced_absolute_division_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );        % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                               	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    R3 = self.R_DEFAULT;                                                                                    % [V] Maximum Membrane Voltage.
                    Gm3 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 3                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a reduced division subnetwork.
        function params = process_reduced_division_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                            	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_division_DEFAULT;
                    delta = self.delta_reduced_absolute_division_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_division_DEFAULT;
                    delta = self.delta_reduced_relative_division_DEFAULT;
                    x2_max = self.x2max_reduced_relative_division_DEFAULT;
                    R3 = self.R_reduced_relative_division_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the params for computing the synaptic conductances of a reduced division subnetwork.
        function params = process_reduced_division_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            %{
                % Absolute: delta2, R3, Gm3, dEs31, dEs32, Ia3
            
                % Absolute gs31: R3, Gm3, dEs31, Ia3
                % Absolute gs32: delta2, Gm3, gs31, dEs31, dEs32, Ia3
        
            
                % Relative: delta2, R3, Gm3, dEs31, dEs32, Ia3
            
                % Relative gs31: R3, Gm3, dEs31, Ia3
                % Relative gs32: delta2, Gm3, gs31, dEs31, dEs32, Ia3
            
            %}
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_division_DEFAULT;
                    delta = self.delta_reduced_absolute_division_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );        % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_division_DEFAULT;
                    delta = self.delta_reduced_relative_division_DEFAULT;
                    x2_max = self.x2max_reduced_relative_division_DEFAULT;
                    R3 = self.R_reduced_relative_division_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_division_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );       	% [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta = delta;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the design params for a reduced division subnetwork.
        function params = process_reduced_division_params( self, params, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_division_DEFAULT;
                    delta = self.delta_reduced_absolute_division_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta = delta;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_division_DEFAULT;
                    delta = self.delta_reduced_relative_division_DEFAULT;
                    x2_max = self.x2max_reduced_relative_division_DEFAULT;
                    R3 = self.R_reduced_relative_division_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_division_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta = delta;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance for synapse 31 of a division after inversion subnetwork.
        function params = process_dai_gs31_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                        % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_dai_DEFAULT;
                    c3 = self.c3_absolute_dai_DEFAULT;
                    x1_max = self.x1max_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_absolute_dai_DEFAULT;
                    dEs31 = self.dEs_absolute_dai_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                  % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_dai_DEFAULT;
                    c3 = self.c3_relative_dai_DEFAULT;
                    x1_max = self.x1max_relative_dai_DEFAULT;
                    R1 = self.R_relative_dai_DEFAULT;
                    Gm3 = self.Gm_relative_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.c3 = c3;
                    params.x1_max = x1_max;
                    params.R1 = R1;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a division after inversion subnetwork.
        function params = process_dai_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                         % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                           % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                            % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_dai_DEFAULT;
                    c3 = self.c3_absolute_dai_DEFAULT;
                    delta2 = self.delta2_absolute_dai_DEFAULT;
                    x1_max = self.x1max_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_absolute_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                            % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                   	% If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                       % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                            % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_dia_DEFAULT;
                    c3 = self.c3_relative_dia_DEFAULT;
                    delta2 = self.delta2_relative_dia_DEFAULT;
                    x1_max = self.x1max_relative_dia_DEFAULT;
                    x2_max = self.x2max_relative_dia_DEFAULT;
                    R2 = self.R_relative_dia_DEFAULT;
                    Gm3 = self.Gm_relative_dia_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R2 = R2;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                         	% Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                    	% If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the params for computing the synaptic conductances of a division after inversion subnetwork.
        function params = process_dai_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            %{
            
            % Absolute:  c1, c3, delta1, delta2, R1, R2, dEs31
        
            % Absolute gs31: c1, c3, delta1, delta2, R1, R2
            % Absolute gs32: c1, c3, delta2, R1, R2, dEs31

        
            % Relative: c1, c3, delta1, delta2, R2, dEs31
        
            % Relative gs31: c1, c3, delta1, delta2, R2, dEs31
            % Relative gs32: c1, c3, delta1, delta2, R2, dEs31
            
            %}
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                   	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_dia_DEFAULT;
                    c3 = self.c3_absolute_dia_DEFAULT;
                    delta2 = self.delta2_absolute_dia_DEFAULT;
                    x1_max = self.x1max_absolute_dia_DEFAULT;
                    Gm3 = self.Gm_absolute_dia_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_dai_DEFAULT;
                    c3 = self.c3_relative_dai_DEFAULT;
                    delta2 = self.delta2_relative_dai_DEFAULT;
                    x1_max = self.x1max_relative_dai_DEFAULT;
                    x2_max = self.x2max_relative_dai_DEFAULT;
                    R1 = self.R_relative_dai_DEFAULT;
                    R2 = self.R_relative_dai_DEFAULT;
                    Gm3 = self.Gm_relative_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R1 = R1;
                    params.R2 = R2;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 9                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the design params for a division after inversion subnetwork.
        function params = process_dai_params( self, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                   	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_absolute_dia_DEFAULT;
                    c3 = self.c3_absolute_dia_DEFAULT;
                    delta2 = self.delta2_absolute_dia_DEFAULT;
                    x1_max = self.x1max_absolute_dia_DEFAULT;
                    Gm3 = self.Gm_absolute_dia_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_relative_dai_DEFAULT;
                    c3 = self.c3_relative_dai_DEFAULT;
                    delta2 = self.delta2_relative_dai_DEFAULT;
                    x1_max = self.x1max_relative_dai_DEFAULT;
                    x2_max = self.x2max_relative_dai_DEFAULT;
                    R1 = self.R_relative_dai_DEFAULT;
                    R2 = self.R_relative_dai_DEFAULT;
                    Gm3 = self.Gm_relative_dai_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.c3 = c3;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R1 = R1;
                    params.R2 = R2;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                           % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance for synapse 31 of a reduced division after inversion subnetwork.
        function params = process_reduced_dai_gs31_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_dai_DEFAULT;
                    delta2 = self.delta2_reduced_absolute_dai_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_dai_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_dai_DEFAULT;
                    delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                    delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                    x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                    x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                    R3 = self.R_reduced_relative_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a reduced division after inversion subnetwork.
        function params = process_reduced_dai_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                            	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_absolute_dai_DEFAULT;
                    delta2 = self.delta2_reduced_absolute_dai_DEFAULT;
                    x1_max = self.x1max_reduced_absolute_dai_DEFAULT;
                    x2_max = self.x2max_reduced_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_absolute_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_dai_DEFAULT;
                    delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                    delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                    x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                    x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                    R3 = self.R_reduced_relative_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the params for computing the synaptic conductances of a reduced division after inversion subnetwork.
        function params = process_reduced_dai_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            %{
            
            % Absolute: delta1, delta2, R2, R3, Gm3, dEs31
        
            % Absolute gs31: delta1, delta2, R2, R3, Gm3, dEs31
            % Absolute gs32: delta1, delta2, R2, R3, Gm3, dEs31
        
            % Relative: delta1, delta2, R2, R3, Gm3, dEs31
            
            % Relative gs31: delta1, delta2, R2, R3, dEs31
            % Relative gs32: delta1, delta2, R2, R3, Gm3, dEs31
            
            %}
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                   	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduce_absolute_dai_DEFAULT;
                    delta2 = self.delta2_reduce_absolute_dai_DEFAULT;
                    x1_max = self.x1max_reduce_absolute_dai_DEFAULT;
                    x2_max = self.x2max_reduce_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_reduce_absolute_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_dai_DEFAULT;
                    delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                    delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                    x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                    x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                    R3 = self.R_reduced_relative_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                    dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs31 = dEs31;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the design params for a reduced division after inversion subnetwork.
        function params = process_reduced_dai_params( self, params, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                   	% [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduce_absolute_dai_DEFAULT;
                    delta2 = self.delta2_reduce_absolute_dai_DEFAULT;
                    x1_max = self.x1max_reduce_absolute_dai_DEFAULT;
                    x2_max = self.x2max_reduce_absolute_dai_DEFAULT;
                    Gm3 = self.Gm_reduce_absolute_dai_DEFAULT;
                    
                    % Store the required params.                    
                    params.c1 = c1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c1 = self.c1_reduced_relative_dai_DEFAULT;
                    delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                    delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                    x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                    x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                    R3 = self.R_reduced_relative_dai_DEFAULT;
                    Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                    
                    % Store the required params.
                    params.c1 = c1;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.x1_max = x1_max;
                    params.x2_max = x2_max;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance for synapse 41 of a multiplication subnetwork.
        function params = process_multiplication_gs41_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R1 = self.R_DEFAULT;
                    R3 = self.R_DEFAULT;

                    % Store the required params.
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R1 = R1;
                    params.R3 = R3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a multiplication subnetwork.
        function params = process_multiplication_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );      	% [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;

                    % Store the required params.
                    params.delta1 = delta1;
                    params.Gm3 = Gm3;
                    params.dEs32 = dEs32;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );      	% [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.Gm3 = Gm3;
                    params.dEs32 = dEs32;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 43 of a multiplication subnetwork.
        function params = process_multiplication_gs43_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R1 = self.R_DEFAULT;
                    R3 = self.R_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.

                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta2 = delta2;
                    params.R1 = R1;
                    params.R3 = R3;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the params for computing the synaptic conductances of a multiplication subnetwork.
        function params = process_multiplication_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
            
            %{
            
            % Absolute: c4, c6, delta1, delta2, R1, R3, Gm3, dEs41, dEs32, Ia3
        
            % Absolute gs41: c4, c6, delta1, delta2, R1, R3
            % Absolute gs32: delta1, Gm3, dEs32, Ia3
            % Absolute gs43: c4, c6, delta2, R1, R3, dEs41
        
            % Relative: c4, c6, delta1, delta2, R3, Gm3, dEs41, Ia3
            
            % Relative gs41: c4, c6, delta1, delta2, R3, dEs41
            % Relative gs32: delta1, Gm3, dEs32, Ia3
            % Relative gs43: c4, c6, delta1, delta2, R3, dEs41
            
            %}
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R1 = self.R_DEFAULT;
                    R3 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;

                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R1 = R1;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs41 = dEs41;
                    params.dEs32 = dEs32;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 10                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;
                    
                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.dEs41 = dEs41;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        

        % Implement a function to process the design params for a multiplication subnetwork.
        function params = process_multiplication_params( self, params, encoding_scheme )
                        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R1 = self.R_DEFAULT;
                    R3 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Ia3 = self.Ia_DEFAULT;

                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R1 = R1;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    c4 = self.c1_dai_DEFAULT;
                    c6 = self.c3_dai_DEFAULT;
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Ia3 = self.Ia_DEFAULT;
                    
                    % Store the required params.                    
                    params.c4 = c4;
                    params.c6 = c6;
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.Gm3 = Gm3;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to process the maximum synaptic conductance for synapse 41 of a reduced multiplication subnetwork.
        function params = process_reduced_multiplication_gs41_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.

                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm4 = Gm4;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.

                    % Store the required params.
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.dEs41 = dEs41;
 
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 5                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 32 of a reduced multiplication subnetwork.
        function params = process_reduced_multiplication_gs32_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );      	% [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;

                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.Gm3 = Gm3;
                    params.dEs32 = dEs32;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );      	% [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.Gm3 = Gm3;
                    params.dEs32 = dEs32;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 4                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the maximum synaptic conductance for synapse 43 of a reduced multiplication subnetwork.
        function params = process_reduced_multiplication_gs43_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.

                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm4 = Gm4;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm4 = Gm4;
                    params.dEs41 = dEs41;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 6                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the params for computing the synaptic conductances of a reduced multiplication subnetwork.
        function params = process_reduced_multiplication_gs_params( self, synapse_IDs, params, encoding_scheme, synapses, undetected_option )
        
            %{
            
            % Absolute: delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3
        
            % Absolute gs41: delta1, delta2, R3, R4, Gm4, dEs41
            % Absolute gs32: delta1, Gm3, dEs32, Ia3
            % Absolute gs43: delta1, delta2, R3, R4, Gm4, dEs41
        
            % Relative: delta1, delta2, R3, R4, Gm3, Gm4, dEs41, Ia3
        
            % Relative gs41: delta1, delta2, R3, R4, dEs41
            % Relative gs32: delta1, Gm3, dEs32, Ia3
            % Relative gs43: delta1, delta2, R3, R4, Gm4, dEs41
            
            %}
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                                          % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, synapses = self.synapses; end                                                                    % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;  
                    
                    % Store the required params.
                    params = { delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3 };
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 9                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                    Ia3 = self.Ia_DEFAULT;  

                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm3 = Gm3;
                    params.Gm4 = Gm4;
                    params.dEs41 = dEs41;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 8                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        

        % Implement a function to process the design params for a reduced multiplication subnetwork.
        function params = process_reduced_multiplication_params( self, params, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, params = struct( [  ] ); end                                                                           % [struct] Parameters Structure.
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the params given that this operation is using an absolute encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    Ia3 = self.Ia_DEFAULT;  
                    
                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm3 = Gm3;
                    params.Gm4 = Gm4;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether params is valid given that this operation is using a relative encoding scheme.
                if isempty( params )                                                                                    % If no params were provided...
                    
                    % Set the default parameter values.
                    delta1 = self.delta_inversion_DEFAULT;
                    delta2 = self.delta_dai_DEFAULT;
                    R3 = self.R_DEFAULT;
                    R4 = self.R_DEFAULT;
                    Gm3 = self.Gm_DEFAULT;
                    Gm4 = self.Gm_DEFAULT;
                    Ia3 = self.Ia_DEFAULT;  

                    % Store the required params.                    
                    params.delta1 = delta1;
                    params.delta2 = delta2;
                    params.R3 = R3;
                    params.R4 = R4;
                    params.Gm3 = Gm3;
                    params.Gm4 = Gm4;
                    params.Ia3 = Ia3;
                    
                else                                                                                                        % Otherwise...
                    
                    % Determine whether the params has a valid number of entries.
                    if length( fieldnames( params ) ) ~= 7                                                                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid params detected.' )
                    
                    end
                    
                end
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        %% Parameter Retrieval Functions.
        
        % Implement a function to retrieve addition subnetwork params.
        function these_params = get_addition_gs_params( self, k, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                   % [struct] Parameters Structure.
            
            % Determine how to unpack the params for this synapse.
            if strcmpi( encoding_scheme, 'absolute' )                               % If the encoding scheme is absolute...
                
                % Unpack the params.
                c_ks = params.c_ks;                                                % [-] Subnetwork Gain.
                R_ks = params.R_ks;                                             % [V] Maximum Membrane Voltage.
                Gm_n = params.Gm_n;                                             % [S] Membrane Conductance.
                dEs_nks = params.dEs_nks;                                          % [V] Synaptic Reversal Potential.
                Ia_n = params.Ia_n;                                             % [A] Applied Current.
                                
                % Assemble the params for this synapse.                
                these_params.c_ks = c_ks( k );
                these_params.R_ks = R_ks( k );
                these_params.Gm_n = Gm_n;
                these_params.dEs_nks = dEs_nks( k );
                these_params.Ia_n = Ia_n;
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is relative...
                
                % Unpack the params.
                c_ks = params.c_ks;                                                % [-] Subnetwork Gain.
                R_n = params.R_n;                                              % [V] Maximum Membrane Voltage.
                Gm_n = params.Gm_n;                                             % [S] Membrane Conductance.
                dEs_nk = params.dEs_nk;                                           % [V] Synaptic Reversal Potential.
                Ia_n = params.Ia_n;                                             % [A] Applied Current.
                                
                % Assemble the params for this synapse.                
                these_params.c_ks = c_ks( k );
                these_params.R_n = R_n;
                these_params.Gm_n = Gm_n;
                these_params.dEs_nk = dEs_nk( k );
                these_params.Ia_n = Ia_n;
                
            else
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to retrieve subtraction subnetwork params.
        function these_params = get_subtraction_gs_params( ~, k, params, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end      % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                   % [struct] Parameters Structure.
            
            % Determine how to unpack the params for this synapse.
            if strcmpi( encoding_scheme, 'absolute' )                               % If the encoding scheme is absolute...

                % Unpack the params.
                c_ks = params.c_ks;                                                % [-] Subnetwork Gain.
                s_ks = params.s_ks;                                             % [-1/+1] Input Signature.
                R_ks = params.R_ks;                                             % [V] Maximum Membrane Voltage.
                Gm_n = params.Gm_n;                                             % [S] Membrane Conductance.
                dEs_nks = params.dEs_nks;                                          % [V] Synaptic Reversal Potential.
                Ia_n = params.Ia_n;                                             % [A] Applied Current.
                
                % Assemble the params for this synapse.
                these_params.c_ks = c_ks( k );
                these_params.s_ks = s_ks( k );
                these_params.R_ks = R_ks( k );
                these_params.Gm_n = Gm_n;
                these_params.dEs_nks = dEs_nks( k );
                these_params.Ia_n = Ia_n;
                
            elseif strcmpi( encoding_scheme, 'relative' )                           % If the encoding scheme is relative...

                % Unpack the params.
                c_ks = params.c_ks;                                                % [-] Subnetwork Gain.
                s_ks = params.s_ks;                                             % [-1/+1] Input Signature.
                R_n = params.R_n;                                             % [V] Maximum Membrane Voltage.
                Gm_n = params.Gm_n;                                             % [S] Membrane Conductance.
                dEs_nks = params.dEs_nks;                                          % [V] Synaptic Reversal Potential.
                Ia_n = params.Ia_n;                                             % [A] Applied Current.
                
                % Assemble the params for this synapse.
                these_params.c_ks = c_ks( k );
                these_params.s_ks = s_ks( k );
                these_params.R_n = R_n;
                these_params.Gm_n = Gm_n;
                these_params.dEs_nks = dEs_nks( k );
                these_params.Ia_n = Ia_n;
                
            else

                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )

            end
            
        end

        
        %% Synaptic Reversal Potential Compute Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 21 of a transmission subnetwork.
        function [ dEs21, synapses, self ] = compute_transmission_dEs21( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = encoding_scheme_DEFAULT; end                       % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.                
            [ dEs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_transmission_dEs21( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential of absolute addition subnetwork synapses.
        function [ dEs, synapses, self ] = compute_addition_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_addition_dEs( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential of subtraction subnetwork excitatory synapses.
        function [ dEs, synapses, self ] = compute_subtraction_dEs_excitatory( self, synapse_IDs_excitatory, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs_excitatory = 'all'; end                                	% [-] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs_excitatory = self.validate_synapse_IDs( synapse_IDs_excitatory, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs_excitatory );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs_excitatory( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_excitatory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of subtraction subnetwork inhibitory synapses.
        function [ dEs, synapses, self ] = compute_subtraction_dEs_inhibitory( self, synapse_IDs_inhibitory, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs_inhibitory = 'all'; end                                	% [-] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs_inhibitory = self.validate_synapse_IDs( synapse_IDs_inhibitory, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs_inhibitory );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs_inhibitory( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_inhibitory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
               
        % Implement a function to compute and set the synaptic reversal potential of subtraction subnetwork synapses.
        function [ dEs, synapses, self ] = compute_subtraction_dEs( self, synapse_IDs, s_ks, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, s_ks = self.signature_DEFAULT; end                                   % [+1/-1] Subtraction Signature.
            if nargin < 2, synapse_IDs = 'all'; end                                          	% [-] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Determine whether this synapse is excitatory or inhibitory.
                if s_ks( k ) == 1                   % If this synapse is excitatory...
                
                    % Compute and set the required parameter for this synapse.
                    [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_excitatory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
                elseif s_ks( k ) == -1              % If this synapse is inhibitory...
                    
                    % Compute and set the required parameter for this synapse.
                    [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_inhibitory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                    
                else                                % Otherwise...
                   
                    % Throw an error.
                    error( 'Invalid subtraction signature.  Must be either: +1 or -1.' )
                    
                end
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 21 of an inversion subnetwork.
        function [ dEs21, synapses, self ] = compute_inversion_dEs21( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_inversion_dEs21( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the synaptic reversal potential for synapse 21 of a reduced inversion subnetwork.
        function [ dEs21, synapses, self ] = compute_reduced_inversion_dEs21( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_inversion_dEs21( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 31 of a division subnetwork.
        function [ dEs31, synapses, self ] = compute_division_dEs31( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_dEs31( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a division subnetwork.
        function [ dEs32, synapses, self ] = compute_division_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
                
        
        % Implement a function to compute and set the synaptic reversal ptoential for the synapses of a division subnetwork.
        function [ dEs, synapses, self ] = compute_division_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 31.
            [ dEs31, synapses, synapse_manager ] = self.compute_division_dEs31( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_division_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
            
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to compute and set the synaptic reversal potential for synapse 31 of a reduced division subnetwork.
        function [ dEs31, synapses, self ] = compute_reduced_division_dEs31( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_division_dEs31( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                       
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a reduced division subnetwork.
        function [ dEs32, synapses, self ] = compute_reduced_division_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_division_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );

            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
            
        
        % Implement a function to compute and set the synaptic reversal ptoential for the synapses of a reduced division subnetwork.
        function [ dEs, synapses, self ] = compute_reduced_division_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 31.
            [ dEs31, synapses, synapse_manager ] = self.compute_reduced_division_dEs31( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_division_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
         
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the synaptic reversal potential for synapse 31 of a division after inversion subnetwork.
        function [ dEs31, synapses, self ] = compute_dai_dEs31( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_dai_dEs31( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                  
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a division after inversion subnetwork.
        function [ dEs32, synapses, self ] = compute_dai_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_dai_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                         
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
                
        
        % Implement a function to compute and set the synaptic reversal ptoential for the synapses of a division after inversion subnetwork.
        function [ dEs, synapses, self ] = compute_dai_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 31.
            [ dEs31, synapses, synapse_manager ] = self.compute_dai_dEs31( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_dai_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
            
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the synaptic reversal potential for synapase 31 of a reduced division after inversion subnetwork.
        function [ dEs31, synapses, self ] = compute_reduced_dai_dEs31( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_dai_dEs31( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a reduced division after inversion subnetwork.
        function [ dEs32, synapses, self ] = compute_reduced_dai_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_dai_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                                        
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
                
        
        % Implement a function to compute and set the synaptic reversal ptoential for the synapses of a reduced division after inversion subnetwork.
        function [ dEs, synapses, self ] = compute_reduced_dai_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 31.
            [ dEs31, synapses, synapse_manager ] = self.compute_reduced_dai_dEs31( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_dai_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs31, dEs32 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
            
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 41 of a multiplication subnetwork.
        function [ dEs41, synapses, self ] = compute_multiplication_dEs41( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute the required parameter for this synapse.
            [ dEs41, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs41( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );

            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a multiplication subnetwork.
        function [ dEs32, synapses, self ] = compute_multiplication_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 43 of a multiplication subnetwork.
        function [ dEs43, synapses, self ] = compute_multiplication_dEs43( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 3 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs43, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs43( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for the synapses of a multiplication subnetwork.
        function [ dEs, synapses, self ] = compute_multiplication_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 41.
            [ dEs41, synapses, synapse_manager ] = self.compute_multiplication_dEs41( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_multiplication_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 43.
            [ dEs43, synapses, synapse_manager ] = synapse_manager.compute_multiplication_dEs43( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs41, dEs32, dEs43 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
            
        
        % ---------- Rduced Multiplication Subnetwork Functions ----------

        % Implement a function to compute and set the synaptic reversal potential for synapse 41 of a reduced multiplication subnetwork.
        function [ dEs41, synapses, self ] = compute_reduced_multiplication_dEs41( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute the required parameter for this synapse.
            [ dEs41, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_dEs41( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 32 of a reduced multiplication subnetwork.
        function [ dEs32, synapses, self ] = compute_reduced_multiplication_dEs32( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_dEs32( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for synapse 43 of a reduced multiplication subnetwork.
        function [ dEs43, synapses, self ] = compute_reduced_multiplication_dEs43( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 3 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ dEs43, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_dEs43( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential for the synapses of a reduced multiplication subnetwork.
        function [ dEs, synapses, self ] = compute_reduced_multiplication_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Compute the synaptic reversal potential for synapse 41.
            [ dEs41, synapses, synapse_manager ] = self.compute_reduced_multiplication_dEs41( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 32.
            [ dEs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_multiplication_dEs32( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Compute the synaptic reversal potential for synapse 43.
            [ dEs43, synapses, synapse_manager ] = synapse_manager.compute_reduced_multiplication_dEs43( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials.
            dEs = [ dEs41, dEs32, dEs43 ];
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = synapse_manager; end
            
        end    
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function [ dEs1, synapses, self ] = compute_derivation_dEs31( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_derivation_dEs31( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function [ dEs2, synapses, self ] = compute_derivation_dEs32( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_derivation_dEs32( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, synapses, self ] = compute_integration_dEs1( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_integration_dEs1( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, synapses, self ] = compute_integration_dEs2( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_integration_dEs2( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, synapses, self ] = compute_vbi_dEs1( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_vbi_dEs1( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, synapses, self ] = compute_vbi_dEs2( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                                % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_vbi_dEs2( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to compute and set the synaptic reversal potential of a driven multistate cpg subnetwork.
        function [ dEs, synapses, self ] = compute_dmcpg_dEs( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [  dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_dmcpg_dEs( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        %% Parameter Unpacking Functions.
        
        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to unpack the params for an absolute transmission subnetwork.
        function [ c, x1_max, Gm2 ] = unpack_absolute_transmission_params( self, transmission_params )
            
            % Absolute: c, x1_max, Gm2

            % Set the default input arguments.
            if nargin < 2, transmission_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( transmission_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c = self.c_absolute_transmission_DEFAULT;                                                                   	% [-] Subnetwork Gain.
                x1_max = self.x1max_absolute_transmission_DEFAULT;                                                              % [-] Maximum Decoded Input.
                Gm2 = self.Gm_DEFAULT;                                                                                          % [S] Membrane Conductance.
                
            elseif length( fieldnames( transmission_params ) ) == 3                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c = transmission_params.c;                                                                            	% [-] Subnetwork Gain.
                x1_max = transmission_params.x1_max;                                                                          % [-] Maximum Decoded Input.
                Gm2 = transmission_params.Gm2;                                                                            	% [S] Membrane Conductance.
            
            else                                                                                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a relative transmission subnetwork.
        function [ R2, Gm2 ] = unpack_relative_transmission_params( self, transmission_params )
            
            % Relative: R2, Gm2

            % Set the default input arguments.
            if nargin < 2, transmission_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( transmission_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                R2 = self.R_DEFAULT;                                                                                % [V] Activation Domain.                                                                                            % [V] Activation Domain.
                Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.                                                                                          % [S] Membrane Conductance.
                
            elseif length( fieldnames( transmission_params ) ) == 2                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                R2 = transmission_params.R2;                                                                            	% [V] Activation Domain.
                Gm2 = transmission_params.Gm2;                                                                          	% [S] Membrane Conductance.
            
            else                                                                                                                % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to unpack the params for an absolute addition subnetwork.
        function [ c_k, R_k, Gm_n, Ia_n ] = unpack_absolute_addition_params( self, synapse_IDs, addition_params )
            
            % Absolute: c_k, R_k, Gm_n, Ia_n

            % Set the default input arguments.
            if nargin < 3, addition_params = struct( [  ] ); end                                                       	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( addition_params )                                                                       % If the params are empty...
            
                % Compute the number of synapse IDs.
                num_synapse_IDs = length( synapse_IDs );
                
                % Set the params to default values.
                c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs );                                                    % [-] Subnetwork Gain.
                R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                    % [V] Maximum Membrane Voltage.
                Gm_n = self.Gm_DEFAULT;                                                                             % [S] Membrane Conductance.
                Ia_n = self.Ia_DEFAULT;                                                                             % [A] Applied Current.
                                
            elseif length( fieldnames( addition_params ) ) == 4                                                             	% If there are a specific number of params...
                
                % Unpack the params.
                c_k = addition_params.c_k;                                                                     % [-] Subnetwork Gain.
                R_k = addition_params.R_k;                                                                   	% [V] Maximum Membrane Voltage.
                Gm_n = addition_params.Gm_n;                                                                    % [S] Membrane Conductance.
                Ia_n = addition_params.Ia_n;                                                                   	% [A] Applied Current.
            
            else                                                                                                   	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a relative addition subnetwork.
        function [ c_k, R_n, Gm_n, Ia_n ] = unpack_relative_addition_params( self, synapse_IDs, addition_params )
            
            % Relative: c_k, R_n, Gm_n, Ia_n

            % Set the default input arguments.
            if nargin < 3, addition_params = struct( [  ] ); end                                                       	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( addition_params )                                                                       % If the params are empty...
            
                % Compute the number of synapse IDs.
                num_synapse_IDs = length( synapse_IDs );
                
                % Set the params to default values.
                c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs );                                                	% [-] Subnetwork Gain.
                R_n = self.R_DEFAULT;                                                                               % [V] Maximum Membrane Voltage.
                Gm_n = self.Gm_DEFAULT;                                                                             % [S] Membrane Conductance.
                Ia_n = self.Ia_DEFAULT;                                                                             % [A] Applied Current.
                
            elseif length( fieldnames( addition_params ) ) == 4                                                             	% If there are a specific number of params...
                
                % Unpack the params.
                c_k = addition_params.c_k;                                                                     % [-] Subnetwork Gain.
                R_n = addition_params.R_n;                                                                   	% [V] Maximum Membrane Voltage.
                Gm_n = addition_params.Gm_n;                                                                    % [S] Membrane Conductance.
                Ia_n = addition_params.Ia_n;                                                                   	% [A] Applied Current.
            
            else                                                                                                   	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        

        % ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to unpack the params for an absolute subtraction subnetwork.
        function [ c_k, s_k, R_k, Gm_n, Ia_n ] = unpack_absolute_subtraction_params( self, synapse_IDs, subtraction_params )
            
            % Absolute: c_k, s_k, R_k, Gm_n, Ia_n

            % Set the default input arguments.
            if nargin < 3, subtraction_params = struct( [  ] ); end                                                            	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( subtraction_params )                                                                            % If the params are empty...
            
                % Compute the number of synapse IDs.
                num_synapse_IDs = length( synapse_IDs );
                
                % Set the default parameter values.
                c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs );                                                         	% [-] Subnetwork Gain.
                s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [-] Input Signature.
                R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [V] Maximum Membrane Voltage.
                Gm_n = self.Gm_DEFAULT;                                                                                     % [S] Membrane Conductance.
                Ia_n = self.Ia_DEFAULT;                                                                                     % [A] Applied Current.
                                
            elseif length( fieldnames( subtraction_params ) ) == 5                                                                    % If there are a specific number of params...
                
                % Unpack the params.
                c_k = subtraction_params.c_k;                                                                          % [-] Subnetwork Gain.
                s_k = subtraction_params.s_k;                                                                          % [-] Input Signature.
                R_k = subtraction_params.R_k;                                                                          % [V] Maximum Membrane Voltage.
                Gm_n = subtraction_params.Gm_n;                                                                        	% [S] Membrane Conductance.
                Ia_n = subtraction_params.Ia_n;                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
                    
        % Implement a function to unpack the params for a relative subtraction subnetwork.
        function [ c_k, s_k, R_k, Gm_n, Ia_n ] = unpack_relative_subtraction_params( self, synapse_IDs, subtraction_params )
            
            % Relative: c_k, s_k, R_k, Gm_n, Ia_n

            % Set the default input arguments.
            if nargin < 3, subtraction_params = struct( [  ] ); end                                                            	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( subtraction_params )                                                                            % If the params are empty...
            
                % Compute the number of synapse IDs.
                num_synapse_IDs = length( synapse_IDs );
                
                % Set the default parameter values.
                c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs );                                                         	% [-] Subnetwork Gain.
                s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs );                                                            % [-] Input Signature.
                R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs );                                                         	% [V] Maximum Membrane Voltage. 
                Gm_n = self.Gm_DEFAULT;                                                                                     % [S] Membrane Conductance.
                Ia_n = self.Ia_DEFAULT;                                                                                     % [A] Applied Current.

            elseif length( fieldnames( subtraction_params ) ) == 5                                                                    % If there are a specific number of params...
                
                % Unpack the params.
                c_k = subtraction_params.c_k;                                                                          % [-] Subnetwork Gain.
                s_k = subtraction_params.s_k;                                                                          % [-] Input Signature.
                R_k = subtraction_params.R_k;                                                                          % [V] Maximum Membrane Voltage.
                Gm_n = subtraction_params.Gm_n;                                                                        	% [S] Membrane Conductance.
                Ia_n = subtraction_params.Ia_n;                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------

        % Implement a function to unpack the params for an absolute inversion subnetwork.
        function [ c1, c3, delta, Gm2 ] = unpack_absolute_inversion_params( self, inversion_params )
            
            % Set the default input arguments.
            if nargin < 2, inversion_params = struct( [  ] ); end                                                 	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( inversion_params )                                                                       	% If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_absolute_inversion_DEFAULT;
                c3 = self.c3_absolute_inversion_DEFAULT;
                delta = self.delta_absolute_inversion_DEFAULT;                                                        	% [V] Inversion Subnetwork Offset.
                Gm2 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.                                                                                 	% [S] Membrane Conductance.
                                
            elseif length( fieldnames( inversion_params ) ) == 4                                                    % If there are a specific number of params...
                
                % Unpack the params.
                c1 = inversion_params.c1;
                c3 = inversion_params.c3;
                delta = inversion_params.delta;                                                                    	% [V] Inversion Subnetwork Offset.
                Gm2 = inversion_params.Gm2;                                                                       	% [S] Membrane Conductance.
            
            else                                                                                                       	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a relative inversion subnetwork.
        function [ c1, c3, delta, R2, Gm2 ] = unpack_relative_inversion_params( self, inversion_params )
            
            % Set the default input arguments.
            if nargin < 2, inversion_params = struct( [  ] ); end                                                            	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( inversion_params )                                                                       	% If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_absolute_inversion_DEFAULT;
                c3 = self.c3_absolute_inversion_DEFAULT;
                delta = self.delta_absolute_inversion_DEFAULT;                                                        	% [V] Inversion Subnetwork Offset.
                R2 = self.R_DEFAULT;
                Gm2 = self.Gm_DEFAULT;                                                                                  % [S] Membrane Conductance.     
                                
            elseif length( fieldnames( inversion_params ) ) == 5                                                                	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = inversion_params.c1;
                c3 = inversion_params.c3;
                delta = inversion_params.delta;                                                                    	% [V] Inversion Subnetwork Offset.
                R2 = inversion_params.R2;
                Gm2 = inversion_params.Gm2;                                                                       	% [S] Membrane Conductance.
            
            else                                                                                                       	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to unpack the params for a reduced absolute inversion subnetwork.
        function [ c1, delta, x1_max, Gm2 ] = unpack_reduced_absolute_inversion_params( self, inversion_params )
            
            % Absolute: delta1, Gm2, Ia2

            % Set the default input arguments.
            if nargin < 2, inversion_params = struct( [  ] ); end                                                            	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( inversion_params )                                                                       	% If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_reduced_absolute_inversion_DEFAULT;                                                                	% [V] Inversion Subnetwork Offset.
                delta = self.delta_reduced_absolute_inversion_DEFAULT;
                x1_max = self.x1max_reduced_absolute_inversion_DEFAULT;
                Gm2 = self.Gm_DEFAULT;                                                                              % [S] Membrane Conductance.                                                                                 	% [S] Membrane Conductance.
                
            elseif length( fieldnames( inversion_params ) ) == 4                                                                	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = inversion_params.c1;
                delta = inversion_params.delta;
                x1_max = inversion_params.x1_max;
                Gm2 = inversion_params.Gm2;                                                                       	% [S] Membrane Conductance.
            
            else                                                                                                       	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a reduced relative inversion subnetwork.
        function [ c1, delta, x1_max, Gm2 ] = unpack_reduced_relative_inversion_params( self, inversion_params )
            
            % Set the default input arguments.
            if nargin < 2, inversion_params = struct( [  ] ); end                                                            	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( inversion_params )                                                                       	% If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_reduced_relative_DEFAULT;
                delta = self.delta_reduced_relative_DEFAULT;
                x1_max = self.x1max_reduced_relative_DEFAULT;
                Gm2 = self.Gm_reduced_relative_DEFAULT;
                
            elseif length( fieldnames( inversion_params ) ) == 4                                                                	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = inversion_params.c1;
                delta = inversion_params.delta;
                x1_max = inversion_params.x1_max;
                Gm2 = inversion_params.Gm2;
                
            else                                                                                                       	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to unpack the gs params for an absolute division subnetwork.
        function [ c1, c3, delta, x1_max, Gm3, dEs31 ] = unpack_absolute_division_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_absolute_division_DEFAULT;
                c3 = self.c3_absolute_division_DEFAULT;
                delta = self.delta_absolute_division_DEFAULT;
                x1_max = self.x1max_absolute_division_DEFAULT;
                Gm3 = self.Gm_absolute_division_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );       	% [V] Synaptic Reversal Potential.

            elseif length( fieldnames( division_params ) ) == 6                                                                       % If there are a specific number of params...
                
                % Store the required params.                    
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
                
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the gs params for a relative division subnetwork.
        function [ c1, c3, delta, x1_max, R3, Gm3, dEs31 ] = unpack_relative_division_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                         	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                                   % If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_relative_division_DEFAULT;
                c3 = self.c3_relative_division_DEFAULT;
                delta = self.delta_relative_division_DEFAULT;
                x1_max = self.x1max_relative_division_DEFAULT;
                R3 = self.R_relative_division_DEFAULT;
                Gm3 = self.Gm_relative_division_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 7                                                            	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
                
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for an absolute division subnetwork.
        function [ c1, c3, delta, x1_max, Gm3 ] = unpack_absolute_division_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                    % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                          	% If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_absolute_division_DEFAULT;
                c3 = self.c3_absolute_division_DEFAULT;
                delta = self.delta_absolute_division_DEFAULT;
                x1_max = self.x1max_absolute_division_DEFAULT;
                Gm3 = self.Gm_absolute_division_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 5                                                     % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                Gm3 = division_params.Gm3;
            
            else                                                                                                   	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a relative division subnetwork.
        function [ c1, c3, delta, x1_max, R3, Gm3 ] = unpack_relative_division_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                    	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_relative_division_DEFAULT;
                c3 = self.c3_relative_division_DEFAULT;
                delta = self.delta_relative_division_DEFAULT;
                x1_max = self.x1max_relative_division_DEFAULT;
                R3 = self.R_relative_division_DEFAULT;
                Gm3 = self.Gm_relative_division_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 6                                                        	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
            
            else                                                                                                     	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to unpack the design params for a reduced absolute division subnetwork.
        function [ c1, delta, x1_max, x2_max, Gm3, dEs31 ] = unpack_reduced_absolute_division_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduced_absolute_division_DEFAULT;
                delta = self.delta_reduced_absolute_division_DEFAULT;
                x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );        % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 6                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
                
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the design params for a reduced relative division subnetwork.
        function [ c1, delta, x2_max, R3, Gm3, dEs31 ] = unpack_reduced_relative_division_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
                
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                        % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the default parameter values.
                c1 = self.c1_reduced_relative_division_DEFAULT;
                delta = self.delta_reduced_relative_division_DEFAULT;
                x2_max = self.x2max_reduced_relative_division_DEFAULT;
                R3 = self.R_reduced_relative_division_DEFAULT;
                Gm3 = self.Gm_reduced_relative_division_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );       	% [V] Synaptic Reversal Potential.
                                    
            elseif length( fieldnames( division_params ) ) == 6                                                        	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta = division_params.delta;
                x2_max = division_params.x2_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
            
            else                                                                                                      	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
            
        % Implement a function to unpack the params for a reduced absolute division subnetwork.
        function [ c1, delta, x1_max, x2_max, Gm3 ] = unpack_reduced_absolute_division_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduced_absolute_division_DEFAULT;
                delta = self.delta_reduced_absolute_division_DEFAULT;
                x1_max = self.x1max_reduced_absolute_division_DEFAULT;
                x2_max = self.x2max_reduced_absolute_division_DEFAULT;
                Gm3 = self.Gm_reduced_absolute_division_DEFAULT;
                                
            elseif length( fieldnames( division_params ) ) == 5                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta = division_params.delta;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                Gm3 = division_params.Gm3;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a reduced relative division subnetwork.
        function [ c1, delta, x2_max, R3, Gm3 ] = unpack_reduced_relative_division_params( self, division_params )
                        
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduced_relative_division_DEFAULT;
                delta = self.delta_reduced_relative_division_DEFAULT;
                x2_max = self.x2max_reduced_relative_division_DEFAULT;
                R3 = self.R_reduced_relative_division_DEFAULT;
                Gm3 = self.Gm_reduced_relative_division_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 5                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta = division_params.delta;
                x2_max = division_params.x2_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        % Implement a function to unpack the design params for an absolute division after inversion subnetwork.
        function [ c1, c3, delta2, x1_max, Gm3, dEs31 ] = unpack_absolute_dai_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_absolute_dia_DEFAULT;
                c3 = self.c3_absolute_dia_DEFAULT;
                delta2 = self.delta2_absolute_dia_DEFAULT;
                x1_max = self.x1max_absolute_dia_DEFAULT;
                Gm3 = self.Gm_absolute_dia_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 6                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the design params for a relative division after inversion subnetwork.
        function [ c1, c3, delta2, x1_max, x2_max, R1, R2, Gm3, dEs31 ] = unpack_relative_dai_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_relative_dai_DEFAULT;
                c3 = self.c3_relative_dai_DEFAULT;
                delta2 = self.delta2_relative_dai_DEFAULT;
                x1_max = self.x1max_relative_dai_DEFAULT;
                x2_max = self.x2max_relative_dai_DEFAULT;
                R1 = self.R_relative_dai_DEFAULT;
                R2 = self.R_relative_dai_DEFAULT;
                Gm3 = self.Gm_relative_dai_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 9                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                R1 = division_params.R1;
                R2 = division_params.R2;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for an absolute division after inversion subnetwork.
        function [ c1, c3, delta2, x1_max, Gm3 ] = unpack_absolute_dai_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                      	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_absolute_dia_DEFAULT;
                c3 = self.c3_absolute_dia_DEFAULT;
                delta2 = self.delta2_absolute_dia_DEFAULT;
                x1_max = self.x1max_absolute_dia_DEFAULT;
                Gm3 = self.Gm_absolute_dia_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 5                                                        	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                Gm3 = division_params.Gm3;
            
            else                                                                                                    	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a relative division after inversion subnetwork.
        function [ c1, c3, delta2, x1_max, x2_max, R1, R2, Gm3 ] = unpack_relative_dai_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_relative_dai_DEFAULT;
                c3 = self.c3_relative_dai_DEFAULT;
                delta2 = self.delta2_relative_dai_DEFAULT;
                x1_max = self.x1max_relative_dai_DEFAULT;
                x2_max = self.x2max_relative_dai_DEFAULT;
                R1 = self.R_relative_dai_DEFAULT;
                R2 = self.R_relative_dai_DEFAULT;
                Gm3 = self.Gm_relative_dai_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 8                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                c3 = division_params.c3;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                R1 = division_params.R1;
                R2 = division_params.R2;
                Gm3 = division_params.Gm3;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        % Implement a function to unpack the design params for a reduced absolute division after inversion subnetwork.
        function [ c1, delta2, x1_max, x2_max, Gm3, dEs31 ] = unpack_reduced_absolute_dai_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduce_absolute_dai_DEFAULT;
                delta2 = self.delta2_reduce_absolute_dai_DEFAULT;
                x1_max = self.x1max_reduce_absolute_dai_DEFAULT;
                x2_max = self.x2max_reduce_absolute_dai_DEFAULT;
                Gm3 = self.Gm_reduce_absolute_dai_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 6                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
                
        % Implement a function to unpack the design params for a reduced relative division after inversion subnetwork.
        function [ c1, delta1, delta2, x1_max, x2_max, R3, Gm3, dEs31 ] = unpack_reduced_relative_dai_gs_params( self, synapse_IDs, division_params, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, division_params = struct( [  ] ); end                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                                                               % If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduced_relative_dai_DEFAULT;
                delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                R3 = self.R_reduced_relative_dai_DEFAULT;
                Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );          % [V] Synaptic Reversal Potential.
                
            elseif length( fieldnames( division_params ) ) == 8                                                                       % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta1 = division_params.delta1;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
                dEs31 = division_params.dEs31;
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end

        
        % Implement a function to unpack the params for a reduced absolute division after inversion subnetwork.
        function [ c1, delta2, x1_max, x2_max, Gm3 ] = unpack_reduced_absolute_dai_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                       	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                             	% If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduce_absolute_dai_DEFAULT;
                delta2 = self.delta2_reduce_absolute_dai_DEFAULT;
                x1_max = self.x1max_reduce_absolute_dai_DEFAULT;
                x2_max = self.x2max_reduce_absolute_dai_DEFAULT;
                Gm3 = self.Gm_reduce_absolute_dai_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 5                         % If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                Gm3 = division_params.Gm3;
            
            else                                                                       	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a reduced relative division after inversion subnetwork.
        function [ c1, delta1, delta2, x1_max, x2_max, R3, Gm3 ] = unpack_reduced_relative_dai_params( self, division_params )
            
            % Set the default input arguments.
            if nargin < 2, division_params = struct( [  ] ); end                                  % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( division_params )                                             	% If the params are empty...
            
                % Set the params to default values.
                c1 = self.c1_reduced_relative_dai_DEFAULT;
                delta1 = self.delta1_reduced_relative_dai_DEFAULT;
                delta2 = self.delta2_reduced_relative_dai_DEFAULT;
                x1_max = self.x1max_reduced_relative_dai_DEFAULT;
                x2_max = self.x2max_reduced_relative_dai_DEFAULT;
                R3 = self.R_reduced_relative_dai_DEFAULT;
                Gm3 = self.Gm_reduced_relative_dai_DEFAULT;
                
            elseif length( fieldnames( division_params ) ) == 7                                     	% If there are a specific number of params...
                
                % Unpack the params.
                c1 = division_params.c1;
                delta1 = division_params.delta1;
                delta2 = division_params.delta2;
                x1_max = division_params.x1_max;
                x2_max = division_params.x2_max;
                R3 = division_params.R3;
                Gm3 = division_params.Gm3;
            
            else                                                                         	% Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end

        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to unpack the design params for an absolute multiplication subnetwork.
        function [ c4, c6, delta1, delta2, R1, R3, Gm3, dEs41, dEs32, Ia3 ] = unpack_absolute_multiplication_gs_params( self, synapse_IDs, multiplication_params, synapses, undetected_option )
            
            % Absolute: c4, c6, delta1, delta2, R1, R3, Gm3, dEs41, dEs32, Ia3

            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, multiplication_params = struct( [  ] ); end                                                         	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                      	% If the params are empty...
            
                % Set the params to default values.
                c4 = self.c1_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 1.
                c6 = self.c3_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 3.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R1 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );           	% [V] Synaptic Reversal Potential.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 10                                                              	% If there are a specific number of params...
                
                % Unpack the params.
                c4 = multiplication_params.c4;
                c6 = multiplication_param.c6;
                delta1 = multiplication_params.delta1;                                                                 	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                 	% [V] Division Subnetwork Offset.
                R1 = multiplication_params.R1;                                                                      	% [V] Activation Domain.
                R3 = multiplication_params.R3;                                                                       	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                     	% [S] Membrane Conductance.
                dEs41 = multiplication_params.dEs41;                                                                    	% [V] Synaptic Reversal Potential.
                dEs32 = multiplication_params.dEs32;                                                                  	% [V] Synaptic Reversal Potential.
                Ia3 = multiplication_params.Ia3;                                                                     	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
                    
            
        % Implement a function to unpack the design params for a relative multiplication subnetwork.
        function [ c4, c6, delta1, delta2, R3, Gm3, dEs41, Ia3 ] = unpack_relative_multiplication_gs_params( self, synapse_IDs, multiplication_params, synapses, undetected_option )
            
            % Relative: c4, c6, delta1, delta2, R3, Gm3, dEs41, Ia3

            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                     	% If the params are empty...
            
                % Set the params to default values.
                c4 = self.c1_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 1.
                c6 = self.c3_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 3.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 10                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                c4 = multiplication_params.c4;
                c6 = multiplication_params.c6;
                delta1 = multiplication_params.delta1;                                                                	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                   	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                      	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                      	% [S] Membrane Conductance.
                dEs41 = multiplication_params.dEs41;                                                                    	% [V] Synaptic Reversal Potential.
                Ia3 = multiplication_params.Ia3;                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end

        
        % Implement a function to unpack the params for an absolute multiplication subnetwork.
        function [ c4, c6, delta1, delta2, R1, R3, Gm3, Ia3 ] = unpack_absolute_multiplication_params( self, multiplication_params )
            
            % Absolute: c4, c6, delta1, delta2, R1, R3, Gm3, Ia3

            % Set the default input arguments.
            if nargin < 2, multiplication_params = struct( [  ] ); end                                                         	% [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                      	% If the params are empty...
            
                % Set the params to default values.
                c4 = self.c1_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 1.
                c6 = self.c3_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 3.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R1 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 8                                                              	% If there are a specific number of params...
                
                % Unpack the params.
                c4 = multiplication_params.c4;
                c6 = multiplication_params.c6;
                delta1 = multiplication_params.delta1;                                                                 	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                 	% [V] Division Subnetwork Offset.
                R1 = multiplication_params.R1;                                                                      	% [V] Activation Domain.
                R3 = multiplication_params.R3;                                                                       	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                     	% [S] Membrane Conductance.
                Ia3 = multiplication_params.Ia3;                                                                     	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
                    
        
        % Implement a function to unpack the params for a relative multiplication subnetwork.
        function [ c4, c6, delta1, delta2, R3, Gm3, Ia3 ] = unpack_relative_multiplication_params( self, multiplication_params )
            
            % Relative: c4, c6, delta1, delta2, R3, Gm3, Ia3

            % Set the default input arguments.
            if nargin < 2, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                     	% If the params are empty...
            
                % Set the params to default values.
                c4 = self.c1_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 1.
                c6 = self.c3_absolute_dai_DEFAULT;                                                                          % [-] Division Subnetwork Gain 3.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 7                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                c4 = multiplication_params.c4;
                c6 = multiplication_params.c6;
                delta1 = multiplication_params.delta1;                                                                	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                   	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                      	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                      	% [S] Membrane Conductance.
                Ia3 = multiplication_params.Ia3;                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end

        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to unpack the design params for a reduced absolute multiplication subnetwork.
        function [ delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3 ] = unpack_reduced_absolute_multiplication_gs_params( self, synapse_IDs, multiplication_params, synapses, undetected_option )
            
            % Absolute: delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3

            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                      	% If the params are empty...
            
                % Set the params to default values.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R4 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Gm4 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option );           	% [V] Synaptic Reversal Potential.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 9                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                delta1 = multiplication_params.delta1;                                                                  	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                 	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                      	% [V] Activation Domain.
                R4 = multiplication_params.R4;                                                                      	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                      	% [S] Membrane Conductance.
                Gm4 = multiplication_params.Gm4;                                                                     	% [S] Membrane Conductance.
                dEs41 = multiplication_params.dEs41;                                                                   	% [V] Synaptic Reversal Potential.
                dEs32 = multiplication_params.dEs32;                                                                   	% [V] Synaptic Reversal Potential.
                Ia3 = multiplication_params.Ia3;                                                                    	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        

        % Implement a function to unpack the design params for a reduced relative multiplication subnetwork.
        function [ delta1, delta2, R3, R4, Gm3, Gm4, dEs41, Ia3 ] = unpack_reduced_relative_multiplication_gs_params( self, synapse_IDs, multiplication_params, synapses, undetected_option )
            
            % Relative: delta1, delta2, R3, R4, Gm3, Gm4, dEs41, Ia3

            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                     	% If the params are empty...
            
                % Set the params to default values.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R4 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Gm4 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option );            % [V] Synaptic Reversal Potential.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 8                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                delta1 = multiplication_params.delta1;                                                                  	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                  	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                     	% [V] Activation Domain.
                R4 = multiplication_params.R4;                                                                       	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                     	% [S] Membrane Conductance.
                Gm4 = multiplication_params.Gm4;                                                                     	% [S] Membrane Conductance.
                dEs41 = multiplication_params.dEs41;                                                                    	% [V] Synaptic Reversal Potential.
                Ia3 = multiplication_params.Ia3;                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end

        
        % Implement a function to unpack the params for a reduced absolute multiplication subnetwork.
        function [ delta1, delta2, R3, R4, Gm3, Gm4, Ia3 ] = unpack_reduced_absolute_multiplication_params( self, multiplication_params )
            
            % Absolute: delta1, delta2, R3, R4, Gm3, Gm4, Ia3

            % Set the default input arguments.
            if nargin < 2, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                      	% If the params are empty...
            
                % Set the params to default values.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R4 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Gm4 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 7                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                delta1 = multiplication_params.delta1;                                                                  	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                 	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                      	% [V] Activation Domain.
                R4 = multiplication_params.R4;                                                                      	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                      	% [S] Membrane Conductance.
                Gm4 = multiplication_params.Gm4;                                                                     	% [S] Membrane Conductance.
                Ia3 = multiplication_params.Ia3;                                                                    	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        % Implement a function to unpack the params for a reduced relative multiplication subnetwork.
        function [ delta1, delta2, R3, R4, Gm3, Gm4, Ia3 ] = unpack_reduced_relative_multiplication_params( self, multiplication_params )
            
            % Relative: delta1, delta2, R3, R4, Gm3, Gm4, Ia3

            % Set the default input arguments.
            if nargin < 2, multiplication_params = struct( [  ] ); end                                                            % [-] Input Parameters Structure.
            
            % Determine how to set the params.
            if isempty( multiplication_params )                                                                     	% If the params are empty...
            
                % Set the params to default values.
                delta1 = self.delta_inversion_DEFAULT;                                                                      % [V] Inversion Subnetwork Offset.
                delta2 = self.delta_dai_DEFAULT;                                                                            % [V] Division Subnetwork Offset.
                R3 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                R4 = self.R_DEFAULT;                                                                                        % [V] Activation Domain.
                Gm3 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Gm4 = self.Gm_DEFAULT;                                                                                      % [S] Membrane Conductance.
                Ia3 = self.Ia3_absolute_division_DEFAULT;                                                                    % [A] Applied Current.
                
            elseif length( fieldnames( multiplication_params ) ) == 7                                                               	% If there are a specific number of params...
                
                % Unpack the params.
                delta1 = multiplication_params.delta1;                                                                  	% [V] Inversion Subnetwork Offset.
                delta2 = multiplication_params.delta2;                                                                  	% [V] Division Subnetwork Offset.
                R3 = multiplication_params.R3;                                                                     	% [V] Activation Domain.
                R4 = multiplication_params.R4;                                                                       	% [V] Activation Domain.
                Gm3 = multiplication_params.Gm3;                                                                     	% [S] Membrane Conductance.
                Gm4 = multiplication_params.Gm4;                                                                     	% [S] Membrane Conductance.
                Ia3 = multiplication_params{ 7 };                                                                      	% [A] Applied Current.
            
            else                                                                                                            % Otherwise...
               
                % Throw an error.
                error( 'Unable to unpack params.' )
                
            end 
            
        end
        
        
        %% Parameter Packing Functions.
        
        % ---------- Transmission Subnetwork Functions ----------

        % Implement a function to pack absolute transmission gs params.
        function params_gs = pack_absolute_transmission_gs_params( self, synapse_ID, c, x1_max, Gm2, dEs21, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, dEs21 = selfv.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_absolute_transmission_DEFAULT; end
            if nargin < 3, c = self.c_absolute_transmission_DEFAULT; end
            
            % Pack the params.
            params_gs.c = c;
            params_gs.x1_max = x1_max;
            params_gs.Gm2 = Gm2;
            params_gs.dEs21 = dEs21;
            
        end
        
        
        % Implement a function to pack relative transmission gs params.
        function params_gs = pack_relative_transmission_gs_params( self, synapse_ID, R2, Gm2, dEs21, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm2 = self.Gm_DEFAULT; end
            if nargin < 3, R2 = self.R_DEFAULT; end
            
            % Pack the params.
            params_gs.R2 = R2;
            params_gs.Gm2 = Gm2;
            params_gs.dEs21 = dEs21;
            
        end
        
        
        % Implement a function to pack absolute transmission params.
        function transmission_params = pack_absolute_transmission_params( self, c, x1_max, Gm2 )
            
            % Set the default input arguments.
            if nargin < 4, Gm2 = self.Gm_DEFAULT; end
            if nargin < 3, x1_max = self.x1max_absolute_transmission_DEFAULT; end
            if nargin < 2, c = self.c_absolute_transmission_DEFAULT; end
            
            % Pack the params.
            transmission_params.c = c;
            transmission_params.x1_max = x1_max;
            transmission_params.Gm2 = Gm2;
            
        end
        
        
        % Implement a function to pack relative transmission params.
        function transmission_params = pack_relative_transmission_params( self, R2, Gm2 )
            
            % Set the default input arguments.
            if nargin < 3, Gm2 = self.Gm_DEFAULT; end
            if nargin < 2, R2 = self.R_DEFAULT; end
                        
            % Pack the params.
            transmission_params.R2 = R2;
            transmission_params.Gm2 = Gm2;
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to pack absolute addition gs params.
        function params_gs = pack_absolute_addition_gs_params( self, synapse_IDs, c_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option )
            
            % Compute the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
                    
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, Ia_n = self.Ia_DEFAULT; end
            if nargin < 6, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs ); end
            if nargin < 3, c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs ); end
            
            % Pack the params.
            params_gs.c_k = c_k;
            params_gs.R_k = R_k;
            params_gs.Gm_n = Gm_n;
            params_gs.dEs_nk = dEs_nk;
            params_gs.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack relative addition gs params.
        function params_gs = pack_relative_addition_gs_params( self, synapse_IDs, c_k, R_n, Gm_n, dEs_nk, Ia_n, synapses, undetected_option )
            
            % Compute the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
                    
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, Ia_n = self.Ia_DEFAULT; end
            if nargin < 6, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_n = self.R_DEFAULT; end
            if nargin < 3, c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs ); end
            
            % Pack the params.
            params_gs.c_k = c_k;
            params_gs.R_n = R_n;
            params_gs.Gm_n = Gm_n;
            params_gs.dEs_nk = dEs_nk;
            params_gs.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack absolute addition params.
        function addition_params = pack_absolute_addition_params( self, c_k, R_k, Gm_n, Ia_n )
            
            % Set the default input arguments.
            if nargin < 5, Ia_n = self.Ia_DEFAULT; end
            if nargin < 4, Gm_n = self.Gm_DEFAULT; end
            if nargin < 3, R_k = self.R_DEFAULT; end
            if nargin < 2, c_k = self.c_absolute_addition_DEFAULT; end
                        
            % Pack the params.
            addition_params.c_k = c_k;
            addition_params.R_k = R_k;
            addition_params.Gm_n = Gm_n;
            addition_params.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack relative addition params.
        function addition_params = pack_relative_addition_params( self, c_k, R_n, Gm_n, Ia_n )
            
            % Set the default input arguments.
            if nargin < 5, Ia_n = self.Ia_DEFAULT; end
            if nargin < 4, Gm_n = self.Gm_DEFAULT; end
            if nargin < 3, R_n = self.R_DEFAULT; end
            if nargin < 2, c_k = self.c_relative_addition_DEFAULT; end
            
            % Pack the params.
            addition_params.c_k = c_k;
            addition_params.R_n = R_n;
            addition_params.Gm_n = Gm_n;
            addition_params.Ia_n = Ia_n;

        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to pack absolute subtraction gs params.
        function params_gs = pack_absolute_subtraction_gs_params( self, synapse_IDs, c_k, s_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option )

            % Compute the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
                    
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, Ia_n = self.Ia_DEFAULT; end
            if nargin < 6, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs ); end
            if nargin < 4, s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs ); end
            if nargin < 3, c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs ); end
            
            % Pack the params.
            params_gs.c_k = c_k;
            params_gs.s_k = s_k;
            params_gs.R_k = R_k;
            params_gs.Gm_n = Gm_n;
            params_gs.dEs_nk = dEs_nk;
            params_gs.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack relative subtraction gs params.
        function params_gs = pack_relative_subtraction_gs_params( self, synapse_IDs, c_k, s_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option )

            % Compute the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
                    
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, Ia_n = self.Ia_DEFAULT; end
            if nargin < 6, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_k = self.R_DEFAULT*ones( 1, num_synapse_IDs ); end
            if nargin < 4, s_k = self.s_DEFAULT*ones( 1, num_synapse_IDs ); end
            if nargin < 3, c_k = self.c_DEFAULT*ones( 1, num_synapse_IDs ); end
            
            % Pack the params.
            params_gs.c_k = c_k;
            params_gs.s_k = s_k;
            params_gs.R_k = R_k;
            params_gs.Gm_n = Gm_n;
            params_gs.dEs_nk = dEs_nk;
            params_gs.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack absolute subtraction params.
        function subtraction_params = pack_absolute_subtraction_params( self, c_k, s_k, R_k, Gm_n, Ia_n )
            
            % Set the default input arguments.
            if nargin < 6, Ia_n = self.Ia_DEFAULT; end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_k = self.R_DEFAULT; end
            if nargin < 3, s_k = self.signature_DEFAULT; end
            if nargin < 2, c_k = self.c_absolute_subtraction_DEFAULT; end
            
            % Pack the params.
            subtraction_params.c_k = c_k;
            subtraction_params.s_k = s_k;
            subtraction_params.R_k = R_k;
            subtraction_params.Gm_n = Gm_n;
            subtraction_params.Ia_n = Ia_n;

        end
        
        
        % Implement a function to pack relative subtraction params.
        function subtraction_params = pack_relative_subtraction_params( self, c_k, s_k, R_k, Gm_n, Ia_n )
            
            % Set the default input arguments.
            if nargin < 6, Ia_n = self.Ia_DEFAULT; end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_k = self.R_DEFAULT; end
            if nargin < 3, s_k = self.signature_DEFAULT; end
            if nargin < 2, c_k = self.c_absolute_subtraction_DEFAULT; end
            
            % Pack the params.
            subtraction_params.c_k = c_k;
            subtraction_params.s_k = s_k;
            subtraction_params.R_k = R_k;
            subtraction_params.Gm_n = Gm_n;
            subtraction_params.Ia_n = Ia_n;

        end
        
        
        % ---------- Inversion Subnetwork Functions ----------

        % Implement a function to pack absolute inversion gs params.
        function params_gs = pack_absolute_inversion_gs_params( self, synapse_ID, c1, c3, delta, Gm2, dEs21, synapses, undetected_option )

            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 6, Gm2 = self.Gm_DEFAULT; end
            if nargin < 5, delta = self.delta_absolute_inversion_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_inversion_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta = delta;
            params_gs.Gm2 = Gm2;
            params_gs.dEs21 = dEs21;
            
        end
        
        
        % Implement a function to pack relative inversion gs params.
        function params_gs = pack_relative_inversion_gs_params( self, synapse_ID, c1, c3, delta, R2, Gm2, dEs21, synapses, undetected_option )

            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm2 = self.Gm_DEFAULT; end
            if nargin < 6, R2 = self.R_DEFAULT; end
            if nargin < 5, delta = self.delta_absolute_inversion_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_inversion_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta = delta;
            params_gs.R2 = R2;
            params_gs.Gm2 = Gm2;
            params_gs.dEs21 = dEs21;
            
        end
        
        
        % Implement a function to pack absolute inversion params.
        function inversion_params = pack_absolute_inversion_params( self, c1, c3, delta, Gm2 )
            
            % Set the default input arguments.
            if nargin < 5, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, delta = self.delta_absolute_inversion_DEFAULT; end
            if nargin < 3, c3 = self.c3_absolute_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            inversion_params.c1 = c1;
            inversion_params.c3 = c3;
            inversion_params.delta = delta;
            inversion_params.Gm2 = Gm2;
            
        end
        
        
        % Implement a function to pack relative inversion params.
        function inversion_params = pack_relative_inversion_params( self, c1, c3, delta, R2, Gm2 )
            
            % Set the default input arguments.
            if nargin < 6, Gm2 = self.Gm_DEFAULT; end
            if nargin < 5, R2 = self.R_DEFAULT; end
            if nargin < 4, delta = self.delta_relative_inversion_DEFAULT; end
            if nargin < 3, c3 = self.c3_relative_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_relative_inversion_DEFAULT; end
            
            % Pack the params.
            inversion_params.c1 = c1;
            inversion_params.c3 = c3;
            inversion_params.delta = delta;
            inversion_params.R2 = R2;
            inversion_params.Gm2 = Gm2;
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to pack reduced absolute inversion gs params.
        function params_gs = pack_reduced_absolute_inversion_gs_params( self, c1, delta, x1_max, Gm2 )

            % Set the default input arguments.
            if nargin < 5, Gm2 = self.Gm2_reduced_absolute_inversion_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_reduced_absolute_inversion_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_absolute_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta = delta;
            params_gs.x1_max = x1_max;
            params_gs.Gm2 = Gm2;
            
        end
        
        
        % Implement a function to pack reduced relative inversion gs params.
        function params_gs = pack_reduced_relative_inversion_gs_params( self, c1, delta, x1_max, Gm2 )

            % Set the default input arguments.
            if nargin < 5, Gm2 = self.Gm2_reduced_absolute_inversion_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_reduced_absolute_inversion_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_absolute_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta = delta;
            params_gs.x1_max = x1_max;
            params_gs.Gm2 = Gm2;
            
        end
        
        
        % Implement a function to pack reduced absolute inversion params.
        function reduced_inversion_params = pack_reduced_absolute_inversion_params( self, c1, delta, x1_max, Gm2 )
            
            % Set the default input arguments.
            if nargin < 5, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_absolute_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            reduced_inversion_params.c1 = c1;
            reduced_inversion_params.delta = delta;
            reduced_inversion_params.x1_max = x1_max;
            reduced_inversion_params.Gm2 = Gm2;
            
        end
        
        
        % Implement a function to pack reduced relative inversion params.
        function reduced_inversion_params = pack_reduced_relative_inversion_params( self, c1, delta, x1_max, Gm2 )
            
            % Set the default input arguments.
            if nargin < 4, Gm2 = self.Gm_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_reduced_relative_inversion_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_relative_inversion_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_relative_inversion_DEFAULT; end
            
            % Pack the params.
            reduced_inversion_params.c1 = c1;
            reduced_inversion_params.delta = delta;
            reduced_inversion_params.x1_max = x1_max;
            reduced_inversion_params.Gm2 = Gm2;
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------

        % Implement a function to pack absolute division gs31 params.
        function params_gs31 = pack_absolute_division_gs31_params( self, synapse_IDs, c1, c3, x1_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 6, Gm3 = self.Gm_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_absolute_division_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.c3 = c3;
            params_gs31.x1_max = x1_max;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division gs31 params.
        function params_gs31 = pack_relative_division_gs31_params( self, synapse_IDs, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, R3 = self.R_DEFAULT; end
            
            % Pack the params.
            params_gs31.R3 = R3;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
                        
        
        % Implement a function to pack absolute division gs32 params.
        function params_gs32 = pack_absolute_division_gs32_params( self, synapse_IDs, c1, c3, delta, x1_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_absolute_division_DEFAULT; end
            if nargin < 5, delta = self.delta_absolute_division_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.c3 = c3;
            params_gs32.delta = delta;
            params_gs32.x1_max = x1_max;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division gs32 params.
        function params_gs32 = pack_relative_division_gs32_params( self, synapse_IDs, c1, c3, delta, x1_max, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, synapses = self.synapses; end
            if nargin < 9, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 8, Gm3 = self.Gm_DEFAULT; end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_relative_division_DEFAULT; end
            if nargin < 5, delta = self.delta_relative_division_DEFAULT; end
            if nargin < 4, c3 = self.c3_relative_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_relative_division_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.c3 = c3;
            params_gs32.delta = delta;
            params_gs32.x1_max = x1_max;
            params_gs32.R3 = R3;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;

        end
        
        
        % Implement a function to pack absolute division gs params.
        function params_gs = pack_absolute_division_gs_params( self, synapse_IDs, c1, c3, delta, x1_max, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_absolute_division_DEFAULT; end
            if nargin < 5, delta = self.delta_absolute_division_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta = delta;
            params_gs.x1_max = x1_max;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division gs params.
        function params_gs = pack_relative_division_gs_params( self, synapse_IDs, c1, c3, delta, x1_max, R3, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 11, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 10, synapses = self.synapses; end
            if nargin < 9, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 8, Gm3 = self.Gm_DEFAULT; end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_relative_division_DEFAULT; end
            if nargin < 5, delta = self.delta_relative_division_DEFAULT; end
            if nargin < 4, c3 = self.c3_relative_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_relative_division_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta = delta;
            params_gs.x1_max = x1_max;
            params_gs.R3 = R3;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack absolute division params.
        function division_params = pack_absolute_division_params( self, c1, c3, delta, x1_max, Gm3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm3 = self.Gm_absolute_division_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_absolute_division_DEFAULT; end
            if nargin < 4, delta = self.delta_absolute_division_DEFAULT; end
            if nargin < 3, c3 = self.c3_absolute_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_absolute_division_DEFAULT; end
            
            % Pack the params.
            division_params.c1 = c1;
            division_params.c3 = c3;
            division_params.delta = delta;
            division_params.x1_max = x1_max;
            division_params.Gm3 = Gm3;
            
        end
        
        
        % Implement a function to pack relative division params.
        function division_params = pack_relative_division_params( self, c1, c3, delta, x1_max, R3, Gm3 )
            
            % Set the default input arguments.
            if nargin < 7, Gm3 = self.Gm_relative_division_DEFAULT; end
            if nargin < 6, R3 = self.R_relative_division_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_relative_division_DEFAULT; end
            if nargin < 4, delta = self.delta_relative_division_DEFAULT; end
            if nargin < 3, c3 = self.c3_relative_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_relative_division_DEFAULT; end
            
            % Pack the params.
            division_params.c1 = c1;
            division_params.c3 = c3;
            division_params.delta = delta;
            division_params.x1_max = x1_max;
            division_params.R3 = R3;
            division_params.Gm3 = Gm3;
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to pack reduced absolute division gs31 params.
        function params_gs31 = pack_reduced_absolute_division_gs31_params( self, synapse_IDs, c1, delta, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_division_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_division_DEFAULT; end
            if nargin < 4, delta = self.delta_reduced_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.delta = delta;
            params_gs31.x1_max = x1_max;
            params_gs31.x2_max = x2_max;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
                
        
        % Implement a function to pack reduced relative division gs31 params.
        function params_gs31 = pack_reduced_relative_division_gs31_params( self, synapse_IDs, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, R3 = self.R_DEFAULT; end
            
            % Pack the params.
            params_gs31.R3 = R3;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
                
                
        % Implement a function to pack reduced absolute division gs32 params.
        function params_gs32 = pack_reduced_absolute_division_gs32_params( self, synapse_IDs, c1, delta, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_division_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_division_DEFAULT; end
            if nargin < 4, delta = self.delta_reduced_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.delta = delta;
            params_gs32.x1_max = x1_max;
            params_gs32.x2_max = x2_max;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;

        end
        
                
        % Implement a function to pack reduced relative division gs32 params.
        function params_gs32 = pack_reduced_relative_division_gs32_params( self, synapse_IDs, c1, delta, x2_max, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_reduced_relative_division_DEFAULT; end
            if nargin < 6, R3 = self.R_reduced_relative_division_DEFAULT; end
            if nargin < 5, x2_max = self.x2max_reduced_relative_division_DEFAULT; end
            if nargin < 4, delta = self.delta_reduced_relative_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_relative_division_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.delta = delta;
            params_gs32.x2_max = x2_max;
            params_gs32.R3 = R3;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;

        end
             
        
        % Implement a function to pack reduced absolute division gs params.
        function params_gs = pack_reduced_absolute_division_gs_params( self, synapse_IDs, c1, delta, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_reduced_absolute_division_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_division_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_division_DEFAULT; end
            if nargin < 4, delta = self.delta_reduced_absolute_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_division_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta = delta;
            params_gs.x1_max = x1_max;
            params_gs.x2_max = x2_max;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack reduced relative division gs params.
        function params_gs = pack_reduced_relative_division_gs_params( self, synapse_IDs, c1, delta, x2_max, R3, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, R3 = self.R_DEFAULT; end
            if nargin < 5, x2_max = self.x2max_reduced_relative_division_DEFAULT; end
            if nargin < 4, delta = self.delta_reduced_relative_division_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_relative_division_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta = delta;
            params_gs.x2_max = x2_max;
            params_gs.R3 = R3;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack reduced absolute division params.
        function reduced_division_params = pack_reduced_absolute_division_params( self, c1, delta, x1_max, x2_max, Gm3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm3 = self.Gm_reduced_absolute_division_DEFAULT; end
            if nargin < 5, x2_max = self.x2max_reduced_absolute_division_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_reduced_absolute_division_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_absolute_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_absolute_division_DEFAULT; end
            
            % Pack the params.
            reduced_division_params.c1 = c1;
            reduced_division_params.delta = delta;
            reduced_division_params.x1_max = x1_max;
            reduced_division_params.x2_max = x2_max;
            reduced_division_params.Gm3 = Gm3;
            
        end
        
        
        % Implement a function to pack reduced relative division params.
        function reduced_division_params = pack_reduced_relative_division_params( self, c1, delta, x2_max, R3, Gm3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm3 = self.Gm_reduced_relative_division_DEFAULT; end
            if nargin < 5, R3 = self.R_reduce_relative_division_DEFAULT; end
            if nargin < 4, x2_max = self.x2max_reduced_relative_division_DEFAULT; end
            if nargin < 3, delta = self.delta_reduced_relative_division_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduce_relative_division_DEFAULT; end
            
            % Pack the params.
            reduced_division_params.c1 = c1;
            reduced_division_params.delta = delta;
            reduced_division_params.x2_max = x2_max;
            reduced_division_params.R3 = R3;
            reduced_division_params.Gm3 = Gm3;
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to pack absolute division after inversion gs31 params.
        function params_gs31 = pack_absolute_dai_gs31_params( self, c1, c3, x1_max, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 5, Gm3 = self.Gm_absolute_dai_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_absolute_dai_DEFAULT; end
            if nargin < 3, c3 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 2, c1 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.c3 = c3;
            params_gs31.x1_max = x1_max;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division after inversion gs31 params.
        function params_gs31 = pack_relative_dai_gs31_params( self, synapse_IDs, c1, c3, x1_max, R1, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_relative_dai_DEFAULT; end
            if nargin < 6, R1 = self.R_relative_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_relative_dai_DEFAULT; end
            if nargin < 4, c3 = self.c3_relative_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_relative_dai_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.c3 = c3;
            params_gs31.x1_max = x1_max;
            params_gs31.R1 = R1;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack absolute division after inversion gs32 params.
        function params_gs32 = pack_absolute_dai_gs32_params( self, synapse_IDs, c1, c3, delta2, x1_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_absolute_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_absolute_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_absolute_dai_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.c3 = c3;
            params_gs32.delta2 = delta2;
            params_gs32.x1_max = x1_max;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division after inversion gs32 params.
        function params_gs32 = pack_relative_dai_gs32_params( self, synapse_IDs, c1, c3, delta2, x1_max, x2_max, R2, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, Gm3 = self.Gm_relative_dai_DEFAULT; end
            if nargin < 8, R2 = self.R_relative_dai_DEFAULT; end
            if nargin < 7, x2_max = self.x2max_relative_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_relative_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_relative_dai_DEFAULT; end
            if nargin < 4, c3 = self.c3_relative_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_relative_dai_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.c3 = c3;
            params_gs32.delta2 = delta2;
            params_gs32.x1_max = x1_max;
            params_gs32.x2_max = x2_max;
            params_gs32.R2 = R2;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;

        end
               
        
        % Implement a function to pack absolute division after inversion gs params.
        function params_gs = pack_absolute_dai_gs_params( self, synapse_IDs, c1, c3, delta2, x1_max, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_absolute_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_absolute_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_absolute_dai_DEFAULT; end
            if nargin < 4, c3 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta2 = delta2;
            params_gs.x1_max = x1_max;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
        
        
        % Implement a function to pack relative division after inversion gs params.
        function params_gs = pack_relative_dai_gs_params( self, synapse_IDs, c1, c3, delta2, x1_max, x2_max, R1, R2, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 12, synapses = self.synapses; end
            if nargin < 11, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 10, Gm3 = self.Gm_relative_dai_DEFAULT; end
            if nargin < 9, R2 = self.R_relative_dai_DEFAULT; end
            if nargin < 8, R1 = self.R_relative_dai_DEFAULT; end
            if nargin < 7, x2_max = self.x2max_relative_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_relative_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_relative_dai_DEFAULT; end
            if nargin < 4, c3 = self.c3_relative_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_relative_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.c3 = c3;
            params_gs.delta2 = delta2;
            params_gs.x1_max = x1_max;
            params_gs.x2_max = x2_max;
            params_gs.R1 = R1;
            params_gs.R2 = R2;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
            
        end
        
        
        % Implement a function to pack absolute division after inversion params.
        function division_params = pack_absolute_dai_params( self, c1, c3, delta2, x1_max, Gm3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm3 = self.Gm_absolute_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_absolute_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_absolute_dai_DEFAULT; end
            if nargin < 3, c3 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 2, c1 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            division_params.c1 = c1;
            division_params.c3 = c3;
            division_params.delta2 = delta2;
            division_params.x1_max = x1_max;
            division_params.Gm3 = Gm3;
            
        end
        
        
        % Implement a function to pack relative division after inversion params.
        function division_params = pack_relative_dai_params( self, c1, c3, delta2, x1_max, x2_max, R1, R2, Gm3 )
            
            % Set the default input arguments.
            if nargin < 9, Gm3 = self.Gm_relative_dai_DEFAULT; end
            if nargin < 8, R2 = self.R_relative_dai_DEFAULT; end
            if nargin < 7, R1 = self.R_relative_dai_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_relative_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_relative_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_relative_dai_DEFAULT; end
            if nargin < 3, c3 = self.c3_relative_dai_DEFAULT; end
            if nargin < 2, c1 = self.c1_relative_dai_DEFAULT; end
            
            % Pack the params.
            division_params.c1 = c1;
            division_params.c3 = c3;
            division_params.delta2 = delta2;
            division_params.x1_max = x1_max;
            division_params.x2_max = x2_max;
            division_params.R1 = R1;
            division_params.R2 = R2;
            division_params.Gm3 = Gm3;
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to pack reduced absolute division after inversion gs31 params.
        function params_gs31 = pack_reduced_absolute_dai_gs31_params( self, synapse_IDs, c1, delta2, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_reduced_absolute_dai_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_reduced_absolute_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.delta2 = delta2;
            params_gs31.x1_max = x1_max;
            params_gs31.x2_max = x2_max;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
                
        
        % Implement a function to pack reduced relative division after inversion gs31 params.
        function params_gs31 = pack_reduced_relative_dai_gs31_params( self, synapse_IDs, c1, delta1, delta2, x1_max, x2_max, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, Gm3 = self.Gm_reduced_relative_dai_DEFAULT; end
            if nargin < 8, R3 = self.R_reduced_relative_dai_DEFAULT; end
            if nargin < 7, x2_max = self.x2max_reduced_relative_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_reduced_relative_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_reduced_relative_dai_DEFAULT; end
            if nargin < 4, delta1 = self.delta1_reduced_relative_dai_DEFAULT; end
            if anrgin < 3, c1 = self.c1_reduced_relative_dai_DEFAULT; end
            
            % Pack the params.
            params_gs31.c1 = c1;
            params_gs31.delta1 = delta1;
            params_gs31.delta2 = delta2;
            params_gs31.x1_max = x1_max;
            params_gs31.x2_max = x2_max;
            params_gs31.R3 = R3;
            params_gs31.Gm3 = Gm3;
            params_gs31.dEs31 = dEs31;
            
        end
        
                
        % Implement a function to pack reduced absolute division after inversion gs32 params.
        function params_gs32 = pack_reduced_absolute_dai_gs32_params( self, synapse_IDs, c1, delta2, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_reduced_absolute_dai_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_reduced_absolute_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.delta2 = delta2;
            params_gs32.x1_max = x1_max;
            params_gs32.x2_max = x2_max;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;
            
        end
                

        % Implement a function to pack reduced relative division after inversion gs32 params.
        function params_gs32 = pack_reduced_relative_dai_gs32_params( self, synapse_IDs, c1, delta1, delta2, x1_max, x2_max, R3, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, Gm3 = self.Gm_reduced_relative_dai_DEFAULT; end
            if nargin < 8, R3 = self.R_reduced_relative_dai_DEFAULT; end
            if nargin < 7, x2_max = self.x2max_reduced_relative_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_reduced_relative_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_reduced_relative_dai_DEFAULT; end
            if nargin < 4, delta1 = self.delta1_reduced_relative_dai_DEFAULT; end
            if anrgin < 3, c1 = self.c1_reduced_relative_dai_DEFAULT; end
                
            % Pack the params.
            params_gs32.c1 = c1;
            params_gs32.delta1 = delta1;
            params_gs32.delta2 = delta2;
            params_gs32.x1_max = x1_max;
            params_gs32.x2_max = x2_max;
            params_gs32.R3 = R3;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs31 = dEs31;
            
        end
        
       
        % Implement a function to pack reduced absolute division after inversion gs params.
        function params_gs = pack_reduced_absolute_dai_gs_params( self, synapse_IDs, c1, delta2, x1_max, x2_max, Gm3, dEs31, synapses, undetected_option )
                        
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm3 = self.Gm_reduced_absolute_dai_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_absolute_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_absolute_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_reduced_absolute_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_absolute_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta2 = delta2;
            params_gs.x1_max = x1_max;
            params_gs.x2_max = x2_max;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;
            
        end
                
        
        % Implement a function to pack reduced relative division after inversion gs params.
        function params_gs = pack_reduced_relative_dai_gs_params( self, synapse_IDs, c1, delta1, delta2, x1_max, x2_max, R3, Gm3, dEs31, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, Gm3 = self.Gm_reduced_relative_dai_DEFAULT; end
            if nargin < 8, R3 = self.R_reduced_relative_dai_DEFAULT; end
            if anrgin < 7, x2_max = self.x2max_reduced_relative_dai_DEFAULT; end
            if nargin < 6, x1_max = self.x1max_reduced_relative_dai_DEFAULT; end
            if nargin < 5, delta2 = self.delta2_reduced_relative_dai_DEFAULT; end
            if nargin < 4, delta1 = self.delta1_reduced_relative_dai_DEFAULT; end
            if nargin < 3, c1 = self.c1_reduced_relative_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c1 = c1;
            params_gs.delta1 = delta1;
            params_gs.delta2 = delta2;
            params_gs.x1_max = x1_max;
            params_gs.x2_max = x2_max;
            params_gs.R3 = R3;
            params_gs.Gm3 = Gm3;
            params_gs.dEs31 = dEs31;

        end
        
        
        % Implement a function to pack reduced absolute division after inversion params.
        function reduced_division_params = pack_reduced_absolute_dai_params( self, c1, delta2, x1_max, x2_max, Gm3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm3 = self.Gm_reduced_absolute_dai_DEFAULT; end
            if nargin < 5, x2_max = self.x2max_reduced_absolute_dai_DEFAULT; end
            if nargin < 4, x1_max = self.x1max_reduced_absolute_dai_DEFAULT; end
            if nargin < 3, delta2 = self.delta2_reduced_absolute_dai_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_absolute_dai_DEFAULT; end
            
            % Pack the params.
            reduced_division_params.c1 = c1;
            reduced_division_params.delta2 = delta2;
            reduced_division_params.x1_max = x1_max;
            reduced_division_params.x2_max = x2_max;
            reduced_division_params.Gm3 = Gm3;
            
        end
        
        
        % Implement a function to pack reduced relative division after inversion params.
        function reduced_division_params = pack_reduced_relative_dai_params( self, c1, delta1, delta2, x1_max, x2_max, R3, Gm3 )
            
            % Set the default input arguments.
            if nargin < 8, Gm3 = self.Gm_reduced_relative_dai_DEFAULT; end
            if nargin < 7, R3 = self.R_reduced_relative_dai_DEFAULT; end
            if nargin < 6, x2_max = self.x2max_reduced_relative_dai_DEFAULT; end
            if nargin < 5, x1_max = self.x1max_reduced_relative_dai_DEFAULT; end
            if nargin < 4, delta2 = self.delta2_reduced_relative_dai_DEFAULT; end
            if nargin < 3, delta1 = self.delta1_reduced_relative_dai_DEFAULT; end
            if nargin < 2, c1 = self.c1_reduced_relative_dai_DEFAULT; end
            
            % Pack the params.
            reduced_division_params.c1 = c1;
            reduced_division_params.delta1 = delta1;
            reduced_division_params.delta2 = delta2;
            reduced_division_params.x1_max = x1_max;
            reduced_division_params.x2_max = x2_max;
            reduced_division_params.R3 = R3;
            reduced_division_params.Gm3 = Gm3;
            
        end
        

        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to pack absolute multiplication gs41 params.
        function params_gs41 = pack_absolute_multiplication_gs41_params( self, c4, c6, delta1, delta2, R1, R3 )
            
            % Absolute: c4, c6, delta1, delta2, R1, R3
            
            % Set the default input arguments.
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_division_DEFAULT; end
            if nargin < 4, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 3, c6 = self.c3_dai_DEFAULT; end
            if nargin < 2, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs41.c4 = c4;
            params_gs41.c6 = c6;
            params_gs41.delta1 = delta1;
            params_gs41.delta2 = delta2;
            params_gs41.R1 = R1;
            params_gs41.R3 = R3;
            
        end
        
        
        % Implement a function to pack relative multiplication gs41 params.
        function params_gs41 = pack_relative_multiplication_gs41_params( self, synapse_IDs, c4, c6, delta1, delta2, R3, dEs41, synapses, undetected_option )
            
            % Relative: c4, c6, delta1, delta2, R3, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, delta2 = self.delta_division_DEFAULT; end
            if nargin < 5, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 4, c6 = self.c3_dai_DEFAULT; end
            if nargin < 3, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs41.c4 = c4;
            params_gs41.c6 = c6;
            params_gs41.delta1 = delta1;
            params_gs41.delta2 = delta2;
            params_gs41.R3 = R3;
            params_gs41.dEs41 = dEs41;
            
        end
        
        
        % Implement a function to pack absolute multiplication gs32 params.
        function params_gs32 = pack_absolute_multiplication_gs32_params( self, synapse_IDs, delta1, Gm3, dEs32, Ia3, synapses, undetected_option )
            
            % Absolute: delta1, Gm3, dEs32, Ia3
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, Ia3 = self.Ia_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs32.delta1 = delta1;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs32 = dEs32;
            params_gs32.Ia3 = Ia3;
            
        end
        
                
        % Implement a function to pack relative multiplication gs32 params.
        function params_gs32 = pack_relative_multiplication_gs32_params( self, synapse_IDs, delta1, Gm3, dEs32, Ia3, synapses, undetected_option )
            
            % Relative: delta1, Gm3, dEs32, Ia3
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, Ia3 = self.Ia_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs32.delta1 = delta1;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs32 = dEs32;
            params_gs32.Ia3 = Ia3;
            
        end
        
               
        % Implement a function to pack absolute multiplication gs43 params.
        function params_gs43 = pack_absolute_multiplication_gs43_params( self, synapse_IDs, c4, c6, delta2, R1, R3, dEs41, synapses, undetected_option )
            
            % Absolute: c4, c6, delta2, R1, R3, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_division_DEFAULT; end
            if nargin < 4, c6 = self.c3_dai_DEFAULT; end
            if nargin < 3, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs43.c4 = c4;
            params_gs43.c6 = c6;
            params_gs43.delta2 = delta2;
            params_gs43.R1 = R1;
            params_gs43.R3 = R3;
            params_gs43.dEs41 = dEs41;

        end
                
        
        % Implement a function to pack relative multiplication gs43 params.
        function params_gs43 = pack_relative_multiplication_gs43_params( self, synapse_IDs, c4, c6, delta1, delta2, R3, dEs41, synapses, undetected_option )
            
            % Relative: c4, c6, delta1, delta2, R3, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, delta2 = self.delta_division_DEFAULT; end
            if nargin < 5, delta1 = self.inversion_division_DEFAULT; end
            if nargin < 4, c6 = self.c3_dai_DEFAULT; end
            if nargin < 3, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs43.c4 = c4;
            params_gs43.c6 = c6;
            params_gs43.delta1 = delta1;
            params_gs43.delta2 = delta2;
            params_gs43.R3 = R3;
            params_gs43.dEs41 = dEs41;

        end
                
        
        % Implement a function to pack absolute multiplication gs params.
        function params_gs = pack_absolute_multiplication_gs_params( self, synapse_IDs, c4, c6, delta1, delta2, R1, R3, Gm3, dEs41, dEs32, Ia3, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 14, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 13, synapses = self.synapses; end
            if nargin < 12, Ia3 = self.Ia_DEFAULT; end
            if nargin < 11, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 10, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, Gm3 = self.Gm_DEFAULT; end
            if nargin < 8, R3 = self.R_DEFAULT; end
            if nargin < 7, R1 = self.R_DEFAULT; end
            if nargin < 6, delta2 = self.delta_division_DEFAULT; end
            if nargin < 5, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 4, c6 = self.c3_dai_DEFAULT; end
            if nargin < 3, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c4 = c4;
            params_gs.c6 = c6;
            params_gs.delta1 = delta1;
            params_gs.delta2 = delta2;
            params_gs.R1 = R1;
            params_gs.R3 = R3;
            params_gs.Gm3 = Gm3;
            params_gs.dEs41 = dEs41;
            params_gs.dEs32 = dEs32;
            params_gs.Ia3 = Ia3;

        end
        
        
        % Implement a function to pack relative multiplication gs params.
        function params_gs = pack_relative_multiplication_gs_params( self, synapse_IDs, c4, c6, delta1, delta2, R3, Gm3, dEs41, Ia3, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, Ia3 = self.Ia_DEFAULT; end
            if nargin < 9, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 8, Gm3 = self.Gm_DEFAULT; end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, delta2 = self.delta_division_DEFAULT; end
            if nargin < 5, delta1 = self.delta_inversion_DEFAULT; end
            if nargin < 4, c6 = self.c3_dai_DEFAULT; end
            if nargin < 3, c4 = self.c1_dai_DEFAULT; end
            
            % Pack the params.
            params_gs.c4 = c4;
            params_gs.c6 = c6;
            params_gs.delta1 = delta1;
            params_gs.delta2 = delta2;
            params_gs.R3 = R3;
            params_gs.Gm3 = Gm3;
            params_gs.dEs41 = dEs41;
            params_gs.Ia3 = Ia3;

        end
        
        
        % Implement a function to pack absolute multiplication params.
        function multiplication_params = pack_absolute_multiplication_params( self, c4, c6, delta1, delta2, R1, R3, Gm3, Ia3 )
            
            % Set the default input arguments.
            if nargin < 9, Ia3 = self.Ia_DEFAULT; end
            if nargin < 8, Gm3 = self.Gm_DEFAULT; end
            if nargin < 7, R3 = self.R_DEFAULT; end
            if nargin < 6, R1 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_absolute_dai_DEFAULT; end
            if nargin < 4, delta1 = self.delta_absolute_inversion_DEFAULT; end
            if nargin < 3, c6 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 2, c4 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            multiplication_params.c4 = c4;
            multiplication_params.c6 = c6;
            multiplication_params.delta1 = delta1;
            multiplication_params.delta2 = delta2;
            multiplication_params.R1 = R1;
            multiplication_params.R3 = R3;
            multiplication_params.Gm3 = Gm3;
            multiplication_params.Ia3 = Ia3;
            
        end
        
        
        % Implement a function to pack relative multiplication params.
        function multiplication_params = pack_relative_multiplication_params( self, c4, c6, delta1, delta2, R3, Gm3, Ia3 )
            
            % Set the default input arguments.
            if nargin < 8, Ia3 = self.Ia_DEFAULT; end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, R3 = self.R_DEFAULT; end
            if nargin < 5, delta2 = self.delta_absolute_dai_DEFAULT; end
            if nargin < 4, delta1 = self.delta_absolute_inversion_DEFAULT; end
            if nargin < 3, c6 = self.c3_absolute_dai_DEFAULT; end
            if nargin < 2, c4 = self.c1_absolute_dai_DEFAULT; end
            
            % Pack the params.
            multiplication_params.c4 = c4;
            multiplication_params.c6 = c6;
            multiplication_params.delta1 = delta1;
            multiplication_params.delta2 = delta2;
            multiplication_params.R3 = R3;
            multiplication_params.Gm3 = Gm3;
            multiplication_params.Ia3 = Ia3;
            
        end
                
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to pack reduced absolute multiplication gs41 params.
        function params_gs41 = pack_reduced_absolute_multiplication_gs41_params( self, synapse_IDs, delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option )
            
            % Absolute: delta1, delta2, R3, R4, Gm4, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm4 = self.Gm_DEFAULT; end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs41.delta1 = delta1;
            params_gs41.delta2 = delta2;
            params_gs41.R3 = R3;
            params_gs41.R4 = R4;
            params_gs41.Gm4 = Gm4;
            params_gs41.dEs41 = dEs41;

        end
        
                
        % Implement a function to pack reduced relative multiplication gs41 params.
        function params_gs41 = pack_reduced_relative_multiplication_gs41_params( self, synapse_IDs, delta1, delta2, R3, R4, dEs41, synapses, undetected_option )
            
            % Relative: delta1, delta2, R3, R4, dEs41
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 8, synapses = self.synapses; end
            if nargin < 7, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs41.delta1 = delta1;
            params_gs41.delta2 = delta2;
            params_gs41.R3 = R3;
            params_gs41.R4 = R4;
            params_gs41.dEs41 = dEs41;

        end
                
                
        % Implement a function to pack reduced absolute multiplication gs32 params.
        function params_gs32 = pack_reduced_absolute_multiplication_gs32_params( self, synapse_IDs, delta1, Gm3, dEs32, Ia3, synapses, undetected_option )
            
            % Absolute: delta1, Gm3, dEs32, Ia3
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, Ia3 = self.Ia_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs32.delta1 = delta1;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs32 = dEs32;
            params_gs32.Ia3 = Ia3;
            
        end
        
        
        % Implement a function to pack reduced relative multiplication gs32 params.
        function params_gs32 = pack_reduced_relative_multiplication_gs32_params( self, synapse_IDs, delta1, Gm3, dEs32, Ia3, synapses, undetected_option )
            
            % Relative: delta1, Gm3, dEs32, Ia3
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, Ia3 = self.Ia_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, Gm3 = self.Gm_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs32.delta1 = delta1;
            params_gs32.Gm3 = Gm3;
            params_gs32.dEs32 = dEs32;
            params_gs32.Ia3 = Ia3;
            
        end
        
                
        % Implement a function to pack reduced absolute multiplication gs43 params.
        function params_gs43 = pack_reduced_absolute_multiplication_gs43_params( self, synapse_IDs, delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option )
            
            % Absolute: delta1, delta2, R3, R4, Gm4, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm4 = self.Gm_DEFAULT; end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs43.delta1 = delta1;
            params_gs43.delta2 = delta2;
            params_gs43.R3 = R3;
            params_gs43.R4 = R4;
            params_gs43.Gm4 = Gm4;
            params_gs43.dEs41 = dEs41;

        end
                
                
        % Implement a function to pack reduced relative multiplication gs43 params.
        function params_gs43 = pack_reduced_relative_multiplication_gs43_params( self, synapse_IDs, delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option )
            
            % Relative: delta1, delta2, R3, R4, Gm4, dEs41
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 9, synapses = self.synapses; end
            if nargin < 8, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 7, Gm4 = self.Gm_DEFAULT; end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs43.delta1 = delta1;
            params_gs43.delta2 = delta2;
            params_gs43.R3 = R3;
            params_gs43.R4 = R4;
            params_gs43.Gm4 = Gm4;
            params_gs43.dEs41 = dEs41;
            
        end
                        
        
        % Implement a function to pack reduced absolute multiplication gs params.
        function params_gs = pack_reduced_absolute_multiplication_gs_params( self, synapse_IDs, delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 13, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 12, synapses = self.synapses; end
            if nargin < 11, Ia3 = self.Ia_DEFAULT; end
            if nargin < 10, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 9, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 8, Gm4 = self.Gm_DEFAULT; end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.delta1 = delta1;
            params_gs.delta2 = delta2;
            params_gs.R3 = R3;
            params_gs.R4 = R4;
            params_gs.Gm3 = Gm3;
            params_gs.Gm4 = Gm4;
            params_gs.dEs41 = dEs41;
            params_gs.dEs32 = dEs32;
            params_gs.Ia3 = Ia3;

        end
        
        
        % Implement a function to pack reduced relative multiplication gs params.
        function params_gs = pack_reduced_relative_multiplication_gs_params( self, synapse_IDs, delta1, delta2, R3, R4, Gm3, Gm4, dEs41, Ia3, synapses, undetected_option )

            % Set the default input arguments.
            if nargin < 12, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 11, synapses = self.synapses; end
            if nargin < 10, Ia3 = self.Ia_DEFAULT; end
            if nargin < 9, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 8, Gm4 = self.Gm_DEFAULT; end
            if nargin < 7, Gm3 = self.Gm_DEFAULT; end
            if nargin < 6, R4 = self.R_DEFAULT; end
            if nargin < 5, R3 = self.R_DEFAULT; end
            if nargin < 4, delta2 = self.delta_division_DEFAULT; end
            if nargin < 3, delta1 = self.delta_inversion_DEFAULT; end
            
            % Pack the params.
            params_gs.delta1 = delta1;
            params_gs.delta2 = delta2;
            params_gs.R3 = R3;
            params_gs.R4 = R4;
            params_gs.Gm3 = Gm3;
            params_gs.Gm4 = Gm4;
            params_gs.dEs41 = dEs41;
            params_gs.Ia3 = Ia3;

        end
        
        
        % Implement a function to pack reduced absolute multiplication params.
        function multiplication_params = pack_reduced_absolute_multiplication_params( self, delta1, delta2, R3, R4, Gm3, Gm4, Ia3 )
            
            % Set the default input arguments.
            if nargin < 8, Ia3 = self.Ia_DEFAULT; end
            if nargin < 7, Gm4 = self.Gm_DEFAULT; end
            if nargin < 6, Gm3 = self.Gm_DEFAULT; end
            if nargin < 5, R4 = self.R_DEFAULT; end
            if nargin < 4, R3 = self.R_DEFAULT; end
            if nargin < 3, delta2 = self.delta_absolute_dai_DEFAULT; end
            if nargin < 2, delta1 = self.delta_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            multiplication_params.delta1 = delta1;
            multiplication_params.delta2 = delta2;
            multiplication_params.R3 = R3;
            multiplication_params.R4 = R4;
            multiplication_params.Gm3 = Gm3;
            multiplication_params.Gm4 = Gm4;
            multiplication_params.Ia3 = Ia3;
            
        end
        
        
        % Implement a function to pack reduced relative multiplication params.
        function multiplication_params = pack_reduced_relative_multiplication_params( self, delta1, delta2, R3, R4, Gm3, Gm4, Ia3 )
            
            % Set the default input arguments.
            if nargin < 8, Ia3 = self.Ia_DEFAULT; end
            if nargin < 7, Gm4 = self.Gm_DEFAULT; end
            if nargin < 6, Gm3 = self.Gm_DEFAULT; end
            if nargin < 5, R4 = self.R_DEFAULT; end
            if nargin < 4, R3 = self.R_DEFAULT; end
            if nargin < 3, delta2 = self.delta_absolute_dai_DEFAULT; end
            if nargin < 2, delta1 = self.delta_absolute_inversion_DEFAULT; end
            
            % Pack the params.
            multiplication_params.delta1 = delta1;
            multiplication_params.delta2 = delta2;
            multiplication_params.R3 = R3;
            multiplication_params.R4 = R4;
            multiplication_params.Gm3 = Gm3;
            multiplication_params.Gm4 = Gm4;
            multiplication_params.Ia3 = Ia3;
            
        end
        
        
        %% Maximum Synaptic Conductance Parameter Conversion Functions.
        
        % ---------- Transmission Subnetwork Functions ----------

        % Implement a function to convert transmission params into transmission gs params.
        function transmission_gs_params = convert_transmission_params2gs_params( self, synapse_ID, transmission_params, dEs21, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, transmission_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute transmission params.
                [ c, x1_max, Gm2 ] = self.unpack_absolute_transmission_params( transmission_params );
                
                % Pack the absolute transmission gs params.
                transmission_gs_params = self.pack_absolute_transmission_gs_params( synapse_ID, c, x1_max, Gm2, dEs21, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative transmission params.
                [ R2, Gm2 ] = self.unpack_relative_transmission_params( transmission_params );
                
                % Pack the relative transmission gs params.
                transmission_gs_params = self.pack_relative_transmission_gs_params( synapse_ID, R2, Gm2, dEs21, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to convert addition params into addition gs params.
        function addition_gs_params = convert_addition_params2gs_params( self, synapse_IDs, addition_params, dEs_nk, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, addition_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute addition params.
                [ c_k, R_k, Gm_n, Ia_n ] = self.unpack_absolute_addition_params( synapse_IDs, addition_params );
                
                % Pack the absolute addition gs params.
                addition_gs_params = self.pack_absolute_addition_gs_params( synapse_IDs, c_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative addition params.
                [ c_k, R_n, Gm_n, Ia_n ] = self.unpack_relative_addition_params( synapse_IDs, addition_params );
                
                % Pack the relative addition gs params.
                addition_gs_params = self.pack_relative_addition_gs_params( synapse_IDs, c_k, R_n, Gm_n, dEs_nk, Ia_n, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to convert subtraction params into subtraction gs params.
        function subtraction_gs_params = convert_subtraction_params2gs_params( self, synapse_IDs, subtraction_params, dEs_nk, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs_nk = self.get_synapse_property( synapse_IDs, 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, subtraction_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute subtraction params.
                [ c_k, s_k, R_k, Gm_n, Ia_n ] = self.unpack_absolute_subtraction_params( synapse_IDs, subtraction_params );
                
                % Pack the absolute subtraction gs params.
                subtraction_gs_params = self.pack_absolute_subtraction_gs_params( synapse_IDs, c_k, s_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative subtraction params.
                [ c_k, s_k, R_k, Gm_n, Ia_n ] = self.unpack_relative_subtraction_params( synapse_IDs, subtraction_params );
                
                % Pack the relative subtraction gs params.
                subtraction_gs_params = self.pack_relative_subtraction_gs_params( synapse_IDs, c_k, s_k, R_k, Gm_n, dEs_nk, Ia_n, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------

        % Implement a function to convert inversion gs params into inversion gs params.
        function inversion_gs_params = convert_inversion_params2gs_params( self, synapse_ID, inversion_params, dEs21, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs21 = self.get_synapse_property( synapse_ID, 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, inversion_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute inversion params.
                [ c1, c3, delta, Gm2 ] = self.unpack_absolute_inversion_params( inversion_params );
                
                % Pack the absolute subtraction gs params.
                inversion_gs_params = self.pack_absolute_inversion_gs_params( synapse_ID, c1, c3, delta, Gm2, dEs21, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative subtraction params.
                [ c1, c3, delta, R2, Gm2 ] = self.unpack_relative_inversion_params( inversion_params );
                
                % Pack the relative subtraction gs params.
                inversion_gs_params = self.pack_relative_inversion_gs_params( synapse_ID, c1, c3, delta, R2, Gm2, dEs21, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to convert reduced inversion gs params into reduced inversion gs params.
        function reduced_inversion_gs_params = convert_reduced_inversion_params2gs_params( self, synapse_ID, reduced_inversion_params, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, reduced_inversion_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute inversion params.
                [ c1, delta, x1_max, Gm2 ] = self.unpack_reduced_absolute_inversion_params( reduced_inversion_params );
                
                % Pack the absolute subtraction gs params.                
                reduced_inversion_gs_params = self.pack_reduced_absolute_inversion_gs_params( c1, delta, x1_max, Gm2 );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative subtraction params.
                [ c1, delta, x1_max, Gm2 ] = self.unpack_reduced_relative_inversion_params( reduced_inversion_params );
                
                % Pack the relative subtraction gs params.
                reduced_inversion_gs_params = self.pack_reduced_relative_inversion_gs_params( c1, delta, x1_max, Gm2 );                
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to convert division gs params into division gs31 params.
        function params_gs31 = convert_division_gs_params2gs31_params( self, division_gs_params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_gs_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ ~, R3, Gm3, dEs31, ~, Ia3 ] = self.unpack_absolute_division_gs_params( division_gs_params, synapses, undetected_option );
                
                % Pack the absolute division gs31 params.
                params_gs31 = self.pack_absolute_division_gs31_params( R3, Gm3, dEs31, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.
                [ ~, R3, Gm3, dEs31, ~, Ia3 ] = self.unpack_relative_division_gs_params( division_gs_params, synapses, undetected_option );
                
                % Pack the relative division gs31 params.
                params_gs31 = self.pack_relative_division_gs31_params( R3, Gm3, dEs31, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
            
        % Implement a function to convert division gs params into division gs32 design params.
        function params_gs32 = convert_division_gs_params2gs32_params( self, division_gs_params, gs31, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, gs31 = self.get_synapse_property( synapse_IDs( 1 ), 'gs', true, synapses, undetected_option ); end            % [V] Synaptic Reversal Potential.
            if nargin < 2, division_gs_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ delta, ~, Gm3, dEs31, dEs32, Ia3 ] = self.unpack_absolute_division_gs_params( division_gs_params, synapses, undetected_option );
                
                % Pack the absolute division gs32 params.
                params_gs32 = self.pack_absolute_division_gs32_params( delta, Gm3, gs31, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.
                [ delta, ~, Gm3, dEs31, dEs32, Ia3 ] = self.unpack_relative_division_gs_params( division_gs_params, synapses, undetected_option );
                
                % Pack the relative division gs32 params.
                params_gs32 = self.pack_relative_division_gs32_params( delta, Gm3, gs31, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert division params into division gs params.
        function division_gs_params = convert_division_params2gs_params( self, synapse_IDs, division_params, dEs31, dEs32, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ delta, R3, Gm3, Ia3 ] = self.unpack_absolute_division_params( division_params );
                
                % Pack the absolute division gs params.
                division_gs_params = self.pack_absolute_division_gs_params( synapse_IDs, delta, R3, Gm3, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.
                [ delta, R3, Gm3, Ia3 ] = self.unpack_relative_division_params( division_params );
                
                % Pack the relative division gs params.
                division_gs_params = self.pack_relative_division_gs_params( synapse_IDs, delta, R3, Gm3, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------
        
        % Implement a function to convert reduced division gs params into reduced division gs31 design params.
        function params_gs31 = convert_reduced_division_gs_params2gs31_params( self, division_params, encoding_scheme, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ ~, R3, Gm3, dEs31, ~, Ia3 ] = self.unpack_reduced_absolute_division_gs_params( division_params, synapses, undetected_option );
                
                % Pack the reduced absolute division gs31 params.                
                params_gs31 = self.pack_reduced_absolute_division_gs31_params( R3, Gm3, dEs31, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.
                [ ~, R3, Gm3, dEs31, ~, Ia3 ] = self.unpack_reduced_relative_division_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs31 params.
                params_gs31 = self.pack_reduced_relative_division_gs31_params( R3, Gm3, dEs31, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced division gs params into reduced division gs32 design params.
        function params_gs32 = convert_reduced_division_gs_params2gs32_params( self, division_params, gs31, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, gs31 = self.get_synapse_property( synapse_IDs( 1 ), 'gs', true, synapses, undetected_option ); end            % [V] Synaptic Reversal Potential.
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ delta, ~, Gm3, dEs31, dEs32, Ia3 ] = self.unpack_reduced_absolute_division_gs_params( division_params, synapses, undetected_option );
                
                % Pack the absolute division gs32 params.
                params_gs32 = self.pack_reduced_absolute_division_gs32_params( delta, Gm3, gs31, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.
                [ delta, ~, Gm3, dEs31, dEs32, Ia3 ] = self.unpack_reduced_relative_division_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs32 params.
                params_gs32 = self.pack_reduced_relative_division_gs32_params( delta, Gm3, gs31, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced division params into reduced division gs params.
        function reduced_division_gs_params = convert_reduced_division_params2gs_params( self, synapse_IDs, reduced_division_params, dEs31, dEs32, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, reduced_division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute reduced division params.
                [ delta, R3, Gm3, Ia3 ] = self.unpack_reduced_absolute_division_params( reduced_division_params );
                
                % Pack the absolute reduced division gs params.
                reduced_division_gs_params = self.pack_reduced_absolute_division_gs_params( synapse_IDs, delta, R3, Gm3, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative reduced division params.
                [ delta, R3, Gm3, Ia3 ] = self.unpack_reduced_relative_division_params( division_params );
                
                % Pack the relative reduced division gs params.
                reduced_division_gs_params = self.pack_reduced_relative_division_gs_params( synapse_IDs, delta, R3, Gm3, dEs31, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------
        
        % Implement a function to convert division after inversion gs params into division after inversion gs31 params.
        function params_gs31 = convert_dai_gs_params2gs31_params( self, division_params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ c1, c3, delta1, delta2, R1, R2, ~ ] = self.unpack_absolute_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the absolute division gs31 params.
                params_gs31 = self.pack_absolute_dai_gs31_params( c1, c3, delta1, delta2, R1, R2 );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.                
                [ c1, c3, delta1, delta2, R2, dEs31 ] = self.unpack_relative_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs31 params.                
                params_gs31 = self.pack_relative_dai_gs31_params( c1, c3, delta1, delta2, R2, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert division after inversion gs params into division after inversion gs32 params.
        function params_gs32 = convert_dai_gs_params2gs32_params( self, division_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ c1, c3, ~, delta2, R1, R2, dEs31 ] = self.unpack_absolute_dai_gs_params( division_params, synapses, undetected_option );

                % Pack the absolute division gs32 params.                
                params_gs32 = self.pack_absolute_dai_gs32_params( c1, c3, delta2, R1, R2, dEs31, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.                
                [ c1, c3, delta1, delta2, R2, dEs31 ] = self.unpack_relative_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs32 params.                
                params_gs32 = self.pack_relative_dai_gs32_params( c1, c3, delta1, delta2, R2, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert division after inversion params into division after inversion gs params.
        function dai_gs_params = convert_dai_params2gs_params( self, synapse_IDs, dai_params, dEs31, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, dai_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute dai params.
                [ c1, c3, delta1, delta2, R1, R2 ] = self.unpack_absolute_dai_params( dai_params );
                
                % Pack the absolute dai gs params.
                dai_gs_params = self.pack_absolute_dai_gs_params( synapse_IDs, c1, c3, delta1, delta2, R1, R2, dEs31, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative dai params.
                [ c1, c3, delta1, delta2, R2 ] = self.unpack_relative_dai_params( dai_params );
                
                % Pack the relative dai gs params.
                dai_gs_params = self.pack_relative_dai_gs_params( synapse_IDs, c1, c3, delta1, delta2, R2, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------
        
        % Implement a function to convert reduced division after inversion gs params into reduced division after inversion gs31 params.
        function params_gs31 = convert_reduced_dai_gs_params2gs31_params( self, division_params, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.                
                [ delta1, delta2, R2, R3, Gm3, dEs31 ] = self.unpack_reduced_absolute_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the absolute division gs31 params.                
                params_gs31 = self.pack_reduced_absolute_dai_gs31_params( delta1, delta2, R2, R3, Gm3, dEs31, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.                                
                [ delta1, delta2, R2, R3, ~, dEs31 ] = self.unpack_reduced_relative_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs31 params.                                
                params_gs31 = self.pack_reduced_relative_dai_gs31_params( delta1, delta2, R2, R3, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced division after inversion gs params into reduced division after inversion gs32 params.
        function params_gs32 = convert_reduced_dai_gs_params2gs32_params( self, division_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, division_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute division params.
                [ delta1, delta2, R2, R3, Gm3, dEs31 ] = self.unpack_reduced_absolute_dai_gs_params( division_params, synapses, undetected_option );

                % Pack the absolute division gs32 params.                                
                params_gs32 = self.pack_reduced_absolute_dai_gs32_params( delta1, delta2, R2, R3, Gm3, dEs31, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative division params.                
                [ delta1, delta2, R2, R3, Gm3, dEs31 ] = self.unpack_reduced_relative_dai_gs_params( division_params, synapses, undetected_option );
                
                % Pack the relative division gs32 params.                                
                params_gs32 = self.pack_reduced_relative_dai_gs32_params( delta1, delta2, R2, R3, Gm3, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced division after inversion params into reduced division after inversion gs params.
        function reduced_dai_gs_params = convert_reduced_dai_params2gs_params( self, synapse_IDs, reduced_dai_params, dEs31, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 6, synapses = self.synapses; end
            if nargin < 5, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 4, dEs31 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, reduced_dai_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the reduced absolute dai params.
                [ delta1, delta2, R2, R3, Gm3 ] = self.unpack_reduced_absolute_dai_params( reduced_dai_params );
                
                % Pack the reduced absolute dai gs params.
                reduced_dai_gs_params = self.pack_reduced_absolute_dai_gs_params( synapse_IDs, delta1, delta2, R2, R3, Gm3, dEs31, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the reduced relative dai params.
                [ delta1, delta2, R2, R3, Gm3 ] = self.unpack_reduced_relative_dai_params( division_params );
                
                % Pack the reduced relative dai gs params.
                reduced_dai_gs_params = self.pack_reduced_relative_dai_gs_params( synapse_IDs, delta1, delta2, R2, R3, Gm3, dEs31, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to convert multiplication gs params into multiplication gs41 params.
        function params_gs41 = convert_multiplication_gs_params2gs41_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                
                [ c4, c6, delta1, delta2, R1, R3, ~, ~, ~, ~ ] = self.unpack_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs41 params.                
                params_gs41 = self.pack_absolute_multiplication_gs41_params( c4, c6, delta1, delta2, R1, R3 );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                
                [ c4, c6, delta1, delta2, R3, ~, dEs41, ~ ] = self.unpack_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs41 params.                
                params_gs41 = self.pack_relative_multiplication_gs41_params( c4, c6, delta1, delta2, R3, dEs41, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert multiplication gs params into multiplication gs32 params.
        function params_gs32 = convert_multiplication_gs_params2gs32_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                
                [ ~, ~, delta1, ~, ~, ~, Gm3, ~, dEs32, Ia3 ] = self.unpack_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs32 params.                                
                params_gs32 = self.pack_absolute_multiplication_gs32_params( delta1, Gm3, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                
                [ ~, ~, delta1, ~, ~, Gm3, ~, Ia3 ] = self.unpack_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs32 params.                                
                params_gs32 = self.pack_relative_multiplication_gs32_params( delta1, Gm3, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert multiplication gs params into multiplication gs43 params.
        function params_gs43 = convert_multiplication_gs_params2gs43_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                
                [ c4, c6, ~, delta2, R1, R3, ~, dEs41, ~, ~ ] = self.unpack_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs43 params.                                
                params_gs43 = self.pack_absolute_multiplication_gs43_params( c4, c6, delta2, R1, R3, dEs41, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                
                [ c4, c6, delta1, delta2, R3, ~, dEs41, ~ ] = self.unpack_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs43 params.                                
                params_gs43 = self.pack_relative_multiplication_gs43_params( c4, c6, delta1, delta2, R3, dEs41, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert multiplication params into multiplication gs params.
        function multiplication_gs_params = convert_multiplication_params2gs_params( self, synapse_IDs, multiplication_params, dEs41, dEs32, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.
                [ c4, c6, delta1, delta2, R1, R3, Gm3, Ia3 ] = self.unpack_absolute_multiplication_params( multiplication_params );
                
                % Pack the absolute multiplication gs params.
                multiplication_gs_params = self.pack_absolute_multiplication_gs_params( synapse_IDs, c4, c6, delta1, delta2, R1, R3, Gm3, dEs41, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.
                [ c4, c6, delta1, delta2, R3, Gm3, Ia3 ] = self.unpack_relative_multiplication_params( multiplication_params );
                
                % Pack the relative multiplication gs params.
                multiplication_gs_params = self.pack_relative_multiplication_gs_params( synapse_IDs, c4, c6, delta1, delta2, R3, Gm3, dEs41, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to convert reduced multiplication gs params into multiplication gs41 params.
        function params_gs41 = convert_reduced_multiplication_gs_params2gs41_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                                
                [ delta1, delta2, R3, R4, ~, Gm4, dEs41, ~, ~ ] = self.unpack_reduced_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs41 params.                                
                params_gs41 = self.pack_reduced_absolute_multiplication_gs41_params( delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                                
                [ delta1, delta2, R3, R4, ~, ~, dEs41, ~ ] = self.unpack_reduced_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs41 params.                                
                params_gs41 = self.pack_reduced_relative_multiplication_gs41_params( delta1, delta2, R3, R4, dEs41, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced multiplication gs params into multiplication gs32 params.
        function params_gs32 = convert_reduced_multiplication_gs_params2gs32_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                                
                [ delta1, ~, ~, ~, Gm3, ~, ~, dEs32, Ia3 ] = self.unpack_reduced_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs32 params.                                                
                params_gs32 = self.pack_reduced_absolute_multiplication_gs32_params( delta1, Gm3, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                
                [ delta1, ~, ~, ~, Gm3, ~, ~, Ia3 ] = self.unpack_reduced_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs32 params.                                                
                params_gs32 = self.pack_reduced_relative_multiplication_gs32_params( delta1, Gm3, dEs32, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced multiplication gs params into multiplication gs43 params.
        function params_gs43 = convert_reduced_multiplication_gs_params2gs43_params( self, multiplication_params, encoding_scheme, synapses, undetected_option )
                    
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the absolute multiplication params.                                
                [ delta1, delta2, R3, R4, ~, Gm4, dEs41, ~, ~ ] = self.unpack_reduced_absolute_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the absolute multiplication gs43 params.                                               
                params_gs43 = self.pack_reduced_absolute_multiplication_gs43_params( delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the relative multiplication params.                
                [ delta1, delta2, R3, R4, ~, Gm4, dEs41, ~ ] = self.unpack_reduced_relative_multiplication_gs_params( multiplication_params, synapses, undetected_option );
                
                % Pack the relative multiplication gs43 params.                                                
                params_gs43 = self.pack_reduced_relative_multiplication_gs43_params( delta1, delta2, R3, R4, Gm4, dEs41, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to convert reduced multiplication params into reduced multiplication gs params.
        function reduced_multiplication_gs_params = convert_reduced_multiplication_params2gs_params( self, synapse_IDs, reduced_multiplication_params, dEs41, dEs32, encoding_scheme, synapses, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end
            if nargin < 7, synapses = self.synapses; end
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 5, dEs32 = self.get_synapse_property( synapse_IDs( 2 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 4, dEs41 = self.get_synapse_property( synapse_IDs( 1 ), 'dEs', true, synapses, undetected_option ); end
            if nargin < 3, reduced_multiplication_params = struct( [  ] ); end
            
            % Determine how to create the params.
            if strcmpi( encoding_scheme, 'absolute' )                                                                       % If this operation is using an absolute encoding scheme...
                
                % Unpack the reduced absolute multiplication params.
                [ delta1, delta2, R3, R4, Gm3, Gm4, Ia3 ] = self.unpack_reduced_absolute_multiplication_params( reduced_multiplication_params );
                
                % Pack the reduced absolute multiplication gs params.
                reduced_multiplication_gs_params = self.pack_reduced_absolute_multiplication_gs_params( synapse_IDs, delta1, delta2, R3, R4, Gm3, Gm4, dEs41, dEs32, Ia3, synapses, undetected_option );
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                                   % If this operation uses a relative encoding scheme...
                
                % Unpack the reduced relative multiplication params.
                [ delta1, delta2, R3, R4, Gm3, Gm4, Ia3 ] = self.unpack_reduced_relative_multiplication_params( multiplication_params );
                
                % Pack the reduced relative multiplication gs params.
                reduced_multiplication_gs_params = self.pack_reduced_relative_multiplication_gs_params( synapse_IDs, delta1, delta2, R3, R4, Gm3, Gm4, dEs41, Ia3, synapses, undetected_option );
                
            else                                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions.
        
        % ---------- Transmission Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 21 of a transmission subnetwork.
        function [ gs21, synapses, self ] = compute_transmission_gs21( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_transmission_gs21_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ gs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_transmission_gs21( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
                       
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance of addition subnetwork synapses.
        function [ gs_nk, synapses, self ] = compute_addition_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.

            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = process_addition_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            gs_nk = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Retrieve the params associated with this synapse.
                these_params = self.get_addition_gs_params( k, params, encoding_scheme );
                
                % Compute the required parameter for this synapse.
                [ gs_nk( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_addition_gs( these_params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
                                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to compute and set the maximum synaptic conductance of subtraction subnetwork synapses.
        function [ gs_nk, synapses, self ] = compute_subtraction_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = process_subtraction_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            gs_nk = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Retrieve the params associated with this synapse.
                these_params = self.get_subtraction_gs_params( k, params, encoding_scheme );
                
                % Compute and set the required parameter for this synapse.
                [ gs_nk( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_gs( these_params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to compute and set the maximum synaptic conductance of inversion subnetwork synapses.
        function [ gs21, synapses, self ] = compute_inversion_gs21( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_inversion_gs21_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );

            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ gs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_inversion_gs21( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
                            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance of reduced inversion subnetwork synapses.
        function [ gs21, synapses, self ] = compute_reduced_inversion_gs21( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_inversion_gs21_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );

            % Retrieve the index associated with this synapse ID.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );

            % Compute and set the required parameter for this synapse.
            [ gs21, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_inversion_gs21( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
                            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 31 of a division subnetwork.
        function [ gs31, synapses, self ] = compute_division_gs31( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_division_gs31_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_gs31( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a division subnetwork.
        function [ gs32, synapses, self ] = compute_division_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_division_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Retrieve the index associated with the numerator and denominator synapses.
            synapse_index = self.get_synapse_index( synapse_IDs( end ), synapses, undetected_option );
            
            % Compute and set the required parameter for this synapse.
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance for the synapses of a division subnetwork.
        function [ gs, synapses, self ] = compute_division_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_division_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs31 design params.
            params_gs31 = self.convert_division_gs_params2gs31_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 31.
            [ gs31, synapses, synapse_manager ] = self.compute_division_gs31( synapse_IDs, params_gs31, encoding_scheme, synapses, true, validation_flag, undetected_option );

            % Convert the generic design params into gs32 design params.
            params_gs32 = self.convert_division_gs_params2gs32_params( params, gs31, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductnace for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_division_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs31, gs32 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 31 of a reduced division subnetwork.
        function [ gs31, synapses, self ] = compute_reduced_division_gs31( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.            
            params = self.process_reduced_division_gs31_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Retrieve the index associated for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for this synapse.
            [ gs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_division_gs31( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a reduced division subnetwork.
        function [ gs32, synapses, self ] = compute_reduced_division_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.            
            params = self.process_reduced_division_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Retrieve the index associated for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the required parameter for this synapse.
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductance for the synapses of a reduced division subnetwork.
        function [ gs, synapses, self ] = compute_reduced_division_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_reduced_division_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs31 design params.
            params_gs31 = self.convert_reduced_convert_division_gs_params2gs31_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 31.
            [ gs31, synapses, synapse_manager ] = self.compute_reduced_division_gs31( synapse_IDs, params_gs31, encoding_scheme, synapses, true, validation_flag, undetected_option );

            % Convert the generic design  params into gs32 design params.
            params_gs32 = self.convert_reduced_division_gs_params2gs32_params( params, gs31, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductnace for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_division_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs31, gs32 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 31 of a division after inversion subnetwork.
        function [ gs31, synapses, self ] = compute_dai_gs31( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_dai_gs31_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.                        
            [ gs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_dai_gs31( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a division after inversion subnetwork.
        function [ gs32, synapses, self ] = compute_dai_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_dai_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.                        
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_dai_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a division after inversion subnetwork.
        function [ gs, synapses, self ] = compute_dai_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_dai_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs31 design params.
            params_gs31 = self.convert_dai_gs_params2gs31_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 31.
            [ gs31, synapses, synapse_manager ] = self.compute_dai_gs31( synapse_IDs, params_gs31, encoding_scheme, synapses, true, validation_flag, undetected_option );

            % Convert the generic design  params into gs32 design params.
            params_gs32 = self.convert_dai_gs_params2gs32_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductnace for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_dai_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs31, gs32 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 31 of a reduced division after inversion subnetwork.
        function [ gs31, synapses, self ] = compute_reduced_dai_gs31( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_dai_gs31_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.                        
            [ gs31, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_dai_gs31( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a reduced division after inversion subnetwork.
        function [ gs32, synapses, self ] = compute_reduced_dai_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_dai_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.                        
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_dai_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the maximum synaptic conductances for a reduced division after inversion subnetwork.
        function [ gs, synapses, self ] = compute_reduced_dai_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
           
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_reduced_dai_gs_params(synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs31 design params.
            params_gs31 = self.convert_reduced_dai_gs_params2gs31_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 31.
            [ gs31, synapses, synapse_manager ] = self.compute_reduced_dai_gs31( synapse_IDs, params_gs31, encoding_scheme, synapses, true, validation_flag, undetected_option );

            % Convert the generic design  params into gs32 design params.
            params_gs32 = self.convert_reduced_dai_gs_params2gs32_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductnace for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_dai_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs31, gs32 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 41 of a multiplication subnetwork.
        function [ gs41, synapses, self ] = compute_multiplication_gs41( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_multiplication_gs41_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs41, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_gs41( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a multiplication subnetwork.
        function [ gs32, synapses, self ] = compute_multiplication_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_multiplication_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 43 of a multiplication subnetwork.
        function [ gs43, synapses, self ] = compute_multiplication_gs43( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_multiplication_gs43_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 3 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs43, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_gs43( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the amximum synaptic conductance for the synapses of a multiplication subnetwork.
        function [ gs, synapses, self ] = compute_multiplication_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_multiplication_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs41 design params.
            params_gs41 = self.convert_multiplication_gs_params2gs41_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 41.
            [ gs41, synapses, synapse_manager ] = self.compute_multiplication_gs41( synapse_IDs, params_gs41, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Convert the generic design params into gs32 design params.
            params_gs32 = self.convert_multiplication_gs_params2gs32_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_multiplication_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Convert the generic design params into gs43 design params.
            params_gs43 = self.convert_multiplication_gs_params2gs43_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 43.
            [ gs43, synapses, synapse_manager ] = synapse_manager.compute_multiplication_gs43( synapse_IDs, params_gs43, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs41, gs32, gs43 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to compute and set the maximum synaptic conductance for synapse 41 of a reduced multiplication subnetwork.
        function [ gs41, synapses, self ] = compute_reduced_multiplication_gs41( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_multiplication_gs41_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs41, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_gs41( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 32 of a reduced multiplication subnetwork.
        function [ gs32, synapses, self ] = compute_reduced_multiplication_gs32( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_multiplication_gs32_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs32, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_gs32( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance for synapse 43 of a reduced multiplication subnetwork.
        function [ gs43, synapses, self ] = compute_reduced_multiplication_gs43( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the params.
            params = self.process_reduced_multiplication_gs43_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
                        
            % Compute and set the required parameter for this synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 3 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            [ gs43, synapses( synapse_index ) ] = synapses( synapse_index ).compute_reduced_multiplication_gs43( params, encoding_scheme, true, validation_flag, synapses( synapse_index ).synapse_utilities );            
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute the amximum synaptic conductance for the synapses of a reduced multiplication subnetwork.
        function [ gs, synapses, self ] = compute_reduced_multiplication_gs( self, synapse_IDs, params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, params = struct( [  ] ); end                                               % [struct] Parameters Structure.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the generic params.
            params = self.process_reduced_multiplication_gs_params( synapse_IDs, params, encoding_scheme, synapses, undetected_option );
            
            % Convert the generic design params into gs41 design params.
            params_gs41 = self.convert_reduced_multiplication_gs_params2gs41_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 41.
            [ gs41, synapses, synapse_manager ] = self.compute_reduced_multiplication_gs41( synapse_IDs, params_gs41, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Convert the generic design params into gs32 design params.
            params_gs32 = self.convert_reduced_multiplication_gs_params2gs32_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 32.
            [ gs32, synapses, synapse_manager ] = synapse_manager.compute_reduced_multiplication_gs32( synapse_IDs, params_gs32, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Convert the generic design params into gs43 design params.
            params_gs43 = self.convert_reduced_multiplication_gs_params2gs43_params( params, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance for synapse 43.
            [ gs43, synapses, synapse_manager ] = synapse_manager.compute_reduced_multiplication_gs43( synapse_IDs, params_gs43, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synaptic conductances.
            gs = [ gs41, gs32, gs43 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to compute and set the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function [ gs, synapses, self ] = compute_dmcpg_gs( self, synapse_IDs, delta_oscillatory, Id_max, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, Id_max = self.Id_max_DEFAULT; end                                    % [A] Max Drive Current.                                  	% [A] Maximum Drive Current.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end              % [V] Oscillatory CPG Bifurcation Parameter.            	% [V] Oscillatory CPG Equilibrium Offset.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            gs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate                                                  % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ gs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_dmcpg_gs( synapses( synapse_index ).dEs, delta_oscillatory, Id_max, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        %% Enable & Disable Functions.
        
        % Implement a function to verify the compatibility of synapse properties.
        function valid_flag = validate_synapse_properties( self, n_synapses, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities )
        
            % Set the default synapse properties.
            if nargin < 12, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                     	% [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.deltas_DEFAULT*ones( 1, n_synapses ); end                                          % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = 2*ones( 1, n_synapses ); end                                                     % [#] ID of Neuron At Which Synapse Terminates.
            if nargin < 7, from_neuron_IDs = ones( 1, n_synapses ); end                                                     % [#] ID of Neuron From Which Synapse Originates.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductances.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                      % [str] Synapse Names.
            if nargin < 3, IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end             % [#] Synapse IDs.
            
            % Determine whether to convert the names property to a cell.
            if ~iscell( names ), names = { names }; end
            
            % Determine whether the synapse properties are relevant.
            valid_flag = ( n_synapses == length( IDs ) ) && ( n_synapses == length( names ) ) && ( n_synapses == length( dEs ) ) && ( n_synapses == length( gs ) ) && ( n_synapses == length( from_neuron_IDs ) ) && ( n_synapses == length( to_neuron_IDs ) ) && ( n_synapses == length( deltas ) ) && ( n_synapses == length( enabled_flags ) );
                
        end
        
            
        % Implement a function to enable a synapse.
        function [ enabled_flag, synapses, self ] = enable_synapse( self, synapse_ID, synapses, set_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Enable this synapse.
            [ enabled_flag, synapses( synapse_index ) ] = synapses( synapse_index ).enable( true );
            
            % Determine whether to update the synapse maanger object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to enable synapses.
        function [ enabled_flags, synapses, self ] = enable_synapses( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % SEt the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to enable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Preallocate an array to store the enabled flags.
            enabled_flags = false( 1, num_synapses_to_enable );
            
            % Enable all of the specified synapses.
            for k = 1:num_synapses_to_enable                                                    % Iterate through all of the specified synapses...
                
                % Enable this synapse.
                [ enabled_flags( k ), synapses, self ] = self.enable_synapse( synapse_IDs( k ), synapses, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to disable a synapse.
        function [ enabled_flag, synapses, self ] = disable_synapse( self, synapse_ID, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Disable this synapse.
            [ enabled_flag, synapses( synapse_index ) ] = synapses( synapse_index ).disable( true );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to disable synapses.
        function self = disable_synapses( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Preallocate an array to store the enabled flags.
            enabled_flags = false( 1, num_synapses_to_enable );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                                                    % Iterate through all of the specified synapses...
                
                % Disable this synapse.
                [ enabled_flags( k ), synapses, self ] = self.disable_synapse( synapse_IDs( k ), synapses, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to toggle a synapses enabled flag.
        function [ enabled_flag, synapses, self ] = toggle_enabled_synapse( self, synapse_ID, synapses, set_flag, undetected_option )
        
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Toggle whether this synapse is enabled.
            [ enabled_flag, synapses( synapse_index ) ] = synapses( synapse_index ).toogle_enabled( synapses( synapse_index ).enabled_flag, true );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to toggle synapse enable state.
        function [ enabled_flags, synapses, self ] = toggle_enabled_synapses( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Preallocate an array to store the enabled flags.
            enabled_flags = false( 1, num_synapses_to_enable );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                                                    % Iterate through all of the specified synapses...
                
                % Toggle this synapse.
                [ enabled_flags( k ), synapses, self ] = self.toggle_enabled_synapse( synapse_IDs( k ), synapses, set_flag, undetected_option );
                
            end
            
        end
        
        
        %% Synapse Creation Functions.
        
        % Implement a function to update the synapse manager.
        function [ synapses, self ] = update_synapse_manager( self, synapses, synapse_manager, set_flag )
        
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end         	% [T/F] Set Flag (Determines whether output self object is updated.)
            
            % Determine whether to update the synapse manager object.
            if set_flag                                                  	% If we want to update the synapse manager object...
                
                % Update the synapse manager object.
                self = synapse_manager;
            
            else                                                            % Otherwise...
                
                % Reset the synapses object.
                synapses = self.synapses;
            
            end
            
        end
        
        
        % Implement a function to process synapse creation inputs.
        function [ n_synapses, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = process_synapse_creation_inputs( self, n_synapses, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities )
           
            % Set the default synapse properties.
            if nargin < 13, array_utilities = self.array_utilities; end                                    	% [class] Array Utilities Class.
            if nargin < 10, synapses = self.synapses; end                                                 	% [class] Array of Synapse Class Objects.
            if nargin < 9, enabled_flags = true; end                                                        % [T/F] Synapse Enabled Flag.
            if nargin < 8, deltas = self.delta_noncpg_DEFAULT; end                                         	% [V] Generic CPG Equilibrium Offset.
            if nargin < 7, to_neuron_IDs = self.to_neuron_ID_DEFAULT; end                                   % [-] To Neuron ID.
            if nargin < 6, from_neuron_IDs = self.from_neuron_ID_DEFAULT; end                               % [-] From Neuron ID.
            if nargin < 5, gs = self.gs_DEFAULT; end                                                        % [S] Maximum Synaptic Conductance.
            if nargin < 4, dEs = self.dEs_minimum_DEFAULT; end                                              % [V] Synaptic Reversal Potential.
            if nargin < 3, names = ''; end                                                                  % [-] Synapse Name.
            if nargin < 2, IDs = self.generate_unique_synapse_ID( synapses, array_utilities ); end          % [#] Synapse ID.
           
            % Convert the synpase params from cells to arrays as appropriate.
            enabled_flags = array_utilities.cell2array( enabled_flags );                                    % [T/F] Synapse Enabled Flag.
            deltas = array_utilities.cell2array( deltas );                                                  % [V] Generic CPG Equilibrium Offset.
            to_neuron_IDs = array_utilities.cell2array( to_neuron_IDs );                                    % [-] To Neuron ID.
            from_neuron_IDs = array_utilities.cell2array( from_neuron_IDs );                                % [-] From Neuron ID.
            gs = array_utilities.cell2array( gs );                                                          % [S] Maximum Synaptic Conductance.
            dEs = array_utilities.cell2array( dEs );                                                        % [V] Synaptic Reversal Potential.
            names = array_utilities.cell2array( names );                                                    % [-] Synapse Name.
            IDs = array_utilities.cell2array( IDs );                                                        % [#] Synapse ID.
            
            % Ensure that the synapse properties match the required number of synapses.
            assert( self.validate_synapse_properties( n_synapses, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities ), 'Provided neuron properties must be of consistent size.' )
            
        end
        
        
        % Implement a function to process the synapse creation outputs.
        function [ IDs, synapses ] = process_synapse_creation_outputs( ~, IDs, synapses, as_cell_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 5, array_utilities = self.array_utilities; end                    	% [class] Array Utilities Class.
            if nargin < 4, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)                   	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 3, synapses = self.neurons; end                                    	% [class] Array of Synapse Class Objects.
            
            % Determine whether to embed the new synapse IDs and objects in cells.
            if as_cell_flag                                                                 % If we want to embed the new synapse IDs and objects into cells...
                
                % Determine whether to embed the synapse IDs into a cell.
                if ~iscell( IDs )                                                           % If the IDs are not already a cell...
                
                    % Embed synapse IDs into a cell.
                    IDs = { IDs };
                
                end
                
                % Determine whether to embed the synapse objects into a cell.
                if ~iscell( synapses )                                                       % If the synapses are not already a cell...
                
                    % Embed synapse objects into a cell.
                    synapses = { synapses };
                    
                end
                
            else                                                                            % Otherwise...
                
                % Determine whether to embed the synapse IDs into an array.
                if iscell( IDs )                                                            % If the synapse IDs are a cell...
                
                    % Convert the synapse IDs cell to a regular array.
                    IDs = array_utilities.cell2array( IDs );
                    
                end
                
                % Determine whether to embed the synapse objects into an array.
                if iscell( synapses )                                                        % If the synapse objects are a cell...
                
                    % Convert the synapse objects cell to a regular array.
                    synapses = array_utilities.cell2array( synapses );
                    
                end
                
            end
            
        end
        
        
        % Implement a function to create a new synapse.
        function [ ID_new, synapse_new, synapses, self ] = create_synapse( self, ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the default synapse properties.
            if nargin < 13, array_utilities = self.array_utilities; end                                     % [class] Array Utilities Class.
            if nargin < 12, as_cell_flag = self.as_cell_flag_DEFAULT; end                                  	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)                                   % [T/F] As Cell Flag (Determines whether the new synapse IDs and objects should be stored in arrays or cells.)
            if nargin < 11, set_flag = self.set_flag_DEFAULT; end                                          	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 10, synapses = self.synapses; end                                                   % [class] Array of Synapse Class Objects.
            if nargin < 9, enabled_flag = true; end                                                        	% [T/F] Synapse Enabled Flag.
            if nargin < 8, delta = self.delta_noncpg_DEFAULT; end                                         	% [V] Generic CPG Equilibrium Offset.
            if nargin < 7, to_neuron_ID = self.to_neuron_ID_DEFAULT; end                                  	% [-] To Neuron ID.
            if nargin < 6, from_neuron_ID = self.from_neuron_ID_DEFAULT; end                              	% [-] From Neuron ID.
            if nargin < 5, gs = self.gs_DEFAULT; end                                                        % [S] Maximum Synaptic Conductance.
            if nargin < 4, dEs = self.dEs_minimum_DEFAULT; end                                              % [V] Synaptic Reversal Potential.
            if nargin < 3, name = ''; end                                                                   % [-] Synapse Name.
            if nargin < 2, ID = self.generate_unique_synapse_ID( synapses, array_utilities ); end           % [#] Synapse ID.
            
            % Process the synapse creation properties.
            [ ~, ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag ] = self.process_synapse_creation_inputs( 1, ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, array_utilities );
            
            % Ensure that this synapse ID is a unique natural.
            assert( self.unique_natural_synapse_ID( ID, synapses, array_utilities ), 'Proposed synapse ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the synapse manager.
            synapse_manager = self;
            
            % Create an instance of the synapse class.
            synapse_new = synapse_class( ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag );
            
            % Retrieve the new synapse ID.
            ID_new = synapse_new.ID; 
            
            % Determine whether to embed the new synapse ID and object in cells.
            [ ID_new, synapse_new ] = self.process_synapse_creation_outputs( ID_new, synapse_new, as_cell_flag, array_utilities );
            
            % Append this synapse to the array of existing synapses.
            synapses = [ synapses, synapse_new ];
            
            % Update the synapse manager to reflect the update neurons object.
            synapse_manager.synapses = synapses;
            synapse_manager.num_synapses = length( synapses );
            
            % Determine whether to update the synapse manager object.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create multiple synapses.
        function [ IDs_new, synapses_new, synapses, self ] = create_synapses( self, n_synapses_to_create, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the default synapse properties.
            if nargin < 14, array_utilities = self.array_utilities; end                                                             % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                                 	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                           % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses_to_create ); end                                                       % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_noncpg_DEFAULT*ones( 1, n_synapses_to_create ); end                                  % [V] Generic CPG Equilibrium Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses_to_create ); end                          % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses_to_create ); end                      % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses_to_create ); end                                            % [S] Maximum Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_minimum_DEFAULT*ones( 1, n_synapses_to_create ); end                                      % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses_to_create ); end                                                   % [-] Synapse Name.
            if nargin < 3, IDs = self.generate_unique_synapse_IDs( n_synapses_to_create, synapses, array_utilities ); end           % [#] Synapse ID.
            
            % Process the synapse creation properties.
            [ n_synapses_to_create, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses_to_create, IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Preallocate an array to store the new synapses.
            synapses_new = repmat( synapse_class(  ), [ 1, n_synapse_to_create ] );
            
            % Preallocate an array to store the new synapse IDs.
            IDs_new = zeros( 1, n_synapses_to_create );
            
            % Create an instance of the synapse manager that can be updated.
            synapse_manager = self;
            
            % Create each of the spcified synapses.
            for k = 1:n_synapses_to_create                                                                                          % Iterate through each of the synapses we want to create...
                
                % Create this synapse.                
                [ IDs_new{ k }, synapses_new{ k }, synapses, synapse_manager ] = synapse_manager.create_synapse( IDs( k ), names{ k }, dEs( k ), gs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ), deltas( k ), enabled_flags( k ), synapses, true, false, array_utilities );
                
            end
            
            % Determine whether to embed the new synapse ID and object in cells.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Determine whether to update the synapse manager object.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to delete a synapse.
        function [ synapses, self ] = delete_synapse( self, synapse_ID, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Create an instance of the synpase manager that can be updated.
            synapse_manager = self;
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Remove this synapse from the array of synapses.
            synapses( synapse_index ) = [  ];
            
            % Update the synpase manager to reflect these changes.
            synapse_manager.synapses = synapses;
            synapse_manager.num_synapses = length( synapses );
            
            % Determine whether to update the synapses and synapse manager objects in the output.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to delete multiple synapses.
        function [ synapses, self ] = delete_synapses( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapses to delete.
            num_synapses_to_delete = length( synapse_IDs );
            
            % Delete each of the specified synapses.
            for k = 1:num_synapses_to_delete                                                    % Iterate through each of the synapses we want to delete...
                
                % Delete this synapse.
                [ synapses, self ] = self.delete_synapse( synapse_IDs( k ), synapses, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to connect a synapse to neurons.
        function [ synapses, self ] = connect_synapse( self, synapse_ID, from_neuron_ID, to_neuron_ID, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Set the from neuron ID property of this synapse.
            synapses( synapse_index ).from_neuron_ID = from_neuron_ID;
            
            % Set the to neuron ID property of this synapse.
            synapses( synapse_index ).to_neuron_ID = to_neuron_ID;
         
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to connet multiple synapses to multiple neurons.
        function [ synapses, self ] = connect_synapses( self, synapse_IDs, from_neuron_IDs, to_neuron_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, to_neuron_IDs = 2; end
            if nargin < 3, from_neuron_IDs = 1; end
            if nargin < 2, synapse_IDs = 'all'; end                                             % [str] Synapse IDs.
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapses to connect.
            num_synapses_to_connect = length( synapse_IDs );
            
            % Ensure that the synapse IDs, from neuron IDs, and to neuron IDs have the same length.
            assert( ( num_synapses_to_connect == length( from_neuron_IDs ) ) && ( num_synapses_to_connect == length( to_neuron_IDs ) ), 'The number of from and to neuron IDs must match the number of specified synapse IDs.' )
            
            % Connect each of the specified synapses.
            for k = 1:num_synapses_to_connect                                                   % Iterate through each of the synapses we want to connect...
                
                % Connect this synapse.
                [ synapses, self ] = self.connect_synapse( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ), synapses, set_flag, undetected_option );
                                
            end
            
        end
                
        
        %% Subnetwork Synapse Quantity Functions.
        
        % Implement a function to compute the number of multistate cpg synapses.
        function n_mcpg_synapses = compute_num_mcpg_synapses( self, num_cpg_neurons )
           
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                  % [#] Number of CPG Neurons.
            
            % Compute the number of synapses.
            n_mcpg_synapses = num_cpg_neurons^2;
            
        end
            
        
        % Implement a function to compute the number of driven multistate cpg synapses.
        function [ n_dmcpg_synapses, n_mcpg_synapses ] = compute_num_dmcpg_synapses( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                  % [#] Number of CPG Neurons.
            
            % Compute the number of multistate cpg synapses.
            n_mcpg_synapses = self.compute_num_mcpg_synapses( num_cpg_neurons );
            
            % Compute the number of driven multistate cpg synapses.
            n_dmcpg_synapses = n_mcpg_synapses + num_cpg_neurons;
            
        end
        
        
        % Implement a function to compute the number of driven multistate central pattern generator to modulated split subtraction voltage based integration subnetwork synapses.
        function n_dmcpg2mssvbi_synapses = compute_num_dmcpg2mssvbi_synapses( self, num_cpg_neurons )
        
            % Set the default input arugments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                  % [#] Number of CPG Neurons.
            
            % Compute the number of driven multistate central pattern generator to modulated split subtraction voltage based integration subnetwork synapses 
            n_dmcpg2mssvbi_synapses = 2*num_cpg_neurons;
            
        end
        
        
        % Implement a function to compute the number of modulated split subtraction voltage based integration to split lead lag subnetwork synapses.
        function n_mssvbi2sll_synapses = compute_num_mssvbi2sll_synapses( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                  % [#] Number of CPG Neurons.
            
            % Compute the number of mssbvi2sll synapses.
            n_mssvbi2sll_synapses = 2*num_cpg_neurons + 2;
            
        end
        
        
        %% Subnetwork Synapse Creation Functions.

        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a transmission subnetwork.
        function [ ID_new, synapse_new, synapses, self ] = create_transmission_synapse( self, neuron_IDs, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, set_flag, as_cell_flag, array_utilities )
        
            % Define the number of neurons and synapses.
            n_neurons = self.n_transmission_neurons_DEFAULT;                                                              	% [#] Number of Neurons.
            n_synapses = self.n_transmission_synapses_DEFAULT;                                                            	% [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                   	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                         	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                 	% [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flag = true( 1, n_synapses ); end                                                      	% [T/F] Enabled Flag.
            if nargin < 9, delta = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           	% [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_ID = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            	% [#] To Neuron ID.
            if nargin < 7, from_neuron_ID = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                         	% [#] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, name = repmat( { '' }, 1, n_synapses ); end                                                     	% [str] Synapse Name.
            if nargin < 3, synapse_ID = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end      % [#] Synapse ID.     
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
        
            % Process the synapse creation inputs.
            [ ~, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag ] = self.process_synapse_creation_inputs( n_synapses, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )

            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_ID, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_ID );
            [ to_neuron_ID, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_ID );
            
            % Determine whether it is necessary to generate synapse names.
            [ name, name_flag ] = self.process_names( name );
            
            % Determine whether it is necessary to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_ID = neuron_IDs( 1 ); end
            if to_neuron_IDs_flag, to_neuron_ID = neuron_IDs( 2 ); end
            
            % Determine whether it is necessary to comptue the synapse name.
            if name_flag, name = sprintf( 'Transmission %0.0f%0.0f', from_neuron_ID, to_neuron_ID ); end
            
            % Create the transmission subnetwork synapse.    
            [ ID_new, synapse_new, synapses, synapse_manager ] = self.create_synapse( synapse_ID, name{ 1 }, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, true, false, array_utilities );
               
            % Determine how to format the synapse IDs and objects.
            [ ID_new, synapse_new ] = self.process_synapse_creation_outputs( ID_new, synapse_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to create the synapses for an addition subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_addition_synapses( self, n_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of neurons.
            if nargin < 2, n_neurons = self.n_addition_neurons_DEFAULT; end                                                   % [#]  Number of Neurons.
            
            % Compute the number of addition synapses.
            n_synapses = n_neurons - 1;                                                                                         % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                         % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                       % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                               % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                       % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                             % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                               % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                                % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                    % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                         % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end         % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from neuron IDs, to neuron IDs, and synapse names.
           if from_neuron_IDs_flag || to_neuron_IDs_flag || names_flag                                                          % If we want to compute the from neuron IDs, to enuron IDs, or synapse names...
               
               % Compute the from neuron IDs, to neuron IDs, and synapse names for each synpase as appropriate.
               for k = 1:n_synapses                                                                                             % Iterate througuh each of the synapses...
                  
                   % Compute the from and to neuron IDs for this synapse.
                   if from_neuron_IDs_flag, from_neuron_IDs( k ) = neuron_IDs( k ); end
                   if to_neuron_IDs_flag, to_neuron_IDs( k ) = neuron_IDs( end ); end 
                   
                   % Compute the name of this synapse.
                   if names_flag, names{ k } = sprintf( 'Addition %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ); end
                   
               end
               
           end
            
           % Create the multistate cpg subnetwork synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag ); 
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a subtraction subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_subtraction_synapses( self, n_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of neurons.
            if nargin < 2, n_neurons = self.n_subtraction_neurons_DEFAULT; end                                                % [#] Number of Neurons.
            
            % Compute the number of addition synapses.
            n_synapses = n_neurons - 1;                                                                                         % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                         % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                     	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                               % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                       % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                             % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                               % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                                % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                    % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                         % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end         % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from neuron IDs, to neuron IDs, and synapse names.
           if from_neuron_IDs_flag || to_neuron_IDs_flag || names_flag                                                        	% If we want to compute the from neuron IDs, to enuron IDs, or synapse names...
               
               % Compute the from neuron IDs, to neuron IDs, and synapse names for each synpase as appropriate.
               for k = 1:n_synapses                                                                                             % Iterate througuh each of the synapses...
                  
                   % Compute the from and to neuron IDs for this synapse.
                   if from_neuron_IDs_flag, from_neuron_IDs( k ) = neuron_IDs( k ); end
                   if to_neuron_IDs_flag, to_neuron_IDs( k ) = neuron_IDs( end ); end 
                   
                   % Compute the name of this synapse.
                   if names_flag, names{ k } = sprintf( 'Subtraciton %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ); end
                   
               end
               
           end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag ); 
            
        end
        
        
        % Implement a function to create the synapses for a double subtraction subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_double_subtraction_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.n_double_subtraction_neurons_DEFAULT;                                                        % [#] Number of Neurons.
            n_synapses = self.n_double_subtraction_synapses_DEFAULT;                                                      % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                  	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                 	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ 1, 2, 1, 2 ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ 1, 1, 2, 2 ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Double Subtraction %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a centering subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_centering_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.n_centering_neurons_DEFAULT;                                                                 % [#] Number of Neurons.
            n_synapses = self.n_centering_synapses_DEFAULT;                                                               % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                            	% [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 4 ), neuron_IDs( 3 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 4 ), neuron_IDs( 4 ), neuron_IDs( 5 ), neuron_IDs( 5 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Centering %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a double centering subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_double_centering_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.n_double_centering_neurons_DEFAULT;                                                          % [#] Number of Neurons.
            n_synapses = self.n_double_centering_synapses_DEFAULT;                                                        % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                 	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 2 ), neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 5 ), neuron_IDs( 1 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 4 ), neuron_IDs( 4 ), neuron_IDs( 5 ), neuron_IDs( 5 ), neuron_IDs( 6 ), neuron_IDs( 6 ), neuron_IDs( 7 ), neuron_IDs( 7 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Double Centering %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses that connect a double subtraction subnetwork to a double centering subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_ds2dc_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_ds_neurons = self.n_double_subtraction_neurons_DEFAULT;                                                     % [#] Number of DS Neurons.
            n_neurons = self.n_ds2dc_neurons_DEFAULT;                                                                     % [#] Number of Neurons.
            
            % Define the number of synapses.
            n_synapses = self.n_ds2dc_synapses_DEFAULT;                                                                   % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 4 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( n_ds_neurons + 1 ), neuron_IDs( n_ds_neurons + 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Double Subtrction -> Double Centering %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
            % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a centered double subtraction subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_cds_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons from the various subnetworks.
            n_ds_neurons = self.n_double_subtraction_neurons_DEFAULT;                                                     % [#] Number of DS Neurons.
            n_dc_neurons = self.n_double_centering_neurons_DEFAULT;                                                       % [#] Number of DC Neurons.
            n_neurons = n_ds_neurons + n_dc_neurons;                                                                        % [#] Number of Neurons.
            
            % Define the number of synapses from the various subnetworks.
            n_ds_synapses = self.n_double_subtraction_synapses_DEFAULT;                                                   % [#] Number of DS Synapses.
            n_dc_synapses = self.n_double_centering_synapses_DEFAULT;                                                     % [#] Number of DC Synapses.
            n_synapses = self.n_ds2dc_synapses_DEFAULT;                                                                   % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
                        
            % Preallocate a cell array to store the synapse IDs and objects.
            IDs_new = cell( 1, 3 );
            synapses_new = cell( 1, 3 );
            
            % Define the starting and ending indexes for the double subtraction information.
            i_start_ds_neurons = 1; i_end_ds_neurons = n_ds_neurons;
            i_start_ds_synapses = 1; i_end_ds_synapses = n_ds_synapses;
            
            % Create the double subtraction subnetwork synapses.
            [ IDs_new{ 1 }, synapses_new{ 1 }, synapses, synapse_manager ] = self.create_double_subtraction_synapses( neuron_IDs( i_start_ds_neurons:i_end_ds_neurons ), synapse_IDs( i_start_ds_synapses:i_end_ds_synapses ), names{ i_start_ds_synapses:i_end_ds_synapses }, dEs( i_start_ds_synapses:i_end_ds_synapses ), gs( i_start_ds_synapses:i_end_ds_synapses ), from_neuron_IDs( i_start_ds_synapses:i_end_ds_synapses ), to_neuron_IDs( i_start_ds_synapses:i_end_ds_synapses ), deltas( i_start_ds_synapses:i_end_ds_synapses ), enabled_flags( i_start_ds_synapses:i_end_ds_synapses ), synapses, true, false, array_utilities );
            
            % Define the starting and ending indexes for the double centering information.
            i_start_dc_neurons = i_end_ds_neurons + 1; i_end_dc_neurons = i_end_ds_neurons + n_dc_neurons;
            i_start_dc_synapses = i_end_ds_synapses + 1; i_end_dc_synapses = i_end_ds_synapses + n_dc_synapses;
            
            % Create the double centering subnetwork synapses.
            [ IDs_new{ 2 }, synapses_new{ 2 }, synapses, synapse_manager ] = synapse_manager.create_double_centering_synapses( neuron_IDs( i_start_dc_neurons:i_end_dc_neurons ), synapse_IDs( i_start_dc_synapses:i_end_dc_synapses ), names{ i_start_dc_synapses:i_end_dc_synapses }, dEs( i_start_dc_synapses:i_end_dc_synapses ), gs( i_start_dc_synapses:i_end_dc_synapses ), from_neuron_IDs( i_start_dc_synapses:i_end_dc_synapses ), to_neuron_IDs( i_start_dc_synapses:i_end_dc_synapses ), deltas( i_start_dc_synapses:i_end_dc_synapses ), enabled_flags( i_start_dc_synapses:i_end_dc_synapses ), synapses, true, false, array_utilities );
            
            % Define the starting and ending indexes for the ds to dc information.
            i_start_ds2dc_neurons = 1; i_end_ds2dc_neurons = n_neurons;
            i_start_ds2dc_synapses = i_end_dc_synapses + 1; i_end_ds2dc_synapses = i_end_dc_synapses + n_synapses;
            
            % Create the double subtraction subnetwork to double centering subnetwork synapses.
            [ IDs_new{ 3 }, synapses_new{ 3 }, synapses, synapse_manager ] = synapse_manager.create_ds2dc_synapses( neuron_IDs( i_start_ds2dc_neurons:i_end_ds2dc_neurons ), synapse_IDs( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), names{ i_start_ds2dc_synapses:i_end_ds2dc_synapses }, dEs( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), gs( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), from_neuron_IDs( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), to_neuron_IDs( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), deltas( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), enabled_flags( i_start_ds2dc_synapses:i_end_ds2dc_synapses ), synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
                
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to create the synapse for an inversion subnetwork.
        function [ ID_new, synapse_new, synapses, self ] = create_inversion_synapse( self, neuron_IDs, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons and synapses.
            n_neurons = self.n_inversion_neurons_DEFAULT;                                                                 % [#] Number of Neurons.
            n_synapses = self.n_inversion_synapses_DEFAULT;                                                               % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flag = true( 1, n_synapses ); end                                                      	% [T/F] Enabled Flag.
            if nargin < 9, delta = self.delta_DEFAULT*ones( 1, n_synapses ); end                                            % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_ID = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                              % [#] To Neuron ID.
            if nargin < 7, from_neuron_ID = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                          % [#] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, name = repmat( { '' }, 1, n_synapses ); end                                                  	% [str] Synapse Name.
            if nargin < 3, synapse_ID = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end      % [#] Synapse ID.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
        
            % Process the synapse creation inputs.
            [ ~, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag ] = self.process_synapse_creation_inputs( n_synapses, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )

            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_ID, from_neuron_ID_flag ] = self.process_to_from_neuron_IDs( from_neuron_ID );
            [ to_neuron_ID, to_neuron_ID_flag ] = self.process_to_from_neuron_IDs( to_neuron_ID );
            
            % Determine whether it is necessary to generate synapse names.
            [ name, name_flag ] = self.process_names( name );
            
            % Determine whether it is necessary to compute the from and to neuron IDs.
            if from_neuron_ID_flag, from_neuron_ID = neuron_IDs( 1 ); end
            if to_neuron_ID_flag, to_neuron_ID = neuron_IDs( 2 ); end
            
            % Determine whether it is necessary to comptue the synapse name.
            if name_flag, name = sprintf( 'Inversion %0.0f%0.0f', from_neuron_ID, to_neuron_ID ); end
            
            % Create the modulation subnetwork synapse.    
            [ ID_new, synapse_new, synapses, synapse_manager ] = self.create_synapse( synapse_ID, name{ 1 }, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, true, false, array_utilities );
               
            % Determine how to format the synapse IDs and objects.
            [ ID_new, synapse_new ] = self.process_synapse_creation_outputs( ID_new, synapse_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end

        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to create the synapse for a reduced inversion subnetwork.
        function [ ID_new, synapse_new, synapses, self ] = create_reduced_inversion_synapse( self, neuron_IDs, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons and synapses.
            n_neurons = self.n_inversion_neurons_DEFAULT;                                                                 % [#] Number of Neurons.
            n_synapses = self.n_inversion_synapses_DEFAULT;                                                               % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flag = true( 1, n_synapses ); end                                                          % [T/F] Enabled Flag.
            if nargin < 9, delta = self.delta_DEFAULT*ones( 1, n_synapses ); end                                            % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_ID = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                             % [#] To Neuron ID.
            if nargin < 7, from_neuron_ID = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                         % [#] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                            	% [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, name = repmat( { '' }, 1, n_synapses ); end                                                  	% [str] Synapse Name.
            if nargin < 3, synapse_ID = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end      % [#] Synapse ID.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
        
            % Process the synapse creation inputs.
            [ ~, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag ] = self.process_synapse_creation_inputs( n_synapses, synapse_ID, name, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )

            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_ID, from_neuron_ID_flag ] = self.process_to_from_neuron_IDs( from_neuron_ID );
            [ to_neuron_ID, to_neuron_ID_flag ] = self.process_to_from_neuron_IDs( to_neuron_ID );
            
            % Determine whether it is necessary to generate synapse names.
            [ name, name_flag ] = self.process_names( name );
            
            % Determine whether it is necessary to compute the from and to neuron IDs.
            if from_neuron_ID_flag, from_neuron_ID = neuron_IDs( 1 ); end
            if to_neuron_ID_flag, to_neuron_ID = neuron_IDs( 2 ); end
            
            % Determine whether it is necessary to comptue the synapse name.
            if name_flag, name = sprintf( 'Reduced Inversion %0.0f%0.0f', from_neuron_ID, to_neuron_ID ); end
            
            % Create the synapse.    
            [ ID_new, synapse_new, synapses, synapse_manager ] = self.create_synapse( synapse_ID, name{ 1 }, dEs, gs, from_neuron_ID, to_neuron_ID, delta, enabled_flag, synapses, true, false, array_utilities );
               
            % Determine how to format the synapse IDs and objects.
            [ ID_new, synapse_new ] = self.process_synapse_creation_outputs( ID_new, synapse_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a division subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_division_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_division_neurons_DEFAULT;                                                                  % [#] Number of Neurons.
            n_synapses = self.n_division_synapses_DEFAULT;                                                                % [#] Number of Synpases.
             
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                   	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Division %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to create the synapses for a division after inversion subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_dai_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_division_neurons_DEFAULT;                                                                  % [#] Number of Neurons.
            n_synapses = self.n_division_synapses_DEFAULT;                                                                % [#] Number of Synpases.
             
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                   	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                     	% [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                             % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                         % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                  % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Division After Inversion %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to create the synapses for a reduced division subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_reduced_division_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_division_neurons_DEFAULT;                                                                  % [#] Number of Neurons.
            n_synapses = self.n_division_synapses_DEFAULT;                                                                % [#] Number of Synpases.
             
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                   	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Reduced Division %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Reduced Division After Inversion Subnetwork Functions ----------

        % Implement a function to create the synapses for a reduced division after inversion subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_reduced_dai_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_division_neurons_DEFAULT;                                                                  % [#] Number of Neurons.
            n_synapses = self.n_division_synapses_DEFAULT;                                                                % [#] Number of Synpases.
             
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                   	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Reduced Division After Inversion %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a multiplication subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_multiplication_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_multiplication_neurons_DEFAULT;                                                            % [#] Number of Neurons.
            n_synapses = self.n_multiplication_synapses_DEFAULT;                                                          % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 3 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 4 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                               % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                    % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Multiplcation %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to create the synapses for a reduced multiplication subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_reduced_multiplication_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_multiplication_neurons_DEFAULT;                                                            % [#] Number of Neurons.
            n_synapses = self.n_multiplication_synapses_DEFAULT;                                                          % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 3 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 4 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                               % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                    % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Reduced Multiplcation %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a derivation subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_derivation_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_derivation_neurons_DEFAULT;                                                                % [#] Number of Neurons.
            n_synapses = self.n_derivation_synapses_DEFAULT;                                                              % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                               	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Derivation %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to create the synapses for an integration subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_integration_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_integration_neurons_DEFAULT;                                                               % [#] Number of Neurons.
            n_synapses = self.n_integration_synapses_DEFAULT;                                                             % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 2 ), neuron_IDs( 1 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'Derivation %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a voltage based integration subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_vbi_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_vbi_neurons_DEFAULT;                                                                       % [#] Number of Neurons.
            n_synapses = self.n_vbi_synapses_DEFAULT;                                                                     % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 3 ), neuron_IDs( 4 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 3 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'VBI %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a split voltage based integration subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_svbi_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons and synapses.
            n_neurons = self.num_svbi_neurons_DEFAULT;                                                                      % [#] Number of Neurons.
            n_synapses = self.num_svbi_synapses_DEFAULT;                                                                    % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                  	% [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 1 ), neuron_IDs( 2 ), neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 5 ), neuron_IDs( 6 ), neuron_IDs( 5 ), neuron_IDs( 6 ), neuron_IDs( 9 ), neuron_IDs( 3 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 3 ), neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 7 ), neuron_IDs( 7 ), neuron_IDs( 8 ), neuron_IDs( 8 ), neuron_IDs( 6 ), neuron_IDs( 5 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'SVBI %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
           % Create the synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );

            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
                        
        end
        
        
        % Implement a function to create the synapses for a modulated split voltage based integration subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_msvbi_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons from the various subnetworks.
            n_svbi_neurons = self.num_svbi_neurons_DEFAULT;                                                                 % [#] Number of SVBI Neurons.
            n_msvbi_neurons = self.num_msvbi_neurons_DEFAULT;                                                               % [#] Number of MSVBI Neurons.
            n_neurons = n_svbi_neurons + n_msvbi_neurons;                                                                   % [#] Number of Neurons.
            
            % Define the number of synapses from the various subnetworks.
            n_svbi_synapses = self.num_svbi_synapses_DEFAULT;                                                               % [#] Number of SVBI Synapses.
            n_msvbi_synapses = self.num_msvbi_synapses_DEFAULT;                                                             % [#] Number of MSVBI Synapses.
            n_synapses = n_svbi_synapses + n_msvbi_synapses;                                                                % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                 	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Preallocate a cell array to store the synapse IDs and objects.
            IDs_new = cell( 1, 2 );
            synapses_new = cell( 1, 2 );
            
            % Define the starting and ending indexes for the double subtraction information.
            i_start_svbi_neurons = 1; i_end_svbi_neurons = n_svbi_neurons;
            i_start_svbi_synapses = 1; i_end_svbi_synapses = n_svbi_synapses;
            
            % Create the double subtraction subnetwork synapses.
            [ IDs_new{ 1 }, synapses_new{ 1 }, synapses, synapse_manager ] = self.create_svbi_synapses( neuron_IDs( i_start_svbi_neurons:i_end_svbi_neurons ), synapse_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), names{ i_start_svbi_synapses:i_end_svbi_synapses }, dEs( i_start_svbi_synapses:i_end_svbi_synapses ), gs( i_start_svbi_synapses:i_end_svbi_synapses ), from_neuron_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), to_neuron_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), deltas( i_start_svbi_synapses:i_end_svbi_synapses ), enabled_flags( i_start_svbi_synapses:i_end_svbi_synapses ), synapses, true, false, array_utilities );
            
            % Define the starting and ending indexes for the double centering information.
            i_start_msvbi_synapses = i_end_svbi_synapses + 1; i_end_msvbi_synapses = i_end_svbi_synapses + n_msvbi_synapses;
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ to_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ) );
            [ from_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ) );

            % Determine whether it is necessary to generate synapse names.
            [ names{ i_start_msvbi_synapses:i_end_msvbi_synapses }, names_flag ] = self.process_names( names{ i_start_msvbi_synapses:i_end_msvbi_synapses } );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 7 ), neuron_IDs( 8 ), neuron_IDs( 10 ), neuron_IDs( 10 ), neuron_IDs( 1 ), neuron_IDs( 2 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 11 ), neuron_IDs( 12 ), neuron_IDs( 11 ), neuron_IDs( 12 ), neuron_IDs( 10 ), neuron_IDs( 10 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                      	% Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'MSVBI %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
            % Create the msvbi synapses.            
            [ IDs_new{ 2 }, synapses_new{ 2 }, synapses, synapse_manager ] = synapse_manager.create_synapses( n_msvbi_synapses, synapse_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), names{ i_start_msvbi_synapses:i_end_msvbi_synapses }, dEs( i_start_msvbi_synapses:i_end_msvbi_synapses ), gs( i_start_msvbi_synapses:i_end_msvbi_synapses ), from_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), to_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), deltas( i_start_msvbi_synapses:i_end_msvbi_synapses ), enabled_flags( i_start_msvbi_synapses:i_end_msvbi_synapses ), synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
                        
        end
        
        
        % Implement a function to create the synapses for a modulated split difference voltage based integration subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_mssvbi_synapses( self, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons from the various subnetworks.
            n_ds_neurons = self.num_ds_neurons_DEFAULT;                                                                     % [#] Number of DS Neurons.
            n_msvbi_neurons = self.num_msvbi_neurons_DEFAULT;                                                               % [#] Number of MSVBI Neurons.
            n_mssvbi_neurons = self.num_mssvbi_neurons_DEFAULT;                                                             % [#] Number of MSSVBI Neurons.
            n_neurons = n_ds_neurons + n_msvbi_neurons + n_mssvbi_neurons;                                                  % [#] Number of Neurons.
            
            % Define the number of synapses from the various subnetworks.
            n_ds_synapses = self.num_ds_synapses_DEFAULT;                                                                   % [#] Number of DS Synapses.
            n_msvbi_synapses = self.num_msvbi_synapses_DEFAULT;                                                             % [#] Number of MSVBI Synapses.
            n_mssvbi_synapses = self.num_mssvbi_synapses_DEFAULT;                                                           % [#] Number of MSSVBI Synapses.
            n_synapses = n_ds_synapses + n_msvbi_synapses + n_mssvbi_synapses;                                              % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 14, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 13, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 12, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 11, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 10, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 9, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                           % [-] Subnetwork Output Offset.
            if nargin < 8, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 7, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 6, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 5, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 4, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 3, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 2, neuron_IDs = 1:n_neurons; end                                                                    % [#] Neuron IDs.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( n_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Preallocate a cell array to store the synapse IDs and objects.
            IDs_new = cell( 1, 3 );
            synapses_new = cell( 1, 3 );            
            
            % Define the starting and ending indexes for the double subtraction information.
            i_start_svbi_neurons = 1; i_end_svbi_neurons = n_svbi_neurons;
            i_start_svbi_synapses = 1; i_end_svbi_synapses = n_svbi_synapses;
            
            % Create the double subtraction subnetwork synapses.
            [ IDs_new{ 1 }, synapses_new{ 1 }, synapses, synapse_manager ] = self.create_double_subtraction_synapses( neuron_IDs( i_start_svbi_neurons:i_end_svbi_neurons ), synapse_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), names{ i_start_svbi_synapses:i_end_svbi_synapses }, dEs( i_start_svbi_synapses:i_end_svbi_synapses ), gs( i_start_svbi_synapses:i_end_svbi_synapses ), from_neuron_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), to_neuron_IDs( i_start_svbi_synapses:i_end_svbi_synapses ), deltas( i_start_svbi_synapses:i_end_svbi_synapses ), enabled_flags( i_start_svbi_synapses:i_end_svbi_synapses ), synapses, true, false, array_utilities );
            
            % Define the starting and ending indexes for the double subtraction information.
            i_start_msvbi_neurons = i_end_svbi_neurons + 1; i_end_msvbi_neurons = i_start_msvbi_neurons + n_msvbi_neurons;
            i_start_msvbi_synapses = i_end_svbi_synapses + 1; i_end_msvbi_synapses = i_start_msvbi_synapses + n_msvbi_synapses;
            
            % Create the modulated split voltage based integration subnetwork synapses.
            [ IDs_new{ 2 }, synapses_new{ 2 }, synapses, synapse_manager ] = synapse_manager.create_msvbi_synapses( neuron_IDs( i_start_msvbi_neurons:i_end_msvbi_neurons ), synapse_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), names{ i_start_msvbi_synapses:i_end_msvbi_synapses }, dEs( i_start_msvbi_synapses:i_end_msvbi_synapses ), gs( i_start_msvbi_synapses:i_end_msvbi_synapses ), from_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), to_neuron_IDs( i_start_msvbi_synapses:i_end_msvbi_synapses ), deltas( i_start_msvbi_synapses:i_end_msvbi_synapses ), enabled_flags( i_start_msvbi_synapses:i_end_msvbi_synapses ), synapses, true, false, array_utilities );
            
            % Define the starting and ending indexes for the double subtraction information.
            i_start_mssvbi_neurons = i_end_msvbi_neurons + 1; i_end_mssvbi_neurons = i_start_mssvbi_neurons + n_mssvbi_neurons;
            i_start_mssvbi_synapses = i_end_msvbi_synapses + 1; i_end_mssvbi_synapses = i_start_mssvbi_synapses + n_mssvbi_synapses;
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ to_neuron_IDs( i_start_mssvbi_neurons:i_end_mssvbi_neurons ), to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs( i_start_mssvbi_neurons:i_end_mssvbi_neurons ) );
            [ from_neuron_IDs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ) );

            % Determine whether it is necessary to generate synapse names.
            [ names{ i_start_mssvbi_synapses:i_end_mssvbi_synapses }, names_flag ] = self.process_names( names{ i_start_mssvbi_synapses:i_end_mssvbi_synapses } );
            
            % Determine whether to compute the from and to neuron IDs.
            if from_neuron_IDs_flag, from_neuron_IDs = [ neuron_IDs( 3 ), neuron_IDs( 4 ) ]; end
            if to_neuron_IDs_flag, to_neuron_IDs = [ neuron_IDs( 5 ), neuron_IDs( 6 ) ]; end
            
            % Determinine whether to compute the synapse names.
            if names_flag                                                                                                   % If we want to compute the synapse names...

                % Compute the synapse names.
                for k = 1:n_synapses                                                                                        % Iterate through each of the synapses...

                    % Compute the name of this synapse.
                    names{ k } = sprintf( 'MSSVBI %0.0f%0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) );

                end
                
            end
            
            % Create the synapses unique to this subnetwork.
            [ IDs_new{ 3 }, synapses_new{ 3 }, synapses, synapse_manager ] = synapse_manager.create_synapses( n_mssvbi_synapses, synapse_IDs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), names{ i_start_mssvbi_synapses:i_end_mssvbi_synapses }, dEs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), gs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), from_neuron_IDs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), to_neuron_IDs( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), deltas( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), enabled_flags( i_start_mssvbi_synapses:i_end_mssvbi_synapses ), synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to create the synapses for a multistate CPG subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_mcpg_synapses( self, num_cpg_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of cpg neurons.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                              % [#] Number of CPG Neurons.
            
            % Compute the number of synapses.
            n_synapses = self.compute_num_mcpg_synapses( num_cpg_neurons );                                                 % [#] Number of Synapses.
            
            % Set the default input arguments.
            if nargin < 15, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 12, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 11, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 10, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                          % [-] Subnetwork Output Offset.
            if nargin < 9, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 8, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 7, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 6, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 5, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 4, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs. 
            if nargin < 3, neuron_IDs = 1:num_cpg_neurons; end                                                              % [#] Number of CPG Neurons.
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );

            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( num_cpg_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Initialize a counter variable.
            k3 = 0;
            
            % Edit the network properties.
            for k1 = 1:num_cpg_neurons                                                                                      % Iterate through each of the CPG neurons (from which the synapses are starting)...
                for k2 = 1:num_cpg_neurons                                                                                  % Iterate through each of the CPG neurons (to which the synapses are going)...
                    
                    % Advance the counter variable.
                    k3 = k3 + 1;
                                        
                    % Set the from neuron ID and to neuron ID.
                    if from_neuron_IDs_flag, from_neuron_IDs( k3 ) = neuron_IDs( k1 ); end
                    if to_neuron_IDs_flag, to_neuron_IDs( k3 ) = neuron_IDs( k2 ); end
                    
                    % Set the name of this synapse.
                    if names_flag, names{ k3 } = sprintf( 'CPG %0.0f%0.0f', neuron_IDs( k1 ), neuron_IDs( k2 ) ); end
                    
                    % Set the reversal potential of this synapse (if necessary).
                    if k1 == k2, dEs( k3 ) = 0; end
                    
                end
            end
            
            % Create the multistate cpg subnetwork synapses.            
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses_to_create, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the synapse manager and synapses objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses for a multistate CPG subnetwork.
        function [ IDs_new, synapses_new, synapses, self ] = create_dmcpg_synapses( self, num_cpg_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities  )
            
            % Compute the number of synapses.
            [ n_synapses, n_mcpg_synapses ] = self.compute_num_dmcpg_synapses( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 15, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 12, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 11, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 10, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                          % [-] Subnetwork Output Offset.
            if nargin < 9, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 8, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 7, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 6, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 5, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 4, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 3, neuron_IDs = 1:( num_cpg_neurons + 1 ); end
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( num_cpg_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
            
            % Preallocate a cell array to store the new synapse IDs and obejcts.
            IDs_new = cell( 1, 2 );
            synapses_new = cell( 1, 2 );
            
            % Define the indexes of the synapses for the multistate cpg synapses.
            i_start_mcpg = 1;
            i_end_mcpg = n_mcpg_synapses;
            
            % Create the multistate cpg synapses.
            [ IDs_new{ 1 }, synapses_new{ 1 }, synapses, synapse_manager ] = self.create_mcpg_synapses( num_cpg_neurons, neuron_IDs( i_start_mcpg:i_end_mcpg ), synapse_IDs( i_start_mcpg:i_end_mcpg ), names{ i_start_mcpg:i_end_mcpg }, dEs( i_start_mcpg:i_end_mcpg ), gs( i_start_mcpg:i_end_mcpg ), from_neuron_IDs( i_start_mcpg:i_end_mcpg ), to_neuron_IDs( i_start_mcpg:i_end_mcpg ), deltas( i_start_mcpg:i_end_mcpg ), enabled_flags( i_start_mcpg:i_end_mcpg ), synapses, true, false, array_utilities );
            
            % Compute the number of drive synapses.
            num_drive_synapses = n_synapses - n_mcpg_synapses;
            
            % Define the indexes of the synapses for the drive synapses.
            i_start_d = i_end_mcpg + 1;
            i_end_d = i_end_mcpg + num_drive_synapses;
            
            % Determine whether it is necessary to generate to and from neuron IDs.
            [ to_neuron_IDs( i_start_d:i_end_d ), to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs( i_start_d:i_end_d ) );
            [ from_neuron_IDs( i_start_d:i_end_d ), from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs( i_start_d:i_end_d ) );
            
            % Determine whether it is necessary to generate synapse names.
            [ names( i_start_d:i_end_d ), names_flag ] = self.process_names( names( i_start_d:i_end_d ) );
                
            % Determine whether to compute the from neuron IDs, to neuron IDs, or names.
            if from_neuron_IDs_flag || to_neuron_IDs_flag || names_flag                                                     % If we want compute either the from neuron IDs, to neuron IDs, or synapse names...
                
                % Compute the from neuron IDs, to neuron IDs, and synapse names as appropriate.
                for k = 1:num_drive_synapes                                                                                 % Iterate through each of the drive synapses...
                    
                    % Determine the neuron ID from which this synapse originates.
                    if from_neuron_IDs_flag, from_neuron_IDs( i_end_mcpg + k ) = neuron_IDs( end ); end
                    
                    % Determine the neuron ID at which this synapse terminates.
                    if to_neuron_IDs_flag, to_neuron_IDs( i_end_mcpg + k ) = neuron_IDs( k ); end
                    
                    % Determine the name of this drive synapse.
                    if names_flag, names{ i_end_mcpg + k } = sprintf( 'Drive -> CPG %0.0f', neuron_IDs( k ) ); end
                    
                end
            end
                
            % Create the drive synapses.
            [ IDs_new{ 2 }, synapses_new{ 2 }, synapses, synapse_manager ] = synapse_manager.create_synapses( num_drive_synapes, synapse_IDs( i_start_d:i_end_d ), names{ i_start_d:i_end_d }, dEs( i_start_d:i_end_d ), gs( i_start_d:i_end_d ), from_neuron_IDs( i_start_d:i_end_d ), to_neuron_IDs( i_start_d:i_end_d ), deltas( i_start_d:i_end_d ), enabled_flags( i_start_d:i_end_d ), synapses, true, false, array_utilities );
                        
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        % Implement a function to create the synapses that connect driven multistate cpg to their respective modulated split subtraction voltage based integration subnetworks.
        function [ IDs_new, synapses_new, synapses, self ] = create_dmcpg2mssvbi_synapses( self, num_cpg_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
            
            % Compute the number of synapses.
            n_synapses = self.compute_num_dmcpg2mssvbi_synapses( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 15, array_utilities = self.array_utilities; end                                                     % [class] Array Utilities Class.
            if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                   % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                           % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 12, synapses = self.synapses; end                                                                   % [class] Array of Synapse Class Objects.
            if nargin < 11, enabled_flags = true( 1, n_synapses ); end                                                         % [T/F] Synapse Enabled Flag.
            if nargin < 10, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                          % [-] Subnetwork Output Offset.
            if nargin < 9, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                            % [-] To Neuron ID.
            if nargin < 8, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                        % [-] From Neuron ID.
            if nargin < 7, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                              % [S] Synaptic Conductance.
            if nargin < 6, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                % [V] Synaptic Reversal Potential.
            if nargin < 5, names = repmat( { '' }, 1, n_synapses ); end                                                     % [str] Synapse names.
            if nargin < 4, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end     % [#] Synapse IDs.            
            if nargin < 3, neuron_IDs = 1:num_cpg_neurons; end                                                              % [#] Number of CPG Neurons.
            
            % Process the synapse creation inputs.
            [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
            
            % Ensure that the neuron properties match the require number of neurons.
            assert( num_cpg_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )

            % Determine whether it is necessary to generate to and from neuron IDs.
            [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
            [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
            
            % Determine whether it is necessary to generate synapse names.
            [ names, names_flag ] = self.process_names( names );
            
            % Determine whether to compute the from neuron IDs, to neuron IDs, and synapse names.
            if to_neuron_IDs_flag || from_neuron_IDs_flag || names_flag                                                     % If we want to compute the from neuron IDs, to neuron IDs, or synapse names...
                
                % Create the synapses that connect the driven multistate cpg neurons to the modulated split subtraction voltage based integration neurons.
                for k = 1:num_cpg_neurons                                                                                   % Iterate through each of the CPG neurons...
                    
                    % Compute the synapse index.
                    synapse_index = 2*( k - 1 ) + 1;
                    
                    % Compute the dmcpg indexes.
                    dmcpg_index1 = k;
                    dmcpg_index2 = dmcpg_index1 + num_cpg_neurons + 1;
                    
                    % Compute the mssvbi indexes.
                    mssvbi_index1 = 2*( num_cpg_neurons + 1 ) + 2*k - 1;
                    mssvbi_index2 = mssvbi_index1 + 1;
                    
                    % Determine whether to compute the neuron ID from which these synapses originate.
                    if to_neuron_IDs_flag                                                                                   % If we want to compute the neuron ID from which these synapses originate...
                        
                        % Determine the neuron ID from which these synapses originate.
                        from_neuron_IDs( synapse_index ) = neuron_IDs( dmcpg_index1 );
                        from_neuron_IDs( synapse_index + 1 ) = neuron_IDs( dmcpg_index2 );
                        
                    end
                    
                    % Determine whether to compute the nueron ID at which these synapses terminate.
                    if from_neuron_IDs_flag                                                                                 % If we want to compute the neuron ID at which these synapses terminate...
                        
                        % Determine the neuron ID at which these synapses terminate.
                        to_neuron_IDs( synapse_index ) = neuron_IDs( mssvbi_index1 );
                        to_neuron_IDs( synapse_index + 1 ) = neuron_IDs( mssvbi_index2 );
                        
                    end
                    
                    % Determine whether to compute the nes of these synapses.
                    if names_flag                                                                                           % If we want to compute the names of these synapses...
                        
                        % Define the synapse names.
                        names{ synapse_index } = sprintf( 'Syn %0.0f%0.0f ', from_neuron_IDs1( synapse_index ), to_neuron_IDs1( synapse_index ) );
                        names{ synapse_index + 1 } = sprintf( 'Syn %0.0f%0.0f ', from_neuron_IDs2( synapse_index + 1 ), to_neuron_IDs2( synapse_index + 1 ) );
                        
                    end
                    
                end
                
            end
            
            % Create the unique synapses.
            [ IDs_new, synapses_new, synapses, synapse_manager ] = self.create_synapses( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, true, false, array_utilities );
            
            % Determine how to format the synapse IDs and objects.
            [ IDs_new, synapses_new ] = self.process_synapse_creation_outputs( IDs_new, synapses_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ synapses, self ] = self.update_synapse_manager( synapses, synapse_manager, set_flag );
            
        end
        
        
        %{
%         % Implement a function to create the synapses that connect modulated split subtraction voltage based integration subnetworks to the split lead lag subnetwork.
%         function [ self, synapse_IDs ] = create_mssvbi2sll_synapses( self, num_cpg_neurons, neuron_IDs, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, set_flag, as_cell_flag, array_utilities )
%             
%             % Compute the number of synapses.
%             n_synapses = self.compute_num_mssvbi2sll_synapses( num_cpg_neurons );
%             
%             % Set the default input arguments.
%             if nargin < 15, array_utilities = self.array_utilities; end                                                       % [class] Array Utilities Class.
%             if nargin < 14, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                     % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
%             if nargin < 13, set_flag = self.set_flag_DEFAULT; end                                                             % [T/F] Set Flag (Determines whether output self object is updated.)
%             if nargin < 12, synapses = self.synapses; end                                                                     % [class] Array of Synapse Class Objects.
%             if nargin < 11, enabled_flags = true( 1, n_synapses ); end                                                           % [T/F] Synapse Enabled Flag.
%             if nargin < 10, deltas = self.delta_DEFAULT*ones( 1, n_synapses ); end                                            % [-] Subnetwork Output Offset.
%             if nargin < 9, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                              % [-] To Neuron ID.
%             if nargin < 8, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, n_synapses ); end                          % [-] From Neuron ID.
%             if nargin < 7, gs = self.gs_DEFAULT*ones( 1, n_synapses ); end                                                % [S] Synaptic Conductance.
%             if nargin < 6, dEs = self.dEs_DEFAULT*ones( 1, n_synapses ); end                                                  % [V] Synaptic Reversal Potential.
%             if nargin < 5, names = repmat( { '' }, 1, n_synapses ); end                                                       % [str] Synapse names.
%             if nargin < 4, synapse_IDs = self.generate_unique_synapse_IDs( n_synapses, synapses, array_utilities ); end       % [#] Synapse IDs.            
%             if nargin < 3, neuron_IDs = 1:num_cpg_neurons; end                                                                % [#] Number of CPG Neurons.
%             
%             % Process the synapse creation inputs.
%             [ ~, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags ] = self.process_synapse_creation_inputs( n_synapses, synapse_IDs, names, dEs, gs, from_neuron_IDs, to_neuron_IDs, deltas, enabled_flags, synapses, array_utilities );
%             
%             % Ensure that the neuron properties match the require number of neurons.
%             assert( num_cpg_neurons == length( neuron_IDs ), 'Provided neuron properties must be of consistent size.' )
%             
%             % Determine whether it is necessary to generate to and from neuron IDs.
%             [ to_neuron_IDs, to_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( to_neuron_IDs );
%             [ from_neuron_IDs, from_neuron_IDs_flag ] = self.process_to_from_neuron_IDs( from_neuron_IDs );
%             
%             % Determine whether it is necessary to generate synapse names.
%             [ names, names_flag ] = self.process_names( names );
%             
%             % Create the unique synapses.
%             [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
%             
%             % Create the addition synapses of the split lead lag subnetwork.
%             for k = 1:num_cpg_neurons                                                                                         % Iterate through each of the CPG neurons...
%                 
%                 % Compute the index.
%                 index = 2*( k - 1 ) + 1;
%                 
%                 % Define the from and to neuron IDs.
%                 from_neuron_ID1 = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 1 );
%                 from_neuron_ID2 = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 2 );
%                 
%                 % Define the synapse names.
%                 synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
%                 synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
%                 
%                 % Set the names of these synapses.
%                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( index ), { synapse_name1 }, 'name', synapses, set_flag );
%                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( index + 1 ), { synapse_name2 }, 'name', synapses, set_flag );
%                 
%                 % Connect this synapse.
%                 self = self.connect_synapse( synapse_IDs( index ), from_neuron_ID1, to_neuron_ID1 );
%                 self = self.connect_synapse( synapse_IDs( index + 1 ), from_neuron_ID2, to_neuron_ID2 );
%                 
%             end
%             
%             % Define the from and to neuron IDs for the slow tranmission synapses.
%             from_neuron_ID1 = neuron_IDs_cell{ end }( 1 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 3 );
%             from_neuron_ID2 = neuron_IDs_cell{ end }( 2 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 4 );
%             
%             % Define the synapse names for the slow transmission synapses
%             synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
%             synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
%             
%             % Set the names of the slow transmission synapses of the split lead lag subnetwork.
%             [ synapses, self ] = self.set_synapse_property( synapse_IDs( end - 1 ), { synapse_name1 }, 'name', synapses, set_flag );
%             [ synapses, self ] = self.set_synapse_property( synapse_IDs( end ), { synapse_name2 }, 'name', synapses, set_flag );
%             
%             % Connect the slow tranmission synapses of the split lead lag subnetwork.
%             self = self.connect_synapse( synapse_IDs( end - 1 ), from_neuron_ID1, to_neuron_ID1 );
%             self = self.connect_synapse( synapse_IDs( end ), from_neuron_ID2, to_neuron_ID2 );
% 
% %             % Create the unique synapses.
% %             [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
% %             
% %             % Create the addition synapses of the split lead lag subnetwork.
% %             for k = 1:num_cpg_neurons                                                                                       % Iterate through each of the CPG neurons...
% %                 
% %                 % Compute the index.
% %                 index = 2*( k - 1 ) + 1;
% %                 
% %                 % Define the from and to neuron IDs.
% %                 from_neuron_ID1 = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 1 );
% %                 from_neuron_ID2 = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 2 );
% %                 
% %                 % Define the synapse names.
% %                 synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
% %                 synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
% %                 
% %                 % Set the names of these synapses.
% %                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( index ), { synapse_name1 }, 'name', synapses, set_flag );
% %                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( index + 1 ), { synapse_name2 }, 'name', synapses, set_flag );
% %                 
% %                 % Connect this synapse.
% %                 self = self.connect_synapse( synapse_IDs( index ), from_neuron_ID1, to_neuron_ID1 );
% %                 self = self.connect_synapse( synapse_IDs( index + 1 ), from_neuron_ID2, to_neuron_ID2 );
% %                 
% %             end
% %             
% %             % Define the from and to neuron IDs for the slow tranmission synapses.
% %             from_neuron_ID1 = neuron_IDs_cell{ end }( 1 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 3 );
% %             from_neuron_ID2 = neuron_IDs_cell{ end }( 2 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 4 );
% %             
% %             % Define the synapse names for the slow transmission synapses
% %             synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
% %             synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
% %             
% %             % Set the names of the slow transmission synapses of the split lead lag subnetwork.
% %             [ synapses, self ] = self.set_synapse_property( synapse_IDs( end - 1 ), { synapse_name1 }, 'name', synapses, set_flag );
% %             [ synapses, self ] = self.set_synapse_property( synapse_IDs( end ), { synapse_name2 }, 'name', synapses, set_flag );
% %             
% %             % Connect the slow tranmission synapses of the split lead lag subnetwork.
% %             self = self.connect_synapse( synapse_IDs( end - 1 ), from_neuron_ID1, to_neuron_ID1 );
% %             self = self.connect_synapse( synapse_IDs( end ), from_neuron_ID2, to_neuron_ID2 );
%             
%         end
%         
%         
%         % Implement a function to create the synapses for a driven multistate cpg split lead lag subnetwork.
%         function [ self, synapse_IDs_cell ] = create_dmcpg_sll_synapses( self, neuron_IDs_cell )
%             
%             % Retrieve the number of subnetworks and cpg neurons.
%             num_subnetworks = length( neuron_IDs_cell );
%             num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
%             
%             % Preallocate a cell array to store the synapse IDs.
%             synapse_IDs_cell = cell( 1, num_subnetworks + 1 );
%             
%             % Create the driven multistate cpg synapses.
%             [ self, synapse_IDs_cell{ 1 } ] = self.create_dmcpg_synapses( neuron_IDs_cell{ 1 } );
%             [ self, synapse_IDs_cell{ 2 } ] = self.create_dmcpg_synapses( neuron_IDs_cell{ 2 } );
%             
%             % Create the synapses for each of the modulated split subtraction voltage based integration synapses.
%             for k = 1:num_cpg_neurons                                                                                         % Iterate through each of the cpg neurons...
%                 
%                 % Create the modulated split subtraction voltage based integration synapses for this subnetwork.
%                 [ self, synapse_IDs_cell{ k + 2 } ] = self.create_mssvbi_synapses( neuron_IDs_cell{ k + 2 } );
%                 
%             end
%             
%             % Create the synapses that connect the driven multistate cpg to the modulated split subtraction voltage based integration subnetworks.
%             [ self, synapse_IDs_cell{ end - 1 } ] = self.create_dmcpg2mssvbi_synapses( neuron_IDs_cell );
%             
%             % Create the synapses that connect the modulated split subtraction voltage based integration subnetworks to the split lead lag subnetwork.
%             [ self, synapse_IDs_cell{ end } ] = self.create_mssvbi2sll_synapses( neuron_IDs_cell );
%             
%         end
%         
%         
%         % Implement a function to create the synapses that connect a driven multistate cpg double centered lead lag subnetwork to a double centered subnetwork.
%         function [ self, synapse_IDs ] = create_dmcpgsll2dc_synapses( self, neuron_IDs_cell )
%             
%             % Define the number of unique synapses.
%             num_unique_synapses = 2;
%             
%             % Create the unique synapses.
%             [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ end }( end - 1 ) neuron_IDs_cell{ 1 }{ end }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
%             
%             % Setup each of the synapses.
%             for k = 1:num_unique_synapses                                                                                     % Iterate through each of the unique synapses...
%                 
%                 % Set the names of each of the unique synapses.
%                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
%                 
%                 % Connect the unique synapses.
%                 self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to create the synapses for a driven multistate cpg double centered lead lag subnetwork.
%         function [ self, synapse_IDs_cell ] = create_dmcpg_dcll_synapses( self, neuron_IDs_cell )
%             
%             % Create the double subtraction subnetwork synapses.
%             [ self, synapse_IDs_dmcpgsll ] = self.create_dmcpg_sll_synapses( neuron_IDs_cell{ 1 } );
%             
%             % Create the double centering subnetwork synapses.
%             [ self, synapse_IDs_dc ] = self.create_double_centering_synapses( neuron_IDs_cell{ 2 } );
%             
%             % Create the driven multistate cpg double centered lead lag to double centering subnetwork synapses.
%             [ self, synapse_IDs_dmcpgsll2dc ] = self.create_dmcpgsll2dc_synapses( neuron_IDs_cell );
%             
%             % Concatenate the synapse IDs.
%             synapse_IDs_cell = { synapse_IDs_dmcpgsll, synapse_IDs_dc, synapse_IDs_dmcpgsll2dc };
%             
%         end
%         
%         
%         % Implement a function to create the synapses that connect the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
%         function [ self, synapse_IDs ] = create_dmcpgdcll2cds_synapses( self, neuron_IDs_cell )
%             
%             % Define the number of unique synapses.
%             num_unique_synapses = 2;
%             
%             % Create the unique synapses.
%             [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 2 }( end - 1 ) neuron_IDs_cell{ 3 } ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 1 }( 1 ) neuron_IDs_cell{ 2 }{ 1 }( 2 ) ];
%             
%             % Setup each of the synapses.
%             for k = 1:num_unique_synapses                                                                                     % Iterate through each of the unique synapses...
%                 
%                 % Set the names of each of the unique synapses.
%                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
%                 
%                 % Connect the unique synapses.
%                 self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to create the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
%         function [ self, synapse_IDs_cell ] = create_ol_dmcpg_dclle_synapses( self, neuron_IDs_cell )
%             
%             % Create the driven multistate cpg double centered lead lag subnetwork synapses.
%             [ self, synapse_IDs_dmcpgdcll ] = self.create_dmcpg_dcll_synapses( neuron_IDs_cell{ 1 } );
%             
%             % Create the centered double subtraction subnetwork synapses.
%             [ self, synapse_IDs_cds ] = self.create_cds_synapses( neuron_IDs_cell{ 2 } );
%             
%             % Create the synapses that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
%             [ self, synapse_IDs_dmcpgdcll2cds ] = self.create_dmcpgdcll2cds_synapses( neuron_IDs_cell );
%             
%             % Concatenate the synapse IDs.
%             synapse_IDs_cell = { synapse_IDs_dmcpgdcll, synapse_IDs_cds, synapse_IDs_dmcpgdcll2cds };
%             
%         end
%         
%         
%         % Implement a function to create the synapses that close the open loop driven multistate cpg double centered lead lag error subnetwork using a proportional controller.
%         function [ self, synapse_IDs ] = create_oldmcpgdclle2dmcpg_synapses( self, neuron_IDs_cell )
%             
%             % Define the number of unique synapses.
%             num_unique_synapses = 2;
%             
%             % Create the unique synapses.
%             [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
%             
%             % Define the from and to neuron IDs.
%             from_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 2 }( end - 1 ) neuron_IDs_cell{ 2 }{ 2 }( end ) ];
%             to_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 1 }{ 2 }( end ) neuron_IDs_cell{ 1 }{ 1 }{ 1 }( end ) ];
%             
%             % Setup each of the synapses.
%             for k = 1:num_unique_synapses                                                                                     % Iterate through each of the unique synapses...
%                 
%                 % Set the names of each of the unique synapses.
%                 [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
%                 
%                 % Connect the unique synapses.
%                 self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
%                 
%             end
%             
%         end
%         
%         
%         % Implement a function to create the synapses for an closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
%         function [ self, synapse_IDs_cell ] = create_clpc_dmcpg_dcll_synapses( self, neuron_IDs_cell )
            
            % Create the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            [ self, synapse_IDs_oldmcpgdclle ] = self.create_ol_dmcpg_dclle_synapses( neuron_IDs_cell );
            
            % Create the synapses that assist in closing the open loop driven multistate cpg double centered lead lag error subnetwork using a proportional controller.
            [ self, synapse_IDs_oldmcpgdclle2dmcpg ] = self.create_oldmcpgdclle2dmcpg_synapses( neuron_IDs_cell );
            
            % Concatenate the synapse IDs.
            synapse_IDs_cell = { synapse_IDs_oldmcpgdclle, synapse_IDs_oldmcpgdclle2dmcpg };
            
        end
        %}
        
                
        %% Subnetwork Synapse Design Functions.

        % ---------- Transmission Subnetwork Functions ----------
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function [ synapse_output_params, synapse_ID, synapses, self ] = design_transmission_synapse( self, neuron_IDs, synapse_input_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Absolute:
                % synapse_input_params = { c, x1_max, Gm2 }
                % synapse_output_params = { gs21, dEs21 }
            
            % Relative:
                % synapse_input_params = { R2, Gm2 }
                % synapse_output_params = { gs21, dEs21 }
                
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, synapse_input_params = struct( [  ] ); end                                	% [variable] Synapse Input Parameters.
            if nargin < 2, neuron_IDs = 1:self.n_transmission_neurons_DEFAULT; end              % [#] Neuron IDs.
            
            % Retrieve the synapse ID associated with the transmission neurons.
            synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
            % Process the design params.
            synapse_input_params = self.process_transmission_params( synapse_input_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs21, synapses, synapse_manager ] = self.compute_transmission_dEs21( synapse_ID, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs21 params.
            gs_params = self.convert_transmission_params2gs_params( synapse_ID, synapse_input_params, dEs21, encoding_scheme, synapses, undetected_option );

            % Compute the synaptic conductance.
            [ gs21, synapses, synapse_manager ] = synapse_manager.compute_transmission_gs21( synapse_ID, gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synapse output params in a structure.
            synapse_output_params.dEs21 = dEs21;
            synapse_output_params.gs21 = gs21;
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Addition Subnetwork Functions ----------
        
        % Implement a function to design the synapses for an addition subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_addition_synapses( self, neuron_IDs, addition_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, addition_params = struct( [  ] ); end
            if nargin < 2, neuron_IDs = 1:self.n_addition_neurons_DEFAULT; end                % [#] Neuron IDs.
            
            % Compute the number of synapses.
            num_neurons = length( neuron_IDs );
            num_synapses_to_evaluate = num_neurons - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_evaluate );
            
            % Retrieve the synapse IDs that connect to the output neuron.
            for k = 1:num_synapses_to_evaluate              % Iterate through each of the synapses...                    
                
                % Retrieve the ID of this synapse that connects to the output neuron.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
            end
            
            % Process the design params.            
            addition_params = self.process_addition_params( synapse_IDs, addition_params, encoding_scheme );
            
            % Compute the synaptic reversal potentials.
            [ dEs, synapses, synapse_manager ] = self.compute_addition_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
                        
            % Convert the generic params into gs params.
            addition_gs_params = self.convert_addition_params2gs_params( synapse_IDs, addition_params, dEs, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_addition_gs( synapse_IDs, addition_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );

            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Subtraction Subnetwork Functions ----------

        % Implement a function to design the synapses for a subtraction subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_subtraction_synapses( self, neuron_IDs, subtraction_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                              	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, subtraction_params = struct( [  ] ); end
            if nargin < 2, neuron_IDs = 1:self.n_subtraction_neurons_DEFAULT; end             % [#] Neuron IDs.   
            
            % Compute the number of synapses.
            num_neurons = length( neuron_IDs );
            num_synapses_to_evaluate = num_neurons - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_evaluate );
            
            % Retrieve the synapse IDs that connect to the output neuron.
            for k = 1:num_synapses_to_evaluate              % Iterate through each of the synapses...                    
                
                % Retrieve the ID of this synapse that connects to the output neuron.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
            end
               
            % Process the design params.            
            subtraction_params = self.process_subtraction_params( synapse_IDs, subtraction_params, encoding_scheme );
            
            % Compute the synaptic reversal potentials.            
            [ dEs, synapses, synapse_manager ] = self.compute_subtraction_dEs( synapse_IDs, s_ks, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            subtraction_gs_params = self.convert_subtraction_params2gs_params( synapse_IDs, subtraction_params, dEs, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductance.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_subtraction_gs( synapse_IDs, subtraction_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end

        
        % ---------- Inversion Subnetwork Functions ----------
        
        % Implement a function to design the synapses for an inversion subnetwork.
        function [ synapse_output_params, synapse_ID, synapses, self ] = design_inversion_synapse( self, neuron_IDs, inversion_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, inversion_params = struct( [  ] ); end                                     % [struct] Parameters Structure.
            if nargin < 2, neuron_IDs = 1:self.n_inversion_neurons_DEFAULT; end                 % [#] Neuron IDs.
            
            % Get the synapse ID that connects the first neuron to the second neuron.
            synapse_ID = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1 ), neuron_IDs( 2 ), synapses, undetected_option );
            
            % Process the design params.            
            inversion_params = self.process_inversion_params( inversion_params, encoding_scheme );
            
            % Compute and set the synapse reversal potential.            
            [ dEs21, synapses, synapse_manager ] = self.compute_inversion_dEs21( synapse_ID, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            inversion_gs_params = self.convert_inversion_params2gs_params( synapse_ID, inversion_params, dEs21, encoding_scheme, synapses, undetected_option );
                        
            % Compute the synaptic conductance.
            [ gs21, synapses, synapse_manager ] = synapse_manager.compute_inversion_gs21( synapse_ID, inversion_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synapse output params in a structure.
            synapse_output_params.dEs21 = dEs21;
            synapse_output_params.gs21 = gs21;
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Inversion Subnetwork Functions ----------

        % Implement a function to design the synapses for a reduced inversion subnetwork.
        function [ synapse_output_params, synapse_ID, synapses, self ] = design_reduced_inversion_synapse( self, neuron_IDs, reduced_inversion_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, reduced_inversion_params = struct( [  ] ); end                            	% [struct] Parameters Structure.
            if nargin < 2, neuron_IDs = 1:self.n_inversion_neurons_DEFAULT; end                 % [#] Neuron IDs.
            
            % Get the synapse ID that connects the first neuron to the second neuron.
            synapse_ID = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1 ), neuron_IDs( 2 ), synapses, undetected_option );
            
            % Process the design params.
            reduced_inversion_params = self.process_reduced_inversion_params( reduced_inversion_params, encoding_scheme );
            
            % Compute and set the synapse reversal potential.            
            [ dEs21, synapses, synapse_manager ] = self.compute_reduced_inversion_dEs21( synapse_ID, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            reduced_inversion_gs_params = self.convert_reduced_inversion_params2gs_params( synapse_ID, reduced_inversion_params, encoding_scheme );
                        
            % Compute the synaptic conductance.
            [ gs21, synapses, synapse_manager ] = synapse_manager.compute_reduced_inversion_gs21( synapse_ID, reduced_inversion_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Store the synapse output params in a structure.
            synapse_output_params.dEs21 = dEs21;
            synapse_output_params.gs21 = gs21;
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Division Subnetwork Functions ----------
        
        % Implement a function to design the synapses for a division subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_division_synapses( self, neuron_IDs, division_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, division_params = struct( [  ] ); end                                    	% [struct] Parameters Structure. { delta2, R3, Gm3, Ia3 }
            if nargin < 2, neuron_IDs = 1:self.num_division_neurons_DEFAULT; end                % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Process the design params.
            division_params = self.process_division_params( division_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_division_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );

            % Convert the generic params into gs params.
            division_gs_params = self.convert_division_params2gs_params( synapse_IDs, division_params, dEs31, dEs32, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductances.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_division_gs( synapse_IDs, division_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Division After Inversion Subnetwork Functions ----------

        % Implement a function to design the synapses for a division after inversion subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_dai_synapses( self, neuron_IDs, dai_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, dai_params = struct( [  ] ); end                                          	% [struct] Parameters Structure. { delta2, R3, Gm3, Ia3 }
            if nargin < 2, neuron_IDs = 1:self.num_division_neurons_DEFAULT; end                % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Process the design params.
            dai_params = self.process_dai_params( dai_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_dai_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            dai_gs_params = self.convert_dai_params2gs_params( synapse_IDs, dai_params, dEs31, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductances.            
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_dai_gs( synapse_IDs, dai_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Division Subnetwork Functions ----------

        % Implement a function to design the synapses for a reduced division subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_reduced_division_synapses( self, neuron_IDs, reduced_division_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, reduced_division_params = struct( [  ] ); end                             	% [struct] Parameters Structure. { delta2, R3, Gm3, Ia3 }
            if nargin < 2, neuron_IDs = 1:self.num_division_neurons_DEFAULT; end                % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Process the design params.
            reduced_division_params = self.process_reduced_division_params( reduced_division_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_reduced_division_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            reduced_division_gs_params = self.convert_reduced_division_params2gs_params( synapse_IDs, reduced_division_params, dEs31, dEs32, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductances.            
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_reduced_division_gs( synapse_IDs, reduced_division_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Division After Invesion Subnetwork Functions ----------

        % Implement a function to design the synapses for a reduced division after inversion subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_reduced_dai_synapses( self, neuron_IDs, reduced_dai_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                             	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, reduced_dai_params = struct( [  ] ); end                                 	% [struct] Parameters Structure. { delta2, R3, Gm3, Ia3 }
            if nargin < 2, neuron_IDs = 1:self.num_division_neurons_DEFAULT; end                % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Process the design params.
            reduced_dai_params = self.process_reduced_dai_params( reduced_dai_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.            
            [ dEs, synapses, synapse_manager ] = self.compute_reduced_dai_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            reduced_dai_gs_params = self.convert_reduced_dai_params2gs_params( synapse_IDs, reduced_dai_params, dEs31, encoding_scheme, synapses, undetected_option );
            
            % Compute the maximum synaptic conductances.                        
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_reduced_dai_gs( synapse_IDs, reduced_dai_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Multiplication Subnetwork Functions ----------

        % Implement a function to design the synapses for a multiplication subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_multiplication_synapses( self, neuron_IDs, multiplication_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, multiplication_params = struct( [  ] ); end                               	% [struct] Parameters Structure.
            if nargin < 2, neuron_IDs = 1:self.num_multiplication_neurons_DEFAULT; end          % [#] Neuron IDs.
            
            % Get the synapse IDs that comprise this multiplication subnetwork.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1:3 ), [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 4 ) ], synapses, undetected_option );
            
            % Process the params.
            multiplication_params = self.process_multiplication_params( multiplication_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_multiplication_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
            
            % Convert the generic params into gs params.
            multiplication_gs_params = self.convert_multiplication_params2gs_params( synapse_IDs, multiplication_params, dEs41, dEs32, encoding_scheme, synapses, undetected_option );
        
            % Compute the maximum synaptic conductance.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_multiplication_gs( synapse_IDs, multiplication_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Reduced Multiplication Subnetwork Functions ----------

        % Implement a function to design the synapses for a reduced multiplication subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_reduced_multiplication_synapses( self, neuron_IDs, reduced_multiplication_params, encoding_scheme, synapses, set_flag, validation_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, validation_flag = self.validation_flag_DEFAULT; end                  % [T/F] Validation Flag.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, reduced_multiplication_params = struct( [  ] ); end                       	% [struct] Parameters Structure.
            if nargin < 2, neuron_IDs = 1:self.num_multiplication_neurons_DEFAULT; end          % [#] Neuron IDs.
            
            % Get the synapse IDs that comprise this multiplication subnetwork.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1:3 ), [ neuron_IDs( 4 ), neuron_IDs( 3 ), neuron_IDs( 4 ) ], synapses, undetected_option );
            
            % Process the params.
            reduced_multiplication_params = self.process_reduced_multiplication_params( reduced_multiplication_params, encoding_scheme );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_reduced_multiplication_dEs( synapse_IDs, encoding_scheme, synapses, true, undetected_option );
                        
            % Convert the generic params into gs params.
            reduced_multiplication_gs_params = self.convert_reduced_multiplication_params2gs_params( synapse_IDs, reduced_multiplication_params, dEs41, dEs32, encoding_scheme, synapses, undetected_option );
        
            % Compute the maximum synaptic conductance.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_reduced_multiplication_gs( synapse_IDs, reduced_multiplication_gs_params, encoding_scheme, synapses, true, validation_flag, undetected_option );
                        
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Derivation Subnetwork Functions ----------
        
        % Implement a function to design the synapses for a derivation subnetwork.
        function [ dEs, synapse_IDs, synapses, self ] = design_derivation_synapses( self, neuron_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, neuron_IDs = 1:self.num_derivation_neurons_DEFAULT; end              % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Compute the synaptic reversal potential.
            [ dEs1, synapses, synapse_manager ] = self.compute_derivation_dEs31( synapse_IDs( 1 ), synapses, true, undetected_option );
            [ dEs2, synapses, synapse_manager ] = synapse_manager.compute_derivation_dEs32( synapse_IDs( 2 ), synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials in an array.
            dEs = [ dEs1, dEs2 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Integration Subnetwork Functions ----------
        
        % Implement a function to design the synapses for an integration subnetwork.
        function [ dEs, synapse_IDs, synapses, self ] = design_integration_synapses( self, neuron_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, neuron_IDs = 1:self.num_derivation_neurons_DEFAULT; end              % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID12 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            synapse_ID21 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 1 ) );
            synapse_IDs = [ synapse_ID12, synapse_ID21 ];
            
            % Compute the synaptic reversal potential.
            [ dEs1, synapses, synapse_manager ] = self.compute_integration_dEs1( synapse_IDs( 1 ), synapses, set_flag, undetected_option );
            [ dEs2, synapses, synapse_manager ] = synapse_manager.compute_integration_dEs2( synapse_IDs( 2 ), synapses, set_flag, undetected_option );
            
            % Store the synaptic reversal potentials in an array.
            dEs = [ dEs1, dEs2 ];
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % Implement a function to design the synapses for a voltage based integration subnetwork.
        function [ dEs, synapse_IDs, synapses, self ] = design_vbi_synapses( self, neuron_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 2, neuron_IDs = 1:self.num_derivation_neurons_DEFAULT; end              % [#] Neuron IDs.
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13, synapse_ID23 ];
            
            % Compute the synaptic reversal potential.
            [ dEs1, synapses, synapse_manager ] = self.compute_vbi_dEs1( synapse_IDs( 1 ), synapses, true, undetected_option );
            [ dEs2, synapses, synapse_manager ] = synapse_manager.compute_vbi_dEs2( synapse_IDs( 2 ), synapses, true, undetected_option );
            
            % Store the synaptic reversal potentials in an array.
            dEs = [ dEs1, dEs2 ];
            
            % Detemrine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        % ---------- Central Pattern Generator Subnetwork Functions ----------
        
        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function [ synapses, self ] = design_mcpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable, synapses, set_flag, undetected_option, array_utilities )
            
            % Set the default input arguments.
            if nargin < 8, array_utilities = self.array_utilities; end                        	% [class] Array Utilities Class.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                               	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end                    % [V] Bistable CPG Bifurcation Parameter.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end              % [V] Oscillatory CPG Bifurcation Parameter.
            
            % Compute the synapse delta values.
            [ synapses, self ] = self.compute_cpg_deltas( neuron_IDs, delta_oscillatory, delta_bistable, synapses, set_flag, undetected_option, array_utilities );
            
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg subnetwork.
        function [ dEs, gs, synapse_IDs, synapses, self ] = design_dmcpg_synapses( self, neuron_IDs, delta_oscillatory, Id_max, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end              % [str] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, synapses = self.synapses; end                                        % [class] Array of Synapse Class Objects.
            if nargin < 4, Id_max = self.Id_max_DEFAULT; end                                    % [A] Max Drive Current.
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end              % [V] Oscillatory CPG Bifurcation Parameter.
            
            % Retrieve the number of cpg neurons.
            num_cpg_neurons = length( neuron_IDs ) - 1;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = neuron_IDs( end )*ones( 1, num_cpg_neurons );
            to_neuron_IDs = neuron_IDs( 1:( end - 1 ) );
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs, synapses, undetected_option );
            
            % Compute the synaptic reversal potential.
            [ dEs, synapses, synapse_manager ] = self.compute_dmcpg_dEs( synapse_IDs, synapses, true, undetected_option );
            
            % Compute the maximum synaptic conductances.
            [ gs, synapses, synapse_manager ] = synapse_manager.compute_dmcpg_gs( synapse_IDs, delta_oscillatory, Id_max, synapses, true, undetected_option );
            
            % Determine whether to update the synapse manager.
            if set_flag, self = synapse_manager; end
            
        end
        
        
        %% Print Functions
        
        % Implement a function to print the properties of the synapses contained in the synapse manager.
        function print( self, synapses, verbose_flag )
        
            % Set the default input arguments.
            if nargin < 3, verbose_flag = false; end
            if nargin < 2, synapses = self.synapses; end
            
            % Retrieve the number of synapses.
            n_synapses = length( synapses );
            
            % Print out the properties associated with each synapses.
            for k = 1:n_synapses             % Iterate through each of the synapses...
            
                % Print out the properties for this synapses.
                synapses( k ).print( verbose_flag );
            
            end
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save synapse manager data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end           % [str] File Name.
            if nargin < 2, directory = '.'; end                             % [str] Save Directory.
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load synapse manager data as a matlab object.
        function [ data, self ] = load( self, directory, file_name, set_flag )
            
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end           % [str] File Name.
            if nargin < 2, directory = '.'; end                             % [str] Load Directory.
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Determine whether to update the synapse manager object.
            if set_flag, self = data; end
            
        end
        
        
        % Implement a function to load synapse from a xlsx data.
        function [ synapses, self ] = load_xlsx( self, file_name, directory, append_flag, verbose_flag, synapses, set_flag, data_loader_utilities )
            
            % Set the default input arguments.
            if nargin < 8, data_loader_utilities = self.data_loader_utilities; end          % [class] Data Load Utilities Class.
            if nargin < 7, set_flag  = self.set_flag; end                                   % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 6, synapses = self.synapses; end                                    % [class] Array of Synapse Class Objects.
            if nargin < 5, verbose_flag = true; end                                         % [T/F] Verbose Flag.
            if nargin < 4, append_flag = false; end                                         % [T/F] Append Flag.
            if nargin < 3, directory = '.'; end                                             % [str] Load Directory.
            if nargin < 2, file_name = 'Synapse_Data.xlsx'; end                             % [str] File Name.
            
            % Determine whether to print status messages.
            if verbose_flag, fprintf( 'LOADING SYNAPSE DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic
            
            % Load the synapse data.
            [ synapse_IDs, synapse_names, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = data_loader_utilities.load_synapse_data( file_name, directory );
            
            % Define the number of synapses.
            num_synapses_to_load = length( synapse_IDs );
            
            % Preallocate an array of synapses.
            synapses_to_load = repmat( synapse_class(  ), 1, num_synapses_to_load );
            
            % Create each synapse object.
            for k = 1:num_synapses_to_load                            	% Iterate through each of the synapses...
                
                % Create this synapse.
                synapses_to_load( k ) = synapse_class( synapse_IDs( k ), synapse_names{ k }, synapse_dEsyns( k ), synapse_gsyn_maxs( k ), synapse_from_neuron_IDs( k ), synapse_to_neuron_IDs( k ) );
                
            end
            
            % Determine whether to append the synapses we just loaded.
            if append_flag                                            	% If we want to append the synapses we just loaded...
                
                % Append the synapses we just loaded to the array of existing synapses.
                synapses = [ synapses, synapses_to_load ];
                
                % Update the number of synapses.
                n_synapses = length( synapses );
                
            else                                                        % Otherwise...
                
                % Replace the existing synapses with the synapses we just loaded.
                synapses = synapses_to_load;
                
                % Update the number of synapses.
                n_synapses = length( synapses );
                
            end
            
            % Determine whether to update the synapse manager properties.
            if set_flag                                             	% If we want to update the synapse manager properties...
                
                % Update the synapses property.
                self.synapses = synapses;
                
                % Update the number of synapses.
                self.num_synapses = n_synapses;
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if verbose_flag, fprintf( 'LOADING SYNAPSE DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        
    end
end

