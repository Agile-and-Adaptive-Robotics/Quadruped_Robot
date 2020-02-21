function [ int ] = low_high_bytes2int( low_byte, high_byte )
%This script converts low and high bytes into an integer value.

%Convert the low and high bytes into an integer value.
int = low_byte + 256*high_byte;

end

