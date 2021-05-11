clear;close all;clc;
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
b1 = -10;
b2 = -10;
b3 = -10.25;
K1 = 0;
K2 = 0;
K3 = 0; 
theta1bias = 0;
theta2bias = 0;
theta3bias = 0;
%Stores them in a vector
U = [b1,b2,b3,K1,K2,K3,theta1bias,theta2bias,theta3bias];
%% Sim
init_t=0;
final_t=10;
dt=0.001;
N= (final_t-init_t)/dt;
t_span=linspace(init_t,final_t,N);

x0=[0 0 0 0 0 0]';

jointValues = [-8.998356861808200,-9.571639693430512,-10.710810654428446,-5.567924826570082e-05,-1.328306884798939e-04,-1.756101662896097e-04,-1.101122922301906e-04,-3.581093501959271e-05,-8.914363522641354e-06];
[t,x] = ode45(@(t,x) Dynamic_code(t,x,P,U),t_span,x0);
[t2,e] = ode45(@(t,y) Dynamic_code(t,y,P,jointValues),t_span,x0);

figure; hold on; plot(x,t);

for i=1:N-1
    if(mod(i,50)==1)
        clf;
        x1=x(i,1);
        x2=x(i,3);
        x3=x(i,5);
        p0x=0;
        p0y=0;
        p1x = L1*cos(x1);
        p1y = L1*sin(x1);
        p2x = L1*cos(x1)+L2*cos(x1+x2);
        p2y = L1*sin(x1)+L2*sin(x1+x2);
        p3x = L1*cos(x1)+L2*cos(x1+x2)+L3*cos(x1+x2+x3);
        p3y = L1*sin(x1)+L2*sin(x1+x2)+L3*sin(x1+x2+x3);
        px=[p0x p1x p2x p3x];
        py=[p0y p1y p2y p3y];
        
        %Optimized Joint positions
        e1=e(i,1);
        e2=e(i,3);
        e3=e(i,5);
        e0x=0;
        e0y=0;
        e1x = L1*cos(e1);
        e1y = L1*sin(e1);
        e2x = L1*cos(e1)+L2*cos(e1+e2);
        e2y = L1*sin(e1)+L2*sin(e1+e2);
        e3x = L1*cos(e1)+L2*cos(e1+e2)+L3*cos(e1+e2+e3);
        e3y = L1*sin(e1)+L2*sin(e1+e2)+L3*sin(e1+e2+e3);
        ex=[e0x e1x e2x e3x];
        ey=[e0y e1y e2y e3y];
        plot(px,py,'ro-',ex,ey,'bo-');
        title(i/10000);
        axis([-(L1+L2+L3+4) (L1+L2+L3+4) -(L1+L2+L3+4) (L1+L2+L3+4)]);
        legend('Model','Optimization');
        pause(0.001);
       
    end
end

