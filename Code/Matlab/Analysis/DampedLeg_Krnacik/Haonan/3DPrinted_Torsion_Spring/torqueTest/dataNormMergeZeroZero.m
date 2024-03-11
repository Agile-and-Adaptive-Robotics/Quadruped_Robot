close all;
clear;
clc;

% folder path with subfolders of spring specfic data
dataFolder = 'C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\data';

% list of spring names
springNames = {'2L2LT4ST_37T' '2L3LT4ST_37T' '2L4LT4ST_37T' '2L5LT4ST_37T'};%...
              %'2L5LT2ST_37T' '2L5LT8ST_37T' '2L5LT12ST_37T'};

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
    startIndices = readmatrix('SpringStartIndex.xlsx','Sheet',springName,'Range','C2:F17');
    startIndices = startIndices .* 100;
    
    % torque applied
    for jj = 1:length(torques.(saveNames{ii}))
        torqueName = torques.(saveNames{ii}){jj};
        
        % direction of torque applied
        for kk = 1:length(directions)
            direction = directions{kk};
            path = strcat(dataFolder,'\',springName,'\',torqueName,'\',direction);
            addpath(path);
            startIndex = zeros(1,8);
            
            if kk == 1
                for xx = 1:8
                startIndex(xx) = startIndices(xx,jj);
                end
            elseif kk == 2
                for xx = 9:16
                startIndex(xx-8) = startIndices(xx,jj);
                end           
            end
                 
%             figure
%             hold on

            loadingAverage = zeros(12000,1);
            unloadingAverage = zeros(12000,1);  
            
            indexEndLoading = 12000;
            indexEndUnloading = 12000;
            
            % trial number
            for yy = 1:length(trials)
                trial = trials{yy};
                file = strcat(springNames{ii},'_',torqueName,'_',direction,'_',trial,'.mat');
                load (file);       
                torqueDataName = strcat('T',torqueName);
                
                data = data(int32(startIndex(yy)):end);             
                data = data - data(1); % move data up or down to start at 0
                
                % separate loading and unloading trials
                if mod(yy,2) ~= 0
                    if length(data) < indexEndLoading
                        indexEndLoading = length(data);
                        loadingAverage(1:indexEndLoading) = loadingAverage(1:indexEndLoading) + data;
                    else
                        loadingAverage(1:length(data)) = loadingAverage(1:length(data)) + data;
                    end
                    springData.data.(saveName).(torqueDataName).(direction).loading.(trial) = data;
                else
                    if length(data) < indexEndUnloading
                        indexEndUnloading = length(data);
                        unloadingAverage(1:indexEndUnloading) = unloadingAverage(1:indexEndUnloading) + data;
                    else
                        unloadingAverage(1:length(data)) = unloadingAverage(1:length(data)) + data;
                    end
                    springData.data.(saveName).(torqueDataName).(direction).unloading.(trial) = data;
                end
                
%                 t = linspace(0,length(data)/100,length(data));
%                 plot(t,data);
            end % trial number
            
            loadingAverage = loadingAverage(1:indexEndLoading);
            unloadingAverage = unloadingAverage(1:indexEndUnloading);
            
            loadingAverage = loadingAverage ./ 4;
            unloadingAverage = unloadingAverage ./ 4;
            
            t_load = linspace(0,(length(loadingAverage)-1)/100,length(loadingAverage));
            t_unload = linspace(0,(length(unloadingAverage)-1)/100,length(unloadingAverage));            
            springData.data.(saveName).(torqueDataName).(direction).loading.average = loadingAverage;
            springData.data.(saveName).(torqueDataName).(direction).unloading.average = unloadingAverage;
            
            figure
            plot(t_load,loadingAverage)
            xlim([0 1.5])
            xlabel('Time (s)')
            ylabel('Angular Displacement (º)')
            title(strcat(saveName,' ',torqueName,' ',direction,' loading')) 
            
            figure
            plot(t_unload,unloadingAverage)
            xlim([0 1.5])
            xlabel('Time (s)')
            ylabel('Angular Displacement (º)')
            title(strcat(saveName,' ',torqueName,' ',direction,' unloading')) 
        end % direction of torque applied
        
        springData.data.(saveName).(torqueDataName).torque = torque;
    end % torque applied
    
end % spring name

close all