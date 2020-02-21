function [ x_bytes ] = int2bytes( x_dec, num_bytes )
%This function takes in an integer and outputs this value as an array of bytes of length num_bytes.

%%Set Default Input Arguments.

%Define the number of bits per byte.
bitsperbyte = 8;

%Compute the minimum number of required bytes to represent this integer.
if nargin < 2, num_bytes = ceil(log2(x_dec)/bitsperbyte); end                     %If the number of bytes is not specified, use the minimum possible number of bytes.
    

%% Convert the Integer Value to a Byte Array.

%Compute the total number of bits.
num_bits = bitsperbyte*num_bytes;

%Convert the integer to its binary expression.
x_bin = dec2bin(x_dec, num_bits);

%Preallocate an array to store the byte array.
x_bytes = zeros(1, num_bytes);

%Compute the bytes associated with each set of 8 bytes from most to least significant.
for k = 1:num_bytes                                                 %Iterate through each byte...
    
    %Compute the location of interest in the bit array.
    loc = bitsperbyte*(k - 1) + 1;
    
    %Compute the byte associated with this section of the bit array.
    x_bytes(k) = bin2dec(x_bin(loc:(loc + bitsperbyte - 1)));
    
end


end

