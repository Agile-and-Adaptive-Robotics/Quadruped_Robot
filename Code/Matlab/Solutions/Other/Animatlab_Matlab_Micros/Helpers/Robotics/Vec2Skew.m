function [ X ] = Vec2Skew( x )

%Determine how to define the skew matrix.
if length(x) == 3           %If the vector is 3x1...
    
    %Define the skew matrix.
    X = [0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];
    
elseif length(x) == 6       %If the vector is 6x1...
    
    %Define the skew matrix of the angular velocity component.
    W = [0 -x(3) x(2); x(3) 0 -x(1); -x(2) x(1) 0];
    
    %Define the velocity component of the vector.
    v = x(4:6);
    
    %Define the skew matrix.
    X = [W v; 0 0 0 0];
end

end

