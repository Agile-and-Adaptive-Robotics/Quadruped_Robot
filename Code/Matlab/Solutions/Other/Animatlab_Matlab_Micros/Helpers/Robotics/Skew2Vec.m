function [ x ] = Skew2Vec( X )

%This script computes the vector associated with a skew matrix.

%Commpute the vector associated with the given skew matrix.
if size(X, 2) == 3         %If the matrix is rank three...
    
    %Compute the vector associated with the given skew matrix.
    x = [X(3,2); X(1,3); X(2,1)];
    
elseif size(X, 2) == 4     %If the matrix is rank four...
    
    %Extract the rotation component of the matrix.
    W = X(1:3, 1:3);
    
    %Extract the linear component of the matrix.
    v = X(1:3, 4);
    
    %Compute the vector associated with the given skew matrix.
    w = [W(3,2); W(1,3); W(2,1)];
    
    %Define the twist.
    x = [w; v];
    
end

end

