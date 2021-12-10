%% Double Pendulum Dynamics

% Clear Everything.
clear, close('all'), clc


%% Define the Symbolic Dynamical System.

% Define the symbolic variables.
syms t theta1(t) theta2(t) L1 L2 m1 m2 c1 c2 k1 k2 g M1 M2 x1 x2 x3 x4 u1 u2 dx1 dx2 dx3 dx4

dtheta1 = diff( theta1, t );
dtheta2 = diff( theta2, t );

ddtheta1 = diff( dtheta1, t );
ddtheta2 = diff( dtheta2, t );

x1_com = -L1*sin(theta1);
y1_com = L1*cos(theta1);

x2_com = x1_com - L2*sin(theta2) ;
y2_com = y1_com + L2*cos(theta2);

dx1_com = diff( x1_com, t ); dy1_com = diff( y1_com, t );
dx2_com = diff( x2_com, t ); dy2_com = diff( y2_com, t );

v1_squared = dx1_com^2 + dy1_com^2; v1_squared = simplify( v1_squared ); v1_squared = collect( v1_squared, [ dtheta1, dtheta2 ] );
v2_squared = dx2_com^2 + dy2_com^2; v2_squared = simplify( v2_squared ); v2_squared = collect( v2_squared, [ dtheta1, dtheta2 ] );

T = (1/2)*m1*v1_squared + (1/2)*m2*v2_squared; T = simplify( T ); T = collect( T, [ dtheta1, dtheta2 ] );

V1s = (1/2)*k1*theta1^2;
V2s = (1/2)*k2*theta2^2;

V1g = m1*g*y1_com;
V2g = m2*g*y2_com;

V = V1s + V1g + V2s + V2g; V = simplify( V ); V = collect( V, [ theta1, theta2 ] );

D1 = (1/2)*c1*dtheta1^2;
D2 = (1/2)*c2*dtheta2^2;

D = D1 + D2;

Lagr = T - V;

eq1 = dx1 == x2;
eq2 = simplify( diff( diff( Lagr, formula( dtheta1 ) ) , t ) ) + simplify( diff( D, formula( dtheta1 ) ) ) - simplify( diff( Lagr, theta1 ) ) == M1;
eq3 = dx3 == x4;
eq4 = simplify( diff( diff( Lagr, formula( dtheta2 ) ) , t ) ) + simplify( diff( D, formula( dtheta2 ) ) ) - simplify( diff( Lagr, theta2 ) ) == M2;

eq2 = subs( eq2, [ theta1(t), dtheta1(t), ddtheta1(t), theta2(t), dtheta2(t), ddtheta2(t), M1, M2 ], [ x1, x2, dx2, x3, x4, dx4, u1, u2 ] );
eq4 = subs( eq4, [ theta1(t), dtheta1(t), ddtheta1(t), theta2(t), dtheta2(t), ddtheta2(t), M1, M2 ], [ x1, x2, dx2, x3, x4, dx4, u1, u2 ] );

sol = solve( [ eq1 eq2 eq3 eq4 ], [ dx1, dx2, dx3, dx4 ] );

dx1 = collect( simplify( sol.dx1 ), [ x1 x2 x3 x4 ] );
dx2 = collect( simplify( sol.dx2 ), [ x1 x2 x3 x4 ] );
dx3 = collect( simplify( sol.dx3 ), [ x1 x2 x3 x4 ] );
dx4 = collect( simplify( sol.dx4 ), [ x1 x2 x3 x4 ] );


%% Define the Numerical Dynamical System

% % Define the numerical system values.
% w_value = 2;
% h_value = 1;
% L_value = 5;
% m1_value = 1;
% m2_value = 1;
% c1_value = 1;
% c2_value = 1;
% k1_value = 1;
% k2_value = 1;
% g_value = 9.81;

w_value = 2;
h_value = 1;
L1_value = sqrt( (w_value/2)^2 + h_value^2 );
L2_value = 5;
m1_value = 1;
m2_value = 1;
c1_value = 0;
c2_value = 0;
k1_value = 0;
k2_value = 0;
g_value = 9.81;

% Define relevant geomtric locations.
% P1s = [ 0 w_value/2; 0 h_value; 0 0 ];
% P2s = [ w_value/2 w_value/2; h_value h_value + L2_value; 0 0 ];

P1s = [ 0 0; 0 L1_value; 0 0 ];
P2s = [ 0 0; L1_value L1_value + L2_value; 0 0 ];

% Substitute numerical values into the symbolic dynamical system.
dx1_numeric = simplify( vpa( subs( dx1, [ L1 L2 m1 m2 c1 c2 k1 k2 g ], [ L1_value L2_value m1_value m2_value c1_value c2_value k1_value k2_value g_value ] ) ) );
dx2_numeric = simplify( vpa( subs( dx2, [ L1 L2 m1 m2 c1 c2 k1 k2 g ], [ L1_value L2_value m1_value m2_value c1_value c2_value k1_value k2_value g_value ] ) ) );
dx3_numeric = simplify( vpa( subs( dx3, [ L1 L2 m1 m2 c1 c2 k1 k2 g ], [ L1_value L2_value m1_value m2_value c1_value c2_value k1_value k2_value g_value ] ) ) );
dx4_numeric = simplify( vpa( subs( dx4, [ L1 L2 m1 m2 c1 c2 k1 k2 g ], [ L1_value L2_value m1_value m2_value c1_value c2_value k1_value k2_value g_value ] ) ) );

% Create anonymous functions for the dynamical system.
fdx1_temp = matlabFunction( dx1_numeric ); fdx1 = @( x1, x2, x3, x4, u1, u2 ) fdx1_temp( x2 );
fdx2_temp = matlabFunction( dx2_numeric ); fdx2 = @( x1, x2, x3, x4, u1, u2 ) fdx2_temp(  u1, u2, x1, x2, x3, x4 );
fdx3_temp = matlabFunction( dx3_numeric ); fdx3 = @( x1, x2, x3, x4, u1, u2 ) fdx3_temp( x4 );
fdx4_temp = matlabFunction( dx4_numeric ); fdx4 = @( x1, x2, x3, x4, u1, u2 ) fdx4_temp( u1, u2, x1, x2, x3, x4 );


%% Perform Robotics Setup.

% Define the displacement vectors.
r1 = [ 0; 0; 0 ];
r2 = [ 0; L1_value; 0 ];

% Define the rotation vectors.
waxis1 = [ 0; 0; 1 ];
waxis2 = [ 0; 0; 1 ];

% Compute the velocities.
vaxis1 = cross( r1, waxis1 );
vaxis2 = cross( r2, waxis2 );

% Compute the screws axes.
S1 = [ waxis1; vaxis1 ];
S2 = [ waxis2; vaxis2 ];
Slist = [ S1 S2 ];

% Define the home matrix.
M11 = [ 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1 ];
M12 = [ 1 0 0 0; 0 1 0 L1_value; 0 0 1 0; 0 0 0 1 ];
M21 = [ 1 0 0 0; 0 1 0 L1_value; 0 0 1 0; 0 0 0 1 ];
M22 = [ 1 0 0 0; 0 1 0 L1_value + L2_value; 0 0 1 0; 0 0 0 1 ];


%% Compute the Flow Field.

% Define the dimension of the state space.
dim = 4;

% Define the number of field points per dimension.
n = 20;

% Define the axes of the flow field.
xs1 = linspace( -2*pi, 2*pi, n );
xs2 = linspace( -pi, pi, n );
xs3 = linspace( -2*pi, 2*pi, n );
xs4 = linspace( -pi, pi, n );

% Create the field grids.
[ Xs1, Xs2, Xs3, Xs4 ] = ndgrid( xs1, xs2, xs3, xs4 );

% Concatenate the field grids.
Xs = cat( dim + 1, Xs1, Xs2, Xs3, Xs4 );

% Preallocate a variable to store the flow field.
Fs = zeros( n, n, n, n, dim );

% Compute the flow field.
for k1 = 1:n                                    % Iterate through the first dimension...
    for k2 = 1:n                                % Iterate through the second dimension...
        for k3 = 1:n                            % Iterate through the third dimension...
            for k4 = 1:n                        % Iterate through the fourth dimension...

                % Retrieve this flow point.
                x = reshape( Xs( k1, k2, k3, k4, : ), [ dim, 1 ] );

                % Compute the flow at this point.
                f1 = fdx1( x(1), x(2), x(3), x(4), 0, 0 );
                f2 = fdx2( x(1), x(2), x(3), x(4), 0, 0 );
                f3 = fdx3( x(1), x(2), x(3), x(4), 0, 0 );
                f4 = fdx4( x(1), x(2), x(3), x(4), 0, 0 );

                % Store the flow at this point in a vector.
                f = [ f1; f2; f3; f4 ];

                % Store the flow at this point in a higher order tensor.
                Fs( k1, k2, k3, k4, : ) = reshape( f, [ 1, 1, 1, 1, numel(f) ] );

            end
        end
    end
end

Xs1_12 = squeeze( Xs( :, :, round( n/2 ), round( n/2 ), 1 ) ); Xs2_12 = squeeze( Xs( :, :, round( n/2 ), round( n/2 ), 2 ) );
Fs1_12 = squeeze( Fs( :, :, round( n/2 ), round( n/2 ), 1 ) ); Fs2_12 = squeeze( Fs( :, :, round( n/2 ), round( n/2 ), 2 ) );

Xs1_13 = squeeze( Xs( :, round( n/2 ), :, round( n/2 ), 1 ) ); Xs3_13 = squeeze( Xs( :, round( n/2 ), :, round( n/2 ), 3 ) );
Fs1_13 = squeeze( Fs( :, round( n/2 ), :, round( n/2 ), 1 ) ); Fs3_13 = squeeze( Fs( :, round( n/2 ), :, round( n/2 ), 3 ) );

Xs1_14 = squeeze( Xs( :, round( n/2 ), round( n/2 ), :, 1 ) ); Xs4_14 = squeeze( Xs( :, round( n/2 ), round( n/2 ), :, 4 ) );
Fs1_14 = squeeze( Fs( :, round( n/2 ), round( n/2 ), :, 1 ) ); Fs4_14 = squeeze( Fs( :, round( n/2 ), round( n/2 ), :, 4 ) );

Xs2_23 = squeeze( Xs( round( n/2 ), :, :, round( n/2 ), 2 ) ); Xs3_23 = squeeze( Xs( round( n/2 ), :, :, round( n/2 ), 3 ) );
Fs2_23 = squeeze( Fs( round( n/2 ), :, :, round( n/2 ), 2 ) ); Fs3_23 = squeeze( Fs( round( n/2 ), :, :, round( n/2 ), 3 ) );

Xs2_24 = squeeze( Xs( round( n/2 ), :, round( n/2 ), :, 2 ) ); Xs4_24 = squeeze( Xs( round( n/2 ), :, round( n/2 ), :, 4 ) );
Fs2_24 = squeeze( Fs( round( n/2 ), :, round( n/2 ), :, 2 ) ); Fs4_24 = squeeze( Fs( round( n/2 ), :, round( n/2 ), :, 4 ) );

Xs3_34 = squeeze( Xs( round( n/2 ), round( n/2 ), :, :, 3 ) ); Xs4_34 = squeeze( Xs( round( n/2 ), round( n/2 ), :, :, 4 ) );
Fs3_34 = squeeze( Fs( round( n/2 ), round( n/2 ), :, :, 3 ) ); Fs4_34 = squeeze( Fs( round( n/2 ), round( n/2 ), :, :, 4 ) );


%% Simulate the Numerical Dynamical System Step Response.

% Define the simulation duration.
tspan = [0 10];

% Define the initial condition.
% x0 = [ 0; 0; 0; 0 ];
% x0 = [ -180*pi/180; 0; -180*pi/180; 0 ];
x0 = [ -150*pi/180; 0; -180*pi/180; 0 ];

% Define the input function.
fu1 = @(t) 0;
fu2 = @(t) 0;

% fu1 = @(t) 1;
% fu2 = @(t) 0;

% fu1 = @(t) 0;
% fu2 = @(t) 1;
% 
% fu1 = @(t) 1;
% fu2 = @(t) 1;

% Simulate the dynamical system.
% [ ts_step, xs_step ] = ode45( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );
[ ts_step, xs_step ] = ode15s( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fdx4, fu1, fu2 ), tspan, x0 );


%% Simulate the Numerical Dynamical System Initial Response.

% Define the simulation duration.
tspan = [0 10];

% Define the initial condition.
% x0 = [ 0; 0; 0; 0 ];
x0 = [ 30*pi/180; 0; 30*pi/180; 0 ];

% Define the input function.
fu1 = @(t) 0;
fu2 = @(t) 0;

% Simulate the dynamical system.
% [ ts_initial, xs_initial ] = ode45( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );
[ ts_initial, xs_initial ] = ode15s( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fdx4, fu1, fu2 ), tspan, x0 );


%% Plot the Initial Problem Setup.

% Plot the initial problem setup.
figure( 'Color', 'w', 'Name', 'Initial Problem Setup' ), hold on, grid on, rotate3d on, axis equal
plot3( P1s( 1, : ), P1s( 2, : ), P1s( 3, : ), 'k.-', 'Linewidth', 3, 'Markersize', 20 )
plot3( P2s( 1, : ), P2s( 2, : ), P2s( 3, : ), 'g.-', 'Linewidth', 3, 'Markersize', 20 )


%% Plot the System Step Response.

% Plot the step response.
figure( 'Color', 'w', 'Name', 'Step Response (No Slip, Tip)')
subplot(2, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position 1 [rad]'), title('Angular Position 1 vs Time'), plot( ts_step, xs_step(:, 1), '-', 'Linewidth', 3 )
subplot(2, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity 1 [rad/s]'), title('Angular Velocity 1 vs Time'), plot( ts_step, xs_step(:, 2), '-', 'Linewidth', 3 )
subplot(2, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position 2 [rad]'), title('Angular Position 2 vs Time'), plot( ts_step, xs_step(:, 3), '-', 'Linewidth', 3 )
subplot(2, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity 2 [rad/s]'), title('Angular Velocity 2 vs Time'), plot( ts_step, xs_step(:, 4), '-', 'Linewidth', 3 )


%% Plot the System Response to a Non-Zero Initial Condition.

% Plot the initial condition response.
figure( 'Color', 'w', 'Name', 'Initial Response (No Slip, Tip)')
subplot(2, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position 1 [rad]'), title('Angular Position 1 vs Time'), plot( ts_initial, xs_initial(:, 1), '-', 'Linewidth', 3 )
subplot(2, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity 1 [rad/s]'), title('Angular Velocity 1 vs Time'), plot( ts_initial, xs_initial(:, 2), '-', 'Linewidth', 3 )
subplot(2, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position 2 [rad]'), title('Angular Position 2 vs Time'), plot( ts_initial, xs_initial(:, 3), '-', 'Linewidth', 3 )
subplot(2, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity 2 [rad/s]'), title('Angular Velocity 2 vs Time'), plot( ts_initial, xs_initial(:, 4), '-', 'Linewidth', 3 )


%% Animate the Step Response.

% Retrieve the starting link data.
P1s0 = P1s; P2s0 = P2s;

P1xs = P1s( 1, : ); P1ys = P1s( 2, : ); P1zs = P1s( 3, : );
P2xs = P2s( 1, : ); P2ys = P2s( 2, : ); P2zs = P2s( 3, : );


% Define the rotation matrix anonymous function.
fRz = @(theta) [ cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1 ];

% Retrieve the number of thetas.
num_timesteps = length( ts_step );

% Create a figure to store the step response animation.
fig = figure( 'Color', 'w', 'Name', 'Step Response Animation (No Slip, Tip)' ); hold on, grid on, xlabel( 'x Position [m]' ), ylabel( 'y Position [m]' ), title( 'Step Response Animation (No Slip, Tip)' ), axis equal, axis( [ -(L1_value + L2_value) (L1_value + L2_value) -(L1_value + L2_value) (L1_value + L2_value) ] )
line1 = plot3( P1xs, P1ys, P1zs, 'k.-', 'Linewidth', 3, 'Markersize', 20, 'XDataSource', 'P1xs', 'YDataSource', 'P1ys', 'ZDataSource', 'P1zs'  );
line2 = plot3( P2xs, P2ys, P2zs, 'g.-', 'Linewidth', 3, 'Markersize', 20, 'XDataSource', 'P2xs', 'YDataSource', 'P2ys', 'ZDataSource', 'P2zs'  );

% Animate the step response.
for k = 1:num_timesteps                 % Iterate through each timestep...
    
%     thetalist = [ xs_step( k, 1 ); xs_step( k, 3 ) ];
    thetalist = [ xs_step( k, 1 ); xs_step( k, 3 ) - xs_step( k, 1 ) ];

    T11 = FKinSpace( M11, Slist( :, 1 ), thetalist(1) ); [ ~, P11 ] = TransToRp( T11 );
    T12 = FKinSpace( M12, Slist( :, 1 ), thetalist(1) ); [ ~, P12 ] = TransToRp( T12 );

    T21 = FKinSpace( M21, Slist, thetalist ); [ ~, P21 ] = TransToRp( T21 );
    T22 = FKinSpace( M22, Slist, thetalist ); [ ~, P22 ] = TransToRp( T22 );
    
    P1s = [ P11, P12 ];
    P2s = [ P21, P22 ];
    
    P1xs = P1s( 1, : ); P1ys = P1s( 2, : ); P1zs = P1s( 3, : );
    P2xs = P2s( 1, : ); P2ys = P2s( 2, : ); P2zs = P2s( 3, : );
    
    % Refresh the figure.
    refreshdata( fig )
    
    % Redraw the figure.
    drawnow(  )
    
end



%% Local Functions

% Implement the ODE function.
function dxdt = odefunc( t, x, fdx1, fdx2, fdx3, fdx4, fu1, fu2 )

    % Evaluate the input function.
    u1 = fu1(t);
    u2 = fu2(t);
    
    % Compute the flow values.
    dx1 = fdx1( x(1), x(2), x(3), x(4), u1, u2 );
    dx2 = fdx2( x(1), x(2), x(3), x(4), u1, u2 );
    dx3 = fdx3( x(1), x(2), x(3), x(4), u1, u2 );
    dx4 = fdx4( x(1), x(2), x(3), x(4), u1, u2 );

    % Store the flow values in an array.
    dxdt = [ dx1; dx2; dx3; dx4 ];

end

