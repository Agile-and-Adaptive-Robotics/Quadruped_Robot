function AnimateTrajectoryFunc( S, M, T_Plane, Pts_Plane, rs, thetas )

%Given screw axes, home positions, link lengths, and joint angles this script computes the link point
%trajectories and animates them.

%% Compute Joint Paths to Animate.

%Compute the trajectory of each link point based on the link lengths and
%motor angles.
ps = MotorAngles2Trajectory( S, M, thetas );

%% Animate the Trajectories.

%Define a vector to store whether the link lengths are changing.
bLengthCheck = -1*ones(1, size(ps, 2));

%Create and format a plot for the trajectories.
fig = figure; hold on, grid on
title('Workspace'), xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis')
view(30, 30), rotate3d on, axis equal, axis([-15 15 -5 20 -5 20])

%Plot the plane.
patch(Pts_Plane(1, :), Pts_Plane(2, :), Pts_Plane(3, :), 'k', 'Facealpha', 0.25, 'Edgecolor', 'none')

%Plot the orientation of the plane.
PlotOrientation(T_Plane, fig)

%Plot the plane points.
plot3([Pts_Plane(1, :), Pts_Plane(1, 1)], [Pts_Plane(2, :), Pts_Plane(2, 1)], [Pts_Plane(3, :), Pts_Plane(3, 1)], '.-', 'Markersize', 20)

%Iterate through all of the link point positions.
for k = 1:size(ps, 2)
    
    %Create arrays of the joint positions.   
    [xs, ys, zs] = deal( [0 0 reshape(ps(1, k, :), [1 size(ps, 3)])], [0 0 reshape(ps(2, k, :), [1 size(ps, 3)])], [0 rs(1) reshape(ps(3, k, :), [1 size(ps, 3)])] );
    
    %Retrieve the path followed by the end effector so far.
    [xs_path, ys_path, zs_path] = deal( ps(1, 1:k, end), ps(2, 1:k, end), ps(3, 1:k, end) );
    
    %Store the structure into a matrix of points.
    P = [xs; ys; zs];
    
    %Compute the vectors between the links.
    dP = diff(P, 1, 2);
    
    %Compute the length of each link.
    dPmag = vecnorm(dP);
    
    %Check whether the lengths are constant.
    bLengthCheck(k) = sum(round(dPmag, 8) == rs) == length(rs);
    
    %Animate the link positions.
    if k == 1                       %If this is the first iteration...
        %Plot the path of the end effector.
        h5 = plot3(xs_path, ys_path, zs_path, '-', 'Markersize', 20, 'XDataSource', 'xs_path', 'YDataSource', 'ys_path', 'ZDataSource', 'zs_path');
        
        %Plot the entire structure.
        h = plot3(xs, ys, zs, '.-', 'Markersize', 20, 'XDataSource', 'xs', 'YDataSource', 'ys', 'ZDataSource', 'zs');
    else
        %Refresh the figure.
        refreshdata([h h5], 'caller'), drawnow
    end
    
end

%Add the paths of all link points to the plot for reference after the
%animation is complete.
for k = 1:size(ps, 3)               %Iterate through each of the joints...
    %Plot this joints path.
    plot3(ps(1, :, k), ps(2, :, k), ps(3, :, k), '.-', 'Markersize', 10)
end

%Update the plot with the joint paths.
drawnow

%Throw a warning if the link lengths do not remain constant.
if ~isempty(bLengthCheck( bLengthCheck == 0 ))
    %Warn that the link lengths appear to be changing.
    warning('Link lengths appear to change in at least one animation frame.')
end

end

