%%
% Read in joint positions
%for ii = 1:1000
    
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

%end