classdef array_manager_class

    % This class constains properties and methods related to converting data types.
    
    
    %% ARRAY MANAGER PROPERTIES
    
    % Define the class properties.
    properties ( Constant = true )

        
        
    end
    
    
    %% ARRAY MANAGER SETUP FUNCTIONS
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = array_manager_class(  )

            
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
        
      
        
            
    end
end

