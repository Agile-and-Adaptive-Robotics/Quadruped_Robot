%% Biarticular analysis of the quadruped hind legs
clear, close('all'), clc

<<<<<<< Updated upstream
%% Define given geometric and physical constants
% Defining hind leg section lengths
l1 = 8.94 * (0.0254);               % [m] Limb length 1 (inches to meters conversion)
l2 = 9.34 * (0.0254);               % [m] Limb length 2 (inches to meters conversion)
=======
% This simulation is intended to provide a static analysis and rough visual
% depiction of a cam/pulley system. I did not alter the plots to show the
% cam, but rather changed r (which is a constant moment arm) to represent
% the correct final position. The pin functions to move the string away
% from the insertion point, but in reality it would wrap around a cam.
%% Define given geometric and physical constants

% Defining hind leg section lengths
l1 = 8.92 * (0.0254);               % [m] Limb length 1 (inches to meters conversion)
l2 = 9.37 * (0.0254);               % [m] Limb length 2 (inches to meters conversion)
>>>>>>> Stashed changes
l3 = 6.5 * (0.0254);                % [m] Limb length 3 (inches to meters conversion)

% Define gravitational constant
g = 9.8;                            % [m/s^2]

% Define length of actuators
<<<<<<< Updated upstream
L_AF = (4:0.5:8) * (0.0254);        % [m] Ankle flexor length (inches to meters conversion)
L_AE = (4:0.5:8) * (0.0254);        % [m] Ankle extensor length (inches to meters conversion)
L_KF = (6:0.5:10) * (0.0254);       % [m] Knee flexor length (inches to meters conversion)
L_KE = (6:0.5:10) * (0.0254);       % [m] Knee extensor length (inches to meters conversion)
L_KFb = 14 * (0.0254);               % [m] Biarticular knee flexor length (inches to meters conversion)
=======
L_AF = 9 * (0.0254);                % [m] Ankle flexor length (inches to meters conversion)
L_AE = 9 * (0.0254);                % [m] Ankle extensor length (inches to meters conversion)
L_KF = 8 * (0.0254);                % [m] Knee flexor length (inches to meters conversion)
L_KE = 8 * (0.0254);                % [m] Knee extensor length (inches to meters conversion)
L_KFb = 14 * (0.0254);              % [m] Biarticular knee flexor length (inches to meters conversion)
L_KEb = 14 * (0.0254);              % [m] Biarticular knee flexor length (inches to meters conversion)
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
% Define range of attachment radii
r_KF = 0.005:0.001:0.06;            % [m] Knee flexor (5mm to 6cm range)
r_KE = 0.005:0.001:0.06;            % [m] Knee extensor (5mm to 6cm range)
r_AF = 0.005:0.001:0.06;            % [m] Ankle flexor (5mm to 6cm range)
r_AE = 0.005:0.001:0.06;            % [m] Ankle extensor (5mm to 6cm range)

% Define "pin" (or channel) length n
n_KFb = 0.7188 * (0.0254);           % [m] (inches to meter conversion)

% Define radius of attachment from knee to point of insertion on the tibia
r_KFb1 = 0.5 * (0.0254);            % [m] (inches to meter conversion)
=======
% Define r1 and r2 for the flexor and extensor, corresponding to the cam
% radius at positon one and two
r1_KFb_length = 0.5 * (0.0254);          % [m] (inches to meter conversion)
r1_KEb_length = 0.75 * (0.0254);         % [m] (inches to meter conversion)
r2_KFb_length = 0.75 * (0.0254);         % [m] (inches to meter conversion)
r2_KEb_length = 0.5 * (0.0254);          % [m] (inches to meter conversion)
>>>>>>> Stashed changes

% Define where point of rotation of the upper end of the actuator is in the
% xy plane, with the hip point of rotation as the origin
b_KFb_top = [1, 0]* (0.0254);     % [m] (inches to meter conversion)
<<<<<<< Updated upstream

% Define the safety factor of required force
SF = 1.6;                           % [-]
=======
b_KEb_top = [-1, 0]* (0.0254);     % [m] (inches to meter conversion)

% Define the safety factor of required force
SF = 1;                           % [-]
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
r_KFb_pos1 = [(knee_pos1(1) - r_KFb1 * sind(theta1_pos1)), (knee_pos1(2) - r_KFb1 * cosd(theta1_pos1))]; % [m]

% Define the position in the xy plane of the fixed head of the "pin" from
% the defined location of the radius of attchment and defined angles
KFb_pin_pos1(1) = (r_KFb_pos1(1) + n_KFb * cosd(theta1_pos1));  % [m]
KFb_pin_pos1(2) = (r_KFb_pos1(2) - n_KFb * sind(theta1_pos1));  % [m]
=======
r1_KFb_pos1 = [(knee_pos1(1) + r1_KFb_length * cosd(theta1_pos1)), (knee_pos1(2) - r1_KFb_length * sind(theta1_pos1))]; % [m]
r2_KFb_pos1 = [(knee_pos1(1) - r2_KFb_length * sind(theta1_pos1)), (knee_pos1(2) - r2_KFb_length * cosd(theta1_pos1))]; % [m]
r1_KEb_pos1 = [(knee_pos1(1) - r1_KEb_length * cosd(theta1_pos1)), (knee_pos1(2) + r1_KEb_length * sind(theta1_pos1))]; % [m]
r2_KEb_pos1 = [(knee_pos1(1) + r1_KEb_length * sind(theta1_pos1)), (knee_pos1(2) + r2_KEb_length * cosd(theta1_pos1))]; % [m]
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
% Plot a marker for string attachment point based on radius of attachment
plot(r_KFb_pos1(1), r_KFb_pos1(2), '.', 'LineWidth', 4)

% Plot the pin position and length
plot(KFb_pin_pos1(1), KFb_pin_pos1(2), '*', 'LineWidth', 1)
plot([r_KFb_pos1(1) KFb_pin_pos1(1)], [r_KFb_pos1(2) KFb_pin_pos1(2)])

% Plot the ankle/foot as a triangle
plot(ankle_pos1(1), ankle_pos1(2), '<', 'LineWidth', 4)
=======
% Plot the cam radii for flexor and extensor (2 each) for position 1 as
% points
plot(r1_KFb_pos1(1), r1_KFb_pos1(2), '*c')
plot(r2_KFb_pos1(1), r1_KFb_pos1(2), '*c')
plot(r1_KEb_pos1(1), r1_KEb_pos1(2), '*b')
plot(r2_KEb_pos1(1), r2_KEb_pos1(2), '*b')

% Plot the ankle/foot as a triangle
plot(ankle_pos1(1), ankle_pos1(2), '<k', 'LineWidth', 4)
>>>>>>> Stashed changes

% Plot the hip/body as a horizontal line for reference
plot([-1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0,0, 'x', 'LineWidth', 3)


<<<<<<< Updated upstream
% Plot the upper point of rotation of the actuator
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)

% Plot the lines representing string
plot([b_KFb_top(1) KFb_pin_pos1(1)], [b_KFb_top(2) KFb_pin_pos1(2)])

=======
% Plot the final pulley point before string goes to the tibia for the
% lfexor and extensor
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)
plot(b_KEb_top(1), b_KEb_top(2), 'xr', 'LineWidth', 5)

% Plot the lines representing strings for the flexor and extensor
plot([b_KFb_top(1) r1_KFb_pos1(1)], [b_KFb_top(2) r1_KFb_pos1(2)], 'b')
plot([b_KEb_top(1) r1_KEb_pos1(1)], [b_KEb_top(2) r1_KEb_pos1(2)], 'b')
>>>>>>> Stashed changes


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
<<<<<<< Updated upstream
r_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r_KFb_pos1') - knee_pos2) + knee_pos2;
r_KFb_pos2 = r_KFb_pos2 + (0.25 * 0.0254) *[(r_KFb_pos2 - knee_pos2)/norm(r_KFb_pos2 - knee_pos2)];
KFb_pin_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * KFb_pin_pos1')- knee_pos2) + knee_pos2;
KFb_pin_pos2 = KFb_pin_pos2 + (0.25 * 0.0254) *[(r_KFb_pos2 - knee_pos2)/norm(r_KFb_pos2 - knee_pos2)];
=======
r1_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r1_KFb_pos1') - knee_pos2) + knee_pos2;
r2_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r2_KFb_pos1') - knee_pos2) + knee_pos2;
r1_KEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r1_KEb_pos1') - knee_pos2) + knee_pos2;
r2_KEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r2_KEb_pos1') - knee_pos2) + knee_pos2;

>>>>>>> Stashed changes
%% Plot fully flexed position of the knee in 2D space (position 2)
subplot(1, 2, 2)
hold on

% Plot the femur from knee position, and add a marker at the knee
plot([0, knee_pos2(1)], [0, knee_pos2(2)], '-m', 'LineWidth', 4)
plot(knee_pos2(1), knee_pos2(2), 'o', 'LineWidth', 3)

% Plot the tibia from knee to ankle points
plot([knee_pos2(1), ankle_pos2(1)], [knee_pos2(2), ankle_pos2(2)], '-m', 'LineWidth', 4)

<<<<<<< Updated upstream
% Plot a marker for string attachment point based on radius of attachment
plot(r_KFb_pos2(1), r_KFb_pos2(2), '.', 'LineWidth', 4)

% Plot the pin position and length
plot(KFb_pin_pos2(1), KFb_pin_pos2(2), '*', 'LineWidth', 1)
plot([r_KFb_pos2(1) KFb_pin_pos2(1)], [r_KFb_pos2(2) KFb_pin_pos2(2)])

% Plot the ankle/foot as a triangle
plot(ankle_pos2(1), ankle_pos2(2), '<', 'LineWidth', 5)
=======
% Plot the cam radii for flexor and extensor (2 each) for position 1 as
% points
plot(r1_KFb_pos2(1), r1_KFb_pos2(2), '*c')
plot(r2_KFb_pos2(1), r2_KFb_pos2(2), '*c')
plot(r1_KEb_pos2(1), r1_KEb_pos2(2), '*b')
plot(r2_KEb_pos2(1), r2_KEb_pos2(2), '*b')

% Plot the ankle/foot as a triangle
plot(ankle_pos2(1), ankle_pos2(2), '<k', 'LineWidth', 5)
>>>>>>> Stashed changes

% Plot the hip/body as a horizontal line for reference
plot([-1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0,0, 'x', 'LineWidth', 3)

<<<<<<< Updated upstream
% Plot the lines representing string
plot([b_KFb_top(1) KFb_pin_pos2(1)], [b_KFb_top(2) KFb_pin_pos2(2)])

% Plot the upper point of rotation of the actuator
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)
=======

% Plot the final pulley point before string goes to the tibia for the
% lfexor and extensor
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)
plot(b_KEb_top(1), b_KEb_top(2), 'xr', 'LineWidth', 5)

% Plot the lines representing strings for the flexor and extensor
plot([b_KFb_top(1) r2_KFb_pos2(1)], [b_KFb_top(2) r2_KFb_pos2(2)], 'b')
plot([b_KEb_top(1) r2_KEb_pos2(1)], [b_KEb_top(2) r2_KEb_pos2(2)], 'b')
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
delta_L_KFb = norm(KFb_pin_pos1 - b_KFb_top) - norm(KFb_pin_pos2' - b_KFb_top);
% Calculate strain from contracted and resting lengths
k_KFb = delta_L_KFb / L_KFb;
fprintf('\n\nActuator length: %.0f inches', L_KFb/0.0254)
fprintf('\nHip rotation: %.0f degrees', rot_hip)
fprintf('\nKnee rotation: %.0f degrees', rot_knee)
fprintf('\nStrain to achieve this position: %.2f\n', k_KFb)

%% Torque calculations
=======
delta_L_KFb = norm(r1_KFb_pos1 - b_KFb_top) - norm(r2_KFb_pos2' - b_KFb_top);
delta_L_KEb = -norm(r1_KEb_pos1 - b_KEb_top) + norm(r2_KEb_pos2' - b_KEb_top);

% Calculate strain from contracted and resting lengths
k_KFb = delta_L_KFb / L_KFb;
k_KEb = delta_L_KEb / L_KEb;

%Print out actuator lengths and strains
fprintf('\nHip rotation: %.0f degrees', rot_hip)
fprintf('\nKnee rotation: %.0f degrees', rot_knee)
fprintf('\n\nBA knee flexor actuator length: %.0f inches', L_KFb/0.0254)
fprintf('\nBA knee flexor strain to achieve this position: %.2f', k_KFb)
fprintf('\n\nBA knee extensor actuator length: %.0f inches', L_KEb/0.0254)
fprintf('\nBA knee extensor to achieve this position: %.2f\n', k_KEb)

%% Torque calculations for the biarticular knee flexor and knee extensor

% NOTE: THESE HAVE ONLY BEEN SET UP TO DEFINE TORQUE AT SET POSITIONS.
% Needs modification to find force at a given rotation.

% Torque requirements for flexor:
% Define torques created by the weight of the different leg segments
T1_KFb = 0.5 * l1 * cosd(60) * (m1 + m_KF + m_KE) * g;                      % [N-m]
T2_KFb = (l1 * cosd(60) + 0.5 * l2 * sind(60)) * (m1 + m_AF + m_AE) * g;    % [N-m]
T3_KFb = (l1 * cosd(60) + (l2 + l3/2) * sind(60)) * m3 * g;                 % [N-m]

% Define force necessary for actuator to exert to hold leg at position 2
F_KFb = (T1_KFb + T2_KFb + T3_KFb) / r2_KFb_length;                % [N]         


% Torque requirements for extensor:
% Define torques created by the weight of the different leg segments
T1_KEb = 0.5 * l1 * sind(30) * (m1 + m_KF + m_KE) * g;                      % [N-m]
T2_KEb = ((l1 + 0.5 * l2) * sind(30)) * (m1 + m_AF + m_AE) * g;    % [N-m]
T3_KEb = (((l1 + l2) * sind(30)) + (l3/2)) * m3 * g;                 % [N-m]

% Define force necessary for actuator to exert to hold leg at position 1
F_KEb = (T1_KEb + T2_KEb + T3_KEb) / r1_KEb_length;                % [N] 

% Print out force required to hold position 1 and 2 for the knee extensor
% and flexor, respectfully
fprintf('\nThe required force for the BA knee flexor to hold position 2 is %.1f pounds', F_KFb/4.448)
fprintf('\nThe required force for the BA knee extensor to hold position 1 is %.1f pounds', F_KEb/4.448)

%% Plotting strain vs necessary pressure for a given force

% Constructing a pressure vs strain plot for BPAs of varying force based on
% equation 4.

% Define range of strains
k = 0.001:0.001:0.2;            % []
k_max = 0.17;                   % []
F = [0:6:36] * 4.448;           % [N] (pounds to newtons conversion)
S = 1;                          % [0,1] hysteresis 

key = strings(1,length(F));

figure(2)
% plot pressure vs strain, each loop doing a different applied force
for n = 1:length(F)
    P = a0 + (a1 * tan( a2 * ((k./ (a4 * F(n) + k_max)) + a3))) + (a5 * F(n)) + (a6 * S); % [Pa]
    plot(k, P/1000, '.')
    hold on
    key(n) = sprintf('Applied force: %.1f pounds', F(n)/4.448);
end

% Plot strain and forces required for position 1 and 2 for biarticular knee
% muscles
plot(k_KFb, 0.001 * (a0 + (a1 * tan( a2 * ((k_KFb./ (a4 * F_KFb + k_max)) + a3))) + (a5 * F_KFb) + (a6 * S)), 'xr', 'LineWidth', 2)
plot(k_KEb, 0.001 * (a0 + (a1 * tan( a2 * ((k_KEb./ (a4 * F_KEb + k_max)) + a3))) + (a5 * F_KEb) + (a6 * S)), 'xr', 'LineWidth', 2)

key(8) = 'BA KE at pos1';
key(9) = 'BA KF at pos2';
legend(key)

xlabel('Strain')
ylabel('Pressure (kPa)')
xlim([0 0.2])
ylim([0 700])
title('14 inch biarticular knee actuators')
>>>>>>> Stashed changes
