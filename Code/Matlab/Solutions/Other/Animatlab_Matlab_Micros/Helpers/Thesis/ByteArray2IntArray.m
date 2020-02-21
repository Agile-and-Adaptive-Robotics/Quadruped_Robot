function [ int_array ] = ByteArray2IntArray( byte_array )

%Preallocate an array to store the integers.
int_array = zeros(1, length(byte_array)/2);

%Initialize the critical index location.
loc = 1;

%Convert each pair of low and high byes to integers.
for k = 1:length(int_array)
    
    %Convert the low and high bytes for this iteration into an integer.
    int_array(k) =  typecast(uint8(byte_array(loc:loc + 1)), 'uint16');
%         int_array(k) =  typecast(uint8(byte_array(loc + 1:-1:loc)), 'uint16');

    %Advance to the next critical index location.
    loc = loc + 2;
    
end

end

