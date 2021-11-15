%% Double Hill Muscle With Joint

% Clear Everything.
clear, close('all'), clc


%% Determine the Symbolic Dynamical Function.

% Define the symbolic variables.
syms t kse kpe b k kt ct L m Ta dTa Tb dTb ua ub theta(t) Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ddeltaLa ddeltaLb x1 dx1 x2 dx2 x3 dx3 x4 dx4

% Define variable conditions.
assume( [ t kse kpe b k kt ct L m Ta dTa Tb dTb ua ub theta(t) Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ddeltaLa ddeltaLb ], 'real' )
assume( [ kse kpe b k kt ct L m ], 'positive' )

% Define the state variable derivatives.
dtheta = diff( theta, t );
ddtheta = diff( dtheta, t );

% Define the geometry points.
Pa1 = [ Pa1x; Pa1y; Pa1z  ]; Pb1 = [ Pb1x; Pb1y; Pb1z ];
Pa2 = [ Pa2x; Pa2y; Pa2z  ]; Pb2 = [ Pb2x; Pb2y; Pb2z ];
Pa30 = [ Pa30x; Pa30y; Pa30z ]; Pb30 = [ Pb30x; Pb30y; Pb30z ];

% Pa1 = [ Pa1x; Pa1y; 0  ]; Pb1 = [ Pb1x; Pb1y; 0  ];
% Pa2 = [ Pa2x; Pa2y; 0  ]; Pb2 = [ Pb2x; Pb2y; 0  ];
% Pa30 = [ Pa30x; Pa30y; 0  ]; Pb30 = [ Pb30x; Pb30y; 0  ];

% Define the rotation matrix.
Rz = [ cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1 ];

% Define the location of the third geometric points.
% Pa3 = Rz*Pa30; Pb3 = Rz'*Pb30;
Pa3 = Rz*Pa30; Pb3 = Rz*Pb30;

% Define the initial tendon lengths.
La0 = norm( Pa2 - Pa30, 2 );
Lb0 = norm( Pb2 - Pb30, 2 );

% Define the current tendon lengths.
La = norm( Pa2 - Pa3, 2 );
Lb = norm( Pb2 - Pb3, 2 );

% Compute the change in length of the muscles.
deltaLa = La - La0;
deltaLb = Lb - Lb0;

% Compute the rate of length change of the muscles.
ddeltaLa = diff( deltaLa, t );
ddeltaLb = diff( deltaLb, t );

% Compute the direction of the forces.
Fahat = ( Pa2 - Pa3 )/norm( Pa2 - Pa3 );
Fbhat = ( Pb2 - Pb3 )/norm( Pb2 - Pb3 );

% Compute the magnitude of the forces.
Famag = Ta;
Fbmag = Tb;

% Famag = k*deltaLa;
% Fbmag = k*deltaLb;

% Famag = 0;
% Fbmag = k*deltaLb;

% Famag = k*deltaLa;
% Fbmag = 0;

% Famag = 0;
% Fbmag = 0;

% Define the force vectors.
Fa = Famag*Fahat;
Fb = Fbmag*Fbhat;

% Define the moment arms.
ra = Pa3;
rb = Pb3;

% Compute the applied moments.
Ma = cross( ra, Fa ); Ma_vec = formula(Ma);
Mb = cross( rb, Fb ); Mb_vec = formula(Mb);

% Define the Hill Muscle model.
% eq1 = dT == ((kse*kpe)/b)*deltaLa + kse*ddeltaLa - (kse/b)*(1 + kpe/kse)*T + (kse/b)*u;
eq1 = dTa == ((kse*kpe)/b)*deltaLa + kse*ddeltaLa - (kse/b)*(1 + kpe/kse)*Ta + (kse/b)*ua;
eq2 = dTb == ((kse*kpe)/b)*deltaLb + kse*ddeltaLb - (kse/b)*(1 + kpe/kse)*Tb + (kse/b)*ub;

% Define the link moment of intertia.
I = (1/3)*m*L^2;

% Define the equation of motion.
% eq2 = I*ddtheta + ct*dtheta + kt*theta == Ma + Mb;
eq3 = I*ddtheta + ct*dtheta + kt*theta == Ma_vec(3) + Mb_vec(3);
% eq2 = I*ddtheta + ct*dtheta + kt*theta == Mb_vec(3);
% eq2 = I*ddtheta + ct*dtheta + kt*theta == 0;

% Define the third equation.
eq4 = dx1 == x2;

% Substitute in state variables.
eq1 = subs( eq1, [ theta, dtheta, ddtheta, Ta, dTa, Tb, dTb ], [ x1, x2, dx2, x3, dx3, x4, dx4 ] );
eq2 = subs( eq2, [ theta, dtheta, ddtheta, Ta, dTa, Tb, dTb ], [ x1, x2, dx2, x3, dx3, x4, dx4 ] );
eq3 = subs( eq3, [ theta, dtheta, ddtheta, Ta, dTa, Tb, dTb ], [ x1, x2, dx2, x3, dx3, x4, dx4 ] );

% Solve the equations for the flow variables.
sol = solve( [ eq1 eq2 eq3 eq4 ], [ dx1 dx2 dx3 dx4 ] );

% Define the flow functions.
dx1 = simplify( sol.dx1 );
dx2 = simplify( sol.dx2 );
dx3 = simplify( sol.dx3 );
dx4 = simplify( sol.dx4 );


%% Determine the Numerical Dynamical System.

% Hill Muscle Properties.
kse_value = 1;
kpe_value = 1;
b_value = 1;

% Opposing Spring Properties.
k_value = 1;
% k_value = 20;

% Joint Properties.
kt_value = 1;
ct_value = 1;
% ct_value = 100;

% Limb Properties.
L_value = 3;
m_value = 1;

% Attachment Location Properties.
Pa1x_value = -5; Pa1y_value = 0.5; Pa1z_value = 0; Pa1_value = [ Pa1x_value; Pa1y_value; Pa1z_value ];
Pa2x_value = -0.25; Pa2y_value = 0.5; Pa2z_value = 0; Pa2_value = [ Pa2x_value; Pa2y_value; Pa2z_value ];
Pa30x_value = 0.75; Pa30y_value = 0.125; Pa30z_value = 0; Pa30_value = [ Pa30x_value; Pa30y_value; Pa30z_value ];

Pb1x_value = -5; Pb1y_value = -0.5; Pb1z_value = 0; Pb1_value = [ Pb1x_value; Pb1y_value; Pb1z_value ];
Pb2x_value = -0.25; Pb2y_value = -0.5; Pb2z_value = 0; Pb2_value = [ Pb2x_value; Pb2y_value; Pb2z_value ];
Pb30x_value = 0.5; Pb30y_value = -0.125; Pb30z_value = 0; Pb30_value = [ Pb30x_value; Pb30y_value; Pb30z_value ];

Pcx_value = 0; Pcy_value = 0; Pcz_value = 0; Pc_value = [ Pcx_value; Pcy_value; Pcz_value ];

Pj_value = [ 0; 0; 0 ];

Pw1_value = [ -5; 1; 0 ];
Pw2_value = [ -5; -1; 0 ];
Pw3_value = [ -5; 0; 0 ];
Pw4_value = [ 0; 0; 0 ];

Pl1_value = [ 0; 0; 0 ];
Pl2_value = [ L_value; 0; 0 ];

% Organize the attachment points into bodies.
Pas_value = [ Pa1_value, Pa2_value, Pa30_value ];
Pbs_value = [ Pb1_value, Pb2_value, Pb30_value ];
Pws_value = [ Pw1_value, Pw2_value, Pw3_value, Pw4_value ];
Pls_value = [ Pl1_value, Pl2_value ];

% Substitute numerical values into the symbolic dynamical system.
dx1_numeric = simplify( vpa( subs( dx1, [ kse kpe b k kt ct L m Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ], [ kse_value kpe_value b_value k_value kt_value ct_value L_value m_value Pa1x_value Pa1y_value Pa1z_value Pa2x_value Pa2y_value Pa2z_value Pa30x_value Pa30y_value Pa30z_value Pb1x_value Pb1y_value Pb1z_value Pb2x_value Pb2y_value Pb2z_value Pb30x_value Pb30y_value Pb30z_value ] ) ) );
dx2_numeric = simplify( vpa( subs( dx2, [ kse kpe b k kt ct L m Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ], [ kse_value kpe_value b_value k_value kt_value ct_value L_value m_value Pa1x_value Pa1y_value Pa1z_value Pa2x_value Pa2y_value Pa2z_value Pa30x_value Pa30y_value Pa30z_value Pb1x_value Pb1y_value Pb1z_value Pb2x_value Pb2y_value Pb2z_value Pb30x_value Pb30y_value Pb30z_value ] ) ) );
dx3_numeric = simplify( vpa( subs( dx3, [ kse kpe b k kt ct L m Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ], [ kse_value kpe_value b_value k_value kt_value ct_value L_value m_value Pa1x_value Pa1y_value Pa1z_value Pa2x_value Pa2y_value Pa2z_value Pa30x_value Pa30y_value Pa30z_value Pb1x_value Pb1y_value Pb1z_value Pb2x_value Pb2y_value Pb2z_value Pb30x_value Pb30y_value Pb30z_value ] ) ) );
dx4_numeric = simplify( vpa( subs( dx4, [ kse kpe b k kt ct L m Pa1x Pa1y Pa1z Pa2x Pa2y Pa2z Pa30x Pa30y Pa30z Pb1x Pb1y Pb1z Pb2x Pb2y Pb2z Pb30x Pb30y Pb30z ], [ kse_value kpe_value b_value k_value kt_value ct_value L_value m_value Pa1x_value Pa1y_value Pa1z_value Pa2x_value Pa2y_value Pa2z_value Pa30x_value Pa30y_value Pa30z_value Pb1x_value Pb1y_value Pb1z_value Pb2x_value Pb2y_value Pb2z_value Pb30x_value Pb30y_value Pb30z_value ] ) ) );

% Create anonymous functions for the dynamical system.
fdx1_temp = matlabFunction( dx1_numeric ); fdx1 = @(x1, x2, x3, u) fdx1_temp( x2 );
fdx2_temp = matlabFunction( dx2_numeric ); fdx2 = @(x1, x2, x3, u) fdx2_temp( x1, x2, x3 );
% fdx2_temp = matlabFunction( dx2_numeric ); fdx2 = @(x1, x2, x3, u) fdx2_temp( x1, x2 );
fdx3_temp = matlabFunction( dx3_numeric ); fdx3 = @(x1, x2, x3, u) fdx3_temp( u, x1, x2, x3 );
fdx4_temp = matlabFunction( dx4_numeric ); fdx4 = @(x1, x2, x3, u) fdx4_temp( u, x1, x2, x3 );


%% Compute the Flow Field.

% Define the number of field points per dimension.
n = 20;

% Define the axes of the flow field.
xs1 = linspace( -30*pi/180, 30*pi/180, n );
xs2 = linspace( -15*pi/180, 15*pi/180, n );
xs3 = linspace( -1, 1, n );

% Create the field grids.
[ Xs1, Xs2, Xs3 ] = ndgrid( xs1, xs2, xs3 );

% Preallocate a variable to store the flow field.
Fs = zeros( n, n, n, 3 );

% Compute the flow field.
for k1 = 1:n                                    % Iterate through the first dimension...
    for k2 = 1:n                                % Iterate through the second dimension...
        for k3 = 1:n                            % Iterate through the third dimension...
            
            % Retrieve this flow point.
            x = [ Xs1( k1, k2, k3 ); Xs2( k1, k2, k3 ); Xs3( k1, k2, k3 ) ];
            
            % Compute the flow at this point.
            f1 = fdx1( x(1), x(2), x(3), 0 );
            f2 = fdx2( x(1), x(2), x(3), 0 );
            f3 = fdx3( x(1), x(2), x(3), 0 );

            % Store the flow at this point in a vector.
            f = [ f1; f2; f3 ];
            
            % Store the flow at this point in a higher order tensor.
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


%% Simulate the Numerical Dynamical System Step Response.

% Define the simulation duration.
tspan = [0 30];

% Define the initial condition.
x0 = [ 0; 0; 0 ];

% Define the input function.
% fu = @(t) 0;
fu = @(t) 1;

% Simulate the dynamical system.
% [ ts_step, xs_step ] = ode45( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );
[ ts_step, xs_step ] = ode15s( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );


%% Simulate the Numerical Dynamical System Non-Zero Initial Condition Response.

% Define the simulation duration.
tspan = [0 30];

% Define the initial condition.
% x0 = [ -15*(pi/180); 0; 0 ];
% x0 = [ 0*(pi/180); 0; 0 ];
x0 = [ 15*(pi/180); 0; 0 ];

% Define the input function.
fu = @(t) 0;
% fu = @(t) 1;

% Simulate the dynamical system.
% [ ts_initial, xs_initial ] = ode45( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );
[ ts_initial, xs_initial ] = ode15s( @(t, x) odefunc( t, x, fdx1, fdx2, fdx3, fu ), tspan, x0 );


%% Plot the Initial Problem Setup.

% Plot the initial problem setup.
figure( 'Color', 'w', 'Name', 'Initial Problem Setup' ), hold on, grid on, rotate3d on, axis equal
plot3( Pws_value( 1, : ), Pws_value( 2, : ), Pws_value( 3, : ), 'k.-', 'Linewidth', 3, 'Markersize', 20 )
plot3( Pls_value( 1, : ), Pls_value( 2, : ), Pls_value( 3, : ), 'g.-', 'Linewidth', 3, 'Markersize', 20 )
plot3( Pas_value( 1, : ), Pas_value( 2, : ), Pas_value( 3, : ), 'r.-', 'Linewidth', 3, 'Markersize', 20 )
plot3( Pbs_value( 1, : ), Pbs_value( 2, : ), Pbs_value( 3, : ), 'b.-', 'Linewidth', 3, 'Markersize', 20 )


%% Plot the Flow Field.

% Plot the flow field.
figure( 'Color', 'w', 'Name', 'Hill Muscle Flow Field: Angular Velocity, Angular Position' ), hold on, grid on, xlabel('Angular Velocity [rad/s]'), ylabel('Angular Position [rad]'), title('Flow Field: Angular Velocity, Angular Position'), quiver( Xs1_12, Xs2_12, Fs1_12, Fs2_12 )
figure( 'Color', 'w', 'Name', 'Hill Muscle Flow Field: Angular Velocity, Angular Position' ), hold on, grid on, xlabel('Angular Velocity [rad/s]'), ylabel('Muscle Tension [N]'), title('Flow Field: Angular Velocity, Muscle Tension'), quiver( Xs1_13, Xs3_13, Fs1_13, Fs3_13 )
figure( 'Color', 'w', 'Name', 'Hill Muscle Flow Field: Angular Velocity, Angular Position' ), hold on, grid on, xlabel('Angular Position [rad]'), ylabel('Muscle Tension [N]'), title('Flow Field: Angular Position, Muscle Tension'), quiver( Xs2_23, Xs3_23, Fs2_23, Fs3_23 )


%% Plot the System Step Response.

% Plot the step response.
figure( 'Color', 'w', 'Name', 'Hill Muscle Step Response')
subplot(3, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position [rad]'), title('Angular Position vs Time'), plot( ts_step, xs_step(:, 1), '-', 'Linewidth', 3 )
subplot(3, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity [rad/s]'), title('Angular Velocity vs Time'), plot( ts_step, xs_step(:, 2), '-', 'Linewidth', 3 )
subplot(3, 1, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Tension [N]'), title('Muscle Tension vs Time'), plot( ts_step, xs_step(:, 3), '-', 'Linewidth', 3 )


%% Plot the System Response to a Non-Zero Initial Condition.

% Plot the initial condition response.
figure( 'Color', 'w', 'Name', 'Hill Muscle Initial Condition Response')
subplot(3, 1, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Position [rad]'), title('Angular Position vs Time'), plot( ts_initial, xs_initial(:, 1), '-', 'Linewidth', 3 )
subplot(3, 1, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Angular Velocity [rad/s]'), title('Angular Velocity vs Time'), plot( ts_initial, xs_initial(:, 2), '-', 'Linewidth', 3 )
subplot(3, 1, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Tension [N]'), title('Muscle Tension vs Time'), plot( ts_initial, xs_initial(:, 3), '-', 'Linewidth', 3 )


%% Simulate the System.

num_thetas = 20;

thetas = linspace( -15*(pi/180), 15*(pi/180), num_thetas );

% [ La, Lb, deltaLa, deltaLb, Famag, Fbmag, Ma, Mb ] = forward_step( theta );

[ Las, Lbs, deltaLas, deltaLbs, Famags, Fbmags, Mas, Mbs ] = forward_simulation( thetas );

figure( 'Color', 'w', 'Name', 'Tendon Length vs Angle' ), hold on, grid on, xlabel('Angle [rad]'), ylabel('Tendon Length [m]'), title('Tendon Length vs Angle')
plot( thetas, Las, '-', 'Linewidth', 3 )
plot( thetas, Lbs, '-', 'Linewidth', 3 )
legend('Actuator A', 'Actuator B')

figure( 'Color', 'w', 'Name', 'Change in Muscle Length vs Angle' ), hold on, grid on, xlabel('Angle [rad]'), ylabel('Change in Muscle Length [m]'), title('Change in Muscle Length vs Angle')
plot( thetas, deltaLas, '-', 'Linewidth', 3 )
plot( thetas, deltaLbs, '-', 'Linewidth', 3 )
legend('Actuator A', 'Actuator B')

figure( 'Color', 'w', 'Name', 'Muscle Tension vs Angle' ), hold on, grid on, xlabel('Angle [rad]'), ylabel('Muscle Tension [m]'), title('Muscle Tension vs Angle')
plot( thetas, Famags, '-', 'Linewidth', 3 )
plot( thetas, Fbmags, '-', 'Linewidth', 3 )
legend('Actuator A', 'Actuator B')

figure( 'Color', 'w', 'Name', 'Moment vs Angle' ), hold on, grid on, xlabel('Angle [rad]'), ylabel('Moment [Nm]'), title('Moment vs Angle')
plot( thetas, Mas, '-', 'Linewidth', 3 )
plot( thetas, Mbs, '-', 'Linewidth', 3 )
legend('Actuator A', 'Actuator B')




%% Local Functions

% Implement the ODE function.
function dxdt = odefunc( t, x, fdx1, fdx2, fdx3, fu )

%     % Evaluate the input function.
%     u = fu(t);
%     
%     % Compute the flow values.
%     dx1 = fdx1( x(1), x(2), x(3), u );
%     dx2 = fdx2( x(1), x(2), x(3), u );
%     dx3 = fdx3( x(1), x(2), x(3), u );
% 
%     % Store the flow values in an array.
%     dxdt = [ dx1; dx2; dx3 ];
    
    % Evaluate the input function.
    u = fu(t);

%     % Compute the flow values.
%     dx1 = x(2);
%     dx2 = -(1/3)*x(1) - (1/3)*x(2);
%     dx3 = 0;
    
%     % Compute the flow values.
%     dx1 = x(2);
%     dx2 = -(1/3)*x(1) - (1/3)*x(2);
%     dx3 = fdx3( x(1), x(2), x(3), u );

%     % Compute the flow values.
%     dx1 = fdx1( x(1), x(2), x(3), u );
%     dx2 = -(1/3)*x(1) - (1/3)*x(2);
%     dx3 = fdx3( x(1), x(2), x(3), u );
    
    % Compute the flow values.
    dx1 = fdx1( x(1), x(2), x(3), u );
    dx2 = fdx2( x(1), x(2), x(3), u );
    dx3 = fdx3( x(1), x(2), x(3), u );

    % Store the flow values in an array.
    dxdt = [ dx1; dx2; dx3 ];

end


% Implement a function to compute simulation properties as a function of angle.
function [ La, Lb, deltaLa, deltaLb, Famag, Fbmag, Ma, Mb ] = forward_step( theta )

    % Define the rotation matrix.
    Rz = [ cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1 ];

    % Define the spring properties.
    k = 1;
    
    % Define the first actuator points.
    Pa1x = -5; Pa1y = 0.5; Pa1z = 0; Pa1 = [ Pa1x; Pa1y; Pa1z ];
    Pa2x = -0.25; Pa2y = 0.5; Pa2z = 0; Pa2 = [ Pa2x; Pa2y; Pa2z ];
    Pa30x = 0.75; Pa30y = 0.125; Pa30z = 0; Pa30 = [ Pa30x; Pa30y; Pa30z ];

    % Define the second actuator points.
    Pb1x = -5; Pb1y = -0.5; Pb1z = 0; Pb1 = [ Pb1x; Pb1y; Pb1z ];
    Pb2x = -0.25; Pb2y = -0.5; Pb2z = 0; Pb2 = [ Pb2x; Pb2y; Pb2z ];
    Pb30x = 0.5; Pb30y = -0.125; Pb30z = 0; Pb30 = [ Pb30x; Pb30y; Pb30z ];
    
    % Define the location of the third geometric points.
%     Pa3 = Rz*Pa30; Pb3 = Rz'*Pb30;
    Pa3 = Rz*Pa30; Pb3 = Rz*Pb30;

    % Define the initial tendon lengths.
    La0 = norm( Pa2 - Pa30, 2 );
    Lb0 = norm( Pb2 - Pb30, 2 );

    % Define the current tendon lengths.
    La = norm( Pa2 - Pa3, 2 );
    Lb = norm( Pb2 - Pb3, 2 );

    % Compute the change in length of the muscles.
    deltaLa = La - La0;
    deltaLb = Lb - Lb0;
    
    % Compute the direction of the forces.
    Fahat = ( Pa2 - Pa3 )/norm( Pa2 - Pa3 );
    Fbhat = ( Pb2 - Pb3 )/norm( Pb2 - Pb3 );

    % Compute the magnitude of the forces.
    Famag = k*deltaLa;
    Fbmag = k*deltaLb;

    % Define the force vectors.
    Fa = Famag*Fahat;
    Fb = Fbmag*Fbhat;

    % Define the moment arms.
    ra = Pa3;
    rb = Pb3;

    % Compute the applied moments.
    Ma = cross( ra, Fa );
    Mb = cross( rb, Fb );
    
    Ma = Ma(3);
    Mb = Mb(3);

end


% Implement a function to compute simulation properties across multiple angles.
function [ Las, Lbs, deltaLas, deltaLbs, Famags, Fbmags, Mas, Mbs ] = forward_simulation( thetas )

    % Retrieve the number of angles.
    num_thetas = length(thetas);

    % Preallocate the simulation properties at each angle.
    [ Las, Lbs, deltaLas, deltaLbs, Famags, Fbmags, Mas, Mbs ] = deal( zeros( num_thetas, 1 ) );

    % Compute the simulation properties at each angle.
    for k = 1:num_thetas                    % Iterate through each angle...

        % Compute the simulation properties associated with this time step.
        [ Las(k), Lbs(k), deltaLas(k), deltaLbs(k), Famags(k), Fbmags(k), Mas(k), Mbs(k) ] = forward_step( thetas(k) );

    end
    
end


