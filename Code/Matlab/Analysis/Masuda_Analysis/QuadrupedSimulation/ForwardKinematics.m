function Ts = ForwardKinematics( Ms, Js, Ss, thetas )

% This functions computes the transformation matrices associated with each given home matrix in an open kinematic chain.

% Retrieve information about the size of our input arguments.
num_joints = size(thetas, 1);
num_angles = size(thetas, 2);
num_pts_per_body = size(Ms, 3);
num_bodies = size(Ms, 4);

% Initialize a matrix to store the transformation matrix associated with each of the joints.
Ts = zeros(4, 4, num_pts_per_body, num_bodies, num_angles);

% Compute the transformation matrix associated with each angle and each joint.
for k1 = 1:num_angles                       % Iterate through each of the angles...
    for k2 = 1:num_bodies                       % Iterate through each of the bodies...
        for k3 = 1:num_pts_per_body                   % Iterate through each of the body points...
            
            % Retrieve the applicable joints.
            joint_indexes = 1:Js(k3, k2);
            
            % Determine how to compute the current transformation matrix.
            if ~isempty(joint_indexes)          % If the joint index variable is not empty...
                % Compute the transformation matrix associated with the current joint and the current angles.
                Ts(:, :, k3, k2, k1) = FKinSpace(Ms(:, :, k3, k2), Ss(:, joint_indexes), thetas(joint_indexes, k1));
            else
                % Use the home matrix in place of the current transformation martix.
                Ts(:, :, k3, k2, k1) = Ms(:, :, k3, k2);
            end
            
        end
    end
end

end

