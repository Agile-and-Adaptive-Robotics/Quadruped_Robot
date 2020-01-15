function s = OpenAtmegaSerialPort( Port, BaudRate )

%This function opens serial port communication.

%Retrieve any open ports with the specified name.
open_port = instrfind({'Port', 'Status'}, {Port, 'open'});

%Ensure that the serial port is closed before attempting to open it.
if ~isempty(open_port)                  %If this serial port is already in use...
    CloseSerialPort(open_port);         %Close the serial port before proceeding...
end

%State that we are opening the serial port.
fprintf('\nOPENING SERIAL PORT. Please Wait...\n')
    
%Define the serial port.
s = serial(Port, 'BaudRate', BaudRate);

%Open the serial port.
fopen(s);

%Wait for the serial port to connect.
% pause(7)            %Depending on the device, it may take a few seconds for the serial port to open.  For Matlab / Animatlab this should be relatively immediate.

%Clear any existing commands in the serial port.
flushinput(s), flushoutput(s)

%State that the serial port is open.
fprintf('Done: Serial Port Open.\n\n')

end

