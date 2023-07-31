% This script is intended to process data collected on the response of each
% leg joint with dampers only.

clear; close('all'); clc

% Add file paths
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')


% Specify length to track response for in seconds, and interval time
time_L = [5 1 0.88];                        % [s]
time_I = 0.01;                     % [s]

% Create time array
time.hip1 = 0:time_I:time_L(1);
time.hip2 = 0:time_I:time_L(2);
time.knee = 0:time_I:time_L(3);
data_N(1) = length(time.hip1);
data_N(2) = length(time.hip2);
data_N(3) = length(time.knee);

%% Load data from excel file

knee_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', 'Knee Damper Data');
hip1_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', '6597K118 Damper Data');
hip2_dat = readmatrix('damping_data_Haonan.xlsx', 'UseExcel', 1, 'Sheet', '6597K119 Damper Data');


%% Process data
% Cut off data for specified time length
knee_dat =  knee_dat(1:data_N(3), :);
hip2_dat = hip2_dat(1:data_N(2), :);
hip1_dat = hip1_dat(1:data_N(1), :);

% Set hip to 90 deg for all knee trials, and set ankle to 180 for first
% four trials, and to 90 for last four trials
knee_dat(:,(3:4:11)) = 90;      % set hip to 90º for all trials
knee_dat(:,(1:4:9)) = 180;      % set ankle to 180° for all trials

% Set knee to 180 for all hip trials, and set ankle to 120
hip1_dat(:,(2:3:24)) = 180;
hip1_dat(:,(3:3:24)) = 180;

% Convert encoder angles to my angle convention
ankle_dat(:, (3:3:24)) = 180 - ankle_dat(:, (3:3:24));
knee_dat(:, (2:3:24)) = 180 + knee_dat(:, (2:3:24));
hip1_dat(:, (1:3:24)) = hip1_dat(:, (1:3:24));

%% Plot data

% Creating 6 plots, two for each type of drop for all three joints, with
% all four data sets in each graph.
% Produce figure
fig = figure( 'Color', 'w');

subplot(2, 2, 2)
plot(time.knee, knee_dat(:,(2:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 180])
title({'Knee damper drops:', 'Hip @90, ankle @180'})

subplot(2, 2, 5)
plot(time.knee, knee_dat(:,(14:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(2)]); ylim([90 180])
title({'Knee damper drops:', 'Hip @90, ankle @90'})

subplot(2, 2, 3)
plot(time.hip, hip1_dat(:,(1:3:12)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([0 90])
title({'Hip damper drops:', 'Knee @180, ankle @129'})

subplot(2, 2, 6)
plot(time.hip, hip1_dat(:,(13:3:24)))
xlabel('Time (s)'); ylabel('Position (deg)')
xlim([0 time_L(1)]); ylim([90 180])
title({'Hip damper drops:', 'Knee @180, ankle @129'})

%% Save data and figure

% Convert to radians
ankle_dat = deg2rad(ankle_dat);
knee_dat = deg2rad(knee_dat);
hip1_dat = deg2rad(hip1_dat);

saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\DamperDat.fig'))
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\DampData.mat'), 'ankle_dat', 'knee_dat', 'hip_dat', 'time')
