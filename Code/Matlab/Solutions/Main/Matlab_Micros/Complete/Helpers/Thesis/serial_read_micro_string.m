function [ mystr ] = serial_read_micro_string( serial_port, window_size )
%% Function Summary
%This script reads in a string from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the length of the string to read in.  Finally, it reads in the desired string.

%INPUTS:
%serial_port = Serial port used to communicate with the microcontroller.
%window_size = The number of bytes of 1s used in the start up sequence to establish synchronized communication.

%OUTPUTS:
%mystr = String read from the microcontroller.


%% Established Synchronized Communication by Searching for the Startup Key.

%Preallocate the last four read bytes to zeros.
byte_window = zeros(1, window_size);

%Wait for there to be enough information to fill up the window.
while (serial_port.BytesAvailable < (window_size + 2)), end

%Preallocate the sequence detected flag to false.
bStartSequenceDetected = 0;

%Search for the starting sequence.
while (serial_port.BytesAvailable > 0) && (~bStartSequenceDetected)                      %While there is still data to read and the start sequence has not been detected...

    %Shift the window over.
    byte_window = [fread(serial_port, 1) byte_window(1:(window_size - 1))];

    %Determine whether the start sequence has been detected.
    bStartSequenceDetected = sum(byte_window == 255*ones(1, window_size)) == window_size;
end

%% Read in the String from the Microcontroller.

%Read in the number of bytes to read in for the string.
num_bytes = fread(serial_port, 1);

%Read in the string of the specified length.
mystr = fread(serial_port, num_bytes);

%Convert from a byte string to a character string.
mystr = char(mystr');

end

