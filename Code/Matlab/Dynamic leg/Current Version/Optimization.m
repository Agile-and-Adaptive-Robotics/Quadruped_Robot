clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
%initialGuess=[-4.612173474021026e+02,23.158328148991920,-1.063925869261585e+04,-6.578556810735615e+03,-14.885236935699204,0.221662962060255];
initialGuess = [-4.584529608866828e+02,1.407280982810701e+02,-1.836691662593935e+04,-5.192003202845893e+03,-4.263485490934336,0.125205833629962];
%get cost(this part is not nescessary)
f = objectiveFunc(initialGuess)
%optimization
initialGuess = [-4.575698136738724e+02,48.556754803082330,-1.564675449509693e+04,-5.188223638070525e+03,15.968758573183504,0.248315899160000,1000,1000,1000,0,0,0];
options = optimset('PlotFcns',{@optimplotfval,@optimplotx});
[jointValues,fval] = fminsearch(@objectiveFuncMMComplex,initialGuess,options);
%% Define Mechanical Properties 
% Define the mechanical properties of link 1.
M1 = .716;  %[lb] Mass of femur with encoder                   
R1 = 4.75; % [in]
L1 = 9.25; %[in]
I1 =  496.26;%(1/3)*M1*L1^2;%[in^4]

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

g = 9.81;
%Stores system paramters in a vector; 
P = [M1,R1,I1,L1,M2,R2,I2,L2,M3,R3,I3,L3,g];

%% Plot
%variables for simulation
dwrite = 0.00046;
dt = dwrite*4;
init_t=0;
N = 3751;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0.104311 jointValues(10) -0.0230097 jointValues(11) 0 jointValues(12)]';
Lengths = [L1,L2,L3,N];
%prompt to ask if the user would like to plot
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    [t,x] = ode45(@(t,x) Dynamic_code_complex(t,x,P,jointValues),t_span,x0);
    [a] = ProcessMuscleMutt();
    plotLegs(x,a,Lengths);
     figure
plot(t,x(:,1),'r-',t,a(:,1),'b-');
title('Hip rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');

figure
plot(t,x(:,3),'r-',t,a(:,2),'b-');
title('Knee rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');

figure
plot(t,x(:,5),'r-',t,a(:,3),'b-');
title('Ankle rotation');
xlabel('time (s)');
ylabel('radians');
legend('Optimized Model', 'Muscle Mutt Data');
else
end
