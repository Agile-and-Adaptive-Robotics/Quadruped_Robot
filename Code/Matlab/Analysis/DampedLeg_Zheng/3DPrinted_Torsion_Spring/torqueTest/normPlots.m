figure
plot(t,data1norm)
hold on
plot(t,data2norm)
plot(t,data3norm)

legend(num2str(data1.torque),num2str(data2.torque),num2str(data3.torque))
title('Normalized Step Response of 2L3LT4ST_37')
xlabel('Time (s)')
ylabel('Normalized Angular Displacement')
