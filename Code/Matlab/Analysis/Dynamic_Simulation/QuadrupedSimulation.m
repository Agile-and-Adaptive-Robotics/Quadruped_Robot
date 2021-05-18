%% Quadruped Simulation

% This script constructs position controllers for the joints of a quadruped robot.

% Clear Everything.
clear, close('all'), clc


%% Define the Robot Geometry & Mechanical Properties.

%{
Modify parameters to match Biarticulating Design
Add Total Body Weight Component for calculating normal force during
standing
%}

% Define the mechanical properties of link 1 - Femur.
m1 = .320188;                                                                                                   % [kg] Link Mass.
ct1 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt1 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
% Lx1 = 1; Ly1 = 0.1; Lz1 = 0.1; Ls1 = [Lx1; Ly1; Lz1];                                                         % [m] Link Length in each direction of the local link frame.
% Original Lx1 = 0.331795; Ly1 = 0.036894; Lz1 = 0.033084; Ls1 = [Lx1; Ly1; Lz1];                               % [m] Link Length in each direction of the local link frame.
Lx1 = 0.344495; Ly1 = 0.036894; Lz1 = 0.033084; Ls1 = [Lx1; Ly1; Lz1];
% Lx1 = 0.1524; Ly1 = 0.0254; Lz1 = 0.0254; Ls1 = [Lx1; Ly1; Lz1];                                              % [m] Link Length in each direction of the local link frame.
% Phome_cm1 = [Lx1/2; 0; 0];                                                                                    % [m] Link Center of Mass Location in the Global Frame.
Phome_cm1 = [0.065365; -0.000337 ;0.049341];                                                                    % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm1 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm1 = [0.000115	-0.000022	0.000015
		-0.000022	0.003254	0.000000
		0.000015	0.000000	0.003180];      % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G1 = [Ihome_cm1, zeros(3, 3); zeros(3, 3), m1*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body1 = GetCuboidPoints(Ls1(1), Ls1(2), Ls1(3), Phome_cm1(1), Phome_cm1(2), Phome_cm1(3), 0, 0, 0);       % [m] Link Points
Rhome_body1 = Rhome_cm1;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Define the mechanical properties of link 2 - Tibia.
m2 = .170503;                                                                                                   % [kg] Link Mass.
ct2 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt2 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
% Lx2 = 1; Ly2 = 0.1; Lz2 = 0.1; Ls2 = [Lx2; Ly2; Lz2];                                                         % [m] Link Length in each direction of the local link frame.
% Original Lx2 = 0.275273; Ly2 = 0.02856; Lz2 = 0.032385; Ls2 = [Lx2; Ly2; Lz2];                                % [m] Link Length in each direction of the local link frame.
Lx2 = 0.237173; Ly2 = 0.02856; Lz2 = 0.032385; Ls2 = [Lx2; Ly2; Lz2];
% Lx2 = 0.20955; Ly2 = 0.0254; Lz2 = 0.0254; Ls2 = [Lx2; Ly2; Lz2];                                             % [m] Link Length in each direction of the local link frame.
% Phome_cm2 = [Lx1 + Lx2/2; 0; 0];                                                                              % [m] Link Center of Mass Location in the Global Frame.
Phome_cm2 = [0.366555; -.000297; 0.053825];                                                                     % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm2 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm2 = [0.000033		0.000005		0.000010
		0.000005		0.001383		0.000000
		0.000010		0.000000		0.001372];      % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G2 = [Ihome_cm2, zeros(3, 3); zeros(3, 3), m2*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body2 = GetCuboidPoints(Ls2(1), Ls2(2), Ls2(3), Phome_cm2(1), Phome_cm2(2), Phome_cm2(3), 0, 0, 0);       % [m] Link Points
Rhome_body2 = Rhome_cm2;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Define the mechanical properties of link 3 - Foot.
m3 = 0.087102;                                                                                                  % [kg] Link Mass.
ct3 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt3 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
% Lx3 = 1; Ly3 = 0.1; Lz3 = 0.1; Ls3 = [Lx3; Ly3; Lz3];                                                         % [m] Link Length in each direction of the local link frame.
Lx3 = 0.14845; Ly3 = 0.078967; Lz3 = 0.032385; Ls3 = [Lx3; Ly3; Lz3];                                           % [m] Link Length in each direction of the local link frame.
% Lx3 = 0.1143; Ly3 = 0.0254; Lz3 = 0.0254; Ls3 = [Lx3; Ly3; Lz3];                                              % [m] Link Length in each direction of the local link frame.
% Phome_cm3 = [Lx1 + Lx2 + Lx3/2; 0; 0];                                                                        % [m] Link Center of Mass Location in the Global Frame.
Phome_cm3 = [.539952; .014351 ; 0.049821];                                                                     % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm3 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm3 = [0.000038		-0.000042		0.000001
		-0.000042		0.000277		0.000000
		0.000001		0.000000		0.000306];      % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G3 = [Ihome_cm3, zeros(3, 3); zeros(3, 3), m3*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body3 = GetCuboidPoints(Ls3(1), Ls3(2), Ls3(3), Phome_cm3(1), Phome_cm3(2), Phome_cm3(3), 0, 0, 0);       % [m] Link Points
Rhome_body3 = Rhome_cm3;                                                                                        % [-] Orientation of the Link in the Global Frame.                                                                                      % [-] Orientation of the Link in the Global Frame.

%{
Add information to incorporate Ad/Abduction Joint at hip
Needs new joint location, orientation, axis of rotation
%}

% Compile information about each link into arrays.
ms = [m1; m2; m3];                                                                                              % [kg] Mass of Each Link.
cts = [ct1; ct2; ct3];                                                                                          % [Nms/rad] Angular Viscous Friction of Each Link.
kts = [kt1; kt2; kt3];                                                                                          % [Nm/rad] Link Angular Stiffness.
Phome_cms = [Phome_cm1 Phome_cm2 Phome_cm3];                                                                    % [m] Center of Mass Location for Each Link in the Global Frame.
Rhome_cms = cat(3, Rhome_cm1, Rhome_cm2, Rhome_cm3);                                                            % [-] Center of Mass Orientation for Each Link in the Global Frame.
Ihome_cms = cat(3, Ihome_cm1, Ihome_cm2, Ihome_cm3);                                                            % [m^2/kg] Moment of Inertia for Each Link in their Local Frames.
Gs = cat(3, G1, G2, G3);                                                                                        % [-] Spatial Inertia Matrix for Each Link in the Global Frame.
Phome_bodies = cat(3, Phome_body1, Phome_body2, Phome_body3);                                                   % [m] Body Points for Each Link in the Global Frame.
Rhome_bodies = cat(3, Rhome_body1, Rhome_body2, Rhome_body3);                                                   % [m] Orientation of Each Link in the Global Frame.
% Ltotal = Lx1 + Lx2 + Lx3;                                                                                     % [m] Total Length.
Ltotal = Phome_cm3(1) + Lx3/2;                                                                                  % [m] Total Length.

% Define the home joint locations.
Phome_joint1 = [0; 0; 0];                                                                                       % [m] Joint Location in the Global Frame.
% Phome_joint2 = [Lx1; 0; 0];                                                                                   % [m] Joint Location in the Global Frame.
Phome_joint2 = [Phome_cm1(1) + Lx1/2; 0; 0];                                                                    % [m] Joint Location in the Global Frame.
% Phome_joint3 = [Lx1 + Lx2; 0; 0];                                                                             % [m] Joint Location in the Global Frame.
Phome_joint3 = [Phome_cm2(1) + Lx2/2; 0; 0];                                                                    % [m] Joint Location in the Global Frame.
Phome_joints = [Phome_joint1 Phome_joint2 Phome_joint3];                                                        % [m] Joint Locations in the Global Frame.

% Define the home joint orientations.
Rhome_joint1 = Rhome_body1;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joint2 = Rhome_body2;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joint3 = Rhome_body3;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joints = cat(3, Rhome_joint1, Rhome_joint2, Rhome_joint3);                                                % [-] Joint Orientations in the Global Frame.

% Define the joint axes of rotation.

%{
Add Adduction and Abduction by adding hip joint with w = {0,0,1}
%}

w1_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
w2_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
w3_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
ws_local = [w1_local w2_local w3_local];                                                                        % [rad/s] Axes of Rotation of Each Link in its Local Frame.

% Define the end effector location & orientation.
% Phome_end = [Lx1 + Lx2 + Lx3; 0; 0];                                                                    % [m] End Effector Location in the Global Frame.
Phome_end = [Ltotal; 0; 0];                                                                    % [m] End Effector Location in the Global Frame.
Rhome_end = eye(3);                                                                                     % [-] End Effector Orientation in the Global Frame.

% Retrieve size information from the specified geometry.
num_joints = size(Phome_joints, 2);                                                                             % [#] Number of Joints in the Open Kinematic Chain.
num_body_points = size(Phome_bodies, 2);                                                                        % [#] Number of Points in Each Body of the Open Kinematic Chain.
num_bodies = size(Phome_bodies, 3);                                                                             % [#] Number of Bodies in the Open Kinematic Chain.


%% Define the Muscle Attachment Locations.

% Define muscle properties.
kse = 30;                % [N/m] Hill Muscle Model Series Stiffness.
kpe = 30;                % [N/m] Hill Muscle Model Parallel Stiffness.
b = 1;                  % [Ns/m] Hill Muscle Model Damping Coefficient.

% Define the joint names.
joint_names = {'Hip', 'Knee', 'Ankle'};

% Define the possible muscle types.
muscle_type_names = {'Ext', 'Flx'};

% Comute the number of muscle types.
num_muscle_types = length(muscle_type_names);

% Define a cell to store the muscle names.
muscle_names = cell(num_muscle_types*num_joints, 1);

% Initialize a loop counter.
k3 = 0;

% Define the muscle names.
for k1 = 1:num_joints                       % Iterate through each joint...
    for k2 = 1:num_muscle_types             % Iterate through each muscle type...
       
        % Advance the counter.
        k3 = k3 + 1;
        
        % Create the current muscle name.
        muscle_names{k3} = [joint_names{k1}, ' ', muscle_type_names{k2}];
        
    end
end

% Define the joint orientations.  i.e., the first joint is moved in the positive direction by the extensor, the second by the flexor, and the third by the extensor.
muscle_joint_orientations = {'Ext', 'Flx', 'Ext'};

% Read in the muscle location data.

%{
Adjust text files to reflect BiArticular Design
%}

Ps_hipext = dlmread('Ps_hipext.txt');
Ps_hipflx = dlmread('Ps_hipflx.txt');
Ps_kneeext = dlmread('Ps_kneeext.txt');
Ps_kneeflx = dlmread('Ps_kneeflx.txt');
Ps_ankleext = dlmread('Ps_ankleext.txt');
Ps_ankleflx = dlmread('Ps_ankleflx.txt');

% Store the muscle attachment locations in a high order tensor.
Phome_muscles = cat(3, Ps_hipext, Ps_hipflx, Ps_kneeext, Ps_kneeflx, Ps_ankleext, Ps_ankleflx);

% Define the home orientation of the muscles.
Rhome_muscles = eye(3);

% Retrieve the number of muscles.
num_pts_per_muscle = size(Phome_muscles, 2);
num_muscles = size(Phome_muscles, 3);


%% Define the Robot Home Matrices & Screw Axes.

% Define the home matrices for each body point.
Mbodies = zeros(4, 4, num_body_points, num_bodies);
Jbodies = zeros(num_body_points, num_bodies);
for k1 = 1:num_bodies
    for k2 = 1:num_body_points
        Mbodies(:, :, k2, k1) = [Rhome_bodies(:, :, k1), Phome_bodies(:, k2, k1); zeros(1, 3), 1];
        Jbodies(k2, k1) = k1;
    end
end

% Define the home matrices for each joint.
Mjoints = zeros(4, 4, 1, num_joints);
Jjoints = zeros(1, num_joints);
for k = 1:num_joints
    Mjoints(:, :, 1, k) = [Rhome_joints(:, :, k), Phome_joints(:, k); zeros(1, 3), 1];
    Jjoints(1, k) = k;
end

% Define the home matrices for each center of mass.
Mcms = zeros(4, 4, 1, num_bodies);
Jcms = zeros(1, num_bodies);
for k = 1:num_bodies
    Mcms(:, :, 1, k) = [Rhome_cms(:, :, k), Phome_cms(:, k); zeros(1, 3), 1] ;
    Jcms(1, k) = k;
end

% Define the home matrices for each muscle.
Mmuscles = zeros(4, 4, num_pts_per_muscle, num_muscles);
Jmuscles = zeros(num_pts_per_muscle, num_muscles);
k3 = 0;
for k1 = 1:num_muscles                      % Iterate through each of the muscles...
    for k2 = 1:num_pts_per_muscle           % Iterate through each of the muscle attachment points...
        
        % Compute the home matrix asscoated with this point on this muscle.
        Mmuscles(:, :, k2, k1) = [Rhome_muscles, Phome_muscles(:, k2, k1); zeros(1, 3), 1];
        
        % Determine which joint to assign this point to.
        if k2 == num_pts_per_muscle
            Jmuscles(k2, k1) = k3 + 1;
        else
            Jmuscles(k2, k1) = k3;
        end
    end
    
    % Advance the counter on even iterations.
    if mod(k1, 2) == 0          % If this is an even iteration...
        
        % Advance the counter.
        k3 = k3 + 1;
        
    end
    
end

% Define the home matrix for the end effector.

Mend = [Rhome_end, Phome_end; zeros(1, 3), 1];
Jend = num_joints;

% Define the screw axes.

%{
Add Screw Axis for the Hip Adduction and Abduction S2 = {1,0,0,0,0,0}';
%}

% S1 = [0; 0; 1; 0; 0; 0];
% S2 = [0; 0; 1; 0; -Lx1; 0];
% S3 = [0; 0; 1; 0; -(Lx1 + Lx2); 0];
S1 = [0; 0; 1; 0; -Phome_joint1(1); 0];
S2 = [0; 0; 1; 0; -Phome_joint2(1); 0];
S3 = [0; 0; 1; 0; -Phome_joint3(1); 0];
Ss = [S1 S2 S3];

% With lateral hip axis
%S1 = [0; 0; 1; 0; -Phome_joint1(1); 0];
%S2 = [1;0,0;0;-Phome_joint2(1); 0];
%S3 = [0; 0; 1; 0; -Phome_joint2(1); 0];
%S4 = [0; 0; 1; 0; -Phome_joint3(1); 0];
%Ss = [S1 S2 S3 S4];


%% Define the Simulation Properties.

% Create a time vector.
  dt = 0.001;                    % [s] Simulation Step Size
% dt = 0.0001;                   % [s] Simulation Step Size
% dt = 0.00005;                  % [s] Simulation Step Size
% dt = 0.00001;                  % [s] Simulation Step Size

tfinal = 1;                 % [s] Simulation Duration.
ts = 0:dt:tfinal;           % [s] Simulation Time Vector.

% Retrieve the number of time steps.
num_timesteps = length(ts);

% Define the gravity vector.
g = [0; -9.81; 0];


%% Define the Trajectory Properties.

% Define the stance duty cycle. - Unused?
stance_duty = 0.4;
% stance_duty = 0.25;

% Retrieve the time indexes associated with stance and swing.
ns_stance = round(stance_duty*num_timesteps);
ns_swing = num_timesteps - ns_stance;

% Retrieve the time associated with stance and swing.
ts_stance = ts(ns_swing + 1:num_timesteps);
ts_swing = ts(1:ns_swing);

% Define reaction forces during the stance cycle
smoothing_step =  round(ns_stance * 0.4);
Fsmoothing = ones(ns_stance, 1);

for i = 1:smoothing_step
    Fsmoothing(i) = Fsmoothing(i) * (i/smoothing_step);
end

for i = ns_stance - smoothing_step : ns_stance
    Fsmoothing(i) = Fsmoothing(i) * ((ns_stance-i)/smoothing_step);
end

Ftip_norm = 38 * [zeros(ns_swing, 1); ones(ns_stance , 1) .* Fsmoothing];
Ftip_stride = 5 * [zeros(ns_swing, 1); ones(ns_stance , 1)];

% Ftip_norm = zeros(num_timesteps, 1);
% Ftip_stride = zeros(num_timesteps, 1);

% Define the ground height.

%{
Adjust to fit current model
%}

ground_height = 0.52;   % [m] Ground Height Relative to Body.
% ground_height = 0.381;

% Define the horizontal step shift.
horizontal_shift = 0.075;           % [m] Horizontal Shift to Apply to Step Trajectory.

% Define the step height and stride length.

%{
Verify this matches the step trajectory and check where in code thse vars
are used
%}

step_height = 0.04;         % [m] Step Heigth.
step_length = 0.15;          % [m] Step Length.


%% Generate Desired End Effector Trajectory.

% State that we are generating a desired trajectory.
fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY... Please Wait...\n')

% Define the swing end effector path.

%{
First - adjust swing to reflect top half of circle
Second - adjust swing to reflect oval dimensions <- cut
Third - Add stability factors for account for stance to swing and swing to
stance deformations. - Define Stance to Swing and swing to stance segments
and create smoothing profile in position and force elements
%}

xs_swing = step_length*cos((pi/(1-stance_duty))*ts_swing) + horizontal_shift;
ys_swing = step_height*sin((pi/(1-stance_duty))*ts_swing) - ground_height;
zs_swing = zeros(1, ns_swing);

% Define the stance end effector path.

%{
Verify that stance segment of path is added to model
%}

xs_stance = linspace(xs_swing(end), xs_swing(1), ns_stance);
ys_stance = -ground_height*ones(1, ns_stance);
zs_stance = zeros(1, ns_stance);

% % Define the desired end effector path. (Use for testing other paths.)
% xs_desired = (horizontal_shift - step_length)*ones(1, num_timesteps);
% ys_desired = -ground_height*ones(1, num_timesteps);
% zs_desired = zeros(1, num_timesteps);

% Define the desired end effector path. (Use for circular swing and stance.)

%{
Adjust to reflect stance and swing end effector paths
%}

%xs_desired = step_length*cos(2*pi*ts) + horizontal_shift;
%ys_desired = step_height*sin(2*pi*ts) - ground_height;
%zs_desired = zeros(1, num_timesteps);

% % Define the desired end effector path. (Use for circular swing and horizontal stance.)
xs_desired = [xs_swing xs_stance];
ys_desired = [ys_swing ys_stance];
zs_desired = [zs_swing zs_stance];

% Define the End Effector Forces 
% Store the desired end effector path into an array.
Ps_desired = [xs_desired; ys_desired; zs_desired];
dPs_desired = diff(Ps_desired, 1, 2)./diff(ts);
ddPs_desired = diff(dPs_desired, 1, 2)./diff(ts(1:end-1));

% Compute the desired end effector orientation.
Rs_desired = [0 1 0; -1 0 0; 0 0 1];

% Initialize a high order matrix to store the desired end effect trajectory.
Ts_desired = zeros(4, 4, 1, 1, num_timesteps);

% Compute the desired end effector trajectory at each time step.
for k = 1:num_timesteps                 % Iterate through each time step...
    
    % Generate the desired end effector trajectory.
    Ts_desired(:, :, 1, 1, k) = RpToTrans(Rs_desired, Ps_desired(:, k));
    
end

% State that we are done generating a desired trajectory.
fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY... Done.\n\n')


%% Compute the Joint Angles That Achieve the Desired Trajectory.

% State that we are computing the inverse kinematics solution to achieve the desired trajectory.
fprintf('COMPUTING INVERSE KINEMATICS SOLUTION (i.e., Desired Joint Angles)... Please Wait...\n')

% Define the inverse kinematics error parameters.
eomg = 1e-6; ev = 1e-6;

% Define the starting joint angle values for the inverse kinematics algorithm.
% theta_guess = zeros(num_joints, 1);
theta_guess = (pi/180)*[-143; 63; -10.21];

% Compute the joint angles associated with the desired trajectory.
[thetas_desired, successes] = InverseKinematics(Ss, Mend, Ts_desired, theta_guess, eomg, ev);
% theta1 = linspace(0, 2*pi, num_timesteps); theta2 = linspace(0, 2*pi, num_timesteps); theta3 = linspace(0, 2*pi, num_timesteps); thetas_desired = [theta1; theta2; theta3];
% theta1 = (pi/4)*ones(1, num_timesteps); theta2 = 0*ones(1, num_timesteps); theta3 = 0*ones(1, num_timesteps); thetas_desired = [theta1; theta2; theta3];
% theta1 = linspace(0, 2*pi, num_timesteps); theta2 = 0*ones(1, num_timesteps); theta3 = 0*ones(1, num_timesteps); thetas_desired = [theta1; theta2; theta3];
% theta1 = 0*ones(1, num_timesteps); theta2 = linspace(0, 2*pi, num_timesteps); theta3 = 0*ones(1, num_timesteps); thetas_desired = [theta1; theta2; theta3];
% theta1 = 0*ones(1, num_timesteps); theta2 = 0*ones(1, num_timesteps); theta3 = linspace(0, 2*pi, num_timesteps); thetas_desired = [theta1; theta2; theta3];

% Compute the joint velocities associated with the desired trajectory.
dthetas_desired = diff(thetas_desired, 1, 2)./repmat(diff(ts), [num_joints 1]);
dthetas_desired = [dthetas_desired dthetas_desired(:, end)];

% Compute the joint acceleration associated with the desired trajectory.
ddthetas_desired = diff(dthetas_desired, 1, 2)./repmat(diff(ts(1:end)), [num_joints 1]);
ddthetas_desired = [ddthetas_desired ddthetas_desired(:, end)];

% State that we are done computing the inverse kinematics solution to achieve the desired trajectory.
fprintf('COMPUTING INVERSE KINEMATICS SOLUTION (i.e., Desired Joint Angles)... Done.\n\n')


%% Compute the Desired Path of Key Points on the Open Kinematic Chain (In Addition to the End Effector).

% State that we are propogating end effector trajectory to the rest of the rigid body.
fprintf('COMPUTING FORWARD KINEMATICS SOLUTION AT NON-END EFFECTOR POINTS (i.e., Desired Non-End Effector Trajectories)... Please Wait...\n')

% Retrieve the transformation matrices associated with the given angles.
Tbodies_desired = ForwardKinematics( Mbodies, Jbodies, Ss, thetas_desired );
Tcms_desired = ForwardKinematics( Mcms, Jcms, Ss, thetas_desired );
Tjoints_desired = ForwardKinematics( Mjoints, Jjoints, Ss, thetas_desired );
Tmuscles_desired = ForwardKinematics( Mmuscles, Jmuscles, Ss, thetas_desired );
Tend_desired = ForwardKinematics( Mend, Jend, Ss, thetas_desired );

% Retrieve the rotational and translational components associated with the given transformation matrices.
[Rbodies_desired, Pbodies_desired] = TransToRpAllBodies(Tbodies_desired);
[Rcms_desired, Pcms_desired] = TransToRpAllBodies(Tcms_desired);
[Rjoints_desired, Pjoints_desired] = TransToRpAllBodies(Tjoints_desired);
[Rmuscles_desired, Pmuscles_desired] = TransToRpAllBodies(Tmuscles_desired);
[Rend_desired, Pend_desired] = TransToRpAllBodies(Tend_desired);

% State that we are done propogating end effector trajectory to the rest of the rigid body.
fprintf('COMPUTING FORWARD KINEMATICS SOLUTION AT NON-END EFFECTOR POINTS (i.e., Desired Non-End Effector Trajectories)... Done.\n\n')


%% Compute the Muscle Lengths Throughout the Desired Trajectory.

% Compute the muscle lengths, velocities, and accelerations associated with the desired trajectory.
Lmuscles_desired = GetMuscleLengths( Pmuscles_desired );

% Compute the associated desired muscle velocities and accelerations.
[dLmuscles_desired, ddLmuscles_desired] = GetMuscleVelAccel(Lmuscles_desired, ts);


%% Compute the Moments of Inertia Associated with Each Body Throughout the Desired Trajectory.

% Compute the moments of inertia associated with bodies at each angle.
[Ijoints_cumulative_local, Pcm_cumulative_desired_global] = MapIs(ms, Ihome_cms, Tcms_desired, Tjoints_desired);

% Initialize an array to store the moment of inertia of each joint about its axis of rotation in its local frame.
Ijointaxes = zeros([num_bodies, num_timesteps]);

% Compute the moment of inertia of each joint about its axis of rotation in its local frame.
for k1 = 1:num_timesteps                    % Iterate through each time step...
    for k2 = 1:num_bodies                   % Iterate through each of the bodies...
        
        % Compute the moment of inertia of this joint at this time step about its axis.
        Ijointaxes(k2, k1) = (ws_local(:, k2)')*Ijoints_cumulative_local(:, :, 1, k2, k1)*ws_local(:, k2);
        
    end
end


%% Compute the Joint Torques Required to Achieve the Desired Trajectory.

% State that we are computing the inverse dynamics solution.
fprintf('COMPUTING INVERSE DYNAMICS SOLUTION (i.e., Required Joint Torques)... Please Wait...\n')

% Define any external forces & moments applied to the end effector.

%{
Add any ground forces during stance timesteps
%}

% Ftipmat = zeros(num_timesteps, 6);
Ftipmat = [zeros(num_timesteps,4), -Ftip_norm, zeros(num_timesteps,1)];
%Ftipmat = [zeros(num_timesteps,3), Ftip_stride, -Ftip_norm, zeros(num_timesteps,1)];

% Configure the relevant home matrices to have the shape required by the inverse dynamics function.  Note that the inverse dynamics function requires relative home matrices.
Mlist = cat(4, Mcms(:, :, 1, 1), reshape(TSpace2TRelative(reshape(cat(4, Mcms, Mend), [4, 4, num_joints + 1, 1])), [4, 4, 1, num_joints]));

% Compute the joint torques necessary to achieve the desired trajectory.
taus_desired = InverseDynamicsTrajectory(thetas_desired', dthetas_desired', ddthetas_desired', g, Ftipmat, Mlist, Gs, Ss)';

% State that we are done computing the inverse dynamics solution.
fprintf('COMPUTING INVERSE DYNAMICS SOLUTION (i.e., Requied Joint Torques)... Done.\n\n')


%% Compute the Total Muscle Forces Required to Achieve the Desired Trajectory.

% Define the minimum allowable total muscle force.
Fmuscles_total_lowbnd = zeros(num_muscles, 1);
% Fmuscles_total_lowbnd = 25*ones(num_muscles, 1);

% Compute the total muscle force required to achieved the desired trajectory.
Fmuscles_total_desired = JointTorques2TotalMuscleForces( taus_desired, Pmuscles_desired, Pjoints_desired, muscle_joint_orientations, Fmuscles_total_lowbnd );

% Compute the rate of change of total muscle force with respect to time.
dFmuscles_total_desired = Force2Yank( Fmuscles_total_desired, ts );


%% Compute the Active Muscle Force Required to Achieved the Desired Trajectory.

% Compute the active muscle force requied to achieve the desired trajectory.
Fmuscles_active_desired = InverseHillMuscle(Fmuscles_total_desired, dFmuscles_total_desired, Lmuscles_desired, dLmuscles_desired, kse, kpe, b);

% Compute the associated passive muscle force.
Fmuscles_passive_desired = Fmuscles_total_desired - Fmuscles_active_desired;

% Define the number of integration steps to perform when simulating the forward hill muscle model.
intRes = 1;

% Check the forward Hill Muscle model calculation.
[Fmuscles_total_achieved, dFmuscles_total_achieved] = ForwardHillMuscle(Fmuscles_total_desired(:, 1), Lmuscles_desired, dLmuscles_desired, Fmuscles_active_desired, kse, kpe, b, dt, intRes);


%% Compute the Actual Dynamics Response of the Open Kinematic Chain.

% State that we are computing the forward dynamics solution.
fprintf('COMPUTING FORWARD DYNAMICS SOLUTION (i.e., Achieved Joint Angles)... Please Wait...\n')

% Define the initial joint angles and joint velocities.
theta0 = thetas_desired(:, 1);
dtheta0 = dthetas_desired(:, 1);

% Define the forward dynamics number of integration steps.
intRes = 10;

% Compute the actual joint angles and velocities that the open kinematic chain achieves.
[thetas_achieved, dthetas_achieved] = ForwardDynamicsTrajectory(theta0, dtheta0, taus_desired', g, Ftipmat, Mlist, Gs, Ss, dt, intRes);

% Transpose the achieved joint angles and velocities to have shapes consistent with our convention.
thetas_achieved = thetas_achieved'; 
dthetas_achieved = dthetas_achieved';

% Compute the achieved joint angular accelerations.
ddthetas_achieved = diff(dthetas_achieved, 1, 2)./repmat(diff(ts), [num_joints 1]);
ddthetas_achieved = [ddthetas_achieved ddthetas_achieved(:, end)];

% State that we are computing the forward dynamics solution.
fprintf('COMPUTING FORWARD DYNAMICS SOLUTION (i.e., Achieved Joint Angles)... Done.\n\n')


%% Compute the Achieved Trajectory of the Open Kinematic Chain.

% State that we are propogating end effector trajectory to the rest of the rigid body.
fprintf('COMPUTING FORWARD KINEMATICS SOLUTION AT NON-END EFFECTOR POINTS (i.e., Achieved Non-End Effector Trajectories)... Please Wait...\n')

% Retrieve the transformation matrices associated with the given angles.
Tbodies_achieved = ForwardKinematics( Mbodies, Jbodies, Ss, thetas_achieved );
Tcms_achieved = ForwardKinematics( Mcms, Jcms, Ss, thetas_achieved );
Tjoints_achieved = ForwardKinematics( Mjoints, Jjoints, Ss, thetas_achieved );
Tmuscles_achieved = ForwardKinematics( Mmuscles, Jmuscles, Ss, thetas_achieved );
Tend_achieved = ForwardKinematics( Mend, Jend, Ss, thetas_achieved );

% Retrieve the rotational and translational components associated with the given transformation matrices.
[Rbodies_achieved, Pbodies_achieved] = TransToRpAllBodies(Tbodies_achieved);
[Rcms_achieved, Pcms_achieved] = TransToRpAllBodies(Tcms_achieved);
[Rjoints_achieved, Pjoints_achieved] = TransToRpAllBodies(Tjoints_achieved);
[Rmuscles_achieved, Pmuscles_achieved] = TransToRpAllBodies(Tmuscles_achieved);
[Rend_achieved, Pend_achieved] = TransToRpAllBodies(Tend_achieved);

% Compute the achieved cumulative center of mass locations.
[~, Pcm_cumulative_achieved_global] = MapIs(ms, Ihome_cms, Tcms_achieved, Tjoints_achieved);

% Store the achieved end effector locations into a variable with a consistent name.
Ps_achieved = reshape(Pend_achieved, size(Ps_desired));
dPs_achieved = diff(Ps_achieved, 1, 2)./diff(ts);
ddPs_achieved = diff(dPs_achieved, 1, 2)./diff(ts(1:end-1));

% State that we are done propogating end effector trajectory to the rest of the rigid body.
fprintf('COMPUTING FORWARD KINEMATICS SOLUTION AT NON-END EFFECTOR POINTS (i.e., Achieved Non-End Effector Trajectories)... Done.\n\n')


%% Compute the Muscle Lengths Throughout the Achieved Trajectory.

% Compute the muscle lengths, velocities, and accelerations associated with the achieved trajectory.
Lmuscles_achieved = GetMuscleLengths( Pmuscles_achieved );

% Compute the associated achieved muscle velocities and accelerations.
[dLmuscles_achieved, ddLmuscles_achieved] = GetMuscleVelAccel( Lmuscles_achieved, ts );


%% Compute Muscle Summary Statistics.

% Define the muscle variable names.
muscle_var_names_desired_metric = {'Min Length [m]', 'Max Length [m]', 'Length Range [m]', 'Muscle Width [m]', 'Resting Length [m]', 'Min Velocity [m/s]', 'Max Velocity [m/s]', 'Min Acceleration [m/s^2]', 'Max Acceleration [m/s^2]', 'Min Force [N]', 'Max Force [N]'};
muscle_var_names_desired_imperial = {'Min Length [in]', 'Max Length [in]', 'Length Range [in]', 'Muscle Width [in]', 'Resting Length [in]', 'Min Velocity [in/s]', 'Max Velocity [in/s]', 'Min Acceleration [in/s^2]', 'Max Acceleration [in/s^2]', 'Min Force [lb]', 'Max Force [lb]'};
muscle_var_names_achieved_metric = {'Min Length [m]', 'Max Length [m]', 'Length Range [m]', 'Muscle Width [m]', 'Resting Length [m]', 'Min Velocity [m/s]', 'Max Velocity [m/s]', 'Min Acceleration [m/s^2]', 'Max Acceleration [m/s^2]'};
muscle_var_names_achieved_imperial = {'Min Length [in]', 'Max Length [in]', 'Length Range [in]', 'Muscle Width [in]', 'Resting Length [in]', 'Min Velocity [in/s]', 'Max Velocity [in/s]', 'Min Acceleration [in/s^2]', 'Max Acceleration [in/s^2]'};

% Retrieve summary information about the desired muscle results.
Lmuscles_min_desired = min(Lmuscles_desired, [], 2); Lmuscles_max_desired = max(Lmuscles_desired, [], 2); Lmuscles_range_desired = Lmuscles_max_desired - Lmuscles_min_desired; Lmuscles_width_desired = Lmuscles_range_desired/2; Lmuscles_rest_desired = Lmuscles_max_desired - Lmuscles_width_desired;
dLmuscles_min_desired = min(dLmuscles_desired, [], 2); dLmuscles_max_desired = max(dLmuscles_desired, [], 2);
ddLmuscles_min_desired = min(ddLmuscles_desired, [], 2); ddLmuscles_max_desired = max(ddLmuscles_desired, [], 2);
Fmuscles_min_desired = min(Fmuscles_total_desired(:, 1:end-2), [], 2); Fmuscles_max_desired = max(Fmuscles_total_desired(:, 1:end-2), [], 2);

% Retrieve summary information about the achieved muscle results.
Lmuscles_min_achieved = min(Lmuscles_achieved, [], 2); Lmuscles_max_achieved = max(Lmuscles_achieved, [], 2); Lmuscles_range_achieved = Lmuscles_max_achieved - Lmuscles_min_achieved; Lmuscles_width_achieved = Lmuscles_range_achieved/2; Lmuscles_rest_achieved = Lmuscles_max_achieved - Lmuscles_width_achieved;
dLmuscles_min_achieved = min(dLmuscles_achieved, [], 2); dLmuscles_max_achieved = max(dLmuscles_achieved, [], 2);
ddLmuscles_min_achieved = min(ddLmuscles_achieved, [], 2); ddLmuscles_max_achieved = max(ddLmuscles_achieved, [], 2);

% Store the desired muscle summary information into a matrix. 
Muscle_Info_Matrix_Desired_Metric = [Lmuscles_min_desired, Lmuscles_max_desired, Lmuscles_range_desired, Lmuscles_width_desired, Lmuscles_rest_desired, dLmuscles_min_desired, dLmuscles_max_desired, ddLmuscles_min_desired, ddLmuscles_max_desired, Fmuscles_min_desired, Fmuscles_max_desired];
Muscle_Info_Matrix_Desired_Imperial = [39.3701*Lmuscles_min_desired, 39.3701*Lmuscles_max_desired, 39.3701*Lmuscles_range_desired, 39.3701*Lmuscles_width_desired, 39.3701*Lmuscles_rest_desired, 39.3701*dLmuscles_min_desired, 39.3701*dLmuscles_max_desired, 39.3701*ddLmuscles_min_desired, 39.3701*ddLmuscles_max_desired, 0.224809*Fmuscles_min_desired, 0.224809*Fmuscles_max_desired];

% Store the desired muscle summary information into a matrix.
Muscle_Info_Matrix_Achieved_Metric = [Lmuscles_min_achieved, Lmuscles_max_achieved, Lmuscles_range_achieved, Lmuscles_width_achieved, Lmuscles_rest_achieved, dLmuscles_min_achieved, dLmuscles_max_achieved, ddLmuscles_min_achieved, ddLmuscles_max_achieved];
Muscle_Info_Matrix_Achieved_Imperial = [39.3701*Lmuscles_min_achieved, 39.3701*Lmuscles_max_achieved, 39.3701*Lmuscles_range_achieved, 39.3701*Lmuscles_width_achieved, 39.3701*Lmuscles_rest_achieved, 39.3701*dLmuscles_min_achieved, 39.3701*dLmuscles_max_achieved, 39.3701*ddLmuscles_min_achieved, 39.3701*ddLmuscles_max_achieved];

% Create a table of desired muscle information.
Muscle_Table_Desired_Metric = array2table(Muscle_Info_Matrix_Desired_Metric, 'RowNames', muscle_names, 'VariableNames', muscle_var_names_desired_metric);
Muscle_Table_Desired_Imperial = array2table(Muscle_Info_Matrix_Desired_Imperial, 'RowNames', muscle_names, 'VariableNames', muscle_var_names_desired_imperial);

% Create a table of achieved muscle information.
Muscle_Table_Achieved_Metric = array2table(Muscle_Info_Matrix_Achieved_Metric, 'RowNames', muscle_names, 'VariableNames', muscle_var_names_achieved_metric);
Muscle_Table_Achieved_Imperial = array2table(Muscle_Info_Matrix_Achieved_Imperial, 'RowNames', muscle_names, 'VariableNames', muscle_var_names_achieved_imperial);

% Print the muscle information table.
fprintf('\n\nMETRIC DESIRED MUSCLE SUMMARY INFORMATION:\n\n')
disp(Muscle_Table_Desired_Metric)

fprintf('\n\nIMPERIAL DESIRED MUSCLE SUMMARY INFORMATION:\n\n')
disp(Muscle_Table_Desired_Imperial)

fprintf('\n\nMETRIC ACHIEVED MUSCLE SUMMARY INFORMATION:\n\n')
disp(Muscle_Table_Achieved_Metric)

fprintf('\n\nIMPERIAL ACHIEVED MUSCLE SUMMARY INFORMATION:\n\n')
disp(Muscle_Table_Achieved_Imperial)


%% Plot the Desired & Achieved Trajectory Over Time.

% Define the size ratio to use for figures.
figure_size = 0.5;

% Create a plot of the desired trajectory vs time.
fig_trajectory1 = figure('Color', 'w', 'Name', 'End Effector Trajectory vs Time');
subplot(3, 2, 1), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Position [m]'), title('Position vs Time (Metric)')
plt = plot(ts, Ps_desired(1, :), '--', 'Linewidth', 3); plot(ts, Ps_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, Ps_desired(2, :), '--', 'Linewidth', 3); plot(ts, Ps_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, Ps_desired(3, :), '--', 'Linewidth', 3); plot(ts, Ps_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, vecnorm(Ps_desired), '--', 'Linewidth', 3); plot(ts, vecnorm(Ps_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 2), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Position [in]'), title('Position vs Time (Imperial)')
plt = plot(ts, 39.3701*Ps_desired(1, :), '--', 'Linewidth', 3); plot(ts, 39.3701*Ps_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, 39.3701*Ps_desired(2, :), '--', 'Linewidth', 3); plot(ts, 39.3701*Ps_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, 39.3701*Ps_desired(3, :), '--', 'Linewidth', 3); plot(ts, 39.3701*Ps_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts, vecnorm(39.3701*Ps_desired), '--', 'Linewidth', 3); plot(ts, vecnorm(39.3701*Ps_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 3), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Velocity [m/s]'), title('Velocity vs Time (Metric)')
plt = plot(ts(1:end-1), dPs_desired(1, :), '--', 'Linewidth', 3); plot(ts(1:end-1), dPs_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), dPs_desired(2, :), '--', 'Linewidth', 3); plot(ts(1:end-1), dPs_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), dPs_desired(3, :), '--', 'Linewidth', 3); plot(ts(1:end-1), dPs_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), vecnorm(dPs_desired), '--', 'Linewidth', 3); plot(ts(1:end-1), vecnorm(dPs_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 4), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Velocity [in/s]'), title('Velocity vs Time (Imperial)')
plt = plot(ts(1:end-1), 39.3701*dPs_desired(1, :), '--', 'Linewidth', 3); plot(ts(1:end-1), 39.3701*dPs_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), 39.3701*dPs_desired(2, :), '--', 'Linewidth', 3); plot(ts(1:end-1), 39.3701*dPs_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), 39.3701*dPs_desired(3, :), '--', 'Linewidth', 3); plot(ts(1:end-1), 39.3701*dPs_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-1), vecnorm(39.3701*dPs_desired), '--', 'Linewidth', 3); plot(ts(1:end-1), vecnorm(39.3701*dPs_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 5), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Acceleration [m/s^2]'), title('Acceleration vs Time (Metric)')
plt = plot(ts(1:end-2), ddPs_desired(1, :), '--', 'Linewidth', 3); plot(ts(1:end-2), ddPs_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), ddPs_desired(2, :), '--', 'Linewidth', 3); plot(ts(1:end-2), ddPs_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), ddPs_desired(3, :), '--', 'Linewidth', 3); plot(ts(1:end-2), ddPs_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), vecnorm(ddPs_desired), '--', 'Linewidth', 3); plot(ts(1:end-2), vecnorm(ddPs_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 6), hold on, grid on, rotate3d on, xlabel('Time [s]'), ylabel('Acceleration [in/s^2]'), title('Acceleration vs Time (Imperial)')
plt = plot(ts(1:end-2), 39.3701*ddPs_desired(1, :), '--', 'Linewidth', 3); plot(ts(1:end-2), 39.3701*ddPs_achieved(1, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), 39.3701*ddPs_desired(2, :), '--', 'Linewidth', 3); plot(ts(1:end-2), 39.3701*ddPs_achieved(2, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), 39.3701*ddPs_desired(3, :), '--', 'Linewidth', 3); plot(ts(1:end-2), 39.3701*ddPs_achieved(3, :), '-', 'Linewidth', 3, 'Color', plt.Color)
plt = plot(ts(1:end-2), vecnorm(39.3701*ddPs_desired), '--', 'Linewidth', 3); plot(ts(1:end-2), vecnorm(39.3701*ddPs_achieved), '-', 'Linewidth', 3, 'Color', plt.Color)
legend({'x Desired', 'x Achieved', 'y Desired', 'y Achieved', 'z Desired', 'z Achieved', 'Mag Desired', 'Mag Achieved'}, 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_trajectory1.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_trajectory1, filename, figure_size)


%% Plot the Desired & Achieved Trajectories in the State Space.

% Create a plot of both the desired and achieved trajectories in the state space.
fig_trajectory2 = figure('Color', 'w', 'Name', 'End Effector Trajectory in the State Space');
subplot(3, 2, 1), hold on, grid on, rotate3d on, xlabel('x Position [m]'), ylabel('y Position [m]'), zlabel('z Position [m]'), title('Position in the State Space (Metric)')
plot3(Ps_desired(1, :), Ps_desired(2, :), Ps_desired(3, :), '--', 'Linewidth', 3)
plot3(Ps_achieved(1, :), Ps_achieved(2, :), Ps_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 2), hold on, grid on, rotate3d on, xlabel('x Position [in]'), ylabel('y Position [in]'), zlabel('z Position [in]'), title('Position in the State Space (Imperial)')
plot3(39.3701*Ps_desired(1, :), 39.3701*Ps_desired(2, :), 39.3701*Ps_desired(3, :), '--', 'Linewidth', 3)
plot3(39.3701*Ps_achieved(1, :), 39.3701*Ps_achieved(2, :), 39.3701*Ps_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 3), hold on, grid on, rotate3d on, xlabel('x Velocity [m/s]'), ylabel('y Velocity [m/s]'), zlabel('z Velocity [m/s]'), title('Velocity in the State Space (Metric)')
plot3(dPs_desired(1, :), dPs_desired(2, :), dPs_desired(3, :), '--', 'Linewidth', 3)
plot3(dPs_achieved(1, :), dPs_achieved(2, :), dPs_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 4), hold on, grid on, rotate3d on, xlabel('x Velocity [in/s]'), ylabel('y Velocity [in/s]'), zlabel('z Velocity [in/s]'), title('Velocity in the State Space (Imperial)')
plot3(39.3701*dPs_desired(1, :), 39.3701*dPs_desired(2, :), 39.3701*dPs_desired(3, :), '--', 'Linewidth', 3)
plot3(39.3701*dPs_achieved(1, :), 39.3701*dPs_achieved(2, :), 39.3701*dPs_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 5), hold on, grid on, rotate3d on, xlabel('x Acceleration [m/s^2]'), ylabel('y Acceleration [m/s^2]'), zlabel('z Acceleration [m/s^2]'), title('Acceleration in the State Space (Metric)')
plot3(ddPs_desired(1, :), ddPs_desired(2, :), ddPs_desired(3, :), '--', 'Linewidth', 3)
plot3(ddPs_achieved(1, :), ddPs_achieved(2, :), ddPs_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

subplot(3, 2, 6), hold on, grid on, rotate3d on, xlabel('x Acceleration [in/s^2]'), ylabel('y Acceleration [in/s^2]'), zlabel('z Acceleration [in/s^2]'), title('Acceleration in the State Space (Imperial)')
plot3(39.3701*ddPs_desired(1, :), 39.3701*ddPs_desired(2, :), 39.3701*ddPs_desired(3, :), '--', 'Linewidth', 3)
plot3(39.3701*ddPs_achieved(1, :), 39.3701*ddPs_achieved(2, :), 39.3701*ddPs_achieved(3, :), '-', 'Linewidth', 3)
legend('Desired', 'Achieved', 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_trajectory2.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_trajectory2, filename, figure_size)


%% Plot the Desired & Achieved Trajectory over Time in the Joint Space.

% Create a plot of the desired trajectory in the joint space over time.
fig_jointspace = figure('Color', 'w', 'Name', 'End Effector Trajectory in Joint Space');
subplot(3, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Angles, $\theta$ [rad]', 'Interpreter', 'Latex'), title('Joint Angles vs Time (Metric)')
subplot(3, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Angles, $\theta$ [deg]', 'Interpreter', 'Latex'), title('Joint Angles vs Time (Imperial)')
subplot(3, 2, 3), hold  on, grid on, xlabel('Time [s]'), ylabel('Joint Angular Velocities, $\dot{\theta}$ [rad/s]', 'Interpreter', 'Latex'), title('Joint Angular Velocity vs Time (Metric)')
subplot(3, 2, 4), hold  on, grid on, xlabel('Time [s]'), ylabel('Joint Angular Velocities, $\dot{\theta}$ [deg/s]', 'Interpreter', 'Latex'), title('Joint Angular Velocity vs Time (Imperial)')
subplot(3, 2, 5), hold  on, grid on, xlabel('Time [s]'), ylabel('Joint Angular Accelerations, $\ddot{\theta}$ [rad/$\mathrm{s}^2$]', 'Interpreter', 'Latex'), title('Joint Angular Acceleration vs Time (Metric)')
subplot(3, 2, 6), hold  on, grid on, xlabel('Time [s]'), ylabel('Joint Angular Accelerations, $\ddot{\theta}$ [deg/$\mathrm{s}^2$]', 'Interpreter', 'Latex'), title('Joint Angular Acceleration vs Time (Imperial)')

% Initialize a cell array to store the legend entries.
legstr = cell(2*num_joints, 1);

% Plot the desired trajectory in the joint space.
for k = 1:num_joints        % Iterate through each of the joints...
    
    % Plot this joint's angle over time.
    subplot(3, 2, 1), plt = plot(ts, thetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, thetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    subplot(3, 2, 2), plt = plot(ts, (180/pi)*thetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, (180/pi)*thetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    
    % Plot this joint's angular velocity over time.
    subplot(3, 2, 3), plt = plot(ts, dthetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, dthetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    subplot(3, 2, 4), plt = plot(ts, (180/pi)*dthetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, (180/pi)*dthetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    
    % Plot this joint's angular acceleration over time.
    subplot(3, 2, 5), plt = plot(ts, ddthetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, ddthetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    subplot(3, 2, 6), plt = plot(ts, (180/pi)*ddthetas_desired(k, :), '--', 'Linewidth', 3); plot(ts, (180/pi)*ddthetas_achieved(k, :), '-', 'Linewidth', 3, 'Color', plt.Color)
    
    % Create this legend entry.
    legstr{2*k - 1} = [joint_names{k} ' Desired'];
    legstr{2*k} = [joint_names{k} ' Achieved'];    

end

% Display the legend.
legend(legstr, 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_jointspace.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_jointspace, filename, figure_size)


%% Plot the Local Moments of Inertia Over Time.

% Plot the change in moment of inertia about each joint over time.
fig_MOI = figure('Color', 'w', 'Name', 'Moments of Inertia vs Time');
subplot(3, 1, 1), hold on , grid on, xlabel('Time [s]'), ylabel('Moment of Inertia (Joint 1) [m^2/kg]'), title('Moment of Inertia vs Time (Joint 1)'), plot(ts, Ijointaxes(1, :), '-', 'Linewidth', 2)
subplot(3, 1, 2), hold on , grid on, xlabel('Time [s]'), ylabel('Moment of Inertia (Joint 2) [m^2/kg]'), title('Moment of Inertia vs Time (Joint 2)'), plot(ts, Ijointaxes(2, :), '-', 'Linewidth', 2)
subplot(3, 1, 3), hold on , grid on, xlabel('Time [s]'), ylabel('Moment of Inertia (Joint 3) [m^2/kg]'), title('Moment of Inertia vs Time (Joint 3)'), plot(ts, Ijointaxes(3, :), '-', 'Linewidth', 2)

% Create a file name for the saved figure.
filename = split(fig_MOI.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_MOI, filename, figure_size)


%% Plot the Desired Joint Torques.

% Create a figure to store the necessary joint torques over time.
fig_jointtorques = figure('Color', 'w', 'Name', 'Joint Torques vs Time');
subplot(1, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Torque [Nm]'), title('Joint Torque vs Time (Metric)')
subplot(1, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Joint Torque [lb-in]'), title('Joint Torque vs Time (Imperial)')

% Initialize a variable to store the legend entries.
legstr = cell(num_joints, 1);

% Plot each of the required joint torques over time.
for k = 1:num_joints            % Iterate through each joint..
    
    % Plot the required torque for this joint.
    subplot(1, 2, 1), plot(ts(1:end-2), taus_desired(k, 1:end-2), '-', 'Linewidth', 3)
    subplot(1, 2, 2), plot(ts(1:end-2), 8.8507457673787*taus_desired(k, 1:end-2), '-', 'Linewidth', 3)

    % Add an entry to the legend cell.
%     legstr{k} = sprintf('Joint %0.0f', k);
    legstr{k} = joint_names{k};

end

% Display the legend.
subplot(1, 2, 1), legend(legstr, 'Location', 'South', 'Orientation', 'Horizontal')
subplot(1, 2, 2), legend(legstr, 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_jointtorques.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_jointtorques, filename, figure_size)


%% Plot the Muscle States (Length, Velocity, Acceleration) Over Time.

% Define the extensor colors.
ext_colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.929 0.694 0.125];

% Define the flexor colors.
flx_colors = min(1.50*ext_colors, 1);

% Define an array of colors to use on the plot.
line_colors = cat(3, ext_colors, flx_colors);

% Create a figure to store the muscle length vs time.
fig_musclelengths = figure('Color', 'w', 'Name', 'Muscle Lengths vs Time');
subplot(3, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Lengths [m]'), title('Muscle Length vs Time (Metric)')
subplot(3, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Lengths [in]'), title('Muscle Length vs Time (Imperial)')
subplot(3, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Velocity [m/s]'), title('Muscle Velocity vs Time (Metric)')
subplot(3, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Velocity [in/s]'), title('Muscle Velocity vs Time (Imperial)')
subplot(3, 2, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Acceleration [m/s^2]'), title('Muscle Acceleration vs Time (Metric)')
subplot(3, 2, 6), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Acceleration [in/s^2]'), title('Muscle Acceleration vs Time (Imperial)')

% Initialize a cell array to store the legend entries.
legstr = cell(2*num_muscles, 1);

% Define a legend entry counter variable.
legend_counter = 0;

% Initialize a muscle counter variable.
muscle_counter = 0;

% Plot each of the muscle lengths over time.
for k1 = 1:num_joints                   % Iterate through each joint...
    for k2 = 1:num_muscle_types         % Iterate through each muscle type...
        
        % Advance the legend counter variable.
        legend_counter = legend_counter + 1;
        
        % Advance the muscle counter variable.
        muscle_counter = muscle_counter + 1;
        
        % Plot the desired length of this muscle over time.
        subplot(3, 2, 1), plot(ts, Lmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 2), plot(ts, 39.3701*Lmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 3), plot(ts, dLmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 4), plot(ts, 39.3701*dLmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 5), plot(ts, ddLmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 6), plot(ts, 39.3701*ddLmuscles_desired(muscle_counter, :), '-', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))       

        % Plot the achieved length of this muscle over time.
        subplot(3, 2, 1), plot(ts, Lmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 2), plot(ts, 39.3701*Lmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 3), plot(ts, dLmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 4), plot(ts, 39.3701*dLmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 5), plot(ts, ddLmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))
        subplot(3, 2, 6), plot(ts, 39.3701*ddLmuscles_achieved(muscle_counter, :), '--', 'Linewidth', 3, 'Color', line_colors(k1, :, k2))  
        
        % Create an appropriate legend entry for this figure element.
        legstr{legend_counter} = [muscle_names{muscle_counter}, ' Desired'];
        legend_counter = legend_counter + 1;
        legstr{legend_counter} = [muscle_names{muscle_counter}, ' Achieved'];

    end
end

% Create the legend.
legend(legstr, 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_musclelengths.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_musclelengths, filename, figure_size)


%% Plot the Muscle Forces Over Time.

% Define an array of colors to use on the plot.
line_colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.929 0.694 0.125];

% Define an array of line styles to use.
line_styles = {'-', '--'};

% Create a figure to store the muscle forces over time.
fig_muscleforces = figure('Color', 'w', 'Name', 'Muscle Forces vs Time');
subplot(3, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Passive Muscle Force [N]'), title('Passive Muscle Force vs Time (Metric)')
subplot(3, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Passive Muscle Force [lbf]'), title('Passive Muscle Force vs Time (Imperial)')
subplot(3, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Active Muscle Force [N]'), title('Active Muscle Force vs Time (Metric)')
subplot(3, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Active Muscle Force [lbf]'), title('Active Muscle Force vs Time (Imperial)')
subplot(3, 2, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Total Muscle Force [N]'), title('Total Muscle Force vs Time (Metric)')
subplot(3, 2, 6), hold on, grid on, xlabel('Time [s]'), ylabel('Total Muscle Force [lbf]'), title('Total Muscle Force vs Time (Imperial)')

% Initialize an array to store the legend entries.
legstr = cell(num_muscles, 1);

% Initialize a counter variable.
k3 = 0;

% Plot the force of each muscle over time.
for k1 = 1:num_joints                   % Iterate through each joint...
    for k2 = 1:num_muscle_types         % Iterate through each muscle type...
        
        % Advance the counter variable.
        k3 = k3 + 1;
        
        % Add the current muscle force over time to the plot.
        subplot(3, 2, 1), plot(ts(2:end-3), Fmuscles_passive_desired(k3, 2:end-3), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        subplot(3, 2, 2), plot(ts(2:end-3), 0.224809*Fmuscles_passive_desired(k3, 2:end-3), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        subplot(3, 2, 3), plot(ts(2:end-3), Fmuscles_active_desired(k3, 2:end-3), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        subplot(3, 2, 4), plot(ts(2:end-3), 0.224809*Fmuscles_active_desired(k3, 2:end-3), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        subplot(3, 2, 5), plot(ts(1:end-2), Fmuscles_total_desired(k3, 1:end-2), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        subplot(3, 2, 6), plot(ts(1:end-2), 0.224809*Fmuscles_total_desired(k3, 1:end-2), line_styles{k2}, 'Linewidth', 3, 'Color', line_colors(k1, :))
        
        % Add an appropriate legend entry to our cell.
        legstr{k3} = muscle_names{k3};
        
    end
end

% Add display the legend.
legend(legstr, 'Location', 'South', 'Orientation', 'Horizontal')

% Create a file name for the saved figure.
filename = split(fig_muscleforces.Name, ' '); filename = strcat(filename{:}, '.jpg');

% Save the figure.
SaveFigureAtSize(fig_muscleforces, filename, figure_size)


%% Animate the Open Kinematic Chain.

% Create a figure to store the animation.
fig_animation = figure('Color', 'w', 'Name', 'Robot Animation'); hold on, rotate3d on, view(0, 90), xlabel('x'), ylabel('y'), zlabel('z')
axis([-Ltotal Ltotal, -Ltotal Ltotal -Ltotal Ltotal])
%axis equal

% Preallocate an array to store the legend entries.
legstr = cell(num_bodies + 6, 1);

% Initialize a legend index.
legindex = 0;

% Plot the desired path.
desiredpath_plt = plot3(Ps_desired(1, :), Ps_desired(2, :), Ps_desired(3, :), '--', 'Linewidth', 2, 'XDataSource', 'Pend_desired(1, :, 1:k)', 'YDataSource', 'Pend_desired(2, :, 1:k)', 'ZDataSource', 'Pend_desired(3, :, 1:k)');
legstr{legindex + 1} = 'Desired Path';
legindex = legindex + 1;

% Initialize a graphics object array to store the body figure elements.
bodies_desired_plt = gobjects(num_bodies, 1);
bodies_achieved_plt = gobjects(num_bodies, 1);

% Create a graphics object for each body.
for k = 1:num_bodies                % Iterate through each of the bodies...
    
    % Define the data source strings.
    xDataSourceStr_desired = sprintf('Pbodies_desired(1, :, %0.0f, k)', k);
    yDataSourceStr_desired = sprintf('Pbodies_desired(2, :, %0.0f, k)', k);
    zDataSourceStr_desired = sprintf('Pbodies_desired(3, :, %0.0f, k)', k);
    
    xDataSourceStr_achieved = sprintf('Pbodies_achieved(1, :, %0.0f, k)', k);
    yDataSourceStr_achieved = sprintf('Pbodies_achieved(2, :, %0.0f, k)', k);
    zDataSourceStr_achieved = sprintf('Pbodies_achieved(3, :, %0.0f, k)', k);
    
    % Create a graphics object for this body.
    bodies_desired_plt(k) = plot3(0, 0, 0, '-', 'Linewidth', 2, 'Color', [0.5 0.5 0.5], 'XDataSource', xDataSourceStr_desired, 'YDataSource', yDataSourceStr_desired, 'ZDataSource', zDataSourceStr_desired);
    bodies_achieved_plt(k) = plot3(0, 0, 0, '-', 'Linewidth', 2, 'Color', [0 0 0], 'XDataSource', xDataSourceStr_achieved, 'YDataSource', yDataSourceStr_achieved, 'ZDataSource', zDataSourceStr_achieved);
    
    % Add an appropriate entry to the legend string.
    legstr{legindex + 1} = sprintf('Body %0.0f Desired', k);
    legindex = legindex + 1;
    
    legstr{legindex + 1} = sprintf('Body %0.0f Achieved', k);
    legindex = legindex + 1;
    
end

% Initialize a graphics object to store the muscle figure elements.
muscles_desired_plt = gobjects(num_bodies, 1);
muscles_achieved_plt = gobjects(num_bodies, 1);

% Create a graphics object for each muscle.
for k = 1:num_muscles                % Iterate through each of the muscles...
    
    % Define the data source strings.
    xDataSourceStr_desired = sprintf('Pmuscles_desired(1, :, %0.0f, k)', k);
    yDataSourceStr_desired = sprintf('Pmuscles_desired(2, :, %0.0f, k)', k);
    zDataSourceStr_desired = sprintf('Pmuscles_desired(3, :, %0.0f, k)', k);
    
    xDataSourceStr_achieved = sprintf('Pmuscles_achieved(1, :, %0.0f, k)', k);
    yDataSourceStr_achieved = sprintf('Pmuscles_achieved(2, :, %0.0f, k)', k);
    zDataSourceStr_achieved = sprintf('Pmuscles_achieved(3, :, %0.0f, k)', k);
    
    % Create a graphics object for this body.
    muscles_desired_plt(k) = plot3(0, 0, 0, '.-', 'Markersize', 20, 'Linewidth', 2, 'Color', [0.5 0.5 1], 'XDataSource', xDataSourceStr_desired, 'YDataSource', yDataSourceStr_desired, 'ZDataSource', zDataSourceStr_desired);
    muscles_achieved_plt(k) = plot3(0, 0, 0, '.-', 'Markersize', 20, 'Linewidth', 2, 'Color', [0 0 1], 'XDataSource', xDataSourceStr_achieved, 'YDataSource', yDataSourceStr_achieved, 'ZDataSource', zDataSourceStr_achieved);
    
    % Add an appropriate entry to the legend string.
    legstr{legindex + 1} = sprintf('Muscle %0.0f Desired', k);
    legindex = legindex + 1;
    
    legstr{legindex + 1} = sprintf('Muscle %0.0f Achieved', k);
    legindex = legindex + 1;
    
end

% Create a graphics object for the center of mass locations.
cm_desired_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [0.5 1 0.5], 'XDataSource', 'Pcms_desired(1, 1, :, k)', 'YDataSource', 'Pcms_desired(2, 1, :, k)', 'ZDataSource', 'Pcms_desired(3, 1, :, k)');
legstr{legindex + 1} = 'COMs Desired';
legindex = legindex + 1;

cm_achieved_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [0 1 0], 'XDataSource', 'Pcms_achieved(1, 1, :, k)', 'YDataSource', 'Pcms_achieved(2, 1, :, k)', 'ZDataSource', 'Pcms_achieved(3, 1, :, k)');
legstr{legindex + 1} = 'COMs Achieved';
legindex = legindex + 1;

% Create a graphics object for the cumulative center of mass locations.
cm_cumulative_desired_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [1, 178/255, 102/255], 'XDataSource', 'Pcm_cumulative_desired_global(1, 1, :, k)', 'YDataSource', 'Pcm_cumulative_desired_global(2, 1, :, k)', 'ZDataSource', 'Pcm_cumulative_desired_global(3, 1, :, k)');
legstr{legindex + 1} = 'Cumulative COMs Desired';
legindex = legindex + 1;

cm_cumulative_achieved_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [1, 0.5, 0], 'XDataSource', 'Pcm_cumulative_achieved_global(1, 1, :, k)', 'YDataSource', 'Pcm_cumulative_achieved_global(2, 1, :, k)', 'ZDataSource', 'Pcm_cumulative_achieved_global(3, 1, :, k)');
legstr{legindex + 1} = 'Cumulative COMs Achieved';
legindex = legindex + 1;

% Create a graphics object for the joint locations.
joint_desired_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [102/255, 1, 1], 'XDataSource', 'Pjoints_desired(1, 1, :, k)', 'YDataSource', 'Pjoints_desired(2, 1, :, k)', 'ZDataSource', 'Pjoints_desired(3, 1, :, k)');
legstr{legindex + 1} = 'Joints Desired';
legindex = legindex + 1;

joint_achieved_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [0, 1, 1], 'XDataSource', 'Pjoints_achieved(1, 1, :, k)', 'YDataSource', 'Pjoints_achieved(2, 1, :, k)', 'ZDataSource', 'Pjoints_achieved(3, 1, :, k)');
legstr{legindex + 1} = 'Joints Achieved';
legindex = legindex + 1;

% Create a graphics object for the end effector.
endeffector_desired_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [102/255 178/255 1], 'XDataSource', 'Pend_desired(1, :, k)', 'YDataSource', 'Pend_desired(2, :, k)', 'ZDataSource', 'Pend_desired(3, :, k)');
legstr{legindex + 1} = 'End Effector Desired';
legindex = legindex + 1;

endeffector_achieved_plt = plot3(0, 0, 0, '.', 'Markersize', 20, 'Color', [0 0.5 1], 'XDataSource', 'Pend_achieved(1, :, k)', 'YDataSource', 'Pend_achieved(2, :, k)', 'ZDataSource', 'Pend_achieved(3, :, k)');
legstr{legindex + 1} = 'End Effector Achieved';
legindex = legindex + 1;

% Create a graphics object for the end effector path.
endpath_desired_plt = plot3(0, 0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Pend_desired(1, :, 1:k)', 'YDataSource', 'Pend_desired(2, :, 1:k)', 'ZDataSource', 'Pend_desired(3, :, 1:k)');
legstr{legindex + 1} = 'End Path Desired';
legindex = legindex + 1;

endpath_achieved_plt = plot3(0, 0, 0, '-', 'Linewidth', 2, 'XDataSource', 'Pend_achieved(1, :, 1:k)', 'YDataSource', 'Pend_achieved(2, :, 1:k)', 'ZDataSource', 'Pend_achieved(3, :, 1:k)');
legstr{legindex + 1} = 'End Path Achieved';
legindex = legindex + 1;

% Create a legend for the plot.
legend(legstr, 'Location', 'Eastoutside', 'Orientation', 'Vertical')

% Set the number of animation playbacks.
num_playbacks = 3;

% % Initialize a video object.
% myVideo = VideoWriter('RobotAnimation'); %open video file
% myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
% open(myVideo)

% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back...    
    for k = 1:10:num_timesteps              % Iterate through each of the angles...
        
        % Refresh the plot data.
        refreshdata([bodies_achieved_plt; bodies_desired_plt; muscles_desired_plt; muscles_achieved_plt; cm_desired_plt; cm_achieved_plt; cm_cumulative_desired_plt; cm_cumulative_achieved_plt; joint_desired_plt; joint_achieved_plt; endeffector_desired_plt; endeffector_achieved_plt; endpath_desired_plt; endpath_achieved_plt], 'caller')
        
        % Update the plot.
        drawnow
        
%         % Write the current frame to the file.
%         writeVideo(myVideo, getframe(gcf));

    end
end

% % Close the video object.
% close(myVideo)


