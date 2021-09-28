%% Pendulum on Chart Controller

% This script simulates a controlled pendulum on a chart.

% Clear Everything.
clear, close('all'), clc

%% Scratch Paper

% Define the symbolic variables.
syms x1 x2 x3 x4 xdot1 xdot2 xdot3 xdot4 m1 m2 c1 c2 k1 k2 L F g

% Define the two equations of motion
eq1 = (m1 + m2)*xdot2 + c1*x2 + k1*x1 + (1/2)*m2*L*(x4^2)*sin(x3) - (1/2)*m2*L*cos(x3)*xdot4 == F;
eq2 = (7/12)*m2*(L^2)*xdot4 + c2*x4 + k2*x3 - (1/2)*m2*g*L*sin(x3) - (1/2)*m2*L*cos(x3)*xdot2 == 0;

% Put the system of ODEs into the standard form.
sol = solve([eq1 eq2], [xdot2 xdot4]);

% Set the LHS of the system of ODEs in standard form.
xdot1 = x2;
xdot2 = sol.xdot2;
xdot3 = x4;
xdot4 = sol.xdot4;

% Simplify the system of ODEs.
xdot2 = collect(xdot2, [x1 x2 x3 x4]);
xdot4 = collect(xdot4, [x1 x2 x3 x4]);

% Compute the right-hand side matrix.
B = [0; coeffs(subs(xdot2, [x1 x2 x3 x4], [0 0 0 0]), F); 0; coeffs(subs(xdot4, [x1 x2 x3 x4], [0 0 0 0]), F)];

% Substitute numerical values for the parameters in our symbolic equations.
xdot2 = subs(xdot2, [m1 m2 c1 c2 k1 k2 L F g], [1 1 1 1 1 0 1 0 9.81]);
xdot4 = subs(xdot4, [m1 m2 c1 c2 k1 k2 L F g], [1 1 1 1 1 0 1 0 9.81]);

% Compute the Jacobian of the system.
J = [diff(xdot1, x1) diff(xdot1, x2) diff(xdot1, x3) diff(xdot1, x4); diff(xdot2, x1) diff(xdot2, x2) diff(xdot2, x3) diff(xdot2, x4); diff(xdot3, x1) diff(xdot3, x2) diff(xdot3, x3) diff(xdot3, x4); diff(xdot4, x1) diff(xdot4, x2) diff(xdot4, x3) diff(xdot4, x4)];

% Compute the linear system matrices.
A = double(subs(J, [x1 x2 x3 x4], [0 0 0 0]));
B = double(subs(B, [m1 m2 c1 c2 k1 k2 L g], [1 1 1 1 1 0 1 9.81]));
% C = [1 0 0 0; 0 0 1 0];
% D = [0; 0];
C = [1 0 0 0];
D = 0;

% Create the linear pendulum state space model.
sys_lin_ol = ss(A, B, C, D);

% Create the linearized system function.
f_lin_ol = @(t, x) A*x;

% Create functions for each symbolic equation.
f1 = @(x1, x2, x3, x4) x2;
f2 = matlabFunction(xdot2);
f3 = @(x1, x2, x3, x4) x4;
f4 = matlabFunction(xdot4);
f_nlin_ol = @(t, x) [f1(x(1), x(2), x(3), x(4)); f2(x(1), x(2), x(3), x(4)); f3(x(1), x(2), x(3), x(4)); f4(x(1), x(2), x(3), x(4))];


%% Design a State Space Controller for the Linear System.

% Define the desired response characteristics.
PMO = 0;
tsettle = 4.5;

% Compute the necessary 2nd system parameters that acheive these response characteristics.
zeta = PMO2zeta( PMO );
omegan = SettlingTime2omegan( tsettle, zeta );

% Compute the leading design point that satifies the desired response characteristics.
s = GetsDesignPoints( omegan, zeta );

% Compute the desired roots of the closed loop system that satisfy the desired response charactersitics.
ps_lin = [s 10*s 11*s 12*s 13*s];

% Design a continuous state space controller with an outer loop integrator for the linear system.
[ sys_lin_cl, K_lin ] = GetSSIController( sys_lin_ol, ps_lin );


%% Define the Nonlinear Closed Loop System Dynamics.

% Define the nonlinear closed loop system dynamics.
f_nlin_cl = @(t, x) [f_nlin_ol(t, x(1:end-1)); -C*x(1:end-1)] + [B*[-K_lin(1:end-1) K_lin(end)]*x; 0];
% f_nlin_cl = @(t, x) [f_nlin_ol(t, x(1:end-1)); -C*x(1:end-1)] + B*[-K(1:end-1) K(end)]*x;


%% Simulate the Linear & Nonlinear Open & Closed Loop Systems.

% Define the simulation duration.
tf_ol = 10; tdomain_ol = [0 tf_ol];
tf_cl = 10; tdomain_cl = [0 tf_cl];

% Define the initial conditions.
theta_offset = -30;
ICs_ol = [0; 0; (pi/180)*theta_offset; 0];
ICs_cl = [0; 0; (pi/180)*theta_offset; 0; 0.1];

% Simulate the linear open loop system.
[ts_lin_ol, ys_lin_ol] = ode45(f_lin_ol, tdomain_ol, ICs_ol);

% Simulate the linear closed loop system.
[ys_lin_cl, ts_lin_cl, xs_lin_cl] = initial(sys_lin_cl, ICs_cl, tf_cl);

% Simulate the nonlinear open loop system.
[ts_nlin_ol, ys_nlin_ol] = ode45(f_nlin_ol, tdomain_ol, ICs_ol);

% Simulate the nonlinear closed loop system.
[ts_nlin_cl, ys_nlin_cl] = ode45(f_nlin_cl, tdomain_cl, ICs_cl);


%% Plot the Linear & Nonlinear Open & Closed Loop System Responses.

% Plot the linear open loop system.
figure('Color', 'w', 'Name', 'Linear Open Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot(ts_lin_ol, ys_lin_ol(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Angle vs Time'), plot(ts_lin_ol, (180/pi)*ys_lin_ol(:, 3), 'Linewidth', 3)

% Plot the linear closed loop system.
figure('Color', 'w', 'Name', 'Linear Closed Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot(ts_lin_cl, xs_lin_cl(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Angle vs Time'), plot(ts_lin_cl, (180/pi)*xs_lin_cl(:, 3), 'Linewidth', 3)

% Plot the nonlinear open loop system.
figure('Color', 'w', 'Name', 'Nonlinear Open Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot(ts_nlin_ol, ys_nlin_ol(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Angle vs Time'), plot(ts_nlin_ol, (180/pi)*ys_nlin_ol(:, 3), 'Linewidth', 3)

% Plot the nonlinear closed loop system.
figure('Color', 'w', 'Name', 'Nonlinear Closed Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot(ts_nlin_cl, ys_nlin_cl(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angle [deg]'), title('Angle vs Time'), plot(ts_nlin_cl, (180/pi)*ys_nlin_cl(:, 3), 'Linewidth', 3)

