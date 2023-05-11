function [ time_ode, thetas_ode, time, thetas ] = dynamics_func_no_springs(U, dui, joint, trial, systemProp, DampData)

%% Assign symbolic equations of motion

% State symbolic variables used in EOM solver
syms M1 M2 M3;
syms theta1(t) dtheta1(t) ddtheta1(t) theta2(t) dtheta2(t) ddtheta2(t) theta3(t) dtheta3(t) ddtheta3(t);
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms I1 I2 I3;
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

% Load the geometrical and mass values for the system.
load('-mat', 'MechPropDog2');

% Define the mechanical properties of link 1.
b1_value = U(4);                            % [Ns/m]

% Define the mechanical properties of link 2.
b2_value = U(5);                            % [Ns/m]

% Define the mechanical properties of link 3.
b3_value = U(6);                            % [Ns/m]                     

% Define universal constants.
g_value = 9.81;                             % [m/s^2]

if joint == 1
    thetas = DampData.hip_dat;
    
elseif joint == 2
    thetas = DampData.knee_dat;
    
elseif joint == 3
    thetas = DampData.ankle_dat;
end

% Define time
time = DampData.time;
%% Convert to numerical values
% Substitute numerical values into the dynamical system flow.
du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );
du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );
du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );
du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );
du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );
du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 g ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value g_value ] );


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
theta0s = [thetas(1,((trial-1)*3+1)), thetas(1,((trial-1)*3+2)), thetas(1,((trial-1)*3+3))];

% Define the initial joint angular velocities.
w0s = [U(1), U(2), U(3)];

% Assemble the state variable initial condition.
u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ); ];

% Simulate the triple pendulum dynamics.
% [ t, x ] = ode45( @( t, u ) fdu( t, u, taus ), time, u0s );
[ time_ode, thetas_ode ] = ode15s( @( t, u ) fdu( t, u, taus ), time, u0s );


end
