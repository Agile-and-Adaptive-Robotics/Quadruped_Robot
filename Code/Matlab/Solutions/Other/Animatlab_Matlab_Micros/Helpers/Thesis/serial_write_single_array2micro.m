function serial_write_single_array2micro(serial_port, single_array )
%This function writes a single array, single_array, to the serial port, serial_port, for a microcontroller to interpret.

%Convert the current single array to a byte array.
byte_array = SingleArray2ByteArray( single_array );

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the number of singles to expect.
fwrite(serial_port, length(single_array))

%Write the byte array to the serial port.
fwrite(serial_port, byte_array)

%Write out the end sequence.
WriteEndSequence( serial_port )

end

