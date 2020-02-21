function [ ps_normal_boundary ] = GetBivariateNormalBoundary( mean_vec, cov_matrix, num_stds )

ts_circle = linspace(0, 2*pi, 100);
xs_circle = cos(ts_circle);
ys_circle = sin(ts_circle);

ps_circle = [xs_circle; ys_circle; ones(1, length(xs_circle))];

dx = mean_vec(1); dy = mean_vec(2);
[R, S] = eig(cov_matrix);

S = num_stds*sqrt(S);

R = [R zeros(size(R, 1), 1); zeros(1, size(R, 2)) 1];
S = [S zeros(size(S, 1), 1); zeros(1, size(S, 2)) 1];
T = [1 0 dx; 0 1 dy; 0 0 1];

ps_normal_boundary = T*R*S*ps_circle;


end

