function [ x_dec ] = bytes2int( x_bytes )
%This function converts a byte array into an integer.

%Define the number of bits per byte.
numbitsperbyte = 8;

%Compute the number of bytes in the byte array.
num_bytes = length(x_bytes);

%Convert each byte into a bit pattern.
x_bins = dec2bin(x_bytes);

%Preallocate a char array to store the complete bit pattern.
x_bin = char(zeros(1, numbitsperbyte*num_bytes));

%Organize the individual bit patterns into a single bit pattern for the complete number.
for k = 1:num_bytes                             %Iterate through each byte...
    
    %Compute the location to store the current bit pattern.
    loc = 8*(k - 1) + 1;
    
    %Store the current bit pattern into the composite bit pattern.
    x_bin(loc:(loc + 7)) = x_bins(k, :);
    
end

%Convert the composite bit pattern into an integer.
x_dec = bin2dec(x_bin);


end

