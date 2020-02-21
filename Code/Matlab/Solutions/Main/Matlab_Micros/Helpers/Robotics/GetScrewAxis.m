function [ S, theta ] = GetScrewAxis( T )

%Retrieve the rotational component of the transformation matrix.
R = T(1:3, 1:3);

%Retrieve the translational component of the transformation matrix.
p = T(1:3, 4);

%Determine which solution method to apply.
if ~sum(sum(R ~= eye(3)))
    
    %Define the rotational component of the screw axis.
    w = zeros(3, 1);
    
    %Define the translational component of the screw axis.
    v = p/norm(p);
    
    %Define the amount of rotation.
    theta = norm(p);
    
else
    
    %Define the rotational component of the screw axis.
    [w, theta] = GetTransAxis(R);
    
    %Define the screw matrix.
    wskew = Vec2Skew(w);
    
    %Compute the Ginv intermediate result.
    Ginv = (1/theta)*eye(3) - (1/2)*wskew + ( (1/theta) - (1/2)*cot(theta/2) )*(wskew^2);
    
    %Define the translational component of the screw axis.
    v = Ginv*p;
    
end

%Define the screw axis.
S = [w; v];

end

