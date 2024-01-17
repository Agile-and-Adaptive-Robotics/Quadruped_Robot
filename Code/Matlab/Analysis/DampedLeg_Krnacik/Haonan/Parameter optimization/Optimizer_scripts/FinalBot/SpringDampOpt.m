%% Parameter Swarm Optimization for the robot leg with springs and dampers


clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\IC_check')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer_scripts\ParticleSwarmOpt')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 3')
% addpath('C:\Users\Haonan\Documents\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_damping_calcs')
% addpath('C:\Users\Haonan\Documents\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_spring_calcs')

% Create folder to save results to and add file path
% folder_title = 'Robot_results';
% mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
% addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 
% clc;


%% Load and format data to be used

% Choose mechanical system to optimize
sysName = 'MechPropBigRat';
sysProp = load('-mat', sysName);

% Load the data file for all joint data
Data = load('-mat', 'SpringDampDataHaonanv5');

% Load solved b values and k values to use as inital conditions
load('-mat', 'C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_damping_calcs_Haonan\Results_HaonanK119.mat', 'b_sols');
load('-mat', 'C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_spring_calcs_Haonan\SpringOptK119.mat', 'k_1', 'k_2', 'k_3');


% Set start time step
time_step = 0.001;                                                  % [ s ]

% Joint names
jnames = ["Hip" "Knee" "Ankle"];


%% Set optimization specifications (IC, BC, options)

% Set initial condiiton data for each joint based on solved values
IC_data = [b_sols(1) k_1; b_sols(2)*2 k_2/1.5; b_sols(3)/3 k_3];

% set a scalar value to create boundary conditions from inital conditions
UB = IC_data * 1.5;
LB = IC_data / 1.5;


%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];

% Assign search options
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 60);

%% OPTIMIZATION 

% Compile non-optimized variables into single structure
data.dui                    = dui;                  % Symbolic EOM
data.thetabias_sym          = thetabias_sym;        % symbolic spring offset
data.time_step              = time_step;            % Time step for interpolation
data.sysProp                = sysProp;              % Mechanical system properties
data.Data                   = Data;                 % Joint response data

% Create an array to save results in
% OptResultsFinal = [ 0 0; 0 0; 0.0112524918202006 0.241039745604524];
OptResultsFinal = [ 0 0; 0 0; 0 0];
data.ORF = OptResultsFinal;

% Produce figure
figure(1)
    
for n = 1:3
    %Assign joints to be solved in reverse order
    joint = 4-n;
    
    data.joint = joint;
    % Run fminsearch on cost function
    fprintf('Beginning optimization for %s...\n', jnames(joint))
    [OptResults,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_springdamp(U, data),IC_data(joint,:),LB(joint,:),UB(joint,:),options);
    fprintf('\nSaving results and creating graphs for %s.\n', jnames(joint))
    
    %SAve results to final array of results
    OptResultsFinal(joint, :) = OptResults;
    data.ORF = OptResultsFinal;
    
    % Assign correct data variable according to joint
    if joint == 1
        data_temp = Data.hip_dat;
        time = data.Data.time.hip;
        b1_value = OptResultsFinal(1,1);                    % [Ns/m]
        k1_value = OptResultsFinal(1,2);                    % [N/m]
        b2_value = OptResultsFinal(2,1);                    % [Ns/m]
        k2_value = OptResultsFinal(2,2);                    % [N/m]
        b3_value = OptResultsFinal(3,1);                	% [Ns/m]
        k3_value = OptResultsFinal(3,2);                    % [N/m]
        
    elseif joint == 2
        data_temp = Data.knee_dat;
        time = data.Data.time.knee;
        b1_value = 1000;                                    % [Ns/m]
        k1_value = 0.1;                                     % [N/m]
        b2_value = OptResultsFinal(2,1);                    % [Ns/m]
        k2_value = OptResultsFinal(2,2);                    % [N/m]
        b3_value = OptResultsFinal(3,1);                	% [Ns/m]
        k3_value = OptResultsFinal(3,2);                    % [N/m]

    elseif joint == 3
        data_temp = Data.ankle_dat;
        time = data.Data.time.ankle;
        b1_value = 1000;                                    % [Ns/m]
        k1_value = 0.1;                                     % [N/m]
        b2_value = 1000;                                    % [Ns/m]
        k2_value = 0.1;                                     % [N/m]
        b3_value = OptResultsFinal(3,1);                	% [Ns/m]
        k3_value = OptResultsFinal(3,2);                    % [N/m]

    end

         % Define which trial to use
         trial = 4;
         thetas = data_temp(:, (trial*3-2):trial*3);

        % Interpolate data so that risetime may be more accurate
        tt = 0:0.0001:time(end);
        a = spline(time, thetas(:,1), tt);
        b = spline(time, thetas(:,2), tt);
        c = spline(time, thetas(:,3), tt);
        thetas = [ a' b' c' ];
        
        % Calculate starting joint angle velocites
        w0s = [ ( thetas(2,1) - thetas(1,1) ) ( thetas(2,2) - thetas(1,2) ) ( thetas(2,3) - thetas(1,3) ) ] / tt(2);

        % Set parameters to run ODE
        param = [ w0s  b1_value b2_value b3_value k1_value k2_value k3_value 0 0 0];

        % Run ODE
        [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, tt, thetas, thetabias_sym, sysName);

        figure(1)
        % Create plot of simulated vs optimized response
        subplot(1,3,joint); hold on
  
        % Plot trial
        plot(tt, rad2deg(thetas(:,joint)), '--k'); plot(time_ode, rad2deg(thetas_ode(:,joint*2-1)), '-k')

        % Graph set-up
        title(sprintf('%s response', jnames(joint)))
        xlabel('Time (s)')
        ylabel('Joint angles (deg)')
        xlim([0 1])
        ylim([60 180])

end
    legend('Experimental response', 'ODE response')

%% %% SAVE RESULTS 
% 
% 
% 
%     
% % save results - optimized parameters and figure
% 
% save(strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_results_Haonan','\AllTrialsPSOResultsHaonan.mat'), 'PSO_results', 'thetabias_val', 'risetime_sim', 'omega_sim', 'zeta_sim', 'JAdiff_sim')
% saveas(fig, strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results\Robot_results_Haonan'\AllTrialsPSOresultsHaonan.fig'))
% fprintf('Data saved.\n')



