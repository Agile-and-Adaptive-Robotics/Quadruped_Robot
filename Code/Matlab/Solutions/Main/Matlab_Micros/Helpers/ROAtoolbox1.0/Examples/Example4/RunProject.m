
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
hs = Boundaries(ProjectOptions, phi_t([1, 2, 3, end], 1));
box
grid on

%
% [phiEnlarge, executionTime] = EnlargeROA(ProjectOptions, 0.1, phi);
% [meshxs, meshPhi] = PhiValue(ProjectOptions, phiEnlarge);
% hs = Boundaries(ProjectOptions, phi_t);