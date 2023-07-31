% This script is intended to process data collected on the response of each
% leg joint with dampers only.

clear; close('all'); clc

% Add file paths
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')


% Specify length to track response for in seconds, and interval time
time_L = [11 2 2];                        % [s]
time_I = 0.01;                     % [s]

% Create time array
time.hip = 0:time_I:time_L(1);
time.knee = 0:time_I:time_L(2);
time.ankle = 0:time_I:time_L(3);
data_N(1) = length(time.hip);
data_N(2) = length(time.knee);
data_N(3) = length(time.ankle);

%% Load data from excel file

ankle_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'Ankle damper data');
knee_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'Knee Damper Data');
hip_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'Hip Damper Data');


%% Process data
% Cut off data for specified time length
ankle_dat = ankle_dat(1:data_N(3), :);
knee_dat =  knee_dat(1:data_N(2), :);
hip_dat = hip_dat(1:data_N(1), :);


% Set hip to 90 deg for all ankle trials, and set knee to 180 for first
% four trials, and to 90 for second four trials
ankle_dat(:,(1:3:24)) = 90;
ankle_dat(:,(2:3:12)) = 180; ankle_dat(:,(14:3:24)) = 90;

% Set hip to 90 deg for all knee trials, and set ankle to 180 for first
% four trials, and to 90 for last four trials
knee_dat(:,(1:3:24)) = 90;
knee_dat(:,(3:3:12)) = 180; knee_dat(:,(15:3:24)) = 90;

% Set knee to 180 for all hip trials, and set ankle to 120
hip_dat(:,(2:3:24)) = 180;
hip_dat(:,(3:3:24)) = 129;

% Convert encoder angles to my angle convention
ankle_dat(:, (3:3:24)) = 180 - ankle_dat(:, (3:3:24));
knee_dat(:, (2:3:24)) = 180 + knee_dat(:, (2:3:24));
hip_dat(:, (1:3:24)) = hip_dat(:, (1:3:24));

%% Plot data

% Creating 6 plots, two for each type of drop for all three joints, with
% all four data sets in each graph.
% Produce figure
fig = figure( 'Color', 'w');

subplot(2, 3, 1)
plot(time.ankle, ankle_dat(:,(3:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 180])
title({'Ankle damper drops:', 'Hip @90, knee @180'})

subplot(2, 3, 4)
plot(time.ankle, ankle_dat(:,(15:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 180])
title({'Ankle damper drops:', 'Hip @90, knee @90'})

subplot(2, 3, 2)
plot(time.knee, knee_dat(:,(2:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 180])
title({'Knee damper drops:', 'Hip @90, ankle @180'})

subplot(2, 3, 5)
plot(time.knee, knee_dat(:,(14:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 180])
title({'Knee damper drops:', 'Hip @90, ankle @90'})

subplot(2, 3, 3)
plot(time.hip, hip_dat(:,(1:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([0 90])
title({'Hip damper drops:', 'Knee @180, ankle @129'})

subplot(2, 3, 6)
plot(time.hip, hip_dat(:,(13:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([90 180])
title({'Hip damper drops:', 'Knee @180, ankle @129'})

%% Save data and figure

% Convert to radians
ankle_dat = deg2rad(ankle_dat);
knee_dat = deg2rad(knee_dat);
hip_dat = deg2rad(hip_dat);

saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\DamperDat.fig'))
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\DampData.mat'), 'ankle_dat', 'knee_dat', 'hip_dat', 'time')
