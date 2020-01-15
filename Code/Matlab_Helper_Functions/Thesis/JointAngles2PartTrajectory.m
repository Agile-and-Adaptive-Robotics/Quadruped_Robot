function [ ps ] = JointAngles2PartTrajectory( S, M, L, thetas )
%This function takes in the link lengths and motor angles for a robotic arm
%and outputs the position of each point of interest along the arm.

%Preallocate a matrix to store the data points.
ps = deal( zeros(3, size(thetas, 2), size(M, 3)) );

%Solve the forward kinematics problem.
for k1 = 1:size(thetas, 2)          %Iterate through each joint angle...
    
    %Solve the forward kinematics problem for this angle.
    for k2 = 1:size(M, 3)                   %Iterate through each of the joints...

        %Determine whether to solve the forward kinematics problem.
        if (L(k2) ~= 0)                                                             %If there are screw axes to apply...
            nT = FKinSpace(M(:, :, k2), S(:, 1:L(k2)), thetas(1:L(k2), k1));        %Solve the forward kinematics problem.
        else                                                                        %Otherwise...
            nT = M(:, :, k2);                                                       %This orientation does not change.
        end
        
        %Extract the joint positions.
        ps(:, k1, k2) = nT(1:3, 4);
        
    end
    
end

end
