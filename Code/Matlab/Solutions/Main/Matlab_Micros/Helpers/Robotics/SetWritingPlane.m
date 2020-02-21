function [T_Plane, Pts_Plane, thetac, thetas_user] = SetWritingPlane( S, M, thetac, thetas_user, s, MotorIDs, xbox_controller, dtol, move_speed, move_size, move_sensitivity, move_threshold, eomg, ev, bPlotMotorGraphs )

%Wait for the "y" button to be lifted.
while button(xbox_controller, 4), end           %This is just a safety to make sure that matlab waits for the user to completely lift up on the "y" button before proceeding.  Otherwise Matlab can interpret a slightly held button as being multiple presses.

%Print messages to the user that we are beginning the plane definition procedure.
fprintf('\n\nPLANE DEFINITION\n')
fprintf('Three points are required to define a plane.\n\n')

%Preallocate a vector to store the plane points.
[Pts_Plane, Pen_Vectors] = deal( zeros(3, 3) );

%Retrieve three points to define the plane of interest.
for k = 1:3                 %Iterate three times...
    
    %Wait for the "y" button to be lifted.
    while button(xbox_controller, 4), end
    
    %Prompt the user to confirm the current point.
    fprintf('Point %0.0f: Press "y" to confirm location.\n', k)
    
    %Allow the user to navigate to the point of interest.
    while ~button(xbox_controller, 4)               %While the y button is not pressed...
        
        %Intepret input from the xbox controller and move the end effector approperiately.
        [ thetac, thetas_user ] = ControllerMovement( S, M, thetac, thetas_user, s, MotorIDs, xbox_controller, dtol, move_speed, move_size, move_sensitivity, move_threshold, eomg, ev, bPlotMotorGraphs );
        
    end
    
    %Retrieve the current orientation of the end effector.
    Tc = FKinSpace(M(:, :, end), S, thetac);
    
    %Get the current position & orientation from the current transformation matrix.
    [ R, Pts_Plane(:, k) ] = TransMatrix2Rp( Tc );
    
    %Retrieve the z-direction vector of the pen tip.
    Pen_Vectors(:, k) = R(:, 3);
    
    %Print a message to the user to confirm the point.
    fprintf('Point %0.0f: (%0.2f, %0.2f, %0.2f) [in] Confirmed\n\n', k, Pts_Plane(1, k), Pts_Plane(2, k), Pts_Plane(3, k));
end

%Wait for the y button to be lifted.
while button(xbox_controller, 4), end

%Compute the average z-direction vector of the pen tip.
Pen_Vector = mean(Pen_Vectors, 2); Pen_Vector = Pen_Vector/norm(Pen_Vector);

%Compute the transformation matrix associated with the defined plane.  i.e., the transformation matrix that maps from the template letter space in the xy-plane at the origin to the location of the newly defined plane in space.
T_Plane = GetPlaneTransformationMatrix( Pts_Plane, Pen_Vector );

%State that the plane is defined.
fprintf('Done: Plane Fully Defined.\n\n')

end

