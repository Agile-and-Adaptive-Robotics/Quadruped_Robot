function pbest_err = f_epoch(X, iteration, data)

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
jdata                  = data.jdata;
thetabias_sym          = data.thetabias_sym;
muscles                = data.muscles;
trials                 = data.trials;
start_indices          = data.start_indices;
end_indices            = data.end_indices;
time_step              = data.time_step;
sysProp                = data.sysProp;
trial_value            = data.trial_value;              % indicator for which trials to place higher cost
set_vals               = data.set_vals; 

m1_value = data.sysProp.m1_value; m2_value = data.sysProp.m2_value; m3_value = data.sysProp.m3_value;
R1_value = data.sysProp.R1_value; R2_value = data.sysProp.R2_value; R3_value = data.sysProp.R3_value;
L1_value = data.sysProp.L1_value; L2_value = data.sysProp.L2_value; L3_value = data.sysProp.L3_value;

% Create pbest_err array to save error between simulation and actual data
pbest_err = zeros(length(X), 1);

% Start looping through particles
for m = 1:length(X)
    
    
    %% Assign mechanical properties
   
    b1_value = set_vals(1);                 % [Ns/m]
    k1_value = X(m, 1);                     % [N/m]
    mu1_value = 0;                          % [Ns/m]
    b2_value = X(m, 2);                     % [Ns/m]
    k2_value = X(m, 3);                     % [N/m]
    mu2_value = 0;                          % [Ns/m]
    b3_value = X(m, 4);                     % [Ns/m]
    k3_value = X(m, 5);                     % [N/m]
    mu3_value = 0;                          % [Ns/m]                       

    % Define universal constants.
    g_value = 9.81;                         % [m/s^2]
    
    % Create arrays to save muscle data in 
    JAdiff_sim          = zeros(length(muscles), 1);
    risetime_sim        = zeros(length(muscles),1);
    omega_sim           = zeros(length(muscles), 1);
    zeta_sim            = zeros(length(muscles), 1);
    
    pk_diff             = zeros(length(muscles), 1);
    locs_diff           = zeros(length(muscles), 1);
    
    for n = 1:length(muscles)

        %% Set-up data
        % Assign equations of motion
        du1 = dui(1); 
        du2 = dui(2); 
        du3 = dui(3); 
        du4 = dui(4); 
        du5 = dui(5); 
        du6 = dui(6);

        % Choose muscle and trial, and starting index value (check figure from
        % "plotjdat" in RawDataPlottingProcessing folder. All starting values
        % have been manually chosen and saved to "start_indices" data file.
        muscle = muscles(n);
        trial = trials(n);
        start_index = start_indices(muscle, trial);
        end_index = end_indices(muscle, trial);

        % From chosen muscle and trial extract joint angles and time data. Note that
        % first cell of jdata corresponds to theta values, the second corresponds
        % to time values, and the third corresponds to "force" values.
        time = jdata{2}{muscle, trial}(start_index:end_index);                      % [s]
        time = time - time(1);
        thetas = jdata{1}{muscle, trial}(start_index:end_index, :) * (2 * pi)/360;  % [rad]

        % Interpolate the data using spline method                                    
        thetas = interp1(time, thetas, 0:time_step:time(end), 'spline');
        time = 0:time_step:time(end);
        time = time * 2;

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
        [ t, x ] = ode15s( @( t, u ) fdu( t, u, taus ), time, u0s );


        %% Calculate risetime calculation for hip

        % Calculate the risetime for simulation and actual data. 
        risetime_sim(n) = risetime_ek(x(:,1), t);

        %% Calculate knee frequency and damping

        % Find peaks and location of sim response and actual response for knee
        [pks_x, loc_x] = findpeaks(x(:,3)); [pks_xneg, loc_xneg] = (findpeaks(-x(:,3)));   

        % Consolidate into single array
        pks_x = abs([pks_x' pks_xneg']); loc_x = [loc_x' loc_xneg'];

        % Define peaks based on offset from steady state value
        SteadyStateX = x(end,3);
        pks_x = abs(pks_x - SteadyStateX);

        % sort positive and negative peaks into singular array
        [pks_x, I_x] = sort(pks_x, 'descend'); loc_x = loc_x(I_x);
        
        if length(pks_x) > 2
            
            % Calculate log dec and damping ratio
            logdec_x = log(pks_x(1) / pks_x(3));
            zeta_x = ( logdec_x / (2*pi) ) / sqrt( 1 + (logdec_x / (2*pi))^2);

            % Calculate frequency
            omega_x = 2* pi * (0.002 * (loc_x(3) - loc_x(1)))^-1;
        
           % Adding variables to cost function for knee
            [pks_thetas, locs_thetas] = findpeaks(thetas(:,2));
            pk_diff(n) = abs(pks_thetas(1) - pks_x(1));
            locs_diff(n) = abs(locs_thetas(1) - loc_x(1));
        else
            % if system is over/criticlly damped, assign arbitrarily low
            % omega_x and high zeta
            omega_x = 0.1;
            zeta_x = 300;
            locs_diff(n) = 300;
            pk_diff(n) = 300;
        end
        
        % Save data into array
        omega_sim(n)    = omega_x;
        zeta_sim(n)     = zeta_x;
         
        
        %% Calculate ankle average joint angle difference
        JAdiff_sim(n) = sum(( x(:,5) - thetas(:,3) ) .^2);
        
        
    end % end of muscle loop (n)

    % Calculate cost of hip
    cost_hip = trial_value(:,1) .* abs(risetime_sim - jdataProp.risetime);
    
    % Calculate cost of knee
    cost_knee = trial_value(:,2) .* (50*abs( zeta_sim - jdataProp.zetas ) + abs( omega_sim - jdataProp.omegas ) + 5*pk_diff + locs_diff);
    
    % Calculate cost of ankle
    cost_ankle = trial_value(:,3) .* JAdiff_sim;
    
    % Calculate total cost of particle
    pbest_err(m) = 200 * sum(cost_hip) + sum(cost_knee) + 30 * sum(cost_ankle);
    
end % end of particle loop (m)



end % end of epoch
