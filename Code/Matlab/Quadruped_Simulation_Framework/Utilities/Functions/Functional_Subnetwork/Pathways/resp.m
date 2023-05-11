t = 0:100;
sig = zeros(size(t));
sig(31:70) = 1 - exp(-t(1:40)/5);
sig(70:101) = exp(-t(1:32)/5);

input = double(t > 30 & t < 70);

figure
subplot(2,1,1)
plot(t,sig,'linewidth',2)
ylabel('Voltage')
subplot(2,1,2)
stairs(t,input,'linewidth',2)
ylabel('Applied current')