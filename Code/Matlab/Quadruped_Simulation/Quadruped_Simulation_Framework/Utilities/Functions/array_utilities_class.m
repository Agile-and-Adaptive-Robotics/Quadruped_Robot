classdef array_utilities_class
    
    % This class constains properties and methods related to converting data types.
    
    
    %% ARRAY MANAGER PROPERTIES
    
    % Define the class properties.
    properties ( Constant = true )
        
        
        
    end
    
    
    %% ARRAY MANAGER SETUP FUNCTIONS
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = array_utilities_class(  )
            
            
        end
        
        
        %% ARRAY FUNCTIONS
        
        % Implement a function to remove all specified values from an array.
        function array = remove_entries( ~, array, entries_to_remove )
            
            % Retrieve the number of entries to remove.
            num_entries_to_remove = length( entries_to_remove );
            
            % Remove each of the specified entries.
            for k = 1:num_entries_to_remove                          % Iterate through each of the entries ot remove...
                
                % Remove this entry.
                array( array == entries_to_remove(k) ) = [  ];
                
            end
            
        end
        
        
        % Implement a function to determine whether a value exists in an array.
        function [ b_match_found, match_logicals, match_indexes ] = is_value_in_array( ~, value, array )
            
            % Determine how to process the inputs.
            if ( ~isempty( value ) ) && ( ~isempty( array ) )                           % If neither the value nor the array are empty...
            
                % Retrieve the number of array values.
                num_array_values = length( array );

                % Determine which array entries match the value.
                match_logicals = value == array;

                % Define an array of indexes.
                indexes = 1:num_array_values;

                % Retrieve the indexes of the array entries that match the value.
                match_indexes = indexes( match_logicals );

                % Determine whether the value is contained in the array.
                b_match_found = any( match_logicals );
            
            else                                                                            % Otherwise...
                
                % Set the match found flag to false.
                b_match_found = false;
                
                % Set the match logicals and match indexes to be empty.
                [ match_logicals, match_indexes ] = deal( [  ] );
                
            end
                
        end
        
        
        % Implement a function to determine whether any of an array of values is contained in a given array.
        function [ b_match_founds, match_logicals, match_indexes ] = are_values_in_array( self, values, array )
            
            % Retrieve the number of values to check.
            num_values = length( values );
            
            % Retrieve the number of array values.
            num_array_values = length( array );
            
            % Preallocate arrays to store the uniqueness flags, match logicals, and match indexes.
            b_match_founds = false( num_values, 1 );
            [ match_logicals, match_indexes ] = deal( zeros( num_values, num_array_values ) );
            
            % Determine whether each value is in the array.
            for k = 1:num_values                % Iterate through each of the values...
                
                % Determine whether this value is in the array.
                [ b_match_founds(k), match_logicals(k, :), match_indexes(k, :) ] = self.is_value_in_array( values(k), array );
                
            end
            
        end
        
        
        % Implement a function to get the lowest whole number not in an array.
        function n = get_lowest_natural_number( self, exclude_array )
            
            % Determine the lowest natural number (excluding the array of 
            if nargin < 2                           % If no values were given to exclude...
                
                % Set the lowest natural number to one.
                n = 1;
                
            else                                    % Otherwise...
                           
                % Initialize the unique flag to false.
                b_unique = false;
                
                % Initialize the lowest natural number to be zero.
                n = 0;
                
                % Compute the lowest natural number.
                while ~b_unique                                 % While the natural number that we have selected is not unique...
                    
                    % Advance the candidate natural number.
                    n = n + 1;
                    
                    % Determine whether this natural number candidate is in the exclude array.
                    if ~self.is_value_in_array( n, exclude_array )                  % If this natural number candidate is not in the exclude array...
                        
                        % Set the unique flag to true.
                        b_unique = true;
                        
                    end
                    
                end
                
            end
            
            
        end
        
        
        % Implement a function to compute the step size of an array.
        function step_size = compute_step_size( ~, array )
            
            % Determine how to compute the step size of the array.
           if length( array ) > 1                                       % If there are at least two array elements...
               
               % Compute the step size.
               step_size = mean( array(2:end) - array(1:end-1) );
               
           else                                                         % Otherwise...
              
               % Set the step size to be empty.
               step_size = [  ];
               
           end
            
        end
        
        
        % Implement a function to scale a domain in an absolute sense.
        function domain = scale_domain_absolute( ~, domain, scale )
            
            % Determine whether to directly add the scale.
            if domain(1) == 0                                           % If this bound is zero...
                
                % Directly add the scale to the bound.
                domain(1) = domain(1) - scale;
                
            else                                                        % Otherwise...
                
                % Scale the domain lower bound.
                domain(1) = domain(1) - abs( scale*domain(1) );
                
            end
            
            % Determine whether to directly add the scale.
            if domain(2) == 0                                           % If this bound is zero...
                
                % Directly add the scale to the bound.
                domain(2) = domain(2) + scale;
                
            else                                                        % Otherwise...
                
                % Scale the domain upper bound.
                domain(2) = domain(2) + abs( scale*domain(2) );
                
            end

        end
        
        % Implement a function to scale a domain in a relative sense.
        function domain = scale_domain_relative( ~, domain, scale )
           
            % Compute the middle of the domain.
            middle = ( domain(2) - domain(1) )/2 + domain(1);

            % Center the domain at the origin.
            domain_centered = domain - middle;
            
            % Scale the domain.
            domain_scaled = scale*domain_centered;
            
            % Uncenter the scaled domain.
            domain = domain_scaled + middle; 
            
        end
        
        
        % Implement a function to expand a given domain.
        function domain = scale_domain( self, domain, scale, type )
        
            % Define the default input arguments.
            if nargin < 4, type = 'relative'; end
            
            % Determine how to perform the scaling.
            if strcmpi( type, 'relative' )                                      % If the scaling type is relative...
                
                % Scale the domain in a relative sense.
                domain = self.scale_domain_relative( domain, scale );
                
            elseif strcmpi( type, 'absolute' )                                  % If the scaling type is absolute...
                
                % Scale the domain in an absolute sense.
                domain = self.scale_domain_absolute( domain, scale );
                
            else                                                                % Otherwise...
                
                % Throw an error.
                error( 'Unrecognized scaling type: %s.', type )
                
            end
            
        end
            
        
    end
end

