function PlotingRatData()

load('JointAngles&time1.mat')
figure;
plot(timeVec(1,:),NWmotion)
title('1')

load('JointAngles&time2.mat')
figure;
plot(timeVec2(1,:),NWmotion2)
title('2')

load('JointAngles&time3.mat')
figure;
plot(timeVec3(1,:),NWmotion3)
title('3')

load('JointAngles&timeNoAct.mat')
figure;
plot(timeVec4(1,:),NWmotion4)
title('4')
Lengths = [175,180.652,139.55,370]
L1 = Lengths(1);
L2 = Lengths(2);
L3 = Lengths(3);
N = Lengths(4);

[]


px=[0 0 0 0];
py=[0 0 0 0];
figure; hold on;
h = plot(px,py,'ro-'); 

axis([-(L1+L2+L3+4) (L1+L2+L3+4) -(L1+L2+L3+4) 4]);
for i=1:N-1
x1 = NWmotion4(i,4);
x2 = 34.657; %tilt of rat hip datacollection
x3 = (x1-x2);
x4 = NWmotion4(i,5);
x5 = x4-x3;
x6 = NWmotion4(i,6);
x7 = x6-x4+x3;
x3 = deg2rad(x3);
x5 = deg2rad(x5);
x7 = deg2rad(x7);

p0x=0;
p0y=0;
p1x = -L1*cos(x3);
p1y = -L1*sin(x3);
p2x = -L1*cos(x3)+L2*cos(x5);
p2y = -(L1*sin(x3)+L2*sin(x5));
p3x = -L1*cos(x3)+L2*cos(x5)-L3*cos(x7);
p3y =  -(L1*sin(x3)+L2*sin(x5)+L3*sin(x7));
px=[p0x p1x p2x p3x];
py=[p0y p1y p2y p3y];

            
            h.XData = px;
            h.YData = py;
            
            drawnow
            pause(0.001)
end
end