function eq_points = GetNetworkEquilibriumPoints(eq0, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapp)

% This function computes the equilibrium points of a network defined by the given network properties by starting a numerical search at eq0.

% Solve for the equilibrium points.
eq_points = fsolve(@(xs) NetworkFunc(xs), eq0);

    % Implement a function that computes a single network step with the correct stacked network states.
    function dxs = NetworkFunc(xs)
        
        % Retrieve the individual network states.
        Us = xs(1:2); hs = xs(3:4);
        
        % Compute one step of the network.
        [dUs, dhs] = NetworkStep(Us, hs, Gms, Cms, Rs, gsyn_maxs, dEsyns, Ams, Sms, dEms, Ahs, Shs, dEhs, tauh_maxs, Gnas, dEnas, Iapp);
        
        % Concatenate the states for output.
        dxs = [dUs; dhs];
        
    end

end

