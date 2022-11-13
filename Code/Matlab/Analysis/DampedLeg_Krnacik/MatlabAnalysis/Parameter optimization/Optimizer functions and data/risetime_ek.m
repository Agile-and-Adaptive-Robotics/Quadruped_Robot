function RiseTime = risetime_ek(y, t)

% This is a function intended to calculate the risetime for an overdamped
% system. Both negative and positive inputs are acceptable. Y-axis data is
% y, t is time is seconds. Function assumes that data is at steady state by
% the end of the y array.

% Calculate steady state from y array
stst = y(end);

% Calculate input value difference between y(1) and steady state value (in
% rad for dynamic leg)
input = abs( y(1) - stst );

% Create an array where input is zero and data rises to steady state of 1
y = abs(y - y(1));
y = y / y(end);

% Interpolate data so that risetime may be more accurate
tt = 0:0.0001:t(end);
yy = spline(t, y, tt);

% Find range of y where data rises up/crosses steady state value (1)
locs = find(yy>=0.9);
rise_range = yy(1:locs(1));

% Find range of y where data is between 0.1 and 0.9, and define first
% ocsillation range
rise_range_idx = find(rise_range>=0.1 & rise_range<=0.9);

% Find the time difference of this range
RiseTime = tt( rise_range_idx(end) - rise_range_idx(1) );

end


