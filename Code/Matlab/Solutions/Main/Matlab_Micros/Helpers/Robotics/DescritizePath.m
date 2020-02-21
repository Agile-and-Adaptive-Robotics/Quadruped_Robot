function [ T_Descritized ] = DescritizePath( T_WayPoints, dist_max, Type )

%Set the default type.
if nargin < 3, Type = 'Linear'; end

%Preallocate a multidimensional matrix to store all of the orientations.
T_Descritized = [];

%Determine how many points to interpolate between letter template points.
for k = 1:(size(T_WayPoints, 3) - 1)           %Iterate through each pair of orientations...
    
    %Compute the displacement for this step.
    dist = norm( diff( T_WayPoints(1:3, 4, k:(k + 1)), 1, 3 ) );
    
    %Compute the required step size.
    nsteps = ceil(dist/dist_max);
    
    %Determine whether interpolation is necessary.
    if nsteps > 1                                       %If interpolation is necessary...
        
        %Retrieve interpolate the necessary number of intermediate steps to get from the starting orientation to the ending orientation.
        nTs = ParameterizePath( T_WayPoints(:, :, k), T_WayPoints(:, :, k + 1), nsteps, Type );
        
        %Determine whether we need to remove the final new orientation.
        if k ~= (size(T_WayPoints, 3) - 1)     %If this is not the last iteration...
            nTs(:, :, end) = [];               %Remove the final new orientation.
        end
        
    else                                                %If interpolation is unnecessary...
        
        %Determine whether we need to add one new orientation or two new orientations.
        if k ~= (size(T_WayPoints, 3) - 1)                      %If this is not the final iteration...
            nTs = T_WayPoints(:, :, k);                         %Only add the starting orientation.
        else
            nTs = T_WayPoints(:, :, k:k+1);                     %Add both the starting and ending orientations.
        end
    end
    
    %Add the list of new orientations to the existing list of orientations.
    T_Descritized = cat(3, T_Descritized, nTs);
    
end

end

