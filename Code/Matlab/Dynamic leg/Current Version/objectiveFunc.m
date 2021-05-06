function f = objectiveFunc(b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias)
%pick parameters

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

U.b1 = b1; 
U.b2 = b2;
U.b3 = b3;
U.K1 = K1;
U.K2 = K2;
U.K3 = K3; 
U.theta1bias=theta1bias;
U.theta2bias = theta2bias;
U.theta3bias = theta3bias;
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';


[t,x] = ode45(@(t,y) Dynamic_code(t,y,P,U),t_span,x0);
[theta1Data] = sin(3*t);
[theta2Data] = sin(5*t);
[theta3Data] = sin(2*t);
x1 = x(1);
x2 = x(3);
x3 = x(5);

f = (theta1Data - x1).^2 + (theta2Data - x2).^2 + (theta3Data - x3).^2;
end