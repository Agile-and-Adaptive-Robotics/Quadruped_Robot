function [dLmuscles, ddLmuscles] = GetMuscleVelAccel(Lmuscles, ts)

% Retrieve the number of muscles.
num_muscles = size(Lmuscles, 1);

% Compute the muscle velocity.
dLmuscles = diff(Lmuscles, 1, 2)./repmat(diff(ts), [num_muscles 1]);
dLmuscles = [dLmuscles dLmuscles(:, end)];

% Compute the muscle accelerations.
ddLmuscles = diff(dLmuscles, 1, 2)./repmat(diff(ts), [num_muscles 1]);
ddLmuscles = [ddLmuscles ddLmuscles(:, end)];

end

