% This script is intended to process data collected on the response of each
% leg joint with dampers and spring.

clear; close('all'); clc

% Add file paths
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results')


% Specify length to track response for in seconds, and interval time
time_L = [0.75 0.75 0.75];                        % [s]
time_I = 0.01;                     % [s]

% Create time array
time.hip = 0:time_I:time_L(1);
time.knee = 0:time_I:time_L(2);
time.ankle = 0:time_I:time_L(3);
data_N(1) = length(time.hip);
data_N(2) = length(time.knee);
data_N(3) = length(time.ankle);

%% Load data from excel file

ankle_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'SpringDampAnkle');
knee_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'SpringDampKnee');
hip_dat = readmatrix('Damping_data.xlsx', 'UseExcel', 1, 'Sheet', 'SpringDampHip');


%% Process data
% Cut off data for specified time length
ankle_dat = ankle_dat(1:data_N(3), :);
knee_dat =  knee_dat(1:data_N(2), :);
hip_dat = hip_dat(1:data_N(1), :);


% Set hip to 90 deg for all ankle trials, and set knee to 180 for first
% six trials, and to 90 for second six trials
ankle_dat(:,(1:3:36)) = 90;
ankle_dat(:,(2:3:18)) = 180; ankle_dat(:,(20:3:36)) = 90;

% Set hip to 180 deg first 6 knee trials
knee_dat(:,(1:3:18)) = 180; knee_dat(:, (19:3:36)) = 90;

% Convert encoder angles to my angle convention
ankle_dat(:, (3:3:36)) = 180 - ankle_dat(:, (3:3:36));
knee_dat(:, (2:3:36)) = 90 + knee_dat(:, (2:3:36)); knee_dat(:,(3:3:36)) = 180 - knee_dat(:, (3:3:36));
hip_dat(:, (1:3:36)) = 90 + hip_dat(:, (1:3:36)); hip_dat(:, (2:3:36)) = 90 + hip_dat(:, (2:3:36)); hip_dat(:,(3:3:36)) = 180 - hip_dat(:, (3:3:36));

%% Plot data

% Creating 6 plots, two for each type of drop for all three joints, with
% all four data sets in each graph.
% Produce figure
fig = figure( 'Color', 'w');

subplot(2, 3, 1)
plot(time.ankle, ankle_dat(:,(3:3:18)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 180])
title({'Ankle damper drops:', 'Hip @90, knee @180'})

subplot(2, 3, 4)
plot(time.ankle, ankle_dat(:,(21:3:36)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(3)]); ylim([90 180])
title({'Ankle damper drops:', 'Hip @90, knee @90'})

subplot(2, 3, 2)
plot(time.knee, knee_dat(:,(2:3:18)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 180])
title({'Knee damper drops:', 'Hip @180, ankle free'})

subplot(2, 3, 5)
plot(time.knee, knee_dat(:,(20:3:36)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([-10 180])
title({'Knee damper drops:', 'Hip @90, ankle free'})

subplot(2, 3, 3)
plot(time.hip, hip_dat(:,(1:3:18)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([0 120])
title({'Hip damper drops:', 'Knee and ankle free'})

%% Save data and figure

% Convert to radians
ankle_dat = deg2rad(ankle_dat);
knee_dat = deg2rad(knee_dat);
hip_dat = deg2rad(hip_dat);

saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\SpringDamperDat.fig'))
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\SpringDampData.mat'), 'ankle_dat', 'hip_dat', 'knee_dat', 'time')

