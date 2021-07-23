clear;close all;
%% Define Mechanical Properties 
% Define the mechanical properties of link 1.
M1 = .716;  %[lb] Mass of femur with encoder                   
R1 = 4.75; % [in]
L1 = 9.25; %[in]
I1 = 496.26;%(1/3)*M1*L1^2;%[in^4]

% Define the mechanical properties of link 2.
M2 = .4299; %[lb]
R2 = 4.75; %[in]
L2 = 9.25; %[in
I2 = 496.26; %(1/3)*M2*L2^2;[in^4]

% Define the mechanical properties of link 3.
M3 = 0.010992; %[lb]
R3 = 3.5; %[in]
L3 = 7.875;
I3 = 122.09;%(1/3)*M3*L3^2; %[in^4]

G = 9.81;
%Stores system paramters in a double; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,G];

%Joint parameters

b4 = 0;
b5 = 0;
b6 = 0;
K4 = 0;
K5 = 0;
K6 = 0; 
theta4bias = 0;
theta5bias = 0;
theta6bias = 0;

%Stores Joint Parameters in a vector
%U = [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias];
U = [-4.575698136738724e+02,48.556754803082330,-1.564675449509693e+04,-5.188223638070525e+03,15.968758573183504,0.248315899160000];
%% Model
dwrite = 0.00046;
dt = dwrite*4;
init_t=0;
N = 3751;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0.104311 0 -0.0230097 0 0 0]';

[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);
%[t2,e] = ode45(@(t,e) Dynamic_code2(t,e,P,U),t_span,x0);
[e] = ProcessMuscleMutt();%Loads processed MuscleMutt Data

logdec = log(-3.11398/-2.2212);
zeta = 1/(sqrt(1 + (2*pi)/logdec))
dampedFrequency = (2*pi)/(3.30368-1.04724);
naturalFrequency = dampedFrequency/sqrt(1+zeta^2)

HipZetaEqu = U(4)/(2*(sqrt(M1/U(1))))% b/2*squar(M/C)
HipNfEqu = sqrt(1/(U(1)*M1)) %squr(1/M*C)
KneeZetaEqu = U(5)/(2*(sqrt(M1/U(2))))% b/2*squar(M/C)
KneeNfEqu = sqrt(1/(U(2)*M2)) %squr(1/M*C)
AnkleZetaEqu = U(6)/(2*(sqrt(M1/U(3))))% b/2*squar(M/C)
AnkleNfEqu = sqrt(1/(U(3)*M3)) %squr(1/M*C)
%% Plot
Lengths = [L1,L2,L3,N];
%plotSingleLeg(e,Lengths);
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    plotLegs(x,e,Lengths);
        figure
plot(t,x(:,1),'r-',t,e(:,1),'b-');
title('Hip rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');


%logdec2 = log(-0.727107/-1.43887)
%zeta2 = 1/(sqrt(1 + (2*pi)/logdec2))
%dampedFrequency2 = (2*pi)/(4.37321-2.15521)
%naturalFrequency2 = dampedFrequency2/sqrt(1+zeta2^2)


figure
plot(t,x(:,3),'r-',t,e(:,2),'b-');
title('Knee rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');
figure
plot(t,x(:,5),'r-',t,e(:,3),'b-');
title('Ankle rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');
else
end



