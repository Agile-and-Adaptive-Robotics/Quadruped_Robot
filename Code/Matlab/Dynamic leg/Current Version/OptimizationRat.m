clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
%initialGuess = [-1.485320940187607e+04,-2.015892992525524e+03,-1.423018958713817e+03,-6.176146031757453e+05,-2.975634699460119e+04,-1.031563682169998e+04];
initialGuess = [-1.005342817406907e+04,-2.100094959087983e+03,-2.911463050324035e+03,-2.866699888879884e+05,-3.040738075416034e+04,-1.890734695664714e+04]

f = objectiveFuncRat(initialGuess)
%optimization
options = optimset('PlotFcns',{@optimplotfval,@optimplotx});
%[jointValues,fval] = fminsearch(@objectiveFuncRat,initialGuess,options);
jointValues = [-1.485320940187607e+04,-2.015892992525524e+03,-1.423018958713817e+03,-6.176146031757453e+05,-2.975634699460119e+04,-1.031563682169998e+04,1000,1000,1000,0,0,0];
[jointValuesComplex,fval] = fminsearch(@objectiveFuncRatFricIC,jointValues,options);
%% Define Mechanical Properties of Rat
% Define the mechanical properties of link 1.
M1 = 13.26;  %[kg] Mass of femur with encoder                   
R1 = 1.305; % [cm]
I1 = 7.52737; %(1/3)*M1*R1^2[g cm^2]
L1 = 2.9; %[cm]

% Define the mechanical properties of link 2.
M2 = 9.06; %[g]
R2 = 1.558; %[cm]
I2 = 7.330542; %(1/3)*M2*R2^2[g*cm^2]
L2 = 4.1; %[cm
% Define the mechanical properties of link 3.

M3 = 1.7; %[lb]
R3 = 1.6; %[in]
I3 = 1.45; %(1/3)*M3*R3^2[in^4]
L3 = 3.3;
g = 9.81;
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

a = ProccessRat();
x0=[a(1,1) jointValuesComplex(10) a(1,2) jointValuesComplex(11) a(1,3) jointValuesComplex(12)]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat_complex(t,x,P,jointValuesComplex),a(:,4),x0);
figure;
plot(t,x(:,1),'-r',t,a(:,1),'-b');
Lengths = [L1,L2,L3,a(:,4)'];
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


