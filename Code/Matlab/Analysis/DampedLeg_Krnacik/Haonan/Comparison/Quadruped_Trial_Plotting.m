clear
clc
addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison')

%% BFa Trial Data Processing
load BFa_trial1.mat;
load BFa_trial2.mat;
load BFa_trial3.mat;

%  initial conditions
BFa_hip_IC = 108;
BFa_knee_IC = 105;
BFa_ankle_IC = 142;

%  create single matrix to edit data
BFa = zeros(length(BFa_trial1(:,1)),3*length(BFa_trial1(1,:)));
BFa(:,1:4) = BFa_trial1(:,1:4);
BFa(:,5:8) = BFa_trial2(:,1:4);
BFa(:,9:12) = BFa_trial3(:,1:4);

% data processing
for ii = 4:4:12
    BFa(:,ii-3) = BFa(:,ii-3) + BFa_hip_IC;         %   encoder readings start at 0
    BFa(:,ii-2) = BFa(:,ii-2) + BFa_knee_IC;        %   add initial conditions to encoder readings
    BFa(:,ii-1) = BFa(:,ii-1) + BFa_ankle_IC;       
    
    for jj = 2:length(BFa(:,1))                     %   make time values continuous instead of resetting every 1 second
        if BFa(jj,ii) - BFa(jj-1,ii) >= 0
            BFa(jj,ii) = BFa(jj,ii);
        else if BFa(jj,ii) - BFa(jj-1,ii) < 0 && abs(BFa(jj,ii) - BFa(jj-1,ii)) < 1500
                BFa(jj,ii) = BFa(jj,ii) + 1000;
            else
                BFa(jj,ii) = BFa(jj,ii) + 2000;
            end
        end
    end
    
    BFa_offset(1) = 396;             %
    BFa_offset(2) = 296;             %   find time offset (milliseconds) when the leg was dropped for each trial
    BFa_offset(3) = 246;             %
   
    BFa(:,ii) = BFa(:,ii) - BFa_offset(ii/4);
        
    figure
    hold on
    plot(BFa(:,ii),BFa(:,ii-3),'.',"color","k")
    plot(BFa(:,ii),BFa(:,ii-2),'.',"color","b")
    plot(BFa(:,ii),BFa(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("BFa Trial " + ii/4)
    xlabel("time (milliseconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 500])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\BFa.mat','BFa')

%% IP Trial Data Processing
load IP_trial1.mat;
load IP_trial2.mat;
load IP_trial3.mat;

%  initial conditions
IP_hip_IC = 93;
IP_knee_IC = 143;
IP_ankle_IC = 155;

%  create single matrix to edit data
IP = zeros(length(IP_trial1(:,1)),3*length(IP_trial1(1,:)));
IP(:,1:4) = IP_trial1(:,1:4);
IP(:,5:8) = IP_trial2(:,1:4);
IP(:,9:12) = IP_trial3(:,1:4);

% data processing
for ii = 4:4:12
    IP(:,ii-3) = IP(:,ii-3) + IP_hip_IC;         %   encoder readings start at 0
    IP(:,ii-2) = IP(:,ii-2) + IP_knee_IC;        %   add initial conditions to encoder readings
    IP(:,ii-1) = IP(:,ii-1) + IP_ankle_IC;       
    
    for jj = 2:length(IP(:,1))                     %   make time values continuous instead of resetting every 1 second
        if IP(jj,ii) - IP(jj-1,ii) >= 0
            IP(jj,ii) = IP(jj,ii);
        else if IP(jj,ii) - IP(jj-1,ii) < 0 && abs(IP(jj,ii) - IP(jj-1,ii)) < 1500
                IP(jj,ii) = IP(jj,ii) + 1000;
            else
                IP(jj,ii) = IP(jj,ii) + 2000;
            end
        end
    end
    
    IP_offset(1) = 96;             %
    IP_offset(2) = 136;            %   find time offset (milliseconds) when the leg was dropped for each trial
    IP_offset(3) = 136;            %
   
    IP(:,ii) = IP(:,ii) - IP_offset(ii/4);
        
    figure
    hold on
    plot(IP(:,ii),IP(:,ii-3),'.',"color","k")
    plot(IP(:,ii),IP(:,ii-2),'.',"color","b")
    plot(IP(:,ii),IP(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("IP Trial " + ii/4)
    xlabel("time (milliseconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 500])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\IP.mat','IP')

%% ST2 Trial Data Processing
load ST2_trial1.mat;
load ST2_trial2.mat;
load ST2_trial3.mat;

%  initial conditions
ST2_hip_IC = 107;
ST2_knee_IC = 101;      %   *does not match rat leg data - quadruped knee does not have same range of motion
ST2_ankle_IC = 140;

%  create single matrix to edit data
ST2 = zeros(length(ST2_trial1(:,1)),3*length(ST2_trial1(1,:)));
ST2(:,1:4) = ST2_trial1(:,1:4);
ST2(:,5:8) = ST2_trial2(:,1:4);
ST2(:,9:12) = ST2_trial3(:,1:4);

% data processing
for ii = 4:4:12
    ST2(:,ii-3) = ST2(:,ii-3) + ST2_hip_IC;         %   encoder readings start at 0
    ST2(:,ii-2) = ST2(:,ii-2) + ST2_knee_IC;        %   add initial conditions to encoder readings
    ST2(:,ii-1) = ST2(:,ii-1) + ST2_ankle_IC;       
    
    for jj = 2:length(ST2(:,1))                     %   make time values continuous instead of resetting every 1 second
        if ST2(jj,ii) - ST2(jj-1,ii) >= 0
            ST2(jj,ii) = ST2(jj,ii);
        else if ST2(jj,ii) - ST2(jj-1,ii) < 0 && abs(ST2(jj,ii) - ST2(jj-1,ii)) < 1500
                ST2(jj,ii) = ST2(jj,ii) + 1000;
            else
                ST2(jj,ii) = ST2(jj,ii) + 2000;
            end
        end
    end
    
    ST2_offset(1) = 226;             %
    ST2_offset(2) = 186;             %   find time offset (milliseconds) when the leg was dropped for each trial
    ST2_offset(3) = 236;             %
   
    ST2(:,ii) = ST2(:,ii) - ST2_offset(ii/4);   
        
    figure
    hold on
    plot(ST2(:,ii),ST2(:,ii-3),'.',"color","k")
    plot(ST2(:,ii),ST2(:,ii-2),'.',"color","b")
    plot(ST2(:,ii),ST2(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("ST2 Trial " + ii/4)
    xlabel("time (milliseconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 500])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\ST2.mat','ST2')

%% BFp Trial Data Processing
load BFp_trial1.mat;
load BFp_trial2.mat;
load BFp_trial3.mat;

%  initial conditions
BFp_hip_IC = 116;
BFp_knee_IC = 101;
BFp_ankle_IC = 99;

%  create single matrix to edit data
BFp = zeros(length(BFp_trial1(:,1)),3*length(BFp_trial1(1,:)));
BFp(:,1:4) = BFp_trial1(:,1:4);
BFp(:,5:8) = BFp_trial2(:,1:4);
BFp(:,9:12) = BFp_trial3(:,1:4);

% data processing
for ii = 4:4:12
    BFp(:,ii-3) = BFp(:,ii-3) + BFp_hip_IC;         %   encoder readings start at 0
    BFp(:,ii-2) = BFp(:,ii-2) + BFp_knee_IC;        %   add initial conditions to encoder readings
    BFp(:,ii-1) = BFp(:,ii-1) + BFp_ankle_IC;       
    
    for jj = 2:length(BFp(:,1))                     %   make time values continuous instead of resetting every 1 second
        if BFp(jj,ii) - BFp(jj-1,ii) >= 0
            BFp(jj,ii) = BFp(jj,ii);
        else if BFp(jj,ii) - BFp(jj-1,ii) < 0 && abs(BFp(jj,ii) - BFp(jj-1,ii)) < 1500
                BFp(jj,ii) = BFp(jj,ii) + 1000;
            else
                BFp(jj,ii) = BFp(jj,ii) + 2000;
            end
        end
    end
    
    BFp_offset(1) = 196;             %
    BFp_offset(2) = 226;             %   find time offset (milliseconds) when the leg was dropped for each trial
    BFp_offset(3) = 206;             %
   
    BFp(:,ii) = BFp(:,ii) - BFp_offset(ii/4);
        
    figure
    hold on
    plot(BFp(:,ii),BFp(:,ii-3),'.',"color","k")
    plot(BFp(:,ii),BFp(:,ii-2),'.',"color","b")
    plot(BFp(:,ii),BFp(:,ii-1),'.',"color","r")
    legend('hip','knee','ankle')
    title("BFp Trial " + ii/4)
    xlabel("time (milliseconds)")
    ylabel("angle (degrees)")
    ylim([80 180])
    xlim([0 500])
    hold off
end
save('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\BFp.mat','BFp')