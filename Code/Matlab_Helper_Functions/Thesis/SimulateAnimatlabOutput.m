function SimulateAnimatlabOutput( serial_port, value, ID )
%This function writes out a value with associated ID to serial_port in the same format as the default Animatlab serial port communication protocol.

%Convert the value to bytes.
value_bytes = typecast(single(value), 'uint8');

%Write to the serial port in the same format as Animatlab.
fwrite(serial_port, 255);
fwrite(serial_port, 255);
fwrite(serial_port, 1);
fwrite(serial_port, 12);
fwrite(serial_port, 0);
fwrite(serial_port, ID);
fwrite(serial_port, 0);
fwrite(serial_port, value_bytes(1));
fwrite(serial_port, value_bytes(2));
fwrite(serial_port, value_bytes(3));
fwrite(serial_port, value_bytes(4));
fwrite(serial_port, 0);

end

