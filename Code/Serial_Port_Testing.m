%% Serial Port Testing.

%Clear Everything
clear, close('all'), clc


%% Test the Serial Port.

%Open the serial port.
serial_port = OpenAtmegaSerialPort( 'COM6', 9600 );

% %Write the low and high bytes to the serial port.
% fwrite(serial_port, plow), fwrite(serial_port, phigh)

%Read in a value from the serial port.
% y = fread(serial_port, 1) + fread(serial_port, 1)*256;

%Set the window size.
window_size = 2;

%Define the integer array.
xs = [1235 6543 4561 324];

while true
    
    %Write out the integer array.
    serial_write_int_array2micro( serial_port, xs )
    
    %Read in an int from the microcontroller.
    int_array = serial_read_micro_int_array( serial_port, window_size );
    
    %Display the string read from the microcontroller.
    disp(int_array)
    
end


%Close the serial port.
CloseSerialPort(serial_port)

