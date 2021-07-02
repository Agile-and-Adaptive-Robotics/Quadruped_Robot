clear;close all;
%% Define Mechanical Properties 
% Define the mechanical properties of link 1.
M1 = .716;  %[lb] Mass of femur with encoder                   
R1 = 4.75; % [in]
I1 = 496.26; %[in^4]
L1 = 9.25; %[in]

% Define the mechanical properties of link 2.
M2 = .4299; %[lb]
R2 = 4.75; %[in]
I2 = 496.26; %[in^4]
L2 = 9.25; %[in
% Define the mechanical properties of link 3.

M3 = 0.10992; %[lb]
R3 = 3.5; %[in]
I3 = 122.09; %[in^4]
L3 = 7.875;
G = 9.81;
%Stores system paramters in a double; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,G];


%Joint parameters
b1 = -40;
b2 = -150;
b3 = -400;
K1 = -1000;
K2 = -1000;
K3 = -400; 
theta1bias = 1.5;
theta2bias = 0;
theta3bias = 0;

b4 = 0;
b5 = 0;
b6 = 0;
K4 = 0;
K5 = 0;
K6 = 0; 
theta4bias = 0;
theta5bias = 0;
theta6bias = 0;

%Stores Joint Parameters in a vector
%U = [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias];
U = [-4.330506086268185e+02,2.147219387356593e+02,-2.954513848446761e+04,-3.507180463647218e+03,-4.351754432148147e+02,0.158216152670930,1.591501043256868,-0.357059593608212,0];
%% Model
dwrite = 0.00046;
dt = dwrite*4;
init_t=0;
N = 4000;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);
[e] = ProcessMuscleMutt();%Loads processed MuscleMutt Data

%% Plot
Lengths = [L1,L2,L3,N];
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    plotLegs(x,e,Lengths);
else
end




