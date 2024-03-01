function damping_ratio = dampingRatio(tr, ts)

% This function is designed to calculate the damping ratio of a second order
% system for a given rise time and settling time.

a = 1;
b = -((0.4169/2.917)+((4.5*tr)/(2.917*ts)));
c = 1/2.917;

% zeta = zeros(1,2);
% zeta(1) = (-b + sqrt(b^4 - 4*a*c))/(2*a); % positive value
% zeta(2) = (-b - sqrt(b^4 - 4*a*c))/(2*a); % negative value
% we only want the positive damping ratio returned

zeta = (-b + sqrt(b^4 - 4*a*c))/(2*a);

damping_ratio = zeta;

end