%% Spring With Wall Analysis

% Clear Everything.
clear, close('all'), clc


%% Setup the Problem.

% Define the symbolic variables.
syms t m c k A kwall xwall x(t) x1 x2 dx1 dx2

% Define variable conditions.
assume( [ t m c k kwall x(t) ], 'real' )
assume( [ t m c k kwall ], 'positive' )

% Define the state variable derivatives.
dx = diff( x, t );
ddx = diff( dx, t );

% Define the system of equations.
eq1 = dx1 == x2;
eq2 = m*ddx + c*dx + k*x + ( A/m )*( 1/( 1 + exp( -kwall*( x - xwall) ) ) ) == 0;

% Substitute in state variables.
eq2 = subs( eq2, [ x dx ddx ], [ x1 x2 dx2 ] );

% Solve the system of equations for the state variable derivatives.
sol = solve( [ eq1 eq2 ], [ dx1 dx2 ] );

% Define the flow functions.
dx1 = simplify( sol.dx1 );
dx2 = simplify( sol.dx2 );


%% Determine the Numerical Dynamical System.

% Define the mass, spring, damper properties.
m_value = 1;
c_value = 1;
k_value = 1;

% Define the wall properties.
A_value = 100;
kwall_value = 100;
xwall_value = 1;

% Substitute numerical values into the symbolic dynamical system.
dx1_numeric = simplify( vpa( subs( dx1, [ m c k A kwall xwall ], [ m_value c_value k_value A_value kwall_value xwall_value ] ) ) );
dx2_numeric = simplify( vpa( subs( dx2, [ m c k A kwall xwall ], [ m_value c_value k_value A_value kwall_value xwall_value ] ) ) );

% Create anonymous functions for the dynamical system.
fdx1_temp = matlabFunction( dx1_numeric ); fdx1 = @(x1, x2) fdx1_temp( x2 );
fdx2_temp = matlabFunction( dx2_numeric ); fdx2 = @(x1, x2) fdx2_temp( x1, x2 );


%% Compute the Flow Field.

% Define the number of field points per dimension.
n = 20;

% Define the axes of the flow field.
xs1 = linspace( -1, 1, n );
xs2 = linspace( -1, 1, n );

% Create a mesh of the axis vectors.
[ Xs1, Xs2 ] = ndgrid( xs1, xs2 );

% Concatenate the grids.
Xs = cat( 3, Xs1, Xs2 );

% Preallocate a variable to store the flow field.
Fs = zeros( n, n, 2 );

% Compute the flow field.
for k1 = 1:n                                    % Iterate through the first dimension...
    for k2 = 1:n                                % Iterate through the second dimension...

        % Retrieve this flow point.
        x = [ Xs1( k1, k2 ); Xs2( k1, k2 ) ];

        % Compute the flow at this point.
        f1 = fdx1( x(1), x(2) );
        f2 = fdx2( x(1), x(2) );

        % Store the flow at this point in a vector.
        f = [ f1; f2 ];

        % Store the flow at this point in a higher order tensor.
        Fs( k1, k2, : ) = reshape( f, [ 1, 1, numel(f) ] );

    end
end


%% Simulate the Numerical Dynamical System Initial Condition Response.

% Define the simulation duration.
tspan = [0 30];

% Define the initial condition.
x0 = [ 1; 0 ];

% Simulate the dynamical system.
[ ts_initial, xs_initial ] = ode15s( @(t, x) odefunc( t, x, fdx1, fdx2 ), tspan, x0 );


%% Plot the Flow Field.

% Plot the flow field.
figure( 'Color', 'w', 'Name', 'Hill Muscle Flow Field: Position, Velocity' ), hold on, grid on, xlabel('Position [m]'), ylabel('Velocity [m/s]'), title('Flow Field: Position, Velocity'), quiver( Xs( :, :, 1 ), Xs( :, :, 2 ), Fs( :, :, 1 ), Fs( :, :, 2 ) )



%% Plot the System Response to a Non-Zero Initial Condition.

% Plot the initial condition response.
figure( 'Color', 'w', 'Name', 'Spring Wall Initial Condition Response')
subplot(2, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position [rad]'), title('Angular Position vs Time'), plot( ts_initial, xs_initial(:, 1), '-', 'Linewidth', 3 )
subplot(2, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity [rad/s]'), title('Angular Velocity vs Time'), plot( ts_initial, xs_initial(:, 2), '-', 'Linewidth', 3 )



%% Local Functions

% Implement the ODE function.
function dxdt = odefunc( t, x, fdx1, fdx2 )
    
    % Compute the flow values.
    dx1 = fdx1( x(1), x(2) );
    dx2 = fdx2( x(1), x(2) );

    % Store the flow values in an array.
    dxdt = [ dx1; dx2 ];

end

