close all
clear
clc
%%
% system parameters
g = 9.81;                  % [m/s^2]   acceleration due to gravity
l = 0.300;                 % [m]       length of pendulum 
r = l/2;                   % [m]       length to center of mass of pendulum
m = 52/1000;               % [kg]      mass of the pendulum
Ip = 1530486.60/1000^3;    % [kg*m^2]  mass moment of inertia of the pulley about the rotational axis

thetaPend = deg2rad(data);
thetaCropped = thetaPend(27:end);
tPend = linspace(0,(length(thetaCropped)-1)/100,length(thetaCropped));

alpha = (m*g*r)/Ip;

% setting up the pendulum ODE
coulomb = 0.7;
f = @(t,x) [x(2); -alpha*sin(x(1)) - coulomb*sign(x(2))];

% initial conditions
theta0 = [deg2rad(data(1)); 0];

% solve the ODE from time interval [0 12] seconds
[t,x] = ode23(f,[0 12],theta0);

% plot the response
figure
hold on
plot(t,x(:,1))
plot(tPend,thetaCropped)
legend('angle')
xlabel('time (s)')
ylabel('angle (rad)')
legend('simulated model','data')
xlim([0 12])
title('Pendulum with no attached mass')
