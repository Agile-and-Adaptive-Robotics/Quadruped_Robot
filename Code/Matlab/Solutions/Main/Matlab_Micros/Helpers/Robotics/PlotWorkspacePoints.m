function PlotWorkspacePoints( ps, WBs, mrksz )

%Plot the origin for reference.
plot3(0, 0, 0, '.r', 'Markersize', mrksz)

%Plot the workspace if necessary.
if ~isempty(ps)
    %Plot the workspace of the point.
    plot3(ps(1, :), ps(2, :), ps(3, :), '.k', 'Markersize', mrksz)
end

%Plot the Whiteboard.
surf(WBs(:, :, 1), WBs(:, :, 2), WBs(:, :, 3), 'Edgecolor', 'none', 'Facecolor', 'k', 'Facealpha', 0.2)

%Format the subplot.
title('Workspace')
xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis')
view(30, 30), rotate3d on,
axis equal, axis([-25 25 -25 25 -25 25])

end

