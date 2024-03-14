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
% save(strcat(dataFolder,'\'springName,'\',

%%


% folder path with subfolders of spring specfic data


% list of spring names
springNames = {'2L2LT4ST_37T' '2L3LT4ST_37T' '2L4LT4ST_37T' '2L5LT4ST_37T'};%...
              %'2L5LT4ST_37T' '2L5LT8ST_37T' '2L5LT12ST_37T'};

% number of different spring configurations
springCount = length(springNames);

% convert spring names to Matlab compliant variable notation (cannot start
% with number, no underscores)
saveNames = cell(1,springCount);
for ii = 1:springCount
    saveNames{ii} = strcat('S',springNames{ii}(1:8),springNames{ii}(10:12));
end

% list of directions of torque trials
directions = {'CW' 'CCW'};

% list of trial numbers
trials = {'trial1' 'trial2' 'trial3' 'trial4' 'trial5' 'trial6' 'trial7' 'trial8'};

% input torque values used to testing each spring
% torque value must be written here exactly how it is written in the folder
% name and in the data file name for this script to work
torques.(saveNames{1}) = {'10Nmm' '20Nmm' '40Nmm' '50Nmm'};
torques.(saveNames{2}) = {'20Nmm' '40Nmm' '100Nmm' '200Nmm'};
torques.(saveNames{3}) = {'40Nmm' '100Nmm' '200Nmm' '300Nmm'};
torques.(saveNames{4}) = {'60Nmm' '100Nmm' '200Nmm' '300Nmm'};

% iterate through each spring/torque/direction/trial and save data in
% springData structure

% spring name
for ii = 1:springCount
    springName = springNames{ii};
    saveName = saveNames{ii};
    springFolder = strcat(dataFolder,'\',springNames{ii});
    
    % torque applied
    for jj = 1:length(torques.(saveNames{ii}))
        torqueName = torques.(saveNames{ii}){jj};
        
        % direction of torque applied
        for kk = 1:length(directions)
            direction = directions{kk};
            path = strcat(dataFolder,'\',springName,'\',torqueName,'\',direction);
            addpath(path);
            figure
            title(strcat(springName,' ',torqueName,' ',direction))
            hold on
            
            % trial number
            for yy = 1:length(trials)
                trial = trials{yy};
                file = strcat(springNames{ii},'_',torqueName,'_',direction,'_',trial,'.mat');
                load (file);
                torqueDataName = strcat('T',torqueName);
                springData.(saveName).(torqueDataName).(direction).(trial) = data;
                
                t = linspace(0,(length(data)-1)/100,length(data));
                plot(t,data);
            end % trial number
            
            hold off
            xlabel('Time (s)')
            ylabel('Angular Displacement (º)')
            legend(trials)
            xlim([0 2.5])
        end % direction of torque applied
        
        springData.(saveName).(torqueDataName).torque = torque;
    end % torque applied
    
end % spring name