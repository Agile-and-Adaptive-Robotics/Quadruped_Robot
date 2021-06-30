clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [0,0,0,-0.5,-8,-0.5,0,0,0];
%get cost
f = objectiveFunc(initialGuess)
%optimization
jointValues = fminsearch(@objectiveFunc,initialGuess);
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
g = 9.81;
%Stores system paramters in a vector; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

%Joint parameters
b1 = 0;
b2 = 0;
b3 = 0;
K1 = -1;
K2 = -9;
K3 = -1; 
theta1bias = 0;
theta2bias = 0;
theta3bias = 0;
%Stores Joint Parameters in a vector
U = [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias];
%% Sim
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);
[t2,a] = ode45(@(t,y) Dynamic_code(t,y,P,jointValues),t_span,x0);
%% Plot
Lengths = [L1,L2,L3,N];
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    plotLegs(x,a,Lengths);
else
end
