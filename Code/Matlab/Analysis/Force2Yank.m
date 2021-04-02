function dFs = Force2Yank( Fs, ts )

% This function computes the yank (time derivative of force) given forces and an associated time scaling.

% Retrieve the number of muscles.
num_muscles = size(Fs, 1);

% Compute the time derivative of force.
dFs = diff(Fs, 1, 2)./repmat(diff(ts), [num_muscles 1]);

% Duplicate the last entry to preserve matrix dimensions.
dFs = [dFs dFs(:, end)];

end

