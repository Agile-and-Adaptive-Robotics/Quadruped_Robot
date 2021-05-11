%% Dynamic Leg Simulation

% This Script creates simulation of Dynamic Leg

% Clear Everything.
clear, close('all'), clc

%% Define Mechanical Properties and create Stucture P to store values

% Define the mechanical properties of link 1.
P.m1 = .716;  %[lb] Mass of femur with encoder                   
P.R1 = 4.75; % [in]
P.I1 = 496.26; %[in^4]
P.L1 = 9.25; %[in]

% Define the mechanical properties of link 2.
P.m2 = .4299; %[lb]
P.R2 = 4.75; %[in]
P.I2 = 496.26; %[in^4]
P.L2 = 9.25; %[in
% Define the mechanical properties of link 3.

P.m3 = 0.00992; %[lb]
P.R3 = 3.5; %[in]
P.I3 = 122.09; %[in^4]
P.L3 = 7.875;
P.g = -9.81;

%% Graphzzzzz

tspan = linspace(0,150,1500);
y0 = [1;0;0;0;0;0];
opts = odeset('Mass',@(t,q) mass(t,q,P));

[t,q] = ode45(@(t,q) f(t,q,P),tspan,y0,opts);

figure
title({'Never Works on the (Stopped counting) Try         ', 'y0 = [1;0;0;0;0;0]         '})
axis([-30 30 -30 30])
xlabel('In');
ylabel('In')
hold on
for j = 1:length(t)
theta1 = q(j,1);
theta2 = q(j,3);
theta3 = q(j,5);

xval = [P.R1*sin(theta1) (P.L1*sin(theta1)+P.R2*sin(theta1+theta2)) (P.L1*sin(theta1)+P.L2*sin(theta1+theta2)+P.R3*sin(theta1+theta2+theta3))];
yval = [-P.R1*cos(theta1) (-P.L1*cos(theta1)-P.R2*cos(theta1+theta2)) (-P.L1*cos(theta1)-P.L2*cos(theta1+theta2)-P.R3*cos(theta1+theta2+theta3))];
jointx = [0 P.L1*sin(theta1) (P.L1*sin(theta1) +P.L2*sin(theta1+theta2)) (P.L1*sin(theta1)+P.L2*sin(theta1+theta2)+P.L3*sin(theta1+theta2+theta3))];
jointy = [0 -P.L1*cos(theta1) -(P.L1*cos(theta1) +P.L2*cos(theta1+theta2)) (-P.L1*cos(theta1)-P.L2*cos(theta1+theta2)-P.R3*cos(theta1+theta2+theta3))];
plot(jointx,jointy,xval(1),yval(1),'ro',xval(2),yval(2),'go',xval(3),yval(3),'bo');
drawnow
end

legend('Links', 'Com1', 'CoM2','Com3');
