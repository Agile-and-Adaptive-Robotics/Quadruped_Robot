function H = GetHankleMatrix( response_data )
%This script takes SISO system response data (impulse, step, etc.) and generates the associated hankle matrix.

%Retrieve the number of data points.
num_data_points = length(response_data);

%Preallocate the input matrix.
H = zeros(num_data_points);

%Create the input matrix.
for k = 1:num_data_points    
    H(k, k:num_data_points) = response_data(1:(num_data_points - k + 1));
end

end

