norm1CW(:,1) = S2L5LT12ST100I.T245Nmm.CW.trial1;
norm1CW(:,2) = S2L5LT12ST100I.T245Nmm.CW.trial2;
norm1CW(:,3) = S2L5LT12ST100I.T245Nmm.CW.trial3;
norm1CW(:,4) = S2L5LT12ST100I.T245Nmm.CW.trial4;
norm2CW(:,1) = S2L5LT12ST100I.T613Nmm.CW.trial1;
norm2CW(:,2) = S2L5LT12ST100I.T613Nmm.CW.trial2;
norm2CW(:,3) = S2L5LT12ST100I.T613Nmm.CW.trial3;
norm2CW(:,4) = S2L5LT12ST100I.T613Nmm.CW.trial4;
norm3CW(:,1) = S2L5LT12ST100I.T858Nmm.CW.trial1;
norm3CW(:,2) = S2L5LT12ST100I.T858Nmm.CW.trial2;
norm3CW(:,3) = S2L5LT12ST100I.T858Nmm.CW.trial3;
norm3CW(:,4) = S2L5LT12ST100I.T858Nmm.CW.trial4;
norm4CW(:,1) = S2L5LT12ST100I.T1226Nmm.CW.trial1;
norm4CW(:,2) = S2L5LT12ST100I.T1226Nmm.CW.trial2;
norm4CW(:,3) = S2L5LT12ST100I.T1226Nmm.CW.trial3;
norm4CW(:,4) = S2L5LT12ST100I.T1226Nmm.CW.trial4;

% norm1CW(:,1) = norm1CW(:,1) - norm1CW(1,1);
% norm1CW(:,2) = norm2CW(:,2) - norm2CW(1,2);
% norm1CW(:,3) = norm3CW(:,3) - norm3CW(1,3);
% norm1CW(:,4) = norm4CW(:,4) - norm4CW(1,4);

figure
hold on
plot(norm1CW)
% plot(norm2CW)
% plot(norm3CW)
% plot(norm4CW)
hold off
xlim([0 150])

%%
t1 = S2L5LT12ST100I.T245Nmm.mgrValue/1000;
t2 = S2L5LT12ST100I.T613Nmm.mgrValue/1000;
t3 = S2L5LT12ST100I.T858Nmm.mgrValue/1000;
t4 = S2L5LT12ST100I.T1226Nmm.mgrValue/1000;

T = ones(4,4);
T(:,1) = T(:,1)*t1;
T(:,2) = T(:,2)*t2;
T(:,3) = T(:,3)*t3;
T(:,4) = T(:,4)*t4;

idx1CW(1,1) = find(norm1CW(:,1)>0,1);
idx1CW(1,2) = find(norm1CW(:,2)>0,1);
idx1CW(1,3) = find(norm1CW(:,3)>0,1);
idx1CW(1,4) = find(norm1CW(:,4)>0,1);
idx2CW(1,1) = find(norm2CW(:,1)>0,1);
idx2CW(1,2) = find(norm2CW(:,2)>0,1);
idx2CW(1,3) = find(norm2CW(:,3)>0,1);
idx2CW(1,4) = find(norm2CW(:,4)>0,1);
idx3CW(1,1) = find(norm3CW(:,1)>0,1);
idx3CW(1,2) = find(norm3CW(:,2)>0,1);
idx3CW(1,3) = find(norm3CW(:,3)>0,1);
idx3CW(1,4) = find(norm3CW(:,4)>0,1);
idx4CW(1,1) = find(norm4CW(:,1)>0,1);
idx4CW(1,2) = find(norm4CW(:,2)>0,1);
idx4CW(1,3) = find(norm4CW(:,3)>0,1);
idx4CW(1,4) = find(norm4CW(:,4)>0,1);

%%
k1CW(1,1) = t1/deg2rad(norm1CW(160,1));
k1CW(1,2) = t1/deg2rad(norm1CW(idx1CW(1,2)+150,2));
k1CW(1,3) = t1/deg2rad(norm1CW(idx1CW(1,3)+150,3));
k1CW(1,4) = t1/deg2rad(norm1CW(idx1CW(1,4)+150,4));
k2CW(1,1) = t2/deg2rad(norm2CW(idx2CW(1,1)+150,1));
k2CW(1,2) = t2/deg2rad(norm2CW(idx2CW(1,2)+150,2));
k2CW(1,3) = t2/deg2rad(norm2CW(idx2CW(1,3)+150,3));
k2CW(1,4) = t2/deg2rad(norm2CW(idx2CW(1,4)+150,4));
k3CW(1,1) = t3/deg2rad(norm3CW(idx3CW(1,1)+150,1));
k3CW(1,2) = t3/deg2rad(norm3CW(idx3CW(1,2)+150,2));
k3CW(1,3) = t3/deg2rad(norm3CW(idx3CW(1,3)+150,3));
k3CW(1,4) = t3/deg2rad(norm3CW(idx3CW(1,4)+150,4)); 
k4CW(1,1) = t4/deg2rad(norm4CW(idx4CW(1,1)+150,1));
k4CW(1,2) = t4/deg2rad(norm4CW(idx4CW(1,2)+150,2));
k4CW(1,3) = t4/deg2rad(norm4CW(idx4CW(1,3)+150,3));
k4CW(1,4) = t4/deg2rad(norm4CW(idx4CW(1,4)+150,4));

kCW = [k1CW ; k2CW ; k3CW ; k4CW];
kCWavg = [mean(k1CW) mean(k2CW) mean(k3CW) mean(k4CW)];
figure
plot(kCW,'o')
title('CW')

%%
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
norm1 = norm1/norm1(end);
norm2 = norm2/norm2(end);
norm3 = norm3/norm3(end);
norm4 = norm4/norm4(end);

norm1 = norm1(10:end,1);
norm2 = norm2(idx2CW:end,1);
norm3 = norm3(idx3CW:end,1);
norm4 = norm4(idx4CW:end,1);

figure
hold on
plot(norm1)
plot(norm2)
plot(norm3)
plot(norm4)
hold off
xlim([0 150])
legend(num2str(t1),num2str(t2),num2str(t3),num2str(t4))