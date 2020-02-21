function [ nLpts ] = CenterLetter( Lpts )

%Compute the maximum and minimum values of the letter points.
[Lpts_max, Lpts_min] = deal( max(Lpts, [], 2), min(Lpts, [], 2) );

%Compute the width of the letter.
Lpts_width = Lpts_max - Lpts_min;

%Compute the center point of the letter.
Lpts_center = Lpts_min + Lpts_width/2;

%Set the z-adjustment to zero.
Lpts_center(3) = 0;

%Translate the letter so that its center is at the origin.
nLpts = Lpts - Lpts_center;

%% Plot the results for troubleshooting.

% figure, hold on, grid on, axis equal, rotate3d on
% plot3(Lpts(1, :), Lpts(2, :), Lpts(3, :), '.-', 'Markersize', 20)
% plot3(nLpts(1, :), nLpts(2, :), nLpts(3, :), '.-', 'Markersize', 20)

end

