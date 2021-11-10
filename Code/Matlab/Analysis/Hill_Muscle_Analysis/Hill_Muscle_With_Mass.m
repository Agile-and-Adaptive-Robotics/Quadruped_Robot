%% Hill Muscle With Mass Analysis

% Clear Everything.
clear, close('all'), clc


%% Setup the Problem.

% Define the system variables.
m = 1;
c = 1;
k = 1;
kse = 1;
kpe = 1;
b = 1;

% Define the system matrix.
A = [ 0 1 0; -(k/m) -(c/m) -(1/m); (kse*kpe)/b kse -(kse/b)*(1 + kpe/kse) ];
B = [ 0; 0; kse/b ];
C = eye(3);
D = 0;

% Create the state space system.
Gss = ss( A, B, C, D );


%% Generate the Step Response.

% Define the simulation duration.
tfinal = 10;

% Compute the step response.
[ ys, ts ] = step( Gss, tfinal );

% Plot the step response.
figure( 'Color', 'w', 'Name', 'Hill Muscle with Mass Step Response' )
subplot( 3, 1, 1 ), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot( ts, ys(:, 1), '-', 'Linewidth', 3 )
subplot( 3, 1, 2 ), hold on, grid on, xlabel('Time [s]'), ylabel('Velocity [m/s]'), title('Velocity vs Time'), plot( ts, ys(:, 2), '-', 'Linewidth', 3 )
subplot( 3, 1, 3 ), hold on, grid on, xlabel('Time [s]'), ylabel('Tension [N]'), title('Tension vs Time'), plot( ts, ys(:, 3), '-', 'Linewidth', 3 )


%% Simulate the Hill Muscle Model.

% Define the system initial condition.
% x0 = [ 0; 0; 0 ];
x0 = [ 1; 0; 0 ];

% Define the simulation duration.
tfinal = 10;

% Compute the system response.
[ ys, ts ] = initial( Gss, x0, tfinal );

% Plot the system states.
figure( 'Color', 'w', 'Name', 'Hill Muscle With Mass State Response' )
subplot( 3, 1, 1 ), hold on, grid on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time'), plot( ts, ys(:, 1), '-', 'Linewidth', 3 )
subplot( 3, 1, 2 ), hold on, grid on, xlabel('Time [s]'), ylabel('Velocity [m/s]'), title('Velocity vs Time'), plot( ts, ys(:, 2), '-', 'Linewidth', 3 )
subplot( 3, 1, 3 ), hold on, grid on, xlabel('Time [s]'), ylabel('Tension [N]'), title('Tension vs Time'), plot( ts, ys(:, 3), '-', 'Linewidth', 3 )


