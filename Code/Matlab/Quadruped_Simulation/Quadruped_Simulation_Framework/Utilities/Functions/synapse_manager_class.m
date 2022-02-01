classdef synapse_manager_class

    % This class contains properties and methods related to managing synapses.
    
    %% SYNAPSE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        synapses
        num_synapses
%         delta_oscillatory
%         delta_bistable
    end
    
    
    %% SYNAPSE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_manager_class( synapses )

            % Set the default synapse properties.
            if nargin < 1, self.synapses = synapse_class(  ); else, self.synapses = synapses; end
            
            % Compute the number of synapses.
            self.num_synapses = length( self.synapses );
            
        end

        
        %% Get & Set Synapse Property Functions
        
        % Implement a function to retrieve the index associated with a given synapse ID.
        function synapse_index = get_synapse_index( self, synapse_ID )
            
            % Set a flag variable to indicate whether a matching synapse index has been found.
            bMatchFound = false;
            
            % Initialize the synapse index.
            synapse_index = 0;
            
            while (synapse_index < self.num_synapses) && (~bMatchFound)
                
                % Advance the synapse index.
                synapse_index = synapse_index + 1;
                
                % Check whether this synapse index is a match.
                if self.synapses(synapse_index).ID == synapse_ID                       % If this synapse has the correct synapse ID...
                    
                    % Set the match found flag to true.
                    bMatchFound = true;
                    
                end
                
            end
            
            % Determine whether a match was found.
            if ~bMatchFound                     % If a match was not found...
                
                % Throw an error.
                error('No synapse with ID %0.0f.', synapse_ID)
                
            end
            
        end
        
        
        % Implement a function to validate synapse IDs.
        function synapse_IDs = validate_synapse_IDs( self, synapse_IDs )
            
            % Determine whether we want get the desired synapse property from all of the synapses.
            if isa( synapse_IDs, 'char' )                                                      % If the synapse IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmp( synapse_IDs, 'all' ) || strcmp( synapse_IDs, 'All' )                  % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the synapse IDs.
                    synapse_IDs = zeros( 1, self.num_synapses );
                    
                    % Retrieve the synapse ID associated with each synapse.
                    for k = 1:self.num_synapses                   % Iterate through each synapse...
                        
                        % Store the synapse ID associated with the current synapse.
                        synapse_IDs(k) = self.synapses(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error('Synapse_IDs must be either an array of valid synapse IDs or one of the strings: ''all'' or ''All''.')
                    
                end
                
            end
            
        end
        
        
        % Implement a function to retrieve the properties of specific synapses.
        function xs = get_synapse_property( self, synapse_IDs, synapse_property )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_properties_to_get = length(synapse_IDs);
            
            % Preallocate a variable to store the synapse properties.
            xs = cell( 1, num_properties_to_get );

            % Retrieve the given synapse property for each synapse.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.synapses(%0.0f).%s;', synapse_index, synapse_property );

                % Evaluate the given synapse property.
                eval(eval_str);
                
            end
            
        end
        
        
        % Implement a function to set the properties of specific synapses.
        function self = set_synapse_property( self, synapse_IDs, synapse_property_values, synapse_property )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Validate the synapse property values.
            if ~isa( synapse_property_values, 'cell' )                    % If the synapse property values are not a cell array...
               
                % Convert the synapse property values to a cell array.
                synapse_property_values = num2cell( synapse_property_values );
                
            end
            
            % Set the properties of each synapse.
            for k = 1:self.num_synapses                   % Iterate through each synapse...
                
                % Determine the index of the synapse property value that we want to apply to this synapse (if we want to set a property of this synapse).
                index = find(self.synapses(k).ID == synapse_IDs, 1);
                
                % Determine whether to set a property of this synapse.
                if ~isempty(index)                         % If a matching synapse ID was detected...
                    
                    % Create an evaluation string that sets the desired synapse property.
                    eval_string = sprintf('self.synapses(%0.0f).%s = synapse_property_values{%0.0f};', k, synapse_property, index);
                    
                    % Evaluate the evaluation string.
                    eval(eval_string);
                    
                end
            end
            
        end
        
        
        %% Call Methods Functions
        
        % Implement a function to that calls a specified synapse method for each of the specified synapses.
        function self = call_synapse_method( self, synapse_IDs, synapse_method )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length(synapse_IDs);
            
            % Evaluate the given synapse method for each synapse.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.synapses(%0.0f) = self.synapses(%0.0f).%s();', synapse_index, synapse_index, synapse_method );
                
                % Evaluate the given synapse method.
                eval(eval_str);
                
            end
            
        end
        

    end
end

