close all;

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
jointValuesComplex = [-455966.586054817,-2697.52255454156,-994290.467464718,-1585317.51076767,-165630.063450391,-30418585.8698192,4457633.87198565,49.8967669815472,179345.046691652,-9.76893513885852,-27.2045743261926,284.991209172362];
a = ProccessRat2();
x0=[a(1,1) jointValuesComplex(10) a(1,2) jointValuesComplex(11) a(1,3) jointValuesComplex(12)]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat_complex(t,x,P,jointValuesComplex),a(:,4),x0);

%plotLegsRat(a,x,Lengths);

figure;
plot(a(:,4),x(:,3),'-r',a(:,4),a(:,2),'-b');
title('RatKnee')
%axis([0 1 -1.5 -0.7])
figure;
plot(a(:,4),x(:,1),'-r',a(:,4),a(:,1),'-b');
title('RatHip')
%axis([0 1 1.7 2.2])
figure;
plot(a(:,4),x(:,5),'-r',a(:,4),a(:,3),'-b');
title('RatAnkle')
%axis([0 1 0.5 1.3])
