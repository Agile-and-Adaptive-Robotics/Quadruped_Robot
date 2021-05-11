P.m1 = 0.1;
P.m2 = 0.1;
P.L = 1;
P.g = 9.81;
tspan = linspace(0,4,25);
y0 = [0; 4; P.L; 20; -pi/2; 2];
opts = odeset('Mass',@(t,q) mass(t,q,P));
[t,q] = ode45(@(t,q) f(t,q,P),tspan,y0,opts)
figure
title('Motion of a Thrown Baton, Solved by ODE45');
axis([0 22 0 25])
hold on
for j = 1:length(t)
   theta = q(j,5);
   X = q(j,1);
   Y = q(j,3);
   xvals = [X X+P.L*cos(theta)];
   yvals = [Y Y+P.L*sin(theta)];
   plot(xvals,yvals)
end
hold off