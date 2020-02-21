function [ theta_cont, mpos_cont ] = GetControllerMotorAngles( S, M, thetac, xbox_controller, dtol, move_size, move_sensitivity, eomg, ev  )

%% Setup the Space Frame Axes.

%Define the space frame unit axes.
[xhat, yhat, zhat] = deal( [1 0 0]', [0 1 0]', [0 0 1]' );

%% Compute the Current Orientation.

%Retrieve the current orientation of the end effector.
Tc = FKinSpace(M(:, :, end), S, thetac);

%Get the current position & orientation from the current transformation matrix.
[ ~, pc ] = TransMatrix2Rp( Tc );

%% Read & Interpret Input from the Controller.

%Get the translational input from the controller.
[dx_scl, dy_scl, dz_scl] = deal( round(axis(xbox_controller, 1), move_sensitivity), round(-axis(xbox_controller, 3), move_sensitivity), round(-axis(xbox_controller, 2), move_sensitivity) );

%Get the rotational input from the controller.
[dtx_scl, dtz_scl] = deal( round(axis(xbox_controller, 5), move_sensitivity), round(axis(xbox_controller, 4), move_sensitivity) );

%Determine the translational step size to apply.
[dx, dy, dz] = deal( dx_scl*move_size*dtol, dy_scl*move_size*dtol, dz_scl*move_size*dtol );

%Determine the rotational step size in the x & z directions.
[dtx, dtz] = deal( dtx_scl*move_size*dtol, dtz_scl*move_size*dtol );

%Determine the rotational step size in the y direciton.
if button(xbox_controller, 6) == 1              %If the right bumper is pressed...
    dty = move_size*dtol;                                 %Set the y axis rotation to be positive.
elseif button(xbox_controller, 5) == 1          %If the left bumper is pressed...
    dty = -move_size*dtol;                                %Set the y axis rotation to be negative.
else                                            %If neither bumper is pressed...
    dty = 0;                                    %Set the y axis rotation to be zero.
end

%         %Hardwire the translational and rotational displacements.  This is useful for debugging.
%         [dx, dy, dz] = deal( 0, 0, -0.25 );
%         [dtx, dty, dtz] = deal( 0, 0, 0 );
dtz = 0;

%% Compute the Transformation Matrix Associated with the Desired Position & Orientation.

%Compute the displacement vector to apply.
pm = [dx; dy; dz];

%Define the translation component of the transformation matrix that maps to the desired position.
Transm = Rp2TransMatrix( eye(3), pm );

%Compute the rotation matrices associated with the angle changes.
[Rx, Ry, Rz] = deal( GetTransMatrix( xhat, dtx ), GetTransMatrix( yhat, dty ), GetTransMatrix( zhat, dtz ) );

%Elevate the rank of the rotation matrices.
[Rx, Ry, Rz] = deal( [Rx zeros(size(Rx, 1), 1); zeros(1, size(Rx, 2)) 1], [Ry zeros(size(Ry, 1), 1); zeros(1, size(Ry, 2)) 1], [Rz zeros(size(Rz, 1), 1); zeros(1, size(Rz, 2)) 1] );

%Define the translation matrix associated with the current position.
Transc = Rp2TransMatrix( eye(3), pc );

%Compute the rotational component of the transformation matrix that maps to the desired orientation.
Rm = Transc*Rx*Ry*Rz*inv(Transc);                   %THIS MAY NEED TO BE REVISTED.  STILL NOT WORKING CORRECTLY.

%Compute the transformation matrix that maps the current position to the desired position.
Tm = Transm*Rm;

%Compute the new position and orientation.
Td = Tm*Tc;

%% Parameterize the Path.

%Parameterize the path from the current position to the desired first letter position with the specified number of subdivisions.
Ts = DescritizePath( cat(3, Tc, Td), move_size*dtol, 'Linear' );

%Throw out the first orientation.
Ts(:, :, 1) = [];

%Compute the motor angles along this path.
[ theta_cont, mpos_cont ] = Trajectory2MotorAngles( S, M, Ts, thetac, eomg, ev );


end

