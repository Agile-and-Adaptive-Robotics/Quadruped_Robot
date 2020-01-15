function PlanLetterTrajectoryFunc( S, M, T_Plane, W_Plane, Ltr, theta_guess, eomg, ev, dtol, bMakePlots )
%% ME 557: Project, Plan Letter Trajectory

%This function performs the following tasks:
%1) it reads in a template letter,
%2) it maps this letter to a specified plane,
%3) it linearly interpolates points between each vertex of the letter
%4) it solves the inverse kinematics problem to determine the joint angles necessary to achieve the path specified above,
%5) it creates plots of these paths, joints angles, and error estimates if requested,
%6) it converts joint angles from radians into motor command positions (i.e., 0-1023 etc).
%7) it writes these motor commands to .txt files for later recall.


%% Read in the Letter Data.

%Read in the letter points.
Lpts = GetLetterTemplate( Ltr );

%% Modified the Letter Template.

%Compute the maximum and minimum x & y values in the letter.
[Lpts_max, Lpts_min] = deal( max(Lpts, [], 2), min(Lpts, [], 2) );

%Compute the width of the letter.
widths = Lpts_max - Lpts_min;

%Retrieve the x & y direcitonal widths.
W_Letter = widths(1:2);

%Define a scaling factor of safety.  We are going to scale the size of the letter based on the three points we are using to define the writing plane.
FOS = 0.75;                             %A value of one would make the letter have the same width and height of the triangle who's vertices are the three points defining the letter plane.

%Compute the width ratios.
Scl = FOS*(W_Plane./W_Letter);

%Create a scaling matrix.
SclMat = [Scl(1) 0 0 0; 0 Scl(2) 0 0; 0 0 1 0; 0 0 0 1];

%Transform the letter points to be on the target plane and scale the points to be the correct size.
Lpts = T_Plane*SclMat*[Lpts; ones(1, size(Lpts, 2))];

%Remove the additional row.  The additional row is necessary for use with the transformation matrices, but is not useful otherwise.
Lpts(4, :) = [];

%% Refine the Letter to Have an Appropriate Number of Steps.

%Retrieve the orientation of the plane.
R_Plane = T_Plane(1:3, 1:3);

%Define the desired orientation of the end effector when drawing the letter.
% R_Ltr = [-R_Plane(:, 3), -R_Plane(:, 1), R_Plane(:, 2)];
R_Ltr = [R_Plane(:, 1), -R_Plane(:, 2), -R_Plane(:, 3)];

%Define the combine the desired orientation and positions into a mutltidimensional transformation matrix.
T_Ltr = Rp2TransMatrix( R_Ltr, Lpts );

%Refine the letter path.
T_Ltr = DescritizePath( T_Ltr, dtol );

%Retrieve the interpolated letter positions.
[ ~, Lpts ] = TransMatrix2Rp( T_Ltr );

%% Solve the Inverse Kinematics Problem (i.e., Determine Which Angles Produce the Desired Positions).

%Compute the motor angles & positions.
[ nthetas, mpos ] = Trajectory2MotorAngles( S, M, T_Ltr, theta_guess, eomg, ev );

%Compute the trajectory of each link point based on the link lengths and
%motor angles.
nPts = MotorAngles2Trajectory( S, M, nthetas );
nPts = nPts(:, :, end);

%Compute the componentwise error in the end effector position.
errs = nPts - Lpts;

%Compute the magnitude of the error in the end effector position.
errmags = vecnorm(errs);

%Compute angle changes for reference.
dnthetas = diff(nthetas, 1, 2);

%Create plots of trajectory, joint angles, and error, if requested.
if bMakePlots                               %If request to create plots...
    %% Plot the Pts and Letter.
    
    %Create a figure to store the workspace points & letter.
    figure, hold on, grid on
    
    %Plot the modified letter points.
    plot3(Lpts(1, :), Lpts(2, :), Lpts(3, :), '-k', 'Linewidth', 3)
    
    %Plot the workspace points that are nearby the letter points.
    plot3(nPts(1, :), nPts(2, :), nPts(3, :), '.r', 'Markersize', 20)
    
    %Format the plot.
    title('Workspace'), xlabel('x-axis'), ylabel('y-axis'), zlabel('z-axis')
    view(30, 30), rotate3d on
    
    %% Compute the associated Motor Positions and plot them.
    
    %Define the points to move through.
    ns = 1:size(nthetas, 2);
    
    %Plot the angles versus command number.
    figure, subplot(1, 3, 1), hold on, grid on
    plot(ns , nthetas(1, :), '.-', 'Markersize', 20);
    plot(ns , nthetas(2, :), '.-', 'Markersize', 20);
    plot(ns , nthetas(3, :), '.-', 'Markersize', 20);
    plot(ns , nthetas(4, :), '.-', 'Markersize', 20);
    plot(ns , nthetas(5, :), '.-', 'Markersize', 20);
    plot(ns , nthetas(6, :), '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Angle [rad]')
    title('Angles vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %Plot the angles versus command number.
    subplot(1, 3, 2), hold on, grid on
    plot(ns , nthetas(1, :)*180/pi, '.-', 'Markersize', 20);
    plot(ns , nthetas(2, :)*180/pi, '.-', 'Markersize', 20);
    plot(ns , nthetas(3, :)*180/pi, '.-', 'Markersize', 20);
    plot(ns , nthetas(4, :)*180/pi, '.-', 'Markersize', 20);
    plot(ns , nthetas(5, :)*180/pi, '.-', 'Markersize', 20);
    plot(ns , nthetas(6, :)*180/pi, '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Angle [deg]')
    title('Angles vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %Plot the motor position versus command number.
    subplot(1, 3, 3), hold on, grid on
    plot(ns , mpos(1, :), '.-', 'Markersize', 20);
    plot(ns , mpos(2, :), '.-', 'Markersize', 20);
    plot(ns , mpos(3, :), '.-', 'Markersize', 20);
    plot(ns , mpos(4, :), '.-', 'Markersize', 20);
    plot(ns , mpos(5, :), '.-', 'Markersize', 20);
    plot(ns , mpos(6, :), '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Motor Position [0-4096]')
    title('Motor Position vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %% Plot the Motor Difference Positions.
    
    %Define the points to move through.
    dns = 1:size(dnthetas,2);
    
    %Convert the angles into motor positions.
    dmpos = Rad2MotorPos(dnthetas);
    
    %Plot the angles versus command number.
    figure, subplot(1, 3, 1), hold on, grid on
    plot(dns , dnthetas(1, :), '.-', 'Markersize', 20);
    plot(dns , dnthetas(2, :), '.-', 'Markersize', 20);
    plot(dns , dnthetas(3, :), '.-', 'Markersize', 20);
    plot(dns , dnthetas(4, :), '.-', 'Markersize', 20);
    plot(dns , dnthetas(5, :), '.-', 'Markersize', 20);
    plot(dns , dnthetas(6, :), '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Angle [rad]')
    title('Difference Angles vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %Plot the angles versus command number.
    subplot(1, 3, 2), hold on, grid on
    plot(dns , dnthetas(1, :)*180/pi, '.-', 'Markersize', 20);
    plot(dns , dnthetas(2, :)*180/pi, '.-', 'Markersize', 20);
    plot(dns , dnthetas(3, :)*180/pi, '.-', 'Markersize', 20);
    plot(dns , dnthetas(4, :)*180/pi, '.-', 'Markersize', 20);
    plot(dns , dnthetas(5, :)*180/pi, '.-', 'Markersize', 20);
    plot(dns , dnthetas(6, :)*180/pi, '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Angle [deg]')
    title('Difference Angles vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %Plot the motor position versus command number.
    subplot(1, 3, 3), hold on, grid on
    plot(dns , dmpos(1, :), '.-', 'Markersize', 20);
    plot(dns , dmpos(2, :), '.-', 'Markersize', 20);
    plot(dns , dmpos(3, :), '.-', 'Markersize', 20);
    plot(dns , dmpos(4, :), '.-', 'Markersize', 20);
    plot(dns , dmpos(5, :), '.-', 'Markersize', 20);
    plot(dns , dmpos(6, :), '.-', 'Markersize', 20);
    xlabel('Command Number'), ylabel('Motor Position [0-4096]')
    title('Difference Motor Position vs Command Number')
    legend('Motor 1', 'Motor 2', 'Motor 3', 'Motor 4', 'Motor 5', 'Motor 6')
    
    %% Plot the End Effector Position Error.
    
    %Create a plot for the end effector position error components.
    figure, subplot(1, 2, 1), hold on, grid on
    plot(ns, errs(1, :), '.-'), plot(ns, errs(2, :), '.-'), plot(ns, errs(3, :), '.-')
    xlabel('Command Number'), ylabel('Position Error [in]')
    title('Error Components vs Command Number')
    legend('x-error', 'y-error', 'z-error')
    
    %Create a plot for the end effector position error magnitude.
    subplot(1, 2, 2), hold on, grid on
    plot(ns, errmags, '.-')
    xlabel('Command Number'), ylabel('Position Error [in]')
    title('Error Magnitude vs Command Number'), legend('Error Mag')
end

%% Write out the Computed Motor Angles and Motor Positions.

%Define the folder.
RawTrajFolder = 'C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\Trajectories';

%Define the filenames.
fname_MotorAngles = strcat('MotorAnglesTrajectory_', Ltr, '.txt');
fname_MotorPositions = strcat('MotorPositionTrajectory_', Ltr, '.txt');

%Define the paths.
fpath_MotorAngles = strcat(RawTrajFolder, '\', fname_MotorAngles);
fpath_MotorPositions= strcat(RawTrajFolder, '\', fname_MotorPositions);

%Write out the data.
dlmwrite(fpath_MotorAngles, nthetas)        %Motor Angles.
dlmwrite(fpath_MotorPositions, mpos)        %Motor Positions.

end

