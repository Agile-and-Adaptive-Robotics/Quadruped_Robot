% This script checks that the center of masses are properly defined for the
% equations of motion.

clear, close('all'), clc

% Define theta values in degrees because I hate radians
theta1 = (102) * (pi/180);
theta2 = (118) * (pi/180);
theta3 = (139) * (pi/180);

% Define limb lengths and r values (half of limbs), units don't matter,
% this is just a geomtrey test.
L1 = 2.9;
L2 = 4.1;
L3 = 3.3;
R1 = 1.305;
R2 = 1.558;
R3 = 1.6;

% Now define center of masses in x-y coordinates
m1(1) = R1 * cos(pi - theta1);
m1(2) = R1 * sin(pi - theta1);
m2(1) = L1 * cos(pi - theta1) + R2 * cos(-(theta1 + theta2));
m2(2) = L1 * sin(pi - theta1) + R2 * sin(-(theta1 + theta2));
m3(1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2)) + R3 * cos(theta3 - (theta1 + theta2) + pi);
m3(2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2)) + R3 * sin(theta3 - (theta1 + theta2) + pi);

% Define joint locations for plotting uses
knee = 2 * m1;
ankle(1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2));
ankle(2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2));
toe(1) = L1 * cos(pi - theta1) + L2 * cos(-(theta1 + theta2)) + L3 * cos(theta3 - (theta1 + theta2) + pi);
toe(2) = L1 * sin(pi - theta1) + L2 * sin(-(theta1 + theta2)) + L3 * sin(theta3 - (theta1 + theta2 + pi));

% Plot limbs
figure(1), hold on
plot(-[0 knee(1) ankle(1) toe(1)], -[0 knee(2) ankle(2) toe(2)], '-k', 'LineWidth', 2)

% Plot center of masses
plot(-[m1(1) m2(1) m3(1)], -[m1(2) m2(2) m3(2)], 'or', 'MarkerSize', 6)

% Plot origin and joints
plot(0, 0, 'ob', 'MarkerSize', 6)
plot(-[knee(1) ankle(1)], -[knee(2) ankle(2)], 'ob', 'MarkerSize', 6)

xlim([-10 10])
ylim([-15 5])
