function [ Motor_Angles, Motor_Positions ] = Trajectory2MotorAngles( S, M, T, theta_guess, eomg, ev )

%INPUTS:
%S = Matrix of screw axes where each screw axis is a column of S.
%M = Multidimensional matrix where each layer is the home position of a joint.  Higher layers correspond to more distal joints.
%R = Orientation of End Effector.
%T = Multidimensional matrix where each layer is an orientation along the path to follow.
%eomg = Orientation Error Tolerance.
%ev = Translational Error Tolerance.

%OUPUTS:
%Motor_Angles = A 6xn matrix of motor angles.  Each row corresponds to the angles for one motor.
%Motor_Positions = A 6xn matrix of motor positions.  The same as the above, but having been converted to motor positions.

%Preallocate a vector to store the associated angles.
Motor_Angles = zeros(size(S, 2), size(T, 3));

%Preallocate a vector to store whether the inverse kinematics solution was successful.
bIK_Successes = zeros(1, size(T, 3));

%Set the random noise level.
noise_level = 0.10;

%Define the maximum angle change.
dAngle_tol = 10*pi/180;

%Set the maximum number of guesses to use.
num_guesses_max = 10;

%Itererate through each point in the letter.
for k = 1:size(T, 3)
    
    %     fprintf('Iteration %0.0f\n', k)
    
    %Set a counter to keep track of the number of guesses used for the current position.
    num_guesses = 0;
    
    %Reset the inverse kinematics convergence boolean.
    bIK_Success = 0;
    
    %Reset the large angle change boolean.
    bSmallAngleChange = 0;
        
    %Run the inverse kinematics problem until we find a solution that is convergent and does not cause too large of an angle change.
    while (~bIK_Success || ~bSmallAngleChange) && (num_guesses < num_guesses_max)
        
        %Advance the guess counter.
        num_guesses = num_guesses + 1;
        
        %         disp(theta_guess)
        
        %Solve the inverse kinematics problem.
        [Motor_Angle, bIK_Success] = IKinSpace(S, M(:, :, end), T(:, :, k), theta_guess, eomg, ev);         %THIS FUNCTION IS PROVIDED WITH THE TEXTBOOK.
        
        %Determine whether the angle change is too large.
        if k == 1                           %If this is the first iteration...
            bSmallAngleChange = 1;          %Accept any convergent solution...
        else
            %Compute the componentwise angle change.
            dAngle = abs(mod(Motor_Angle, 2*pi) - mod(Motor_Angles(:, k - 1), 2*pi));
            
            %Determine whether this angle change is too large.
            if sum((dAngle > dAngle_tol) & (dAngle < 2*pi - dAngle_tol)) > 0                  %If any of the joint angles change more than the maximum tolerance...
                bSmallAngleChange = 1;                       %Do not accept the result...       WHEN THIS IS SET TO 0, THE RESULT WILL BE REJECTED IF THE ANGLE CHANGE IS TOO LARGE.  WHEN THIS IS SET TO 1, THE RESULT WILL NOT BE REJECTED, EVEN IF THE ANGLE CHANGE IS TOO LARGE.
                %                 fprintf('Position %0.0f Angle change too large.\n', k)
            else
                bSmallAngleChange = 1;                       %Otherwise, accept a convergent result.
            end
            
        end
        
        if ~bIK_Success
            fprintf('Position #%0.0f, Guess #%0.0f: Result not convergent.\n', k, num_guesses)
        end
        
        %Update the angle guess in a random way.
        theta_guess = mod(theta_guess + 2*pi*noise_level*(-1 + 2*rand(size(theta_guess, 1), 1)), 2*pi);
        
    end
    
    
    %If the current position did not converge after the maximum number of allotted guesses, truncate the outputs and break the loop.
    if (num_guesses >= num_guesses_max)                 %If the current position did not converge after the maximum number of allotted guesses...
    
        %Truncate the output to only include the solutions that have convergered.
%         [Motor_Angles(:, k:end), bIK_Successes(k:end)] = deal( [] );
        [Motor_Angles, bIK_Successes] = deal( Motor_Angles(:, 1:(k - 1)), bIK_Successes(1:(k - 1)) );
        
        %Throw a warning that the solution did not converge.
        warning('Inverse kinematics did not converge.  Target position may be out of bounds.')
        
        %Discontinue the for loop so that we can proceed with the succesfully converged results.
        break
    end
    
    %Record whether the inverse kinematics was successful (it should always be successful).
    bIK_Successes(k) = bIK_Success;
    
    %Record the final motor angle.
    Motor_Angles(:, k) = Motor_Angle;
    
    %Update the guess angle.
    theta_guess = mod(Motor_Angles(:, k), 2*pi);
    
end

%Ensure that the motor angles are positive and within the interval [0, 2*pi);
Motor_Angles = mod(Motor_Angles, 2*pi);

%Convert the motor angles to motor positions.
Motor_Positions  = Rad2MotorPos( Motor_Angles );

%Throw a warning if at least one inverse kinematic solutions did not converge.
if sum(~bIK_Successes) > 0
    warning('At least one orientation did not fully converge.')
end

end

