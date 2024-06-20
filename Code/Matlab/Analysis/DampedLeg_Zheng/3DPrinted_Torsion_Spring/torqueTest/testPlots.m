t1 = linspace(0,length(data1.data)/100,length(data1.data));
t2 = linspace(0,length(data2.data)/100,length(data2.data));
t3 = linspace(0,length(data3.data)/100,length(data3.data));

data1norm = data1.data ./ data1.data(length(data1.data));
data2norm = data2.data ./ data2.data(length(data2.data));

figure
plot(t1,data1.data);
hold on
plot(t2,data2.data);
plot(t3,data3.data);
title('Torsion Spring Test Behaviours')
xlabel('Time (s)')
ylabel('Angular Deflection (°)')
legend(num2str(data1.torque),num2str(data2.torque),num2str(data2.torque));

figure
plot(t1,data1norm);
hold on
plot(t2,data2norm);
title('Normalized Torsion Spring Test Behaviours')
xlabel('Time (s)')
ylabel('Normalized Angular Deflection (°)')
legend(num2str(data1.torque),num2str(data2.torque));

velocity = zeros(length(data1.data)-1);
tv = zeros(length(data1.data)-1);
for ii = 1:length(velocity)
    velocity(ii) = (data1.data(ii+1)-data1.data(ii))./0.01;
    tv(ii) = t1(ii);
end

figure
plot(t1,data1.data)
hold on
plot(tv,velocity)