%% Dynamics check
% Used to check if parameters for optmization are a good inital condition
% Much of this has been copied from optimization code, but the optimizer
% itself is not run

clear, clc;
addpath('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Optimizer functions and data')

% Define what system properties to use
systemProp = 'MechPropDog2';

% Ask user if data (parameters and graph) should be saved. If yes, save
% parameters used and resulting graph

%save_dat = input('Do you want to save the parameters used and resulting graph? (y/n) ', 's');
save_dat = 'n';

%% Set parameters

% Set initial joint velocities, b, k, and u values
dthetas_i = [0, 0, 0];
b_i = [1.29, 0.0725, 0.0277];
k_i = [23.67, 2.2922, 0.4646];
u_i = [0, 0, 0];

% Compile parameters to be optimized into a single variable 
U = [dthetas_i, b_i, k_i, u_i];

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
    error('ERROR: Unsuitable trial was selected')
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
time = time * 2;

% Determine resting theta values from end of data set
thetairest(1) = thetas(end, 1);
thetairest(2) = thetas(end, 2);
thetairest(3) = thetas(end, 3);

%% Define symbolic equations of motion from saved EOM file

load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];

%% Run ODE
time_ode = 0:0.001:1;

fprintf('\nRunning ODE...\n')
[ time_ode, thetas_ode, thetabias_val ] = dynamics_func(U, dui, time_ode, thetas, thetabias_sym, systemProp);


%% Comparing joint angles from actual and theoretical values

fprintf('\nODE completed, print graphed responses.\n')
fig = figure( 'Color', 'w');

% Create plot of hip angles
subplot(1,3,1)
plot(time, rad2deg(thetas(:,1)), '--k'); hold on
plot(time_ode, rad2deg(thetas_ode(:,1)), '-k')
legend('Experimental data', 'ODE results')
title('Experimental vs optimized responses - Hip joint')
xlabel('Time (s)')
ylabel('Joint angles (deg)')
ylim([80 180])
xlim([0 0.8])

% Create plot of knee angles
subplot(1,3,2)
plot(time, rad2deg(thetas(:,2)), '--r'); hold on
plot(time_ode, rad2deg(thetas_ode(:,3)), '-r')
legend('Experimental data', 'ODE results')
title('Experimental vs optimized responses - Knee joint')
xlabel('Time (s)')
ylabel('Joint angles (deg)')
ylim([80 180])
xlim([0 0.8])

% Create plot of ankle angles
subplot(1,3,3)
plot(time, rad2deg(thetas(:,3)), '--b'); hold on
plot(time_ode, rad2deg(thetas_ode(:,5)), '-b')
legend('Experimental data', 'ODE results')
title('Experimental vs optimized responses - Ankle joint')
xlabel('Time (s)')
ylabel('Joint angles (deg)')
ylim([80 180])
xlim([0 0.8])

fprintf('\nCalculated thetabiases:\n')
disp(rad2deg(thetabias_val))

% %% Calculate joint dynamic parameters
% 
% % Calculate the risetime for simulation and actual data. 
% risetime_sim = risetime_ek(thetas_ode(:,1), time);
% 
% 
% % Calculate knee frequency and damping
% 
% % Find peaks and location of sim response and actual response for knee
% [pks_x, loc_x] = findpeaks(thetas_ode(:,3)); [pks_xneg, loc_xneg] = (findpeaks(-thetas_ode(:,3)));   
% 
% % Consolidate into single array
% pks_x = abs([pks_x' pks_xneg']); loc_x = [loc_x' loc_xneg'];
% 
% % Define peaks based on offset from steady state value
% SteadyStateX = thetas_ode(end,3);
% pks_x = abs(pks_x - SteadyStateX);
% 
% % sort positive and negative peaks into singular array
% [pks_x, I_x] = sort(pks_x, 'descend'); loc_x = loc_x(I_x);
% 
% % Calculate log dec and damping ratio
% logdec_x = log(pks_x(1) / pks_x(3));
% zeta_x = ( logdec_x / (2*pi) ) / sqrt( 1 + (logdec_x / (2*pi))^2);
% 
% % Calculate frequency
% omega_x = 2 * pi * abs(2 * 0.001 * (loc_x(1) - loc_x(2))) ^-1;
% 
% omega_sim    = omega_x;
% zeta_sim     = zeta_x;
% 
% 
% % Calculate ankle settling time
% settlingtime_sim = settime(time_ode,thetas_ode(:,5));
% 
% fprintf('\nSimulated risetime: %.3f', risetime_sim)
% fprintf('\nSimulated omega: %.3f', omega_sim)
% fprintf('\nSimulated zeta: %.3f', zeta_sim)
% fprintf('\nSimulated settling time: %.3f', settlingtime_sim)

%% Save data

if save_dat == 'y'
    
    save('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check\HandOPTD3R2_IC.mat', 'dthetas_i', 'b_i', 'k_i', 'u_i')
    saveas(fig, 'C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\IC_check\HandOPTD3R2_IC')
    
    fprintf('\nParameters and graph saved.\n')

elseif save_dat == 'n'
    
    fprintf('\nData not saved.\n')
    
else 
        
    error('ERROR: Please select either y or n')
        
end
