clear
clc

theta1 = linspace(0,2*pi);
R1 = 1;

for t = 0:100
    p1x = R1 .* cos(pi - theta1(t));
    p1y = R1 .* sin(pi - theta1(t));

