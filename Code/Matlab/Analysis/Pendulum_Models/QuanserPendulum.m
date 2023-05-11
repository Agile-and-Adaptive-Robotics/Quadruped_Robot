%% Pendulum on Chart Controller

% This script simulates a controlled pendulum on a chart.

% Clear Everything.
clear, close('all'), clc

%% Scratch Paper

% Define the symbolic variables.
syms x1 x2 x3 x4 xdot1 xdot2 xdot3 xdot4 m1 m2 c1 c2 k1 k2 L1 L2 F g etag Kg etam kt km Vm Rm

% Define the two equations of motion
eq1 = ( ((1/12)*m1 + m2)*(L1.^2) + (1/4)*m2*(L2^2)*(1 - cos(x3)^2) )*xdot2 - ( (1/2)*m2*L2*L1*cos(x3) )*xdot4 + ((1/2)*m2*(L2^2)*sin(x3)*cos(x3) )*x2*x4 + ( (1/2)*m2*L2*L1*sin(x3) )*(x4^2) + ((etag*(Kg^2)*etam*kt*km)/Rm + c1)*x2 == (etag*Kg*etam*kt*Vm)/Rm;
eq2 = -((1/2)*m2*L2*L1*cos(x3))*xdot2 + ((1/3)*m2*(L2^2))*xdot4 - ((1/4)*m2*(L2^2)*cos(x3)*sin(x3))*(x2^2) - ((1/2)*m2*L2*g*sin(x3)) + c2*x4 == 0;

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
% B = [0; coeffs(subs(xdot2, [x1 x2 x3 x4], [0 0 0 0]), F); 0; coeffs(subs(xdot4, [x1 x2 x3 x4], [0 0 0 0]), F)];
B = [0; coeffs(subs(xdot2, [x1 x2 x3 x4], [0 0 0 0]), Vm); 0; coeffs(subs(xdot4, [x1 x2 x3 x4], [0 0 0 0]), Vm)];

% Substitute numerical values for the parameters in our symbolic equations.
xdot2 = subs(xdot2, [m1 m2 c1 c2 k1 k2 L1 L2 g etag Kg etam kt km Vm Rm], [1 1 1 1 0 0 1 1 -9.81 1 1 1 1 1 0 1]);
xdot4 = subs(xdot4, [m1 m2 c1 c2 k1 k2 L1 L2 g etag Kg etam kt km Vm Rm], [1 1 1 1 0 0 1 1 -9.81 1 1 1 1 1 0 1]);

% Compute the Jacobian of the system.
J = [diff(xdot1, x1) diff(xdot1, x2) diff(xdot1, x3) diff(xdot1, x4); diff(xdot2, x1) diff(xdot2, x2) diff(xdot2, x3) diff(xdot2, x4); diff(xdot3, x1) diff(xdot3, x2) diff(xdot3, x3) diff(xdot3, x4); diff(xdot4, x1) diff(xdot4, x2) diff(xdot4, x3) diff(xdot4, x4)];

% Compute the linear system matrices.
% A = double(subs(J, [x1 x2 x3 x4], [0 0 0 0]));
A = double(subs(J, [x1 x2 x3 x4], [pi pi pi pi]));
B = double(subs(B, [m1 m2 c1 c2 k1 k2 L1 L2 g etag Kg etam kt km Vm Rm], [1 1 1 1 0 0 1 1 -9.81 1 1 1 1 1 0 1]));
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
f_nlin_ol = @(t, x) [f1(x(1), x(2), x(3), x(4)); f2(x(2), x(3), x(4)); f3(x(1), x(2), x(3), x(4)); f4(x(2), x(3), x(4))];

% m1 = 1;
% m2 = 2;
% c1 = 1;
% c2 = 1;
% 
% L1 = 1;
% L2 = 1;
% 
% etag = 1;
% etam =1;
% km =1;
% kt = 1;
% Kg = 1;
% Rm = 1;
% 
% g = -9.81;
% 
% f1 = @(x) x(2);
% f2 = @(x) ( ( 9*L1*L2*m2*(cos(x(3))^2)*sin(x(3)) )/( 2*(L1^2)*(m1 + 12*m2) + 6*(L2^2)*m2 - 6*(3*(L1^2) + (L2^2))*m2*(cos(x(3))^2) ) )*(x(2)^2) + ( ( -6*m2*(L2^2)*cos(x(3))*sin(x(3)) )/( (L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2)) ) )*x(2)*x(4) + ( ( -24*(L2*etag*etam*km*kt*(Kg^2) + L2*Rm*c1) )/( 2*L2*Rm*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) )*x(2) + ( ( -6*L1*L2*m2*sin(x(3)) )/( (L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2)) ) )*(x(4)^2) + ( ( -18*L1*c2*cos(x(3)) )/( L2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) )*x(4) + ( ( 18*L1*L2*Rm*g*m2*cos(x(3))*sin(x(3)) )/( 2*L2*Rm*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) );
% f3 = @(x) x(4);
% f4 = @(x) ( ( 3*Rm*sin(x(3))*cos(x(3))*(L2^2)*m2*(4*(L1^2)*m2 + m1*(L1^2) - 3*(L2^2)*m2*(cos(x(3))^2) + 3*(L2^2)*m2) )/( 4*(L2^2)*Rm*m2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) )*(x(2)^2) + ( ( -9*L1*L2*m2*(cos(x(3))^2)*sin(x(3)) )/( (L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2)) ) )*x(2)*x(4) + ( ( -72*L1*L2*m2*cos(x(3))*(etag*etam*km*kt*(Kg^2) + Rm*c1) )/( 4*(L2^2)*Rm*m2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) )*x(2) + ( ( -9*(L1^2)*m2*cos(x(3))*sin(x(3)) )/( (L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2)) ) )*(x(4)^2) + ( ( -12*Rm*c2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2*(1 - (cos(x(3))^2))) )/( 4*(L2^2)*Rm*m2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) )*x(4) + ( ( 6*Rm*g*sin(x(3))*L2*m2*(12*(L1^2)*m2 + m1*sin(x(3))*(L1^2) - 3*(L2^2)*m2*(cos(x(3))^2) + 3*L2*m2) )/( 4*(L2^2)*Rm*m2*((L1^2)*(m1 + 12*m2) + 3*(L2^2)*m2 - 3*m2*(cos(x(3))^2)*(3*(L1^2) + (L2^2))) ) );
% 
% f_nlin_ol = @(t, x) [f1(x); f2(x); f3(x); f4(x)];


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
theta_offset = 45;
% ICs_ol = [0; 0; (pi/180)*theta_offset; 0];
% ICs_ol = [0; 0; 0; 0];
% ICs_ol = [0; (pi/180)*theta_offset; 0; 0];
ICs_ol = [(pi/180)*theta_offset; 0; (pi/180)*theta_offset; 0];
ICs_cl = [0; 0; (pi/180)*theta_offset; 0; 0.1];

% Simulate the linear open loop system.
[ts_lin_ol, ys_lin_ol] = ode45(f_lin_ol, tdomain_ol, ICs_ol);

% Simulate the linear closed loop system.
[ys_lin_cl, ts_lin_cl, xs_lin_cl] = initial(sys_lin_cl, ICs_cl, tf_cl);

% Simulate the nonlinear open loop system.
[ts_nlin_ol, ys_nlin_ol] = ode45(f_nlin_ol, tdomain_ol, ICs_ol);

% % Simulate the nonlinear closed loop system.
% [ts_nlin_cl, ys_nlin_cl] = ode45(f_nlin_cl, tdomain_cl, ICs_cl);


%% Plot the Linear & Nonlinear Open & Closed Loop System Responses.

% Plot the linear open loop system.
figure('Color', 'w', 'Name', 'Linear Open Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Base Angle [deg]'), title('Base Angle vs Time'), plot(ts_lin_ol, (180/pi)*ys_lin_ol(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angle [deg]'), title('Pendulum Angle vs Time'), plot(ts_lin_ol, (180/pi)*(ys_lin_ol(:, 3) + pi), 'Linewidth', 3)

% Plot the linear closed loop system.
figure('Color', 'w', 'Name', 'Linear Closed Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Base Angle [deg]'), title('Base Angle vs Time'), plot(ts_lin_cl, (180/pi)*xs_lin_cl(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angle [deg]'), title('Pendulum Angle vs Time'), plot(ts_lin_cl, (180/pi)*(xs_lin_cl(:, 3) + pi), 'Linewidth', 3)

% Plot the nonlinear open loop system.
figure('Color', 'w', 'Name', 'Nonlinear Open Loop System Simulation')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Base Angle [deg]'), title('Base Angle vs Time'), plot(ts_nlin_ol, (180/pi)*ys_nlin_ol(:, 1), 'Linewidth', 3)
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angle [deg]'), title('Pendulum Angle vs Time'), plot(ts_nlin_ol, (180/pi)*ys_nlin_ol(:, 3), 'Linewidth', 3)

% % Plot the nonlinear closed loop system.
% figure('Color', 'w', 'Name', 'Nonlinear Closed Loop System Simulation')
% subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Base Angle [deg]'), title('Base Angle vs Time'), plot(ts_nlin_cl, (180/pi)*ys_nlin_cl(:, 1), 'Linewidth', 3)
% subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angle [deg]'), title('Pendulum Angle vs Time'), plot(ts_nlin_cl, (180/pi)*ys_nlin_cl(:, 3), 'Linewidth', 3)

