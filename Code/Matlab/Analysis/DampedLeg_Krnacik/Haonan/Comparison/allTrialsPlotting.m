%% Trial plotting
% Plot all trials to be used
clear
close all
clc

% Add paths needed for loading data and using functions

addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\IC_check')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping')
addpath('C:\Github\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2')
points = [0 0.4];

% Load the data file for all joint data
load('-mat', 'jdata');
load('-mat', 'start_indices')
load('-mat', 'end_indices')
load QuadrupedAvg.mat
load QuadrupedNoDampingAvg.mat

muscles = 1:7;
trials = [5 1 1 1 1 1 1];
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};

fig = figure('Color', 'w');
sgtitle({'Comparison of Quadruped Hind Leg With and Without Integrated Passive Dynamics to Scaled Rat Leg Data',' '})

for n = 1:length(muscles)
    
    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle = muscles(n);
    trial = trials(n);
    data1 = QuadrupedAvg{n};
    data2 = QuadrupedNoDampingAvg{n};

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
    xlim([0 1.4]); ylim([80 180])
    
    hold on
    
    % Plot all three joint angles
    plot(time, thetas(:,1), '-k') %, 'MarkerSize', 3)
    plot(time, thetas(:,2), '-b') %, 'MarkerSize', 3)
    plot(time, thetas(:,3), '-r') %, 'MarkerSize', 3)
   
    a = 0.3;
    markerSize = 5;
    
    hip1 = scatter(data1(:,4),data1(:,1),markerSize,'k','filled');
    knee1 = scatter(data1(:,4),data1(:,2),markerSize,'b','filled');
    ankle1 = scatter(data1(:,4),data1(:,3),markerSize,'r','filled');
    alpha(hip1,0.7)
    alpha(knee1,0.7)
    alpha(ankle1,0.7)
        
    hip2 = scatter(data2(:,4),data2(:,1),markerSize,'k','filled',"square");
    knee2 = scatter(data2(:,4),data2(:,2),markerSize,'b','filled',"square");
    ankle2 = scatter(data2(:,4),data2(:,3),markerSize,'r','filled',"square");
    alpha(hip2,a)
    alpha(knee2,a)
    alpha(ankle2,a)

%         plot(data1(:,4),data1(:,1),'ok','MarkerSize',1);
%         plot(data1(:,4),data1(:,2),'ob','MarkerSize',1);
%         plot(data1(:,4),data1(:,3),'or','MarkerSize',1);
%         
%         plot(data2(:,4),data2(:,1),'^k','MarkerSize',1);
%         plot(data2(:,4),data2(:,2),'^b','MarkerSize',1);
%         plot(data2(:,4),data2(:,3),'^r','MarkerSize',1);

end

hold off
legend('Hip (scaled rat)', 'Knee (scaled rat)', 'Ankle (scaled rat)','Hip (quadruped with springs & dampers)','Knee (quadruped with springs & dampers)','Ankle (quadruped with springs & dampers)','Hip (quadruped no springs or dampers)','Knee (quadruped no springs or dampers)','Ankle (quadruped no springs or dampers)')

% save figure
% addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Trial plotting')
% saveas(fig, 'C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Trial plotting\Plotted_trials.fig')