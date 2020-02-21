function [ w, theta ] = GetTransAxis( R )

%This function computes the angle and axis of rotation given a transformation matrix.

%Determine whether the rotation matrix is valid.
if trace(R) == 0
   fprintf('Warning: trace(R) = 0.\n') 
end

%Compute the exponential coordinates screw matrix associated with the given transformation matrix.
wtheta_skew = logm(R);

%Compute the exponential coordinates given the screw matrix.
wtheta = Skew2Vec(wtheta_skew);

%Determine how to resolve the exponential coordinate representation into a vector representation.
if size(wtheta, 1) == 3                 %If the vector is 3x1...
    
    %Resolve the exponential coordinates into its magnitude and direction.
    theta = norm(wtheta);
    w = wtheta/theta;
    
elseif size(wtheta, 1) == 6             %If the vector is 6x1...
    
    %Compute the magnitude of the rotational terms.
    wmag = norm(wtheta(1:3));
    
    %Determine how to normalize the twist.
    if wmag == 0                        %If there is no rotational component...
       
        %Normaliize with respect to the linear component.
        theta = norm(wtheta(4:6));
        w = wtheta/theta;
        
    else
        
        %Normalize with respect to the rotational component.
        theta = wmag;
        w = wtheta/wmag;
        
    end
    
end

end
