function [ J ] = TransMat2Jacobian( T )
%This script computes the jacobian associated with the 4x4xn T matrix of transformation matrices.

%Preallocate a matrix to store the screw axes.
S = zeros(6, size(T, 3));

%Preallocate a matrix to store the transformation matrix adjoints.
adT = zeros(6, 6, size(T, 3));

%Compute the Adjoints & Screw axes associated with each layer of the T matrix.
for j2 = 1:size(T, 3)           %Iterate through each layer of T...
    
    %Compute the screw axes associated with the transformation matrices.
    S(:, j2) = GetTransAxis(T(:, :, j2));
    
    %Compute the adjoints of the transformation matrices.
    adT(:, :, j2) = adjointT(T(:, :, j2));
    
end

%Preallocate the jacobian matrix.
J = zeros(6, size(T, 3));

%Initialize the first column of the Jacobian.
J(:, 1) = S(:, 1);

%Define the rest of the columns of the Jacobian.
for j3 = 1:(size(T, 3) - 1)         %Iterate through all of the columns, less one (we already defined the first column)...
    
    %Preallocate the coeff of the screw matrix.
    coeff = 1;
    
    %Compute the coefficient for this screw axis.
    for j4 = 1:j3           %Iterate through all of the terms in the product.
        
        %Compute the coefficient for this screw axis.
        coeff = coeff*adT(:, :, j4);
        
    end
    
    %Define the next column of the Jacobian.
    J(:, j3 + 1) = coeff*S(:, j3 + 1);
    
end

disp(S)

end

