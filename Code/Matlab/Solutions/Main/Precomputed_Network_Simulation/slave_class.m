classdef slave_class
    
    % This class contains properties and methods related to the slave microcontrollers.
    
    % Define the slave data class properties.
    properties
        slave_ID
        muscle_ID
        muscle_name
        pressure_sensor_ID1
        pressure_sensor_ID2
        joint_ID
        joint_name
        measured_pressure_value1
        measured_pressure_value2
        measured_joint_value
        desired_pressure
    end
    
    % Define the slave data class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_class( slave_ID, muscle_ID, muscle_name, pressure_sensor_ID1, pressure_sensor_ID2, joint_ID, joint_name, measured_pressure_value1, measured_pressure_value2, measured_joint_value, desired_pressure )
            
            % Define the desired pressure.
            if nargin < 11, self.desired_pressure = uint16( 0 ); else, self.desired_pressure = desired_pressure; end

            % Define the joint value.
            if nargin < 10, self.measured_joint_value = uint16( 0 ); else, self.measured_joint_value = measured_joint_value; end
            
            % Define the second pressure sensor value.
            if nargin < 9, self.measured_pressure_value2 = uint16( 0 ); else, self.measured_pressure_value2 = measured_pressure_value2; end
            
            % Define the first pressure sensor value.
            if nargin < 8, self.measured_pressure_value1 = uint16( 0 ); else, self.measured_pressure_value1 = measured_pressure_value1; end
            
            % Define the joint name.
            if nargin < 7, self.joint_name = {''}; else, self.joint_name = joint_name; end
            
            % Define the joint ID.
            if nargin < 6, self.joint_ID = uint8( 0 ); else, self.joint_ID = joint_ID; end
            
            % Define the second pressure sensor ID.
            if nargin < 5, self.pressure_sensor_ID2 = uint8( 0 ); else, self.pressure_sensor_ID2 = pressure_sensor_ID2; end
            
            % Define the first pressure sensor ID.
            if nargin < 4, self.pressure_sensor_ID1 = uint8( 0 ); else, self.pressure_sensor_ID1 = pressure_sensor_ID1; end
            
            % Define the muscle name.
            if nargin < 3, self.muscle_name = {''}; else, self.muscle_name = muscle_name; end
            
            % Define the muscle ID.
            if nargin < 2, self.muscle_ID = uint8( 0 ); else, self.muscle_ID = muscle_ID; end
            
            % Define the slave ID.
            if nargin < 1, self.slave_ID = uint8( 0 ); else, self.slave_ID = slave_ID; end
            
        end
        
    end
end

