function WriteStartSequence( serial_port, window_size )
%This function writes out the starting byte sequence for serial port communication.

%Set the default window size to two.
if nargin < 2, window_size = 2; end

%Write out the start sequence.
for k = 1:window_size                       %Iterate the specified number of times...
    fwrite(serial_port, 255)                %Write out a sequence of 255s as the start sequence.  The number of 255s to write defaults to two but can be set by the user.
end

end

