function [ values, IDs ] = ReadSentenceFromAnimatlab( serial_port, bverbose )

%Define default input arguments.
if nargin < 2, bverbose = false; end

%Define the window size for the start sequence.
window_size  = 2;

%Define the number of bytes per data point.
num_bytes_per_data_point = 6;

%Initialize the datatype to an invalid type.
data_type = -1;

%Scan the buffer until we find the appropriate start sequence and data type.
while data_type ~= 1                                                    %While the data type is invalid...
    %Wait for the start sequence.
    WaitForStartSequence( serial_port, window_size, bverbose )
    
    %Read in the data type from animatlab.
    data_type = fread(serial_port, 1);
    
    %State that an invalid data type was detected if this was the case and the user has requested that we print debug information.
    if bverbose && (data_type ~= 1)
       fprintf('Invalid data type detected.\n')
    end
    
end

%Initialize the checksum.
check_sum = 2*255 + data_type;              %Check sum starts by accounting for the start sequence and data type.

%Read in the number of bytes in the sentence.
num_bytes_bytes = fread(serial_port, 2); num_bytes = typecast(uint8(num_bytes_bytes), 'uint16');

%Increase the check sum.
check_sum = check_sum + sum(num_bytes_bytes);

%Compute the number of data points in this message.
num_data_points = num_bytes/num_bytes_per_data_point - 1;                      %[#] Number of Data Points in this Sentence.  There are 6 bytes per data point, however, there are also 6 bytes of non-data point information.

%Preallocate arrays to store the IDs and associated values
[IDs, values] = deal( zeros(1, num_data_points) );

%Read in each of the data points.
for k = 1:num_data_points                                                                               %Iterate through each of the data points...
    
    %Read in the current ID.
    ID_bytes = fread(serial_port, 2); IDs(k) = typecast(uint8(ID_bytes), 'uint16');
    
    %Read in the current value.
    value_bytes = fread(serial_port, 4); values(k) = typecast(uint8(value_bytes), 'single');
    
    %Advance the check sum.
    check_sum = check_sum + sum(ID_bytes) + sum(value_bytes);
    
end

%Read in the check sum target.
check_sum_target = fread(serial_port, 1);

%Determine whether the checksum is valid.
if check_sum_target ~= mod(check_sum, 256)
   warning('Possible check sum error detected.') 
end

end



