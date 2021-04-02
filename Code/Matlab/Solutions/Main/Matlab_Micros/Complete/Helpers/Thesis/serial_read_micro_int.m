function [ myint ] = serial_read_micro_int( serial_port, window_size )
%% Function Summary
%This script reads in an int from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the number of bytes to read in.  Finally, it reads in the desired int.

%INPUTS:
%serial_port = Serial port used to communicate with the microcontroller.
%window_size = The number of bytes of 1s used in the start up sequence to establish synchronized communication.

%OUTPUTS:
%myint = int to read from the microcontroller.


%% Established Synchronized Communication by Searching for the Startup Key.

%Wait for the start sequence to ensure synchronization.
WaitForStartSequence( serial_port, window_size )

%% Read in the Int from the Microcontroller.

%Read in the number of bytes to read in for the int.
num_bytes = fread(serial_port, 1);

%Read in the int of the specified length.
myint = fread(serial_port, num_bytes);

%Convert the bytes into an integer.
myint = low_high_bytes2int( myint(1), myint(2) );

end

