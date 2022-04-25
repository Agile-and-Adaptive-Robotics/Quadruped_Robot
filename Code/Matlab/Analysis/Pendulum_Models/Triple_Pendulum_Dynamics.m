%% Triple Pendulum Dynamics.

% This script computes the dynamics of a triple pendulum using Emma's notational convention.

% Clear Everything.
close('all'), clear, clc


%% Define the Symbolic Triple Pendulum Dynamics.

% Define the symbolic variables.
syms g m1 m2 m3 I1 I2 I3 c1 c2 c3 k1 k2 k3 L1 L2 L3 R1 R2 R3 theta1o theta2o theta3o theta1(t) theta2(t) theta3(t) dtheta1(t) dtheta2(t) dtheta3(t) ddtheta1(t) ddtheta2(t) ddtheta3(t) w1 w2 w3 a1 a2 a3 tau1 tau2 tau3 u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6

% Define the moments of inertia.
I1 = (1/12)*m1*L1^2;
I2 = (1/12)*m2*L2^2;
I3 = (1/12)*m3*L3^2;

% Define canonical angles.
phi1 = pi - theta1;
phi2 = -( theta1 + theta2 );
phi3 = pi + theta3 - theta1 - theta2;

% Define the joint locations.
x_knee = L1*cos( phi1 ); y_knee = L1*sin( phi1 );
x_ankle = x_knee + L2*cos( phi2 ); y_ankle = y_knee + L2*sin( phi2 );
x_foot = x_ankle + L3*cos( phi3 ); y_foot = y_ankle + L3*sin( phi3 );

% Define the center of mass locations.
x1 = R1*cos( phi1 ); y1 = R1*sin( phi1 );
x2 = x_knee + R2*cos( phi2 ); y2 = y_knee + R2*sin( phi2 );
x3 = x_ankle + R3*cos( phi3 ); y3 = y_ankle + R3*sin( phi3 );

% Compute the center of mass velocities.
dx1 = diff( x1, t ); dy1 = diff( y1, t );
dx2 = diff( x2, t ); dy2 = diff( y2, t );
dx3 = diff( x3, t ); dy3 = diff( y3, t );

% Substitute in convenient angle derivative variables.
dx1 = subs( dx1, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] );
dx2 = subs( dx2, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] );
dx3 = subs( dx3, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] );

% Compute the kinetic energy.
T1 = (1/2)*m1*dx1.^2 + (1/2)*I1*dtheta1.^2; T1 = simplify( T1 );
T2 = (1/2)*m2*dx2.^2 + (1/2)*I2*dtheta2.^2; T2 = simplify( T2 );
T3 = (1/2)*m3*dx3.^2 + (1/2)*I3*dtheta3.^2; T3 = simplify( T3 );
T = T1 + T2 + T3;

% Compute the potential energy.
V1 = -m1*g*y1 + (1/2)*k1*( theta1 - theta1o ).^2; V1 = simplify( V1 );
V2 = -m2*g*y2 + (1/2)*k2*( theta2 - theta2o ).^2; V2 = simplify( V2 );
V3 = -m3*g*y3 + (1/2)*k3*( theta3 - theta3o ).^2; V3 = simplify( V3 );
V = V1 + V2 + V3;

% Compute the energy dissipation term.
C1 = (1/2)*c1*dx1.^2; C1 = simplify( C1 );
C2 = (1/2)*c2*dx2.^2; C2 = simplify( C2 );
C3 = (1/2)*c3*dx3.^2; C3 = simplify( C3 );
C = C1 + C2 + C3;

% Compute the Largangian.
L = T - V; L = simplify( L );

% Remove the time dependence terms.
Law = subs( L, [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ], [ a1 a2 a3 w1 w2 w3 ] );
Caw = subs( C, [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ], [ a1 a2 a3 w1 w2 w3 ] );

% Compute the first Lagrangian and dissipation derivative terms.
dLawdw1 = diff( Law, w1 ); dLawdw1 = simplify( dLawdw1 );
dLawdw2 = diff( Law, w2 ); dLawdw2 = simplify( dLawdw2 );
dLawdw3 = diff( Law, w3 ); dLawdw3 = simplify( dLawdw3 );

dCawdw1 = diff( Caw, w1 ); dCawdw1 = simplify( dCawdw1 );
dCawdw2 = diff( Caw, w2 ); dCawdw2 = simplify( dCawdw2 );
dCawdw3 = diff( Caw, w3 ); dCawdw3 = simplify( dCawdw3 );

dLawda1 = diff( Law, a1 ); dLawda1 = simplify( dLawda1 );
dLawda2 = diff( Law, a2 ); dLawda2 = simplify( dLawda2 );
dLawda3 = diff( Law, a3 ); dLawda3 = simplify( dLawda3 );

% Reestablish the time dependence terms.
dLddtheta1 = subs( dLawdw1, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dLddtheta2 = subs( dLawdw2, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dLddtheta3 = subs( dLawdw3, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

dCddtheta1 = subs( dCawdw1, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dCddtheta2 = subs( dCawdw2, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dCddtheta3 = subs( dCawdw3, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

dLdtheta1 = subs( dLawda1, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dLdtheta2 = subs( dLawda2, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
dLdtheta3 = subs( dLawda3, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

% Compute the second Lagrangian derivative terms.
dLdtddtheta1 = diff( dLddtheta1, t ); dLdtddtheta1 = simplify( dLdtddtheta1 );
dLdtddtheta2 = diff( dLddtheta2, t ); dLdtddtheta2 = simplify( dLdtddtheta2 );
dLdtddtheta3 = diff( dLddtheta3, t ); dLdtddtheta3 = simplify( dLdtddtheta3 );

% Substitute in convenient angle derivative variables.
dLdtddtheta1 = subs( dLdtddtheta1, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ), diff( dtheta1( t ), t ) diff( dtheta2( t ), t ) diff( dtheta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
dLdtddtheta2 = subs( dLdtddtheta2, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ), diff( dtheta1( t ), t ) diff( dtheta2( t ), t ) diff( dtheta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
dLdtddtheta3 = subs( dLdtddtheta3, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ), diff( dtheta1( t ), t ) diff( dtheta2( t ), t ) diff( dtheta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );

% Compute the equations of motion.
eq1 = dLdtddtheta1 + dCddtheta1 - dLdtheta1 == tau1;
eq2 = dLdtddtheta2 + dCddtheta2 - dLdtheta2 == tau2;
eq3 = dLdtddtheta3 + dCddtheta3 - dLdtheta3 == tau3;

% Substitute in state variables.
eq1 = subs( eq1, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eq2 = subs( eq2, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eq3 = subs( eq3, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );

% Solve the system of equations for the relevant state variables.
sol = solve( [ eq1 eq2 eq3 ], [ du2 du4 du6 ] );

% Define the dynamical system flow.
du1 = u2;
du2 = sol.du2; %du2 = simplify( du2 );
du3 = u4;
du4 = sol.du4; %du4 = simplify( du4 );
du5 = u6;
du6 = sol.du6; %du6 = simplify( du6 );


%% Define the Numerical Triple Pendulum Dynamics.

% Define the pendulum geometry.
L1_value = 1;
L2_value = 1;
L3_value = 1;

R1_value = L1_value/2;
R2_value = L2_value/2;
R3_value = L3_value/2;

% Define the pendulum dynamic properties.
% m1_value = 1;
% m2_value = 1;
% m3_value = 1;

m1_value = 5;
m2_value = 5;
m3_value = 5;

% c1_value = 0;
% c2_value = 0;
% c3_value = 0;

c1_value = 1;
c2_value = 1;
c3_value = 1;

k1_value = 0;
k2_value = 0;
k3_value = 0;

theta1o_value = ( pi/180 )*135;
theta2o_value = ( pi/180 )*135;
theta3o_value = ( pi/180 )*135;

% Define universal constants.
g_value = 9.81;

% Substitute numerical values into the kinematics equations.
x1_value = subs( x1, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y1_value = subs( y1, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

x2_value = subs( x2, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y2_value = subs( y2, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

x3_value = subs( x3, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y3_value = subs( y3, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

x_knee_value = subs( x_knee, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y_knee_value = subs( y_knee, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

x_ankle_value = subs( x_ankle, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y_ankle_value = subs( y_ankle, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

x_foot_value = subs( x_foot, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
y_foot_value = subs( y_foot, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );


% Create anonymous functions for the kinematic equations.
fx1_temp = matlabFunction( subs( x1_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx1 = @( t, u ) fx1_temp( t, u(1) );
fy1_temp = matlabFunction( subs( y1_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy1 = @( t, u ) fy1_temp( t, u(1) );

fx2_temp = matlabFunction( subs( x2_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx2 = @( t, u ) fx2_temp( t, u(1), u(3) );
fy2_temp = matlabFunction( subs( y2_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy2 = @( t, u ) fy2_temp( t, u(1), u(3) );

fx3_temp = matlabFunction( subs( x3_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx3 = @( t, u ) fx3_temp( t, u(1), u(3), u(5) );
fy3_temp = matlabFunction( subs( y3_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy3 = @( t, u ) fy3_temp( t, u(1), u(3), u(5) );

fx_knee_temp = matlabFunction( subs( x_knee_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx_knee = @( t, u ) fx_knee_temp( t, u(1) );
fy_knee_temp = matlabFunction( subs( y_knee_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy_knee = @( t, u ) fy_knee_temp( t, u(1) );

fx_ankle_temp = matlabFunction( subs( x_ankle_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx_ankle = @( t, u ) fx_ankle_temp( t, u(1), u(3) );
fy_ankle_temp = matlabFunction( subs( y_ankle_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy_ankle = @( t, u ) fy_ankle_temp( t, u(1), u(3) );

fx_foot_temp = matlabFunction( subs( x_foot_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fx_foot = @( t, u ) fx_foot_temp( t, u(1), u(3), u(5) );
fy_foot_temp = matlabFunction( subs( y_foot_value, [ theta1 theta2 theta3 ], [ u1 u3 u5 ] ) ); fy_foot = @( t, u ) fy_foot_temp( t, u(1), u(3), u(5) );


% Substitute numerical values into the dynamical system flow.
du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );
du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 m1 m2 m3 c1 c2 c3 k1 k2 k3 theta1o theta2o theta3o g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value c1_value c2_value c3_value k1_value k2_value k3_value theta1o_value theta2o_value theta3o_value g_value ] );

% Create anonymous functions from the dynamical system flow components.
fdu1_temp = matlabFunction( du1_value ); fdu1 = @( t, u, tau ) fdu1_temp( u(2) );
fdu2_temp = matlabFunction( du2_value ); fdu2 = @( t, u, tau ) fdu2_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu3_temp = matlabFunction( du3_value ); fdu3 = @( t, u, tau ) fdu3_temp( u(4) );
fdu4_temp = matlabFunction( du4_value ); fdu4 = @( t, u, tau ) fdu4_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu5_temp = matlabFunction( du5_value ); fdu5 = @( t, u, tau ) fdu5_temp( u(6) );
fdu6_temp = matlabFunction( du6_value ); fdu6 = @( t, u, tau ) fdu6_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu = @( t, u, tau ) [ fdu1( t, u, tau ); fdu2( t, u, tau ); fdu3( t, u, tau ); fdu4( t, u, tau ); fdu5( t, u, tau ); fdu6( t, u, tau ) ];


%% Simulate the Triple Pendulum Dynamics.

% Define the simulation duration.
tf = 30;

% Define the applied torques.
taus = zeros( 3, 1 );

% Define the initial joint angles.
% theta0s = ( pi/180 )*[ 90; 180; 180 ];    % theta1 \in [0, 90], theta2 \in [0, 180], theta3 \in [0, 180]
% theta0s = ( pi/180 )*[ 0; 180; 180 ];
% theta0s = ( pi/180 )*[ 90; 180; 90 ];
theta0s = ( pi/180 )*[ 225; 180; 180 ];

% Define the initial joint angular velocities.
w0s = zeros( 3, 1 );

% Assemble the state variable initial condition.
u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ); ];

% Simulate the triple pendulum dynamics.
% [ ts, us ] = ode113( @( t, u ) fdu( t, u, taus ), [ 0 tf ], u0s );
% [ ts, us ] = ode45( @( t, u ) fdu( t, u, taus ), [ 0 tf ], u0s );
[ ts, us ] = ode15s( @( t, u ) fdu( t, u, taus ), [ 0 tf ], u0s );


%% Compute Center-Of-Mass Trajectories.

% Post-process the simulation results.
us( :, [ 1 3 5 ] ) = mod( us( :, [ 1 3 5 ] ), 2*pi );

dt_avg = mean( diff( ts ) );
ts_sample = 0:dt_avg:tf;
us_sample = interp1( ts, us, ts_sample );

% Retrieve the number of timesteps.
num_timesteps = length( ts_sample );

% Preallocate arrays to store the kinematic results.
[ xs1, ys1, xs2, ys2, xs3, ys3, xs_knee, ys_knee, xs_ankle, ys_ankle, xs_foot, ys_foot ] = deal( zeros( num_timesteps, 1 ) );

% Compute the center of mass trajectories.
for k = 1:num_timesteps                     % Iterate through all of the timesteps...
    
    % Compute the center of mass locations.
    xs1( k ) = fx1( ts_sample( k ), us_sample( k, : ) );
    ys1( k ) = fy1( ts_sample( k ), us_sample( k, : ) );
    
    xs2( k ) = fx2( ts_sample( k ), us_sample( k, : ) );
    ys2( k ) = fy2( ts_sample( k ), us_sample( k, : ) );
    
    xs3( k ) = fx3( ts_sample( k ), us_sample( k, : ) );
    ys3( k ) = fy3( ts_sample( k ), us_sample( k, : ) );
    
    % Compute the joint locations.
    xs_knee( k ) = fx_knee( ts_sample( k ), us_sample( k, : ) );
    ys_knee( k ) = fy_knee( ts_sample( k ), us_sample( k, : ) );
    
    xs_ankle( k ) = fx_ankle( ts_sample( k ), us_sample( k, : ) );
    ys_ankle( k ) = fy_ankle( ts_sample( k ), us_sample( k, : ) );
    
    xs_foot( k ) = fx_foot( ts_sample( k ), us_sample( k, : ) );
    ys_foot( k ) = fy_foot( ts_sample( k ), us_sample( k, : ) );
    
end


%% Plot the Triple Pendulum Simulation Results.

% Create a figure to store the triple pendulum states over time.
figure( 'Color', 'w', 'Name', 'Triple Pendulum States vs Time' )
subplot( 2, 1, 1 ), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angles [deg]'), title('Pendulum Angle vs Time'), ylim( [ 0 360 ] )
plot( ts, ( 180/pi )*us( :, 1 ), '-', 'Linewidth', 3 ), plot( ts, ( 180/pi )*us( :, 3 ), '-', 'Linewidth', 3 ), plot( ts, ( 180/pi )*us( :, 5 ), '-', 'Linewidth', 3 )

subplot( 2, 1, 2 ), hold on, grid on, xlabel('Time [s]'), ylabel('Pendulum Angular Velocities [deg/s]'), title('Pendulum Angular Velocities vs Time')
plot( ts, ( 180/pi )*us( :, 2 ), '-', 'Linewidth', 3 ), plot( ts, ( 180/pi )*us( :, 4 ), '-', 'Linewidth', 3 ), plot( ts, ( 180/pi )*us( :, 6 ), '-', 'Linewidth', 3 )

% Create a figure to store an animation of the simulation results.
figure( 'Color', 'w', 'Name', 'Triple Pendulum Animation' ), hold on, grid on, xlabel('x [in]'), ylabel('y [in]'), title('Triple Pendulum Animation'), axis( 39.3701*[ -( L1_value + L2_value + L3_value ), L1_value + L2_value + L3_value, -( L1_value + L2_value + L3_value ), L1_value + L2_value + L3_value ] )

% Create variables to store the bar points.
[ xs_bar, ys_bar ] = deal( zeros( 4, 1 ) );
[ xs_com, ys_com ] = deal( zeros( 3, 1 ) );

% Create templates for the animation.
h1 = plot( xs_bar, ys_bar, '.-', 'Linewidth', 3, 'Markersize', 20, 'XDataSource', 'xs_bar', 'YDataSource', 'ys_bar' );
h2 = plot( xs_com, ys_com, '.', 'Markersize', 20, 'XDataSource', 'xs_com', 'YDataSource', 'ys_com' );

% Define the number of playbacks.
num_playbacks = 10;

% Animate each of the simulation states.
for k1 = 1:num_playbacks                 % Iterate through each of the playbacks...
    for k2 = 1:num_timesteps                 % Iterate through each of the timesteps...
        
        xs_bar = 39.3701*[ 0; -xs_knee( k2 ); -xs_ankle( k2 ); -xs_foot( k2 ) ];
        ys_bar = 39.3701*[ 0; -ys_knee( k2 ); -ys_ankle( k2 ); -ys_foot( k2 ) ];
        
        xs_com = 39.3701*[ -xs1( k2 ); -xs2( k2 ); -xs3( k2 ) ];
        ys_com = 39.3701*[ -ys1( k2 ); -ys2( k2 ); -ys3( k2 ) ];
        
        refreshdata( [ h1 h2 ] )
        drawnow(  )
        
        pause( 1e-2 )
        
    end
end



