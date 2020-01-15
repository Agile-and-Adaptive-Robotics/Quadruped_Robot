function T = GetPlaneTransformationMatrix( Ps_plane, Pen_Vector )

%This function takes in three points, Ps_plane, and determines the orientation of the associated plane, T.
%This function also reports the width of the writing area defined by the three points.

%% Compute the Plane Normal & Centroid.

%Define the points of the plane.
[ P1, P2, P3 ] = deal( Ps_plane(:, 1), Ps_plane(:, 2), Ps_plane(:, 3) );

%Retrieve the x, y, & z components of each point.
[xs, ys, zs] = deal( [P1(1) P2(1) P3(1)]', [P1(2) P2(2) P3(2)]', [P1(3) P2(3) P3(3)]' );

%Define two vectors in the plane.
[V1, V2] = deal( P2 - P1, P3 - P1 );

%Compute the plane normal vector.
N = cross(V1, V2);

%Compute the centroid location for the triangle who's vertices are the three points defining the plane.
[x_centroid, y_centroid, z_centroid] = deal( mean(xs), mean(ys), mean(zs) );

%Define the centroid as a column vector.
P_centroid = [x_centroid y_centroid z_centroid]';


%% Determine the Orientation of the Plane with Respect to the Global Coordinate System (i.e., With Respect to the Space Frame).

%Define the space frame basis.
[x0, y0, z0] = deal( [1 0 0]', [0 1 0]', [0 0 1]' );

%Define the z-axis of the plane orientation.
zhat = N/norm(N);

% %Determine whether it is necessary to switch the direction of the z axis.  The cross product above produces the correct z-axis up to the sign of the axis, so the sign may required the correction performed in the following if statement.
% if (dot(zhat, P_centroid) > 0)                           %If the plane normal is pointing away from the origin...
%     zhat = -zhat;                                       %Flip the plane normal.
% elseif (dot(zhat, P_centroid) == 0)                      %If the plane normal is orthogonal to the origin....
%     if ( sign(P_centroid(3) - 7) == sign(zhat(1)) )      %If the vector from the robot base to the centroid has the same sign as the normal...
%         zhat = -zhat;                                   %Flip the plane normal.
%     end
% end

%Determine whether it is necessary to switch the direction of the z axis.  The cross product above produces the correct z-axis up to the sign of the axis, so the sign may required the correction performed in the following if statement.
if (dot(zhat, Pen_Vector) > 0)                           %If the plane normal is pointing away from the origin...
    zhat = -zhat;                                       %Flip the plane normal.
elseif (dot(zhat, Pen_Vector) == 0)                      %If the plane normal is orthogonal to the pen vector....
    if (dot(zhat, P_centroid) > 0)                      %If the plane normal is pointing away from the origin...
        zhat = -zhat;                                   %Flip the plane normal.
    end
end

%THIS METHOD PRODUCES AN UPRIGHT UNDISTORTED IMAGE.
%Compute the quantity by which the z-axis is rotated.
theta = acos(dot(z0, zhat)/(norm(z0)*norm(zhat)));

%Compute the axis of rotation about which the z-axis is rotated.
what = cross(z0, zhat)/norm(cross(z0, zhat));

%Compute the rotation matrix associated with this axis of rotation and angular quantity.
R = GetTransMatrix( what, theta );

%Compute the yhat direction of the plane.
yhat = R\z0;
yhat(3) = 0;
yhat = R*yhat;
yhat = yhat/norm(yhat);

%Compute the xhat direction of the plane.
xhat = cross(yhat, zhat);
xhat = xhat/norm(xhat);



% %THIS TRANSFORMATION APPEARS TO DRAW THE LETTER ON A TITLTED SURFACE SUCH THAT, WHEN LOOKING PERPENDICULAR TO THE DRAWING PLANE, THE LETTER IS DISTORTED, BUT WHEN LOOKING FROM THE SPACE FRAME, THE LETTER LOOKS NORMAL.
% %Project the space frame x-axis onto the plane.  Call this the plane's x-axis.
% x0 =[1 0 0]';                                   %Define the x-axis in Space Frame.
% zhat_mod1 = zhat; zhat_mod1(3) = 0; zhat_mod1 = zhat_mod1/norm(zhat_mod1);
% x0_perp = dot(x0, zhat_mod1)*zhat_mod1;                   %Component of the Space Frame x-axis that is orthogonal to the plane.
% xhat = x0 - x0_perp;                            %Component of the Space Frame x-axis that is parallel to the plane.
% xhat = xhat/norm(xhat);                         %Normalize the plane's x-axis vector.
%
% %Project the space frame z-axis onto the plane.  Call this the plane's y-axis.
% z0 =[0 0 1]';                                   %Define the z-axis in Space Frame.
% zhat_mod2 = zhat; zhat_mod2(1) = 0; zhat_mod2 = zhat_mod2/norm(zhat_mod2);
% z0_perp = dot(z0, zhat_mod2)*zhat_mod2;                   %Component of the Space Frame z-axis that is orthogonal to the plane.
% yhat = z0 - z0_perp;                            %Component of the Space Frame z-axis that is parallel to the plane.
% yhat = yhat/norm(yhat);                         %Normalize the plane's y-axis vector.


%Use the plane's directional unit vectors (xhat, yhat, and zhat) to define its orientation with respect to the space frame.
R_end = [xhat yhat zhat];


%% Compute the Transformation Matrix that Maps from the Space Frame to the Plane.

%Define the orientation of the Space Frame (i.e., just the identify matrix).
R_start = eye(3);

%Compute the rotation matrix from the space frame orientation to the plane's orientation.
R = R_end/R_start;

%Define the Transformation Matrix that maps from the space frame to the plane.
T = [R, P_centroid; zeros(1, size(R, 2)), 1];


end

