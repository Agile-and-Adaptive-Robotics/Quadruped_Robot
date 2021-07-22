load('JointAngles&timeNoAct.mat');

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
U = [[-1.108253263219041e+03,-1.350718240197184e+02,-3.009249694503650e+02,-1.376256431241576e+02,-6.818431317628306,1.180756926243309e+03,-89.309969023003490,-0.698274723835142,-1.737623952094057]];

[a] = ProccessRat();
Lengths = [175,180.652,139.55,370]
L1 = Lengths(1);
L2 = Lengths(2);
L3 = Lengths(3);
N = Lengths(4);



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
