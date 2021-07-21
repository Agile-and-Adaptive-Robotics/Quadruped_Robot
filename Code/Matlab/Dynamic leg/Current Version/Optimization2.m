clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]

%initialGuess = [-4.286935783524542e+02,-2.406295528493199e+02,-3.332955650505215e+03,-1.262806632086322e+03,1.595266905831073,-0.166884675216155];
%initialGuess =[-4.277196376451152e+02,2.927567999697626e+02,-3.340120808690405e+03,-3.644839905916694,1.596381503496003,2.133055049954218];
initialGuess = [-4.286804704438719e+02,-2.405790069465634e+02,-3.332984336659848e+03,-1.264307253384557e+03,1.595256309727422,-0.166726536707248];
%get cost(this part is not nescessary)
%f = objectiveFunc2(initialGuess)
%optimization
jointValues = fmincon(@objectiveFunc2,initialGuess)
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

M3 = 0.010992; %[lb]
R3 = 3.5; %[in]
I3 = 122.09; %[in^4]
L3 = 7.875;
g = 9.81;

M4 = M2+M3;
R4 = (M2*R2 + M3*R3)/(M4);
L4 = L3 + L2;
I4 = I2 + I3;


P = [M1,R1,I1,L1,M4,R4,I4,L4,g];

%% Plot
%variables for simulation
dwrite = 0.00046;
dt = dwrite*4;
init_t=0;
N = 4000;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0]';
Lengths = [L1,L4,N];
%prompt to ask if the user would like to plot
prompt = 'Would you like to plot?(Y/N): ';
fileName = input(prompt,'s');
if fileName == 'Y' || fileName == 'y'
    [t,x] = ode45(@(t,x) Dynamic_code2(t,x,P,jointValues),t_span,x0);
    [a] = ProcessMuscleMutt();
    plotLegs2DOF(x,a,Lengths);
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
else
end
