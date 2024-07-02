norm1CCW(:,1) = -S2L5LT12ST100I.T245Nmm.CCW.trial1;
norm1CCW(:,2) = -S2L5LT12ST100I.T245Nmm.CCW.trial2;
norm1CCW(:,3) = -S2L5LT12ST100I.T245Nmm.CCW.trial3;
norm1CCW(:,4) = -S2L5LT12ST100I.T245Nmm.CCW.trial4;
norm2CCW(:,1) = -S2L5LT12ST100I.T613Nmm.CCW.trial1;
norm2CCW(:,2) = -S2L5LT12ST100I.T613Nmm.CCW.trial2;
norm2CCW(:,3) = -S2L5LT12ST100I.T613Nmm.CCW.trial3;
norm2CCW(:,4) = -S2L5LT12ST100I.T613Nmm.CCW.trial4;
norm3CCW(:,1) = -S2L5LT12ST100I.T858Nmm.CCW.trial1;
norm3CCW(:,2) = -S2L5LT12ST100I.T858Nmm.CCW.trial2;
norm3CCW(:,3) = -S2L5LT12ST100I.T858Nmm.CCW.trial3;
norm3CCW(:,4) = -S2L5LT12ST100I.T858Nmm.CCW.trial4;
norm4CCW(:,1) = -S2L5LT12ST100I.T1226Nmm.CCW.trial1;
norm4CCW(:,2) = -S2L5LT12ST100I.T1226Nmm.CCW.trial2;
norm4CCW(:,3) = -S2L5LT12ST100I.T1226Nmm.CCW.trial3;
norm4CCW(:,4) = -S2L5LT12ST100I.T1226Nmm.CCW.trial4;

% norm1CCW(:,1) = norm1CCW(:,1) - norm1CCW(1,1);
% norm1CCW(:,2) = norm2CCW(:,2) - norm2CCW(1,2);
% norm1CCW(:,3) = norm3CCW(:,3) - norm3CCW(1,3);
% norm1CCW(:,4) = norm4CCW(:,4) - norm4CCW(1,4);

figure
hold on
plot(norm1CCW)
% plot(norm2CCW)
% plot(norm3CCW)
% plot(norm4CCW)
hold off
xlim([0 150])
%%
t1 = S2L5LT12ST100I.T245Nmm.mgrValue/1000;
t2 = S2L5LT12ST100I.T613Nmm.mgrValue/1000;
t3 = S2L5LT12ST100I.T858Nmm.mgrValue/1000;
t4 = S2L5LT12ST100I.T1226Nmm.mgrValue/1000;

T = [t1 ; t2 ; t3 ; t4];

legend(num2str(t1),num2str(t2),num2str(t3),num2str(t4))
idx1(1,1) = find(norm1CCW(:,1)>0,1);
idx1(1,2) = find(norm1CCW(:,2)>0,1);
idx1(1,3) = find(norm1CCW(:,3)>0,1);
idx1(1,4) = find(norm1CCW(:,4)>0,1);
idx2(1,1) = find(norm2CCW(:,1)>0,1);
idx2(1,2) = find(norm2CCW(:,2)>0,1);
idx2(1,3) = find(norm2CCW(:,3)>0,1);
idx2(1,4) = find(norm2CCW(:,4)>0,1);
idx3(1,1) = find(norm3CCW(:,1)>0,1);
idx3(1,2) = find(norm3CCW(:,2)>0,1);
idx3(1,3) = find(norm3CCW(:,3)>0,1);
idx3(1,4) = find(norm3CCW(:,4)>0,1);
idx4(1,1) = find(norm4CCW(:,1)>0,1);
idx4(1,2) = find(norm4CCW(:,2)>0,1);
idx4(1,3) = find(norm4CCW(:,3)>0,1);
idx4(1,4) = find(norm4CCW(:,4)>0,1);
%%
k1(1,1) = t1/deg2rad(norm1CCW(idx1(1,1)+150,1));
k1(1,2) = t1/deg2rad(norm1CCW(idx1(1,2)+150,2));
k1(1,3) = t1/deg2rad(norm1CCW(idx1(1,3)+150,3));
k1(1,4) = t1/deg2rad(norm1CCW(idx1(1,4)+150,4));
k2(1,1) = t2/deg2rad(norm2CCW(idx2(1,1)+150,1));
k2(1,2) = t2/deg2rad(norm2CCW(idx2(1,2)+150,2));
k2(1,3) = t2/deg2rad(norm2CCW(idx2(1,3)+150,3));
k2(1,4) = t2/deg2rad(norm2CCW(idx2(1,4)+150,4));
k3(1,1) = t3/deg2rad(norm3CCW(idx3(1,1)+150,1));
k3(1,2) = t3/deg2rad(norm3CCW(idx3(1,2)+150,2));
k3(1,3) = t3/deg2rad(norm3CCW(idx3(1,3)+150,3));
k3(1,4) = t3/deg2rad(norm3CCW(idx3(1,4)+150,4));
k4(1,1) = t4/deg2rad(norm4CCW(idx4(1,1)+150,1));
k4(1,2) = t4/deg2rad(norm4CCW(idx4(1,2)+150,2));
k4(1,3) = t4/deg2rad(norm4CCW(idx4(1,3)+150,3));
k4(1,4) = t4/deg2rad(norm4CCW(idx4(1,4)+150,4));

kCCW = [k1 ; k2 ; k3 ; k4];
kCCWavg = [mean(k1) mean(k2) mean(k3) mean(k4)];
figure
plot(kCCW,'o')
title('CCW')
%%
norm1 = norm1/norm1(end);
norm2 = norm2/norm2(end);
norm3 = norm3/norm3(end);
norm4 = norm4/norm4(end);

norm1 = norm1(15:end,1);
norm2 = norm2(idx2:end,1);
norm3 = norm3(idx3:end,1);
norm4 = norm4(idx4:end,1);

figure
hold on
plot(norm1)
plot(norm2)
plot(norm3)
plot(norm4)
hold off
xlim([0 150])
legend(num2str(t1),num2str(t2),num2str(t3),num2str(t4))