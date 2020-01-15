function [ sym_matrix ] = GetRandSymMatrix( dim, max_value, num_matrices )
%This function generates a random symmetric matrix of dimension dim with entries in [0, 1].

%Set the default input arguments.
if nargin < 3, num_matrices = 1; end
if nargin < 2, max_value = 1; end

%Preallocate a matrix to store the symmetric matrices.
sym_matrix = zeros(dim, dim, num_matrices);

for k = 1:num_matrices
    %Define the diagonal entries.
    diag_entries = rand(1, dim);
    
    %Define the upper entries.
    upper_entries = triu(rand(dim), 1);
    
    %Assemble these components into a symmetric matrix.
    sym_matrix(:, :, k) = diag(diag_entries) + upper_entries + upper_entries'; 
end

%Convert the random symmetric matrices to have values in the specified range.
sym_matrix = interp1([0 1], [0 max_value], sym_matrix);

end

