%% ME 557: Project, Control Robot.

%This script is the central script that continuously runs, checking for user input via the xbox controller and sending the appropriate signals to the arduino.

%SETWRITEPLANE: DO NOT ALLOW USER TO SUPPLY DUPLICATE POINTS.
%SETWRITEPLANE: ALLOW USER TO BREAK OUT OF PLANE DEFINITION PROCEDURE.
%CONTROLLERMOVEMENT: ALLOW D-PAD MOTIONS TO CREATE MOTIONS IN THE PLANE.
%CONTROLLERMOVEMENT: ALLOW BUMPERS TO MOVE PERPENDICULAR TO THE PLANE.
%CONTROLLERMOVEMENT: ALLOW GRIPPER TO OPEN AND CLOSE WITH B-BUTTON.

%Increase the scaling factor to write as large of letters as possible that are within the workspace.
%If clarity is still not satisfactory, increase the middle length link and continue to increase the scaling factor until clarity is satisfactory.

%Clear Everything
clear, close('all'), clc

%% Open Serial Port.

%Open the serial port.
s = OpenSerialPort( 'COM4', 115200 );

%% Define the Geometry of the Robot.

% %VERTICAL HOME POSITION DESIGN - ALTERNATING MOTOR AXES, COUPLED
% %Define the link lengths of the robot.
% rs = [1 + 7/16, 11 + 7/16, 2 + 7/16, 4 + 3/16, 3 + 1/8, 0, 4 + 3/4];
rs = [1 + 7/16, 11 + 7/16, 2 + 7/16, 7 + 1/4, 3 + 1/8, 0, 4 + 3/4];

%Define the home orientation of each joint.  To compute the appropriate joint angles, we only need the home orientation of the end effector.  However, in order to plot the movement of all of the joints, we need all home orientations.
M1 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1); 0 0 0 1];
M2 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1) + rs(2); 0 0 0 1];
M3 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1) + rs(2) + rs(3); 0 0 0 1];
M4 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1) + rs(2) + rs(3) + rs(4); 0 0 0 1];
M5 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1) + rs(2) + rs(3) + rs(4) + rs(5); 0 0 0 1];
M6 = [1 0 0 0; 0 1 0 0; 0 0 1 rs(1) + rs(2) + rs(3) + rs(4) + rs(5) + rs(6); 0 0 0 1];
M7 = [1 0 0 0; 0 1 0 -(1 + 5/8); 0 0 1 rs(1) + rs(2) + rs(3) + rs(4) + rs(5) + rs(6) + rs(7); 0 0 0 1];

% %Store the joint orientations in a multidimensional matrix.  Each layer corresponds to one of the joint home positions.
M = cat(3, M1, M2, M3, M4, M5, M6, M7);

%Define the screw axes.
S1 = [1 0 0 0 rs(1) 0]';
S2 = [1 0 0 0 rs(1) + rs(2) 0]';
S3 = [0 1 0 -(rs(1) + rs(2) + rs(3)) 0 0]';
S4 = [0 1 0 -(rs(1) + rs(2) + rs(3) + rs(4)) 0 0]';
S5 = [1 0 0 0 (rs(1) + rs(2) + rs(3) + rs(4) + rs(5)) 0]';
S6 = [1 0 0 0 (rs(1) + rs(2) + rs(3) + rs(4) + rs(5) + rs(6)) 0]';

%Store the screw axes in a matrix.  Each column of S is a screw axis for a different joint.
S = [S1 S2 S3 S4 S5];

%% Setup for the while loop.

%Set the default letter.
% Ltr = 'ABCDE';
% Ltr = 'FGHIJ';
Ltr = 'ACDGH';

%Define the array of possible letters.
Ltrs = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'};

%Setup the xbox controller.
xbox_controller = vrjoystick(1);                        %IF THE XBOX CONTROLLER IS NOT HOOKED UP TO THE COMPUTER, THIS WILL CAUSE AN ERROR.

%Define the Motor ID numbers.
MotorIDs = (1:5)';

%Define the rotational and translational tolerances to use for the Newton-Raphson approximation of the inverse kinematics.
[eomg, ev] = deal( 1, 1e-2 );

%Define the maximum displacement in a single step.
[dtol_ltr, dtol_travel] = deal( 1, 0.75 );         %Works okay in regular mode.
% [dtol_ltr, dtol_travel] = deal( 1/8, 1 );         %Works okay in regular mode.

%Set the making plots option to false.  Some functions make a lot of different plots for reference and debugging, however it isn't always useful to have many plots appearing.
bMakePlots = false;

%Set whether to animate the letter trajectory.
bAnimateLetterTrajectory = true;

%Set whether to create the motor plots.
bPlotMotorGraphs = false;

%Set the gripper to be closed by default.
bGripperClosed = true;

%Define the movement tolerance.
move_threshold = 0.25;                            %Defines the threshold at which xbox controller axis data will be interpreted as being an intentional movement (and not just random noise).

%Set the free movement sensitivity.
move_sensitivity = 4;                       %This is the number of decimal points to which to round xbox controller axis data.  The higher the number, the more sensitive.  This makes the system more susceptible to noise.

%Set the free movement size. Increasing this number makes the robot move farther in a single step.
move_size = 1;                             %Defines the percentage of the maximum single displacement step to travel when an axis is fully engaged.

%Set the movement speed.
move_speed = 0.1;

%Define the number of read attempts to use. SHOULD BE AN ODD INTEGER.
NumReadAttempts = 3;            %Increasing this number makes it less likely that an incorrect read position will occur, but makes each read attempt take longer.

%Set the assumed starting angle.
[thetac, thetas_user, theta_home] = deal( [pi/4 -pi/2 0 0 -pi/4]' );

%Offset the starting current motor angles.  This prevents the system from moving very slowly the first time the system is sent to the home position.
thetac = thetac + pi/6;

%Define the Default Plane Points.
% Pts_Plane = [   -0.3533   -2.6501    1.7698;
%    18.6333   18.6921   18.6122;
%    12.7984   10.1644   10.2269];
% Pts_Plane = [   -0.4704   -2.4096    2.7743;
%    19.3047   19.3507   19.3409;
%    12.7100    9.6246    9.8118];

Pts_Plane = [0.94 -1.53 1.53;
             17.84 18.16 18.16;
             13.91 10.01 10.01];

%Compute the transformation matrix associated with the defined plane.  i.e., the transformation matrix that maps from the template letter space in the xy-plane at the origin to the location of the newly defined plane in space.
T_Plane = GetPlaneTransformationMatrix( Pts_Plane, [0 1 0]' );

%% Continuously Check for User Commands via the Xbox Controller & Respond Appropriately.

%Continuously search for user commands via the xbox controller...
while ~button(xbox_controller, 7)                                               %While the 'back' button is not pressed...
    
    %Read the data from the xbox controller.  These three variables contain the current values of all of the buttons and joysticks on the xbox controller.
    [axes, buttons, povs] = read(xbox_controller);
    
    %% Allow the User to Move the End Effector Freely.
    
    %Intepret input from the xbox controller and move the end effector approperiately.
    [ thetac, thetas_user ] = ControllerMovement( S, M, thetac, thetas_user, s, MotorIDs, xbox_controller, dtol_travel, move_speed, move_size, move_sensitivity, move_threshold, eomg, ev, bPlotMotorGraphs );
    
    %% Define the Letter to be Drawn.
    
    %When the user presses the "x" button, let them select the letter they want to write.
    if button(xbox_controller, 3)                                               %If the x button is pressed...
        
        %Wait for the "x" button to be lifted.
        while button(xbox_controller, 3), end           %This is just a safety to make sure that matlab waits for the user to completely lift up on the "y" button before proceeding.  Otherwise Matlab can interpret a slightly held button as being multiple presses.
        
        %Define the target letter.
        Ltr = SetTargetLetter( Ltrs );
        
    end
    
    %% Define the Writing Plane.
    
    %When the user presses the "y" button, initiate the writing plane defintion process.
    if button(xbox_controller, 4)                                               %If the y button is pressed...
        
        %Set the writing plane.
        [T_Plane, Pts_Plane, thetac, thetas_user] = SetWritingPlane( S, M, thetac, thetas_user, s, MotorIDs, xbox_controller, dtol_ltr, move_speed, move_size, move_sensitivity, move_threshold, eomg, ev, bPlotMotorGraphs );              %This is currently hardwired to provide a consistent result.
        
    end
    
    %% Draw the Target Letter.
    
    %When the user presses the "start" button, send motor commands to the Arduino for the letter specified by the user ("A" by default).
    if button(xbox_controller, 8)                           %If the start button is pressed...
        %% Retrieve the Current Position / Orientation of the End Effector.
        
        %Retrieve the current orientation of the end effector.
        Tc = FKinSpace(M(:, :, end), S, thetac);
        
        %% Generate the Trajectory.
        
        %State that letter trajectories will now be generated.
        fprintf('\nGENERATING TRAJECTORy. Please Wait...\n\n')
        
        %State which letter is being processed.
        fprintf(['Generating ', Ltr, ' Trajectory...\n'])
        
        %Generate the letter trajectories.
        [ thetas, mpos ] = PlanLetterTrajectoryWithTravel( S, M, Tc, T_Plane, Pts_Plane, Ltr, thetac, eomg, ev, dtol_ltr, dtol_travel, bMakePlots );          %Note that this function has no output variables.  This is because it is instead writing the trajectory data to text files.
        
        %Print that we are finished generating the letter trajectories.
        fprintf('\nDone: Letter Trajectories Confirmed.\n\n')
        
        %% Animate the Trajectory.
        
        %Animate the trajectory, if requsted.
        if bAnimateLetterTrajectory                                 %If we want to animate the letter writting trajectory...
            %State that we are going to animate the trajectory.
            fprintf('\nTRAJECTORY ANIMATION\n')
            fprintf('Animating trajectory...\n')
            
            %Animate the given trajectory.
            AnimateTrajectoryFunc( S, M, T_Plane, Pts_Plane, rs, thetas )
            
            %State that we are done animating the trajectory.
            fprintf('\nDone: Animating trajectory.\n')
        end
        
        %% Write Motor Positions to Arduino.
        
        %Send the trajectory to the motors.
        [ nmpos, bGotResponse ] = SetMotorPosition3( s, MotorIDs, mpos, Rad2MotorPos( thetac ), move_speed, bPlotMotorGraphs );
        
        %% Update the Current Motor Angles Variable.
        
        %Update the current motor angles variable.
        thetac = thetas(:, end);
        
    end
    
    %% Return to the Home Position.
    
    %If the 'a' Button is pressed, return to the home position.
    if button(xbox_controller, 1)                       %If the 'a' button is pressed...
        
        %Set the motor to the home position.
        SetMotorPosition3( s, MotorIDs, Rad2MotorPos( theta_home ), Rad2MotorPos( thetac ), 0.1, bPlotMotorGraphs );
        
        %Reset the default motor angles.
        [thetac, thetas_user] = deal( theta_home );
        
    end
    
    %% Open / Closed the Gripper.
    
    %If the 'b' Button is pressed, open / closed the gripper.
    if button(xbox_controller, 2)               %If the 'b' button is pressed...
        
        %Determine whether to open or closed the gripper.
        if bGripperClosed                    %If the gripper is closed...
            
            %Define the open gripper position.
            theta_Gripper = thetac; theta_Gripper(end) = -3*pi/4;
            
            %Update the flag to state that the gripper is open.
            bGripperClosed = false;
            
        else                                 %If the gripper is open...
            
            %Define the closed gripper position.
            theta_Gripper = thetac; theta_Gripper(end) = theta_home(end);
            
            %Update the flag to state that the gripper is closed.
            bGripperClosed = true;
            
        end
        
        %Move the gripper.
        SetMotorPosition3( s, MotorIDs, Rad2MotorPos( theta_Gripper ), Rad2MotorPos( thetac ), 0.1, bPlotMotorGraphs );
        
        %Update the current joint angles variable.
        thetac = theta_Gripper;
        
    end
    
    
    
end


%% Close Serial Port.

%Close the serial port.
CloseSerialPort( s )
