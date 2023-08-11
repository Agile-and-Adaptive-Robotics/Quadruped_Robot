% This script is intended to process data collected on the response of each
% leg joint with dampers only.

% run once for K119 damper and once for K118 damper
% both dampers need data to be stored as "hip_dat" in Workspace for optimizer scripts

clear; close('all'); clc

% Add file paths
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')

% Specify length to track response for in seconds, and interval time
time_L = [5 0.87 2];               % [s] 5 for K119, 1 for K118
time_I = 0.01;                     % [s]

% Create time array
time.hip = 0:time_I:time_L(1);
time.knee = 0:time_I:time_L(2);
time.ankle = 0:time_I:time_L(3);
data_N(1) = length(time.hip);
data_N(2) = length(time.knee);
data_N(3) = length(time.ankle);

%% Load data from excel file
% hip_dat can be chosen from '6597K119 Damper Data' or '6597K118 Damper Data'

hip_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', '6597K119 Damper Data');
knee_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', 'Knee Damper Data');
ankle_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', 'Ankle Damper Data');

%% Process data
% Cut off data for specified time length
hip_dat = hip_dat(1:data_N(1), :);
knee_dat =  knee_dat(1:data_N(2), :);
ankle_dat = ankle_dat(1:data_N(3), :);

% Ankle :: Set hip and knee angles for ankle trials
% Ankle data is copied from Emma's trials
ankle_dat(:,(1:3:24)) = 90;     % set hip to 90º for all trials
ankle_dat(:,(2:3:12)) = 180;    % set knee to 180° for first 4 trials
ankle_dat(:,(14:3:24)) = 90;    % set knee to 90° for first 4 trials

% Knee :: Set hip and ankle angles for knee trials
knee_dat(:,(1:3:24)) = 90;      % set hip to 90º for all trials
knee_dat(:,(3:3:12)) = 180;     % set ankle to 180° for trials 1 - 4
knee_dat(:,(15:3:24)) = 90;     % set ankle to 90° for trials 5 - 8

% Hip :: Set knee and ankle for hip trials
hip_dat(:,(2:3:24)) = 180;       % set knee to 180° for all trials
hip_dat(:,(3:3:24)) = 180;      % set ankle to 180° for all trials

% Convert encoder angles to my angle convention
hip_dat(:, (1:3:12)) = 180 - hip_dat(:, (1:3:12));
knee_dat(:, (2:3:24)) = knee_dat(:, (2:3:24)) + 90;
ankle_dat(:, (3:3:24)) = 180 - ankle_dat(:, (3:3:24));

%% Plot data
fig = figure( 'Color', 'w');

subplot(2, 3, 1)
plot(time.hip, hip_dat(:,(1:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([90 190])
title({'Hip Damper K119 Drops:', 'Knee @180, Ankle @180'})

subplot(2, 3, 4)
plot(time.hip, hip_dat(:,(13:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([0 100])
title({'Hip Damper K119 Drops:', 'Knee @180, Ankle @180'})

subplot(2, 3, 2)
plot(time.knee, knee_dat(:,(2:3:13)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 190])
title({'Knee Damper Drops:', 'Hip @90, Ankle @180'})

subplot(2, 3, 5)
plot(time.knee, knee_dat(:,(14:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 190])
title({'Knee Damper Drops:', 'Hip @90, Ankle @90'})

subplot(2, 3, 3)
plot(time.ankle, ankle_dat(:,(3:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 190])
title({'Ankle Damper Drops:', 'Hip @90, Knee @180'})

subplot(2, 3, 6)
plot(time.ankle, ankle_dat(:,(15:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 190])
title({'Ankle Damper Drops:', 'Hip @90, Knee @90'})

%% Save data and figure

% Convert to radians
ankle_dat = deg2rad(ankle_dat);
knee_dat = deg2rad(knee_dat);
hip_dat = deg2rad(hip_dat);

save(strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\DampDataHaonanK119.mat'), 'ankle_dat', 'knee_dat', 'hip_dat', 'time')
