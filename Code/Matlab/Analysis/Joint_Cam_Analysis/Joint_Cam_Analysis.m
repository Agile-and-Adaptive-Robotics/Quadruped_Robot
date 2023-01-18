%% Joint Cam Analysis

% Clear Everything.
clear, close('all'), clc


%% Setup the Problem.

% Define the circle radius.
r = 1;

% Define the circle thetas.
ts = linspace(0, 2*pi, 100);

% Define the circle points.
xs_circle = r*cos(ts - pi/2);
ys_circle = r*sin(ts - pi/2);

% Define the actuation point.
P0 = [r; r];

% Define the starting point.
P1 = [0; -r];

% Define all possible ending points.
P2s = [xs_circle; ys_circle];


%% Compute the Length Changes.

% Compute the position of the starting point with respect to the actuation point.
P10 = P1 - P0;

% Compute the position of the sending point with respect to the actuation point.
P20s = P2s - P0;

% Comptue the distance between the actuation point and the starting & ending actuation points.
L10 = norm(P10, 2);
L20s = vecnorm(P20s, 2, 1);

% Compute the length change associated with each starting and ending point.
deltaLs = L20s - L10;

% Compute the minimum possible length change value.
[deltaLs_min, index] = min(deltaLs);

% Retrieve the angle associated with the minimum length change.
theta_crit = ts(index);

% Define the rotation matrix associated with the critical angle.
R = [cos(theta_crit) -sin(theta_crit) 0; sin(theta_crit) cos(theta_crit) 0; 0 0 1];

% Retrieve only the relevant joint angles and length changes.
thetas = ts(1:index);
deltaLs = deltaLs(1:index);

% Define the arc length associated with the joint angles.
arclengths = -r*thetas;

% Define the final ending point.
P2 = R*[P1; 1];


%% Plot the Length Changes

% Plot the length change vs joint angle.
figure('Color', 'w'), hold on, grid on, xlabel('Angle [deg]'), ylabel('Length Change [in]'), title('Length Change vs Angle'), xlim([0, (180/pi)*theta_crit])
plot((180/pi)*thetas, deltaLs, '-', 'Linewidth', 3)

% Plot the arclength vs joint angle.
figure('Color', 'w'), hold on, grid on, xlabel('Angle [deg]'), ylabel('Arclength [in]'), title('Length Change vs Angle'), xlim([0, (180/pi)*theta_crit])
plot((180/pi)*thetas, arclengths, '-', 'Linewidth', 3)

% Plot the length changes and arclength vs joint angle.
figure('Color', 'w'), hold on, grid on, xlabel('Angle [deg]'), ylabel('Length Change [in]'), title('Length Change vs Angle'), xlim([0, (180/pi)*theta_crit])
plot((180/pi)*thetas, deltaLs, 'b-', 'Linewidth', 3)
plot((180/pi)*thetas, arclengths, 'r-', 'Linewidth', 3)
legend('Length Change', 'Arclength')

% Plot the joint configuration.
figure('Color', 'w'), hold on, grid on, xlabel('x'), ylabel('y'), title('Strain Demonstration')
plot(xs_circle, ys_circle, '-k', 'Linewidth', 1)
plot(xs_circle(1:index), ys_circle(1:index), '-r', 'Linewidth', 3)
plot([P0(1) P1(1)], [P0(2) P1(2)], '-b', 'Linewidth', 3)
plot([P0(1) P2(1)], [P0(2) P2(2)], '-b', 'Linewidth', 3)
plot(P0(1), P0(2), '.g', 'Markersize', 20)
plot(P1(1), P1(2), '.r', 'Markersize', 20)
plot(P2(1), P2(2), '.m', 'Markersize', 20)

