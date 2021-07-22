load('JointAngles&timeNoAct.mat');

%% Define Mechanical Properties 
% Define the mechanical properties of link 1.
M1 = 13.26;  %[kg] Mass of femur with encoder                   
R1 = 1.305; % [cm]
I1 = 5; %[g cm^2]
L1 = 2.9; %[cm]

% Define the mechanical properties of link 2.
M2 = 9.06; %[g]
R2 = 1.558; %[cm]
I2 = 5; %[in^4]
L2 = 4.1; %[cm
% Define the mechanical properties of link 3.

M3 = 1.7; %[g]
R3 = 1.6; %[cm]
I3 = 5; %[in^4]
L3 = 3.3;
g = 9.81;
%Stores system paramters in a vector; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];
U = [-3.623109295579507e+04,-1.660777252860805e+03,-2.931412027249705e+03,-1.684511170064975e+05,-2.613931504194101e+04,-2.337723425492226e+04];

[a] = ProccessRat();
Lengths = [L1,L2,L3,370];
x0=[a(1,1) 0 a(1,2) 0 a(1,3) 0]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat(t,x,P,U),timeVec4',x0);

plotLegsRat(a,x,Lengths)

figure;
plot(timeVec4,x(:,3),'-r',timeVec4,a(:,2),'-b');
title('RatKnee')
figure;
plot(timeVec4,x(:,1),'-r',timeVec4,a(:,1),'-b');
title('RatHip')
figure;
plot(timeVec4,x(:,5),'-r',timeVec4,a(:,3),'-b');
title('RatAnkle')
