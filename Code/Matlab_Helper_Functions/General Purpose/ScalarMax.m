function [ nx ] = ScalarMax( x, n )
%This function compares each entry in the matrix x to the scalar n.  It creates a new matrix nx whose ij'th entry is the maximum of the ij'th entry in x and the scalar n.

%Throw an error if n is not a scalar.
if sum(size(n) == 1) ~= length(size(n))
    error('n must be a scalar.')
end

%Preallocate a matrix to store the new matrix entries.
nx = zeros(size(x, 1), size(x, 2));

%Compare each entry in x to the scalar n, and select the maximum for the entry in the new matrix.
for k1 = 1:size(x, 1)                           %Iterate through all of the rows...
    for k2 = 1:size(x, 2)                       %Iterate through all of the columns...
        
        %Compute the maximum of this entry of the matrix x and the scalar n.
        nx(k1, k2) = max( [x(k1, k2), n] );
        
    end
end


end

