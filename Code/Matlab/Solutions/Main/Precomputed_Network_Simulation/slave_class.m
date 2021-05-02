classdef slave_class
    
    % This class contains properties and methods related to the slave microcontrollers.
    
    % Define the slave data class properties.
    properties
        slave_ID
        muscle_ID
        muscle_name
        pressure_sensor_ID1
        pressure_sensor_ID2
        encoder_ID
        encoder_name
        measured_pressure_value1
        measured_pressure_value2
        measured_encoder_value
        desired_pressure
    end
    
    % Define the slave data class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_class( slave_ID, muscle_ID, muscle_name, pressure_sensor_ID1, pressure_sensor_ID2, encoder_ID, encoder_name, measured_pressure_value1, measured_pressure_value2, measured_encoder_value, desired_pressure )
            
            % Define the desired pressure.
            if nargin < 11, self.desired_pressure = uint16( 0 ); else, self.desired_pressure = desired_pressure; end
            if nargin < 10, self.measured_encoder_value = uint16( 0 ); else, self.measured_encoder_value = measured_encoder_value; end
            if nargin < 9, self.measured_pressure_value2 = uint16( 0 ); else, self.measured_pressure_value2 = measured_pressure_value2; end
            if nargin < 8, self.measured_pressure_value1 = uint16( 0 ); else, self.measured_pressure_value1 = measured_pressure_value1; end
            if nargin < 7, self.encoder_name = {''}; else, self.encoder_name = encoder_name; end
            if nargin < 6, self.encoder_ID = uint8( 0 ); else, self.encoder_ID = encoder_ID; end
            if nargin < 5, self.pressure_sensor_ID2 = uint8( 0 ); else, self.pressure_sensor_ID2 = pressure_sensor_ID2; end
            if nargin < 4, self.pressure_sensor_ID1 = uint8( 0 ); else, self.pressure_sensor_ID1 = pressure_sensor_ID1; end
            if nargin < 3, self.muscle_name = {''}; else, self.muscle_name = muscle_name; end
            if nargin < 2, self.muscle_ID = uint8( 0 ); else, self.muscle_ID = muscle_ID; end
            if nargin < 1, self.slave_ID = uint8( 0 ); else, self.slave_ID = slave_ID; end
            
        end
        
    end
end

