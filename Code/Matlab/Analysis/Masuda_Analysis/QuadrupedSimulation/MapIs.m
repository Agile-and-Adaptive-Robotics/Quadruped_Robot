function [Ijoints_cumulative_local, Pcms_cumulative_global] = MapIs(ms, Icms_local, Tcms_global, Tjoints_global)

% Throw an error if there is more than one point per body.
if size(Tcms_global, 3) ~= 1        % If there is not one point per body...
    
    % Throw an error stating that there may only be one point per body.
    error('When mapping moments of inertia, there must be only one point (the COM) per body.')
    
end

% Retrieve size information from the inputs.
num_bodies = size(Tcms_global, 4);
num_timesteps = size(Tcms_global, 5);

% Compute the cumulative mass of the bodies.
ms_cumulative = flipud(cumsum(flipud(ms)));

% Retrieve the rotational and translational components associated with the given transformation matrices.
[Rcms_global, Pcms_global] = TransToRpAllBodies(Tcms_global);
[Rjoints_global, Pjoints_global] = TransToRpAllBodies(Tjoints_global);

% Initialize a matrix to store the moment of inertia of each body about their center of mass in the global frame.
Icms_global = zeros(size(Rcms_global));

% Convert the local moments of inertia into the global frame.
for k1 = 1:num_timesteps             % Iterate through each of the time steps...
    for k2 = 1:num_bodies            % Iterate through each of the bodies...
        
        % Compute the global moment of inertia of each body about their center of mass.
        Icms_global(:, :, 1, k2, k1) = RotateMomentOfInertia( Icms_local(:, :, k2), Rcms_global(:, :, 1, k2, k1) );
        
    end
end

% Initialize a tensor to store the center of mass locations in the global frame for bodies 1,...,n , 2,...,n , 3,...,n, etc.
Pcms_cumulative_global = zeros(size(Pcms_global));

% Compute the center of mass locations in the global frame for bodies 1,...,n , 2,...,n , 3,...,n, etc.
for k1 = 1:num_timesteps            % Iterate through each of the time steps...
    for k2 = 1:num_bodies           % Iterate through each of the bodies...
        
        % Define the body indexes.
        body_indexes = k2:size(Pcms_global, 3);
        
        % Retrieve the relevant COMs for this time step.
        Ps_crit = reshape(Pcms_global(:, 1, body_indexes, k1), [size(Pcms_global, 1) length(body_indexes)]);
        
        % Compute the center of mass location for the given points.
        Pcms_cumulative_global(:, 1, k2, k1) = GetCenterOfMass(Ps_crit, ms(body_indexes));
        
    end
end

% Initialize a tensor to store the cumulative moments of inertia at the center of mass in the global frame.
% Icms_cumulative_global = zeros([size(Icms_global), num_timesteps]);
Icms_cumulative_global = zeros(size(Icms_global));

% Compute the cumulative moments of inertia at the center of mass in the global frame.
for k1 = 1:num_timesteps            % Iterate through each time step...
    for k2 = 1:num_bodies           % Iterate through each body...
        for k3 = k2:num_bodies      % Iterate through each of the bodies that are relevant to this body...
            
            % Compute the position of the cumulative center of mass with respect to this body's center of mass.
            dP = Pcms_cumulative_global(:, 1, k2, k1) - Pcms_global(:, 1, k3, k1);
            
            % Compute the cumulative moments of inertia at the center of mass in the global frame.
            %             Icms_cumulative_global(:, :, k2, k1) = Icms_cumulative_global(:, :, k2, k1) + TranslateMomentOfInertia(Icms_global(:, :, k3), ms(k3), dP);
            Icms_cumulative_global(:, :, 1, k2, k1) = Icms_cumulative_global(:, :, 1, k2, k1) + TranslateMomentOfInertia(Icms_global(:, :, 1, k3, k1), ms(k3), dP);
            
        end
    end
end

% Initialize a tensor to store the cumulative moments of inertia at the joint locations in the global frame.
Ijoints_cumulative_global = zeros(size(Icms_cumulative_global));

% Compute the cumulative moments of inertia at the joint locations in the global frame.
for k1 = 1:num_timesteps
    for k2 = 1:num_bodies
        
        % Compute the position of the relevant joint with respect to the cumulative center of mass of this body in the global frame.
        dP = Pjoints_global(:, 1, k2, k1) - Pcms_cumulative_global(:, 1, k2, k1);
        
        % Compute the cumulative moment of inertia at this joint location in the global frame.
        Ijoints_cumulative_global(:, :, 1, k2, k1) = TranslateMomentOfInertia(Icms_cumulative_global(:, :, 1, k2, k1), ms_cumulative(k2),dP);
        
    end
end

% Initialize a tensor to store the moment of inertia of the structure about each joint in the local frame.
Ijoints_cumulative_local = zeros(size(Ijoints_cumulative_global));

% Convert the global cumulative moments of inertia at the joints to the local frame.
for k1 = 1:num_timesteps            % Iterate through each time step...
    for k2 = 1:num_bodies            % Iterate through each of the bodies...

        % Compute the global moment of inertia of each body about their center of mass.
        Ijoints_cumulative_local(:, :, 1, k2, k1) = RotateMomentOfInertia( Ijoints_cumulative_global(:, :, 1, k2, k1), Rcms_global(:, :, 1, k2, k1)' );

    end
end

end

