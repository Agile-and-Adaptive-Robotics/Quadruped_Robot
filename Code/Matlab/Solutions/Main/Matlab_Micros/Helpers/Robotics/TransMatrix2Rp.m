function [ R, p ] = TransMatrix2Rp( T )

%This function extracts the rotational and translational components of a transformation matrix.
%If T is a multidimensional matrix where each layer is a transformation matrix,
%R will also be a multidimensional matrix where each layer is the associated
%rotation matrix and p is a matrix where each column contains the associated
%translational component of the transformation.

%Preallocate the rotation matrix.
R = zeros(3, 3, size(T, 3));

%Preallocate the position vector.
p = zeros(3, size(T, 3));

%Retrieve the Translational % Rotational Components of the Transformation Matrices.
for k = 1:size(T, 3)        %Iterate through each layer of the multidimensional transformation matrix...
    
    %Retrieve the rotational component from the transformation matrix.
    R(:, :, k) = T(1:3, 1:3, k);
    
    %Retrieve the translational component from the transformation matrix.
    p(:, k) = T(1:3, 4, k);
    
end

end
