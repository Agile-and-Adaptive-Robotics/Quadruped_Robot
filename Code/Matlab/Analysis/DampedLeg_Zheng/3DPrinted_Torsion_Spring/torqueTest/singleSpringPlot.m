%% plot data

LT = 5;
ST = 12;
infill = '100I';

addpath('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\3DPrinted_Torsion_Spring\torqueTest')

springName = strcat('2L',num2str(LT),'LT',num2str(ST),'ST','_',infill);
saveName = strcat('S2L',num2str(LT),'LT',num2str(ST),'ST',infill);
mgrMatrix = {'245Nmm' '613Nmm' '858Nmm' '1226Nmm'};
mgrNames = cell(1,4);

for ii = 1:length(mgrMatrix)
    mgrNames{ii} = strcat('T',mgrMatrix{ii});
end

directions = {'CW' 'CCW'};
trials = {'trial1' 'trial2' 'trial3' 'trial4'};

for ii = 1:length(mgrMatrix)
    mgr = mgrMatrix{ii};
    mgrName = mgrNames{ii};
    figure
    hold on
    for jj = 1:length(directions)
        direction = directions{jj};
        for kk = 1:length(trials)
            trial = trials{kk};
            data = S2L5LT12ST100I.(mgrName).(direction).(trial);
            t = linspace(0,(length(data)-1)/100,length(data));
            plot(t,data)
        end
    end
    title(strcat(saveName,mgrName))
    xlabel('Time (s)')
    ylabel('Displacement (º)')
    xlim([0 1.5])
    hold off
end