%% Biarticular analysis of the quadruped hind legs
clear, close('all'), clc

%% Define given geometric and physical constants
% Defining hind leg section lengths
l1 = 8.94 * (0.0254);               % [m] Limb length 1 (inches to meters conversion)
l2 = 9.34 * (0.0254);               % [m] Limb length 2 (inches to meters conversion)
l3 = 6.5 * (0.0254);                % [m] Limb length 3 (inches to meters conversion)

% Define gravitational constant
g = 9.8;                            % [m/s^2]

% Define length of actuators
L_AF = (4:0.5:8) * (0.0254);        % [m] Ankle flexor length (inches to meters conversion)
L_AE = (4:0.5:8) * (0.0254);        % [m] Ankle extensor length (inches to meters conversion)
L_KF = (6:0.5:10) * (0.0254);       % [m] Knee flexor length (inches to meters conversion)
L_KE = (6:0.5:10) * (0.0254);       % [m] Knee extensor length (inches to meters conversion)
L_KFb = 14 * (0.0254);               % [m] Biarticular knee flexor length (inches to meters conversion)

% Define actuator masses based on linear density estimate of 1.698 kg/m
m_AF = 1.698 * L_AF;                % [kg] Ankle flexor mass
m_AE = 1.698 * L_AE;                % [kg] Ankle extensor mass
m_KF = 1.698 * L_KF;                % [kg] Knee flexor mass
m_KE = 1.698 * L_KE;                % [kg] Knee extensor mass

% Define mass values of the hind leg sections
me = 0.0205;                        % [kg] Mass of encoders
m1 = 0.1302;                        % [kg] Section 1 leg mass
m2 = 0.1302;                        % [kg] Section 2 leg mass
m3 = 0.09814;                       % [kg] Section 3 leg mass

% Define maximum actuator strain estimate 
k_max = 0.1667;                     % [-]

% Define range of attachment radii
r_KF = 0.005:0.001:0.06;            % [m] Knee flexor (5mm to 6cm range)
r_KE = 0.005:0.001:0.06;            % [m] Knee extensor (5mm to 6cm range)
r_AF = 0.005:0.001:0.06;            % [m] Ankle flexor (5mm to 6cm range)
r_AE = 0.005:0.001:0.06;            % [m] Ankle extensor (5mm to 6cm range)

% Define "pin" (or channel) length n
n_KFb = 0.7188 * (0.0254);           % [m] (inches to meter conversion)

% Define radius of attachment from knee to point of insertion on the tibia
r_KFb1 = 0.5 * (0.0254);            % [m] (inches to meter conversion)

% Define where point of rotation of the upper end of the actuator is in the
% xy plane, with the hip point of rotation as the origin
b_KFb_top = [1, 0]* (0.0254);     % [m] (inches to meter conversion)

% Define the safety factor of required force
SF = 1.6;                           % [-]

%Define BPA model constants (eq 4 from paper)
a0 = 254.3e3;                       % [Pa] Model Parameter 0
a1 = 192e3;                         % [Pa] Model Parameter 1
a2 = 2.0265;                        % [-] Model Parameter 2
a3 = -0.461;                        % [-] Model Parameter 3
a4 = -0.331e-3;                     % [1/N] Model Parameter 4
a5 = 1.23e3;                        % [Pa/N] Model Parameter 5
a6 = 15.6e3;                        % [Pa] Model Parameter 6

% Define the hysteresis factor
S = 1;                               % [0,1]

%% Define fully extended position of the knee in 2D space (position 1)

% Origin is at hip joint point of rotation
% Fully extended position occurs when the femur is -30 degrees from
% vertical, with knee fully extended. Fully flexed position occurs when
% the femur is 30 degrees from vertical with knee fully flexed

% Define angle from horizontal for fully extended position (position 1)
theta1_pos1 = 30;                               % [degrees]

% Define the knee location in the xy plane at position 1 from hip angle
% and femur length
knee_pos1(1) = (-l1 * sind(theta1_pos1));                      % [m]
knee_pos1(2) = (-l1 * cosd(theta1_pos1));                      % [m]

% Define the length of the radius of attatchment end point (the point where
% the string inserts to the frame) from known angles and length of r
r_KFb_pos1 = [(knee_pos1(1) - r_KFb1 * sind(theta1_pos1)), (knee_pos1(2) - r_KFb1 * cosd(theta1_pos1))]; % [m]

% Define the position in the xy plane of the fixed head of the "pin" from
% the defined location of the radius of attchment and defined angles
KFb_pin_pos1(1) = (r_KFb_pos1(1) + n_KFb * cosd(theta1_pos1));  % [m]
KFb_pin_pos1(2) = (r_KFb_pos1(2) - n_KFb * sind(theta1_pos1));  % [m]

% Define the ankle position from the defined angles, knee position, and
% tibia length
ankle_pos1(1) = (knee_pos1(1) - l2 * sind(theta1_pos1));        % [m]
ankle_pos1(2) = (knee_pos1(2) - l2 * cosd(theta1_pos1));        % [m]


%% Plot fully extended position of the knee in 2D space (position 1)
figure(1)
subplot(1, 2, 1)
hold on

% Plot the femur from knee position, and add a marker at the knee
plot([0, knee_pos1(1)], [0, knee_pos1(2)], '-m', 'LineWidth', 4)
plot(knee_pos1(1), knee_pos1(2), 'o', 'LineWidth', 3)


% Plot the tibia from knee to ankle points
plot([knee_pos1(1), ankle_pos1(1)], [knee_pos1(2), ankle_pos1(2)], '-m', 'LineWidth', 4)

% Plot a marker for string attachment point based on radius of attachment
plot(r_KFb_pos1(1), r_KFb_pos1(2), '.', 'LineWidth', 4)

% Plot the pin position and length
plot(KFb_pin_pos1(1), KFb_pin_pos1(2), '*', 'LineWidth', 1)
plot([r_KFb_pos1(1) KFb_pin_pos1(1)], [r_KFb_pos1(2) KFb_pin_pos1(2)])

% Plot the ankle/foot as a triangle
plot(ankle_pos1(1), ankle_pos1(2), '<', 'LineWidth', 4)

% Plot the hip/body as a horizontal line for reference
plot([-1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0,0, 'x', 'LineWidth', 3)


% Plot the upper point of rotation of the actuator
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)

% Plot the lines representing string
plot([b_KFb_top(1) KFb_pin_pos1(1)], [b_KFb_top(2) KFb_pin_pos1(2)])



% Finish labeling the plot
hold off
xlim([-0.3 0.5])
ylim([-0.6 0.2])
title(sprintf('Knee flexor at position 1: \nFully extended'))
xlabel('x position (m)')
ylabel('y position (m)')
daspect([1 1 1])

%% Define fully flexed position (position 2) using rotational matrices

% Define 2D rotational matrix in xy-plane as a function of degrees rotated
% counter-clockwise
rotz = @(t) [cosd(t) -sind(t) ; sind(t) cosd(t)] ;

% Define hip rotation in degrees
rot_hip = input(sprintf('Enter the desired hip rotation from fully flexed: ') );                                              % [degrees]

% Rotate the knee about the origin 60 degrees
knee_pos2 = rotz(rot_hip) * knee_pos1';

% Define knee rotation in degrees
rot_knee = input(sprintf('\nEnter the desired knee rotation from fully extended: ') );                                              % [degrees]

%Rotate the all points below the knee about the knee 90 degrees
ankle_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * ankle_pos1') - knee_pos2)+ knee_pos2;
r_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r_KFb_pos1') - knee_pos2) + knee_pos2;
r_KFb_pos2 = r_KFb_pos2 + (0.25 * 0.0254) *[(r_KFb_pos2 - knee_pos2)/norm(r_KFb_pos2 - knee_pos2)];
KFb_pin_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * KFb_pin_pos1')- knee_pos2) + knee_pos2;
KFb_pin_pos2 = KFb_pin_pos2 + (0.25 * 0.0254) *[(r_KFb_pos2 - knee_pos2)/norm(r_KFb_pos2 - knee_pos2)];
%% Plot fully flexed position of the knee in 2D space (position 2)
subplot(1, 2, 2)
hold on

% Plot the femur from knee position, and add a marker at the knee
plot([0, knee_pos2(1)], [0, knee_pos2(2)], '-m', 'LineWidth', 4)
plot(knee_pos2(1), knee_pos2(2), 'o', 'LineWidth', 3)

% Plot the tibia from knee to ankle points
plot([knee_pos2(1), ankle_pos2(1)], [knee_pos2(2), ankle_pos2(2)], '-m', 'LineWidth', 4)

% Plot a marker for string attachment point based on radius of attachment
plot(r_KFb_pos2(1), r_KFb_pos2(2), '.', 'LineWidth', 4)

% Plot the pin position and length
plot(KFb_pin_pos2(1), KFb_pin_pos2(2), '*', 'LineWidth', 1)
plot([r_KFb_pos2(1) KFb_pin_pos2(1)], [r_KFb_pos2(2) KFb_pin_pos2(2)])

% Plot the ankle/foot as a triangle
plot(ankle_pos2(1), ankle_pos2(2), '<', 'LineWidth', 5)

% Plot the hip/body as a horizontal line for reference
plot([-1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0,0, 'x', 'LineWidth', 3)

% Plot the lines representing string
plot([b_KFb_top(1) KFb_pin_pos2(1)], [b_KFb_top(2) KFb_pin_pos2(2)])

% Plot the upper point of rotation of the actuator
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)

% Finish labeling the plot
xlim([-0.3 0.5])
ylim([-0.6 0.2])
title(sprintf('Knee flexor at position 2:\nHip extended %.0f degrees, knee flexed %.0f degrees', rot_hip, rot_knee))
xlabel('x position (m)')
ylabel('y position (m)')
daspect([1 1 1])


%% Define the strain necessary to achieve position 2

% Define length of fully contracted actuator based on previously defined
% vectors
delta_L_KFb = norm(KFb_pin_pos1 - b_KFb_top) - norm(KFb_pin_pos2' - b_KFb_top);
% Calculate strain from contracted and resting lengths
k_KFb = delta_L_KFb / L_KFb;
fprintf('\n\nActuator length: %.0f inches', L_KFb/0.0254)
fprintf('\nHip rotation: %.0f degrees', rot_hip)
fprintf('\nKnee rotation: %.0f degrees', rot_knee)
fprintf('\nStrain to achieve this position: %.2f\n', k_KFb)

%% Torque calculations
