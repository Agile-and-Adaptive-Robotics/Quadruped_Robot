
% For figure
set(0,'defaultfigurecolor', 'w');

% Set options
ProjectOptions = SetProjectOptions();

% Phase portrait, for 2D or 3D systems
[h, VecField] = PhasePortrait(ProjectOptions);

% Estimating the ROA for your project
[ phi, phi_t ] = DeterminingROA(ProjectOptions);


%% Draw phi, for 2D or 3D systems
[meshxs, meshPhi] = PhiValue(ProjectOptions, phi);

%%
hs = Boundaries(ProjectOptions, phi_t([1, 2,  end], 1));
box
grid on

%% Trajectories
sty = {'k'; 'LineWidth'; 1};
% tspan = [0, -20]; % reverse time
% [~, x] = Trajectory(ProjectOptions, [0, -0.001], tspan);
% plot(x(:,1),x(:,2), 'r')
tspan = [0, -20]; % reverse time
[~, x] = Trajectory(ProjectOptions, [0, 0.001], tspan);
plot(x(:,1),x(:,2), sty{:})
% tspan = [0, 20]; % forward time
% [~, x] = Trajectory(ProjectOptions, [ - 0.001, 0], tspan);
% plot(x(:,1),x(:,2), 'r')
tspan = [0, -20]; % reverse time
[~, x] = Trajectory(ProjectOptions, [pi - 0.001, 0], tspan);
plot(x(:,1),x(:,2), sty{:})
tspan = [0, -20]; % reverse time
[~, x] = Trajectory(ProjectOptions, [pi, pi - 0.001], tspan);
plot(x(:,1),x(:,2), sty{:})
tspan = [0, -20]; % reverse time
[~, x] = Trajectory(ProjectOptions, [0.001, pi], tspan);
plot(x(:,1),x(:,2), sty{:})

