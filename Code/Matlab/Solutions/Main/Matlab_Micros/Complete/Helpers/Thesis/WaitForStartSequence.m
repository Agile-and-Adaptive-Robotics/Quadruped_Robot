function WaitForStartSequence( serial_port, window_size, bverbose )
%This function cycles through the buffer until the specified start sequence is detected.  For animatlab this start sequence is [255 255].

%Set the default input arguments.
if nargin < 3, bverbose = false; end
if nargin < 2, window_size = 2; end

%Preallocate the previous read bytes to zeros.
byte_window = zeros(1, window_size);

%Wait for there to be enough information to fill up the window.
while (serial_port.BytesAvailable < (window_size + 2))                      %Determine whether their are enough bytes for the start sequence...
    
    %Print out the current status if desired.
    if bverbose                                     %Determine whether to print the status message.
        fprintf('Not enough bytes for start sequence. %0.0f of %0.0f bytes detected.\n', serial_port.BytesAvailable, (window_size + 2))
    end
    
end

%Preallocate the sequence detected flag to false.
bStartSequenceDetected = 0;

%Search for the starting sequence.
while (serial_port.BytesAvailable > 0) && (~bStartSequenceDetected)                      %While there is still data to read and the start sequence has not been detected...
    
    %Determine whether to print the status message.
    if bverbose                                                                         %If we want to print a status message...
        fprintf('Waiting for start sequence. Current window: '), disp(byte_window)      %Print out the status message.
    end
    
    %Shift the window over.
    byte_window = [fread(serial_port, 1) byte_window(1:(window_size - 1))];
    
    %Determine whether the start sequence has been detected.
    bStartSequenceDetected = sum(byte_window == 255*ones(1, window_size)) == window_size;
    
end

end

