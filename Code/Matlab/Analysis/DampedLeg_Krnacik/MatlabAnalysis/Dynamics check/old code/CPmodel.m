%% CoppeliaSim rat leg oscillation measurements

clear, close('all'), clc

%% %% Initiate connection
disp('Program started');
sim=remApi('remoteApi'); % using the prototype file (remoteApiProto.m)
sim.simxFinish(-1); % just in case, close all opened connections
clientID=sim.simxStart('127.0.0.1',19997,true,true,5000,5);  %Start up Matlab's connection with BlueZero

% Get the handle aka internal 'object number' of the joint we wish to control. 
[~,joint_handle_1]=sim.simxGetObjectHandle(clientID,'Hip',sim.simx_opmode_blocking);
[~,joint_handle_2]=sim.simxGetObjectHandle(clientID,'Knee',sim.simx_opmode_blocking);
[~,joint_handle_3]=sim.simxGetObjectHandle(clientID,'Ankle',sim.simx_opmode_blocking);

joint_handle = [joint_handle_1 joint_handle_2 joint_handle_3];

%%
% Read in joint positions
for ii = 1:1000
    
current_angles = zeros(3,1);
res = zeros(3,1);
angles = zeros(3,1);
current_time = zeros(3,1);

% Loop through three joint angle positions and times
for n = 1:3
    [res(n),current_angles(n)] = sim.simxGetJointPosition(clientID,joint_handle(n),sim.simx_opmode_blocking);

end

% Update time and angle arrays
%time = [time; current_time];
angles = [angles; current_angles];

end
