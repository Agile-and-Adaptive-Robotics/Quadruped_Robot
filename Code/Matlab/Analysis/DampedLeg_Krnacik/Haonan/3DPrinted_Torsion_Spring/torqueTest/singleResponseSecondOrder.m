close all
figure
plot(data)
xlim([0 150])

%%
n = 28;
data0 = data - data(1);
data = abs(deg2rad(data0(n:n+100)));
data0 = data;
data = data - data(1);
dataNorm = data/data(end);

%index  [  1     2     3     4     5     6     7     8  ]
%torque [0.010 0.020 0.030 0.040 0.050 0.060 0.070 0.100 0.200]       % [Nm] small pulley
%torque [      0.123       0.245                   0.613      ]       % [Nm] big pulley
mList = [0.050 0.100 0.150 0.200 0.250 0.300 0.350 0.500 1.000];      % [kg]

index = 1;

I = 6.16561/1000^2;         % [kg*m^2]      inertia of the pulley and hex rod from Solidworks
m = mList(index);       %   [kg]

g = 9.81;       %   [m/s^2]
r = 0.02039;      %   [m]                   small pulley
tstep1 = 0.010;
tstep2 = 0.00001;

t = linspace(0,(length(data)-1)/100,length(data));                      % [s] create time vector
k = (m*g*r)/data0(end);
omegan = sqrt(k/I);
ts = settime5(dataNorm,t);        % [s]           settling time based on 5% of steady state value
% zeta = zetaHOD(ts,omegan);        % overdamped system
% zeta = zetaUD(ts,omegan);         % underdamped system

zeta = 0.99;
b = 2*zeta*omegan*I;


% Set up first order transfer function
s = tf('s');                        
funFO = (m*g*r)/((I+(m*r^2))*s^2 + b*s + k);              % first order system approximation
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


fprintf('k = %1.4f\n',k);
fprintf('b = %1.4f\n',b);