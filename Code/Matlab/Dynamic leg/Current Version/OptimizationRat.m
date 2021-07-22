clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [-3.623109295579507e+04,-1.660777252860805e+03,-2.931412027249705e+03,-1.684511170064975e+05,-2.613931504194101e+04,-2.337723425492226e+04];
%initialGuess = [-3.816258922827336e+03,79.522171198797600,6.361745240753271e+02,1.822378258785216e+02,26.649081407594700,-0.063300591583706,-12.157148498003238,-0.056353540709907,-1.983885479103121e+03]

f = objectiveFuncRat(initialGuess)
%optimization
jointValues = fmincon(@objectiveFuncRat,initialGuess)
%% Define Mechanical Properties of Rat
% Define the mechanical properties of link 1.
M1 = 13.26;  %[kg] Mass of femur with encoder                   
R1 = 1.305; % [cm]
I1 = 0; %[g cm^2]
L1 = 2.9; %[cm]

% Define the mechanical properties of link 2.
M2 = 9.06; %[g]
R2 = 1.558; %[cm]
I2 = 0; %[in^4]
L2 = 4.1; %[cm
% Define the mechanical properties of link 3.

M3 = 1.7; %[lb]
R3 = 1.6; %[in]
I3 = 0; %[in^4]
L3 = 3.3;
g = 9.81;
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

a = ProccessRat();
x0=[a(1,1) 0 a(1,2) 0 a(1,3) 0]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat(t,x,P,jointValues),a(:,4),x0);
figure;
plot(t,x(:,1),'-r',t,a(:,1),'-b');
Lengths = [L1,L2,L3,a(:,4)']
plotLegsRat(a,x,Lengths)

figure;
plot(a(:,4),x(:,3),'-r',a(:,4),a(:,2),'-b');
title('RatKnee')
figure;
plot(a(:,4),x(:,1),'-r',a(:,4),a(:,1),'-b');
title('RatHip')
figure;
plot(a(:,4),x(:,5),'-r',a(:,4),a(:,3),'-b');
title('RatAnkle')


