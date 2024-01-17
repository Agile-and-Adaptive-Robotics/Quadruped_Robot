length = 100;
for ii = 1:length
    for jj = 1:18
        ankle_dat_new(ii,jj) = ankle_dat(2*ii,jj);
        hip_dat_new(ii,jj) = hip_dat(2*ii,jj);
        knee_dat_new(ii,jj) = knee_dat(2*ii,jj);
        time_new.ankle(ii) = time.ankle(2*ii)./1000;
        time_new.hip(ii) = time.hip(2*ii)./1000;
        time_new.knee(ii) = time.knee(2*ii)./1000;
    end
end

ankle_dat = deg2rad(ankle_dat_new);
hip_dat = deg2rad(hip_dat_new);
knee_dat = deg2rad(knee_dat_new);
time = time_new;

save(strcat('C:\GitHub\Quadruped_Robot\Code\Matlab\Analysis\DampedLeg_Krnacik\Haonan\Comparison\Trial 3\SpringDampDataHaonanv5.mat'), 'ankle_dat', 'hip_dat', 'knee_dat', 'time')