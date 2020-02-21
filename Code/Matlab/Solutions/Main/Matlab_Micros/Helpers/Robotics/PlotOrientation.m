function PlotOrientation( R, fig, bLegend )

%This function plots an orientation defined by the transformation matrix R.

%Set the default values.
if nargin < 3, bLegend = false; end
if nargin < 2, fig = []; end

%Determine whether to create a new figure for the orientation plot.
if isempty(fig)
    %Create a figure to store the orientations.
    figure, hold on, grid on
    title('Plot of Orientations in Space Frame')
    xlabel('x-axis (Space)'), ylabel('y-axis (Space)'), zlabel('z-axis (Space)')
    view(30, 30), rotate3d on, axis equal
else
    figure(fig)
end

%Plot the orientation defined by each layer of R.
for k = 1:size(R, 3)                    %Iterate through each layer...
    
    %Determine whether the transformation matrix is rank 3 or 4.
    if size(R, 2) == 3          %If R is a rotation matrix...
        
        %Plot the orientation at the origin.
        quiver3(0, 0, 0, R(1, 1, k), R(2, 1, k), R(3, 1, k))                                %Plot the x-vector.
        quiver3(0, 0, 0, R(1, 2, k), R(2, 2, k), R(3, 2, k))                                %Plot the y-vector.
        quiver3(0, 0, 0, R(1, 3, k), R(2, 3, k), R(3, 3, k))                                %Plot the z-vector.
        
    elseif size(R, 2) == 4      %If R is a transformation matrix...
        
        %Plot the orientation at the given location.
        quiver3(R(1, 4, k), R(2, 4, k), R(3, 4, k), R(1, 1, k), R(2, 1, k), R(3, 1, k))     %Plot the x-vector.
        quiver3(R(1, 4, k), R(2, 4, k), R(3, 4, k), R(1, 2, k), R(2, 2, k), R(3, 2, k))     %Plot the y-vector.
        quiver3(R(1, 4, k), R(2, 4, k), R(3, 4, k), R(1, 3, k), R(2, 3, k), R(3, 3, k))     %Plot the z-vector.
        
    end
    
end

%Determine whether to add a legend to the plot.
if bLegend                          %If a legend is requested...
    %Add a legend to the plot
    legend('x-axis (Body)', 'y-axis (Body)', 'z-axis (Body)')
end

end

