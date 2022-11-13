%% Parameter optimization for rat leg

% Optimizing repsonse for b, k values for the knee only in five muscles
% trials where hip input was minimal and both hip and ankle parameters were
% approximated and set. As all five trials were solved for in one batch,
% inital velocity was calculated/approximated from the first and second
% joint angle position instead of optimized for.

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results')

% Create folder to save results to and add file path
folder_title = 'AllTrialResults_knee_only';
mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 


%% Load and format data to be used

% Load the data file for all joint data
load('-mat', 'jdata');

% Load start and end indices
load('-mat', 'start_indices')
load('-mat', 'end_indices')

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [1 3 4 5 7];
trials = [5 1 1 1 1];

% Define muscle names
muscle_names = {'IP', 'ST', 'ST2', 'VL', 'BFa'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

% Set start time step
time_step = 0.001;                                                  % [ s ]

%% Set optimization specifications (IC, BC, options)

% Load starting conditions from hand optimized trials isolating the hip and
% the knee/ankle.
IC_data_kneeankle = load('-mat', 'HandOPTknee_IC');

% Set initial conditions for the knee and ankle from that respective trial,
% and the same for the hip. Setting inital velocity to zero.
b_i = [IC_data_kneeankle.b_i(2)];
k_i = [IC_data_kneeankle.k_i(2)];
IC_data = [b_i k_i];
U = IC_data;

% Set options for the search function
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 500);

% Set search boundary conditions based on a scalar multiple of inital guess

scalar_b = 1.5;
scalar_k = 1.5;

b_bc = [ scalar_b .* b_i; b_i ./ scalar_b ];
k_bc = [ scalar_k .* k_i; k_i ./ scalar_k ];
    
UB = [ b_bc(1, :) k_bc(1, :) ];
LB = [ b_bc(2, :) k_bc(2, :) ];

% Define parameters of hip and ankle to be set
hip_var = [0.004 0.1];
ankle_var = [0.0002 0.003];
set_var = [hip_var ankle_var];


%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];



%% OPTIMIZATION 

% Compile non-optimized variables into single structure
data.dui = dui;
data.jdata = jdata;
data.thetabias_sym = thetabias_sym;
data.set_var = set_var;
data.muscles = muscles;
data.trials = trials;
data.start_indices = start_indices;
data.end_indices = end_indices;
data.time_step = time_step;

% Run fminsearch on cost function
fprintf('Running optimization...\n')
[param_opt_results,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func_knee_only(U, data),U,LB,UB,options);
fprintf('Optimization finished.\n')



%% DISPLAY AND SAVE RESULTS 

% Run ODE with achieved parameters and save results, run with friction
% set to zero 
fprintf('\nParameter optimization achieved. Producing results.\n')

% Create variable to save damping ratio and frequency
omega_simact_zeta_simact = zeros(length(muscles),4);

% Produce figure
fig = figure( 'Color', 'w');
    
% Run simulation on each trial with solved values
for m = 1:length(muscles)
    
    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle = muscles(m);
    trial = trials(m);
    start_index = start_indices(muscle, trial);
    end_index = end_indices(muscle, trial);

    % From chosen muscle and trial extract joint angles and time data. Note that
    % first cell of jdata corresponds to theta values, the second corresponds
    % to time values, and the third corresponds to "force" values.
    time = jdata{2}{muscle, trial}(start_index:end_index);                      % [s]
    time = time - time(1);
    thetas = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;  % [rad]

    % Interpolate the data using spline method                                    
    thetas = interp1(time, thetas, 0:time_step:time(end), 'spline');
    time = 0:time_step:time(end);
    
    % Calculate starting joint angle velocites
    w0s = [ ( thetas(2,1) - thetas(1,1) ) ( thetas(2,2) - thetas(1,2) ) ( thetas(2,3) - thetas(1,3) ) ] / time_step;
    
    % Set parameters to run ODE
    param = [ w0s set_var(1) param_opt_results(1) set_var(3) set_var(2) param_opt_results(2) set_var(4) 0 0 0];

    % Run ODE
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, time, thetas, thetabias_sym);

    % Calculate damping ratio land natural frequency
    % Find peaks and location of sim response and actual response for knee
    [pks_x, loc_x] = findpeaks(thetas_ode(:,3)); [pks_xneg, loc_xneg] = findpeaks(-thetas_ode(:,3));    
    [pks_thetas, loc_thetas] = findpeaks(thetas(:,2)); [pks_thetasneg, loc_thetasneg] = findpeaks(-thetas(:,2));

    % Consolidate into single array
    pks_x = abs([pks_x' pks_xneg']); loc_x = [loc_x' loc_xneg'];
    pks_thetas = abs([pks_thetas' pks_thetasneg']); loc_thetas = [loc_thetas' loc_thetasneg'];

    % Define peaks based on offset from steady state value
    SteadyStateX = thetas_ode(end,3);
    SteadyStateThetas = thetas(end,2);
    pks_x = abs(pks_x - SteadyStateX);
    pks_thetas = abs(pks_thetas - SteadyStateThetas);

    % sort positive and negative peaks into singular array
    [pks_x, I_x] = sort(pks_x, 'descend'); loc_x = loc_x(I_x);
    [pks_thetas, I_thetas] = sort(pks_thetas, 'descend'); loc_thetas = loc_thetas(I_thetas);   

    % Calculate log dec and damping ratio
    logdec_x = log(pks_x(1) / pks_x(2));
    logdec_thetas = log(pks_thetas(1) / pks_thetas(2));
    zeta_x = ( logdec_x / (2*pi) ) / sqrt( 1 + (logdec_x / (2*pi))^2);
    zeta_thetas = ( logdec_thetas / (2*pi) ) / sqrt( 1 + (logdec_thetas / (2*pi))^2);

    % Calculate frequency
    omega_x = abs(2 * 0.001 * (loc_x(1) - loc_x(2))) ^-1;
    omega_thetas = abs(2 * 0.001 * (loc_thetas(1) - loc_thetas(2))) ^-1;

    % Save data into array
    omega_simact_zeta_simact(m, :) = [omega_x omega_thetas zeta_x zeta_thetas];


    % Create plot of simulated vs optimized response
    subplot(2,3,m); hold on
    
    % Plot hip angles
    plot(time, rad2deg(thetas(:,1)), '--k'); plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
    
    % Plot knee angles
    plot(time, rad2deg(thetas(:,2)), '--r'); plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
    
    % Plot ankle angles
    plot(time, rad2deg(thetas(:,3)), '--b'); plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
    
    % Graph set-up
    title(sprintf('%s - knee only', data_title{m}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])
   

end
legend('Hip response', 'Simulated hip response', 'Knee response', 'Optimized knee response', 'Ankle response', 'Simulated ankle response')
    
% save results - optimized parameters and figure
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsKneeResults.mat'), 'param_opt_results', 'thetas_ode', 'thetas', 'time', 'thetabias_val', 'IC_data', 'omega_simact_zeta_simact')
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsKneeResults.fig'))
fprintf('Data saved.\n')



