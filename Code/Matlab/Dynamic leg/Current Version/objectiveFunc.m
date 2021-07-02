function f = objectiveFunc(U)

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
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

%sim
dwrite = 0.00046;
dt = dwrite*4;

init_t=0;
N = 4000;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';
[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);%simulated leg motion wiht input
[a] = ProcessMuscleMutt();%Loads processed MuscleMutt Data
[theta1Data] = a(:,1);
[theta2Data] = a(:,2);
[theta3Data] = a(:,3);


e1 = (x(:,1) - theta1Data);
e2 = (x(:,3) - theta2Data);
e3 = (x(:,5) - theta3Data);
U
f = e1'*e1 + e2'*e2 + e3'*e3

end