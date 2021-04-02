function serial_write_command_data_singles2micro(serial_port, values, IDs )
%This function writes a single array, single_array, to the serial port, serial_port, for a microcontroller to interpret.

%Convert the current single array to a byte array.
byte_array = SingleArray2ByteArray( values );

%Retrieve the number of commands to issue.
num_commands = length(values);

%Define the number of bytes per single.
num_bytes_per_single = 4;

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the number of singles to expect.
fwrite(serial_port, num_commands)

%Write each of the commands to the serial port.
for k = 1:num_commands                              %Iterate through each of the commands...

    %Compute the critical location from which to send bytes out of the value byte array.
    loc = 1 + num_bytes_per_single*(k - 1);
    
    %Write the ID associated with this command.
    fwrite(serial_port, IDs(k));
    
    %Write the value associated with this command.
    fwrite(serial_port, byte_array(loc: loc + 3));
    
end

%Write out the end sequence.
WriteEndSequence( serial_port )

end

