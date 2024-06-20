function cost = cost_calc_func(U, dui, time, thetas, points, thetabias_sym)

% Choose value to subsitute for any parameter calulcated to be NaN
% (approximate to zero). Band-aid for issue when optimizer has a parameter
% with a very low value and eventually results in NaN and screws up ODE.
NaN_sub = 1e-20;
U(isnan(U)) = NaN_sub;

%% Assign symbolic equations of motion

% State symbolic variables used in EOM solver
syms M1 M2 M3;
syms theta1(t) dtheta1(t) ddtheta1(t) theta2(t) dtheta2(t) ddtheta2(t) theta3(t) dtheta3(t) ddtheta3(t);
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms k1 k2 k3 k4 k5 k6;
syms I1 I2 I3;
syms mu1 mu2 mu3;
syms g;
syms a1 a2 a3 w1 w2 w3;
syms u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6;
syms tau1 tau2 tau3

% Assign equations of motion
du1 = dui(1); 
du2 = dui(2); 
du3 = dui(3); 
du4 = dui(4); 
du5 = dui(5); 
du6 = dui(6);

%% Assign mechanical properties
% Define the mechanical properties of link 1.
m1_value = 0.001 * 13.26;                   % [kg]                 
R1_value = 0.01 * 1.305;                    % [m]
L1_value = 0.01 * 2.9;                      % [m]
b1_value = U(4);                            % [Ns/m]
k1_value = U(7);                            % [N/m]
mu1_value = 0;                          % [Ns/m]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 9.06;                    % [kg]
R2_value = 0.01 * 1.558;                    % [m]
L2_value = 0.01 * 4.1;                      % [m]
b2_value = U(5);                            % [Ns/m]
k2_value = U(8);                            % [N/m]
mu2_value = 0;                          % [Ns/m]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 1.7;                     % [kg]
R3_value = 0.01 * 1.6;                      % [m]
L3_value = 0.01 * 3.3;                      % [m]
b3_value = U(6);                            % [Ns/m]
k3_value = U(9);                            % [N/m]
mu3_value = 0;                          % [Ns/m]                       

% Define universal constants.
g_value = 9.81;                             % [m/s^2]


%% Convert to numerical values
% Substitute numerical values into the dynamical system flow.
du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] );
thetabias_val = double(subs( thetabias_sym, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value ] ));



% Create anonymous functions from the dynamical system flow components.
fdu1_temp = matlabFunction( du1_value ); fdu1 = @( t, u, tau ) fdu1_temp( u(2) );
fdu2_temp = matlabFunction( du2_value ); fdu2 = @( t, u, tau ) fdu2_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu3_temp = matlabFunction( du3_value ); fdu3 = @( t, u, tau ) fdu3_temp( u(4) );
fdu4_temp = matlabFunction( du4_value ); fdu4 = @( t, u, tau ) fdu4_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu5_temp = matlabFunction( du5_value ); fdu5 = @( t, u, tau ) fdu5_temp( u(6) );
fdu6_temp = matlabFunction( du6_value ); fdu6 = @( t, u, tau ) fdu6_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu = @( t, u, tau ) [ fdu1( t, u, tau ); fdu2( t, u, tau ); fdu3( t, u, tau ); fdu4( t, u, tau ); fdu5( t, u, tau ); fdu6( t, u, tau ) ];


%% Simulate the Triple Pendulum Dynamics.

% Define the applied torques.
taus = zeros( 3, 1 );

% Define the initial joint angles.
theta0s = [thetas(1,1), thetas(1,2), thetas(1,3)];

% Define the initial joint angular velocities.
w0s = U(1:3);

% Assemble the state variable initial condition.
u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ); ];

% Simulate the triple pendulum dynamics.
% [ t, x ] = ode45( @( t, u ) fdu( t, u, taus ), time, u0s );
[ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), time, u0s );


% NEED TO INSERT SOMETHING HERE THAT ASSIGNS A HIGH COST IF ODE IS NOT ABLE
% TO FIND A SOLUTION. ALSO MAKE BETTER INITIAL GUESSES

%% Calculate cost by point comparison

% Calculating error in individual points
e1 = (x(points(1):points(2),1) - thetas(points(1):points(2),1));
e2 = (x(points(1):points(2),3) - thetas(points(1):points(2),2));
e3 = (x(points(1):points(2),5) - thetas(points(1):points(2),3));

% Place a higher value where the first peak tends to occur around (0.065s
% to 0.2s
e1(65:end) = e1(65:end) * 10;
e2(65:end) = e2(65:end) * 10;
e3(65:end) = e3(65:end) * 10;

% Define cost from difference in distance at all points and joints
cost = sum(e1.^2) + sum(e2.^2) + sum(e3.^2);


end
