function [ Motor_Positions ] = GetPlannedMotorPositions( Ltr )

%This function retrieves the saved motor positions associated with a given letter.

%Defined the pre-planned trajectories folder.
TrajFolder = 'C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\Trajectories';

%Define the name of the file of interest.
fname_MotorPosition = strcat('MotorPositionTrajectory_', Ltr, '.txt');

%Define the complete path to the file of interest.
fpath_MotorPosition = strcat(TrajFolder, '\', fname_MotorPosition);

%Read in the file of interest.
Motor_Positions = dlmread(fpath_MotorPosition);

end
