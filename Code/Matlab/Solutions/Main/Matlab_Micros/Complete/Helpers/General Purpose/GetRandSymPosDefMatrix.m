function [ sym_matrix ] = GetRandSymPosDefMatrix( dim, max_value, num_matrices )
%This function generates a random symmetric matrix of dimension dim with entries in [0, 1].

%Set the default input arguments.
if nargin < 3, num_matrices = 1; end
if nargin < 2, max_value = 1; end

%Preallocate a matrix to store the symmetric matrices.
sym_matrix = zeros(dim, dim, num_matrices);

for k = 1:num_matrices

    %Generate a random matrix of the correct dimension.
    A = rand(dim);
    
    %Assemble these components into a symmetric matrix.
    sym_matrix(:, :, k) = A*A'; 
end

%Convert the random symmetric matrices to have values in the specified range.
sym_matrix = max_value*sym_matrix;

end

