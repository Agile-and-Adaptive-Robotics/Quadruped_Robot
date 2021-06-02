%% Quadruped Simulation

% This script constructs position controllers for the joints of a quadruped robot.

% Clear Everything.
clear, close('all'), clc

%% Decide whether to run step simulation or abduction/adduction simulation
prompt = 'Would you like to run this as an abduction/adduction simluation instead? y/n: ';
answer = input(prompt, 's');
tf = strcmp(answer, 'y');


%% Define the Robot Geometry & Mechanical Properties.

% Setting global origin to coordinate system 1 as defined by Miles


% Define the mechanical properties of link 1 - defined by hip
% flexion/extension (Hip swivel)
m1 = 0.133594;                                                                                                  % [kg] Link Mass.
ct1 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt1 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
Lx1 = 0.13214; Ly1 = 0.0127; Lz1 = 0.06867; Ls1 = [Lx1; Ly1; Lz1];                                              % [m] Link Length in each direction of the local link frame.
Phome_cm1 = [0.000757; 0 ; 0.048312];                                                                           % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm1 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm1 = [0.000084, 0, 0; 0, 0.000228, 0; 0, 0, 0.000148];                                                   % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G1 = [Ihome_cm1, zeros(3, 3); zeros(3, 3), m1*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body1 = GetCuboidPoints(Ls1(1), Ls1(2), Ls1(3), Phome_cm1(1), Phome_cm1(2), Phome_cm1(3), 0, 0, 0);       % [m] Link Points
Rhome_body1 = Rhome_cm1;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Define the mechanical properties of link 2 - defined by
% abduction/adduction (hip swivel, femur, upper knee)
m2 = 0.186595;                                                                                                  % [kg] Link Mass.
ct2 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt2 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
Lx2 = 0.35065; Ly2 = 0.02111; Lz2 = 0.0254; Ls2 = [Lx2; Ly2; Lz2];                                              % [m] Link Length in each direction of the local link frame.
Phome_cm2 = [0.111622; -0.000577 ; 0.050078];                                                                   % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm2 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm2 = [0.000031, -0.000017, 0; -0.000017, 0.002070, 0; 0, 0, 0.002075];                                   % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G2 = [Ihome_cm2, zeros(3, 3); zeros(3, 3), m2*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body2 = GetCuboidPoints(Ls2(1), Ls2(2), Ls2(3), Phome_cm2(1), Phome_cm2(2), Phome_cm2(3), 0, 0, 0);       % [m] Link Points
Rhome_body2 = Rhome_cm2;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Define the mechanical properties of link 3 - Tibia, lower knee, encoders.
m3 = .170503;                                                                                                   % [kg] Link Mass.
ct3 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt3 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
%Lx3 = 0.23422; Ly3 = 0.01588; Lz3 = 0.01619; Ls3 = [Lx3; Ly3; Lz3];                                             % [m] Link Length in each direction of the local link frame.    
Lx3 = 0.237173; Ly3 = 0.02856; Lz3 = 0.032385; Ls3 = [Lx3; Ly3; Lz3];
Phome_cm3 = [0.366555; -.000297; 0.053825];                                                                     % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm3 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm3 = [0.000033, 0.000005, 0.00001; 
             0.000005, 0.001383, 0; 
             0.00001, 0, 0.001372];                         % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G3 = [Ihome_cm3, zeros(3, 3); zeros(3, 3), m3*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body3 = GetCuboidPoints(Ls3(1), Ls3(2), Ls3(3), Phome_cm3(1), Phome_cm3(2), Phome_cm3(3), 0, 0, 0);       % [m] Link Points
Rhome_body3 = Rhome_cm3;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Define the mechanical properties of link 4 - Foot.
m4 = 0.087102;                                                                                                  % [kg] Link Mass.
ct4 = 1;                                                                                                        % [Nms/rad] Link Angular Viscous Friction.
kt4 = 1;                                                                                                        % [Nm/rad] Link Angular Stiffness.
%Lx4 = 0.13413; Ly4 = 0.00318; Lz4 = 0.01753; Ls4 = [Lx4; Ly4; Lz4];                                          % [m] Link Length in each direction of the local link frame.
Lx4 = 0.14845; Ly4 = 0.078967; Lz4 = 0.032385; Ls4 = [Lx4; Ly4; Lz4]; 
Phome_cm4 = [.539952; 0.014351 ; 0.049821];                                                                     % [m] Link Center of Mass Location in the Global Frame.
Rhome_cm4 = eye(3);                                                                                             % [-] Link Center of Mass Orientation in the Global Frame.
Ihome_cm4 = [0.000038, -0.000042, 0.000001; -0.000042, 0.000277, 0; 0.000001, 0, 0.000306];                     % [m^2/kg] Link Moment of Inertia at COM in the Local Frame.
G4 = [Ihome_cm4, zeros(3, 3); zeros(3, 3), m4*eye(3, 3)];                                                       % [-] Spatial Inertia Matrix for This Link.
Phome_body4 = GetCuboidPoints(Ls4(1), Ls4(2), Ls4(3), Phome_cm4(1), Phome_cm4(2), Phome_cm4(3), 0, 0, 0);       % [m] Link Points
Rhome_body4 = Rhome_cm4;                                                                                        % [-] Orientation of the Link in the Global Frame.

% Compile information about each link into arrays.
ms = [m1; m2; m3; m4];                                                                                          % [kg] Mass of Each Link.
cts = [ct1; ct2; ct3; ct4];                                                                                     % [Nms/rad] Angular Viscous Friction of Each Link.
kts = [kt1; kt2; kt3; kt4];                                                                                     % [Nm/rad] Link Angular Stiffness.
Phome_cms = [Phome_cm1 Phome_cm2 Phome_cm3 Phome_cm4];                                                          % [m] Center of Mass Location for Each Link in the Global Frame.
Rhome_cms = cat(3, Rhome_cm1, Rhome_cm2, Rhome_cm3, Rhome_cm4);                                                 % [-] Center of Mass Orientation for Each Link in the Global Frame.
Ihome_cms = cat(3, Ihome_cm1, Ihome_cm2, Ihome_cm3, Ihome_cm4);                                                 % [m^2/kg] Moment of Inertia for Each Link in their Local Frames.
Gs = cat(3, G1, G2, G3, G4);                                                                                    % [-] Spatial Inertia Matrix for Each Link in the Global Frame.
Phome_bodies = cat(3, Phome_body1, Phome_body2, Phome_body3, Phome_body4);                                      % [m] Body Points for Each Link in the Global Frame.
Rhome_bodies = cat(3, Rhome_body1, Rhome_body2, Rhome_body3, Rhome_body4);                                      % [m] Orientation of Each Link in the Global Frame.                                                                               % [m] Total Length.
Ltotal = Phome_cm4(1) + Lx4/2;                                                                                  % [m] Total Length.

% Define the home joint locations.
Phome_joint1 = [0; 0; 0.05008];                                                                                 % [m] Joint Location in the Global Frame.
Phome_joint2 = [-0.06985; 0; 0.05008];                                                                                    % [m] Joint Location in the Global Frame.
Phome_joint3 = [Phome_cm2(1) + Lx2/2; Phome_cm2(2) + Ly2/2; Phome_cm2(3)];                                                                    % [m] Joint Location in the Global Frame.                                                                          % [m] Joint Location in the Global Frame.
Phome_joint4 = [Phome_cm3(1) + Lx3/2; Phome_cm3(2) + Ly3/2; Phome_cm3(3)];                                                                    % [m] Joint Location in the Global Frame.
Phome_joints = [Phome_joint1 Phome_joint2 Phome_joint3 Phome_joint4];                                           % [m] Joint Locations in the Global Frame.

% Define the home joint orientations.
Rhome_joint1 = Rhome_body1; 
Rhome_joint2 = Rhome_body2;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joint3 = Rhome_body3;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joint4 = Rhome_body4;                                                                                     % [-] Joint Orientation in the Global Frame.
Rhome_joints = cat(3, Rhome_joint1, Rhome_joint2, Rhome_joint3, Rhome_joint4);                                                % [-] Joint Orientations in the Global Frame.

% Define the joint axes of rotation.
w1_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of for a(b/d)duction This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
w2_local = [0; 1; 0];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).                     
w3_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
w4_local = [0; 0; 1];                                                                                           % [rad/s] Axis of Rotation of This Link in its Local Frame (Note that, since the local frames are in this case aligned with the global frame in the home position), these are the same rotational axes used in the screw axes).
ws_local = [w1_local w2_local w3_local w4_local];                                                                        % [rad/s] Axes of Rotation of Each Link in its Local Frame.

% Define the end effector location & orientation.
Phome_end = [Ltotal; 0; 0.05008];                                                                    % [m] End Effector Location in the Global Frame.
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
% Read in Muscle Data
muscle_data = readtable('Muscle_Data.xlsx');


% Define the joint names. Hip x is the joint for abduction/adduction, as it
% rotates around the x-axis, hip z s the joint for flexion/extension as it
% rotates around the z axis
joint_names = {'Hip_y', 'Hip_x', 'Knee', 'Ankle'};

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
muscle_names = table2cell(muscle_data(:,1));
% Define the joint orientations.  i.e., the first joint is moved in the positive direction by the extensor, the second by the flexor, and the third by the extensor.
muscle_joint_orientations = {'Ext', 'Flx', 'Flx', 'Ext'};

% Read in the muscle location data.
% Ps_hipadd = dlmread('Ps_hipadd.txt');
% Ps_hipabd = dlmread('Ps_hipabd.txt');
% Ma_hipext = dlmread('Ma_hipext.txt');
% Ma_hipflx = dlmread('Ma_hipflx.txt');
% Ma_kneeext = dlmread('Ma_kneeext.txt');
% Ma_kneeflx = dlmread('Ma_kneeflx.txt');
% Ma_ankleext = dlmread('Ma_ankleext.txt');
% Ma_ankleflx = dlmread('Ma_ankleflx.txt');
% % % the following files are for the biarticular muscles, uncomment when ready
% Ps_Ba_hipext = dlmread('Ba_hipext.txt');
% Ps_Ba_hipflx = dlmread('Ba_hipflx.txt');
% Ps_Ba_ankleflx = dlmread('Ba_ankleflx.txt');

% Read in muscle location data 
muscle_loc = table2array(muscle_data(:,4:12));
% Hips


    K1=1;
    Ps_Ba_hipext = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
    Ps_Ba_hipflx = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
Ps_hipext = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
Ps_hipflx = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
% Knees
Ps_kneeext = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];

    K1 = K1+1; 
Ps_kneeflx = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
% Ankles
Ps_Ba_ankleflx = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
Ps_ankleext = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
    K1 = K1+1; 
Ps_ankleflx = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
                    K1 = K1+1; 

Ps_hipadd  = [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];
                    K1 = K1+1; 


Ps_hipabd= [muscle_loc(K1,1), muscle_loc(K1,4), muscle_loc(K1,7)
                    muscle_loc(K1,2), muscle_loc(K1,5), muscle_loc(K1,8)
                    muscle_loc(K1,3), muscle_loc(K1,6), muscle_loc(K1,9)];

% Store the muscle attachment locations in a high order tensor.
% Phome_muscles = cat(3, Ma_hipext, Ma_hipflx, Ps_hipadd, Ps_hipabd, Ma_kneeext, Ma_kneeflx, Ma_ankleext, Ma_ankleflx, Ps_Ba_hipext, Ps_Ba_hipflx, Ps_Ba_ankleflx);
Phome_muscles = cat(3, Ps_Ba_hipext,Ps_Ba_hipflx, Ps_hipext, Ps_hipflx, Ps_kneeext, Ps_kneeflx,Ps_Ba_ankleflx, Ps_ankleext, Ps_ankleflx , Ps_hipadd, Ps_hipabd );

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



j_loc = table2array(muscle_data(:,13:15));
for k1 = 1:num_muscles                      % Iterate through each of the muscles...
    for k2 = 1:num_pts_per_muscle           % Iterate through each of the muscle attachment points...
        
        % Compute the home matrix asscoated with this point on this muscle.
        Mmuscles(:, :, k2, k1) = [Rhome_muscles, Phome_muscles(:, k2, k1); zeros(1, 3), 1];
        
        % Determine which joint to assign this point to.
            Jmuscles(k2, k1) = j_loc(k1,k2);

    end
    
    % Advance the counter on even iterations.
%     if mod(k1, 2) == 0          % If this is an even iteration...
%         
%         % Advance the counter.
%         k3 = k3 + 1;
%         
end

% %Delete?
% for k1 = 1:num_muscles                      % Iterate through each of the muscles...
%     for k2 = 1:num_pts_per_muscle           % Iterate through each of the muscle attachment points...
%         
%         % Compute the home matrix asscoated with this point on this muscle.
%         Mmuscles(:, :, k2, k1) = [Rhome_muscles, Phome_muscles(:, k2, k1); zeros(1, 3), 1];
%         
%         % Determine which joint to assign this point to.
%         if k2 == num_pts_per_muscle
%             Jmuscles(k2, k1) = k3 + 1;
%         else
%             Jmuscles(k2, k1) = k3;
%         end
%     end
%     
%     % Advance the counter on even iterations.
%     if mod(k1, 2) == 0          % If this is an even iteration...
%         
%         % Advance the counter.
%         k3 = k3 + 1;
%         
%     end
%     
% end

% Fix the adduction & abduction joint assignments.
% Jmuscles( 2, 3:4 ) = [ 2, 2 ];
% Jmuscles = [0,0,1,1,1,1,2,2,0,0,1;
%             0,0,2,2,1,1,2,2,1,1,3;
%             1,1,2,2,2,2,3,3,2,2,3];
% Define the home matrix for the end effector.

Mend = [Rhome_end, Phome_end; zeros(1, 3), 1];
Jend = num_joints;

% Define the screw axes.

r1 = [Phome_joint1(1); Phome_joint1(2);Phome_joint1(3)];
r2 = [Phome_joint2(1); Phome_joint2(2);Phome_joint2(3)];
r3 = [Phome_joint3(1); Phome_joint3(2);Phome_joint3(3)];
r4 = [Phome_joint4(1); Phome_joint4(2);Phome_joint4(3)];

v1 = cross(r1,w1_local);
v2 = cross(r2,w2_local);
v3 = cross(r3,w3_local);
v4 = cross(r4,w4_local);

S1 = [w1_local;v1];
S2 = [w2_local;v2];
S3 = [w3_local;v3];
S4 = [w4_local;v4];

% S1 = [w1_local; cross(Phome_joint1, w1_local)];
% S2 = [w2_local; cross(Phome_joint2, w2_local)];
% S3 = [w3_local; cross(Phome_joint3, w3_local)];
% S4 = [w4_local; cross(Phome_joint4, w4_local)];
Ss = [S1 S2 S3 S4];

%% Define the Simulation Properties.

% Create a time vector.
  dt = 0.001;                    % [s] Simulation Step Size
% dt = 0.0001;                   % [s] Simulation Step Size
% dt = 0.00005;                  % [s] Simulation Step Size
% dt = 0.00001;                  % [s] Simulation Step Size

%{
Adjust to reflect walking motion loop time (1.5 ~ 2 seconds?)
%}

tfinal = 1;                 % [s] Simulation Duration.
ts = 0:dt:tfinal;           % [s] Simulation Time Vector.

% Retrieve the number of time steps.
num_timesteps = length(ts);

% Define the gravity vector.
g = [0; -9.81; 0];


%% Define the Trajectory Properties of flexion/extension simulation.
if tf == 0
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

ground_height = 0.5605;   % [m] Ground Height Relative to Body.
% ground_height = 0.381;

% Define the horizontal step shift.
horizontal_shift = -0.0069;           % [m] Horizontal Shift to Apply to Step Trajectory.

% Define the step height and stride length.

%{
Verify this matches the step trajectory and check where in code thse vars
are used
%}

step_height = 0.04;         % [m] Step Heigth.
step_length = 0.15;          % [m] Step Length.

end

%% Define the Trajectory Properties of abduction/adduction simulation.
    
if tf == 1
    % Define the step shift.
    radius_y = Phome_end(1);
    horizontal_shift_y = Phome_end(3);
    %vertical_shift_y = Phome_end(1) - Phome_joint4(1);
    
end

%% Generate Desired End Effector Trajectory for y rotation.

if tf == 1
% State that we are generating a desired trajectory.
    fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY FOR Y ROTATION... Please Wait...\n')

    % Define the desired end effector path. (For y rotation.)

%     xs_desired = zeros(1, num_timesteps);
%     ys_desired = -(radius_y * sin(pi*ts));
%     zs_desired = -(-horizontal_shift_y + radius_y * cos(pi*ts));
% 
%     % Eliminate desired path points to reduce from half circle to +/- degrees/
%     % side
%     cut_half = round((158/180) * length(xs_desired)/2);
%     xs_desired = xs_desired(cut_half:(end - cut_half));
%     ys_desired = ys_desired(cut_half:(end - cut_half));
%     zs_desired = zs_desired(cut_half:(end - cut_half));
%     ts = ts(1:length(xs_desired));
%     num_timesteps = length(ts);
% 
%     % Store the desired end effector path into an array.
%     Ps_desired = [xs_desired; ys_desired; zs_desired];
%     dPs_desired = diff(Ps_desired, 1, 2)./diff(ts);
%     ddPs_desired = diff(dPs_desired, 1, 2)./diff(ts(1:end-1));
% 
%     % Compute the desired end effector orientation.
%     Rs_desired = [0 1 0; -1 0 0; 0 0 1];
% 
%     % Initialize a high order matrix to store the desired end effect trajectory.
%     Ts_desired = zeros(4, 4, 1, 1, num_timesteps);
% 
%     % Compute the desired end effector trajectory at each time step.
%     for k = 1:num_timesteps                 % Iterate through each time step...
% 
%         % Generate the desired end effector trajectory.
%         Ts_desired(:, :, 1, 1, k) = RpToTrans(Rs_desired, Ps_desired(:, k));
% 
%     end

    % State that we are done generating a desired trajectory.
    fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY FOR Y ROTATION... Please wait.\n\n')
    
    % Define the number of joint angles.
    num_timesteps = length(ts);
    
    % Define the desired joint angles.
    thetas_desired = (pi/180)*[ -90*ones( 1, num_timesteps ); linspace( -11, 11, num_timesteps ); 30*ones( 1, num_timesteps ); -10.21*ones( 1, num_timesteps ) ];
    
    % Compute the desired end effector configuration trajectory.
    Ts_desired = ForwardKinematics( Mend, Jend, Ss, thetas_desired );
    
    % Compute the desired end effector position trajectory.
    [ ~, Ps_desired ] = TransToRpAllBodies(Ts_desired);
    
    % Remove extra desired end effector positions.
    Ps_desired = squeeze(Ps_desired);
    dPs_desired = diff(Ps_desired, 1, 2)./diff(ts);
    ddPs_desired = diff(dPs_desired, 1, 2)./diff(ts(1:end-1));
    
    % State that we are done generating a desired trajectory.
    fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY FOR Y ROTATION... Done.\n\n')
    
end
%% Generate Desired End Effector Trajectory.
if tf == 0
    % State that we are generating a desired trajectory.
    fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY FOR Z ROTATION... Please Wait...\n')

    %Define the swing end effector path
    xs_swing = step_length*cos((pi/(1-stance_duty))*ts_swing) + horizontal_shift;
    ys_swing = step_height*sin((pi/(1-stance_duty))*ts_swing) - ground_height;
    zs_swing = ones(1, ns_swing) * 0.05008;

    % Define the stance end effector path.
    xs_stance = linspace(xs_swing(end), xs_swing(1), ns_stance);
    ys_stance = -ground_height*ones(1, ns_stance);
    zs_stance = ones(1, ns_stance) * 0.05008;


    %{
    % Define the desired end effector path. (Use for circular swing and stance.)
    xs_desired = step_length*cos(2*pi*ts) + horizontal_shift;
    ys_desired = step_height*sin(2*pi*ts) - ground_height + vertical_shift;
    zs_desired = 0.05008 + zeros(1, num_timesteps);
    %}
    
    % Define the desired end effector path.
    xs_desired = [xs_swing, xs_stance];
    ys_desired = [ys_swing, ys_stance];
    zs_desired = [zs_swing, zs_stance];
    
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
    fprintf('GENERATING DESIRED END EFFECTOR TRAJECTORY FOR Z ROTATION... Done.\n\n')
end

%% DEBUGGING: PLOTTING ROBOT CONFIGURATION

% Create a figure to store the debugging plot.
figure('Color', 'w', 'WindowStyle', 'normal'), hold on, grid on, axis equal, rotate3d on, xlabel('x'), ylabel('y'), zlabel('z'), title('Left Hind Limb Pose')

% Plot the home position of the centers of mass of each link.
plot3( Phome_cms(1, :), Phome_cms(2, :), Phome_cms(3, :), '.c', 'Markersize', 20 )

% Plot the home position of the links bodies.
plot3( Phome_bodies(1, :, 1), Phome_bodies(2, :, 1), Phome_bodies(3, :, 1), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_bodies(1, :, 2), Phome_bodies(2, :, 2), Phome_bodies(3, :, 2), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_bodies(1, :, 3), Phome_bodies(2, :, 3), Phome_bodies(3, :, 3), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_bodies(1, :, 4), Phome_bodies(2, :, 4), Phome_bodies(3, :, 4), '.-k', 'Linewidth', 2, 'Markersize', 20 )

% Plot the home position of the muscles attachment points.
plot3( Phome_muscles(1, :, 1), Phome_muscles(2, :, 1), Phome_muscles(3, :, 1), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 2), Phome_muscles(2, :, 2), Phome_muscles(3, :, 2), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 3), Phome_muscles(2, :, 3), Phome_muscles(3, :, 3), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 4), Phome_muscles(2, :, 4), Phome_muscles(3, :, 4), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 5), Phome_muscles(2, :, 5), Phome_muscles(3, :, 5), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 6), Phome_muscles(2, :, 6), Phome_muscles(3, :, 6), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 7), Phome_muscles(2, :, 7), Phome_muscles(3, :, 7), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 8), Phome_muscles(2, :, 8), Phome_muscles(3, :, 8), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 9), Phome_muscles(2, :, 9), Phome_muscles(3, :, 9), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 10), Phome_muscles(2, :, 10), Phome_muscles(3, :, 10), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Phome_muscles(1, :, 11), Phome_muscles(2, :, 11), Phome_muscles(3, :, 11), '.-b', 'Linewidth', 2, 'Markersize', 20 )

% Plot the home position of the joints.
plot3( Phome_joints(1, :), Phome_joints(2, :), Phome_joints(3, :), '.r', 'MarkerSize', 20 )




% Plot the home position of the end effector.
plot3(Phome_end(1), Phome_end(2), Phome_end(3), '.m', 'MarkerSize', 20)

% Define a new desired pose for the left hind limb.
thetas_desired = (pi/180)*[-90; 0; 45; -45];
% thetas_desired = (pi/180)*[-90; 0; 30; -10.21];
% thetas_desired = (pi/180)*[-90; -15; 30; -10.21];

% Retrieve the transformation matrices associated with the given angles.
Tbodies_desired = ForwardKinematics( Mbodies, Jbodies, Ss, thetas_desired );
Tcms_desired = ForwardKinematics( Mcms, Jcms, Ss, thetas_desired );
Tjoints_desired = ForwardKinematics( Mjoints, Jjoints, Ss, thetas_desired );
Tmuscles_desired = ForwardKinematics( Mmuscles, Jmuscles, Ss, thetas_desired );
Tend_desired = ForwardKinematics( Mend, Jend, Ss, thetas_desired );

% Retrieve the rotational and translational components associated with the given transformation matrices.
[~, Pbodies_desired] = TransToRpAllBodies(Tbodies_desired);
[~, Pcms_desired] = TransToRpAllBodies(Tcms_desired);
[~, Pjoints_desired] = TransToRpAllBodies(Tjoints_desired);
[~, Pmuscles_desired] = TransToRpAllBodies(Tmuscles_desired);
[~, Pend_desired] = TransToRpAllBodies(Tend_desired);




% Process the center of mass and joint positions for plotting.
Pcms_desired = squeeze(Pcms_desired);
Pjoints_desired = squeeze(Pjoints_desired);

% Compute the inverse kinematics solution for this end effector location.
eomg = 1e-3; ev = 1e-3;
[ thetas_achieved, successes ] = InverseKinematics( Ss, Mend, Tend_desired, thetas_desired, eomg, ev );

% Plot the new position of the centers of mass of each link.
plot3( Pcms_desired(1, :), Pcms_desired(2, :), Pcms_desired(3, :), '.c', 'Markersize', 20 )

% Plot the new position of the links bodies.
plot3( Pbodies_desired(1, :, 1), Pbodies_desired(2, :, 1), Pbodies_desired(3, :, 1), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pbodies_desired(1, :, 2), Pbodies_desired(2, :, 2), Pbodies_desired(3, :, 2), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pbodies_desired(1, :, 3), Pbodies_desired(2, :, 3), Pbodies_desired(3, :, 3), '.-k', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pbodies_desired(1, :, 4), Pbodies_desired(2, :, 4), Pbodies_desired(3, :, 4), '.-k', 'Linewidth', 2, 'Markersize', 20 )

% Plot the new position of the muscles attachment points.
plot3( Pmuscles_desired(1, :, 1), Pmuscles_desired(2, :, 1), Pmuscles_desired(3, :, 1), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 2), Pmuscles_desired(2, :, 2), Pmuscles_desired(3, :, 2), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 3), Pmuscles_desired(2, :, 3), Pmuscles_desired(3, :, 3), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 4), Pmuscles_desired(2, :, 4), Pmuscles_desired(3, :, 4), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 5), Pmuscles_desired(2, :, 5), Pmuscles_desired(3, :, 5), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 6), Pmuscles_desired(2, :, 6), Pmuscles_desired(3, :, 6), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 7), Pmuscles_desired(2, :, 7), Pmuscles_desired(3, :, 7), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 8), Pmuscles_desired(2, :, 8), Pmuscles_desired(3, :, 8), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 9), Pmuscles_desired(2, :, 9), Pmuscles_desired(3, :, 9), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 10), Pmuscles_desired(2, :, 10), Pmuscles_desired(3, :, 10), '.-b', 'Linewidth', 2, 'Markersize', 20 )
plot3( Pmuscles_desired(1, :, 11), Pmuscles_desired(2, :, 11), Pmuscles_desired(3, :, 11), '.-b', 'Linewidth', 2, 'Markersize', 20 )

% Plot the new position of the joints.
plot3( Pjoints_desired(1, :), Pjoints_desired(2, :), Pjoints_desired(3, :), '.r', 'MarkerSize', 20 )

% Plot the new position of the end effector.
plot3( Pend_desired(1), Pend_desired(2), Pend_desired(3), '.m', 'MarkerSize', 20 )

% Plot the desired end effector trajectory.
plot3( Ps_desired(1, :), Ps_desired(2, :), Ps_desired(3, :), '-', 'Linewidth', 3 )


%% Compute the Joint Angles That Achieve the Desired Trajectory for z rotation.
if tf == 0
    % State that we are computing the inverse kinematics solution to achieve the desired trajectory.
    fprintf('COMPUTING INVERSE KINEMATICS SOLUTION (i.e., Desired Joint Angles)... Please Wait...\n')

    % Define the inverse kinematics error parameters.
    eomg = 1e-6; ev = 1e-6;

    % Define the starting joint angle values for the inverse kinematics algorithm.
%     theta_guess = (pi/180)*[-90; 0; 0; 0];

    theta_guess = (pi/180)*[-90; 0; 45; -45];

    % Compute the joint angles associated with the desired trajectory.
    [thetas_desired, successes] = InverseKinematics(Ss, Mend, Ts_desired, theta_guess, eomg, ev);


    % Compute the joint velocities associated with the desired trajectory.
    dthetas_desired = diff(thetas_desired, 1, 2)./repmat(diff(ts), [num_joints 1]);
    dthetas_desired = [dthetas_desired dthetas_desired(:, end)];

    % Compute the joint acceleration associated with the desired trajectory.
    ddthetas_desired = diff(dthetas_desired, 1, 2)./repmat(diff(ts(1:end)), [num_joints 1]);
    ddthetas_desired = [ddthetas_desired ddthetas_desired(:, end)];

    % State that we are done computing the inverse kinematics solution to achieve the desired trajectory.
    fprintf('COMPUTING INVERSE KINEMATICS SOLUTION FOR Z ROTATION(i.e., Desired Joint Angles)... Done.\n\n')
end


%% Compute the Joint Angles That Achieve the Desired Trajectory for y rotation.
if tf == 1
    % State that we are computing the inverse kinematics solution to achieve the desired trajectory.
    fprintf('COMPUTING INVERSE KINEMATICS SOLUTION FOR Y ROTATION (i.e., Desired Joint Angles)... Please Wait...\n')

    % Define the inverse kinematics error parameters.
    eomg = 1e-6; ev = 1e-6;

    % Define the starting joint angle values for the inverse kinematics algorithm.
    theta_guess = (pi/180)*[-90; -15; 30; -10.21];

    % Compute the joint angles associated with the desired trajectory.
  [thetas_desired, successes] = InverseKinematics(Ss, Mend, Ts_desired, theta_guess, eomg, ev);
    % Assign thetas_desired directly
%     thetas_desired = zeros(4, length(ts));
%     thetas_desired(1, :) = -90;
%     thetas_desired(2, :) = linspace(-10, 10, length(ts));

    % Compute the joint velocities associated with the desired trajectory.
    dthetas_desired = diff(thetas_desired, 1, 2)./repmat(diff(ts), [num_joints 1]);
    dthetas_desired = [dthetas_desired dthetas_desired(:, end)];

    % Compute the joint acceleration associated with the desired trajectory.
    ddthetas_desired = diff(dthetas_desired, 1, 2)./repmat(diff(ts(1:end)), [num_joints 1]);
    ddthetas_desired = [ddthetas_desired ddthetas_desired(:, end)];

    % State that we are done computing the inverse kinematics solution to achieve the desired trajectory.
    fprintf('COMPUTING INVERSE KINEMATICS SOLUTION FOR Y ROTATION(i.e., Desired Joint Angles)... Done.\n\n')
end
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

%% DEBUGGING: PLOTTING

figure('Color', 'w'), hold on, grid on, rotate3d on, xlabel('x'), ylabel('y'), zlabel('z'), title('Muscle Lengths')

plot( ts, Lmuscles_desired, '-', 'Linewidth', 3 )

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

Ftipmat = zeros(num_timesteps, 6);

% Configure the relevant home matrices to have the shape required by the inverse dynamics function.  Note that the inverse dynamics function requires relative home matrices.
Mlist = cat(4, Mcms(:, :, 1, 1), reshape(TSpace2TRelative(reshape(cat(4, Mcms, Mend), [4, 4, num_joints + 1, 1])), [4, 4, 1, num_joints]));

% Compute the joint torques necessary to achieve the desired trajectory.
taus_desired = InverseDynamicsTrajectory(thetas_desired', dthetas_desired', ddthetas_desired', g, Ftipmat, Mlist, Gs, Ss)';

% State that we are done computing the inverse dynamics solution.
fprintf('COMPUTING INVERSE DYNAMICS SOLUTION (i.e., Requied Joint Torques)... Done.\n\n')


%% DEBUGGING: PLOTTING JOINT TORQUES

figure('Color', 'w'), hold on, grid on, rotate3d on, xlabel('x'), ylabel('y'), zlabel('z'), title('Joint Torques')

plot( ts, taus_desired, '-', 'Linewidth', 3 )


%% Compute the Total Muscle Forces Required to Achieve the Desired Trajectory.

% Define the minimum allowable total muscle force.
Fmuscles_total_lowbnd = zeros(num_muscles, 1);
% Fmuscles_total_lowbnd = 25*ones(num_muscles, 1);

% Compute the total muscle force required to achieved the desired trajectory.
Fmuscles_total_desired = JointTorques2TotalMuscleForcesCombined( taus_desired, Pmuscles_desired, Pjoints_desired, muscle_joint_orientations, Fmuscles_total_lowbnd );

% Compute the rate of change of total muscle force with respect to time.
dFmuscles_total_desired = Force2Yank( Fmuscles_total_desired, ts );


%% DEBUGGING: PLOTTING TOTAL MUSCLE FORCES

figure('Color', 'w'), hold on, grid on, rotate3d on, xlabel('x'), ylabel('y'), zlabel('z'), title('Muscle Forces')

% plot( ts, Fmuscles_total_desired, '-', 'Linewidth', 3 )

plot( ts, Fmuscles_total_desired(1, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(2, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(3, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(4, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(5, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(6, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(7, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(8, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(9, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(10, :), '-', 'Linewidth', 3 )
plot( ts, Fmuscles_total_desired(11, :), '-', 'Linewidth', 3 )


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
thetas_achieved = thetas_achieved'; dthetas_achieved = dthetas_achieved';

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
muscle_var_names_desired_metric = {'Min_Length_m', 'Max_Length_m', 'Length_Range_m', 'Muscle_Width_m', 'Resting_Length_m_', 'Min_Velocity_mps', 'Max_Velocity_mps', 'Min_Acceleration_mps2', 'Max_Acceleration_mps2', 'Min_Force_N', 'Max_Force_N'};
muscle_var_names_desired_imperial = {'Min_Length_in', 'Max_Length_in', 'Length_Range_in', 'Muscle_Width_in', 'Resting_Length_in', 'Min_Velocity_inps', 'Max_Velocity_inps', 'Min_Acceleration_inps2', 'Max_Acceleration_inps2', 'Min_Force_lb', 'Max_Force_lb'};
muscle_var_names_achieved_metric = {'Min_Length_m', 'Max_Length_m', 'Length_Range_m', 'Muscle_Width_m', 'Resting_Length_m', 'Min_Velocity_mps', 'Max_Velocity_mps', 'Min_Acceleration_mps2', 'Max_Acceleration_mps2'};
muscle_var_names_achieved_imperial = {'Min_Length_in', 'Max_Length_in', 'Length_Range_in', 'Muscle_Width_in', 'Resting_Length_in', 'Min_Velocity_inps', 'Max_Velocity_inps', 'Min_Acceleration_inps2', 'Max_Acceleration_inps2'};


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
ext_colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.929 0.694 0.125; 0.4940 0.1840 0.5560];

% Define the flexor colors.
flx_colors = min(1.50*ext_colors, 1);

% Define the Bi-articular Colors
bi_colors = min(1.25*ext_colors,1);

% Define an array of colors to use on the plot.
% line_colors = cat(3, ext_colors, flx_colors);
line_colors = cat(3, ext_colors, flx_colors, bi_colors);

% Create a figure to store the muscle length vs time.
fig_musclelengths = figure('Color', 'w', 'Name', 'Muscle Lengths vs Time');
subplot(3, 2, 1), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Lengths [m]'), title('Muscle Length vs Time (Metric)')
subplot(3, 2, 2), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Lengths [in]'), title('Muscle Length vs Time (Imperial)')
subplot(3, 2, 3), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Velocity [m/s]'), title('Muscle Velocity vs Time (Metric)')
subplot(3, 2, 4), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Velocity [in/s]'), title('Muscle Velocity vs Time (Imperial)')
subplot(3, 2, 5), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Acceleration [m/s^2]'), title('Muscle Acceleration vs Time (Metric)')
subplot(3, 2, 6), hold on, grid on, xlabel('Time [s]'), ylabel('Muscle Acceleration [in/s^2]'), title('Muscle Acceleration vs Time (Imperial)')

% Initialize a cell array to store the legend entries.

if tf == 1
   num_muscles = 11;
   num_joints = 4;
   musc_types = 3;
else
    num_joints = 3;
    num_muscles = 9;
    musc_types = 3;
end
legstr = cell(2*num_muscles, 1);

% Define a legend entry counter variable.
legend_counter = 0;

% Initialize a muscle counter variable.
muscle_counter = 0;



% Plot each of the muscle lengths over time.
for k1 = 1:num_joints                   % Iterate through each joint...
    for k2 = 1:musc_types         % Iterate through each muscle type...
        
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
    muscle_counter;
    
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
line_colors = [0 0.447 0.741; 0.850 0.325 0.098; 0.929 0.694 0.125; 0.4940 0.1840 0.5560];

% Define an array of line styles to use.
line_styles = {'-', '--','.-'};

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
    for k2 = 1:3         % Iterate through each muscle type...
        
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

%% Calculate the highest force and find the change in length at that point
% thetas_desired = (pi/180)*[-90; 0; 45; -45];
for k1 = 1:length(muscle_names)
    
    [a,i] = max(Fmuscles_total_achieved(k1,:));
%     where(k1,:,:) = [a,i];
%     dlength = Lmuscles_rest_achieved(k1) - Lmuscles_achieved(k1,i);
%     dlength = dLmuscles_achieved(k1,i);    

        % Compute the distance between the muscle attachment points for this muscle at this time step.
%         dPmuscles_achieved = diff(Pmuscles_achieved(:, :, k1, i), 1, 2);
        
        % Compute the length of this muscle at this time step.
%         Lmuscles = sum(vecnorm(dPmuscles_achieved, 2, 1))
        
        dPmuscles_initial =  diff(Pmuscles_desired(:, :, k1, 1), 1, 2);
        Lmuscle_initial(k1,:) = sum(vecnorm(dPmuscles_initial, 2, 1));
        
        % Compute the distance between the muscle attachment points for this muscle at this time step.
        dPmuscles_achieved = diff(Pmuscles_achieved(:, :, k1, i), 1, 2);
        
        % Compute the length of this muscle at this time step.
        Lmuscles(k1, :) = sum(vecnorm(dPmuscles_achieved, 2, 1));
        
        
        
        dMuscleLength = Lmuscles(k1,:) - Lmuscle_initial(k1,:);

        
    
end
    columns = [Lmuscles-Lmuscle_initial]; 

%% Animate the Open Kinematic Chain.

% Create a figure to store the animation.
fig_animation = figure('Color', 'w', 'Name', 'Robot Animation','units','normalized','outerposition',[0 0 1 1]); hold on, rotate3d on, view(0, 90), xlabel('x'), ylabel('y'), zlabel('z')
axis([-Ltotal Ltotal -Ltotal Ltotal -Ltotal Ltotal])                                      
axis equal
xlim([-0.6 0.6])
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

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
legend(legstr, 'Location', 'Eastoutside', 'Orientation', 'Vertical');

% Set the number of animation playbacks.
num_playbacks = 3;

% % Initialize a video object.
myVideo = VideoWriter('RobotAnimationCombined'); %open video file
myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me

open(myVideo)


% Animate the figure.
for j = 1:num_playbacks                     % Iterate through each play back...    
    for k = 1:10:num_timesteps              % Iterate through each of the angles...
        
        % Refresh the plot data.
        refreshdata([bodies_achieved_plt; bodies_desired_plt; muscles_desired_plt; muscles_achieved_plt; cm_desired_plt; cm_achieved_plt; cm_cumulative_desired_plt; cm_cumulative_achieved_plt; joint_desired_plt; joint_achieved_plt; endeffector_desired_plt; endeffector_achieved_plt; endpath_desired_plt; endpath_achieved_plt], 'caller')
        
        % Update the plot.
        drawnow
        
        % Write the current frame to the file.
         writeVideo(myVideo, getframe(gcf));

    end
end

% % Close the video object.
close(myVideo)


