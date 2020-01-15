function [h, VecField] = PhasePortrait(ProjectOptions, density)
% Compute the phase portrait and draw it.
% Since toolboxLS-1.1.1 uses ndgrid, one should transfer the grid to 
%   mexhgrid-based array.
% Parameters:
%   projectoptions  Project Options for ROAtoolbox
%   densit    the density of trajectories
%   VecField        cell contains the stream.
%   h    handle of trajectories
%
% YUAN Guoqiang, Oct, 2016
%

g = ProjectOptions.Grid;
VF = ProjectOptions.VectorField;
sep = ProjectOptions.InitCircleCen;

if nargin < 2
    switch g.dim
        case 2
            density = 2;
        case 3
            density = 0.4;
    end
end

switch(g.dim)
 case 2
    % 2D phase portrait.    
    [meshxs, U, V] = gridnd2mesh(g, VF{1},VF{2});
    VecField = {U; V};
    MX = meshxs{1};
    MY = meshxs{2};
    figure
    h = streamslice(MX, MY, U, V, density);
    box
    xlabel('x_1'); ylabel('x_2');    
    axis equal;
    axis(g.axis);
 case 3
    % 3D phase portrait.
    [meshxs, U, V, W] = gridnd2mesh(g, VF{1},VF{2}, VF{3});
    VecField = {U; V; W};
    MX = meshxs{1};
    MY = meshxs{2};
    MZ = meshxs{3};
    figure
    h = streamslice(MX, MY, MZ, U, V, W, sep(1), [], [], density);
    streamslice(MX, MY, MZ, U, V, W, [], sep(2), [], density);
    streamslice(MX, MY, MZ, U, V, W, [], [], sep(3), density);
    box
    xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
    axis equal;
    axis(g.axis);
  otherwise
    error('Can not draw phase portrait for system with dimention: %s!', g.dim);
end