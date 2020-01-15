%% ME 557: Project, Define Letter O Points.

%Clear Everything
clear
close all
clc

%% Define the Letter Points.

%Define the points componentwise.
ts = linspace(0, 2*pi, 10);
xs = cos(ts);
ys = sin(ts);
zs = zeros(1, length(xs));

%Store the points in a matrix.
Lpts = [xs; ys; zs];

%% Plot the Letter Points.

%Plot the Letter Points.
figure, hold on, grid on
plot3(Lpts(1, :), Lpts(2, :), Lpts(3, :), '.-', 'Markersize', 20)
title('Workspace')
xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis')
view(30, 30), rotate3d on,
axis equal

%% Write out the Data Points.

%Write out the letter data points.
dlmwrite('C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints\LetterPts_O.txt', Lpts)

