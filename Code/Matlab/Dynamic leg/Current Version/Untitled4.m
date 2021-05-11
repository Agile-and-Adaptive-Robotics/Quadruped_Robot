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

%Joint torqes
b1 = 1.2; 
b2 = 1.5;
b3 = 0;
K1 = 0;
K2 = 0;
K3 = 0; 
theta1bias=0;
theta2bias = 0;
theta3bias = 0;
%% Sim
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

x=zeros(6,N);
x(:,1)=x0;

[theta1Data] = sin(3*t);
[theta2Data] = sin(5*t);
[theta3Data] = sin(2*t);
%kin = simulate with optimized joint torques
[t,y] = ode45(@(t,y) Dynamic_code(t,y,b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias,P),t_span,x0);
%get cost
f = objectiveFunc(y,theta1Data,theta2Data,theta3Data)


