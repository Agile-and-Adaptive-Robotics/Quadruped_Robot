%% ME 557: Project, Define Letter P Points.

%Clear Everything
clear
close all
clc

%% Define the Letter Points.

%Define the first stroke.
xs1 = [0 0 0 0 0 0 0];
ys1 = [1 -1 -1 -1 1 1 1];
zs1 = [0 0 0.5 1 1 0.5 0];

%Define the second stroke.
ts = linspace(pi/2, 3*pi/2, 10);
xs2 = -0.5*cos(ts);
ys2 = 0.5*sin(ts) + 0.5;
zs2 = zeros(1, length(xs2));

%Combine the strokes.
xs = [xs1 xs2];
ys = [ys1 ys2];
zs = [zs1 zs2];

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
dlmwrite('C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints\LetterPts_P.txt', Lpts)

