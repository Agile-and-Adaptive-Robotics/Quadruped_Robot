%% Parameter optimization for dog leg

% Optimizing repsonse k value of each robot joint only based on gathered
% response data.

clear; clc; close('all');

% Add paths needed for loading data and using functions
addpath('C:\Users\Haonan\Documents\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Optimizer functions and data')
addpath('C:\Users\Haonan\Documents\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Parameter optimization\Results')

% Create folder to save results to and add file path
% folder_title = 'Robot_springdamping_calcs';
% mkdir(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title))
% addpath(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title)) 
% clc

%% Load and format data to be used

% Choose mechanical system to optimize
sysName = 'MechPropDog2';
sysProp = load('-mat', sysName);

% Load the data file for all joint data
DampData = load('-mat', 'SpringDampData');

% Load solved b values
Bresults = load('-mat', 'C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\Robot_damping_calcs\Results.mat');
b_vals = Bresults.b_sols;

% Set start time step
time_step = 0.001;                                                  % [ s ]

%% Set optimization specifications (IC, BC, options)

% Set initial conditions based on expected spring values
IC_data = [79 2.2922 1];

% Set options for the search function
options = optimset('PlotFcns','optimplotfval', 'MaxIter', 500);

% Set search boundary conditions based on a scalar multiple of inital guess
scalar_b = 5;

UB = scalar_b .* IC_data;
LB = IC_data ./ scalar_b;

% Set high damping constants to be used to hold joints steady
set_var = [1000 1000 1000];

%% Load EOM

% Define equations of motion from saved EOM file
load('EOM.mat')
fprintf('\nEOM loaded.\n')

% Compile EOM into single variable
dui = [du1, du2, du3, du4, du5, du6];



%% OPTIMIZATION 

% Compile non-optimized variables into single structure
data.dui        = dui;
data.DampData   = DampData;
data.set_var    = set_var;
data.time_step  = time_step;
data.sysProp    = sysProp;
data.b_vals     = b_vals;

% Run fminsearch on cost function for all three joints
k_sols = [ 0 0 0 ];

for n = 1:1
    
m = 4-n;
fprintf('Running optimization for hip...\n')
[k_sol,fval1,exitflag,output] = fminsearchbnd(@(U) cost_calc_springdamp(U, data, m),IC_data(m),LB(m),UB(m),options);
fprintf('Optimization for hip finished.\n\n')

k_sols(n) = k_sol;

end

%% DISPLAY RESULTS 

% Run ODE with achieved parameters and save results, only for one trial per
% joint 
fprintf('\nParameter optimization achieved. Producing results.\n')

% Produce figure
fig = figure( 'Color', 'w');
    
% Create array of b values to use
b = [b_vals(1) set_var(2) set_var(3); set_var(1) b_vals(2) set_var(3); set_var(1) set_var(2) b_vals(3)];

% Define time
time = DampData.time;

% Define universal constants.
g_value = 9.81;                             % [m/s^2]

% State symbolic variables used in EOM solver
syms M1 M2 M3;
syms theta1rest theta2rest theta3rest;
syms theta1(t) dtheta1(t) ddtheta1(t) theta2(t) dtheta2(t) ddtheta2(t) theta3(t) dtheta3(t) ddtheta3(t);
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms mu1 mu2 mu3;
syms k1 k2 k3;
syms I1 I2 I3;
syms g;
syms a1 a2 a3 w1 w2 w3;
syms u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6;
syms tau1 tau2 tau3

% No friction
mu1_value = 0;
mu2_value = 0;
mu3_value = 0;

m1_value = data.sysProp.m1_value; m2_value = data.sysProp.m2_value; m3_value = data.sysProp.m3_value;
R1_value = data.sysProp.R1_value; R2_value = data.sysProp.R2_value; R3_value = data.sysProp.R3_value;
L1_value = data.sysProp.L1_value; L2_value = data.sysProp.L2_value; L3_value = data.sysProp.L3_value;

% Define x limits for each trial
lim = [0 2; 0 2; 0 1];

for n = 3:3
    
    b1_value = b(n,1);
    b2_value = b(n,2);
    b3_value = b(n,3);
    
    if n == 1
        thetas = DampData.hip_dat; 
        time = DampData.time.hip;
    elseif n == 2
        thetas = DampData.knee_dat; 
        time = DampData.time.knee;
    else
        thetas = DampData.ankle_dat;
        time = DampData.time.ankle;
    end
    
    %CHANGE MEEEEE
    k1_value = 0.001;
    k2_value = 0.001;
    k3_value = k_sol;

    % Assign equations of motion
    du1 = dui(1); 
    du2 = dui(2); 
    du3 = dui(3); 
    du4 = dui(4); 
    du5 = dui(5); 
    du6 = dui(6);

    % Define thetarest values
    theta1rest_value = thetas(end,((n-1)*3 +1));
    theta2rest_value = thetas(end,((n-1)*3 +2));
    theta3rest_value = thetas(end,((n-1)*3 +3));
    
    % Substitute numerical values into the dynamical system flow.
    du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
    du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
    du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
    du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
    du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
    du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );

    % Create anonymous functions from the dynamical system flow components.
    fdu1_temp = matlabFunction( du1_value ); fdu1 = @( t, u, tau ) fdu1_temp( u(2) );
    fdu2_temp = matlabFunction( du2_value ); fdu2 = @( t, u, tau ) fdu2_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
    fdu3_temp = matlabFunction( du3_value ); fdu3 = @( t, u, tau ) fdu3_temp( u(4) );
    fdu4_temp = matlabFunction( du4_value ); fdu4 = @( t, u, tau ) fdu4_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
    fdu5_temp = matlabFunction( du5_value ); fdu5 = @( t, u, tau ) fdu5_temp( u(6) );
    fdu6_temp = matlabFunction( du6_value ); fdu6 = @( t, u, tau ) fdu6_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
    fdu = @( t, u, tau ) [ fdu1( t, u, tau ); fdu2( t, u, tau ); fdu3( t, u, tau ); fdu4( t, u, tau ); fdu5( t, u, tau ); fdu6( t, u, tau ) ];

    % Define the applied torques.
    taus = zeros( 3, 1 );

    % Define the initial joint angles.
    theta0s = [thetas(1,1), thetas(1,2), thetas(1,3)];
    
    % Calculate initial joint angular velocity
    w0s = zeros(3, 1);
   
    % Assemble the state variable initial condition.
    u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ) ];

    % Simulate the triple pendulum dynamics.
    [ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), time, u0s );


    subplot(2,3,n)
    plot(time, rad2deg(thetas( :,n )), ':b', 'LineWidth', 1); hold on
    plot(t, rad2deg(x( :,(n*2-1) )), '-r', 'LineWidth', 1)
    title(sprintf('Damped %s response', joints(n)))
    xlabel('Time(s)'); ylabel('Joint angle (deg)')
    xlim(lim(n,:))
    ylim([0 185])
    
    % Create scaled plot
    x_scale = x( :,(n*2-1) ); x_scale = x_scale - x_scale(1); x_scale = x_scale/x_scale(end);
    thetas_scale = thetas(:,n); thetas_scale = thetas_scale - thetas_scale(1); thetas_scale = thetas_scale/thetas_scale(end);
    
    subplot(2, 3, n+3)
    plot(time, thetas_scale, ':b', 'LineWidth', 1); hold on
    plot(t, x_scale, '-r', 'LineWidth', 1)
    title(sprintf('Damped scaled %s response', joints(n)))
    xlabel('Time(s)'); ylabel('Scaled response')
    xlim(lim(n,:))
    ylim([0 1.2])
end
legend('Actual response', 'ODE response')
%% Save results

% save results - optimized parameters and figure
save(strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\Results.mat'), 'b1', 'b2', 'b3', 'rt_ode', 'rt_data')
saveas(fig, strcat('C:\Users\krnac\OneDrive\Desktop\School\Dynamic leg\Krnacik\Parameter optimization\Results\', folder_title, '\Results.fig'))
fprintf('Data saved.\n')



