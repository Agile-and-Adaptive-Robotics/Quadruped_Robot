% This script is intended to process data collected on the response of each
% leg joint with dampers and spring.

clear; close('all'); clc

% Add file paths
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results')


% Specify length to track response for in seconds, and interval time
time_L = 2;                        % [s]
time_I = 0.01;                     % [s]

% Create time array
time = 0:time_I:time_L;
data_N = length(time);

%% Load data from excel file and process

% Import data
AllDat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'AllJointTesting');

% Eliminate duplicate rows
AllDat = AllDat(1:2:end,:);

% Sort data by trial, leg, and only choose processed joint angles in
% degrees
NewLeg1 = AllDat(:,4:6); OldLeg1 = AllDat(:,10:12);
NewLeg2 = AllDat(:,16:18); OldLeg2 = AllDat(:,22:24);


% Cut off data for specified time length
NewLeg1 = NewLeg1(1:data_N, :); NewLeg2 = NewLeg2(1:data_N, :);
OldLeg1 = OldLeg1(1:data_N, :); OldLeg2 = OldLeg2(1:data_N, :);


%% Plot collected data

% Creating plots
fig = figure( 'Color', 'w');

subplot(3, 2, 1)
plot(time, OldLeg1(:,1), '-', 'LineWidth', 1.5); hold on
plot(time, OldLeg1(:,2), ':', 'LineWidth', 1.5)
plot(time, OldLeg1(:,3), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 1 - Old Leg'})


subplot(3, 2, 3)
plot(time, NewLeg1(:,1), '-', 'LineWidth', 1.5); hold on
plot(time, NewLeg1(:,2), ':', 'LineWidth', 1.5)
plot(time, NewLeg1(:,3), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 1 - New Leg'})


subplot(3, 2, 2)
plot(time, OldLeg2(:,1), '-', 'LineWidth', 1.5); hold on
plot(time, OldLeg2(:,2), ':', 'LineWidth', 1.5)
plot(time, OldLeg2(:,3), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 2 - Old Leg'})


subplot(3, 2, 4)
plot(time, NewLeg2(:,1), '-', 'LineWidth', 1.5); hold on
plot(time, NewLeg2(:,2), ':', 'LineWidth', 1.5)
plot(time, NewLeg2(:,3), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 2 - New Leg'})
legend('Hip', 'Knee', 'Ankle')


%% Run simulation for scaled rat data optimization results

% Choose mechnical system to optimize
sysName = 'MechPropDog';
sysProp = load('-mat', sysName);

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];

% Assign b and k values from D3 dog model
b_vals = [1.29 0.105 0.063];
k_vals = [23.667 1.706 0.454];

% Calculate starting joint angle velocites
w0s = [ 0 0 0];

% Set parameters to run ODE
param = [ w0s b_vals k_vals 0 0 0];

% Run ODE
[ time_ode1, thetas_ode1, thetabias_val ] = dynamics_func(param, dui, time, deg2rad(NewLeg1), thetabias_sym, sysName);
[ time_ode2, thetas_ode2, thetabias_val ] = dynamics_func(param, dui, time, deg2rad(NewLeg2), thetabias_sym, sysName);

% Convert to degrees
thetas_ode1 = rad2deg(thetas_ode1);
thetas_ode2 = rad2deg(thetas_ode2);

subplot(3, 2, 5)
plot(time_ode1, thetas_ode1(:,1), '-', 'LineWidth', 1.5); hold on
plot(time_ode1, thetas_ode1(:,3), ':', 'LineWidth', 1.5)
plot(time_ode1, thetas_ode1(:,5), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 1 - Desired model'})

subplot(3, 2, 6)
plot(time_ode2, thetas_ode2(:,1), '-', 'LineWidth', 1.5); hold on
plot(time_ode2, thetas_ode2(:,3), ':', 'LineWidth', 1.5)
plot(time_ode2, thetas_ode2(:,5), '*', 'MarkerSize', 1.5)
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L]); ylim([60 200])
title({'Drop 2 - Desired model'})