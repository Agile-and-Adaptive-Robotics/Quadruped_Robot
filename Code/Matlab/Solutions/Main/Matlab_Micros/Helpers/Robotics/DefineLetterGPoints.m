%% ME 557: Project, Define Letter G Points.

%Clear Everything
clear
close all
clc

%% Define the Letter Points.
%Define the points componentwise.
xs = [0.22252 -0.31849 -0.76604 -0.98883 -0.92148 -0.58374 -0.07473 0.45621 0.85329 1 0];
ys = [0.97493 0.94793 0.64279 0.14904 -0.38843 -0.81194 -0.9972 -0.88987 -0.52144 -2.4493e-16 0];
zs = [0 0 0 0 0 0 0 0 0 0 0];

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
dlmwrite('C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints\LetterPts_G.txt', Lpts)

