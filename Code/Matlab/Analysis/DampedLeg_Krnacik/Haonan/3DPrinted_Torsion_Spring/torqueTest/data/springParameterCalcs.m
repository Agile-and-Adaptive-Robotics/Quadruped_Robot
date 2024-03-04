%% Torque Step Response
% Calculate spring stiffness and damping characteristics based on averaged
% torque step responses gathered about the springs.

clear
close all
clc

%% Set Up

load springData;

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

I1 = 6.6066/1000^2;        % [kg*m^2]     inertia of the pulley from Solidworks
loading = {'loading' 'unloading'};

s = tf('s');

%% Spring Parameter Calculations and Plots
% spring name
for ii = 1:springCount
    springName = springNames{ii};
    saveName = saveNames{ii};
    
    T = zeros(4,1);
    kCWloading = zeros(4,1);
    kCWunloading = zeros(4,1);
    kCCWloading = zeros(4,1);
    kCCWunloading = zeros(4,1);
    
    dCWloading = zeros(4,1);
    dCWunloading = zeros(4,1);
    dCCWloading = zeros(4,1);
    dCCWunloading = zeros(4,1);
    
    % torque applied
    for jj = 1:length(torques.(saveNames{ii}))
        torqueName = torques.(saveNames{ii}){jj};
        torqueDataName = strcat('T',torqueName);
        torque = (springData.data.(saveName).(torqueDataName).torque)/1000;     %   [N*m] = [kg*m^2/s^2]
        
        T(jj) = torque;

        % direction of torque applied
        for kk = 1:length(directions)
            direction = directions{kk};
             
            % loading/unloading
            for yy = 1:2
                data = springData.data.(saveName).(torqueDataName).(direction).(loading{yy}).average(1:250,1);
                t = linspace(0,(length(data)-1)/100,length(data));
                
                if (data(end) - data(1)) < 0
                    data = -data;
                end
                
%                 figure
%                 sgtitle(strcat(torqueDataName,'  ', direction,'  ',loading{yy})) 
%                 hold on
%                 subplot(1,3,1)
%                 plot(t,data)
%                 xlim([0 2.5])
%                 
%                 
                tr = risetime_ek(data,t);
%                 
                ts = settime(data,t);
%                 
                zeta = dampingRatio(tr,ts);
%                 
                omegan = (4.5*zeta)/ts;
%                 
                b = 2*I1*zeta*omegan;    % [kg*m^2/s]   damping constant of the spring
%                 
                k = I1*omegan^2;         % [kg*m^2/s^2] spring constant of the spring
%                 
                Phi_1 = torque/(I1*s^2 + b*s + k);
%                 
%                 subplot(1,3,2)
%                 step(Phi_1)
%                 xlim([0 2.5])
%                 
                k2 = torque/deg2rad(data(end));
%                 Phi_2 = 1/(I1*s^2 + k);
%                 subplot(1,3,3)
%                 step(Phi_2)
%                 xlim([0 2.5])               
%                 
%                 hold off        
                if kk == 1 && yy == 1
                    kCWloading(jj,1) = k;
                    dCWloading(jj) = data(end);
                elseif kk == 1 && yy == 2
                    kCWunloading(jj,1) = k;
                    dCWunloading(jj) = data(end);
                elseif kk == 2 && yy == 1
                    kCCWloading(jj,1) = k;
                    dCCWloading(jj) = data(end);
                elseif kk == 2 && yy == 2
                    kCCWunloading(jj,1) = k;
                    dCCWunloading(jj) = data(end);
                end

            end % trial number
            
%             hold off
%             xlabel('Time (s)')
%             ylabel('Angular Displacement (º)')
%             legend(trials)
        end % direction of torque applied  
        
%         springData.(saveName).(torqueDataName).torque = torque;
    end % torque applied
    
        % plot deflection vs torque applied
        figure
        plot(dCWloading,T,'o')
        title(strcat(springName,torqueName,' CWloading'))
        ylabel('Torque (N-m)')
        xlabel('Deflection (rad)')
        
        figure
        plot(dCWunloading,T,'o')
        title(strcat(springName,torqueName,' CWunloading'))
        ylabel('Torque (N-m)')
        xlabel('Deflection (rad)')
        
        figure
        plot(dCCWloading,T,'o')
        title(strcat(springName,torqueName,' CCWloading'))
        ylabel('Torque (N-m)')
        xlabel('Deflection (rad)')
        
        figure
        plot(dCCWunloading,T,'o')
        title(strcat(springName,torqueName,' CCWunloading'))
        ylabel('Torque (N-m)')
        xlabel('Deflection (rad)')
        
        % plot spring rate vs torque applied
        figure
        plot(T,kCWloading,'o')
        title(strcat(springName,torqueName,' CWloading'))
        xlabel('Torque (N-m)')
        ylabel('Spring Rate')
        
        figure
        plot(T,kCWunloading,'o')
        title(strcat(springName,torqueName,' CWunloading'))
        xlabel('Torque (N-m)')
        ylabel('Spring Rate')
        
        figure
        plot(T,kCCWloading,'o')
        title(strcat(springName,torqueName,' CCWloading'))
        xlabel('Torque (N-m)')
        ylabel('Spring Rate')
        
        figure
        plot(T,kCCWunloading,'o')
        title(strcat(springName,torqueName,' CCWunloading'))
        xlabel('Torque (N-m)')
        ylabel('Spring Rate')
        
end % spring name
% hold off


% figure
% step(Phi_1)
