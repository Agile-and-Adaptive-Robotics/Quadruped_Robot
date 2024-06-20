%% plot raw data for a given spring
close all;
clear;
clc;

%% load spring data

LT = 2;
ST = 4;
infill = '100I';

springName = strcat('2L',num2str(LT),'LT',num2str(ST),'ST','_',infill);
saveName = strcat('S2L',num2str(LT),'LT',num2str(ST),'ST',infill);
mgrMatrix = {'20Nmm' '30Nmm' '50Nmm' '60Nmm'};
mgrNames = cell(1,4);

for ii = 1:length(mgrMatrix)
    mgrNames{ii} = strcat('T',mgrMatrix{ii});
end

directions = {'CW' 'CCW'};
trials = {'trial1' 'trial2' 'trial3' 'trial4'};

dataFolder = 'C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\data';

for ii = 1:length(mgrMatrix)
    mgr = mgrMatrix{ii};
    mgrName = mgrNames{ii};
    for jj = 1:length(directions)
        direction = directions{jj};
        filePath = strcat(dataFolder,'\',springName,'\',mgr,'\',direction);
        addpath(filePath);
        for kk = 1:length(trials)
            trial = trials{kk};
            fileName = strcat(springName,'_',mgr,'_',direction,'_',trial,'.mat');
            load (fileName);
            dataSave.(mgrName).(direction).(trial) = data;
        end
    end
    dataSave.(mgrName).mgrValue = torque;
end

assignin('base',saveName,dataSave);
save(strcat(dataFolder,'\',springName,'\',springName,'.mat'),(saveName));
