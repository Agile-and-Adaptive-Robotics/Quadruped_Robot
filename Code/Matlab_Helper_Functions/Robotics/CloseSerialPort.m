function CloseSerialPort( s )

%This function clears any existing commands in the serial port queue and closes the serial port.

%State that we are closing the serial port.
fprintf('\nCLOSING SERIAL PORT. Please Wait...\n')

%Clear any existing commands in the serial port.
flushinput(s), flushoutput(s)

%Close the Serial Port.
fclose(s); delete(s);

%State that the serial port is closed.
fprintf('Done: Serial Port Closed.\n\n')

end

