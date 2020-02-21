%% ME 557: Project, Define Letter I Points.

%Clear Everything
clear
close all
clc

%% Define the Letter Points.
%Define the points componentwise.
% xs = [-1 1 1 0 0 0 0 -1 -1 1];
% ys = [1 1 1 1 1 -1 -1 -1 -1 -1];
% zs = [0 0 1 1 0 0 1 1 0 0];

xs = [-1 1 1 1 0 0 0 0 0 0 -1 -1 -1 1];
ys = [1 1 1 1 1 1 1 -1 -1 -1 -1 -1 -1 -1];
zs = [0 0 0.5 1 1 0.5 0 0 0.5 1 1 0.5 0 0];

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
dlmwrite('C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints\LetterPts_I.txt', Lpts)

