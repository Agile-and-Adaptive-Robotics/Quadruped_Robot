close all;
clear;
clc;

% folder path with subfolders of spring specfic data
dataFolder = 'C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\data';

% list of spring names
springNames = {'2L5LT4ST_37T'}; %'2L2LT4ST_37T' '2L3LT4ST_37T' '2L4LT4ST_37T' };...
              %'2L5LT4ST_37T' '2L5LT8ST_37T' '2L5LT12ST_37T'};
springData.springNames = springNames;
              
% number of different spring configurations
springCount = length(springNames);

% convert spring names to Matlab compliant variable notation (cannot start
% with number, no underscores)
saveNames = cell(1,springCount);
for ii = 1:springCount
    saveNames{ii} = strcat('S',springNames{ii}(1:8),springNames{ii}(10:12));
end
springData.saveNames = saveNames;

% list of directions of torque trials
directions = {'CW' 'CCW'};
springData.torqueDirections = directions;

% list of trial numbers
% odd numbered trials are loading the spring
% even numbered trials are unloading the spring
trials = {'trial1' 'trial2' 'trial3' 'trial4' 'trial5' 'trial6' 'trial7' 'trial8'};
springData.trials = trials;

% input torque values used to testing each spring
% torque value must be written here exactly how it is written in the folder
% name and in the data file name for this script to work
% torques.(saveNames{1}) = {'10Nmm' '20Nmm' '40Nmm' '50Nmm'};
% torques.(saveNames{2}) = {'20Nmm' '40Nmm' '100Nmm' '200Nmm'};
% torques.(saveNames{3}) = {'40Nmm' '100Nmm' '200Nmm' '300Nmm'};
torques.(saveNames{1}) = {'60Nmm' '100Nmm' '200Nmm' '300Nmm'};
springData.torques = torques;

% iterate through each spring/torque/direction/trial and save data in
% springData structure

% open spring name
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
%             figure
%             title(strcat(springName,' ',torqueName,' ',direction))
%             hold on

            loadingAverage = zeros(12000,1);
            unloadingAverage = zeros(12000,1);    
            
            % trial number
            for yy = 1:length(trials)
                trial = trials{yy};
                file = strcat(springNames{ii},'_',torqueName,'_',direction,'_',trial,'.mat');
                load (file);
                torqueDataName = strcat('T',torqueName);
                
                % separate loading and unloading trials
                if mod(yy,2) ~= 0
                    springData.data.(saveName).(torqueDataName).(direction).loading.(trial) = data;
                    loadingAverage = loadingAverage + data;
                else
                    springData.data.(saveName).(torqueDataName).(direction).unloading.(trial) = data;
                    unloadingAverage = unloadingAverage + data;
                end

%                 t = linspace(0,length(data)/100,length(data));
%                 plot(t,data);
            end % trial number

            loadingAverage = loadingAverage ./ 4;
            unloadingAverage = unloadingAverage ./ 4;
            
            springData.data.(saveName).(torqueDataName).(direction).loading.average = loadingAverage;
            springData.data.(saveName).(torqueDataName).(direction).unloading.average = unloadingAverage;
            t = linspace(0,(length(data)-1)/100,length(data));

            figure
            plot(t, loadingAverage)
            title(strcat(springName,' ',torqueName,' ',direction,' Loading Average'))
            
            figure
            plot(t, unloadingAverage)            
            title(strcat(springName,' ',torqueName,' ',direction,' Unloading Average'))
            
%             hold off
%             xlabel('Time (s)')
%             ylabel('Angular Displacement (º)')
        end % direction of torque applied
        
        springData.data.(saveName).(torqueDataName).torque = torque;
    end % torque applied
    
end % spring name

