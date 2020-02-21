function [phiEnlarge, executionTime] = EnlargeROA(ProjectOptions, EvolutionTime, phi0)
% Enlarge phi0 to phiEnlarge 
% Parameters:
%   ProjectOptions  Project Options for ROAtoolbox
%   phi0        Implicit surface function for initial set.
%   phiEnlarge        Implicit surface function for ROA.
%
% YUAN Guoqiang, Oct, 2016
%

if nargin < 3
    phi0 = ProjectOptions.InitialCondition;
end
%%
accuracy = ProjectOptions.accuracy;
g = ProjectOptions.Grid;
VecField = ProjectOptions.VectorField ;
% Mind the minus
% Multiply by -1 to get backward field
for ii = 1:size(VecField)
    VecField{ii} = -VecField{ii};
end


%%
growOnly = 1;
%---------------------------------------------------------------------------
% Set up spatial approximation scheme.
schemeFunc = @termConvection;
schemeData.grid = g;
schemeData.velocity = VecField;

%---------------------------------------------------------------------------
% Set up time approximation scheme.
integratorOptions = odeCFLset('factorCFL', 0.75, 'stats', 'on');

% Choose approximations at appropriate level of accuracy.
switch(accuracy)
 case 'low'
  schemeData.derivFunc = @upwindFirstFirst;
  integratorFunc = @odeCFL1;
 case 'medium'
  schemeData.derivFunc = @upwindFirstENO2;
  integratorFunc = @odeCFL2;
 case 'high'
  schemeData.derivFunc = @upwindFirstENO3;
  integratorFunc = @odeCFL3;
 case 'veryHigh'
  schemeData.derivFunc = @upwindFirstWENO5;
  integratorFunc = @odeCFL3;
 otherwise
  error('Unknown accuracy level %s', accuracy);
end

%---------------------------------------------------------------------------
% Restrict the Hamiltonian so that reachable set only grows.

if(growOnly)
  innerFunc = schemeFunc;
  innerData = schemeData;
  clear schemeFunc schemeData;

  % Wrap the true Hamiltonian inside the term approximation restriction.
  schemeFunc = @termRestrictUpdate;
  schemeData.innerFunc = innerFunc;
  schemeData.innerData = innerData;
  schemeData.positive = 0;
end

startTime = cputime;
% Reshape data array into column vector for ode solver call.
y0 = phi0(:);
% How far to step?
t0 = 0;                              % Start time.
tSpan = [ t0, EvolutionTime ];
% Take a timestep.
[ ~, y ] = feval(integratorFunc, schemeFunc, tSpan, y0,...
              integratorOptions, schemeData);

% Get back the correctly shaped data array
data = reshape(y, g.shape);
executionTime = cputime - startTime;
fprintf('Enlarge the ROA, execution time %g seconds\n', executionTime);

phiEnlarge = data;