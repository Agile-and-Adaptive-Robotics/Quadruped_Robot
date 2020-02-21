function [ low_byte, high_byte ] = int2low_high_bytes( myint )
%This function converts an integer < 2^16 into its high and low bytes.

%Conver the integer into its high and low bytes.
[low_byte, high_byte] = deal( mod(myint, 256), floor(myint/256) );

end

