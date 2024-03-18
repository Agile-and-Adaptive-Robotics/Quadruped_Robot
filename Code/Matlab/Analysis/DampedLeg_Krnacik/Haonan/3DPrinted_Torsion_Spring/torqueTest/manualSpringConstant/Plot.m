figure
hold on
plot(T(:,1),kCW(1,:),'.r')
plot(T(:,1),kCCW(1,:),'.b')
plot(T(:,2),kCW(2,:),'.r')
plot(T(:,2),kCCW(2,:),'.b')
plot(T(:,3),kCW(3,:),'.r')
plot(T(:,3),kCCW(3,:),'.b')
plot(T(:,4),kCW(4,:),'.r')
plot(T(:,4),kCCW(4,:),'.b')
plot(T(1,:),kCWavg,'-r')
plot(T(1,:),kCCWavg,'-b')
legend('CW','CCW')
xlabel('Torque Applied (Nm)')
ylabel('Spring Rate (Nm/rad)')
title('S2L5LT4ST100I Spring Rate')
hold off