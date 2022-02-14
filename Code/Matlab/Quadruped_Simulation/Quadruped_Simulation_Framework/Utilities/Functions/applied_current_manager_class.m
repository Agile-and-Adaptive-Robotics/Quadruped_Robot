classdef applied_current_manager_class

    % This class contains properties and methods related to managing applied currents.
    
    %% APPLIED CURRENT MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        applied_currents
        
        num_applied_currents
        num_timesteps
        
        data_loader_utilities
        
    end
    
    
    %% APPLIED CURRENT MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = applied_current_manager_class( applied_currents )
            
            % Create an instance of the data loader utilities class.
            self.data_loader_utilities = data_loader_utilities_class(  );
            
            % Set the default properties.
            if nargin < 1, self.applied_currents = applied_current_class(  ); else, self.applied_currents = applied_currents; end
            
            % Compute the number of applied currents.
            self.num_applied_currents = length( self.applied_currents );
            
            % Retrieve the number of timesteps.
            self.num_timesteps = length( self.applied_currents(1).I_apps );
            
        end
        
        
        %% Applied Current Index & ID Functions
        
        % Implement a function to retrieve the index associated with a given applied_current ID.
        function applied_current_index = get_applied_current_index( self, applied_current_ID )
            
            % Set a flag variable to indicate whether a matching applied_current index has been found.
            bMatchFound = false;
            
            % Initialize the applied_current index.
            applied_current_index = 0;
            
            while ( applied_current_index < self.num_applied_currents ) && ( ~bMatchFound )
                
                % Advance the applied_current index.
                applied_current_index = applied_current_index + 1;
                
                % Check whether this applied_current index is a match.
                if self.applied_currents( applied_current_index ).ID == applied_current_ID                       % If this applied_current has the correct applied_current ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error( 'No applied current with ID %0.0f.', applied_current_ID )
                
            end
            
        end
        
        
        % Implement a function to validate applied_current IDs.
        function applied_current_IDs = validate_applied_current_IDs( self, applied_current_IDs )
            
            % Determine whether we want get the desired applied_current property from all of the applied_currents.
            if isa( applied_current_IDs, 'char' )                                                      % If the applied_current IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( applied_current_IDs, 'all' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the applied_current IDs.
                    applied_current_IDs = zeros( 1, self.num_applied_currents );
                    
                    % Retrieve the applied_current ID associated with each applied_current.
                    for k = 1:self.num_applied_currents                   % Iterate through each applied_current...
                        
                        % Store the applied_current ID associated with the current applied_current.
                        applied_current_IDs(k) = self.applied_currents(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Applied current ID must be either an array of valid applied_current IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        
        %% Basic Get & Set Functions
        
        % Implement a function to retrieve the applied currents.
        function I_apps = get_applied_currents( self, applied_current_IDs )
            
            % Validate the applied current IDs.
            applied_current_IDs = self.validate_applied_current_IDs( applied_current_IDs );
            
            % Determine how many applied currents to get.
            num_applied_currents_to_get = length( applied_current_IDs );
                        
            % Preallocate a variable to store the applied current properties.
            I_apps = zeros( self.num_timesteps, num_applied_currents_to_get );

            % Retrieve the given neuron property for each applied current.
            for k = 1:num_applied_currents_to_get                           % Iterate through each of the currents to retrieve...
                
                % Retrieve the index associated with this applied current ID.
                applied_current_index = self.get_applied_current_index( applied_current_IDs(k) );
                
                % Retrieve the applied currents.
                I_apps( :, k ) = self.applied_currents( applied_current_index ).I_apps;
                
            end
            
        end
        
        
        %% Save & Load Functions
        
        % Implement a function to save applied current manager data as a matlab object.
        function save( self, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Save the neuron data.
            save( full_path, self )
            
        end
        
        
        % Implement a function to load applied current manager data as a matlab object.
        function self = load( ~, directory, file_name )
        
            % Set the default input arguments.
            if nargin < 3, file_name = 'Applied_Current_Manager.mat'; end
            if nargin < 2, directory = '.'; end

            % Create the full path to the file of interest.
            full_path = [ directory, '\', file_name ];
            
            % Load the data.
            data = load( full_path );
            
            % Retrieve the desired variable from the loaded data structure.
            self = data.self;
            
        end
        
        
        % Implement a function to load applied current data from an xlsx file.
        function self = load_xlsx( self, file_name, directory, b_append, b_verbose )
        
            % Set the default input arguments.
            if nargin < 5, b_verbose = true; end
            if nargin < 4, b_append = false; end
            if nargin < 3, directory = '.'; end
            if nargin < 2, file_name = 'Applied_Current_Data.xlsx'; end
        
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED CURRENT DATA. Please Wait...\n' ), end
            
            % Start a timer.
            tic

            % Load the applied current data.
            [ applied_current_IDs, applied_current_names, applied_current_neuron_IDs, applied_current_ts, applied_current_I_apps ] = self.data_loader_utilities.load_applied_current_data( file_name, directory );
            
            
            % Define the number of synapses.
            num_applied_currents_to_load = length( applied_current_IDs );

            % Preallocate an array of applied currents.
            applied_currents_to_load = repmat( applied_current_class(  ), 1, num_applied_currents_to_load );

            % Create each applied current object.
            for k = 1:num_applied_currents_to_load               % Iterate through each of the applied currents...

                % Create this applied current.
                applied_currents_to_load(k) = applied_current_class( applied_current_IDs(k), applied_current_names{k}, applied_current_neuron_IDs(k), applied_current_ts( :, k ), applied_current_I_apps( :, k ) );

            end
            
            % Determine whether to append the applied currents we just loaded.
            if b_append                         % If we want to append the applied currents we just loaded...
                
                % Append the applied currents we just loaded to the array of existing applied currents.
                self.applied_currents = [ self.applied_currents applied_currents_to_load ];
                
                % Update the number of applied currents.
                self.num_applied_currents = length( self.applied_currents );
                
                % Update the number of time steps.
                self.num_timesteps = length( self.applied_currents(1).ts );
                
            else                                % Otherwise...
                
                % Replace the existing applied currents with the applied currents we just loaded.
                self.applied_currents = applied_currents_to_load;
                
                % Update the number of applied currents.
                self.num_applied_currents = length( self.applied_currents );
                
                % Update the number of time steps.
                self.num_timesteps = length( self.applied_currents(1).ts );
                
            end
            
            % Retrieve the elapsed time.
            elapsed_time = toc;
            
            % Determine whether to print status messages.
            if b_verbose, fprintf( 'LOADING APPLIED CURRENT DATA. Please Wait... Done. %0.3f [s] \n\n', elapsed_time ), end
            
        end
        
        

    end
end

