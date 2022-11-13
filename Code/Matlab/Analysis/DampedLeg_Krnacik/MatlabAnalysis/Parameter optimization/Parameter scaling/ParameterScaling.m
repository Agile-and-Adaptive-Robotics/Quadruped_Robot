%% Scaling spring/damper parameters by length

% The purpose of this script is to scale found spring/damper parameters
% found on the rat based on length scaling and to simulate the response

clear; close('all'); clc;

% Add necessary paths
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_knee_only')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_hip_only')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_ankle_only')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')


%% Load and format data to be used

% Choose mechnical system to optimize
sysName = 'MechPropDog';
sysProp = load('-mat', sysName);
sysProp2 = load('-mat', 'MechPropRat');

% Load results from piecewise optimization
hipOPT      = load('-mat', 'AllTrialsHipResults');
kneeOPT     = load('-mat', 'AllTrialsKneeResults');
ankleOPT    = load('-mat', 'AllTrialsAnkleResults');

% Assign variables for rat spring/damper values
hip_b      = hipOPT.param_opt_results(1);    hip_k      = hipOPT.param_opt_results(2);
knee_b     = kneeOPT.param_opt_results(1);   knee_k     = kneeOPT.param_opt_results(2);
ankle_b    = ankleOPT.param_opt_results(1);  ankle_k    = ankleOPT.param_opt_results(2);

RatParam = [hip_b knee_b ankle_b hip_k knee_k ankle_k];     % Consolidate parameters into array

% Create scaling factors from center of mass measurements comparing the dog
% leg to the rat leg
expval      = 1;

scale = [((sysProp.m1_value/sysProp2.m1_value) ^ expval)...
        ((sysProp.m2_value/sysProp2.m2_value) ^ expval)...
        ((sysProp.m3_value/sysProp2.m3_value) ^ expval)];

D2Param = RatParam .* [scale scale];
    
% Load the data file for all joint data
load('-mat', 'jdata');

% Load start and end indices
load('-mat', 'start_indices')
load('-mat', 'end_indices')

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [1 2 3 4 5 6 7];
trials  = [5 1 1 1 1 1 1];

% Define muscle names
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

% Set start time step
time_step = 0.001;                                                  % [ s ]


%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];




%% Run simulations

% Produce figure
fig = figure( 'Color', 'w');
    
% Run simulation on each trial with solved values
for m = 1:length(muscles)
    
    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle      = muscles(m);
    trial       = trials(m);
    start_index = start_indices(muscle, trial);
    end_index   = end_indices(muscle, trial);

    % From chosen muscle and trial extract joint angles and time data. Note that
    % first cell of jdata corresponds to theta values, the second corresponds
    % to time values, and the third corresponds to "force" values.
    time    = jdata{2}{muscle, trial}(start_index:end_index);                      % [s]
    time    = time - time(1);
    thetas  = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;  % [rad]

    % Interpolate the data using spline method                                    
    thetas  = interp1(time, thetas, 0:time_step:time(end), 'spline');
    time    = 0:time_step:time(end);
    
    % Calculate starting joint angle velocites
    w0s = [ ( thetas(2,1) - thetas(1,1) ) ( thetas(2,2) - thetas(1,2) ) ( thetas(2,3) - thetas(1,3) ) ] / time_step;
    
    % Set parameters to run ODE
    param = [ w0s  D2Param 0 0 0];

    timeODE = 0:time_step:5;
    
    % Run ODE
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, timeODE, thetas, thetabias_sym, sysName);
    
    
    % Create plot of simulated vs optimized response
    subplot(2,4,m); hold on
    
    % Plot hip angles
    plot(time, rad2deg(thetas(:,1)), '--k'); plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
    
    % Plot knee angles
    plot(time, rad2deg(thetas(:,2)), '--r'); plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
    
    % Plot ankle angles
    plot(time, rad2deg(thetas(:,3)), '--b'); plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
    
    % Graph set-up
    title(sprintf('%s - Parameter scaling', data_title{m}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 5])
    ylim([60 180])
   

end

legend('Hip response', 'Simulated hip response', 'Knee response', 'Simulated knee response', 'Ankle response', 'Simulated ankle response')
   