
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

%% exact ROA
cirp = genCircle([0; 0], 2, 1000);
plot(cirp(:, 1), cirp(:, 2) ,  'k', 'LineWidth', 1)
