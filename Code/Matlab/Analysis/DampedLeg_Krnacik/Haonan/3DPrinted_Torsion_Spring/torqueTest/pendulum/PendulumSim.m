close all
clear
clc

% system parameters
g = 9.81;                  % [m/s^2]   acceleration due to gravity
l = 0.302;                 % [m]       length of pendulum 
r = l/2;                   % [m]       length to center of mass of pendulum
m = 52/1000;               % [kg]      mass of the pendulum
Ip = 1530486.60/1000^3;    % [kg*m^2]  mass moment of inertia of the pulley about the rotational axis

alpha = (m*g*r)/Ip;

% setting up the pendulum ODE
coulomb = 0.4;
f = @(t,x) [x(2); -alpha*sin(x(1)) - coulomb*sign(x(2))];

% initial conditions
theta0 = [pi/6; 0];

% solve the ODE from time interval [0 10] seconds
[t,x] = ode23(f,[0 10],theta0);

% plot the response
figure
plot(t,x(:,1))
legend('angle')
xlabel('time (s)')
ylabel('angle (rad)')
