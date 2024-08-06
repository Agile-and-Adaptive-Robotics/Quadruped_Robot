xclose all
figure
plot(data)
%xlim([0 150])

%%
n = 20;
data0 = data - data(1);
data = abs(deg2rad(data0(n:n+100)));
data0 = data;
data = data - data(1);
dataNorm = data/data(end);

%index  [  1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16 ]
%torque [0.010 0.020 0.030 0.040 0.050 0.060 0.070 0.080 0.100 0.120 0.140 0.200 0.240 0.300 0.340 0.400]  % [Nm] small pulley
%torque [      0.123       0.245             0.429       0.613       0.858 1.226                        ]       % [Nm] big pulley
mList = [0.050 0.100 0.150 0.200 0.250 0.300 0.350 0.400 0.500 0.600 0.700 1.000 1.200 1.500 1.700 2.000];      % [kg]

index = 9;

I1 = 6.16561/1000^2;         % [kg*m^2]      inertia of the pulley and hex rod from Solidworks
m = mList(index);       %   [kg]

g = 9.81;       %   [m/s^2]
r = 0.02;      %   [m]                   small pulley
tstep1 = 0.010;
tstep2 = 0.00001;

t = linspace(0,(length(data)-1)/100,length(data));                      % [s] create time vector additional data
k = (m*g*r)/data0(end);

ts = settime5(dataNorm,t);        % [s]           settling time based on 5% of steady state value
tau = ts/4;                                     % [s]           first order system coefficient
b = tau*k;                                     % [Nms/rad]     damping constant derived from second order ODE characteristics

% Set up first order transfer function
s = tf('s');                        
funFO = (m*g*r)/(b*s + k);              % first order system approximation
modelFO = step(funFO,t);     % store step response of first order system
modelFONorm = modelFO/modelFO(end); % normalize first order system response for comparison

figure
hold on
plot(t,dataNorm)
plot(t,modelFONorm)
xlabel('Time (s)')
ylabel('Normalized Deflection')
legend('Experimental Data','First Order Model Approximation','Location','southeast')
hold off
title('2L2LT4ST37T 10Nm CW Torque Test')

fprintf('k = %1.4f\n',k);
fprintf('b = %1.4f\n',b);