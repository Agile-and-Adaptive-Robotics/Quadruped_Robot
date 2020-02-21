function serial_write_int_array2micro( serial_port, int_array )
%This function writes an integer array, int_array, to the serial port, serial_port, for a microcontroller to interpret.

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the number of integers to expect.
fwrite(serial_port, length(int_array))

%Convert each integer to its low and high bytes.  Send these bytes to the serial port.
for j = 1:length(int_array)                                        %Iterate through each of the integers in the array...
    
    %Convert the integers into their low and high bytes.
    [low_byte, high_byte] = int2low_high_bytes(int_array(j));
    
    %Write out the low and high bytes.
    fwrite(serial_port, low_byte), fwrite(serial_port, high_byte)
end

%Write out the end sequence.
WriteEndSequence( serial_port )

end

