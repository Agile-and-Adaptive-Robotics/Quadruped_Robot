clear;
clc;
close all;

%% Analysis of the knee extensor
% motion analysis
p = [-23.13 ; 16.14];       % mm   resting location of tendon attachment point on knee from center of rotation
q = [44.9 ; 21.65];         % mm   resting location of tendon attachment point on knee extensor muscle from center of rotation


L_rest = 0.182;             % m    does not include end cap length
Pmax = 620;                 % kPa  max pressure available

% From 'Force Equations for Festo Articifial Muscle' - B.Bolen, A.Hunt
a1 = 0.4848;                % N/kPa
a2 = 0.03306;               % 1/(kPa*m)
Fmax = a1*Pmax*atan(a2*pmax*(L_rest-0.0075));       % N   max force of knee extensor

