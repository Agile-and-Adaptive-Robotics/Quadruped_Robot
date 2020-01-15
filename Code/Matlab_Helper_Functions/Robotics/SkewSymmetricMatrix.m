function [ Ws ] = SkewSymmetricMatrix( ws )

%Define the skew-symmetric matrix.
Ws = [0 -ws(3) ws(2); ws(3) 0 -ws(1); -ws(2) ws(1) 0];

end
