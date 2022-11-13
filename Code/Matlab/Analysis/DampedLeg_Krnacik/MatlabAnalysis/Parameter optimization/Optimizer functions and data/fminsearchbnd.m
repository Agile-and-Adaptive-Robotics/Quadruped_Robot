function [x,fval,exitflag,output] = fminsearchbnd(fun,x0,LB,UB,options,varargin)
%FMINSEARCHBND Multidimensional constrained nonlinear minimization (Nelder-Mead).
%   FMINSEARCHBND attempts to solve problems of the form:
%    min F(X)  subject to:  LB <= X <= UB        (bounds)
%
%   X = FMINSEARCHBND(FUN,X0,LB,UB) starts at X0 and attempts to find a local 
%   minimizer X of the function FUN subject to a set of lower and upper
%   bounds on the design variables, X, so that a solution is found in 
%   the range LB <= X <= UB. Use empty matrices for LB and UB
%   if no bounds exist. Set LB(i) = -Inf if X(i) is unbounded below; 
%   set UB(i) = Inf if X(i) is unbounded above. FUN is a function handle.
%   FUN accepts input X and returns a scalar function value F evaluated at X.
%   X0 can be a scalar, vector or matrix.
%
%   X = FMINSEARCHBND(FUN,X0,LB,UB,OPTIONS)  minimizes with the default
%   optimization parameters replaced by values in the structure OPTIONS, created
%   with the OPTIMSET function.  See OPTIMSET for details. FMINSEARCHBND uses
%   these options: Display, TolX, TolFun, MaxFunEvals, MaxIter, FunValCheck,
%   PlotFcns, and OutputFcn.
%
%   [X,FVAL]= FMINSEARCHBND(...) returns the value of the objective function,
%   described in FUN, at X.
%
%   [X,FVAL,EXITFLAG] = FMINSEARCHBND(...) returns an EXITFLAG that describes 
%   the exit condition of FMINSEARCHBND. Possible values of EXITFLAG and the 
%   corresponding exit conditions are
%
%    1  Maximum coordinate difference between current best point and other
%       points in simplex is less than or equal to TolX, and corresponding 
%       difference in function values is less than or equal to TolFun.
%    0  Maximum number of function evaluations or iterations reached.
%   -1  Algorithm terminated by the output function.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCHBND(...) returns a structure
%   OUTPUT with the number of iterations taken in OUTPUT.iterations, the
%   number of function evaluations in OUTPUT.funcCount, the algorithm name 
%   in OUTPUT.algorithm, and the exit message in OUTPUT.message.
%
%   Examples
%     FUN can be specified using @:
%        X = fminsearchbnd(@sin,3)
%     finds a minimum of the SIN function near 3.
%     In this case, SIN is a function that returns a scalar function value
%     SIN evaluated at X.
%
%     FUN can be an anonymous function:
%        X = fminsearchbnd(@(x) norm(x),[1;2;3])
%     returns a point near the minimizer [0;0;0].
%
%     FUN can be a parameterized function. Use an anonymous function to
%     capture the problem-dependent parameters:
%        f = @(x,c) x(1).^2+c.*x(2).^2;  % The parameterized function.
%        c = 1.5;                        % The parameter.
%        X = fminsearchbnd(@(x) f(x,c),[0.3;1])
%        
%   FMINSEARCHBND uses the Nelder-Mead simplex (direct search) method.
%
%   See also OPTIMSET, FMINBND, FUNCTION_HANDLE.

%   Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
%   Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
%   Method in Low Dimensions", SIAM Journal of Optimization, 9(1):
%   p.112-147, 1998.

% size checks
xsize = size(x0);
x0 = x0(:);
n = length(x0);

if (nargin < 3) || isempty(LB)
    LB = -inf(n,1);
else
    LB = LB(:);
end

if (nargin < 4) || isempty(UB)
    UB = inf(n,1);
else
    UB = UB(:);
end

if (n ~= length(LB)) || (n ~= length(UB))
    error('X0 is incompatible in size with either LB or UB.')
end

% set default options if necessary
if (nargin < 5) || isempty(options)
    options = optimset('fminsearch');
end

% stuff into a struct to pass around
params.args = varargin;
params.LB   = LB;
params.UB   = UB;
params.fun  = fun;
params.n    = n;
% note that the number of parameters may actually vary if 
% a user has chosen to fix one or more parameters
params.xsize     = xsize;
params.OutputFcn = [];

% 0 --> unconstrained variable
% 1 --> lower bound only
% 2 --> upper bound only
% 3 --> dual finite bounds
% 4 --> fixed variable

params.BoundClass = zeros(n,1);

for i = 1:n
    k = isfinite(LB(i)) + 2*isfinite(UB(i));
    params.BoundClass(i) = k;
    if (k == 3) && (LB(i) == UB(i))
        params.BoundClass(i) = 4;
    end
end

% transform starting values into their unconstrained
% surrogates. Check for infeasible starting guesses.

x0u = x0;
k   = 1;

for i = 1:n
    switch params.BoundClass(i)
        case 1
            % lower bound only
            if x0(i) <= LB(i)
            % infeasible starting value. Use bound.
                x0u(k) = -Inf;
            else
                x0u(k) = log(x0(i) - LB(i));
            end
      
            % increment k
            k = k+1;
        case 2
            % upper bound only
            if x0(i) >= UB(i)
                % infeasible starting value. use bound.
                x0u(k) = -Inf;
            else
                x0u(k) = log(UB(i) - x0(i));
            end
      
            % increment k
            k = k+1;
        case 3
            % lower and upper bounds
            if x0(i) <= LB(i)
                % infeasible starting value
                x0u(k) = -Inf;
            elseif x0(i) >= UB(i)
                % infeasible starting value
                x0u(k) = -Inf;
            else
                x0u(k) = -log((UB(i) - LB(i)) ./ (x0(i) - LB(i)) - 1);
            end

            % increment k
            k = k+1;
        case 0
            % unconstrained variable. x0u(i) is set.
            x0u(k) = x0(i);

            % increment k
            k = k+1;
        case 4
            % fixed variable. drop it before fminsearch sees it.
            % k is not incremented for this variable.
    end
  
end

% if any of the unknowns were fixed, then we need to shorten x0u.
if k <= n
  x0u(k:n) = [];
end

% were all the variables fixed?
if isempty(x0u)
    % All variables were fixed. quit immediately, setting the
    % appropriate parameters, then return.

    % undo the variable transformations into the original space
    x = xtransform(x0u,params);

    % final reshape
    x = reshape(x,xsize);

    % stuff fval with the final value
    fval = feval(params.fun,x,params.args{:});

    % fminsearchbnd was not called
    exitflag = 0;

    output.iterations = 0;
    output.funcCount = 1;
    output.algorithm = 'fminsearch';
    output.message = 'All variables were held fixed by the applied bounds';

    % return with no call at all to fminsearch
    return
end

% Check for an outputfcn. If there is any, then substitute my
% own wrapper function.
if ~isempty(options.OutputFcn)
    params.OutputFcn  = options.OutputFcn;
    options.OutputFcn = @outfun_wrapper;
end

% now we can call fminsearch, but with our own
% intra-objective function.
[xu,fval,exitflag,output] = fminsearch(@intrafun,x0u,options,params);

% undo the variable transformations into the original space
x = xtransform(xu,params);

% final reshape to make sure the result has the proper shape
x = reshape(x,xsize);

%-------------------------------------------------------------------------%
%                              Helper functions                           %
%-------------------------------------------------------------------------%

% Use a nested function as the OutputFcn wrapper
function stop = outfun_wrapper(x,varargin)
% we need to transform x first
xtrans = xtransform(x,params);

% then call the user supplied OutputFcn
stop = params.OutputFcn(xtrans,varargin{1:(end-1)});

%-------------------------------------------------------------------------%

function fval = intrafun(x,params)
% transform variables, then call original function

% transform
xtrans = xtransform(x,params);

% and call fun
fval = feval(params.fun,reshape(xtrans,params.xsize),params.args{:});

%-------------------------------------------------------------------------%

function xtrans = xtransform(x,params)
% converts unconstrained variables into their original domains

xtrans = zeros(params.xsize);
% k allows some variables to be fixed, thus dropped from the
% optimization.
k = 1;

for i = 1:params.n
    switch params.BoundClass(i)
    case 1
        % lower bound only
        xtrans(i) = params.LB(i) + exp(x(k));

        k = k+1;
    case 2
        % upper bound only
        xtrans(i) = params.UB(i) - exp(x(k));

        k = k+1;
    case 3
        % lower and upper bounds
        xtrans(i) = params.LB(i) + (params.UB(i) - params.LB(i)) ./ (1 + exp(-x(k)));
        k = k+1;
    case 4
        % fixed variable, bounds are equal, set it at either bound
        xtrans(i) = params.LB(i);
    case 0
        % unconstrained variable.
        xtrans(i) = x(k);

        k = k+1;
    end
end