close all
figure
plot(data)

%%
data = deg2rad(data(34:133));       
data0 = data - data(1);

%%
%index  [  1     2     3     4     5  ]
%torque [0.010 0.020 0.040 0.100 0.200]       % [Nm] small pulley
%torque [      0.123 0.245 0.613      ]       % [Nm] big pulley
mList = [0.050 0.100 0.200 0.500 1.000];      % [kg]
hList = [0.040 0.035 0.044 0.063 0.072];      % [m]

index = 5;

m = mList(index);       %   [kg]
hmass = hList(index);   %   [m]

g = 9.81;       %   [m/s^2]
r = 0.02039;      %   [m]                   small pulley  
% r = 0.125;      %   [m]                       big pulley
hmax = 0.7675;   %   [m]
h0 = 0.5725 + 2*pi*r  ;     %   [m]          small pulley
% h0 = 0.625;     %   [m]                       big pulley
tstep1 = 0.010;
tstep2 = 0.00001;

t1 = 0:tstep1:(length(data)-1)/100;
t2 = 0:tstep2:(length(data)/100-tstep2);

x = spline(t1,data,t2);
xdot = diff(x)/tstep2;
xdotsq = xdot.^2;
[pks, locs] = findpeaks(x);
tpeak = locs(1);
integral = cumtrapz(t2(1:tpeak),xdotsq(1:tpeak));

x0 = spline(t1,data0,t2);
xdot0 = diff(x0)/tstep2;
xdotsq0 = xdot0.^2;
[pks0, locs0] = findpeaks(x0);
tpeak0 = locs0(1);
integral0 = cumtrapz(t2(1:tpeak),xdotsq0(1:tpeak));

figure
plot(t1,data)
xlabel('Time (s)')
ylabel('Deflection (rad)')
title('Deflection Data')

figure
plot(t2,x)
xlabel('Time (s)')
ylabel('Deflection (rad)')
title('Deflection Spline')

thetamax = x(tpeak);
thetamax0 = x0(tpeak);

figure
plot(t2(1:tpeak),x(1:tpeak))
xlabel('Time (s)')
ylabel('Deflection (rad)')
title('Deflection Until Peak')

figure
plot(t2(1:tpeak),xdot(1:tpeak))
xlabel('Time (s)')
ylabel('Angular Veloctiy (rad/s)')
title('Angular Velocity Until Peak ')

k0 = (m*g*r)/data0(end);
k = (m*g*r)/data(end);

PE1 = m*g*hmax;
PE2 = m*g*(h0-hmass-thetamax*r);
SE = 0.5*k*thetamax^2;


PE20 = m*g*(h0-hmass-thetamax0*r);
SE0 = 0.5*k0*thetamax0^2;
    
b0 = (PE1-PE20-SE0)/integral0(tpeak);
b = (PE1-PE2-SE)/integral(tpeak);

fprintf('k0 = %1.4f, k = %1.4f\n',[k0 k]);
fprintf('b0 = %1.4f, b = %1.4f\n',[b0 b]);

%%
figure
plot(t2,x0)
xlabel('Time (s)')
ylabel('Deflection (rad)')
title('2L2LT4ST100I Energy Test 40Nmm')