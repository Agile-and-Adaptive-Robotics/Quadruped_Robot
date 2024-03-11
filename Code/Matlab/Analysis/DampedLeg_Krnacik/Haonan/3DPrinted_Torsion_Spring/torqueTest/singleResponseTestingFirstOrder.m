clear
close all
clc

%% load data
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\data');
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest');
load springData;                        

springName = 'S2L5LT4ST37T';
torqueName = 'T300Nmm';
direction = 'CCW';
loadingg = 'loading';

data = springData.data.(springName).(torqueName).(direction).(loadingg).average;     % choose a spring to analyze
mgr = springData.data.(springName).(torqueName).torque/1000;             % [Nm] mass*gravity*pulley radius

% physical parameters
I1 = 6.6066/1000^2;         % [kg*m^2]      inertia of the pulley and hex rod from Solidworks
r1 = 20.4/1000;             % [m]           radius of the pulley
m = mgr/(9.81*r1);          % [kg]          mass hung from pulley

indStart = 25;
indEnd = 200;

%% cropped data
% Due to the high uncertainty in load application (we estimate a ramp then step input)
% the spring response data is cropped starting at 0.25 seconds.
% The springs continue to deflect past 20 minutes. For a spring intended on
% being used in a dynamic system, we will analyze the first 1.5 seconds of
% the spring response.
% Deflection beyond this time frame is attributed to material properties i.e. creep in elastomers
% instead of inherent dynamics of the spring.

dataCropped = deg2rad(data(indStart:indEnd));                                    % [rad] convert to radians and crop data from 0.25-1.5s
data = deg2rad(data(1:indEnd));                                            % [rad] additional data set for parameter validation later
tCropped = linspace(0,(length(dataCropped)-1)/100,length(dataCropped)); % [s] create time vector for cropped data
t = linspace(0,(length(data)-1)/100,length(data));                      % [s] create time vector additional data
k = abs(mgr/dataCropped(end))                                               % [Nm/rad] manually calculate spring rate

% The inertia of the system is very low and we expect the effects of inertia
% on the system response to be limited to around the first 0.25 seconds.
% Because the inertia influenced portion of the data is cropped out, the
% response can be modelled as a first order step response.

dataCropped = dataCropped - dataCropped(1);         % shift data down to start at 0
dataCroppedNorm = dataCropped/dataCropped(end);     % normalize cropped data - we are only interested in response characteristics

ts = settime5(dataCroppedNorm,tCropped);        % [s]           settling time based on 5% of steady state value
tau = ts/3;                                     % [s]           first order system coefficient
b = tau*k                                      % [Nms/rad]     damping constant derived from second order ODE characteristics

% Set up first order transfer function
s = tf('s');                        
funFO = mgr/(b*s + k);              % first order system approximation
modelFO = step(funFO,tCropped);     % store step response of first order system
modelFONorm = modelFO/modelFO(end); % normalize first order system response for comparison

figure
hold on
plot(tCropped,abs(dataCroppedNorm))
plot(tCropped,modelFONorm)
xlabel('Time (s)')
ylabel('Normalized Deflection')
legend('Experimental Data','First Order Model Approximation','Location','southeast')
plotTitleCropped = {springName + " " + torqueName + " " + direction + " " + loadingg ; ' Normalized Cropped First Order Step Response'};
fileTitleCropped = springName + " " + torqueName + " " + direction + " " + loadingg + ' Normalized Cropped First Order Step Response';
title(plotTitleCropped)
hold off

% save plot
saveas(gcf,strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\Figures\FirstOrder\',(fileTitleCropped),'.png'))

%% full response
% We are assuming a ramp into step input for the torque applied to each
% spring trial. The weights were dropped carefully to avoid swinging
% however this may have resulted in a gradual loading instead of a true
% step. Keeping the spring and damping constants found in our first order
% approximation, we will see if these parameters will yield a similar
% result to the data in a second order system.

ramp = linspace(0,1,34);                        % ramp input from 0-1 in 0.34s
const = ones(1,length(data) - length(ramp));    % ones for constant portion of input
input = cat(2,ramp,const);                      % concatenate ramp and const input into a single input vector

funSO = mgr/((I1+(m*(r1^2)))*s^2 + b*s + k);    % second order system approximation
modelSO = lsim(funSO,input,t);                  % store response of second order system

figure
hold on
plot(t,abs(data))
plot(t,modelSO)
xlabel('Time (s)')
ylabel('Deflection (rad)')
legend('Experimental Data','Second Order Model Approximation','Location','southeast')
plotTitle = springName + " " + torqueName + " " + direction + " " + loadingg + ' Full Second Order Ramp Response';
title(plotTitle)
hold off

% save plot
saveas(gcf,strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\Figures\FirstOrder\',(plotTitle),'.png'))