%% Parameter optimization for rat leg

% Optimizing repsonse for b, k values for the ankle only, using optimized
% knee values and set ankle values. Optimizer iterates through four trials
% to be used in the cost function on each iteration

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_knee_only')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_hip_only')

% Create folder to save results to and add file path
folder_title = 'AllTrialResults_ankle_only';
mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 


%% Load and format data to be used

% Load the data file for all joint data
load('-mat', 'jdata');

% Load start and end indices
load('-mat', 'start_indices')
load('-mat', 'end_indices')

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [ 1 2 3 4 5 6 7 ];
trials = [ 5 1 1 1 1 1 1];

% Define muscle names
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

% Set start time step
time_step = 0.001;                                                  % [ s ]

%% Set optimization specifications (IC, BC, options)

% Load starting conditions from the optimized trials for the hip and knee,
% and the IC for the ankle from a hand optimization.
dynchk_results = load('-mat', 'HandOPTknee_IC');
kneeOPT = load('-mat', 'AllTrialsKneeResults');
hipOPT = load('-mat', 'AllTrialsHipResults');

% Set initial conditions for the ankle based on hand optimized data
b_i = dynchk_results.b_i(3)/3;
k_i = dynchk_results.k_i(3);
IC_data = [b_i k_i];
U = IC_data;

% Set options for the search function
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 500);

% Set search boundary conditions 
UB = [ (kneeOPT.param_opt_results(1) / 2) (kneeOPT.param_opt_results(2) / 2) ];
LB = [ b_i/5 k_i/5 ];

% Define parameters of knee and hip to be set
hip_var = [hipOPT.param_opt_results];
knee_var = [kneeOPT.param_opt_results];
set_var = [hip_var knee_var];


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
[param_opt_results,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func_ankle_only(U, data),U,LB,UB,options);
fprintf('Optimization finished.\n')



%% DISPLAY AND SAVE RESULTS 

% Run ODE with achieved parameters and save results, run with friction
% set to zero 
fprintf('\nParameter optimization achieved. Producing results.\n')

% Create variable to save damping ratio and frequency
risetime_simact = zeros(length(muscles),2);

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
    param = [ w0s set_var(1) set_var(3) param_opt_results(1) set_var(2) set_var(4) param_opt_results(2) 0 0 0];


    % Run ODE
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, time, thetas, thetabias_sym);

    
    
    % CALCULATE RISETIME IN HIP
    risetime_x = risetime_ek(thetas_ode(:,1), time_ode);
    risetime_thetas = risetime_ek(thetas(:,1), time);

    
    % CALCULATE DAMPING RATIO AND NATURAL FREQUENCY IN KNEE
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
    
    % CALCULATE JOINT ANGLE ERROR IN ANKLE
    JAdiff = rad2deg( abs( thetas_ode(:,5) - thetas(:,3) ) );
    
    % Save data into array (risetime for hip, frequency/damping for knee,
    % and average joint angle difference for ankle
    risetime_simact(m, :) = [risetime_x risetime_thetas];
    omega_simact_zeta_simact(m, :) = [omega_x omega_thetas zeta_x zeta_thetas];
    avgJAdiff(m) = mean(JAdiff);
    
    % Create plot of simulated vs optimized response
    subplot(2,4,m); hold on
    
    % Plot hip angles
    plot(time, rad2deg(thetas(:,1)), '--k'); plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
    
    % Plot knee angles
    plot(time, rad2deg(thetas(:,2)), '--r'); plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
    
    % Plot ankle angles
    plot(time, rad2deg(thetas(:,3)), '--b'); plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
    
    % Graph set-up
    title(sprintf('%s - Hip only', data_title{m}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])
   

end

legend('Hip response', 'Optimized hip response', 'Knee response', 'Optimized knee response', 'Ankle response', 'Optimized ankle response')
    
% save results - optimized parameters and figure
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsAnkleResults.mat'), 'param_opt_results', 'thetas_ode', 'thetas', 'time', 'thetabias_val', 'IC_data', 'risetime_simact', 'omega_simact_zeta_simact', 'avgJAdiff')
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsAnkleResults.fig'))
fprintf('Data saved.\n')



