function [ single_array ] = serial_read_micro_single_array( serial_port, window_size )
%% Function Summary
%This script reads in a single array from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the number of bytes to read in.  Finally, it reads in the single array.

%INPUTS:
%serial_port = Serial port used to communicate with the microcontroller.
%window_size = The number of bytes of 1s used in the start up sequence to establish synchronized communication.

%OUTPUTS:
%myint = int to read from the microcontroller.

%% Handle Default Arguments.

%Set the window size to two if it is not specified by the user.
if nargin < 2, window_size = 2; end

%% Established Synchronized Communication by Searching for the Startup Key.

%Wait for the start sequence to ensure synchronization.
WaitForStartSequence( serial_port, window_size )

%% Read in the Single Array from the Microcontroller.

%Read in the number of bytes to read in for the single array.
num_bytes = fread(serial_port, 1);

%Ensure that all of the integer low and high bytes have been sent before attempting to read them.
while (serial_port.BytesAvailable < num_bytes), end

%Read in the int of the specified length.
byte_array = fread(serial_port, num_bytes);

%Convert the byte array into an array of singles.
single_array = ByteArray2SingleArray( byte_array );

end

