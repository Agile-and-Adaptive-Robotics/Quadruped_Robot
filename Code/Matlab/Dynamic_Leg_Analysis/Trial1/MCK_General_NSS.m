clear
close all

starttime = 0;
endtime = 2;
est_max = 1.1;
est_min = -1.1;

dt = 0.002;
t = 0:dt:endtime;

M = 1;
C = .5;
K = 200;

x = zeros(3,length(t));

x(1,1) = 1; %position;
x(2,1) = 0; %velocity;
x(3,1) = 0; %acceleration;

figure
h = plot(t(1),x(1),'-r','linewidth',4);
xlim([starttime endtime]);
ylim([est_min est_max]);

for i=2:length(t)
    x(3,i) = 1/(M)*(-K*x(1,i-1)-C*x(2,i-1));
    x(2,i) = x(2,i-1) + x(3,i)*dt;
    x(1,i) = x(1,i-1) + x(2,i)*dt + 1/2*x(3,i)*dt^2;
    
    h.XData = t(1:i);
    h.YData = x(1,1:i);
    drawnow;
end


