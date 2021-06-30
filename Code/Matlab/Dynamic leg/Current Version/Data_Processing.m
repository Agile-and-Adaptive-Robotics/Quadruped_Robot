clear;
close all;
 
load('Golden6.mat');

figure
plot(Trial4);
legend('knee', 'hip')
N = 4000;

[DogLegDataKnee] = Trial4(:,1);
[DogLegDataHip] = Trial4(:,2)*-1;
[DogLegDataAnkle]= zeros(N,1);

DogLegData = [DogLegDataHip,DogLegDataKnee,DogLegDataAnkle];

%
%baudRate = 115200;
%RPM = 7500;
%speed = RPM*0.10472;

% n = number of pulses; N is pulses per rotation 
%n = 4000; N = 2048;
%t = (2*pi*n)/(N*speed);

%% Spacing of data sent to serialportread
% digitalwrite takes about 500 ms, 4 digitalwrite, 4000 instances
dwrite = 0.00046;
dt = dwrite*4;

init_t=0;
N = 4000;
final_t= N*dt;
t_span=linspace(init_t,final_t,N);
%% Converts leg data from PPR to radians rotation
PPR = 2048;
RPT = (2*pi)/(PPR);

DogLegData = DogLegData*RPT;

Lengths = [9.25,9.25,9.81,N];
plotSingleLeg(DogLegData, Lengths)







