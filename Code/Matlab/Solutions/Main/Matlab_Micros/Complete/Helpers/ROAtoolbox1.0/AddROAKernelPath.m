% Script file that adds the ROA Kernel subdirectories to the path.
%
% Call this script before working with the ROAtoolbox
%   (or place it in your startup.m file).

% Copyright 2016 YUAN Guoqiang.
% This software is used, copied and distributed under the licensing 
%   agreement contained in the file LICENSE in the top directory of 
%   the distribution.
%
% YUAN Guoqiang, Oct, 2016


addpath(genpath(fullfile(pwd, 'toolboxLS-1.1.1', 'ToolboxLS', 'Kernel')));

addpath(genpath(fullfile(pwd, 'ROAtoolbox', 'Kernel')));
