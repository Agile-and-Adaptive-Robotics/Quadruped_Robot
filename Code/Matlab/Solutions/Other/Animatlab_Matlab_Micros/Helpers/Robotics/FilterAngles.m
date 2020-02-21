function [ nthetas ] = FilterAngles( thetas, tols )

%Initialize a counter.
k = 1;
c = 0;

%Iterate through all of the angle values.
while k < size(thetas, 2) - 1
    
    %Compute the difference between the current angle and the next angle.
    dtheta = thetas(:, k) - thetas(:, k + 1);
    
    %Determine whether to throw out the next angle.
    if (abs(dtheta(1)) > tols(1)) || (abs(dtheta(2)) > tols(2)) || (abs(dtheta(3)) > tols(3))  %If the angle difference is outside of the tolerance bounds...
        %Remove this angle.
        thetas(:, k + 1) = [];      
    else
        %Advance the counter.
        k = k + 1;
    end
    
    %Advance the counter.
    c = c + 1;
end

%Remove the final point (for some reason the final point is distant from the others).
% nthetas = thetas(:, 1:end-1);
nthetas = thetas;

end

