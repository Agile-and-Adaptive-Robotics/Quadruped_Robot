clear;
close all;

%prompt = 'Enter Joint Data:' ;
%fileName = input(prompt,'s');
%fileName1 = [fileName, '.mat'];
%load(fileName,'-mat') 
load('golden4.mat');

figure
plot(Trial4);

[DogLegDataKnee] = Trial1(:,1);
[DogLegDataHip] = Trial4(:,2);

plot(DogLegDataKnee);

baudRate = 115200;
RPM = 7500;







