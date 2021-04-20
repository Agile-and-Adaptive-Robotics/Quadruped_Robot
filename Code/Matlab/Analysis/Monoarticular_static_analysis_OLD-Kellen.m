%Static analysis for quadruped robot hind legs
clear
close all
clc

%Defining leg length dimensions, gravity
%L_Back = 6 * (0.0254)       %inches to meters
L_Femur = 8.625 * (0.0254);  %inches to meters
L_Tibia = 8.625 * (0.0254);  %inches to meters
L_Tarsus = 6.5 * (0.0254);   %inches to meters

g = 9.8; %m/s^2

%Defining values for length of actuators
L_HF = (4:0.5:9) * (0.0254);  %inches to meters, Hip Flexor;
L_HE = (4:0.5:9) * (0.0254);  %inches to meters, Hip Extender;
L_KF = (6:0.5:10) * (0.0254); %inches to meters, knee flexor, current model is 7.28 inches
L_KE = (6:0.5:10) * (0.0254); %inches to meters, knee extender
L_AF = (4:0.5:8) * (0.0254);  %inches to meters, ankle flexor
L_AE = (4:0.5:8) * (0.0254);  %inches to meters, ankle extender


%Defining actuator masses based on estimate 1.698 kg/m
%m_HF
%m_HE
m_KF = 1.698 * L_KF; %kg, knee flexor
m_KE = 1.698 * L_KE; %kg, knee extender
m_AF = 1.698 * L_AF; %kg, ankle flexor
m_AE = 1.698 * L_AE; %kg, ankle extender


%Defining mass values of the leg
mE = 0.0205;        %kg, mass of encoders
m_Femur = 0.1302;   %kg, mass of Femur Section of Leg (L1)
m_Tib = 0.1302;     %kg, mass of Tibia/Fibia of Leg
m_Tarsus = 0.09814; %kg, Mass of Tarsus/Foot of Leg

%Setting a and S constants for pressure equation (eq 4 from paper)
a0 = 254.3e3;   % [Pa] Model Parameter 0.
a1 = 192e3;     % [Pa] Model Parameter 1.
a2 = 2.0265;    % [-] Model Parameter 2.
a3 = -0.461;    % [-] Model Parameter 3.
a4 = -0.331e-3; % [1/N] Model Parameter 4.
a5 = 1.23e3;    % [Pa/N] Model Parameter 5.
a6 = 15.6e3;    % [Pa] Model Parameter 6.
aC = [a0,a1,a2,a3,a4,a5,a6];
%Approximating k_max
k_max = 0.1667;

%Pick a range of possible attachment radii
%r_HF
%r_HE
r_KF = 0.002:0.001:0.06;  %meters, 1mm to 6cm range
%r_KE
%r_AF
r_AE = 0.0001:0.0005:0.1; %meters, 2mm to 6cm

%Solving torque from gravity for static Hip Flexion held at 90deg

%Solving torque from gravity for static Hip Extension held at 90deg

%Solving torque from gravity for static Knee Flexion with full Ankle Extension
T_leg = (L_Tibia/2) * (m_Tib + m_AE(end) + m_AF(end)) * g; %N-m, torque from frame and actuator
T_ankle = (L_Tibia + L_Tarsus/2) * m_Tarsus * g; %N-m, max torque from ankle, extended
T_encoder = L_Tibia * mE * g;                    %torque from encoder at ankle
Tg_KF = T_leg + T_ankle + T_encoder;

%Solving torque from gravity for static Knee Extension held at 90deg

%Solving torque from gravity for static Ankle Flexion held at 

%Solving torque from gravity for static Ankle Extension held at 90deg
T_Tarsus = (L_Tarsus/2) * (m_Tarsus) * g;
Tg_AE = T_Tarsus;

%Setting torque from actuator equal to torque from gravity, solving for F
% SF*T = F*r
SF = 1; %safety factor
F_KF = SF .* (Tg_KF ./ r_KF); %N
F_AE = SF .* (Tg_AE ./ r_AE); %N

key = strings(1,length(L_KF)); %pre-allocating for plot legend

%For Knee Flextion Loop to evaluate and store values for each varying attachment length and
%plotting the results. function staticMonoKnee = x pending 
for n = 1:length(L_KF)
   
    k = (r_KF * sqrt(2)) ./ L_KF(n); %defining k distance vector that occurs with L_rest to L_inflated
    rowsToDelete = k > k_max; %need to get rid of k values that are larger than k max
    k(rowsToDelete) = [];
    F_KF = F_KF(1:length(k)); %Getting rid of unnecessary force values corresponding to k
    r_KF = r_KF(1:length(k)); %Getting rid of unnecessary r values corresponding to k
    S = 1; %hysteresis factor
    %Solving for pressure
    P = a0 + (a1 * tan( a2 * (( k ./ (a4 * F_KF + k_max)) + a3))) + (a5 * F_KF) + (a6 * S); %Pa
    
    %plotting attachement radius vs required pressure to achieve static torque
    %requirements
    plot((r_KF*1000), (P/1000), '-')
    hold on
    key(n) = sprintf('Actuator length: %.1f inch', (L_KF(n)/0.0254));
end
%label plot
yline(620, 'r', 'LineWidth', 2)
ylabel('Pressure (kPa)')
xlabel('Attachment radius (mm)')
title('Monoarticular Knee Flexor: Pressure Needed for Static Requirements')
legend(key)

%For Ankle Extension Loop to evaluate and store values for each varying
%attachment point and plotting the results.
actLoop(k_max, r_AE, L_AE, F_AE, aC, ' Ankle Extender ')




%Thinking of adding a sub function or secondary function to handle the for
%loop and plotting of each muscle.
%staticMonoKnee();


% Notes
%{
Need to redesign the static model to incorporate hip motion. Needs
x_Hip, y_Hip

Would like to have X,Y components from centerline for each segment on next
iterarion.

For Hip Motion, need to define torques with reference to the attachment
point datum.

%}

function actLoop(k_max, r_Eff, L_Eff, F_Eff, a, j_Name)

key = strings(1:length(L_Eff));
figure
for n = 1:length(L_Eff)
    k = (r_Eff * sqrt(2)) ./ L_Eff(n); %defining k distance vector that occurs with L_rest to L_inflated
    rowsToDelete = k > k_max; %need to get rid of k values that are larger than k max
    k(rowsToDelete) = [];
    F_Eff = F_Eff(1:length(k)); %Getting rid of unnecessary force values corresponding to k
    r_Eff = r_Eff(1:length(k)); %Getting rid of unnecessary r values corresponding to k
    S = 1; %hysteresis factor
    
    %Solving for pressure (index - 1 = subscript of a constant)
    P = a(1) + (a(2) * tan( a(3) * (( k ./ (a(5) * F_Eff + k_max)) + a(4)))) + (a(6) * F_Eff) + (a(7) * S); %Pa
    
    %plotting attachement radius vs required pressure to achieve static torque
    %requirements
    plot((r_Eff*1000), (P/1000), '-')
    hold on
    key(n) = sprintf('Actuator length: %.1f inch', (L_Eff(n)/0.0254));
end

%label plot
yline(620, 'r', 'LineWidth', 2)
ylabel('Pressure (kPa)')
xlabel('Attachment radius (mm)')
title(strcat('Monoarticular ', j_Name , ' : Pressure Needed for Static Requirements'))
legend(key)

end

