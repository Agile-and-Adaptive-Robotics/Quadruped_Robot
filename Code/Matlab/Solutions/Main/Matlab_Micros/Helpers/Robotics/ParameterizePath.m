function [ Ts ] = ParameterizePath( T_start, T_end, n, Type )

%This function takes two orientations T_start and T_end and interpolates n intermediate orientations via a method defined by Type.
%This allows one to specify starting and ending orientations that are distant from one another and automatically generate a trajectory between them.
%Type = 'Linear' makes the translation interpolation linear (i.e., the path from the starting orientation to the ending orientation will be straight).
%Type = 'Screw' makes the translation interpolation curved (typically in the shape of a helix).  This tends to be "easier" for the kinematic chain to achieve, but is perhaps less predictable.

%% Set Default Inputs.

%Set the default arguments.
if nargin < 4, Type = 'Screw'; end              %Set the interpolation type to 'Screw'.
if nargin < 3, n = 100; end                     %Set the number of points to be 100.

%% Compute the Transformation Matrix dT.

%Compute the transformation matrix that maps from the starting orientation to the ending orientation.
T = T_end/T_start;

%Get the axis and angle of rotation associated with the rotation matrix.
[ S, theta ] = GetTransAxis( T );

%Divid the angle of rotation into smaller components.
dtheta = theta/(n - 1);

%Compute the associated rotation matrix.
dT = GetTransMatrix( S, dtheta );

%% Compute the Orientations at each Step.

%Prellocate a multidimensional matrix to store the orientations at each point.
Ts = zeros(size(T_start, 1), size(T_start, 2), n);

%Initialize the first orientation to be the provided starting position.
Ts(:, :, 1) = T_start;

%Iterate through all of the intermediate orientations.
for k = 1:(n - 1)
    %Store each intermediate orientation.
    Ts(:, :, k + 1) = dT*Ts(:, :, k);
end

%% Linearize the Translation Path (if necessary).

%Determine whether it is necessary to linearize the path.
if strcmp(Type, 'Linear') && (~isequal(T(1:3, 1:3), eye(3)))            %If the Type is set to linear and the rotational component of the transformation matrix is not the identity matrix (in which case the path would already be linear)...
    
    %Retrieve the desired starting & ending position.
    [P_start, P_end] = deal( T_start(1:3, 4), T_end(1:3, 4) );
    
    %Parameterize the path linearly.
    Ps = ParameterizeLinearPath( P_start, P_end, n );
    
    %Update the transformation matrices to reflect the linear path.
    for k = 1:size(Ps, 2)       %Iterate through all of the linear interpolated points...
        %Replace the translation values in the original transformation matrices.
        Ts(1:3, 4, k) = Ps(:, k);
    end
end

end
