%% Muscle Length Requirements
%This script computes the muscle length requirements based on the desired changes in muscle length.

%Clear Everything
clear, close('all'), clc

%% Plot the Maximum Strain vs Resting Length (@ 8 lbs).

%Define the resting muscle lengths.
Lrests = 39.3701*[15.3e-2 18.3e-2 27.3e-2];

%Define the resulting maximum strains.
eps_max_Ls = [0.13 0.1425 0.155];

%Fit a line to the maximum strain vs resting length data.
p_eps_Ls = polyfit(Lrests, eps_max_Ls, 1);

%Compute the associated draw lengths.
deltaL_Ls = eps_max_Ls.*Lrests;

%Plot the maximum strain vs resting length.
figure, hold on, grid on, title('Maximum Strain vs Resting Length (@F = 8 lbs)'), xlabel('Resting Length [in]'), ylabel('Maximum Strain [-]')
plot(Lrests, eps_max_Ls, '.k', 'Markersize', 20), fplot(@(x) polyval(p_eps_Ls, x), [min(Lrests) max(Lrests)])

%Plot the maximum draw length vs resting length.
figure, hold on, grid on, title('Maximum Draw Length vs Resting Length (@F = 8 lbs)'), xlabel('Resting Length [in]'), ylabel('Maximum Draw Length [in]')
plot(Lrests, deltaL_Ls, '.k', 'Markersize', 20)


%% Plot the Maximum Strain & Draw Length vs Applied Force.

%Define the resting muscle length.
Lcrit = 39.3701*18.9e-2;

%Define the applied forces.
Fs = [0 12 24];

%Define the resulting maximum strains.
eps_max_Fs = [0.165 0.1425 0.12];

%Fit a line to the maximum strain vs applied force data.
p_eps_Fs = polyfit(Fs, eps_max_Fs, 1);

%Compute the associated draw lengths.
deltaL_Fs = eps_max_Fs*Lcrit;

%Plot the maximum strain vs applied force.
figure, hold on, grid on, title('Maximum Strain vs Applied Force (@L_0 = 18.9 cm)'), xlabel('Applied Force [lbs]'), ylabel('Maximum Strain [-]')
plot(Fs, eps_max_Fs, '.k', 'Markersize', 20), fplot(@(x) polyval(p_eps_Fs, x), [min(Fs) max(Fs)])

%Plot the maximum draw length vs applied force.
figure, hold on, grid on, title('Maximum Draw Length vs Applied Force (@L_0 = 18.9 cm)'), xlabel('Applied Force [lbs]'), ylabel('Maximum Draw Length [in]')
plot(Fs, deltaL_Fs, '.k', 'Markersize', 20)


%% Plot the Maximum Strain & Draw Length Functions.

%Define the maximum strain function with respect to resting length.
fstrain_L = @(x) polyval(p_eps_Ls, x);

%Define the maximum strain function with respect to applied force.
fstrain_F = @(x) polyval(p_eps_Fs, x);

%Define the draw length function with respect to resting length.
fdraw_length_L = @(x) fstrain_L(x).*x;

%Define the draw length function with respect to applied force.
fdraw_length_F = @(x) fstrain_F(x)*Lcrit;

%Plot the maximum strain function.
figure, hold on, grid on, title('Maximum Strain vs Resting Actuator Length (@F = 8 lbs)'), xlabel('Resting Actuator Length [in]'), ylabel('Maximum Strain [-]'), fplot(fstrain_L, [0 15])

%Plot the draw length function.
figure, hold on, grid on, title('Draw Length vs Resting Actuator Length (@F = 8 lbs)'), xlabel('Resting Actuator Length [in]'), ylabel('Draw Length [in]'), fplot(fdraw_length_L, [0 15])


%% Plot the Modified Draw Length Function (@F = 0 lbs).

%Compute the strain offset.
strain_offset = fstrain_F(0) - fstrain_F(8);

%Compute the modified strain function for an applied force of F = 0 lbs.
fstrain_mod = @(x) fstrain_L(x) + strain_offset;

%Compute the modified draw length function for an applied force of F = 0 lbs.
fdraw_length_mod = @(x) fstrain_mod(x).*x;

%Plot the modified maximum strain function.
figure, hold on, grid on, title('Maximum Strain vs Resting Actuator Length'), xlabel('Resting Actuator Length [in]'), ylabel('Maximum Strain [-]')
fplot(fstrain_mod, [0 15]), fplot(fstrain_L, [0 15])
legend('F = 0 lbs', 'F = 8 lbs')

%Plot the modified draw length function.
figure, hold on, grid on, title('Draw Length vs Resting Actuator Length'), xlabel('Resting Actuator Length [in]'), ylabel('Draw Length [in]')
fplot(fdraw_length_mod, [0 15]), fplot(fdraw_length_L, [0 15])
legend('F = 0 lbs', 'F = 8 lbs')

%% Define a Function to Compute the Resting Muscle Length From the Draw Length.

%Create a function to compute the resting muscle length required to achieve a given draw length.
fresting_length = @(x) fzero(@(y) (fdraw_length_mod(y) - x), 1);

%Plot the resting muscle length required vs draw length.
figure, hold on, grid on, title('Resting Actuator Length vs Draw Length'), xlabel('Draw Length [in]'), ylabel('Resting Actuator Length [in]'), axis([0 3 0 15]), fplot(fresting_length, [0 3])


%% Plot the Standing Joint Locations and the Standing Muscle Attachment Locations.

%Define the joint locations and muscle attachment locations in the original standing position.
Define_Joint_Attachment_Standing_Positions

%Plot the standing joint locations.
fig = figure; hold on, grid on, title('Joint Locations'), xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis'), rotate3d on, axis equal
plot3(p_Front_Joints_Stand(1, :), p_Front_Joints_Stand(2, :), p_Front_Joints_Stand(3, :), '.-k', 'Markersize', 20);
plot3(p_Back_Joints_Stand(1, :), p_Back_Joints_Stand(2, :), p_Back_Joints_Stand(3, :), '.-k', 'Markersize', 20)
plot3(p_Attachments_Ext_Stand(1, :), p_Attachments_Ext_Stand(2, :), p_Attachments_Ext_Stand(3, :), '.k', 'Markersize', 20);
plot3(p_Attachments_Flx_Stand(1, :), p_Attachments_Flx_Stand(2, :), p_Attachments_Flx_Stand(3, :), '.k', 'Markersize', 20);


%% Compute the Limb Lengths.

%Compute the front limb lengths.
l_Front_Shoulder = norm(p_Front_Hip_Joint_Stand, 2);
l_Front_Femur = norm(p_Front_Knee1_Joint_Stand - p_Front_Hip_Joint_Stand, 2);
l_Front_Pantograph = norm(p_Front_Knee2_Joint_Stand - p_Front_Knee1_Joint_Stand, 2);
l_Front_Tibia = norm(p_Front_Ankle_Joint_Stand - p_Front_Knee2_Joint_Stand, 2);
l_Front_Foot = norm(p_Front_Foot_Joint_Stand - p_Front_Ankle_Joint_Stand, 2);

%Compute the rear limb lengths.
l_Back_Shoulder = norm(p_Back_Hip_Joint_Stand, 2);
l_Back_Femur = norm(p_Back_Knee_Joint_Stand - p_Back_Hip_Joint_Stand, 2);
l_Back_Tibia = norm(p_Back_Ankle_Joint_Stand - p_Back_Knee_Joint_Stand, 2);
l_Back_Foot = norm(p_Back_Foot_Joint_Stand - p_Back_Ankle_Joint_Stand, 2);

%Store the front limb lengths in an array.
ls_Front = [l_Front_Femur l_Front_Pantograph l_Front_Tibia l_Front_Foot];
ls_Back = [l_Back_Femur l_Back_Tibia l_Back_Foot];


%% Define the Home Joint Locations.

%Define the front joint locations.
p_Front_Hip_Joint_Home = p_Front_Hip_Joint_Stand;
p_Front_Knee1_Joint_Home = p_Front_Hip_Joint_Home + [0; -l_Front_Femur; 0];
p_Front_Knee2_Joint_Home = p_Front_Knee1_Joint_Home + [0; -l_Front_Pantograph; 0];
p_Front_Ankle_Joint_Home = p_Front_Knee2_Joint_Home + [0; -l_Front_Tibia; 0];
p_Front_Foot_Joint_Home = p_Front_Ankle_Joint_Home + [0; -l_Front_Foot; 0];

%Define the back joint locations.
p_Back_Hip_Joint_Home = p_Back_Hip_Joint_Stand;
p_Back_Knee_Joint_Home = p_Back_Hip_Joint_Home + [0; -l_Back_Femur; 0];
p_Back_Ankle_Joint_Home = p_Back_Knee_Joint_Home + [0; -l_Back_Tibia; 0];
p_Back_Foot_Joint_Home = p_Back_Ankle_Joint_Home + [0; -l_Back_Foot; 0];

%Store the front & back joints into matrices.
p_Front_Joints_Home = [p_Front_Hip_Joint_Home p_Front_Knee1_Joint_Home p_Front_Knee2_Joint_Home p_Front_Ankle_Joint_Home p_Front_Foot_Joint_Home];
p_Back_Joints_Home = [p_Back_Hip_Joint_Home p_Back_Knee_Joint_Home p_Back_Ankle_Joint_Home p_Back_Foot_Joint_Home];

%Plot the home joint positions.
plot3(p_Front_Joints_Home(1, :), p_Front_Joints_Home(2, :), p_Front_Joints_Home(3, :), '.-c', 'Markersize', 20);
plot3(p_Back_Joints_Home(1, :), p_Back_Joints_Home(2, :), p_Back_Joints_Home(3, :), '.-c', 'Markersize', 20);


%% Define the Home Muscle Attachment Point Locations.

%Define the Home Muscle Attachment Point Locations.
Define_Attachment_Home_Positions


%% Plot the Home Muscle Attachment Point Locations.

%Plot the home muscle attachment locations.
plot3(p_Attachments_Ext_Home(1, :), p_Attachments_Ext_Home(2, :), p_Attachments_Ext_Home(3, :), '.c', 'Markersize', 20);
plot3(p_Attachments_Flx_Home(1, :), p_Attachments_Flx_Home(2, :), p_Attachments_Flx_Home(3, :), '.c', 'Markersize', 20);


%% Define the Home Pulley Locations.

%Define the pulley locations for the front extensor muscles.
p_Front_Knee_Pulley_Ext_Home = [-10.75000; -4.375000; 0];
p_Front_Ankle_Pulley_Ext_Home = [-9.37500; -19.750000; 0];

%Define the pulley locations for the front flexor muscles.
p_Front_Knee_Pulley_Flx_Home = [-9.125000; -5.875; 0];
p_Front_Ankle_Pulley_Flx_Home = [-10.875000; -21.375; 0];                 %This is just slightly out of bounds assuming pulley is on lower member.
% p_Front_Ankle_Pulley_Flx_Home = [-10.625; -20.375; 0];                      %This is in bounds assuming pulley is on upper member.

%Define the pulley locations for the front extensor muscles.
p_Back_Knee_Pulley_Ext_Home = [9.375000; -6.875000; 0];
p_Back_Ankle_Pulley_Ext_Home = [10.625000; -15.125000; 0];

%Define the pulley locations for the front flexor muscles.
p_Back_Knee_Pulley_Flx_Home = [10.8750; -8.375; 0];
p_Back_Ankle_Pulley_Flx_Home = [9.125000; -16.875; 0];

%Store the pulley locations for the extensor muscles into an array.
p_Front_Pulley_Ext_Home = [p_Front_Knee_Pulley_Ext_Home p_Front_Ankle_Pulley_Ext_Home];
p_Back_Pulley_Ext_Home = [p_Back_Knee_Pulley_Ext_Home p_Back_Ankle_Pulley_Ext_Home];

%Store the pulley locations for the flexor muscles into an array.
p_Front_Pulley_Flx_Home = [p_Front_Knee_Pulley_Flx_Home p_Front_Ankle_Pulley_Flx_Home];
p_Back_Pulley_Flx_Home = [p_Back_Knee_Pulley_Flx_Home p_Back_Ankle_Pulley_Flx_Home];


%% Plot the Home Pulley Locations.

%Plot the front home pulley locations.
plot3(p_Front_Pulley_Ext_Home(1, :), p_Front_Pulley_Ext_Home(2, :), p_Front_Pulley_Ext_Home(3, :), '.c', 'Markersize', 20);
plot3(p_Front_Pulley_Flx_Home(1, :), p_Front_Pulley_Flx_Home(2, :), p_Front_Pulley_Flx_Home(3, :), '.c', 'Markersize', 20);

%Plot the back home pulley locations.
plot3(p_Back_Pulley_Ext_Home(1, :), p_Back_Pulley_Ext_Home(2, :), p_Back_Pulley_Ext_Home(3, :), '.c', 'Markersize', 20);
plot3(p_Back_Pulley_Flx_Home(1, :), p_Back_Pulley_Flx_Home(2, :), p_Back_Pulley_Flx_Home(3, :), '.c', 'Markersize', 20);


%% Compute the Attachment Point Radii with Respect to the Joint Locations.

%Compute the vector from the front knee muscle attachment points to the knee joint location.
r_front_knee_joint_ext = p_Front_Knee1_Joint_Home - p_Front_Knee_Ext2_Home;
r_front_knee_joint_flx = p_Front_Knee1_Joint_Home - p_Front_Knee_Flx2_Home;

%Compute the vector from the front ankle muscle attachment points to the ankle joint location.
r_front_ankle_joint_ext = p_Front_Ankle_Joint_Home - p_Front_Ankle_Ext2_Home;
r_front_ankle_joint_flx = p_Front_Ankle_Joint_Home - p_Front_Ankle_Flx2_Home;

%Compute the vector from the back knee muscle attachment points to the knee joint location.
r_back_knee_joint_ext = p_Back_Knee_Joint_Home - p_Back_Knee_Ext2_Home;
r_back_knee_joint_flx = p_Back_Knee_Joint_Home - p_Back_Knee_Flx2_Home;

%Compute the vector from the back ankle muscle attachment points to the ankle joint location.
r_back_ankle_joint_ext = p_Back_Ankle_Joint_Home - p_Back_Ankle_Ext2_Home;
r_back_ankle_joint_flx = p_Back_Ankle_Joint_Home - p_Back_Ankle_Flx2_Home;

%Compute the radius of rotation for the front knee extensor and flexor.
rmag_front_knee_joint_ext = norm(r_front_knee_joint_ext, 2);
rmag_front_knee_joint_flx = norm(r_front_knee_joint_flx, 2);

%Compute the radius of rotation for the front ankle extensor and flexor.
rmag_front_ankle_joint_ext = norm(r_front_ankle_joint_ext, 2);
rmag_front_ankle_joint_flx = norm(r_front_ankle_joint_flx, 2);

%Compute the radius of rotation for the back knee extensor and flexor.
rmag_back_knee_joint_ext = norm(r_back_knee_joint_ext, 2);
rmag_back_knee_joint_flx = norm(r_back_knee_joint_flx, 2);

%Compute the radius of rotation for the back ankle extensor and flexor.
rmag_back_ankle_joint_ext = norm(r_back_ankle_joint_ext, 2);
rmag_back_ankle_joint_flx = norm(r_back_ankle_joint_flx, 2);


%% Compute the Pulley Point Radii with Respect to the Attachment Point

%Compute the vector from the front knee muscle attachment points to the pulley locations.
r_front_knee_pulley_ext = p_Front_Knee_Pulley_Ext_Home - p_Front_Knee_Ext2_Home;
r_front_knee_pulley_flx = p_Front_Knee_Pulley_Flx_Home - p_Front_Knee_Flx2_Home;

%Compute the vector from the front ankle muscle attachment points to the pulley locations.
r_front_ankle_pulley_ext = p_Front_Ankle_Pulley_Ext_Home - p_Front_Ankle_Ext2_Home;
r_front_ankle_pulley_flx = p_Front_Ankle_Pulley_Flx_Home - p_Front_Ankle_Flx2_Home;

%Compute the vector from the back knee muscle attachment points to the pulley locations.
r_back_knee_pulley_ext = p_Back_Knee_Pulley_Ext_Home - p_Back_Knee_Ext2_Home;
r_back_knee_pulley_flx = p_Back_Knee_Pulley_Flx_Home - p_Back_Knee_Flx2_Home;

%Compute the vector from the back ankle muscle attachment points to the pulley locations.
r_back_ankle_pulley_ext = p_Back_Ankle_Pulley_Ext_Home - p_Back_Ankle_Ext2_Home;
r_back_ankle_pulley_flx = p_Back_Ankle_Pulley_Flx_Home - p_Back_Ankle_Flx2_Home;

%Compute the distance between the front knee muscle attachment points and their pulley locations.
rmag_front_knee_pulley_ext = norm(p_Front_Knee_Pulley_Ext_Home - p_Front_Knee_Ext2_Home, 2);
rmag_front_knee_pulley_flx = norm(p_Front_Knee_Pulley_Flx_Home - p_Front_Knee_Flx2_Home, 2);

%Compute the distance between the front ankle muscle attachment points and their pulley locations.
rmag_front_ankle_pulley_ext = norm(p_Front_Ankle_Pulley_Ext_Home - p_Front_Ankle_Ext2_Home, 2);
rmag_front_ankle_pulley_flx = norm(p_Front_Ankle_Pulley_Flx_Home - p_Front_Ankle_Flx2_Home, 2);

%Compute the distance between the back knee muscle attachment points and their pulley locations.
rmag_back_knee_pulley_ext = norm(p_Back_Knee_Pulley_Ext_Home - p_Back_Knee_Ext2_Home, 2);
rmag_back_knee_pulley_flx = norm(p_Back_Knee_Pulley_Flx_Home - p_Back_Knee_Flx2_Home, 2);

%Compute the distance between the back ankle muscle attachment points and their pulley locations.
rmag_back_ankle_pulley_ext = norm(p_Back_Ankle_Pulley_Ext_Home - p_Back_Ankle_Ext2_Home, 2);
rmag_back_ankle_pulley_flx = norm(p_Back_Ankle_Pulley_Flx_Home - p_Back_Ankle_Flx2_Home, 2);


%% Compute the String Angle.

%Compute the front knee string angle.
gamma_front_knee_ext = acos(dot(r_front_knee_pulley_ext, r_front_knee_joint_ext)/(rmag_front_knee_pulley_ext*rmag_front_knee_joint_ext));
gamma_front_knee_flx = acos(dot(r_front_knee_pulley_flx, r_front_knee_joint_flx)/(rmag_front_knee_pulley_flx*rmag_front_knee_joint_flx));

%Compute the front ankle string angle.
gamma_front_ankle_ext = acos(dot(r_front_ankle_pulley_ext, r_front_ankle_joint_ext)/(rmag_front_ankle_pulley_ext*rmag_front_ankle_joint_ext));
gamma_front_ankle_flx = acos(dot(r_front_ankle_pulley_flx, r_front_ankle_joint_flx)/(rmag_front_ankle_pulley_flx*rmag_front_ankle_joint_flx));

%Compute the back knee string angle.
gamma_back_knee_ext = acos(dot(r_back_knee_pulley_ext, r_back_knee_joint_ext)/(rmag_back_knee_pulley_ext*rmag_back_knee_joint_ext));
gamma_back_knee_flx = acos(dot(r_back_knee_pulley_flx, r_back_knee_joint_flx)/(rmag_back_knee_pulley_flx*rmag_back_knee_joint_flx));

%Compute the back ankle string angle.
gamma_back_ankle_ext = acos(dot(r_back_ankle_pulley_ext, r_back_ankle_joint_ext)/(rmag_back_ankle_pulley_ext*rmag_back_ankle_joint_ext));
gamma_back_ankle_flx = acos(dot(r_back_ankle_pulley_flx, r_back_ankle_joint_flx)/(rmag_back_ankle_pulley_flx*rmag_back_ankle_joint_flx));



%% Define the Home Transformation Matrices.

%Define the front home transformation matrices for the joints.
M_Front_Hip_Joint = [eye(3) p_Front_Hip_Joint_Home; zeros(1, 3) 1];
M_Front_Knee1_Joint = [eye(3) p_Front_Knee1_Joint_Home; zeros(1, 3) 1];
M_Front_Knee2_Joint = [eye(3) p_Front_Knee2_Joint_Home; zeros(1, 3) 1];
M_Front_Ankle_Joint = [eye(3) p_Front_Ankle_Joint_Home; zeros(1, 3) 1];
M_Front_Foot_Joint = [eye(3) p_Front_Foot_Joint_Home; zeros(1, 3) 1];

%Define the back home transformation matrices for the joints.
M_Back_Hip_Joint = [eye(3) p_Back_Hip_Joint_Home; zeros(1, 3) 1];
M_Back_Knee_Joint = [eye(3) p_Back_Knee_Joint_Home; zeros(1, 3) 1];
M_Back_Ankle_Joint = [eye(3) p_Back_Ankle_Joint_Home; zeros(1, 3) 1];
M_Back_Foot_Joint = [eye(3) p_Back_Foot_Joint_Home; zeros(1, 3) 1];

%Define the front home transformation matrices for the extensor muscle attachment points.
M_Front_Hip_Ext1 = [eye(3) p_Front_Hip_Ext1_Home; zeros(1, 3) 1];
M_Front_Hip_Ext2 = [eye(3) p_Front_Hip_Ext2_Home; zeros(1, 3) 1];
M_Front_Knee_Ext1 = [eye(3) p_Front_Knee_Ext1_Home; zeros(1, 3) 1];
M_Front_Knee_Ext2 = [eye(3) p_Front_Knee_Ext2_Home; zeros(1, 3) 1];
M_Front_Ankle_Ext1 = [eye(3) p_Front_Ankle_Ext1_Home; zeros(1, 3) 1];
M_Front_Ankle_Ext2 = [eye(3) p_Front_Ankle_Ext2_Home; zeros(1, 3) 1];

%Define the front home transformation matrices for the flexor muscle attachment points.
M_Front_Hip_Flx1 = [eye(3) p_Front_Hip_Flx1_Home; zeros(1, 3) 1];
M_Front_Hip_Flx2 = [eye(3) p_Front_Hip_Flx2_Home; zeros(1, 3) 1];
M_Front_Knee_Flx1 = [eye(3) p_Front_Knee_Flx1_Home; zeros(1, 3) 1];
M_Front_Knee_Flx2 = [eye(3) p_Front_Knee_Flx2_Home; zeros(1, 3) 1];
M_Front_Ankle_Flx1 = [eye(3) p_Front_Ankle_Flx1_Home; zeros(1, 3) 1];
M_Front_Ankle_Flx2 = [eye(3) p_Front_Ankle_Flx2_Home; zeros(1, 3) 1];

%Define the back home transformation matrices for the extensor muscle attachment points.
M_Back_Hip_Ext1 = [eye(3) p_Back_Hip_Ext1_Home; zeros(1, 3) 1];
M_Back_Hip_Ext2 = [eye(3) p_Back_Hip_Ext2_Home; zeros(1, 3) 1];
M_Back_Knee_Ext1 = [eye(3) p_Back_Knee_Ext1_Home; zeros(1, 3) 1];
M_Back_Knee_Ext2 = [eye(3) p_Back_Knee_Ext2_Home; zeros(1, 3) 1];
M_Back_Ankle_Ext1 = [eye(3) p_Back_Ankle_Ext1_Home; zeros(1, 3) 1];
M_Back_Ankle_Ext2 = [eye(3) p_Back_Ankle_Ext2_Home; zeros(1, 3) 1];

%Define the back home transformation matrices for the flexor muscle attachment points.
M_Back_Hip_Flx1 = [eye(3) p_Back_Hip_Flx1_Home; zeros(1, 3) 1];
M_Back_Hip_Flx2 = [eye(3) p_Back_Hip_Flx2_Home; zeros(1, 3) 1];
M_Back_Knee_Flx1 = [eye(3) p_Back_Knee_Flx1_Home; zeros(1, 3) 1];
M_Back_Knee_Flx2 = [eye(3) p_Back_Knee_Flx2_Home; zeros(1, 3) 1];
M_Back_Ankle_Flx1 = [eye(3) p_Back_Ankle_Flx1_Home; zeros(1, 3) 1];
M_Back_Ankle_Flx2 = [eye(3) p_Back_Ankle_Flx2_Home; zeros(1, 3) 1];

%Define the front home transformation matrices for the extensor muscle pulley points.
M_Front_Knee_Pulley_Ext = [eye(3) p_Front_Knee_Pulley_Ext_Home; zeros(1, 3) 1];
M_Front_Ankle_Pulley_Ext = [eye(3) p_Front_Ankle_Pulley_Ext_Home; zeros(1, 3) 1];

%Define the front home transformation matrices for the flexor muscle pulley points.
M_Front_Knee_Pulley_Flx = [eye(3) p_Front_Knee_Pulley_Flx_Home; zeros(1, 3) 1];
M_Front_Ankle_Pulley_Flx = [eye(3) p_Front_Ankle_Pulley_Flx_Home; zeros(1, 3) 1];

%Define the back home transformation matrices for the extensor muscle pulley points.
M_Back_Knee_Pulley_Ext = [eye(3) p_Back_Knee_Pulley_Ext_Home; zeros(1, 3) 1];
M_Back_Ankle_Pulley_Ext = [eye(3) p_Back_Ankle_Pulley_Ext_Home; zeros(1, 3) 1];

%Define the back home transformation matrices for the flexor muscle pulley points.
M_Back_Knee_Pulley_Flx = [eye(3) p_Back_Knee_Pulley_Flx_Home; zeros(1, 3) 1];
M_Back_Ankle_Pulley_Flx = [eye(3) p_Back_Ankle_Pulley_Flx_Home; zeros(1, 3) 1];


%Store the front home joint transformation matrices into a multi-dimensional matrix.
M_Front_Joint = cat(3, M_Front_Hip_Joint, M_Front_Knee1_Joint, M_Front_Knee2_Joint, M_Front_Ankle_Joint, M_Front_Foot_Joint);

%Store the back home joint transformation matrices into a multi-dimmensional matrix.
M_Back_Joint = cat(3, M_Back_Hip_Joint, M_Back_Knee_Joint, M_Back_Ankle_Joint, M_Back_Foot_Joint);

%Store all of the front home transformation matrices into a single multi-dimensional matrix.
L_Front = [0 1 2 3 4 0 0 1 1 1 1 2 2 3 3 4 4 2 4 2 4];
n_Front_Joints = find(diff(L_Front) < 0, 1);
M_Front = cat(3, M_Front_Hip_Joint, M_Front_Knee1_Joint, M_Front_Knee2_Joint, M_Front_Ankle_Joint, M_Front_Foot_Joint, M_Front_Hip_Ext1, M_Front_Hip_Flx1, M_Front_Hip_Ext2, M_Front_Hip_Flx2, M_Front_Knee_Ext1, M_Front_Knee_Flx1, M_Front_Knee_Ext2, M_Front_Knee_Flx2, M_Front_Ankle_Ext1, M_Front_Ankle_Flx1, M_Front_Ankle_Ext2, M_Front_Ankle_Flx2, M_Front_Knee_Pulley_Ext, M_Front_Ankle_Pulley_Ext, M_Front_Knee_Pulley_Flx, M_Front_Ankle_Pulley_Flx);

%Store all of the back home transformation matrices into a single-multi-dimensional matrix.
L_Back = [0 1 2 3 0 0 1 1 1 1 2 2 2 2 3 3 2 3 2 3];
n_Back_Joints = find(diff(L_Back) < 0, 1);
M_Back = cat(3, M_Back_Hip_Joint, M_Back_Knee_Joint, M_Back_Ankle_Joint, M_Back_Foot_Joint, M_Back_Hip_Ext1, M_Back_Hip_Flx1, M_Back_Hip_Ext2, M_Back_Hip_Flx2, M_Back_Knee_Ext1, M_Back_Knee_Flx1, M_Back_Knee_Ext2, M_Back_Knee_Flx2, M_Back_Ankle_Ext1, M_Back_Ankle_Flx1, M_Back_Ankle_Ext2, M_Back_Ankle_Flx2, M_Back_Knee_Pulley_Ext, M_Back_Ankle_Pulley_Ext, M_Back_Knee_Pulley_Flx, M_Back_Ankle_Pulley_Flx);

%% Define the Screw Axes for Each Joint.

%Define the rotation component of the front screw axes.
[w_Front_Hip_Joint, w_Front_Knee1_Joint, w_Front_Knee2_Joint, w_Front_Ankle_Joint] = deal( [0; 0; 1] );

%Define the rotation component of the back screw axes.
[w_Back_Hip_Joint, w_Back_Knee_Joint, w_Back_Ankle_Joint] = deal( [0; 0; 1] );

%Define the velocity component of the front screw axes.
v_Front_Hip_Joint = cross(p_Front_Hip_Joint_Home, w_Front_Hip_Joint);
v_Front_Knee1_Joint = cross(p_Front_Knee1_Joint_Home, w_Front_Knee1_Joint);
v_Front_Knee2_Joint = cross(p_Front_Knee2_Joint_Home, w_Front_Knee2_Joint);
v_Front_Ankle_Joint = cross(p_Front_Ankle_Joint_Home, w_Front_Ankle_Joint);

%Define the velocity component of the back screw axes.
v_Back_Hip_Joint = cross(p_Back_Hip_Joint_Home, w_Back_Hip_Joint);
v_Back_Knee_Joint = cross(p_Back_Knee_Joint_Home, w_Back_Knee_Joint);
v_Back_Ankle_Joint = cross(p_Back_Ankle_Joint_Home, w_Back_Ankle_Joint);

%Define the screw axes for each front joint.
S_Front_Hip_Joint = [w_Front_Hip_Joint; v_Front_Hip_Joint];
S_Front_Knee1_Joint = [w_Front_Knee1_Joint; v_Front_Knee1_Joint];
S_Front_Knee2_Joint = [w_Front_Knee2_Joint; v_Front_Knee2_Joint];
S_Front_Ankle_Joint = [w_Front_Ankle_Joint; v_Front_Ankle_Joint];

%Define the screw axes for each back joint.
S_Back_Hip_Joint = [w_Back_Hip_Joint; v_Back_Hip_Joint];
S_Back_Knee_Joint = [w_Back_Knee_Joint; v_Back_Knee_Joint];
S_Back_Ankle_Joint = [w_Back_Ankle_Joint; v_Back_Ankle_Joint];

%Store the front screw axes in a matrix.
S_Front = [S_Front_Hip_Joint S_Front_Knee1_Joint S_Front_Knee2_Joint S_Front_Ankle_Joint];

%Store the back screw axes in a matrix.
S_Back = [S_Back_Hip_Joint S_Back_Knee_Joint S_Back_Ankle_Joint];


%% Define the Maximum Extension, Maximum Flexion, and Standing Joint Angles.

%Define the maximum extension, maximum flexion, and standing joint angles.
Define_Max_Ext_Flx_Stand_Joint_Angles


%% Animate Joint and Muscle Attachment Points through the Range of Motion of Each Leg.

%Specific whether to create a new figure.
bNewFig = false;

%Specify whether to plot the joint and attachment point paths.
bPlotPaths = false;

%Specify the angles through which to move each joint.
thetas_front_hip = linspace( theta_front_hip_ext, theta_front_hip_flx, 100);
thetas_front_knee1 = linspace( theta_front_knee1_ext, theta_front_knee1_flx, 100);
thetas_front_knee2 = -thetas_front_knee1;
thetas_front_ankle = linspace( theta_front_ankle_ext, theta_front_ankle_flx, 100);

%Store the desired angles into a matrix.
thetas_front = (pi/180)*[thetas_front_hip; thetas_front_knee1; thetas_front_knee2; thetas_front_ankle];

%Animate the resulting trajectory.
AnimatePartTrajectory( S_Front, M_Front, L_Front, thetas_front, bNewFig, bPlotPaths )

%Specify the angles through which to move each joint.
thetas_back_hip = linspace( theta_back_hip_ext, theta_back_hip_flx, 100);
thetas_back_knee = linspace( theta_back_knee_ext, theta_back_knee_flx, 100);
thetas_back_ankle = linspace( theta_front_ankle_ext, theta_back_ankle_flx, 100);

%Store the desired angles into a matrix.
thetas_back = (pi/180)*[thetas_back_hip; thetas_back_knee; thetas_back_ankle];

%Animate the resulting trajectory.
AnimatePartTrajectory( S_Back, M_Back, L_Back, thetas_back, bNewFig, bPlotPaths )


%% Compute the Gap Lengths through the Range of Motion of Each Leg.

%Define a variable to represent the precentage along the range of motion.
prom = linspace(0, 1, length(thetas_front));

%Compute the front leg muscle lengths.
ls_front = JointAngles2GapLengths( S_Front, M_Front, L_Front, thetas_front, false );
ls_back = JointAngles2GapLengths( S_Back, M_Back, L_Back, thetas_back, true );

%Plot each muscle length throughout the range of motion of each leg.
figure, hold on, grid on, title('Muscle Length vs Percent Along Range of Motion (Front Leg)'), xlabel('Percent Along Range of Motion'), ylabel('Muscle Length [in]')
plot(prom, ls_front(1, :), '-k'), plot(prom, ls_front(2, :), '-b'), plot(prom, ls_front(3, :), '-r')
plot(prom, ls_front(4, :), '--k'), plot(prom, ls_front(5, :), '--b'), plot(prom, ls_front(6, :), '--r')
legend('Hip Ext', 'Knee Ext', 'Ankle Ext', 'Hip Flx', 'Knee_Flx', 'Ankle_Flx')

figure, hold on, grid on, title('Muscle Length vs Percent Along Range of Motion (Back Leg)'), xlabel('Percent Along Range of Motion'), ylabel('Muscle Length [in]')
plot(prom, ls_back(1, :), '-k'), plot(prom, ls_back(2, :), '-b'), plot(prom, ls_back(3, :), '-r')
plot(prom, ls_back(4, :), '--k'), plot(prom, ls_back(5, :), '--b'), plot(prom, ls_back(6, :), '--r')
legend('Hip Ext', 'Knee Ext', 'Ankle Ext', 'Hip Flx', 'Knee Flx', 'Ankle Flx')

%Plot each muscle length throughout the range of motion of each leg.
figure, hold on, grid on, title('Muscle Length vs Joint Angle (Front Leg)'), xlabel('Joint Angle [deg]'), ylabel('Muscle Length [in]')
plot(thetas_front_hip, ls_front(1, :), '-k'), plot(thetas_front_knee1, ls_front(2, :), '-b'), plot(thetas_front_ankle, ls_front(3, :), '-r')
plot(thetas_front_hip, ls_front(4, :), '--k'), plot(thetas_front_knee1, ls_front(5, :), '--b'), plot(thetas_front_ankle, ls_front(6, :), '--r')
legend('Hip Ext', 'Knee Ext', 'Ankle Ext', 'Hip Flx', 'Knee Flx', 'Ankle Flx')

figure, hold on, grid on, title('Muscle Length vs Joint Angle (Back Leg)'), xlabel('Joint Angle [deg]'), ylabel('Muscle Length [in]')
plot(thetas_back_hip, ls_back(1, :), '-k'), plot(thetas_back_knee, ls_back(2, :), '-b'), plot(thetas_back_ankle, ls_back(3, :), '-r')
plot(thetas_back_hip, ls_back(4, :), '--k'), plot(thetas_back_knee, ls_back(5, :), '--b'), plot(thetas_back_ankle, ls_back(6, :), '--r')
legend('Hip Ext', 'Knee Ext', 'Ankle Ext', 'Hip Flx', 'Knee Flx', 'Ankle Flx')


%% Plot the Robot in its Maximum Extension, Maximum Flexion, and Standing Positions.

%Create arrays for each angle case.

%Create arrays for the maximum extension angles.
thetas_front_ext_max = (pi/180)*[theta_front_hip_ext; theta_front_knee1_ext; theta_front_knee2_ext; theta_front_ankle_ext];
thetas_back_ext_max = (pi/180)*[theta_back_hip_ext; theta_back_knee_ext; theta_back_ankle_ext];

%Create arrays for the maximum flexion angles.
thetas_front_flx_max = (pi/180)*[theta_front_hip_flx; theta_front_knee1_flx; theta_front_knee2_flx; theta_front_ankle_flx];
thetas_back_flx_max = (pi/180)*[theta_back_hip_flx; theta_back_knee_flx; theta_back_ankle_flx];

%Create arrays for the standing angles.
thetas_front_standing = (pi/180)*[theta_front_hip_standing; theta_front_knee1_standing; theta_front_knee2_standing; theta_front_ankle_standing];
thetas_back_standing = (pi/180)*[theta_back_hip_standing; theta_back_knee_standing; theta_back_ankle_standing];


%Perform forward kinematics for each angle case.

%Perform forward kinematics for the maximum extension case.
ps_front_ext_max = JointAngles2PartTrajectory( S_Front, M_Front, L_Front, thetas_front_ext_max );
ps_back_ext_max = JointAngles2PartTrajectory( S_Back, M_Back, L_Back, thetas_back_ext_max );

%Perform forward kinematics for the maximum flexion case.
ps_front_flx_max = JointAngles2PartTrajectory( S_Front, M_Front, L_Front, thetas_front_flx_max );
ps_back_flx_max = JointAngles2PartTrajectory( S_Back, M_Back, L_Back, thetas_back_flx_max );

%Perform forward kinematics for the standing angles.
ps_front_standing = JointAngles2PartTrajectory( S_Front, M_Front, L_Front, thetas_front_standing );
ps_back_standing = JointAngles2PartTrajectory( S_Back, M_Back, L_Back, thetas_back_standing );


%Reshape the forward kinematics results for each angle case.

%Reshape the maximum extension joint locations for both legs.
ps_front_ext_max = reshape(ps_front_ext_max, size(ps_front_ext_max, 1), size(ps_front_ext_max, 3), 1);
ps_back_ext_max = reshape(ps_back_ext_max, size(ps_back_ext_max, 1), size(ps_back_ext_max, 3), 1);

%Reshape the maximum flexion joint locations for both legs.
ps_front_flx_max = reshape(ps_front_flx_max, size(ps_front_flx_max, 1), size(ps_front_flx_max, 3), 1);
ps_back_flx_max = reshape(ps_back_flx_max, size(ps_back_flx_max, 1), size(ps_back_flx_max, 3), 1);

%Reshape the standing joint locations for both legs.
ps_front_standing = reshape(ps_front_standing, size(ps_front_standing, 1), size(ps_front_standing, 3), 1);
ps_back_standing = reshape(ps_back_standing, size(ps_back_standing, 1), size(ps_back_standing, 3), 1);


%Store the forward kienmatics results for each angle case into separate variables for joints and attachment points.

%Store the maximum extension joint and attachment point locations into separate variables.
ps_front_ext_max_joint = ps_front_ext_max(:, 1:n_Front_Joints); ps_front_ext_max_attachment = ps_front_ext_max(:, (n_Front_Joints + 1):end);
ps_back_ext_max_joint = ps_back_ext_max(:, 1:n_Back_Joints); ps_back_ext_max_attachment = ps_back_ext_max(:, (n_Back_Joints + 1):end);

%Store the maximum flexion joint and attachment point locations into separate variables.
ps_front_flx_max_joint = ps_front_flx_max(:, 1:n_Front_Joints); ps_front_flx_max_attachment = ps_front_flx_max(:, (n_Front_Joints + 1):end);
ps_back_flx_max_joint = ps_back_flx_max(:, 1:n_Back_Joints); ps_back_flx_max_attachment = ps_back_flx_max(:, (n_Back_Joints + 1):end);

%Store the standing joint and attachment point locations into separate variables.
ps_front_standing_joint = ps_front_standing(:, 1:n_Front_Joints); ps_front_standing_attachment = ps_front_standing(:, (n_Front_Joints + 1):end);
ps_back_standing_joint = ps_back_standing(:, 1:n_Back_Joints); ps_back_standing_attachment = ps_back_standing(:, (n_Back_Joints + 1):end);


%Plot each case.

%Plot the maximum extension joint locations.
figure(fig);
rgb = rand(1, 3);
plot3(ps_front_ext_max_joint(1, :), ps_front_ext_max_joint(2, :), ps_front_ext_max_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                           %Plot the front maximum extension joint locations.
plot3(ps_front_ext_max_attachment(1, :), ps_front_ext_max_attachment(2, :), ps_front_ext_max_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)             %Plot the front maximum extension attachment locations.
plot3(ps_back_ext_max_joint(1, :), ps_back_ext_max_joint(2, :), ps_back_ext_max_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                              %Plot the back maximum extension joint locations.
plot3(ps_back_ext_max_attachment(1, :), ps_back_ext_max_attachment(2, :), ps_back_ext_max_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)                %Plot the back maximum extension attachment locations.

%Plot the maximum flexion joint locations.
rgb = rand(1, 3);
plot3(ps_front_flx_max_joint(1, :), ps_front_flx_max_joint(2, :), ps_front_flx_max_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                           %Plot the front maximum flexion joint locations.
plot3(ps_front_flx_max_attachment(1, :), ps_front_flx_max_attachment(2, :), ps_front_flx_max_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)             %Plot the front maximum flexion attachment locations.
plot3(ps_back_flx_max_joint(1, :), ps_back_flx_max_joint(2, :), ps_back_flx_max_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                              %Plot the back maximum flexion joint locations.
plot3(ps_back_flx_max_attachment(1, :), ps_back_flx_max_attachment(2, :), ps_back_flx_max_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)                %Plot the back maximum flexion attachment locations.

%Plot the standing joint locations.
rgb = rand(1, 3);
plot3(ps_front_standing_joint(1, :), ps_front_standing_joint(2, :), ps_front_standing_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                           %Plot the front standing joint locations.
plot3(ps_front_standing_attachment(1, :), ps_front_standing_attachment(2, :), ps_front_standing_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)             %Plot the front standing attachment locations.
plot3(ps_back_standing_joint(1, :), ps_back_standing_joint(2, :), ps_back_standing_joint(3, :), '.-', 'Markersize', 20, 'Color', rgb)                              %Plot the back standing joint locations.
plot3(ps_back_standing_attachment(1, :), ps_back_standing_attachment(2, :), ps_back_standing_attachment(3, :), '.', 'Markersize', 20, 'Color', rgb)                %Plot the back standing attachment locations.

%% Compute the Maximum Gap Length for Each Muscle.

%Compute the front & back leg gap lengths in the maximum extension orientation.
ls_front_ext_max = JointAngles2GapLengths( S_Front, M_Front, L_Front, thetas_front_ext_max, false );
ls_back_ext_max = JointAngles2GapLengths( S_Back, M_Back, L_Back, thetas_back_ext_max, true );

%Compute the front & back leg gap lengths in the maximum flexion orientation.
ls_front_flx_max = JointAngles2GapLengths( S_Front, M_Front, L_Front, thetas_front_flx_max, false );
ls_back_flx_max = JointAngles2GapLengths( S_Back, M_Back, L_Back, thetas_back_flx_max, true );

%Store the maximum extension and maximum flexion gap lengths for the front and back legs into matrices.
ls_front_ext_flx_max = [ls_front_ext_max ls_front_flx_max];
ls_back_ext_flx_max = [ls_back_ext_max ls_back_flx_max];


%% Compute the Draw Length of Each Muscle.

%Compute the angle change from maximum extension to maximum flexion.
dthetas_front_max = thetas_front_flx_max - thetas_front_ext_max;
dthetas_back_max = thetas_back_flx_max - thetas_back_ext_max;

%Compute the change in gap length for both the front and back legs (used to calculate draw length of hip muscles).
dls_front_gap = abs(ls_front_ext_max - ls_front_flx_max);
dls_back_gap = abs(ls_back_ext_max - ls_back_flx_max);

%Compute the draw length of the front hip extensor and flexor.
dl_front_hip_ext = abs(ls_front_flx_max(1) - ls_front_ext_max(1));
dl_front_hip_flx = abs(ls_front_flx_max(4) - ls_front_ext_max(4));

%Compute the draw length of the back hip extensor and flexor.
dl_back_hip_ext = abs(ls_back_flx_max(1) - ls_back_ext_max(1));
dl_back_hip_flx = abs(ls_back_flx_max(4) - ls_back_ext_max(4));

%Compute the draw length of the front knee extensor and flexor.
dl_front_knee_ext = abs(sin(gamma_front_knee_ext)*rmag_front_knee_joint_ext*dthetas_front_max(2));
dl_front_knee_flx = abs(sin(gamma_front_knee_flx)*rmag_front_knee_joint_flx*dthetas_front_max(2));

%Compute the draw length of the back knee extensor and flexor.
dl_back_knee_ext = abs(sin(gamma_back_knee_ext)*rmag_back_knee_joint_ext*dthetas_back_max(2));
dl_back_knee_flx = abs(sin(gamma_back_knee_flx)*rmag_back_knee_joint_flx*dthetas_back_max(2));

%Compute the ankle draw length of the front ankle extensor and flexor.
dl_front_ankle_ext = abs(sin(gamma_front_ankle_ext)*rmag_front_ankle_joint_ext*dthetas_front_max(4));
dl_front_ankle_flx = abs(sin(gamma_front_ankle_flx)*rmag_front_ankle_joint_flx*dthetas_front_max(4));

%Compute the ankle draw length of the back ankle extensor and flexor.
dl_back_ankle_ext = abs(sin(gamma_back_ankle_ext)*rmag_back_ankle_joint_ext*dthetas_back_max(3));
dl_back_ankle_flx = abs(sin(gamma_back_ankle_flx)*rmag_back_ankle_joint_flx*dthetas_back_max(3));

%Store the front and back draw lengths into separate arrays.
dls_front = [dl_front_hip_ext; dl_front_knee_ext; dl_front_ankle_ext; dl_front_hip_flx; dl_front_knee_flx; dl_front_ankle_flx];
dls_back = [dl_back_hip_ext; dl_back_knee_ext; dl_back_ankle_ext; dl_back_hip_flx; dl_back_knee_flx; dl_back_ankle_flx];


%% Compute the Maximum Muscle Length that can be used Between Each Pair of Attachment Points.

%Compute the maximum gap length for each muscle.
ls_front_max = max(ls_front_ext_flx_max, [], 2);
ls_back_max = max(ls_back_ext_flx_max, [], 2);

%Define the connector lengths.
l_connector_muscle = 0.5 + 0.501597;
l_connector_string = 0.8125;

%Define the amount to back off from the maximum gap length.
[ls_front_offset, ls_back_offset] = deal( zeros(size(dls_front, 1), 1) );

%Set the offset to half the draw length for the hip muscles.
ls_front_offset([1 4]) = dls_front([1 4])/2;
ls_back_offset([1 4]) = dls_back([1 4])/2;

%Preallocate an array to store the minimum string lengths.
[ls_front_string, ls_back_string] = deal( zeros(size(dls_front, 1), 1) );

%Compute the minimum string length for the hip muscles.
ls_front_string([1 4]) = ls_front_offset([1 4]) - l_connector_string;
ls_back_string([1 4]) = ls_back_offset([1 4]) - l_connector_string;

%Compute the minimum string length for the knee and ankle muscles of the front leg.
ls_front_string(2) = rmag_front_knee_pulley_ext;
ls_front_string(3) = rmag_front_ankle_pulley_ext;
ls_front_string(5) = rmag_front_knee_pulley_flx;
ls_front_string(6) = rmag_front_ankle_pulley_flx;

%Compute the minimum string length for the knee and ankle muscles of the back leg.
ls_back_string(2) = rmag_back_knee_pulley_ext;
ls_back_string(3) = rmag_back_ankle_pulley_ext;
ls_back_string(5) = rmag_back_knee_pulley_flx;
ls_back_string(6) = rmag_back_ankle_pulley_flx;

%Compute the maximum available muscle length.
ls_front_max_available = ls_front_max - ls_front_offset - l_connector_muscle;
ls_back_max_available = ls_back_max - ls_back_offset - l_connector_muscle;


%% Compute the Required Resting Muscle Lengths for Desired Draw Lengths.

%Preallocate variables to store front and back resting muscle lengths.
[ls_front_resting, ls_back_resting] = deal( zeros(length(dls_front), 1) );

%Compute the associated resting lengths.
for k = 1:length(dls_front)
    ls_front_resting(k) = fresting_length(dls_front(k));
    ls_back_resting(k) = fresting_length(dls_back(k));
end


%% Define the Current Muscle Lengths.

%Define the current muscle lengths.
ls_current_front = [6; 5; 4; 6.625; 3.375; 4.25];
ls_current_back = [6.3125; 2.75; 3.9375; 6.8125; 4.625; 4];


%% Create a Bar Chart of the Muscle Lengths.

%Define the categories for the extension bar chart.
ext_cats = categorical({'Front Hip Ext', 'Front Knee Ext', 'Front Ankle Ext', 'Front Hip Flx', 'Front Knee Flx', 'Front Ankle Flx'});

%Define the categories for the flexor bar chart.
flx_cats = categorical({'Back Hip Ext', 'Back Knee Ext', 'Back Ankle Ext', 'Back Hip Flx', 'Back Knee Flx', 'Back Ankle Flx'});

%Create the extensor muscle length matrix.
ls_front_mat = [ls_current_front ls_front_max_available ls_front_max ls_front_resting];

%Create the flexor muscle length matrix.
ls_back_mat = [ls_current_back ls_back_max_available ls_back_max ls_back_resting];

%Plot the extensor muscle length bar chart.
figure, hold on, grid on, title('Current / Required Muscle Lengths (Front)'), xlabel('Muscle Category'), ylabel('Muscle Length [in]')
bar(ext_cats, ls_front_mat)
legend('Current', 'Max Available', 'Max Gap', 'Required', 'Location', 'North', 'Orientation', 'Horizontal')

%Plot the flexor muscle length bar chart.
figure, hold on, grid on, title('Current / Required Muscle Lengths (Back)'), xlabel('Muscle Category'), ylabel('Muscle Length [in]')
bar(flx_cats, ls_back_mat)
legend('Current', 'Max Available', 'Max', 'Required', 'Location', 'North', 'Orientation', 'Horizontal')


%% Print out the Muscle Length Results.

%Print out the current muscle lengths.
fprintf('Current Muscle Lengths (Front):\n')
fprintf('%0.16f [in]\n', ls_current_front)

fprintf('\nCurrent Muscle Lengths (Back):\n')
fprintf('%0.16f [in]\n', ls_current_back)

%Print out the maximum possible current muscle lengths.
fprintf('\nMaximum Possible Current Muscle Lengths (Front):\n')
fprintf('%0.16f [in]\n', ls_front_max)

fprintf('\nMaximum Possible Current Muscle Lengths (Back):\n')
fprintf('%0.16f [in]\n', ls_back_max)

%Print out the required muscle lengths.
fprintf('\nRequired Muscle Lengths (Front):\n')
fprintf('%0.16f [in]\n', ls_front_resting)

fprintf('\nRequired Muscle Lengths (Back):\n')
fprintf('%0.16f [in]\n', ls_back_resting)
