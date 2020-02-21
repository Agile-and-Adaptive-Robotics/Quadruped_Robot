%% BPA Force & Length Requirements (Version 2)

% Clear everything.
clear, close('all'), clc

%% Define the Limb Properties.

% Define the limb mass.
m = 1;                  % [kg] Mass of the Limb.

% Define the gravitational constant.
g = 9.81;               % [m/s^2] Gravitational Constant.

% Define the Joint Geometry.
L_limb = 0.0254*8.25;        % [m] Limb Length.

% x20 = 0.0254*0.604432;  % [m] x Distance to the Pulley Point.  Decreasing x30 decreases T.
% y20 = 0.0254*0.680268;  % [m] y Distance to the Pulley Point.  Increasing y30 decreases T.

% x40 = 0.0254*0.4309;    % [m] x Distance to Tendon Attachment Point in Home Position.  Decreasing x20 decreases T.
% y40 = 0.0254*0.361568;  % [m] y Distance to Tendon Attachment Point in Home Position.  Should be between 0.4 and 0.5.  Too low of a value causes a infinite spike within the operating domain.  Too high of a value increases the maximum required pressure to start.

x20 = 0.0254*0.65;  % [m] x Distance to the Pulley Point.  Decreasing x30 decreases T.
y20 = 0.0254*0.70;  % [m] y Distance to the Pulley Point.  Increasing y30 decreases T.

x40 = 0.0254*0.40;  % [m] x Distance to Tendon Attachment Point in Home Position.  Decreasing x20 decreases T.
y40 = 0.0254*0.40;  % [m] y Distance to Tendon Attachment Point in Home Position.  Should be between 0.4 and 0.5.  Too low of a value causes a infinite spike within the operating domain.  Too high of a value increases the maximum required pressure to start.

% Compute the Distance to the Center of Mass of the Limb.
x60 = L_limb/2;              % [m] x Distance to the Center of Mass of the Limb in the Home Position.

% Define the resting lengths of the muscles.
L_ext_rest = 0.0254*7.28125;      % [m] Resting muscle length.
L_flx_rest = 0.0254*7.28125;      % [m] Resting muscle length.

% Define the minimum lengths of the muscles.
L_ext_min = (1 - 0.16)*L_ext_rest;    % [m] Muscle length at maximum contraction.
L_flx_min = (1 - 0.16)*L_flx_rest;    % [m] Muscle length at maximum contraction.

% Define the muscle parameters.
a0 = 254.3e2;                     % [Pa]
a1 = 192.0e2;                     % [Pa]
a2 = 2.0265;                      % [-]
a3 = -0.461;                      % [-]
a4 = -0.331e-3;                   % [1/N]
a5 = 6.5e3/53;                    % [Pa/N]
a6 = 1.5e3;                       % [Pa]

% Define the hystersis constant.
S = 0;                            % [-]

% Compute the maximum muscle strain.
epsilon_ext_max = (L_ext_rest - L_ext_min)/L_ext_rest;
epsilon_flx_max = (L_flx_rest - L_flx_min)/L_flx_rest;

% Define a function to convert contraction and tension to the required pressure.
fT2P = @(epsilons, Ts_ext, epsilon_max) a0 + a1*tan( a2*(epsilons./(a4*Ts_ext + epsilon_max)) + a3 ) + a5*Ts_ext + a6*S;


%% Compute the Positions of Important Points on the Joint in the Home Position.

% Compute the positions.
P10 = [0; 0; 0];                % [m] Position of the joint center of rotation in the home position.
P20 = [x20; y20; 0];
P30 = [x30; -y30; 0];
P40 = [-x40; y40; 0];
P50 = [-x50; y50; 0];
P60 = [-x60; 0; 0];
P70 = [x20; 0; 0];
P80 = [x30; 0; 0];
P90 = [x40; 0; 0];
P100 = [x50; 0; 0];


%% Compute the Positions of Important Points Throughout the Joint Range of Motion.

% Define the gravitational force vector.
Fg = [0; -mg; 0];

% Define the tension in the flexor

% Define an anonymous function that generates a rotation matrix.
fR = @(x) [cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1];

% Define the number of angles of interest.
num_thetas = 1000;

% Define the angles of interest.
thetas = linspace(0, pi/2, num_thetas);
% thetas = linspace(0, 3*pi/4, num_thetas);

% Define arrays to store the points of interest.
[P1s, P2s, P3s, P4s, P5s, P6s, P7s, P8s, P9s, P10s] = deal( zeros(3, num_thetas) );

% Create an array to store the angle between the tendon and limb.
[Ts_ext, Ls_ext] = deal( zeros(1, num_thetas) );

% Create a flag variable to determine whether to switch the phi sign.
bSwitched = false; 

% Create a flag variable to set the sign of the phi angle.
sign = 1;
% sign = -1;

% Compute the positions of the important points.
for k = 1:num_thetas
    
    % Compute the rotation matrix associated with this iteration.
    R = fR(thetas(k));
    
    % Compute the location of each of the important points for this iteration.
    P1s(:, k) = P10;
    P2s(:, k) = P20;
    P3s(:, k) = P30;
    P4s(:, k) = R*P40;
    P5s(:, k) = R*P50;
    P6s(:, k) = R*P60;
    P7s(:, k) = P70;
    P8s(:, k) = P80;
    P9s(:, k) = R*P90;
    P10s(:, k) = R*P100;

    % Compute the the vectors between some of the points of interest.
    P24 = P2s(:, k) - P4s(:, k);
    P35 = P3s(:, k) - P5s(:, k);
    
    % Compute the length of the tendons.
    Ls_ext(k) = norm(P24);
    Ls_flx(k) = norm(P35);

    % Compute the extensor muscle tension.
    Ts_ext(k) = norm( cross( P6s(:, k), Fg ) + cross( P5s(:, k), F_flx ) ) / norm( P4s(:, k) );
    
end

% Compute the required contraction length throughout the range of motion.
deltaLs_ext = max(Ls_ext) - Ls_ext;         % [m] Required contraction length of the muscle throughout the range of motion.

% Compute the muscle strain with respect to the resting muscle length throughout the range of motion.
epsilons_ext = deltaLs_ext/L_ext_rest;

% Compute the BPA pressure required to lift the limb throughout the range of motion.
% Ps = a0 + a1*tan( a2*(epsilons_ext./(a4*Ts_ext + epsilon_max)) + a3 ) + a5*Ts_ext + a6*S;
Ps_ext = fT2P(epsilons_ext, Ts_ext, epsilon_ext_max);


%% Plot Variables of Interest Over the Range of Motion.

% Plot the tendon to limb angle over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Tendon-Limb Angle, $\phi$ [deg]', 'Interpreter', 'Latex'), title('Tendon-Limb Angle vs Joint Angle')
plot((180/pi)*thetas, (180/pi)*phis, '-', 'Linewidth', 3)

% Plot the tendon length over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Tendon Length, $L$ [in]', 'Interpreter', 'Latex'), title('Tendon Length vs Joint Angle')
plot((180/pi)*thetas, 39.3701*Ls_ext, '-', 'Linewidth', 3)

% Plot the change in muscle length over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Change in Muscle Length, $\Delta L$ [in]', 'Interpreter', 'Latex'), title('Change in Muscle Length vs Joint Angle')
plot((180/pi)*thetas, 39.3701*deltaLs_ext, '-', 'Linewidth', 3)

% Plot the muscle strain over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Muscle Strain, $\epsilon$ [-]', 'Interpreter', 'Latex'), title('Muscle Strain vs Joint Angle')
plot((180/pi)*thetas, epsilons_ext, '-', 'Linewidth', 3)

% Plot the force required to lift the limb over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Required Force, $T$ [lbs]', 'Interpreter', 'Latex'), title('Tension vs Joint Angle')
plot((180/pi)*thetas, Ts_ext/4.4482216282509, '-', 'Linewidth', 3)

% Plot the required BPA pressure over the range of motion.
fig = figure('color', 'w'); hold on, grid on
xlabel('Joint Angle, $\theta$ [deg]', 'Interpreter', 'Latex'), ylabel('Muscle Pressure, $P$ [psi]', 'Interpreter', 'Latex'), title('Muscle Pressure vs Joint Angle')
plot((180/pi)*thetas, 0.000145038*Ps, '-', 'Linewidth', 3)



%% Animate the Joint Through the Specified Range of Motion.

% Define the number of times to play the animation.
N = 1;

% Create a figure to store the animation.
fig = figure('color', 'w'); hold on
axis([-0.21, 0.05, -0.21, 0.05])
% axis([-0.21, 0.21, -0.21, 0.21])

ts = linspace(pi, 3*pi/2, 100);
xs_circle = L_limb*cos(ts); ys_circle = L_limb*sin(ts);
plot(xs_circle, ys_circle, '--', 'Linewidth', 3)

% Define the structure in the home position.
P0s = [P30 P50 P10 P60 P20 P60 P40 P70];

% Initialize the data source variables.
xs_limb = P0s(1, :); ys_limb = P0s(2, :);

% Plot the initial structure.
h_limb = plot(xs_limb, ys_limb, '-', 'Linewidth', 3, 'XDataSource', 'xs_limb', 'YDataSource', 'ys_limb');

for j = 1:N
    
    % Animate the structure through the range of motion.
    for k = 1:num_thetas        % Iterate through each of the frames...
        
        % Retrieve the points of the structure associated with the current animation frame.
        Ps = [P3s(:, k) P5s(:, k) P1s(:, k) P6s(:, k) P2s(:, k) P6s(:, k) P4s(:, k) P7s(:, k)];
        
        % Update the data source variables.
        xs_limb = Ps(1, :); ys_limb = Ps(2, :);
        
        % Update the plot with the new frame.
        refreshdata(h_limb, 'caller'), drawnow()
                
    end
    
end


