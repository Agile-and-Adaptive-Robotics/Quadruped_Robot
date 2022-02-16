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
        function [ b_unique, match_logicals, match_indexes ] = is_value_in_array( ~, value, array )
        
            % Retrieve the number of array values.
            num_array_values = length( array );
            
            % Determine which array entries match the value.
            match_logicals = value == array;
            
            % Define an array of indexes.
            indexes = 1:num_array_values;
            
            % Retrieve the indexes of the array entries that match the value.
            match_indexes = indexes( match_logicals );
            
            % Determine whether the value is contained in the array.
            b_unique = all( ~match_logicals );
            
        end
            
        
        % Implement a function to determine whether any of an array of values is contained in a given array.
        function [ b_unique, match_logicals, match_indexes ] = are_values_in_array( values, array )
        
            % Retrieve the number of values to check.
            num_values = length( values )
            
            % Preallocate arrays to store the 
            
            [ b_unique, match_logicals, match_indexes ] = self.is_value_in_array( value, array );
            
        end
            
            
    end
end

