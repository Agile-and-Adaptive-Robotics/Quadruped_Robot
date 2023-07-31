function theta = vecangle(u, v)

% Compute the angle between the given vectors.
theta = atan2( norm(cross(u, v)), dot(u, v) );

end

