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
        
        % Define the neuron parameters.
        R_DEFAULT = 20e-3;                                 	% [V] Activation Domain.
        Gm_DEFAULT = 1e-6;                              	% [S] Membrane Conductance.
        
        % Define the maximum synaptic conductance.
        gs_max_DEFAULT = 1e-6;                            	% [S] Maximum Synaptic Conductance.
        
        % Define the synaptic reversal potential parameters.
        dEs_maximum_DEFAULT = 194e-3;                      	% [V] Maximum Synaptic Reversal Potential.
        dEs_minimum_DEFAULT = -40e-3;                      	% [V] Minimum Synaptic Reversal Potential.
        dEs_small_negative_DEFAULT = -1e-3;             	% [V] Small Negative Synaptic Reversal Potential.
        
        % Define the synapse identification parameters.
        to_neuron_ID_DEFAULT = 0;                          	% [#] To Neuron ID.
        from_neuron_ID_DEFAULT = 0;                       	% [#] From Neuron ID.
        ID_DEFAULT = 0;                                  	% [#] Synapse ID.
        
        % Define the subnetwork gain parameters.
        c_absolute_addition_DEFAULT = 1;                   	% [-] Absolute Addition Subnetwork Gain.
        c_relative_addition_DEFAULT = 1;                   	% [-] Relative Addition Subnetwork Gain.
        c_absolute_subtraction_DEFAULT = 1;             	% [-] Absolute Subtraction Subnetwork Gain.
        c_relative_subtraction_DEFAULT = 1;              	% [-] Relative Subtraction Subnetwork Gain.
        c_absolute_inversion_DEFAULT = 1;                	% [-] Absolute Inversion Subnetwork Gain.
        c_relative_inversion_DEFAULT = 1;                 	% [-] Relative Inversion Subnetwork Gain.
        c_absolute_division_DEFAULT = 1;                  	% [-] Absolute Division Subnetwork Gain.
        c_relative_division_DEFAULT = 1;                  	% [-] Relative Division Subnetwork Gain.
        c_absolute_multiplication_DEFAULT = 1;            	% [-] Absolute Multiplication Subnetwork Gain.
        c_relative_multiplication_DEFAULT = 1;              % [-] Relative Multiplication Subnetwork Gain.
        
        % Define the subnetwork offset parameters.
        epsilon_DEFAULT = 1e-6;                          	% [-] Subnetwork Input Offset.
        delta_DEFAULT = 1e-6;                           	% [-] Subnetwork Output Offset.
        alpha_DEFAULT = 1e-6;                             	% [-] Division Subnetwork Denominator Offset.
        
        % Define the number of subnetwork neurons.
        num_addition_neurons_DEFAULT = 2;                 	% [#] Number of Addition Neurons.
        num_absolute_addition_neurons_DEFAULT = 3;        	% [#] Number of Absolute Addition Neurons.
        num_relative_addition_neurons_DEFAULT = 3;        	% [#] Number of Relative Addition Neurons.
        
        % Define the number of subnetwork synapses.
        num_transmission_synapses_DEFAULT = 1;            	% [#] Number of Transmission Synapses.
        num_modulation_synapses_DEFAULT = 1;               	% [#] Number of Modulation Synapses.
        num_addition_synapses_DEFAULT = 2;               	% [#] Number of Addition Synapses.
        num_subtraction_synapses_DEFAULT = 2;            	% [#] Number of Subtraction Synapses.
        num_double_subtraction_synapses_DEFAULT = 4;       	% [#] Number of Double Subtraction Synapses.
        num_centering_synapses_DEFAULT = 4;               	% [#] Number of Centering Synapses.
        num_double_centering_synapses_DEFAULT = 8;        	% [#] Number of Double Centering Synapses.
        num_multiplication_synapses_DEFAULT = 3;          	% [#] Number of Multiplication Synapses.
        num_inversion_synapses_DEFAULT = 1;                	% [#] Number of Inversion Synapses.
        num_division_synapses_DEFAULT = 2;               	% [#] Number of Division Synapses.
        num_derivation_synapses_DEFAULT = 2;              	% [#] Number of Derivation Synapses.
        num_integration_synapses_DEFAULT = 2;             	% [#] Number of Integration Synapses.
        num_vbi_synapses_DEFAULT = 4;                    	% [#] Number of Voltage Based Integration Synapses.
        num_svbi_synapses =  10;                          	% [#] Number of Split Voltage Based Integration Synapses.
        num_msvbi_synapses = 6;                          	% [#] Number of Modulated Split Voltage Based Integration Synapses.
        num_mssvbi_synapses = 2;                           	% [#] Number fo Modulated Split Difference Voltage Based Integration Synapses.
        
        % Define the CPG parameters.
        delta_bistable_DEFAULT = -10e-3;                  	% [V] Bistable CPG Equilibrium Offset.
        delta_oscillatory_DEFAULT = 0.01e-3;              	% [V] Oscillatory CPG Equilibrium Offset.
        delta_noncpg_DEFAULT = 0;                         	% [V] Generic CPG Equilibrium Offset.
        
        % Define the applied current parameters.
        Id_max_DEFAULT = 1.25e-9;                         	% [A] Maximum Drive Current.
        Ia_absolute_addition_DEFAULT = 0;                	% [A] Absolute Addition Applied Current.
        Ia_relative_addition_DEFAULT = 0;                 	% [A] Relative Addition Applied Current.
        Ia_absolute_subtraction_DEFAULT = 0;             	% [A] Absolute Subtraction Applied Current.
        Ia_relative_subtraction_DEFAULT = 0;             	% [A] Relative Subtraction Applied Current.
        Ia1_absolute_inversion_DEFAULT = 0;              	% [A] Absolute Inversion Applied Current 1.
        Ia2_absolute_inversion_DEFAULT = 2e-8;          	% [A] Absolute Inversion Applied Current 2.
        Ia1_relative_inversion_DEFAULT = 0;                	% [A] Relative Inversion Applied Current 1.
        Ia2_relative_inversion_DEFAULT = 2e-8;             	% [A] Relative Inversion Applied Current 2.
        Ia_absolute_division_DEFAULT = 0;                  	% [A] Absolute Division Applied Current.
        Ia_relative_division_DEFAULT = 0;                 	% [A] Relative Division Applied Current.
        
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
        
        
        %% General Get & Set Synapse Property Functions.
        
        % Implement a function to retrieve the properties of specific synapses.
        function xs = get_synapse_property( self, synapse_IDs, synapse_property, as_matrix, synapses, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, as_matrix = false; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_properties_to_get = length( synapse_IDs );
            
            % Preallocate a variable to store the synapse properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given synapse property for each synapse.
            for k = 1:num_properties_to_get                         % Iterate through each of the properties to get...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{ k } = synapses( %0.0f ).%s;', synapse_index, synapse_property );
                
                % Evaluate the given synapse property.
                eval( eval_str );
                
            end
            
            % Determine whether to convert the network properties to a matrix.
            if as_matrix                                    % If we want the neuron properties as a matrix instead of a cell...
               
                % Convert the synapse properties from a cell to a matrix.
                xs = cell2mat( xs );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific synapses.
        function [ synapses, self ] = set_synapse_property( self, synapse_IDs, synapse_property_values, synapse_property, synapses, set_flag )
            
            % Set the default input arguments.
            if nargin < 6, set_flag = true; end
            if nargin < 5, synapses = self.synapses; end
            
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
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            values = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each synapse.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
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
            if nargin < 4, undetected_option = 'error'; end
            if nargin < 3, synapses = self.synapses; end
            
            % Compute the number of synapses.
            n_synapses = length( synapses );                                            % [#] Number of Synapses.
            
            % Set a flag variable to indicate whether a matching synapse index has been found.
            b_match_found = false;
            
            % Initialize the synapse index.
            synapse_index = 0;
            
            % Search for a synapse whose ID matches the target value.
            while ( synapse_index < n_synapses ) && ( ~b_match_found )                  % While we have not yet checked all of the synapses and have not yet found an ID match...
                
                % Advance the synapse index.
                synapse_index = synapse_index + 1;
                
                % Check whether this synapse index is a match.
                if self.synapses( synapse_index ).ID == synapse_ID                       % If this synapse has the correct synapse ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the synapse index.
            if ~b_match_found                                                           % If a match was not found...
                
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                                % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No synapse with ID %0.0f.', synapse_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                          % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No synapse with ID %0.0f.', synapse_ID )
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                           % If the undetected option is set to 'ignore'...
                    
                    % Set the synapse index to negative one.
                    synapse_index = -1;
                    
                else                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the index associated with a given array of synapse IDs.
        function synapse_indexes = get_synapse_indexes( self, synapse_IDs, synapses, undetected_option )
            
            % Set the default synapse IDs.
            if nargin < 4, undetected_option = 'error'; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapse IDs.
            num_synapse_IDs = length( synapse_IDs );
            
            % Preallocate an array of synapse indexes.
            synapse_indexes = zeros( 1, num_synapse_IDs );
            
            % Retrieve the synapse index of each synapse ID.
            for k = 1:num_synapse_IDs                           % Iterate through each synapse ID...
                
                % Determine how to compute the synapse index.
                if synapse_IDs( k ) >= 0                           % If the synapse ID is positive... (this means that the synapse ID exists...)
                    
                    % Retrieve the synapse index associated with this synapse ID.
                    synapse_indexes( k ) = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                    
                elseif synapse_IDs( k ) == -1                     % If the synapse ID is -1... (this means that the synapse ID does not exist...)
                    
                    % Set the synapse index to negative one (to indicate that it doesn't exist).
                    synapse_indexes( k ) = -1;
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse ID %0.2f not recognized.', synapse_IDs( k ) )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get all of the synapse IDs.
        function synapse_IDs = get_all_synapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1,  n_synapses );
            
            % Retrieve each synapse ID.
            for k = 1:n_synapses                  % Iterate through each synapse...
                
                % Retrieve the ID of this synapse.
                synapse_IDs( k ) = synapses( k ).ID;
                
            end
            
        end
        
        
        % Implement a function to retrieve all self connecting synapses.
        function synapse_IDs = get_self_connecting_sypnapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Initialize a loop counter.
            index = 0;
            
            % Preallocate an array to store the synapses IDs.
            synapse_IDs = zeros( 1, n_synapses );
            
            % Retrieve all self-connecting synapse IDs.
            for k = 1:n_synapses                         % Iterate through each synapse...
                
                % Determine whether this synapse is a self-connection.
                if ( synapses( k ).from_neuron_ID == synapses( k ).to_neuron_ID )             % If this synapse is a self-connection...
                    
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
            if nargin < 3, synapses = self.synapses; end
            
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
            if nargin < 3, array_utilities = self.array_utilities; end
            if nargin < 2, synapses = self.synapses; end
            
            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Generate a unique synapse ID.
            synapse_ID = array_utilities.get_lowest_natural_number( existing_synapse_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique synapse IDs.
        function synapse_IDs = generate_unique_synapse_IDs( self, num_IDs, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end
            if nargin < 3, synapses = self.synapses; end
            
            % Retrieve the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Preallocate an array to store the newly generated synapse IDs.
            synapse_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                           % Iterate through each of the new IDs...
                
                % Generate a unique synapse ID.
                synapse_IDs( k ) = array_utilities.get_lowest_natural_number( [ existing_synapse_IDs, synapse_IDs( 1:( k - 1 ) ) ] );
                
            end
            
        end
        
        
        % Implement a function to check if a proposed synapse ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_synapse_ID( self, synapse_ID, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end
            if nargin < 3, synapses = self.synapses; end
            
            % Retrieve all of the existing synapse IDs.
            existing_synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Determine whether the given synapse ID is one of the existing synapse IDs ( if so, provide the matching logicals and indexes ).
            [ b_match_found, match_logicals, match_indexes ] = array_utilities.is_value_in_array( synapse_ID, existing_synapse_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to check whether a proposed synapse ID is a unique natural.
        function b_unique_natural = unique_natural_synapse_ID( self, synapse_ID, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end
            if narign < 3, synapses = self.synapses; end
            
            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this synapse ID is unique.
            b_unique = self.unique_synapse_ID( synapse_ID, synapses, array_utilities );
            
            % Determine whether this synapse ID is a unique natural.
            if b_unique && ( synapse_ID > 0 ) && ( round( synapse_ID ) == synapse_ID )                     % If this neuron ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end
        
        
        % Implement a function to check if the existing synapse IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_synapse_IDs( self, synapses )
            
            % Set the default input arguments.
            if nargin < 2, synapses = self.synapses; end
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Retrieve all of the existing synapse IDs.
            synapse_IDs = self.get_all_synapse_IDs( synapses );
            
            % Determine whether all entries are unique.
            if length( unique( synapse_IDs ) ) == n_synapses                    % If all of the synapse IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, n_synapses );
                
            else                                                                     % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, synapses );
                
                % Determine which synapses have duplicate IDs.
                for k1 = 1:n_synapses                          % Iterate through each synapse...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another synapse with the same ID.
                    while ( k2 < n_synapses ) && ( ~match_logicals( k1 ) ) && ( k1 ~= ( k2 + 1 ) )                    % While we haven't checked all of the synapses and we haven't found a match...
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this synapse is a match.
                        if synapses( k2 ).ID == synapse_IDs( k1 )                              % If this synapse ID is a match...
                            
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
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, synapses = self.synapses; end
            
            % Compute the number of synapses.
            n_synapses = length( synapses );
            
            % Initialize the  synapse detected flag.
            b_synapse_detected = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the synapse(s) that connect the specified neurons.
            while ( ~b_synapse_detected ) && ( k < n_synapses )              % While a matching synapse has not yet been detected and we haven't looked through all of the synapses...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this synapse connects the specified neurons.
                if ( synapses( k ).from_neuron_ID == from_neuron_ID ) && ( synapses( k ).to_neuron_ID == to_neuron_ID )
                    
                    % Set the synapse detected flag to true.
                    b_synapse_detected = true;
                    
                end
                
            end
            
            % Determine whether a matching synapse was detected.
            if b_synapse_detected                                   % If we found a matching synapse....
                
                % Retrieve the ID of the matching synapse.
                synapse_ID = synapses( k ).ID;
                
            else                                                    % Otherwise...
                
                % Determine how to handle the situation where we can not find a synapse that connects the selected neurons.
                if strcmpi( undetected_option, 'error' )                                    % If the error option is selected...
                    
                    % Throw an error.
                    error( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                              % If the warning option is selected...
                    
                    % Throw a warning.
                    warning( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                               % If the ignore option is selected...
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the synpase IDs associated with the synapses that connect an array of specified neurons.
        function synapse_IDs = from_to_neuron_IDs2synapse_IDs( self, from_neuron_IDs, to_neuron_IDs, synapses, undetected_option )
            
            % Set the default input argument.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, synapses = self.synapses; end
            
            % Ensure that the same number of from and to neuron IDs are specified.
            assert( length( from_neuron_IDs ) == length( to_neuron_IDs ), 'length( from_neuron_IDs ) must equal length( to_neuron_IDs ).' )
            
            % Retrieve the number of synapses to find.
            num_synapses_to_find = length( from_neuron_IDs );
            
            % Preallocate an array to store the syanpse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_find );
            
            % Search for each synapse ID.
            for k = 1:num_synapses_to_find                              % Iterate through each set of neurons for which we are searching for a connecting synapse...
                
                % Retrieve the ID of the synapse that connects these neurons.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( from_neuron_IDs( k ), to_neuron_IDs( k ), synapses, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to oscillatory from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2oscillatory_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Retrieve the number of pairs of neurons.
                num_pairs = length( neuron_ID_order );
                
                % Augment the neuron ID order.
                neuron_ID_order = [ neuron_ID_order, neuron_ID_order( 1 ) ];
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k = 1:num_pairs                         % Iterate through each pair of neurons...
                    
                    % Retrieve the from neuron ID.
                    from_neuron_IDs( k ) = neuron_ID_order( k );
                    
                    % Retrieve the to neuron ID.
                    to_neuron_IDs( k ) = neuron_ID_order( k + 1 );
                    
                end
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to self connecting from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2self_from_to_neuron_IDs( ~, neuron_ID_order )
            
            % Determine whether there are neuron IDs to return.
            if ~isempty( neuron_ID_order )                                  % If the neuron ID order was specified...
                
                % Set the from-to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( neuron_ID_order );
                
            else                                                % Otherwise...
                
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
                for k1 = 1:num_neurons                         % Iterate through each pair of neurons...
                    for k2 = 1:num_neurons                         % Iterate through each pair of neurons...
                        
                        % Advance the counter variable.
                        k3 = k3 + 1;
                        
                        % Retrieve the from neuron ID.
                        from_neuron_IDs( k3 ) = neuron_ID_order( k1 );
                        
                        % Retrieve the to neuron ID.
                        to_neuron_IDs( k3 ) = neuron_ID_order( k2 );
                        
                    end
                end
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to retrieve the synapse IDs relevant to a set of neuron IDs.
        function synapse_IDs = neuron_IDs2synapse_IDs( self, neuron_IDs, synapses, undetected_option )
            
            % Set the default input argument.
            if nargin < 4, undetected_option = 'error'; end
            if nargin < 3, synapses = self.synapses; end
            
            % Retrieve the IDs of all relevant from and to neurons.
            [ from_neuron_IDs, to_neuron_IDs ] = self.neuron_ID_order2all_from_to_neuron_IDs( neuron_IDs );
            
            % Retrieve the synapse IDs associated with the given neuron IDs.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs, synapses, undetected_option );
            
        end
        
        
        % Implement a function to determine whether only a single synapse connects each pair of neurons.
        function b_one_to_one = one_to_one_synapses( self, synapses, array_utilities )
            
            % Set the default input arguments.
            if nargin < 3, array_utilities = self.array_utilities; end
            if nargin < 2, synapses = self.synapses; end
            
            % Set the one-to-one flag.
            b_one_to_one = true;
            
            % Initialize a counter variable.
            k = 0;
            
            % Preallocate arrays to store the from and to neuron IDs.
            [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, n_synapses ) );
            b_enableds = false( 1, n_synapses );
            
            % Determine whether there is only one synapse between each neuron.
            while ( b_one_to_one ) && ( k < n_synapses )                             % While we haven't found a synapse repetition and we haven't checked all of the synpases...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Store these from neuron and to neuron IDs.
                from_neuron_IDs( k ) = synapses( k ).from_neuron_ID;
                to_neuron_IDs( k ) = synapses( k ).to_neuron_ID;
                b_enableds( k ) = synapses( k ).b_enabled;
                
                % Determine whether we need to check this synapse for repetition.
                if k ~= 1                               % If this is not the first iteration...
                    
                    % Determine whether the from and to neuron IDs are unique.
                    [ from_neuron_ID_match, from_neuron_ID_match_logicals ] = array_utilities.is_value_in_array( from_neuron_IDs( k ), from_neuron_IDs( 1:( k  - 1 ) ) );
                    [ to_neuron_ID_match, to_neuron_ID_match_logicals ] = array_utilities.is_value_in_array( to_neuron_IDs( k ), to_neuron_IDs( 1:( k  - 1 ) ) );
                    
                    % Determine whether this synapse is a duplicate.
                    if from_neuron_ID_match && to_neuron_ID_match && b_enableds( k ) && any( from_neuron_ID_match_logicals & to_neuron_ID_match_logicals & b_enableds( 1:( k  - 1 ) ) )                           % If both the from neuron ID match flag and to neuron ID match flag are true, and we detect that these flags are aligned...
                        
                        % Set the one-to-one flag to false (this synapse is duplicate).
                        b_one_to_one = false;
                        
                    end
                    
                end
                
            end
            
        end
        
        
        %% CPG Delta Compute Functions.
        
        % Implement a function to assign the desired delta value to each synapse based on the neuron order that we want to follow.
        function [ synapses, self ] = compute_cpg_deltas( self, neuron_IDs, delta_oscillatory, delta_bistable, synapses, set_flag, undetected_option, array_utilities )
            
            % Set the default input arguments.
            if nargin < 8, array_utilities = self.array_utilities; end
            if nargin < 7, undetected_option = 'error'; end
            if nargin < 6, set_flag = true; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end
            
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
        
        
        %% Parameter Processing Functions.
        
        % Implement a function to process the inversion subnetwork output synaptic reversal potential parameters.
        function parameters = process_inversion_dEs_parameters( self, parameters, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, parameters = {  }; end
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                   	% If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                    % If no parameters were provided...
                    
                    % Set the default parameter values.
                    c = self.c_DEFAULT;
                    delta_offset = self.delta_DEFAULT;
                    
                    % Store the required parameters in a cell.
                    parameters = { c, delta_offset };
                    
                else                                                       	% Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 2                            % If there is anything other than four parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                   % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if isempty( parameters )                                   % If no parameters were provided...
                    
                    % Set the default parameter values.
                    epsilon = self.epsilon_DEFAULT;
                    delta_offset = self.delta_DEFAULT;
                    R2 = self.R_DEFAULT;
                    
                    % Store the required parameters in a cell.
                    parameters = { epsilon, delta_offset, R2 };
                    
                else                                                        % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 3                            % If there is anything other than four parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                    
                    end
                    
                end
                
            else                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
                        
        end
        
        
        % Implement a function to process the division subnetwork output synaptic reversal potential parameters.
        function parameters = process_division_dEs1_parameters( self, parameters, encoding_scheme )
        
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, parameters = {  }; end
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                   	% If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                    % If no parameters were provided...
                    
                    % Set the default parameter values.
                    c = self.c_DEFAULT;
                    alpha = self.alpha_DEFAULT;
                    
                    % Store the required parameters in a cell.
                    parameters = { c, alpha };
                    
                else                                                       	% Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 2                            % If there is anything other than the required number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                   % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if isempty( parameters )                                   % If no parameters were provided...
                    
                    % Set the default parameter values.
                    c = self.c_DEFAULT;
                    alpha = self.alpha_DEFAULT;
                    
                    % Store the required parameters in a cell.
                    parameters = { c, alpha };
                    
                else                                                        % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 2                            % If there is anything other than the require number of parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                    
                    end
                    
                end
                
            else                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
                        
        end
        
        
        %% Synaptic Reversal Potential Compute Functions.
        
        % Implement a function to compute and set the synaptic reversal potential of a driven multistate cpg subnetwork.
        function [ dEs, synapses, self ] = compute_dmcpg_dEs( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [  dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_dmcpg_dEs( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synapses = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a transmission subnetwork.
        function [ dEs, synapses, self ] = compute_transmission_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_transmission_dEs( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a modulation subnetwork.
        function [ dEs, synapses, self ] = compute_modulation_dEs( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_modulation_dEs( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function [ dEs1, synapses, self ] = compute_addition_dEs1( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_addition_dEs1( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an addition subnetwork.
        function [ dEs2, synapses, self ] = compute_addition_dEs2( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if anrgin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_addition_dEs2( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute addition subnetwork synapses.
        function [ dEs, synapses, self ] = compute_addition_dEs( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                             % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_addition_dEs( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        

        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function [ dEs1, synapses, self ] = compute_subtraction_dEs1( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end     
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs1( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a subtraction subnetwork.
        function [ dEs2, synapses, self ] = compute_set_subtraction_dEsyn2( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs2( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction subnetwork excitatory synapses.
        function [ dEs, synapses, self ] = compute_subtraction_dEs_excitatory( self, synapse_IDs_excitatory, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs_excitatory = 'all'; end                                                                                                % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs_excitatory = self.validate_synapse_IDs( synapse_IDs_excitatory, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs_excitatory );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs_excitatory( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_excitatory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of absolute subtraction subnetwork inhibitory synapses.
        function [ dEs, synapses, self ] = compute_subtraction_dEs_inhibitory( self, synapse_IDs_inhibitory, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs_inhibitory = 'all'; end                                                                                  % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs_inhibitory = self.validate_synapse_IDs( synapse_IDs_inhibitory, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs_inhibitory );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs_inhibitory( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_subtraction_dEs_inhibitory( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs1, synapses, self ] = compute_multiplication_dEs1( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute the required parameter for this synapse.
                [ dEs1, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs1( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs2, synapses, self ] = compute_multiplication_dEs2( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2, synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs2( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a multiplication subnetwork.
        function [ dEs3, synapses, self ] = compute_multiplication_dEs3( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs3 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs3( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_multiplication_dEs3( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of an inversion subnetwork.
        function [ dEs, synapses, self ] = compute_inversion_dEs( self, synapse_IDs, parameters, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = 'error'; end
            if nargin < 6, set_flag = true; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, parameters = {  }; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the parameters.
            parameters = self.process_inversion_dEs_parameters( parameters, encoding_scheme );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_inversion_dEs( parameters, encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function [ dEs, synapses, self ] = compute_division_dEs1( self, synapse_IDs, parameters, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = 'error'; end
            if nargin < 6, set_flag = true; end
            if nargin < 5, synapses = self.synapses; end
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 3, parameters = {  }; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Process the parameters.
            parameters = process_division_dEs1_parameters( parameters, encoding_scheme );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_dEs1( parameters, encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a division subnetwork.
        function [ dEs2, synapses, self ] = compute_division_dEs2( self, synapse_IDs, encoding_scheme, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = 'error'; end
            if nargin < 5, set_flag = true; end
            if nargin < 4, synapses = self.synapses; end
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_division_dEs2( encoding_scheme, true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
                
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function [ dEs1, synapses, self ] = compute_derivation_dEs1( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_derivation_dEs1( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a derivation subnetwork.
        function [ dEs2, synapses, self ] = compute_derivation_dEs2( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_derivation_dEs2( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, synapses, self ] = compute_integration_dEs1( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_integration_dEs1( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, synapses, self ] = compute_integration_dEs2( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_integration_dEs2( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs1, synapses, self ] = compute_vbi_dEs1( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs1 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs1( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_vbi_dEs1( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        % Implement a function to compute and set the synaptic reversal potential of a voltage based integration subnetwork.
        function [ dEs2, synapses, self ] = compute_vbi_dEs2( self, synapse_IDs, synapses, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = 'error'; end
            if nargin < 4, set_flag = true; end
            if nargin < 3, synapses = self.synapses; end
            if nargin < 2, synapse_IDs = 'all'; end                                                                                                 % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Preallocate an array to store the computed values.
            dEs2 = zeros( 1, num_synapses_to_evaluate ); 
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                [ dEs2( k ), synapses( synapse_index ) ] = synapses( synapse_index ).compute_vbi_dEs2( true, synapses( synapse_index ).synapse_utilities );
                
            end
            
            % Determine whether to update the synapse manager object.
            if set_flag, self.synpases = synapses; end
            
        end
        
        
        %% Maximum Synaptic Conductance Compute Functions.
        
        % Implement a function to compute and set the maximum synaptic conductance of a driven multistate cpg subnetwork.
        function self = compute_set_driven_multistate_cpg_gsynmax( self, synapse_IDs, delta_oscillatory, I_drive_max )
            
            % Set the default input arguments.
            if nargin < 4, I_drive_max = self.Id_max_DEFAULT; end                                                                  % [A] Maximum Drive Current
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end                                                      % [V] Oscillatory CPG Equilibrium Offset
            if nargin < 2, synapse_IDs = 'all'; end                                                                                     % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_driven_multistate_cpg_gsynmax( self.synapses( synapse_index ).dE_syn, delta_oscillatory, I_drive_max );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute addition subnetwork synapses.
        function self = compute_set_absolute_addition_gsyn( self, synapse_IDs, c, R_k, Gm_n, Iapp_n )
            
            % Set the default input arguments.
            if nargin < 6, Iapp_n = self.Ia_absolute_addition_DEFAULT; end                                                            % [A] Applied Current
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end                                                                                  % [S] Membrane Conductance
            if nargin < 4, R_k = self.R_DEFAULT; end                                                                                    % [V] Activation Domain
            if nargin < 3, c = self.c_absolute_addition_DEFAULT; end                                                                    % [-] Subnetwork Gain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                     % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_absolute_addition_gsyn( c, R_k, Gm_n, self.synapses( synapse_index ).dE_syn, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative addition subnetwork synapses.
        function self = compute_set_relative_addition_gsyn( self, synapse_IDs, c, n, R_n, Gm_n, Iapp_n )
            
            % Set the default input arguments.
            if nargin < 7, Iapp_n = self.Ia_relative_addition_DEFAULT; end                                                                % [A] Applied Current
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 5, R_n = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 4, n = self.num_addition_neurons_DEFAULT; end                                                                       % [#] Number of Addition Neurons
            if nargin < 3, c = self.c_relative_addition_DEFAULT; end                                                                        % [-] Subnetwork Gain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_relative_addition_gsyn( c, n, R_n, Gm_n, self.synapses( synapse_index ).dE_syn, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute subtraction subnetwork synapses.
        function self = compute_set_absolute_subtraction_gsyn( self, synapse_IDs, c, s_k, R_k, Gm_n, Iapp_n )
            
            % Set the default input arguments.
            if nargin < 7, Iapp_n = self.Ia_absolute_subtraction_DEFAULT; end                                                             % [A] Applied Current
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 5, R_k = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 4, s_k = [ 1, -1 ]; end                                                                                             % [-] Excitatory / Inhibitory Sign Flag
            if nargin < 3, c = self.c_absolute_subtraction_DEFAULT; end                                                                     % [-] Subnetwork Gain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_absolute_subtraction_gsyn( c, s_k( k ), R_k( k ), Gm_n, self.synapses( synapse_index ).dE_syn, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative subtraction subnetwork synapses.
        function self = compute_set_relative_subtraction_gsyn( self, synapse_IDs, c, npm_k, s_k, R_n, Gm_n, Iapp_n )
            
            % Set the default input arguments.
            if nargin < 8, Iapp_n = self.Ia_relative_subtraction_DEFAULT; end                                                             % [A] Applied Current
            if nargin < 7, Gm_n = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 6, R_n = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 5, s_k = [ 1, -1 ]; end                                                                                             % [-] Excitatory / Inhibitory Sign Flag
            if nargin < 4, npm_k = [ 1, 1 ]; end                                                                                            % [-] Number of Excitatory / Inhibitory Neurons
            if nargin < 3, c = self.c_relative_subtraction_DEFAULT; end                                                                     % [-] Subnetwork Gain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_relative_subtraction_gsyn( c, npm_k( k ), s_k( k ), R_n, Gm_n, self.synapses( synapse_index ).dE_syn, Iapp_n );
                
            end
            
        end
        
        
        %         % Implement a function to compute and set the maximum synaptic conductance of absolute inversion subnetwork synapses.
        %         function self = compute_set_absolute_inversion_gsyn( self, synapse_IDs, c, epsilon, R_1, Gm_2, Iapp_2 )
        %
        %             % Set the default input arguments.
        %             if nargin < 7, Iapp_2 = self.Iapp_ABSOLUTE_INVERSION_DEFAULT; end                                                               % [A] Applied Current
        %             if nargin < 6, Gm_2 = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
        %             if nargin < 5, R_1 = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                              % [-] Subnetwork Offset
        %             if nargin < 3, c = self.c_absolute_inversion_DEFAULT; end                                                                       % [-] Subnetwork Gain
        %             if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
        %
        %             % Validate the synapse IDs.
        %             synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
        %
        %             % Determine how many synapses to which we are going to apply the given method.
        %             num_synapses_to_evaluate = length( synapse_IDs );
        %
        %             % Evaluate the given synapse method for each neuron.
        %             for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
        %
        %                 % Retrieve the index associated with this synapse ID.
        %                 synapse_index = self.get_synapse_index( synapse_IDs( k ) );
        %
        %                 % Compute and set the required parameter for this synapse.
        %                 self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_absolute_inversion_gsyn( c, epsilon, R_1, Gm_2, Iapp_2 );
        %
        %             end
        %
        %         end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute inversion subnetwork synapses.
        function self = compute_set_absolute_inversion_gsyn( self, synapse_IDs, Iapp_2 )
            
            % Set the default input arguments.
            if nargin < 3, Iapp_2 = self.Iapp_ABSOLUTE_INVERSION_DEFAULT; end                                                               % [A] Applied Current
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_absolute_inversion_gsyn( self.synapses( synapse_index ).dE_syn, Iapp_2 );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative inversion subnetwork synapses.
        function self = compute_set_relative_inversion_gsyn( self, synapse_IDs, Iapp_2 )
            
            % Set the default input arguments.
            if nargin < 3, Iapp_2 = self.Iapp_ABSOLUTE_INVERSION_DEFAULT; end                                                               % [A] Applied Current
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each neuron.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Compute and set the required parameter for this synapse.
                self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_relative_inversion_gsyn( self.synapses( synapse_index ).dE_syn, Iapp_2 );
                
            end
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute division subnetwork numerator synapses.
        function self = compute_set_absolute_division_gsyn31( self, synapse_IDs, alpha, epsilon, R_1, Gm_3 )
            
            % Set the default input arguments.
            if nargin < 6, Gm_3 = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 5, R_1 = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                                              % [-] Subnetwork Offset
            if nargin < 3, alpha = self.alpha_DEFAULT; end                                                                                  % [-] Subnetwork Denominator Adjustment
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with the numerator synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_absolute_division_gsyn31( alpha, epsilon, R_1, Gm_3 );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of absolute division subnetwork denominator synapses.
        function self = compute_set_absolute_division_gsyn32( self, synapse_IDs, epsilon, R_2, Gm_3 )
            
            % Set the default input arguments.
            if nargin < 5, Gm_3 = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 4, R_2 = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                                              % [-] Subnetwork Offset
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with the numerator and denominator synapses.
            synapse_index_denominator = self.get_synapse_index( synapse_IDs( end ), synapses, undetected_option );
            
            % Compute and set the required parameter for the denominator synapse.
            self.synapses( synapse_index_denominator ) = self.synapses( synapse_index_denominator ).compute_set_absolute_division_gsyn32( epsilon, R_2, Gm_3 );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative division subnetwork numerator synapses.
        function self = compute_set_relative_division_gsyn31( self, synapse_IDs, R_3, Gm_3 )
            
            % Set the default input arguments.
            if nargin < 4, Gm_3 = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 3, R_3 = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with the numerator synapse.
            synapse_index = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            
            % Compute and set the required parameter for the numerator synapse.
            self.synapses( synapse_index ) = self.synapses( synapse_index ).compute_set_relative_division_gsyn31( R_3, Gm_3, self.synapses( synapse_index ).dE_syn );
            
        end
        
        
        % Implement a function to compute and set the maximum synaptic conductance of relative division subnetwork denominator synapses.
        function self = compute_set_relative_division_gsyn32( self, synapse_IDs, c, alpha, epsilon, R_3, Gm_3 )
            
            % Set the default input arguments.
            if nargin < 7, Gm_3 = self.Gm_DEFAULT; end                                                                                      % [S] Membrane Conductance
            if nargin < 6, R_3 = self.R_DEFAULT; end                                                                                        % [V] Activation Domain
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                                                                              % [-] Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end
            if nargin < 3, c = self.c_relative_division_DEFAULT; end                                                                        % [-] Subnetwork Gain
            if nargin < 2, synapse_IDs = 'all'; end                                                                                         % [-] Synapse IDs
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the index associated with the numerator and denominator synapses.
            synapse_index_numerator = self.get_synapse_index( synapse_IDs( 1 ), synapses, undetected_option );
            synapse_index_denominator = self.get_synapse_index( synapse_IDs( end ), synapses, undetected_option );
            
            % Compute and set the required parameter for this synapse.
            self.synapses( synapse_index_denominator ) = self.synapses( synapse_index_denominator ).compute_set_relative_division_gsyn32( c, alpha, epsilon, R_3, Gm_3, self.synapses( synapse_index_numerator ).dE_syn );
            
        end
        
        
        %% Enable & Disable Functions
        
        % Implement a function to enable synapses.
        function self = enable_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to enable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Enable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Enable this synapse.
                self.synapses( synapse_index ).b_enabled = true;
                
            end
            
        end
        
        
        % Implement a function to disable synapses.
        function self = disable_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Disable this synapse.
                self.synapses( synapse_index ).b_enabled = false;
                
            end
            
        end
        
        
        % Implement a function to toggle synapse enable state.
        function self = toggle_enabled_synapses( self, synapse_IDs )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Determine the number of synapses to disable.
            num_synapses_to_enable = length( synapse_IDs );
            
            % Disable all of the specified synapses.
            for k = 1:num_synapses_to_enable                      % Iterate through all of the specified synapses...
                
                % Retrieve this synapse index.
                synapse_index = self.get_synapse_index( synapse_IDs( k ), synapses, undetected_option );
                
                % Toggle this synapse.
                self.synapses( synapse_index ).b_enabled = ~self.synapses( synapse_index ).b_enabled;
                
            end
            
        end
        
        
        %% Synapse Creation Functions
        
        % Implement a function to create a new synapse.
        function [ self, ID ] = create_synapse( self, ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled )
            
            % Set the default synapse properties.
            if nargin < 9, b_enabled = true; end                                                            % [T/F] Synapse Enabled Flag
            if nargin < 8, delta = self.delta_noncpg_DEFAULT; end                                                  % [V] Generic CPG Equilibrium Offset
            if nargin < 7, to_neuron_ID = self.to_neuron_ID_DEFAULT; end                                    % [-] To Neuron ID
            if nargin < 6, from_neuron_ID = self.from_neuron_ID_DEFAULT; end                                % [-] From Neuron ID
            if nargin < 5, g_syn_max = self.gs_max_DEFAULT; end                                            % [S] Maximum Synaptic Conductance
            if nargin < 4, dE_syn = self.dEs_minimum_DEFAULT; end                                        % [V] Synaptic Reversal Potential
            if nargin < 3, name = ''; end                                                                   % [-] Synapse Name
            if nargin < 2, ID = self.generate_unique_synapse_ID( synapses, array_utilities ); end                                    % [#] Synapse ID
            
            % Ensure that this synapse ID is a unique natural.
            assert( self.unique_natural_synapse_ID( ID, synapses, array_utilities ), 'Proposed synapse ID %0.2f is not a unique natural number.', ID )
            
            % Create an instance of the synapse class.
            synapse = synapse_class( ID, name, dE_syn, g_syn_max, from_neuron_ID, to_neuron_ID, delta, b_enabled );
            
            % Append this synapse to the array of existing synapses.
            self.synapses = [ synapses, synapse ];
            
            % Increase the number of synapses counter.
            self.num_synapses = self.num_synapses + 1;
            
        end
        
        
        % Implement a function to create multiple synapses.
        function [ self, IDs ] = create_synapses( self, IDs, names, dE_syns, g_syn_maxs, from_neuron_IDs, to_neuron_IDs, deltas, b_enableds )
            
            % Determine whether number of synapses to create.
            if nargin > 2                                               % If more than just synapse IDs were provided...
                
                % Set the number of synapses to create to be the number of provided IDs.
                num_synapses_to_create = length( IDs );
                
            elseif nargin == 2                                          % If just the synapse IDs were provided...
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                % Determine who to interpret this number of IDs.
                if num_IDs == 1                                     % If the number of IDs is one...
                    
                    % Then create a number of synapses equal to the specific ID.  (i.e., in this case we are treating the single provided ID value as the number of synapses that we want to create.)
                    num_synapses_to_create = IDs;
                    
                    % Preallocate an array of IDs.
                    IDs = self.generate_unique_synapse_IDs( num_synapses_to_create, synapses, array_utilities );
                    
                else                                                % Otherwise... ( More than one ID was provided... )
                    
                    % Set the number of synapses to create to be the number of provided synapse IDs.
                    num_synapses_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1                                      % If no input arguments were provided... ( Beyond the default self argument.)
                
                % Set the number of synapses to create to one.
                num_synapses_to_create = 1;
                
            end
            
            % Set the default synapse properties.
            if nargin < 9, b_enableds = true( 1, num_synapses_to_create ); end                                                      % [T/F] Synapse Enabled Flag
            if nargin < 8, deltas = self.delta_noncpg_DEFAULT*ones( 1, num_synapses_to_create ); end                                       % [V] Generic CPG Equilibrium Offset
            if nargin < 7, to_neuron_IDs = self.to_neuron_ID_DEFAULT*ones( 1, num_synapses_to_create ); end                         % [-] To Neuron ID
            if nargin < 6, from_neuron_IDs = self.from_neuron_ID_DEFAULT*ones( 1, num_synapses_to_create ); end                     % [-] From Neuron ID
            if nargin < 5, g_syn_maxs = self.gs_max_DEFAULT*ones( 1, num_synapses_to_create ); end                                 % [S] Maximum Synaptic Conductance
            if nargin < 4, dE_syns = self.dEs_minimum_DEFAULT*ones( 1, num_synapses_to_create ); end                             % [V] Synaptic Reversal Potential
            if nargin < 3, names = repmat( { '' }, 1, num_synapses_to_create ); end                                                 % [-] Synapse Name
            if nargin < 2, IDs = self.generate_unique_synapse_IDs( num_synapses_to_create, synapses, array_utilities ); end                                    % [#] Synapse ID
            
            % Create each of the spcified synapses.
            for k = 1:num_synapses_to_create                         % Iterate through each of the synapses we want to create...
                
                % Create this synapse.
                self = self.create_synapse( IDs( k ), names{k}, dE_syns( k ), g_syn_maxs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ), deltas( k ), b_enableds( k ) );
                
            end
            
        end
        
        
        % Implement a function to delete a synapse.
        function self = delete_synapse( self, synapse_ID )
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Remove this synapse from the array of synapses.
            self.synapses( synapse_index ) = [  ];
            
            % Decrease the number of synapses counter.
            self.num_synapses = self.num_synapses - 1;
            
        end
        
        
        % Implement a function to delete multiple synapses.
        function self = delete_synapses( self, synapse_IDs )
            
            % Set the default input arguments.
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapses to delete.
            num_synapses_to_delete = length( synapse_IDs );
            
            % Delete each of the specified synapses.
            for k = 1:num_synapses_to_delete                      % Iterate through each of the synapses we want to delete...
                
                % Delete this synapse.
                self = self.delete_synapse( synapse_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to connect a synapse to neurons.
        function self = connect_synapse( self, synapse_ID, from_neuron_ID, to_neuron_ID )
            
            % Retrieve the index associated with this synapse.
            synapse_index = self.get_synapse_index( synapse_ID, synapses, undetected_option );
            
            % Set the from neuron ID property of this synapse.
            self.synapses( synapse_index ).from_neuron_ID = from_neuron_ID;
            
            % Set the to neuron ID property of this synapse.
            self.synapses( synapse_index ).to_neuron_ID = to_neuron_ID;
            
        end
        
        
        % Implement a function to connet multiple synapses to multiple neurons.
        function self = connect_synapses( self, synapse_IDs, from_neuron_IDs, to_neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, synapse_IDs = 'all'; end
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs, synapses );
            
            % Retrieve the number of synapses to connect.
            num_synapses_to_connect = length( synapse_IDs );
            
            % Ensure that the synapse IDs, from neuron IDs, and to neuron IDs have the same length.
            assert( ( num_synapses_to_connect == length( from_neuron_IDs ) ) && ( num_synapses_to_connect == length( to_neuron_IDs ) ), 'The number of from and to neuron IDs must match the number of specified synapse IDs.' )
            
            % Connect each of the specified synapses.
            for k = 1:num_synapses_to_connect                      % Iterate through each of the synapses we want to connect...
                
                % Connect this synapse.
                self = connect_synapse( self, synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
                
            end
            
        end
        
        
        %% Subnetwork Synapse Creation Functions
        
        % Implement a function to create the synapses for a multistate CPG subnetwork.
        function [ self, synapse_IDs ] = create_multistate_cpg_synapses( self, neuron_IDs )
            
            % Compute the number of CPG neurons.
            num_cpg_neurons = length( neuron_IDs );
            
            % Generate unique synapse IDs for the multistate CPG subnetwork.
            synapse_IDs = self.generate_unique_synapse_IDs( num_cpg_neurons^2, synapses, array_utilities );
            
            % Create the multistate cpg subnetwork synapses.
            self = self.create_synapses( synapse_IDs );
            
            % Initialize a counter variable.
            k3 = 0;
            
            % Edit the network properties.
            for k1 = 1:num_cpg_neurons                              % Iterate through each of the CPG neurons (from which the synapses are starting)...
                for k2 = 1:num_cpg_neurons                          % Iterate through each of the CPG neurons (to which the synapses are going)...
                    
                    % Advance the counter variable.
                    k3 = k3 + 1;
                    
                    % Get the index associated with this synapse.
                    synapse_index = self.get_synapse_index( synapse_IDs( k3 ), synapses, undetected_option );
                    
                    % Set the from neuron ID and to neuron ID.
                    synapses( synapse_index ).from_neuron_ID = neuron_IDs( k1 );
                    synapses( synapse_index ).to_neuron_ID = neuron_IDs( k2 );
                    
                    % Set the name of this synapse.
                    synapses( synapse_index ).name = sprintf( 'CPG %0.0f%0.0f', neuron_IDs( k1 ), neuron_IDs( k2 ) );
                    
                    % Set the reversal potential of this synapse (if necessary).
                    if k1 == k2, self.synapses( synapse_index ).dE_syn = 0; end
                    
                end
            end
            
        end
        
        
        % Implement a function to create the synapses for a multistate CPG subnetwork.
        function [ self, synapse_IDs ] = create_driven_multistate_cpg_synapses( self, neuron_IDs )
            
            % Create the multistate cpg synapses.
            [ self, synapse_IDs_cpg ] = self.create_multistate_cpg_synapses( neuron_IDs( 1:( end - 1 ) ) );
            
            % Compute the number of drive synapses.
            num_drive_synapses = length( neuron_IDs ) - 1;
            
            % Create the drive synapses.
            [ self, synapse_IDs_drive ] = self.create_synapses( num_drive_synapses );
            
            % Connect and set the name of each drive synapse.
            for k = 1:num_drive_synapses                    % Iterate through each of the drive synapses...
                
                % Set the name of this synapse.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs_drive( k ), { sprintf( 'Drive -> CPG %0.0f', neuron_IDs( k ) ) }, 'name', synapses, set_flag );
                
                % Connect this synapse.
                self = self.connect_synapse( synapse_IDs_drive( k ), neuron_IDs( end ), neuron_IDs( k ) );
                
            end
            
            % Concatenate the synapse IDs.
            synapse_IDs = [ synapse_IDs_cpg, synapse_IDs_drive ];
            
        end
        
        
        % Implement a function to create the synapses that connect driven multistate cpg to their respective modulated split subtraction voltage based integration subnetworks.
        function [ self, synapse_IDs ] = create_dmcpg2mssvbi_synapses( self, neuron_IDs_cell )
            
            % Determine the number of cpg neurons.
            num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Define the number of unique synapses.
            num_unique_synapses = 2*num_cpg_neurons;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Create the synapses that connect the driven multistate cpg neurons to the modulated split subtraction voltage based integration neurons.
            for k = 1:num_cpg_neurons                   % Iterate through each of the CPG neurons...        %NOTE: While it may seem odd that I have two separate consecutive loops with the same iterator, this is done because we want to create all of the modulated split subtraction voltage based integration synapses first before creating the unique synapses.
                
                % Compute the index.
                index = 2*( k - 1 ) + 1;
                
                % Define the from and to neuron IDs.
                from_neuron_ID1 = neuron_IDs_cell{ 1 }( k ); to_neuron_ID1 = neuron_IDs_cell{ k + 2 }( 1 );
                from_neuron_ID2 = neuron_IDs_cell{ 2 }( k ); to_neuron_ID2 = neuron_IDs_cell{ k + 2 }( 2 );
                
                % Define the synapse names.
                synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
                synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
                
                % Set the names of these synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( index ), { synapse_name1 }, 'name', synapses, set_flag );
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( index + 1 ), { synapse_name2 }, 'name', synapses, set_flag );
                
                % Connect this synapse.
                self = self.connect_synapse( synapse_IDs( index ), from_neuron_ID1, to_neuron_ID1 );
                self = self.connect_synapse( synapse_IDs( index + 1 ), from_neuron_ID2, to_neuron_ID2 );
                
            end
            
        end
        
        
        % Implement a function to create the synapses that connect modulated split subtraction voltage based integration subnetworks to the split lead lag subnetwork.
        function [ self, synapse_IDs ] = create_mssvbi2sll_synapses( self, neuron_IDs_cell )
            
            % Determine the number of cpg neurons.
            num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Define the number of unique synapses.
            num_unique_synapses = 2*num_cpg_neurons + 2;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Create the addition synapses of the split lead lag subnetwork.
            for k = 1:num_cpg_neurons                   % Iterate through each of the CPG neurons...
                
                % Compute the index.
                index = 2*( k - 1 ) + 1;
                
                % Define the from and to neuron IDs.
                from_neuron_ID1 = neuron_IDs_cell{ k + 2 }( 15 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 1 );
                from_neuron_ID2 = neuron_IDs_cell{ k + 2 }( 16 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 2 );
                
                % Define the synapse names.
                synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
                synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
                
                % Set the names of these synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( index ), { synapse_name1 }, 'name', synapses, set_flag );
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( index + 1 ), { synapse_name2 }, 'name', synapses, set_flag );
                
                % Connect this synapse.
                self = self.connect_synapse( synapse_IDs( index ), from_neuron_ID1, to_neuron_ID1 );
                self = self.connect_synapse( synapse_IDs( index + 1 ), from_neuron_ID2, to_neuron_ID2 );
                
            end
            
            % Define the from and to neuron IDs for the slow tranmission synapses.
            from_neuron_ID1 = neuron_IDs_cell{ end }( 1 ); to_neuron_ID1 = neuron_IDs_cell{ end }( 3 );
            from_neuron_ID2 = neuron_IDs_cell{ end }( 2 ); to_neuron_ID2 = neuron_IDs_cell{ end }( 4 );
            
            % Define the synapse names for the slow transmission synapses
            synapse_name1 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID1, to_neuron_ID1 );
            synapse_name2 = sprintf( 'Syn %0.0f%0.0f ', from_neuron_ID2, to_neuron_ID2 );
            
            % Set the names of the slow transmission synapses of the split lead lag subnetwork.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs( end - 1 ), { synapse_name1 }, 'name', synapses, set_flag );
            [ synapses, self ] = self.set_synapse_property( synapse_IDs( end ), { synapse_name2 }, 'name', synapses, set_flag );
            
            % Connect the slow tranmission synapses of the split lead lag subnetwork.
            self = self.connect_synapse( synapse_IDs( end - 1 ), from_neuron_ID1, to_neuron_ID1 );
            self = self.connect_synapse( synapse_IDs( end ), from_neuron_ID2, to_neuron_ID2 );
            
        end
        
        
        % Implement a function to create the synapses for a driven multistate cpg split lead lag subnetwork.
        function [ self, synapse_IDs_cell ] = create_dmcpg_sll_synapses( self, neuron_IDs_cell )
            
            % Retrieve the number of subnetworks and cpg neurons.
            num_subnetworks = length( neuron_IDs_cell );
            num_cpg_neurons = length( neuron_IDs_cell{ 1 } ) - 1;
            
            % Preallocate a cell array to store the synapse IDs.
            synapse_IDs_cell = cell( 1, num_subnetworks + 1 );
            
            % Create the driven multistate cpg synapses.
            [ self, synapse_IDs_cell{ 1 } ] = self.create_driven_multistate_cpg_synapses( neuron_IDs_cell{ 1 } );
            [ self, synapse_IDs_cell{ 2 } ] = self.create_driven_multistate_cpg_synapses( neuron_IDs_cell{ 2 } );
            
            % Create the synapses for each of the modulated split subtraction voltage based integration synapses.
            for k = 1:num_cpg_neurons                   % Iterate through each of the cpg neurons...
                
                % Create the modulated split subtraction voltage based integration synapses for this subnetwork.
                [ self, synapse_IDs_cell{ k + 2 } ] = self.create_mod_split_sub_vb_integration_synapses( neuron_IDs_cell{ k + 2 } );
                
            end
            
            % Create the synapses that connect the driven multistate cpg to the modulated split subtraction voltage based integration subnetworks.
            [ self, synapse_IDs_cell{ end - 1 } ] = self.create_dmcpg2mssvbi_synapses( neuron_IDs_cell );
            
            % Create the synapses that connect the modulated split subtraction voltage based integration subnetworks to the split lead lag subnetwork.
            [ self, synapse_IDs_cell{ end } ] = self.create_mssvbi2sll_synapses( neuron_IDs_cell );
            
        end
        
        
        % Implement a function to create the synapses that connect a driven multistate cpg double centered lead lag subnetwork to a double centered subnetwork.
        function [ self, synapse_IDs ] = create_dmcpgsll2dc_synapses( self, neuron_IDs_cell )
            
            % Define the number of unique synapses.
            num_unique_synapses = 2;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ end }( end - 1 ) neuron_IDs_cell{ 1 }{ end }( end ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Setup each of the synapses.
            for k = 1:num_unique_synapses               % Iterate through each of the unique synapses...
                
                % Set the names of each of the unique synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
                
                % Connect the unique synapses.
                self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a driven multistate cpg double centered lead lag subnetwork.
        function [ self, synapse_IDs_cell ] = create_dmcpg_dcll_synapses( self, neuron_IDs_cell )
            
            % Create the double subtraction subnetwork synapses.
            [ self, synapse_IDs_dmcpgsll ] = self.create_dmcpg_sll_synapses( neuron_IDs_cell{ 1 } );
            
            % Create the double centering subnetwork synapses.
            [ self, synapse_IDs_dc ] = self.create_double_centering_synapses( neuron_IDs_cell{ 2 } );
            
            % Create the driven multistate cpg double centered lead lag to double centering subnetwork synapses.
            [ self, synapse_IDs_dmcpgsll2dc ] = self.create_dmcpgsll2dc_synapses( neuron_IDs_cell );
            
            % Concatenate the synapse IDs.
            synapse_IDs_cell = { synapse_IDs_dmcpgsll, synapse_IDs_dc, synapse_IDs_dmcpgsll2dc };
            
        end
        
        
        % Implement a function to create the synapses that connect the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
        function [ self, synapse_IDs ] = create_dmcpgdcll2cds_synapses( self, neuron_IDs_cell )
            
            % Define the number of unique synapses.
            num_unique_synapses = 2;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 2 }( end - 1 ) neuron_IDs_cell{ 3 } ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 1 }( 1 ) neuron_IDs_cell{ 2 }{ 1 }( 2 ) ];
            
            % Setup each of the synapses.
            for k = 1:num_unique_synapses               % Iterate through each of the unique synapses...
                
                % Set the names of each of the unique synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
                
                % Connect the unique synapses.
                self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function [ self, synapse_IDs_cell ] = create_ol_dmcpg_dclle_synapses( self, neuron_IDs_cell )
            
            % Create the driven multistate cpg double centered lead lag subnetwork synapses.
            [ self, synapse_IDs_dmcpgdcll ] = self.create_dmcpg_dcll_synapses( neuron_IDs_cell{ 1 } );
            
            % Create the centered double subtraction subnetwork synapses.
            [ self, synapse_IDs_cds ] = self.create_centered_double_subtraction_synapses( neuron_IDs_cell{ 2 } );
            
            % Create the synapses that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the centered double subtraction subnetwork.
            [ self, synapse_IDs_dmcpgdcll2cds ] = self.create_dmcpgdcll2cds_synapses( neuron_IDs_cell );
            
            % Concatenate the synapse IDs.
            synapse_IDs_cell = { synapse_IDs_dmcpgdcll, synapse_IDs_cds, synapse_IDs_dmcpgdcll2cds };
            
        end
        
        
        % Implement a function to create the synapses that close the open loop driven multistate cpg double centered lead lag error subnetwork using a proportional controller.
        function [ self, synapse_IDs ] = create_oldmcpgdclle2dmcpg_synapses( self, neuron_IDs_cell )
            
            % Define the number of unique synapses.
            num_unique_synapses = 2;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 2 }{ 2 }( end - 1 ) neuron_IDs_cell{ 2 }{ 2 }( end ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 1 }{ 1 }{ 2 }( end ) neuron_IDs_cell{ 1 }{ 1 }{ 1 }( end ) ];
            
            % Setup each of the synapses.
            for k = 1:num_unique_synapses               % Iterate through each of the unique synapses...
                
                % Set the names of each of the unique synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
                
                % Connect the unique synapses.
                self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for an closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
        function [ self, synapse_IDs_cell ] = create_clpc_dmcpg_dcll_synapses( self, neuron_IDs_cell )
            
            % Create the synapses for an open loop driven multistate cpg double centered lead lag error subnetwork synapses.
            [ self, synapse_IDs_oldmcpgdclle ] = self.create_ol_dmcpg_dclle_synapses( neuron_IDs_cell );
            
            % Create the synapses that assist in closing the open loop driven multistate cpg double centered lead lag error subnetwork using a proportional controller.
            [ self, synapse_IDs_oldmcpgdclle2dmcpg ] = self.create_oldmcpgdclle2dmcpg_synapses( neuron_IDs_cell );
            
            % Concatenate the synapse IDs.
            synapse_IDs_cell = { synapse_IDs_oldmcpgdclle, synapse_IDs_oldmcpgdclle2dmcpg };
            
        end
        
        
        % Implement a function to create the synapses for a transmission subnetwork.
        function [ self, synapse_ID ] = create_transmission_synapses( self, neuron_IDs )
            
            % Create the transmission subnetwork synapses.
            [ self, synapse_ID ] = self.create_synapses( self.num_transmission_synapses_DEFAULT );
            
            % Set the names of the transmission subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_ID, { 'Trans 12' }, 'name', synapses, set_flag );
            
            % Connect the transmission subnetwork synapses to the transmission subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapses for a modulation subnetwork.
        function [ self, synapse_ID ] = create_modulation_synapses( self, neuron_IDs )
            
            % Create the modulation subnetwork synapses.
            [ self, synapse_ID ] = self.create_synapses( self.num_modulation_synapses_DEFAULT );
            
            % Set the names of the modulation subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_ID, { 'Mod 12' }, 'name', synapses, set_flag );
            
            % Connect the modulation subnetwork synapses to the modulation subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapses for an addition subnetwork.
        function [ self, synapse_IDs ] = create_addition_synapses( self, neuron_IDs )
            
            % Create the addition subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_addition_synapses_DEFAULT );
            
            % Set the names of the addition subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Add 13', 'Add 23' }, 'name', synapses, set_flag );
            
            % Connect the addition subnetwork synapses to the addition subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for an absolute addition subnetwork.
        function [ self, synapse_IDs ] = create_absolute_addition_synapses( self, neuron_IDs )
            
            % Compute the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Compute the number of synapses.
            num_synapses_to_create = num_neurons - 1;
            
            % Create the absolute addition subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_synapses_to_create );
            
            % Setup each of the synapses.
            for k = 1:num_synapses_to_create                  % Iterate through each of the synapses...
                
                % Connect this synapse to its input and output neurons.
                self = self.connect_synapses( synapse_IDs( k ), neuron_IDs( k ), neuron_IDs( end ) );
                
                % Set the name of this synapse.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Absolute Addition Synapse %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ) }, 'name', synapses, set_flag );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a relative addition subnetwork.
        function [ self, synapse_IDs ] = create_relative_addition_synapses( self, neuron_IDs )
            
            % Compute the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Compute the number of synapses.
            num_synapses_to_create = num_neurons - 1;
            
            % Create the absolute addition subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_synapses_to_create );
            
            % Setup each of the synapses.
            for k = 1:num_synapses_to_create                  % Iterate through each of the synapses...
                
                % Connect this synapse to its input and output neurons.
                self = self.connect_synapses( synapse_IDs( k ), neuron_IDs( k ), neuron_IDs( end ) );
                
                % Set the name of this synapse.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Relative Addition Synapse %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ) }, 'name', synapses, set_flag );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a subtraction subnetwork.
        function [ self, synapse_IDs ] = create_subtraction_synapses( self, neuron_IDs )
            
            % Create the subtraction subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_subtraction_synapses_DEFAULT );
            
            % Set the names of the subtraction subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Sub 13', 'Sub 23' }, 'name', synapses, set_flag );
            
            % Connect the subtraction subnetwork synapses to the subtraction subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for an absolute subtraction subnetwork.
        function [ self, synapse_IDs ] = create_absolute_subtraction_synapses( self, neuron_IDs )
            
            % Compute the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Compute the number of synapses.
            num_synapses_to_create = num_neurons - 1;
            
            % Create the absolute subtraction subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_synapses_to_create );
            
            % Setup each of the synapses.
            for k = 1:num_synapses_to_create                  % Iterate through each of the synapses...
                
                % Connect this synapse to its input and output neurons.
                self = self.connect_synapses( synapse_IDs( k ), neuron_IDs( k ), neuron_IDs( end ) );
                
                % Set the name of this synapse.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Absolute Subtraction Synapse %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ) }, 'name', synapses, set_flag );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a relative subtraction subnetwork.
        function [ self, synapse_IDs ] = create_relative_subtraction_synapses( self, neuron_IDs )
            
            % Compute the number of neurons.
            num_neurons = length( neuron_IDs );
            
            % Compute the number of synapses.
            num_synapses_to_create = num_neurons - 1;
            
            % Create the relative subtraction subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_synapses_to_create );
            
            % Setup each of the synapses.
            for k = 1:num_synapses_to_create                  % Iterate through each of the synapses...
                
                % Connect this synapse to its input and output neurons.
                self = self.connect_synapses( synapse_IDs( k ), neuron_IDs( k ), neuron_IDs( end ) );
                
                % Set the name of this synapse.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Relative Subtraction Synapse %0.0f%0.0f', neuron_IDs( k ), neuron_IDs( end ) ) }, 'name', synapses, set_flag );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a double subtraction subnetwork.
        function [ self, synapse_IDs ] = create_double_subtraction_synapses( self, neuron_IDs )
            
            % Create the double subtraction subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_double_subtraction_synapses_DEFAULT );
            
            % Set the names of the double subtraction subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Sub 13', 'Sub 23', 'Sub 14', 'Sub 24' }, 'name', synapses, set_flag );
            
            % Connect the double subtraction subnetwork synapses to the subtraction subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) neuron_IDs( 4 ) neuron_IDs( 4 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a centering subnetwork.
        function [ self, synapse_IDs ] = create_centering_synapses( self, neuron_IDs )
            
            % Create the centering subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_centering_synapses_DEFAULT );
            
            % Set the names of the centering subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { '14', '24', '45', '35' }, 'name', synapses, set_flag );
            
            % Connect the centering subnetwork synapses.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 4 ) neuron_IDs( 3 ) ], [ neuron_IDs( 4 ) neuron_IDs( 4 ) neuron_IDs( 5 ) neuron_IDs( 5 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a double centering subnetwork.
        function [ self, synapse_IDs ] = create_double_centering_synapses( self, neuron_IDs )
            
            % Create the centering subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_double_centering_synapses_DEFAULT );
            
            % Set the names of the centering subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { '14', '24', '25', '35', '46', '36', '57', '17' }, 'name', synapses, set_flag );
            
            % Set the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 2 ) neuron_IDs( 3 ) neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 5 ) neuron_IDs( 1 ) ];
            to_neuron_IDs = [ neuron_IDs( 4 ) neuron_IDs( 4 ) neuron_IDs( 5 ) neuron_IDs( 5 ) neuron_IDs( 6 ) neuron_IDs( 6 ) neuron_IDs( 7 ) neuron_IDs( 7 ) ];
            
            % Connect the centering subnetwork synapses.
            self = self.connect_synapses( synapse_IDs, from_neuron_IDs, to_neuron_IDs );
            
        end
        
        
        % Implement a function to create the synapses that connect a double subtraction subnetwork to a double centering subnetwork.
        function [ self, synapse_IDs ] = create_ds2dc_synapses( self, neuron_IDs_cell )
            
            % Define the number of unique synapses.
            num_unique_synapses = 2;
            
            % Create the unique synapses.
            [ self, synapse_IDs ] = self.create_synapses( num_unique_synapses );
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs_cell{ 1 }( 3 ) neuron_IDs_cell{ 1 }( 4 ) ];
            to_neuron_IDs = [ neuron_IDs_cell{ 2 }( 1 ) neuron_IDs_cell{ 2 }( 3 ) ];
            
            % Setup each of the synapses.
            for k = 1:num_unique_synapses               % Iterate through each of the unique synapses...
                
                % Set the names of each of the unique synapses.
                [ synapses, self ] = self.set_synapse_property( synapse_IDs( k ), { sprintf( 'Neuron %0.0f -> Neuron %0.0f', from_neuron_IDs( k ), to_neuron_IDs( k ) ) }, 'name', synapses, set_flag );
                
                % Connect the unique synapses.
                self = self.connect_synapses( synapse_IDs( k ), from_neuron_IDs( k ), to_neuron_IDs( k ) );
                
            end
            
        end
        
        
        % Implement a function to create the synapses for a centered double subtraction subnetwork.
        function [ self, synapse_IDs_cell ] = create_centered_double_subtraction_synapses( self, neuron_IDs_cell )
            
            % Create the double subtraction subnetwork synapses.
            [ self, synapse_IDs_double_subtraction ] = self.create_double_subtraction_synapses( neuron_IDs_cell{ 1 } );
            
            % Create the double centering subnetwork synapses.
            [ self, synapse_IDs_double_centering ] = self.create_double_centering_synapses( neuron_IDs_cell{ 2 } );
            
            % Create the double subtraction subnetwork to double centering subnetwork synapses.
            [ self, synapse_IDs_ds2dc ] = self.create_ds2dc_synapses( neuron_IDs_cell );
            
            % Concatenate the synapse IDs.
            synapse_IDs_cell = { synapse_IDs_double_subtraction, synapse_IDs_double_centering, synapse_IDs_ds2dc };
            
        end
        
        
        % Implement a function to create the synapses for a multiplication subnetwork.
        function [ self, synapse_IDs ] = create_multiplication_synapses( self, neuron_IDs )
            
            % Create the multiplication subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_multiplication_synapses_DEFAULT );
            
            % Set the names of the multiplication subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Mult 14', 'Mult 23', 'Mult 34' }, 'name', synapses, set_flag );
            
            % Connect the multiplication subnetwork synapses to the multiplication subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 3 ) ], [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for an absolute multiplication subnetwork.
        function [ self, synapse_IDs ] = create_absolute_multiplication_synapses( self, neuron_IDs )
            
            % Create the multiplication subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_multiplication_synapses_DEFAULT );
            
            % Set the names of the multiplication subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Absolute Multiplication Synapse 14', 'Absolute Multiplication Synapse 23', 'Absolute Multiplication Synapse 34' }, 'name', synapses, set_flag );
            
            % Connect the multiplication subnetwork synapses to the multiplication subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 3 ) ], [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a relative multiplication subnetwork.
        function [ self, synapse_IDs ] = create_relative_multiplication_synapses( self, neuron_IDs )
            
            % Create the multiplication subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_multiplication_synapses_DEFAULT );
            
            % Set the names of the multiplication subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Relative Multiplication Synapse 14', 'Relative Multiplication Synapse 23', 'Relative Multiplication Synapse 34' }, 'name', synapses, set_flag );
            
            % Connect the multiplication subnetwork synapses to the multiplication subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 3 ) ], [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ] );
            
        end
        
        
        % Implement a function to create the synapse for an inversion subnetwork.
        function [ self, synapse_ID ] = create_inversion_synapse( self, neuron_IDs )
            
            % Create the inversion subnetwork synapses.
            [ self, synapse_ID ] = self.create_synapse( self.num_inversion_synapses_DEFAULT );
            
            % Set the name of the inversion subnetwork synapse.
            [ synapses, self ] = self.set_synapse_property( synapse_ID, { 'Inv 12' }, 'name', synapses, set_flag );
            
            % Connect the inversion subnetwork synapse to the inversion subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapse for an absolute inversion subnetwork.
        function [ self, synapse_ID ] = create_absolute_inversion_synapses( self, neuron_IDs )
            
            % Create the inversion subnetwork synapses.
            [ self, synapse_ID ] = self.create_synapse( self.num_inversion_synapses_DEFAULT );
            
            % Set the name of the inversion subnetwork synapse.
            [ synapses, self ] = self.set_synapse_property( synapse_ID, { 'Absolute Inversion Synapse 12' }, 'name', synapses, set_flag );
            
            % Connect the inversion subnetwork synapse to the inversion subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synapse for a relative inversion subnetwork.
        function [ self, synapse_ID ] = create_relative_inversion_synapses( self, neuron_IDs )
            
            % Create the inversion subnetwork synapses.
            [ self, synapse_ID ] = self.create_synapse( self.num_inversion_synapses_DEFAULT );
            
            % Set the name of the inversion subnetwork synapse.
            [ synapses, self ] = self.set_synapse_property( synapse_ID, { 'Relative Inversion Synapse 12' }, 'name', synapses, set_flag );
            
            % Connect the inversion subnetwork synapse to the inversion subnetwork neurons.
            self = self.connect_synapses( synapse_ID, neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
        end
        
        
        % Implement a function to create the synpases for a division subnetwork.
        function [ self, synapse_IDs ] = create_division_synapses( self, neuron_IDs )
            
            % Create the division subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_division_synapses_DEFAULT );
            
            % Set the names of the division subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Div 13', 'Div 23' }, 'name', synapses, set_flag );
            
            % Connect the division subnetwork synapses to the division subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synpases for an absolute division subnetwork.
        function [ self, synapse_IDs ] = create_absolute_division_synapses( self, neuron_IDs )
            
            % Create the division subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_division_synapses_DEFAULT );
            
            % Set the names of the division subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Absolute Division Synapse 13', 'Absolute Division Synapse 23' }, 'name', synapses, set_flag );
            
            % Connect the division subnetwork synapses to the division subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synpases for a relative division subnetwork.
        function [ self, synapse_IDs ] = create_relative_division_synapses( self, neuron_IDs )
            
            % Create the division subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_division_synapses_DEFAULT );
            
            % Set the names of the division subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Relative Division Synapse 13', 'Relative Division Synapse 23' }, 'name', synapses, set_flag );
            
            % Connect the division subnetwork synapses to the division subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synpases for a derivation subnetwork.
        function [ self, synapse_IDs ] = create_derivation_synapses( self, neuron_IDs )
            
            % Create the derivation subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_derivation_synapses_DEFAULT );
            
            % Set the names of the derivation subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Der 13', 'Der 23' }, 'name', synapses, set_flag );
            
            % Connect the derivation subnetwork synapses to the derivation subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for an integration subnetwork.
        function [ self, synapse_IDs ] = create_integration_synapses( self, neuron_IDs )
            
            % Create the integration subnetwork synapses.
            [ self, synapse_IDs ] = self.create_synapses( self.num_integration_synapses_DEFAULT );
            
            % Set the names of the integration subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Int 12', 'Int 21' }, 'name', synapses, set_flag );
            
            % Connect the integration subnetwork synapses to the integration subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) ], [ neuron_IDs( 2 ) neuron_IDs( 1 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a voltage based integration subnetwork.
        function [ self, synapse_IDs ] = create_vb_integration_synapses( self, neuron_IDs )
            
            % Create the voltage based integetration subnetwork synpases.
            [ self, synapse_IDs ] = self.create_synapses( self.num_vbi_synapses_DEFAULT );
            
            % Set the names of the voltage based integration subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Int 13', 'Int 23', 'Int 34', 'Int 43' }, 'name', synapses, set_flag );
            
            % Connect the voltage based integration subnetwork synapses to the integration subnetwrok neurons.
            self = self.connect_synapses( synapse_IDs, [ neuron_IDs( 1 ) neuron_IDs( 2 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ], [ neuron_IDs( 3 ) neuron_IDs( 3 ) neuron_IDs( 4 ) neuron_IDs( 3 ) ] );
            
        end
        
        
        % Implement a function to create the synapses for a split voltage based integration subnetwork.
        function [ self, synapse_IDs ] = create_split_vb_integration_synapses( self, neuron_IDs )
            
            % Create the voltage based integetration subnetwork synpases.
            [ self, synapse_IDs ] = self.create_synapses( self.num_svbi_synapses );
            
            % Set the names of the voltage based integration subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs, { 'Int 13', 'Int 23', 'Int 34', 'Int 43', 'Sub 13', 'Sub 23', 'Sub 14', 'Sub 24', 'Eq 1 -> Sub 2', 'Int 3 -> Sub 1' }, 'name', synapses, set_flag );
            
            % Define the from and to neuron IDs.  NOTE: Neuron IDs are in this order: { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1' }
            from_neuron_IDs = [ neuron_IDs( 1:4 ) neuron_IDs( 5:6 ) neuron_IDs( 5:6 ) neuron_IDs( 9 ) neuron_IDs( 3 ) ];
            to_neuron_IDs = [ neuron_IDs( 3 ) neuron_IDs( 3 ) neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 7 ) neuron_IDs( 7 ) neuron_IDs( 8 ) neuron_IDs( 8 ) neuron_IDs( 6 ) neuron_IDs( 5 ) ];
            
            % Connect the voltage based integration subnetwork synapses to the integration subnetwork neurons.
            self = self.connect_synapses( synapse_IDs, from_neuron_IDs, to_neuron_IDs );
            
        end
        
        
        % Implement a function to create the synapses for a modulated split voltage based integration subnetwork.
        function [ self, synapse_IDs ] = create_mod_split_vb_integration_synapses( self, neuron_IDs )
            
            % Create the split voltage based integration subnetwork synapses.
            [ self, synapse_IDs1 ] = self.create_split_vb_integration_synapses( neuron_IDs( 1:9 ) );
            
            % Create the synapses that are unique to the modulated split voltage based integration subnetwork.
            [ self, synapse_IDs2 ] = self.create_synapses( self.num_msvbi_synapses );
            
            % Set the names of the modulated split voltage based integration subnetwork synapses.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs2, { 'Sub 3 -> Mod 2', 'Sub 4 -> Mod 3', 'Mod 1 -> Mod 2', 'Mod 1 -> Mod 3', 'Int 1 -> Mod 1', 'Int 2 -> Mod 1' }, 'name', synapses, set_flag );
            
            % Define the from and to neuron IDs. NOTE: Neurons are organized as follows: { 'Int 1', 'Int 2', 'Int 3', 'Int 4' 'Sub 1', 'Sub 2', 'Sub 3', 'Sub 4', 'Eq 1', 'Mod 1', 'Mod 2', 'Mod 3' }
            from_neuron_IDs = [ neuron_IDs( 7 ) neuron_IDs( 8 ) neuron_IDs( 10 ) neuron_IDs( 10 ) neuron_IDs( 1 ) neuron_IDs( 2 ) ];
            to_neuron_IDs = [ neuron_IDs( 11 ) neuron_IDs( 12 ) neuron_IDs( 11 ) neuron_IDs( 12 ) neuron_IDs( 10 ) neuron_IDs( 10 ) ];
            
            % Connect the modulated split voltage based integration subnetwork synapses.
            self = self.connect_synapses( synapse_IDs2, from_neuron_IDs, to_neuron_IDs );
            
            % Concatenate the synapse IDs.
            synapse_IDs = [ synapse_IDs1, synapse_IDs2 ];
            
        end
        
        
        % Implement a function to create the synapses for a modulated split difference voltage based integration subnetwork.
        function [ self, synapse_IDs ] = create_mod_split_sub_vb_integration_synapses( self, neuron_IDs )
            
            % Create the double subtraction subnetwork synapses.
            [ self, synapse_IDs1 ] = self.create_double_subtraction_synapses( neuron_IDs( 1:4 ) );
            
            % Create the modulated split voltage based integration subnetwork synapses.
            [ self, synapse_IDs2 ] = self.create_mod_split_vb_integration_synapses( neuron_IDs( 5:end ) );
            
            % Create the synapses unique to this subnetwork.
            [ self, synapse_IDs3 ] = self.create_synapses( self.num_mssvbi_synapses );
            
            % Set the names of the synapses that are unique to this subnetwork.
            [ synapses, self ] = self.set_synapse_property( synapse_IDs3, { 'Sub 3 -> Int 1', 'Sub 4 -> Int 2' }, 'name', synapses, set_flag );
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = [ neuron_IDs( 3 ) neuron_IDs( 4 ) ];
            to_neuron_IDs = [ neuron_IDs( 5 ) neuron_IDs( 6 ) ];
            
            % Connect the synapses that are unique to this subnetwork.
            self = self.connect_synapses( synapse_IDs3, from_neuron_IDs, to_neuron_IDs );
            
            % Concatenate the synapse IDs.
            synapse_IDs = [ synapse_IDs1, synapse_IDs2, synapse_IDs3 ];
            
        end
        
        
        %% Subnetwork Synapse Design Functions
        
        % Implement a function to design the synapses for a multistate cpg subnetwork.
        function self = design_multistate_cpg_synapses( self, neuron_IDs, delta_oscillatory, delta_bistable )
            
            % Set the default input arguments.
            if nargin < 4, delta_bistable = self.delta_bistable_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end
            
            % Set the synapse delta values.
            self = self.compute_set_cpg_deltas( neuron_IDs, delta_oscillatory, delta_bistable );
            
        end
        
        
        % Implement a function to design the synapses for a driven multistate cpg subnetwork.
        function self = design_driven_multistate_cpg_synapses( self, neuron_IDs, delta_oscillatory, I_drive_max )
            
            % Set the default input arguments.
            if nargin < 4, I_drive_max = self.Id_max_DEFAULT; end
            if nargin < 3, delta_oscillatory = self.delta_oscillatory_DEFAULT; end
            
            % Retrieve the number of cpg neurons.
            num_cpg_neurons = length( neuron_IDs ) - 1;
            
            % Define the from and to neuron IDs.
            from_neuron_IDs = neuron_IDs( end )*ones( 1, num_cpg_neurons );
            to_neuron_IDs = neuron_IDs( 1:( end - 1 ) );
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs, synapses, undetected_option );
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_dmcpg_dEs( synapse_IDs );
            
            % Compute and set the maximum synaptic conductances.
            self = self.compute_set_driven_multistate_cpg_gsynmax( synapse_IDs, delta_oscillatory, I_drive_max );
            
        end
        
        
        % Implement a function to design the synapses for a transmission subnetwork.
        function [ self, synapse_ID ] = design_transmission_synapse( self, neuron_IDs )
            
            % Retrieve the synapse ID associated with the transmission neurons.
            synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_transmission_dEs( synapse_ID );
            
        end
        
        
        % Implement a function to design the synapses for a modulation subnetwork.
        function [ self, synapse_ID ] = design_modulation_synapse( self, neuron_IDs )
            
            % Retrieve the synapse ID associated with the transmission neurons.
            synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_modulation_dEs( synapse_ID );
            
        end
        
        
        % Implement a function to design the synapses for an addition subnetwork.
        function [ self, synapse_IDs ] = design_addition_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_addition_dEs1( synapse_IDs( 1 ) );
            self = self.compute_set_addition_dEsyn2( synapse_IDs( 2 ) );
            
        end
        
        
        % Implement a function to design the synapses for an absolute addition subnetwork.
        function [ self, synapse_IDs ] = design_absolute_addition_synapses( self, neuron_IDs, c, R_ks, Gm_n, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 6, Iapp_n = self.Ia_absolute_addition_DEFAULT; end
            if nargin < 5, Gm_n = self.Gm_DEFAULT; end
            if nargin < 4, R_ks = self.R_DEFAULT*ones( 1, length( neuron_IDs ) - 1 ); end
            if nargin < 3, c = self.c_absolute_addition_DEFAULT; end
            
            % Compute the number of synapses.
            num_synapses_to_create = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_create );
            
            % Create each of the synapses.
            for k = 1:num_synapses_to_create                    % Iterate through each of the synapses...
                
                % Retrieve the ID associated with this synapse.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
                % Compute and set the absolute addition synaptic reversal potential.
                self = self.compute_addition_dEs( synapse_IDs( k ) );
                
                % Compute and set the absolute addition maximum synaptic conductance.
                self = self.compute_set_absolute_addition_gsyn( synapse_IDs( k ), c, R_ks( k ), Gm_n, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a relative addition subnetwork.
        function [ self, synapse_IDs ] = design_relative_addition_synapses( self, neuron_IDs, c, n, R_n, Gm_n, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 7, Iapp_n = self.Ia_relative_addition_DEFAULT; end                                        % [A] Output Applied Current
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
            if nargin < 5, R_n = self.R_DEFAULT; end                                                                % [V] Output Activation Domain
            if nargin < 4, n = self.num_relative_addition_neurons_DEFAULT; end                                              % [#] Number of Addition Neurons
            if nargin < 3, c = self.c_relative_addition_DEFAULT; end                                                % [-] Addition Subnetwork Gain
            
            % Compute the number of synapses.
            num_synapses_to_create = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_create );
            
            % Create each of the synapses.
            for k = 1:num_synapses_to_create                    % Iterate through each of the synapses...
                
                % Retrieve the ID associated with this synapse.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
                % Compute and set the relative addition synaptic reversal potential.
                self = self.compute_set_relative_addition_dEsyn( synapse_IDs( k ) );
                
                % Compute and set the relative addition maximum synaptic conductance.
                self = self.compute_set_relative_addition_gsyn( synapse_IDs( k ), c, n, R_n, Gm_n, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a subtraction subnetwork.
        function [ self, synapse_IDs ] = design_subtraction_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_subtraction_dEs1( synapse_IDs( 1 ) );
            self = self.compute_set_subtraction_dEsyn2( synapse_IDs( 2 ) );
            
        end
        
        
        % Implement a function to design the synapses for an absolute subtraction subnetwork.
        function [ self, synapse_IDs ] = design_absolute_subtraction_synapses( self, neuron_IDs, c, s_ks, R_ks, Gm_n, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 7, Iapp_n = self.Ia_absolute_subtraction_DEFAULT; end                                     % [A] Output Applied Current
            if nargin < 6, Gm_n = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
            if nargin < 5, R_ks = self.R_DEFAULT*ones( 1, length( neuron_IDs ) - 1 ); end                           % [-] Input Activation Domains
            if nargin < 4, s_ks = [ 1, -1 ]; end                                                                    % [-] Input Excitatory / Inhibitory Signs
            if nargin < 3, c = self.c_DEFAULT; end                                                                  % [-] Subtraction Subnetwork Gain
            
            % Compute the number of synapses.
            num_synapses_to_create = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_create );
            
            % Create each of the synapses.
            for k = 1:num_synapses_to_create                    % Iterate through each of the synapses...
                
                % Retrieve the ID associated with this synapse.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
                % Determine how to compute the synaptic reversal potential.
                if s_ks( k ) == 1                                                                                   % If this is an excitatory synapse...
                    
                    % Compute and set the absolute subtraction synaptic reversal potential for an excitatory synapse.
                    self = self.compute_subtraction_dEs_excitatory( synapse_IDs( k ) );
                    
                elseif s_ks( k ) == -1                                                                              % If this is an inhibitory synapse...
                    
                    % Compute and set the absolute subtraction synaptic reversal potential for an inhibitory synapse.
                    self = self.compute_subtraction_dEs_inhibitory( synapse_IDs( k ) );
                    
                else                                                                                                % Otherwise... (The synaptic type (excitatory / inhibitory) is undefined...
                    
                    % Throw an error.
                    error( 'The excitatory / inhibitory nature of this synapse can not be determined.' )
                    
                end
                
                % Compute and set the absolute subtraction maximum synaptic gain.
                self = self.compute_set_absolute_subtraction_gsyn( synapse_IDs( k ), c, s_ks( k ), R_ks( k ), Gm_n, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a relative subtraction subnetwork.
        function [ self, synapse_IDs ] = design_relative_subtraction_synapses( self, neuron_IDs, c, npm_k, s_ks, R_n, Gm_n, Iapp_n )
            
            % Define the default input arguments.
            if nargin < 8, Iapp_n = self.Ia_relative_subtraction_DEFAULT; end                                     % [A] Output Applied Current
            if nargin < 7, Gm_n = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
            if nargin < 6, R_n = self.R_DEFAULT; end                                                                % [V] Output Activation Domain
            if nargin < 5, s_ks = [ 1, -1 ]; end                                                                    % [-] Input Excitatory / Inhibitory Sign
            if nargin < 4, npm_k = [ 1, 1 ]; end                                                                    % [#] Number of Excitatory / Inhibitory Inputs
            if nargin < 3, c = self.c_DEFAULT; end                                                                  % [-] Subtraction Subnetwork Gain
            
            % Compute the number of synapses.
            num_synapses_to_create = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the synapse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_create );
            
            % Create each of the synapses.
            for k = 1:num_synapses_to_create                                                                        % Iterate through each of the synapses...
                
                % Retrieve the ID associated with this synapse.
                synapse_IDs( k ) = self.from_to_neuron_ID2synapse_ID( neuron_IDs( k ), neuron_IDs( end ) );
                
                % Determine how to compute the synaptic reversal potential.
                if s_ks( k ) == 1                                                                                   % If this is an excitatory synapse...
                    
                    % Compute and set the relative subtraction synaptic reversal potential for an excitatory synapse.
                    self = self.compute_set_relative_subtraction_dEsyn_excitatory( synapse_IDs( k ) );
                    
                    % Set the number of relavent input neurons to be those with excitatory connections to the output neuron.
                    n = npm_k( 1 );
                    
                elseif s_ks( k ) == -1                                                                              % If this is an inhibitory synapse...
                    
                    % Compute and set the relative subtraction synaptic reversal potential for an inhibitory synapse.
                    self = self.compute_set_relative_subtraction_dEsyn_inhibitory( synapse_IDs( k ) );
                    
                    % Set the number of relavent input neurons to be those with inhibitory connections to the output neuron.
                    n = npm_k( 2 );
                    
                else                                                                                                % Otherwise... (The synaptic type (excitatory / inhibitory) is undefined...
                    
                    % Throw an error.
                    error( 'The excitatory / inhibitory nature of this synapse can not be determined.' )
                    
                end
                
                % Compute and set the relative subtraction maximum synaptic gain.
                self = self.compute_set_relative_subtraction_gsyn( synapse_IDs( k ), c, n, s_ks( k ), R_n, Gm_n, Iapp_n );
                
            end
            
        end
        
        
        % Implement a function to design the synapses for a multiplication subnetwork.
        function [ self, synapse_IDs ] = design_multiplication_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that comprise this multiplication subnetwork.
            synapse_IDs = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1:3 ), [ neuron_IDs( 4 ) neuron_IDs( 3 ) neuron_IDs( 4 ) ], synapses, undetected_option );
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_multiplication_dEs1( synapse_IDs( 1 ) );
            self = self.compute_multiplication_dEs2( synapse_IDs( 2 ) );
            self = self.compute_multiplication_dEs3( synapse_IDs( 3 ) );
            
        end
        
        
        % Implement a function to design the synapses for an absolute multiplication subnetwork.
        function [ self, synapse_IDs ] = design_absolute_multiplication_synapses( self, neuron_IDs, c1, c2, alpha, epsilon1, epsilon2, R_1, R_2, R_3, Gm_3, Gm_4, Iapp_3 )
            
            % Define the default input arugments.
            if nargin < 13, Iapp_3 = self.Ia2_absolute_inversion_DEFAULT; end                                     % [A] Inversion Output Applied Current
            if nargin < 12, Gm_4 = self.Gm_DEFAULT; end                                                             % [S] Division Output Membrane Conductance
            if nargin < 11, Gm_3 = self.Gm_DEFAULT; end                                                             % [S] Inversion Output Membrane Conductance
            if nargin < 10, R_3 = self.R_DEFAULT; end                                                                % [V] Inversion Output Activation Domain
            if nargin < 9, R_2 = self.R_DEFAULT; end                                                                % [V] Inversion Input Activation Domain
            if nargin < 8, R_1 = self.R_DEFAULT; end                                                                % [V] Division Input Activation Domain
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                                     % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                                     % [-] Inversion Subnetwork Offset
            if nargin < 5, alpha = self.alpha_DEFAULT; end                                                          % [-] Division Subnetwork Denominator Adjustment
            if nargin < 4, c2 = self.c_absolute_division_DEFAULT; end                                               % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_absolute_inversion_DEFAULT; end                                              % [-] Inversion Subnetwork Gain
            
            % Design the absolute inversion subnetwork synapse.
            [ self, synapse_ID_inversion ] = self.design_absolute_inversion_synapse( neuron_IDs( 2:3 ), c1, epsilon1, R_2, Gm_3, Iapp_3 );
            
            % Design the absolute division subnetwork synpases.
            [ self, synapse_IDs_division ] = self.design_absolute_division_synapses( neuron_IDs( [ 1, 3, 4 ] ), c2, alpha, epsilon2, R_1, R_3, Gm_4 );
            
            % Concatenate the synapse IDs.
            synapse_IDs = [ synapse_ID_inversion, synapse_IDs_division ];
            
        end
        
        
        % Implement a function to design the synapses for a relative multiplication subnetwork.
        function [ self, synapse_IDs ] = design_relative_multiplication_synapses( self, neuron_IDs, c1, c2, alpha, epsilon1, epsilon2, R_3, R_4, Gm_3, Gm_4, Iapp_3 )
            
            % Define the default input arguments.
            if nargin < 12, Iapp_3 = self.Ia2_relative_inversion_DEFAULT; end                                     % [A] Inversion Output Applied Current
            if nargin < 11, Gm_4 = self.Gm_DEFAULT; end                                                             % [S] Division Output Membrane Conductance
            if nargin < 10, Gm_3 = self.Gm_DEFAULT; end                                                              % [S] Inversion Output Membrane Conductance
            if nargin < 9, R_4 = self.R_DEFAULT; end                                                                % [V] Division Output Activation Domain
            if nargin < 8, R_3 = self.R_DEFAULT; end                                                                % [V] Inversion Output Activation Domain
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                                                     % [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                                                     % [-] Inversion Subnetwork Offset
            if nargin < 5, alpha = self.alpha_DEFAULT; end
            if nargin < 4, c2 = self.c_relative_division_DEFAULT; end                                               % [-] Division Subnetwork Gain
            if nargin < 3, c1 = self.c_relative_inversion_DEFAULT; end                                              % [-] Inversion Subnetwork Gain
            
            % Design the relative inversion subnetwork synapse.
            [ self, synapse_ID_inversion ] = self.design_relative_inversion_synapse( neuron_IDs( 2:3 ), c1, epsilon1, R_3, Gm_3, Iapp_3 );
            
            % Design the relative division subnetwork synpases.
            [ self, synapse_IDs_division ] = self.design_relative_division_synapses( neuron_IDs( [ 1, 3, 4 ] ), c2, alpha, epsilon2, R_4, Gm_4 );
            
            % Concatenate the synapse IDs.
            synapse_IDs = [ synapse_ID_inversion, synapse_IDs_division ];
            
        end
        
        
        % Implement a function to design the synapses for an inversion subnetwork.
        function [ self, synapse_ID ] = design_inversion_synapse( self, neuron_IDs )
            
            % Get the synapse ID that connects the first neuron to the second neuron.
            synapse_ID = self.from_to_neuron_IDs2synapse_IDs( neuron_IDs( 1 ), neuron_IDs( 2 ), synapses, undetected_option );
            
            % Compute and set the synapse reversal potential.
            self = self.compute_inversion_dEs( synapse_ID );
            
        end
        
        
        %         % Implement a function to design the synapses for an absolute inversion subnetwork.
        %         function [ self, synapse_ID ] = design_absolute_inversion_synapse( self, neuron_IDs, c, epsilon, R_1, Gm_2, Iapp_2 )
        %
        %             % Define the default input arguments.
        %             if nargin < 7, Iapp_2 = self.Ia2_absolute_inversion_DEFAULT; end                                      % [A] Output Applied Current
        %             if nargin < 6, Gm_2 = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
        %             if nargin < 5, R_1 = self.R_DEFAULT; end                                                                % [V] Input Activation Domain
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                      % [-] Inversion Subnetwork Offset
        %             if nargin < 3, c = self.c_DEFAULT; end                                                                  % [-] Inversion Subnetwork Gain
        %
        %             % Retrieve the ID associated with this synapse.
        %             synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
        %
        %             % Compute and set the synaptic reversal potential of the absolute inversion synapse.
        % %             self = self.compute_set_absolute_inversion_dEsyn( synapse_ID );
        %             self = self.compute_set_absolute_inversion_dEsyn( synapse_IDs, epsilon, delta );
        %
        %             % Compute and set the synaptic reversal potential of the absolute inversion synapse.
        % %             self = self.compute_set_absolute_inversion_gsyn( synapse_ID, c, epsilon, R_1, Gm_2, Iapp_2 );
        %             self = self.compute_set_absolute_inversion_gsyn( synapse_IDs, Iapp_2 );
        %
        %         end
        
        
        % Implement a function to design the synapses for an absolute inversion subnetwork.
        function [ self, synapse_ID ] = design_absolute_inversion_synapse( self, neuron_IDs, c, delta, Iapp_2 )
            
            % Define the default input arguments.
            if nargin < 5, Iapp_2 = self.Ia2_absolute_inversion_DEFAULT; end                                      % [A] Output Applied Current
            if nargin < 4, delta = self.delta_DEFAULT; end                                                          % [V] Inversion Subnetwork Output Offset
            if nargin < 3, c = self.c_absolute_inversion_DEFAULT; end                                            	% [-] Inversion Subnetwork Gain
            
            % Retrieve the ID associated with this synapse.
            synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
            % Compute and set the synaptic reversal potential of the absolute inversion synapse.
            self = self.compute_set_absolute_inversion_dEsyn( synapse_ID, c, delta );
            
            % Compute and set the synaptic reversal potential of the absolute inversion synapse.
            self = self.compute_set_absolute_inversion_gsyn( synapse_ID, Iapp_2 );
            
        end
        
        
        %         % Implement a function to design the synapses for a relative inversion subnetwork.
        %         function [ self, synapse_ID ] = design_relative_inversion_synapse( self, neuron_IDs, c, epsilon, R_2, Gm_2, Iapp_2 )
        %
        %             % Define the default input arguments.
        %             if nargin < 7, Iapp_2 = self.Ia2_relative_inversion_DEFAULT; end                                      % [A] Output Applied Current
        %             if nargin < 6, Gm_2 = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
        %             if nargin < 5, R_2 = self.R_DEFAULT; end                                                                % [V] Output Activation Domain
        %             if nargin < 4, epsilon = self.epsilon_DEFAULT; end                                                      % [-] Inversion Subnetwork Offset
        %             if nargin < 3, c = self.c_DEFAULT; end                                                                  % [-] Inversion Subnetwork Gain
        %
        %             % Retrieve the ID associated with this synapse.
        %             synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
        %
        %             % Compute and set the synaptic reversal potential of the absolute inversion synapse.
        %             self = self.compute_set_relative_inversion_dEsyn( synapse_ID );
        %
        %             % Compute and set the synaptic reversal potential of the absolute inversion synapse.
        %             self = self.compute_set_relative_inversion_gsyn( synapse_ID, c, epsilon, R_2, Gm_2, Iapp_2 );
        %
        %         end
        
        
        % Implement a function to design the synapses for a relative inversion subnetwork.
        function [ self, synapse_ID ] = design_relative_inversion_synapse( self, neuron_IDs, epsilon, delta, R_2, Iapp_2 )
            
            % Define the default input arguments.
            if nargin < 6, Iapp_2 = self.Ia2_relative_inversion_DEFAULT; end                                      % [A] Output Applied Current
            if nargin < 5, R_2 = self.R_DEFAULT; end                                                                % [V] Activation Domain
            if nargin < 4, delta = self.delta_DEFAULT; end                                                          % [V] Inversion Subnetwork Output Offset
            if nargin < 3, epsilon = self.epsilon_DEFAULT; end                                                      % [V] Inversion Subnetwork Input Offset
            
            % Retrieve the ID associated with this synapse.
            synapse_ID = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            
            % Compute and set the synaptic reversal potential of the absolute inversion synapse.
            self = self.compute_set_relative_inversion_dEsyn( synapse_ID, epsilon, delta, R_2 );
            
            % Compute and set the synaptic reversal potential of the absolute inversion synapse.
            self = self.compute_set_relative_inversion_gsyn( synapse_ID, Iapp_2 );
            
        end
        
        
        % Implement a function to design the synapses for a division subnetwork.
        function [ self, synapse_IDs ] = design_division_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_division_dEs1( synapse_IDs( 1 ) );
            self = self.compute_division_dEs2( synapse_IDs( 2 ) );
            
        end
        
        
        % Implement a function to design the synapses for an absolute division subnetwork.
        function [ self, synapse_IDs ] = design_absolute_division_synapses( self, neuron_IDs, c, alpha, epsilon, R_1, R_2, Gm_3 )
            
            % Define the default input arguments.
            if nargin < 8, Gm_3 = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
            if nargin < 7, R_2 = self.R_DEFAULT; end                                                                % [V] Second Input Activation Domain
            if nargin < 6, R_1 = self.R_DEFAULT; end                                                                % [V] First Input Activation Domain
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                                                      % [-] Division Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end                                                          % [-] Division Subnetwork Denominator Adjustment
            if nargin < 3, c = self.c_absolute_division_DEFAULT; end                                                % [-] Division Subnetwork Gain
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential of the numerator absolute division synapse.
            self = self.compute_set_absolute_division_dEsyn1( synapse_IDs, c, alpha );
            
            % Compute and set the synaptic reversal potential of the denominator absolute division synapse.
            self = self.compute_set_absolute_division_dEsyn2( synapse_IDs );
            
            % Compute and set the maximum synaptic gain of the numerator absolute division synapse.
            self = self.compute_set_absolute_division_gsyn31( synapse_IDs, alpha, epsilon, R_1, Gm_3 );
            
            % Compute and set the maximum synaptic gain of the denominator absolute division synapse.
            self = self.compute_set_absolute_division_gsyn32( synapse_IDs, epsilon, R_2, Gm_3 );
            
        end
        
        
        % Implement a function to design the synapses for a relative division subnetwork.
        function [ self, synapse_IDs ] = design_relative_division_synapses( self, neuron_IDs, c, alpha, epsilon, R_3, Gm_3 )
            
            % Define the default input arguments.
            if nargin < 7, Gm_3 = self.Gm_DEFAULT; end                                                              % [S] Output Membrane Conductance
            if nargin < 6, R_3 = self.R_DEFAULT; end                                                                % [V] Output Activation Domain
            if nargin < 5, epsilon = self.epsilon_DEFAULT; end                                                      % [-] Inversion Subnetwork Offset
            if nargin < 4, alpha = self.alpha_DEFAULT; end
            if nargin < 3, c = self.c_relative_division_DEFAULT; end                                                % [-] Inversion Subnetwork Gain
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential of the numerator relative division synapse.
            self = self.compute_set_relative_division_dEsyn1( synapse_IDs, c, alpha );
            
            % Compute and set the synaptic reversal potential of the denominator relative division synapse.
            self = self.compute_set_relative_division_dEsyn2( synapse_IDs );
            
            % Compute and set the maximum synaptic gain of the numerator relative division synapse.
            self = self.compute_set_relative_division_gsyn31( synapse_IDs, R_3, Gm_3 );
            
            % Compute and set the maximum synaptic gain of the denominator relative division synapse.
            self = self.compute_set_relative_division_gsyn32( synapse_IDs, c, alpha, epsilon, R_3, Gm_3 );
            
        end
        
        
        % Implement a function to design the synapses for a derivation subnetwork.
        function [ self, synapse_IDs ] = design_derivation_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_derivation_dEs1( synapse_IDs( 1 ) );
            self = self.compute_derivation_dEs2( synapse_IDs( 2 ) );
            
        end
        
        
        % Implement a function to design the synapses for an integration subnetwork.
        function [ self, synapse_IDs ] = design_integration_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID12 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 2 ) );
            synapse_ID21 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 1 ) );
            synapse_IDs = [ synapse_ID12 synapse_ID21 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_integration_dEs1( synapse_IDs( 1 ) );
            self = self.compute_integration_dEs2( synapse_IDs( 2 ) );
            
        end
        
        
        % Implement a function to design the synapses for a voltage based integration subnetwork.
        function [ self, synapse_IDs ] = design_vb_integration_synapses( self, neuron_IDs )
            
            % Get the synapse IDs that connect the first two neurons to the third neuron.
            synapse_ID13 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 1 ), neuron_IDs( 3 ) );
            synapse_ID23 = self.from_to_neuron_ID2synapse_ID( neuron_IDs( 2 ), neuron_IDs( 3 ) );
            synapse_IDs = [ synapse_ID13 synapse_ID23 ];
            
            % Compute and set the synaptic reversal potential.
            self = self.compute_vbi_dEs1( synapse_IDs( 1 ) );
            self = self.compute_vbi_dEs2( synapse_IDs( 2 ) );
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save synapse manager data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load synapse manager data as a matlab object.
        function self = load( ~, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Synapse_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load synapse from a xlsx data.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
            
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Synapse_Data.xlsx'; end
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING SYNAPSE DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic
            
            % Load the synapse data.
            [ synapse_IDs, synapse_names, synapse_dEsyns, synapse_gsyn_maxs, synapse_from_neuron_IDs, synapse_to_neuron_IDs ] = self.data_loader_utilities.load_synapse_data( file_name, directory );
            
            % Define the number of synapses.
            num_synapses_to_load = length( synapse_IDs );
            
            % Preallocate an array of synapses.
            synapses_to_load = repmat( synapse_class(  ), 1, num_synapses_to_load );
            
            % Create each synapse object.
            for k = 1:num_synapses_to_load               % Iterate through each of the synapses...
                
                % Create this synapse.
                synapses_to_load( k ) = synapse_class( synapse_IDs( k ), synapse_names{k}, synapse_dEsyns( k ), synapse_gsyn_maxs( k ), synapse_from_neuron_IDs( k ), synapse_to_neuron_IDs( k ) );
                
            end
            
            % Determine whether to append the synapses we just loaded.
            if b_append                         % If we want to append the synapses we just loaded...
                
                % Append the synapses we just loaded to the array of existing synapses.
                self.synapses = [ self.synapses, synapses_to_load ];
                
                % Update the number of synapses.
                self.num_synapses = length( self.synapses );
                
            else                                % Otherwise...
                
                % Replace the existing synapses with the synapses we just loaded.
                self.synapses = synapses_to_load;
                
                % Update the number of synapses.
                self.num_synapses = length( self.synapses );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING SYNAPSE DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        
    end
end

