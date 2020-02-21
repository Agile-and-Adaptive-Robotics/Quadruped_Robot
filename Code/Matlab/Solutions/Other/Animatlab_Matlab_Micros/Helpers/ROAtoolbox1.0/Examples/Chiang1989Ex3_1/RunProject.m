
% For figure
set(0,'defaultfigurecolor', 'w');

% Set options
ProjectOptions = SetProjectOptions();

% For 2D or 3D systems
[h, VecField] = PhasePortrait(ProjectOptions);

% Estimating the ROA for your project
[ phi, phi_t ] = DeterminingROA(ProjectOptions);


% Draw phi
[meshxs, meshPhi] = PhiValue(ProjectOptions, phi);

%%
hs = Boundaries(ProjectOptions, phi_t([1, 2,  end], 1));
box
grid on
%% exact ROA by reverse trajectories
sty = {'k'; 'LineWidth'; 1};
hold on
xa = [0.04667; 3.11489];
[xa, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xa);
[traj1, traj2] = StableTrajectories(ProjectOptions, xa);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
xb = [-3.03743; 0.33413];
[xb, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xb);
[traj1, traj2] = StableTrajectories(ProjectOptions, xb);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
xc = [-3.147; -3.098];
[xc, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xc);
[traj1, traj2] = StableTrajectories(ProjectOptions, xc);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
xd = [0; -3.153];
[xd, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xd);
[traj1, traj2] = StableTrajectories(ProjectOptions, xd);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
xe = [3.222; 0.3404];
[xe, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xe);
[traj1, traj2] = StableTrajectories(ProjectOptions, xe);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
xf = [2.922; 3.337];
[xf, fval, exitflag, lambda] = SearchForEP(ProjectOptions, xf);
[traj1, traj2] = StableTrajectories(ProjectOptions, xf);
plot(traj1{2}(:,1), traj1{2}(:,2), sty{:});
plot(traj2{2}(:,1), traj2{2}(:,2), sty{:});
