function [ sensor_data_doubles, sensor_data_voltages ] = ConvertSensorInts2Doubles( sensor_data_ints )
%% Function Description.
%This function converts the sensor data inputs reported from the microcontroller into intelligible Matlab doubles.

%INPUTS: sensor_data_ints = an array of sensor data integers in the range 0-65535.
%OUTPUTS: sensor_data_doubles = an array of sensor data doubles in the range appropriate for the corresponding sensor.


%% Set the Number of Expected Sensors of Each Type.

%Define the total number of expected sensors, the expected number of pressure sensors, and the expected number of angle sensors.
num_pressure_sensors = 24; num_angle_sensors = 14; num_sensors = num_pressure_sensors + num_angle_sensors;

%Throw an error if the number of sensors is not the expected value.
if (length(sensor_data_ints) ~= num_sensors), error('There must be 38 sensor values reported from the microcontroller.'), end

%% Set the Voltage, Pressure, and Angle Bounds.

%Set the voltage bounds for each sensor.
% voltage_bounds = [0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5];
voltage_bounds = [0 4.83; 0 4.83; 0 4.88; 0 4.88; 0.120 4.82; 0.278 4.96; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0.600 3.96; 0 4.30; 0 4.16; 0.0593 4.28; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5];
% voltage_bounds = [0 3.81; 0 3.81; 0 3.81; 0 3.81; 0.120 3.81; 0.278 3.81; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0.600 3.96; 0 4.30; 0 4.16; 0.0593 4.28; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5; 0 5];

%Set the pressure bounds.
pressure_bounds = [0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90];

%Set the angle bounds.
angle_bounds = [0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90; 0 90];

%% Convert the Sensor Data Integers to Meaningful Sensor Data Doubles.

%Preallocate variables to store the sensor data voltages and doubles.
[sensor_data_voltages, sensor_data_doubles] = deal( zeros(1, num_sensors) );

%Convert the sensor data integers to meaningful sensor data doubles.
for k = 1:num_sensors                                                                                                                   %Iterate through each of the sensor values...
   
    %Convert the sensor data integer to a sensor data voltage.
    sensor_data_voltages(k) = interp1([0 65535], voltage_bounds(k, :), sensor_data_ints(k), 'linear', 'extrap');
    
    %Convert the sensor data voltage to a double in the range appropriate for this sensor.
    if k <= num_pressure_sensors                                                                                                            %If this is a pressure sensor...
        sensor_data_doubles(k) = interp1(voltage_bounds(k, :), pressure_bounds(k, :), sensor_data_voltages(k), 'linear', 'extrap');                              %Convert the sensor voltage using the appropriate pressure bound.
    elseif k <= num_sensors                                                                                                                 %If this is an angle sensor...
        sensor_data_doubles(k) = interp1(voltage_bounds(k, :), angle_bounds(k - num_pressure_sensors, :), sensor_data_voltages(k), 'linear', 'extrap');          %Convert the sensor voltage using the appropriate angle bound.
    end
    
end

end

