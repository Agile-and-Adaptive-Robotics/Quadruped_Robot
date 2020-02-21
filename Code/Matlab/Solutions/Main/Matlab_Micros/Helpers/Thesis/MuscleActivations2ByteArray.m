function [ muscle_bytes ] = MuscleActivations2ByteArray( muscle_values, muscle_IDs )

%Define the number of bytes per muscle that are used when sending animatlab values to the microcontroller.
num_bytes_per_muscle = 6;

%Retrieve the number of muscle command values we have on this iteration.
num_muscle_values = length(muscle_values);

%Preallocate an array to store the muscle bytes.
muscle_bytes = zeros(1, num_bytes_per_muscle*num_muscle_values);

%Convert the animatlab muscle values and IDs into an integer array to send to the microcontroller.
for k = 1:num_muscle_values                                        %Iterate through each of the muscles...
    
    %Convert the muscle ID to bytes.
    muscle_ID_bytes = int2bytes(muscle_IDs(k), 2);
    
    %Convert the muscle value to bytes.
    muscle_value_bytes = typecast(single(muscle_values(k)), 'uint8');
    
    %Store the muscle ID and value bytes into an array.
    muscle_bytes(1 + num_bytes_per_muscle*(k - 1):num_bytes_per_muscle*k) = [muscle_ID_bytes muscle_value_bytes];
    
end

end

