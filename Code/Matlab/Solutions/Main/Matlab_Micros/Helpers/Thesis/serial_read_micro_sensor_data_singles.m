function [ values, IDs ] = serial_read_micro_sensor_data_singles( serial_port, window_size )
%% Function Summary
%This script reads in a sensor data single array from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the number of bytes to read in.  Finally, it reads in the single array.

%INPUTS:
%serial_port = Serial port used to communicate with the microcontroller.
%window_size = The number of bytes of 1s used in the start up sequence to establish synchronized communication.

%OUTPUTS:
%values = An array of singles that are the sensor data values.
%IDs = An arary of ints indicating to which sensor the data belongs.

%% Handle Default Arguments.

%Set the window size to two if it is not specified by the user.
if nargin < 2, window_size = 2; end

%Define the number of bytes per ID / Value pair.
num_bytes_per_pair = 5;

%% Established Synchronized Communication by Searching for the Startup Key.

%Wait for the start sequence to ensure synchronization.
WaitForStartSequence( serial_port, window_size )

%% Read in the Single Array from the Microcontroller.

%Read in the number of sensor ID / Value Pairs to read in.
num_pairs = fread(serial_port, 1);

%Compute the number of bytes to read in.
num_bytes = num_bytes_per_pair*num_pairs;

%Ensure that all of the integer low and high bytes have been sent before attempting to read them.
while (serial_port.BytesAvailable < num_bytes), end

%Read in the specified number of bytes.
byte_array = fread(serial_port, num_bytes);

%Retrieve the bytes associated with the IDs.
IDs = byte_array(1:num_bytes_per_pair:end);

%Remove the ID bytes from the byte array.
byte_array(1:num_bytes_per_pair:end) = [];

%Convert the remaining bytes into an array of singles.
values = ByteArray2SingleArray( byte_array );

end

