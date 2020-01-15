
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

