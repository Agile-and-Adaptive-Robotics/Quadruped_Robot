function [ int_array ] = serial_read_micro_int_array( serial_port, window_size )
%% Function Summary
%This script reads in an int from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the number of bytes to read in.  Finally, it reads in the desired int.

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

%% Read in the Int from the Microcontroller.

%Read in the number of bytes to read in for the int.
num_bytes = fread(serial_port, 1);

%Ensure that all of the integer low and high bytes have been sent before attempting to read them.
while (serial_port.BytesAvailable < num_bytes), end

%Read in the int of the specified length.
byte_array = fread(serial_port, num_bytes);

%Preallocate an array to store the integers.
int_array = zeros(1, length(byte_array)/2);

%Convert each pair of low and high byes to integers.
for k = 1:length(int_array)
    
    %Compute the target location in the integer array.
    loc = 2*k - 1;
    
    %Convert the low and high bytes for this iteration into an integer.
    int_array(k) =  low_high_bytes2int( byte_array(loc), byte_array(loc + 1));
    
end


end

