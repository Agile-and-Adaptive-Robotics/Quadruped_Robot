clear;close all;clc;
%% Optimization 
%get parameters [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias]
initialGuess = [0,0,0,-0.5,-8,-0.5,0,0,0];
%get cost
f = objectiveFunc2(initialGuess)
%optimization
jointValues = fminsearch(@objectiveFunc,initialGuess)
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

%Joint parameters
b1 = 0;
b2 = 0;
b3 = 0;
K1 = -1;
K2 = -9;
K3 = -1; 
theta1bias = 0;
theta2bias = 0;
theta3bias = 0;
%Stores Joint Parameters in a vector
U = [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias];
%% Sim
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);
[t2,a] = ode45(@(t,y) Dynamic_code(t,y,P,jointValues),t_span,x0);
mx=[0 0 0 0];
my=[0 0 0 0];

ax = [0 0 0 0];
ay = [0 0 0 0];

figure; hold on;
h = plot(mx,my,'ro-');      
z = plot(ax,ay,'bo-');
legend('Model', 'Optimized Model');
axis([-(L1+L2+L3+4) (L1+L2+L3+4) -(L1+L2+L3+4) (L1+L2+L3+4)]);

for i=1:N-1
    if(mod(i,50)==1)
        x1=x(i,1);
        x2=x(i,3);
        x3=x(i,5);
        m0x=0;
        m0y=0;
        m1x = L1*cos(x1);
        m1y = L1*sin(x1);
        m2x = L1*cos(x1)+L2*cos(x1+x2);
        m2y = L1*sin(x1)+L2*sin(x1+x2);
        m3x = L1*cos(x1)+L2*cos(x1+x2)+L3*cos(x1+x2+x3);
        m3y = L1*sin(x1)+L2*sin(x1+x2)+L3*sin(x1+x2+x3);
        mx=[m0x m1x m2x m3x];
        my=[m0y m1y m2y m3y];
        
        %Optimized Joint positions
        a1=a(i,1);
        a2=a(i,3);
        a3=a(i,5);
        a0x=0;
        a0y=0;
        a1x = L1*cos(a1);
        a1y = L1*sin(a1);
        a2x = L1*cos(a1)+L2*cos(a1+a2);
        a2y = L1*sin(a1)+L2*sin(a1+a2);
        a3x = L1*cos(a1)+L2*cos(a1+a2)+L3*cos(a1+a2+a3);
        a3y = L1*sin(a1)+L2*sin(a1+a2)+L3*sin(a1+a2+a3);
        ax=[a0x a1x a2x a3x];
        ay=[a0y a1y a2y a3y];

        h.XData = mx;
        h.YData = my;
        z.XData = ax;
        z.YData = ay;
        
        drawnow
        pause(0.001);
       
    end
end

