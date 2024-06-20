function cost = cost_calc_damp(U, data, joint)

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
syms I1 I2 I3;
syms g;
syms a1 a2 a3 w1 w2 w3;
syms u1 u2 u3 u4 u5 u6 du1 du2 du3 du4 du5 du6;
syms tau1 tau2 tau3

% De-compile non-optimized variables from single structure
dui = data.dui;
DampData = data.DampData;
set_var = data.set_var;

m1_value = data.sysProp.m1_value; m2_value = data.sysProp.m2_value; m3_value = data.sysProp.m3_value;
R1_value = data.sysProp.R1_value; R2_value = data.sysProp.R2_value; R3_value = data.sysProp.R3_value;
L1_value = data.sysProp.L1_value; L2_value = data.sysProp.L2_value; L3_value = data.sysProp.L3_value;


% Create array of b values to use
b = [U set_var(2) set_var(3); set_var(1) U set_var(3); set_var(1) set_var(2) U];

%% Assign mechanical properties

b1_value = b(joint,1);
b2_value = b(joint,2);
b3_value = b(joint,3);

% Define time
T = DampData.time;

% Define universal constants.
g_value = 9.81;                             % [m/s^2]

% Define a cost vector
cost_trial = zeros( 8, 1 );

for n = 1:8
    
    if joint == 1
        thetas = DampData.hip_dat; 
        time = T.hip;
    elseif joint == 2
        thetas = DampData.knee_dat; 
        time = T.knee;
    else
        thetas = DampData.ankle_dat;
        time = T.ankle;
    end
        
    % Assign equations of motion
    du1 = dui(1); 
    du2 = dui(2); 
    du3 = dui(3); 
    du4 = dui(4); 
    du5 = dui(5); 
    du6 = dui(6);


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
    theta0s = [thetas(1,((n-1)*3 +1)), thetas(1,((n-1)*3 +2)), thetas(1,((n-1)*3 +3))];
    
    % Calculate initial joint angular velocity
    w0s = zeros(3, 1);
   
    % Assemble the state variable initial condition.
    u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ) ];

    % Simulate the triple pendulum dynamics.
    % [ t, x ] = ode45( @( t, u ) fdu( t, u, taus ), time, u0s );
    [ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), time, u0s );


%     %% Calculate cost by point comparison
%     
%     % Calculating error in individual points to find cost value for this
%     % specific muscle in this iteration
%     err = x( :,(joint*2-1) ) - thetas( :,((n-1)*3 + joint) );
%     cost_trial(n) = sum(err.^2);

    %% Calculate cost by risetime

    rt_ode = risetime_ek(x( :,(joint*2-1) ),t);
    rt_data = risetime_ek(thetas( :,((n-1)*3 + joint) ),time);

    cost_trial(n) = abs(rt_ode - rt_data);

end

% Calculate cost of the iteration from all seven muscle trials
cost = sum(cost_trial);


end
