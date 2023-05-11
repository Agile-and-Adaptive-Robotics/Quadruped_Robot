%% Parameter optimization for rat leg

% Optimizing repsonse for b, k , u, and x0 values. Updated from Joe's
% version.

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results')

% Ask how many points from the first data point to optimize to
points = input('Start and end at what times (s)? Use brackets. ');

%% Choose and load data to optimize to

% Load the data file for all joint data
load('-mat', 'jdata');

% Choose muscle and trial, and starting index value (check figure from
% "plotjdat" in RawDataPlottingProcessing folder. All starting values
% have been manually chosen and saved to "start_indices" data file.
muscle = 3;
trial = 1;
load('-mat', 'start_indices')
load('-mat', 'end_indices')
start_index = start_indices(muscle, trial);
end_index = end_indices(muscle, trial);

% Some trials are not suitable for analysis due to missing data, these have
% been marked by starting indices of 0.
if start_index == 0
    error('\nERROR: Unsuitable trial was selected')
end


% From chosen muscle and trial extract joint angles and time data. Note that
% first cell of jdata corresponds to theta values, the second corresponds
% to time values, and the third corresponds to "force" values.
time = jdata{2}{muscle, trial}(start_index:end_index);                                % [s]
time = time - time(1);
thetas = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;               % [rad]

% Interpolate the data using spline method
time_step = 0.001;                                                  % [ s ]
thetas = interp1(time, thetas, 0:time_step:time(end), 'spline');
time = 0:time_step:time(end);

% Set start and end points for optimizer ("points") variable to indicies
% instead of time
if points(1) == 0
    points(1) = 1;
    points(2) = points(2) / time_step;
else
    points = points / time_step;
end

% Determine resting theta values from end of data set
thetairest(1) = thetas(end, 1);
thetairest(2) = thetas(end, 2);
thetairest(3) = thetas(end, 3);

% Create folder to save results to and add file path
folder_title = strcat('Muscle ', num2str(muscle), ' Trial ', num2str(trial));
mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 


%% Define equations of motion from EOM OR from saved EOM

% Ask user if they want to keep previous EOMs or not
EOM_Q = input('\nDo you want to re-solve for EOM? \nYou should re-solve if using new muscle trial. (y/n) ', 's');

if EOM_Q == 'y'
    fprintf('\nSolving EOM...\n')
    
    [du1, du2, du3, du4, du5, du6, thetabias_sym] = EOM_solver_func(thetairest);
    
    fprintf('\nEOM solved.\n')
    
elseif EOM_Q == 'n'
    
    load('EOM.mat')
    fprintf('\nEOM loaded.\n')
else 
        
    error('ERROR: Please select either y or n')
        
end

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];


%% Set optimization parameters 


% Set options for the search function
options = optimset('PlotFcns','optimplotfval');


% Set initial joint velocities, b, k, and u value guesses manually
% dthetas_i = [0.012672946390051, 0.034892511161215, 0.011994222765143];
% b_i = [0.003, 0.003, 1e-04];
% k_i = [0.064248390406762, 0.454290595328452, 0.001371450462600];
% u_i = [3.705522066482500e-16, 4.329414590071685e-13, 2.848565012127457e-24];

% Compile parameters to be optimized into a single variable 
% U = [dthetas_i, b_i, k_i, u_i];

% Use previous trial's results as initial guesses
IC = input('\nWhat data set do you want to pull initial conditions from? (Do not include .mat) ', 's');
IC_data = load('-mat', IC);
U = [IC_data.dthetas_i IC_data.b_i IC_data.k_i];


%% Optimization
% Set search boundary conditions
LB = [-pi, -pi, -pi, 1e-20, 1e-20, 1e-20, 1e-20, 1e-20, 1e-20];
UB = [pi, pi, pi, 1, 1, 1, 1, 1, 1];

% Run fminsearch on cost function
[param_opt_results,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func(U, dui, time, thetas, points, thetabias_sym),U,LB,UB,options);
%[jointValuesComplex,fval] = fminsearch(@(U) objectiveFuncRatFricIC_Emma(U, dui, time, thetas), U, options);
%[jointValuesComplex,fval] = fminunc(@(U) objectiveFuncRatFricIC_Emma(U, dui, time, thetas), U, options);

%% Comparing joint angles from actual and theoretical values

fprintf('\nParameter optimization achieved, print graphed responses.\n')

% Load ode results
load('ode_results_temp.mat')

fig = figure( 'Color', 'w');

% Create variable to show where optmization ended
optline1 = [ 0.001*points(1)*ones(1, 100); linspace(0, 360, 100) ];
optline2 = [ 0.001*points(2)*ones(1, 100); linspace(0, 360, 100) ];

% Create plot of hip angles
subplot(1,3,1)
plot(time, rad2deg(thetas(:,1)), '--k'); hold on
plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
plot( optline1(1, :), optline1(2,:), '.g'); plot( optline2(1, :), optline1(2,:), '.g')
legend('Experimental data', 'ODE results', 'Optimization end point')
title(sprintf('%s - Hip joint', folder_title))
xlabel('Time (s)')
ylabel('Joint angles (deg)')
xlim([0 0.6])
ylim([60 180])

% Create plot of knee angles
subplot(1,3,2)
plot(time, rad2deg(thetas(:,2)), '--r'); hold on
plot(time_ode, rad2deg(thetas_ode(:,2)), '-r')
plot( optline1(1, :), optline1(2,:), '.g'); plot( optline2(1, :), optline1(2,:), '.g')
legend('Experimental data', 'ODE results', 'Optimization end point')
title(sprintf('%s - Knee joint', folder_title))
xlabel('Time (s)')
ylabel('Joint angles (deg)')
xlim([0 0.6])
ylim([60 180])

% Create plot of ankle angles
subplot(1,3,3)
plot(time, rad2deg(thetas(:,3)), '--b'); hold on
plot(time_ode, rad2deg(thetas_ode(:,3)), '-b')
plot( optline1(1, :), optline1(2,:), '.g'); plot( optline2(1, :), optline1(2,:), '.g')
legend('Experimental data', 'ODE results', 'Optimization end point')
title(sprintf('%s - Ankle joint', folder_title))
xlabel('Time (s)')
ylabel('Joint angles (deg)')
xlim([0 0.6])
ylim([60 180])

% Calculate average difference at each time point
avg_dif = rad2deg(fval / (points(2) - points(1)));
    

% save results - optimized parameters and figure
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\data_results.mat'), 'param_opt_results', 'avg_dif', 'thetas_ode', 'thetas', 'time', 'thetabias_val', 'IC_data')
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\Graphed_results.fig'))




