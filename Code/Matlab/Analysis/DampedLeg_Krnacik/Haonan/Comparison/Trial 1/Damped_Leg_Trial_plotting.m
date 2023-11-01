%% Trial plotting
% Plot all trials to be used
clear
close all
clc

% Add paths needed for loading data and using functions

addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\IC_check')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison')
points = [0 0.4];

% Load the data file for all joint data
load('-mat', 'jdata');
load('-mat', 'start_indices')
load('-mat', 'end_indices')
load Quadruped.mat

muscles = 1:7;
trials = [5 1 1 1 1 1 1];
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};

fig = figure('Color', 'w');

for n = 1:length(muscles)
    
    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle = muscles(n);
    trial = trials(n);
    data = Quadruped{n};

    start_index = start_indices(muscle, trial);
    end_index = end_indices(muscle, trial);

    % From chosen muscle and trial extract joint angles and time data. Note that
    % first cell of jdata corresponds to theta values, the second corresponds
    % to time values, and the third corresponds to "force" values.
    time = jdata{2}{muscle, trial}(start_index:end_index);                          % [s]
    time = 2*(time - time(1));
    thetas = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;      % [rad]
    thetas = rad2deg(thetas);                                                       % [deg]
    
    subplot(2, 4, n)
    
    % Create graph set-up
    title(strcat({'Muscle stimulated: '}, muscle_names(n), {', Trial chosen: '}, num2str(trial)))
    xlabel('Time (s)'); ylabel('Joint angles (deg)')
    xlim([0 0.50]); ylim([80 180])
    
    hold on
    
    % Plot all three joint angles
    plot(time, thetas(:,1), '-k') %, 'MarkerSize', 3)
    plot(time, thetas(:,2), '-b') %, 'MarkerSize', 3)
    plot(time, thetas(:,3), '-r') %, 'MarkerSize', 3)
   
    hold on
      for ii = 1:3
        hip = scatter(data(:,4*ii),data(:,4*ii-3),5,'k','filled');
        knee = scatter(data(:,4*ii),data(:,4*ii-2),5,'b','filled');
        ankle = scatter(data(:,4*ii),data(:,4*ii-1),5,'r','filled');
        alpha(hip,.1)
        alpha(knee,.1)
        alpha(ankle,.1)
      end 
    hold off
end

legend('Hip (scaled rat)', 'Knee (scaled rat)', 'Ankle (scaled rat)','Hip (quadruped)','Knee (quadruped)','Ankle (quadruped)')

% save figure
% addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Trial plotting')
% saveas(fig, 'C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Trial plotting\Plotted_trials.fig')