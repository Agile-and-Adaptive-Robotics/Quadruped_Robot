function [t, x] = Trajectory(projectoptions, x0, tspan)
% Create the grid.
% Parameters:
%   projectoptions   Project Options for ROAtoolbox
%   x0   Integrate initial point
%   tspan  Integrate time
%
% YUAN Guoqiang, Oct, 2016
%

% Adjust integrate range
xspan = projectoptions.GridRange;
% wd = xspan(:,2) -  xspan(:,1);
% dd = [wd, -wd] * 0.02;
% xspan = xspan + dd;

fx = projectoptions.VectorFieldOperator;
hftx = @(t, x) fx(x); 
[t,x] = odeSolwithSpan(hftx, tspan, x0, xspan);