function [ Motor_Position ] = Rad2MotorPos( theta )

%This function converts joint angles in the space frame to motor positions (i.e. 0-1023, 0-4096).

%Define the motor orientations with respect to the home position.
theta_offset = pi*ones(size(theta, 1), 1);

%Create an array of ones with alternating signs.
theta_sign = ones(size(theta, 1), 1);
theta_sign(1:2:end) = -theta_sign(1:2:end);

%Convert the theta values to the motor coordinates.
theta = theta.*theta_sign + theta_offset;

%Map all angles to be in [0, 2*pi).
theta = mod(theta, 2*pi);

%Preallocate the motor and theta domain variable.
[theta_Domain, Motor_Domain] = deal( zeros(size(theta, 1), 2) );

%Define the motor position domain and theta domain for the first two large motors.
[theta_Domain(1:2, 1:2), Motor_Domain(1:2, 1:2)] = deal( [[0 2*pi]; [0 2*pi]], [[0 4096]; [0 4096]] );

%Define the motor position domain and the theta domain for the rest of the small motors.  Here we assume that all other motors are small motors.
for k = 1:(size(theta, 1) - 2)
    [theta_Domain(k+2, :), Motor_Domain(k+2, :)] = deal( [pi/6, (11*pi)/6], [0 1023] );                %Set the small motor domain.
end

%Preallocate a variable to store the motor positions.
Motor_Position = zeros(size(theta, 1), size(theta, 2));

%Iterate through each set of angle and motor position domains.
for k = 1:size(theta, 1)                                            %Iterate through the joint angles for each motor...
    
    %Check whether all of the angles are in the acceptable domain.
    if sum((theta(k, :) < theta_Domain(k, 1)) | (theta(k, :) > theta_Domain(k, 2))) > 0                     %If there are angles outside of the feasible domain.
        %Throw a warning that some of the angles appear to be out of bounds.
        warning('Some angles may be outside of the feasible motor angle range [30, 330] degrees. Collision may occur.')
    end
        
    %Convert the angles into motor positions.
    Motor_Position(k, :) = round(interp1(theta_Domain(k, :), Motor_Domain(k, :), theta(k, :)));
end

%Account for the first motor being off center.
% Motor_Position(1, :) = mod(Motor_Position(1, :) - 298, 4096);
% % Motor_Position(2, :) = mod(Motor_Position(2, :) + 135, 4096);
% Motor_Position(3, :) = mod(Motor_Position(3, :) + 2.5, 1023);
% Motor_Position(4, :) = mod(Motor_Position(4, :) - 2.5, 1023);

%Switch the x-axis direction.
Motor_Position(3:4, :) = interp1( [0 1023], [1023 0], Motor_Position(3:4, :) );             %Commenting out this line causes the x-axis to be inverted.

end
