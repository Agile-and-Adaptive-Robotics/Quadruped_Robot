function [ theta ] = MotorPos2Rad( Motor_Position )

%This function converts motor positions to joint angles.

% %Define the angle domain for each motor.
% theta_Domain = [pi/6*ones(size(Motor_Position, 1), 1) ((11*pi)/6)*ones(size(Motor_Position, 1), 1)];
% 
% %Preallocate the motor domain variable.
% Motor_Domain = zeros(size(Motor_Position, 1), 2);
% 
% %Define the motor position domain for the first two large motors.
% Motor_Domain(1:2, 1:2) = [[0 4096]; [0 4096]];
% 
% %define the motor position domain for the rest of the small motors.  Here we assume that all other motors are small motors.
% for k = 1:(size(Motor_Position, 1) - 2)
%     Motor_Domain(k+2, :) = [0 1023];                %Set the small motor domain.
% end

%Account for the first motor being off center.
Motor_Position(1, :) = mod(Motor_Position(1, :) - 298, 4096);

Motor_Position(3, :) = mod(Motor_Position(3, :) - 2.5, 1023);
Motor_Position(4, :) = mod(Motor_Position(4, :) + 2.5, 1023);

%Preallocate the motor and theta domain variable.
[theta_Domain, Motor_Domain] = deal( zeros(size(Motor_Position, 1), 2) );

%Define the motor position domain and theta domain for the first two large motors.
[theta_Domain(1:2, 1:2), Motor_Domain(1:2, 1:2)] = deal( [[0 2*pi]; [0 2*pi]], [[0 4096]; [0 4096]] );

%Define the motor position domain and the theta domain for the rest of the small motors.  Here we assume that all other motors are small motors.
for k = 1:(size(Motor_Position, 1) - 2)
    [theta_Domain(k+2, :), Motor_Domain(k+2, :)] = deal( [pi/6, (11*pi)/6], [0 1023] );                %Set the small motor domain.
end

%Preallocate a variable to store the motor positions.
theta = zeros(size(Motor_Position, 1), size(Motor_Position, 2));

%Iterate through each set of angle and motor position domains.
for k = 1:size(Motor_Position, 1)                                            %Iterate through the joint angles for each motor...
    %Convert the angles into motor positions.
    theta(k, :) = interp1(Motor_Domain(k, :), theta_Domain(k, :), Motor_Position(k, :));
end

%Define the motor orientations with respect to the home position.
theta_offset = pi*ones(size(theta, 1), 1);

%Create an array of ones with alternating signs.
theta_sign = ones(size(theta, 1), 1);
theta_sign(1:2:end) = -theta_sign(1:2:end);

%Convert the theta values to the motor coordinates.
theta = theta_sign.*(theta - theta_offset);

%Map all angles to be in [0, 2*pi).
theta = mod(theta, 2*pi);

end

