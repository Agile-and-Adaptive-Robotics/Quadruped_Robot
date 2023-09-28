%% Biarticular analysis of the quadruped hind legs
clear, close('all'), clc

%% Define given geometric and physical constants

% This simulation is intended to provide a static analysis and rough visual
% depiction of a cam/pulley system. CAM radii are sown as points around the
% knee

%% Define a rotational function to be used
% Define 2D rotational matrix in xy-plane as a function of degrees rotated
% counter-clockwise
rotz = @(t) [cosd(t) -sind(t) ; sind(t) cosd(t)] ;
%% Define given geometric and physical constants

% Defining hind leg section lengths
l1 = 8.92 * (0.0254);               % [m] Limb length 1 (inches to meters conversion)
l2 = 9.37 * (0.0254);               % [m] Limb length 2 (inches to meters conversion)
l3 = 5 * (0.0254);                  % [m] Limb length 3 (inches to meters conversion)

% Define gravitational constant
g = 9.8;                            % [m/s^2]

% Define length of actuators             
L_AF = 9 * (0.0254);                % [m] Ankle flexor length (inches to meters conversion)
L_AE = 9 * (0.0254);                % [m] Ankle extensor length (inches to meters conversion)
L_KF = 8 * (0.0254);                % [m] Knee flexor length (inches to meters conversion)
L_KE = 8 * (0.0254);                % [m] Knee extensor length (inches to meters conversion)
L_KFb = 12 * (0.0254);              % [m] Biarticular knee flexor length (inches to meters conversion)
L_KEb = 12 * (0.0254);              % [m] Biarticular knee flexor length (inches to meters conversion)
L_AEb = 8.5 * (0.0254);              % [m] Biarticular ankle extensor length (inches to meters conversion)

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

% Define r1 and r2 for the knee and ankle cam, corresponding to the cam
% radius at positon one and two
r1_KFb_length = .75 * (0.0254);         % [m] (inches to meter conversion)
r1_KEb_length = 0.5 * (0.0254);         % [m] (inches to meter conversion)
r2_KFb_length = 0.5 * (0.0254);         % [m] (inches to meter conversion)
r2_KEb_length = .75* (0.0254);          % [m] (inches to meter conversion)
r1_AEb_length = 0.5 * (0.0254);         % [m] (inches to meter conversion)
r2_AEb_length = 0.5 * (0.0254);        % [m] (inches to meter conversion)

% Define where point of rotation of the upper end of the knee actuators is in the
% xy plane, with the hip point of rotation as the origin
b_KFb_top = [1.5, 0]* (0.0254);            % [m] (inches to meter conversion)
b_KEb_top = [-1.5, 0]* (0.0254);           % [m] (inches to meter conversion)

% Define the safety factor of required force
SF = 1;                           % [-]

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

% Define the length of the radius of attatchment end point for the knee(the point where
% the string inserts to the frame) from known angles and length of r
r1_KFb_pos1 = [(knee_pos1(1) + r1_KFb_length * cosd(theta1_pos1)), (knee_pos1(2) - r1_KFb_length * sind(theta1_pos1))]; % [m]
r2_KFb_pos1 = [(knee_pos1(1) - r2_KFb_length * sind(theta1_pos1)), (knee_pos1(2) - r2_KFb_length * cosd(theta1_pos1))]; % [m]
r1_KEb_pos1 = [(knee_pos1(1) - r1_KEb_length * cosd(theta1_pos1)), (knee_pos1(2) + r1_KEb_length * sind(theta1_pos1))]; % [m]
r2_KEb_pos1 = [(knee_pos1(1) + r2_KEb_length * sind(theta1_pos1)), (knee_pos1(2) + r2_KEb_length * cosd(theta1_pos1))]; % [m]

% Define the ankle position from the defined angles, knee position, and
% tibia length
ankle_pos1(1) = (knee_pos1(1) - l2 * sind(theta1_pos1));        % [m]
ankle_pos1(2) = (knee_pos1(2) - l2 * cosd(theta1_pos1));        % [m]

% Define the length of the radius of attatchment end point for the ankle(the point where
% the string inserts to the frame) from known angles and length of r
r1_AEb_pos1 = [(ankle_pos1(1) + r1_AEb_length * cosd(theta1_pos1)), (ankle_pos1(2) - r1_AEb_length * sind(theta1_pos1))]; % [m]
r2_AEb_pos1 = [(ankle_pos1(1) - r2_AEb_length * sind(theta1_pos1)), (ankle_pos1(2) - r2_AEb_length * cosd(theta1_pos1))]; % [m]

% Define the toe postion, modeling the foot as a straight line
toe_pos1 = [(ankle_pos1(1) - l3 * cosd(theta1_pos1)) (ankle_pos1(2) + l3 * sind(theta1_pos1))];

%Define upper actuator position 1
upper_AEb_pos1 = knee_pos1 + 0.0254*1.25*[sind(30) cosd(30)]; 

%Define string length
string = norm(upper_AEb_pos1 - r1_KFb_pos1);

% Define the outer cam circle in quarter sections for knee and ankle
thetaKF = 1.5 *pi() : 0.001 : 2*pi;
thetaKE = 0.5 *pi() : 0.001 : pi;
thetaAE = 1.5 *pi() : 0.001 : 2 * pi;

camKF(1,:) = r1_KFb_length * cos(thetaKF) + knee_pos1(1);
camKF(2,:) = r2_KFb_length * sin(thetaKF) + knee_pos1(2);
camKF = rotz(-theta1_pos1) * [(camKF(1,:) - knee_pos1(1)); (camKF(2,:) - knee_pos1(2))];
camKF(1,:) = camKF(1,:) + knee_pos1(1);
camKF(2,:) = camKF(2,:) + knee_pos1(2);

camKE(1,:) = r1_KEb_length * cos(thetaKE) + knee_pos1(1);
camKE(2,:) = r2_KEb_length * sin(thetaKE) + knee_pos1(2);
camKE = rotz(-theta1_pos1) * [(camKE(1,:) - knee_pos1(1)); (camKE(2,:) - knee_pos1(2))];
camKE(1,:) = camKE(1,:) + knee_pos1(1);
camKE(2,:) = camKE(2,:) + knee_pos1(2);

camAE(1,:) = r1_AEb_length * cos(thetaAE) + ankle_pos1(1);
camAE(2,:) = r2_AEb_length * sin(thetaAE) + ankle_pos1(2);
camAE = rotz(-theta1_pos1) * [(camAE(1,:) - ankle_pos1(1)); (camAE(2,:) - ankle_pos1(2))];
camAE(1,:) = camAE(1,:) + ankle_pos1(1);
camAE(2,:) = camAE(2,:) + ankle_pos1(2);


%% Plot fully extended position of the knee in 2D space (position 1)
figure(1)
subplot(1, 2, 1)
hold on

% Plot the femur from knee position, and add a marker at the knee
plot([0, knee_pos1(1)], [0, knee_pos1(2)], '-m', 'LineWidth', 4)
plot(knee_pos1(1), knee_pos1(2), 'o', 'LineWidth', 3)

% Plot the cam radii
plot(camKF(1,:), camKF(2,:))
plot(camKE(1,:), camKE(2,:))
plot(camAE(1,:), camAE(2,:))

% Plot the tibia from knee to ankle points
plot([knee_pos1(1), ankle_pos1(1)], [knee_pos1(2), ankle_pos1(2)], '-m', 'LineWidth', 4)

% Plot the cam radii for the knee flexor and extensor (2 each) for position 1 as
% points
plot(r1_KFb_pos1(1), r1_KFb_pos1(2), '*c')
plot(r2_KFb_pos1(1), r2_KFb_pos1(2), '*c')
plot(r1_KEb_pos1(1), r1_KEb_pos1(2), '*b')
plot(r2_KEb_pos1(1), r2_KEb_pos1(2), '*b')

% Plot the ankle/foot as a circle
plot(ankle_pos1(1), ankle_pos1(2), 'o', 'LineWidth', 3)

% Plot the foot as a straight line
plot([ankle_pos1(1) toe_pos1(1)], [ankle_pos1(2) toe_pos1(2)], '-m', 'LineWidth', 4) 

% Plot the CAM radii for the ankle
plot(r1_AEb_pos1(1), r1_AEb_pos1(2), '*b')
plot(r2_AEb_pos1(1), r2_AEb_pos1(2), '*b')

% Plot the ankle extensor actuator
plot([upper_AEb_pos1(1) r1_AEb_pos1(1)], [upper_AEb_pos1(2) r1_AEb_pos1(2)], '-b', 'LineWidth', 3)


% Plot the hip/body as a horizontal line for reference
plot([-.1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0,0, 'xg', 'LineWidth', 3)

% Plot the final pulley point before string goes to the tibia for the
% flexor and extensor
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)
plot(b_KEb_top(1), b_KEb_top(2), 'xr', 'LineWidth', 5)

% Plot the lines representing strings for the flexor and extensor
plot([b_KFb_top(1) r1_KFb_pos1(1)], [b_KFb_top(2) r1_KFb_pos1(2)], 'b')
plot([b_KEb_top(1) r1_KEb_pos1(1)], [b_KEb_top(2) r1_KEb_pos1(2)], 'b')

% Finish labeling the plot
hold off
xlim([-0.4 0.2])
ylim([-0.5 0.1])
title(sprintf('Knee flexor at position 1: \nFully extended'))
xlabel('x position (m)')
ylabel('y position (m)')
daspect([1 1 1])
set(gcf,'color','w');

%% Define fully flexed position (position 2) using rotational matrices

% Define hip rotation in degrees
rot_hip = input(sprintf('Enter the desired hip rotation from fully flexed: ') );                                              % [degrees]

% Rotate the knee about the origin 60 degrees
knee_pos2 = rotz(rot_hip) * knee_pos1';

% Define knee rotation in degrees
rot_knee = input(sprintf('\nEnter the desired knee rotation from fully extended: ') );                                              % [degrees]

%Rotate the all points below the knee about the knee 90 degrees
ankle_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * ankle_pos1') - knee_pos2)+ knee_pos2;
r1_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r1_KFb_pos1') - knee_pos2) + knee_pos2;
r2_KFb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r2_KFb_pos1') - knee_pos2) + knee_pos2;
r1_KEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r1_KEb_pos1') - knee_pos2) + knee_pos2;
r2_KEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r2_KEb_pos1') - knee_pos2) + knee_pos2;
toe_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * toe_pos1') - knee_pos2)+ knee_pos2;
r1_AEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r1_AEb_pos1') - knee_pos2)+ knee_pos2;
r2_AEb_pos2 = rotz(rot_knee) * ((rotz(rot_hip) * r2_AEb_pos1') - knee_pos2)+ knee_pos2;
camAE = rotz(rot_knee) * ((rotz(rot_hip) * camAE) - knee_pos2)+ knee_pos2;
camKF = rotz(rot_knee) * ((rotz(rot_hip) * camKF) - knee_pos2)+ knee_pos2;
camKE = rotz(rot_knee) * ((rotz(rot_hip) * camKE) - knee_pos2)+ knee_pos2;

% Define knee rotation in degrees
rot_ankle = input(sprintf('\nEnter the desired ankle rotation from fully flexed: ') );

%Rotate the foot and ankle cam about the ankle
toe_pos2 = rotz(rot_ankle) * (toe_pos2 - ankle_pos2)+ ankle_pos2;
r1_AEb_pos2 = rotz(rot_ankle) * (r1_AEb_pos2 - ankle_pos2)+ ankle_pos2;
r2_AEb_pos2 = rotz(rot_ankle) * (r2_AEb_pos2 - ankle_pos2)+ ankle_pos2;
camAE = rotz(rot_ankle) * (camAE - ankle_pos2) + ankle_pos2;

% Define upper ankle actuator position
%upper_AEb_pos2 = r1_KFb_pos2 + string * ((r2_AEb_pos2 - r1_KFb_pos2)/ norm(r2_AEb_pos2 - r1_KFb_pos2));
upper_AEb_pos2 = rotz(rot_hip) * upper_AEb_pos1';

% Define the EFFECTIVE radius based on knee rotation and ankle rotation
rKFb_eff_length = (r1_KFb_length * r2_KFb_length)/((r2_KFb_length * cosd(rot_knee))^2 + (r1_KFb_length * sind(rot_knee))^2)^.5;
rKEb_eff_length = (r1_KEb_length * r2_KEb_length)/((r2_KEb_length * cosd(rot_knee))^2 + (r1_KEb_length * sind(rot_knee))^2)^.5;
rAEb_eff_length = (r1_AEb_length * r2_AEb_length)/((r2_AEb_length * cosd(rot_ankle))^2 + (r1_AEb_length * sind(rot_ankle))^2)^.5;

% Define the string attachment point from effective radius and knee/ankle rotation
rKFb_eff = knee_pos1 + rKFb_eff_length * [cosd(theta1_pos1) -sind(theta1_pos1)];
rKFb_eff = rotz(rot_hip) * rKFb_eff';
rKEb_eff = knee_pos1 + rKEb_eff_length * [-cosd(theta1_pos1) sind(theta1_pos1)];
rKEb_eff = rotz(rot_hip) * rKEb_eff';

rAEb_eff = ankle_pos1 + rAEb_eff_length * [cosd(theta1_pos1) -sind(theta1_pos1)];
rAEb_eff = rotz(rot_knee) * ((rotz(rot_hip) * rAEb_eff') - knee_pos2) + knee_pos2;

% Also need to define the fully extended knee extensor position, even if the
% user input doesn't rotate it to that point.
knee_pos2_extended = rotz(60) * knee_pos1';
r1_KEb_extended = rotz(90) * ((rotz(60) * r1_KEb_pos1') - knee_pos2_extended) + knee_pos2_extended;
r2_KEb_extended = rotz(90) * ((rotz(60) * r2_KEb_pos1') - knee_pos2_extended) + knee_pos2_extended;

string_length = (pi()/2)*(((r1_AEb_length^2) + (r2_AEb_length^2))/2)^0.5;

lower_AEb_pos2 = rAEb_eff' + string_length * (upper_AEb_pos2' - rAEb_eff')/norm(upper_AEb_pos2' - rAEb_eff');

%% Plot fully flexed position of the knee in 2D space (position 2)
subplot(1, 2, 2)
hold on

% Plot the femur from knee position, and add a marker at the knee
plot([0, knee_pos2(1)], [0, knee_pos2(2)], '-m', 'LineWidth', 4)
plot(knee_pos2(1), knee_pos2(2), 'o', 'LineWidth', 3)

% Plot the tibia from knee to ankle points
plot([knee_pos2(1), ankle_pos2(1)], [knee_pos2(2), ankle_pos2(2)], '-m', 'LineWidth', 4)

% Plot the cam radii for flexor and extensor (2 each) for position 1 as
% points
plot(r1_KFb_pos2(1), r1_KFb_pos2(2), '*c'); plot(r2_KFb_pos2(1), r2_KFb_pos2(2), '*c')
plot(r1_KEb_pos2(1), r1_KEb_pos2(2), '*b'); plot(r2_KEb_pos2(1), r2_KEb_pos2(2), '*b')
plot(camKF(1,:), camKF(2,:)); plot(camKE(1,:), camKE(2,:))

% Plot the CAM radii for the ankle
plot(r1_AEb_pos2(1), r1_AEb_pos2(2), '*b')
plot(r2_AEb_pos2(1), r2_AEb_pos2(2), '*b')
plot(camAE(1,:), camAE(2,:))

% Plot the ankle/foot as a circle
plot(ankle_pos2(1), ankle_pos2(2), 'o', 'LineWidth', 3)

% Plot the hip/body as a horizontal line for reference
plot([-.1, .1], [0, 0], '-k', 'LineWidth', 12)

% Mark the hip joint as the origin
plot(0, 0, 'xg', 'LineWidth', 3)

% Plot the foot as a straight line
plot([ankle_pos2(1) toe_pos2(1)], [ankle_pos2(2) toe_pos2(2)], '-m', 'LineWidth', 4)

% Plot the ankle extensor actuator
plot([upper_AEb_pos2(1) lower_AEb_pos2(1)], [upper_AEb_pos2(2) lower_AEb_pos2(2)], '-b', 'LineWidth', 3)

% Plot the string from ankle to actuator
plot([rAEb_eff(1) lower_AEb_pos2(1)], [rAEb_eff(2) lower_AEb_pos2(2)])

% Plot the lines representing strings for the flexor and extensor
plot([b_KFb_top(1) rKFb_eff(1)], [b_KFb_top(2) rKFb_eff(2)], 'b')
plot([b_KEb_top(1) rKEb_eff(1)], [b_KEb_top(2) rKEb_eff(2)], 'b')

% Plot the final pulley point before string goes to the tibia for the
% lfexor and extensor
plot(b_KFb_top(1), b_KFb_top(2), 'xr', 'LineWidth', 5)
plot(b_KEb_top(1), b_KEb_top(2), 'xr', 'LineWidth', 5)



% Finish labeling the plot
xlim([-0.1 0.5])
ylim([-0.4 0.2])
title(sprintf('Knee flexor at position 2:\nHip extended %.0f degrees, knee flexed %.0f degrees', rot_hip, rot_knee))
xlabel('x position (m)')
ylabel('y position (m)')
daspect([1 1 1])


%% Define the strain necessary to achieve position 2

% DefineThe effective length of the string or actuator/string with the
% actuator fully deflated, in an extended position.
L_KFb_rest = norm(r1_KFb_pos1 - b_KFb_top); 
L_KEb_rest = norm(r2_KEb_extended' - b_KEb_top);
L_AEb_rest = norm(r1_AEb_pos1 - upper_AEb_pos1);

% Define the length of string wrapped around the cam at the fully
%extended/resting position. Using an approximation of a quarter of an
%ellipse.
L_KFb_camstring = (pi()/2)*(((r1_KFb_length^2) + (r2_KFb_length^2))/2)^0.5;
L_KEb_camstring = (pi()/2)*(((r1_KEb_length^2) + (r2_KEb_length^2))/2)^0.5;
L_AEb_camstring = (pi()/2)*(((r1_AEb_length^2) + (r2_AEb_length^2))/2)^0.5;

% Define the length of the string/actuator after desired rotation (this is
% from origin to effective attachment point on the outside of the cam).
L_KFb_rot = norm(rKFb_eff' - b_KFb_top); 
L_KEb_rot = norm(rKEb_eff' - b_KEb_top);
L_AEb_rot = norm(rAEb_eff' - upper_AEb_pos2');

% Define the length of string wrapped around the cam at the new position. 
% Using an approximation of the degree of rotation as a fraction of the
% ellipse of the cam.
L_KFb_camstring_new = ((90 - rot_knee)/360) * (pi()*2)*(((r1_KFb_length^2) + (r2_KFb_length^2))/2)^0.5;
L_KEb_camstring_new = ((rot_knee)/360) * (pi()*2)*(((r1_KEb_length^2) + (r2_KEb_length^2))/2)^0.5;
L_AEb_camstring_new = ((90 - rot_ankle)/360) * (pi()*2)*(((r1_AEb_length^2) + (r2_AEb_length^2))/2)^0.5;

% Define the change in actuator length by subtracting the new length from
% the old length, including the parts of string wrapped around the cam at
% both positions.
delta_L_KFb = (L_KFb_rest + L_KFb_camstring) - (L_KFb_rot + L_KFb_camstring_new);
delta_L_KEb = (L_KEb_rest + L_KEb_camstring) - (L_KEb_rot + L_KEb_camstring_new);
delta_L_AEb = (L_AEb_rest + L_AEb_camstring) - (L_AEb_rot + L_AEb_camstring_new);

% Calculate strain from contracted and resting lengths
k_KFb = delta_L_KFb / L_KFb;
k_KEb = delta_L_KEb / L_KEb;
k_AEb = delta_L_AEb / L_AEb;

%Print out actuator lengths and desired rotations.
clc
fprintf('\nHip rotation: %.0f degrees', rot_hip)
fprintf('\nKnee rotation: %.0f degrees', rot_knee)
fprintf('\nAnkle rotation: %.0f degrees', rot_ankle)
fprintf('\n\nBA knee flexor actuator length: %.0f inches', L_KFb/0.0254)
fprintf('\nBA knee extensor actuator length: %.0f inches', L_KEb/0.0254)
fprintf('\nBA ankle extensor actuator length: %.0f inches', L_AEb/0.0254)

% Print out actuator strains at position 2.
fprintf('\n\nBA knee flexor strain to achieve position 2: %.2f', k_KFb)
fprintf('\nBA knee extensor strain to achieve position 1: %.2f', k_KEb)
fprintf('\nBA ankle extensor strain to achieve this position: %.2f\n', k_AEb)

%% Torque calculations for the biarticular knee flexor and knee extensor
% 
% % NOTE: THESE HAVE ONLY BEEN SET UP TO DEFINE TORQUE AT SET POSITIONS.
% % Needs modification to find force at a given rotation.
% 
% % Torque requirements for knee flexor:
% % Define torques created by the weight of the different leg segments
% T1_KFb = 0.5 * l1 * cosd(60) * (m1 + m_KF + m_KE) * g;                      % [N-m]
% T2_KFb = (l1 * cosd(60) + 0.5 * l2 * sind(60)) * (m2 + m_AF + m_AE) * g;    % [N-m]
% T3_KFb = (l1 * cosd(60) + (l2 + l3/2) * sind(60)) * m3 * g;                 % [N-m]
% T_knee_KFb = l1 * cosd(60) * me * g;                                        % [N-m]
% T_ankle_KFb = (l1 * cosd(60) + l2 * sind(60)) * me * g;                     % [N-m]
% 
% % Define force necessary for actuator to exert to hold leg at position 2
% F_KFb = (T1_KFb + T2_KFb + T3_KFb + T_knee_KFb + T_ankle_KFb) / r2_KFb_length;  % [N]              % [N]         
% 
% 
% % Torque requirements for knee extensor:
% % Define torques created by the weight of the different leg segments
% T1_KEb = 0.5 * l1 * sind(30) * (m1 + m_KF + m_KE) * g;             % [N-m]
% T2_KEb = ((l1 + 0.5 * l2) * sind(30)) * (m2 + m_AF + m_AE) * g;    % [N-m]
% T3_KEb = (((l1 + l2) * sind(30)) + (l3/2)) * m3 * g;               % [N-m]
% T_knee_KEb = l1 * sind(30) * me * g;                               % [N-m]
% T_ankle_KEb = (l1 + l2) * sind(30) * me * g;                       % [N-m]
% 
% % Define force necessary for actuator to exert to hold leg at position 1
% F_KEb = (T1_KEb + T2_KEb + T3_KEb + T_knee_KEb + T_ankle_KEb) / r1_KEb_length;                % [N] 
% 
% 
% % Torque requirements for ankle extensor:
% % Define torques created by the weight of the different leg segments
% T2_AEb = (0.5 * l2) * (m2 + m_AF + m_AE) * g;                      % [N-m]
% T3_AEb = (l2 + 0.5 * l3) * m3 * g;                                 % [N-m]
% T_ankle_AEb = l2 * me * g;                                         % [N-m]
% 
% % Define force necessary for actuator to exert to hold leg at a fully
% % contracted position with the femur aligned with the vertical
% F_AEb = (T2_AEb + T3_KEb + T_ankle_AEb) / r2_AEb_length;                % [N] 
% 
% % Print out force required to hold position 1 and 2 for the knee extensor
% % and flexor, respectively
% fprintf('\nThe required force for the BA knee flexor to hold a fully contracted position is %.1f pounds\n', F_KFb/4.448)
% fprintf('\nThe required force for the BA knee extensor to hold a fully contracted position is %.1f pounds\n', F_KEb/4.448)
% fprintf('\nThe required force for the BA ankle extensor to hold position 1 is %.1f pounds', F_AEb/4.448)
% 
% %% Plotting strain vs necessary pressure for a given force
% 
% % Constructing a pressure vs strain plot for BPAs of varying force based on
% % equation 4.
% 
% % Define range of strains
% k = 0.001:0.001:0.2;            % []
% k_max = 0.17;                   % []
% F = (0:6:36) * 4.448;           % [N] (pounds to newtons conversion)
% S = 1;                          % [0,1] hysteresis 
% 
% key = strings(1,length(F));
% 
% figure(2)
% % plot pressure vs strain, each loop doing a different applied force
% for n = 1:length(F)
%     tangent = a2 * ((k./ (a4 * F(n) + k_max)) + a3);
%     tangent(tangent > (pi()/2)) = [];
%     P = a0 + (a1 * tan(tangent)) + (a5 * F(n)) + (a6 * S); % [Pa]
%     plot(k(1:length(P)), P/1000, '.')
%     hold on
%     key(n) = sprintf('Applied force: %.1f pounds', F(n)/4.448);
% end
% 
% % Plot strain and forces required for position 1 and 2 for biarticular knee
% % muscles
% plot(k_KFb, 0.001 * (a0 + (a1 * tan( a2 * ((k_KFb./ (a4 * F_KFb + k_max)) + a3))) + (a5 * F_KFb) + (a6 * S)), 'xr', 'LineWidth', 2)
% plot(k_KEb, 0.001 * (a0 + (a1 * tan( a2 * ((k_KEb./ (a4 * F_KEb + k_max)) + a3))) + (a5 * F_KEb) + (a6 * S)), 'xb', 'LineWidth', 2)
% 
% % Plot maximum pressure line at P = 620 kPa
% plot([0 .2], [620 620], '-r')
% 
% legend(key)
% xlabel('Strain')
% ylabel('Pressure (kPa)')
% xlim([0 0.2])
% ylim([0 900])
% title(sprintf('Required pressure to achieve a given strain with varied applied force'))
% set(gcf,'color','w');