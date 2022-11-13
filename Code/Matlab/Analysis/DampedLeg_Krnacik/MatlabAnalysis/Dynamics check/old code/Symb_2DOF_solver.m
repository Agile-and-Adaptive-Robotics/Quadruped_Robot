function [fx1, fx2] = Symb_2DOF_solver()
% JOE'S CODE - with some modifications

% Symbolically solves equations of motion. 
% Theta value were altered, and so coordinate designation was also changed.

clear;close all;clc;

syms M1 M2 M3;
syms x1 x1d x1dd x2 x2d x2dd x3 x3d x3dd;
syms L1 L2 L3;
syms R1 R2 R3;
syms b1 b2 b3 b4 b5 b6;
syms K1 K2 K3 K4 K5 K6;
syms theta1bias theta2bias theta3bias theta4bias theta5bias theta6bias;
syms I1 I2 I3;
syms u1 u2 u3;
syms g;

% Coordinates of center of masses of each point of 3-link pendulum. Theta
% values are measured between the negative horizontal (right direction) and
% the back of the thigh, the back of the thigh to the back of the calf, and
% the front of the shin to the top of the foot, respectively.
p1x = R1 * cos(pi - x1);
p1y = R1 * sin(pi - x1);
p2x = L1 * cos(pi - x1) + R2 * cos(-(x1 + x2));
p2y = L1 * sin(pi - x1) + R2 * sin(-(x1 + x2));
p3x = L1 * cos(pi - x1) + L2 * cos(-(x1 + x2)) + R3 * cos(x3 - (x1 + x2) + pi);
p3y = L1 * sin(pi - x1) + L2 * sin(-(x1 + x2)) + R3 * sin(x3 - (x1 + x2) + pi);

% First derivative of each point
v1x = diff(p1x);
v1y = diff(p1y);
v2x = diff(p2x);
v2y = diff(p2y);
v3x = diff(p3x);
v3y = diff(p3y);

% I think these are friction values
D1 = u1*M1*g*R1*x1d;
D2 = u2*M2*g*R2*x2d;
D3 = u3*M3*g*R3*x3d;

% Kinetic Energy equation (unverified)
KE1 = 0.5*I1*(x1d)^2;
KE2 = 0.5*I2*(x2d)^2 + 0.5*M2*(x1d * L1)^2;
KE1 = simplify(KE1);
KE2 = simplify(KE2);

% Potential energy is defined with positive y-axis pointing downward, so
% the zero PE for each link is defined as the lowest point the center of
% mass can reach.
PE1 = M1*g*(R1 - p1y);
PE2 = M2*g*(L1 + R2 - p2y);
PE3 = M3*g*(L1 + L2 + R3 - p3y);
PE1 = simplify(PE1);
PE2 = simplify(PE2);

% Joint torques. Note that Joe's version had the u (friction values
% replaced with the commented out portion. Friction appeared to be unused
% in his model.
Px1 = -b1*x1d - K1*(x1+theta1bias) - u1*sign(x1d);%(b4*x1d+K4*(x1+theta4bias));
Px2 = -b2*x2d - K2*(x2+theta2bias) - u2*sign(x2d);%(b5*x1d+K5*(x1+theta5bias));
Px3 = b3*x3d + K3*(x3+theta3bias) - u3*sign(x3d);%(b6*x1d+K6*(x1+theta6bias));

pKEpx1d = diff(KE1,x1d);
ddtpKEpx1d = diff(pKEpx1d,x1)*x1d+ ...
             diff(pKEpx1d,x1d)*x1dd + ...
             diff(pKEpx1d,x2)*x2d + ...
             diff(pKEpx1d,x2d)*x2dd + ...
             diff(pKEpx1d,x3)*x3d + ...
             diff(pKEpx1d,x3d)*x3dd;
pKEpx1 = diff(KE1,x1);
pPEpx1 = diff(PE1,x1);

pKEpx2d = diff(KE2,x2d);
ddtpKEpx2d = diff(pKEpx2d,x1)*x1d+ ...
             diff(pKEpx2d,x1d)*x1dd + ...
             diff(pKEpx2d,x2)*x2d + ...
             diff(pKEpx2d,x2d)*x2dd + ...
             diff(pKEpx2d,x3)*x3d + ...
             diff(pKEpx2d,x3d)*x3dd;
pKEpx2 = diff(KE2,x2);
pPEpx2 = diff(PE2,x2);
% 
% pKEpx3d = diff(KE,x3d);
% ddtpKEpx3d = diff(pKEpx3d,x1)*x1d+ ...
%              diff(pKEpx3d,x1d)*x1dd+ ...
%              diff(pKEpx3d,x2)*x2d + ...
%              diff(pKEpx3d,x2d)*x2dd + ...
%              diff(pKEpx3d,x3)*x3d + ...
%              diff(pKEpx3d,x3d)*x3dd;
% pKEpx3 = diff(KE,x3);
% pPEpx3 = diff(PE,x3);

eqx1 = simplify( ddtpKEpx1d - pKEpx1 + pPEpx1 - Px1);
eqx2 = simplify( ddtpKEpx2d - pKEpx2 + pPEpx2 - Px2);
% eqx3 = simplify( ddtpKEpx3d - pKEpx3 + pPEpx3 - Px3);

% Sol = solve(eqx1,eqx2,eqx3,x1dd,x2dd,x3dd);
Sol = solve(eqx1,eqx2,x1dd,x2dd);
% Sol.x1dd = simplify(Sol.x1dd);
% Sol.x2dd = simplify(Sol.x2dd);
% Sol.x3dd = simplify(Sol.x3dd);
% 
syms y1 y2 y3 y4 y5 y6
fx1=subs(Sol.x1dd,{x1,x1d,x2,x2d},{y1,y2,y3,y4});
fx2=subs(Sol.x2dd,{x1,x1d,x2,x2d},{y1,y2,y3,y4});
% fx1=subs(Sol.x1dd,{x1,x1d,x2,x2d,x3,x3d},{y1,y2,y3,y4,y5,y6})
% fx2=subs(Sol.x2dd,{x1,x1d,x2,x2d,x3,x3d},{y1,y2,y3,y4,y5,y6})
% fx3=subs(Sol.x3dd,{x1,x1d,x2,x2d,x3,x3d},{y1,y2,y3,y4,y5,y6})

end