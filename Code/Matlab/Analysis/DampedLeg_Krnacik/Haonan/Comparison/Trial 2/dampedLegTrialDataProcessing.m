clear
clc
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2')

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
    BFa_offset(1) = 0.15;
    BFa_offset(2) = 0.23;
    BFa_offset(3) = 0.36;
    BFa_offset(4) = 0.32;
    
    % apply time offsets
    BFa(:,ii) = BFa(:,ii) - BFa_offset(ii/4);
        
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
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\BFaSet2.mat','BFa')

%% BFp
load BFp_trial1.mat;
BFp_trial1 = data;
load BFp_trial2.mat;
BFp_trial2 = data;
load BFp_trial3.mat;
BFp_trial3 = data;
load BFp_trial4.mat;
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
    BFp_offset(1) = 0.22;
    BFp_offset(2) = 0.24;
    BFp_offset(3) = 0.26;
    BFp_offset(4) = 0.22;
    
    % apply time offsets
    BFp(:,ii) = BFp(:,ii) - BFp_offset(ii/4);
        
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
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\BFpSet2.mat','BFp')

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
    IP_offset(1) = 0.33;
    IP_offset(2) = 0.27;
    IP_offset(3) = 0.34;
    IP_offset(4) = 0.21;
    
    % apply time offsets
    IP(:,ii) = IP(:,ii) - IP_offset(ii/4);
        
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
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\IPSet2.mat','IP')

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
    ST_offset(1) = 0.26;
    ST_offset(2) = 0.37;
    ST_offset(3) = 0.23;
    ST_offset(4) = 0.31;
    
    % apply time offsets
    ST(:,ii) = ST(:,ii) - ST_offset(ii/4);
        
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
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\STSet2.mat','ST')

%% ST2
load ST2_trial1.mat;
ST2_trial1 = data;
load ST2_trial2.mat;
ST2_trial2 = data;
load ST2_trial3.mat;
ST2_trial3 = data;
load ST2_trial4.mat;
ST2_trial4 = data;

%  create single matrix to edit data
ST2 = zeros(length(ST2_trial1(:,1)),4*length(ST2_trial1(1,:)));
ST2(:,1:4) = ST2_trial1(:,1:4);
ST2(:,5:8) = ST2_trial2(:,1:4);
ST2(:,9:12) = ST2_trial3(:,1:4);
ST2(:,13:16) = ST2_trial4(:,1:4);

% data processing
for ii = 4:4:16
    
    % process time values
    ST2(:,ii) = ST2(:,ii) - ST2(1,ii);      %   start time at 0   
    ST2(:,ii) = ST2(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    ST2_offset(1) = 0.28;
    ST2_offset(2) = 0.29;
    ST2_offset(3) = 0.26;
    ST2_offset(4) = 0.37;
    
    % apply time offsets
    ST2(:,ii) = ST2(:,ii) - ST2_offset(ii/4);
        
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
    xlim([0 1])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\ST2Set2.mat','ST2')

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
    VL_offset(1) = 0.24;
    VL_offset(2) = 0.28;
    VL_offset(3) = 0.25;
    VL_offset(4) = 0.24;
    
    % apply time offsets
    VL(:,ii) = VL(:,ii) - VL_offset(ii/4);
        
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
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\VLSet2.mat','VL')

%% GS
load GS_trial1.mat;
GS_trial1 = data;
load GS_trial2.mat;
GS_trial2 = data;
load GS_trial3.mat;
GS_trial3 = data;
load GS_trial4.mat;
GS_trial4 = data;
load GS_trial5.mat;
GS_trial5 = data;

%  create single matrix to edit data
GS = zeros(length(GS_trial1(:,1)),5*length(GS_trial1(1,:)));
GS(:,1:4) = GS_trial1(:,1:4);
GS(:,5:8) = GS_trial2(:,1:4);
GS(:,9:12) = GS_trial3(:,1:4);
GS(:,13:16) = GS_trial4(:,1:4);
GS(:,17:20) = GS_trial5(:,1:4);

% data processing
for ii = 4:4:20
    
    % process time values
    GS(:,ii) = GS(:,ii) - GS(1,ii);      %   start time at 0   
    GS(:,ii) = GS(:,ii)/1000;             %   convert to seconds
    
    % manually enter time offsets
    GS_offset(1) = 0.28;
    GS_offset(2) = 0.11;
    GS_offset(3) = 0.25;
    GS_offset(4) = 0.14;
    GS_offset(5) = 0.18;
    
    % apply time offsets
    GS(:,ii) = GS(:,ii) - GS_offset(ii/4);
        
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
    xlim([0 1])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\GSSet2.mat','GS')

%% Save as an array
Quadruped{1} = IP;
Quadruped{2} = GS;
Quadruped{3} = ST;
Quadruped{4} = ST2;
Quadruped{5} = VL;
Quadruped{6} = BFp;
Quadruped{7} = BFa;

close all
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 2\QuadrupedSet2.mat','Quadruped')