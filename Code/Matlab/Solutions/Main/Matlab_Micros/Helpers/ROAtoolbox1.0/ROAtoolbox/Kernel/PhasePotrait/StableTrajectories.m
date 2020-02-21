function [traj1, traj2] = StableTrajectories(ProjectOptions, xep)
% Search for the equilibrium point of the system from a point x0.
% Parameters:
%   traj1, traj2    the stable trajectories
%   ProjectOptions    the project options
%   xep        equilibrium point
%
% YUAN Guoqiang, Oct, 2016
%

dd = 0.1 * ProjectOptions.Grid.dx;
tspan = [0, -1000]; % reverse time
[t, x] = Trajectory(ProjectOptions, xep + dd, tspan);
traj1 = {t; x};

tspan = [0, -1000]; % reverse time
[t, x] = Trajectory(ProjectOptions, xep - dd, tspan);
traj2 = {t; x};

