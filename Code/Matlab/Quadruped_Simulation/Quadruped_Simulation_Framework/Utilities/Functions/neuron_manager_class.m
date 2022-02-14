classdef neuron_manager_class
    
    % This class contains properties and methods related to managiing neurons.
    
    %% NEURON MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        neurons
        num_neurons
        
        data_loader_utilities
        
    end
    
    
    %% NEURON MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = neuron_manager_class( neurons )
            
            % Create an instance of the data loader class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Set the default class properties.
            if nargin < 1, self.neurons = neuron_class(  ); else, self.neurons = neurons; end
            
            % Compute the number of neurons.
            self.num_neurons = length( self.neurons );

        end
        
        
        %% Neuron Index & ID Functions
        
        % Implement a function to retrieve the index associated with a given neuron ID.
        function neuron_index = get_neuron_index( self, neuron_ID )
            
            % Set a flag variable to indicate whether a matching neuron index has been found.
            bMatchFound = false;
            
            % Initialize the neuron index.
            neuron_index = 0;
            
            while ( neuron_index < self.num_neurons ) && ( ~bMatchFound )
                
                % Advance the neuron index.
                neuron_index = neuron_index + 1;
                
                % Check whether this neuron index is a match.
                if self.neurons(neuron_index).ID == neuron_ID                       % If this neuron has the correct neuron ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No neuron with ID %0.0f.', neuron_ID)
                
            end
            
        end
        
        
        % Implement a function to validate neuron IDs.
        function neuron_IDs = validate_neuron_IDs( self, neuron_IDs )
            
            % Determine whether we want get the desired neuron property from all of the neurons.
            if isa( neuron_IDs, 'char' )                                                      % If the neuron IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( neuron_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the neuron IDs.
                    neuron_IDs = zeros( 1, self.num_neurons );
                    
                    % Retrieve the neuron ID associated with each neuron.
                    for k = 1:self.num_neurons                   % Iterate through each neuron...
                        
                        % Store the neuron ID associated with the current neuron.
                        neuron_IDs(k) = self.neurons(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Neuron_IDs must be either an array of valid neuron IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        %% Get & Set Neuron Property Functions
        
        % Implement a function to retrieve the properties of specific neurons.
        function xs = get_neuron_property( self, neuron_IDs, neuron_property )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_properties_to_get = length( neuron_IDs );
            
            % Preallocate a variable to store the neuron properties.
            xs = cell( 1, num_properties_to_get );

            % Retrieve the given neuron property for each neuron.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.neurons(%0.0f).%s;', neuron_index, neuron_property );

                % Evaluate the given neuron property.
                eval( eval_str );
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific neurons.
        function self = set_neuron_property( self, neuron_IDs, neuron_property_values, neuron_property )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Validate the neuron property values.
            if ~isa( neuron_property_values, 'cell' )                    % If the neuron property values are not a cell array...
               
                % Convert the neuron property values to a cell array.
                neuron_property_values = num2cell( neuron_property_values );
                
            end
            
            % Set the properties of each neuron.
            for k = 1:self.num_neurons                   % Iterate through each neuron...
                
                % Determine the index of the neuron property value that we want to apply to this neuron (if we want to set a property of this neuron).
                index = find( self.neurons(k).ID == neuron_IDs, 1 );
                
                % Determine whether to set a property of this neuron.
                if ~isempty( index )                         % If a matching neuron ID was detected...
                    
                    % Create an evaluation string that sets the desired neuron property.
                    eval_string = sprintf( 'self.neurons(%0.0f).%s = neuron_property_values{%0.0f};', k, neuron_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end
        
        
        %% Call Neuron Methods Functions
        
        % Implement a function to that calls a specified neuron method for each of the specified neurons.
        function self = call_neuron_method( self, neuron_IDs, neuron_method )
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.neurons(%0.0f) = self.neurons(%0.0f).%s();', neuron_index, neuron_index, neuron_method );
                
                % Evaluate the given neuron method.
                eval( eval_str );
                
            end
            
        end
        
        
        %% Sodium Channel Conductance Functions
                
        % Implement a function to set the sodium channel conductance for a two neuron CPG subnetwork for each neuron.
        function self = compute_set_CPG_Gna( self, neuron_IDs )
            
            % Set the default input arguments.
            if nargin < 2, neuron_IDs = 'all'; end
            
            % Validate the neuron IDs.
            neuron_IDs = self.validate_neuron_IDs( neuron_IDs );
            
            % Determine how many neurons to which we are going to apply the given method.
            num_neurons_to_evaluate = length( neuron_IDs );
            
            % Evaluate the given neuron method for each neuron.
            for k = 1:num_neurons_to_evaluate               % Iterate through each of the neurons of interest...
                
                % Retrieve the index associated with this neuron ID.
                neuron_index = self.get_neuron_index( neuron_IDs(k) );
                
                % Compute and set the sodium channel conductance for this neuron.
                self.neurons( neuron_index ) = self.neurons( neuron_index ).compute_set_CPG_Gna(  );
                
            end
            
        end
        
        
        %% Neuron Creation Functions
        
        % Implement a function to create a new neuron.
        function self = create_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total )
            
            % Set the default neuron properties.
            if nargin < 24, I_total = 0; end
            if nargin < 23, I_app = 0; end
            if nargin < 22, I_tonic = 0; end
            if nargin < 21, I_na = 0; end
            if nargin < 20, I_syn = 0; end
            if nargin < 19, I_leak = 0; end
            if nargin < 18, Gna = 1e-6; end
            if nargin < 17, tauh_max = 0.25; end
            if nargin < 16, dEna = 110e-3; end
            if nargin < 15, dEh = 0; end
            if nargin < 14, Sh = 50; end
            if nargin < 13, Ah = 0.5; end
            if nargin < 12, dEm = 40e-3; end
            if nargin < 11, Sm = -50; end
            if nargin < 10, Am = 1; end
            if nargin < 9, R = 20e-3; end
            if nargin < 8, Er = -60e-3; end
            if nargin < 7, Gm = 1e-6; end
            if nargin < 6, Cm = 5e-9; end
            if nargin < 5, h = 0; end
            if nargin < 4, U = 0; end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = 0; end
            
            % Determine whether this ID is valid.
            
            
            % Create an instance of the neuron class.
            neuron = neuron_class( ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total );
            
            % Append this neuron to the array of existing neurons.
            self.neurons = [ self.neurons neuron ];
            
            % Increase the number of neurons counter.
            self.num_neurons = self.num_neurons + 1;
            
        end
        
        
        % Implement a function to create multiple neurons.
        function self = create_neurons( self, IDs, names, Us, hs, Cms, Gms, Ers, Rs, Ams, Sms, dEms, Ahs, Shs, dEhs, dEnas, tauh_maxs, Gnas, I_leaks, I_syns, I_nas, I_tonics, I_apps, I_totals )
            
            % Determine whether number of neurons to create.
            if nargin > 2
            
                num_neurons_to_create = length( IDs );
                
            elseif nargin == 2
                
                % Retrieve the number of IDs.
                num_IDs = length( IDs );
                
                if num_IDs == 1
                    
                    num_neurons_to_create = IDs;
                    
                    IDs = zeros( 1, num_neurons_to_create );
                    
                else
                   
                    num_neurons_to_create = num_IDs;
                    
                end
                
            elseif nargin == 1
                
                num_neurons_to_create = 1;
                
            end
            
            % Set the default neuron properties.
            if nargin < 24, I_total = zeros( 1, num_neurons_to_create ); end
            if nargin < 23, I_app = zeros( 1, num_neurons_to_create ); end
            if nargin < 22, I_tonic = zeros( 1, num_neurons_to_create ); end
            if nargin < 21, I_na = zeros( 1, num_neurons_to_create ); end
            if nargin < 20, I_syn = zeros( 1, num_neurons_to_create ); end
            if nargin < 19, I_leak = zeros( 1, num_neurons_to_create ); end
            if nargin < 18, Gna = 1e-6; end
            if nargin < 17, tauh_max = 0.25; end
            if nargin < 16, dEna = 110e-3; end
            if nargin < 15, dEh = zeros( 1, num_neurons_to_create ); end
            if nargin < 14, Sh = 50; end
            if nargin < 13, Ah = 0.5; end
            if nargin < 12, dEm = 40e-3; end
            if nargin < 11, Sm = -50; end
            if nargin < 10, Am = 1; end
            if nargin < 9, R = 20e-3; end
            if nargin < 8, Er = -60e-3; end
            if nargin < 7, Gm = 1e-6; end
            if nargin < 6, Cm = 5e-9; end
            if nargin < 5, h = zeros( 1, num_neurons_to_create ); end
            if nargin < 4, U = zeros( 1, num_neurons_to_create ); end
            if nargin < 3, name = ''; end
            if nargin < 2, ID = zeros( 1, num_neurons_to_create ); end
            
            
            
            self = create_neuron( self, ID, name, U, h, Cm, Gm, Er, R, Am, Sm, dEm, Ah, Sh, dEh, dEna, tauh_max, Gna, I_leak, I_syn, I_na, I_tonic, I_app, I_total )
            
            
        end
        
        
        % Implement a function to delete a neuron.
        function self = delete_neuron( self, neuron_ID )
            
            % Retrieve the index associated with this neuron.
            neuron_index = self.get_neuron_index( neuron_ID );
            
            % Remove this neuron from the array of neurons.
            self.neurons( neuron_index ) = [  ];
            
            % Decrease the number of neurons counter.
            self.num_neurons = self.num_neurons - 1;
            
        end
        
        
        % Implement a function to delete multiple neurons.
        function self = delete_neurons( self, neuron_IDs )
            
            % Retrieve the number of neurons to delete.
           num_neurons_to_delete = length( neuron_IDs );
           
           % Delete each of the specified neurons.
           for k = 1:num_neurons_to_delete                      % Iterate through each of the neurons we want to delete...
            
               % Delete this neuron.
               self = self.delete_neurons( neuron_IDs(k) );
               
           end
               
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
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Neuron_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load neuron data from a xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
        
            % Set the default input arguments.
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
            for k = 1:num_neurons_to_load               % Iterate through each of the neurons...

                % Compute the initial sodium channel deactivation parameter.
                neuron_h0 = neurons_to_load(k).neuron_utilities.compute_mhinf( neuron_U0s(k), neuron_Ahs(k), neuron_Shs(k), neuron_dEhs(k) );

                % Create this neuron.
                neurons_to_load(k) = neuron_class( neuron_IDs(k), neuron_names{k}, neuron_U0s(k), neuron_h0, neuron_Cms(k), neuron_Gms(k), neuron_Ers(k), neuron_Rs(k), neuron_Ams(k), neuron_Sms(k), neuron_dEms(k), neuron_Ahs(k), neuron_Shs(k), neuron_dEhs(k), neuron_dEnas(k), neuron_tauh_maxs(k), neuron_Gnas(k) );

            end
            
            % Determine whether to append the neurons we just loaded.
            if b_append                         % If we want to append the neurons we just loaded...
                
                % Append the neurons we just loaded to the array of existing neurons.
                self.neurons = [ self.neurons neurons_to_load ];
                
                % Update the number of neurons.
                self.num_neurons = length( self.neurons );
                
            else                                % Otherwise...
                
                % Replace the existing neurons with the neurons we just loaded.
                self.neurons = neurons_to_load;
                
                % Update the number of neurons.
                self.num_neurons = length( self.neurons );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING NEURON DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
            
        
        
        
    end
end

