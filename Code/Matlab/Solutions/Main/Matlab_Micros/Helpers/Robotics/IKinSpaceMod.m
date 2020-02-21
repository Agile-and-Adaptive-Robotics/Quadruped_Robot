%*** CHAPTER 6: INVERSE KINEMATICS ***

function [theta0, success] = IKinSpaceMod(S, M, T, theta0, tol)
% Takes Slist: The joint screw axes in the space frame when the manipulator
%              is at the home position,
%       M: The home configuration of the end-effector,
%       T: The desired end-effector configuration Tsd,
%       thetalist0: An initial guess of joint angles that are close to
%                   satisfying Tsd,
%       eomg: A small positive tolerance on the end-effector orientation
%             error. The returned joint angles must give an end-effector
%             orientation error less than eomg,
%       ev: A small positive tolerance on the end-effector linear position
%           error. The returned joint angles must give an end-effector
%           position error less than ev.
% Returns thetalist: Joint angles that achieve T within the specified
%                    tolerances,
%         success: A logical value where TRUE means that the function found
%                  a solution and FALSE means that it ran through the set
%                  number of maximum iterations without finding a solution
%                  within the tolerances eomg and ev.
% Uses an iterative Newton-Raphson root-finding method.
% The maximum number of iterations before the algorithm is terminated has
% been hardcoded in as a variable called maxiterations. It is set to 20 at
% the start of the function, but can be changed if needed.

%Define the target position.
p = T(1:3, 4);

%Initialize a counter for the while loop.
i = 0;

%Set the maximum number of iterations to perform.
maxiterations = 1e6;

%Compute the starting orientation.
nT = FKinSpace(M, S, theta0);

%Retrieve the location associated with the starting orientation.
np = nT(1:3, 4);

%Compute the initial error.
err = p - np;

%Compute the initial error magnitude.
errmag = norm(err);


%Perform the inverse kinematics calculations.
while (errmag > tol) && (i < maxiterations)                %While error is too large and the maximum number of iterations is not met...
    
    %Advance the counter.
    i = i + 1;
    
    %Compute the jacobian.
    J = JacobianSpace(S, theta0);
    
    %Compute the pseudoinverse of the jacobian.
    Jpinv = pinv(J);
    
    %Use only part of the pseudoinverse.
    Jpinv = Jpinv(:, 4:6);
    
    %Compute the next theta value.
    theta0 = theta0 + Jpinv * err;
    
    %Compute the new orientation.
    nT = FKinSpace(M, S, theta0);
    
    %Retrieve the location of the new point.
    np = nT(1:3, 4);
    
    %Compute the error.
    err = p - np;
    
    %Compute the error magnitude.
    errmag = norm(err);
    
end

%Determine whether the loop ended due to the tolerance being met.
success = errmag <= tol;

end
