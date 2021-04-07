classdef conversion_manager_class

    % This class constains properties and methods related to converting data types.
    
    % Define the class properties.
    properties
        MAX_UINT16_VALUE
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = conversion_manager_class()

            % Set the maximum uint16 value constant.
            self.MAX_UINT16_VALUE = 65535;
            
        end
        
        % Implement a function to convert a double to a uint16.
        function uint16_value = double2uint16( self, double_value, double_domain )
            
            % Compute the uint16 value.
            uint16_value = uint16( interp1( double_domain, [0 self.MAX_UINT16_VALUE], double_value ) );
            
        end
        
        % Implement a function to convert a uint16 to double.
        function double_value = uint162double( self, uint16_value, double_domain )
            
            % Compute the double value.
            double_value = interp1( [0 self.MAX_UINT16_VALUE], double_domain, double( uint16_value ) );
            
        end
        
    end
end

