norm1 = S2L5LT4ST100I.T120Nmm.CW.trial1;
norm2 = S2L5LT4ST100I.T200Nmm.CW.trial1;
norm3 = S2L5LT4ST100I.T300Nmm.CW.trial1;
norm4 = S2L5LT4ST100I.T400Nmm.CW.trial1;

t1 = S2L5LT4ST100I.T120Nmm.mgrValue/1000;
t2 = S2L5LT4ST100I.T200Nmm.mgrValue/1000;
t3 = S2L5LT4ST100I.T300Nmm.mgrValue/1000;
t4 = S2L5LT4ST100I.T400Nmm.mgrValue/1000;
T = [t1 ; t2 ; t3 ; t4];

figure
hold on
plot(norm1)
plot(norm2)
plot(norm3)
plot(norm4)
hold off
xlim([0 150])

legend(num2str(t1),num2str(t2),num2str(t3),num2str(t4))
idx1 = find(norm1>0,1);
idx2 = find(norm2>0,1);
idx3 = find(norm3>0,1);
idx4 = find(norm4>0,1);

k1 = t1/deg2rad(norm1(idx1+150));
k2 = t2/deg2rad(norm2(idx2+150));
k3 = t3/deg2rad(norm3(idx3+150));
k4 = t4/deg2rad(norm4(idx4+150));

kCW = [k1 ; k2 ; k3 ; k4];
figure
plot(kCW,'o')
title('CW')

norm1 = norm1/norm1(end);
norm2 = norm2/norm2(end);
norm3 = norm3/norm3(end);
norm4 = norm4/norm4(end);

norm1 = norm1(12:end,1);
norm2 = norm2(35:end,1);
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