load 'VL_trial2.mat';
length = 200;
index1 = 1176;
k1 = find(data(:,4)==index1,1);
time.hip = data(k1:k1+length,4);
time.hip = time.hip - time.hip(1);
hip_dat(:,1:3) = data(k1:k1+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,3))
plot([time.hip],hip_dat(:,2))
plot([time.hip],hip_dat(:,1))
hold off
legend('ankle','knee','hip')

load 'VL_trial3.mat'
index2 = 926;
k2 = find(data(:,4)==index2,1);
hip_dat(:,4:6) = data(k2:k2+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,6))
plot([time.hip],hip_dat(:,5))
plot([time.hip],hip_dat(:,4))
hold off

load 'VL_trial4.mat'
index3 = 1186;
k3 = find(data(:,4)==index3,1);
hip_dat(:,7:9) = data(k3:k3+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,9))
plot([time.hip],hip_dat(:,8))
plot([time.hip],hip_dat(:,7))
hold off

load 'VL_trial5.mat'
index4 = 606;
k4 = find(data(:,4)==index4,1);
hip_dat(:,10:12) = data(k4:k4+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,12))
plot([time.hip],hip_dat(:,11))
plot([time.hip],hip_dat(:,10))
hold off

load 'VL_trial6.mat'
index5 = 1116;
k5 = find(data(:,4)==index5,1);
hip_dat(:,13:15) = data(k5:k5+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,15))
plot([time.hip],hip_dat(:,14))
plot([time.hip],hip_dat(:,13))
hold off

load 'VL_trial7.mat'
index6 = 906;
k6 = find(data(:,4)==index6,1);
hip_dat(:,16:18) = data(k6:k6+length,1:3);
figure
hold on
plot([time.hip],hip_dat(:,18))
plot([time.hip],hip_dat(:,17))
plot([time.hip],hip_dat(:,16))
hold off