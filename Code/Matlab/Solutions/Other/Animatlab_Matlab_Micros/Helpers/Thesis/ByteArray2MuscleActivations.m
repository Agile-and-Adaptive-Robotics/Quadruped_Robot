function [ muscle_values, muscle_IDs ] = ByteArray2MuscleActivations( muscle_bytes )

%Define the number of bytes per data point.
num_bytes_per_data_point = 6;

%Compute the number of bytes.
num_bytes = length(muscle_bytes);

%Compute the number of data points.
num_data_points = num_bytes/num_bytes_per_data_point;

%Preallocate arrays to store the muscle IDs and values.
[muscle_IDs, muscle_values] = deal( zeros(1, num_data_points) );

for k = 1:num_data_points
    %Compute the current critical index.
    loc = 1 + num_bytes_per_data_point*(k - 1);
    
    %Convert the muscle activations byte array to muscle activation arrays.
    muscle_ID_bytes = muscle_bytes(loc:(loc + 1)); muscle_value_bytes = muscle_bytes((loc + 2):(loc + 5));
    
    %Read in the current ID.
    muscle_IDs(k) = typecast(uint8(fliplr(muscle_ID_bytes)), 'uint16');
    
    %Read in the current value.
    muscle_values(k) = typecast(uint8(muscle_value_bytes), 'single');
end


end

