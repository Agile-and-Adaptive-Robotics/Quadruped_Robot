function [ ys ] = RollOverArray( x_domain, xs )

% %Compute the rolled over value.
% y = mod(x, x_domain(2)) + x_domain(1);

%Compute the number of values to roll over.
num_points = length(xs);

%Preallocate an array to store the rolled over values.
ys = zeros(1, num_points);

%Roll over each of the values.
for k = 1:num_points                                        %Iterate through each of the values...
    
    %Roll over the value.
    ys(k) = RollOverValue( x_domain, xs(k) );
    
end


end

