%% Derive system of equations
% Symbolically solves equations of motion. 
% Theta value were altered, and so coordinate designation was also changed.

clear;close all;%clc;

% Define symbolic variables used in EOM
syms M1 M2 M3;
syms theta1(t) dtheta1(t) ddtheta1(t) theta2(t) dtheta2(t) ddtheta2(t) theta3(t) dtheta3(t) ddtheta3(t);
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms k1 k2 k3 k4 k5 k6;
syms theta1bias theta2bias theta3bias theta4bias theta5bias theta6bias;
syms theta1rest theta2rest theta3rest;
syms I1 I2 I3;
syms mu1 mu2 mu3;
syms g;
syms a1 a2 a3 w1 w2 w3;
syms u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6;
syms tau1 tau2 tau3

% Define inertia values, modeling links as rods
I1 = (1/3)*M1*( L1^2 - 3*L1*R1 + 3*R1^2 );
I2 = (1/3)*M2*( L2^2 - 3*L2*R2 + 3*R2^2 );
I3 = (1/3)*M3*( L3^2 - 3*L3*R3 + 3*R3^2 );

% Coordinates of center of masses of each point of 3-link pendulum. Theta
% values are measured between the negative horizontal (right direction) and
% the back of the thigh, the back of the thigh to the back of the calf, and
% the front of the shin to the top of the foot, respectively.
p1x = R1 * cos(pi - theta1(t));
p1y = R1 * sin(pi - theta1(t));
p2x = L1 * cos(pi - theta1(t)) + R2 * cos(-(theta1(t) + theta2(t)));
p2y = L1 * sin(pi - theta1(t)) + R2 * sin(-(theta1(t) + theta2(t)));
p3x = L1 * cos(pi - theta1(t)) + L2 * cos(-(theta1(t) + theta2(t))) + R3 * cos(theta3(t) - (theta1(t) + theta2(t)) + pi);
p3y = L1 * sin(pi - theta1(t)) + L2 * sin(-(theta1(t) + theta2(t))) + R3 * sin(theta3(t) - (theta1(t) + theta2(t)) + pi);

% First derivative of each point
v1 = sqrt(diff(p1x, t)^2 + diff(p1y, t)^2);
v2 = sqrt(diff(p2x, t)^2 + diff(p2y, t)^2);
v3 = sqrt(diff(p3x, t)^2 + diff(p3y, t)^2);

v1 = subs( v1, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 
v2 = subs( v2, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 
v3 = subs( v3, [ diff( theta1( t ), t ) diff( theta2( t ), t ) diff( theta3( t ), t ) ], [ dtheta1 dtheta2 dtheta3 ] ); 

% friction values
D1 = u1*M1*g*R1*dtheta1(t);
D2 = u2*M2*g*R2*dtheta2(t);
D3 = u3*M3*g*R3*dtheta3(t);

% Kinetic Energy equation
KE1 = 0.5*M1*(v1.^2) + 0.5*I1*(dtheta1(t)).^2; KE1 = simplify(KE1);
KE2 = 0.5*M2*(v2^2) + 0.5*I2*(dtheta2(t))^2; KE2 = simplify(KE2);
KE3 = 0.5*M3*(v3^2) + 0.5*I3*(dtheta3(t))^2; KE3 = simplify(KE3);
KE = KE1 + KE2 + KE3;

% Define thetabias values based on k values
eq_thetabias1 = k1 * (theta1rest - theta1bias) - k2 * (theta2rest - theta2bias) - k3 * (theta3bias - theta3rest) + g * ( M1 * R1 * sin(theta1rest - pi/2) + M2 * sin(theta1rest - pi/2) * (L1 + R2 * cos(pi-theta2rest)) + M3 * sin(theta1rest-pi/2) * (L1 + L2 * cos(pi-theta2rest) + R3) ) == 0;
eq_thetabias2 = k2 * (theta2rest - theta2bias) - k3 * (theta3bias - theta3rest) - g * ( M2 * R2 * cos(theta1rest - pi + theta2rest) + M3 * cos(theta1rest - pi + theta2rest) * (L2 + R3 * cos(pi - theta3rest)) ) == 0;
eq_thetabias3 = k3 * (theta3bias - theta3rest) - g * ( M3 * R3 * sin(pi/2 - theta1rest - theta2rest + theta3rest) ) == 0;

Sol_thetabias = solve( [ eq_thetabias1 eq_thetabias2 eq_thetabias3 ], [ theta1bias theta2bias theta3bias ] );

theta1bias = Sol_thetabias.theta1bias;
theta2bias = Sol_thetabias.theta2bias;
theta3bias = Sol_thetabias.theta3bias;


% Potential energy - modified. 
% define horizontal line at which the center of mass of the entire leg is
% at zero
m_tot = M1 + M2 + M3;
r_tot = (M1/m_tot)*R1 + (M2/m_tot)*(L1 + R2) + (M3/m_tot)*(L1 + L2 + R3);
PE1 = M1*g*(r_tot - p1y);
PE2 = M2*g*(r_tot - p2y);
PE3 = M3*g*(r_tot - p3y);
PE = simplify(PE1 + PE2 + PE3);

% Joint torques. Note that Joe's version had the u (friction values
% replaced with the commented out portion. Friction appeared to be unused
% in his model.
P1 = -b1*dtheta1(t) - k1*(theta1(t)-theta1bias) - mu1*sign(dtheta1(t));%(b4*dtheta1(t)+K4*(theta1(t)+theta4bias));
P2 = -b2*dtheta2(t) - k2*(theta2(t)-theta2bias) - mu2*sign(dtheta2(t));%(b5*dtheta1(t)+K5*(theta1(t)+theta5bias));
P3 = -b3*dtheta3(t) - k3*(theta3(t)-theta3bias) - mu3*sign(dtheta3(t));%(b6*dtheta1(t)+K6*(theta1(t)+theta6bias));

% Lagrangian formulation
L = simplify(KE - PE);

% Subsitute in non-time dependent variables for KE and PE
L_sub = subs( L, [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ], [ a1 a2 a3 w1 w2 w3 ] );

% Partial derivative of L with respect to theta (SUBBED)
pL_ptheta1_sub = simplify(diff(L_sub, a1));
pL_ptheta2_sub = simplify(diff(L_sub, a2));
pL_ptheta3_sub = simplify(diff(L_sub, a3));

% Partial derivative of L with respect to theta dot (SUBBED)
pL_pdtheta1_sub = simplify(diff(L_sub, w1));
pL_pdtheta2_sub = simplify(diff(L_sub, w2));
pL_pdtheta3_sub = simplify(diff(L_sub, w3));


% Subsitute BACK in time dependent variables for L
pL_ptheta1 = subs( pL_ptheta1_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_ptheta2 = subs( pL_ptheta2_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_ptheta3 = subs( pL_ptheta3_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

pL_pdtheta1 = subs( pL_pdtheta1_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_pdtheta2 = subs( pL_pdtheta2_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );
pL_pdtheta3 = subs( pL_pdtheta3_sub, [ a1 a2 a3 w1 w2 w3 ], [ theta1 theta2 theta3 dtheta1 dtheta2 dtheta3 ] );

% Compute the derivative with respect to time of the partial derivative of
% L with respect to theta dot
d_dt_pL_pdtheta1 = simplify(diff(pL_pdtheta1, t));
d_dt_pL_pdtheta2 = simplify(diff(pL_pdtheta2, t));
d_dt_pL_pdtheta3 = simplify(diff(pL_pdtheta3, t));


% Substitute in convenient angle derivative variables.
d_dt_pL_pdtheta1 = subs(d_dt_pL_pdtheta1, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
d_dt_pL_pdtheta2 = subs(d_dt_pL_pdtheta2, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );
d_dt_pL_pdtheta3 = subs(d_dt_pL_pdtheta3, [ diff(theta1(t), t ) diff(theta2(t), t ) diff(theta3(t), t ), diff(dtheta1(t), t ) diff(dtheta2(t), t ) diff(dtheta3(t), t ) ], [ dtheta1 dtheta2 dtheta3 ddtheta1 ddtheta2 ddtheta3 ] );


% Create system of equations from Lagrangian derivations
eqx1 = simplify( d_dt_pL_pdtheta1 - pL_ptheta1 - P1) == tau1;
eqx2 = simplify( d_dt_pL_pdtheta2 - pL_ptheta2 - P2) == tau2;
eqx3 = simplify( d_dt_pL_pdtheta3 - pL_ptheta3 - P3) == tau3;

% Substitute in state variables.
eqx1 = subs( eqx1, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eqx2 = subs( eqx2, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );
eqx3 = subs( eqx3, [ theta1 dtheta1 ddtheta1 theta2 dtheta2 ddtheta2 theta3 dtheta3 ddtheta3 ], [ u1 u2 du2 u3 u4 du4 u5 u6 du6 ] );

% Solve the system of equations for the relevant state variables.
Sol = solve( [ eqx1 eqx2 eqx3 ], [ du2 du4 du6 ] );
Sol.du2 = simplify(Sol.du2);
Sol.du4 = simplify(Sol.du4);
Sol.du6 = simplify(Sol.du6);

% Define the dynamical system flow.
du1 = u2;
du2 = Sol.du2; %du2 = simplify( du2 );
du3 = u4;
du4 = Sol.du4; %du4 = simplify( du4 );
du5 = u6;
du6 = Sol.du6; %du6 = simplify( du6 );




%% Define the Numerical Triple Pendulum Dynamics.

% Define the mechanical properties of link 1.
m1_value = 0.001 * 13.26;                   % [kg]                 
R1_value = 0.01 * 1.305;                    % [m]
L1_value = 0.01 * 2.9;                      % [m]
b1_value = 0.005355785617948;                            % [Ns/m]
mu1_value = 1.329240672957200e-10;
k1_value = 0.062509709895451;                               % [N/m]
theta1rest_value = deg2rad(105);             % [rad]

% Define the mechanical properties of link 2.
m2_value = 0.001 * 9.06;                    % [kg]
R2_value = 0.01 * 1.558;                    % [m]
L2_value = 0.01 * 4.1;                      % [m]
b2_value = 0.01;                            % [Ns/m]
mu2_value = 1.245141590332877e-19;                            % [Ns/m]
k2_value = 0.099945713155010;                               % [N/m]
theta2rest_value = deg2rad(117);             % [rad]

% Define the mechanical properties of link 3.
m3_value = 0.001 * 1.7;                     % [kg]
R3_value = 0.01 * 1.6;                      % [m]
L3_value = 0.01 * 3.3;                      % [m]
b3_value = 0.001424727087787;                            % [Ns/m]
mu3_value = 4.266130533124647e-37;
k3_value = 0.1;                               % [N/m]
theta3rest_value = deg2rad(140);             % [rad]d]

% Define universal constants.
g_value = 9.81;                             % [m/s^2]




% Substitute numerical values into the dynamical system flow.
du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );



% Create anonymous functions from the dynamical system flow components.
fdu1_temp = matlabFunction( du1_value ); fdu1 = @( t, u, tau ) fdu1_temp( u(2) );
fdu2_temp = matlabFunction( du2_value ); fdu2 = @( t, u, tau ) fdu2_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu3_temp = matlabFunction( du3_value ); fdu3 = @( t, u, tau ) fdu3_temp( u(4) );
fdu4_temp = matlabFunction( du4_value ); fdu4 = @( t, u, tau ) fdu4_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu5_temp = matlabFunction( du5_value ); fdu5 = @( t, u, tau ) fdu5_temp( u(6) );
fdu6_temp = matlabFunction( du6_value ); fdu6 = @( t, u, tau ) fdu6_temp( tau(1), tau(2), tau(3), u(1), u(2), u(3), u(4), u(5), u(6) );
fdu = @( t, u, tau ) [ fdu1( t, u, tau ); fdu2( t, u, tau ); fdu3( t, u, tau ); fdu4( t, u, tau ); fdu5( t, u, tau ); fdu6( t, u, tau ) ];


% Substitute numerical values into the Lagrangian energy components.
KE1_value = subs( KE1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
KE2_value = subs( KE2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
KE3_value = subs( KE3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );

PE1_value = subs( PE1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
PE2_value = subs( PE2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );
PE3_value = subs( PE3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 theta1rest theta2rest theta3rest g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value theta1rest_value theta2rest_value theta3rest_value g_value ] );


% Create anonymous functions from the Lagrangian energy components.
fKE1_temp = matlabFunction( subs( KE1_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fKE1 = @( t, u ) fKE1_temp( t, u(2) );
fKE2_temp = matlabFunction( subs( KE2_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fKE2 = @( t, u ) fKE2_temp( t, u(2), u(3), u(4) );
fKE3_temp = matlabFunction( subs( KE3_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fKE3 = @( t, u ) fKE3_temp( t, u(1), u(2), u(3), u(4), u(5), u(6) );
fKE = @( t, u ) fKE1( t, u ) + fKE2( t, u ) + fKE3( t, u );

fPE1_temp = matlabFunction( subs( PE1_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fPE1 = @( t, u ) fPE1_temp( t, u(1) );
fPE2_temp = matlabFunction( subs( PE2_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fPE2 = @( t, u ) fPE2_temp( t, u(1), u(3) );
fPE3_temp = matlabFunction( subs( PE3_value, [ theta1 dtheta1 theta2 dtheta2 theta3 dtheta3 ], [ u1 u2 u3 u4 u5 u6 ] ) ); fPE3 = @( t, u ) fPE3_temp( t, u(1), u(3), u(5) );
fPE = @( t, u ) fPE1( t, u ) + fPE2( t, u ) + fPE3( t, u );

fL = @( t, u ) fKE( t, u ) - fPE( t, u );

fEtotal = @( t, u ) fT( t, u ) + fV( t, u );


%% Simulate the Triple Pendulum Dynamics.

% Define the simulation duration.
tf = 10;

% Define the applied torques.
taus = zeros( 3, 1 );

% Define the initial joint angles.
theta0s = ( pi/180 )*[ 30; 160; 90 ];

% Define the initial joint angular velocities.
%w0s = zeros( 3, 1 );
w0s = [-14.310489390171824; 12.633931937282568; -9.174690528604970];

% Assemble the state variable initial condition.
u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ); ];

% Simulate the triple pendulum dynamics.
% [ t, x ] = ode45( @( t, u ) fdu( t, u, taus ), [ 0 tf ], u0s );
[ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), [ 0 tf ], u0s );



%% Animation

% Create a figure to store the animation.
fig_animation = figure('Color', 'w', 'Name', 'Robot Animation'); hold on, view(180, 90), xlabel('x'), ylabel('y')                                    
axis equal
xlim([-0.15 0.15])
ylim([-0.15 0.15])


% Define theta values
theta1 = x(:,1);
theta2 = x(:,3);
theta3 = x(:,5);

% Now define center of masses in x-y coordinates
m1(:,1) = R1 * cos(pi - theta1);
m1(:,2) = R1 * sin(pi - theta1);
m2(:,1) = L1 * cos(pi - theta1) + R2 * cos(-(theta1 + theta2));
m2(:,2) = L1 * sin(pi - theta1) + R2 * sin(-(theta1 + theta2));
m3(:,1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2)) + R3 * cos(theta3 - (theta1 + theta2) + pi);
m3(:,2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2)) + R3 * sin(theta3 - (theta1 + theta2) + pi);

% Define joint locations for plotting uses
knee = (m1/R1)*L1;
ankle(:,1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2));
ankle(:,2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2));
toe(:,1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2)) + L3 * cos(theta3 - (theta1 + theta2) + pi);
toe(:,2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2)) + L3 * sin(theta3 - (theta1 + theta2 + pi));

% Substitute in numerical values
ankle = subs(ankle, [L1 L2 L3 R1 R2 R3], [L1_value L2_value L3_value R1_value R2_value R3_value]);
knee = subs(knee, [L1 L2 L3 R1 R2 R3], [L1_value L2_value L3_value R1_value R2_value R3_value]);
toe = subs(toe, [L1 L2 L3 R1 R2 R3], [L1_value L2_value L3_value R1_value R2_value R3_value]);

% Create a graphics object for the knee
hip = zeros(length(t), 2);
hip_plot = plot(0, 0, '.r', 'Markersize', 20, 'XDataSource', 'hip(k,1)', 'YDataSource', 'hip(k,2)');

% Create a graphics object for the knee
knee_plot = plot(0, 0, '.r', 'Markersize', 20, 'XDataSource', 'knee(k,1)', 'YDataSource', 'knee(k,2)');

% Create a graphics object for the ankle
ankle_plot = plot(0, 0, '.r', 'Markersize', 20, 'XDataSource', 'ankle(k,1)', 'YDataSource', 'ankle(k,2)');

% Create a graphics object for the toe
toe_plot = plot(0, 0, '.r', 'Markersize', 20, 'XDataSource', 'toe(k,1)', 'YDataSource', 'toe(k,2)');



% Set the number of animation playbacks.
num_playbacks = 1;

% Retrieve the number of time steps.
num_timesteps = length(t);

% % Initialize a video object.
myVideo = VideoWriter('RobotAnimation'); %open video file
myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
open(myVideo)


% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back    
    for k = 1:10:num_timesteps               % Iterate through each of the angles
        
        % Note: I've been defining num_timesteps such that the total time
        % to play is approximately equivalent to the time span designated.
        % This has been done manually.
        
        % Refresh the plot data.
        refreshdata([knee_plot; ankle_plot; toe_plot], 'caller')
        
        % Update the plot.
        drawnow
        
        % Write the current frame to the file.
         writeVideo(myVideo, getframe(gcf));


    end
end

% % Close the video object.
close(myVideo)


%% 1-link pendulum check
% % Check to see if 3L pendulum with knee and ankle locked out has same
% % period as expected for a 1L pendulum
% m_tot = M1 + M2 + M3;
% r_tot = (M1/m_tot)*R1 + (M2/m_tot)*(L1 + R2) + (M3/m_tot)*(L1 + L2 + R3);
% I_tot = (1/3) * m_tot* (2*r_tot)^2;
% T_expected = 2 * pi * sqrt(I_tot/(m_tot*g*r_tot));
% fprintf('\nExpected period:\n')
% disp(T_expected)

% Plot joint angle of all joints
figure
plot(t,rad2deg(theta1), '-k', 'LineWidth', 2); hold on
plot(t,rad2deg(theta2), '-r', 'LineWidth', 2)
plot(t,rad2deg(theta3), '-b', 'LineWidth', 2)
title('Unloaded spring angle calculation test')
xlabel('Time (s)')
ylabel('Angle (deg)')

% Make and plot expected resting values
expected1 = rad2deg(theta1rest_value * ones(1, length(theta1)));
expected2 = rad2deg(theta2rest_value * ones(1, length(theta2)));
expected3 = rad2deg(theta3rest_value * ones(1, length(theta3)));

plot(t, expected1, ':k', 'LineWidth', 2)
plot(t, expected2, ':r', 'LineWidth', 2)
plot(t, expected3, ':b', 'LineWidth', 2)
legend('Hip', 'Knee', 'Ankle', 'Expected resting hip', 'Expected resting knee', 'Expected resting ankle')
ylim([0 180])
xlim([0 2])


% % Display period of first joint
% [pks, loc] = findpeaks(x(:,1),t);
% loc;
% Calc_period = mean(diff(loc))

set(gcf,'color','white')