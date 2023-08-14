%% Parameter optimization for rat leg

% Optimizing response for k value of knee given solved damper values

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\IC_check')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer_scripts\ParticleSwarmOpt')

% Create folder to save results to and add file path
% folder_title = 'Robot_spring_calcs';
% mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
% addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 
% clc

%% Load and format data to be used

% Choose mechanical system to optimize
sysName = 'MechPropBigRat';
sysProp = load('-mat', sysName);

% Load calculated dynamic properties of each joint
jdataProp = load('-mat', 'jointdyn3');

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

% Set IC from original optimization
k_i = 1.71;
IC = k_i;

% Set search boundary conditions based on a scalar multiple of inital guess
scalar = 5;
UB = k_i * scalar;
LB = k_i / scalar;

% Define parameters to be set (from D3 opt)
hip_var = [1.29 23.67];
ankle_var = [0.0277 0.4538];
knee_var = 0.0725;


%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];



%% KNEE OPTIMIZATION

% Compile non-optimized variables into single structure
data.dui            = dui;
data.jdata          = jdata;
data.thetabias_sym  = thetabias_sym;
data.hip_var        = hip_var; data.knee_var = knee_var; data.ankle_var = ankle_var;
data.muscles        = muscles;
data.trials         = trials;
data.start_indices  = start_indices;
data.end_indices    = end_indices;
data.time_step      = time_step;
data.sysProp        = sysProp;
data.jdataProp      = jdataProp;            % Dynamic properties for system

% Set options for the search function
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 500);

% Run fminsearch on cost function on the knee
fprintf('Running optimization for knee...\n')
[k_2,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func_knee_spring(U, data),IC,LB,UB,options);
fprintf('Knee optimization finished.\n\n')

%% ANKLE OPTIMIZATION

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

% Set IC from original optimization
k_i = 0.4538;
IC = k_i;

% Set search boundary conditions based on a scalar multiple of inital guess
scalar = 5;
UB = k_i * scalar;
LB = k_i / scalar;

% Define parameters to be set (from D3 opt)
hip_var = [1.29 23.67];
ankle_var = 0.0277;
knee_var = [0.0725 k_2];

data.hip_var        = hip_var; data.knee_var = knee_var; data.ankle_var = ankle_var;
data.muscles        = muscles;
data.trials         = trials;

fprintf('Running optimization for ankle...\n')
[k_3,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func_ankle_spring(U, data),IC,LB,UB,options);
fprintf('Ankle optimization finished.\n\n')



%% HIP OPTIMIZATION

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [ 1 2 3 6 ];
trials = [ 5 1 1 1 ];

% Define muscle names
muscle_names = {'IP', 'GS', 'ST', 'BFp'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

% Set IC from original optimization
k_i = 23.7;
IC = k_i;

% Set search boundary conditions based on a scalar multiple of inital guess
scalar = 5;
UB = k_i * scalar;
LB = k_i / scalar;

% Define parameters to be set (from D3 opt)
hip_var = 4.1056;
ankle_var = [0.0277 k_3];
knee_var = [0.0725 k_2];

data.hip_var        = hip_var; data.knee_var = knee_var; data.ankle_var = ankle_var;
data.muscles        = muscles;
data.trials         = trials;

fprintf('Running optimization for hip...\n')
[k_1,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func_hip_spring(U, data),IC,LB,UB,options);
fprintf('Hip optimization finished.\n\n')


%% DISPLAY AND SAVE RESULTS 

% Run ODE with achieved parameters and save results, run with friction
% set to zero 
fprintf('\nParameter optimization achieved. Producing results.\n')

% Create variable to save damping ratio and frequency
omega_simact_zeta_simact = zeros(length(muscles),4);

% Produce figure
fig = figure( 'Color', 'w');
   
% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [1 2 3 4 5 6 7];
trials  = [5 1 1 1 1 1 1];

% Define which trials for each joint to place higher value on. Rows
% correspond to hip, knee, and ankle, and columns refer to each trial, 1
% indicating a higher value should be placed
trial_value = 5 *  [1 1 1 0 0 1 0; ...
                    1 0 1 1 0 1 0; ...
                    1 0 1 0 0 1 0]';
                
trial_value(trial_value==0) = 1;

% Define muscle names
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

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
    param = [ w0s hip_var(1) knee_var(1) ankle_var(1) k_1 k_2 k_3 0 0 0];

    % Run ODE
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func(param, dui, time, thetas, thetabias_sym, sysName);

    %% Calculate knee frequency and damping

        % Find peaks and location of sim response and actual response for knee
        [pks_x, loc_x] = findpeaks(thetas_ode(:,3)); [pks_xneg, loc_xneg] = (findpeaks(-thetas_ode(:,3)));   

        % Consolidate into single array
        pks_x = abs([pks_x' pks_xneg']); loc_x = [loc_x' loc_xneg'];

        % Define peaks based on offset from steady state value
        SteadyStateX = thetas_ode(end,3);
        pks_x = abs(pks_x - SteadyStateX);

        % sort positive and negative peaks into singular array
        [pks_x, I_x] = sort(pks_x, 'descend'); loc_x = loc_x(I_x);
        
        if length(pks_x) > 2
            
            % Calculate log dec and damping ratio
            logdec_x = log(pks_x(1) / pks_x(3));
            zeta_x = ( logdec_x / (2*pi) ) / sqrt( 1 + (logdec_x / (2*pi))^2);

            % Calculate frequency
            omega_x = 2* pi * (0.002 * (loc_x(3) - loc_x(1)))^-1;
        
           % Adding variables to cost function for knee
            [pks_thetas, locs_thetas] = findpeaks(thetas(:,2));
            pk_diff(m) = abs(pks_thetas(1) - pks_x(1));
            locs_diff(m) = abs(locs_thetas(1) - loc_x(1));
        else
            % if system is over/criticlly damped, assign arbitrarily low
            % omega_x and high zeta
            omega_x = 0.1;
            zeta_x = 300;
            locs_diff(m) = 300;
            pk_diff(n) = 300;
        end
        
        % Save data into array
        omega_sim(m)    = omega_x;
        zeta_sim(m)     = zeta_x;
         
        
        %% Calculate ankle average joint angle difference
        JAdiff_sim(m) = sum(( thetas_ode(:,5) - thetas(:,3) ) .^2);
    
    
%% Plot results
    % Create plot of simulated vs optimized response
    subplot(2,4,m); hold on
    
    % Plot hip angles
    plot(time, rad2deg(thetas(:,1)), '--k'); plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
    
    % Plot knee angles
    plot(time, rad2deg(thetas(:,2)), '--r'); plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
    
    % Plot ankle angles
    plot(time, rad2deg(thetas(:,3)), '--b'); plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
    
    % Graph set-up
    title(sprintf('%s Re-optimized for springs', data_title{m}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])
   

end
legend('Hip response', 'Simulated hip response', 'Knee response', 'Optimized knee response', 'Ankle response', 'Simulated ankle response')
    
% save results - optimized parameters and figure
% save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\SpringOpt.mat'), 'k_1', 'k_2','k_3','thetas_ode', 'thetas', 'time', 'thetabias_val', 'omega_simact_zeta_simact')
% saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\SpringOpt.fig'))
% fprintf('Data saved.\n')

