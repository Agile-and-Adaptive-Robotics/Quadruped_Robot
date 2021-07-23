load('JointAngles&timeNoAct.mat');

%% Define Mechanical Properties 
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
%Stores system paramters in a vector; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];
jointValuesComplex = [-1.485320940187607e+04,-2.015892992525524e+03,-1.423018958713817e+03,-6.176146031757453e+05,-2.975634699460119e+04,-1.031563682169998e+04,1000,1000,1000,0,0,0];
a = ProccessRat();
x0=[a(1,1) jointValuesComplex(10) a(1,2) jointValuesComplex(11) a(1,3) jointValuesComplex(12)]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat_complex(t,x,P,jointValuesComplex),a(:,4),x0);

%plotLegsRat(a,x,Lengths);

figure;
plot(timeVec4,x(:,3),'-r',timeVec4,a(:,2),'-b');
title('RatKnee')
logdec = log(-1.03745/-1.11913)
zeta = 1/(sqrt(1 + (2*pi)/logdec))
dampedFrequency = (2*pi)/(0.31-0.15)
naturalFrequency = dampedFrequency/sqrt(1+zeta^2)
figure;
plot(timeVec4,x(:,1),'-r',timeVec4,a(:,1),'-b');
title('RatHip')
figure;
plot(timeVec4,x(:,5),'-r',timeVec4,a(:,3),'-b');
title('RatAnkle')
