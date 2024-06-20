addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest\manualSpringConstant');
close all

trials = {'trial1' 'trial2' 'trial3' 'trial4'};
mgrs = {'T20Nmm' 'T40Nmm' 'T100Nmm' 'T200Nmm'};
T = ones(1,16);

for ii = 1:4
    mgr = mgrs{ii};
    t(1,ii) = S2L3LT4ST37T.(mgr).mgrValue/1000;
    for jj = 1:4
        trial = trials{jj};
        num = (ii-1)*4+jj;
        normCW(:,num) = S2L3LT4ST37T.(mgr).CW.(trial);
        idxCW(1,num) = find(normCW(:,num)>0,1);
        normCCW(:,num) = -S2L3LT4ST37T.(mgr).CCW.(trial);
        idxCCW(1,num) = find(normCCW(:,num)>0,1);
        T(1,num) = t(1,ii);
        kCW(1,num) = t(1,ii)/deg2rad(normCW(idxCW(1)+150,num));
        kCCW(1,num) = t(1,ii)/deg2rad(normCCW(idxCCW(1)+150,num));
    end
    kCWavg(ii) = mean(kCW(1,4*ii-3:4*ii));
    kCCWavg(ii) = mean(kCCW(1,4*ii-3:4*ii));
end

%%
figure
hold on
for yy = 1:16
    plot(normCW(idxCW(yy):end,yy))
end
hold off
xlim([0 150])
title('CW')

figure
hold on
for yy = 1:16
    plot(normCCW(idxCCW(yy):end,yy))
end
hold off
xlim([0 150])
title('CCW')

%% plot spring rates
figure
hold on
for kk = 1:4
    plot(T(1,4*kk-3:4*kk),kCW(1,4*kk-3:4*kk),'.r')
    plot(T(1,4*kk-3:4*kk),kCCW(1,4*kk-3:4*kk),'.b')
end
plot(t,kCWavg,'-r')
plot(t,kCCWavg,'-b')
legend('CW','CCW')
xlabel('Torque Applied (Nm)')
ylabel('Spring Rate (Nm/rad)')
title('S2L3LT4ST37T Spring Rate')
hold off
