function [ values, IDs ] = serial_read_micro_sensor_data_ints( serial_port, window_size, bDebugPrint )
%% Function Summary
%This script reads in a sensor data int array from the microcontroller on serial port, serial_port.  To established synchronized communication, this script first looks for a start up sequence of window_size bytes of ones.  Next, it reads the number of bytes to read in.  Finally, it reads in the single array.

%INPUTS:
%serial_port = Serial port used to communicate with the microcontroller.
%window_size = The number of bytes of 1s used in the start up sequence to establish synchronized communication.

%OUTPUTS:
%values = An array of ints that are the sensor data values.
%IDs = An arary of ints indicating to which sensor the data belongs.

%% Handle Default Arguments.

%Set the window size to two if it is not specified by the user.
if nargin < 3, bDebugPrint = false; end
if nargin < 2, window_size = 2; end

%Define the number of bytes per ID / Value pair.
num_bytes_per_pair = 3;

%% Established Synchronized Communication by Searching for the Startup Key.

%Wait for the start sequence to ensure synchronization.
WaitForStartSequence( serial_port, window_size )

%% Read in the Single Array from the Microcontroller.

%Read in the number of sensor ID / Value Pairs to read in.
num_pairs = fread(serial_port, 1);

disp(num_pairs)

%Check to ensure that there are not 255 specified pairs.
while (num_pairs == 255)                                         %If we read that there are 255 expected pairs...
    %This is probably an error that indicates we are out of sequence.  Since the byte after 255 255 is supposed to be the number of pairs to expect, this can sometimes be fixed by interpreting the next byte as the number of pairs to expect.
    num_pairs = fread(serial_port, 1);
end

%Compute the number of bytes to read in.
num_bytes = num_bytes_per_pair*num_pairs;

%Ensure that all of the bytes have been sent before attempting to read.
while (serial_port.BytesAvailable < (num_bytes + 1)), end

%Read in the specified number of bytes.
byte_array = fread(serial_port, num_bytes);

%Read in the end byte.
end_byte = fread(serial_port, 1);

%Compute the check sum.
check_sum = 255 + 255 + num_pairs + sum(byte_array);

% %Determine whether the checksum is valid.
% if end_byte ~= mod(check_sum, 256)
%
%     warning('First check sum error detected.')
%
%     %Wait for any additional bytes that might explain this check sum error.
%     while serial_port.BytesAvailable < 1, if bDebugPrint, fprintf('Check sum error detected.  Waiting for extra bytes...\n'), end, end
%
%     %Add the previous end byte to the byte array, because this wasn't actually the last byte.
%     byte_array = [byte_array; end_byte];
%
%     %Delete the 28th element (this is sometimes an erroneous 13 for some reason that I don't understand).
%     byte_array(28) = [];
%
%     %Read in the actual last byte.
%     end_byte = fread(serial_port, 1);
%
%     %Recompute the check sum.
%     check_sum = 255 + 255 + num_pairs + sum(byte_array);
%
% end

% Determine whether the checksum is valid.
if end_byte ~= mod(check_sum, 256)
    
    % Throw a warning that the first check sum failed.
    warning('First check sum error detected.')
    
    % Create a counter for the number of bytes removed.
    num_bytes_removed = 0;
    
    % Remove any potentially unnecessary bytes.
    for k = 1:(length(byte_array) - 1)              % Iterate through each pair of bytes...
        
        % Retrieve the current bytes of interest.
        these_bytes = byte_array(k:(k + 1));
                
        % Determine whether these bytes match the erroneous sequence.
        if all(these_bytes == [13; 10])                      % If these bytes match the erroneous sequence...
            
            % Replace this entry with a negative one.
            byte_array(k) = -1;
            
            % Advance the bytes removed counter.
            num_bytes_removed = num_bytes_removed + 1;
        end
        
    end
    
    % Determine whether any bytes should be removed.
    if num_bytes_removed > 0                   % If we have bytes to remove...

        % Remove the entries that were converted to negative ones.
        byte_array(byte_array == -1) = [];

        % Wait for any additional bytes that might explain this check sum error.
        while serial_port.BytesAvailable < num_bytes_removed, if bDebugPrint, fprintf('Check sum error detected.  Waiting for extra bytes...\n'), end, end

        % Add the previous end byte to the byte array, because this wasn't actually the last byte.
        byte_array = [byte_array; end_byte];

        % Read in the missing bytes.
        missing_bytes = fread(serial_port, num_bytes_removed);

        % Add the missing bytes (less the check sum) to the byte array.
        byte_array = [byte_array; missing_bytes(1:end - 1)];

        % Set the end byte to be the last of the missing bytes.
        end_byte = missing_bytes(end);

        %Recompute the check sum.
        check_sum = 255 + 255 + num_pairs + sum(byte_array);
        
    end
    
end

%Check the check sum again.
if end_byte ~= mod(check_sum, 256)                      %If check sum error is detected...
    
    %Throw a warning for reference.
    warning('Second check sum error detected.')
    %     warning('Possible check sum error detected.')
    
    %Set the ID and value bytes to be empty.
    IDs = []; values = [];
    
else                                                    %Otherwise...
    
    %Retrieve the bytes associated with the IDs.
    IDs = byte_array(1:num_bytes_per_pair:end);
    
    %Remove the ID bytes from the byte array.
    byte_array(1:num_bytes_per_pair:end) = [];
    
    %Convert the remaining bytes into an array of ints.
    values = ByteArray2IntArray( byte_array );
    
end


end

