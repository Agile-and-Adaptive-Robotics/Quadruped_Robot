function [ single_array ] = ByteArray2SingleArray( byte_array )

%Preallocate an array to store the integers.
single_array = zeros(1, length(byte_array)/4);

%Initialize the critical index location.
loc = 1;

%Convert each pair of low and high byes to integers.
for k = 1:length(single_array)
    
    %Convert the low and high bytes for this iteration into an integer.
    single_array(k) =  typecast(uint8(byte_array(loc:loc + 3)), 'single');
    
    %Advance the to the next critical index location.
    loc = loc + 4;
    
end

end

