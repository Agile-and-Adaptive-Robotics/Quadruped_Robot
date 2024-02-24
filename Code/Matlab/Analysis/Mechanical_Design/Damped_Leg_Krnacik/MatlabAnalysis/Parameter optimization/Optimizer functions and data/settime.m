function settling_time = settime(t, x)

% This function is designed to calculate a settling time for a given data
% set, assuming time is seconds. It assumes x is has reached steady state
% value by the last value.

% Calculate the "input" value
input_val = abs(x(end) - x(1));

% Calculate the upper and lower cutoff
colow   = x(end) - (0.1 * input_val);
cohigh  = x(end) + (0.1 * input_val);

% Find incdices where x values exceed settling time cutoffs
idx = find((x>cohigh | x<colow));

% Find point in time where last cutoff crossing occurs
settling_time = t(idx(end));


end