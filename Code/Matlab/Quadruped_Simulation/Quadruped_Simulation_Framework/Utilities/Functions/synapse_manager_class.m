classdef synapse_manager_class
    
    % This class contains properties and methods related to managing synapses.
    
    %% SYNAPSE MANAGER PROPERTIES
    
    % Define the class properties.
    properties
        
        synapses
        num_synapses
        
        delta_oscillatory
        delta_bistable
        neuron_ID_order
        
    end
    
    
    %% SYNAPSE MANAGER METHODS SETUP
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = synapse_manager_class( synapses, delta_oscillatory, delta_bistable, neuron_ID_order )
            
            % Set the default synapse properties.
            if nargin < 4, self.neuron_ID_order = []; else, self.neuron_ID_order = neuron_ID_order; end
            if nargin < 3, self.delta_bistable = []; else, self.delta_bistable = delta_bistable; end
            if nargin < 2, self.delta_oscillatory = []; else, self.delta_oscillatory = delta_oscillatory; end
            if nargin < 1, self.synapses = synapse_class(  ); else, self.synapses = synapses; end
            
            % Compute the number of synapses.
            self.num_synapses = length( self.synapses );
            
        end
        
        
        %% General Get & Set Synapse Property Functions
        
        % Implement a function to retrieve the properties of specific synapses.
        function xs = get_synapse_property( self, synapse_IDs, synapse_property )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_properties_to_get = length( synapse_IDs );
            
            % Preallocate a variable to store the synapse properties.
            xs = cell( 1, num_properties_to_get );
            
            % Retrieve the given synapse property for each synapse.
            for k = 1:num_properties_to_get
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'xs{k} = self.synapses(%0.0f).%s;', synapse_index, synapse_property );
                
                % Evaluate the given synapse property.
                eval( eval_str );
                
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
                index = find( self.synapses(k).ID == synapse_IDs, 1 );
                
                % Determine whether to set a property of this synapse.
                if ~isempty( index )                         % If a matching synapse ID was detected...
                    
                    % Create an evaluation string that sets the desired synapse property.
                    eval_string = sprintf( 'self.synapses(%0.0f).%s = synapse_property_values{%0.0f};', k, synapse_property, index );
                    
                    % Evaluate the evaluation string.
                    eval( eval_string );
                    
                end
            end
            
        end
        
        
        %% Specific Get & Set Synapse Property Functions
        
        % Implement a function to retrieve the index associated with a given synapse ID.
        function synapse_index = get_synapse_index( self, synapse_ID )
            
            % Set a flag variable to indicate whether a matching synapse index has been found.
            bMatchFound = false;
            
            % Initialize the synapse index.
            synapse_index = 0;
            
            while ( synapse_index < self.num_synapses ) && ( ~bMatchFound )
                
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
                error( 'No synapse with ID %0.0f.', synapse_ID )
                
            end
            
        end
        
        
        % Implement a function to validate synapse IDs.
        function synapse_IDs = validate_synapse_IDs( self, synapse_IDs )
            
            % Determine whether we want get the desired synapse property from all of the synapses.
            if isa( synapse_IDs, 'char' )                                                      % If the synapse IDs variable is a character array instead of an integer srray...
                
                % Determine whether this is a valid character array.
                if  strcmpi( synapse_IDs, 'all' )                 % If the character array is either 'all' or 'All'...
                    
                    % Preallocate an array to store the synapse IDs.
                    synapse_IDs = zeros( 1, self.num_synapses );
                    
                    % Retrieve the synapse ID associated with each synapse.
                    for k = 1:self.num_synapses                   % Iterate through each synapse...
                        
                        % Store the synapse ID associated with the current synapse.
                        synapse_IDs(k) = self.synapses(k).ID;
                        
                    end
                    
                else                                                                        % Otherwise...
                    
                    % Throw an error.
                    error( 'Synapse_IDs must be either an array of valid synapse IDs or one of the strings: ''all'' or ''All''.' )
                    
                end
                
            end
            
        end
        
        
        % Implement a function to get all of the synapse IDs.
        function synapse_IDs = get_all_synapse_IDs( self )
            
            % Preallocate an array to store the synapse IDs.
           synapse_IDs = zeros( 1,  self.num_synapses );
           
           % Retrieve each synapse ID.
           for k = 1:self.num_synapses                  % Iterate through each synapse...
              
               % Retrieve the ID of this synapse.
               synapse_IDs(k) = self.synapses(k).ID;
               
           end
            
        end
        
        
        %% Call Methods Functions
        
        % Implement a function to that calls a specified synapse method for each of the specified synapses.
        function self = call_synapse_method( self, synapse_IDs, synapse_method )
            
            % Validate the synapse IDs.
            synapse_IDs = self.validate_synapse_IDs( synapse_IDs );
            
            % Determine how many synapses to which we are going to apply the given method.
            num_synapses_to_evaluate = length( synapse_IDs );
            
            % Evaluate the given synapse method for each synapse.
            for k = 1:num_synapses_to_evaluate               % Iterate through each of the synapses of interest...
                
                % Retrieve the index associated with this synapse ID.
                synapse_index = self.get_synapse_index( synapse_IDs(k) );
                
                % Define the eval string.
                eval_str = sprintf( 'self.synapses(%0.0f) = self.synapses(%0.0f).%s();', synapse_index, synapse_index, synapse_method );
                
                % Evaluate the given synapse method.
                eval( eval_str );
                
            end
            
        end
        
        
        %% Multistate CPG Functions
        
        % Implement a function to retrieve the synapse ID of the synapse that connect two specified neurons.
        function synapse_ID = from_to_neuron_ID2synapse_ID( self, from_neuron_ID, to_neuron_ID, undetected_option )
            
            % NOTE: This function assumes that only one synapse connects each set of neurons.
            
            % Set the default input argument.
            if nargin < 4, undetected_option = 'error'; end
            
            % Initialize the  synapse detected flag.
            b_synapse_detected = false;
            
            % Initialize the loop counter.
            k = 0;
            
            % Search for the synapse(s) that connect the specified neurons.
            while ( ~b_synapse_detected ) && ( k < self.num_synapses )              % While a matching synapse has not yet been detected and we haven't looked through all of the synapses...
                
                % Advance the loop counter.
                k = k + 1;
                
                % Determine whether this synapse connects the specified neurons.
                if ( self.synapses(k).from_neuron_ID == from_neuron_ID ) && ( self.synapses(k).to_neuron_ID == to_neuron_ID )
                    
                    % Set the synapse detected flag to true.
                    b_synapse_detected = true;
                    
                end
                
            end
            
            % Determine whether a matching synapse was detected.
            if b_synapse_detected                                   % If we found a matching synapse....
                
                % Retrieve the ID of the matching synapse.
                synapse_ID = self.synapses(k).ID;
                
            else                                                    % Otherwise...
                
                if strcmpi( undetected_option, 'error' )
                    
                    error( 'No synapse found that connects neuron %0.0f to neuron %0.0f.', from_neuron_ID, to_neuron_ID )
                    
                    
                elseif strcmpi( undetected_option, 'warning' )
                    
                    % Throw a warning.
                    warning( 'undetected_option %s unrecognized.', undetected_option )
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                elseif strcmpi( undetected_option, 'ignore' )
                    
                    % Set the synapse ID to be negative one.
                    synapse_ID = -1;
                    
                else
                    
                    % Throw an error.
                    error( 'undetected_option %s unrecognized.', undetected_option )
                    
                end
                
                
            end
            
        end
        
        
        % Implement a function to retrieve the synpase IDs associated with the synapses that connect an array of specified neurons.
        function synapse_IDs = from_to_neuron_IDs2synapse_IDs( self, from_neuron_IDs, to_neuron_IDs )
            
            % Ensure that the same number of from and to neuron IDs are specified.
            assert( length( from_neuron_IDs ) == length( to_neuron_IDs ), 'length(from_neuron_IDs) must equal length(to_neuron_IDs).' )
            
            % Retrieve the number of synapses to find.
            num_synapses_to_find = length( from_neuron_IDs );
            
            % Preallocate an array to store the syanpse IDs.
            synapse_IDs = zeros( 1, num_synapses_to_find );
            
            % Search for each synapse ID.
            for k = 1:num_synapses_to_find                              % Iterate through each set of neurons for which we are searching for a connecting synapse.
                
                % Retrieve the ID of the synapse that connects these neurons.
                synapse_IDs(k) = self.from_to_neuron_ID2synapse_ID( from_neuron_IDs(k), to_neuron_IDs(k) );
                
            end
            
        end
        
        
        % Implement a function to convert a specific neuron ID order to from-to neuron ID pairs.
        function [ from_neuron_IDs, to_neuron_IDs ] = neuron_ID_order2from_to_neuron_IDs( ~, neuron_ID_order )
            
            if ~isempty( neuron_ID_order )
                
                % Retrieve the number of pairs of neurons.
                num_pairs = length( neuron_ID_order );
                
                % Augment the neuron ID order.
                neuron_ID_order = [ neuron_ID_order neuron_ID_order(1) ];
                
                % Preallocate arrays to store the from and to neuron IDs.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( zeros( 1, num_pairs ) );
                
                % Retrieve the from and to neuron IDs for each neuron pair.
                for k = 1:num_pairs                         % Iterate through each pair of neurons...
                    
                    % Retrieve the from neuron ID.
                    from_neuron_IDs(k) = neuron_ID_order(k);
                    
                    % Retrieve the to neuron ID.
                    to_neuron_IDs(k) = neuron_ID_order(k + 1);
                    
                end
                
            else                                                % Otherwise...
                
                % Set the from and to neuron IDs to be empty.
                [ from_neuron_IDs, to_neuron_IDs ] = deal( [  ] );
                
            end
            
        end
        
        
        % Implement a function to assign the desired delta value to each synapse based on the neuron order that we want to follow.
        function self = neuron_ID_order2synapse_delta( self )
            
            % Retrieve the IDs of the from and to neurons.
            [ from_neuron_IDs, to_neuron_IDs ] = self.neuron_ID_order2from_to_neuron_IDs( self.neuron_ID_order );
            
            % Retrieve all of the synapse IDs.
%             synapse_IDs = self.get_synapse_property( 'all', 'ID' );
            synapse_IDs = self.get_all_synapse_IDs(  );
            
            
            % Retrieve the synapse IDs for each synapse the connects the specified neurons.
            synapse_IDs_oscillatory = self.from_to_neuron_IDs2synapse_IDs( from_neuron_IDs, to_neuron_IDs );
            
            % Retrieve the synapse IDs for all of the other neurons.
            synapse_IDs_bistable = 1;
            
            % Set the delta value of each of the specified synapses.
            self = self.set_synapse_property( synapse_IDs_oscillatory, self.delta_oscillatory, 'delta' );
            
            % Set the delta value of each of the remaining synapses.
            self = self.set_synapse_property( synapse_IDs_bistable, self.delta_bistable, 'delta' );
            
            
        end
        
        
        % Implement a function to compute the delta matrix.
        function deltas = compute_delta_matrix( self, neuron_ID_order, delta_bistable, delta_oscillatory )
            
            % This function computes the delta matrix required to make a multistate CPG oscillate in a specified order.
            
            % Inputs:
            % neuron_order = 1 x num_neurons array that specifies the order in which the multistate CPG should oscillate.
            % delta_bistable = Scalar delta value that describes the steady state voltage to which low neurons should be sent in bistable configurations.
            % delta_oscillatory = Scalar delta value that describes the steady state voltage to which low neurons should be sent in oscillatory configurations.
            
            % Outputs:
            % deltas = num_neurons x num_neurons matrix whose ij entry is the delta value that describes the synapse from neuron j to neuron i.
            
            % Compute the number of neurons.
            num_oscillatory_synapses = length( neuron_ID_order );
            
            % Initialize the delta matrix to be completely bistable.
            deltas = delta_bistable*ones( num_oscillatory_synapses, num_oscillatory_synapses );
            
            % Switch the desired synapses to be oscillatory.
            for k = 1:num_oscillatory_synapses                              % Iterate through each oscillatory synapse.
                
                % Compute the index of the next neuron in the chain.
                j = mod(k, num_oscillatory_synapses) + 1;
                
                % Compute the from and to indexes.
                from_index = neuron_ID_order(k);
                to_index = neuron_ID_order(j);
                
                % Set the appropriate synapse to be oscillatory.
                deltas(to_index, from_index) = delta_oscillatory;
                
            end
            
            % Zero out the diagonal entries.
            deltas(1:(1 + size(deltas, 1)):end) = 0;
            
        end
        
        
        
        
    end
end

