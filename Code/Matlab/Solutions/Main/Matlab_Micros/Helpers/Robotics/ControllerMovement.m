function [ thetac, thetas_user ] = ControllerMovement( S, M, thetac, thetas_user, s, MotorIDs, xbox_controller, dtol, move_speed, move_size, move_sensitivity, move_threshold, eomg, ev, bPlotMotorGraphs )

%This function interprets xbox controller axis inputs, generates the desired trajectory associated with these inputs, and then moves the end effector to the desired location.

%Determine whether to move based on controller inputs.
if (abs(axis(xbox_controller, 1)) > move_threshold) || (abs(axis(xbox_controller, 2)) > move_threshold) || (abs(axis(xbox_controller, 3)) > move_threshold) || (abs(axis(xbox_controller, 4)) > move_threshold) || (abs(axis(xbox_controller, 5)) > move_threshold) || button(xbox_controller, 5) || button(xbox_controller, 6)         %If any axis value is greater in magnitude than the movement tolerance...
    
    %Write the current xbox controller axis data to the command window.
    fprintf('\nXbox Controller Axes Data: '), disp(read(xbox_controller));
    
    %Compute the motor angles that achieve the current xbox controller data.
    [ theta_cont, mpos_cont ] = GetControllerMotorAngles( S, M, thetac, xbox_controller, dtol, move_size, move_sensitivity, eomg, ev  );
    
    %Determine whether the motor angles converged.
    if ~isempty(theta_cont)                             %If the solution converged...
        %Add the new user angles to the existing user angles.  This is used for animating the path, if desired.
        thetas_user = cat( 2, thetas_user, theta_cont );
        
        %Send the trajectory to the motors.
        %         [ ~, ~ ] = SetMotorPosition2( s, MotorIDs, mpos_cont, bPlotMotorGraphs );
        SetMotorPosition3( s, MotorIDs, mpos_cont, Rad2MotorPos( thetac ), move_speed, bPlotMotorGraphs );
        
        %Update the current motor angles variable.
        thetac = theta_cont(:, end);
    end
    
end

end

