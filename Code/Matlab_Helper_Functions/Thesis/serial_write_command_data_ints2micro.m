function serial_write_command_data_ints2micro(serial_port, values, IDs )
%This function writes the uint16 values, values, and associated uint8 IDs, IDs, to serial port, serial_port. 

%Convert the uint16 value array to an uint8 array of bytes.
byte_array = typecast(uint16(values), 'uint8');

%Retrieve the number of commands to issue.
num_commands = length(values);

%Define the number of bytes per uint16.
num_bytes_per_int = 2;

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the number of singles to expect.
fwrite(serial_port, num_commands)

%Write each of the commands to the serial port.
for k = 1:num_commands                              %Iterate through each of the commands...

    %Compute the critical location from which to send bytes out of the value byte array.
    loc = 1 + num_bytes_per_int*(k - 1);
    
    %Write the ID associated with this command.
    fwrite(serial_port, IDs(k));
    
    %Write the value associated with this command.
    fwrite(serial_port, byte_array(loc: loc + 1));
    
end

%Write out the end sequence.
WriteEndSequence( serial_port )

end

