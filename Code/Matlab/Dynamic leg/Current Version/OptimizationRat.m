clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [-3.816258922827336e+03,79.522171198797600,6.361745240753271e+02,1.822378258785216e+02,26.649081407594700,-0.063300591583706,-12.157148498003238,-0.056353540709907,-1.983885479103121e+03]

f = objectiveFuncRat(initialGuess)
%optimization
jointValues = fminsearch(@objectiveFuncRat,initialGuess)
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

M3 = 0.010992; %[lb]
R3 = 3.5; %[in]
I3 = 122.09; %[in^4]
L3 = 7.875;
g = 9.81;
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

a = ProccessRat();
x0=[a(1,1) 0 a(1,2) 0 a(1,3) 0]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat(t,x,P,jointValues),a(:,4),x0);
figure;
plot(t,x(:,1),'-r',t,a(:,1),'-b')



