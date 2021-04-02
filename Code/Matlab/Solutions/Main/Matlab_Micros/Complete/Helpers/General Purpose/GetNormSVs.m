function [ sigmas ] = GetNormSVs( A )

%Calculate the SVD.
[~, S, ~] = svd(A);

%Retrieve the singular values of A.
sigmas = diag(S);

%Normalize the singular values of A.
sigmas = sigmas/sigmas(1);

end

