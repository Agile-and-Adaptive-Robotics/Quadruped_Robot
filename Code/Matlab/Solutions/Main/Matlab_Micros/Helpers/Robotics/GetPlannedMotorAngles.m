function [ theta ] = GetPlannedMotorAngles( Ltr )

%This function retrieves the saved motor angles associated with a given letter.

%Defined the pre-planned trajectories folder.
TrajFolder = 'C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\Trajectories';

%Define the name of the file of interest.
fname_MotorAngles = strcat('MotorAnglesTrajectory_', Ltr, '.txt');

%Define the complete path to the file of interest.
fpath_MotorAngles = strcat(TrajFolder, '\', fname_MotorAngles);

%Read in the file of interest.
theta = dlmread(fpath_MotorAngles);

end
