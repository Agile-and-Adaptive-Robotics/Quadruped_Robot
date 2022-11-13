%% Knee damping and frequency calculations

% this script is intended to calculate the estimated damping ratio and
% frequency of the rat knee responses, as it was calculated incorrectly
% (but was fine for optimizer) in D1 and rat optimization. Also updated to
% save settling time for ankle.

clear; clc;

% Add paths needed for loading data and using functions
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')

%% Load data

% Load the data file for all joint data
load('-mat', 'jdata');

% Load start and end indices
load('-mat', 'start_indices')
load('-mat', 'end_indices')

% Define muscles and trials, respectively, to optimize to (chosen by me)
muscles = [1 2 3 4 5 6 7];
trials = [5 1 1 1 1 1 1];

% Set start time step
time_step = 0.001;  

% Iniate array to save calculated values in
omegas          = zeros(length(muscles), 1);
zetas           = zeros(length(muscles), 1);
settling_time   = zeros(length(muscles), 1);
risetime        = zeros(length(muscles), 1);

for n = 1:length(muscles)

    % Choose muscle and trial, and starting index value (check figure from
    % "plotjdat" in RawDataPlottingProcessing folder. All starting values
    % have been manually chosen and saved to "start_indices" data file.
    muscle      = muscles(n);
    trial       = trials(n);
    start_index = start_indices(muscle, trial);
    end_index   = end_indices(muscle, trial);

    % From chosen muscle and trial extract joint angles and time data. Note that
    % first cell of jdata corresponds to theta values, the second corresponds
    % to time values, and the third corresponds to "force" values.
    time = jdata{2}{muscle, trial}(start_index:end_index);                      % [s]
    time = time - time(1);
    thetas = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;  % [rad]

    % Interpolate the data using spline method                                    
    thetas = interp1(time, thetas, 0:time_step:time(end), 'spline');
    time = 0:time_step:time(end);

    % Define thetarest values
    theta1rest_value = thetas(end,1);
    theta2rest_value = thetas(end,2);
    theta3rest_value = thetas(end,3);


    
    % KNEE PARAMETERS

    % Find peaks and location ofactual response for knee
    [pks_thetas, loc_thetas] = findpeaks(thetas(:,2)); [pks_thetasneg, loc_thetasneg] = findpeaks(-thetas(:,2));

    % Consolidate into single array
    pks_thetas = abs([pks_thetas' pks_thetasneg']); loc_thetas = [loc_thetas' loc_thetasneg'];

    % Define peaks based on offset from steady state value
    SteadyStateThetas = thetas(end,2);
    pks_thetas = abs(pks_thetas - SteadyStateThetas);

    % sort positive and negative peaks into singular array
    [pks_thetas, I_thetas] = sort(pks_thetas, 'descend'); loc_thetas = loc_thetas(I_thetas);   

    % Calculate log dec and damping ratio
    logdec_thetas = log(pks_thetas(1) / pks_thetas(3));
    zeta = ( logdec_thetas / (2*pi) ) / sqrt( 1 + (logdec_thetas / (2*pi))^2);

    % Calculate frequency
    omega = (abs(2 * 0.001 * (loc_thetas(1) - loc_thetas(2))) ^-1) * 2 * pi;        % [rad/s]

    % Save data into array
    omegas(n) = omega;
    zetas(n) = zeta;
    
    
    
    % ANKLE PARAMETERS
    settling_time(n) = settime(time, thetas(:,3));
    
    
    % HIP PARAMETERS
    risetime = risetime_ek(thetas(:,1), time);
    
    
    
end

save('jointdyn.mat', 'omegas', 'zetas', 'settling_time', 'risetime')
