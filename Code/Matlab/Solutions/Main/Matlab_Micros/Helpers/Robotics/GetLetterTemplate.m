function [ Lpts ] = GetLetterTemplate( Ltr )

%This function retrieves the letter template points for the letter specified by Ltr.

%Define the letter template folder.
Ltr_Folder = 'C:\Users\USER\Documents\Coursework\MSME\Year1\Winter2018\ME557_IntroToRobotics\Project\LetterPoints';         %This path would need to be updated if this code is run on a different computer.

%Define the letter template file name.
Ltr_FileName = strcat('LetterPts_', Ltr, '.txt');

%Define the complete letter template path.
Ltr_Path = strcat(Ltr_Folder, '\', Ltr_FileName);

%Read the letter template points.
Lpts = dlmread(Ltr_Path);

end
