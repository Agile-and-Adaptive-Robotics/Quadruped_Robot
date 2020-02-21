
% For figure
set(0,'defaultfigurecolor', 'w');

% Set options
ProjectOptions = SetProjectOptions();

% For 2D or 3D systems
[h, VecField] = PhasePortrait(ProjectOptions);

% Estimating the ROA for your project
[ phi, phi_t ] = DeterminingROA(ProjectOptions);
camlight(-30,22);
alpha(0.6);

% Draw phi
[meshxs, meshPhi] = PhiValue(ProjectOptions, phi);
camlight(-30,22);

%%
hs = Boundaries(ProjectOptions, phi_t([1, 2,  end], 1));
camlight(-30,22);
alpha(0.6);