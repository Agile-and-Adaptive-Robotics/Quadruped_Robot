%% Simple Pendulum Controller

% This script creates a state space controller for a linearized simple pendulum and evalutes the performance of this controller on the full nonlinear pendulum model.

% Clear Everything.
clear, close('all'), clc

%% Define the Dynamics of the Open Loop Linear & Nonlinear Pendulum Models.

% Define the pendulum parameters.
m = 1;
L = 1;
g = 9.81;
c = 1;
ktau = 1;
kmotor = 1;

% Define the nonlinear simple pendulum dynamics.
f1_ol = @(t, x, u) x(2);
f2_ol = @(t, x, u) (-ktau./(m*(L.^2))).*x(1) + (-g./L).*sin(x(1)) + (-c./(m.*(L.^2))).*x(2) + (kmotor./(m*(L.^2)))*u;
f_ol = @(t, x, u) [f1_ol(t, x, u); f2_ol(t, x, u)];

% % Linearize the simple pendulum dynamics about the bottom.
% A = [0 1; -((m.*g.*L + ktau)./(m.*(L.^2))) -(c./(m.*(L.^2)))]; B = [0; ktau./(m.*(L.^2))]; C = [1 0]; D = 0;

% Linearize the simple pendulum dynamics about the top.
A = [0 1; ((m.*g.*L - ktau)./(m.*(L.^2))) -(c./(m.*(L.^2)))]; B = [0; ktau./(m.*(L.^2))]; C = [1 0]; D = 0;

% Define the open loop linearized simple pendulum model.
sys_pen_lin_ol = ss(A, B, C, D);


%% Design a Continuous State Space Controller with an Outer-Loop Integrator (Assuming Full State Feedback) to Balance the Pendulum.

% Define the desired response characteristics.
PMO = 0;
tsettle = 1;

% Compute the necessary 2nd system parameters that acheive these response characteristics.
zeta = PMO2zeta( PMO );
omegan = SettlingTime2omegan( tsettle, zeta );

% Compute the leading design point that satifies the desired response characteristics.
s = GetsDesignPoints( omegan, zeta );

% Compute the desired roots of the closed loop system that satisfy the desired response charactersitics.
ps = [s 10*s 11*s];

% Design a state-space controller with an outer-loop integrator (assuming full state feedback).
[ sys_pen_lin_cl, K ] = GetSSIController( sys_pen_lin_ol, ps );


%% Define the Dynamics of the Closed Loop Nonlinear Pendulum.

% Define the dynamics of the closed loop nonlinear pendulum.
% f1_cl = @(t, x, u) x(2);
% f2_cl = @(t, x, u) -((ktau + kmotor.*K(1))./(m.*(L.^2))).*x(1) - ((c + kmotor.*K(2))./(m.*(L.^2))).*x(2) + ((kmotor.*K(3))./(m.*(L.^2))).*x(3) - (g./L).*sin(x(1));
% f3_cl = @(t, x, u) -x(1) + u;
% f_cl = @(t, x, u) [f1_cl(t, x, u); f2_cl(t, x, u); f3_cl(t, x, u)];

f_cl = @(t, x, u) [0 1 0; -((ktau + kmotor.*K(1))./(m.*(L.^2))) -((c + kmotor.*K(2))./(m.*(L.^2))) (kmotor.*K(3)./(m.*(L.^2))); -1 0 0]*x + [0; 0; 1]*u + [0; -(g./L); 0]*sin(x(1));

% Kp = 30;
% f_cl = @(t, x, u) [0 1; -(ktau + kmotor.*Kp)./(m.*(L.^2)) -(c./(m.*(L.^2)))]*x + [0; ((kmotor.*Kp)./(m.*(L.^2)))].*u + [0; -(g./L)].*sin(x(1));


%% Simulate the Open Loop & Closed Loop Linear & Nonlinear Pendulum Response.

% Set the system inputs for the closed loop linear & nonlinear pendulums.
u_lin = 0;
u_nlin = pi;

% Set the simulation duration.
Tfinal = 1;

% Set the simulation initial condition.
% x0_ol = [-(pi/180)*10; 0];
% x0_cl = [x0_ol; 0.01];

x0_ol = [-(pi/180)*10; 0];
x0_lin_cl = [x0_ol; 0];
x0_nlin_cl = [x0_ol; 0.8];

% Simulate the open loop & closed loop linear pendulum systems.
[ys_lin_ol, ts_lin_ol, xs_lin_ol] = initial(sys_pen_lin_ol, x0_ol, Tfinal);
[ys_lin_cl, ts_lin_cl, xs_lin_cl] = initial(sys_pen_lin_cl, x0_lin_cl, Tfinal);

% Simulate the nonlinear open loop linear pendulum system.
[ts_nlin_ol, ys_nlin_ol] = ode45(@(t, x) f_ol(t, x, u_lin), [0 10], [pi + x0_ol(1); x0_ol(2)]);
[ts_nlin_cl, ys_nlin_cl] = ode45(@(t, x) f_cl(t, x, u_nlin), [0 1], [pi + x0_nlin_cl(1); x0_nlin_cl(2); x0_nlin_cl(3)]);

% [ts_nlin_cl, ys_nlin_cl] = ode45(@(t, x) f_cl(t, x, u_nlin), [0 10], [pi + x0_nlin_cl(1); x0_nlin_cl(2)]);


%% Plot the Open Loop & Closed Loop Linear & Nonlinear Pendulum Response.

% Plot the open loop & closed loop linear system response.
figure('Color', 'w'), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Linear Pendulum: Angle vs Time')
plot(ts_lin_ol, (180/pi)*(ys_lin_ol + pi), 'Linewidth', 3)
plot(ts_lin_cl, (180/pi)*(ys_lin_cl + pi), 'Linewidth', 3)
legend({'Open Loop', 'Closed Loop'})

% % Plot the closed loop linear system response.
% figure('Color', 'w'), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Linear Pendulum: Angle vs Time')
% plot(ts_lin_cl, (180/pi)*ys_lin_cl, 'Linewidth', 3)

% Plot the open loop nonlinear system response.
figure('Color', 'w'), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Nonlinear Pendulum: Angle vs Time')
plot(ts_nlin_ol, (180/pi)*ys_nlin_ol(:, 1), 'Linewidth', 3)


% Plot the closed loop linear system response.
figure('Color', 'w'), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Nonlinear Pendulum: Angle vs Time')
plot(ts_nlin_cl, (180/pi)*ys_nlin_cl(:, 1), 'Linewidth', 3)



