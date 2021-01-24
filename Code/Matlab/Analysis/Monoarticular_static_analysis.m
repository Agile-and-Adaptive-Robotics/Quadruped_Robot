%Static analysis for quadruped robot hind legs
clear
close all
clc

%Defining leg length dimensions, gravity
l1 = 8.625 * (0.0254); %inches to meters
l2 = 8.625 * (0.0254); %inches to meters
l3 = 6.5 * (0.0254); %inches to meters

g = 9.8; %m/s^2

%Defining values for length of actuators
L_AF = 5.76 * (0.0254); %inches to meters, ankle flexor
L_AE = 4.86 * (0.0254); %inches to meters, ankle extender
L_KF = (6:0.5:10) * (0.0254); %inches to meters, knee flexor, current model is 7.28 inches
L_KE = 7.28 * (0.0254); %inches to meters, knee extender

%Defining actuator masses based on estimate 1.698 kg/m
m_AF = 1.698 * L_AF; %kg, ankle flexor
m_AE = 1.698 * L_AE; %kg, ankle extender
m_KF = 1.698 * L_KF; %kg, knee flexor
m_KE = 1.698 * L_KE; %kg, knee extender

%Defining mass values of the leg
me = 0.0205; %kg, mass of encoders
m1 = 0.1302; %kg, mass of section 1 of leg
m2 = 0.1302; %kg
m3 = 0.09814; %kg

%Approximating k_max 
k_max = 0.1667;

%Pick a range of possible attachment radii
r_KF = 0.005:0.001:0.06; %meters, 1mm to 6cm range

%Solving torque from gravity
T_leg = (l2/2) * (m2 + m_AE + m_AF) * g; %N-m, torque from frame and actuator
T_ankle = (l2 + l3/2) * m3 * g; %N-m, max torque from ankle, extended
T_encoder = l2 * me * g; %torque from encoder at ankle
Tg = T_leg + T_ankle + T_encoder;

%setting torque from actuator equal to torque from gravity, solving for F
SF = 1.9; %safety factor
F_KF = SF * (Tg ./ r_KF); %N

%Setting a and S constants for pressure equation (eq 4 from paper)
a0 = 254.3e3; % [Pa] Model Parameter 0.
a1 = 192e3; % [Pa] Model Parameter 1.
a2 = 2.0265;            % [-] Model Parameter 2.
a3 = -0.461;            % [-] Model Parameter 3.
a4 = -0.331e-3;         % [1/N] Model Parameter 4.
a5 = 1.23e3; % [Pa/N] Model Parameter 5.
a6 = 15.6e3; % [Pa] Model Parameter 6.

key = strings(1,length(L_KF)); %pre-allocating for plot legend

for n = 1:length(L_KF)
   
    k = (r_KF * sqrt(2)) ./ L_KF(n); %defining k distance vector that occurs with L_rest to L_inflated
    rowsToDelete = k > k_max; %need to get rid of k values that are larger than k max
    k(rowsToDelete) = [];
    S = 1; %hysteresis factor
    %Solving for pressure
    P = a0 + (a1 * tan( a2 * (( k ./ (a4 * F_KF(1:length(k)) + k_max)) + a3))) + (a5 * F_KF(1:length(k))) + (a6 * S); %Pa
    
    %plotting attachement radius vs required pressure to achieve static torque
    %requirements
    plot((r_KF(1:length(k))*1000), (P/1000), '-')
    hold on
    key(n) = sprintf('Actuator length: %.1f inch', (L_KF(n)/0.0254));
end

%label plot
yline(620, 'r', 'LineWidth', 2);
ylabel('Pressure (kPa)')
xlabel('Attachment radius (mm)')
title('Monoarticular knee flexor: Necessary pressure to achieve static requirements')
legend(key)



