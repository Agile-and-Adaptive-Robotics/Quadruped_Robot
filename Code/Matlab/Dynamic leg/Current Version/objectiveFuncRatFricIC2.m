function cost = objectiveFuncRatFricIC2(U)
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

%sim
[a] = ProccessRat2();%Loads processed MuscleMutt Data

[theta1Data] = a(:,1);
[theta2Data] = a(:,2);
[theta3Data] = a(:,3);
timeVec = a(:,4);

x0=[theta1Data(1,1) U(8) theta2Data(1,1) U(9) theta3Data(1,1) U(10)]';
[t,x] = ode45(@(t,x) Dynamic_code_Rat_complex2(t,x,P,U),timeVec,x0); %simulated leg motion wiht input

e1 = (x(:,1) - theta1Data);
e2 = (x(:,3) - theta2Data);
e3 = (x(:,5) - theta3Data);

cost = e1'*e1 + e2'*e2 + e3'*e3;
end
