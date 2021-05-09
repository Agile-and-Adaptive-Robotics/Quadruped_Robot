clear;close all;clc;
%% Define Mechanical Properties and create Stucture P to store values

% Define the mechanical properties of link 1.
P.M1 = .716;  %[lb] Mass of femur with encoder                   
P.R1 = 4.75; % [in]
P.I1 = 496.26; %[in^4]
P.L1 = 9.25; %[in]

% Define the mechanical properties of link 2.
P.M2 = .4299; %[lb]
P.R2 = 4.75; %[in]
P.I2 = 496.26; %[in^4]
P.L2 = 9.25; %[in
% Define the mechanical properties of link 3.

P.M3 = 0.10992; %[lb]
P.R3 = 3.5; %[in]
P.I3 = 122.09; %[in^4]
P.L3 = 7.875;
P.g = 9.81;

%Joint parameters
U.b1 = 1.2; 
U.b2 = 1.5;
U.b3 = -1;
U.K1 = 0;
U.K2 = 0;
U.K3 = 0; 
U.theta1bias=0;
U.theta2bias = 0;
U.theta3bias = 0;
%% Sim
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

x=zeros(6,N);
x(:,1)=x0;

[t,y] = ode45(@(t,y) Dynamic_code(t,y,P,U),t_span,x0);
[theta1Data] = sin(3*t);
[theta2Data] = sin(5*t);
[theta3Data] = sin(2*t);
L1=P.L1;
L2=P.L2;
L3=P.L3;
M1=P.M1;
M2=P.M2;
M3=P.M3;
g=9.8;

x=y;

figure; hold on;
for i=1:N-1
    if(mod(i,50)==1)
        clf;
        x1=x(i,1);
        x2=x(i,3);
        x3=x(i,5);
        p0x=0;
        p0y=0;
        p1x = L1*cos(x1);
        p1y = L1*sin(x1);
        p2x = L1*cos(x1)+L2*cos(x1+x2);
        p2y = L1*sin(x1)+L2*sin(x1+x2);
        p3x = L1*cos(x1)+L2*cos(x1+x2)+L3*cos(x1+x2+x3);
        p3y = L1*sin(x1)+L2*sin(x1+x2)+L3*sin(x1+x2+x3);
        px=[p0x p1x p2x p3x];
        py=[p0y p1y p2y p3y];
        plot(px,py,'ro-');
        axis([-(P.L1+P.L2+P.L3+4) (P.L1+P.L2+P.L3+4) -(P.L1+P.L2+P.L3+4) (P.L1+P.L2+P.L3+4)]);
        pause(0.001);
       
    end
end

