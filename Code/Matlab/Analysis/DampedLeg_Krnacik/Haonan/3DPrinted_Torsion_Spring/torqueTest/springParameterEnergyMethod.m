%%
m = 0.200;      %   [kg]
g = 9.81;       %   [m/s^2]
r = 0.125;      %   [m]
hmax = 0.760;   %   [m]
h0 = 0.365;     %   [m]

tstep1 = 0.010;
tstep2 = 0.00001;

t1 = 0:tstep1:(length(data)-1)/100;
t2 = 0:tstep2:(length(data)/100-tstep2);

x = spline(t1,data,t2);
xdot = diff(x)/tstep2;
xdotsq = xdot.^2;
[pks, locs] = findpeaks(x);
tend = locs(2);
integral = cumtrapz(t2(1:tend),xdotsq(1:tend));

figure
plot(t1,data)
xlabel('Time (s)')
ylabel('Deflection (rad)')

figure
plot(t2,x)
xlabel('Time (s)')
ylabel('Deflection (rad)')

thetamax = x(tend);

figure
plot(t2(1:tend),x(1:tend))
xlabel('Time (s)')
ylabel('Deflection (rad)')

figure
plot(t2(1:tend),xdot(1:tend))
xlabel('Time (s)')
ylabel('Angluar Veloctiy (rad/s)')

figure
plot(t2(1:tend),xdotsq(1:tend))

figure
plot(t2(1:tend),integral)

k = 0.245/data(200);
%%
PE1 = m*g*hmax;

PE2 = m*g*(h0-thetamax*0.125);

SE = 0.5*k*thetamax^2;

b = (PE1-PE2-SE)/integral(tend)
