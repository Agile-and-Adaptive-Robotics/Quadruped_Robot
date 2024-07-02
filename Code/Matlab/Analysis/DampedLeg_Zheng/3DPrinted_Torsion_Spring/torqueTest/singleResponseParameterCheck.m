data = springData.data.S2L4LT4ST37T.T200Nmm.CW.loading.average;
mgr = springData.data.S2L4LT4ST37T.T200Nmm.torque/1000;
t = linspace(0,(length(data)-1)/100,length(data));
I1 = 6.6066/1000^2;                 % [kg*m^2]      inertia of the pulley from Solidworks
qq = 175;        
tt = 151;

r = 20.4/1000;                      % [m]           radius of the pulley
m = 1;                              % [kg]          mass hung from pulley

dataCropped = deg2rad(data(25:qq,1));
dataLessCropped = deg2rad(data(1:tt,1));
tCropped = t(1,25:qq);
tCropped = tCropped - tCropped(1);
tLessCropped = t(1,1:tt);

ramp = linspace(0,1,30);
const = ones(1,length(dataLessCropped) - length(ramp));
input = cat(2,ramp,const);

%%
k = mgr/dataLessCropped(end);
ts = settime5(dataLessCropped,tLessCropped);
omegan = sqrt(k/(I1+(m*(r^2))));
zeta = zetaHOD(ts,omegan);
b = 2*(I1+(m*(r^2)))*zeta*omegan;

s = tf('s');

fun = mgr/((I1+(m*(r^2)))*s^2 + b*s + k);

xfun = lsim(fun,input,tLessCropped);

figure
hold on
plot(tLessCropped,dataLessCropped)
plot(tLessCropped,xfun)
ylabel('Deflection (rad)')
xlabel('Time (s)')
title('2L4LT4ST37T 200Nmm Torque CW Loading Average Step Response')
xlim([0 1.5])

%%
k = mgr/dataCropped(end);
ts = settime5(dataCropped,tCropped);
omegan = sqrt(k/(I1+(m*(r^2))));
zeta = zetaHOD(ts,omegan);
b = 2*(I1+(m*(r^2)))*zeta*omegan;

s = tf('s');

fun = mgr/((I1+(m*(r^2)))*s^2 + b*s + k);

xfun = lsim(fun,input,tCropped);

figure
hold on
plot(tLessCropped,dataCropped)
plot(tCropped,xfun)
ylabel('Deflection (rad)')
xlabel('Time (s)')
title('2L4LT4ST37T 200Nmm Torque CW Loading Average Step Response')
xlim([0 1.5])