function serial_write_sensor_data2animatlab(serial_port, values, IDs )
%This function writes a single array, single_array, to the serial port, serial_port, for a microcontroller to interpret.

%Convert the ID uint16 array to a byte array.
ID_byte_array = typecast(uint16(IDs), 'uint8');

%Convert the value single array to a byte array.
value_byte_array = SingleArray2ByteArray( values );

%Retrieve the number of commands to issue.
num_commands = length(values);

%Define the number of bytes per single.
num_bytes_per_single = 4;

%Define the number of bytes per data point.
num_bytes_per_data_point = 6;

%Compute the total number of bytes that will be sent in this sentence.
num_bytes = num_bytes_per_data_point*num_commands + 6;                    %[#] Total number of bytes in this sentence.  There are 6 bytes per command (2 bytes for ID, 4 bytes for value), as well as 2 start bytes, 1 data type byte, 2 sentence length bytes, and 1 check sum byte.

%Compute the bytes associated with the total number of bytes in this sequence.
num_bytes_bytes = typecast(uint16(num_bytes), 'uint8');

%Compute the check sum.
check_sum = 2*255 + 1 + sum(num_bytes_bytes) + sum(ID_byte_array) + sum(value_byte_array);

%Ensure that the check sum is within the the [0 255] range.
check_sum = mod(check_sum, 256);

%Write the start sequence.
WriteStartSequence( serial_port )

%Write the data type.
fwrite(serial_port, 1);

%Write the number of singles to expect.
fwrite(serial_port, num_bytes_bytes)

%Write each of the commands to the serial port.
for k = 1:num_commands                              %Iterate through each of the commands...

    %Compute the critical location from which to send bytes out of the ID byte array.
    loc_ID = 1 + 2*(k - 1);
    
    %Compute the critical location from which to send bytes out of the value byte array.
    loc_value = 1 + num_bytes_per_single*(k - 1);
    
    %Write the ID associated with this command.
    fwrite( serial_port, ID_byte_array( loc_ID:(loc_ID + 1) ) );
    
    %Write the value associated with this command.
    fwrite( serial_port, value_byte_array( loc_value:(loc_value + 3) ) );
    
end

%Write out the check sum.
fwrite(serial_port, check_sum)

end

