function ROAToolboxOptions = SetProjectOptions()
% Setting the Project Options
% Edit the file to change the options for the underlying system
%
% YUAN Guoqiang, Oct, 2016
%
%% Parameters for creating computational grid
% The dimension of the grid should equal to to number of  state variables
ROAToolboxOptions.GridDimension = 2; 
% The toolboxLS-1.1.1 work best if all the dimension in the problem are
%   approximately the same size: for example, the grid ranges and cell
%   widths should be within an order of magnitude of one another. So the
%   next two parameters should be approximately same.
% The range of each dimension i.e. [x1min, x1max; x2min, x2max; x3min, x3max ...]
ROAToolboxOptions.GridRange = [-6, 6; -6, 6];
% A column vector specifying the size of grid cell in each dimension
%  i.e. [x1cellsize; x2cellsize; x3cellsize ...]
% ROAToolboxOptions.GridCellSize = [0.01; 0.01]; % will take a long time
ROAToolboxOptions.GridCellSize = [0.1; 0.1]; % will quiet quick
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
ROAToolboxOptions.InitCircleCen = [0; 0];

%% Parameters for integrating
% End time for integrate.
ROAToolboxOptions.IntegratorTime = 10;
% Period at which intermediate results should be produced.
ROAToolboxOptions.IntegratorShowTime = 2;

%% Set computational accuracy
% accuracy     Controls the order of approximations.
%    one of:  'low', 'medium', 'high', 'veryHigh'             
ROAToolboxOptions.accuracy = 'medium';

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
%% ---------Modify according to the undetlying system------------
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
    [x1, x2] = xs{:};
       % The  dynamics equation
    % Use Element-wise operator
    x1dot = - sin(x1) - 0.5 * sin(x1 - x2) + 0.01;
    x2dot = - 0.5 * sin(x2) - 0.5 * sin(x2 - x1) + 0.05;
        
    VectorField = { x1dot;   x2dot};
    % -----------------------------------------------------------------------    
    % -----------------------------------------------------------------------    
else   % scalar
    % Do not change
    % recursion
    VectorField = cell2mat (GenVecField( num2cell(xs) ));
end
