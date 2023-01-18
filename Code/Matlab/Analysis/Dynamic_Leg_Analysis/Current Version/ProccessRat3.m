%data = ProccessRat3()
load('JointAngles&time2.mat');
figure
plot(NWmotion2)
x1 = NWmotion2(10:100,1);
x2 = 34.657; %tilt of rat hip datacollection
x3 = 180-(x1-x2);
x4 = NWmotion2(10:100,2);
x5 = -(180-x4);
x6 = NWmotion2(10:100,3);
x7 = 180-x6;
RatHipAngle = deg2rad(x3);
RatKneeAngle = deg2rad(x5);
RatAnkleAngle = deg2rad(x7);
totalTime = timeVec2(10:100)';
data = [RatHipAngle,RatKneeAngle,RatAnkleAngle,totalTime];
