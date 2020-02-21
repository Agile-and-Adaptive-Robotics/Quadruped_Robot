function [ Ak ] = GetRankKApprox( A, k )

%Compute the singular value decomposition of A.
[U, S, V] = svd(A);

%Retrieve the singular values of A.
sigmas = diag(S);

%Preallocate a matrix B.
B = zeros( size(U, 1), size(V, 1), k );

%Create an array of the column products up to the kth column.
for j = 1:k
    B(:, :, j) = sigmas(j)*U(:,j)*(V(:,j)');
end

%Get the best rank k approximation of A.
Ak = sum(B, 3);

end

