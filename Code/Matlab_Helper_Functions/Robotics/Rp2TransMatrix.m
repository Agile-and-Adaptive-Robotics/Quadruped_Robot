function [ T ] = Rp2TransMatrix( R, p )

%This function generates a transformation matrix T from a rotation matrix R and column vector p.
%If p is a matrix where each column is a point, this function generates a multidimensional transformation matrix T where each layer is the transformation matrix associated with its respective column of p.

%Determine whether it is necessary to repeat the given orientation.
if (size(R, 3) == 1) && (size(p, 2) > 1)                    %If only one orienation is provided...
    
    %Preallocate a multidimensional matrix to store the orientations.
    nR = zeros(3, 3, size(p, 2));
    
    %Set each layer of the new matrix to be the old matrix.
    for k = 1:size(p, 2)            %Iterate through all of the positions in p.
        
        %Set this layer to be the original matrix.
        nR(:, :, k) = R;
        
    end
    
    %Replace the original matrix with the new multidimensional matrix.
    R = nR;
    
end

%Preallocate the transformation matrix.
T = zeros(4, 4, size(p, 2));

%Create transformation matrices.
for k = 1:size(p, 2)                %Iterate through all of the points & orienations.
    
    %Create transformation matrices.
    T(:, :, k) = [R(:, :, k), p(:, k); zeros(1, size(R(:, :, k), 2)) 1];
    
end

end
