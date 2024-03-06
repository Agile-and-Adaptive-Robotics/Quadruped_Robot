data = springData.data.S2L4LT4ST37T.T200Nmm.CW.loading.average;
mgr = springData.data.S2L4LT4ST37T.T200Nmm.torque;
t = linspace(0,(length(data)-1)/100,length(data));
I1 = 6.6066;        % [kg*mm^2]     inertia of the pulley from Solidworks
qq = 150;

r = 20.4;           % [mm]          radius of the pulley
m = 1;              % [kg]          mass hung from pulley

dataCropped = deg2rad(data(1:qq,1));
tCropped = t(1,1:qq);

%%
tr = risetime_ek(dataCropped,tCropped);
ts = settime(dataCropped,tCropped); 
zeta = dampingRatio(tr,ts);
omegan = (4.5*zeta)/ts;

b1 = 2*(I1+(m*(r^2)))*zeta*omegan;    % [kg*m^2/s]   damping constant of the spring                
k1 = (I1+(m*(r^2)))*omegan^2;         % [kg*m^2/s^2] spring constant of the spring

s = tf('s');

k2 = mgr/dataCropped(end);
% k2 = mgr/0.1816;
% omegan2 = sqrt(k2/(I1+(m*(r^2))));
omegan2 = sqrt(k2/(I1));
zeta2 = ts*omegan2/4.5;
% zeta2 = 3.2/(ts*omegan);
b2 = 2*(I1+(m*(r^2)))*zeta2*omegan2;

fun1 = mgr/((I1+(m*(r^2)))*s^2 + b1*s + k1);
% fun2 = mgr/((I1+(m*(r^2)))*s^2 + b2*s + k2);
fun2 = mgr/((I1)*s^2 + b2*s + k2);

figure
plot(tCropped,dataCropped)
ylabel('Deflection (rad)')
xlabel('Time (s)')
xlim([0 1.5])

figure
step(fun1)
xlabel('Time (s)')
xlim([0 1.5])

figure
step(fun2)
xlabel('Time (s)')

