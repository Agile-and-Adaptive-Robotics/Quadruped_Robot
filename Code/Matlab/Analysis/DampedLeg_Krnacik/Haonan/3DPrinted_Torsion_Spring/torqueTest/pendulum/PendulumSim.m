close all
clear
clc
%%
% extract damping and spring constants from data

thetaPend = deg2rad(data);
thetaCropped = thetaPend(27:1187);
tPend = linspace(0,(length(thetaCropped)-1)/100,length(thetaCropped));
tSpline = linspace(0,(length(thetaCropped)-1)/100,length(thetaCropped)*100);
thetaSpline = spline(tPend,thetaCropped,tSpline);

[pks,locs] = findpeaks(thetaSpline);
deltas = zeros(1,length(pks)-1);
zetas = zeros(1,length(pks)-1);
omegads = zeros(1,length(locs)-1);
omegans = zeros(1,length(locs)-1);


for ii = 1:length(deltas)
    deltas(ii) = log(pks(ii)/pks(ii+1));
    zetas(ii) = deltas(ii)/sqrt((4*pi^2) + deltas(ii)^2);
    omegads(ii) = (2*pi)/(tSpline(locs(ii+1)) - tSpline(locs(ii)));
    omegans(ii) = omegads(ii)/sqrt(1 - zetas(ii)^2);
end

%%
% physical system parameters
g = 9.81;                  % [m/s^2]   acceleration due to gravity
l = 0.300;                 % [m]       length of pendulum 
r = l/2;                   % [m]       length to center of mass of pendulum
m = 52/1000;               % [kg]      mass of the pendulum
Ip = 1530486.60/1000^3;    % [kg*m^2]  mass moment of inertia of the pulley about the rotational axis

alpha = (m*g*r)/Ip;

% initial conditions
theta0 = [deg2rad(data(1)); 0];

%%
% setting up the pendulum ODE
coulomb = 0.7;
f = @(t1,x1) [x1(2); -alpha*sin(x1(1)) - coulomb*sign(x1(2))];     % physical system representation

% solve the ODEs from time interval [0 12] seconds
[t,x] = ode23(f,[0 12],theta0);

%%
% set up pendulum ODEs for all zeta and omegan values and plot

names = cell(1,length(omegans)+1);

figure
hold on
for jj = 1:length(omegans)
    names{jj} = strcat('zeta:',num2str(zetas(jj)),' omegan:',num2str(omegans(jj)));
    f = @(t,x) [x(2); -alpha*sin(x(1)) - 2*zetas(jj)*omegans(jj)*x(2) - omegans(jj)^2*x(1)];
    [t,x] = ode23(f,[0 12],theta0);
    plot(t,x(:,1))
end
names{end} = 'splined data';

plot(tSpline,thetaSpline)
legend(names)



% plot the response
% figure
% hold on
% plot(t,x(:,1))
% plot(tPend,thetaCropped)
% plot(tSpline,thetaSpline)
% legend('angle')
% xlabel('time (s)')
% ylabel('angle (rad)')
% legend('simulated model','data','splined data')
% xlim([0 12])
% title('Pendulum with no attached mass')
