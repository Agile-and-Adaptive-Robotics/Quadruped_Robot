%% Parameter Swarm Optimization for rat leg

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_knee_only')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\AllTrialResults_hip')

% Create folder to save results to and add file path
folder_title = 'PSOrat_results2';
mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 
clc;

%% Load and format data to be used

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

%% Set optimization specifications (IC, BC, options)

% Load results from sequential optimization
hipOPT      = load('-mat', 'AllTrialsHipResults');
kneeOPT     = load('-mat', 'AllTrialsKneeResults');
ankleOPT    = load('-mat', 'AllTrialsAnkleResults');

% Set initial conditions for each joint based on previously optimized
% parameters
hip_bi      = hipOPT.param_opt_results(1);    hip_ki = hipOPT.param_opt_results(2);
knee_bi     = kneeOPT.param_opt_results(1);   knee_ki = kneeOPT.param_opt_results(2);
ankle_bi    = ankleOPT.param_opt_results(1);  ankle_ki = ankleOPT.param_opt_results(2);

IC_data     = [hip_bi hip_ki knee_bi knee_ki ankle_bi ankle_ki];

% Set options for the particle swarm optimization
n_particles     = 20;
n_iterations    = 100;

% Set search boundary conditions based on a scalar multiple of inital guess
% (corresponding to hip, knee, ankle)
upscal = [1.5 1.5 1.25 1.25 1.5 1.5];
lowscal = [15 15 1.5 1.5 5 5];


%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];



%% OPTIMIZATION 

% Compile non-optimized variables into single structure
data.dui            = dui;                  % [ Symbolic EOM ]
data.jdata          = jdata;                % [ All joint angle data ]
data.thetabias_sym  = thetabias_sym;        % [ symbolic spring offset ]
data.muscles        = muscles;              % [ Muscles to be used ]
data.trials         = trials;               % [ Trials to be used ]
data.start_indices  = start_indices;        % [ Start indices for data ]
data.end_indices    = end_indices;          % [ End indices for data ]
data.time_step      = time_step;            % [ Time step for interpolation ]
data.upscal         = upscal;               % [ Upper boundary conditions for param ]
data.lowscal        = lowscal;              % [ Lower boundary conditions for param ]

% Run fminsearch on cost function
fprintf('Beginning particle swarm optimization...\n')
[ PSO_results ] = pso_fsn_start(data, IC_data, n_particles, n_iterations);
fprintf('\nSaving results and creating graphs.\n')


%% DISPLAY AND SAVE RESULTS 

fig = figure(1);
% Save convergence graph
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\PSOconvergence.fig'))

% Create variable to save cost calculation parameters for the hip, knee,
% and ankle
risetime_simact             = zeros(length(muscles),2);
omega_simact_zeta_simact    = zeros(length(muscles),4);
avgdiffdeg                  = zeros(length(muscles),1);

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
    param = [ w0s  PSO_results.gbest(1) PSO_results.gbest(3) PSO_results.gbest(5) PSO_results.gbest(2) PSO_results.gbest(4) PSO_results.gbest(6) 0 0 0];

    % Run ODE
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, time, thetas, thetabias_sym);

    % Calculate risetime.
    risetime_x      = risetime_ek(thetas_ode(:,1), time_ode);
    risetime_thetas = risetime_ek(thetas(:,1), time);
    
    % Save data into array
    risetime_simact(m, :) = [risetime_x risetime_thetas];
    
    
        % Calculate damping ratio land natural frequency
    % Find peaks and location of sim response and actual response for knee
    [pks_x, loc_x]              = findpeaks(thetas_ode(:,3)); [pks_xneg, loc_xneg] = findpeaks(-thetas_ode(:,3));    
    [pks_thetas, loc_thetas]    = findpeaks(thetas(:,2)); [pks_thetasneg, loc_thetasneg] = findpeaks(-thetas(:,2));

    % Consolidate into single array
    pks_x       = abs([pks_x' pks_xneg']); loc_x = [loc_x' loc_xneg'];
    pks_thetas  = abs([pks_thetas' pks_thetasneg']); loc_thetas = [loc_thetas' loc_thetasneg'];

    % Define peaks based on offset from steady state value
    SteadyStateX        = thetas_ode(end,3);
    SteadyStateThetas   = thetas(end,2);
    pks_x               = abs(pks_x - SteadyStateX);
    pks_thetas          = abs(pks_thetas - SteadyStateThetas);

    % sort positive and negative peaks into singular array
    [pks_x, I_x] = sort(pks_x, 'descend'); loc_x = loc_x(I_x);
    [pks_thetas, I_thetas] = sort(pks_thetas, 'descend'); loc_thetas = loc_thetas(I_thetas);   

    % Calculate log dec and damping ratio
    logdec_x        = log(pks_x(1) / pks_x(2));
    logdec_thetas   = log(pks_thetas(1) / pks_thetas(2));
    zeta_x          = ( logdec_x / (2*pi) ) / sqrt( 1 + (logdec_x / (2*pi))^2);
    zeta_thetas     = ( logdec_thetas / (2*pi) ) / sqrt( 1 + (logdec_thetas / (2*pi))^2);

    % Calculate frequency
    omega_x         = abs(2 * 0.001 * (loc_x(1) - loc_x(2))) ^-1;
    omega_thetas    = abs(2 * 0.001 * (loc_thetas(1) - loc_thetas(2))) ^-1;

    % Save data into array
    omega_simact_zeta_simact(m, :) = [omega_x omega_thetas zeta_x zeta_thetas];

    
    % Calculating error in individual points for ankle cost
    avgdiff         = sum( abs( thetas_ode(:,5) - thetas(:,3) ) ) / length(thetas);
    avgdiffdeg(m)   = rad2deg(avgdiff);
    
    
    
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

legend('Hip response', 'Optimized hip response', 'Knee response', 'Simulated knee response from opt', 'Ankle response', 'Simulated ankle response')
    
% save results - optimized parameters and figure
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsPSOResults.mat'), 'PSO_results', 'thetabias_val', 'risetime_simact', 'omega_simact_zeta_simact', 'avgdiffdeg')
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\AllTrialsPSOresults.fig'))
fprintf('Data saved.\n')



