function g = GenerateGrid(ROAToolboxOptions)
% Create the grid.
% Parameters:
%   ROAToolboxOptions  Project Options for ROAtoolbox
%   g            Grid structure on which data was computed. 
%                     g is ndgrid-based.
%
% YUAN Guoqiang, Oct, 2016
%
g.dim = ROAToolboxOptions.GridDimension;
g.min = ROAToolboxOptions.GridRange(:, 1);
g.max = ROAToolboxOptions.GridRange(:, 2);
g.bdry = @addGhostExtrapolate;
g.dx = ROAToolboxOptions.GridCellSize;
g = processGrid(g);
