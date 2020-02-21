%% ME 557: Project, Define Letter Q Points.

%Clear Everything
clear
close all
clc

%% Define the Letter Points.

%Define the first stroke.
ts = linspace(0, 2*pi, 10);
xs1 = cos(ts);
ys1 = sin(ts);
zs1 = zeros(1, length(xs1));

%Define the second stroke.
xs2 = [xs1(end) xs1(end) 0.5 0.5 0.5 1];
ys2 = [ys1(end) ys1(end) -0.5 -0.5 -0.5 -1];
zs2 = [0.5 1 1 0.5 0 0];

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
dlmwrite('C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints\LetterPts_Q.txt', Lpts)

