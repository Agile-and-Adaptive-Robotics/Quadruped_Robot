clear;
close all;
 
load('Golden5.mat')

[a] = ProcessMuscleMutt()%Loads processed MuscleMutt Data
initialGuess = [-100,-56,-31554,-899,-2253,-3279,2,0,0];