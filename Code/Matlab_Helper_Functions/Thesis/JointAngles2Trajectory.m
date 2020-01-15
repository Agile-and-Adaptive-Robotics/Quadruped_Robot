function [ ps ] = JointAngles2Trajectory( S, M, thetas )
%This function takes in the link lengths and motor angles for a robotic arm
%and outputs the position of each point of interest along the arm.

%Preallocate a matrix to store the data points.
ps = deal( zeros(3, size(thetas, 2), size(M, 3) - 1) );

%Iterate through all of the possible joint angles.
for k1 = 1:size(thetas, 2)
    
    %Define a indexing variable for determining which screws are applied to which joints.
    loc = 1;
    
    %Solve the forward kinematics problem.
    for k2 = 1:(size(M, 3)-1)                   %Iterate through each of the joints...
%     for k2 = 1:size(M, 3)                   %Iterate through each of the joints...

        %Determine whether we have another screw axis to apply.
        if (loc < size(S, 2))                %If we have not run out of screw axes...
            %Advance the indexing variable.
            loc = loc + 1;
        end
        
        %Solve the forward kinematics problem.
        nT = FKinSpace(M(:, :, k2+1), S(:, 1:loc), thetas(1:loc, k1));
%         nT = FKinSpace(M(:, :, k2), S(:, 1:loc), thetas(1:loc, k1));

        %Extract the joint positions.
        ps(:, k1, k2) = nT(1:3, 4);
        
    end
    
end

end
