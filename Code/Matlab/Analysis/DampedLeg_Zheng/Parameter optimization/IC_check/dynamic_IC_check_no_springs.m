%% Dynamics check
% Used to check if parameters for optmization are a good inital condition
% Much of this has been copied from optimization code, but the optimizer
% itself is not run

clear, clc;
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\IC_check')
% Define what system properties to use
systemProp = 'MechPropBigRat';

% Ask user if data (parameters and graph) should be saved. If yes, save
% parameters used and resulting graph

%save_dat = input('Do you want to save the parameters used and resulting graph? (y/n) ', 's');
save_dat = 'n';

%% Set parameters
joint = 3;
trial = 1;
% Set initial joint velocities, b, k, and u values
dthetas_i = [0, 0, 0];
b_i = [1000, 1000, 0.04];
k_i = [0.000001, 0.000001, 0.000001];
u_i = [0, 0, 0];

% Compile parameters to be optimized into a single variable 
U = [dthetas_i, b_i, k_i, u_i];

%% Choose and load data to optimize to


% Load the data file for all joint data
DampData = load('-mat', 'DampDataHaonanK118');

%% Define symbolic equations of motion from saved EOM file

load('EOM_no_springs.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];

%% Run ODE
time_ode = 0:0.001:5;

fprintf('\nRunning ODE...\n')
[time_ode, thetas_ode, time, thetas] = dynamics_func_no_springs(U, dui, joint, trial, systemProp, DampData);


%% Comparing joint angles from actual and theoretical values

fprintf('\nODE completed, print graphed responses.\n')
fig = figure( 'Color', 'w');

plot(time_ode, rad2deg(thetas_ode(:,(joint*2-1)))); hold on
plot(time, rad2deg(thetas(:, ((trial-1)*3+joint))))
legend('ODE', 'Exp data')

