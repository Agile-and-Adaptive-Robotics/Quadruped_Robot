function [ ls ] = JointAngles2GapLengths( S, M, L, thetas, bBackLeg )
%This function computes the gap lengths between the muscle attachment points where the muscles will be attached at given the joint angles.

%% Set the Default Options.

%Set the default options.
if nargin < 5, bBackLeg = false; end

%% Compute the Gap Lengths

%Compute the point paths.
Ps = JointAngles2PartTrajectory( S, M, L, thetas );

%Preallocate a variable to store the muscle lengths.
ls = zeros(6, size(Ps, 2));

%Compute the muscle lengths.
for k = 1:size(Ps, 2)                   %Iterate through the points at each angle.

    %Reshape the point paths.
    ps = reshape(Ps(:, k, :), [size(Ps, 1) size(Ps, 3), 1]);
    
    %Compute the extensor muscle lengths.
    l_hip_ext = norm(ps(:, 8 - bBackLeg) - ps(:, 6 - bBackLeg), 2);
%     l_knee_ext = norm(ps(:, 12 - bBackLeg) - ps(:, 10 - bBackLeg), 2);                %WITH PULLEYS.
    l_knee_ext = norm(ps(:, 18 - bBackLeg) - ps(:, 10 - bBackLeg), 2);                  %WITH PULLEYS.
%     l_ankle_ext = norm(ps(:, 16 - bBackLeg) - ps(:, 14 - bBackLeg), 2);               %WITHOUT PULLEYS.
    l_ankle_ext = norm(ps(:, 19 - bBackLeg) - ps(:, 14 - bBackLeg), 2);                 %WITH PULLEYS.

    %Compute the flexor muscle lengths.
    l_hip_flx = norm(ps(:, 9 - bBackLeg) - ps(:, 7 - bBackLeg), 2);
%     l_knee_flx = norm(ps(:, 13 - bBackLeg) - ps(:, 11 - bBackLeg), 2);                %WITHOUT PULLEYS.
    l_knee_flx = norm(ps(:, 20 - bBackLeg) - ps(:, 11 - bBackLeg), 2);                  %WITH PULLEYS.
%     l_ankle_flx = norm(ps(:, 17 - bBackLeg) - ps(:, 15 - bBackLeg), 2);               %WITHOUT PULLEYS.
    l_ankle_flx = norm(ps(:, 21 - bBackLeg) - ps(:, 15 - bBackLeg), 2);                 %WITH PULLEYS.

    %Store the muscle lengths into a matrix.
    ls(:, k) = [l_hip_ext; l_knee_ext; l_ankle_ext; l_hip_flx; l_knee_flx; l_ankle_flx];
    
end

end

