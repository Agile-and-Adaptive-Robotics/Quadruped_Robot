classdef slave_manager_class
    
    % This class contains properties and methods related to managing the slave microcontrollers.
    
    % Define the class properties.
    properties
        slaves
        num_slaves
    end
    
    % Define the class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_manager_class( slave_IDs, muscle_IDs, muscle_names, pressure_sensor_ID1s, pressure_sensor_ID2s, joint_IDs, joint_names, measured_pressure_value1s, measured_pressure_value2s, measured_joint_values, desired_pressures )
            
            % Define the default class properties.
            if nargin < 11, desired_pressures = 0; end
            if nargin < 10, measured_joint_values = 0; end
            if nargin < 9, measured_pressure_value2s = 0; end
            if nargin < 8, measured_pressure_value1s = 0; end
            if nargin < 7, joint_names = {''}; end
            if nargin < 6, joint_IDs = 0; end
            if nargin < 5, pressure_sensor_ID2s = 0; end
            if nargin < 4, pressure_sensor_ID1s = 0; end
            if nargin < 3, muscle_names = {''}; end
            if nargin < 2, muscle_IDs = 0; end
            if nargin < 1, slave_IDs = 0; end
            
            % Determine the number of slaves that we want to create.
            self.num_slaves = length(slave_IDs);
            
            % Ensure that we have the correct number of properties for each slave.
            slave_IDs = self.validate_property( slave_IDs, 'slave_IDs' );
            muscle_IDs = self.validate_property( muscle_IDs, 'muscle_IDs' );
            muscle_names = self.validate_property( muscle_names, 'muscle_names' );
            pressure_sensor_ID1s = self.validate_property( pressure_sensor_ID1s, 'pressure_sensor_ID1s' );
            pressure_sensor_ID2s = self.validate_property( pressure_sensor_ID2s, 'pressure_sensor_ID2s' );
            joint_IDs = self.validate_property( joint_IDs, 'joint_IDs' );
            joint_names = self.validate_property( joint_names, 'joint_names' );
            measured_pressure_value1s = self.validate_property( measured_pressure_value1s, 'measured_pressure_value1s' );
            measured_pressure_value2s = self.validate_property( measured_pressure_value2s, 'measured_pressure_value2s' );
            measured_joint_values = self.validate_property( measured_joint_values, 'measured_joint_values' );
            desired_pressures = self.validate_property( desired_pressures, 'desired_pressures' );

            % Preallocate an array of muscles.
            self.slaves = repmat( slave_class(), 1, self.num_slaves );
            
            % Create each slave object.
            for k = 1:self.num_slaves              % Iterate through each slave...
                
                % Create this slave.
                self.slaves(k) = slave_class( slave_IDs(k), muscle_IDs(k), muscle_names{k}, pressure_sensor_ID1s(k), pressure_sensor_ID2s(k), joint_IDs(k), joint_names{k}, measured_pressure_value1s(k), measured_pressure_value2s(k), measured_joint_values(k), desired_pressures(k) );
                
            end
            
        end
        
        
        % Implement a function to validate the input properties.
        function x = validate_property( self, x, var_name )
        
            % Set the default variable name.
            if nargin < 3, var_name = 'properties'; end
            
            % Determine whether we need to repeat this property for each muscle.
            if length(x) ~= self.num_slaves                % If the number of instances of this property do not agree with the number of slaves...
               
                % Determine whether to repeat this property for each muscle.
                if length(x) == 1                               % If only one slave property was provided...
                    
                    % Repeat the slave property.
                    x = repmat( x, 1, self.num_slaves );
                    
                else                                            % Otherwise...
                    
                    % Throw an error.
                    error( 'The number of provided %s must match the number of slaves being created.', var_name )
                    
                end
                
            end
            
        end
        
        
        
    end
end

