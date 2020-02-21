function serial_write_byte_array2micro( serial_port, byte_array )
%This function writes an integer array, int_array, to the serial port, serial_port, for a microcontroller to interpret.

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the number of integers to expect.
fwrite(serial_port, length(byte_array))

%Write out the low and high bytes.
fwrite(serial_port, byte_array)

%Write out the end sequence.
WriteEndSequence( serial_port )

end

