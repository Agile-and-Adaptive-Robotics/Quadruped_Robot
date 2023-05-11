function Ts_rel = TSpace2TRelative(Ts_space)

% This function takes a high order array of transformation matrices defined with respect to the space frame and converts each transformation matrix to be relative to the nearest proximal joint.

% Retrieve the size information associated with the transformation matrix array in the space frame.
num_rows = size(Ts_space, 1);
num_cols = size(Ts_space, 2);
num_joints = size(Ts_space, 3);
num_angles = size(Ts_space, 4);

% Create a high order matrix to store the relative transformation matrices.
Ts_rel = zeros([num_rows, num_cols, num_joints - 1, num_angles]);

% Compute the relative transformation matrix for each joint at each angle.
for k1 = 1:num_angles                           % Iterate through each of the angles...
    for k2 = 1:(num_joints - 1)                 % Iterate through each of the joints less one...

        % Compute the relative transformation matrix for this joint at this angle.
        Ts_rel(:, :, k2, k1) = TwrtT( Ts_space(:, :, k2, k1), Ts_space(:, :, k2 + 1, k1) );
        
    end
end

end

