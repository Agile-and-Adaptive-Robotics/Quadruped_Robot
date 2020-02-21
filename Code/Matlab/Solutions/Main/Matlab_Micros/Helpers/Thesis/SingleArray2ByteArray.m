function [ byte_array ] = SingleArray2ByteArray( single_array )

%Convert the single array to a byte array.
byte_array = typecast(single(single_array), 'uint8');

end

