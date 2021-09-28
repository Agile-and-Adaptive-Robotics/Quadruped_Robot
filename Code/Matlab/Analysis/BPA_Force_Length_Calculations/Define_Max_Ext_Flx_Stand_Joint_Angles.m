%% Define the Maximum Extension, Maximum Flexion, and Standing Joint Angles.

%Define the maximum extension, maximum flexion, and standing angles for the front leg.
theta_front_hip_ext = -45; theta_front_hip_flx = 15; theta_front_hip_standing = 5;
theta_front_knee1_ext = 0; theta_front_knee1_flx = 90; theta_front_knee1_standing = 30;
theta_front_knee2_ext = 0; theta_front_knee2_flx = -90; theta_front_knee2_standing = -30;
theta_front_ankle_ext = 0; theta_front_ankle_flx = -90; theta_front_ankle_standing = -30;

%Define the maximum extension, maximum flexion, and standing angles for the back leg.
theta_back_hip_ext = 45; theta_back_hip_flx = -45; theta_back_hip_standing = 5; 
theta_back_knee_ext = 0; theta_back_knee_flx = 90; theta_back_knee_standing = 45;
theta_back_ankle_ext = 0; theta_back_ankle_flx = -90; theta_back_ankle_standing = -105;

%Compute the range of motion for the front leg joints.
theta_front_hip_rom = abs(theta_front_hip_ext) + abs(theta_front_hip_flx);
theta_front_knee1_rom = abs(theta_front_knee1_ext) + abs(theta_front_knee1_flx);
theta_front_knee2_rom = abs(theta_front_knee2_ext) + abs(theta_front_knee2_flx);
theta_front_ankle_rom = abs(theta_front_ankle_ext) + abs(theta_front_ankle_flx);

%Compute the range of motion for the back leg joints.
theta_back_hip_rom = abs(theta_back_hip_ext) + abs(theta_back_hip_flx);
theta_back_knee_rom = abs(theta_back_knee_ext) + abs(theta_back_knee_flx);
theta_back_ankle_rom = abs(theta_back_ankle_ext) + abs(theta_back_ankle_flx);

