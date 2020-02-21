function ROAToolboxOptions = SetProjectOptions()
% Setting the Project Options
% Edit the file to change the options for the underlying system
%
% YUAN Guoqiang, Oct, 2016
%
%% Parameters for creating computational grid
% The dimension of the grid should equal to to number of  state variables
ROAToolboxOptions.GridDimension = 3; 
% The toolboxLS-1.1.1 work best if all the dimension in the problem are
%   approximately the same size: for example, the grid ranges and cell
%   widths should be within an order of magnitude of one another. So the
%   next two parameters should be approximately same.
% The range of each dimension i.e. [x1min, x1max; x2min, x2max; x3min, x3max ...]
ROAToolboxOptions.GridRange = [-3, 3; -3, 3; -3, 3];
% A column vector specifying the size of grid cell in each dimension
%  i.e. [x1cellsize; x2cellsize; x3cellsize ...]
% ROAToolboxOptions.GridCellSize = [0.05; 0.05; 0.05]; % high accuracy
ROAToolboxOptions.GridCellSize = [0.2; 0.2; 0.2];
% A column vector specifying the number of grid nodes in each dimension.
%   this parameter can be automatically generated from GridRange and
%   GridCellSize.
% ROAToolboxOptions.GridNodeNumber = [101; 101];

%% Initial condition
% In the version we use a circle as the initial condition because it always work well enough.
%   The initial circle is an initial estimate of the ROA
%   InitCircleRad is the  Radius of initial circle (positive).
%   InitCircleCen is the  center of initial circle (column vector [x1; x2; x3 ...]).
ROAToolboxOptions.InitCircleRad = 1;
ROAToolboxOptions.InitCircleCen = [ 0; 0; 0 ];

%% Parameters for integrating
% End time for integrate.
ROAToolboxOptions.IntegratorTime = 0.5;
% Period at which intermediate results should be produced.
ROAToolboxOptions.IntegratorShowTime = 0.1;

%% Set computational accuracy
% accuracy     Controls the order of approximations.
%    one of:  'low', 'medium', 'high', 'veryHigh'             
ROAToolboxOptions.accuracy = 'low';

%% System equation
ROAToolboxOptions.VectorFieldOperator = @(x) GenVecField( x ); 

%% For efficient, do not change
% ----------do not change -----------------
ROAToolboxOptions.Grid = GenerateGrid(ROAToolboxOptions);
fx = ROAToolboxOptions.VectorFieldOperator;
ROAToolboxOptions.VectorField = fx(ROAToolboxOptions.Grid.xs);
initialRadius = ROAToolboxOptions.InitCircleRad;
initialCenter = ROAToolboxOptions.InitCircleCen;
phi0 = shapeSphere(ROAToolboxOptions.Grid, initialCenter, initialRadius);
ROAToolboxOptions.InitialCondition = phi0;
% --------------------------------------------


%% System equation, 
function VectorField = GenVecField( xs )
% ---------Modify according to the undetlying system------------
% Compute the vector field of the system.
% This function should be element-wise.
% Parameters:
% xs is either a cell(n*1) contain n members each of which is a
%   multidimansional array, or a n*1 array containing the state variable.
% VectorField is the same type as xs.
%
% YUAN Guoqiang, Oct, 2016
%
if iscell(xs)  % element-wise
    % -----------------------------------------------------------------------
    % ---------Modify according to the undetlying system------------
    [x1, x2, x3] = xs{:};
    % The  dynamics equation
    % Use Element-wise operator
    mu  = 12;
    squsum = x1 .^2 + x2 .^2;
    comm = mu + squsum - squsum .^2;

    x1dot =  -(x1 .* comm - x2);
    x2dot =  -(x2 .* comm + x1);
    x3dot =  -mu * x3;
        
    VectorField = { x1dot;  x2dot; x3dot };
    % -----------------------------------------------------------------------    
    % -----------------------------------------------------------------------    
else   % scalar
    % Do not change
    % recursion
    VectorField = cell2mat (GenVecField( num2cell(xs) ));
end
