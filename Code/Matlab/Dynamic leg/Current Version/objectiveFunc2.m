function f = objectiveFunc2(U)
%pick parameters

b1 = U(1); 
b2 = U(2);
b3 = U(3);
K1 = U(4);
K2 = U(5);
K3 = U(6); 
theta1bias = U(7);
theta2bias = U(8);
theta3bias = U(9);

% Define the mechanical properties of link 1.
P.M1 = .716;  %[lb] Mass of femur with encoder                   
P.R1 = 4.75; % [in]
P.I1 = 496.26; %[in^4]
P.L1 = 9.25; %[in]

% Define the mechanical properties of link 2.
P.M2 = .4299; %[lb]
P.R2 = 4.75; %[in]
P.I2 = 496.26; %[in^4]
P.L2 = 9.25; %[in
% Define the mechanical properties of link 3.
P.M3 = 0.10992; %[lb]
P.R3 = 3.5; %[in]
P.I3 = 122.09; %[in^4]
P.L3 = 7.875;
P.g = 9.81;

init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';


[t,x] = ode45(@(t,y) Dynamic_code2(t,y,b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias,P),t_span,x0);
[t2,x2] = ode45(@(t,y) Dynamic_code2(t,y,0,0,0,0,0,0,0,0,0,P),t_span,x0);
[theta1Data] = x2(:,1);
[theta2Data] = x2(:,3);
[theta3Data] = x2(:,5);
%x1 = x(1);
%x2 = x(3);
%x3 = x(5);

e1 = (theta1Data - x(1));
e2 = (theta2Data - x(3));
e3 = (theta3Data - x(5));

f = e1'*e1 + e2'*e2 + e3'*e3;

end