function AnimatePartTrajectory( S, M, L, thetas, bNewFig, bPlotPaths )

%Given screw axes, home positions, link lengths, and joint angles this script computes the link point
%trajectories and animates them.

%% Set the Defaul Argument Values.

%Set the default options.
if nargin < 6, bPlotPaths = false; end
if nargin < 5, bNewFig = false; end

%% Compute Joint Paths to Animate.

%Compute the trajectory of each link point based on the link lengths and
%motor angles.
ps = JointAngles2PartTrajectory( S, M, L, thetas );

%% Animate the Trajectories.

%Determine how many joints there are on this leg.
num_joints = find(diff(L) < 0, 1);

%Determine whether to create a new figure.
if bNewFig
    %Create and format a plot for the trajectories.
    figure, hold on, grid on, title('Workspace'), xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis'), rotate3d on, axis equal, axis([-40 40 -40 40 -40 40])
end

%Iterate through all of the link point positions.
for k = 1:size(ps, 2)
    
    %Create arrays of the point paths.
    [xs, ys, zs] = deal( reshape(ps(1, k, :), [1 size(ps, 3)]), reshape(ps(2, k, :), [1 size(ps, 3)]), reshape(ps(3, k, :), [1 size(ps, 3)]) );
    
    %Store the joint paths into their own variables.
    xs_joint = xs(1:num_joints); ys_joint = ys(1:num_joints); zs_joint = zs(1:num_joints);
    
    %Store the attachment point paths into their own variables.
    xs_attachment = xs((num_joints + 1):end); ys_attachment = ys((num_joints + 1):end); zs_attachment = zs((num_joints + 1):end);
    
    %Retrieve the path followed by the end effector so far.
    [xs_path, ys_path, zs_path] = deal( ps(1, 1:k, num_joints), ps(2, 1:k, num_joints), ps(3, 1:k, num_joints) );
    
    %Animate the link positions.
    if k == 1                       %If this is the first iteration...
        
        %Choose a random color.
        rgb = rand(1, 3);
        
        %Plot the current joint locations.
        h_Structure = plot3(xs_joint, ys_joint, zs_joint, '.-', 'Color', rgb, 'Markersize', 20, 'XDataSource', 'xs_joint', 'YDataSource', 'ys_joint', 'ZDataSource', 'zs_joint');
        
        %Plot the current attachment points locations.
        h_Attachments = plot3(xs_attachment, ys_attachment, zs_attachment, '.', 'Color', rgb, 'Markersize', 20, 'XDataSource', 'xs_attachment', 'YDataSource', 'ys_attachment', 'ZDataSource', 'zs_attachment');
        
        %Plot the path of the end effector.
        h_Foot = plot3(xs_path, ys_path, zs_path, '-', 'Markersize', 20, 'XDataSource', 'xs_path', 'YDataSource', 'ys_path', 'ZDataSource', 'zs_path');
    else
        %Refresh the figure.
        refreshdata([h_Structure h_Attachments h_Foot], 'caller'), drawnow
    end
    
end

%Determine whether to plot the joint paths.
if bPlotPaths                                   %If requested to plot the joint paths...
    
    %Add the paths of all link points to the plot for reference after the animation is complete.
    for k = 1:size(ps, 3)               %Iterate through each of the joints...
        %Plot this joints path.
        plot3(ps(1, :, k), ps(2, :, k), ps(3, :, k), '.-', 'Markersize', 10)
    end
    
    %Update the plot with the joint paths.
    drawnow
end



end

