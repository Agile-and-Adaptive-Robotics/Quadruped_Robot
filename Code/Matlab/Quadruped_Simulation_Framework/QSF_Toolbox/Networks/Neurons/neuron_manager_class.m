classdef neuron_manager_class
    
    % This class contains properties and methods related to managiing neurons.
    
    %% NEURON MANAGER PROPERTIES
    
    % Define general class properties.
    properties
        
        neurons                                                                 % [class] Neurons Class.               
        num_neurons                                                             % [#] Number of Neurons.
        
        array_utilities                                                         % [class] Array Utilities Class.
        data_loader_utilities                                                   % [class] Data Loader Utilities.
        neuron_utilities                                                        % [class] Neuron Utilities.
        
    end
    
    
    % Define private, constant class properties.
    properties ( Access = private, Constant = true )
        
        % Define the neuron parameters.
        Cm_DEFAULT = 5e-9;                                                   	% [C] Membrane Capacitance
        Gm_DEFAULT = 1e-6;                                                   	% [S] Membrane Conductance
        Er_DEFAULT = -60e-3;                                                  	% [V] Equilibrium Voltage
        R_DEFAULT = 20e-3;                                                      % [V] Activation Domain
        Am_DEFAULT = 1;                                                       	% [-] Sodium Channel Activation Parameter Amplitude
        Sm_DEFAULT = -50;                                                     	% [-] Sodium Channel Activation Parameter Slope
        dEm_DEFAULT = 40e-3;                                                   	% [V] Sodium Channel Activation Reversal Potential
        Ah_DEFAULT = 0.5;                                                     	% [-] Sodium Channel Deactivation Parameter Amplitude
        Sh_DEFAULT = 50;                                                      	% [-] Sodium Channel Deactivation Parameter Slope
        dEh_DEFAULT = 0;                                                      	% [V] Sodium Channel Deactivation Reversal Potential
        dEna_DEFAULT = 110e-3;                                                	% [V] Sodium Channel Reversal Potential
        tauh_max_DEFAULT = 0.25;                                               	% [s] Maximum Sodium Channel Steady State Time Constant
        Gna_DEFAULT = 1e-6;                                                   	% [S] Sodium Channel Conductance
        Ileak_DEFAULT = 0;                                                      % [A] Leak Current
        Isyn_DEFAULT = 0;                                                     	% [A] Synaptic Current
        Ina_DEFAULT = 0;                                                     	% [A] Sodium Channel Current
        Itonic_DEFAULT = 0;                                                  	% [A] Tonic Current
        Iapp_DEFAULT = 0;                                                      	% [A] Applied Current
        Itotal_DEFAULT = 0;                                                  	% [A] Total Current
        
        % Define the default sizes of the original FSA subnetworks.
        num_transmission_neurons_DEFAULT = 2;                                   % [#] Number of Transmission Neurons.
        num_modulation_neurons_DEFAULT = 2;                                     % [#] Number of Modulation Neurons.
        num_inversion_neurons_DEFAULT = 2;                                      % [#] Number of Inversion Neurons.
        num_addition_neurons_DEFAULT = 3;                                     	% [#] Number of Addition Neurons.
        num_subtraction_neurons_DEFAULT = 3;                                  	% [#] Number of Subtraction Neurons.
        num_division_neurons_DEFAULT = 3;                                    	% [#] Number of Division Neurons.
        num_multiplication_neurons_DEFAULT = 4;                               	% [#] Number of Multiplication Neurons.
        num_derivation_neurons_DEFAULT = 3;                                  	% [#] Number of Derivation Neurons.
        num_integration_neurons_DEFAULT = 2;                                  	% [#] Number of Integration Neurons.
        
        % Define the default sizes of custom FSA toolbox subnetworks.
        num_cpg_neurons_DEFAULT = 2;                                          	% [#] Number of CPG Neurons.
        num_dcpg_neurons_DEFAULT = 3;
        num_double_subtraction_neurons_DEFAULT = 4;                         	% [#] Number of Double Subtraction Neurons.
        num_centering_neurons_DEFAULT = 5;                                    	% [#] Number of Centering Neurons.
        num_double_centering_neurons_DEFAULT = 7;                            	% [#] Number of Double Centering Neurons.
        num_cds_neurons_DEFAULT = 11;
        num_dmcpgdcll2cds_neurons_DEFAULT = 1;
        num_vbi_neurons_DEFAULT = 4;                                         	% [#] Number of Voltage Based Integration Neurons.
        num_svbi_neurons_DEFAULT = 9;                                         	% [#] Number of Split Voltage Based Integration Neurons.
        num_new_msvbi_neurons_DEFAULT = 3;
        num_msvbi_neurons_DEFAULT = 3;                                      	% [#] Number of Unique Modualted Split Voltage Based Integration Neurons.
        num_mssvbi_neurons_DEFAULT = 16;                                      	% [#] Total Number of Modualted Split Subtraction Voltage Based Integration Neurons.
        num_sll_neurons_DEFAULT = 4;                                         	% [#] Number of Split Lead Lag Neurons.
        
        % Define subtraction subnetwork parameters.
        s_ks_DEFAULT = [ 1, -1 ];                                            	% [-] Subtraction Input Signature.
        
        % Define inversion subnetwork parameters.
        c_inversion_DEFAULT = 1;                                             	% [-] Inversion Subnetwork Gain.
        epsilon_inversion_DEFAULT = 1e-6;                                     	% [V] Inversion Subnetwork Input Offset.
        delta_inversion_DEFAULT = 1e-6;                                       	% [V] Inversion Subnetwork Output Offset.
        
        % Define division subnetwork parameters.
        c_division_DEFAULT = 1;                                               	% [-] Division Subnetwork Gain.
        epsilon_division_DEFAULT = 1e-6;                                     	% [-] Division Subnetwork Offset.
        alpha_DEFAULT = 1e-6;                                                	% [-] Subnetwork Denominator Adjustment
        
        % Define multiplication subnetwork parameters.
        c_multiplication_DEFAULT = 1;                                         	% [-] Multiplication Subnetwork Gain.
        
        % Define derivation subnetwork parameters.
        c_derivation_DEFAULT = 1e6;                                          	% [-] Derivative Subnetwork Gain
        w_derivation_DEFAULT = 1;                                            	% [Hz?] Derivative Subnetwork Cutoff Frequency?
        sf_derivation_DEFAULT = 0.05;                                          	% [-] Derivative Subnetwork Safety Factor
        
        % Define integration subnetwork parameters.
        c_integration_mean_DEFAULT = 0.01e9;                                 	% [-] Average Integration Gain
        
        % Define cpg subnetwork parameters.
        T_oscillation_DEFAULT = 2;                                            	% [s] Oscillation Period.
        r_oscillation_DEFAULT = 0.90;                                          	% [-] Oscillation Decay.
        
        % Define the default options.
        encoding_scheme_DEFAULT = 'Absolute';                                 	% [str] Encoding Scheme ('Absolute' or 'Relative')
        undetected_option_DEFAULT = 'error';                                	% [str] Undetected Option ('Error', 'Warning', 'Ignore'). Determines what to do when neuron IDs are not detected.
        set_flag_DEFAULT = true;                                               	% [T/F] Flag to determine whether to update the neuron manager after operations.
        as_cell_flag_DEFAULT = false;                                       	% [T/F] Flag to determine whether parameters are stored in cells.
        
        % Define the default saving and loading properties.
        file_name_DEFAULT = 'Neuron_Manager.mat';
        load_directory_DEFAULT = '.';
        
    end
    
    
    %% NEURON MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_manager_class( neurons, neuron_utilities, data_loader_utilities, array_utilities )
            
            % Set the default class properties.
            if nargin < 4, array_utilities = array_utilities_class(  ); end                     % [class] Array Utilities Class.
            if nargin < 3, data_loader_utilities = data_loader_utilities_class(  ); end         % [class] Data Load Utilities Class.
            if nargin < 2, neuron_utilities = neuron_utilities_class(  ); end                   % [class] Neuron Utilities Class.
            if nargin < 1, neurons = [  ]; end                                                  % [class] Array of Neuron Class Objects.
            
            % Store utilities class properties.
            self.array_utilities = array_utilities;
            self.data_loader_utilities = data_loader_utilities;
            self.neuron_utilities = neuron_utilities;
            
            % Store the neuron property.
            self.neurons = neurons;
            
            % Compute the number of neurons.
            self.num_neurons = length( neurons );
            
        end
        
        
        %% Neuron Index & ID Functions.
        
        % Implement a function to retrieve the index associated with a given neuron ID.
        function neuron_index = get_neuron_index( self, neuron_ID, neurons, undetected_option )
            
            % Set the default input arguments.
            if nargin < 4, undetected_option = self.undetected_option_DEFAULT; end      % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 3, neurons = self.neurons; end                                  % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Set a flag variable to indicate whether a matching neuron index has been found.
            b_match_found = false;
            
            % Initialize the neuron index.
            neuron_index = 0;
            
            % Search for a neuron whose ID matches the target value.
            while ( neuron_index < n_neurons ) && ( ~b_match_found )                    % While we have not yet checked all of the neurons and have not yet found an ID match...
                
                % Advance the neuron index.
                neuron_index = neuron_index + 1;
                
                % Check whether this neuron index is a match.
                if neurons( neuron_index ).ID == neuron_ID                              % If this neuron has the correct neuron ID...
                    
                    % Set the match found flag to true.
                    b_match_found = true;
                    
                end
                
            end
            
            % Determine whether to adjust the neuron index.
            if ~b_match_found                                                           % If a match was not found...
                
                % Determine how to handle when a match is not found.
                if strcmpi( undetected_option, 'error' )                                % If the undetected option is set to 'error'...
                    
                    % Throw an error.
                    error( 'No neuron with ID %0.0f.', neuron_ID )
                    
                elseif strcmpi( undetected_option, 'warning' )                          % If the undetected option is set to 'warning'...
                    
                    % Throw a warning.
                    warning( 'No neuron with ID %0.0f.', neuron_ID )
                    
                    % Set the neuron index to negative one.
                    neuron_index = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )                           % If the undetected option is set to 'ignore'...
                    
                    % Set the neuron index to negative one.
                    neuron_index = -1;
                    
                else                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Undetected option %s not recognized.', undetected_option )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to validate neuron IDs.
        function neuron_IDs = validate_neuron_IDs( self, neuron_IDs, neurons )
            
            % Set the default input arguments.
            if nargin < 3, neurons = self.neurons; end            	% [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Determine whether we want get the desired neuron property from all of the neurons.
            if isa( neuron_IDs, 'char' )                          	% If the neuron IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( neuron_IDs, 'all' )                    % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the neuron IDs.
                    neuron_IDs = zeros( 1, n_neurons );
                    
                    % Retrieve the neuron ID associated with each neuron.
                    for k = 1:n_neurons                             % Iterate through each neuron...
                        
                        % Store the neuron ID associated with the current neuron.
                        neuron_IDs( k ) = neurons( k ).ID;
                        
                    end
                    
                else                                               	% Otherwise...
                    
                    % Throw an error.
                    error( 'Neuron_IDs must be either an array of valid neuron IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to check if a proposed neuron ID is unique.
        function [ b_unique, match_logicals, match_indexes ] = unique_neuron_ID( self, neuron_ID, neurons, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve all of the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Determine whether the given neuron ID is one of the existing neuron IDs (if so, provide the matching logicals and indexes).
            [ b_match_found, match_logicals, match_indexes ] = array_utilities.is_value_in_array( neuron_ID, existing_neuron_IDs );
            
            % Define the uniqueness flag.
            b_unique = ~b_match_found;
            
        end
        
        
        % Implement a function to check whether a proposed neuron ID is a unique natural.
        function b_unique_natural = unique_natural_neuron_ID( self, neuron_ID, neurons, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                   	% [class] Array Utilities Class.
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Initialize the unique natural to false.
            b_unique_natural = false;
            
            % Determine whether this neuron ID is unique.
            b_unique = self.unique_neuron_ID( neuron_ID, neurons, array_utilities );
            
            % Determine whether this neuron ID is a unique natural.
            if b_unique && ( neuron_ID > 0 ) && ( round( neuron_ID ) == neuron_ID )         % If this neuron ID is a unique natural...
                
                % Set the unique natural flag to true.
                b_unique_natural = true;
                
            end
            
        end
        
        
        % Implement a function to check if an array of proposed neuron IDs are unique.
        function [ b_uniques, match_logicals, match_indexes ] = unique_neuron_IDs( self, neuron_IDs, neurons, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, neurons = self.neurons; end                                      % [class] Array of Neuron Class Objects.
            
            % Retrieve all of the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Determine whether the given neuron IDs are in the existing neuron IDs array (if so, provide the matching logicals and indexes).
            [ b_match_founds, match_logicals, match_indexes ] = array_utilities.are_values_in_array( neuron_IDs, existing_neuron_IDs );
            
            % Determine the uniqueness flags.
            b_uniques = ~b_match_founds;
            
        end
        
        
        % Implement a function to check if the existing neuron IDs are unique.
        function [ b_unique, match_logicals ] = unique_existing_neuron_IDs( self, neurons )
            
            % Set the default input arguments.
            if nargin < 2, neurons = self.neurons; end                                                      % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Determine whether all entries are unique.
            if length( unique( neuron_IDs ) ) == n_neurons                                                  % If all of the neuron IDs are unique...
                
                % Set the unique flag to true.
                b_unique = true;
                
                % Set the logicals array to true.
                match_logicals = false( 1, n_neurons );
                
            else                                                                                            % Otherwise...
                
                % Set the unique flag to false.
                b_unique = false;
                
                % Set the logicals array to true.
                match_logicals = false( 1, n_neurons );
                
                % Determine which neurons have duplicate IDs.
                for k1 = 1:n_neurons                                                                        % Iterate through each neuron...
                    
                    % Initialize the loop variable.
                    k2 = 0;
                    
                    % Determine whether there is another neuron with the same ID.
                    while ( k2 < n_neurons ) && ( ~match_logicals( k1 ) ) && ( k1 ~= ( k2 + 1 ) )           % While we haven't checked all of the neurons and we haven't found a match.
                        
                        % Advance the loop variable.
                        k2 = k2 + 1;
                        
                        % Determine whether this neuron is a match.
                        if neurons( k2 ).ID == neuron_IDs( k1 )                                             % If this neuron ID is a match...
                            
                            % Set this match logical to true.
                            match_logicals( k1 ) = true;
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        
        % Implement a function to generate a unique neuron ID.
        function neuron_ID = generate_unique_neuron_ID( self, neurons, array_utilities )
            
            % Set the default input arguments.
            if nargin < 3, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 2, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Generate a unique neuron ID.
            neuron_ID = array_utilities.get_lowest_natural_number( existing_neuron_IDs );
            
        end
        
        
        % Implement a function to generate multiple unique neuron IDs.
        function neuron_IDs = generate_unique_neuron_IDs( self, num_IDs, neurons, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the existing neuron IDs.
            existing_neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Preallocate an array to store the newly generated neuron IDs.
            neuron_IDs = zeros( 1, num_IDs );
            
            % Generate each of the new IDs.
            for k = 1:num_IDs                                                               % Iterate through each of the new IDs...
                
                % Generate a unique neuron ID.
                neuron_IDs( k ) = array_utilities.get_lowest_natural_number( [ existing_neuron_IDs, neuron_IDs( 1:( k - 1 ) ) ] );
                
            end
            
        end
        
        
        % Implement a function to enforce the uniqueness of the existing neuron IDs.
        function [ unique_neuron_IDs, neurons, self ] = make_neuron_IDs_unique( self, neurons, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 2, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Determine whether all entries are unique.
            if length( unique( neuron_IDs ) ) ~= n_neurons                                  % If the neuron IDs are not unique...
                
                % Preallocate an array to store the unique neuron IDs.
                unique_neuron_IDs = zeros( 1, n_neurons );
                
                % Create an array of unique neuron IDs.
                for k = 1:n_neurons                                                         % Iterate through each neuron...
                    
                    % Determine whether this neuron ID is non-unique.
                    b_match_found = array_utilities.is_value_in_array( neurons( k ).ID, unique_neuron_IDs );
                    
                    % Determine whether to keep this neuron ID or generate a new one.
                    if b_match_found                                                        % If this neuron ID already exists...
                        
                        % Generate a new neuron ID.
                        unique_neuron_IDs( k ) = self.generate_unique_neuron_ID( neurons, array_utilities );
                        
                        % Set the ID of this neuron.
                        neurons( k ).ID = unique_neuron_IDs( k );
                        
                    else                                                                    % Otherwise...
                        
                        % Keep the existing neuron ID.
                        unique_neuron_IDs( k ) = neurons( k ).ID;
                        
                    end
                    
                end
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to enforce the positivity of the existing neuron IDs.
        function [ new_neuron_IDs, neurons, self ] = make_neuron_IDs_positive( self, neurons, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 2, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Preallocate an array to store the new neuron IDs.
            new_neuron_IDs = zeros( 1, n_neurons );
            
            % Ensure that all of the neuron IDs are positive.
            for k = 1:n_neurons                                                             % Iterate through each of the neurons...
                
                % Determine whether this neuron ID is non-positive.
                if neurons( k ).ID <= 0                                                     % If this neuron ID is non-positive...
                    
                    % Generate a new unique ID for this neuron.
                    new_neuron_IDs( k ) = array_utilities.get_lowest_natural_number( neuron_IDs );
                    
                    % Update the neuron ID.
                    neurons( k ).ID = new_neuron_IDs( k );
                    
                end
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to ensure that the neuron IDs are integers.
        function [ new_neuron_IDs, neurons, self ] = make_neuron_IDs_integers( self, neurons, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 2, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Preallocate an array to store the new neuron IDs.
            new_neuron_IDs = zeros( 1, n_neurons );
            
            % Ensure that all of the neuron IDs are integers.
            for k = 1:n_neurons                                                             % Iterate through each of the neurons...
                
                % Determine whether this neuron ID is an integer.
                if round( neurons( k ).ID ) ~= neurons( k ).ID                               % If this neuron ID is not an integer...
                    
                    % Generate a new ID for this neuron.
                    new_neuron_IDs( k ) = array_utilities.get_lowest_natural_number( neuron_IDs );
                    
                    % Update the neuron ID.
                    neurons( k ).ID = new_neuron_IDs( k );
                    
                end
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to ensure that the neuron IDs are natural numbers.
        function [ new_neuron_IDs, neurons, self ] = make_neuron_IDs_naturals( self, neurons, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                                  % [class] Array Utilities Class.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                        % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 2, neurons = self.neurons; end                                                  % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Retrieve all of the existing neuron IDs.
            neuron_IDs = self.get_all_neuron_IDs( neurons );
            
            % Preallocate an array to store the new neuron IDs.
            new_neuron_IDs = zeros( 1, n_neurons );
            
            % Ensure that all of the neuron IDs are naturals.
            for k = 1:n_neurons                                                                         % Iterate through each of the neurons...
                
                % Determine whether this neuron ID is natural.
                if ( round( neurons( k ).ID ) ~= neurons( k ).ID ) || ( neurons( k ).ID <= 0 )          % If this neuron ID is not a natural...
                    
                    % Generate a new ID for this neuron.
                    new_neuron_IDs( k ) = array_utilities.get_lowest_natural_number( neuron_IDs );
                    
                    % Generate a new unique ID for this neuron.
                    neurons( k ).ID = new_neuron_IDs( k );
                    
                end
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to ensure that the neuron IDs are natural numbers.
        function [ new_neuron_IDs, neurons, self ] = make_neuron_IDs_unique_naturals( self, neurons, set_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 4, array_utilities = self.array_utilities; end                                                  % [class] Array Utilities Class.
            if nargin < 3, set_flag = self.set_flag_DEFAULT; end                                                        % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 2, neurons = self.neurons; end                                                                  % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Create an array to store the new neuron IDs.
            new_neuron_IDs = zeros( 1, n_neurons );
            
            % Ensure that all of the neuron IDs are naturals.
            for k = 1:n_neurons                                                                                         % Iterate through each of the neurons...
                
                % Retrieve all of the existing neuron IDs.
                neuron_IDs = self.get_all_neuron_IDs( neurons );
                
                % Remove the kth entry.
                neuron_IDs( k ) = [  ];
                
                % Determine whether this neuron ID is non-unique.
                b_match_found = array_utilities.is_value_in_array( neurons( k ).ID, neuron_IDs );
                
                % Determine whether this neuron ID is natural.
                if ( round( neurons( k ).ID ) ~= neurons( k ).ID ) || ( neurons( k ).ID <= 0 ) || b_match_found         % If this neuron ID is not a unique natural...
                    
                    % Generate a new ID for this neuron.
                    new_neuron_IDs( k ) = array_utilities.get_lowest_natural_number( neuron_IDs );
                    
                    % Generate a new unique ID for this neuron.
                    neurons( k ).ID = new_neuron_IDs( k );
                    
                end
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to retrieve all of the neuron IDs.
        function neuron_IDs = get_all_neuron_IDs( self, neurons )
            
            % Set the default input arguments.
            if nargin < 2, neurons = self.neurons; end      % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Preallocate a variable to store the neuron IDs.
            neuron_IDs = zeros( 1, n_neurons );
            
            % Retrieve the ID associated with each neuron.
            for k = 1:n_neurons                             % Iterate through each of the neurons...
                
                neuron_IDs( k ) = neurons( k ).ID;
                
            end
            
        end
        
        
        % Implement a function to get all enabled neuron IDs.
        function neuron_IDs = get_enabled_neuron_IDs( self, neurons )
            
            % Set the default input arguments.
            if nargin < 2, neurons = self.neurons; end              % [class] Array of Neuron Class Objects.
            
            % Preallocate an array to store the neuron IDs.
            neuron_IDs = zeros( 1, n_neurons );
            
            % Initialize a counter variable.
            k2 = 0;
            
            % Retrieve the IDs of the enabled neurons.
            for k1 = 1:n_neurons                                    % Iterate through each of the neurons...
                
                % Determine whether to store this neuron ID.
                if neurons( k1 ).b_enabled                          % If this neuron is enabled...
                    
                    % Advance the counter variable.
                    k2 = k2 + 1;
                    
                    % Store this neuron ID.
                    neuron_IDs( k2 ) = neurons( k1 ).ID;
                    
                end
                
            end
            
            % Remove extra neuron IDs.
            neuron_IDs = neuron_IDs( 1:k2 );
            
        end
        
        
        %% General Get & Set Neuron Property Functions.
        
        % Implement a function to retrieve the properties of specific neurons.
        function xs = get_neuron_property( self, neuron_IDs, neuron_property, as_matrix, neurons, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, as_matrix = false; end                                           % [T/F] As Matrix Flag (Determines whether to return the neuron property as a matrix or as a cell.)
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_properties_to_get = length( neuron_IDs );
            
            % Preallocate a variable to store the neuron properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given neuron property for each neuron.
            for k = 1:num_properties_to_get                 % Iterate through each of the properties to get...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{ k } = neurons( %0.0f ).%s;', neuron_index, neuron_property );
                
                % Evaluate the given neuron property.
                eval( eval_str );
                
            end
            
            % Determine whether to convert the network properties to a matrix.
            if as_matrix                                    % If we want the neuron properties as a matrix instead of a cell...
                
                % Convert the neuron properties from a cell to a matrix.
                xs = cell2mat( xs );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific neurons.
        function [ neurons, self ] = set_neuron_property( self, neuron_IDs, neuron_property_values, neuron_property, neurons, set_flag )
            
            % Set the default input arguments.
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                                    % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                              % [class] Array of Neuron Class Objects.
            
            % Compute the number of neurons.
            n_neurons = length( neurons );
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retreive the number of neuron IDs.
            num_neuron_IDs = length( neuron_IDs );
            
            % Retrieve the number of neuron property values.
            num_neuron_property_values = length( neuron_property_values );
            
            % Ensure that the provided neuron property values have the same length as the provided neuron IDs.
            if ( num_neuron_IDs ~= num_neuron_property_values )                                     % If the number of provided neuron IDs does not match the number of provided property values...
                
                % Determine whether to agument the property values.
                if num_neuron_property_values == 1                                                  % If there is only one provided property value...
                    
                    % Agument the property value length to match the ID length.
                    neuron_property_values = neuron_property_values*ones( 1, num_neuron_IDs );
                    
                else                                                                                % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided neuron propety values must match the number of provided neuron IDs, unless a single neuron property value is provided.' )
                    
                end
                
            end
            
            % Validate the neuron property values.
            if ~isa( neuron_property_values, 'cell' )                                               % If the neuron property values are not a cell array...
                
                % Convert the neuron property values to a cell array.
                neuron_property_values = num2cell( neuron_property_values );
                
            end
            
            % Set the properties of each neuron.
            for k = 1:n_neurons                                                                     % Iterate through each neuron...
                
                % Determine the index of the neuron property value that we want to apply to this neuron (if we want to set a property of this neuron).
                index = find( neurons( k ).ID == neuron_IDs, 1 );
                
                % Determine whether to set a property of this neuron.
                if ~isempty( index )                                                                % If a matching neuron ID was detected...
                    
                    % Create an evaluation string that sets the desired neuron property.
                    eval_string = sprintf( 'neurons( %0.0f ).%s = neuron_property_values{ %0.0f };', k, neuron_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Enable & Disable Functions.
        
        % Implement a function to enable a neuron.
        function [ b_enabled, neurons, self ] = enable_neuron( self, neuron_ID, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID, neurons, undetected_option );
            
            % Enable this neuron.
            [ b_enabled, neurons( neuron_index ) ] = neurons( neuron_index ).enable( true );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to enable neurons.
        function [ b_enableds, neurons, self ] = enable_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine the number of neurons to enable.
            num_neuron_IDs = length( neuron_IDs );
            
            % Preallocate an array to store the enabled flags.
            b_enableds = false( 1, num_neuron_IDs );
            
            % Enable all of the specified neurons.
            for k = 1:num_neuron_IDs                                                        % Iterate through all of the specified neurons...
                
                % Enable this neuron.
                [ b_enableds( k ), neurons, self ] = self.enable_neuron( neuron_IDs( k ), neurons, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to disable a neuron.
        function [ b_enabled, neurons, self ] = disable_neuron( self, neuron_ID, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID, neurons, undetected_option );
            
            % Disable this neuron.
            [ b_enabled, neurons( neuron_index ) ] = neurons( neuron_index ).disable( true );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to disable neurons.
        function [ b_enableds, neurons, self ] = disable_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undected_option_DEFAULT; end            % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine the number of neurons to disable.
            num_neuron_IDs = length( neuron_IDs );
            
            % Preallocate an array to store the enabled flags.
            b_enableds = false( 1, num_neuron_IDs );
            
            % Disable all of the specified neurons.
            for k = 1:num_neuron_IDs                                                        % Iterate through all of the specified neurons...
                
                % Disable this neuron.
                [ b_enableds( k ), neurons, self ] = self.disable_neuron( neuron_IDs( k ), neurons, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to toggle a neuron's enabled flag.
        function [ b_enabled, neurons, self ] = toggle_enabled_neuron( self, neuron_ID, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID, neurons, undetected_option );
            
            % Toggle whether this neuron is enabled.
            [ b_enabled, neurons( neuron_index ) ] = neurons( neuron_index ).toggle_enabled( neurons( neuron_index ).b_enabled, true );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to toggle multiple neuron enable states.
        function [ b_enableds, neurons, self ] = toggle_enabled_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine the number of neurons to disable.
            num_neuron_IDs = length( neuron_IDs );
            
            % Preallocate an array to store the enabled flags.
            b_enableds = false( 1, num_neuron_IDs );
            
            % Disable all of the specified neurons.
            for k = 1:num_neuron_IDs                                                        % Iterate through all of the specified neurons...
                
                % Toggle this neuron.
                [ b_enableds( k ), neurons, self ] = self.toggle_enabled_neuron( neuron_IDs( k ), neurons, set_flag, undetected_option );
                
            end
            
        end
        
        
        %% Call Neuron Methods Functions.
        
        % Implement a function to that calls a specified neuron method for each of the specified neurons.
        function [ values, neurons, self ] = call_neuron_method( self, neuron_IDs, neuron_method, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the computed values.
            values = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Define the eval string.
                eval_str = sprintf( '[ values( k ), neurons( %0.0f ) ] = neurons( %0.0f ).%s(  );', neuron_index, neuron_index, neuron_method );
                
                % Evaluate the given neuron method.
                eval( eval_str );
                
            end
            
            % Determine whether to update the neuron manager object.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Compute Multiplication-Division Subnetwork Gain Functions.
        
        % Implement a function to compute the absolute multiplication division subgain.
        function c2 = compute_absolute_multiplication_c2( self, c, c1, epsilon1, epsilon2, R2 )
            
            % Define the default input arguments.
            if nargin < 6, R2 = self.R_DEFAULT; end                          	% [V] Maximum Membrane Voltage.
            if nargin < 5, epsilon2 = self.epsilon_DEFAULT; end                 % [-] Division Subnetwork Offset.
            if nargin < 4, epsilon1 = self.epsilon_DEFAULT; end                 % [-] Inversion Subnetwork Offset.
            if nargin < 3, c1 = self.c_DEFAULT; end                             % [-] Inversion Subnetwork Gain.
            if nargin < 2, c = self.c_DEFAULT; end                              % [-] Multiplication Subnetwork Gain.
            
            % Compute the absolute multiplication subnetwork gain.
            c2 = ( ( c*R2 )/( R2 + epsilon1 ) )*c1 + c*epsilon2*R2;             % [-] Division Subnetwork Gain.
            
        end
        
        
        %% Sodium Channel Conductance Compute Functions.
        
        % Implement a function to compute the sodium channel conductance for a two neuron CPG subnetwork for each neuron.
        function [ Gnas, neurons, self ] = compute_cpg_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_cpg_Gna( neurons( neuron_index ).R, neurons( neuron_index ).Gm, neurons( neuron_index ).Am, neurons( neuron_index ).Sm, neurons( neuron_index ).dEm, neurons( neuron_index ).Ah, neurons( neuron_index ).Sh, neurons( neuron_index ).dEh, neurons( neuron_index ).dEna, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of driven multistate cpg neurons.
        function [ Gnas, neurons, self ] = compute_dmcpg_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_dmcpg_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of transmission neurons.
        function [ Gnas, neurons, self ] = compute_transmission_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_transmission_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of modulation neurons.
        function [ Gnas, neurons, self ] = compute_modulation_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_modulation_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of addition neurons.
        function [ Gnas, neurons, self ] = compute_addition_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end        	% [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of subtraction neurons.
        function [ Gnas, neurons, self ] = compute_subtraction_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of double subtraction neurons.
        function [ Gnas, neurons, self ] = compute_double_subtraction_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_double_subtraction_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of multiplication neurons.
        function [ Gnas, neurons, self ] = compute_multiplication_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_multiplication_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of inversion neurons.
        function [ Gnas, neurons, self ] = compute_inversion_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of division neurons.
        function [ Gnas, neurons, self ] = compute_division_Gna( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_Gna( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of derivation neurons.
        function [ Gnas, neurons, self ] = compute_derivation_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_derivation_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of integration neurons.
        function [ Gnas, neurons, self ] = compute_integration_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_integration_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of voltage based integration neurons.
        function [ Gnas, neurons, self ] = compute_vbi_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_vbi_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the sodium channel conductance of split voltage based integration neurons.
        function [ Gnas, neurons, self ] = compute_svbi_Gna( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the soduium channel conductances.
            Gnas = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gnas( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_svbi_Gna( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Membrane Conductance Compute Functions.
        
        % Implement a function to compute the membrane conductance of addition input neurons.
        function [ Gms, neurons, self ] = compute_addition_Gm_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;                             % [#] Number of Neurons to Evaluate (All expect the final neuron are inputs.)
            
            % Preallocate an array to store the membrane conductances.
            Gms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane conductance for this neuron.
                [ Gms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_Gm_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of addition output neurons.
        function [ Gm, neurons, self ] = compute_addition_Gm_output( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end                          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                                      % [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                            	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );          % Only the final addition neuron is the output neuron.
            
            % Compute and set the membrane conductance for the output neuron.
            [ Gm, neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_Gm_output( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of subtraction input neurons.
        function [ Gms, neurons, self ] = compute_subtraction_Gm_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                         	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the membrane conductances.
            Gms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_Gm_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of subtraction output neurons.
        function [ Gm, neurons, self ] = compute_subtraction_Gm_output( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme; end                      % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ Gm, neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_Gm_output( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of inversion input neurons.
        function [ Gm, neurons, self ] = compute_inversion_Gm_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end        	% [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                         	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the input neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the input neuron.
            [ Gm, neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_Gm_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of inversion output neurons.
        function [ Gm, neurons, self ] = compute_inversion_Gm_output( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ Gm, neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_Gm_output( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of division input neurons.
        function [ Gms, neurons, self ] = compute_division_Gm_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;
            
            % Preallocate an array to store the membrane conductances.
            Gms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the sodium channel conductance for this neuron.
                [ Gms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_Gm_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of division output neurons.
        function [ Gms, neurons, self ] = compute_division_Gm_output( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ Gms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_Gm_output( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane conductance of derivation neurons.
        function [ Gms, neurons, self ] = compute_derivation_Gm( self, neuron_IDs, k_gain, w, safety_factor, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 6, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end               	% [-] Derivative Subnetwork Safety Factor
            if nargin < 4, w = self.w_derivation_DEFAULT; end                              	% [Hz?] Derivative Subnetwork Cutoff Frequency
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end                        	% [-] Derivative Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Gms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane conductance for this neuron.
                [ Gms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_derivation_Gm( k_gain, w, safety_factor, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Membrane Capacitance Compute Functions.
        
        % Implement a function to compute the membrane capacitance of transmission subnetwork neurons.
        function [ Cms, neurons, self ] = compute_transmission_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                      	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_transmission_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of slow transmission subnetwork neurons.
        function [ Cms, neurons, self ] = compute_slow_transmission_Cm( self, neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 7, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 5, r = self.r_oscillation_DEFAULT; end                            	% [-] Oscillation Decay
            if nargin < 4, T = self.T_oscillation_DEFAULT; end                            	% [s] Oscillation Period
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.             	% [#] Number of CPG Neurons
            if nargin < 2, neuron_IDs = 'all'; end                                         	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_slow_transmission_Cm( neurons( neuron_index ).Gm, num_cpg_neurons, T, r, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of modulation subnetwork neurons.
        function [ Cms, neurons, self ] = compute_modulation_Cm( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                      	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_modulation_Cm( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of addition subnetwork neurons.
        function [ Cms, neurons, self ] = compute_addition_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                         	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of subtraction subnetwork neurons.
        function [ Cms, neurons, self ] = compute_subtraction_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                              	% Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of double subtraction subnetwork neurons.
        function [ Cms, neurons, self ] = compute_double_subtraction_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_double_subtraction_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of multiplication subnetwork neurons.
        function [ Cms, neurons, self ] = compute_multiplication_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_multiplication_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of inversion subnetwork neurons.
        function [ Cms, neurons, self ] = compute_inversion_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                       	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of division subnetwork neurons.
        function [ Cms, neurons, self ] = compute_division_Cm( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                       	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_Cm( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the first membrane capacitance of derivation subnetwork neurons.
        function [ Cm1, neurons, self ] = compute_derivation_Cm1( self, neuron_IDs, k_gain, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end                        	% [-] Derivative Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the membrane capacitance of the second neuron.
            Cm2 = self.get_neuron_property( neuron_IDs( 2 ), 'Cm', true, neurons );       	% [F] Membrane Capacitance
            Gm2 = self.get_neuron_property( neuron_IDs( 2 ), 'Gm', true, neurons );        	% [S] Membrane Conductance
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ), neurons, undetected_option );
            
            % Compute and set the membrane capacitance for this neuron.
            [ Cm1, neurons( neuron_index ) ] = neurons( neuron_index ).compute_derivation_Cm1( Gm2, Cm2, k_gain, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the second memebrane capacitance of derivation subnetwork neurons.
        function [ Cm2, neurons, self ] = compute_derivation_Cm2( self, neuron_IDs, w, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, w = self.w_derivation_DEFAULT; end                              	% [Hz?] Derivative Subnetwork Cutoff Frequency?
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with this neuron ID.
            neuron_index = self.get_neuron_index( neuron_IDs( 2 ), neurons, undetected_option );
            
            % Compute and set the membrane capacitance for this neuron.
            [ Cm2, neurons( neuron_index ) ] = neurons( neuron_index ).compute_derivation_Cm2( neurons( neuron_index ).Gm, w, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of integration neurons.
        function [ Cms, neurons, self ] = compute_integration_Cm( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                  	% [-] Average Integration Mean
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_integration_Cm( ki_mean, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the membrane capacitance of voltage based integration neurons.
        function [ Cms, neurons, self ] = compute_vbi_Cm( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end                 	% [-] Average Integration Gain
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_vbi_Cm( ki_mean, true, neuros( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the first membrane capacitance of split voltage based integration neurons.
        function [ Cms, neurons, self ] = compute_svbi_Cm1( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end               	% [-] Average Integration Gain
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_svbi_Cm1( ki_mean, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the second membrane capacitance of split voltage based integration neurons.
        function [ Cms, neurons, self ] = compute_svbi_Cm2( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Preallocate an array to store the membrane conductances.
            Cms = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane capacitance for this neuron.
                [ Cms( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_svbi_Cm2( true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Method Parameter Processing Functions.
        
        % Implement a function to process the addition subnetwork output activation domain parameters.
        function parameters = process_addition_R_output_parameters( self, parameters, encoding_scheme, neurons )
            
            % Set the default input arguments.
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                       % [cell] Parameters Cell.
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                                    % If no parameters were provided...
                    
                    % Retrieve the maximum membrane voltages of the input neurons.
                    Rs = self.get_neuron_property( neuron_IDs( 1:( end - 1 ) ), 'R', true, neurons );
                    
                    % Store the required parameters in a cell.
                    parameters = { Rs };
                    
                else                                                                        % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 1                                            % If there is anything other than a single parameter entry...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if ~isempty( parameters )                                                   % If the parameters cell is not empty...
                    
                    % Throw an error.
                    error( 'Invalid parameters detected.' )
                    
                end
                
            else                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the subtraction subnetwork output activation domain parameters.
        function parameters = process_subtraction_R_output_parameters( self, parameters, encoding_scheme, neurons )
            
            % Set the default input arguments.
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                       % [cell] Parameters Cell.
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                                    % If no parameters were provided...
                    
                    % Set the input signature to the default value.
                    s_ks = self.s_ks_DEFAULT;
                    
                    % Retrieve the maximum membrane voltages of the input neurons.
                    Rs = self.get_neuron_property( neuron_IDs( 1:( end - 1 ) ), 'R', true, neurons );
                    
                    % Store the required parameters in a cell.
                    parameters = { Rs, s_ks };
                    
                else                                                                        % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 2                                            % If there is anything other than two parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if ~isempty( parameters )                                                   % If the parameters cell is not empty...
                    
                    % Throw an error.
                    error( 'Invalid parameters detected.' )
                    
                end
                
            else                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the inversion subnetwork input activation domain parameters.
        function parameters = process_inversion_R_input_parameters( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end         	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                       % [cell] Parameters Cell.
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                                % If no parameters were provided...
                    
                    % Set the default input and output voltage offsets.
                    epsilon = self.epsilon_inversion_DEFAULT;                        	% [V] Inversion Subnetwork Input Offset.
                    delta = self.delta_inversion_DEFAULT;                               % [V] Inversion Subnetwork Output Offset.
                    
                    % Store the required parameters in a cell.
                    parameters = { epsilon, delta };
                    
                else                                                                	% Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 2                                        % If there is anything other than two parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if ~isempty( parameters )                                               % If the parameters cell is not empty...
                    
                    % Throw an error.
                    error( 'Invalid parameters detected.' )
                    
                end
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the inversion subnetwork output activation domain parameters.
        function parameters = process_inversion_R_output_parameters( self, parameters, encoding_scheme )
            
            % Set the default input arguments.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end         	% [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                       % [cell] Parameters Cell.
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                                   % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                                % If no parameters were provided...
                    
                    % Set the default input and output voltage offsets.
                    c = self.c_inversion_DEFAULT;
                    epsilon = self.epsilon_inversion_DEFAULT;                           % [V] Inversion Subnetwork Input Offset.
                    delta = self.delta_inversion_DEFAULT;                               % [V] Inversion Subnetwork Output Offset.
                    
                    % Store the required parameters in a cell.
                    parameters = { c, epsilon, delta };
                    
                else                                                                    % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 3                                        % If there is anything other than three parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                               % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if ~isempty( parameters )                                               % If the parameters cell is not empty...
                    
                    % Throw an error.
                    error( 'Invalid parameters detected.' )
                    
                end
                
            else                                                                        % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        
        
        % Implement a function to process the division subnetwork output activation domain parameters.
        function parameters = process_division_R_output_parameters( self, parameters, encoding_scheme, neurons )
            
            % Set the default input arguments.
            if nargin < 4, neurons = self.neurons; end                                                      % [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                                           % [cell] Parameters Cell.
            
            % Determine how to create the parameters cell.
            if strcmpi( encoding_scheme, 'absolute' )                                                       % If this operation is using an absolute encoding scheme...
                
                % Determine how to create the parameters cell given that this operation is using an absolute encoding scheme.
                if isempty( parameters )                                                                    % If no parameters were provided...
                    
                    % Set the default input and output voltage offsets.
                    c = self.c_inversion_DEFAULT;                                                           % [-] Inversion Subnetwork Gain.
                    alpha = self.alpha_DEFTAULT;                                                            % [-] Subnetwork Denominator Adjustment
                    epsilon = self.epsilon_inversion_DEFAULT;                                               % [V] Division Subnetwork Input Offset.
                    R_numerator = self.get_neuron_property( neuron_IDs( 1 ), 'R', true, neurons );          % [V] Activation Domain.
                    
                    % Store the required parameters in a cell.
                    parameters = { c, alpha, epsilon, R_numerator };
                    
                else                                                                                        % Otherwise...
                    
                    % Determine whether the parameters cell has a valid number of entries.
                    if length( parameters ) ~= 4                                                            % If there is anything other than four parameter entries...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )
                        
                    end
                    
                end
                
            elseif strcmpi( encoding_scheme, 'relative' )                                                   % If this operation uses a relative encoding scheme...
                
                % Determine whether parameters cell is valid given that this operation is using a relative encoding scheme.
                if ~isempty( parameters )                                                                   % If the parameters cell is not empty...
                    
                    % Throw an error.
                    error( 'Invalid parameters detected.' )
                    
                end
                
            else                                                                                            % Otherwise...
                
                % Throw an error.
                error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                
            end
            
        end
        

        % Implement a function to process the multiplication subnetwork design parameters.
        function [ parameters_inversion, parameters_division, parameters_multiplication ] = process_multiplication_design_parameters( self, parameters, encoding_scheme, neurons )
           
            % Set the default input arguments.
            if nargin < 4, neurons = self.neurons; end                                          % [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end                  % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, parameters = {  }; end                                               % [cell] Parameters Cell.
            
            % Determine whether there are multiplication design parameters to process.
            if ~isempty( parameters )                                                           % If parameters were provided...
                
                % Determine how to process the multiplication design parameters based on the encoding scheme of this multiplication subnetwork.
                if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is absolute...
            
                    % Determine whether there are the correct number of parameters for an absolute multiplication subnetwork.
                    if length( parameters ) == 8                                                % If there are exactly eight parameters...
                        
                        % Unpack the multiplication parameters.
                        c = parameters{ 1 };                                                    % [-] Multiplication Subnetwork Gain.
                        c1 = parameters{ 2 };                                                   % [-] Inversion Subnetwork Gain.
                        alpha = parameters{ 3 };                                                % [-] Division Subnetwork Denominator Adjustment.
                        epsilon1 = parameters{ 4 };                                             % [V] Inversion Subnetwork Input Offset.
                        epsilon2 = parameters{ 5 };                                             % [V] Division Subnetwork Input Offset.
                        delta = parameters{ 6 };                                                % [V] Inversion Subnetwork Output Offset.
                        R1 = parameters{ 7 };                                                   % [V] Multiplication Subnetwork Neuron 1 Activation Domain.
                        R2 = parameters{ 8 };                                                   % [V] Multiplication Subnetwork Neuron 2 Activation Domain.
                        
                        % Compute the required absolute division subnetwork gain.
                        c2 = self.compute_absolute_multiplication_c2( c, c1, epsilon1, epsilon2, R2 );
                        
                        % Create the inversion, division, and multiplication parameters.
                        parameters_inversion = { c1, epsilon1, delta };
                        parameters_division = { c2, alpha, epsilon2, R1 };
                        parameters_multiplication = { c, c1, c2, alpha, epsilon1, epsilon2, delta, R1, R2 };
                        
                    else                                                                        % Otherwise...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )                        
                        
                    end
                    
                elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is relative...
                
                    if length( parameters ) == 5                                                % If there are exactly five parameters...

                        % Create the inversion, division, and multiplication parameters.
                        parameters_inversion = {  };
                        parameters_division = {  };
                        parameters_multiplication = parameters;
                    
                    else                                                                        % Otherwise...
                        
                        % Throw an error.
                        error( 'Invalid parameters detected.' )    
                        
                    end
                    
                else                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                    
                end
                    
            else                                                                                % Otherwise...
                
                % Process the inversion and division parameters.
                parameters_inversion = self.process_inversion_R_output_parameters( parameters, encoding_scheme );
                parameters_division = self.process_division_R_output_parameters( parameters, encoding_scheme, neurons );
            
                % Process the multiplication gain.
                c = self.c_multiplication_DEFAULT; 
                
                % Determine how to process encoding scheme specific multiplication parameters.
                if strcmpi( encoding_scheme, 'absolute' )                                       % If the encoding scheme is absolute...
                    
                    % Retrieve the activation domain of the second neuron.
                    R2 = self.get_neuron_property( neuron_IDs( 2 ), 'R', true, neurons );       % [V] Multiplication Subnetwork Neuron 2 Activation Domain.

                    % Create the multiplication parameters.
                    parameters_multiplication = { c, parameters_inversion{ 1 }, parameters_division{ 1 }, parameters_division{ 2 }, parameters_inversion{ 2 }, parameters_division{ 3 }, parameters_inversion{ 3 }, parameters_division{ 4 }, R2 };
                
                elseif strcmpi( encoding_scheme, 'relative' )                                   % If the encoding scheme is relative...
                
                    % Set the default multiplication subnetwork parameters.
                    c1 = self.c_inversion_DEFAULT;
                    c2 = self.c_division_DEFAULT;
                    epsilon1 = self.epsilon_inversion_DEFAULT;
                    epsilon2 = self.epsilon_division_DEFAULT;
                    
                    % Create the multiplication parameters.
                    parameters_multiplication = { c, c1, c2, epsilon1, epsilon2 };
                
                    
                else                                                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'Invalid encoding scheme.  Must be either: ''absolute'' or ''relative''.' )
                    
                end
                
            end

        end
        
        
        %% Activation Domain Compute Functions.
        
        % Implement a function to compute the operational domain of the addition subnetwork input neurons.
        function [ Rs, neurons, self ] = compute_addition_R_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;                             % [#] Number of Neurons to Evaluate (All expect the final neuron are inputs.)
            
            % Preallocate an array to store the membrane conductances.
            Rs = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane conductance for this neuron.
                [ Rs( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_R_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the addition subnetwork output neurons.
        function [ R, neurons, self ] = compute_addition_R_output( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end      	% [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Process the parameters.
            parameters = self.process_addition_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_addition_R_output( parameters, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the subtraction subnetwork input neurons.
        function [ Rs, neurons, self ] = compute_subtraction_R_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;                             % [#] Number of Neurons to Evaluate (All expect the final neuron are inputs.)
            
            % Preallocate an array to store the membrane conductances.
            Rs = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane conductance for this neuron.
                [ Rs( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_R_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the subtraction subnetwork output neurons.
        function [ R, neurons, self ] = compute_subtraction_R_output( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Process the parameters.
            parameters = self.process_subtraction_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_subtraction_R_output( parameters, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the inversion subnetwork input neurons.
        function [ R, neurons, self ] = compute_inversion_R_input( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                          % [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Process the parameters.
            parameters = self.process_inversion_R_input_parameters( parameters, encoding_scheme );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( 1 ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_R_input( parameters, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the inversion subnetwork output neurons.
        function [ R, neurons, self ] = compute_inversion_R_output( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Process the parameters.
            parameters = self.process_inversion_R_output_parameters( parameters, encoding_scheme );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_inversion_R_output( parameters, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the division subnetwork input neurons.
        function [ Rs, neurons, self ] = compute_division_R_input( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs ) - 1;                             % [#] Number of Neurons to Evaluate (All expect the final neuron are inputs.)
            
            % Preallocate an array to store the membrane conductances.
            Rs = zeros( 1, num_neurons_to_evaluate );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate                                               % Iterate through each of the input neurons...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs( k ), neurons, undetected_option );
                
                % Compute and set the membrane conductance for this neuron.
                [ Rs( k ), neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_R_input( encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
                
            end
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the division subnetwork output neurons.
        function [ R, neurons, self ] = compute_division_R_output( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                       	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Process the parameters.
            parameters = self.process_division_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_division_R_output( parameters, encoding_scheme, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        % Implement a function to compute the operational domain of the relative multiplication subnetwork output neurons.
        function [ R, neurons, self ] = compute_relative_multiplication_R_output( self, neuron_IDs, c, c1, c2, epsilon1, epsilon2, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 10, undetected_option = self.undetected_option_DEFAULT; end         % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 9, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 8, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 7, epsilon2 = self.epsilon_DEFAULT; end                         	% [-] Division Subnetwork Offset
            if nargin < 6, epsilon1 = self.epsilon_DEFAULT; end                         	% [-] Inversion Subnetwork Offset
            if nargin < 5, c2 = self.c_DEFAULT; end                                       	% [-] Division Subnetwork Gain
            if nargin < 4, c1 = self.c_DEFAULT; end                                       	% [-] Inversion Subnetwork Gain
            if nargin < 3, c = self.c_DEFAULT; end                                      	% [-] Multiplication Subnetwork Gain
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the index associated with the output neuron.
            neuron_index = self.get_neuron_index( neuron_IDs( end ), neurons, undetected_option );
            
            % Compute and set the membrane conductance for the output neuron.
            [ R, neurons( neuron_index ) ] = neurons( neuron_index ).compute_relative_multiplication_R_output( c, c1, c2, epsilon1, epsilon2, true, neurons( neuron_index ).neuron_utilities );
            
            % Determine whether to update the neuron manager.
            if set_flag, self.neurons = neurons; end
            
        end
        
        
        %% Neuron Property Validation Functions.
        
        % Implement a function to verify the compatibility of neuron properties.
        function valid_flag = validate_neuron_properties( self, n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities )
            
            % Set the default neuron properties.
            if nargin < 28, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            
            % Determine whether to convert the names property to a cell.
            if ~iscell( names ), names = { names }; end
            
            % Determine whether the neuron properties are relevant.
            valid_flag = ( n_neurons == length( IDs ) ) && ( n_neurons == length( names ) &&  n_neurons == length( Us ) ) && ( n_neurons == length( hs ) ) && ( n_neurons == length( Cms ) ) && ( n_neurons == length( Gms ) ) && ( n_neurons == length( Ers ) ) && ( n_neurons == length( Rs ) ) && ( n_neurons == length( Ams ) ) && ( n_neurons == length( Sms ) ) && ( n_neurons == length( dEms ) ) && ( n_neurons == length( Ahs ) ) && ( n_neurons == length( Shs ) ) && ( n_neurons == length( dEhs ) ) && ( n_neurons == length( dEnas ) ) && ( n_neurons == length( tauh_maxs ) ) && ( n_neurons == length( Gnas ) ) && ( n_neurons == length( I_leaks ) ) && ( n_neurons == length( I_syns ) ) && ( n_neurons == length( I_nas ) ) && ( n_neurons == length( I_tonics ) ) && ( n_neurons == length( I_apps ) ) && ( n_neurons == length( I_totals ) ) && ( n_neurons == length( b_enableds ) );
            
        end
        
        
        %% Basic Neuron Creation & Deletion Functions.
                
        % Implement a function to process neuron creation inputs.
        function [ n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = process_neuron_creation_inputs( self, n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities )
           
            % Set the default neuron properties.
            if nargin < 28, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag.
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current.
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current.
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current.
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current.
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current.
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current.
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance.
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant.
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential.
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential.
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope.
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude.
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential.
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope.
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude.
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain.
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential.
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance.
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance.
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter.
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage.
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name.
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID.
            
            % Convert the neuron parameters from cells to arrays as appropriate.
            b_enableds = array_utilities.cell2array( b_enableds );                                                                 % [T/F] Neuron Enabled Flag.
            I_totals = array_utilities.cell2array( I_totals );                                                                     % [A] Total Current.
            I_apps = array_utilities.cell2array( I_apps );                                                                         % [A] Applied Current.
            I_tonics = array_utilities.cell2array( I_tonics );                                                                     % [A] Tonic Current.
            I_nas = array_utilities.cell2array( I_nas );                                                                           % [A] Sodium Channel Current.
            I_syns = array_utilities.cell2array( I_syns );                                                                         % [A] Synaptic Current.
            I_leaks = array_utilities.cell2array( I_leaks );                                                                     	% [A] Leak Current.
            Gnas = array_utilities.cell2array( Gnas );                                                                             % [S] Sodium Channel Conductance.
            tauh_maxs = array_utilities.cell2array( tauh_maxs );                                                                 	% [s] Maximum Sodium Channel Deactivation Time Constant.
            dEnas = array_utilities.cell2array( dEnas );                                                                           % [V] Sodium Channel Reversal Potential.
            dEhs = array_utilities.cell2array( dEhs );                                                                           	% [V] Sodium Channel Deactivation Reversal Potential.
            Shs = array_utilities.cell2array( Shs );                                                                               % [-] Sodium Channel Deactivation Slope.
            Ahs = array_utilities.cell2array( Ahs  );                                                                              % [-] Sodium Channel Deactivation Amplitude.
            dEms = array_utilities.cell2array( dEms );                                                                             % [-] Sodium Channel Activation Reversal Potential.
            Sms = array_utilities.cell2array( Sms );                                                                               % [-] Sodium Channel Activation Slope.
            Ams = array_utilities.cell2array( Ams );                                                                               % [-] Sodium Channel Activation Amplitude.
            Rs = array_utilities.cell2array( Rs );                                                                               	% [V] Activation Domain.
            Ers = array_utilities.cell2array( Ers );                                                                               % [V] Membrane Equilibrium Potential.
            Gms = array_utilities.cell2array( Gms );                                                                               % [S] Membrane Conductance.
            Cms = array_utilities.cell2array( Cms );                                                                               % [F] Membrane Capacitance.
            hs = array_utilities.cell2array( hs );                                                                                 % [-] Sodium Channel Deactivation Parameter.
            Us = array_utilities.cell2array( Us );                                                                                 % [V] Membrane Voltage.
            names = array_utilities.cell2array( names );                                                                           % [-] Neuron Name.
            IDs = array_utilities.cell2array( IDs );                                                                               % [#] Neuron ID.
            n_neurons = array_utilities.cell2array( n_neurons );
            
            % Ensure that the neuron properties match the required number of neurons.
            assert( self.validate_neuron_properties( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities ), 'Provided neuron properties must be of consistent size.' )
            
        end
        
        
        % Implement a function to process the neuron creation outputs.
        function [ IDs, neurons ] = process_neuron_creation_outputs( ~, IDs, neurons, as_cell_flag, array_utilities )
            
            % Set the default input arguments.
            if nargin < 5, array_utilities = self.array_utilities; end                      % [class] Array Utilities Class.
            if nargin < 4, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Determine whether to embed the new neuron IDs and objects in cells.
            if as_cell_flag                                                                 % If we want to embed the new neuron IDs and objects into cells...
                
                % Determine whether to embed the neuron IDs into a cell.
                if ~iscell( IDs )                                                           % If the IDs are not already a cell...
                
                    % Embed neuron IDs into a cell.
                    IDs = { IDs };
                
                end
                
                % Determine whether to embed the neuron objects into a cell.
                if ~iscell( neurons )                                                       % If the neurons are not already a cell...
                
                    % Embed neuron objects into a cell.
                    neurons = { neurons };
                    
                end
                
            else                                                                            % Otherwise...
                
                % Determine whether to embed the neuron IDs into an array.
                if iscell( IDs )                                                            % If the neuron IDs are a cell...
                
                    % Convert the neuron IDs cell to a regular array.
                    IDs = array_utilities.cell2array( IDs );
                    
                end
                
                % Determine whether to embed the neuron objects into an array.
                if iscell( neurons )                                                        % If the neuron objects are a cell...
                
                    % Convert the neuron objects cell to a regular array.
                    neurons = array_utilities.cell2array( neurons );
                    
                end
                
            end
            
        end
        
        
        % Implement a function to create a new neuron.
        function [ ID_new, neuron_new, neurons, self ] = create_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default neuron properties.
            if nargin < 29, array_utilities = self.array_utilites; end
            if nargin < 28, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 27, set_flag = self.set_flag_DEFAULT; end                                               % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 26, neurons = self.neurons; end                                                         % [class] Array of Neuron Class Objects.
            if nargin < 25, b_enabled = true; end                                                               % [T/F] Neuron Enabled Flag
            if nargin < 24, I_total = self.Itotal_DEFAULT; end                                                  % [A] Total Current
            if nargin < 23, I_app = self.Iapp_DEFFAULT; end                                                     % [A] Applied Current
            if nargin < 22, I_tonic = self.Itonic_DEFAULT; end                                                  % [A] Tonic Current
            if nargin < 21, I_na = self.Ina_DEFAULT; end                                                        % [A] Sodium Channel Current
            if nargin < 20, I_syn = self.Isyn_DEFAULT; end                                                      % [A] Synaptic Current
            if nargin < 19, I_leak = self.Ileak_DEFAULT; end                                                    % [A] Leak Current
            if nargin < 18, Gna = self.Gna_DEFAULT; end                                                         % [S] Sodium Channel Conductance
            if nargin < 17, tauh_max = self.tauh_max_DEFAULT; end                                               % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEna = self.dEna_DEFAULT; end                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEh = self.dEh_DEFAULT; end                                                         % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Sh = self.Sh_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ah = self.Ah_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEm = self.dEm_DEFAULT; end                                                         % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sm = self.Sm_DEFAULT; end                                                           % [-] Sodium Channel Activation Slope
            if nargin < 10, Am = self.Am_DEFAULT; end                                                           % [-] Sodium Channel Activation Amplitude
            if nargin < 9, R = self.R_DEFAULT; end                                                              % [V] Activation Domain
            if nargin < 8, Er = self.Er_DEFAULT; end                                                            % [V] Membrane Equilibrium Potential
            if nargin < 7, Gm = self.Gm_DEFAULT; end                                                            % [S] Membrane Conductance
            if nargin < 6, Cm = self.Cm_DEFAULT; end                                                            % [F] Membrane Capacitance
            if nargin < 5, h = [  ]; end                                                                        % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, U = 0; end                                                                           % [V] Membrane Voltage
            if nargin < 3, name = ''; end                                                                       % [-] Neuron Name
            if nargin < 2, ID = self.generate_unique_neuron_ID( neurons, array_utilities ); end                 % [#] Neuron ID
            
            % Process the neuron creation properties.
            [ ~, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled ] = self.process_neuron_creation_inputs( 1, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled, neurons, array_utilities );
            
            % Ensure that this neuron ID is a unique natural.
            assert( self.unique_natural_neuron_ID( ID, neurons, array_utilities ), 'Proposed neuron ID %0.2f is not a unique natural number.', ID )
            
            % Make an instance of the neuron manager.
            neuron_manager = self;
            
            % Create an instance of the neuron class.
            neuron_new = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled );
                        
            % Retrieve the new neuron ID.
            ID_new = neuron_new.ID;
            
            % Determine whether to embed the new neuron ID and object in cells.
            [ ID_new, neuron_new ] = self.process_neuron_creation_outputs( ID_new, neuron_new, as_cell_flag, array_utilities );
            
            % Append this neuron to the array of existing neurons.
            neurons = [ neurons, neuron_new ];
            
            % Update the neuron manager to reflect the update neurons object.
            neuron_manager.neurons = neurons;
            neuron_manager.num_neurons = length( neurons );
            
            % Determine whether to update the neuron manager object.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create multiple neurons.
        function [ IDs_new, neurons_new, neurons, self ] = create_neurons( self, n_neurons_to_create, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default neuron properties.
            if nargin < 30, array_utilities = self.array_utilities; end                                                             % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)                                                           % [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                                   % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                             % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, num_neurons_to_create ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, num_neurons_to_create ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, num_neurons_to_create ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, num_neurons_to_create ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, num_neurons_to_create ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, num_neurons_to_create ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, num_neurons_to_create ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, num_neurons_to_create ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, num_neurons_to_create ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, num_neurons_to_create ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, num_neurons_to_create ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, num_neurons_to_create ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, num_neurons_to_create ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, num_neurons_to_create ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, num_neurons_to_create ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, num_neurons_to_create ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, num_neurons_to_create ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, num_neurons_to_create ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( num_neurons_to_create, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, n_neurons_to_create = 1; end
            
            % Process the neuron creation inputs.
            [ n_neurons_to_create, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons_to_create, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate an array to store the new neurons.
            neurons_new = repmat( neuron_class(  ), [ 1, n_neurons_to_create ] );
            
            % Preallocate an array to store the new neuron IDs.
            IDs_new = zeros( 1, n_neurons_to_create );
            
            % Create an instance of the neuron manager that can be updated.
            neuron_manager = self;
            
            % Create each of the spcified neurons.
            for k = 1:n_neurons_to_create                                                                                           % Iterate through each of the neurons we want to create...
                
                % Create this neuron.
                [ IDs_new( k ), neurons_new( k ), neurons, neuron_manager ] = neuron_manager.create_neuron( IDs( k ), names{ k }, Us( k ), hs{ k }, Cms( k ), Gms( k ), Ers( k ), Rs( k ), Ams( k ), Sms( k ), dEms( k ), Ahs( k ), Shs( k ), dEhs( k ), dEnas( k ), tauh_maxs( k ), Gnas( k ), I_leaks( k ), I_syns( k ), I_nas( k ), I_tonics( k ), I_apps( k ), I_totals( k ), b_enableds( k ), neurons, true, false, array_utilities );
                
            end
            
            % Determine whether to embed the new neuron IDs and objects in cells.
            if as_cell_flag                                                                                                         % If we want to embed the new neuron IDs and objects in cells...
                
                % Embed the new neuron IDs in a cell.
                IDs_new = { IDs_new };
                
                % Embed the new neuron objects in a cell.
                neurons_new = { neurons_new };
                
            end
            
            % Determine whether to update the neuron manager object.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to delete a neuron.
        function [ neurons, self ] = delete_neuron( self, neuron_ID, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID, neurons, undetected_option );
            
            % Remove this neuron from the array of neurons.
            neurons( neuron_index ) = [  ];
            
            % Determine whether to update the neuron manager object.
            if set_flag                                                                     % If we want to update the neuron manager object...
                
                % Update the neuron property.
                self.neurons = neurons;
                
                % Decrease the number of neurons counter.
                self.num_neurons = self.num_neurons - 1;
                
            end
            
        end
        
        
        % Implement a function to delete multiple neurons.
        function [ neurons, self ] = delete_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the number of neurons to delete.
            num_neurons_to_delete = length( neuron_IDs );
            
            % Delete each of the specified neurons.
            for k = 1:num_neurons_to_delete                                                 % Iterate through each of the neurons we want to delete...
                
                % Delete this neuron.
                [ neurons, self ] = self.delete_neuron( neuron_IDs( k ), neurons, set_flag, undetected_option );
                
            end
            
        end
        
        
        % Implement a function to update the neuron manager.
        function [ neurons, self ] = update_neuron_manager( self, neurons, neuron_manager, set_flag )
        
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end            % [T/F] Set Flag (Determines whether output self object is updated.)
            
            % Determine whether to update the neuron manager object.
            if set_flag                                                  	% If we want to update the neuron manager object...
                
                % Update the neuron manager object.
                self = neuron_manager;
            
            else                                                            % Otherwise...
                
                % Reset the neurons object.
                neurons = self.neurons;
            
            end
            
        end
        
        
        %% Subnetwork Neuron Quantity Functions.
        
        % Implement a function to compute the number of centered double subtraction neurons.
        function [ n_cds_neurons, n_ds_neurons, n_dc_neurons ] = compute_num_cds_neurons( self )
            
            % Compute the number of double subtraction neurons.
            n_ds_neurons = self.num_double_subtraction_neurons_DEFAULT;
            
            % Compute the number of double centering neurons.
            n_dc_neurons = self.num_double_centering_neurons_DEFAULT;
            
            % Compute the number of centered double subtraction neurons.
            n_cds_neurons = n_ds_neurons + n_dc_neurons;
            
        end
        
        
        % Implement a function to compute the number of multistate cpg neurons.
        function n_mcpg_neurons = compute_num_mcpg_neurons( self, num_cpg_neurons )
        
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.          
            
            % Compute the number of multistate cpg neurons.
            n_mcpg_neurons = num_cpg_neurons;
            
        end
        
        
        % Implement a function to compute the number of driven multistate cpg neurons.
        function [ n_dmcpg_neurons, n_mcpg_neurons ] = compute_num_dmcpg_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.
            
            % Compute the number of multistate cpg neurons.
            n_mcpg_neurons = self.compute_num_mcpg_neurons( num_cpg_neurons );
            
            % Compute the number of driven multistate cpg neurons.
            n_dmcpg_neurons = n_mcpg_neurons + 1;
            
        end
        
        
        % Implement a function to compute the number of modulated split voltage based integration neurons.
        function [ n_msvbi_neurons, n_vsbi_neurons, n_new_msvbi_neurons ] = compute_num_msvbi_neurons( self )
            
            % Compute the number of split voltage based integration neurons.
            n_vsbi_neurons = self.num_svbi_neurons_DEFAULT;
            
            % Compute the number of new modulated split voltage based integration neurons.
            n_new_msvbi_neurons = self.num_new_msvbi_neurons_DEFAULT;
            
            % Compute the number of modulated split voltaged based integration neurons.
            n_msvbi_neurons = n_vsbi_neurons + n_new_msvbi_neurons;
            
        end
        
        
        % Implement a function to compute the number of modulated split difference voltage based integration neurons.
        function [ n_mssvbi_neurons, n_ds_neurons, n_msvbi_neurons ] = compute_num_mssvbi_neurons( self )
            
            % Compute the number of double subtraction neurons.
            n_ds_neurons = self.num_double_subtraction_neurons_DEFAULT;
            
            % Compute the number of modulated split voltage based integration neurons.
            [ n_msvbi_neurons, ~, ~ ] = self.compute_num_msvbi_neurons(  );
            
            % Compute the number of modulated split difference voltage based integration neurons.
            n_mssvbi_neurons = n_ds_neurons + n_msvbi_neurons;
            
        end
        
        
        % Implement a function to compute the number of dmcpg sll neurons.
        function [ n_dmcpg_sll_neurons, n_dmcpg_neurons, n_mssvbi_neurons, n_sll_neurons ] = compute_num_dmcpg_sll_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.
            
            % Compute the number of neurons for a driven multistate cpg.
            [ n_dmcpg_neurons, ~ ] = self.compute_num_dmcpg_neurons( num_cpg_neurons );
            
            % Compute the number of neurons for a modulated split subtraction voltage based integration subnetwork.
            [ n_mssvbi_neurons, ~, ~ ] = self.compute_num_mssvbi_neurons(  );
            
            % Compute the number of neurons for a split lead lag subnetwork.
            n_sll_neurons = self.num_sll_neurons_DEFAULT;
            
            % Compute the number of driven multistate cpg split lead lag neurons.
            n_dmcpg_sll_neurons = 2*n_dmcpg_neurons + num_cpg_neurons*n_mssvbi_neurons + n_sll_neurons;
            
        end
        
        
        % Implement a function to compute the number of dmcpg dcll neurons.
        function [ n_dmcpg_dcll_neurons, n_dmcpg_sll_neurons, n_dc_neurons ] = compute_num_dmcpg_dcll_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.
            
            % Compute the number of dmcpg sll neurons.
            [ n_dmcpg_sll_neurons, ~, ~, ~ ] = self.compute_num_dmcpg_sll_neurons( num_cpg_neurons );
            
            % Compute the number of double centering neurons.
            n_dc_neurons = self.num_double_centering_neurons_DEFAULT;
            
            % Compute the number of dmcpg dcll neurons.
            n_dmcpg_dcll_neurons = n_dmcpg_sll_neurons + n_dc_neurons;
            
        end
        
        
        % Implement a function to compute the number of open loop driven multistate central pattern generator double centering lead lag error subnetwork.
        function [ n_ol_dmcpg_dclle_neurons, n_dmcpg_dcll_neurons, n_cds_neurons, n_dmcpgdcll2cds_neurons ] = compute_num_ol_dmcpg_dclle_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.
            
            % Compute the number of dmcpg dcll neurons.
            [ n_dmcpg_dcll_neurons, ~, ~ ] = self.compute_num_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Compute the number of centered double subtraction neurons.
            [ n_cds_neurons, ~, ~ ] = self.compute_num_cds_neurons(  );
            
            % Compute the number of dmcpgdcll2cds neurons.
            n_dmcpgdcll2cds_neurons = self.num_dmcpgdcll2cds_neurons_DEFAULT;
            
            % Compute the number of ol dmcpg dclle neurons.
            n_ol_dmcpg_dclle_neurons = n_dmcpg_dcll_neurons + n_cds_neurons + n_dmcpgdcll2cds_neurons;
            
        end
        
        
        % Implement a function to compute the number of closed loop proportional control driven multistate central pattern generator double centering lead lag subnetwork.
        function [ n_clpc_dmcpg_dcll_neurons, n_dmcpg_dcll_neurons, n_cds_neurons, n_dmcpgdcll2cds_neurons ] = compute_num_clpc_dmcpg_dcll_neurons( self, num_cpg_neurons )
            
            % Set the default input arguments.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end          % [#] Number of CPG Neurons.
            
            % Compute the number of closed loop proportional control driven multistate central pattern generator double centering lead lag subnetwork.
            [ n_clpc_dmcpg_dcll_neurons, n_dmcpg_dcll_neurons, n_cds_neurons, n_dmcpgdcll2cds_neurons ] = self.compute_num_ol_dmcpg_dclle_neurons( num_cpg_neurons );
            
        end
        
        
        %% Subnetwork Neuron Creation Functions.
        
        % Implement a function to create the neurons for a multistate CPG oscillator subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_mcpg_neurons( self, n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of multistate cpg neurons.
            if nargin < 2, n_neurons = self.num_cpg_neurons_DEFAULT; end                                                % [#] Number of CPG Neurons.

            % Set the default neuron properties.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            
            % Process the multistate cpg neuron properties.
            [ n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to update the names.
            if all( [ names{ : } ] == '' )                                                                              % If all of the names are empty...
                
                % Define the neuron names.
                for k = 1:n_neurons                                                                                     % Iterate through each of the neurons...
                    
                    % Define the name associated with this neuron.
                    names{ k } = sprintf( 'CPG Neuron %0.0f', IDs( k ) );
                    
                end
                
            end
            
            % Create the multistate cpg subnetwork neurons.
            [ IDs_new, neurons_new, neurons, neuron_manager ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, true, as_cell_flag, array_utilities );
 
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for a multistate CPG oscillator subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_dmcpg_neurons( self, num_cpg_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of cpg neurons.
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                          % [#] Number of CPG Neurons.
            
            % Compute the number of drive multistate cpg neurons.
            [ n_neurons, n_mcpg_neurons ] = self.compute_num_dmcpg_neurons( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                           	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            
            % Process the dmcpg inputs.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );

            % Preallocate a cell array to store the new neuron IDs and objects.
            IDs_new = cell( 1, 2 );
            neurons_new = cell( 1, 2 );
            
            % Define the indexes for the mcpg subnetwork.
            i_start_mcpg = 1;
            i_end_mcpg = n_mcpg_neurons;
            
            % Create the neurons for a multistate cpg subnetwork.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_mcpg_neurons( num_cpg_neurons, IDs( i_start_mcpg:i_end_mcpg ), names{ i_start_mcpg:i_end_mcpg }, Us( i_start_mcpg:i_end_mcpg ), hs( i_start_mcpg:i_end_mcpg ), Cms( i_start_mcpg:i_end_mcpg ), Gms( i_start_mcpg:i_end_mcpg ), Ers( i_start_mcpg:i_end_mcpg ), Rs( i_start_mcpg:i_end_mcpg ), Ams( i_start_mcpg:i_end_mcpg ), Sms( i_start_mcpg:i_end_mcpg ), dEms( i_start_mcpg:i_end_mcpg ), Ahs( i_start_mcpg:i_end_mcpg ), Shs( i_start_mcpg:i_end_mcpg ), dEhs( i_start_mcpg:i_end_mcpg ), dEnas( i_start_mcpg:i_end_mcpg ), tauh_maxs( i_start_mcpg:i_end_mcpg ), Gnas( i_start_mcpg:i_end_mcpg ), I_leaks( i_start_mcpg:i_end_mcpg ), I_syns( i_start_mcpg:i_end_mcpg ), I_nas( i_start_mcpg:i_end_mcpg ), I_tonics( i_start_mcpg:i_end_mcpg ), I_apps( i_start_mcpg:i_end_mcpg ), I_totals( i_start_mcpg:i_end_mcpg ), b_enableds( i_start_mcpg:i_end_mcpg ), neurons, true, false, array_utilities );
            
            % Define the indexes for the drive neuron.
            i_start_d = i_end_mcpg + 1;
            i_end_d = i_end_mcpg + 1;
            
            % Determine whether to update the default or provided CPG drive neuron name.
            if isempty( names{ i_start_d:i_end_d } )                                                                    % If the final name is empty...
                
                % Set the drive neuron name.
                names{ i_start_d:i_end_d } = 'CPG Drive';
                
            end 
            
            % Create an additional neuron to drive the multistate cpg.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_neuron( IDs( i_start_d:i_end_d ), names{ i_start_d:i_end_d }, Us( i_start_d:i_end_d ), hs( i_start_d:i_end_d ), Cms( i_start_d:i_end_d ), Gms( i_start_d:i_end_d ), Ers( i_start_d:i_end_d ), Rs( i_start_d:i_end_d ), Ams( i_start_d:i_end_d ), Sms( i_start_d:i_end_d ), dEms( i_start_d:i_end_d ), Ahs( i_start_d:i_end_d ), Shs( i_start_d:i_end_d ), dEhs( i_start_d:i_end_d ), dEnas( i_start_d:i_end_d ), tauh_maxs( i_start_d:i_end_d ), Gnas( i_start_d:i_end_d ), I_leaks( i_start_d:i_end_d ), I_syns( i_start_d:i_end_d ), I_nas( i_start_d:i_end_d ), I_tonics( i_start_d:i_end_d ), I_apps( i_start_d:i_end_d ), I_totals( i_start_d:i_end_d ), b_enableds( i_start_d:i_end_d ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for a driven multistate cpg split lead lag subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_dmcpg_sll_neurons( self, num_cpg_neurons, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Compute the number of neurons.
            [ n_neurons, n_dmcpg_neurons, n_mssvbi_neurons, n_sll_neurons ] = self.compute_num_dmcpg_sll_neurons( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 31, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 30, as_cell_flag = self.as_cell_flag_DEFAULT; end                                              	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 29, set_flag = self.set_flag_DEFAULT; end                                                   	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 28, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 27, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 26, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 25, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 24, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 23, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 22, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 21, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 20, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 19, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 18, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 17, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 16, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 15, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 14, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 13, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 12, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 11, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 10, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                          	% [V] Membrane Equilibrium Potential
            if nargin < 9, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 8, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 7, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 6, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 5, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 4, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 3, network_type = 'Absolute'; end
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                          % [#] Number of CPG Neurons.
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );

            % Preallocate a cell array to store the new neuron IDs and neuron objects.
            IDs_new = cell( 1, num_cpg_neurons + 3 );
            neurons_new = cell( 1, num_cpg_neurons + 3 );
            
            % Define the indexes of the neurons for the first driven multistate CPG.
            i_start1 = 1;
            i_end1 = n_dmcpg_neurons;
            
            % Create the first driven multistate CPG subnetwork neurons.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_dmcpg_neurons( num_cpg_neurons, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Define the indexes of the neurons for the second driven multistate CPG.
            i_start2 = i_end1 + 1;
            i_end2 = i_end1 + n_dmcpg_neurons;
            
            % Create the second driven multistate CPG subnetwork neurons.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_dmcpg_neurons( num_cpg_neurons, IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Create the modulated split subtraction voltage based integration subnetwork neurons for each pair of driven multistate cpg neurons.
            for k = 1:num_cpg_neurons                                                                                   % Iterate through each of the cpg neurons...
                
                % Define the indexes of the neurons for the modulated split subtration voltage based integration subnetwork.
                i_start3 = i_end2 + ( k - 1 )*n_mssvbi_neurons + 1;
                i_end3 = i_end2 + k*n_mssvbi_neurons;
                
                % Create the modulated split difference voltage based integration subnetwork neurons.
                [ IDs_new{ k + 2 }, neurons_new{ k + 2 }, neurons, neuron_manager ] = neuron_manager.create_mssvbi_neurons( network_type, IDs( i_start3:i_end3 ), names( i_start3:i_end3 ), Us( i_start3:i_end3 ), hs( i_start3:i_end3 ), Cms( i_start3:i_end3 ), Gms( i_start3:i_end3 ), Ers( i_start3:i_end3 ), Rs( i_start3:i_end3 ), Ams( i_start3:i_end3 ), Sms( i_start3:i_end3 ), dEms( i_start3:i_end3 ), Ahs( i_start3:i_end3 ), Shs( i_start3:i_end3 ), dEhs( i_start3:i_end3 ), dEnas( i_start3:i_end3 ), tauh_maxs( i_start3:i_end3 ), Gnas( i_start3:i_end3 ), I_leaks( i_start3:i_end3 ), I_syns( i_start3:i_end3 ), I_nas( i_start3:i_end3 ), I_tonics( i_start3:i_end3 ), I_apps( i_start3:i_end3 ), I_totals( i_start3:i_end3 ), b_enableds( i_start3:i_end3 ), neurons, true, false, array_utilities );
                
            end
            
            % Define the unique driven multistate cpg split lead lag indexes.
            i_start4 = i_end3 + 1;
            i_end4 = i_end3 + n_sll_neurons;
            
            % Ensure that there names for the split lead-lag neurons.
            if isempty( names( i_start4:i_end4 ) )                                                                      % If the sll neuron names are empty...
                
                % Set the drive neuron name.
                names( i_start4:i_end4 ) = { 'Fast Lead', 'Fast Lag', 'Slow Lead', 'Slow Lag' };
                
            end
            
            % Create the unique driven multistate cpg split lead lag neurons.
            [ IDs_new{ end }, neurons_new{ end }, neurons, neuron_manager ] = neuron_manager.create_neurons( n_sll_neurons, IDs( i_start4:i_end4 ), names( i_start4:i_end4 ), Us( i_start4:i_end4 ), hs( i_start4:i_end4 ), Cms( i_start4:i_end4 ), Gms( i_start4:i_end4 ), Ers( i_start4:i_end4 ), Rs( i_start4:i_end4 ), Ams( i_start4:i_end4 ), Sms( i_start4:i_end4 ), dEms( i_start4:i_end4 ), Ahs( i_start4:i_end4 ), Shs( i_start4:i_end4 ), dEhs( i_start4:i_end4 ), dEnas( i_start4:i_end4 ), tauh_maxs( i_start4:i_end4 ), Gnas( i_start4:i_end4 ), I_leaks( i_start4:i_end4 ), I_syns( i_start4:i_end4 ), I_nas( i_start4:i_end4 ), I_tonics( i_start4:i_end4 ), I_apps( i_start4:i_end4 ), I_totals( i_start4:i_end4 ), b_enableds( i_start4:i_end4 ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for a driven multistate cpg double centered lead lag subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_dmcpg_dcll_neurons( self, num_cpg_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Compute the number of neurons.
            [ n_neurons, n_dmcpg_sll_neurons, n_dc_neurons ] = self.compute_num_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                    	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                          % [#] Number of CPG Neurons.
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate a cell array to store the neuron objects and IDs.
            IDs_new = cell( 1, 2 );
            neurons_new = cell( 1, 2 );
            
            % Define the indexes associated with the dmcpgsll subnetwork.
            i_start1 = 1;
            i_end1 = n_dmcpg_sll_neurons;
            
            % Create the neurons for a driven multistate cpg split lead lag subnetwork.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_dmcpg_sll_neurons( num_cpg_neurons, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Define the indexes associated with the double centering subnetwork.
            i_start2 = i_end1 + 1;
            i_end2 = i_end1 + n_dc_neurons;
            
            % Create the neurons for a double centering subnetwork.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_double_centering_neurons( IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implemenet a function to create the neurons that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the double centered subtraction subnetwork.
        function [ ID_new, neuron_new, neurons, self ] = create_dmcpgdcll2cds_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default neuron properties.
            if nargin < 29, array_utilities = self.array_utilites; end
            if nargin < 28, as_cell_flag = self.as_cell_flag_DEFAULT; end                                    	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 27, set_flag = self.set_flag_DEFAULT; end                                               % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 26, neurons = self.neurons; end                                                       	% [class] Array of Neuron Class Objects.
            if nargin < 25, b_enabled = true; end                                                               % [T/F] Neuron Enabled Flag
            if nargin < 24, I_total = self.Itotal_DEFAULT; end                                                  % [A] Total Current
            if nargin < 23, I_app = self.Iapp_DEFFAULT; end                                                     % [A] Applied Current
            if nargin < 22, I_tonic = self.Itonic_DEFAULT; end                                                  % [A] Tonic Current
            if nargin < 21, I_na = self.Ina_DEFAULT; end                                                        % [A] Sodium Channel Current
            if nargin < 20, I_syn = self.Isyn_DEFAULT; end                                                      % [A] Synaptic Current
            if nargin < 19, I_leak = self.Ileak_DEFAULT; end                                                    % [A] Leak Current
            if nargin < 18, Gna = self.Gna_DEFAULT; end                                                         % [S] Sodium Channel Conductance
            if nargin < 17, tauh_max = self.tauh_max_DEFAULT; end                                               % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEna = self.dEna_DEFAULT; end                                                       % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEh = self.dEh_DEFAULT; end                                                         % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Sh = self.Sh_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ah = self.Ah_DEFAULT; end                                                           % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEm = self.dEm_DEFAULT; end                                                         % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sm = self.Sm_DEFAULT; end                                                           % [-] Sodium Channel Activation Slope
            if nargin < 10, Am = self.Am_DEFAULT; end                                                           % [-] Sodium Channel Activation Amplitude
            if nargin < 9, R = self.R_DEFAULT; end                                                              % [V] Activation Domain
            if nargin < 8, Er = self.Er_DEFAULT; end                                                            % [V] Membrane Equilibrium Potential
            if nargin < 7, Gm = self.Gm_DEFAULT; end                                                            % [S] Membrane Conductance
            if nargin < 6, Cm = self.Cm_DEFAULT; end                                                            % [F] Membrane Capacitance
            if nargin < 5, h = [  ]; end                                                                        % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, U = 0; end                                                                           % [V] Membrane Voltage
            if nargin < 3, name = 'Desired Lead / Lag'; end                                                 	% [-] Neuron Name
            if nargin < 2, ID = self.generate_unique_neuron_ID( neurons, array_utilities ); end              	% [#] Neuron ID
            
            % Process the neuron creation properties.
            [ ~, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled ] = self.process_neuron_creation_inputs( 1, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled, neurons, array_utilities );
            
            % Create the desired lead lag input neuron.
            [ ID_new, neuron_new, neurons, self ] = self.create_neuron( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total, b_enabled, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_ol_dmcpg_dclle_neurons( self, num_cpg_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Compute the number of neurons.
            [ n_neurons, n_dmcpg_dcll_neurons, n_cds_neurons, ~ ] = self.compute_num_ol_dmcpg_dclle_neurons( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                          % [#] Number of CPG Neurons.
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate a cell to store the neuron IDs and objects.
            IDs_new = cell( 1, 3 );
            neurons_new = cell( 1, 3 );
            
            % Define the indexes associated with the dmcpg dcll neurons.
            i_start1 = 1;
            i_end1 = n_dmcpg_dcll_neurons;
            
            % Create the neurons for a driven multistate cpg double centered lead lag subnetwork.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_dmcpg_dcll_neurons( num_cpg_neurons, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Define the indexes associated with the double subtraction neurons.
            i_start2 = i_end1 + 1;
            i_end2 = i_end1 + n_cds_neurons;
            
            % Create the neurons for a centered double subtraction subnetwork.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_cds_neurons( IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Create the neurons that assist in connecting the driven multistate cpg double centered lead lag subnetwork to the double centered subtraction subnetwork.
            [ IDs_new{ 3 }, neurons_new{ 3 }, neurons, neuron_manager ] = neuron_manager.create_dmcpgdcll2cds_neuron( IDs( end ), names( end ), Us( end ), hs( end ), Cms( end ), Gms( end ), Ers( end ), Rs( end ), Ams( end ), Sms( end ), dEms( end ), Ahs( end ), Shs( end ), dEhs( end ), dEnas( end ), tauh_maxs( end ), Gnas( end ), I_leaks( end ), I_syns( end ), I_nas( end ), I_tonics( end ), I_apps( end ), I_totals( end ), b_enableds( end ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for an closed loop P controlled driven multistate cpg double centered lead lag subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_clpc_dmcpg_dcll_neurons( self, num_cpg_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Compute the number of neurons.
            [ n_neurons, ~, ~, ~ ] = self.compute_num_clpc_dmcpg_dcll_neurons( num_cpg_neurons );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end                                          % [#] Number of CPG Neurons.
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Create the neurons for an open loop driven multistate cpg double centered lead lag error subnetwork.
            [ IDs_new, neurons_new, neurons, neuron_manager ] = self.create_ol_dmcpg_dclle_neurons( num_cpg_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for a transmission subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_transmission_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_transmission_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Transmission Input' ], [ network_type, ' Transmission Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a modulation subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_modulation_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_modulation_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Validate the neuron properties.
            assert( self.validate_neuron_properties( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities ), 'Modulation subnetworks must contain exactly two neurons.' )
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Modulation Input' ], [ network_type, ' Modulation Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for an addition subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_addition_neurons( self, network_type, n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of neurons.
            if nargin < 3, n_neurons = self.num_addition_neurons_DEFAULT; end
            
            % Ensure that the specified number of neurons is valid.
            assert( n_neurons > 1, 'Addition subnetworks must consist of at least two neurons.' );
            
            % Set the default input arguments.
            if nargin < 31, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 30, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 29, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 28, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 27, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 26, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 25, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 24, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 23, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 22, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 21, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 20, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 19, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 18, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 17, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 16, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 15, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 14, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 13, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 12, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 11, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 10, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                         	% [V] Membrane Equilibrium Potential
            if nargin < 9, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 8, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 7, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 6, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 5, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 4, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Determine how to specify the names of the addition neurons.
                if n_neurons ==  2                                                                                    	% If this subnetwork has exactly two neurons...
                    
                    % Define the name of the single input neuron.
                    names{ 1 } = [ network_type, ' Addition Input' ];
                    
                elseif n_neurons > 2                                                                                    % If this subnetwork has more than two neurons...
                    
                    for k = 1:( n_neurons - 1 )                                                                         % Iterate through each of the neurons...
                        
                        % Define the default input neuron names.
                        names{ k } = sprintf( '%s Addition Input %0.0f', network_type, k );
                        
                    end
                    
                else                                                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Addition subnetworks must consist of at least two neurons.' )
                    
                end
                
                % Define the default output neuron names.
                names{ end } = [ network_type, ' Addition Output' ];
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a subtraction subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_subtraction_neurons( self, network_type, n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the default number of neurons.
            if nargin < 3, n_neurons = self.num_subtraction_neurons_DEFAULT; end
            
            % Ensure that the specified number of neurons is valid.
            assert( n_neurons > 1, 'Subtraction subnetworks must consist of at least two neurons.' );
            
            % Set the default input arguments.
            if nargin < 31, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 30, as_cell_flag = self.as_cell_flag_DEFAULT; end                                              	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 29, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 28, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 27, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 26, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 25, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 24, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 23, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 22, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 21, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 20, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 19, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 18, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 17, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 16, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 15, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 14, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 13, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 12, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 11, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 10, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                            	% [V] Membrane Equilibrium Potential
            if nargin < 9, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 8, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 7, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 6, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 5, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 4, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Determine how to specify the names of the addition neurons.
                if n_neurons ==  2                                                                                      % If this subnetwork has exactly two neurons...
                    
                    % Define the name of the single input neuron.
                    names{ 1 } = [ network_type, ' Subtraction Input' ];
                    
                elseif n_neurons > 2                                                                                    % If this subnetwork has more than two neurons...
                    
                    for k = 1:( n_neurons - 1 )                                                                         % Iterate through each of the neurons...
                        
                        % Define the default input neuron names.
                        names{ k } = sprintf( '%s Subtraction Input %0.0f', network_type, k );
                        
                    end
                    
                else                                                                                                    % Otherwise...
                    
                    % Throw an error.
                    error( 'Subtraction subnetworks must consist of at least two neurons.' )
                    
                end
                
                % Define the default output neuron names.
                names{ end } = [ network_type, ' Subtraction Output' ];
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a double subtraction subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_double_subtraction_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons.
            n_neurons = self.num_double_subtraction_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the neuron names.
                names = { [ network_type, ' Subtraction Input 1' ], [ network_type, ' Subtraction Input 2' ], [ network_type, ' Subtraction Output 1' ], [ network_type, ' Subtraction Output 2' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a centering subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_centering_neurons( self, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons.
            n_neurons = self.num_centering_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 29, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 28, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 27, set_flag = self.set_flag_DEFAULT; end                                                     	% [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 26, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 25, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 24, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 23, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 22, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 21, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 20, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 19, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 18, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 17, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 10, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 9, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 8, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 7, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 6, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 5, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 3, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 2, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the neuron names.
                names = { 'Center 1', 'Center 2', 'Center 3', 'Center 4', 'Center 5' };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a double centering subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_double_centering_neurons( self, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons.
            n_neurons = self.num_double_centering_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 29, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 28, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 27, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 26, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 25, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 24, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 23, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 22, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 21, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 20, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 19, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 18, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 17, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 16, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 15, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 14, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 13, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 12, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 11, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 10, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 9, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 8, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 7, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 6, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 5, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 4, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 3, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 2, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the neuron names.
                names = { 'Center 1', 'Center 2', 'Center 3', 'Center 4', 'Center 5', 'Center 6', 'Center 7' };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a centered double subtraction subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_cds_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons.
            [ n_neurons, n_ds_neurons, n_dc_neurons ] = self.compute_num_cds_neurons(  );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate a cell array to store the neuron IDs and objects.
            IDs_new = cell( 1, 2 );
            neurons_new = cell( 1, 2 );
            
            % Set the indexes associated with the double subtraction neurons.
            i_start1 = 1;                                                                                               % [#] Starting Index 1.
            i_end1 = n_ds_neurons;                                                                                      % [#] Ending Index 1.
            
            % Create the double subtraction subnetwork neurons.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_double_subtraction_neurons( network_type, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Set the indexes associated with the double centering neurons.
            i_start2 = i_end1 + 1;                                                                                  	% [#] Starting Index 2.
            i_end2 = i_end1 + n_dc_neurons;                                                                             % [#] Ending Index 2.
            
            % Create the double centering subnetwork neurons.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_double_centering_neurons( IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the neurons for a multiplication subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_multiplication_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Set the number of neurons.
            n_neurons = self.num_multiplication_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                              	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the neuron names.
                names = { [ network_type, ' Multiplication Input 1' ], [ network_type, ' Multiplication Input 2' ], [ network_type, ' Multiplication Interneuron' ], [ network_type, ' Multiplication Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for an inversion subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_inversion_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_inversion_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Inversion Input' ], [ network_type, ' Inversion Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a division subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_division_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_division_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Division Input 1' ], [ network_type, ' Division Input 2' ], [ network_type, ' Division Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for a derivation subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_derivation_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_derivation_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                            	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Derivation Input 1' ], [ network_type, ' Derivation Input 2' ], [ network_type, ' Derivation Output' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the neurons for an integration subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_integration_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_integration_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                              	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Integration Neuron 1' ], [ network_type, ' Integration Neuron 2' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the voltage based neurons for an integration subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_vbi_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_vbi_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Integration Neuron 1' ], [ network_type, ' Integration Neuron 2' ], [ network_type, ' Interneuron 1' ], [ network_type, ' Interneuron 2' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the split voltage based neurons for an integration subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_svbi_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            n_neurons = self.num_svbi_neurons_DEFAULT;
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Determine whether to use default names.
            if all( [ names{ : } ] == '' )                                                                              % If the names are empty...
                
                % Define the default neuron names.
                names = { [ network_type, ' Integration 1' ], [ network_type, ' Integration 2' ], [ network_type, ' Integration 3' ], [ network_type, ' Integration 4' ], [ network_type, ' Subtraction 1' ], [ network_type, ' Subtraction 2' ], [ network_type, ' Subtraction 3' ], [ network_type, ' Subtraction 4' ], [ network_type, ' Equilibrium 1' ] };
                
            end
            
            % Create the subnetwork neurons.
            [ IDs_new, neurons_new, neurons, self ] = self.create_neurons( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities );
            
        end
        
        
        % Implement a function to create the modulated split voltage based neurons for an integration subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_msvbi_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            [ n_neurons, n_vsbi_neurons, n_new_msvbi_neurons ] = self.compute_num_msvbi_neurons(  );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                             	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate an array to store the neuron IDs and objects.
            IDs_new = cell( 1, 2 );
            neurons_new = cell( 1, 2 );
            
            % Define the split voltage based integration neuron indexes.
            i_start1 = 1;
            i_end1 = n_vsbi_neurons;
            
            % Create the split voltage based integration neurons.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_svbi_neurons( network_type, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Define the modulated split voltage based integration neuron indexes.
            i_start2 = i_end1 + 1;
            i_end2 = i_end1 + n_new_msvbi_neurons;
            
            % Create the modulated split voltage based integration subnetwork neurons.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_neurons( n_new_msvbi_neurons, IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Set the names of the modulated split voltage based integration subnetwork neurons.
            neuron_manager = neuron_manager.set_neuron_property( neuron_IDs2, { 'Modulation 1', 'Modulation 2', 'Modulation 3' }, 'name' );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        % Implement a function to create the modulated split difference voltage based neurons for an integration subnetwork.
        function [ IDs_new, neurons_new, neurons, self ] = create_mssvbi_neurons( self, network_type, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, set_flag, as_cell_flag, array_utilities )
            
            % Define the number of neurons.
            [ n_neurons, n_ds_neurons, n_msvbi_neurons ] = self.compute_num_mssvbi_neurons(  );
            
            % Set the default input arguments.
            if nargin < 30, array_utilities = self.array_utilities; end                                                 % [class] Array Utilities Class.
            if nargin < 29, as_cell_flag = self.as_cell_flag_DEFAULT; end                                              	% [T/F] As Cell Flag (Determines whether neurons are returned in an array or a cell.)
            if nargin < 28, set_flag = self.set_flag_DEFAULT; end                                                       % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 27, neurons = self.neurons; end                                                                 % [class] Array of Neuron Class Objects.
            if nargin < 26, b_enableds = true( 1, n_neurons ); end                                                      % [T/F] Neuron Enabled Flag
            if nargin < 25, I_totals = self.Itotal_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Total Current
            if nargin < 24, I_apps = self.Iapp_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Applied Current
            if nargin < 23, I_tonics = self.Itonic_DEFAULT*ones( 1, n_neurons ); end                                    % [A] Tonic Current
            if nargin < 22, I_nas = self.Ina_DEFAULT*ones( 1, n_neurons ); end                                          % [A] Sodium Channel Current
            if nargin < 21, I_syns = self.Isyn_DEFAULT*ones( 1, n_neurons ); end                                        % [A] Synaptic Current
            if nargin < 20, I_leaks = self.Ileak_DEFAULT*ones( 1, n_neurons ); end                                      % [A] Leak Current
            if nargin < 19, Gnas = self.Gna_DEFAULT*ones( 1, n_neurons ); end                                           % [S] Sodium Channel Conductance
            if nargin < 18, tauh_maxs = self.tauh_max_DEFAULT*ones( 1, n_neurons ); end                                 % [s] Maximum Sodium Channel Deactivation Time Constant
            if nargin < 17, dEnas = self.dEna_DEFAULT*ones( 1, n_neurons ); end                                         % [V] Sodium Channel Reversal Potential
            if nargin < 16, dEhs = self.dEh_DEFAULT*ones( 1, n_neurons ); end                                           % [V] Sodium Channel Deactivation Reversal Potential
            if nargin < 15, Shs = self.Sh_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Slope
            if nargin < 14, Ahs = self.Ah_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Deactivation Amplitude
            if nargin < 13, dEms = self.dEm_DEFAULT*ones( 1, n_neurons ); end                                           % [-] Sodium Channel Activation Reversal Potential
            if nargin < 12, Sms = self.Sm_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Slope
            if nargin < 11, Ams = self.Am_DEFAULT*ones( 1, n_neurons ); end                                             % [-] Sodium Channel Activation Amplitude
            if nargin < 10, Rs = self.R_DEFAULT*ones( 1, n_neurons ); end                                             	% [V] Activation Domain
            if nargin < 9, Ers = self.Er_DEFAULT*ones( 1, n_neurons ); end                                              % [V] Membrane Equilibrium Potential
            if nargin < 8, Gms = self.Gm_DEFAULT*ones( 1, n_neurons ); end                                              % [S] Membrane Conductance
            if nargin < 7, Cms = self.Cm_DEFAULT*ones( 1, n_neurons ); end                                              % [F] Membrane Capacitance
            if nargin < 6, hs = repmat( { [  ] }, 1, n_neurons ); end                                                   % [-] Sodium Channel Deactivation Parameter
            if nargin < 5, Us = zeros( 1, n_neurons ); end                                                              % [V] Membrane Voltage
            if nargin < 4, names = repmat( { '' }, 1, n_neurons ); end                                                  % [-] Neuron Name
            if nargin < 3, IDs = self.generate_unique_neuron_IDs( n_neurons, neurons, array_utilities ); end          	% [#] Neuron ID
            if nargin < 2, network_type = 'Absolute'; end
            
            % Process the input information.
            [ ~, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds ] = self.process_neuron_creation_inputs( n_neurons, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals, b_enableds, neurons, array_utilities );
            
            % Preallocate an array to store the neuron IDs and objects.
            IDs_new = cell( 1, 2 );
            neurons_new = cell( 1, 2 );
            
            % Define the double subtraction neuron indexes.
            i_start1 = 1;
            i_end1 = n_ds_neurons;
            
            % Create the double subtraction neurons.
            [ IDs_new{ 1 }, neurons_new{ 1 }, neurons, neuron_manager ] = self.create_double_subtraction_neurons( network_type, IDs( i_start1:i_end1 ), names( i_start1:i_end1 ), Us( i_start1:i_end1 ), hs( i_start1:i_end1 ), Cms( i_start1:i_end1 ), Gms( i_start1:i_end1 ), Ers( i_start1:i_end1 ), Rs( i_start1:i_end1 ), Ams( i_start1:i_end1 ), Sms( i_start1:i_end1 ), dEms( i_start1:i_end1 ), Ahs( i_start1:i_end1 ), Shs( i_start1:i_end1 ), dEhs( i_start1:i_end1 ), dEnas( i_start1:i_end1 ), tauh_maxs( i_start1:i_end1 ), Gnas( i_start1:i_end1 ), I_leaks( i_start1:i_end1 ), I_syns( i_start1:i_end1 ), I_nas( i_start1:i_end1 ), I_tonics( i_start1:i_end1 ), I_apps( i_start1:i_end1 ), I_totals( i_start1:i_end1 ), b_enableds( i_start1:i_end1 ), neurons, true, false, array_utilities );
            
            % Define the modulated split voltage based integration neuron indexes.
            i_start2 = i_end1 + 1;
            i_end2 = i_end1 + n_msvbi_neurons;
            
            % Create the modulated split voltage based integration neurons.
            [ IDs_new{ 2 }, neurons_new{ 2 }, neurons, neuron_manager ] = neuron_manager.create_msvbi_neurons( network_type, IDs( i_start2:i_end2 ), names( i_start2:i_end2 ), Us( i_start2:i_end2 ), hs( i_start2:i_end2 ), Cms( i_start2:i_end2 ), Gms( i_start2:i_end2 ), Ers( i_start2:i_end2 ), Rs( i_start2:i_end2 ), Ams( i_start2:i_end2 ), Sms( i_start2:i_end2 ), dEms( i_start2:i_end2 ), Ahs( i_start2:i_end2 ), Shs( i_start2:i_end2 ), dEhs( i_start2:i_end2 ), dEnas( i_start2:i_end2 ), tauh_maxs( i_start2:i_end2 ), Gnas( i_start2:i_end2 ), I_leaks( i_start2:i_end2 ), I_syns( i_start2:i_end2 ), I_nas( i_start2:i_end2 ), I_tonics( i_start2:i_end2 ), I_apps( i_start2:i_end2 ), I_totals( i_start2:i_end2 ), b_enableds( i_start2:i_end2 ), neurons, true, false, array_utilities );
            
            % Determine how to format the neuron IDs and objects.
            [ IDs_new, neurons_new ] = self.process_neuron_creation_outputs( IDs_new, neurons_new, as_cell_flag, array_utilities );
            
            % Update the neuron manager and neurons objects as appropriate.
            [ neurons, self ] = self.update_neuron_manager( neurons, neuron_manager, set_flag );
            
        end
        
        
        %% Subnetwork Neuron Design Functions.
        
        % Implement a function to design the neurons for a multistate cpg subnetwork.
        function [ Gnas, neurons, self ] = design_mcpg_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Compute the sodium channel conductance required for a multistate cpg subnetwork.
            [ Gnas, neurons, self ] = self.compute_cpg_Gna( neuron_IDs, neurons, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the neurons for a driven multistate cpg subnetwork.
        function [ Gnas, neurons, self ] = design_dmcpg_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Compute the sodium channel conductance required for a driven multistate cpg.
            [ Gnas, neurons, self ] = self.compute_dmcpg_Gna( neuron_IDs, neurons, set_flag, undetected_option );
            
        end
        
        
        % Implement a function to design the neurons for a transmission subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_transmission_neurons( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Compute the sodium channel conductance of the transmission subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_transmission_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the transmission subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_transmission_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a slow transmission subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_slow_transmission_neurons( self, neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 9, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 8, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 7, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 6, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 5, r = self.r_oscillation_DEFAULT; end
            if nargin < 4, T = self.T_oscillation_DEFAULT; end
            if nargin < 3, num_cpg_neurons = self.num_cpg_neurons_DEFAULT; end              % [#] Number of CPG Neurons.
            
            % Compute the sodium channel conductance of the transmission subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_transmission_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the transmission subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_slow_transmission_Cm( neuron_IDs, num_cpg_neurons, T, r, encoding_scheme, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a modulation subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_modulation_neurons( self, neuron_IDs, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 5, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Compute the sodium channel conductance of the modulation subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_modulation_Gna( neuron_IDs, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the mdoluation subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_modulation_Cm( neuron_IDs, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        

        % Implement a function to design the neurons for an addition subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, self ] = design_addition_neurons( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Define the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                        	% [-] Neuron IDs
            
            % Process the parameters.
            parameters = self.process_addition_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Compute the sodium channel conductance of the addition subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_addition_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane conductance of the addition subnetwork neurons.
            [ Gms_input, neurons, neuron_manager ] = neuron_manager.compute_addition_Gm_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ Gm_output, neurons, neuron_manager ] = neuron_manager.compute_addition_Gm_output( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            Gms = [ Gms_input, Gm_output ];
            
            % Compute the membrane capacitance of the addition subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_addition_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the activation domain of the addition subnetwork neurons.
            [ Rs_input, neurons, neuron_manager ] = neuron_manager.compute_addition_R_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ R_output, neurons, neuron_manager ] = neuron_manager.compute_addition_R_output( neuron_IDs, parameters, encoding_scheme, neurons, true, undetected_option );
            Rs = [ Rs_input, R_output ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a subtraction subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, self ] = design_subtraction_neurons( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Define the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end                                       	% [-] Neuron IDs
            
            % Process the parameters.
            parameters = self.process_subtraction_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Compute the sodium channel conductance of the subtraction subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_subtraction_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane conductance of the subtraction subnetwork neurons.
            [ Gms_input, neurons, neuron_manager ] = neuron_manager.compute_subtraction_Gm_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ Gm_output, neurons, neuron_manager ] = neuron_manager.compute_subtraction_Gm_output( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            Gms = [ Gms_input, Gm_output ];
            
            % Compute the sodium channel conductance of the subtraction subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_subtraction_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the activation domain of the subtraction subnetwork neurons.
            [ Rs_input, neurons, neuron_manager ] = neuron_manager.compute_subtraction_R_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ R_output, neurons, neuron_manager ] = neuron_manager.compute_subtraction_R_output( neuron_IDs, parameters, encoding_scheme, neurons, true, undetected_option );
            Rs = [ Rs_input, R_output ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        

        % Implement a function to design the neurons for a double subtraction subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_double_subtraction_neurons( self, neuron_IDs, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Compute the sodium channel conductance of the double subtraction subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_double_subtraction_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the double subtraction subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_double_subtraction_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end          
            
        end
        
        
        % Implement a function to design the neurons for a multiplication subnetwork.
        function [ Gnas_multiplication, Gms_multiplication, Cms_multiplication, Rs_multiplication, neurons, self ] = design_multiplication_neurons( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end

            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs, neurons );
            
            % Retrieve the inversion and division neuron IDs.
            neuron_IDs_inversion = neuron_IDs( 2:3 );
            neuron_IDs_division = neuron_IDs( [ 1, 3, 4 ] );
            
            % Process the multiplication parameters.
            [ parameters_inversion, parameters_division, ~ ] = self.process_multiplication_design_parameters( parameters, encoding_scheme, neurons );
            
            % Design the inversion subnetwork neurons.
            [ Gnas_inversion, Gms_inversion, Cms_inversion, Rs_inversion, neurons, neuron_manager ] = self.design_inversion_neurons( neuron_IDs_inversion, parameters_inversion, encoding_scheme, neurons, true, undetected_option );

            % Design the division subnetwork neurons.
            [ Gnas_division, Gms_division, Cms_division, Rs_division, neurons, neuron_manager ] = neuron_manager.design_division_neurons( neuron_IDs_division, parameters_division, encoding_scheme, neurons, true, undetected_option );
            
            % Create the multiplication subnetwork property arrays.
            Gnas_multiplication = [ Gnas_division( 1 ), Gnas_inversion( 1 ), Gnas_division( 2 ), Gnas_division ( 3 ) ];
            Gms_multiplication = [ Gms_division( 1 ), Gms_inversion( 1 ), Gms_division( 2 ), Gms_division ( 3 ) ];
            Cms_multiplication = [ Cms_division( 1 ), Cms_inversion( 1 ), Cms_division( 2 ), Cms_division ( 3 ) ];
            Rs_multiplication = [ Rs_division( 1 ), Rs_inversion( 1 ), Rs_division( 2 ), Rs_division ( 3 ) ];

            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for an inversion subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, self ] = design_inversion_neurons( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Process the parameters.
            parameters = self.process_inversion_R_output_parameters( parameters, encoding_scheme );
            
            % Compute the sodium channel conductance of the inversion subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_inversion_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane conductance of the inversion subnetwork neurons.
            [ Gm_input, neurons, neuron_manager ] = neuron_manager.compute_inversion_Gm_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ Gm_output, neurons, neuron_manager ] = neuron_manager.compute_inversion_Gm_output( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            Gms = [ Gm_input, Gm_output ];
            
            % Compute the membrane capacitance of the inversion subnetwork neurons.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_inversion_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the activation domain of the inversion subnetwork neurons.
            [ R_input, neurons, neuron_manager ] = neuron_manager.compute_inversion_R_input( neuron_IDs, parameters( 2:3 ), encoding_scheme, neurons, true, undetected_option );
            [ R_output, neurons, neuron_manager ] = neuron_manager.compute_inversion_R_output( neuron_IDs, parameters, encoding_scheme, neurons, true, undetected_option );
            Rs = [ R_input, R_output ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end    
            
        end
        
        
        % Implement a function to design the neurons for a division subnetwork.
        function [ Gnas, Gms, Cms, Rs, neurons, self ] = design_division_neurons( self, neuron_IDs, parameters, encoding_scheme, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 7, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 6, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 5, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 4, encoding_scheme = self.encoding_scheme_DEFAULT; end              % [str] Encoding Scheme (Either 'absolute' or 'relative'.)
            if nargin < 3, parameters = {  }; end                                           % [cell] Parameters Cell.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Process the parameters.
            parameters = self.process_division_R_output_parameters( parameters, encoding_scheme, neurons );
            
            % Compute the sodium channel conductance of the division subnetwork neurons.
            [ Gnas, neurons, neuron_manager ] = self.compute_division_Gna( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the membrane conductance of the division subnetwork neurons.
            [ Gms_input, neurons, neuron_manager ] = neuron_manager.compute_division_Gm_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ Gm_output, neurons, neuron_manager ] = neuron_manager.compute_division_Gm_output( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            Gms = [ Gms_input, Gm_output ];
            
            % Compute the membrane capacitance of the division subnetwork neuron..
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_division_Cm( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            
            % Compute the activation domain of the division subnetwork neurons.
            [ Rs_input, neurons, neuron_manager ] = neuron_manager.compute_division_R_input( neuron_IDs, encoding_scheme, neurons, true, undetected_option );
            [ R_output, neurons, neuron_manager ] = neuron_manager.compute_division_R_output( neuron_IDs, parameters, encoding_scheme, neurons, true, undetected_option );
            Rs = [ Rs_input, R_output ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end   

        end
        
        
        % Implement a function to design the neurons for a derivation subnetwork.
        function [ Gnas, Gms, Cms, neurons, self ] = design_derivation_neurons( self, neuron_IDs, k_gain, w, safety_factor, neurons, set_flag, undetected_option )
            
            % Set the default input arguments.
            if nargin < 8, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 6, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 5, safety_factor = self.sf_derivation_DEFAULT; end
            if nargin < 4, w = self.w_derivation_DEFAULT; end
            if nargin < 3, k_gain = self.c_derivation_DEFAULT; end
            
            % Compute the sodium channel conductance of a derivation subnetwork.
            [ Gnas, neurons, neuron_manager ] = self.compute_derivation_Gna( neuron_IDs, neurons, true, undetected_option );
            
            % Compute the membrane conductance of a derivation subnetwork.
            [ Gms, neurons, neuron_manager ] = neuron_manager.compute_derivation_Gm( neuron_IDs, k_gain, w, safety_factor, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of a derivation subnetwork.
            [ Cm1, neurons, neuron_manager ] = neuron_manager.compute_derivation_Cm1( neuron_IDs, k_gain, neurons, true, undetected_option );
            [ Cm2, neurons, neuron_manager ] = neuron_manager.compute_derivation_Cm2( neuron_IDs, w, neurons, true, undetected_option );
            Cms = [ Cm1, Cm2 ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for an integration subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_integration_neurons( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arugments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the sodium channel conductance of the integration subnetwork.
            [ Gnas, neurons, neuron_manager ] = self.compute_integration_Gna( neuron_IDs, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the integration subnetwork.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_integration_Cm( neuron_IDs, ki_mean, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implement a function to design the neurons for a voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_vbi_neurons( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arugments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the sodium channel conductance of the voltage based integration subnetwork.
            [ Gnas, neurons, neuron_manager ] = self.compute_vbi_Gna( neuron_IDs, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the voltage based integration subnetwork.
            [ Cms, neurons, neuron_manager ] = neuron_manager.compute_vbi_Cm( neuron_IDs( 3:4 ), ki_mean, neurons, true, undetected_option );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        % Implemenet a function to design the neurons for a split voltage based integration subnetwork.
        function [ Gnas, Cms, neurons, self ] = design_svbi_neurons( self, neuron_IDs, ki_mean, neurons, set_flag, undetected_option )
            
            % Set the default input arugments.
            if nargin < 6, undetected_option = self.undetected_option_DEFAULT; end          % [-] Undetected Option (Determines what to do if neuron ID is not detected.)
            if nargin < 5, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 4, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 3, ki_mean = self.c_integration_mean_DEFAULT; end
            
            % Compute the sodium channel conductance of the split voltage based integration subnetwork.
            [ Gnas, neurons, neuron_manager ] = self.compute_svbi_Gna( neuron_IDs, neurons, true, undetected_option );
            
            % Compute the membrane capacitance of the split voltage based integration subnetwork.
            [ Cms1, neurons, neuron_manager ] = neuron_manager.compute_svbi_Cm1( neuron_IDs( 3:4 ), ki_mean, neurons, true, undetected_option );
            [ Cms2, neurons, neuron_manager ] = neuron_manager.compute_svbi_Cm2( neuron_IDs( 5:8 ), neurons, true, undetected_option );
            Cms = [ Cms1, Cms2 ];
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = neuron_manager; end
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save neuron manager data as a matlab object.
        function save( self, directory, file_name )
            
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron_Manager.mat'; end
            if nargin < 2, directory = '.'; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load neuron manager data as a matlab object.
        function [ data, self ] = load( self, directory, file_name, set_flag )
            
            % Set the default input arguments.
            if nargin < 4, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 3, file_name = self.file_name_DEFAULT; end
            if nargin < 2, directory = self.load_directory_DEFAULT; end
            
            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Determine whether to update the neuron manager object.
            if set_flag, self = data; end
            
        end
        
        
        % Implement a function to load neuron data from a xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose, neurons, set_flag )
            
            % Set the default input arguments.
            if nargin < 7, set_flag = self.set_flag_DEFAULT; end                            % [T/F] Set Flag (Determines whether output self object is updated.)
            if nargin < 6, neurons = self.neurons; end                                    	% [class] Array of Neuron Class Objects.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Neuron_Data.xlsx'; end
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING NEURON DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic
            
            % Load the neuron data.
            [ neuron_IDs, neuron_names, neuron_U0s, neuron_Cms, neuron_Gms, neuron_Ers, neuron_Rs, neuron_Ams, neuron_Sms, neuron_dEms, neuron_Ahs, neuron_Shs, neuron_dEhs, neuron_dEnas, neuron_tauh_maxs, neuron_Gnas ] = self.data_loader_utilities.load_neuron_data( file_name, directory );
            
            % Define the number of neurons.
            num_neurons_to_load = length( neuron_IDs );
            
            % Preallocate an array of neurons.
            neurons_to_load = repmat( neuron_class(  ), 1, num_neurons_to_load );
            
            % Create each neuron object.
            for k = 1:num_neurons_to_load                                                   % Iterate through each of the neurons...
                
                % Compute the initial sodium channel deactivation parameter.
                neuron_h0 = neurons_to_load( k ).neuron_utilities.compute_mhinf( neuron_U0s( k ), neuron_Ahs( k ), neuron_Shs( k ), neuron_dEhs( k ) );
                
                % Create this neuron.
                neurons_to_load( k ) = neuron_class( neuron_IDs( k ), neuron_names{ k }, neuron_U0s( k ), neuron_h0, neuron_Cms( k ), neuron_Gms( k ), neuron_Ers( k ), neuron_Rs( k ), neuron_Ams( k ), neuron_Sms( k ), neuron_dEms( k ), neuron_Ahs( k ), neuron_Shs( k ), neuron_dEhs( k ), neuron_dEnas( k ), neuron_tauh_maxs( k ), neuron_Gnas( k ) );
                
            end
            
            % Determine whether to append the neurons we just loaded.
            if b_append                                                                     % If we want to append the neurons we just loaded...
                
                % Append the neurons we just loaded to the array of existing neurons.
                neurons = [ neurons neurons_to_load ];
                
                % Update the number of neurons.
                n_neurons = length( neurons );
                
            else                                                                            % Otherwise...
                
                % Replace the existing neurons with the neurons we just loaded.
                neurons = neurons_to_load;
                
                % Update the number of neurons.
                n_neurons = length( neurons );
                
            end
            
            % Determine whether to update the neuron manager properties.
            if set_flag                                                                     % If we want to update the neuron manager properties...
                
                % Update the neurons property.
                self.neurons = neurons;
                
                % Update the number of neurons.
                self.num_neurons = n_neurons;
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING NEURON DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        
    end
end

