%% Parameter optimization for rat leg

% Optimizing repsonse for b, k , u, and x0 values. Cycle through one trial
% of each muscle stimulation

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check')
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results')

% Create folder to save results to and add file path
folder_title = 'TrialCyclingResults3';
mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 


%% Load and format data to be used
% Define time period to optimize to
points = [0 0.2];                                                   % [ s ]

% Load the data file for all joint data
load('-mat', 'jdata');

% Load start and end indices
load('-mat', 'start_indices')
load('-mat', 'end_indices')

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = 1:7;
trials = [5 1 1 1 1 1 1];

% Define muscle names
muscle_names = {'IP', 'GS', 'ST', 'ST2', 'VL', 'BFp', 'BFa'};
data_title = cell(1,length(muscles));

% Create data titles
for n_i = 1:length(muscles)
   data_title(n_i) = strcat('Muscle', muscle_names(n_i), 'OPT');
end

% Set start and end points for optimizer ("points") variable to indicies
% instead of time
time_step = 0.001;                                                  % [ s ]
if points(1) == 0
    points(1) = 1;
    points(2) = points(2) / time_step;
else
    points = points / time_step;
end


%% Set optimization specifications (IC, BC, options)

% Load starting conditions from hand optimized trials isolating the hip and
% the knee/ankle.
IC_data_hip = load('-mat', 'HandOPThip_IC');
IC_data_kneeankle = load('-mat', 'HandOPTknee_IC');

% Set initial conditions for the knee and ankle from that respective trial,
% and the same for the hip. Setting inital velocity to zero.
dthetas_i = [0 0 0];
b_i = [IC_data_hip.b_i(1) IC_data_kneeankle.b_i(2:3)];
k_i = [IC_data_hip.k_i(1) IC_data_kneeankle.k_i(2:3)];
IC_data = [dthetas_i b_i k_i];
U = IC_data;

% Set options for the search function
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 500);

% Set search boundary conditions based on a scalar multiple of inital guess
dthetas_bc = [ pi pi pi; -pi -pi -pi ];

scalar_b = [ 3, 1.2, 1.5 ];
scalar_k = [ 3, 1.2, 2 ];

b_bc = [ scalar_b .* b_i; b_i ./ scalar_b ];
k_bc = [ scalar_k .* k_i; k_i ./ scalar_k ];
    
UB = [ dthetas_bc(1,:) b_bc(1, :) k_bc(1, :) ];
LB = [ dthetas_bc(2,:) b_bc(2, :) k_bc(2, :) ];



%% Optimizer iteration through each trial

for n = 1:length(muscles)
    
    % SET-UP DATA TO BE RUN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Print statement about 
    fprintf('Starting %s analysis...', data_title{n})
    
    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle = muscles(n);
    trial = trials(n);
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

    % Determine resting theta values from end of data set
    thetairest(1) = thetas(end, 1);
    thetairest(2) = thetas(end, 2);
    thetairest(3) = thetas(end, 3);

    
    
    % SOLVE EOM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Define equations of motion from EOM OR from saved EOM %%%%%%%%%%
    fprintf('\nSolving EOM...\n')
    [du1, du2, du3, du4, du5, du6, thetabias_sym] = EOM_solver_func(thetairest);
    fprintf('EOM solved.\n')

    % Compile EOM into single variable
    dui = [du1, du2, du3, du4, du5, du6];



    % OPTIMIZATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Run fminsearch on cost function
    fprintf('Running optimization...\n')
    [param_opt_results,fval,exitflag,output] = fminsearchbnd(@(U) cost_calc_func(U, dui, time, thetas, points, thetabias_sym),U,LB,UB,options);
    fprintf('Optimization finished.\n')

    
    
    % DISPLAY AND SAVE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Run ODE with achieved parameters and save results, run with friction
    % set to zero 
    fprintf('\nParameter optimization achieved. Producing results.\n')
    [ time_ode, thetas_ode, thetabias_val ] = dynamics_func([param_opt_results 0 0 0], dui, time, thetas, thetabias_sym);

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
    title(sprintf('%s - Hip joint', data_title{n}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])

    % Create plot of knee angles
    subplot(1,3,2)
    plot(time, rad2deg(thetas(:,2)), '--r'); hold on
    plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
    plot( optline1(1, :), optline1(2,:), '.g'); plot( optline2(1, :), optline1(2,:), '.g')
    legend('Experimental data', 'ODE results', 'Optimization end point')
    title(sprintf('%s - Knee joint', data_title{n}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])

    % Create plot of ankle angles
    subplot(1,3,3)
    plot(time, rad2deg(thetas(:,3)), '--b'); hold on
    plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
    plot( optline1(1, :), optline1(2,:), '.g'); plot( optline2(1, :), optline1(2,:), '.g')
    legend('Experimental data', 'ODE results', 'Optimization end point')
    title(sprintf('%s - Ankle joint', data_title{n}))
    xlabel('Time (s)')
    ylabel('Joint angles (deg)')
    xlim([0 0.4])
    ylim([60 180])

    % Calculate average difference at each time point
    avg_dif = rad2deg(sqrt(fval / 3 * (points(2) - points(1))));          % [ deg ]

    % save results - optimized parameters and figure
    save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\', data_title{n}, '.mat'), 'param_opt_results', 'avg_dif', 'thetas_ode', 'thetas', 'time', 'thetabias_val', 'IC_data')
    saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\', data_title{n}, '.fig'))
    fprintf('Data saved.\n')
    
end



