function pbest_err = f_epoch_bot(X, iteration, data, joint)

% Choose value to subsitute for any parameter calulcated to be NaN
% (approximate to zero). Band-aid for issue when optimizer has a parameter
% with a very low value and eventually results in NaN and screws up ODE.
NaN_sub = 1e-20;
X(isnan(X)) = NaN_sub;

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
syms theta1rest theta2rest theta3rest

% De-compile non-optimized variables from single structure
dui                    = data.dui;
thetabias_sym          = data.thetabias_sym;
time_step              = data.time_step; 
Data                   = data.Data; 
IC_data                = data.IC_data;


% Assign correct data variable according to joint
if joint == 1
    Data = Data.Hip_dat;
    time = data.Data.time.hip;
    
elseif joint == 2
    Data = Data.knee_dat;
    time = data.Data.time.knee;
    
elseif joint == 3
    Data = Data.ankle_dat;
    time = data.Data.time.ankle;
    
end
        
m1_value = data.sysProp.m1_value; m2_value = data.sysProp.m2_value; m3_value = data.sysProp.m3_value;
R1_value = data.sysProp.R1_value; R2_value = data.sysProp.R2_value; R3_value = data.sysProp.R3_value;
L1_value = data.sysProp.L1_value; L2_value = data.sysProp.L2_value; L3_value = data.sysProp.L3_value;

% Create pbest_err array to save error between simulation and actual data
pbest_err = zeros(length(X), 1);

% Start looping through particles
for m = 1:length(X)
    
    
    %% Assign mechanical properties
    mu1_value = 0;                          % [Ns/m]
    mu2_value = 0;                          % [Ns/m]
    mu3_value = 0;                          % [Ns/m]
    
    % Assign mechanical properties based on which joint is being solved for
    % assuming we begin with the ankle and work our way up
    if joint == 1
        b1_value = X(m,1);                         % [Ns/m]
        k1_value = X(m,2);                         % [N/m]
        b2_value = SOLB2;                          % [Ns/m]
        k2_value = SOLK2;                          % [N/m]
        b3_value = SOLB1;                          % [Ns/m]
        k3_value = SOLK1;                          % [N/m]
        
    elseif joint == 2
        b1_value = IC_data(2) * 1000;                 % [Ns/m]
        k1_value = IC_data(2);                     % [N/m]
        b2_value = X(m,1);                         % [Ns/m]
        k2_value = X(m,2);                         % [N/m]
        b3_value = SOLB1;                          % [Ns/m]
        k3_value = SOLK1;                          % [N/m]      
        
    elseif joint == 3  
        b1_value = IC_data(3) * 1000;                 % [Ns/m]
        k1_value = IC_data(3);                     % [N/m]
        b2_value = IC_data(3) * 1000;                 % [Ns/m]
        k2_value = IC_data(3);                     % [N/m]
        b3_value = X(m, 1);                        % [Ns/m]
        k3_value = X(m, 2);                        % [N/m]
    end
    
                           

    % Define universal constants.
    g_value = 9.81;                         % [m/s^2]
    
    % Create arrays to save muscle data in 
    risetime_sim        = zeros(length(Data(1,:))/3,1);
    omega_sim           = zeros(length(Data(1,:))/3,1);
    pk_diff             = zeros(length(Data(1,:))/3,1);
    locs_diff           = zeros(length(Data(1,:))/3,1);
    risetime_exp        = zeros(length(Data(1,:))/3,1);
    omega_exp           = zeros(length(Data(1,:))/3,1);
    
    % start looping through trials
    for n = 1:(length(Data(1,:))/3)

        %% Set-up data
        % Assign equations of motion
        du1 = dui(1); 
        du2 = dui(2); 
        du3 = dui(3); 
        du4 = dui(4); 
        du5 = dui(5); 
        du6 = dui(6);

        % Define which trial to use
        thetas = Data(:, (n*3-2):n*3);
        
        % Interpolate data so that risetime may be more accurate
        tt = 0:0.0001:time(end);
        a = spline(time, thetas(:,1), tt);
        b = spline(time, thetas(:,2), tt);
        c = spline(time, thetas(:,3), tt);
        thetas = [ a' b' c' ];

        % Define thetarest values
        theta1rest_value = thetas(end,1);
        theta2rest_value = thetas(end,2);
        theta3rest_value = thetas(end,3);


        %% Convert EOM to numerical values
        % Substitute numerical values into the dynamical system flow.
        du1_value = subs( du1, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        du2_value = subs( du2, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        du3_value = subs( du3, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        du4_value = subs( du4, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        du5_value = subs( du5, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        du6_value = subs( du6, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] );
        thetabias_val = double(subs( thetabias_sym, [ L1 L2 L3 R1 R2 R3 M1 M2 M3 b1 b2 b3 mu1 mu2 mu3 k1 k2 k3 g theta1rest theta2rest theta3rest ], [ L1_value L2_value L3_value R1_value R2_value R3_value m1_value m2_value m3_value b1_value b2_value b3_value mu1_value mu2_value mu3_value k1_value k2_value k3_value g_value theta1rest_value theta2rest_value theta3rest_value ] ));

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

        % Calculate initial joint angular velocity
        w0s = [ ( thetas(2,1) - thetas(1,1) ) ( thetas(2,2) - thetas(1,2) ) ( thetas(2,3) - thetas(1,3) ) ] / time_step;

        % Assemble the state variable initial condition.
        u0s = [ theta0s( 1 ); w0s( 1 ); theta0s( 2 ); w0s( 2 ); theta0s( 3 ); w0s( 3 ) ];

        % Simulate the triple pendulum dynamics.
        % [ t, x ] = ode45( @( t, u ) fdu( t, u, taus ), time, u0s );
        [ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), tt, u0s );


        %% Calculate risetime

        % Calculate the risetime for simulation and actual data. 
        risetime_sim(n) = risetime_ek(x(:,joint*2-1), t);
        risetime_exp(n) = risetime_ek(thetas(:,joint), t);
        
        %% Calculate frequency and damping

% Find peaks and location of sim response and actual response
        [pks_x, loc_x]              = findpeaks(x(:,joint*2-1));            [pks_xneg, loc_xneg] = (findpeaks(-x(:,joint*2-1)));   
        [pks_thetas, loc_thetas]    = findpeaks(thetas(:,joint));   [pks_thetasneg, loc_thetasneg] = (findpeaks(-thetas(:,joint)));
        
        % Consolidate into single array
        pks_x       = abs([pks_x' pks_xneg']);              loc_x = [loc_x' loc_xneg'];
        pks_thetas  = abs([pks_thetas' pks_thetasneg']);    loc_thetas = [loc_thetas' loc_thetasneg'];

        % sort peaks
        [loc_x, I_x]            = sort(loc_x, 'ascend');       pks_x = pks_x(I_x);
        [loc_thetas, I_thetas]  = sort(loc_thetas, 'ascend');  pks_thetas = pks_thetas(I_thetas);
        
        omega_thetas    = 2* pi * (0.002 * (loc_thetas(2) - loc_thetas(1)))^-1;
            
        if length(pks_x) > 1
            
            % Calculate frequency
            omega_x         = 2* pi * (0.002 * (loc_x(2) - loc_x(1)))^-1;
            
           % Adding variables to cost function
            pk_diff(n) = sum(abs(pks_thetas(1:2) - pks_x(1:2)));
            locs_diff(n) = sum(abs(loc_thetas(1:2) - loc_x(1:2)));
        else
            % if system is over/criticlly damped, assign arbitrarily low
            % omega_x and high zeta
            omega_x = 0.1;
            locs_diff(n) = 300;
            pk_diff(n) = 300;
        end
        
        % Save data into array
        omega_sim(n)    = omega_x;
        omega_exp(n)    = omega_thetas;
        
        
    end % end of trial loop (n)

    cost_freq   = sum(abs(omega_sim - omega_exp))/6000;
    cost_pk     = sum(pk_diff)/3000;
    cost_loc    = sum(locs_diff)/3000;
    cost_rt     = sum(abs(risetime_sim - risetime_exp));
    
    % Calculate total cost of particle
    pbest_err(m) = sum(cost_freq + cost_pk + cost_loc + cost_rt);
    
end % end of particle loop (m)



end % end of epoch
