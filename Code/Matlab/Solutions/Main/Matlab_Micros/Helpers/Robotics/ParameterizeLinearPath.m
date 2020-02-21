function [ Ps ] = ParameterizeLinearPath( P_start, P_end, n )

%This function takes in the starting and ending points of a line, as well as the number of desired steps, and produces the linear path connecting these two points.

%Compute the vector from the starting point to the ending point.
dP = P_end - P_start;

%Define a parameter along the line.
ts = linspace(0, 1, n);

%Preallocate a variable to store the parameterized values.
Ps = zeros(3, length(ts));

%Compute the parameterize line points.
for k = 1:length(ts)                    %Iterate through all of the parameter values.
    %Compute the point along the parameterized line.
    Ps(:, k) = ts(k)*dP + P_start;
end

end
