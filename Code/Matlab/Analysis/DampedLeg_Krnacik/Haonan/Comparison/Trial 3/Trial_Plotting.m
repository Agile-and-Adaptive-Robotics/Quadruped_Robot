load 'GS_trial1.mat';
length = 200;
index1 = 616;
k1 = find(data(:,4)==index1,1);
time.ankle = data(k1:k1+length,4);
time.ankle = time.ankle - time.ankle(1);
ankle_dat(:,1:3) = data(k1:k1+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,3))
plot([time.ankle],ankle_dat(:,2))
plot([time.ankle],ankle_dat(:,1))
hold off
legend('ankle','knee','hip')

load 'GS_trial2.mat'
index2 = 1356;
k2 = find(data(:,4)==index2,1);
ankle_dat(:,4:6) = data(k2:k2+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,6))
plot([time.ankle],ankle_dat(:,5))
plot([time.ankle],ankle_dat(:,4))
hold off

load 'GS_trial3.mat'
index3 = 1356;
k3 = find(data(:,4)==index3,1);
ankle_dat(:,7:9) = data(k3:k3+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,9))
plot([time.ankle],ankle_dat(:,8))
plot([time.ankle],ankle_dat(:,7))
hold off

load 'GS_trial4.mat'
index4 = 766;
k4 = find(data(:,4)==index4,1);
ankle_dat(:,10:12) = data(k4:k4+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,12))
plot([time.ankle],ankle_dat(:,11))
plot([time.ankle],ankle_dat(:,10))
hold off

load 'GS_trial5.mat'
index5 = 826;
k5 = find(data(:,4)==index5,1);
ankle_dat(:,13:15) = data(k5:k5+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,15))
plot([time.ankle],ankle_dat(:,14))
plot([time.ankle],ankle_dat(:,13))
hold off

load 'GS_trial6.mat'
index6 = 736;
k6 = find(data(:,4)==index6,1);
ankle_dat(:,16:18) = data(k6:k6+length,1:3);
figure
hold on
plot([time.ankle],ankle_dat(:,18))
plot([time.ankle],ankle_dat(:,17))
plot([time.ankle],ankle_dat(:,16))
hold off

