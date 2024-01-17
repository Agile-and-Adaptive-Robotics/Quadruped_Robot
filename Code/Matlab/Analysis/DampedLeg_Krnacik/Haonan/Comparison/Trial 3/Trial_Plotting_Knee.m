load 'ST_trial1.mat';
length = 200;
index1 = 776;
k1 = find(data(:,4)==index1,1);
time.knee = data(k1:k1+length,4);
time.knee = time.knee - time.knee(1);
knee_dat(:,1:3) = data(k1:k1+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,3))
plot([time.knee],knee_dat(:,2))
plot([time.knee],knee_dat(:,1))
hold off
legend('ankle','knee','hip')

load 'ST_trial2.mat'
index2 = 936;
k2 = find(data(:,4)==index2,1);
knee_dat(:,4:6) = data(k2:k2+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,6))
plot([time.knee],knee_dat(:,5))
plot([time.knee],knee_dat(:,4))
hold off

load 'ST_trial3.mat'
index3 = 596;
k3 = find(data(:,4)==index3,1);
knee_dat(:,7:9) = data(k3:k3+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,9))
plot([time.knee],knee_dat(:,8))
plot([time.knee],knee_dat(:,7))
hold off

load 'ST_trial4.mat'
index4 = 826;
k4 = find(data(:,4)==index4,1);
knee_dat(:,10:12) = data(k4:k4+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,12))
plot([time.knee],knee_dat(:,11))
plot([time.knee],knee_dat(:,10))
hold off

load 'ST_trial5.mat'
index5 = 766;
k5 = find(data(:,4)==index5,1);
knee_dat(:,13:15) = data(k5:k5+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,15))
plot([time.knee],knee_dat(:,14))
plot([time.knee],knee_dat(:,13))
hold off

load 'ST_trial6.mat'
index6 = 1076;
k6 = find(data(:,4)==index6,1);
knee_dat(:,16:18) = data(k6:k6+length,1:3);
figure
hold on
plot([time.knee],knee_dat(:,18))
plot([time.knee],knee_dat(:,17))
plot([time.knee],knee_dat(:,16))
hold off