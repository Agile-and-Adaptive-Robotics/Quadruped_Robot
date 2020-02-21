function [xep, fval, exitflag, lambda] = SearchForEP(ProjectOptions, x0)
% Search for the equilibrium point of the system from a point x0.
% Parameters:
%   xep    the quilibrium point found
%   fval    the function value of xep
%   exitflag        from fsolve
%   lambda    eigvalues respect to xep
%
% YUAN Guoqiang, Oct, 2016
%
OPTIONS = optimset( 'TolFun',1e-12,'TolX',1e-12);
hfx = ProjectOptions.VectorFieldOperator; 
[xep, fval, exitflag, ~, jacobian] = fsolve(hfx, x0, OPTIONS);
lambda = eig(jacobian);
