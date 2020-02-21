function cirp = genCircle(center,radius,pcnt)
% generate circle point
% pcnt for the count of points
% cirp    points lie on the circle [x; y]
% by Guoqiang Yuan
% Sep 2015
%
delta = 2*pi/pcnt;
theta = 0:delta:2*pi-delta;
cirp = [radius*cos(theta)+center(1); ...
          radius*sin(theta)+center(2)].';