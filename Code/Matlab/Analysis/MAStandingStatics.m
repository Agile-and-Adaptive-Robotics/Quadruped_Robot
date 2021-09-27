%{
Capstone: QBAHL Design
Static Analysis
Standing Position
%}
clear all, clc, close all;
%% Define Mechanical Properties
rhoActuator = 1.698;                 %kg/m
%g = 32.174049 * 12;                 %IN/S^2
g = 9.81;                            %m/s^2

%% Define Needed Dimension (L)engths [x,y] for Limbs, Joints, Actuators, and Attachment Points (AP)
% 1 IN = 0.0254 meters
LFEM   = [0, 8.63] .* 0.0254;                  %m Dimensions of the Femur from the Hip joint
LTIB   = [6.1, 6.1] .* 0.0254;                 %m Dimensions of the Tibia from the Knee joint
LFOOT  = [1.46, 6.19]  .* 0.0254;              %m Dimensions of the Foot from the Ankle joint

LHtoB  = [6, 0]  .* 0.0254;                    %m Distance from Hip Joint to Acting Body Force
LHtoK   = [0, 8.63] .* 0.0254;                 %m Distance from Hip Joint to Knee Joint
LHtoA   = [6.1 ,14.73] .* 0.0254;              %m Distance from Hip Joint to Ankle Joint

thetas = [0, 45, -45];                         %DEGREES Angles are taken from preceding joing axis

%Length [x, y] from Joints to Attachment Points at Limb Angle = Thetas
LAP_KE = [0.54, 0.27] .* 0.0254;               %m Distance from Knee Joint to Knee Extension AP
LAP_KF = [0.77, 0.07] .* 0.0254;               %m Distance from Knee Joint to Knee Flexor AP
LAP_AE = [0.43, 0.62] .* 0.0254;               %m Distance from Ankle Joint to Ankle Extension AP
LAP_AF = [0.82, 0.39] .* 0.0254;               %m Distance from Ankle Joint to Ankle Flexor AP
LAP_HE = [0.25, 0.32] .* 0.0254;               %m Distance from Hip Joint to Hip Extension AP
LAP_HF = [0.25, 0.32] .* 0.0254;               %m Distance from Hip Joint to Hip Flexor AP


LA_HE = 6 * 0.0254;                            %m 1/2 Length of Actuator for Hip Extensor
LA_HF = 6 * 0.0254;                            %m 1/2 Length of Actuator for Hip Flexor
LA_KE = 7.25 * 0.0254;                         %m Length of Actuator for Knee Extensor
LA_KF = 7.25 * 0.0254;                         %m Length of Actuator for Knee Flexor
LA_AE = 5 * 0.0254;                            %m Length of Actuator for Ankle Extensor
LA_AF = 6 * 0.0254;                            %m Length of Actuator for Ankle Flexor

%Define Masses of Actuators
mA_HE = LA_HE * rhoActuator;         %[kg] Mass of Actuator for Hip Extensor
mA_HF = LA_HF * rhoActuator;         %[kg] Mass of Actuator for Hip Flexor
mA_KE = LA_KE * rhoActuator;         %[kg] Mass of Actuator for Knee Extensor
mA_KF = LA_KF * rhoActuator;         %[kg] Mass of Actuator for Knee Flexor
mA_AE = LA_AE * rhoActuator;         %[kg] Mass of Actuator for Ankle Extensor
mA_AF = LA_AF * rhoActuator;         %[kg] Mass of Actuator for Ankle Flexor

% Define mass values of the hind leg sections (From AARL Shared Drive -Quadruped/Designs)
mENC = 0.0205;                      %[kg] Mass of encoders
mFEM = (0.325) - 2*mENC;            %[kg] Section 1 leg mass
mTIB = (0.195) - mENC;              %[kg] Section 2 leg mass
mFOOT = .045;                       %[kg] Section 2 leg mass

%Define the Forces from Weight of Limb Components
%1 lbf = 4.44822N
FW_B = 15/4 * 4.44822;                %[N] Force of Weight of Body
FW_ENC = mENC * g;                    %[N] Force of Weight Encoders
FW_FEM = mFEM * g;                    %[N] Force of Weight of Femur Limb
FW_TIB = mTIB * g;                    %[N] Force of Weight of Tibia Limb
FW_FOOT = mFOOT * g;                  %[N] Force of Weight of Ankle Limb

%Define Forces from Weight of Actuators
FWA_HE = mA_HE * g;                   %[N] Force of Weight (FW) of Actuator (A) for Hip Extensor (HE)
FWA_HF = mA_HF * g;                   %[N] Force of Weight of Actuator for Hip Flexor
FWA_KE = mA_KE * g;                   %[N] Force of Weight of Actuator for Knee Extensor
FWA_KF = mA_HE * g;                   %[N] Force of Weight of Actuator for Knee Flexor
FWA_AE = mA_HE * g;                   %[N] Force of Weight of Actuator for Ankle Extensor
FWA_AF = mA_HE * g;                   %[N] Force of Weight of Actuator for Ankle Flexor

%Define BPA model constants (eq 4 from paper)
% 1 Pa = 0.000145038 psi
% 1 N = 0.224809 lbf
a0 = 254.3e3;                       % [Pa] Model Parameter 0
a1 = 192e3;                         % [Pa] Model Parameter 1
a2 = 2.0265;                        % [-] Model Parameter 2
a3 = -0.461;                        % [-] Model Parameter 3
a4 = -0.331e-3;                     % [1/N] Model Parameter 4
a5 = 1.23e3;                        % [Pa/N] Model Parameter 5
a6 = 15.6e3;                        % [Pa] Model Parameter 6

% Define maximum actuator strain estimate 
k_max = 0.1667;                     % [-]

% Define the hysteresis factor
S = 1;                              % [0,1]

%% Create Strain Relationship to given standing positions 
%The following strain values were measured at the joint attachment points relative 
%to the relaxed position of the limbs as (L.rest - L.strained / L.rest) 
k_HF = k_max/2;
k_KF = 0.05;
k_AE = 0.05;


%% Sum of Forces Notes [lbf]
%sumFX = 0;
%sumFY = 0 = FWB + 2*FWENC + FWFEM + FWTIB + FWFOOT + FWA_HE + FWA_HF + FWA_KE + FWA_KF + FWA_AE + FWA_AF - FN;
FN = FW_B + 3*FW_ENC + FW_FEM + FW_TIB + FW_FOOT + FWA_HE + FWA_HF + FWA_KE + FWA_KF + FWA_AE + FWA_AF;

%actuatorForces = FHE*LAP_HE(2)*cosd(90+thetas(1)) + FKE*cosd(sum(theta(1:2)) + FKF*cosd(90+thetas(2)) + FAE*sind(thetas(3)) + FAF*sind(90+thetas(3)) + FKE*sind(90+thetas(2)) + FKF*sind(thetas(2)-90)+ FAF*cosd(90+thetas(3))+ FAE*cosd(thetas(3))


%% Sum of Moments (Torques) Per Joint [lbf*in]
T_FEM = (FW_FEM + FWA_KE + FWA_KF) * 0.5 * LHtoK(1) + FN * (LHtoA(1) - LFOOT(1)); %Nm
T_TIB = (FW_TIB + FWA_AE + FWA_AF) * 0.5 * LHtoA(1) + FN * (LHtoA(1) - LFOOT(1)); %Nm
T_FOOT = FW_FOOT * LHtoA(1) - FN * LFOOT(1); %Nm

sumT_H =  FW_B * LHtoB(1) - (FW_TIB + FWA_KE + FWA_KF) * 0.5 * LHtoA(1) - (FW_FOOT+ FWA_AE+ FWA_AF + FW_ENC)* LHtoA(1) + FN * (LHtoA(1) - LFOOT(1)); %Nm
sumT_K =  FW_B * LHtoB(1) - (FW_TIB + FWA_KE + FWA_KF) * 0.5 * LHtoA(1) - (FW_FOOT+ FWA_AE+ FWA_AF + FW_ENC)*LHtoA(1) +  FN * (LHtoA(1) - LFOOT(1)); %Nm
sumT_A =  FW_B * LHtoB(1) - FN * LFOOT(1); %Nm


%% Solve for force components at Attachment Point (AP) needed per actuator to sustain torques

%Look at Attachment Point Distances and back solve for evenly distributed torque load across opposing muscles.
% T = F x D  :: F = T / D

%FAP_HE = 0.5 * sqrt((sumT_H / LAP_HE(1))^2 + (sumT_H / LAP_HE(2))^2); %[N]
FAP_HE = sumT_H / LAP_HE(2);
%FAP_HF = 0.5 * sqrt((sumT_H / LAP_HF(1))^2 + (sumT_H / LAP_HF(2))^2); %[N]
FAP_HF = sumT_H / LAP_HF(2);

%FAP_KE = sqrt((sumT_K / LAP_KE(1))^2 + (sumT_H / LAP_KE(2))^2);       %[N]
FAP_KE = sumT_K / LAP_KE(1);
%FAP_KF = sqrt((sumT_K / LAP_KF(1))^2 + (sumT_H / LAP_KF(2))^2);       %[N]
FAP_KF = sumT_K / LAP_KF(1);

FAP_AE = (sumT_A / LAP_AE(1));                                        %[N]
FAP_AF = (sumT_A / LAP_AF(2));                                        %[N]


%% Convert force requirements to BPA Pressures
% 1 psi = 6.89476 KPa

P_HF = a0 + (a1 * tan( a2 * (( k_HF / (a4 * FAP_HF + k_max)) + a3))) + (a5 * FAP_HF) + (a6 * S); % [Pa]
P_KF = a0 + (a1 * tan( a2 * (( k_KF / (a4 * FAP_KF + k_max)) + a3))) + (a5 * FAP_KF) + (a6 * S); % [Pa]
P_AF = a0 + (a1 * tan( a2 * (( k_AE / (a4 * FAP_AF + k_max)) + a3))) + (a5 * FAP_AF) + (a6 * S); % [Pa]


