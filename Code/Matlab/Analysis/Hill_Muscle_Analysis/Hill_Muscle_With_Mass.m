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


%% Plot the Flow Field.

n = 11;
xs1 = linspace( -1, 1, n );
xs2 = linspace( -1, 1, n );
xs3 = linspace( -1, 1, n );

% [ Xs1, Xs2, Xs3 ] = meshgrid( xs1, xs2, xs3 );
[ Xs1, Xs2, Xs3 ] = ndgrid( xs1, xs2, xs3 );

Fs = zeros( n, n, n, 3 );

for k1 = 1:n
    for k2 = 1:n
        for k3 = 1:n
            
            x = [ Xs1( k1, k2, k3 ); Xs2( k1, k2, k3 ); Xs3( k1, k2, k3 ) ];
            
            f = A*x;
            
            Fs( k1, k2, k3, : ) = reshape( f, [ 1, 1, 1, numel(f) ] );
            
        end
    end
end

Xs1_12 = squeeze( Xs1( :, :, round( n/2 ) ) ); Xs2_12 = squeeze( Xs2( :, :, round( n/2 ) ) );
Fs1_12 = squeeze( Fs( :, :, round( n/2 ), 1 ) ); Fs2_12 = squeeze( Fs( :, :, round( n/2 ), 2 ) );

Xs1_13 = squeeze( Xs1( :, round( n/2 ), : ) ); Xs3_13 = squeeze( Xs3( :, round( n/2 ), : ) );
Fs1_13 = squeeze( Fs( :, round( n/2 ), :, 1 ) ); Fs3_13 = squeeze( Fs( :, round( n/2 ), :, 3 ) );

Xs2_23 = squeeze( Xs2( round( n/2 ), :, : ) ); Xs3_23 = squeeze( Xs3( round( n/2 ), :, : ) );
Fs2_23 = squeeze( Fs( round( n/2 ), :, :, 2 ) ); Fs3_23 = squeeze( Fs( round( n/2 ), :, :, 3 ) );

% Define the dimension order.
dim_order = [ 2 1 3 ];

figure( 'Color', 'w', 'Name', 'Hill Muscle With Mass Flow Field' ), hold on, grid on, xlabel('Mass Position [m]'), ylabel('Mass Velocity [m/s]'), zlabel('Muscle Tension [N]'), title('Hill Muscle With Mass Flow Field'), rotate3d on
quiver3( permute( Xs1, dim_order ), permute( Xs2, dim_order ), permute( Xs3, dim_order ), permute( Fs( :, :, :, 1 ), dim_order ), permute( Fs( :, :, :, 2 ), dim_order ), permute( Fs( :, :, :, 3 ), dim_order ) )

figure( 'Color', 'w', 'Name', 'Hill Muscle Position-Velocity Projection' ), hold on, grid on, xlabel('Mass Velocity [m/s]'), ylabel('Mass Position [m]'), title('Mass Velocity, Mass Position'), rotate3d on, quiver( Xs1_12, Xs2_12, Fs1_12, Fs2_12 )
figure( 'Color', 'w', 'Name', 'Hill Muscle Position-Tension Projection' ), hold on, grid on, xlabel('Mass Velocity [m/s]'), ylabel('Muscle Tension [N]'), title('Mass Velocity, Mass Tension'), rotate3d on, quiver( Xs1_13, Xs3_13, Fs1_13, Fs3_13 )
figure( 'Color', 'w', 'Name', 'Hill Muscle Velocity-Tension Projection' ), hold on, grid on, xlabel('Mass Position [m]'), ylabel('Muscle Tension [N]'), title('Mass Position, Mass Tension'), rotate3d on, quiver( Xs2_23, Xs3_23, Fs2_23, Fs3_23 )

