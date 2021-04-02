classdef slave_class
    
    % This class contains properties and methods related to the slave microcontrollers.
    
    % Define the slave data class properties.
    properties
        slave_ID
        muscle_ID
        pressure_sensor_ID1
        pressure_sensor_ID2
        joint_ID
        pressure_value1
        pressure_value2
        joint_value
        desired_pressure
    end
    
    % Define the slave data class methods.
    methods
        
        % Implement the class constructor.
        function self = slave_class( slave_ID, muscle_ID, pressure_sensor_ID1, pressure_sensor_ID2, joint_ID, pressure_value1, pressure_value2, joint_value, desired_pressure )
            
            % Define the desired pressure.
            if nargin < 9, self.desired_pressure = 0; else, self.desired_pressure = desired_pressure; end

            % Define the joint value.
            if nargin < 8, self.joint_value = 0; else, self.joint_value = joint_value; end
            
            % Define the second pressure sensor value.
            if nargin < 7, self.pressure_value2 = 0; else, self.pressure_value2 = pressure_value2; end
            
            % Define the first pressure sensor value.
            if nargin < 6, self.pressure_value1 = 0; else, self.pressure_value1 = pressure_value1; end
            
            % Define the joint ID.
            if nargin < 5, self.joint_ID = 0; else, self.joint_ID = joint_ID; end
            
            % Define the second pressure sensor ID.
            if nargin < 4, self.pressure_sensor_ID2 = 0; else, self.pressure_sensor_ID2 = pressure_sensor_ID2; end
            
            % Define the first pressure sensor ID.
            if nargin < 3, self.pressure_sensor_ID1 = 0; else, self.pressure_sensor_ID1 = pressure_sensor_ID1; end
            
            % Define the muscle ID.
            if nargin < 2, self.muscle_ID = 0; else, self.muscle_ID = muscle_ID; end
            
            % Define the slave ID.
            if nargin < 1, self.slave_ID = 0; else, self.slave_ID = slave_ID; end
            
        end
        
%         function outputArg = method1(self, inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = self.Property1 + inputArg;
%         end

    end
end

