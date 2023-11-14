clear
clc
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping')

%% BFa
load BFa_trial1.mat;
BFa_trial1 = data;
load BFa_trial2.mat;
BFa_trial2 = data;
load BFa_trial3.mat;
BFa_trial3 = data;
load BFa_trial4.mat;
BFa_trial4 = data;

%  create single matrix to edit data
BFa = zeros(length(BFa_trial1(:,1)),4*length(BFa_trial1(1,:)));
BFa(:,1:4) = BFa_trial1(:,1:4);
BFa(:,5:8) = BFa_trial2(:,1:4);
BFa(:,9:12) = BFa_trial3(:,1:4);
BFa(:,13:16) = BFa_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    BFa(:,ii) = BFa(:,ii) - BFa(1,ii);      %   start time at 0   
    BFa(:,ii) = BFa(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    BFa_offset(1) = 0.22;
    BFa_offset(2) = 0.39;
    BFa_offset(3) = 0.28;
    BFa_offset(4) = 0.28;
    
    % apply time offsets
    BFa(:,ii) = BFa(:,ii) - BFa_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~BFa(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(BFa(:,ii),BFa(:,ii-3),'.',"color","k")
    plot(BFa(:,ii),BFa(:,ii-2),'.',"color","b")
    plot(BFa(:,ii),BFa(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("BFa Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1])
    hold off
    
    % crop trial matrices to start at t = 0
    BFa_trialsCropped{1,ii/4} = BFa(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(BFa_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
BFaCropped = zeros(trialEnd,4*length(BFa_trial1(1,:)));
for jj = 4:4:16
    BFaCropped(:,jj-3:jj) = BFa_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
BFaAvg = zeros(trialEnd,4);
BFaAvg(:,4) = BFaCropped(:,4);

for jj = 1:3
    BFaAvg(:,jj) = (BFaCropped(:,jj)+BFaCropped(:,jj+4)+BFaCropped(:,jj+8)+BFaCropped(:,jj+12))./4;
end


save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\BFaNoDamping.mat','BFa')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\BFaAvg.mat','BFaAvg')

%% BFp
load BFp_trial1.mat;
BFp_trial1 = data;
% data in trial 2 is cut off at t = 0 and therefore is not usable
load BFp_trial3.mat;
BFp_trial2 = data;
load BFp_trial4.mat;
BFp_trial3 = data;
load BFp_trial5.mat;
BFp_trial4 = data;

%  create single matrix to edit data
BFp = zeros(length(BFp_trial1(:,1)),4*length(BFp_trial1(1,:)));
BFp(:,1:4) = BFp_trial1(:,1:4);
BFp(:,5:8) = BFp_trial2(:,1:4);
BFp(:,9:12) = BFp_trial3(:,1:4);
BFp(:,13:16) = BFp_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    BFp(:,ii) = BFp(:,ii) - BFp(1,ii);      %   start time at 0   
    BFp(:,ii) = BFp(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    BFp_offset(1) = 0.15;
    BFp_offset(2) = 0.25;
    BFp_offset(3) = 0.37;
    BFp_offset(4) = 0.37;
    
    % apply time offsets
    BFp(:,ii) = BFp(:,ii) - BFp_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~BFp(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(BFp(:,ii),BFp(:,ii-3),'.',"color","k")
    plot(BFp(:,ii),BFp(:,ii-2),'.',"color","b")
    plot(BFp(:,ii),BFp(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("BFp Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1])
    hold off

% crop trial matrices to start at t = 0
BFp_trialsCropped{1,ii/4} = BFp(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(BFp_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
BFpCropped = zeros(trialEnd,4*length(BFp_trial1(1,:)));
for jj = 4:4:16
    BFpCropped(:,jj-3:jj) = BFp_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
BFpAvg = zeros(trialEnd,4);
BFpAvg(:,4) = BFpCropped(:,4);

for jj = 1:3
    BFpAvg(:,jj) = (BFpCropped(:,jj)+BFpCropped(:,jj+4)+BFpCropped(:,jj+8)+BFpCropped(:,jj+12))./4;
end

save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\BFpNoDamping.mat','BFp')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\BFpAvg.mat','BFpAvg')

%% IP
load IP_trial1.mat;
IP_trial1 = data;
load IP_trial2.mat;
IP_trial2 = data;
load IP_trial3.mat;
IP_trial3 = data;
load IP_trial4.mat;
IP_trial4 = data;

%  create single matrix to edit data
IP = zeros(length(IP_trial1(:,1)),4*length(IP_trial1(1,:)));
IP(:,1:4) = IP_trial1(:,1:4);
IP(:,5:8) = IP_trial2(:,1:4);
IP(:,9:12) = IP_trial3(:,1:4);
IP(:,13:16) = IP_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    IP(:,ii) = IP(:,ii) - IP(1,ii);      %   start time at 0   
    IP(:,ii) = IP(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    IP_offset(1) = 0.23;
    IP_offset(2) = 0.31;
    IP_offset(3) = 0.30;
    IP_offset(4) = 0.36;
    
    % apply time offsets
    IP(:,ii) = IP(:,ii) - IP_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~IP(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(IP(:,ii),IP(:,ii-3),'.',"color","k")
    plot(IP(:,ii),IP(:,ii-2),'.',"color","b")
    plot(IP(:,ii),IP(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("IP Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1])
    hold off

    % crop trial matrices to start at t = 0
    IP_trialsCropped{1,ii/4} = IP(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(IP_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
IPCropped = zeros(trialEnd,4*length(IP_trial1(1,:)));
for jj = 4:4:16
    IPCropped(:,jj-3:jj) = IP_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
IPAvg = zeros(trialEnd,4);
IPAvg(:,4) = IPCropped(:,4);

for jj = 1:3
    IPAvg(:,jj) = (IPCropped(:,jj)+IPCropped(:,jj+4)+IPCropped(:,jj+8)+IPCropped(:,jj+12))./4;
end

save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\IPNoDamping.mat','IP')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\IPAvg.mat','IPAvg')

%% ST
load ST_trial1.mat;
ST_trial1 = data;
load ST_trial2.mat;
ST_trial2 = data;
load ST_trial3.mat;
ST_trial3 = data;
load ST_trial4.mat;
ST_trial4 = data;

%  create single matrix to edit data
ST = zeros(length(ST_trial1(:,1)),4*length(ST_trial1(1,:)));
ST(:,1:4) = ST_trial1(:,1:4);
ST(:,5:8) = ST_trial2(:,1:4);
ST(:,9:12) = ST_trial3(:,1:4);
ST(:,13:16) = ST_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    ST(:,ii) = ST(:,ii) - ST(1,ii);      %   start time at 0   
    ST(:,ii) = ST(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    ST_offset(1) = 0.36;
    ST_offset(2) = 0.46;
    ST_offset(3) = 0.32;
    ST_offset(4) = 0.33;
    
    % apply time offsets
    ST(:,ii) = ST(:,ii) - ST_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~ST(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(ST(:,ii),ST(:,ii-3),'.',"color","k")
    plot(ST(:,ii),ST(:,ii-2),'.',"color","b")
    plot(ST(:,ii),ST(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("ST Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1])
    hold off

    % crop trial matrices to start at t = 0
    ST_trialsCropped{1,ii/4} = ST(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(ST_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
STCropped = zeros(trialEnd,4*length(ST_trial1(1,:)));
for jj = 4:4:16
    STCropped(:,jj-3:jj) = ST_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
STAvg = zeros(trialEnd,4);
STAvg(:,4) = STCropped(:,4);

for jj = 1:3
    STAvg(:,jj) = (STCropped(:,jj)+STCropped(:,jj+4)+STCropped(:,jj+8)+STCropped(:,jj+12))./4;
end

save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\STNoDamping.mat','ST')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\STAvg.mat','STAvg')

%% ST2
load ST2_trial1.mat;
ST2_trial1 = data;
load ST2_trial2.mat;
ST2_trial2 = data;
load ST2_trial3.mat;
ST2_trial3 = data;
load ST2_trial4.mat;
ST2_trial4 = data;
load ST2_trial5.mat;
ST2_trial5 = data;

%  create single matrix to edit data
ST2 = zeros(length(ST2_trial1(:,1)),5*length(ST2_trial1(1,:)));
ST2(:,1:4) = ST2_trial1(:,1:4);
ST2(:,5:8) = ST2_trial2(:,1:4);
ST2(:,9:12) = ST2_trial3(:,1:4);
ST2(:,13:16) = ST2_trial4(:,1:4);
ST2(:,17:20) = ST2_trial5(:,1:4);

% data processing
for ii = 4:4:20
    
    % process time values
    ST2(:,ii) = ST2(:,ii) - ST2(1,ii);      %   start time at 0   
    ST2(:,ii) = ST2(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    ST2_offset(1) = 0.34;
    ST2_offset(2) = 0.43;
    ST2_offset(3) = 0.38;
    ST2_offset(4) = 0.3;
    ST2_offset(5) = 0.36;
    
    % apply time offsets
    ST2(:,ii) = ST2(:,ii) - ST2_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~ST2(:,ii),1);
        
    % individual plots of trials
    figure
    hold on
    plot(ST2(:,ii),ST2(:,ii-3),'.',"color","k")
    plot(ST2(:,ii),ST2(:,ii-2),'.',"color","b")
    plot(ST2(:,ii),ST2(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("ST2 Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 2])
    hold off
    
    % crop trial matrices to start at t = 0
    ST2_trialsCropped{1,ii/4} = ST2(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:5
    trialLengths(jj) = length(ST2_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
ST2Cropped = zeros(trialEnd,5*length(ST2_trial1(1,:)));
for jj = 4:4:20
    ST2Cropped(:,jj-3:jj) = ST2_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
ST2Avg = zeros(trialEnd,4);
ST2Avg(:,4) = ST2Cropped(:,4);

for jj = 1:3
    ST2Avg(:,jj) = (ST2Cropped(:,jj)+ST2Cropped(:,jj+4)+ST2Cropped(:,jj+8)+ST2Cropped(:,jj+12)+ST2Cropped(:,jj+16))./5;
end

save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\ST2NoDamping.mat','ST2')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\ST2Avg.mat','ST2Avg')

%% VL
load VL_trial1.mat;
VL_trial1 = data;
load VL_trial2.mat;
VL_trial2 = data;
load VL_trial3.mat;
VL_trial3 = data;
load VL_trial4.mat;
VL_trial4 = data;

%  create single matrix to edit data
VL = zeros(length(VL_trial1(:,1)),4*length(VL_trial1(1,:)));
VL(:,1:4) = VL_trial1(:,1:4);
VL(:,5:8) = VL_trial2(:,1:4);
VL(:,9:12) = VL_trial3(:,1:4);
VL(:,13:16) = VL_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    VL(:,ii) = VL(:,ii) - VL(1,ii);      %   start time at 0   
    VL(:,ii) = VL(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    VL_offset(1) = 0.20;
    VL_offset(2) = 0.38;
    VL_offset(3) = 0.44;
    VL_offset(4) = 0.40;
    
    % apply time offsets
    VL(:,ii) = VL(:,ii) - VL_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~VL(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(VL(:,ii),VL(:,ii-3),'.',"color","k")
    plot(VL(:,ii),VL(:,ii-2),'.',"color","b")
    plot(VL(:,ii),VL(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("VL Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1])
    hold off

    % crop trial matrices to start at t = 0
    VL_trialsCropped{1,ii/4} = VL(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(VL_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
VLCropped = zeros(trialEnd,4*length(VL_trial1(1,:)));
for jj = 4:4:16
    VLCropped(:,jj-3:jj) = VL_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
VLAvg = zeros(trialEnd,4);
VLAvg(:,4) = VLCropped(:,4);

for jj = 1:3
    VLAvg(:,jj) = (VLCropped(:,jj)+VLCropped(:,jj+4)+VLCropped(:,jj+8)+VLCropped(:,jj+12))./4;
end

save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\VLNoDamping.mat','VL')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\VLAvg.mat','VLAvg')

%% GS
load GS_trial1.mat;
GS_trial1 = data;
load GS_trial2.mat;
GS_trial2 = data;
load GS_trial3.mat;
GS_trial3 = data;
load GS_trial4.mat;
GS_trial4 = data;

%  create single matrix to edit data
GS = zeros(length(GS_trial1(:,1)),4*length(GS_trial1(1,:)));
GS(:,1:4) = GS_trial1(:,1:4);
GS(:,5:8) = GS_trial2(:,1:4);
GS(:,9:12) = GS_trial3(:,1:4);
GS(:,13:16) = GS_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    GS(:,ii) = GS(:,ii) - GS(1,ii);      %   start time at 0   
    GS(:,ii) = GS(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    GS_offset(1) = 0.29;
    GS_offset(2) = 0.31;
    GS_offset(3) = 0.44;
    GS_offset(4) = 0.36;
    
    % apply time offsets
    GS(:,ii) = GS(:,ii) - GS_offset(ii/4);
    
    % find and save indices of t = 0
    t0index(ii/4) = find(~GS(:,ii),1);
    
    % individual plots of trials
    figure
    hold on
    plot(GS(:,ii),GS(:,ii-3),'.',"color","k")
    plot(GS(:,ii),GS(:,ii-2),'.',"color","b")
    plot(GS(:,ii),GS(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("GS Trial " + ii/4)
    xlabel("time (seconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 1.7])
    hold off

    % crop trial matrices to start at t = 0
    GS_trialsCropped{1,ii/4} = GS(t0index(ii/4):end,ii-3:ii);
end

% find length of cropped trial matrices 
for jj = 1:4
    trialLengths(jj) = length(GS_trialsCropped{1,jj}(:,1));    
end

% find smallest cropped trial length
trialEnd = min(trialLengths);                               

% store cropped trial data in one matrix
GSCropped = zeros(trialEnd,4*length(GS_trial1(1,:)));
for jj = 4:4:16
    GSCropped(:,jj-3:jj) = GS_trialsCropped{1,jj/4}(1:trialEnd,:);
end

% store average of trial responses
GSAvg = zeros(trialEnd,4);
GSAvg(:,4) = GSCropped(:,4);

for jj = 1:3
    GSAvg(:,jj) = (GSCropped(:,jj)+GSCropped(:,jj+4)+GSCropped(:,jj+8)+GSCropped(:,jj+12))./4;
end

%save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\GSNoDamping.mat','GS')
%save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\GSAvg.mat','GSAvg')

%% Save as an array
QuadrupedNoDamping{1} = IP;
QuadrupedNoDamping{2} = GS;
QuadrupedNoDamping{3} = ST;
QuadrupedNoDamping{4} = ST2;
QuadrupedNoDamping{5} = VL;
QuadrupedNoDamping{6} = BFp;
QuadrupedNoDamping{7} = BFa;

QuadrupedNoDampingAvg{1} = IPAvg;
QuadrupedNoDampingAvg{2} = GSAvg;
QuadrupedNoDampingAvg{3} = STAvg;
QuadrupedNoDampingAvg{4} = ST2Avg;
QuadrupedNoDampingAvg{5} = VLAvg;
QuadrupedNoDampingAvg{6} = BFpAvg;
QuadrupedNoDampingAvg{7} = BFaAvg;

close all
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\QuadrupedNoDamping.mat','QuadrupedNoDamping')
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\No Damping\QuadrupedNoDampingAvg.mat','QuadrupedNoDampingAvg')