function [ N ] = vec_norm( A )
%This function computes the 2-norm of each column of the matrix A.

%Preallocate the size of N.
N = zeros(1, size(A, 2));

%Iterate through all of the columns of A.
for k = 1:size(A, 2)
    
    %Compute and store the norm of the column.
    N(k) = norm(A(:, k));
    
end

end
